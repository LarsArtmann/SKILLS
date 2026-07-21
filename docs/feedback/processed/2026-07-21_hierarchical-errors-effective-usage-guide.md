# How to Use `hierarchical-errors` Effectively

**Date:** 2026-07-21
**Audience:** Developers and AI agents running `hierarchical-errors lint` on Go 1.26+ codebases
**Scope:** Practical guidance for getting value from the linter without cargo-culting fixes that regress error handling

---

## TL;DR

`hierarchical-errors` emits **two fundamentally different diagnostics** that must be treated differently:

| Diagnostic                                          | Severity you should assign                                                               | Default action                                               |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `use errors.AsType instead of errors.As`            | **Real modernization** — `errors.As` is genuinely legacy in Go 1.26+                     | Apply the fix, then compile and test                         |
| `consider using errors.AsType instead of errors.Is` | **Advisory and frequently wrong** — `errors.Is` is the correct API for sentinel matching | Review case-by-case; expect the majority to be correct as-is |

Blindly applying both to zero will **regress your error handling**. This document explains why and gives a decision tree for telling the difference.

---

## Background: Go 1.26+ Has Three Error-Matching APIs, Not One

Go's standard library provides three distinct matching primitives. Each has a specific purpose. The linter only understands two of them.

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

The Go standard library and every major Go style guide treat these as **complementary**, not competing. `errors.Is` is not legacy. It is the correct API for comparing against sentinel values like `io.EOF`, `sql.ErrNoRows`, `syscall.EXDEV`, `context.Canceled`, and your own package-level `var ErrXxx = errors.New(...)`.

`hierarchical-errors` correctly pushes migration away from `errors.As` (which IS legacy in 1.26+). It over-reaches by also flagging `errors.Is`.

---

## The Decision Tree

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

## How to Suppress Correctly

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

---

## Anti-Patterns I Have Personally Committed

These are real regressions from blindly driving `hierarchical-errors lint ./...` to zero. Don't repeat them.

### Anti-Pattern 1: Hand-rolling `errors.Is` via an interface assertion

```go
// WRONG — reinvents errors.Is, AND doesn't work for wrapped errors
matchedError, ok := errors.AsType[interface {
    error
    Is(target error) bool
}](err)
if ok && matchedError.Is(atomicwrite.ErrConcurrentModification) {
    // ...
}

// CORRECT — errors.Is walks the chain, handles wrapped errors, calls Is at each level
if errors.Is(err, atomicwrite.ErrConcurrentModification) {
    // ...
}
```

The hand-rolled version only matches when the error itself (or an intermediate wrapper) has an `Is` method. `fmt.Errorf("%w", sentinel)` produces a `*fmt.wrapError` with no `Is` method, so the assertion returns `false` and the branch silently dead-ends. `errors.Is` handles this correctly by walking the `Unwrap` chain.

**Rule:** If the original code was `errors.Is(err, sentinel)`, the replacement MUST preserve chain-walking semantics. `errors.AsType` does not do this. Keep `errors.Is`.

### Anti-Pattern 2: Treating a const value as a type

```go
// WRONG — EXDEV is a value of type syscall.Errno, not a type itself
errno, ok := errors.AsType[syscall.Errno](err)
if !ok || errno != syscall.EXDEV {
    return fmt.Errorf("rename: %w", err)
}

// CORRECT — errors.Is is the stdlib-documented way to match errno values
if !errors.Is(err, syscall.EXDEV) {
    return fmt.Errorf("rename: %w", err)
}
```

`syscall.EXDEV` is a const. Matching a const value is what `errors.Is` is for. Migrating it to `AsType` + `!=` is longer, slower, and loses the ability to match through wrappers that may re-wrap errno values.

### Anti-Pattern 3: Trusting the linter's conditional without reading the IF

The diagnostic says: "consider using errors.AsType instead of errors.Is **if** you are matching by type rather than by value."

