---
name: hierarchical-errors
description: Use when migrating Go error-matching code on Go 1.26+, running `hierarchical-errors lint` or `hierarchical-errors fix`, reviewing findings that say "use errors.AsType instead of errors.As" or "consider using errors.AsType instead of errors.Is", or when the user says "fix all hierarchical-errors findings", "migrate errors.As", "modernize error handling", "errors.As is legacy", or asks whether `errors.Is` should become `errors.AsType`. Prevents the cargo-cult trap where agents driven to zero the linter regress sentinel-value matching (io.EOF, context.Canceled, sql.ErrNoRows, syscall errno values) by hand-rolling `interface{ Is(error) bool }` assertions or treating const errno values as types. Covers the safe fix-first workflow, broken-vs-working CLI flags (--no-suppress, -o, -f, --severity, --type-aware are broken; --type legacy_as and //nolint:legacyerrors work), the errors.Is-vs-errors.As decision tree, and CI gating strategy.
metadata:
  tags: go, golang, errors, linting, hierarchical-errors, errors-astype, errors-is, errors-as, go1.26, modernization, cargo-cult, agent-safety
---

# hierarchical-errors workflow

`hierarchical-errors` is a Go 1.26+ linter that pushes code away from `errors.As` (genuinely legacy in Go 1.26+) toward the new generic `errors.AsType[E]` API. It also flags `errors.Is` calls — and **this is where well-meaning agents regress codebases.**

`errors.Is` is **not legacy.** It is the stdlib-documented API for sentinel value matching (`io.EOF`, `sql.ErrNoRows`, `context.Canceled`, `syscall.EXDEV`, your own `var ErrFoo = errors.New(...)`). The linter's `errors.Is` diagnostic is advisory and frequently wrong. On a real cleanup of `golangci-lint-auto-configure` (2026-07-21), the `errors.Is` diagnostic had **0% precision** — every one of 8 findings was a false positive.

**The highest-risk user of this tool is an agent under a "fix everything to zero" prompt.** This skill exists to prevent that regression.

## TL;DR — two diagnostics, two safety profiles

| Diagnostic                                          | Severity you should assign                                                       | Default action                                               |
| --------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `use errors.AsType instead of errors.As`            | **Real modernization** — `errors.As` is genuinely legacy in 1.26+                | Apply the fix, then compile and test                         |
| `consider using errors.AsType instead of errors.Is` | **Advisory and frequently wrong** — `errors.Is` is correct for sentinel matching | Review case-by-case; expect the majority to be correct as-is |

The word **if** in "consider ... **if** you are matching by type rather than by value" is load-bearing. It means: _the linter cannot tell whether you are doing type matching or value matching, so it is asking you to decide._ If you don't decide, and just apply the suggestion, you will regress value-matching code.

## The safe workflow

Use the `fix` subcommand as your primary tool. It has a semantic guard that `lint` lacks: `fix` understands that `errors.Is` matches by value and refuses to auto-migrate it. `lint` reports `errors.Is` at the same severity as `errors.As`, with a message that reads as a recommendation.

### Step 1: `fix` dry-run

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors fix ./...
```

Shows a diff of every `errors.As` → `errors.AsType` transformation it WOULD apply. Will not touch `errors.Is` calls. Review the diff.

### Step 2: Apply the fixes

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors fix ./... --write
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
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./...
```

Now you see the remaining findings — all `errors.Is` advisories. For each one, run the [decision tree](#decision-tree-for-errorsis-findings) below to classify it as:

- **Sentinel match** → suppress with `//nolint:legacyerrors // <reason>`
- **Type match that should use `AsType`** → migrate manually (rare)

Expect the vast majority to be sentinels.

### Step 5: For CI, use `--type legacy_as` (the only reliable filter)

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./... --type legacy_as
```

Scopes the linter to ONLY `errors.As` findings (the high-precision diagnostic). Excludes all `errors.Is` advisories. This is the only reliable way to gate CI without false-positive noise.

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

**The suppression linter name is `legacyerrors`** (lowercase, no prefix). It is not `hierarchical-errors`, not `he`, not `legacy_errors`. This name is undocumented in the README — only discoverable from the `lint` subcommand help text.

## Anti-patterns to never commit

These are real regressions from blindly driving `hierarchical-errors lint ./...` to zero. For full code examples and the agent-specific guidance, load [./references/anti-patterns.md](./references/anti-patterns.md).

1. **Hand-rolling `errors.Is` via an interface assertion** — reinvents `errors.Is`, AND doesn't work for wrapped errors. `errors.AsType[interface{ error; Is(target error) bool }](err)` returns `false` for `fmt.Errorf("%w", sentinel)` because the wrapper has no `Is` method. Keep `errors.Is`.

2. **Treating a const value as a type** — `syscall.EXDEV` is a value of type `syscall.Errno`, not a type itself. Migrating `errors.Is(err, syscall.EXDEV)` to `AsType[syscall.Errno](err)` + `!=` is longer, slower, and loses wrapper-chain matching.

3. **Trusting the linter's conditional without reading the IF** — the word **if** in the diagnostic is load-bearing. You MUST answer the IF before changing anything.

4. **Suppressing without a reason** — `//nolint:legacyerrors` (no reason) works today but in six months someone may refactor `ErrFoo` into a typed error and the suppression silently hides a now-valid migration. Always state the assumption.

## Flag reliability

Most CLI flags were verified broken on 2026-07-21. Full verification methodology and the `--no-suppress` reproduction is in [./references/cli-and-flags.md](./references/cli-and-flags.md).

### Flags that WORK

| Flag                    | Subcommand  | Behavior                                                                           |
| ----------------------- | ----------- | ---------------------------------------------------------------------------------- |
| `--type legacy_as`      | `lint`      | Filters to only `errors.As` findings. Exits 0 if none. **The reliable CI filter.** |
| `--violations-only`     | `lint`      | Shows only violations, no summary. Cosmetic but works.                             |
| `//nolint:legacyerrors` | source code | Suppresses the finding on that line. Recognized by both `lint` and `fix`.          |

### Flags that are BROKEN or INEFFECTIVE (do not rely on)

| Flag                                      | Actual behavior                                                         | Use instead                         |
| ----------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------- |
| `--no-suppress`                           | Returns 0 even when nolint directives are suppressing real violations   | Remove-and-restore technique        |
| `-o <file>`                               | File never created. Output always goes to stdout.                       | Shell redirection (`> file`)        |
| `-f <format>`                             | Ignored. Always outputs text format.                                    | Parse text output, or fork the tool |
| `--severity-threshold error`              | Shows `errors.Is` advisories regardless of threshold value              | `--type legacy_as`                  |
| `--severity error` / `--severity warning` | Both produce identical output                                           | `--type legacy_as`                  |
| `--type-aware`                            | Does not skip sentinel matches. `errors.Is(err, io.EOF)` still flagged. | Manual review via decision tree     |

## Exit code reference

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
# GitHub Actions snippet — gates only on high-precision findings
- name: Run hierarchical-errors (errors.As only)
  env:
    GOEXPERIMENT: jsonv2
  run: |
    hierarchical-errors lint ./... --type legacy_as

# Optional: report all findings (including advisories) as annotations
# without failing the build
- name: Report advisory findings
  if: always()
  env:
    GOEXPERIMENT: jsonv2
  run: |
    hierarchical-errors lint ./... || true
```

Gating on the full linter output trains developers to suppress everything reflexively, which hides real modernization opportunities later.

## Verification checklist

Before marking a `hierarchical-errors` cleanup "done":

- [ ] Every `errors.As` finding is either fixed or suppressed with a reason
- [ ] Every `errors.Is` finding is classified as sentinel (suppressed) or type (migrated)
- [ ] No `interface{ Is(error) bool }` assertions were introduced
- [ ] No `errors.Is(err, syscall.XXX)` was migrated to `AsType[syscall.Errno]` + `!=`
- [ ] `go build ./...` passes
- [ ] `go test -race ./...` passes, especially tests covering the modified error paths
- [ ] Every `//nolint:legacyerrors` has a specific reason, not just `//nolint`
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
- [./references/cli-and-flags.md](./references/cli-and-flags.md) — Full flag reliability table, the `--no-suppress` bug reproduction, the remove-and-restore verification technique, exit codes
- [./references/anti-patterns.md](./references/anti-patterns.md) — All four anti-patterns with full code, plus the agent-specific "fix-to-zero" trap guidance
