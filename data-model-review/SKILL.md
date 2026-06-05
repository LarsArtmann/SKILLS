---
name: data-model-review
description: Reviews and redesigns data models from first principles using TypeScript's full type system power. Use when the user wants to review a data model, redesign types, improve a domain model, fix stringly-typed code, add type safety, use generics, composition, or discriminated unions, or says "data model", "review types", "redesign schema", "type system", "make impossible states unrepresentable", "branded types", "domain model", "entity design", "data architecture", "type safety review", "refactor data layer", or "model redesign". Triggers for any language but produces TypeScript as the design language. Also fires when the user asks about validation layers, schema design, or converting implicit models to explicit typed ones.
metadata:
  tags: data-model, types, typescript, generics, composition, review, architecture, domain-design, schema, validation, branded-types, discriminated-unions, first-principles
---

# Data Model Review

A first-principles review and redesign skill for data models. Reviews what exists, catalogs every problem, then uses TypeScript's entire type system to design a model where invalid states are unrepresentable.

## Why This Matters

Most data models grow organically. They start as a few interfaces, accumulate optional fields, sprout string-typed enums, and eventually become a minefield of runtime errors masquerading as type-safe code. This skill stops that rot and replaces it with intentional design.

The output is not just a list of problems. It is a complete redesign — using branded types, discriminated unions, generics, mapped types, conditional types, and template literals — delivered as a self-contained HTML presentation that the team can read, bookmark, and reference.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT before each action.

### Step 1: Discovery — Understand the Current Model

1. **Find all type definitions** in the target scope:
   - Interfaces, types, structs, classes, enums, schemas
   - Database schemas, ORM models, DTOs, API request/response types
   - Config types, state types, domain entity definitions
2. **Read every file** that defines data structures. Do not skip any.
3. **Map the relationships** — which types reference which? Draw a mental (or actual) graph.
4. **Identify the primary language** — this skill produces TypeScript as the design language, but adapts concepts to the target language.
5. **Catalog implicit assumptions** — fields that are "always set except when...", types that are strings but should be enums, nullable fields that are never null, etc.

### Step 2: Problem Catalog — Brutal Honesty

For every type, field, and relationship, ask these questions and record every problem found.

Grade each problem by **severity** (critical/high/medium/low) and **systemicity** (how many types it affects).

#### P1 — Stringly-Typed Everything (Critical)
- Are identifiers stored as raw `string` instead of branded types?
- Are enums represented as `string` instead of closed unions?
- Are dates/times stored as `string` instead of `Date` or branded temporal types?
- Are monetary values stored as `number` or `string` instead of `Money` / `Cents`?

#### P2 — Optional Fields as State Encoding (Critical)
- Is `field?: T` used to encode state machine transitions? (e.g., `verifiedAt?: Date` means "not verified yet")
- Are there types where 3 optional fields represent 8 possible states, but only 3 are valid?
- **Fix**: Split into discriminated unions. `UnverifiedUser | VerifiedUser` instead of `User { verifiedAt?: Date }`.

#### P3 — No Validation at the Type Level (High)
- Can a type be constructed in an invalid state and still compile?
- Are there runtime validators that the type system should enforce?
- Is there a schema (Zod, Joi, Yup) that duplicates what the type system could encode?

#### P4 — Primitive Obsession (High)
- Are domain concepts represented as primitives? (`string` for Email, `number` for UserID, `string` for ISBN)
- **Fix**: Branded types. `type Email = string & { readonly __brand: 'Email' }`.

#### P5 — Missing Discriminated Unions (High)
- Are polymorphic types modeled with `type: string` + optional fields for each variant?
- Are there `if (obj.type === 'x')` runtime checks that the compiler should enforce?
- **Fix**: `type Event = ClickEvent | SubmitEvent | ErrorEvent` with `kind` discriminant.

#### P6 — No Composition, Only Inheritance (High)
- Are base classes / abstract classes used where composition would suffice?
- Are types extended with `extends` when they should be intersected with `&`?
- Are DTOs duplicated for "create" vs "update" vs "response" instead of composed from fragments?

#### P7 — Implicit Relationships (Medium)
- Are foreign keys stored as raw `string` / `number` with no type link to the parent?
- Are bidirectional relationships maintained manually without type safety?
- **Fix**: `type Order = { customerId: Customer['id'] }` instead of `customerId: string`.

#### P8 — No Versioning or Lifecycle (Medium)
- Do types have no `createdAt`, `updatedAt`, `version` fields?
- Is there no deprecation mechanism for old fields?
- Are legacy types mixed with current types without separation?

#### P9 — Duplicated Logic Across Types (Medium)
- Is the same validation logic copied into multiple types?
- Are there "helper" types that exist only because the main types are poorly designed?
- **Fix**: Extract shared constraints into reusable type utilities.

#### P10 — Weak Collection Types (Medium)
- Are arrays used where `Set`, `Map`, or `ReadonlyArray` would be more precise?
- Are object keys typed as `string` instead of a closed union of valid keys?
- Are dictionaries typed as `Record<string, T>` when the keys are actually known?

#### P11 — No Generic Parameterization (Medium)
- Are types duplicated for different entity kinds instead of using generics?
- Is `PaginationResult<User>` / `PaginationResult<Order>` defined separately?
- **Fix**: `interface PaginationResult<T> { items: T[]; total: number; page: number }`.

#### P12 — Missing Output Schema (Low)
- Do functions that produce structured output have no formal return type?
- Are API responses typed as `any` or `unknown`?
- Are error responses untyped?

### Step 3: Reflection — Step Back

