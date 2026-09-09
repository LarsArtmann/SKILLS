# Trust Engineering — False-Positive Control and Testing

False positives are the #1 linter killer. One crying-wolf rule and the tool
gets uninstalled, `-`-disabled wholesale, or drowned in blanket suppressions
that then hide real findings. FP control is the hard 80% of linter work —
budget for it up front, not after users complain.

## Rule design: multi-signal detection

**Never ship a single-signal rule.** Require at least two corroborating
signals before firing:

- `go-humanize-linter` H001 (hand-rolled byte formatting) requires
  byte-unit strings AND (division by 1024 OR a KMGTPE unit index) within the
  same function. Either signal alone matches thousands of innocent
  functions; together they match reimplementations.
- H004 (pluralization) additionally gates on the function's return type
  being `string` and a string literal appearing in a branch — negative
  filters that cut the rule's false-positive rate from ~60% to ~0%
  (documented in the project's validation docs).

Pattern: per-function (or per-file) evidence collection → threshold → emit.
Structure rules as **pure predicate helpers** (one file per pattern) tested
independently of the registry.

## Negative filters

For every positive signal, enumerate what LOOKS like the pattern but is not,
and exclude it explicitly:

- Size-bucket `switch` tables (legitimate) are not hand-rolled formatting —
  excluded from H001.
- Generated files, vendored code, testdata — skip BEFORE parsing.
- Word-boundary matching for unit strings ("MEDIUMBLOB" must not match "MB").
- Normalization traps: `1_000_000` underscore literals need a normalizer
  before numeric comparison.

Each negative filter gets a fixture in the negative corpus (below).

## Confidence tiers and triage exit codes

Per-finding confidence (Low/Medium/High/Full) drives machinery a
rule-level severity never can:

```go
// go-linter-sdk (verified): ternary exit code
code := linter.ExitCodeByConfidence(report, finding.ConfidenceHigh)
// 0 = clean, 1 = high-confidence findings (must fix), 2 = only
// low-confidence findings (triage list, does not block)
```

This lets heuristic rules ship early: low-confidence findings surface as a
triage list while only corroborated findings gate CI. Tighten thresholds as
the corpus grows.

## Corpus validation — measure, don't guess

Before shipping, sweep a real corpus and record the numbers
(`go-humanize-linter` swept 158 external projects and documents the
resulting FP adjustments per rule):

1. Collect representative repos (diverse styles, not just your own).
2. Run the linter; manually triage every finding: real / FP / borderline.
3. FP rate per rule is a release metric. A rule with unfixable FP rate
   ships disabled-by-default or not at all.
4. Keep the borderline cases as fixtures.

## Discrimination proof (prove the tests test)

A green corpus proves nothing if the rule never fires at all. Prove the
test suite discriminates (`samber-linter` spec):

1. Build a golden corpus: each case is a minimal snippet the rule MUST flag
   (and a paired near-miss it must NOT flag).
2. Mutant test: in a scratch copy, deliberately break the rule (invert the
   predicate, delete a signal requirement). The suite MUST fail. If it
   stays green, the corpus is decorative — the `go-finding` AGENTS calls
   this "dead gates are worse than no gates."

The same principle applies to check scripts: every check prints explicit
OK/FAIL, and you verify the FAIL path once by breaking something on
purpose. A check that passes by not running is worse than no check.

## Attribute findings where the fix lands

Report at the position a developer can act on:

- Registration/wiring smells → the call site, not the type definition
  (`samber-linter`: attribute at the `do.Provide*` call, "that is where the
  fix lands").
- Suppression meta-findings → anchor carefully: golangci-lint's own nolint
  filter swallows findings anchored ON a nolint line; go-humanize-linter
  re-anchors its suppression-verification finding to line 1 for exactly
  this reason.
- Never fabricate line 0 or file-less positions when a real position
  exists; when there is genuinely no line (project-level rules), use the
  finding model's hash-ID form rather than a fake position.

## Syntax-walker pitfalls (go/analysis users skip these)

- **Import aliases**: `hu "github.com/dustin/go-humanize"` renames the
  identifier. Build an alias map per file
  (`buildImportAliases(file) map[string]string`) before matching qualified
  identifiers.
- **Match by package path, never identifier text** — dot-imports and
  aliases make text matching a false-positive generator.
- `token.FileSet` is required for positions; thread it through predicates
  (`detectorFunc(fset, file, fn, path)`).

## Generated-file detection

Never complete, always needed. Two-phase (`gogenfilter` pattern): cheap
filename-only check (zero I/O) short-circuits; content heuristics run only
on candidates. Reading file bytes once and feeding both checks avoids
double I/O. Skip lists: `vendor/`, `testdata/`, `node_modules/`.

## Self-lint

The linter will contain its own trigger patterns (a byte-formatting linter
needs unit strings in fixtures and sometimes code). Run the linter on
itself in CI with real suppressions — dogfooding keeps the suppression
syntax honest.

## Testing the linter itself

Layered strategy used across the reference projects:

1. **Per-rule predicate tests** — table-driven: snippet in, findings out
   (or not out). The pure-predicate structure makes these trivial.
2. **Fixture directories per rule** — positive AND negative cases as real
   files (`testdata/`), run through the full pipeline. Negative cases are
   the FP regression suite; every negative filter earns one.
3. **Golden/snapshot tests** for rendered output (formats, SARIF) — with
   deterministic output (sorted keys, no timestamps) or the snapshots flake.
4. **BDD specs** (Ginkgo/Gomega) for behavior-level contracts: suppression
   scoping, confidence gating, exit codes.
5. **Black-box tests** (`package linter_test`) — exercises only the public
   API, keeps the test suite honest about the actual surface.
6. **Fuzz the parsers** — anything consuming foreign input (SARIF import,
   external-tool JSON) gets fuzz corpora; go-finding ships 20+.
7. **Concurrency** — registry is shared; race detector in CI.
8. **Examples as integration tests** — `examples/` dirs executed via
   `exec.Command` prove the README claims compile and run.

## Exit criteria before shipping a rule

- [ ] ≥2 corroborating signals, negative filters for known look-alikes
- [ ] Fixture pair per case (must-flag + must-not-flag)
- [ ] Corpus sweep: FP rate measured and acceptable for the confidence tier
- [ ] Discrimination proof: mutant rule fails the suite
- [ ] Suppression path tested (directive silences it; staleness detected)
- [ ] Self-lint clean
