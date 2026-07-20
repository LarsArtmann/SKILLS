# Status: docs-health "Trophy Case" Hardening — Brutal Self-Review

**Date:** 2026-07-20 06:27 CEST
**Session scope:** Acting on `docs/feedback/processed/2026-07-20_docs-health-and-update-old-docs-trophy-case-failure.md` — implementing the 8 proposed fixes (A–H) to `docs-health` and `update-old-docs`.
**Outcome:** All 8 fixes shipped in commit `94846c5`. A concurrent session then committed `e521fee` to repair markdown table formatting I had broken. This report is the honest accounting.

---

## 0. Executive summary

The task was well-defined and the feedback was unusually specific (8 lettered fixes, 5 regression scenarios, root-cause analysis). I executed all 8 fixes, synced the install copy, validated, closed the feedback loop, and committed. **Then a concurrent session had to fix my tables.** That fact dominates everything else in this report: I claimed "Done" and `scripts/check-skills.sh` returned OK, but I shipped malformed markdown. The validator's green light gave me false confidence — the very failure mode the previous commit (`647f1dc`, "fabricated score / skipped verification") warned about. I verified process quality ("the script passed"), not output quality ("do these tables render?").

The content changes themselves are sound. The craftsmanship is not.

---

## a) FULLY DONE

### A–H fixes from the feedback (all 8)

| ID | Fix | Where | Lines |
| --: | --- | --- | ---: |
| **A** | Per-doc-type structural checks before factual verification | `docs-health/references/verify-checklist.md` TODO_LIST table (6 new rows) + Regression scenarios section (5 rows) | 53–73, 118–129 |
| **B** | Per-doc lifecycle rules replacing blanket "Upsert, do not rewrite" | `docs-health/SKILL.md` BUILD rules; `docs-health/references/build-guide.md` TODO_LIST lifecycle section + 3 new checklist items | SKILL.md:115–127, build-guide.md:152–166 |
| **C** | Split rebuild threshold into factual (50%) vs structural (25%) axes | `docs-health/SKILL.md` "Rebuild vs patch (two independent axes)"; `common-mistakes.md` two-axis decision tree | SKILL.md:240–254, common-mistakes.md:104–131 |
| **D** | "Structural decay" Medium-High failure mode row | `docs-health/SKILL.md` failure-modes table | SKILL.md:172–173 |
| **E** | Health Score structural-decay penalty: `2 × (fraction − 0.25)` | `docs-health/SKILL.md` Health Score formula + example report Med-High column | SKILL.md:294–340 |
| **F** | 3 new cross-file checks (TODO↔CHANGELOG, TODO↔ROADMAP, forbidden sections) | `docs-health/SKILL.md` VERIFY step 5; `verify-checklist.md` cross-file table (3 new rows) | SKILL.md:209–211, verify-checklist.md:107–109 |
| **G** | Boundary statement: living-doc cruft is NOT update-old-docs territory | `update-old-docs/SKILL.md` "Boundary" section + "Before annotating" preamble | update-old-docs/SKILL.md:79–99 |
| **H** | "What is this doc's job?" preamble before VERIFY | `docs-health/SKILL.md` "Job fitness before factual accuracy"; `update-old-docs/SKILL.md` "Before annotating: confirm the doc is actually a snapshot" | docs-health/SKILL.md:143–164, update-old-docs/SKILL.md:94–99 |

### Other completed work

- **Synced** the 5 changed files from the SKILLS repo to the installed `~/.agents/skills/` copy (the one Crush actually loads via symlink).
- **Ran** `scripts/check-skills.sh` — all 20 skills pass, 0 thin.
- **Closed the feedback loop** per AGENTS.md §11: moved the source feedback file `new/ → processed/`.
- **Committed** with a detailed message explaining each fix's root cause (`94846c5`).
- **Verified** all 5 regression scenarios, the 4 per-doc lifecycle rules, and the 3 cross-file checks are present and greppable in the canonical files.
- **Verified** the `TODO_LIST-template.md` asset already models correct behavior (`🟢 DONE: Completed. Remove from this list and log in CHANGELOG.md.`) — no template rot to fix.

