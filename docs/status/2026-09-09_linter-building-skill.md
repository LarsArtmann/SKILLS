# Status Report — linter-building Skill Creation

**Date:** 2026-09-09
**Scope:** Found all lint-named projects in `/home/lars/projects/` (+ `/home/lars/projects/go-finding/`), researched them, and distilled the knowledge into a new `linter-building` skill. Plus one incidental fix to `scripts/check-skills.sh`.

**TL;DR:** New skill `linter-building` (179-line SKILL.md + 6 references) built from primary research over 10 local projects; all 27 skills pass structural checks; trigger density STRONG (17 markers). Incidental find: `check-skills.sh` was silently exiting 1 since the f13 wave — the verification-status guard's `grep -c` assignments abort under `set -euo pipefail` on zero counts — fixed with `|| true`.

## a) FULLY DONE

1. **Project inventory** — 9 lint-named dirs found: `go-humanize-linter`, `golangci-lint-auto-configure`, `go-linter-sdk`, `go-structure-linter`, `InboxClean-lint-baseline`, `linter-autoconfigure-sdk`, `oxlint-auto-configure`, `samber-linter`, `template-arch-lint`; plus `go-finding/` (category_linter.go is a file in it, the finding-model library).
2. **Research** — 3 parallel sub-agents read all 10 projects (READMEs, AGENTS.md, core Go files, ADRs, status docs). Key load-bearing claims then spot-verified directly against source: `go-finding/{finding,finding_builder,detector}.go`, `go-linter-sdk/{rule,registry}.go` (incl. `ExitCodeByConfidence` 0/1/2), `go-humanize-linter/plugin/plugin.go` (golangci v2 module-plugin wiring), `InboxClean internal/archtest` + reason-bearing suppressions.
3. **New skill `linter-building/`**:
   - `SKILL.md` (179 lines): tl;dr with named #1 failure mode (false positives) and #2 (wrong layer), 8-step process, 10-row decision-tree summary, core rules, glossary, "when NOT to build", canonical `## Verification status` table (7 claims, distinguishing source-read vs research-pass provenance).
   - `references/mechanism-choice.md` — the 10-row build/configure/delegate matrix with per-row evidence + walker-vs-go/analysis guidance + anti-patterns (linter #842, native-issue-type+converter, string-approximated type facts, forced single engine, god-interface, silent delegation).
   - `references/finding-model.md` — zero-converter rule (1,200–1,900 LOC measured history), Finding anatomy field-by-field, builder/registry contracts (panic-on-duplicate rationale, single-chokepoint error wrapping, capability interfaces), rule-ID discipline, severity-mapping-table adoption method, severity/confidence/correlation separation.
   - `references/trust-engineering.md` — multi-signal detection, negative filters, confidence tiers + ternary exit codes, corpus validation (158-project sweep precedent), discrimination/mutant proof, fix-site attribution, walker pitfalls (alias maps, package-path matching), generated-file detection, self-lint, 8-layer testing strategy, ship checklist.
   - `references/suppressions-and-fixes.md` — suppression-as-data (kind/reason/expiry), directive engineering (namespace discipline, `--verify-suppressions`, placement-form testing, host-nolint interplay), baselines/ratchets/health scores, FixStrategy taxonomy, autofix safety (dry-run default, descending-offset edits, per-finding outcomes, per-file rollback, capped loops), auto-configurator anti-gaming (justified disables, audit ledger, loop detection).
   - `references/distribution.md` — layer stack, CLI contract, verified golangci v2 plugin wiring, SARIF determinism + lenient import, CI integration (pin, loud config failures, release-failure notifications), publishing pitfalls (nested modules vs go install, tag-on-green-only, private-dep audit, exit-1 normalization, GOEXPERIMENT=jsonv2).
   - `references/ecosystem.md` — Lars's local stack map (12 entries with states), need→use decision shortcuts, family conventions, related skills.
4. **Repo wiring** — README: skill row (🆕 New), counts 26→27 / 21→22 / five→six New. `code-quality-scan` description gained the two-sided "Distinct from ... linter-building" clause (skill-writing guide rule 11.3). `scripts/link-skills-to-agents.sh` created the `~/.agents/skills/linter-building` symlink.
5. **Incidental fix — `check-skills.sh` silent exit 1**: the verification-canon guard (added in wave-3 f13) assigned `$(grep -c ...)`; `grep -c` exits 1 on zero matches, and under `set -euo pipefail` the assignment aborted the script before any FAIL output — reproducible on untouched `architecture-review/SKILL.md` at HEAD. Fixed all four count assignments with `|| true` + explanatory comment. This means the f13-era "check-skills passed" claims in earlier runs were likely the pre-abort sections only; today's run is the first full pass through all guards since f13 landed.

## b) PARTIALLY DONE / NOTES

- Two description-embedded claims rest on sub-agent research passes rather than direct source reads (converter LOC numbers; oxlint exit-1/841-rules) — marked as such in the skill's verification table; re-verify before citing exact numbers externally.
- `samber-linter` is spec-only; the skill cites its METHOD (verification ledger, discrimination proof), not an implementation.
- Trigger-eval harness (with/without-skill runs per how-to-write-skills.md) not executed — skill is 🆕 New until first real-work trigger, consistent with repo convention.

## c) VERIFICATION

- `scripts/check-skills.sh`: exit 0, "all 27 skills pass", no broken links (137 md files), 0 thin skills.
- `--triggers`: linter-building markers=17 STRONG (desc 950/1024 chars).
- Symlink live: `~/.agents/skills/linter-building -> ../../projects/SKILLS/linter-building`.

## d) NEXT (optional)

- First real linter request should validate the skill end-to-end; then age 🆕→🟢 with a run note.
- Consider `allowed-tools: art-dupl d2` style pre-approvals — none needed here (skill references bash/view/grep only).
