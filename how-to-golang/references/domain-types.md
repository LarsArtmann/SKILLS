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

| Syntax                    | Kind            | Identity                                           | Inherits methods?                    | Assignable to underlying?         |
| ------------------------- | --------------- | -------------------------------------------------- | ------------------------------------ | --------------------------------- |
| `type Alias = Underlying` | Type alias      | **Same type** — `Alias` IS `Underlying` everywhere | Yes — it's the same type             | Yes — freely, no conversion       |
| `type Def Underlying`     | Type definition | **New, distinct type**                             | No — only methods you write on `Def` | No — explicit conversion required |

### Nuances the table does not show (compiler-verified)

Every claim below was compile- and run-verified against Go 1.26 (2026-08-21),
including the exact compiler errors, so you can recognize them in the wild.

**1. A definition does NOT inherit methods — so it does not satisfy the
underlying type's interfaces.**

```go
type DefBuffer bytes.Buffer // definition

var _ io.Writer = &DefBuffer{}
// compile error: "*DefBuffer does not implement io.Writer (missing method Write)"
```

An alias keeps satisfying everything the underlying type satisfies (it IS
that type). Methods are not forbidden on a definition — they are lost, and
you can re-declare them — but rewriting them all is exactly the cost that
usually signals you wanted an alias.

One case that looks like a contradiction: a definition whose underlying type
is an **interface** (`type MyReader io.Reader`) creates a new interface type
with the same method set, and Go's interface satisfaction is structural, so
values still flow between `MyReader` and `io.Reader` freely. The method-loss
trap only fires for definitions from **concrete** types.

**2. Operators and built-in operations ARE preserved for definitions.**

Methods do not carry over, but the underlying type's operators do:

```go
type Celsius float64

c := Celsius(20) + Celsius(5)*2 // OK: float64 arithmetic preserved
c2 := c > Celsius(0)            // OK: comparison operators preserved

type Lines []string

lines := Lines{"a"}
lines[0] = "z"             // OK: indexing preserved
lines = append(lines, "b") // OK: append works on any defined slice type
```

**3. Untyped constants assign without conversion; typed values do not.**

```go
type MyInt int

const five = 5
var a MyInt = five // OK: untyped constant takes MyInt's type
f := float64(1.5)
var b MyInt = f
// compile error: "cannot use f (variable of type float64) as MyInt value
// in variable declaration"
```

This asymmetry — `var a MyInt = 5` works but `var b MyInt = intVar` does
not — is a recurring source of confusion: constants are untyped in Go,
variables are not. Aliases have no such asymmetry (there is only one type).

**4. `reflect` sees them differently.**

```go
type DefDur time.Duration
type AliasDur = time.Duration

reflect.TypeOf(DefDur(5)) == reflect.TypeOf(time.Duration(5))   // false — distinct
reflect.TypeOf(AliasDur(5)) == reflect.TypeOf(time.Duration(5)) // true  — identical
reflect.TypeOf(DefDur(5)).Name()   // "DefDur"
reflect.TypeOf(AliasDur(5)).Name() // "Duration" (the underlying name)
```

An alias is invisible to reflection; a definition is a brand-new type.
Serialization frameworks, ORMs, and anything switching on `reflect.Type`
identity will treat them differently.

**5. Embedding vs aliasing vs definition — three different tools.**

When you want to extend a type from another package:

| Declaration                        | What you get      | Methods of the foreign type                                             |
| ---------------------------------- | ----------------- | ----------------------------------------------------------------------- |
| `type T = other.T` (alias)         | Same type, renamed | Kept — but you cannot add new ones (`cannot define new methods on non-local type`) |
| `type T other.T` (definition)      | Distinct type      | All lost — `T` starts with an empty method set                            |
| `type T struct{ other.T }` (embed) | New struct         | Promoted — callable on `T`, and you can add your own methods on top       |

Embedding is the only way to give a foreign type new behavior while keeping
the old: embedded methods are promoted and the embedded value is a real
field you can also reach directly. The trade: `T` is not `other.T`, it no
longer satisfies interfaces requiring the exact original type, and the
embedded field name joins the struct's namespace.

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

With the alias, `func SendEmail(e Email)` accepts _any_ string — the type
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
