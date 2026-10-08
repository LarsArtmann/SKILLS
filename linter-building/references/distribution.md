# Distribution — One Detector Core, Many Fronts

Ship the detector core behind every front users want; never fork detection
per front. go-humanize-linter's detectors run unchanged as library, CLI,
golangci-lint plugin, and GitHub Action.

## The layer stack

```
detector core (rules as data + pure functions)
  ├── library API        (Registry, types.Issue = finding.Finding)
  ├── CLI                (exit codes, baseline, formats)
  ├── golangci-lint v2 plugin (module plugin wrapping the same detectors)
  ├── BuildFlow provider (toolsdk.Spec — self-registration, no host glue)
  ├── GitHub Action      (action.yml → CLI)
  └── SARIF              (CI code-scanning UIs)
```

Order matters: library first (the CLI is a consumer), the fronts LAST (thin
wrappers). Detection logic must not import cobra, golangci internals,
BuildFlow, or actions tooling.

## CLI contract

- **Exit codes carry semantics** (go-linter-sdk, verified):

  | Code | Meaning                                                    |
  | ---- | ---------------------------------------------------------- |
  | 0    | Clean — no findings at/above the confidence threshold      |
  | 1    | Findings at/above threshold (actionable; blocks)           |
  | 2    | Only low-confidence findings (triage list; does not block) |

  Distinct from "crashed": tool errors use their own path (sysexits-style
  classification if the tool is large; go-error-family → BSD exit codes is
  the house pattern).
- **Baseline/delta for adoption**: `--save-baseline` once,
  `--behavior-delta` in CI — pre-existing findings don't fail the build,
  new ones do. This is how a linter lands on a legacy codebase without a
  big-bang cleanup.
- **`--min-confidence` and rule selection flags** (`enable`/`disable` by
  rule ID) so teams tune noise without editing configs.
- **Formats**: human (default), JSON, SARIF — deterministically ordered
  (sort by file, line, rule) so diffs and snapshots are stable.

## golangci-lint v2 module plugin (verified wiring)

From go-humanize-linter's released, dogfooded plugin:

1. `plugin/plugin.go` exposes `func New(conf any) ([]*analysis.Analyzer, error)`
   and registers via golangci's `plugin-module-register`:
   `register.Plugin("gohumanize", newPlugin)`. Declare
   `GetLoadMode() → register.LoadModeSyntax` for syntax-only rules (no
   wasted type-check), types mode when needed.
2. Build a custom binary: `.custom-gcl.yml` with `version:` +
   `plugins: [{module, import, path}]`, then `golangci-lint custom`
   produces `./custom-gcl`.
3. Register in the project's `.golangci.yml` — WITHOUT the
   `linters.settings.custom` section golangci reports "unknown linters".
   Settings pass through as `settings: {enable: "H001,H003", ...}`.
4. **Do NOT tell users to put a module plugin into
   `linters.settings.custom`** in shared configs — a custom-built binary
   path belongs to the consuming repo only (stock golangci binaries can't
   load it; golangci-lint-auto-configure enforces exactly this
   distinction when recommending plugin enablement).

Plugin gotchas: re-anchor suppression-verification findings to line 1 (the
host nolint filter eats findings on nolint lines); testdata for the plugin
path lives under `testdata/analysistest/` using
`analysistest.RunWithSuggestedFixes` conventions when you have fixes.

## BuildFlow provider (toolsdk self-registration)

The cheapest distribution front in the local fleet: the tool self-registers
as a BuildFlow provider via `github.com/larsartmann/go-finding/toolsdk`
(a go-finding sub-module, tagged `toolsdk/v*`, v1.15.0 as of 2026-10-05),
and every BuildFlow-covered repo can run it with zero per-repo wiring.
Adding a tool is a one-file change in the tool's own repo; the host side is
a single blank import line. (This section AUTHORs providers; for RUNNING
BuildFlow, see the `buildflow` skill.)

The whole contract — a package-level `Spec` var (runs at init):

```go
package provider

import toolsdk "github.com/larsartmann/go-finding/toolsdk"

//nolint:gochecknoglobals // toolsdk self-registration by design
var Provider = toolsdk.Register(toolsdk.Spec{
	Name:        "mytool",                     // unique, stable
	Description: "One-liner shown in the host --list output", // required
	Trigger:     toolsdk.OnGoFiles(),
	Inputs:      []string{"**/*.go"},          // data-flow edges + presence gate
	Detect:      myDetector,                   // a finding.Detector
})
```

The host (BuildFlow) blank-imports this package
(`tools/providers/sdk_imports.go` — one line + a go.mod require) and
discovers every spec via `toolsdk.All()` at startup. 10 tools ship this way
today (art-dupl, go-structure-linter, cqrs-lint, cmdguard,
dependabot-auto-configure, go-branded-id, go-design-smells,
go-version-auto-configure, oxlint-auto-configure, licenseforge).

