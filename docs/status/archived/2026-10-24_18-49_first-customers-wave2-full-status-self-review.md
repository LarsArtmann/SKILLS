# 2026-10-24 18:49 — first-customers wave 2: Full Status + Self-Review

Scope: THIS session only (17:30–18:49), continuing the arc from
`2026-10-24_17-28_first-customers-session-full-status-self-review.md` (whose
22-task list and 3 open questions gated this work). Format: .md at explicit
user demand (overrides the status-report skill's HTML-canonical default —
flagged, not propagated).

## Self-review answers (up front, brutally honest)

**What did you forget?**

- I created a **mini split brain this session and shipped it**: new
  `references/cold-outreach.md` while `channels-and-launch.md` kept its own
  cold-outreach summary — two places teaching the same channel. Caught it
  only during THIS report's self-review, fixed on sight (summary → pointer,
  gate re-run green). The teardown mode and waitlist-emails had their
  boundaries drawn at authoring time; cold-outreach didn't. That
  inconsistency is the tell: boundary-drawing was per-file habit, not a
  checklist step.
- I never exercised the NEW teardown mode even in degraded self-run mode
  (skill-creator's no-subagent fallback). I shipped a new procedure having
  validated only its structure, not its behavior.
- TODO_LIST.md was not updated from session report #1's next-tasks; both
  reports defer to HARVEST. Deferral is doctrinally correct, but the second
  consecutive deferral means the routing debt is compounding.

**What could you have done better?**

- The aggregation-repo commit: I ran `git commit` in an unfamiliar repo
  without checking the checked-out branch first. It landed on a stale
  stash-WIP branch and required surgery (temp worktree → cherry-pick to
  master → mixed reset of the WIP branch). The fix is verified clean, but
  the mistake created real risk for zero reason. `git branch --show-current`
  costs one call.
- My first AGENTS.md edit failed because I trusted the line-wrapped
  rendering in my context over the actual file (the paragraph is one long
  line on disk). Cost: one round trip. Lesson reinforced: view the exact
  region before editing long paragraphs.
- One hook-blocked `rg` call (the rg-replace guard's third strike on this
  host per its own message). I did not repeat the mistake but I did make it.
- The third research retry added no information over the second — two 429s
  spaced ~15 min apart already characterized a subscription-level cap. The
  third was hope, not method.

**What could you still improve?**

- Close the empirical gap: the skill now has staged evals but ZERO runs in
  any environment; every quality claim about it remains reasoned, not
  measured.
- Make "boundary-or-pointer" an explicit step when adding any reference to
  an existing skill (the de-dupe I did retroactively should have been a
  writing-time check).

**Did you lie?** No. Every number in this report is from a command output or
file in this session. The one soft spot, labeled as such: "the fix is
verified clean" refers to the four checks I ran (branch tips, worktree list,
symlink state, status) — not an independent audit.

---

## a) FULLY DONE (verified this session)

| #  | Item                                                                                                                                                         | Verification                                                   |
| -- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| 1  | PH "downranks non-launchable pages" unsourced claim deleted                                                                                                  | channels-and-launch.md, gate green                             |
| 2  | ProductLed benchmarks date-stamped 2022 in all 3 citing files                                                                                                | metrics-and-payments.md, offer-and-pricing.md, SKILL.md Step 7 |
| 3  | A/B floor replaced with arithmetic (~10k visitors/variant, 20% lift on 4% baseline) + Evan Miller source                                                     | metrics-and-payments.md + SKILL.md Step 8                      |
| 4  | Refund-rate claim relabeled explicit heuristic (no public dataset; track your own)                                                                           | proof-and-trust.md                                             |
| 5  | Lemon Squeezy **5% + 50¢/txn** verified LIVE from lemonsqueezy.com/pricing (2026-10) and pinned; Paddle URL pinned without inventing its number              | metrics-and-payments.md fee table + sources                    |
| 6  | `references/worked-example.md` (175 lines) — fictional StatusHawk through all 8 steps, deliverables checklist, invented numbers labeled                      | file + gate                                                    |
| 7  | `references/cold-outreach.md` (80) — 50-prospect cap, anatomy, 3-touch sequence, compliance floor                                                            | file + gate                                                    |
| 8  | `references/waitlist-emails.md` (90) — 6-email sequence, skeleton, labeled heuristics, boundary vs activation.md                                             | file + gate                                                    |
| 9  | `assets/launch-checklist.md` (58) T-14→T+7                                                                                                                   | file + gate                                                    |
| 10 | `assets/copy-brief.md` (60) strategy→copywriting handoff with empty-field gate                                                                               | file + gate                                                    |
| 11 | SKILL.md "Mode: page teardown" + all new files wired (steps 4/6, intro); 166 lines                                                                           | file + gate                                                    |
| 12 | Demo-video hook == headline alignment note (website-launch cross-check: no split brain found)                                                                | SKILL.md Step 4                                                |
| 13 | Cold-outreach + waitlist split brains de-duped (channels-and-launch.md now points; done during this report)                                                  | edit + gate exit 0                                             |
| 14 | README + FEATURES rows updated (11 refs + 2 assets, teardown, worked example)                                                                                | files                                                          |
| 15 | CHANGELOG "Changed (2026-10-24 — depth + verify-hygiene wave 2)" entry                                                                                       | CHANGELOG.md                                                   |
| 16 | AGENTS §5.5 paragraph extended (wave-2 inventory, ProductLed 2022, LS fee verification)                                                                      | AGENTS.md                                                      |
| 17 | ROADMAP Theme 8: Growth & Sales category decision = deferred until 2nd GTM skill requested twice                                                             | ROADMAP.md                                                     |
| 18 | external-dependencies.md checked: no entries needed (no CLIs referenced)                                                                                     | inspection                                                     |
| 19 | `evals/evals.json` — 3 prompts (diagnosis / greenfield / teardown), skill-creator schema                                                                     | file                                                           |
| 20 | `evals/trigger-eval.json` — 20 queries, 10/10 split, 6 copywriting-collision negatives + near-misses                                                         | file                                                           |
| 21 | skill-creator `quick_validate.py` on first-customers: **valid**                                                                                              | command output                                                 |
| 22 | Aggregation repo: first-customers symlink committed to **master** (990f493), WIP branch restored, stash + third-party churn untouched, temp worktree removed | branch tips, worktree list, status                             |
| 23 | Gates: check-skills exit 0 (×4 runs), triggers STRONG 21 markers/804 chars, signal filler=0 jargon=0 (10 prose advisories reviewed + kept with rationale)    | command outputs                                                |
| 24 | Session report #1 written (17-57); this is #2                                                                                                                | files                                                          |