The word **if** is load-bearing. It means: _the linter cannot tell whether you are doing type matching or value matching, so it is asking you to decide._ If you don't decide, and just apply the suggestion, you will regress value-matching code.

**Rule:** When you see "consider ... if", you MUST answer the IF before changing anything.

### Anti-Pattern 4: Suppressing without a reason

```go
// WRONG
if errors.Is(err, ErrFoo) { //nolint:legacyerrors
    ...
}
```

This works today. In six months, someone refactors `ErrFoo` into a typed error, and the suppression silently hides a now-valid migration. Always state the assumption:

```go
// RIGHT
if errors.Is(err, ErrFoo) { //nolint:legacyerrors // ErrFoo is a sentinel; value match, not type match
    ...
}
```

---

## Recommended Workflow

### For humans

1. Run `GOEXPERIMENT=jsonv2 hierarchical-errors lint ./...`
2. Pipe through `grep errors.As` first — these are real modernizations, fix them all
3. Pipe through `grep errors.Is` separately — review each one with the decision tree
4. After every batch of fixes: `go build ./... && go test -race ./...`
5. Commit `errors.As` migrations and `errors.Is` reviews as **separate commits** — they have different risk profiles

### For AI agents

Agents under "fix everything to zero" prompts are the highest-risk users of this tool. They will cargo-cult.

When invoked to "fix all hierarchical-errors findings", an agent MUST:

1. **Classify each finding** into the `errors.As` (strong) or `errors.Is` (advisory) bucket before touching code
2. **For `errors.Is` findings**, resolve the type of the second argument:
   - If it resolves to `*types.Const`, a `syscall.Errno`, or a package-level `var Err* = errors.New(...)`, **do not migrate** — add a `//nolint:legacyerrors // <reason>` comment instead
   - Only migrate if the second argument is a typed custom error AND the surrounding code reads the error's structured fields
3. **Never hand-roll an `interface{ Is(error) bool }` assertion** as a replacement for `errors.Is`. This always regresses semantics.
4. **Compile and test after every fix** — not just at the end. If a test that exercised the error path breaks, revert the fix and suppress instead.
5. **State the classification** in the commit message or PR description so reviewers can audit.

### For CI

Do not gate CI on `errors.Is` findings — the false-positive rate is too high. Either:

- Use `--severity-threshold error` to gate only on the `errors.As` findings (if your `hierarchical-errors` version supports it), or
- Run the linter but only fail the build on `errors.As`-category diagnostics, or
- Run with `--type legacy_as` to scope to the high-precision diagnostic only

Gating on the full linter output trains developers to suppress everything reflexively, which hides real modernization opportunities later.

---

## Verification Checklist

Before marking a `hierarchical-errors` cleanup "done", verify:

- [ ] Every `errors.As` finding is either fixed or suppressed with a reason
- [ ] Every `errors.Is` finding is classified as sentinel (suppressed) or type (migrated)
- [ ] No `interface{ Is(error) bool }` assertions were introduced
- [ ] No `errors.Is(err, syscall.XXX)` was migrated to `AsType[syscall.Errno]` + `!=`
- [ ] `go build ./...` passes
- [ ] `go test -race ./...` passes, especially tests covering the modified error paths
- [ ] Every `//nolint:legacyerrors` has a specific reason, not just "nolint"
- [ ] The commit message distinguishes `errors.As` migrations from `errors.Is` reviews

---

## When the Linter Is Right About `errors.Is`

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

## Related Reading

- The Go blog: ["Working with Errors"](https://go.dev/blog/go1.13-errors) — the canonical reference for `errors.Is` and `errors.As`
- Go 1.26 release notes — `errors.AsType[E]` generic API
- `syscall.Errno.Is` — documented behavior; `errors.Is` is the supported way to match errno values
- This project's own `hierarchical-errors/docs/errors-astype-guide.md` — explicitly lists `errors.Is(err, ErrSentinel)` as Rule 2 of the "Golden Rules." The linter should match its own docs.
