# Status Report: docs-health + update-old-docs Nuclear Merge

**Date:** 2026-08-04 01:47
**Session goal:** Cut bloat from `docs-health` and `update-old-docs` so the AI focuses on inline item resolution instead of ceremony.
**Outcome:** Merged into one skill. Body cut 67% (977→166 lines). But the merge created its own staleness and the cross-reference sweep had a significant process failure.

---

## a) FULLY DONE

1. **Read both skills** (477 + 500 lines) and diagnosed the root disease: every rule stated 3× (body → anti-patterns → verification gate), burying the actual work procedure under process warnings.
2. **Asked 4 strategic questions** via the Questions tool. User chose: nuclear (~120-line body), move cut material to references/, merge into one skill, all four modes with HARVEST as primary.
3. **Wrote the merged `docs-health/SKILL.md`** — 166 lines, 5 modes (BUILD / HARVEST / VERIFY / ANNOTATE / AUDIT), each rule stated exactly once. HARVEST positioned as the primary mode. ANNOTATE's inline resolution format labeled "The primary work."
4. **Moved 3 reference files** from `update-old-docs/references/` into `docs-health/references/` via `git mv` (preserves history).
5. **Created `harvest-guide.md`** — houses the HARVEST anti-patterns, timing rules, and the two-way loop description that used to clutter the body.
6. **Deleted `update-old-docs/`** from both the repo and `~/.config/crush/skills/` (via `trash`, not `rm`).
7. **Fixed all 17 live cross-references** across 11 files: status-report, architecture-review, pareto-planning, full-code-review, naming-review, deduplicate-code, common-mistakes.md, doc-ownership.md, how-to-write-skills.md, README.md, AGENTS.md.
8. **Updated `check-skills.sh`** — changed the handoff guard needle from `"When to run HARVEST"` to `"## HARVEST — pull forward"` to match the new section heading.
9. **Updated all 4 living docs** — README (25→24 skills, removed Editing Discipline section), FEATURES (docs-health row: 500→166 lines, 6→10 references), TODO_LIST (T5 marked DONE), ROADMAP (removed update-old-docs from pairs, updated open questions), CHANGELOG (added merge entry under [Unreleased]).
10. **Synced all changes** to `~/.config/crush/skills/` — docs-health, status-report, architecture-review, pareto-planning, deduplicate-code, full-code-review, naming-review.
11. **`check-skills.sh` passes** — 24/24 skills, 0 thin, 0 dangling links (after 3 rounds of fixes).

---

## b) PARTIALLY DONE

1. **Cross-reference sweep** — 11 of 17 references found and fixed. But the initial search (via agent tool) **missed 5 skill files** (architecture-review, pareto-planning, deduplicate-code, full-code-review, naming-review). Caught 2 via `check-skills.sh` dangling-link failures, then 3 more via a manual `rg` sweep. If I hadn't run the final sweep, 3 skills would have silent dangling links right now.
2. **`how-to-write-skills.md` Pattern 8** — Updated the references from "update-old-docs" to "docs-health ANNOTATE", but the pattern still describes the architecture as a cross-skill handoff between producers and a consumer skill. Now that ANNOTATE and HARVEST are modes within one skill, the pattern's description of "pair it with the backward note" is internally redundant — both directions live in the same skill now.
3. **Moved reference files** — Links resolve (`../SKILL.md` now correctly points to docs-health/SKILL.md), but the **companion descriptions are stale**: `resolving-items.md` calls itself "Companion to the _Numbered action items_ section" but that section name doesn't exist in the new body (it's now "The primary work: resolve every numbered item inline"). Same for `annotation-placement.md` ("_Annotation placement_ section") and `case-study.md` ("This is why ../SKILL.md says: undo batch edits with `git restore`" — that guidance was cut from the body).

---

## c) NOT STARTED

1. **VERIFY the merged skill on itself.** The supreme irony: I didn't run docs-health VERIFY on the new docs-health. No internal consistency check, no fresh-open test, no description-length audit (it's 1031 chars — borderline against the ~1024 guidance).
2. **Reconcile how-to-golang split brain** — README says 🟢 Comprehensive; FEATURES says 🟡 PARTIALLY_FUNCTIONAL. Carried over from prior session, still unresolved.
3. **Check if `harvest-guide.md` duplicates the body.** I created it to house anti-patterns and the two-way loop. But the body already references "Drop resolved items" and the marker vocabulary. The harvest-guide may restate what the body already says — the exact 3× repetition trap we were trying to eliminate.
4. **Audit what was lost in the nuclear cut.** The old docs-health had an "Adapt to project type" table (Content repo / Library / Web app / Monorepo → which docs are must-have). The new body doesn't include it. It may be in `build-guide.md` — unverified.
5. **Classify the ~20 older status reports** (pre-2026-07-30). Identified in the prior session; not touched.

---

## d) TOTALLY FUCKED UP

