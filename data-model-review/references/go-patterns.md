# Go Data Model Patterns

Complete pattern catalog for making invalid states unrepresentable in Go.

## Branded Types

### Alias Branding (Lightweight)

Use when you need compile-time distinction but no runtime validation.

```go
type UserID string
type Email string
type OrderID string
type PriceInCents int64

// Accidental substitution is caught at compile time:
func SendEmail(to Email, body string) error { ... }

// This compiles:
SendEmail(Email("user@example.com"), "hello")

// This does NOT compile:
SendEmail(UserID("user123"), "hello") // compile error: cannot use UserID as Email
```

### Struct Wrapping (Strong Branding)

Use when you need runtime validation or the zero value must be invalid.

```go
type UserID struct {
    value string
}

func NewUserID(raw string) (UserID, error) {
    if raw == "" {
        return UserID{}, errors.New("userID cannot be empty")
    }
    if len(raw) > 64 {
        return UserID{}, errors.New("userID too long")
    }
    return UserID{value: raw}, nil
}

func (id UserID) String() string { return id.value }
func (id UserID) IsZero() bool   { return id.value == "" }
```

**When to choose which:**

| Concern             | Alias `type X string` | Struct Wrapper            |
| ------------------- | --------------------- | ------------------------- |
| Zero value valid?   | Yes (empty string)    | No (constructor required) |
| Runtime validation? | No                    | Yes                       |
| JSON marshaling     | Trivial               | Needs custom MarshalJSON  |
| DB scanning         | Works directly        | Needs Valuer/Scanner      |
| Performance         | Zero overhead         | One pointer indirection   |
| Method set          | None (unless added)   | Rich                      |

## Interface-Based Unions (Closed Unions)

The Go idiom for "exactly one of these states." Uses an unexported method tag.

```go
type Order interface {
    order() // unexported — only this package can implement
    ID() OrderID
    CreatedAt() time.Time
}

type PendingOrder struct {
    id        OrderID
    createdAt time.Time
    items     []LineItem
}

func (PendingOrder) order() {}
func (p PendingOrder) ID() OrderID      { return p.id }
func (p PendingOrder) CreatedAt() time.Time { return p.createdAt }
func (p PendingOrder) Items() []LineItem     { return p.items }

type PaidOrder struct {
    id        OrderID
    createdAt time.Time
    paidAt    time.Time
    items     []LineItem
}

func (PaidOrder) order() {}
func (p PaidOrder) ID() OrderID           { return p.id }
func (p PaidOrder) CreatedAt() time.Time  { return p.createdAt }
func (p PaidOrder) PaidAt() time.Time     { return p.paidAt }
func (p PaidOrder) Items() []LineItem     { return p.items }

// A CancelledOrder can exist too — the union is exhaustive.
type CancelledOrder struct { /* ... */ }
func (CancelledOrder) order() {}
```

**Consumption with type switch:**

```go
func ProcessOrder(o Order) error {
    switch order := o.(type) {
    case PendingOrder:
        return chargePayment(order)
    case PaidOrder:
        return fulfillOrder(order)
    case CancelledOrder:
        return sendCancellationEmail(order)
    default:
        return fmt.Errorf("unknown order type: %T", o)
    }
}
```

**Important:** The `default` case in a type switch on a closed union should never execute in production code. If it does, someone added a new variant without updating the switch. Treat this as a build-breaker bug.

## Generics

### Pagination

```go
type Page[T any] struct {
    Items []T
    Total int
    Page  int
    Size  int
}

func (p Page[T]) HasNext() bool { return p.Page*p.Size < p.Total }
func (p Page[T]) Offset() int  { return (p.Page - 1) * p.Size }
```

### API Results

```go
type Result[T any] struct {
    Data  T
    Meta  ResponseMeta
}

type ResultOrError[T any] struct {
    Data  T
    Error *ErrorDetail
}
```

### Constraints

```go
type Identifiable interface {
    ~string // any string alias
}

type Repository[T any, ID Identifiable] interface {
    Find(ctx context.Context, id ID) (T, error)
    Save(ctx context.Context, entity T) error
    Delete(ctx context.Context, id ID) error
}
```

## Composition via Embedding

### Timestamped Base

```go
type Timestamped struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

func (t *Timestamped) Touch() {
    t.UpdatedAt = time.Now()
}

type Customer struct {
    ID    CustomerID
    Email Email
    Name  string
    Timestamped // embedded
}

// Usage:
c := Customer{...}
c.Touch() // promoted method from Timestamped
```

