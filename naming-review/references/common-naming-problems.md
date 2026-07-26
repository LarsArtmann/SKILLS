# Common Naming Problems Catalogue

This reference documents naming anti-patterns found across production codebases, organized by category. Read this when evaluating specific identifiers or when you need concrete before/after examples.

## Table of Contents

- [Honesty Issues](#honesty-issues)
- [Clarity Issues](#clarity-issues)
- [Precision Issues](#precision-issues)
- [Domain Alignment Issues](#domain-alignment-issues)
- [Implementation Leakage Issues](#implementation-leakage-issues)
- [Boolean Naming Issues](#boolean-naming-issues)
- [Function Naming Issues](#function-naming-issues)
- [Consistency Issues](#consistency-issues)

---

## Honesty Issues

The most damaging category. A name that lies breaks trust and causes bugs.

### 1. Lying Function Names

A function name that describes one behavior but performs another.

```go
// BAD — name says "get" but it mutates
func getUser(id string) User {
    user := db.Find(id)
    user.LastAccessed = time.Now() // hidden mutation!
    db.Save(user)
    return user
}

// GOOD — name tells the truth
func touchAndGetUser(id string) User
```

```typescript
// BAD — name says "validate" but it also sends email
function validateRegistration(data: Registration) {
	if (data.email) {
		sendWelcomeEmail(data.email); // hidden side effect!
	}
}

// GOOD — separate concerns
function validateRegistration(data: Registration): ValidationResult;
function sendWelcomeEmail(email: string): void;
```

```python
# BAD — name says "get" but it also increments the view counter
def get_article(article_id: str) -> Article:
    article = db.find(article_id)
    article.view_count += 1  # hidden mutation!
    db.save(article)
    return article

# GOOD — name tells the truth
def get_and_touch_article(article_id: str) -> Article
```

### 2. Euphemistic Names

Using soft language to describe destructive or significant operations.

```go
// BAD — "sanitize" means delete
func sanitizeExpiredSessions() { /* deletes rows from DB */ }
func adjustOverflow() { /* truncates data silently */ }

// GOOD — honest about what happens
func deleteExpiredSessions() { /* ... */ }
func truncateOverflow() { /* ... */ }
```

### 3. Misleading Scope

A name that implies broad responsibility but does something narrow.

```typescript
// BAD — "ProcessAll" but only handles credit card payments
function processAllPayments(payment: Payment) {
	// only handles credit cards, throws for others
}

// GOOD — name matches actual scope
function processCreditCardPayment(payment: CreditCardPayment);
```

### 4. Getter That Mutates

The "getter" pattern is specifically dangerous because it carries an implicit contract of no side effects.

```go
// BAD — getter with side effects
func (o *Order) Total() decimal.Decimal {
    o.recalculateTotal() // mutation!
    return o.total
}

// GOOD — query is honest, or command is explicit
func (o *Order) RecalculateTotal() decimal.Decimal
func (o *Order) CachedTotal() decimal.Decimal
```

---

## Clarity Issues

Names that require explanation or context to understand.

### 5. Unpronounceable Names

If you can't say it in a code review discussion, it needs a better name.

```go
// BAD — try saying this out loud
type UsrAcctMgmt struct{}
func prcsRcncltn() {}

// GOOD — sayable
type UserAccountManager struct{}
func processReconciliation() {}
```

### 6. Non-Universal Abbreviations

Abbreviations that aren't universally understood in the domain.

```go
// BAD — requires domain knowledge to decode
cnt, usr, calc, mgr, pmt, hdr, amt, qty, acc, cfg, auth

// ACCEPTABLE — truly universal in computing
id, url, http, api, db, sql, io, cpu, ram, os, ip, dns, tcp, utf, ascii

// GOOD — spell it out
count, user, calculate, manager, payment, header, amount, quantity, account, config, authentication
```

### 7. Single-Letter Variables Beyond Loop Counters

```go
// BAD — what is 'p'? 'c'? 'r'?
func process(p *Payment, c *Customer, r *Receipt) {}

// GOOD
func process(payment *Payment, customer *Customer, receipt *Receipt) {}
```

```typescript
// BAD — single letters except loop vars
function calculate(p: Product, o: Order, c: Coupon): number {}

// GOOD
function calculate(product: Product, order: Order, coupon: Coupon): number {}
```

```python
# BAD — single-letter parameters
def process(p, c, r): ...

# GOOD
def process(payment, customer, receipt): ...
```

**Exceptions**: Loop counters (`i`, `j`, `k`), math variables (`x`, `y`, `z`, `n`), coordinate pairs (`x`, `y`), generic type parameters in Go/Rust/TypeScript (`T`, `K`, `V`).

### 8. Number Suffixes

Number suffixes indicate you're treating distinct concepts as the same thing.

```typescript
// BAD — why two users? What distinguishes them?
const user1 = findUser(senderId);
const user2 = findUser(recipientId);

// GOOD — meaningful distinction
const sender = findUser(senderId);
const recipient = findUser(recipientId);
```

### 9. Hungarian Notation

Encoding type information in the name when the type system already knows it.

```go
// BAD — the type system already knows
var strName string
var intCount int
var boolIsValid bool
var arrItems []string
var ptrConfig *Config

// GOOD — trust the type system
var name string
var count int
var isValid bool
var items []string
var config *Config
```

**Exception**: In systems programming or when the same name exists with different types (e.g., `widthPx` vs `widthEm`), units or representation suffixes add meaning that the type system doesn't capture.

---

## Precision Issues

Names that are so vague they could mean anything.

### 10. Vague Noun Types

Types named with words that carry zero domain meaning.

```go
// BAD — what kind of data? what kind of info?
type UserData struct{}
type PaymentInfo struct{}
type OrderRecord struct{}
type ConfigItem struct{}
type ResultObject struct{}

// GOOD — name describes the domain concept
type UserProfile struct{}
type PaymentReceipt struct{}
type Order struct{}           // just "Order" is enough
type DatabaseConfig struct{}
type ValidationOutcome struct{}
```

```typescript
// BAD — vague nouns
class UserData {}
interface PaymentInfo {}
type OrderRecord = {};

// GOOD — domain-specific
class UserProfile {}
interface PaymentReceipt {}
type Order = {};
```

```python
# BAD — vague nouns
class UserData: ...
class PaymentInfo: ...
class OrderRecord: ...

# GOOD — domain-specific
class UserProfile: ...
class PaymentReceipt: ...
class Order: ...
```

```rust
// BAD — vague nouns
struct UserData {}
struct PaymentInfo {}

// GOOD — domain-specific
struct UserProfile {}
struct PaymentReceipt {}
```

**Why this matters**: `UserData` and `PaymentInfo` tell you nothing about what the type represents that you don't already know from its fields. The name should add meaning, not just confirm "this is data about payments."

### 11. Vague Verb Functions

Verbs so generic they could apply to anything.

```go
// BAD — what does "process" mean for an order? Ship it? Validate it? Charge it?
func processOrder(order *Order) {}
func handleRequest(req *Request) {}
func manageSession(session *Session) {}
func performCalculation(data *Data) {}
func doStuff() {}

// GOOD — specific about what happens
func shipOrder(order *Order) {}
func validateRequest(req *Request) {}
func expireSession(session *Session) {}
func calculateTaxAmount(subtotal decimal.Decimal) {}
func generateInvoice(order *Order) {}
```

```typescript
// BAD — vague verbs
function processOrder(order: Order): void {}
function handleRequest(req: Request): Response {}
function doStuff(): void {}

// GOOD — specific
function shipOrder(order: Order): Shipment {}
function validateRequest(req: Request): ValidationResult {}
function generateInvoice(order: Order): Invoice {}
```

```python
# BAD — vague verbs
def process_order(order): ...
def handle_request(request): ...
def do_stuff(): ...

# GOOD — specific
def ship_order(order): ...
def validate_request(request): ...
def generate_invoice(order): ...
```

### 12. The "Manager/Handler/Processor" Class

These names are垃圾桶 — they collect unrelated behavior because the name is vague enough to hold anything.

```typescript
// BAD — "Manager" that does 12 unrelated things
class UserManager {
	createUser() {}
	deleteUser() {}
	sendWelcomeEmail() {}
	validatePassword() {}
	generateReport() {}
	auditAccess() {}
	syncWithLDAP() {}
	resetPassword() {}
}

// GOOD — split by responsibility
class UserRepository {
	create() {}
	delete() {}
	findById() {}
}

class UserAuthentication {
	validatePassword() {}
	resetPassword() {}
}

class UserNotification {
	sendWelcomeEmail() {}
}

class UserProvisioning {
	syncWithLDAP() {}
}

class UserAuditLog {
	generateReport() {}
	auditAccess() {}
}
```

```python
# BAD — "Manager" collecting unrelated behavior
class OrderManager:
    def create_order(self): ...
    def cancel_order(self): ...
    def send_confirmation(self): ...
    def calculate_tax(self): ...
    def generate_invoice(self): ...

# GOOD — split by responsibility
class OrderRepository:
    def create(self): ...
    def cancel(self): ...

class OrderNotification:
    def send_confirmation(self): ...

class TaxCalculator:
    def calculate(self): ...

class InvoiceGenerator:
    def generate(self): ...
```

### 13. "Helper" and "Util" Classes

Static utility classes are often a sign of misplaced behavior.

```go
// BAD — homeless functions living in a utility ghetto
package util

func FormatDate(t time.Time) string {}
func CalculateTax(amount decimal.Decimal) decimal.Decimal {}
func ValidateEmail(email string) bool {}

// GOOD — behavior belongs with the type it operates on
package timeutil // or better: a DateFormat type
func (f DateFormat) Format(t time.Time) string {}

package tax // domain package
func CalculateTax(amount decimal.Decimal) decimal.Decimal {}

// Or as methods on the type:
func (e Email) IsValid() bool {}
```

### 14. Redundant Context

Repeating the type or containing scope in the name.

```go
// BAD — "User" is repeated in every field
type User struct {
    UserID       string
    UserName     string
    UserEmail    string
    UserPassword string
}

// GOOD — context is clear from the struct
type User struct {
    ID       string
    Name     string
    Email    string
    Password string
}
```

```typescript
// BAD — "Exception" is already the class
class NotFoundException extends Exception {
	exceptionMessage: string; // redundant
}

// GOOD
class NotFoundException extends Exception {
	message: string;
}
```

### 15. Type Name Redundancy

Including the type in the name when the type already says it.

```go
// BAD
var nameString string
var amountDecimal decimal.Decimal
var idGuid uuid.UUID
var listItems []Item
var mapUsers map[string]*User

// GOOD
var name string
var amount decimal.Decimal
var id uuid.UUID
var items []Item
var users map[string]*User
```

---

## Domain Alignment Issues

Names that speak developer-ese instead of the domain language.

### 16. Missing Ubiquitous Language

The most valuable names use the domain's own vocabulary.

```go
// BAD — developer jargon for domain concepts
type AggregateRoot struct{}        // DDD jargon, not domain term
type DTO struct{}                   // technical term, domain says "Transfer"
type Entity struct{}               // DDD term, domain says "Customer"
type ValueObject struct{}          // DDD term, domain says "Money"

// GOOD — speak the domain language
type Order struct{}                // the aggregate root IS an Order
type WireTransfer struct{}        // the DTO IS a WireTransfer
type Customer struct{}             // the entity IS a Customer
type Money struct{}               // the value object IS Money
```

### 17. Split-Brain Terminology

Two or more names for the same domain concept, creating confusion about whether they're different.

```go
// BAD — are Customer, Client, and AccountHolder different things?
type Customer struct{}
type Client struct{}          // same concept?
type AccountHolder struct{}  // same concept?

// In function names:
func getCustomer(id string) {}
func fetchClient(id string) {}     // same operation?
func retrieveAccountHolder(id string) {} // same operation?

// GOOD — one canonical name per concept
type Customer struct{}
func getCustomer(id string) {}
```

### 18. Mixed Metaphors

Same concept expressed with different metaphors in different places.

```typescript
// BAD — is it a "basket", a "cart", or a "bag"?
interface ShoppingBasket { }
class ShoppingCart { }
type ShoppingBag { }

// GOOD — pick one metaphor consistently
interface ShoppingCart { }
```

### 19. Technical Jargon Replacing Domain Terms

```go
// BAD — the domain says "invoice", the code says "record"
type InvoiceRecord struct{}     // "Record" adds nothing
type PaymentDTO struct{}        // "DTO" is architecture, domain says "Payment"

// GOOD
type Invoice struct{}
type Payment struct{}
```

---

## Implementation Leakage Issues

Names that expose how something works instead of what it does.

### 20. "Impl" Suffix

The "Impl" suffix leaks that you have an interface and a concrete class, but tells you nothing about what makes this implementation special.

```java
// BAD
interface PaymentGateway {}
class PaymentGatewayImpl implements PaymentGateway {} // Which implementation?

// GOOD — name describes the implementation's distinguishing characteristic
interface PaymentGateway {}
class StripePaymentGateway implements PaymentGateway {}
class InMemoryPaymentGateway implements PaymentGateway {} // for testing
```

```go
// BAD
type UserRepository interface {}
type userRepositoryImpl struct {} // What kind of repository?

// GOOD
type UserRepository interface {}
type PostgresUserRepository struct {}
type InMemoryUserRepository struct {}
```

### 21. "Abstract/Base" Prefix

These prefixes encode the inheritance hierarchy in the name — a code smell that suggests composition would be better.

```typescript
// BAD — hierarchy encoded in names
abstract class AbstractUser {}
abstract class BaseRepository {}
class UserImpl extends AbstractUser {} // double leakage!

// GOOD — compose behavior, name by role
interface Authenticatable {
	authenticate(): boolean;
}
interface Emailable {
	getEmail(): string;
}
class User implements Authenticatable, Emailable {}

// Or if inheritance is truly needed, name by what it IS:
class ReadOnlyUser extends User {}
class AdminUser extends User {}
```

### 22. "I" Prefix for Interfaces (Non-C#)

Outside of C#, the `I` prefix for interfaces is an anti-pattern because it prioritizes implementation details over domain meaning.

```go
// BAD — Go doesn't use I prefix
type IUserService interface {}
type IRepository interface {}

// GOOD — Go convention: interface named by behavior, often "-er" suffix
type UserService interface {}
type UserStore interface {}     // or Repository if that's your convention
type Reader interface {}
type Writer interface {}
```

```typescript
// BAD — TypeScript doesn't use I prefix
interface IUserService {}
interface IRepository {}

// GOOD — name by role
interface UserService {}
interface UserRepository {}
```

**Exception**: C# convention mandates `I` prefix for interfaces. Respect language conventions.

### 23. Framework Leakage

Including framework names in domain identifiers.

```java
// BAD — framework leaks into domain name
@RestController
class RestCustomerController {} // "Rest" is implementation

@Entity
class JpaCustomer {} // "Jpa" is implementation

// GOOD — domain name, framework as annotation
@RestController
class CustomerController {}

@Entity
class Customer {}
```

---

## Boolean Naming Issues

Boolean names should read as yes/no questions. Getting this wrong creates cognitive load.

### 24. Boolean Fields That Aren't Questions

```go
// BAD — is "status" true or false? What does "flag" flag?
type Config struct {
    status  bool
    flag    bool
    check   bool
    active  bool // OK-ish, but could be clearer
}

// GOOD — reads as a yes/no question
type Config struct {
    isEnabled   bool
    hasAccess   bool
    shouldRetry bool
    isActive    bool
}
```

### 25. Negative Booleans

Double negatives are hard to reason about: `if !isNotVisible` means "if visible".

```go
// BAD — double negative when negated
isNotEnabled
hasNoPermission
isNotValid
isDisconnected  // negative state, but acceptable if domain uses it

// GOOD — positive form, negate the usage
isDisabled      // !isDisabled = enabled
lacksPermission // or: isForbidden, isRestricted
isInvalid       // !isInvalid = valid
isConnected     // !isConnected = disconnected
```

**Guideline**: Prefer the positive form. If the negative form is the common case in the domain (e.g., `isDisconnected` is the default state), then the negative form is acceptable.

### 26. Ambiguous Boolean Names

```go
// BAD — "status" of what? "flag" for what? "check" checks what?
active bool
status bool
flag   bool
check  bool

// GOOD — specific yes/no question
isActive           bool
hasPendingOrder    bool
shouldSendEmail    bool
requiresAuth       bool
```

---

## Function Naming Issues

Functions are actions. Their names should reveal what action they perform.

### 27. Function That Does Two Things (And/Or in Name)

When "and" or "or" appears in a function name, it's doing too much.

```go
// BAD — two responsibilities glued together
func saveAndNotify(user *User) error {
    db.Save(user)
    email.SendWelcome(user.Email)
}

// GOOD — one function, one job
func saveUser(user *User) error {}
func sendWelcomeNotification(email string) error {}
```

### 28. Version Suffixes in Names

Version numbers belong in version control, not in function names.

```go
// BAD — use git, not function names for versioning
func processOrderV2(order *Order) {}
func handleRequest_new(req *Request) {}
func calculateTax_fixed(amount decimal.Decimal) {}

// GOOD — if old version exists, it should be gone; if both needed, name by difference
func processOrder(order *Order) {}
func handleBatchRequest(req *Request) {}      // different behavior, not version
func calculateTaxWithExemptions(amount decimal.Decimal) {} // different behavior
```

### 29. Arbitrary Comments in Names

```typescript
// BAD — comments embedded in names
function fetchUser_TODO(userId: string) {}
function calculatePrice_hack() {}
function login_old() {}

// GOOD — clean names, use proper TODO comments
function fetchUser(userId: string) {} // TODO: handle 404 case
function calculatePrice() {}
function loginWithMfa() {} // if this is truly a different behavior
```

### 30. Factory Functions Named "Create"

`Create` or `New` alone doesn't tell you what you're creating.

```go
// BAD — create what?
func New() *Order {}
func Create() *Payment {}

// GOOD — name says what you're creating
func NewOrder() *Order {}
func NewPayment() *Payment {}

// BETTER — named constructors describe how
func OrderWithDefaults() *Order {}
func NewPaymentFromInvoice(inv Invoice) *Payment {}
func NewDraftOrder(customer Customer) *Order {}
```

### 31. Query Functions Named as Commands

A function that returns a value should be named as a question or noun, not as a command.

```go
// BAD — sounds like a command, but it's a query
func getUserName(id string) string {}    // "get" implies action
func calculateTotal() decimal.Decimal {} // OK: "calculate" is a query

// GOOD — query naming
func userName(id string) string {}       // noun form
func total() decimal.Decimal {}          // property access
func isOrderValid(order *Order) bool {}   // question form
```

**Language note**: Go convention uses `Get` prefix for getters, but not for other queries. TypeScript/Python prefer noun forms for property-like queries.

### 32. Command Functions Named as Queries

A function that changes state should be named as a verb, not a noun.

```go
// BAD — sounds like a query, but it mutates
func currentUser() *User { // this also sets last access time
    u := db.Find(userId)
    u.LastAccessed = time.Now()
    return u
}

// GOOD — command is honest
func touchUser(id string) *User {} // or: refreshUserAccess
```

---

## Consistency Issues

Same thing, different names — the death of readability at scale.

### 33. Synonym Drift Across Codebase

Different verbs for the same operation.

```go
// BAD — same operation, four different verbs across files
func createUser() {}    // user_service.go
func newCustomer() {}  // customer_service.go
func addAccount() {}   // account_service.go
func insertMember() {} // member_service.go

// GOOD — one verb per operation type across the codebase
func createUser() {}
func createCustomer() {}
func createAccount() {}
func createMember() {}
```

### 34. Inconsistent Query Verbs

Getting data: `get` vs `find` vs `fetch` vs `retrieve` vs `query` vs `load`.

```go
// BAD — no consistency
func getUser() {}
func findOrder() {}
func fetchPayment() {}
func retrieveInvoice() {}
func queryCustomer() {}

// GOOD — establish a convention and stick to it
// Convention: "find" for DB lookups, "get" for in-memory access
func getUser() {}       // in-memory
func findOrder() {}     // database lookup
func findPayment() {}   // database lookup
func getInvoice() {}    // in-memory
```

### 35. Cutesy/Clever Names

Names that show off but obscure meaning.

```go
// BAD — what does "reaper" do? "ninja"? "wizard"?
type Reaper struct{}          // garbage collector?
func ninjaSlice(items []int) {} // what kind of slice?
var magicNumber int           // what number?

// GOOD — clear and honest
type SessionCleaner struct{}
func partitionSlice(items []int) {}
var toleranceThreshold int
```

### 36. Inconsistent Casing

When the team mixes conventions.

```typescript
// BAD — mixed conventions in same file
interface user_service {} // snake_case interface
type UserRepo = {}; // PascalCase type alias
function getuser() {} // all lowercase
const MAX_RETRY = 3; // SCREAMING_SNAKE (OK for constants)

// GOOD — consistent TypeScript convention
interface UserService {} // PascalCase
type UserRepo = {}; // PascalCase
function getUser() {} // camelCase
const MAX_RETRY = 3; // SCREAMING_SNAKE for constants
```

---

## Worked Example: Full Mini-Review

This example shows how to apply the checklist to a real file, from discovery to report.

### Input File: `user_service.go`

```go
package service

type UserData struct {
    UserDataID    string
    UserName      string
    UserEmail     string
    status        bool
    Created       time.Time
}

type UserManager struct {
    db *sql.DB
}

func (m *UserManager) ProcessUser(ud *UserData) error {
    if ud.status {
        return m.db.Save(ud)
    }
    return nil
}

func (m *UserManager) GetUserInfo(id string) (*UserData, error) {
    ud, err := m.db.Find(id)
    if err != nil {
        return nil, fmt.Errorf("Error: user not found")
    }
    ud.Created = time.Now() // update last access
    m.db.Save(ud)
    return ud, nil
}

func (m *UserManager) HandleRequest(req *Request) (*Response, error) {
    // ... 50 lines of business logic ...
}
```

### Review Against Checklist

| #   | Line | Identifier                | Category            | Issue                                            | Better Name                                              |
| --- | ---- | ------------------------- | ------------------- | ------------------------------------------------ | -------------------------------------------------------- |
| 1   | 3    | `UserData`                | Precision           | Vague noun — "Data" carries no meaning           | `User` or `UserProfile`                                  |
| 2   | 4    | `UserDataID`              | Precision           | Redundant with struct name                       | `ID`                                                     |
| 3   | 5    | `UserName`                | Precision           | Redundant with struct name                       | `Name`                                                   |
| 4   | 6    | `UserEmail`               | Precision           | Redundant with struct name                       | `Email`                                                  |
| 5   | 7    | `status`                  | Boolean             | Not a yes/no question                            | `isActive` or `isVerified`                               |
| 6   | 8    | `Created`                 | Clarity             | Ambiguous — is this a bool or a time?            | `CreatedAt`                                              |
| 7   | 10   | `UserManager`             | Precision           | Manager is a vague trash-can name                | Split: `UserRepository` + `UserAuthService`              |
| 8   | 13   | `ProcessUser`             | Honesty + Precision | "Process" is vague; what does it do?             | `SaveActiveUser`                                         |
| 9   | 13   | `m`                       | Clarity             | Single-letter receiver                           | `mgr` → but rename the type too                          |
| 10  | 13   | `ud`                      | Clarity             | Non-universal abbreviation                       | `user`                                                   |
| 11  | 18   | `GetUserInfo`             | Honesty             | Mutates state (updates Created, saves)           | `TouchAndFetchUser`                                      |
| 12  | 18   | `GetUserInfo`             | Precision           | Returns `UserData` not "Info"                    | `FetchUser` (after renaming type)                        |
| 13  | 22   | `"Error: user not found"` | Error Naming        | Redundant "Error:" prefix; starts with uppercase | `"user not found"`                                       |
| 14  | 24   | `ud.Created = time.Now()` | Honesty             | Hidden mutation in a "Get" function              | Separate `TouchUserAccess` method                        |
| 15  | 27   | `HandleRequest`           | Precision           | Vague verb "Handle" + vague noun "Request"       | Specific: `ValidateRegistration`, `ProcessPayment`, etc. |

### Generated Report

```markdown
# Naming Review Report

## Executive Summary

- 15 identifiers reviewed in 1 file
- 3 honesty issues (lying names, hidden mutation)
- 4 clarity issues (abbreviations, ambiguous names)
- 5 precision issues (vague nouns, Manager class, vague verbs)
- 2 boolean naming issues (status, Created)
- 1 error naming issue (redundant "Error:" prefix)

## Honesty Issues (Must Fix)

| #   | Line | Identifier              | Issue                                 | Better Name                  |
| --- | ---- | ----------------------- | ------------------------------------- | ---------------------------- |
| 1   | 18   | GetUserInfo()           | Mutates state (saves to DB)           | TouchAndFetchUser()          |
| 2   | 24   | ud.Created = time.Now() | Hidden mutation in getter             | Extract to TouchUserAccess() |
| 3   | 13   | ProcessUser()           | "Process" hides what actually happens | SaveActiveUser()             |

## Precision Issues (Should Fix)

| #   | Line | Identifier                      | Issue                         | Better Name                               |
| --- | ---- | ------------------------------- | ----------------------------- | ----------------------------------------- |
| 1   | 3    | UserData                        | Vague noun "Data"             | User or UserProfile                       |
| 2   | 10   | UserManager                     | Manager trash-can name        | Split: UserRepository + UserAuthService   |
| 3   | 27   | HandleRequest                   | Vague verb + noun             | ValidateRegistration (or specific action) |
| 4   | 4-6  | UserDataID, UserName, UserEmail | Redundant with struct context | ID, Name, Email                           |
| 5   | 13   | ud                              | Non-universal abbreviation    | user                                      |

## Boolean Naming

| #   | Line | Identifier        | Issue                     | Better Name |
| --- | ---- | ----------------- | ------------------------- | ----------- |
| 1   | 7    | status bool       | Not a yes/no question     | isActive    |
| 2   | 8    | Created time.Time | Ambiguous — bool or time? | CreatedAt   |

## Strengths

- Package name `service` is OK, though `user` would be more specific
```
