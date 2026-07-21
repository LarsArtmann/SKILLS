# Anti-Patterns and Agent Guidance

> Loaded on demand from [../SKILL.md](../SKILL.md). The four real regressions from blindly driving `hierarchical-errors lint ./...` to zero, plus the agent-specific "fix-to-zero" trap guidance.

## Table of Contents

1. [Anti-Pattern 1: Hand-rolling `errors.Is` via an interface assertion](#anti-pattern-1-hand-rolling-errorsis-via-an-interface-assertion)
2. [Anti-Pattern 2: Treating a const value as a type](#anti-pattern-2-treating-a-const-value-as-a-type)
3. [Anti-Pattern 3: Trusting the linter's conditional without reading the IF](#anti-pattern-3-trusting-the-linters-conditional-without-reading-the-if)
4. [Anti-Pattern 4: Suppressing without a reason](#anti-pattern-4-suppressing-without-a-reason)
5. [Agent-specific guidance: the "fix-to-zero" trap](#agent-specific-guidance-the-fix-to-zero-trap)

---

## Anti-Pattern 1: Hand-rolling `errors.Is` via an interface assertion

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

---

## Anti-Pattern 2: Treating a const value as a type

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

---

## Anti-Pattern 3: Trusting the linter's conditional without reading the IF

The diagnostic says: "consider using errors.AsType instead of errors.Is **if** you are matching by type rather than by value."

The word **if** is load-bearing. It means: _the linter cannot tell whether you are doing type matching or value matching, so it is asking you to decide._ If you don't decide, and just apply the suggestion, you will regress value-matching code.

**Rule:** When you see "consider ... if", you MUST answer the IF before changing anything.

---

## Anti-Pattern 4: Suppressing without a reason

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

## Agent-specific guidance: the "fix-to-zero" trap

Agents under "fix everything to zero" prompts are the highest-risk users of this tool. They will cargo-cult.

When invoked to "fix all hierarchical-errors findings", an agent MUST:

1. **Classify each finding** into the `errors.As` (strong) or `errors.Is` (advisory) bucket before touching code
2. **For `errors.Is` findings**, resolve the type of the second argument:
   - If it resolves to `*types.Const`, a `syscall.Errno`, or a package-level `var Err* = errors.New(...)`, **do not migrate** — add a `//nolint:legacyerrors // <reason>` comment instead
   - Only migrate if the second argument is a typed custom error AND the surrounding code reads the error's structured fields
3. **Never hand-roll an `interface{ Is(error) bool }` assertion** as a replacement for `errors.Is`. This always regresses semantics.
4. **Compile and test after every fix** — not just at the end. If a test that exercised the error path breaks, revert the fix and suppress instead.
5. **State the classification** in the commit message or PR description so reviewers can audit.

### For humans

1. Run `GOEXPERIMENT=jsonv2 hierarchical-errors lint ./...`
2. Pipe through `grep errors.As` first — these are real modernizations, fix them all
3. Pipe through `grep errors.Is` separately — review each one with the decision tree in [./decision-tree.md](./decision-tree.md)
4. After every batch of fixes: `go build ./... && go test -race ./...`
5. Commit `errors.As` migrations and `errors.Is` reviews as **separate commits** — they have different risk profiles

### For CI

Do not gate CI on `errors.Is` findings — the false-positive rate is too high. Either:

- Use `--severity-threshold error` to gate only on the `errors.As` findings (if your `hierarchical-errors` version supports it), or
- Run the linter but only fail the build on `errors.As`-category diagnostics, or
- Run with `--type legacy_as` to scope to the high-precision diagnostic only

Gating on the full linter output trains developers to suppress everything reflexively, which hides real modernization opportunities later.
