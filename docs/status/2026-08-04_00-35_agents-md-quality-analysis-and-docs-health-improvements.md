# Status Report: AGENTS.md Quality Analysis & docs-health Skill Improvements

> **Date:** 2026-08-04 00:35
> **Session scope:** Rate all AGENTS.md files; improve docs-health skill so agents create better AGENTS.md
> **Status:** Core improvements done, several gaps identified

---

## What triggered this session

The user asked to: (1) view all `~/projects/*/AGENTS.md` files, (2) rate them all, (3) improve the docs-health skill so agents produce BETTER AGENTS.md files in their own projects.

---

## a) FULLY DONE

### 1. Comprehensive rating of all 153 AGENTS.md files

Every `AGENTS.md` file across 153 projects was analyzed via automated metrics (size, anti-pattern counts for changelog/TODO/status/commit-hash/dated-content) and graded A–F.

**Distribution:**

| Grade | Count | Profile                                             |
| ----- | ----- | --------------------------------------------------- |
| A     | 80    | Clean, lean (5–14 KB), minimal anti-patterns        |
| B     | 42    | Good, minor issues or slightly large                |
| C     | 15    | Significant anti-patterns or bloated                |
| D     | 10    | Heavy temporal pollution or severe bloat (42–93 KB) |
| F     | 6     | Skeleton (<1 KB) or absurdly bloated (>100 KB)      |

**Top 5 worst offenders:**

| Project                        | Size   | Anti-patterns | Primary issue                                           |
| ------------------------------ | ------ | ------------- | ------------------------------------------------------- |
| SystemNix                      | 430 KB | 97            | 62 changelog refs, 27 commit hashes, incident graveyard |
| DiscordSync                    | 148 KB | 56            | Feature docs as gotchas, version-bump histories         |
| go-cqrs-lite                   | 107 KB | 16            | 891-line code cookbook (76% of file)                    |
| projects-management-automation | 73 KB  | 62            | 56 sprint-dated changelog entries                       |
| branching-flow                 | 42 KB  | 53            | 50 sprint-dated refactoring entries in gotchas          |

### 2. Five-tier anti-pattern catalog discovered

From deep manual analysis of ~25 files across all quality tiers:

1. **Content misplacement** — changelogs, TODOs, feature status in AGENTS.md (belongs in CHANGELOG/TODO_LIST/FEATURES)
2. **Temporal pollution** — dated headings `(added 2026-07-05)`, commit hashes `abc123`, sprint numbers `(Sprint 52)`, "was X, now Y"
3. **Implementation duplication** — 891-line code cookbooks, 37-row config field tables, 95-line directory trees
4. **Structural decay** — 100+ undifferentiated bullets, 80+ row gotchas tables, feature docs disguised as gotchas
5. **Scope creep** — Firebase/DNS ops state in Go library repos, external tool bug reports

### 3. New reference file: `agents-quality-guide.md` (365 lines)

The centerpiece deliverable. Agents load this when building or verifying AGENTS.md:

- Size budget table (< 1 KB skeleton → > 100 KB broken)
- Full 5-tier anti-pattern catalog with **real examples from the analysis** (not invented)
- **The endurance test:** "Will this be true 6 months from now?"
- Quality scoring rubric (5 dimensions, A–F grades)
- 7-step pruning guide with grep commands for finding temporal pollution
- Good vs bad before/after example (go-retry, clean vs bloated)

### 4. Enhanced existing docs-health files (5 files)

| File                             | What changed                                                                                                                                                                             |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `SKILL.md`                       | Added "AGENTS.md quality" section under BUILD rules; removed duplicate "Determine the task" table (was redundant with Quick start table); held at exactly 500 lines                      |
| `assets/AGENTS-template.md`      | Added inline size budget, endurance test warnings, anti-pattern guardrails; added Architecture + Dependencies sections to template; expanded builder comments from 5 to 8 "do NOT" items |
| `references/build-guide.md`      | Expanded AGENTS.md section: added size budget, endurance test, expanded quality checklist from 5 to 10 items, cross-ref to new guide                                                     |
| `references/verify-checklist.md` | Expanded AGENTS.md checks from 6 to 14: added size, temporal pollution grep, commit hash check, code dump check, endurance test, gotchas table cap                                       |
| `references/common-mistakes.md`  | Expanded AGENTS.md mistakes table from 4 to 15 entries; added endurance test decision tree                                                                                               |

