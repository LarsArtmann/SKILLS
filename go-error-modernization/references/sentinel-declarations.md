# Sentinel declaration contract: declare with the `error` interface type

Verified 2026-10-08 against `github.com/larsartmann/erraudit`
(v0.5.1-0.20260922174106-1c6809adf02e) and a live erraudit-driven
modernization in `github.com/larsartmann/go-retry`.

## The contract

Package-level sentinel errors must be declared with the interface type, not a
concrete type:

```go
// Correct — the standard sentinel declaration:
var ErrExhausted error = errorfamily.NewInfrastructure("retry.exhausted", "...")

// Wrong — concrete type defeats erraudit's sentinel recognition:
var ErrExhausted *errorfamily.Error = errorfamily.NewInfrastructure(...)
// or via type elision (same problem, harder to spot):
var ErrExhausted = errorfamily.NewInfrastructure(...)
```

## Why

- erraudit (and the general Go idiom) recognize `var X error = ...` as
  sentinel-matching setup: `errors.Is(err, X)` call sites then classify as
  legitimate sentinel value matches, not migration candidates.
- The concrete-type declaration forces every consumer that stores the
  sentinel in a struct field or passes it through an interface to also name
  the concrete type — API surface pollution for zero benefit.
- Runtime behavior is identical (the constructor returns the concrete value
  either way); only the declared type and the static-analysis surface change.

## The guard pattern

The regression (a "fix" that retypes sentinels to please another tool) is
cheaply CI-guardable without erraudit in the loop:

```go
func TestTerminalSentinelsStayInterfaceTyped(t *testing.T) {
    t.Parallel()
    source := readRepoFile(t, "retry.go")
    for _, name := range []string{"ErrExhausted", "ErrCanceled", "ErrDeadlineExceeded"} {
        pattern := `(?m)^var ` + name + ` error = errorfamily\.NewInfrastructure\(`
        if !regexp.MustCompile(pattern).MatchString(source) {
            t.Errorf("sentinel %s must keep the error interface type", name)
        }
    }
}
```

Note the drill result from the discovery session: retyping to an unexported
concrete name (`*errorfamily.InfrastructureError`) fails closed at compile
time (the type is unexported), but TYPE ELISION compiles silently — so the
guard must assert the full declaration shape, not just "compiles".
