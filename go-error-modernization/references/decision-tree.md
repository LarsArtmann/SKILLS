# Decision Tree for `erraudit` Findings

> Loaded on demand from [../SKILL.md](../SKILL.md). Covers Go's three error-matching APIs, the full `errors.Is` decision tree with code examples, and how to suppress correctly.

## Verification status

The **decision tree and the three-APIs mental model are verified** — they follow from how `errors.Is`, `errors.As`, and `errors.AsType` actually behave in Go 1.26+, independent of any specific linter. The Go standard library docs and the [Go blog: Working with Errors](https://go.dev/blog/go1.13-errors) confirm the semantics.

The **`//nolint:legacyerrors` suppression name** and the **specific classification examples from `golangci-lint-auto-configure`** are reproduced from the source feedback. The analyzer name `legacyerrors` could not be found in any public Go analysis pass. If your linter rejects the directive, check its help text for the actual analyzer name.

## Table of Contents

1. [Verification status](#verification-status)
2. [Background: Go 1.26+ has three error-matching APIs, not one](#background-go-126-has-three-error-matching-apis-not-one)
3. [The decision tree](#the-decision-tree)
4. [How to suppress correctly](#how-to-suppress-correctly)
5. [Classification examples](#classification-examples)
6. [When the linter IS right about `errors.Is`](#when-the-linter-is-right-about-errorsis)
7. [Related reading](#related-reading)

---

## Background: Go 1.26+ has three error-matching APIs, not one

Go's standard library provides three distinct matching primitives. Each has a specific purpose. The `erraudit` linter only understands two of them.

```go
// 1. Type matching — extract structured data from a custom error type
if ve, ok := errors.AsType[*ValidationError](err); ok {
    log.Printf("field=%s code=%s", ve.Field, ve.Code)
}

// 2. Sentinel value matching — compare against a known error value
if errors.Is(err, ErrNotFound) {
    return 404
}

// 3. Custom predicate matching via As (rare; AsType covers 99% of cases)
var target someInterface
if errors.As(err, &target) { ... }
```

The Go standard library and every major Go style guide treat these as **complementary**, not competing. `errors.Is` is not legacy. It is the correct API for comparing against sentinel values like:

- `io.EOF`
- `sql.ErrNoRows`
- `syscall.EXDEV`, `syscall.ENOENT`, `syscall.EADDRINUSE`
- `context.Canceled`, `context.DeadlineExceeded`
- `fs.ErrNotExist`
- Your own package-level `var ErrXxx = errors.New(...)`

`erraudit` correctly pushes migration away from `errors.As` (which IS legacy in 1.26+). It over-reaches by also flagging `errors.Is`.

---

## The decision tree

When the linter reports a finding, run this tree **before** touching the code:

```
Is the diagnostic "use errors.AsType instead of errors.As"?
├── YES → Apply the suggested fix. Compile. Test. Done.
└── NO (it's the "consider ... errors.Is" form) → Continue.

What is the second argument to errors.Is?
│
├── A package-level sentinel: var ErrFoo = errors.New(...) or fmt.Errorf(...)
│   │
│   │  examples: io.EOF, sql.ErrNoRows, mypkg.ErrNotFound
│   │
│   └── KEEP errors.Is. Suppress with //nolint:legacyerrors // sentinel value match
│
├── A syscall errno value: syscall.EXDEV, syscall.ENOENT, syscall.EADDRINUSE
│   │
│   │  syscall.Errno values are designed for errors.Is. The stdlib itself
│   │  uses errors.Is(err, syscall.EXDEV). Do not migrate these.
│   │
│   └── KEEP errors.Is. Suppress with //nolint:legacyerrors // syscall errno sentinel
│
├── A stdlib sentinel: context.Canceled, context.DeadlineExceeded, fs.ErrNotExist
│   │
│   │  These are sentinels by design. errors.Is is the documented API.
│   │
│   └── KEEP errors.Is. Suppress with //nolint:legacyerrors // stdlib sentinel
│
├── A custom error TYPE stored in a var or const
│   │
│   │  Ambiguous. Ask: are you using the error's fields afterward?
│   │  If yes → migrate to errors.AsType[*T](err) and read the fields.
│   │  If no  → it's being used as a sentinel. KEEP errors.Is.
│   │
│   └── Migrate only if you need the type's structured data
│
└── Anything else (literal, function call, method result)
    │
    │  Read the code carefully. The linter is probably wrong.
    │  When in doubt, keep errors.Is and suppress with a clear reason.
    │
    └── KEEP errors.Is. Suppress with //nolint:legacyerrors // <specific reason>
```

---

## How to suppress correctly

The linter respects three suppression forms. Always use the **specific** form with a reason.

```go
// GOOD — specific linter, with reason
if errors.Is(err, syscall.EXDEV) { //nolint:legacyerrors // syscall errno sentinel
    return copyAcrossDevices(src, dst)
}

// GOOD — specific linter, with reason, on the line above
//nolint:legacyerrors // ErrConcurrentModification is a sentinel from atomicwrite
if errors.Is(err, atomicwrite.ErrConcurrentModification) {
    return errorfamily.NewConflict(...)
}

// ACCEPTABLE — bare nolint, but weaker (suppresses all linters on this line)
if errors.Is(err, io.EOF) { //nolint
    break
}

// BAD — no reason; future readers won't know why
if errors.Is(err, ErrCacheMiss) { //nolint:legacyerrors
    return defaultResponse
}
```

The reason is for the next person (which may be you in three months). "sentinel value match" tells them everything they need.

**The suppression linter name is `legacyerrors`** (lowercase, no prefix). It is not `erraudit`, not `he`, not `legacy_errors`. This name is not documented in the README — it is only discoverable from the `lint` subcommand help text ("Run the legacyerrors go/analysis linter").

---

## Classification examples

Real examples from cleaning up `golangci-lint-auto-configure` on 2026-07-21 (as reported in the source feedback — the specific file paths could not be independently verified):

| File                                              | Code                                      | Classification   | Action                                          |
| ------------------------------------------------- | ----------------------------------------- | ---------------- | ----------------------------------------------- |
| `pkg/utils/retry.go:82`                           | `errors.Is(err, context.Canceled)`        | Stdlib sentinel  | `//nolint:legacyerrors // sentinel value match` |
| `pkg/errors/errors_test.go:36`                    | `errors.Is(wrapped, ErrNotGitRepository)` | Package sentinel | `//nolint:legacyerrors // sentinel value match` |
| `pkg/errors/errors_test.go:156`                   | `errors.Is(wrapped, cause)`               | Sentinel (test)  | `//nolint:legacyerrors // sentinel value match` |
| `internal/cli/cmd_configure_internal_test.go:281` | `errors.Is(err, ErrChangesNeeded)`        | Package sentinel | `//nolint:legacyerrors // sentinel value match` |

All 8 findings in that codebase were reported as sentinel matches, with zero real migrations. **"Precision of the `errors.Is` diagnostic on this codebase: 0%"** is the source feedback's claim, not independently verified.

---

## When the linter IS right about `errors.Is`

To be clear about when the `errors.Is` diagnostic IS actionable:

```go
type ValidationError struct {
    Field string
    Code  string
}

var ErrInvalid = &ValidationError{Field: "unknown", Code: "generic"}

// LINTER IS RIGHT — you are using ErrInvalid as a type, not a sentinel.
// You should extract the structured data.
if errors.Is(err, ErrInvalid) {
    // ... but then you can't read .Field or .Code here
}

// CORRECT MIGRATION
if ve, ok := errors.AsType[*ValidationError](err); ok {
    log.Printf("field=%s code=%s", ve.Field, ve.Code)
}
```

The signal: the second argument is a **typed error with structured fields**, and you'd benefit from reading those fields. If you don't need the fields, `errors.Is` is still fine — the linter is then a false positive.

---

## Related reading

- The Go blog: ["Working with Errors"](https://go.dev/blog/go1.13-errors) — the canonical reference for `errors.Is` and `errors.As`
- Go 1.26 release notes — `errors.AsType[E]` generic API
- `syscall.Errno.Is` — documented behavior; `errors.Is` is the supported way to match errno values
- The `erraudit` project's own `docs/errors-astype-guide.md` (referenced in the source feedback as explicitly listing `errors.Is(err, ErrSentinel)` as Rule 2 of the "Golden Rules" — **this doc could not be located publicly to confirm**)
