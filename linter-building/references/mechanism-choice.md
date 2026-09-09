# Mechanism Choice — What to Build When

The decision matrix distilled from nine real linter/finding projects. Every
row carries evidence: the project that proves it works (or proved the
naive version fails).

## The three questions, in order

Ask these BEFORE writing any analyzer. Most regret comes from answering
question 3 ("how do I write the rule?") before question 1 ("should this be a
rule at all?").

1. **Does an existing tool + config already express it?**
2. **What class of FACT does the rule need?** (syntax / types / layout /
   import graph / config state / external tool output)
3. **Given 1 and 2, which mechanism is the cheapest that fully works?**

## Full decision matrix

| # | Situation | Mechanism | Evidence / Why |
| --- | --- | --- | --- |
| 1 | Existing linter covers it (forbidden identifiers, complexity caps, style) | **Configure it.** golangci-lint settings, oxlint categories, depguard/forbidigo | `template-arch-lint` shows the ceiling empirically: forbidigo bans are global (no per-path allowlists), config cannot express multi-signal patterns or custom detection — those gaps are exactly when you graduate to a plugin or custom linter |
| 2 | "Which of 800 rules matter for THIS repo?" | **Configurator layer** — profiles as data (category × severity matrix) over an embedded, versioned rule registry | `oxlint-auto-configure` (841 oxlint rules, profiles: minimal/recommended/strict/maximal-typesafe), `golangci-lint-auto-configure` (4-tier priorities + per-linter reasons). Both emit config, never findings about code |
| 3 | Syntax pattern in code (hand-rolled idioms, naming shapes, suspicious literals) | **Custom AST walker**: `go/parser` + `token.FileSet` + `ast.Inspect`, per-function or per-file predicates | `go-humanize-linter` (9 rules H001–H009). Fast, zero build/type-check requirement, works on dirty trees. Cost: you own alias resolution (see pitfalls) and get NO type facts |
| 4 | Type facts: interface satisfaction, method sets, `T` vs `*T`, cross-package resolution | **`go/analysis` with types** (`pass.TypesInfo`, `pass.Pkg`) | `samber-linter` spec is the canonical justification: "interface satisfaction cannot be decided from the AST alone." Also the golangci-lint plugin contract — the analyzer interface IS the plugin API |
| 5 | Whole-project facts: file/dir layout, LICENSE/CHANGELOG presence, CI pinning, config hygiene | **Filesystem rule engine** — rules over paths and file contents, not AST | `go-structure-linter` (65 rules, 24 autofix). go/analysis is per-package; "repo has no LICENSE" is not a package question |
| 6 | Cross-package invariant inside one analyzer ("exactly one `main.go` under cmd/") | go/analysis CAN, awkwardly: fabricate a position (`pass.Files[0].Pos()`) because reports need one | `template-arch-lint` `CmdSingleMainAnalyzer` — the documented wart; if you have many such rules, prefer mechanism 5 |
| 7 | Architecture/import constraints (X must not import Y) | **Architecture test as Go code** (`go list -deps` + forbidden-pair table + reason) or go-arch-lint config; or delegate to go-arch-lint from a rule engine | `InboxClean` `internal/archtest/archtest_test.go`: ~100 LOC, runs in `go test`, header says "Fix the import, do not weaken the test". `go-structure-linter` delegates to the go-arch-lint binary behind a no-op-if-absent rule (ADR: delegation beat reimplementing) |
| 8 | Specialist CLI already detects it (any language) | **Wrap it**: run → parse JSON → convert to findings, via a ToolAdapter pattern; normalize exit codes | `oxlint-auto-configure`'s detector wraps the oxlint CLI (exit 1 = findings, NOT an error — normalize before error-wrapping). `go-structure-linter` `ExternalToolRule` converts go-arch-lint JSON |
| 9 | Many tools emit findings; users need one triaged stream | **Merge/correlate layer** on a shared finding model | `go-finding`: `Combine(reports)`, dedup by ID / position / rule (explicit, documented relaxations of identity), correlate overlapping ranges via interval index |
| 10 | Lint the linter's own config generation/repair | Config-issue findings + atomic writes + audit ledger | `linter-autoconfigure-sdk` (`ConfigIssue` → `finding.Finding`), `golangci-lint-auto-configure` (justified-disable ledger, regression-loop detection) |

## Choosing between 3 and 4 (walker vs go/analysis) — the common trap

The rule of thumb: **can you decide with the file's text and shape alone?**

- Yes (pattern smells, literal idioms, function shapes) → custom walker.
  It is dramatically easier to test (parse a fixture, run predicates) and
  does not require the package to compile. `go-humanize-linter` chose
  syntactic alias resolution (`buildImportAliases(file) map[string]string`)
  specifically so the CLI path needs no type-checking (ADR 0001).
- No (does this type implement `Healthchecker`? which concrete type is
  registered behind this interface?) → go/analysis with types. Do NOT
  approximate type facts with string matching on the AST — identifier-text
  matching breaks on dot-imports and aliases and produces exactly the false
  positives that kill linters. Match by package path, never identifier text.
- Both in one tool? Keep ONE detector core and expose it twice:
  go-humanize-linter's CLI uses the walker; its golangci plugin wraps the
  SAME detectors in an `analysis.Analyzer` with
  `register.LoadModeSyntax` (syntax-only, no wasted type-check).

## Distribution shape is a separate axis

Any mechanism above should ship its detector core behind multiple fronts
(library → CLI → plugin → CI). See
[./distribution.md](distribution.md). Do not let "I want a golangci plugin"
force go/analysis when the rule is syntactic — wrap the walker detectors in
a thin analyzer instead.

## Anti-patterns (each one really happened)

- **Linter #842** — building detection that an enable-list change would
  cover. `oxlint-auto-configure` exists because oxlint has 841 rules and the
  problem was selection, not detection.
- **Native issue type + converter** — the most expensive recurring mistake:
  `branching-flow` accumulated 1,871 LOC and `erraudit` 1,214 LOC of
  glue converting private issue types to the shared finding type. Both were
  deletable wholesale after migrating to emitting findings directly
  (`go-linter-sdk/README.md`).
- **Approximating type facts with strings** — matching `do.Provide` by
  identifier text instead of package path; breaks silently on aliases and
  dot-imports.
- **Forcing one engine for all rules** — `go-structure-linter` ADR-003
  kept its 65 filesystem rules behind an adapter to the shared SDK rather
  than migrating them to AST rules, because file create/delete repair
  cannot be expressed as code patches. The adapter is the permanent
  boundary, not a debt item.
- **God-interface rules** — one `Rule` interface with Check, Fix, Validate,
  ProjectAccess, DryRun on every implementer. Capability interfaces
  (`FixableRule`, `ProjectAware`) checked optionally at runtime keep the
  common case tiny (`go-structure-linter`, `go-linter-sdk`).
- **Silent delegation** — wrapping an external tool that no-ops without an
  error when the binary is missing, without telling the user. If the tool
  is absent, say so (or skip with a visible notice), or your CI green lies.
