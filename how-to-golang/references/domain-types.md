# Domain Types (go-composable-business-types)

Required for all new services. No primitive types for domain concepts.

## Core Types

| Type                     | Package     | Use For                        |
| ------------------------ | ----------- | ------------------------------ |
| `id.ID[Brand, V]`        | `id`        | Branded entity identifiers     |
| `nanoid.NanoID`          | `nanoid`    | URL-safe unique IDs (21 chars) |
| `types.Email`            | `types`     | Validated email                |
| `types.URL`              | `types`     | Validated URL (http/https)     |
| `types.Cents`            | `types`     | Money (int64, no float errors) |
| `money.Money`            | `money`     | ISO 4217 currency              |
| `types.Percentage`       | `types`     | 0-100 validated                |
| `types.Timestamp`        | `types`     | Domain-wrapped time.Time       |
| `types.Duration`         | `types`     | Domain-wrapped time.Duration   |
| `bounded.BoundedString`  | `bounded`   | Length-validated string        |
| `datapoint.DataPoint[T]` | `datapoint` | Data + complete audit trail    |
| `actor.ActorChain[T]`    | `actor`     | Ordered actor chain for audit  |
| `temporal.Bitemporal`    | `temporal`  | validFrom/Until + recorded     |

## Branded ID Pattern (canonical)

```go
package ids

import (
	id "github.com/larsartmann/go-composable-business-types/id"
	"github.com/larsartmann/go-composable-business-types/nanoid"
)

type UserBrand struct{}
type UserID = id.ID[UserBrand, nanoid.NanoID]

func GenerateUserID() UserID {
	return id.NewID[UserBrand, nanoid.NanoID](nanoid.New())
}

func GenerateUserIDFromString(s string) (UserID, error) {
	nid, err := nanoid.Parse(s)
	if err != nil { return UserID{}, fmt.Errorf("invalid user ID: %w", err) }
	return id.NewID[UserBrand, nanoid.NanoID](nid), nil
}
```

Key points:

- `id.ID[Brand, V]` implements `sql.Scanner`, `driver.Valuer`, `json.Marshaler`/`Unmarshaler` — no manual methods
- Zero value serializes to JSON `null`
- `ProcessUser(orderID)` → **compile error**, not runtime bug
- sqlc `overrides` maps DB columns to branded IDs directly

## Type alias (`=`) vs type definition (no `=`)

Go has two ways to declare a named type from an underlying type, and they
behave very differently. Picking the wrong one causes subtle bugs — methods
that silently vanish, conversions that shouldn't be needed (or are missing
when they should be), and `errors.As`/`errors.Is` matches that fail.

| Syntax                     | Kind            | Identity | Inherits methods? | Assignable to underlying? |
| -------------------------- | --------------- | -------- | ----------------- | ------------------------- |
| `type Alias = Underlying` | Type alias      | **Same type** — `Alias` IS `Underlying` everywhere | Yes — it's the same type | Yes — freely, no conversion |
| `type Def Underlying`     | Type definition | **New, distinct type** | No — only methods you write on `Def` | No — explicit conversion required |

### When to use a type alias (`type X = Y`)

Use an alias when `X` and `Y` must be **the same type** — interchangeable
everywhere, sharing all methods, no conversions:

- **Branded IDs that wrap a generic base type**, e.g. `type UserID = id.ID[UserBrand, nanoid.NanoID]`. The alias keeps `UserID` assignable to `id.ID[UserBrand, nanoid.NanoID]` so library functions, scanners, and marshalers all work without conversion or re-declaration.
- **Re-exporting a type from another package** for a cleaner import path
  (`type Config = configpkg.Config`).
- **Gradual refactoring** — alias the old name to the new type so callers
  compile during a move, then remove the alias later.

### When to use a type definition (`type X Y`)

Use a type definition when `X` must be a **distinct type** with its own
identity, methods, and validation — not freely interchangeable with `Y`:

- **Domain primitives that need compile-time safety**, e.g. `type Email string`. You get a distinct type that can't be accidentally passed where a plain `string` is expected. You must write methods (validation, parsing) yourself; the underlying `string` methods do NOT carry over.
- **Preventing accidental cross-assignment** — `type UserID string` and `type OrderID string` are two different types; passing one where the other is expected is a compile error. With aliases (`type UserID = string`), there is no such guard.
- **Attaching new methods** to a wrapped type without polluting the
  underlying type's API.

### Common mistake: alias where definition is needed

```go
// WRONG — this is just string, no type safety at all
type Email = string

// RIGHT — distinct type, compile-time safety, write your own methods
type Email string
```

With the alias, `func SendEmail(e Email)` accepts *any* string — the type
safety you wanted is gone.

### Common mistake: definition where alias is needed

This is the most common and most painful variant. It happens when a type
is meant to be a convenience name for an existing function signature or
struct, but is declared as a definition instead of an alias — creating a
**distinct type** that requires explicit conversion at every composition
boundary.

#### Example 1: branded IDs

```go
// WRONG — UserID is now a distinct type; id.NewID[...] returns
// id.ID[UserBrand, nanoid.NanoID], not UserID, so every call site
// needs a conversion and library functions won't accept it.
type UserID id.ID[UserBrand, nanoid.NanoID]

// RIGHT — same type, all library methods and conversions work
type UserID = id.ID[UserBrand, nanoid.NanoID]
```

#### Example 2: middleware types across packages (real-world)

A parent package and a sub-module both declare a `Middleware` type for
`func(http.Handler) http.Handler`. If both use **definitions**, they are
two distinct types — middleware from the sub-module cannot be passed to
the parent package's `Chain()` or `MiddlewareStack` without an explicit
conversion at every call site:

```go
// parent package (recorder.go)
type Middleware func(http.Handler) http.Handler  // definition — distinct type

// sub-module (server_timing/middleware.go)
type Middleware func(http.Handler) http.Handler  // ANOTHER distinct type

// Pain: every composition boundary needs a conversion
addStackMiddleware(t, stack, MiddlewareServerTiming,
    Middleware(servertiming.ServerTimingMiddleware()))  // explicit conversion required
```

With **aliases**, both are the same underlying type and compose freely:

```go
// parent package (recorder.go)
type Middleware = func(http.Handler) http.Handler  // alias — same type

// sub-module (server_timing/middleware.go)
type Middleware = func(http.Handler) http.Handler  // alias — same type

// No conversion needed — they're identical types
addStackMiddleware(t, stack, MiddlewareServerTiming,
    servertiming.ServerTimingMiddleware())  // just works
```

The rule: when the same function signature (or struct) is shared across
packages that must interoperate, use **aliases** so the types are
identical. Use definitions only when you want to prevent cross-assignment.

### Decision rule

> If the type exists only to give a **shorter or domain-specific name** to an
> existing type and must stay fully interchangeable with it → **alias** (`=`).
>
> If the type exists to create a **new, distinct concept** with its own
> invariants, methods, or validation, and must NOT be freely mixed with its
> underlying type → **definition** (no `=`).

A quick diagnostic: if you find yourself writing `MyType(otherPkg.Thing())`
conversions at call sites, you probably have a **definition** where an
**alias** would be correct. If you find bugs where `Email` accepts any
`string`, you probably have an **alias** where a **definition** would be
correct.
