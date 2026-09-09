# The Local Linter-Building Ecosystem

Lars already owns every layer of the linter stack. Reuse before building —
check this map first. Paths are local checkouts; all LarsArtmann repos are
public unless noted. (States verified 2026-09-09; re-check `git log` before
relying on a repo's freshness.)

## The stack, bottom-up

| Layer | Repo | State | What to take from it |
| --- | --- | --- | --- |
| Finding data model | `~/projects/go-finding` | v1.9.x, API locked since v1.0, public | `finding.Finding`, Builder, Severity/Confidence, SARIF import/export, LSP, merge/correlate, filters, fix layer (FixEdit/FixOutcome), pipeline (detect→triage→fix→verify), 70+ golangci-linter→category registry, `analysis.FromDiagnostic` bridge |
| Rule/registry scaffolding | `~/projects/go-linter-sdk` | v0.3.x, public | `Rule`/`RuleFunc{Meta,Run}`, `Registry` (panic-on-duplicate), `RuleError`, `ExitCodeByConfidence` (0/1/2), examples dir with minimal linters |
| Config-tool plumbing | `~/projects/linter-autoconfigure-sdk` | seed-stage, public | `ReadConfig/LoadJSON/SaveJSON` with `Op`-typed `ConfigError`, `ConfigIssue → Finding`, atomic idempotent writes. Use only when a second configurator consumer exists (their own README says value is modest pre-consumer) |
| Configurator (Go) | `~/projects/golangci-lint-auto-configure` | v0.6.0 mature, public | 4-tier linter priorities, governance maps (Disabled/NeverAutoEnable/PragmaticNoise with data-integrity tests), fixer anti-gaming (justified disables, audit ledger, loop detection), v1→v2 migration |
| Configurator (JS) | `~/projects/oxlint-auto-configure` | stable WIP, public | Profile-over-rule-registry pattern (841 oxlint rules as embedded versioned data), external-linter detector via go-finding, exit-code normalization |
| Reference walker-linter | `~/projects/go-humanize-linter` | v0.2.0 mature, public | THE template for custom AST walker linters: multi-signal rules, confidence, suppression verification, baseline/delta, golangci v2 plugin, GitHub Action, per-rule docs + ADRs, 158-project validation corpus |
| Reference rule-engine | `~/projects/go-structure-linter` | mature code, release blocked | THE template for filesystem/project rule engines: capability interfaces, panic isolation, ExternalToolRule delegation, fix mixins, DI services, BDD testutil |
| Reference spec discipline | `~/projects/samber-linter` | spec-only (not started) | The README-as-contract method: verification ledger (every claim pinned to upstream file:line), discrimination-proof requirement, reason-required suppressions. Copy the METHOD even if the analyzer never ships |
| Config seed | `~/projects/template-arch-lint` | dormant | Copy-paste `.go-arch-lint.yml` + `.golangci.yml` starting points (Clean Architecture component map, forbidigo bans); its plugin code is the naive ancestor — read for the ceiling lessons, not for patterns |
| Consumer reference | `~/projects/InboxClean-lint-baseline` | deployed, private-ish app | What good consumption looks like: reason-bearing suppressions, `.cqrs-lint.json` min-severity, archtest (`internal/archtest/`), health-score CI, go-finding migration semantic-mapping docs |
| Architecture linter | `go-cqrs-lite/cmd/cqrs-lint` | shipped | Real architecture linter built on go-finding (the tool InboxClean consumes) |
| Error linting | `erraudit` (private; see `go-error-modernization` skill) | private | Go 1.26 errors.AsType migration linter — request access, don't recreate |

## Decision shortcuts (need → use)

- Emit findings of any kind → import `go-finding`, full stop.
- Build a directory-scoped Go linter (rules over a repo dir) → `go-linter-sdk`
  registry + your rules as `RuleFunc`; expose CLI + plugin like
  go-humanize-linter.
- Build a per-package Go analyzer (needs types) → plain
  `golang.org/x/tools/go/analysis` + `analysis.FromDiagnostic` from
  go-finding for the finding conversion; wrap for golangci per
  go-humanize-linter's plugin.
- Enforce architecture in ONE repo → copy InboxClean's archtest pattern
  (~100 LOC) before reaching for a linter product.
- Add lint config to a project → run the matching auto-configure tool
  (golangci / oxlint) instead of hand-writing configs.
- Wrap an external CLI linter → `finding.ToolAdapter[O]` /
  `CheckBinary`/`RunCmd` (go-finding) — the pattern 4+ consumers
  independently reinvented before it was extracted.
- Merge/dedup findings across tools → `finding.Combine` +
  `DeduplicateByPosition/Rule`, `Correlate`.

## Ecosystem-wide conventions (keep the family coherent)

- Finding type: ALWAYS `finding.Finding` (alias your local name to it);
  never a parallel issue model.
- Rule IDs: prefixed, stable forever (`H001`, `E017`); suppressions and
  configs key on them.
- Exit codes: 0/1/2 by confidence via `linter.ExitCodeByConfidence`.
- Tooling invariants: `GOWORK=off go mod tidy` inside workspace members;
  tag releases only on green CI; `GOEXPERIMENT=jsonv2` documented loudly
  while required.
- Naming: the tool's short namespace (what users write in suppressions) is
  chosen once and never changed — `gohumanize`, not the module path.

## Related skills

- `how-to-golang` — general Go stack/policy decisions (this skill handles
  only the linting domain).
- `code-quality-scan` — RUNNING linters over a codebase (the consumer
  side); `go-error-modernization` — the erraudit-specific workflow.
