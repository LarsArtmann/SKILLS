# Feedback: docs-health + update-old-docs — The "Living Doc Disguised as a Trophy Case" Failure

**Date:** 2026-07-20
**Project:** DiscordSync
**Task:** Verify `TODO_LIST.md` is up to date
**Outcome:** First docs-health pass declared the file healthy (9/10). It was 80% garbage. A one-line user follow-up ("Why do we have so many done things?") exposed what the skill never checked. Second pass deleted 102 of 136 lines. The skill's VERIFY process certified a structurally rotten doc as fresh.

---

## What Happened

### Pass 1 — "Is TODO_LIST.md up to date?"

User asked the question. I loaded `docs-health`, ran its VERIFY process against `TODO_LIST.md`:

1. ✅ Verified every commit hash against `git log` (found one ghost: `2e73963` → `1e27540f`)
2. ✅ Verified every `Evidence` file path exists (9 paths, no ghosts)
3. ✅ Cross-checked against FEATURES.md + CHANGELOG.md (no PLANNED-vs-FULLY_FUNCTIONAL split brain)
4. ✅ Verified D12 feature claims against actual code (5 routes registered, 5 DB methods, 6 tests)
5. ✅ Ran `nix run .#quality` → 0 issues

Declared **Health Score: 9/10**, claimed the file was fresh, reported 4 findings fixed. Working tree clean.

### The user's one-line follow-up

> "Why do we have so many done things in TODO_LIST.md?"

Re-reading the file with this lens exposed what VERIFY never asked:

- **D1-D13 tables retained after completion** with a header note ("retained for reference")
- **"Previously Completed" section** (~50 lines) duplicating `CHANGELOG.md [Unreleased]` verbatim
- **"Correctness gaps (resolved 2026-07-18)"** — struck-through items that belong in CHANGELOG
- **REJECTED CQRS spikes** — belong in ADR-021/022
- **5 "- DONE" backlog items** — duplicating ROADMAP.md

**5 genuinely open items buried under ~80% historical content.** 136 lines → 34 lines after rebuild. Every "done" fact was already in its proper home (CHANGELOG or ROADMAP). Nothing was lost.

### The core failure

**The skill verified the doc was _accurate_. It never verified the doc was _useful_.** A TODO_LIST can be 100% factually correct and 100% useless as a TODO list.

---

## Why docs-health Failed to Catch This

### 1. VERIFY checks truth, not job-fitness

The skill's failure-mode table covers "Points at ghosts," "Wrong commands," "Contradicts code," "Stale status," "Missing reality," "Counted wrong," "Cosmetic." **None of these ask: "Is this doc doing its one job?"**

The documentation model says each file has ONE job. `TODO_LIST.md` owns "short-term actionable work." But VERIFY never tests whether the content actually matches the job. It tests whether each claim is true.

**Missing failure mode:** "Structural decay — living doc accumulated historical content that belongs elsewhere."

### 2. "Upsert, do not rewrite" actively caused the rot

From the BUILD rules:

> **Upsert, do not rewrite.** If the file already exists, update rows in place rather than rewriting from scratch.

This is correct guidance for `FEATURES.md` (rows evolve: PLANNED → FULLY_FUNCTIONAL). It is **actively harmful** for `TODO_LIST.md`. When a TODO item is done, the correct action is **delete it from TODO** (it now lives in CHANGELOG), not "upsert" it to a "done" state and leave it cluttering the file.

The skill treats all living docs the same. They are not. `FEATURES.md` is append-and-update. `TODO_LIST.md` is add-then-delete. `CHANGELOG.md` is append-only. The lifecycle differs per doc type, and the rules should too.

### 3. Cross-file consistency check is too narrow

The skill's minimum consistency checks include:

> - [ ] No feature is listed as both PLANNED (in TODO_LIST.md) and FULLY_FUNCTIONAL (in FEATURES.md)

Good. But the inverse rot — **completed work listed in TODO_LIST when it belongs in CHANGELOG** — is not checked. Nor is **deferred items duplicated between TODO_LIST and ROADMAP.md** (a true split brain: which is the source of truth when they drift?).

This session found both: 5 "- DONE" backlog items duplicated ROADMAP, and the entire "Previously Completed" section duplicated CHANGELOG.

### 4. "Fix drift in place" encourages patching a rotten doc

VERIFY step 4:

> **Fix drift in place.** Update the doc to match the code.

