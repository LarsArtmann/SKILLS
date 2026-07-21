# Feedback: hierarchical-errors Skill — Propagated Unverified Claims About a Linter That Does Not Exist Publicly

**Date:** 2026-07-21
**Skill:** `hierarchical-errors` (created in commit `4a501ab`)
**Severity:** High — a brand-new skill was marked 🟢 Solid and shipped with a verification-status disclaimer buried at zero depth, while every CLI-specific claim inside it could not be confirmed against any public binary
**Trigger prompt:** "READ, UNDERSTAND, RESEARCH, REFLECT. Break this down. Execute and Verify. Repeat until done."

---

## What Happened

### The originating feedback

Two feedback files arrived in `docs/feedback/new/`:

- `2026-07-21_hierarchical-errors-cli-workflow-and-verification.md`
- `2026-07-21_hierarchical-errors-effective-usage-guide.md`

Both documented the `hierarchical-errors` Go 1.26+ linter in extensive detail: CLI subcommands (`lint`, `fix`), flag behaviors (`--type legacy_as`, `--no-suppress`, `-o`, `-f`, `--severity`, `--type-aware`), exit codes, error messages ("errors.Is is not auto-fixable"), the `legacyerrors` analyzer name, the `GOEXPERIMENT=jsonv2` prefix, and a "0% precision" statistic from cleaning up `golangci-lint-auto-configure`.

### What the first session did

Committed `4a501ab` — a new `hierarchical-errors/` skill with SKILL.md + 3 reference files. Marked the skill **🟢 Solid** in README. Updated AGENTS.md §10 external deps. Archived both feedback files to `processed/`. Treated every claim in the feedback as ground truth.

### What the second session discovered

When told to "READ, UNDERSTAND, RESEARCH, REFLECT" again, the second session (this one) attempted to verify the external claims. Findings:

