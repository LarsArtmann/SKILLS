# CLI Workflow, Flag Reliability, and Verification

> Loaded on demand from [../SKILL.md](../SKILL.md). Covers every CLI flag's reported behavior, the `--no-suppress` bug reproduction, the remove-and-restore verification technique, and exit codes.

## ⚠ Verification status — read before trusting any claim below

The source feedback dated 2026-07-21 reports these flags and behaviors as **"verified"** because the original author ran them against a binary on the `golangci-lint-auto-configure` project. **No subsequent session has been able to reproduce these checks** because:

1. The `hierarchical-errors` binary is not publicly findable on GitHub, Sourcegraph, pkg.go.dev, or in `golang.org/x/tools` as of 2026-07-21.
2. The `legacyerrors` analyzer name does not appear in `golang.org/x/tools/go/analysis/passes/` or any public repository.
3. The closest public tool is Go's own `modernize` analyzer (`golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize`), which uses a `-fix` flag rather than `lint`/`fix` subcommands and does not have a `--type legacy_as` filter.

**Treat every claim in this file as a hypothesis to verify against your installed binary, not as confirmed behavior.** The verification methodology below (minimal reproduction files, flag isolation, remove-and-restore) is sound and reusable regardless of which specific tool you are testing — but the _results_ listed here are unverified.

If you have access to the real binary, please:

1. Re-run the verification methodology below
2. Update this file with confirmed behavior
3. Remove the verification disclaimer from [../SKILL.md](../SKILL.md) and this file

If the binary does not exist publicly, the **methodology** in this file still teaches how to test any linter's flags — that part is durable.

## Table of Contents