## b) PARTIALLY DONE

| Item                                        | Done                                                          | Missing                                                                                       |
| ------------------------------------------- | ------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Research hardening of offer/pricing + proof | All claims sourced/deleted/dated/arithmetic/labeled           | Paddle fee number, Stripe Managed Payments fees, refund-rate source — quota-blocked (see d3)  |
| Trigger-eval set                            | 20 queries written, collision cases included                  | User review (skill-creator step 2), optimization loop runs                                    |
| Eval suite                                  | evals.json staged, structural validation passed               | with-skill/baseline runs + assertions (skill-creator steps 1-3)                               |
| Session-end obligations                     | check-skills, worktree, status reports, symlink commit        | TODO_LIST.md harvest routing (correctly deferred to docs-health, second consecutive deferral) |
| 🆕→🟢 aging criterion                       | Criterion defined and respected (not aged without a real run) | The real run itself                                                                           |

## c) NOT STARTED

- Execution of evals.json / trigger-eval.json in ANY environment.
- Assertions for the 3 evals (drafted during runs per skill-creator).
- A worked teardown example (the mode has no worked instance).
- First REAL product run through the skill (the aging gate).
- Paddle / Stripe Managed Payments fee verification.
- docs-health HARVEST over reports 17-28, 17-57, and this one.
- Push of agent-skills master (local commit only; never push unasked).
- Cleanup decision for aggregation repo WIP branch + stash@{0} + third-party churn.

## d) TOTALLY FUCKED UP (all caught and remediated this session)

1. **Aggregation-repo commit on the wrong branch** — committed without
   checking the branch; landed on stale `docs-health-verify-legs`. Remediated
   via temp-worktree cherry-pick to master + mixed reset; verified (branch
   tips, worktree list, symlink state). Root cause: skipped the 1-call
   pre-commit check in an unfamiliar repo.
2. **Cold-outreach split brain shipped** (caught in this self-review, fixed
   above). Root cause: no boundary-or-pointer step in my writing loop.
3. **3× agentic_fetch, all 429, third retry pointless** — synthetic.new
   subscription-level cap; the retry pattern was hope-shaped after the 2nd
   identical failure. No unverified number shipped as a result, so damage is
   ~zero, but the process was sloppy.
4. **AGENTS.md edit #1 failed** — trusted wrapped context rendering over the
   actual single-line file. One wasted round trip.
5. **One hook-blocked rg call** (rg-replace guard). Known trap on this host.

## e) WHAT WE SHOULD IMPROVE

- **Empirical validation is the whole remaining gap.** The skill is now
  structurally excellent and behaviorally untested. Until evals + a real run
  happen, "superb" is a reasoned claim.
- **Add "boundary-or-pointer" to my reference-writing loop** — when a new
  reference subsumes an existing summary section, convert the summary to a
  pointer at authoring time. Candidate for how-to-write-skills.md Principle
  additions.
- **Pre-commit branch check in any repo that isn't the session's primary** —
  one `git branch --show-current`, always.
- **Research-quota policy:** after 2 identical 429s, stop retrying; queue the
  questions and close gaps with raw fetches or honest labels (that's what
  saved this session — the quota never blocked a shipped claim).
- **HARVEST debt:** three unharvested reports now queue (17-28, 17-57, this).
  Route soon or the (f) lists start contradicting each other.
- **Degraded self-runs are cheap:** even without subagents, running one eval
  prompt through the skill manually would have exercised the teardown mode I
  invented this session. Do this before shipping new modes next time.