### 5. Synced to both copies

- `~/.config/crush/skills/docs-health/` — installed/active copy (what Crush loads)
- `~/projects/SKILLS/docs-health/` — canonical repo source (what gets installed via `skills add`)

### 6. Validation passes

`scripts/check-skills.sh` — all 25 skills pass structural checks. SKILL.md at 500/500 line limit. All cross-references resolve.

---

## b) PARTIALLY DONE

### 1. The rating is automated-metric-based, not fully manual-verified

The 153-file rating used automated grep-based heuristics (size + anti-pattern counts). This is good enough for a distribution picture and identifying worst offenders, but individual file grades may be off:

- A file with many commit hashes that are all in legitimate code examples would score worse than it should.
- A file with zero anti-pattern markers but no commands section and no gotchas would score "A" despite being thin.
- **~25 files were manually deep-read** for the qualitative analysis. The rest are heuristic-graded.

**Impact on the work:** The qualitative findings (5-tier anti-pattern catalog) are from manual deep reads and are solid. The per-file grades are approximate.

### 2. The new `agents-quality-guide.md` references "real examples from the wild" but anonymizes them

The examples in the anti-pattern catalog say things like "891 lines of commented Go code" without naming go-cqrs-lite. This is intentional (the guide should be project-agnostic) but means an agent can't look up the actual bad file to learn from. The guide is self-contained with its own before/after examples, so this is a style choice, not a gap.

### 3. AGENTS-template.md improved but not tested with a real rebuild

The template now has inline anti-pattern warnings and expanded guidance, but no agent has actually used it to build a fresh AGENTS.md yet. The template might have too much instructional comment noise (the HTML comments are now quite long).

---

## c) NOT STARTED

### 1. Actually fixing any of the 153 AGENTS.md files

The task was to rate and improve the skill — not to fix the individual files. But the worst offenders (SystemNix at 430 KB, DiscordSync at 148 KB, go-cqrs-lite at 107 KB) are severe and remain untouched. The improvements to docs-health will help future BUILD/VERIFY cycles catch these, but nothing retroactively fixes them.

### 2. Adding an automated linting script for AGENTS.md quality

The `agents-quality-guide.md` includes grep commands for finding temporal pollution, but there is no standalone script (like `scripts/check-skills.sh`) that an agent or CI could run to score AGENTS.md files. The grep patterns are documented but not packaged.

### 3. Updating the global `~/.config/crush/AGENTS.md` (Parakletos)

The global AGENTS.md has a "Project Documentation Files" table and several "anti-patterns" sections about AGENTS.md content. The new findings (5-tier anti-pattern catalog, size budget, endurance test) are not reflected there. The global file is the one every project session loads — it would be the highest-leverage place to add a 3-line summary pointing at the new quality guide.

### 4. Updating `how-to-write-skills.md`

The repo's authoritative skill-writing guide at root does not mention the new `agents-quality-guide.md` or the AGENTS.md quality findings.

### 5. Updating README.md skills inventory

The README may not reflect that docs-health now has a 6th reference file (`agents-quality-guide.md`). Not verified.

---

## d) TOTALLY FUCKED UP / MISTAKES MADE

### 1. First glob attempt used a relative path incorrectly

The initial `glob` call for `~/projects/*/AGENTS.md` failed because the tool resolved it as `/home/lars/projects/SKILLS/home/lars/projects`. Had to fall back to `ls` in bash. Minor, self-corrected immediately.

### 2. The first automated analysis script output was garbled

The first bash analysis script (with grep `-l` flags combined with `-c` and `|| echo "0"` fallbacks) produced misaligned pipe-delimited output that was unreadable. Had to rewrite with a clean script. Time wasted: ~1 round trip.

