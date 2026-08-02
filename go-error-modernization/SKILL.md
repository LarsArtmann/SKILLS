---
name: go-error-modernization
description: Use when modernizing Go 1.26+ error handling — migrating `errors.As` to the new generic `errors.AsType[E]`, deciding whether an `errors.Is` finding should be migrated or kept, reviewing linter diagnostics that say "use errors.AsType instead of errors.As" or "consider errors.AsType instead of errors.Is", or when the user says "fix all erraudit findings", "run erraudit", "migrate errors.As", "modernize error handling", or asks whether `errors.Is` should become `errors.AsType`. Prevents the cargo-cult trap where agents driven to zero a linter regress sentinel-value matching (io.EOF, sql.ErrNoRows, context.Canceled, syscall errno values) by hand-rolling `interface{ Is(error) bool }` assertions or treating const errno values as types.
allowed-tools: bash go view edit grep
metadata:
  tags: go, golang, errors, linting, erraudit, errors-astype, errors-is, errors-as, go1.26, modernization, cargo-cult, agent-safety
---

# Go Error Modernization

> ## Verification status (read first)
>
> **What is verified independent of the source feedback:**
>
> - `errors.AsType[E error](err error) (E, bool)` is a real Go 1.26.0 stdlib function — confirmed via [pkg.go.dev/errors](https://pkg.go.dev/errors).
> - The Go docs explicitly say "For most uses, prefer AsType" over `errors.As`.
> - `errors.Is` is NOT legacy. It is the stdlib-documented API for sentinel value matching (`io.EOF`, `sql.ErrNoRows`, `syscall.EXDEV`, `context.Canceled`, your own `var ErrFoo = errors.New(...)`). See the [Go blog: Working with Errors](https://go.dev/blog/go1.13-errors).
> - The decision tree and anti-patterns below follow logically from how these three APIs actually behave.
>
> **What could NOT be independently verified (treat as reported, not confirmed):**
>
> - The `erraudit` CLI binary is **not publicly findable**. Searched GitHub, Sourcegraph, pkg.go.dev (2026-08-02). Zero matches for `erraudit`, `--enforce-go-error-family`, or the previous name `hierarchical-errors`. The tool is reported to exist by the repository owner (who also owns the `errorfamily` library — see below), so it is likely private/unreleased. All CLI flags, exit codes, and behaviors below are reported by the user and original source feedback — treat as hypotheses to verify against your installed binary.
> - The `--enforce-go-error-family` flag is **not found in any public codebase**. It presumably relates to [`github.com/larsartmann/go-error-family`](https://github.com/larsartmann/go-error-family) (v0.10.0), a real structured error classification library with six error families (Rejection, Conflict, Transient, Corruption, Infrastructure, Orchestration). The flag's exact behavior has not been verified.
> - The `legacyerrors` analyzer name (used in `//nolint:legacyerrors`) does not appear in `golang.org/x/tools/go/analysis/passes/` or any public repository.
> - Exit codes, error messages, and the "0% precision" statistic in [./references/cli-and-flags.md](./references/cli-and-flags.md) are reproduced from the original source feedback (2026-07-21) and have not been re-verified against the renamed `erraudit` binary.
> - The `GOEXPERIMENT=jsonv2` prefix on every command is unconfirmed as a requirement. It may be a quirk of the original project (`golangci-lint-auto-configure`) rather than a hard requirement.
>
> **The decision tree, anti-patterns, and fix-to-zero warning are verified** — they follow from how Go's three error-matching APIs actually behave, independent of any specific linter. The skill's value survives even if `erraudit` is private or changes.

---

## TL;DR — three error-matching APIs, two safety profiles

Go 1.26+ has three complementary error-matching primitives. Knowing which one you are doing is the difference between a safe modernization and a regression:

| API                        | Purpose                                              | Status in Go 1.26+                                                          |
| -------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------- |
| `errors.AsType[E](err)`    | Extract structured data from a custom error **type** | **Preferred** — Go docs say "For most uses, prefer AsType" over `errors.As` |
| `errors.Is(err, sentinel)` | Compare against a known error **value**              | **Current.** Not legacy. The correct API for sentinels like `io.EOF`.       |
| `errors.As(err, &target)`  | Custom predicate matching via pointer (rare)         | Legacy in spirit — `AsType` covers 99% of cases                             |

**The cargo-cult trap:** any linter that flags both `errors.As` (real modernization) and `errors.Is` (frequently a false positive) at the same severity trains agents under "fix everything to zero" prompts to migrate `errors.Is` calls that should have stayed put. Sentinel value matching regresses. Wrapped errors stop matching. This skill exists to prevent that regression.

### Two diagnostics, two safety profiles

| Diagnostic                                          | Severity you should assign                                                       | Default action                                               |
| --------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `use errors.AsType instead of errors.As`            | **Real modernization** — `errors.As` is genuinely legacy in 1.26+                | Apply the fix, then compile and test                         |
| `consider using errors.AsType instead of errors.Is` | **Advisory and frequently wrong** — `errors.Is` is correct for sentinel matching | Review case-by-case; expect the majority to be correct as-is |

The word **if** in "consider ... **if** you are matching by type rather than by value" is load-bearing. It means: _the linter cannot tell whether you are doing type matching or value matching, so it is asking you to decide._ If you don't decide, and just apply the suggestion, you will regress value-matching code.

## The safe workflow

Use the `fix` subcommand as your primary tool (if your linter has one). The `fix` subcommand in the reported tool has a semantic guard that `lint` lacks: `fix` understands that `errors.Is` matches by value and refuses to auto-migrate it. `lint` reports `errors.Is` at the same severity as `errors.As`, with a message that reads as a recommendation.

> **Note:** The workflow below uses `erraudit` (renamed from `hierarchical-errors` in 2026-08-02). Always pass `--type-aware`. Run in every directory containing a `go.mod` — monorepos often have multiple modules. The workflow logic is: apply safe `errors.As` migrations first, then review `errors.Is` findings manually, then gate CI.

### Step 1: `fix` dry-run

Run `erraudit` in **every directory containing a `go.mod`** — a monorepo may have multiple modules:

```bash
find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
  (cd "$(dirname "$gomod")" && GOEXPERIMENT=jsonv2 erraudit fix ./... --type-aware)
done
```

Always pass `--type-aware` — it enables type information to reduce false positives on `errors.Is` sentinel matches. Shows a diff of every `errors.As` → `errors.AsType` transformation it WOULD apply. Will not touch `errors.Is` calls. Review the diff.

### Step 2: Apply the fixes

```bash
find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
  (cd "$(dirname "$gomod")" && GOEXPERIMENT=jsonv2 erraudit fix ./... --type-aware --write)
done
```

Applies only the safe `errors.As` transformations. It explicitly refuses `errors.Is`:

```
No auto-fixable violations found (2 diagnostic(s) detected).
  2 advisory-only: errors.Is is not auto-fixable (value matching vs type matching).
```

This is the correct behavior.

### Step 3: Build and test

```bash
go build ./... && go test -race ./...
```

The `errors.As` → `errors.AsType` transformation is mechanical but still changes code. Verify it compiles and tests pass.

### Step 4: Handle `errors.Is` findings manually

```bash
find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
  (cd "$(dirname "$gomod")" && GOEXPERIMENT=jsonv2 erraudit lint ./... --type-aware)
done
```

Now you see the remaining findings — all `errors.Is` advisories. For each one, run the [decision tree](#decision-tree-for-errorsis-findings) below to classify it as:

- **Sentinel match** → suppress with `//nolint:legacyerrors // <reason>`
- **Type match that should use `AsType`** → migrate manually (rare)

Expect the vast majority to be sentinels.

### Step 5: For CI, use `--type legacy_as` (the only reliable filter reported) or `--type-aware`

With `--type-aware`, the false-positive rate on `errors.Is` is significantly reduced. For CI gating, you have two options:

**Option A (recommended): `--type-aware`** — use if `--type-aware` correctly skips your sentinel matches:

```bash
find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
  (cd "$(dirname "$gomod")" && GOEXPERIMENT=jsonv2 erraudit lint ./... --type-aware)
done
```

**Option B (fallback): `--type legacy_as`** — if `--type-aware` still produces too many false positives, filter to only `errors.As` findings:

```bash
find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
  (cd "$(dirname "$gomod")" && GOEXPERIMENT=jsonv2 erraudit lint ./... --type legacy_as)
done
```

Scopes the linter to ONLY `errors.As` findings (the high-precision diagnostic). Excludes all `errors.Is` advisories.

**Optional: `--enforce-go-error-family`** *(unverified flag)* — reported to enforce that errors conform to a structured error family pattern. Presumably related to [`github.com/larsartmann/go-error-family`](https://github.com/larsartmann/go-error-family), which classifies errors into six families (Rejection, Conflict, Transient, Corruption, Infrastructure, Orchestration). The flag's exact behavior and diagnostics have not been verified against a binary.

## Decision tree for `errors.Is` findings

Run this tree **before** touching any `errors.Is` code. For background on the three error-matching APIs and the full tree with examples, load [./references/decision-tree.md](./references/decision-tree.md).

```
What is the second argument to errors.Is?
│
├── A package-level sentinel: var ErrFoo = errors.New(...) or fmt.Errorf(...)
│   examples: io.EOF, sql.ErrNoRows, mypkg.ErrNotFound
│   └── KEEP errors.Is. Suppress: //nolint:legacyerrors // sentinel value match
│
├── A syscall errno value: syscall.EXDEV, syscall.ENOENT, syscall.EADDRINUSE
│   syscall.Errno values are designed for errors.Is. Do not migrate.
│   └── KEEP errors.Is. Suppress: //nolint:legacyerrors // syscall errno sentinel
│
├── A stdlib sentinel: context.Canceled, context.DeadlineExceeded, fs.ErrNotExist
│   └── KEEP errors.Is. Suppress: //nolint:legacyerrors // stdlib sentinel
│
├── A custom error TYPE stored in a var or const
│   Ask: are you reading the error's structured fields afterward?
│   ├── yes → migrate to errors.AsType[*T](err) and read the fields
│   └── no  → it's being used as a sentinel. KEEP errors.Is.
│
└── Anything else (literal, function call, method result)
    Read the code carefully. The linter is probably wrong.
    └── KEEP errors.Is. Suppress: //nolint:legacyerrors // <specific reason>
```

**The suppression linter name `legacyerrors`** (lowercase, no prefix) is reproduced from the source feedback and could not be verified against a public binary. If your linter rejects `//nolint:legacyerrors`, check its help text for the actual analyzer name and update this skill.

## Anti-patterns to never commit

These are real regressions from blindly driving a linter to zero. For full code examples and the agent-specific guidance, load [./references/anti-patterns.md](./references/anti-patterns.md).

1. **Hand-rolling `errors.Is` via an interface assertion** — reinvents `errors.Is`, AND doesn't work for wrapped errors. `errors.AsType[interface{ error; Is(target error) bool }](err)` returns `false` for `fmt.Errorf("%w", sentinel)` because the wrapper has no `Is` method. Keep `errors.Is`.

2. **Treating a const value as a type** — `syscall.EXDEV` is a value of type `syscall.Errno`, not a type itself. Migrating `errors.Is(err, syscall.EXDEV)` to `AsType[syscall.Errno](err)` + `!=` is longer, slower, and loses wrapper-chain matching.

3. **Trusting the linter's conditional without reading the IF** — the word **if** in the diagnostic is load-bearing. You MUST answer the IF before changing anything.

4. **Suppressing without a reason** — `//nolint:legacyerrors` (no reason) works today but in six months someone may refactor `ErrFoo` into a typed error and the suppression silently hides a now-valid migration. Always state the assumption.

## Flag reliability

The flag table below combines the original source feedback (2026-07-21, when the tool was called `hierarchical-errors`) with updated information (2026-08-02, after the rename to `erraudit`). The `--type-aware` flag was previously reported broken but is now recommended — the tool has been updated. Other flags have not been re-verified against the renamed binary. Full reproduction methodology and the `--no-suppress` reproduction are in [./references/cli-and-flags.md](./references/cli-and-flags.md).

### Flags that WORK

| Flag                        | Subcommand  | Behavior                                                                                                                    |
| --------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------- |
| `--type-aware`              | both        | Uses type information to reduce `errors.Is` false positives on sentinel matches. **Recommended on every invocation.**       |
| `--type legacy_as`          | `lint`      | Filters to only `errors.As` findings. Exits 0 if none. **Reliable CI filter (fallback if `--type-aware` is insufficient).** |
| `--enforce-go-error-family` | both        | **Unverified.** Reported to enforce errors conform to the `go-error-family` library pattern. Behavior not confirmed against a binary. |
| `--violations-only`         | `lint`      | Shows only violations, no summary. Cosmetic but works.                                                                      |
| `//nolint:legacyerrors`     | source code | Suppresses the finding on that line. Recognized by both `lint` and `fix`.                                                   |

### Flags reported BROKEN or INEFFECTIVE (verify before relying on)

| Flag                                      | Reported behavior                                                     | Use instead                          |
| ----------------------------------------- | --------------------------------------------------------------------- | ------------------------------------ |
| `--no-suppress`                           | Returns 0 even when nolint directives are suppressing real violations | Remove-and-restore technique         |
| `-o <file>`                               | File never created. Output always goes to stdout.                     | Shell redirection (`> file`)         |
| `-f <format>`                             | Ignored. Always outputs text format.                                  | Parse text output, or fork the tool  |
| `--severity-threshold error`              | Shows `errors.Is` advisories regardless of threshold value            | `--type-aware` or `--type legacy_as` |
| `--severity error` / `--severity warning` | Both produce identical output                                         | `--type-aware` or `--type legacy_as` |

## Exit code reference (unverified — see verification status above)

| Scenario                                                     | Exit code |
| ------------------------------------------------------------ | --------- |
| `lint` with no violations                                    | 0         |
| `lint` with any violation (including advisory `errors.Is`)   | 1         |
| `fix` dry-run with fixable violations + remaining advisories | 2         |
| `fix --write` with fixes applied + remaining advisories      | 2         |
| `fix` with only advisory violations (nothing fixable)        | 0         |

There is no way to get exit 0 from `lint` when `errors.Is` advisories are present, short of suppressing them with `//nolint:legacyerrors` or filtering with `--type legacy_as`.

## CI integration

Gate the build on `errors.As` modernizations only (high precision) while still surfacing `errors.Is` advisories as information. Do NOT gate on the full `lint` output — the false-positive rate on `errors.Is` is too high.

```yaml
# GitHub Actions snippet — gates on erraudit with --type-aware
# Runs in every directory containing a go.mod
- name: Run erraudit
  env:
    GOEXPERIMENT: jsonv2
  run: |
    find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
      (cd "$(dirname "$gomod")" && erraudit lint ./... --type-aware)
    done

# Fallback: if --type-aware still produces too many false positives,
# gate on errors.As only:
#   erraudit lint ./... --type legacy_as
#
# Optional stricter mode: add --enforce-go-error-family if your
# project uses a structured error family.

# Report all findings (including advisories) as annotations
# without failing the build
- name: Report advisory findings
  if: always()
  env:
    GOEXPERIMENT: jsonv2
  run: |
    find . -name go.mod -not -path "*/vendor/*" | while read gomod; do
      (cd "$(dirname "$gomod")" && erraudit lint ./... --type-aware || true)
    done
```

Gating on the full linter output trains developers to suppress everything reflexively, which hides real modernization opportunities later.

## Verification checklist

Before marking a cleanup "done":

- [ ] Every `errors.As` finding is either fixed or suppressed with a reason
- [ ] Every `errors.Is` finding is classified as sentinel (suppressed) or type (migrated)
- [ ] No `interface{ Is(error) bool }` assertions were introduced
- [ ] No `errors.Is(err, syscall.XXX)` was migrated to `AsType[syscall.Errno]` + `!=`
- [ ] `go build ./...` passes
- [ ] `go test -race ./...` passes, especially tests covering the modified error paths
- [ ] Every suppression directive has a specific reason, not just `//nolint`
- [ ] The commit message distinguishes `errors.As` migrations from `errors.Is` reviews

## When the linter IS right about `errors.Is`

Rare, but real. Signal: the second argument is a **typed error with structured fields**, and you'd benefit from reading those fields.

```go
type ValidationError struct {
    Field string
    Code  string
}

var ErrInvalid = &ValidationError{Field: "unknown", Code: "generic"}

// LINTER IS RIGHT — you are using ErrInvalid as a type, not a sentinel.
if errors.Is(err, ErrInvalid) {
    // ... but then you can't read .Field or .Code here
}

// CORRECT MIGRATION
if ve, ok := errors.AsType[*ValidationError](err); ok {
    log.Printf("field=%s code=%s", ve.Field, ve.Code)
}
```

If you don't need the fields, `errors.Is` is still fine — the linter is then a false positive.

## References

Load on demand:

- [./references/decision-tree.md](./references/decision-tree.md) — Background on Go's three error-matching APIs, the full decision tree with code examples, and how to suppress correctly
- [./references/cli-and-flags.md](./references/cli-and-flags.md) — Full flag reliability table, the `--no-suppress` bug reproduction, the remove-and-restore verification technique, exit codes. Flag behaviors reflect the original feedback (2026-07-21, when the tool was called `hierarchical-errors`) and have not all been re-verified against the renamed `erraudit` binary — see verification status at the top of this file.
- [./references/anti-patterns.md](./references/anti-patterns.md) — All four anti-patterns with full code, plus the agent-specific "fix-to-zero" trap guidance
- [../how-to-golang/SKILL.md](../how-to-golang/SKILL.md) — Broader Go development decision guide (what libraries to use, what to avoid)
