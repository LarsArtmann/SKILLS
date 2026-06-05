---
name: data-model-review
description: Reviews and redesigns data models from first principles using Go's type system. Use when the user wants to review a data model, redesign types, improve a domain model, fix stringly-typed code, add type safety, use Go generics, composition, or interfaces, or says "data model", "review types", "redesign schema", "type system", "make impossible states unrepresentable", "branded types", "domain model", "entity design", "data architecture", "type safety review", "refactor data layer", "model redesign", "Go data model", "Go types", "Go generics", "Go structs", "Go interfaces", "Go composition". Triggers for any language but produces Go as the primary design language. Also fires when the user asks about validation layers, schema design, or converting implicit models to explicit typed ones.
metadata:
  tags: data-model, types, go, golang, generics, composition, interfaces, review, architecture, domain-design, schema, validation, branded-types, first-principles, embedding, iota, type-safety
---

# Data Model Review

A first-principles review and redesign skill for data models. Reviews what exists, catalogs every problem, then uses Go's type system to design a model where invalid states are unrepresentable.

## Why This Matters

Most data models grow organically. They start as a few structs, accumulate pointer fields, sprout string-typed enums, and eventually become a minefield of nil-pointer dereferences and runtime validation masquerading as type-safe code. This skill stops that rot and replaces it with intentional design.

The output is not just a list of problems. It is a complete redesign — using branded types, interface-based unions, generics, composition via embedding and interfaces, and zero-value discipline — delivered as a self-contained HTML presentation that the team can read, bookmark, and reference.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT before each action.

### Step 1: Discovery — Understand the Current Model

1. **Find all type definitions** in the target scope:
   - Structs, interfaces, type aliases, enums (iota)
   - Database schemas, ORM models, DTOs, API request/response types
   - Config types, state types, domain entity definitions
2. **Read every file** that defines data structures. Do not skip any.
3. **Map the relationships** — which types reference which? Draw a mental (or actual) graph.
4. **Identify the primary language** — this skill produces Go as the design language, but adapts concepts to the target language.
5. **Catalog implicit assumptions** — fields that are "always set except when...", types that are strings but should be branded, pointer fields that are never nil, etc.

### Step 2: Problem Catalog — Brutal Honesty

For every type, field, and relationship, ask these questions and record every problem found.

Grade each problem by **severity** (critical/high/medium/low) and **systemicity** (how many types it affects).

#### P1 — Stringly-Typed Everything (Critical)

- Are identifiers stored as raw `string` instead of branded types?
- Are enums represented as `string` instead of typed constants (iota)?
- Are dates/times stored as `string` instead of `time.Time`?
- Are monetary values stored as `float64` or `int` without a Money type?

#### P2 — Pointer Fields as State Encoding (Critical)

- Is `*time.Time` or `*string` used to encode state machine transitions? (e.g., `VerifiedAt *time.Time` means "not verified yet")
- Are there structs where 3 pointer fields represent 8 possible states, but only 3 are valid?
- **Fix**: Split into interface-based unions. `UnverifiedUser | VerifiedUser` via private method tags instead of `User { VerifiedAt *time.Time }`.

#### P3 — No Validation at the Type Level (High)

- Can a struct be constructed in an invalid state and still compile?
- Are there runtime validators (`validate.Struct`, `validator.New`, custom `Validate()` methods) that the type system should enforce?
- Is there validation duplicated between HTTP handlers, services, and DB layers?

#### P4 — Primitive Obsession (High)

- Are domain concepts represented as primitives? (`string` for Email, `int64` for UserID, `string` for ISBN)
- **Fix**: Branded types. `type UserID string` with unexported method, or a thin struct wrapper.

#### P5 — Missing Interface-Based Unions (High)

- Are polymorphic types modeled with `Type string` + optional pointer fields for each variant?
- Are there `if obj.Type == "x"` runtime checks that the compiler should enforce?
- **Fix**: `type Event interface { event() }` with `ClickEvent`, `SubmitEvent`, `ErrorEvent` implementing the private method.

#### P6 — No Composition, Only Inheritance (High)

- Are base structs embedded blindly, creating deep coupling?
- Are "base" structs used where interfaces would suffice?
- Are create/update/response DTOs duplicated instead of composed from fragments?

#### P7 — Implicit Relationships (Medium)

- Are foreign keys stored as raw `string` / `int` with no type link to the parent?
- Are bidirectional relationships maintained manually without type safety?
- **Fix**: `type Order struct { CustomerID CustomerID }` using a branded ID instead of raw `int64`.

#### P8 — No Versioning or Lifecycle (Medium)

- Do structs have no `CreatedAt`, `UpdatedAt`, `Version` fields?
- Is there no deprecation mechanism for old fields?
- Are legacy types mixed with current types without separation?

#### P9 — Duplicated Logic Across Types (High)

- Is the same validation logic copied into multiple structs?
- Are there "helper" functions that exist only because the main types are poorly designed?
- **Fix**: Extract shared constraints into reusable interfaces and constructor functions.

#### P10 — Weak Collection Types (Medium)

- Are slices used where maps, sets, or iteration order matters?
- Are map keys typed as `string` instead of a branded key type?
- Are empty slices confused with nil slices semantically?

#### P11 — No Generic Parameterization (Medium)

- Are types duplicated for different entity kinds instead of using generics?
- Is `UserPage` / `OrderPage` defined separately?
- **Fix**: `type Page[T any] struct { Items []T; Total int; Page int }`.

#### P12 — Missing Error Models (Medium)