1. **`errors.AsType[E error](err error) (E, bool)` is real** — confirmed via [pkg.go.dev/errors](https://pkg.go.dev/errors), added in Go 1.26.0, generic. ✅
2. **The `hierarchical-errors` binary could not be found publicly.** Searched GitHub, Sourcegraph, pkg.go.dev, and `golang.org/x/tools/go/analysis/passes/`. Zero matches for the tool name. ❌
3. **The `legacyerrors` analyzer name could not be found publicly.** Searched `golang.org/x/tools/go/analysis/passes/` (full roster), gopls `analyzers.md` (4,727 lines), and Sourcegraph. Zero matches. ❌
4. **The closest public tool is Go's own `modernize` analyzer** (`golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize`), which uses a `-fix` flag rather than `lint`/`fix` subcommands and has no `--type legacy_as` filter.
5. **`GOEXPERIMENT=jsonv2` is a real Go experiment**, but it gates the JSON v2 proposal — its connection to error linting is unclear. It may be a quirk of the original project (`golangci-lint-auto-configure`) rather than a hard requirement of the linter.
6. **Every flag behavior, exit code, and error message in the skill is unverifiable** because the binary is not available to test against.

### Why this matters

The first session did the literal instructions ("create a skill from this feedback") but skipped the implicit verification step. The result is a skill that:

- Is marked 🟢 Solid in README despite never being triggered or tested
- Propagates specific CLI claims (flag names, exit codes, error message text) that may be fabricated, hallucinated, or private to one project
- Could mislead future agents who try to run `hierarchical-errors lint ./...` and discover no such binary exists
- Repeats the exact failure mode that three recent `docs-health` feedback files warn against: fabricated metrics, skipped verification, trophy-case marking

### The deeper problem

The two source feedback files may themselves be partially or wholly hallucinated by an earlier session. The level of specific detail (exact error message strings, exact exit codes, six flag-behavior table) is the kind of detail an LLM can generate plausibly without ever running the tool. We have no way to confirm without access to the binary.

---

## Root Cause Analysis

### 1. Feedback was treated as ground truth instead of as a lead

The first session treated the feedback files as verified reference material. Feedback is supposed to be a lead — "this happened, here's what would prevent it" — not a primary source. The conversion-to-skill step should have included a verification pass on every external claim before encoding it.

### 2. No "verify external claims" gate exists in the skill-creation process

The skill-creator skill describes drafting, testing against prompts, and iterating on quality. It does not say "before encoding any external claim (CLI behavior, library version, API signature) into a skill, verify it against the primary source." Without that gate, the first session had no prompt to verify.

### 3. The 🟢 Solid status has no requirements

README's legend says 🟢 Solid means "comprehensive, production-ready" — but there is no process that checks either property before assignment. A brand-new skill can be marked Solid by anyone who feels good about it. Three prior feedback files documented this exact failure mode and the legend still does not enforce a check.

### 4. The verification attempt was only triggered by user insistence

The second session only happened because the user said "READ, UNDERSTAND, RESEARCH, REFLECT" a second time with emphasis. Without that prompt, the unverified skill would have stayed shipped as 🟢 Solid indefinitely.

---

## Suggested Improvements

### 1. Add a verification gate to skill-creator

In `skill-creator/SKILL.md`, after the draft step, add:

> **Verify external claims.** Before encoding any external claim into a skill — CLI flag behavior, library version, API signature, error message text, exit code — verify it against the primary source (official docs, source code, or by running the tool). Mark each claim with its verification status. If a claim cannot be verified, either remove it or label it explicitly as "unverified: reported in <source>, not independently confirmed."

### 2. Add a 🆕 New status to README with explicit aging rules

The legend should say:

> **🆕 New** — structurally valid, never yet triggered against real work. Ages into 🟢 Solid only after a documented successful run. New skills must start here, not at 🟢.

### 3. Make verification-status blocks a skill-creator pattern

Add to `how-to-write-skills.md`:

> **Verification-status callout.** Any skill that documents an external tool's behavior MUST include a verification-status block at the top of SKILL.md listing which claims are independently verified and which are reported-by-source only. This is the same pattern as code comments that say "UNVERIFIED" or "TODO: confirm against source."

### 4. Scan feedback for "verify the tool exists" before encoding

A pre-skill-creation check: if the feedback describes a tool by name, search for the tool publicly before building the skill. If the tool is unfindable, either (a) confirm with the user that it is private, or (b) reframe the skill around the durable concepts (the API semantics, the anti-patterns) rather than the specific tool.

### 5. Document the recurring verification pattern as a skill

This is the 4th instance of the "skipped verification before claiming done" pattern (joining `2026-07-19_docs-health-fabricated-score`, `2026-07-20_docs-health-trophy-case`, `2026-07-17_docs-health-verschlimmbesserung`). Consider extracting a `verify-external-claims` skill or hardening `skill-creator` with a mandatory verification phase.

---

## Key Lessons

1. **Feedback is a lead, not a source.** Verify external claims against primary sources before encoding them as reference material.
2. **Detailed specifics are not the same as verified specifics.** An LLM can generate plausible CLI flag tables, exit code references, and error message strings without ever running the tool. Specificity is not evidence.
3. **A tool that cannot be found publicly may not exist.** Search GitHub, pkg.go.dev, Sourcegraph, and the canonical analysis-passes directory before assuming a tool is real.
4. **Never mark new work 🟢 Solid.** New skills start at 🆕 New and age into 🟢 only after a documented successful run.
5. **The verification-gate pattern is now a 4x recurrence.** It should be encoded into `skill-creator` or extracted as its own skill.

---

## Resolution

The skill was restructured (in the same follow-up session) to:

- Lead with a prominent **verification-status block** at the top of SKILL.md separating verified claims (the `errors.AsType` API, the three-APIs mental model, the decision tree) from unverified claims (every CLI-specific behavior)
- Demote every CLI-specific section (flag table, exit codes, CI template) with clear "unverified — see verification status" labels
- Trim the description from 940 → 734 chars and focus triggers on the durable value (error-matching modernization) rather than the specific tool
- Add `allowed-tools: bash go view edit grep` frontmatter per AGENTS.md §5.8
- Change README status from 🟢 Solid → 🆕 New and add the 🆕 New legend entry
- Fix the false "All 21 skills are solid or comprehensive" claim
- Update AGENTS.md §10 to flag the linter as unverified

The skill remains useful because its core value (the three-APIs mental model, the fix-to-zero anti-pattern, the decision tree) is durable regardless of whether the specific `hierarchical-errors` linter exists. But every reader now knows which parts to trust and which to verify.

---

## Related Feedback

- `2026-07-19_docs-health-fabricated-score-skipped-verification.md` — same pattern (fabricated metrics, skipped verification gate)
- `2026-07-20_docs-health-and-update-old-docs-trophy-case-failure.md` — same pattern (trophy-case marking, overclaiming)
- `2026-07-17_docs-health-generic-banner-verschlimmbesserung.md` — same pattern (making things worse while trying to improve)
