# Status: `update-old-docs` Skill — Rename & Re-scope Session

**Date:** 2026-07-17 02:28
**Session arc:** (1) Created `no-harm-edits` from feedback → (2) wrote honest status report → (3) **renamed to `update-old-docs` + re-scoped to the real premise** (this turn).
**Verdict:** Rename is clean and validated. Re-scope is correct but has a framing gap in the reference files. Two carryover failures from last status remain unfixed — most notably D1 (AGENTS.md stale count), now flagged for the **second consecutive report without being fixed**.

---

## a) FULLY DONE

| #   | Item                                             | Evidence                                                                                                                                                                                                                      |
| --- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Directory renamed with history preserved         | `git mv no-harm-edits update-old-docs`; git tracks as `R` (rename) not delete+add                                                                                                                                             |
| 2   | `SKILL.md` rewritten around the real premise     | Now leads with _"old documents go stale; keeping them current is a different problem from docs-health (living docs get rewritten, old docs get annotated)"_. 242 lines.                                                       |
| 3   | `name:` frontmatter updated                      | `no-harm-edits` → `update-old-docs` (matches dir)                                                                                                                                                                             |
| 4   | `description:` re-scoped                         | Trigger phrases now center on "old/stale files", "mark these old reports", "is this still current"; explicit `DISTINCT from docs-health` boundary                                                                             |
| 5   | README inventory row updated                     | New name + reframed description ("Keeps old/historical docs current via non-destructive annotation")                                                                                                                          |
| 6   | docs-health backlink reframed                    | Section retitled _"Keeping old/historical documents current (distinct from living docs)"_ — centers the living-vs-historical distinction instead of generic "bulk annotation"                                                 |
| 7   | No stray `no-harm-edits` refs in tracked content | `grep -rln no-harm-edits` → only `.crush/crush.db` (Crush internal DB, untracked, irrelevant)                                                                                                                                 |
| 8   | Structural validation                            | `check-skills.sh`: **20 skills, 0 thin, all pass**                                                                                                                                                                            |
| 9   | Link integrity                                   | All navigational relative links resolve (only 2 "misses" are illustrative text inside a ` ```markdown ` fence quoting the original bad banner — correct)                                                                      |
| 10  | The re-scope decision itself                     | Reframed from a generic "batch-edit meta-skill" to a precise premise (_old docs go stale; annotate don't rewrite_). This is the most important outcome — the skill now has a sharp, non-overlapping mandate vs `docs-health`. |

**Design decision recorded:** `docs-health` maintains **living** docs by rewriting (`README`, `FEATURES`, `TODO_LIST`). `update-old-docs` maintains **historical** docs by annotating (status reports, plans, audits). The distinction is now stated explicitly in BOTH skills' bodies — clean boundary, no split brain.

---

## b) PARTIALLY DONE

### B1. Reference files were renamed but NOT re-framed (framing gap)

The rename moved `annotation-placement.md` and `case-study.md` intact. They are **clean of the old name** (verified: 0 `no-harm-edits` references). But:

- `annotation-placement.md` — already framed around "historical documents" from the first draft (8 mentions of old/historical/snapshot). **Framing is accidentally correct.** ✅
- `case-study.md` — titled _"The Docs-Health Generic Banner Verschlimmbesserung"_ and framed around "the incident that created this skill". It does not explicitly connect back to the **old-docs premise** — a reader landing there sees a batch-edit cautionary tale, not a lesson about _keeping old documents current_. The connective tissue ("these were old status reports; the failure was in how they were updated") is implied, not stated. ⚠️

**Fix:** Add 2-3 sentences to the top of `case-study.md` explicitly framing it as _"what goes wrong when you update old status reports without the restraint discipline."_ ~5 min.

### B2. The previous status report is now stale (orphaned terminology)

`docs/status/2026-07-17_02-08_no-harm-edits-skill-creation-status.md` references `no-harm-edits` **25 times** — as the deliverable name, in its questions, in its next-steps. After the rename, every one of those references is stale. The report's _substance_ (the D1 count bug, the missing backlinks, the 50-item backlog) is still valid, but the name is wrong throughout.

This is ironically the exact class of problem `update-old-docs` exists to solve: an old document that has gone stale. **I should eat my own dog food and annotate/supersede it.** Options: (a) add a `> Superseded: skill renamed to update-old-docs` inline note at top, (b) rename the file and add a resolution appendix, (c) leave it (it's a point-in-time snapshot — arguably fine as-is).

---

## c) NOT STARTED

| #   | Item                                                                                       | Why it matters                                                                      |
| --- | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| C1  | **`AGENTS.md:30` "18 total"** — STILL unfixed (see D1 below)                               | Second status report flagging this. Real count is 20.                               |
| C2  | Re-frame `case-study.md` to the old-docs premise                                           | See B1                                                                              |
| C3  | Resolve the stale prior status report                                                      | See B2                                                                              |
| C4  | Backlinks from `full-code-review`, `naming-review`, `deduplicate-code` → `update-old-docs` | Carried from last report; those skills still won't load the restraint discipline    |
| C5  | Literal docs-health additions (common-mistakes.md, VERIFY, BUILD)                          | Feedback asked for 3 specific additions; still only a pointer exists                |
| C6  | Trigger testing the new description                                                        | Not verified that it fires on "update the old reports" and NOT on single-file edits |
| C7  | Add `update-old-docs` to `how-to-write-skills.md` pattern catalogue                        | New pattern: "non-destructive annotation of historical docs"                        |

---

## d) TOTALLY FUCKED UP

### D1. `AGENTS.md:30` still says "18 total" — flagged last report, STILL not fixed

```
AGENTS.md:30  ├── <skill-name>/  # One directory per skill (18 total)
```

- Real count: **20**.
- I flagged this as D1 in the **02:08 status report** and called it _"the single highest-priority fix, a 30-second edit."_
- I then did a full rename + re-scope session and **did not fix it again.**
- This is now a **meta-Verschlimmbesserung**: I am building documentation-quality skills while shipping a documentation lie in my own repo's AGENTS.md, across two consecutive status reports.

**This is the most embarrassing thing in the session.** It is a one-line edit. It should have been fixed before the rename, or during it, or immediately after. It is still not fixed.

**Severity:** Medium → escalating. The bug itself is cosmetic, but the _process failure_ (flag → ignore → flag → ignore) is the exact anti-pattern the new skill preaches against.

### D2. (New this turn) I created a stale document while building a skill about stale documents

The 02:08 status report is now stale (25 references to a renamed skill). I did not notice or address this during the rename. The skill I just built says _"when you rename/change something, find the old references and update them"_ — and I applied that to `SKILL.md`, `README.md`, and `docs-health/SKILL.md`, but **not to my own status report from 20 minutes earlier.** Inconsistent application of my own rule.

---

## e) WHAT WE SHOULD IMPROVE (on the work itself)

1. **The re-scope is right but the reference files lag it.** `case-study.md` reads as a generic batch-edit incident, not as a lesson about old documents. Re-frame it (B1).
2. **Eat our own dog food on the stale status report.** The 02:08 report is the perfect test case for the skill's own annotation-placement guidance — add an inline `> Renamed to update-old-docs` note or a resolution appendix (B2).
3. **Fix D1 before ANY other work.** It undercuts every claim this repo makes about documentation quality.
4. **The skill description is long (845→ now larger).** Re-check it's under 1024 after the re-scope expansion. (Likely fine, but unverified this turn.)
5. **The `docs-health` pointer section grew to ~12 lines.** Could be a one-liner + link; docs-health is already 276 lines.
6. **No quick-reference / tl;dr** at the top of `update-old-docs/SKILL.md` (carried from last report).
7. **Verification gate still references `nix run .#quality`** which doesn't exist in THIS repo (carried from last report).

---

## f) NEXT — up to 50 things, ranked by impact

**Tier 1 — fix the lies & close the loop (do first, in order)**

1. **Fix `AGENTS.md:30` "18 total"** — replace hardcoded count with a pointer to `scripts/check-skills.sh` (D1, second flag) 🔴
2. **Re-frame `case-study.md`** to explicitly connect to the old-docs premise (B1)
3. **Annotate the 02:08 status report** — add inline `> Renamed to update-old-docs (02:28)` note (B2 / D2)
4. Audit AGENTS.md for ANY other stale claims worsened this session
5. Add missing **backlink from `full-code-review/SKILL.md` → `update-old-docs`** (C4)
6. Add missing **backlink from `naming-review/SKILL.md` → `update-old-docs`** (C4)
7. Add missing **backlink from `deduplicate-code/SKILL.md` → `update-old-docs`** (C4)

**Tier 2 — literal feedback-loop closure**

8. Add "annotate-everything trap" entry to `docs-health/references/common-mistakes.md` → `update-old-docs` (C5)
9. Add "output quality, not process quality" to `docs-health` VERIFY process (C5)
10. Add "never batch without judgment" to `docs-health` BUILD rules (C5)

**Tier 3 — strengthen the skill**

11. Verify the expanded `description:` is still under 1024 chars
12. Add a 5-line **quick-reference / tl;dr** at the top of `update-old-docs/SKILL.md`
13. Generalize the verification-gate line (`nix run .#quality` → "project's quality gate, e.g. ...")
14. Trim/compress the `docs-health` pointer section to one line + link
15. Add a TOC to `case-study.md` (>50 lines, repo convention)

**Tier 4 — discoverability & patterns**

16. Add **Pattern: Verschlimmbesserung prevention / non-destructive annotation** to `how-to-write-skills.md` (C7)
17. Add `update-old-docs` to "Proven Patterns from Real Skills" table in same file
18. Test trigger description against 3 realistic prompts (C6)
19. Add negative test: skill does NOT fire on single-file or living-doc edits
20. Verify the skill does NOT cannibalize `docs-health` triggers (boundary clarity)

**Tier 5 — repo hygiene & governance**

21. Run `scripts/check-skills.sh` after all fixes (regression guard)
22. Decide backlink scope for `brutal-self-review` + `code-quality-scan` (see Q2)
23. Consider whether `update-old-docs` belongs in a "Documentation" category rather than "Editing Discipline" (placement judgment)
24. Rename README category "Editing Discipline" → "Documentation Maintenance" for clarity?
25. Commit the work (NOT done — user has not asked)

**Tier 6 — deeper content (optional)**

26. Add a **"common stale-doc anti-patterns"** reference (banner stamp, ghost-link, count-rot, status-table duplication)
27. Add a **decision tree**: "inline edit vs appendix vs leave alone"
28. Add guidance for annotating **generated/locked files** (don't edit machine output)
29. Add **idempotency** guidance (re-annotating should be a no-op, not double-stamp)
30. Cross-link from `status-report` (its HTML snapshots will later need this skill)
31. Cross-link from `pareto-planning` (plans are historical artifacts too)
32. Consider `update-old-docs/references/undo-strategies.md` (git restore, etc.)
33. Add an example of a GOOD multi-file annotation pass (not just the bad one)
34. Add guidance for the exception: when the user explicitly WANTS uniform stamps (license headers)
35. Add the Verschlimmbesserung concept to `docs/DOMAIN_LANGUAGE.md` if one exists

**Tier 7 — meta / process for the SKILLS repo itself**

36. Make `scripts/check-skills.sh` **fail on hardcoded skill counts** in AGENTS.md/README.md (grep `N total`/`N skills`, compare to discovered count) — would have auto-caught D1 twice
37. Add a `--check` mode for backlink integrity (every `../<skill>/SKILL.md` resolves)
38. Document the "feedback → skill → archive" loop as `scripts/process-feedback.sh`
39. Add `docs/feedback/README.md` explaining new/processed convention
40. Consider skill versioning (semver in frontmatter)

**Tier 8 — nice-to-haves**

41. Spell-check all new files
42. Check for em-dashes in new files (project convention: avoid)
43. Ensure no unexplained `ALWAYS`/`MUST`/`NEVER` in the new skill
44. Review `metadata.tags` — could add `historical`, `appendix`
45. Consider a companion `rules/no-generic-banners.md` rule file
46. Update the comprehensive status audit cross-reference if it lists skill count
47. Add the new skill to any skill-graph diagram in docs/status
48. Review whether the "Editing Discipline" category is the right README home
49. Add a one-line "living vs historical" callout to `docs-health`'s documentation model table
50. **Schedule a dog-food pass: run `update-old-docs` on the SKILLS repo's own old status reports** (including the 02:08 one) — the ultimate self-test

---

## g) Questions I CANNOT figure out myself

**Q1 — How do I treat the now-stale 02:08 status report?**
It references `no-harm-edits` 25 times. Per the skill I just built, the options are: (a) inline correction at the top (`> Renamed to update-old-docs at 02:28`), (b) rename the file + add a resolution appendix, (c) leave it as a pure point-in-time snapshot (status reports are historical by nature). My instinct is (a) — minimal, honest, non-destructive — but you may prefer (c) on the grounds that status reports are frozen artifacts. Which?

**Q2 — Backlink scope: 3 siblings or 5?**
`full-code-review`, `naming-review`, `deduplicate-code` clearly mutate many files and should defer to `update-old-docs`. `brutal-self-review` and `code-quality-scan` touch many files but are more scan-than-edit. Add backlinks from all 5 (max safety, risk of over-linking), or only the 3 that genuinely produce batch edits?

**Q3 — The AGENTS.md count: hardcode `20`, or pointer to `check-skills.sh`?**
D1's fix has two forms. Principled (matches the docs-health rule _"never hardcode counts"_): replace `(18 total)` with `(run scripts/check-skills.sh for the current count)`. Pragmatic (scannable for humans): hardcode `20` and accept it rots again. The principled fix is what the skill I just built would demand. But AGENTS.md is read by humans who want a quick number. Which do you want — and should the same choice apply to README's "20 skills"?

---

## Summary

**Rename + re-scope: DONE and clean.** `update-old-docs` has a sharp, non-overlapping mandate (historical docs → annotate; vs docs-health's living docs → rewrite). All 20 skills pass structural checks; no stray old-name references in tracked content.

**Biggest failure: D1 (again).** AGENTS.md still says "18 total" two status reports running. This is now a process embarrassment, not just a content bug. Fix it before anything else.

**New failure this turn: D2.** I created a stale document (the 02:08 report) while building a skill about not leaving stale documents. Apply the skill's own guidance to it.

**Awaiting instructions** on Q1–Q3 before final wiring + commit.