- Are errors returned as untyped `error` with string matching?
- Are sentinel errors defined but not typed?
- **Fix**: Custom error types implementing `error` with structured fields.

### Step 3: Reflection — Step Back

STOP. Do not start designing yet.

1. **Re-read the problem catalog.** Are there problems you missed? Problems you graded wrong?
2. **Identify the root causes.** Are the symptoms 12 separate issues or 3 systemic ones?
3. **Ask "what is this model trying to achieve?"** — not "what does it currently do."
4. **Identify the core entities** — the 3-5 concepts that everything else revolves around.
5. **Identify the invariants** — what must ALWAYS be true? (e.g., "an Order must have at least one LineItem")
6. **Think about Go's full type power:**
   - Can branded types prevent accidental substitution?
   - Can interface-based unions replace pointer-field state machines?
   - Can generics eliminate duplicated collection/pagination types?
   - Can struct embedding compose behavior without inheritance?
   - Can unexported methods create closed unions?
   - Can constructor functions enforce invariants at creation time?
   - Can `iota` typed constants replace string enums?

### Step 4: Design the Improved Model

Design a new model from first principles. Every design decision must have a rationale.

#### 4.1 Branded Types — Prevent Accidental Substitution

```go
// UserID is not just any string. It cannot be accidentally substituted.
type UserID string

// Email is distinct from Username, even though both are strings at runtime.
type Email string

// PriceInCents prevents mixing dollars with cents.
type PriceInCents int64
```

For stronger branding, wrap in a struct:

```go
type UserID struct {
    value string
}

func NewUserID(raw string) (UserID, error) {
    if raw == "" {
        return UserID{}, errors.New("userID cannot be empty")
    }
    return UserID{value: raw}, nil
}

func (id UserID) String() string { return id.value }
```

#### 4.2 Interface-Based Unions — Replace Pointer-Field State Machines

```go
// BAD: 8 possible states, only 3 valid
type Order struct {
    Status      string
    PaidAt      *time.Time
    ShippedAt   *time.Time
    CancelledAt *time.Time
}

// GOOD: Exactly 4 valid states, impossible to construct invalid ones
type Order interface {
    order()
    ID() OrderID
    CreatedAt() time.Time
}

type PendingOrder struct { id OrderID; createdAt time.Time }
func (PendingOrder) order() {}
func (p PendingOrder) ID() OrderID      { return p.id }
func (p PendingOrder) CreatedAt() time.Time { return p.createdAt }

type PaidOrder struct { id OrderID; createdAt, paidAt time.Time }
func (PaidOrder) order() {}
```

#### 4.3 Generics — Eliminate Duplication

```go
// One type, infinite specializations
type Page[T any] struct {
    Items []T
    Total int
    Page  int
}

type Result[T any] struct {
    Data T
    Meta ResponseMeta
}

// Domain-specific specializations inherit constraints
type OrderPage = Page[Order]
type OrderResult = Result[Order]
```

#### 4.4 Composition — Build from Fragments

```go
// Core entity fragments
type Identified interface {
    ID() string
}

type Timestamped struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

// Composed via embedding
type Customer struct {
    ID_       CustomerID // underscore to avoid interface collision if needed
    Timestamped         // embedded
    Email     Email
    Name      string
}

func (c Customer) ID() string { return string(c.ID_) }
```

#### 4.5 Constructor Functions — Enforce Invariants

```go
// Invariants encoded at creation time, not runtime validation
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

#### 4.6 Iota Enums — Replace String Enums

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
    case OrderStatusPending:  return "pending"
    case OrderStatusPaid:     return "paid"
    case OrderStatusShipped:  return "shipped"
    case OrderStatusCancelled: return "cancelled"
    default:                  return "unknown"
    }
}
```

**Prefer interface-based unions over iota enums when the states have different fields.**

#### 4.7 Custom Error Types — Replace String Errors

```go
// Structured error domain
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}

// Sentinel error as value, not string matching
var ErrNotFound = errors.New("not found")
```

### Step 5: Create the HTML Presentation

Write a self-contained, zero-dependency HTML file at `docs/brainstorming/YYYY-MM-DD_<slug>.html`.

The HTML must include:

1. **Hero section** — Title, subtitle, architecture deep-dive badge
2. **Table of Contents** — sticky nav linking to every section
3. **Current State** — Summary stats (type count, problem count, severity breakdown)
4. **Problem Catalog** — Each problem as a card with severity badge and Go fix
5. **The Vision** — What perfection looks like (6 bullet points)
6. **Go Data Model** — Full type definitions with syntax highlighting
7. **Composition in Action** — Side-by-side comparison (before/after)
8. **Validation Layer** — How invalid states become unrepresentable
9. **Decision Log** — Why each design choice was made, with rejected alternatives
10. **Anti-Patterns** — Traps to avoid when adopting the new model
11. **Migration Roadmap** — Numbered, incremental steps with tooling guidance
12. **Conclusion** — Summary quote

**Design requirements for the HTML:**

- Single file, zero external dependencies (no CDN, no JS, no build step)
- Dark theme with semantic color coding
- Manual CSS syntax highlighting for Go
- Responsive grid layouts for comparisons
- Cards with left-border color coding (rose = problem, emerald = solution, amber = warning)

### Step 6: Git Workflow

Before finishing:

1. Run `git status` to verify what changed.
2. Stage the new HTML file specifically with `git add <file>`.
3. Commit with a VERY DETAILED commit message describing:
   - What was reviewed
   - Problems identified (list them)
   - Go type system features used in the redesign
   - Files added
   - Design decisions
4. Push with `git push`.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
