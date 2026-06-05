# Decision Trees — When to Use Which Pattern

## Choosing a Type Wrapper

```
Is the zero value meaningful?
├── NO → Use constructor + unexported fields
│        Example: Order must have at least 1 LineItem
│        type Order struct { items []LineItem } // unexported
│        func NewOrder(items []LineItem) (Order, error)
│
├── YES, but must not be confused with other strings → Type alias
│        Example: UserID vs OrderID
│        type UserID string
│        type OrderID string
│
└── YES, and needs runtime validation → Struct wrapper
         Example: Email must contain @
         type Email struct { value string }
         func NewEmail(raw string) (Email, error)
```

## Choosing Union vs Enum

```
Do different states have different fields?
├── YES → Interface-based union
│        type Order interface { order() }
│        type PendingOrder struct { ... }
│        type PaidOrder struct { ... }
│
└── NO → Iota enum
         type Status int
         const StatusPending Status = iota
```

## Choosing Embedding vs Interface

```
Do you need to store state?
├── YES → Struct embedding
│        type Customer struct { Timestamped }
│
└── NO → Interface composition
         type ReadWriter interface { Reader; Writer }
```

## Choosing Generics vs Code Generation

```
Is the type parameter used in more than 3 places?
├── YES → Generics
│        type Page[T any] struct { Items []T }
│
└── NO → Manual duplication is fine
         type UserPage struct { Items []User }
         type OrderPage struct { Items []Order }
```

## Pointer vs Value for Struct Fields

```
Can the field be nil?
├── YES, nil has semantic meaning → Pointer
│        type User struct { VerifiedAt *time.Time }
│        // nil = not verified
│
├── NO, zero value is valid → Value
│        type User struct { Name string }
│        // empty string = name not set yet
│
└── NO, and zero value must be invalid → Constructor + unexported
         type User struct { name string } // unexported
         func NewUser(name string) (User, error)
```