1. **The cross-reference search failed.** I delegated to the agent tool to "search the entire SKILLS directory for every reference to update-old-docs." It returned a detailed report claiming Group 2 (other skill directories) had only 4 files: docs-health/SKILL.md, common-mistakes.md, doc-ownership.md, status-report/SKILL.md. It **missed 5 skill files** that contained `update-old-docs`: architecture-review, pareto-planning, deduplicate-code, full-code-review, naming-review. This is a significant reliability failure. The agent either didn't search all skill directories or missed matches. I trusted the report instead of running my own `rg -l 'update-old-docs' **/SKILL.md` to verify.
   - **Root cause:** Over-reliance on a sub-agent for a critical sweep without independent verification.
   - **Impact:** 5 skills had dangling `../update-old-docs/SKILL.md` links. 2 were caught by check-skills.sh (which has a dangling-reference guard). 3 would have shipped broken if I hadn't run a paranoid final `rg` sweep.
   - **Lesson:** For cross-reference mapping, always run `rg -l '<old-name>' **/SKILL.md` yourself. Do NOT trust a sub-agent summary for blast-radius analysis.

2. **Created new staleness while fixing old staleness.** The moved reference files (`resolving-items.md`, `annotation-placement.md`, `case-study.md`) now have stale companion descriptions — they reference section names and body content that no longer exist in the nuclear-cut SKILL.md. I moved the files without reading them first to check whether their internal references would still be valid against the new body. This is the exact "edit without reading" failure mode the AGENTS.md warns against.

3. **Didn't verify the description trigger coverage.** The old `update-old-docs` had a carefully crafted 715-char description tuned for Crush's skill selection. I merged its trigger phrases into docs-health's description (now 1031 chars — near the limit). But I have no evidence that Crush will actually select `docs-health` when a user says "update old docs" or "mark these reports as done." The trigger phrases are there, but description bloat may dilute selection accuracy. This is untested.

---

## e) WHAT WE SHOULD IMPROVE

### Process improvements

1. **Never trust sub-agent summaries for cross-reference mapping.** Always verify with a direct `rg -l '<pattern>' **/SKILL.md`. The sub-agent missed 5 of 12 matches (42% miss rate).
2. **check-skills.sh needs a general dangling-reference guard** — not just the handoff needle list. It should grep every `](../<name>/SKILL.md)` link and verify the target exists. The current handoff guard caught 2 of 5 misses; a general guard would catch all 5.
3. **The nuclear cut needs a VERIFY step.** After rewriting a skill body, run the skill on itself: open every reference file it mentions, verify the companion descriptions still match, check that no content was silently lost. I skipped this and created 3 stale reference files.
4. **Move-then-verify, not move-and-trust.** When moving reference files between directories, their relative links may resolve but their content references may be stale. Always read moved files against their new companion.

### Skill design improvements

5. **The "each rule once" principle has a tension:** if a rule is stated once in the body and the body is the only thing loaded on trigger, the rule has exactly one chance to be followed. The old 3× repetition was bloated but it was also a defense-in-depth strategy — the verification gate caught agents that skipped the body. The nuclear cut removes that safety net. This may be the right tradeoff (the body is shorter so more likely to be fully read), but it's untested.
6. **`harvest-guide.md` may be unnecessary.** It houses content that used to be in the body (anti-patterns, two-way loop). If the body's 6-step HARVEST procedure is clear enough, the guide is just the anti-patterns — which are inversions of the steps. Consider folding the essential anti-patterns back into the body as a compact "Don't" list and deleting the guide.
7. **The ANNOTATE section in the body is the densest part** (classification table + format + placement + "so what?" test in ~30 lines). It may be too compressed for an agent encountering inline resolution for the first time. The format example (lines 1-4 of the code block) is the single most important thing — consider giving it more visual weight.

### Repo improvements

8. **Add a dangling-reference guard to `check-skills.sh`** that greps every markdown link in every SKILL.md and verifies the target file exists. This would have caught all 5 misses automatically.
9. **The `how-to-write-skills.md` patterns need updating** to reflect that ANNOTATE and HARVEST are now modes within one skill, not a cross-skill pair. Pattern 7 (Restraint) and Pattern 8 (Handoff Notes) both still describe the old two-skill architecture in places.

---

## f) Top things to get done next

### P0 — Fix breakage from this session

1. **Fix stale companion descriptions in 3 moved reference files.** `resolving-items.md` line 3: "Numbered action items section" → "The primary work subsection under ANNOTATE." `annotation-placement.md` line 3: "Annotation placement section" → "Placement: inline before appendix under ANNOTATE." `case-study.md` lines 44, 134: references to body content that was cut.
2. **VERIFY docs-health on itself.** Open the new body fresh. Does it give enough guidance for an agent to BUILD a TODO_LIST? Run HARVEST? Resolve items inline? Identify anything lost in the nuclear cut.
3. **Check `harvest-guide.md` for duplication.** Does it restate body content? If yes, either fold the unique parts into the body or trim the guide to only the anti-patterns.

### P1 — Strengthen the merge