**Why this shape:** the SDK depends ONLY on go-finding — no BuildFlow
internal types leak into the contract, so a provider never couples to
BuildFlow's release cycle. Conversion (`ToolFromSpec`) is one-way and lives
entirely in the host.

### Spec field rules that bite

| Field        | Rule                                                                                                                                                                                                                                                                                                                                                 |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Name`       | Required, unique, stable — suppressions and config key on it. Empty → panic.                                                                                                                                                                                                                                                                          |
| `Description`| Required non-empty (trimmed) → panic otherwise. The host shows it in `--list`; make it say what the tool does AND what it will not do.                                                                                                                                                                                                                 |
| `Detect`     | A `finding.Detector`. `nil` is legal only for repair/generate-only tools; a spec with neither Detect nor Repair panics — a capability is mandatory.                                                                                                                                                                                                   |
| `Repair`     | `Repairer` (or `toolsdk.RepairerFunc`). MUST honor `toolsdk.DryRunFromContext(ctx)` — report what would happen, change nothing. `RepairResult.Description` is the ONLY meaningful field: the host re-runs Detect and measures the finding delta instead of trusting self-reported fix counts (structural anti-lie).                                                                     |
| `Trigger`    | When the tool is relevant: `Files` globs activate it, `Language` gates it (`"go"`, `"js"`, ... or `""` = agnostic), `Requires` is an OR-group of prerequisite patterns (`**/go.mod`, `**/go.work`), `NotRequires` DISQUALIFIES on match — ownership deference: a standalone formatter skips repos carrying their own toolchain config (e.g. `treefmt.toml`) instead of fighting it every run. Constructors: `OnGoFiles()`, `OnGoModule()`, `OnFiles(lang, pats...)`, `AnyLanguage(pats...)`. |
| `DependsOn`  | Plain tool-name strings; the host resolves them into DAG ordering edges.                                                                                                                                                                                                                                                                             |
| `ModuleFanOut` | Declares run-once-per-Go-module (multi-module workspaces). The host wraps Detect/Repair for you — callbacks MUST read the working directory from `finding.WorkingDirFromContext(ctx)`, never the process CWD, and must NOT self-wrap with their own WorkDir/progress adapters.                                                                                          |
| `SwitchCases`| Conditional repair paths keyed on the diagnose output's finding rule IDs: `Suffix` names the DAG node, `FindingRuleIDs` select (any-match runs), `ExcludedRuleIDs` suppress. The host runs EVERY matching case in parallel — mutual exclusion is the SPEC AUTHOR's job: encode precedence via `ExcludedRuleIDs` or lose writes to racing siblings.                                                                       |
| `Options`    | Tunable knobs: `{Name, Kind, Default, Description}` with Kind one of `int`, `string`, `bool`. Kind-checking only — range/semantic validation stays with the tool (art-dupl validates `threshold` 1–1000 itself with domain sentinels). DECLARING an option is what makes it settable: a spec with no Options rejects any value. Unknown names fail loudly (`ErrUnknownOption`) so a consumer config typo cannot silently run on defaults. Read per-run values with `OptionsFromContext(ctx)`; the host injects via `WithOptions` (map is snapshotted; nil/empty CLEARS inherited values). Sentinels match with `errors.Is`. |
| `HealthCheck`| Verify external dependencies (a binary is installed) before the pipeline runs; `nil` = no external dep. Pure-Go tools declare an explicit no-op `func(context.Context) error { return nil }` so absent is not mistaken for unverified (art-dupl).                                                                                                       |

**Registration panics on invalid specs** (empty Name/Description, no
capability, malformed or duplicate Options) — a malformed registration is a
programming error that must surface at startup, not a runtime condition.
Same doctrine as duplicate rule IDs in a registry.

### Testing a provider

The registry is process-global (that is how init-time registration is
discoverable). Tests that mutate it — `ResetForTest`, re-`Register` — must
snapshot with `SnapshotForTest()` and restore via
`t.Cleanup(func() { toolsdk.RestoreForTest(snap) })`, or the suite breaks
under shuffle. `EnsureContext(ctx)` defends standalone callers against a
nil context.

### Lessons from shipped providers (all real)

- **Cap detector-only tools at advisory severity.** If findings feed a gate
  on error-or-above and the tool has NO Repairer, error findings fail every
  run with no automated fix path. art-dupl caps at `SeverityWarning` and
  preserves the original severity in a tag (`original-severity-<sev>`).
- **Hyphenate metadata tags, never colonate.** A colonated tag fails go-finding
  report validation and breaks consumers' `--format finding` output (found
  in branching-flow via PapDashboard, mirrored in art-dupl).
- **"Nothing found" is a clean run, not an error.** Map the SDK's
  no-duplicates sentinel to `[]finding.Finding{}`, `nil` error.
- **Put the spec in its own `pkg/provider` package** with a doc comment
  explaining the registration pattern — the blank import IS the wiring, so
  the package must be importable without side effects beyond registration
  (art-dupl's provider doc is the model).

## SARIF

- Emit SARIF 2.1.0 for GitHub code scanning; users get free UI.
- **Determinism is engineered**: sorted keys, stable order, no timestamps
  in fingerprints. Non-deterministic SARIF breaks code-scanning dedup and
  golden tests (go-structure-linter has two status docs about fixing
  exactly this).
- SARIF has four severities and no `critical` — round-trip the original
  through the property bag (`go-finding/severity` key pattern) rather than
  losing it.
- Import path must be LENIENT: foreign SARIF legitimately lacks fields
  your Validate would demand; filter invalid ones explicitly
  (`slices.DeleteFunc(findings, IsInvalid)`) instead of silently dropping
  partial-but-valid results.
- **Round-trip via property-bag keys** (verified go-finding set, reserve
  your own `<tool>/` prefix the same way): `go-finding/severity`
  (SARIF has no `critical`), `-confidence`, `-category`, `-tags`,
  `-suggestion`, `-snippet`, `-id`, `-start-offset`, `-end-offset`,
  `-suppression-kind`, `-suppression-reason`, `-suppression-rule`,
  `-suppression-expiry`.

## CI integration

- A linter not running in CI is a linter that regresses — findings creep
  back in any environment without the binary. Wire it into the default
  workflow, not an optional one.
- **Pin the linter version** (renovate the pin). Config-validation
  failures should fail LOUDLY in CI — template-arch-lint's crisis docs
  cover discovering config-validation breakage at release time.
- Gate (`--strict`, exit 1 blocks) only once suppression discipline exists
  (see suppressions-and-fixes.md); advisory mode + health score first.
- **Release-failure notifications**: go-structure-linter's releases were
  silently broken for ~2 months (Actions budget exhausted, workflows
  disabled) because nothing watched the watcher. Budget/permission death
  must page, not pass.

## Publishing pitfalls (all really happened)

- **Nested modules break `go install @latest`** — consumer-invisible
  `modules/*` submodules with `replace` directives produce zips `go install`
  can't use (go-structure-linter's blocker). Publish real module tags per
  module (go-finding tags `pipeline/v*`, `analysis/v*`, `cmd/*/v*`
  separately) with a release-preflight script checking cross-module
  references — the v1.7.0 incident was a stale core ref in a sub-module
  tag.
- **Tag only on green CI** — a red 7s CI left a stale go.sum in a released
  tag; pkg.go.dev freezes tagged READMEs forever (docs-only PATCH releases
  are fine to fix them).
- **Private deps block public installs** — audit go.mod for private/
  git+ssh dependencies before publishing; either extract the types or
  document the constraint.
- **Linter exit 1 = findings, not failure** — when wrapping external
  linters, normalize before error-wrapping or every finding run looks like
  a crash (oxlint-auto-configure's `checkExitError`).
- **GOEXPERIMENT=jsonv2 dependence** (go-finding ecosystem) is a real
  adoption friction: document the required Go version + experiment loudly
  in the README install section, and drop it when the toolchain stabilizes.

## Verification status

Canonical block per `verify-external-claims/SKILL.md` §5. Source-read, 2026-09-24.

| Claim                                                                       | Status      | Source                                                                   |
| --------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------ |
| `analysistest.RunWithSuggestedFixes` convention                             | ✅ Verified | `golang.org/x/tools@v0.35.0/go/analysis/analysistest/analysistest.go:82` |
| go-finding per-module tag scheme (`pipeline/v*`, `analysis/v*`, `cmd/*/v*`) | ✅ Verified | `git -C ~/projects/go-finding tag -l` (also `toolsdk/*` + root tags)     |
| toolsdk contract: `Spec` fields + panic-on-invalid `Register`; `Trigger` constructors; `Option` kinds + `WithOptions`/`OptionsFromContext` snapshot-and-clear semantics; `ValidateOptions` unknown-name rejection; `DryRunFromContext`; `RepairResult` description-only (host re-detects); `SnapshotForTest`/`RestoreForTest`; `EnsureContext` | ✅ Verified 2026-10-08, source read | `go-finding/toolsdk/{doc,spec,registry,options,triggers,dryrun}.go` (tagged toolsdk/v1.15.0; 10 consumers) |
| Provider lessons (advisory cap + `original-severity-` tag, explicit no-op HealthCheck, hyphen-not-colon tags, own `pkg/provider` package)   | ✅ Verified 2026-10-08, source read | `art-dupl/pkg/provider/provider.go`; `dependabot-auto-configure/pkg/provider/provider.go`; `BuildFlow/tools/providers/sdk_imports.go` (10 blank imports) |
