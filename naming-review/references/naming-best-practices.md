# Naming Best Practices

This reference documents ideal naming patterns organized by category. Read this when you need to understand the target state — what great naming looks like — or when providing recommendations.

## Table of Contents

- [Core Principles](#core-principles)
- [Data Model Naming](#data-model-naming)
- [Function Naming](#function-naming)
- [Field and Variable Naming](#field-and-variable-naming)
- [Boolean Naming](#boolean-naming)
- [Event and Command Naming](#event-and-command-naming)
- [Package and Module Naming](#package-and-module-naming)
- [Domain-Driven Design Naming](#domain-driven-design-naming)
- [Language-Specific Conventions](#language-specific-conventions)
- [The Renaming Checklist](#the-renaming-checklist)

---

## Core Principles

### 1. Reveal Intent

A name should answer: "What does this do?" or "What does this represent?" — not "How does this work?"

```go
// Intent revealed: we're calculating days until delivery
func daysUntilDelivery(order Order) int {}

// Intent hidden: we're doing something with order numbers
func calculate(ord int) int {}
```

### 2. Avoid Disinformation

A name must not describe something the thing is not. This is worse than no name at all.

```go
// Disinformation: "accountList" is not a list — it's a map
accountList map[string]Account

// Honest
accounts map[string]Account
```

### 3. Make Meaningful Distinctions

If two names are different, they must mean different things. `UserAccount` vs `UserInfo` is not a distinction — it's noise.

```go
// Noise distinction — both mean "data about a user"
type UserAccount struct{}
type UserInfo struct{}

// Meaningful distinction — these are different domain concepts
type UserProfile struct{}        // editable user profile data
type UserCredentials struct{}   // authentication data
type UserPreferences struct{}   // user settings and choices
```

### 4. Use Domain Language

The name that domain experts use in conversation should be the name in code. If the business says "subscription", the code says `Subscription`, not `RecurringPayment` or `AutoRenewalConfig`.

### 5. Name Length Matches Scope

- Short names for short scope (loop variables, lambdas)
- Long names for long scope (public types, exported functions)
- The wider the audience, the more descriptive the name must be

```go
// Short scope — short name is fine
for i, v := range items {}

// Wide scope — long name is necessary
func CalculateOutstandingBalanceForAccount(accountID string) decimal.Decimal {}
```

---

## Data Model Naming

### Types (Structs, Classes, Interfaces, Enums)

Types are nouns. They represent things in the domain.

| Pattern | Example | When to Use |
|---------|---------|-------------|
| Domain noun | `Order`, `Customer`, `Invoice` | Most types — the default |
| Role/behavior | `PaymentGateway`, `TaxCalculator` | Types defined by what they do |
| Event | `OrderPlaced`, `PaymentFailed` | Things that happened in the past |
| Specification | `AdultCustomer`, `OverdueOrder` | Types that represent a subset |
| Collection | `OrderBook`, `ProductCatalog` | Types that primarily hold a group |

### What to Avoid in Type Names

| Anti-Pattern | Why | Instead |
|-------------|-----|---------|
| `Data`, `Info`, `Record` | Adds no meaning | Use the domain noun directly |
| `Manager`, `Handler`, `Processor` | Vague — could be anything | Name by what it manages/handles/processes |
| `Helper`, `Util`, `Utility` | Homeless functions | Move behavior to the type it operates on |
| `Impl`, `Concrete`, `Default` | Leaks architecture | Name by distinguishing characteristic |
| `Abstract`, `Base` | Encodes inheritance | Name by role; compose instead |
| `Entity`, `DTO`, `VO` | DDD jargon, not domain | Use the domain concept name |

### Interface Naming

| Language | Convention | Example |
|----------|-----------|---------|
| **Go** | Behavior, often `-er` suffix | `Reader`, `Writer`, `PaymentGateway` |
| **TypeScript** | PascalCase, no `I` prefix | `UserRepository`, `Logger` |
| **Rust** | PascalCase trait, no `I` | `Read`, `Write`, `PaymentProcessor` |
| **Python** | PascalCase ABC, no `I` | `Repository`, `PaymentGateway` |
| **C#** | `I` prefix | `IUserService`, `IRepository` |
| **Java** | No `I` prefix (increasingly) | `UserService`, `Repository` |

### Enum Naming

Enums should be named as the category, with values as specific members.

```go
// GOOD — category name, specific values
type OrderStatus string
const (
    OrderStatusPending   OrderStatus = "pending"
    OrderStatusConfirmed OrderStatus = "confirmed"
    OrderStatusShipped   OrderStatus = "shipped"
    OrderStatusDelivered OrderStatus = "delivered"
)
```

```typescript
// GOOD
enum PaymentMethod {
    CreditCard = "CREDIT_CARD",
    BankTransfer = "BANK_TRANSFER",
    Crypto = "CRYPTO",
}
```

Avoid generic enum names:

```go
// BAD — "Type" and "Status" add nothing
type OrderType string     // what kind of type?
type UserStatus string    // what kind of status?

// GOOD — specific category
type OrderFulfillment string  // distinguishes from OrderPayment
type AccountState string      // distinguishes from UserStatus
```

---

## Function Naming

Functions are actions. Their names are verbs or verb phrases.

### Function Name Patterns

| Pattern | Form | Example | When |
|---------|------|---------|------|
| **Command** | verb + noun | `shipOrder`, `sendEmail` | Changes state, performs action |
| **Query** | noun / question | `total()`, `isValid()` | Returns data, no side effects |
| **Factory** | New + Type | `NewOrder()`, `NewPayment()` | Creates and returns a new instance |
| **Validator** | is/has/can + adjective | `isValid()`, `hasPermission()` | Returns boolean |
| **Converter** | Type + From + Type | `OrderFromCart()` | Converts between domain types |
| **Event handler** | on + Event | `onOrderPlaced()` | Responds to domain event |

### Verb Selection Guide

Choosing the right verb matters. Use this guide for consistency:

| Operation | Preferred Verb | Avoid | Context |
|-----------|---------------|-------|---------|
| Create new | `create`, `new` | `add`, `insert`, `make` | Object creation |
| Retrieve from DB | `find` | `get`, `fetch`, `retrieve`, `load` | Database lookup |
| Retrieve from memory | `get` | `find`, `fetch` | In-memory access |
| Remove | `delete` | `remove`, `destroy`, `erase` | Permanent removal |
| Remove from collection | `remove` | `delete`, `pop` | Collection operation |
| Update | `update` | `modify`, `change`, `alter` | Mutation |
| Validate | `validate` | `check`, `verify`, `ensure` | Input validation |
| Calculate | `calculate` | `compute`, `determine` | Computation |
| Send over network | `send` | `dispatch`, `transmit`, `push` | Network operation |
| Persist | `save` | `persist`, `store`, `write` | Database write |
| Search | `search` | `find`, `query`, `lookup` | Search/index operation |

### Command-Query Separation

The most important function naming principle: commands change state, queries return data. Never mix them.

```go
// COMMAND — changes state, returns error not data
func ShipOrder(order Order) error {}

// QUERY — returns data, no side effects
func OrderTotal(order Order) decimal.Decimal {}

// BAD — command pretending to be query
func GetAndShipOrder(id string) (Order, error) {} // mutation + query
```

### Function Name Length Guide

| Scope | Name Length | Example |
|-------|-----------|---------|
| Private, called once | Short OK | `sort()` |
| Private, called often | Medium | `sortByPriority()` |
| Public, API surface | Descriptive | `SortOrdersByPriorityDescending()` |
| Test helper | Descriptive | `createUserWithExpiredPassword()` |

---

## Field and Variable Naming

### Field Naming by Role

| Role | Pattern | Example |
|------|---------|---------|
| Identity | `id`, or `typeID` | `id`, `customerId` |
| Timestamp | `verbAt`, `verbedAt` | `createdAt`, `expiresAt`, `deletedAt` |
| Duration | `verbDuration`, `nounTimeout` | `sessionDuration`, `requestTimeout` |
| Count | `nounCount` | `retryCount`, `itemCount` |
| Flag | `is/has/can + adjective` | `isActive`, `hasPermission` |
| Collection | plural noun | `orders`, `customers`, `items` |
| Map/lookup | `nounByAttribute` | `priceBySKU`, `userByEmail` |

### Timestamp Naming Convention

```go
// GOOD — past tense for when something happened
CreatedAt   time.Time // when it was created
UpdatedAt   time.Time // when it was last updated
DeletedAt   time.Time // when it was deleted
ExpiresAt   time.Time // when it will expire
PublishedAt time.Time // when it was published

// BAD — ambiguous
Created   time.Time // is this a boolean or a time?
Date      time.Time // date of what?
Time      time.Time // time of what?
```

### Collection Field Naming

```go
// GOOD — plural nouns for collections
orders      []Order
customers   map[string]Customer
pricesBySKU map[string]decimal.Decimal

// BAD — "List", "Array", "Map" in the name
orderList     []Order
customerMap   map[string]Customer
priceDict     map[string]decimal.Decimal
```

---

## Boolean Naming

### The Yes/No Test

Read the name. Can you answer "yes" or "no"? If not, it's wrong.

```go
// Passes the yes/no test
isActive    // "Is it active?" → "Yes" / "No"
hasAccess   // "Does it have access?" → "Yes" / "No"
canWrite    // "Can it write?" → "Yes" / "No"
shouldRetry // "Should it retry?" → "Yes" / "No"

// Fails the yes/no test
status      // "Is it status?" → ???
flag        // "Is it flag?" → ???
check       // "Is it check?" → ???
active      // "Is it active?" → (works, but "isActive" is clearer at usage site)
```

### Boolean Prefix Guide

| Prefix | Meaning | Example |
|--------|---------|---------|
| `is` | State/condition | `isActive`, `isValid`, `isPublished` |
| `has` | Ownership/containment | `hasPermission`, `hasChildren`, `hasBalance` |
| `can` | Capability | `canWrite`, `canDelete`, `canEdit` |
| `should` | Recommendation/policy | `shouldRetry`, `shouldNotify`, `shouldExpire` |
| `will` | Future event | `willExpire`, `willTransition` |
| `was` | Past event completed | `wasProcessed`, `wasDelivered` |
| `needs` | Requirement | `needsApproval`, `needsRefresh` |
| `allows` | Permission/enablement | `allowsRefund`, `allowsOverride` |

### Negative Boolean Inversion

When the positive form is awkward, use the natural negative:

```go
// Positive form is awkward → negative is OK
isDisconnected  // "connected" is the interesting state, but disconnected is the default
isUnauthenticated  // "authenticated" is the interesting state

// But prefer positive when both forms work equally well
isEmpty        // better than: isNotEmpty
isDisabled     // better than: isNotEnabled
isInvalid      // better than: isNotValid
```

---

## Event and Command Naming

Events and commands are fundamental in event-driven and CQRS architectures.

### Events (Something That Happened)

Events are named in the **past tense** — they describe something that has already occurred.

```go
// GOOD — past tense, noun phrase
OrderPlaced
PaymentFailed
UserRegistered
EmailSent
SessionExpired

// BAD — present tense, verb
PlaceOrder       // this is a command, not an event
FailPayment      // this is a command
Register         // ambiguous — command or event?
```

### Commands (Something to Do)

Commands are named in the **imperative mood** — they tell the system to do something.

```go
// GOOD — imperative, verb phrase
PlaceOrder
CancelSubscription
SendWelcomeEmail
ResetPassword

// BAD — past tense (that's an event)
OrderPlacedHandler  // is this handling the event, or is it a command?
```

### Event Handler Naming

```go
// GOOD — "on" + EventName, or "when" + EventName
onOrderPlaced(event OrderPlaced)
whenPaymentFails(event PaymentFailed)

// ACCEPTABLE — descriptive handler name
handleOrderPlaced(event OrderPlaced)
processPaymentFailure(event PaymentFailed)

// BAD — vague
handleEvent(event interface{})
process(data interface{})
```

---

## Package and Module Naming

### Package Naming Principles

Package names should be:
- **Short** — one or two words
- **Lowercase** — no underscores or mixed case
- **No generic names** — `util`, `common`, `misc`, `base`, `core` are code smells
- **Nouns** — package describes what it provides, not what it does

```go
// GOOD — descriptive, specific
package user
package payment
package tax
package auth
package inventory

// BAD — vague catch-alls
package util
package common
package helpers
package misc
package core
package base
```

### What to Do with Homeless Functions

Functions that don't belong to a type need a package that describes their domain, not their generic nature.

```go
// BAD — utility ghetto
package util
func FormatDate(t time.Time) string {}
func CalculateTax(amount decimal.Decimal) decimal.Decimal {}
func ValidateEmail(email string) bool {}

// GOOD — domain-organized
package timeformat
func Standard(t time.Time) string {}

package tax
func Calculate(amount decimal.Decimal) decimal.Decimal {}

// Or as methods on domain types
func (e Email) IsValid() bool {}
```

---

## Domain-Driven Design Naming

### Ubiquitous Language

The single most impactful naming practice: use the same words that domain experts use.

| Domain Expert Says | Code Name | Anti-Pattern |
|-------------------|-----------|-------------|
| "Customer places an order" | `Customer.PlaceOrder()` | `User.DoAction()` |
| "Payment is declined" | `PaymentDeclined` event | `PaymentFailEvent` |
| "Subscription renews monthly" | `MonthlyRenewal` policy | `RecurringBillingConfig` |
| "Inventory is low" | `LowInventory` specification | `StockThresholdAlert` |

### Bounded Context Naming

Different bounded contexts may use different names for related concepts. This is correct — don't force one name across contexts.

```go
// In Billing context: "Invoice"
type Invoice struct { /* billing fields */ }

// In Shipping context: "Shipment" (different view of same order)
type Shipment struct { /* shipping fields */ }

// In Analytics context: "Transaction" (different granularity)
type Transaction struct { /* analytics fields */ }
```

These are NOT split-brain — they represent different domain concepts in different contexts. Only flag split-brain when the SAME context uses different names for the SAME concept.

### Aggregate Naming

Aggregates are named after the root entity, not with "Aggregate" suffix.

```go
// BAD — "Aggregate" suffix adds nothing
type OrderAggregate struct {}

// GOOD — the aggregate IS the order
type Order struct {
    id        string
    items     []OrderItem  // child entities
    status    OrderStatus
}
```

### Value Object Naming

Value objects are named by what they represent, not with "Value" or "VO" suffix.

```go
// BAD — "Value" suffix
type MoneyValue struct {}
type EmailValue struct {}

// GOOD — just the domain concept
type Money struct { Amount decimal.Decimal; Currency string }
type Email struct { Address string }
```

---

## Language-Specific Conventions

### Go

| Element | Convention | Example |
|---------|-----------|---------|
| Package | lowercase, one word | `package user` |
| Exported type | PascalCase | `type Order struct` |
| Unexported type | camelCase | `type order struct` |
| Interface | PascalCase, behavior name, `-er` suffix | `type Reader interface` |
| Function | PascalCase (exported), camelCase (unexported) | `func FindUser()` |
| Method | PascalCase/camelCase matching export | `func (u *User) Name()` |
| Constant | PascalCase (exported), camelCase (unexported) | `const MaxRetries = 3` |
| Error | `Err` prefix | `var ErrNotFound` |
| Constructor | `New` + Type | `func NewOrder() *Order` |
| Boolean | `is`/`has`/`can` prefix | `func (u *User) IsActive()` |

Go-specific: Don't use `get` prefix for getters. Use `Name()` not `GetName()`.

### TypeScript

| Element | Convention | Example |
|---------|-----------|---------|
| Class/Interface/Type | PascalCase | `class UserService` |
| Function/method | camelCase | `function calculateTotal()` |
| Variable/field | camelCase | `const orderCount = 5` |
| Constant | SCREAMING_SNAKE | `const MAX_RETRIES = 3` |
| Enum | PascalCase + PascalCase values | `enum Color { Red, Blue }` |
| Private field | `#` prefix or `_` prefix | `#name` or `_name` |
| Boolean | `is`/`has`/`can`/`should` prefix | `isActive`, `hasPermission` |
| Event handler | `on` + EventName | `onClick`, `onOrderPlaced` |
| React component | PascalCase | `function UserCard()` |

TypeScript-specific: No `I` prefix for interfaces. Use `interface UserRepository {}` not `interface IUserRepository {}`.

### Rust

| Element | Convention | Example |
|---------|-----------|---------|
| Crate | snake_case | `payment_gateway` |
| Type/Struct | PascalCase | `struct Order` |
| Enum | PascalCase + PascalCase variants | `enum Color { Red, Blue }` |
| Trait | PascalCase | `trait Read` |
| Function/method | snake_case | `fn calculate_total()` |
| Variable | snake_case | `let order_count = 5;` |
| Constant | SCREAMING_SNAKE | `const MAX_RETRIES: u32 = 3;` |
| Module | snake_case | `mod user_service;` |
| Lifetime | short lowercase | `'a`, `'ctx` |
| Boolean | `is_`/`has_`/`can_` prefix | `fn is_active()` |

Rust-specific: Don't use `get` prefix for getters. Use `name()` not `get_name()`. Setters use `set_name()`.

### Python

| Element | Convention | Example |
|---------|-----------|---------|
| Module | snake_case | `user_service.py` |
| Class | PascalCase | `class Order:` |
| Function | snake_case | `def calculate_total():` |
| Variable | snake_case | `order_count = 5` |
| Constant | SCREAMING_SNAKE | `MAX_RETRIES = 3` |
| Private | `_` prefix | `_internal_cache` |
| Boolean | `is_`/`has_`/`can_` prefix | `def is_active():` |
| Property | snake_case | `@property def total():` |

Python-specific: ABCs don't use `I` prefix. Use `class Repository(ABC)` not `class IRepository(ABC)`.

### Java

| Element | Convention | Example |
|---------|-----------|---------|
| Package | lowercase, dot-separated | `com.app.payment` |
| Class | PascalCase | `class OrderService` |
| Interface | PascalCase, no `I` prefix (modern) | `interface UserRepository` |
| Method | camelCase | `void calculateTotal()` |
| Variable | camelCase | `int orderCount` |
| Constant | SCREAMING_SNAKE | `static final int MAX_RETRIES` |
| Boolean getter | `is`/`has`/`can` prefix | `boolean isActive()` |
| Test method | should/when/then pattern | `shouldThrowOnInvalidInput()` |

Java-specific: Modern Java style (since ~2015) drops the `I` prefix. `IUserService` is legacy style; `UserService` is modern.

### C#

| Element | Convention | Example |
|---------|-----------|---------|
| Namespace | PascalCase, dot-separated | `App.Payment` |
| Class | PascalCase | `class OrderService` |
| Interface | `I` prefix + PascalCase | `interface IUserService` |
| Method | PascalCase | `void CalculateTotal()` |
| Variable | camelCase | `int orderCount` |
| Constant | PascalCase | `const int MaxRetries` |
| Boolean property | `Is`/`Has`/`Can` prefix | `bool IsActive { get; }` |
| Event | `On` + EventName | `event EventHandler OnOrderPlaced` |
| Private field | `_` prefix + camelCase | `private readonly int _orderCount` |

C#-specific: The `I` prefix for interfaces IS the convention. This is the one language where it's correct.

---

## The Renaming Checklist

Before renaming, verify:

1. **Is this name truly wrong?** — Don't rename for personal preference; rename for clarity
2. **Will this break external consumers?** — Public API, serialized forms, reflection
3. **Is the new name better?** — Apply the "phone test": say both names out loud in a code review. Which one is clearer?
4. **Is the rename consistent?** — If you rename `getUser` to `findUser`, rename all `get*` DB lookups to `find*`
5. **Can the IDE/refactoring tool handle it?** — Use LSP rename, not find-and-replace
6. **Did you update all references?** — Comments, documentation, error messages, log statements
7. **Did you update tests?** — Test names should reflect the new naming

### Safe Rename Order

1. Rename in the IDE using refactoring tools (preserves all references)
2. Run the test suite
3. Search for string references (reflection, config, serialized forms)
4. Update documentation
5. Commit with a descriptive message explaining the rename and why

### When NOT to Rename

- The name is in a serialized format (JSON key, database column) — alias in code instead
- The name is part of a public API contract — version the API
- The cost of the rename exceeds the benefit — one-letter loop variables in a 5-line function
- You're renaming to match your personal style, not to improve clarity