### 3. Did NOT read the existing `health-report-format.md` before designing the quality rubric

The new `agents-quality-guide.md` introduces its own 5-dimension scoring rubric (Content ownership 30%, Endurance 25%, Leanness 20%, Completeness 15%, Structure 10%). The existing `health-report-format.md` already has a 2-score system (Accuracy + Fitness) with specific formulas. These two scoring systems are **not integrated** — a future AUDIT run might produce conflicting scores for AGENTS.md (Accuracy/Fitness from the health report, plus the 5-dimension rubric from the quality guide). This is a split brain that should be reconciled.

### 4. Removed the "Determine the task" section from SKILL.md to hit 500 lines

This was the quickest way to stay under the limit, but that section had slightly different content than the "Quick start" table — it used verb-based triggers ("Build TODO list") vs situation-based triggers ("You just wrote a status-report"). The situation-based table in Quick start is arguably better, but the removal was a shortcut, not a principled restructuring. The information loss is minimal but the decision was convenience-driven.

### 5. Did NOT verify the new guide renders correctly in an actual agent session

The guide is markdown with tables, code blocks, and cross-references. It was validated structurally (files exist, links resolve) but no agent has actually loaded it via `view` during a real BUILD or VERIFY task. There could be formatting issues, table rendering problems, or unclear instructions that only surface in practice.

---

## e) WHAT WE SHOULD IMPROVE

### High priority

1. **Reconcile the two scoring systems.** The `health-report-format.md` (Accuracy + Fitness, 2 scores) and the new `agents-quality-guide.md` (5-dimension rubric) need to be unified into one system. Either the 5 dimensions feed into Accuracy/Fitness, or the quality guide's rubric is reframed as a sub-scoring within Fitness.

2. **Create a `scripts/check-agents-md.sh` linting script.** Package the temporal-pollution grep patterns into a standalone script that scores any AGENTS.md file and outputs a grade. This would let agents and CI catch anti-patterns automatically, not just when docs-health is explicitly invoked.

3. **Add a 3-line quality summary to the global AGENTS.md.** The global `~/.config/crush/AGENTS.md` is loaded by every project session. Adding a brief pointer to the endurance test and size budget there would be the highest-leverage change — every agent would see it without loading the skill.

4. **Actually fix the worst offenders.** SystemNix (430 KB), DiscordSync (148 KB), and go-cqrs-lite (107 KB) are actively harmful — they waste massive context budget on stale content. A targeted pruning session on just these 3 files would demonstrate the new guide's value.

5. **Test the improved template end-to-end.** Have an agent build a fresh AGENTS.md using the updated template and quality guide for a real project, then verify the output passes the new verify-checklist.

### Medium priority

6. **Add "when this is stale" self-awareness to AGENTS.md template.** None of the 150+ files acknowledge they can become stale or point to a more authoritative source. A footer note like "If commands fail or paths 404, this file is stale — re-run docs-health VERIFY" would help.

7. **Create a "before/after" case study.** Pick one bloated file (e.g., branching-flow), apply the 7-step pruning guide, and document the before/after as a worked example in the quality guide.

8. **Address the duplicate AGENTS.md problem.** Two projects (discordsync and DiscordSync) have near-identical 148-152 KB files. This is either a case-sensitivity issue or a fork that diverged. The skill should have guidance for this scenario.

9. **Expand the quality guide with project-type-specific advice.** The current guide is generic. Library repos vs NixOS configs vs web apps have different AGENTS.md needs. The docs-health skill already has a "project type" table — the quality guide should reference it.

10. **Consider a "living vs frozen" marker for AGENTS.md.** The skill should clarify that AGENTS.md is a LIVING doc (rewritten in place), not a historical artifact. Some files seem to have been treated as append-only logs.

---

## f) Up to 50 things we should get done next

### Fixing existing files (highest impact)