For factual drift (wrong hash, ghost file), fixing in place is correct. For **structural decay** (80% content belongs elsewhere), "fix in place" produces a patched-up scar pile. The correct action is rebuild — but the skill's rebuild-vs-patch threshold is poorly calibrated for this case:

> If a single doc has drift exceeding ~50% of its claims, rebuild it from scratch

A TODO_LIST that is 50% non-actionable is already badly broken. The 50% threshold is calibrated for factual drift density, not structural decay. This file passed the threshold ("only" ~6 factual findings) while being 80% structurally rotten.

### 5. The Health Score gave false confidence

I computed "Health Score: 9/10" on first audit. The formula only deducts for Critical/Medium/Low **findings** — and findings are scoped to factual claims. A doc with zero factual errors but 80% irrelevant content scores 10/10. The score measures _accuracy_, not _fitness_. Reporting "9/10" to the user signaled "this file is fine" when it wasn't.

### 6. No per-doc-type verification specifics

VERIFY has a generic process but no per-doc-type checklist. The skill references `verify-checklist.md` but the actual checks (from the skill body) are all generic. `TODO_LIST.md` needs specific checks that other docs don't:

- What % of lines describe _open_ work vs _completed/rejected/resolved_ work?
- Are any completed items present that are also in CHANGELOG?
- Are any deferred items duplicated from ROADMAP?
- Does the doc have a "Previously Completed" / "Done" section? (It shouldn't.)

---

## Why update-old-docs Has a Blind Spot Here

The documentation model cleanly separates **living** (rewritten in place by docs-health) from **historical** (annotated non-destructively by update-old-docs). But there's a third case neither skill owns:

**A living doc that has slowly accumulated historical cruft over many sessions.**

This isn't a snapshot gone stale (update-old-docs territory). It isn't a living doc with a few drifted facts (docs-health VERIFY). It's a living doc whose _purpose_ has been diluted by months of "I'll just leave this done item here for reference" decisions across many sessions.

`update-old-docs` is about bringing _point-in-time snapshots_ current without destroying history. `docs-health` is about keeping _living docs_ factually accurate. **Neither skill explicitly owns "clean out the accumulated done-items from a TODO_LIST that's been neglected."**

The crossover shows in the AGENTS.md doc-ownership table: TODO_LIST is marked "Living" with "NOT for: completed work" — but the enforcement mechanism for that "NOT for" lives in neither skill's primary process.

---

## Proposed Changes

### To docs-health

**A. Add a "job fitness" check to VERIFY, per doc type.**

For each living doc, before checking factual accuracy, check whether the doc is doing its one job. Concrete checks for `TODO_LIST.md`:

- Count lines/items describing open work vs completed/resolved/rejected.
- Flag any "Previously Completed," "Done," "Resolved" section — these belong in CHANGELOG.
- Flag any item whose content duplicates a ROADMAP entry.
- Flag any item also present in CHANGELOG `[Unreleased]`.

If >25% of content is non-actionable historical material, **rebuild, do not patch**.

**B. Differentiate per-doc lifecycle in BUILD rules.**

Replace the blanket "Upsert, do not rewrite" with per-doc-type guidance:

- `FEATURES.md`: Upsert (rows evolve status). Correct as-is.
- `TODO_LIST.md`: **Delete done items.** A completed TODO is not "upserted to done" — it is removed, because it now lives in CHANGELOG. The only exception: items retained explicitly marked "kept as historical note" with a one-line rationale (see C5 in this session — rejected with ADR reference).
- `CHANGELOG.md`: Append-only. Never edit prior entries.
- `ROADMAP.md`: Update in place; ideas graduate to TODO when actionable.

**C. Lower the rebuild threshold for structural decay.**

Split the rebuild-vs-patch decision into two axes:

- **Factual drift density** (current 50% threshold): keep.
- **Structural decay** (content that belongs elsewhere): threshold 25%. A TODO_LIST that's 25% historical content is failing its job.

**D. Add structural-decay failure mode to the severity table.**

New row, severity Medium-High:

| Severity    | Failure mode     | Example                                                                                                                                                 |
| ----------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Medium-High | Structural decay | Living doc (esp. TODO_LIST) accumulated completed/resolved/rejected content that belongs in CHANGELOG/ADRs; doc is no longer fit for its stated purpose |

**E. Fix the Health Score to penalize structural decay.**

Currently: `10 − findings`. Add: `− 2 × (fraction_of_non_job_content above 25%)`. A TODO_LIST that's 80% historical content loses ~1.1 points even with zero factual errors. The score must reflect fitness, not just accuracy.

**F. Expand cross-file consistency checks.**

Add to the minimum checks:

- [ ] No completed item in TODO_LIST is also in CHANGELOG `[Unreleased]` (split brain: which is source of truth?)
- [ ] No deferred/backlog item in TODO_LIST duplicates a ROADMAP entry
- [ ] TODO_LIST has no "Previously Completed" / "Resolved" / "Done" section (belongs in CHANGELOG)

### To update-old-docs

**G. Acknowledge the living-doc-cruft boundary case.**

Add a short section: "When a _living_ doc (not a snapshot) has accumulated historical material across sessions, that is **not** this skill's territory — defer to `docs-health` with structural-decay handling. This skill annotates point-in-time _snapshots_ non-destructively. Living docs get rewritten, not annotated."

The current skill already says "distinct from docs-health, which maintains LIVING docs by rewriting them in place" — but it should explicitly call out the accumulated-cruft case so an agent doesn't reach for annotation when rebuilding is correct.

### Cross-skill

**H. Add a "first, ask: what job does this doc do?" preamble to both skills.**

Before any VERIFY/BUILD/ANNOTATE work, the agent should state, in one line, what the doc's job is and what content does NOT belong. This forces job-fitness into scope before factual verification begins. Example for TODO_LIST:

> "TODO_LIST.md owns short-term actionable work. Completed/rejected/resolved items do NOT belong here — they go in CHANGELOG/ADRs. Deferred items belong in ROADMAP. I will flag any content outside the job scope before checking factual accuracy."

---

## Test Scenarios That Would Have Caught This

A skill that claims to verify doc health should catch these inputs:

1. **The "trophy section" case:** A TODO_LIST with a "Previously Completed" section duplicating CHANGELOG. Current VERIFY passes (all facts true). Should fail with "structural decay — belongs in CHANGELOG."

2. **The "retained for reference" case:** A TODO_LIST with completed items kept under a header note ("retained for reference"). Current VERIFY passes. Should fail: "completed items must be deleted, not annotated."

3. **The "split brain backlog" case:** A TODO_LIST backlog section and a ROADMAP "Deferred Items" section listing the same 5 items. Current cross-file check passes (it only checks PLANNED-vs-FULLY_FUNCTIONAL). Should fail: "deferred items duplicated across TODO and ROADMAP."

4. **The "rejected but kept" case:** A TODO item marked REJECTED with rationale, sitting in a "still open" list. (This session's C5.) Current VERIFY passes. Should at minimum flag: "rejected items don't belong in open-work lists; move to ROADMAP or delete with ADR reference."

5. **The "struck-through resolved" case:** A "Correctness gaps (resolved YYYY-MM-DD)" section with struck-through items. Current VERIFY passes (items are marked resolved). Should fail: "resolved items belong in CHANGELOG Fixed section, not TODO_LIST."

---

## What Worked Well (Keep These)

- **"Code wins" principle** — drove the hash verification that caught the real ghost.
- **Cite evidence (`path/to/file.go:NN`)** — made the factual verification trustworthy and fast.
- **The "first audit — no baseline" honesty rule** — correctly avoided inventing a prior score.
- **Running the quality gate** — caught nothing here, but the discipline is right.

The skill's factual verification is genuinely good. The gap is _structural_: it certifies docs as healthy without asking whether they serve their purpose. Filling that gap is the difference between a skill that catches typos and a skill that keeps a documentation system coherent.

---

## Summary

| Skill           | Gap                                             | Proposed fix                                |
| --------------- | ----------------------------------------------- | ------------------------------------------- |
| docs-health     | VERIFY checks truth, not job-fitness            | Add per-doc-type structural checks (A, F)   |
| docs-health     | "Upsert" rule causes TODO rot                   | Per-doc lifecycle rules (B)                 |
| docs-health     | Rebuild threshold too high for structural decay | Split factual vs structural thresholds (C)  |
| docs-health     | Health Score ignores fitness                    | Penalize non-job content (E)                |
| docs-health     | Cross-file check too narrow                     | Add TODO↔CHANGELOG, TODO↔ROADMAP checks (F) |
| update-old-docs | Blind spot on living-doc accumulated cruft      | Explicit boundary statement (G)             |
| Both            | No "what is this doc's job?" preamble           | Force job-scope statement before VERIFY (H) |

The fix is not "be more careful." The fix is to make the skill's checks match the skill's own documentation model. The model already says each file has one job and each fact lives in one place. The VERIFY process just doesn't enforce it.