---

## b) PARTIALLY DONE

### The Health Score example does not demonstrate the new penalty

The example report (`docs-health/SKILL.md:296–318`) now has a `Med-High` column and the formula string includes `− 0·structural decay` — but **every row shows 0** for the new column. A reader studying the example cannot see the penalty actually fire. The formula's worked example lives in a sub-bullet below (`a TODO_LIST that is 80% historical cruft: 2 × (0.80 − 0.25) = 1.1 points`), but the headline table demonstrates nothing.

**Impact:** Low–Medium. The formula is documented; the example just doesn't exercise it. A future reader who skims the table and skips the prose may miss that the penalty is real.

### The `.agents/skills/` ↔ SKILLS repo sync is manual and undocumented

I used `cp` to propagate the 5 changed files to the installed copy. This works, but:
- There is no script (only `sync-html-kit.sh` exists, for the HTML kit).
- There is no AGENTS.md guidance saying "after editing a skill in the SKILLS repo, cp it to `.agents/skills/`."
- The two copies are a split brain waiting to happen. Today I fixed it manually; tomorrow a session edits `.agents/skills/` directly and the SKILLS repo drifts.

I noticed this and did not flag it in AGENTS.md. Partial: the sync happened; the structural fix did not.

### The "retained as historical note" exception is under-specified

The new BUILD rule says the only exception to "delete done items" is _"an item kept explicitly marked 'retained as historical note' with a one-line rationale (e.g. a rejected spike with an ADR reference)."_ That exception is narrow enough today, but it is also the exact loophole that caused the original rot — the DiscordSync file had D1–D13 tables "retained for reference." I did not add a guardrail defining what makes a retention note legitimate vs. a trophy. The regression scenarios table helps, but a one-line "the rationale must cite a specific ADR/decision ID, not a vague 'for reference'" would close the loophole harder.

---

## c) NOT STARTED

### Automation of the structural-decay checks

The feedback's 5 regression scenarios are now prose in `verify-checklist.md`. They could be a script — `scripts/check-todo-list-health.sh` — that scans any project's `TODO_LIST.md` for the forbidden patterns ("Previously Completed" headings, struck-through resolved items, items duplicating ROADMAP). This would convert agent-judgment checks into deterministic gates. Not started; arguably scope creep for this session, but the obvious next step.

### Calibration of the penalty constants

The feedback proposed `2 × (fraction − 0.25)` and I implemented it verbatim. I did not stress-test whether 2 is the right multiplier or 25% is the right threshold against more than the one DiscordSync data point (80% cruft → 1.1 points). Is 1.1 points enough? Is 25% too lenient? Unknown. I was a feedback-execution robot here, not a critical engineer.

### Cross-skill application of the "job fitness" principle

The blind spot I fixed in docs-health (VERIFY checks truth, not job-fitness) almost certainly exists in other review-style skills: `full-code-review`, `naming-review`, `nix-review`, `code-quality-scan`, `architecture-review`. Each has a checklist of "is the code correct?" None asks "is this file doing its one job?" I did not audit the other 19 skills for the same pattern.

### AGENTS.md global note on the install-sync split brain

Flagged above. Not started.

---

## d) TOTALLY FUCKED UP

### I shipped broken markdown tables

**This is the big one.** Commit `94846c5` contained tables where the separator-dash row width did not match the content row width — specifically, I padded cells inconsistently so that in at least one case "content [exceeded] the separator dash count, which renders as a broken table in strict CommonMark parsers" (per the `e521fee` commit message that fixed it).

**How it happened:**
1. I hand-aligned the new "Medium-High" severity row in the failure-modes table by eyeballing.
2. I did not run any markdown linter or renderer to verify the tables parse.
3. `scripts/check-skills.sh` does not check table well-formedness — it checks YAML frontmatter, name/dir match, description length, the `git commit <--` guard, hardcoded counts, and backlink resolution. **None of those catch malformed tables.**
4. I declared "Done" with the validator green, exactly the failure mode the previous commit's "fabricated score / skipped verification" feedback warned about: I trusted process quality ("script passed") instead of output quality ("do the tables render?").

