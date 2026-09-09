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
  ├── GitHub Action      (action.yml → CLI)
  └── SARIF              (CI code-scanning UIs)
```

Order matters: library first (the CLI is a consumer), plugin LAST (a thin
`analysis.Analyzer` wrapper). Detection logic must not import cobra,
golangci internals, or actions tooling.

## CLI contract

- **Exit codes carry semantics** (go-linter-sdk, verified):

  | Code | Meaning |
  | --- | --- |
  | 0 | Clean — no findings at/above the confidence threshold |
  | 1 | Findings at/above threshold (actionable; blocks) |
  | 2 | Only low-confidence findings (triage list; does not block) |

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