- **status-report skill standing exception may need widening:** this is now
  the 4th+ interactive (non-dispatch) .md report at explicit path demand; the
  skill's exception list only covers task-queue dispatches. Consider amending
  (needs user confirmation of standing preference).

## f) Next tasks (50, impact-sorted; 1–5 are the Pareto core)

1. **Pick the first real product and run first-customers on it live** (🆕→🟢 gate, only true validation)
2. Execute evals.json with-skill vs baseline in an exec-capable session (Claude Code / Cowork)
3. Run the trigger optimization loop on trigger-eval.json (needs `claude` CLI)
4. User-review the 20-query trigger set (skill-creator HTML review flow)
5. Run docs-health HARVEST over reports 17-28 + 17-57 + this one (dedupe overlapping (f) lists)
6. Write assertions for the 3 eval prompts (during runs)
7. Worked teardown example (before/after fix list for a sample page)
8. Degraded self-run of eval 1 (diagnosis case) even before subagent access
9. Pin Paddle's per-transaction fee when research quota returns
10. Pin Stripe Managed Payments fees + availability
11. Find a real refund-rate source or keep the heuristic label permanently
12. Re-verify Lemon Squeezy pricing at next vendor touch (drifts quarterly)
13. Second worked example: B2B cold-outreach path (no audience, no community)
14. copy-brief.md filled-in instance (worked-example's StatusHawk brief)
15. Assets: phrase-bank harvest template (3-bucket table with dork list)
16. Assets: objection→FAQ worksheet
17. Sales-page accessibility notes (contrast, alt text — CXL evidence exists)
18. Core Web Vitals specifics in the speed evidence block
19. Verify directory list freshness (Uneed, BetaList, SaaSHub, AlternativeTo)
20. Date-stamp the Show HN verbatim fetch (fetched 2026-10-24) in the reference
21. Label or source PH launch-timing mechanics (early PT etc.)
22. worked-example: add "what a teardown of the first page would find" bridge section
23. Privacy/terms/GDPR mini-reference for 0→1 pages (analytics consent)
24. Decide scope: post-trial win-back at 0→1 — in skill or explicitly out?
25. Decide scope: scaling-beyond-first-10 handoff — write the boundary sentence
26. Blind-compare worked-example-guided output vs baseline (comparator.md flow)
27. Fresh-session smoke test: "nobody signs up to my SaaS" triggers first-customers over copywriting
28. Reconcile report 17-28's 22-task list against what this session completed (ANNOTATE)
29. Route this report's (f) 1–5 into TODO_LIST.md (part of HARVEST)
30. Commit-or-discard decision: aggregation repo third-party churn (pre-existing)
31. Decide fate of aggregation repo WIP branch + stash@{0} (pre-existing, user's call)
32. Push agent-skills master? (only on explicit user request)
33. Install shellcheck (gate advisory currently bash -n only)
34. Consider `--signal`/`--triggers` coverage for new asset/eval file types (check-skills coverage audit)
35. naming-review description WARN (§3.1 'Use...' alignment — pre-existing)
36. website-launch 835-line trim (pre-existing allowlisted, TODO T11)
37. Amend how-to-write-skills.md: boundary-or-pointer principle (from e)
38. Amend status-report skill exception list for interactive .md reports (needs user confirm)
39. Investigate synthetic.new quota exhaustion (billing/upgrade decision)
40. capture "quota policy" lesson into crush-config lessons.md (commit there, not in-session write)
41. capture rg-guard lesson (third strike) likewise
42. Track first-customers description length on future edits (804/1024 now)
43. cold-outreach.md: add one real reply-rate data point once a real run exists
44. waitlist-emails.md: replace heuristic open-rate band with first real list's numbers
45. Update FEATURES row when eval runs exist (empirical evidence column)
46. Consider founding-member pricing legality note per jurisdiction (consumer law)
47. Add worked example cross-link from README row? (probably not — README stays lean; decide)
48. Survey SKILL.md allowed-tools list against actual tools used (fetch/bash/view/edit/write/grep — present)
49. Weekly re-run of check-skills during any multi-session skill work (habit)
50. After the first real run: full retro report + 🆕→🟢 aging with evidence links

## g) Questions I cannot answer myself

1. **Which real product gets the first live run?** The skill's aging gate
   (🆕→🟢) needs a real LarsArtmann (micro-)SaaS pushed through the loop —
   only you know what you want to sell next and whether any current project
   fits (e.g., something in the monitor365 orbit, or a fresh idea).
2. **Push agent-skills master to GitHub?** The first-customers symlink commit
   (990f493) is local-only; I never push without an explicit request, and the
   remote also lacks 1d897b7-era… (no — 1d897b7 is the local tip's parent;
   the question stands): push now, or hold until the third-party churn is
   also committed?
3. **The aggregation repo's pre-existing mess:** stale WIP branch +
   stash@{0} + ~48 modified/deleted third-party files (hyperframes suite,
   uncommitted since before this session). Commit the churn, stash-drop,
   or leave frozen — your repo-hygiene call; it gates nothing functional.

— End of report. WAITING FOR INSTRUCTIONS.