1. Prune SystemNix/AGENTS.md (430 KB → target < 30 KB): strip 60+ resolved incidents, 27 commit hashes, sprint-dated entries
2. Prune DiscordSync/AGENTS.md (148 KB → target < 30 KB): remove feature-docs-disguised-as-gotchas, version-bump histories
3. Prune discordsync/AGENTS.md (144 KB): likely duplicate of DiscordSync — merge or delete one
4. Prune go-cqrs-lite/AGENTS.md (107 KB → target < 30 KB): extract 891-line code cookbook to references/
5. Prune projects-management-automation/AGENTS.md (73 KB, 56 changelog refs): strip sprint-dated entries
6. Prune BuildFlow/AGENTS.md (75 KB): strip 22 anti-pattern entries, 7 commit hashes
7. Prune branching-flow/AGENTS.md (42 KB, 50 changelog refs): gut the gotchas refactoring graveyard
8. Prune monitor365/AGENTS.md (93 KB): strip changelog and temporal pollution
9. Prune bank-sync/AGENTS.md (71 KB): remove migration history, deleted-code references
10. Prune emeet-pixyd/AGENTS.md (74 KB): strip implementation detail overload
11. Audit the 15 C-grade files for specific anti-pattern fixes
12. Audit the 10 D-grade files — all need major rewrites
13. Fix the skeleton file: chats/AGENTS.md (8 lines, 312 bytes) — add real content
14. Fix go-output/AGENTS.md (45 KB): strip version-pinned migration notes, keep the excellent invariants
15. Fix segment-buffer/AGENTS.md (39 KB): strip 15 anti-pattern entries
16. Fix go-workflow-auditlog/AGENTS.md (47 KB): strip 15 anti-pattern entries

### Skill improvements

17. Reconcile the 5-dimension rubric in agents-quality-guide.md with the 2-score system in health-report-format.md
18. Create `scripts/check-agents-md.sh` — standalone linting script for AGENTS.md quality
19. Add a 3-line quality summary + endurance test pointer to the global `~/.config/crush/AGENTS.md`
20. Test the updated AGENTS-template.md by building a real AGENTS.md from it
21. Add a "when this is stale" footer to the AGENTS-template.md
22. Create a worked before/after pruning case study in agents-quality-guide.md
23. Add project-type-specific AGENTS.md advice (library vs NixOS vs web app)
24. Add guidance for the "duplicate AGENTS.md across case-variant dirs" problem
25. Add a "living doc, not append-only log" clarification to the quality guide
26. Consider adding a `allowed-tools:` frontmatter field to docs-health for `wc`, `grep`

### Global config / cross-cutting

27. Update the global AGENTS.md "Project Documentation Files" table to mention the quality guide
28. Update `how-to-write-skills.md` to cross-reference the new agents-quality-guide
29. Verify README.md skills inventory reflects the new reference file
30. Add the docs-health skill's reference file count to the SKILLS repo AGENTS.md
31. Consider whether the endurance test should be a global rule (all skills) not just docs-health

### Deepening the analysis

32. Manually verify the automated grades for all 80 A-grade files (sample 10 to validate the heuristic)
33. Manually verify the automated grades for all 42 B-grade files (sample 10 to validate the heuristic)
34. Check whether any A-grade files are false positives (clean metrics but actually useless)
35. Check whether any C/D/F-grade files have redeeming qualities the metrics missed
36. Analyze whether Go library projects systematically have better AGENTS.md than web apps
37. Analyze whether project age correlates with AGENTS.md bloat (older = more accumulated cruft)
38. Map which projects have NO AGENTS.md at all (some projects in ~/projects/ may lack one)
39. Check if the `template-*` projects have appropriate AGENTS.md for their purpose

### Verification & quality assurance

40. Have a second agent independently verify the 5-tier anti-pattern catalog against a fresh sample
41. Verify the grep patterns in the pruning guide actually catch what they claim
42. Run docs-health AUDIT on the SKILLS repo itself using the new AGENTS.md quality checks
43. Verify the new verify-checklist items are actually enforceable (not aspirational)
44. Check that no other skills reference the old "Determine the task" section that was removed from SKILL.md
45. Ensure the agents-quality-guide.md is under 400 lines (currently 365 — check after any additions)
46. Verify that the updated template doesn't break any existing skills that reference AGENTS-template.md
47. Run the full check-skills.sh after any further changes to confirm structural integrity

