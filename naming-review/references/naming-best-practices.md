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
- [Error Naming](#error-naming)
- [Test Naming](#test-naming)
- [API and Database Naming](#api-and-database-naming)
- [Config and Environment Variable Naming](#config-and-environment-variable-naming)
- [Concurrent and Async Naming](#concurrent-and-async-naming)
- [Observability Naming](#observability-naming)
- [The Renaming Checklist](#the-renaming-checklist)
- [Official Style Guide References](#official-style-guide-references)

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

## Error Naming

Errors are a special class of types with their own conventions per language.

### Error Type Naming by Language

| Language | Convention | Example | Anti-Pattern |
|----------|-----------|---------|-------------|
| **Go** | `Err` prefix for sentinel errors, `XxxError` for error types | `var ErrNotFound`, `type ValidationError struct` | `var NotFound`, `type Error struct` |
| **TypeScript** | `XxxError` class suffix | `class PaymentError extends Error` | `class PaymentErr`, `class Error extends Error` |
| **Rust** | `XxxError` enum/struct suffix | `enum ParseError`, `struct DatabaseError` | `enum Error`, `struct Err` |
| **Python** | `XxxError` class suffix (PEP 8) | `class ConfigurationError(Exception)` | `class ConfigFault`, `class Err` |
| **Java** | `XxxException` class suffix | `class InsufficientFundsException` | `class InsufficientFundsError`, `class FundsEx` |
| **C#** | `XxxException` class suffix | `class PaymentDeclinedException` | `class PaymentDeclinedError` |

### Error Value Naming (Go)

```go
// GOOD — sentinel errors with Err prefix
var ErrNotFound      = errors.New("user not found")
var ErrAlreadyExists = errors.New("user already exists")
var ErrUnauthorized  = errors.New("unauthorized access")

// GOOD — custom error types with domain-specific names
type ValidationError struct {
    Field   string
    Message string
}

// BAD — generic names
var NotFound = errors.New("not found")     // is this an error or a variable?
type Error struct {}                       // what kind of error?
type UserErr struct {}                     // non-standard abbreviation
```

### Error Message Naming

Error messages are user-facing strings, not identifiers. They should:
- Start with a lowercase letter (Go convention, since they may be wrapped)
- Describe what went wrong, not what to do about it
- Include relevant context (IDs, names, values)
- Not include "error" or "Error" in the message — the type already says that

```go
// GOOD
errors.New("user not found")
errors.New("payment declined: insufficient funds")
errors.New("connection refused after 3 retries")

// BAD
errors.New("Error: user not found")      // redundant "Error"
errors.New("Not found")                    // what wasn't found?
errors.New("Something went wrong")         // no context
```

---

## Test Naming

Tests have their own naming conventions that differ from production code.

### Test Function Naming by Language

| Language | Convention | Example |
|----------|-----------|---------|
| **Go** | `Test<Unit>_<Scenario>_<Expected>` | `TestUser_CreateWithEmail_ReturnsUser` |
| **TypeScript** | `should <expected> when <scenario>` | `should return user when created with email` |
| **Rust** | `test_<unit>_<scenario>_<expected>` | `test_user_create_with_email_returns_user` |
| **Python** | `test_<unit>_<scenario>_<expected>` | `test_user_create_with_email_returns_user` |
| **Java** | `should<Expected>When<Scenario>` | `shouldReturnUserWhenCreatedWithEmail` |
| **C#** | `<Scenario>_<Expected>` | `CreateWithEmail_ReturnsUser` |

### Test Naming Principles

1. **Test names are specifications** — they describe expected behavior, not implementation
2. **Read as a sentence** — "should return 404 when user not found"
3. **No test numbers** — `testCreateUser1`, `testCreateUser2` is meaningless; use `testCreateUser_WhenEmailMissing_Returns400`
4. **No "test" in test names** — the framework already marks it as a test
5. **Arrange-Act-Assert** naming: describe the state, the action, and the expected outcome

```go
// BAD — vague, no scenario
func TestUser(t *testing.T) {}

// BAD — implementation-focused
func TestCreateUserFunction(t *testing.T) {}

// BAD — numbered
func TestCreateUser1(t *testing.T) {}

// GOOD — scenario and expectation
func TestUser_CreateWithEmail_ReturnsUser(t *testing.T) {}
func TestUser_CreateWithDuplicateEmail_ReturnsConflictError(t *testing.T) {}
func TestUser_DeleteNonExistent_ReturnsNotFoundError(t *testing.T) {}
```

```typescript
// BAD
it('works', () => {});
it('test create user', () => {});

// GOOD
it('should return user when created with valid email', () => {});
it('should return 409 when email already exists', () => {});
it('should send welcome email after successful registration', () => {});
```

### Test Double Naming

| Role | Name Pattern | Example |
|------|-------------|---------|
| **Stub** | `Stub` suffix | `StubPaymentGateway` — returns canned responses |
| **Spy** | `Spy` suffix | `SpyEmailSender` — records calls for verification |
| **Mock** | `Mock` prefix/suffix | `MockUserRepository` — verifies expectations |
| **Fake** | `Fake` prefix | `FakeUserRepository` — working in-memory implementation |
| **Dummy** | `Dummy` prefix | `DummyLogger` — passed but never used |

---

## API and Database Naming

### REST API Naming

| Element | Convention | Example | Anti-Pattern |
|---------|-----------|---------|-------------|
| **Resource paths** | plural nouns, kebab-case | `/api/customers`, `/api/order-items` | `/api/Customer`, `/api/getCustomer` |
| **Actions** | verb only when not CRUD | `/api/orders/{id}/cancel`, `/api/payments/{id}/refund` | `/api/cancelOrder` |
| **Query params** | camelCase | `?sortBy=createdAt`, `?pageSize=50` | `?sort_by`, `?ps=50` |
| **HTTP methods** | Use properly | `GET /orders`, `POST /orders`, `DELETE /orders/{id}` | `GET /deleteOrder` |
| **Status codes** | Semantic, not numeric | `404 Not Found`, `409 Conflict` | `200 { error: "not found" }` |

### Database Naming

| Element | Convention | Example | Anti-Pattern |
|---------|-----------|---------|-------------|
| **Table names** | plural, snake_case | `customers`, `order_items` | `Customer`, `tblCustomer` |
| **Column names** | snake_case | `created_at`, `user_id` | `createdAt`, `UserID` |
| **Primary key** | `id` or `<table_singular>_id` | `id`, `user_id` (for FK references) | `pk_user`, `user_id` (as PK itself) |
| **Foreign key** | `<referenced_table_singular>_id` | `customer_id`, `order_id` | `cust_fk`, `ref_customer` |
| **Join table** | combination of both tables | `customers_products`, `users_roles` | `cp_map`, `link_tbl` |
| **Index** | `idx_<table>_<columns>` | `idx_users_email`, `idx_orders_customer_id` | `idx1`, `email_index` |
| **Boolean column** | `is_`/`has_`/`can_` prefix | `is_active`, `has_verified_email` | `active`, `flag` |

### JSON Field Naming

| Style | Convention | Example |
|-------|-----------|---------|
| **JavaScript/TS API** | camelCase | `{ "firstName": "Ada", "createdAt": "2024-01-01" }` |
| **Go API** | PascalCase or camelCase | `{ "FirstName": "Ada" }` or with `json:"firstName"` tag |
| **Python API** | snake_case | `{ "first_name": "Ada", "created_at": "2024-01-01" }` |

Choose one style per API and stick to it. Document the convention in the API specification.

---

## Config and Environment Variable Naming

### Environment Variables

| Convention | Example | When |
|-----------|---------|------|
| `SCREAMING_SNAKE_CASE` | `DATABASE_URL`, `MAX_RETRIES`, `API_KEY` | Shell env vars (POSIX convention) |
| Prefix with service name | `PAYMENT_STRIPE_KEY`, `AUTH_JWT_SECRET` | Multi-service projects to avoid collisions |

```bash
# GOOD — prefixed, descriptive
PAYMENT_STRIPE_API_KEY=sk_live_...
AUTH_JWT_SECRET=...
DATABASE_URL=postgres://...
LOG_LEVEL=info
SERVER_PORT=8080

# BAD — unprefixed collisions, vague
KEY=sk_live_...        # what key?
SECRET=...             # which secret?
DB=postgres://...      # which database?
PORT=8080              # which service?
```

### Config File Keys

| Format | Convention | Example |
|--------|-----------|---------|
| YAML/TOML | snake_case | `max_retries: 3`, `database_url: "..."` |
| JSON | camelCase or snake_case (pick one) | `{ "maxRetries": 3 }` or `{ "max_retries": 3 }` |
| .env | SCREAMING_SNAKE_CASE | `MAX_RETRIES=3` |

### Feature Flags

| Convention | Example | Anti-Pattern |
|-----------|---------|-------------|
| `enable_<feature>` or `<feature>_enabled` | `enable_dark_mode`, `payments_v2_enabled` | `flag1`, `new_stuff`, `toggle` |

---

## Concurrent and Async Naming

Concurrency introduces naming concerns that don't exist in synchronous code.

### Goroutine Naming (Go)

Goroutines don't have names, but the functions launched as goroutines should be clearly named:

```go
// BAD — anonymous goroutine with unclear purpose
go func() {
    for range ticker.C {
        // what does this do?
    }
}()

// GOOD — named function launched as goroutine
go pollForUpdates(ctx, updateChannel)
go expireStaleSessions(ctx, sessionStore)
go retryFailedPayments(ctx, paymentGateway)
```

### Channel Naming (Go)

Channels are typed conduits — name them by what flows through them and the direction:

```go
// BAD — vague channel names
ch := make(chan int)
result := make(chan bool)
data := make(chan []byte)

// GOOD — describe what flows and direction
orderStream := make(chan Order)        // incoming orders
shutdownSignal := make(chan struct{})   // signal-only channel
validationResult := make(chan error)    // result of validation
```

### Mutex Naming (Go)

Mutexes protect specific state — name them by what they guard:

```go
// BAD — generic mutex name
var mu sync.Mutex
var lock sync.RWMutex

// GOOD — name by what they protect
var ordersMu sync.Mutex       // protects orders map
var cacheMu sync.RWMutex      // protects cache (RWMutex for read-heavy)
var balanceMu sync.Mutex      // protects account balance
```

### WaitGroup Naming (Go)

```go
// BAD — vague
var wg sync.WaitGroup

// GOOD — name by what they're waiting for
var workersWg sync.WaitGroup   // waiting for worker goroutines
var uploadsWg sync.WaitGroup   // waiting for upload goroutines
```

### Async Naming (TypeScript)

```typescript
// BAD — "Async" suffix adds nothing (the return type already says it)
async function fetchUserAsync(): Promise<User> {}

// GOOD — the async keyword and Promise return type already convey async
async function fetchUser(): Promise<User> {}

// GOOD — use suffix only to disambiguate sync vs async versions
function readConfig(): Config                    // sync version
function readConfigAsync(): Promise<Config>      // async version (when both exist)
```

### Future/Promise Naming

```rust
// Rust — name the future by what it produces, not by "Future" suffix
// BAD
type UserFuture = impl Future<Output = User>;
// GOOD
type PendingUser = impl Future<Output = User>;
```

### Context/Cancel Naming (Go)

```go
// BAD — vague context names
ctx := context.Background()
ctx2, cancel := context.WithTimeout(ctx, 5*time.Second)

// GOOD — descriptive names for derived contexts
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()

// For long-lived contexts, name by lifecycle
bgCtx := context.Background()                    // background context
requestCtx, cancel := context.WithTimeout(bgCtx, timeout) // per-request
defer cancel()
```

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

---

## Observability Naming

Log messages, metric names, and trace spans are identifiers that need consistency just like code.

### Log Message Naming

| Element | Convention | Example | Anti-Pattern |
|---------|-----------|---------|-------------|
| **Structured log fields** | snake_case | `user_id`, `request_duration_ms` | `userId`, `RequestDuration` |
| **Log levels** | Standard set only | `debug`, `info`, `warn`, `error` | `critical_alert`, `fyi` |
| **Messages** | Start with lowercase, describe event | `"order placed successfully"` | `"Order Placed Successfully!"`, `"ok"` |

```go
// GOOD — structured, consistent field names
slog.Info("order placed",
    "order_id", order.ID,
    "customer_id", order.CustomerID,
    "total_amount", order.Total,
    "item_count", len(order.Items),
)

// BAD — inconsistent field names, vague message
slog.Info("Order processed!",
    "orderId", order.ID,
    "cust", order.CustomerID,
    "amount", order.Total,
)
```

### Metric Naming

| Convention | Example | Anti-Pattern |
|-----------|---------|-------------|
| `namespace_unit_suffix` | `http_request_duration_seconds` | `httpReqDur`, `latency` |
| Use standard units | `_seconds`, `_bytes`, `_total` | `_ms`, `_kb` |
| Counters end in `_total` | `http_requests_total` | `http_request_count` |
| Gauges describe current state | `active_connections` | `connections` |
| Histograms describe distribution | `request_duration_seconds` | `latency_histogram` |

```python
# GOOD — Prometheus-style metric naming
http_request_duration_seconds = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "path", "status_code"],
)

order_payment_total = Counter(
    "order_payment_total",
    "Total number of order payments",
    ["payment_method", "status"],
)

# BAD — inconsistent units, vague names
latency = Histogram("latency", "how long things take")
payments = Counter("pays", "payments")
```

### Trace Span Naming

| Convention | Example | Anti-Pattern |
|-----------|---------|-------------|
| `operation_type` format | `HTTP GET /api/orders`, `DB Query SELECT orders` | `handleRequest`, `do_db_thing` |
| Include resource type | `Redis GET user:123` | `cache_read` |
| Use uppercase for protocols | `HTTP POST /api/payments` | `http post /api/payments` |

### Consistency Across Observability

The same concept should use the same name in logs, metrics, and traces:

```go
// GOOD — consistent "order_id" across all three
slog.Info("order placed", "order_id", id)
orderCreatedTotal.Inc("order_id", id)
span.SetAttributes(attribute.String("order_id", id))

// BAD — three different names for the same thing
slog.Info("order placed", "order_id", id)
orderCreatedTotal.Inc("orderId", id)
span.SetAttributes(attribute.String("order.orderId", id))
```

---

## Official Style Guide References

These are the authoritative sources for language-specific naming conventions:

| Language | Guide | URL |
|----------|-------|-----|
| **Go** | Effective Go | https://go.dev/doc/effective_go |
| **Go** | Go Code Review Comments | https://github.com/golang/go/wiki/CodeReviewComments |
| **TypeScript** | TypeScript Style Guide | https://typescriptlang.org/docs/handbook |
| **TypeScript** | Google TypeScript Style Guide | https://google.github.io/styleguide/tsguide.html |
| **Rust** | Rust API Guidelines | https://rust-lang.github.io/api-guidelines/naming.html |
| **Rust** | Rust Style Guide | https://doc.rust-lang.org/nightly/style-guide/ |
| **Python** | PEP 8 | https://peps.python.org/pep-0008/ |
| **Python** | Google Python Style Guide | https://google.github.io/styleguide/pyguide.html |
| **Java** | Google Java Style | https://google.github.io/styleguide/javaguide.html |
| **Java** | Oracle Java Conventions | https://oracle.com/java/technologies/javase/codeconventions-contents.html |
| **C#** | Microsoft C# Conventions | https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/ |
| **General** | Clean Code (Robert C. Martin) | Book — foundational naming principles |
| **General** | Domain-Driven Design (Eric Evans) | Book — ubiquitous language, bounded contexts |
| **General** | The Pragmatic Programmer | Book — "Good naming is the heart of clear code" |