1. [The safe workflow (step by step)](#the-safe-workflow-step-by-step)
2. [Flag reliability reference](#flag-reliability-reference)
3. [Verification method for `--no-suppress`](#verification-method-for---no-suppress)
4. [How to verify `//nolint:legacyerrors` actually works](#how-to-verify-nolintlegacyerrors-actually-works)
5. [The `fix` vs `lint` inconsistency](#the-fix-vs-lint-inconsistency-and-why-fix-is-better)
6. [Exit code reference](#exit-code-reference)
7. [Practical example: full cleanup of a real codebase](#practical-example-full-cleanup-of-a-real-codebase)
8. [CI integration template](#ci-integration-template)

---

## The safe workflow (step by step)

### Step 1: Run `fix` in dry-run mode

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors fix ./...
```

This shows a diff of every `errors.As` → `errors.AsType` transformation it WOULD apply. It will not touch `errors.Is` calls. Review the diff.

### Step 2: Apply the fixes

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors fix ./... --write
```

This applies only the safe `errors.As` transformations. It explicitly refuses `errors.Is`:

```
No auto-fixable violations found (2 diagnostic(s) detected).
  2 advisory-only: errors.Is is not auto-fixable (value matching vs type matching).
```

This is the correct behavior. The `fix` subcommand is smarter than `lint` — it understands that `errors.Is` is value matching and should not be auto-migrated.

### Step 3: Build and test

```bash
go build ./... && go test -race ./...
```

The `errors.As` → `errors.AsType` transformation is mechanical but still changes code. Verify it compiles and tests pass.

### Step 4: Handle `errors.Is` findings manually

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./...
```

Now you see the remaining findings — all `errors.Is` advisories. For each one, use the decision tree from [./decision-tree.md](./decision-tree.md) to classify it as:

- **Sentinel match** (e.g., `io.EOF`, `context.Canceled`, `sql.ErrNoRows`, your own `var ErrFoo = errors.New(...)`) → suppress with `//nolint:legacyerrors // <reason>`
- **Type match that should use `AsType`** → migrate manually

### Step 5: For CI, use `--type legacy_as` (the only reliable filter)

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./... --type legacy_as
```

This scopes the linter to ONLY `errors.As` findings (the high-precision diagnostic). It excludes all `errors.Is` advisories. This is the only reliable way to gate CI without false-positive noise.

---

## Flag reliability reference

Every flag below was tested on 2026-07-21 against `hierarchical-errors lint` by the original feedback author. Results were obtained by creating a minimal reproduction file and running each flag in isolation. **These results have not been independently reproduced** — see the verification status at the top of this file.

### Flags that WORK

| Flag                    | Subcommand  | Behavior                                                                           | Verified |
| ----------------------- | ----------- | ---------------------------------------------------------------------------------- | -------- |
| `--type legacy_as`      | `lint`      | Filters to only `errors.As` findings. Exits 0 if none. **The reliable CI filter.** | Yes      |
| `--violations-only`     | `lint`      | Shows only violations, no summary. Cosmetic but works.                             | Yes      |
| `//nolint:legacyerrors` | source code | Suppresses the finding on that line. Recognized by both `lint` and `fix`.          | Yes      |

### Flags that are BROKEN or INEFFECTIVE

| Flag                                      | Subcommand | Expected                                                   | Actual                                                                                                                                   | Impact                                                                                         |
| ----------------------------------------- | ---------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `--no-suppress`                           | `lint`     | Show violations that `//nolint` is hiding                  | Returns 0 even when nolint directives are active and suppressing real violations                                                         | You cannot audit your suppression list with this flag. Must manually remove nolints to verify. |
| `-o <file>`                               | `lint`     | Write output to file                                       | File never created. Output always goes to stdout.                                                                                        | Cannot redirect lint output for CI artifact collection.                                        |
| `-f <format>`                             | `lint`     | Output in json/sarif/jsonl/etc.                            | Ignored. Always outputs text format. (The main `hierarchical-errors` analysis command supports formats; the `lint` subcommand does not.) | Cannot get structured output for editor/CI integration.                                        |
| `--severity-threshold error`              | `lint`     | Show only `error`-severity findings (the `errors.As` ones) | Shows `errors.Is` advisories regardless of threshold value                                                                               | Cannot use severity to filter. Use `--type legacy_as` instead.                                 |
| `--severity error` / `--severity warning` | `lint`     | Filter by severity                                         | Both produce identical output                                                                                                            | Severity filter is non-functional.                                                             |
| `--type-aware`                            | `lint`     | "Reduces false positives" per help text                    | Does not reduce `errors.Is` false positives. `errors.Is(err, io.EOF)` still flagged.                                                     | Type-aware mode does not use type information to skip sentinel matches.                        |

---

## Verification method for `--no-suppress`

```bash
# 1. Create a file with a known violation
cat > /tmp/repro.go << 'EOF'
package main
import ("errors"; "io")
func main() {
    var err error
    if errors.Is(err, io.EOF) { _ = err } //nolint:legacyerrors // sentinel
}
EOF

# 2. Run WITHOUT --no-suppress → exits 0 (nolint suppresses it)
hierarchical-errors lint /tmp/repro.go  # EXIT: 0

# 3. Run WITH --no-suppress → should show the suppressed violation
hierarchical-errors lint /tmp/repro.go --no-suppress  # EXIT: 0 — BUG: shows nothing

# 4. Remove the nolint, run again → violation appears
# (edit the file to remove //nolint:legacyerrors)
hierarchical-errors lint /tmp/repro.go  # EXIT: 1 — violation appears
```

This proves `--no-suppress` does not disable suppression filtering.

---

## How to verify `//nolint:legacyerrors` actually works

Since `--no-suppress` is broken, you cannot audit your suppressions by running the linter. Instead, use the **remove-and-restore technique**:

```bash
# 1. Temporarily comment out one nolint directive
# (edit the file: change //nolint:legacyerrors to //TEST-nolint:legacyerrors)

# 2. Run the linter — the violation should appear
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./path/to/file.go
# Expected: the finding appears at the line where you removed the nolint

# 3. Restore the nolint directive
# (edit the file back)

# 4. Run again — should be clean
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./path/to/file.go
# Expected: no output, exit 0
```

This is tedious but reliable. Do it once per nolint to confirm the linter name is correct and the directive syntax is right.

**Common mistake:** Using the wrong linter name. The suppression linter name is `legacyerrors` (lowercase, no prefix). It is not `hierarchical-errors`, not `he`, not `legacy_errors`. This name is **not documented in the README** — it is only discoverable from the `lint` subcommand help text ("Run the legacyerrors go/analysis linter").

---

## The `fix` vs `lint` inconsistency (and why `fix` is better)

The `fix` subcommand is the safer entry point because it has a built-in semantic guard that `lint` lacks:

- **`fix` knows** that `errors.Is` matches by value, not type. It refuses to auto-fix them and says so explicitly: "errors.Is is not auto-fixable (value matching vs type matching)."
- **`lint` does not know this.** It reports `errors.Is` findings at the same severity as `errors.As` findings, with a message that reads as a recommendation.

This means the two subcommands disagree on what constitutes a fixable problem. If you only use `fix`, you get safe, correct transformations. If you use `lint` and drive to zero, you will regress sentinel matches.

**Recommendation:** Use `fix` as your primary tool. Use `lint` only for the manual review of remaining `errors.Is` findings (Step 4 above) and for CI gating with `--type legacy_as` (Step 5).

---

## Exit code reference

| Scenario                                                     | Exit code |
| ------------------------------------------------------------ | --------- |
| `lint` with no violations                                    | 0         |
| `lint` with any violation (including advisory `errors.Is`)   | 1         |
| `fix` dry-run with fixable violations + remaining advisories | 2         |
| `fix --write` with fixes applied + remaining advisories      | 2         |
| `fix` with only advisory violations (nothing fixable)        | 0         |

Note: `lint` exits 1 for BOTH severity levels. There is no way to get exit 0 from `lint` when `errors.Is` advisories are present, short of suppressing them with `//nolint:legacyerrors` or filtering with `--type legacy_as`.

---

## Practical example: full cleanup of a real codebase

This example is from cleaning up `golangci-lint-auto-configure` on 2026-07-21 (as reported in the source feedback). The project had 12 findings across 6 files. **The "0% precision" claim and the specific file paths below are reproduced from the feedback and could not be independently verified.**

### Initial state

```
12 findings total:
  - 4 × "use errors.AsType instead of errors.As"      (real modernizations)
  - 8 × "consider using errors.AsType instead of errors.Is" (advisories)
```

### Step 1: `fix` dry-run

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors fix ./...
```

This showed the 4 `errors.As` transformations as diffs. The 8 `errors.Is` findings were reported as "advisory-only: not auto-fixable."

### Step 2: `fix --write`

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors fix ./... --write
```

Applied the 4 `errors.As` → `errors.AsType` transformations automatically. Clean, correct, included removing the redundant `var target *Type` declarations.

### Step 3: Build and test

```bash
GOEXPERIMENT=jsonv2 go build ./... && GOEXPERIMENT=jsonv2 go test -race ./...
```

All passed. The `errors.As` migrations were semantically safe.

### Step 4: Handle the 8 `errors.Is` findings manually

Each one was a sentinel match:

| File                                              | Code                                      | Classification   | Action                                          |
| ------------------------------------------------- | ----------------------------------------- | ---------------- | ----------------------------------------------- |
| `pkg/utils/retry.go:82`                           | `errors.Is(err, context.Canceled)`        | Stdlib sentinel  | `//nolint:legacyerrors // sentinel value match` |
| `pkg/errors/errors_test.go:36`                    | `errors.Is(wrapped, ErrNotGitRepository)` | Package sentinel | `//nolint:legacyerrors // sentinel value match` |
| `pkg/errors/errors_test.go:156`                   | `errors.Is(wrapped, cause)`               | Sentinel (test)  | `//nolint:legacyerrors // sentinel value match` |
| `internal/cli/cmd_configure_internal_test.go:281` | `errors.Is(err, ErrChangesNeeded)`        | Package sentinel | `//nolint:legacyerrors // sentinel value match` |

All 8 were sentinel matches. Zero were real migrations. **Precision of the `errors.Is` diagnostic on this codebase: 0%.**

### Step 5: Verify

```bash
GOEXPERIMENT=jsonv2 hierarchical-errors lint ./...  # EXIT: 0
GOEXPERIMENT=jsonv2 go test ./...                    # all pass
```

### Lessons from this cleanup

1. **Every `errors.Is` finding was a false positive.** This matches the prediction: in mature Go codebases, `errors.Is` calls are dominated by sentinel matches.
2. **The `fix` subcommand saved time and prevented regressions.** It handled all 4 real migrations correctly and refused to touch the 8 sentinel matches.
3. **The `//nolint:legacyerrors` suppression works reliably.** The linter name is undocumented but correct.
4. **`--no-suppress` could not be used to audit suppressions** because the flag is broken. The remove-and-restore technique was used instead.

---

## CI integration template

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

This gates the build on `errors.As` modernizations only (high precision) while still surfacing `errors.Is` advisories as information. Do NOT gate on the full `lint` output — the false-positive rate on `errors.Is` is too high.

---

## Summary: what to trust and what not to trust

> ⚠ The trust assignments below reflect the source feedback's claims. The methodology is sound; the specific results are unverified. See the verification status at the top of this file.

| Feature                                               | Trust it?                                                 |
| ----------------------------------------------------- | --------------------------------------------------------- |
| `fix` subcommand (errors.As transformations)          | **Yes** — safe, correct, refuses errors.Is                |
| `lint --type legacy_as`                               | **Yes** — reliable filter for high-precision findings     |
| `//nolint:legacyerrors` suppression                   | **Yes** — works correctly (but name is undocumented)      |
| `lint` on errors.Is findings                          | **No** — 0% precision on real codebases. Review manually. |
| `--no-suppress` flag                                  | **No** — broken, does not show suppressed violations      |
| `-o` / `-f` flags on `lint`                           | **No** — ignored, output always goes to stdout as text    |
| `--severity` / `--severity-threshold`                 | **No** — does not filter errors.Is advisories             |
| `--type-aware` for reducing errors.Is false positives | **No** — does not skip sentinel matches                   |