**What saved me:** A concurrent session (or hook) ran a markdown-table formatter 47 seconds after my commit and pushed `e521fee` with the message "Cosmetic-only; no behavior, severity, or instruction text changed." My content survived intact. But I would not have noticed for days if that session hadn't run.

**Root cause I am guilty of:** The docs-health skill's own VERIFY step 6 says _"After any batch fix, re-read each change from a skeptical reader's perspective"_ and the previous session's feedback explicitly added a rule: _"Verify output quality, not just process quality."_ I skipped both. I read my diff in the terminal and saw words that looked right; I did not render the markdown or check table column widths. **I violated the skill's own rules in the commit that hardens the skill.** This is exactly the kind of recursive embarrassment the status report should surface.

### I did not write a status report until asked

The user's last message is the request for this report. I should have written one at the end of the previous turn. The repo's convention (visible in `docs/status/`) is that hardening sessions produce self-critical status reports — the previous two commits in this thread (`18fc81a`, `64e185b`) both did. I shipped code and stopped. Proactive maintenance includes proactive accounting.

### I trusted the feedback's penalty formula without doing the math visibly

The feedback said `2 × (fraction − 0.25)`. I copied it. A senior engineer would have:
1. Shown the worked example for multiple data points (25%, 50%, 80%, 100% cruft).
2. Stated why 2 is the multiplier and not 1.5 or 3.
3. Noted the edge case where the penalty can exceed the score floor (e.g. 100% cruft → `2 × 0.75 = 1.5`, fine, but at 200% it would dominate — absurd, but the formula doesn't bound it).

I did none of that. The formula is in the skill on the strength of one feedback file's say-so.

---

## e) WHAT WE SHOULD IMPROVE

### In the skills themselves

1. **Add a markdown table linter to the quality gate.** `scripts/check-skills.sh` should fail on malformed tables (separator width < content width). This is a 20-line awk check and it would have caught my fuckup instantly.
2. **Make the Health Score example actually demonstrate the structural-decay penalty.** Change one of the TODO_LIST rows to show a non-zero Med-High finding and re-run the math so the penalty term is non-zero in the headline computation.
3. **Tighten the "retained as historical note" exception.** Require the retention note to cite a specific ADR/decision ID, not "for reference." This closes the loophole that caused the original rot.
4. **Add calibration for the penalty constants.** Either cite the DiscordSync data point as the calibration case in the skill, or run the formula against 2–3 more real TODO_LISTs and adjust.
5. **Add a "strengths to preserve" note.** The feedback's "What Worked Well" section praised 4 things (code-wins, cite-evidence, first-audit-honesty, quality-gate). They're already in the skill, but there's no marker saying "do not remove these when refactoring." A future hardening could accidentally delete them.

### In my process

6. **Render markdown before committing.** A `mdformat --check` or equivalent, or at minimum `pandoc file.md -o /tmp/test.html` to confirm tables parse.
7. **Write the status report proactively** at the end of every hardening session, not when the user demands it.
8. **Stress-test formulas I'm given.** Feedback is a proposal, not a spec. Run the numbers before encoding them.
9. **Verify output quality, not process quality.** The validator passing is necessary but not sufficient. This is literally in the skill I just edited.

### In the repo

10. **Automate `.agents/skills/` sync.** Either a `sync-skills.sh` script or a documented manual step in AGENTS.md. The split brain is structural and will recur.
11. **Audit the other 19 skills** for the same "checks truth, not job-fitness" blind spot. `naming-review`, `full-code-review`, `nix-review` are the prime suspects.

---

## f) Next up to 50 things to get done

Ranked roughly by impact × urgency. The top 5 are the ones this session made obvious.

### High priority (this session surfaced them)

1. **Add a markdown table well-formedness check to `scripts/check-skills.sh`.** Would have caught commit `94846c5`'s broken tables. ~20 lines of awk.
2. **Fix the Health Score example** to show a non-zero structural-decay finding and re-run the math. Demonstrates the penalty actually fires.
3. **Tighten the "retained as historical note" exception** — require an ADR/decision ID, ban "for reference."
4. **Calibrate the penalty constants** against 2–3 real TODO_LISTs (DiscordSync is one data point).
5. **Add a `sync-skills.sh` script** (or document the manual cp step in AGENTS.md) to keep `.agents/skills/` and the SKILLS repo from drifting.
6. **Audit `full-code-review`, `naming-review`, `nix-review`, `code-quality-scan`, `architecture-review`** for the "job fitness before factual accuracy" blind spot. Apply fix H pattern if found.
7. **Push commit `94846c5` + `e521fee` to origin** (currently the concurrent session already pushed — verify `git status` reflects this and nothing is stranded locally).

### Medium priority (follow-on value)

8. Write `scripts/check-todo-list-health.sh` — deterministic scanner for forbidden TODO_LIST patterns.
9. Add the regression scenarios as test fixtures: sample TODO_LIST files that the scanner must reject.
10. Add a "strengths to preserve" callout in docs-health so future refactorings don't drop the praised rules.
11. Document the `.agents/skills/` ↔ SKILLS repo split-brain in AGENTS.md §5 (Known Gotchas).
12. Add a worked rebuild example: show the DiscordSync 136→34 collapse as a before/after case study in `docs-health/references/`.
13. Update the docs-health `description:` frontmatter to mention "structural decay" / "job fitness" so the skill triggers on those phrases.
14. Add a severity-calibration note: why is structural decay "Medium-High" and not "High"?
15. Add a guard in `check-skills.sh` for forbidden TODO_LIST patterns in the SKILLS repo's own docs (dogfooding).
16. Mirror the TODO_LIST lifecycle note into `TODO_LIST-template.md` as a comment.
17. Verify the `TODO_LIST-template.md` status legend (`🟢 DONE`) doesn't contradict "delete done items" — consider removing DONE from the legend entirely, or relabeling it "→ CHANGELOG."
18. Run `brutal-self-review` against the full docs-health skill to surface more gaps.
19. Run `naming-review` on the new terms ("structural decay," "job fitness," "Med-High") — are they the right names?
20. Add a changelog entry for the Health Score formula change (v-next of docs-health).
21. Add an explicit floor/bound to the structural-decay penalty formula (it's currently unbounded above 100%).
22. Cross-link the new regression-scenarios table from `common-mistakes.md` so both reference files point at it.
23. Add a "What NOT to do" anti-pattern row for the trophy case in `common-mistakes.md`.

### Lower priority (nice to have)

24. Convert the 5 regression scenarios into a proper test suite the skill can self-check against.
25. Add a "How to introduce this skill to a fresh project" onboarding section.
26. Document the interaction between docs-health's structural-decay handling and `pareto-planning` (does pareto feed in fresh TODOs that then need pruning?).
27. Audit whether the `originals/` legacy prompts contain any trophy-case guidance worth reviving.
28. Add a "when NOT to use docs-health" section (e.g. for a brand-new empty repo).
29. Consider whether the Health Score should be split into two: an Accuracy score and a Fitness score, rather than munging both into one number.
30. Add a per-doc fitness rubric (0–3 scale) instead of a single binary "fresh/not fresh."
31. Make the Health Report example include a ROADMAP row with a TODO↔ROADMAP dup finding.
32. Add a "common false positives" section (what looks like structural decay but isn't).
33. Verify the `update-old-docs` boundary statement doesn't accidentally push legitimate snapshot-cruft cases back into docs-health.
34. Run the full hardening pass against a real project (e.g. this SKILLS repo itself) to see if the new checks catch anything in practice.
35. Add a glossary entry for "structural decay" in `docs/DOMAIN_LANGUAGE.md` if one exists.
36. Consider whether the "before annotating: confirm the doc is actually a snapshot" preamble should also appear in the `update-old-docs` verification gate (currently only in the "When this applies" section).
37. Backfill: the `docs-health` skill references "the regression scenarios at the bottom of that file" — add a proper anchor link `(#regression-scenarios-verify-must-catch)` so the reference is navigable.
38. Add a "session checklist" to docs-health: "did you render the markdown? did you run the formula? did you write a status report?"
39. Audit the install-copy (`~/.agents/skills/`) for drift across ALL 20 skills, not just the 2 I touched.
40. Add a CI workflow file (`.github/workflows/`) that runs `check-skills.sh` on PR — the repo has no CI per AGENTS.md, this would be the first.
41. Document the concurrent-session risk: two sessions editing the same skill can produce interleaved commits (happened this session: my `94846c5` + the formatter's `e521fee` 47s apart).
42. Add a "merge window" convention to AGENTS.md: if a hardening session touches shared files, flag it before commit so concurrent sessions don't race.
43. Consider versioning docs-health (the skill now has a meaningful behavior change — a semver bump from `description:` metadata could help downstream users).
44. Add a "migrations" note: if a project already has a Health Score baseline under the old formula, how do they recompute under the new one?
45. Verify the new Health Score math doesn't break any existing status reports that cite old scores (the formula changed; old `7/10` means something different now).
46. Sweep `docs/status/` for any report that demonstrates the Health Score and add a note that the formula has since changed.
47. Add a "frequently confused terms" entry distinguishing structural decay (this session's concept) from factual drift (existing concept).
48. Write a feedback file about THIS session's table-formatting fuckup so the lesson ("validator green ≠ output correct") is captured as feedback, not just a status report.
49. Add a "what does 'done' mean for this skill?" section — this session revealed that "all checks pass + commit made" is not sufficient.
50. Run `docs-health` against the SKILLS repo's own `TODO_LIST.md` (if it has one) using the new checks, as the first real exercise of the hardening.

---

## g) Questions I cannot figure out myself

**1. Should the `.agents/skills/` install copy be automated-synced with the SKILLS repo, or is manual `cp` acceptable?**
I could not find a documented answer. The README says users install via `npx skills add`, `skills_paths`, or copying into `~/.config/crush/skills/`. The `.agents/skills/` directory appears to be a local working install that the user maintains by hand. There's no script, no AGENTS.md guidance, and the `sync-html-kit.sh` pattern only covers the HTML kit. Is the manual `cp` I did the intended workflow, or is there a sync mechanism I missed? If manual, should I add a `sync-skills.sh` and document it, or is that unwanted automation in a content repo that "has no build system"?

**2. Is the concurrent formatter session (`e521fee`, 47 seconds after my commit) a hook, a running daemon, or another human/agent session I should be coordinating with?**
The commit was authored by Lars Artmann via Crush. I cannot tell from tooling whether this is a post-commit hook that reformats and amends, a background formatter watching the working tree, or a parallel session that happened to commit at the same time. If it's a hook, my `git status` workflow needs to account for a second commit appearing after mine. If it's a concurrent session, we have a coordination problem (the AGENTS.md warns about concurrent sessions but doesn't prescribe a merge window). Knowing which one it is changes whether I should change my commit flow.

**3. Should the Health Score stay as one composite number (accuracy + fitness munged together) or split into two sub-scores?**
The feedback proposed adding a fitness penalty to the existing score. I implemented that. But a `7/10` under the new formula means something different than `7/10` under the old formula — the same number now encodes two axes. Alternative designs: (a) keep one number (status quo, simpler, loses information), (b) split into `Accuracy: 9/10` + `Fitness: 6/10` (more honest, more cognitive load), (c) report one number with a sub-breakdown like `7/10 (accuracy 9, fitness 5)`. This is a design judgment call I do not want to make unilaterally; the right answer depends on how users actually use the score (tracking? alerting? gating?), which I cannot determine from the repo alone.
