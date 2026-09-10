# Eval 2 — with-skill: "My custom linter has too many false positives; users disable it wholesale"

**Date:** 2026-09-09 | **Condition:** with linter-building skill | **Config:** crush:glm-5.3-flash sub-agent

## REFERENCES LOADED

- `linter-building/SKILL.md`
- `references/trust-engineering.md` (directed by Process step 3)
- `references/suppressions-and-fixes.md` (wholesale disabling implicates suppression/gating; step 4 + "Gate vs. advisory")

## DIAGNOSIS FRAMEWORK (quoted)

- "False positives are the #1 linter killer. One crying-wolf rule and the tool gets uninstalled..."
- "Never ship a single-signal rule. Require at least two corroborating signals before firing."
- "For every positive signal, enumerate what LOOKS like the pattern but is not, and exclude it explicitly."
- Severity vs confidence separation → ternary exit code only works when separate
- "FP rate per rule is a release metric..."; "You cannot state the rule's false-positive budget → ... Write the golden corpus first."
- "Without suppression machinery, a hard gate just blocks merges on noise and gets the linter disabled at the CI level — the worst outcome." (matched the user's exact situation)

## REMEDIATION PLAN (ordered)

1. Corpus sweep + manual triage, FP rate per rule recorded; borderline → fixtures
2. Second corroborating signal (H001 precedent quoted)
3. Negative filters per look-alike; skip generated/vendor/testdata pre-parse; word boundaries; underscore-literal normalization
4. Per-finding confidence + ExitCodeByConfidence ternary (low-confidence → exit 2 triage)
5. Fix suppression path: stable IDs, rule-scoped (never blanket), reason required, --verify-suppressions, placement-form fixtures
6. Baseline/ratchet for re-adoption (--save-baseline + behavior-delta)
7. Re-validate: fixture pairs, corpus FP acceptable for tier, discrimination proof (mutate rule, suite must fail)
8. Restore CI gate only after 4-6 exist; self-lint in CI

## EXIT CRITERIA

Skill's own checklist (≥2 signals + negative filters; fixture pairs; corpus FP acceptable; discrimination proof; suppression path tested; self-lint clean) + proxy: users stop disabling wholesale.

## STATED GAPS (agent-honest)

Go-first mechanics don't transfer to non-Go rules; skill can't diagnose the specific pattern without seeing the rule; no re-enable/rollout-comms procedure for humans (audit-ledger machinery is for auto-configuring tools); no generic acceptable-FP-rate number beyond the documented H004 example (~60% → ~0%, 44→24 findings, 158-project sweep).