### Documentation

48. Write a CHANGELOG entry for the docs-health skill improvements
49. Update FEATURES.md if the SKILLS repo has one to reflect the new capability
50. Consider writing a blog post or guide on "How to write great AGENTS.md" based on the findings

---

## g) Questions I CANNOT figure out myself

### Question 1: Should the scoring systems be unified?

The existing `health-report-format.md` uses a **2-score system** (Accuracy + Fitness, with specific subtraction formulas). The new `agents-quality-guide.md` introduces a **5-dimension rubric** (Content ownership 30%, Endurance 25%, Leanness 20%, Completeness 15%, Structure 10%). These overlap but aren't integrated.

**Option A:** Replace the 5-dimension rubric with Accuracy/Fitness mappings (the 5 dimensions become sub-checks within Fitness).
**Option B:** Keep both — the 5-dimension rubric is for BUILD quality control, the 2-score system is for AUDIT reporting.
**Option C:** Unify into a new single system that serves both purposes.

I cannot determine which without understanding your preference for scoring complexity vs simplicity.

### Question 2: Should we retroactively fix the worst AGENTS.md files now, or only improve the skill?

SystemNix (430 KB), DiscordSync (148 KB), and go-cqrs-lite (107 KB) are actively wasting context budget. But fixing them is a large task per file (each needs careful pruning, not blanket deletion).

**Option A:** Fix the top 5 worst offenders in a follow-up session using the new pruning guide.
**Option B:** Only improve the skill and let future sessions naturally catch up via VERIFY.
**Option C:** Create the `check-agents-md.sh` linting script first so fixes are guided by automated detection.

### Question 3: The discordsync vs DiscordSync duplicate — is this intentional?

There are two directories: `~/projects/discordsync/` (147 KB AGENTS.md) and `~/projects/DiscordSync/` (151 KB AGENTS.md). Their AGENTS.md files are near-identical but not byte-identical (different sizes, slightly different anti-pattern counts). This is either:

- A case-sensitivity issue (the same project checked out twice)
- A fork that diverged
- An intentional rename that didn't clean up the old directory

I cannot determine which without context about these projects' history.

---

## Summary

The core task — rate all AGENTS.md files and improve docs-health to produce better ones — is **done**. The 5-tier anti-pattern catalog, the endurance test, the size budget, the pruning guide, and the expanded checklists are all in place and validated. The main gap is that the worst offenders remain unfixed and the two scoring systems need reconciliation.

---

## Resolution (2026-08-04 — docs-health HARVEST + living-docs build)

Forward-looking items harvested into `TODO_LIST.md` and `ROADMAP.md`.

### Still open (harvested into TODO_LIST)

| Report item                                             | TODO_LIST ID | Notes                                                              |
| ------------------------------------------------------- | ------------ | ------------------------------------------------------------------ |
| Reconcile 5-dimension rubric with 2-score system (e #1) | T8           | `agents-quality-guide.md` vs `health-report-format.md` split brain |
| Create `scripts/check-agents-md.sh` (e #2)              | T9           | Temporal-pollution grep patterns not yet packaged as a script      |

### Out of scope for this repo

Items 1–16 in section f (pruning SystemNix, DiscordSync, go-cqrs-lite, etc.)
target **other projects'** AGENTS.md files, not this repository. They are not
tracked here — they belong in those projects' own TODO lists, guided by the
`docs-health` skill and the `agents-quality-guide.md` reference this session
produced.

### Questions (g) — status

- **Q1 (scoring unification):** Unresolved — routed to TODO_LIST T8.
- **Q2 (retroactive fixes):** Out of scope for this repo (see above).
- **Q3 (discordsync duplicate):** Unresolved — requires project history context
  not available in this repo.
