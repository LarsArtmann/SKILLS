# Eval 1 — with-skill: "Build a lint rule flagging log.Fatal in library code"

**Date:** 2026-09-09 | **Condition:** with linter-building skill (approximated: agent instructed to view SKILL.md and follow it) | **Config:** crush:glm-5.3-flash sub-agent

## REFERENCES LOADED

- `linter-building/SKILL.md`
- `references/mechanism-choice.md` (step 1)
- `references/ecosystem.md` (step 8)
- `references/finding-model.md` (step 2)
- `references/trust-engineering.md` (steps 3, 6)
- `references/suppressions-and-fixes.md` (steps 4-5)
- `references/distribution.md` (step 7)
- Verified reuse targets exist: go-finding/, go-linter-sdk/{rule,registry}.go, go-humanize-linter/

## MECHANISM DECISION

Custom AST walker via go-linter-sdk `RuleFunc`, emitting `finding.Finding`. Applied the skill's three questions in order with quotes:

- Q1: path-scoped ban; skill row 1 ceiling: "forbidigo bans are global (no per-path allowlists) ... graduate to a plugin or custom linter"
- Q2: syntax shape + per-file path predicate; no type facts → walker
- Q3: row 3 custom AST walker; ecosystem shortcut applied verbatim (go-linter-sdk registry + RuleFunc)
  Honest caveat raised: skill's forbidigo evidence pinned to 2026-09-09; newer golangci forbidigo may support per-pattern path excludes — skill does not track version-specific capability.

## PLAN (condensed)

Reuse: finding.Finding + Template, RuleFunc/Registry/RuleError/ExitCodeByConfidence, humanize's buildImportAliases + plugin wiring + baseline + verify-suppressions. Write: LF001 stable ID; pure predicates (import-alias map keyed by path "log", dot-import detection, isFatalCall, inLibraryCode); walker with vendor/testdata/generated skips; findings at call site; Template with FixStrategySuggest + ConfidenceFull; day-one rule-scoped suppressions with staleness verification; fronts in library→CLI→plugin→Action order; tests: predicate tables, must-flag (aliased stdlog, dot-imported) AND must-not-flag (cmd/, `mylog "example.com/x/log"` text-match trap, generated), golden, corpus sweep, discrimination proof (mutant: delete cmd/ filter → suite must fail), self-lint, host-nolint interplay.

## REJECTED ALTERNATIVES (with skill quotes)

forbidigo config (global bans); go/analysis (no type facts; "do not let 'I want a golangci plugin' force go/analysis"); filesystem engine (call pattern, not repo meta); archtest (would also ban legitimate log.Print); native issue type + converter ("1,200-1,900 LOC of glue"); autofix (judgment needed → FixStrategySuggest, never direct); identifier-text matching ("breaks on dot-imports and aliases").

## STATED GAPS (agent-honest)

_test.go handling unspecified by skill (agent chose configurable skip + fixture); standalone module vs in-repo rule not dictated; forbidigo version-specific capability outside pinned verification set.