### Versioned Base

```go
type Versioned struct {
    Version int
}

func (v *Versioned) Bump() {
    v.Version++
}
```

**Warning:** Embedding is not inheritance. It promotes fields and methods, but `Customer` is not a `Timestamped`. Use embedding for composition, not for "is-a" relationships.

## Constructor Functions

Enforce invariants at the only point where construction happens.

```go
type LineItem struct {
    ProductID ProductID
    Quantity  int
    UnitPrice PriceInCents
}

func NewLineItem(productID ProductID, quantity int, unitPrice PriceInCents) (LineItem, error) {
    if quantity <= 0 {
        return LineItem{}, errors.New("quantity must be positive")
    }
    if unitPrice <= 0 {
        return LineItem{}, errors.New("unitPrice must be positive")
    }
    return LineItem{
        ProductID: productID,
        Quantity:  quantity,
        UnitPrice: unitPrice,
    }, nil
}
```

**Rule:** If a struct has a constructor, make all fields unexported. Force all creation through the constructor.

```go
type LineItem struct {
    productID ProductID // unexported
    quantity  int       // unexported
    unitPrice PriceInCents // unexported
}

func (li LineItem) ProductID() ProductID    { return li.productID }
func (li LineItem) Quantity() int           { return li.quantity }
func (li LineItem) UnitPrice() PriceInCents { return li.unitPrice }
```

## Iota Enums

Use for states where all variants have the same fields.

```go
type OrderStatus int

const (
    OrderStatusPending OrderStatus = iota
    OrderStatusPaid
    OrderStatusShipped
    OrderStatusCancelled
)

func (s OrderStatus) String() string {
    switch s {
    case OrderStatusPending:   return "pending"
    case OrderStatusPaid:      return "paid"
    case OrderStatusShipped:   return "shipped"
    case OrderStatusCancelled: return "cancelled"
    default:                   return "unknown"
    }
}

func (s OrderStatus) IsTerminal() bool {
    return s == OrderStatusShipped || s == OrderStatusCancelled
}
```

**When to prefer interface-based unions over iota:**

- If different states have different fields → interface union
- If states have different methods → interface union
- If you need compile-time exhaustiveness checking → interface union (type switch)
- If all states are identical except for identity → iota

## Custom Error Types

Replace string-matching on errors with structured types.

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}

type NotFoundError struct {
    Resource string
    ID       string
}

func (e NotFoundError) Error() string {
    return fmt.Sprintf("%s not found: %s", e.Resource, e.ID)
}

// Usage:
func FindUser(ctx context.Context, id UserID) (User, error) {
    user, err := db.QueryUser(ctx, id)
    if errors.Is(err, sql.ErrNoRows) {
        return User{}, NotFoundError{Resource: "user", ID: id.String()}
    }
    return user, err
}

// Consumer:
user, err := FindUser(ctx, id)
if err != nil {
    var notFound NotFoundError
    if errors.As(err, &notFound) {
        return http.StatusNotFound, notFound
    }
    return http.StatusInternalServerError, err
}
```

**Rule:** Define sentinel errors for cross-package boundaries, custom error structs for rich error context within a package.

## Nil-Safe Design

### Distinguish Missing from Empty

```go
// BAD: nil slice means "not loaded yet" AND "no items"
type Order struct {
    Items []LineItem // nil = ??? empty = ???
}

// GOOD: explicit state
type Order struct {
    Items      []LineItem // always non-nil, empty means no items
    ItemsLoaded bool     // explicit loading state
}

// EVEN BETTER: load state in the type
type Order struct {
    Items OrderItems // embeds loading state
}

type OrderItems struct {
    Loaded bool
    Items  []LineItem
}

func (oi OrderItems) IsLoaded() bool   { return oi.Loaded }
func (oi OrderItems) Count() int      { return len(oi.Items) }
```

### Pointer vs Value Receivers

| Use Value Receiver                | Use Pointer Receiver                 |
| --------------------------------- | ------------------------------------ |
| Immutable types (branded aliases) | Mutable types (structs with setters) |
| Small structs (< 64 bytes)        | Large structs (> 64 bytes)           |
| Types that must not be nil        | Types where nil is a valid state     |
| Read-only methods                 | Write methods                        |

```go
// Value receiver — safe, no nil risk
func (id UserID) String() string { return string(id) }

// Pointer receiver — can mutate, can be nil
func (o *Order) AddItem(item LineItem) {
    o.Items = append(o.Items, item)
    o.UpdatedAt = time.Now()
}
```