4. **Add a general dangling-reference guard to `check-skills.sh`.** Grep every `](../<name>/` link in every SKILL.md; fail if target doesn't exist. Would have caught all 5 misses from this session.
5. **Update Pattern 7 and Pattern 8 in `how-to-write-skills.md`** to reflect single-skill-with-modes architecture instead of cross-skill pairs.
6. **Test the description trigger coverage.** Does Crush select docs-health for "update old docs" / "mark these done"? If not, the merged description needs tuning.
7. **Reconcile how-to-golang status** (README 🟢 vs FEATURES 🟡) — carried over from prior session.
8. **Verify `build-guide.md` still contains the "Adapt to project type" table** that was cut from the body. If not, add it.

### P2 — Deepen and polish

9. **Add TOC-integrity guard to `check-skills.sh`** (TODO T6) — count `## ` headings vs TOC entries.
10. **Add marker-vocabulary guard to `check-skills.sh`** (TODO T7) — verify HARVEST references ANNOTATE-owned markers.
11. **Reconcile scoring systems** (TODO T8) — `agents-quality-guide.md` has 5-dimension rubric; `health-report-format.md` has 2-score. Split brain.
12. **Create `scripts/check-agents-md.sh`** (TODO T9) — package temporal-pollution grep patterns.
13. **Append appendix-only incident to `case-study.md`** (TODO T10) — 4th failure-mode round.
14. **Add condensing checklist to `how-to-write-skills.md`** (TODO T11).
15. **Classify the ~20 older status reports** (pre-2027-07-30) — ANNOTATE/ARCHIVE/SKIP/LEAVE ALONE.

### P3 — Strategic improvements

16. **Consider a "mode dispatch" pattern for other multi-mode skills.** docs-health now has 5 modes in 166 lines. If this works well, apply the pattern to other skills that are really multiple skills stuffed together.
17. **Document the "each rule once" principle in `how-to-write-skills.md`** as a first-class pattern, with the docs-health merge as the worked example.
18. **Consider whether the AUDIT mode is necessary.** It's just BUILD + HARVEST + VERIFY. An agent can be told to run those three in sequence without a named AUDIT mode. Removing it would simplify the mode table.
19. **Audit all other skills for the 3× repetition disease.** If docs-health and update-old-docs had it, others might too. Run `wc -l` on all SKILL.md files; anything over 200 lines is a candidate for the nuclear treatment.
20. **Consider whether `website-launch` (1106 lines) needs the nuclear treatment.** It's allowlisted but it's 6.6× the guideline.
21. **Run a full docs-health AUDIT** on the entire repo now that the living docs exist (TODO_LIST, FEATURES, ROADMAP, CHANGELOG). Verify cross-file consistency.
22. **Consider whether the description is too long** (1031 chars). It merges two skills' worth of trigger phrases. Test whether a shorter description with fewer triggers actually improves selection accuracy (less dilution).

---

## g) Questions I cannot figure out myself

### Q1: Should the moved reference files be updated to match the new body, or should the body's section names be changed to match the reference files?

The moved files (`resolving-items.md`, `annotation-placement.md`, `case-study.md`) reference section names from the old body ("_Numbered action items_ section", "_Annotation placement_ section") that don't exist in the new nuclear body. Two options:
- **A)** Update the reference files' companion descriptions to reference the new section names (e.g., "The primary work subsection under ANNOTATE").
- **B)** Rename the body's sections to match what the reference files already say (e.g., add a "Numbered action items" heading).

Option A is less churn. Option B keeps the reference files stable. Which do you prefer?

### Q2: Should `harvest-guide.md` exist as a separate file, or should its content be folded back into the body?

I created `harvest-guide.md` to house HARVEST anti-patterns and the two-way loop. But the body already covers the essential rules (drop resolved items, questions aren't tasks, don't rewrite the source). The guide may be duplicating the body — the same 3× repetition trap we just eliminated. Options:
- **A)** Keep it — the anti-patterns are valuable detail that would bloat the body if inline.
- **B)** Fold the 2-3 essential anti-patterns into the body as a compact list, delete the guide.
- **C)** Keep it but trim to only the content NOT already in the body (just the anti-patterns, drop the two-way loop which is already implied by the ANNOTATE/HARVEST cross-references).

### Q3: Is the 166-line body actually better at producing the hard work (inline item resolution) than the old 977-line duo?

I've asserted that the nuclear cut makes the AI "focus on the important stuff" but I have zero evidence. The old skills were bloated but their repetition was also a defense-in-depth — the verification gate and anti-patterns list caught agents that skimmed the body. The nuclear cut has exactly one statement of each rule. If an agent skims past the inline resolution format, there's no backup. Should we:
- **A)** Trust the nuclear cut and test it against real work (run ANNOTATE on the 8 un-annotated status reports from the prior session).
- **B)** Add back a minimal verification gate (3-4 checkboxes, not 15) specifically for the inline-resolution completeness check.
- **C)** Add back the #1 failure mode ("appendix-only") as a standalone callout at the top of ANNOTATE, keeping the rest nuclear.