STOP. Do not start designing yet.

1. **Re-read the problem catalog.** Are there problems you missed? Problems you graded wrong?
2. **Identify the root causes.** Are the symptoms 12 separate issues or 3 systemic ones?
3. **Ask "what is this model trying to achieve?"** — not "what does it currently do."
4. **Identify the core entities** — the 3-5 concepts that everything else revolves around.
5. **Identify the invariants** — what must ALWAYS be true? (e.g., "an Order must have at least one LineItem")
6. **Think about the language's full type power:**
   - Can branded types prevent accidental substitution?
   - Can discriminated unions replace optional-field state machines?
   - Can generics eliminate duplicated collection types?
   - Can mapped types generate views (read-only, partial, nullable)?
   - Can conditional types model state transitions?
   - Can template literal types enforce naming conventions?
   - Can intersection types compose behavior without inheritance?

### Step 4: Design the Improved Model

Design a new model from first principles. Every design decision must have a rationale.

#### 4.1 Branded Types — Prevent Accidental Substitution

```typescript
// A UserID is not just any string. It has structural proof.
type UserID = string & { readonly __brand: 'UserID' };
// An Email is distinct from a Username, even though both are strings at runtime.
type Email = string & { readonly __brand: 'Email' };
// A PriceInCents prevents mixing dollars with cents.
type PriceInCents = number & { readonly __brand: 'PriceInCents' };
```

#### 4.2 Discriminated Unions — Replace Optional-Field State Machines

```typescript
// BAD: 8 possible states, only 3 valid
type Order = { status: string; paidAt?: Date; shippedAt?: Date; cancelledAt?: Date };
// GOOD: Exactly 3 valid states, impossible to construct invalid ones
type Order = PendingOrder | PaidOrder | ShippedOrder | CancelledOrder;
type PendingOrder = { kind: 'pending'; id: OrderID; createdAt: Date };
type PaidOrder = { kind: 'paid'; id: OrderID; createdAt: Date; paidAt: Date };
type ShippedOrder = { kind: 'shipped'; id: OrderID; createdAt: Date; paidAt: Date; shippedAt: Date };
```

#### 4.3 Generics — Eliminate Duplication

```typescript
// One type, infinite specializations
interface Paginated<T> { readonly items: ReadonlyArray<T>; readonly total: number; readonly page: number; }
interface ApiResponse<T> { readonly data: T; readonly meta: ResponseMeta; }
// Domain-specific specializations inherit constraints
interface OrderResponse extends ApiResponse<Order> {}
```

#### 4.4 Composition — Build from Fragments

```typescript
// Core entity fragments
interface Timestamped { readonly createdAt: Date; readonly updatedAt: Date; }
interface Versioned { readonly version: number; }
interface Identified { readonly id: string; }
// Composed without inheritance
type Customer = Identified & Timestamped & Versioned & {
  readonly email: Email;
  readonly name: string;
};
```

#### 4.5 Mapped Types — Derive Views Automatically

```typescript
// Never write these by hand again
type CreateDTO<T> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>;
type UpdateDTO<T> = Partial<CreateDTO<T>>;
type ReadonlyDTO<T> = Readonly<T>;
// Domain-specific derived types
type CreateCustomer = CreateDTO<Customer>;
type UpdateCustomer = UpdateDTO<Customer>;
```

#### 4.6 Conditional Types — Model State Transitions

```typescript
// A transition function's return type depends on the input type
type Transition<From, Event> =
  From extends PendingOrder ? (Event extends 'pay' ? PaidOrder : never) :
  From extends PaidOrder ? (Event extends 'ship' ? ShippedOrder : never) :
  never;
```

#### 4.7 Template Literal Types — Enforce Conventions

```typescript
// Enforce ISO date format at compile time
type ISODate = `${number}-${number}-${number}T${number}:${number}:${number}Z`;
// Enforce semantic version format
type Semver = `${number}.${number}.${number}`;
```

### Step 5: Create the HTML Presentation

Write a self-contained, zero-dependency HTML file at `docs/brainstorming/<date>-<slug>.html`.

The HTML must include:

1. **Hero section** — Title, subtitle, architecture deep-dive badge
2. **Table of Contents** — sticky nav linking to every section
3. **Current State** — Summary stats (type count, problem count, severity breakdown)
4. **Problem Catalog** — Each problem as a card with severity badge and TypeScript fix
5. **The Vision** — What perfection looks like (6 bullet points)
6. **TypeScript Data Model** — Full type definitions with syntax highlighting
7. **Composition in Action** — Side-by-side comparison (before/after)
8. **Validation Layer** — How invalid states become unrepresentable
9. **Decision Log** — Why each design choice was made, with rejected alternatives
10. **Anti-Patterns** — Traps to avoid when adopting the new model
11. **Migration Roadmap** — Numbered, incremental steps with tooling guidance
12. **Conclusion** — Summary quote

**Design requirements for the HTML:**
- Single file, zero external dependencies (no CDN, no JS, no build step)
- Dark theme with semantic color coding
- Manual CSS syntax highlighting for TypeScript
- Responsive grid layouts for comparisons
- Cards with left-border color coding (rose = problem, emerald = solution, amber = warning)

### Step 6: Git Workflow

Before finishing:

1. Run `git status` to verify what changed.
2. Stage the new HTML file specifically with `git add <file>`.
3. Commit with a VERY DETAILED commit message describing:
   - What was reviewed
   - Problems identified (list them)
   - TypeScript features used in the redesign
   - Files added
   - Design decisions
4. Push with `git push`.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
