# Eval 3 — WITHOUT-skill baseline (same prompt as eval 1)

**Date:** 2026-09-09 | **Condition:** no skill access (explicitly instructed: no skill files, no research) | **Config:** crush:glm-5.3-flash sub-agent

## MECHANISM DECISION
`go/analysis` Analyzer via `singlechecker.Main` + golangci plugin wrapper. Justification: type info resolves aliased imports; ecosystem-standard shape; multichecker/golangci integration. No decision-tree reasoning about configure/delegate/walker-vs-analysis alternatives — jumped straight to analyzer construction.

## PLAN (summary)
Analyzer with `p.Reportf`; package-path exemption check via `p.Pkg.Path()`/`p.Module`; `inspector.New` filtered to CallExpr; callee resolution via `p.TypesInfo.Uses` (package path == "log", names Fatal/Fatalf/Fatalln); analysistest with `// want` comments; testdata for lib + cmd.

## ALTERNATIVES CONSIDERED
grep/regex (rejected); raw AST walker without types (rejected: alias/shadow FP class); depguard (wrong shape — bans imports, not calls); golangci-only plugin (rejected as primary artifact); codegen/runtime guard (rejected).

## QUALITY CONCERNS
Alias/shadow handling via TypesInfo; skip _test.go by default with a flag; generated-file skip regex; `//lint:ignore` (staticcheck convention) + honor host `//nolint`; configurable exempt prefix; scope discipline for `*log.Logger` methods; adoption noise → `new-from-rev` / severity warning.

## GRADER'S DELTA vs with-skill (eval-1)
Baseline is genuinely competent. Omissions vs skill-driven run:
- No shared finding data model (plain Reportf — no confidence, no FixStrategy, no SARIF round-trip, no merge/dedup story)
- No corpus validation discipline (measured FP rate, discrimination/mutant proof)
- No baseline/ratchet adoption path, no exit-code tiering (0/1/2 by confidence)
- No suppression subsystem (defers to host conventions; no staleness verification, no placement-form testing)
- No multi-front distribution layering guidance beyond CLI+plugin
- Notable: baseline chose go/analysis + TypesInfo; skill-driven run chose walker + alias maps. For shadowing (`var log = fakeLog`) the types approach is strictly safer — real refinement signal for the skill (now encoded in mechanism-choice.md).
