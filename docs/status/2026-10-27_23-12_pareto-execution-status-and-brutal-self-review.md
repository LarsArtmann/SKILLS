# 2026-10-27 23:12 — Pareto execution: full status + brutal self-review

> Blended report: status a–g sections (user demand) over the brutal-self-review
> questions. Scope: THIS session only (22:00–23:12) — the pareto-plan execution
> session that followed the 21:56 plan. Format `.md` per the D.g4 default
> flipped this same session. Timestamps derived from `date` CLI and
> `git show -s --format=%ci`, not guessed (see d1 — that rule was learned the
> hard way 30 minutes ago).

## a) FULLY DONE (verified, exit codes / commits cited)

| #  | Item                                                                                                                                                          | Evidence                                                                     |
| -- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| 1  | **P1/T64 decision package**: 14/14 open decisions answered in one sitting, routed (ROADMAP closed-notes, TODO flips, CHANGELOG, backup trashed via `trash`)   | `docs/decisions/2026-10-27_open-decisions.md` verdicts table; commit 3b5af2e |
| 2  | **P2/T60 behavioral evals**: evals 1–2 × (with-skill + baseline) subagents; assertions graded                                                                 | `stack-selection-workspace/iteration-2/` (4 outputs + grading.json)          |
| 3  | **P3/T62 drift check**: `stack-drift-check.sh` (exit 0/1/2 contract), 4 fixtures pass, wired into SKILL done-bar + STACK template + full-code-review consumer | fixtures 0/1/1/2 exact; real-world run recorded (0/163 STACK.md)             |
| 4  | **P4/T61 trigger eval**: 20-query set + subagent matcher round → 20/20                                                                                        | `evals/trigger-eval.json`, `trigger-eval-results.json`                       |
| 5  | **P5/T63 aggregation commit**: symlink on master 4100313 via worktree; WIP branch untouched; worktree removed                                                 | `link-skills-to-agents.sh --check` EXIT 0                                    |
| 6  | **P6/T65 map re-verify**: `capability-map-diff.sh`; +13 rows, 0 stale, Known-gaps extended; map 55→68 rows                                                    | script output in session; cadence note in AGENTS §5.5                        |
| 7  | **T51/P10 glosses VERBATIM**: 6 skills aligned to the house-jargon table; residual grep zero                                                                  | `--signal` EXIT 0                                                            |
| 8  | **T34/P11 linter direction**: Go-first note, two-stage-aging legend, commit-ownership rule                                                                    | linter-building SKILL.md, FEATURES, AGENTS §7                                |
| 9  | **P14 status-report default `.md`**                                                                                                                           | status-report/SKILL.md + FEATURES + README rows                              |
| 10 | **T66 pre-commit link guard**                                                                                                                                 | `.git/hooks/pre-commit` runs green                                           |
| 11 | Gates all green at close: struct 0, triggers 0, signal 0, link 0; tree clean                                                                                  | quoted in session; commits 3b5af2e, dd6707c                                  |
| 12 | Session status report written (and its timestamp defect fixed — see d1)                                                                                       | `docs/status/2026-10-27_23-10_*`                                             |

## b) PARTIALLY DONE

| Item                                         | Done                                             | Missing                                                                                                                                                             |
| -------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| stack-selection hardening (plan 4%→64% tier) | evals, triggers, drift-check, map — all executed | real user-triggered run (the 🟡→🟢 half of two-stage aging); meta registration never exercised (Phase 6 last bullet still untested — no real new project existed)   |
| Decision routing                             | TODO/ROADMAP/CHANGELOG reflect all 14 verdicts   | execution of the decisions themselves is only STARTED: P7–P9 (the website-template build the Q0–Q5 answers unblock) not begun                                       |
| Trigger-eval rigor                           | 20/20 on one matcher round, STRONG preserved     | single run, no 3× stability sampling; evaluator (me) also designed the queries (recorded as known limit)                                                            |
| Eval grading rigor                           | 16/16 with evidence pointers                     | grader was NOT blind — assertions drafted after outputs were in hand (anchored on yesterday's evals.json expected_output, but still; see e2)                        |
| Fan-out ledger                               | stack-selection committed on master              | aggregation repo NOT pushed (correct — no request); main checkout still on WIP branch `docs-health-verify-legs` with 67 dirty files (pre-existing, not mine to fix) |

## c) NOT STARTED (from the plan; nothing silently skipped)

- **P7/T57** website-template extraction (Go SSG baseline; now fully ungated by Q0–Q5; needs its own session + a push request for CI-green acceptance).
- **P8/T58** `websitelaunch` CLI (gated on P7).
- **P9/T59** website-launch skill slim + ROADMAP 848-line close (gated on P8).
- **P12/T33** site-repo media work (separate repos; ungated; Q5 kept it independent).
- **P13/T30** README 🆕→🟢 flip (externally blocked on a real green upstream PR).

## d) TOTALLY FUCKED UP (session defects — all mine)

1. **Fabricated future timestamp (fixed).** The session report was written at 23:10 but headed "23:30" (scope line "~22:00–23:30" too). Caught by running `date` for THIS report: now=23:11 < 23:30. Fixed via `git mv` + header sed → `2026-10-27_23-10_*`. This is EXACTLY the defect class yesterday's self-review root-caused ("prose written faster than derived") — I repeated it the next day while executing the plan born from that review. The rule that fixes it: every timestamp in a report comes from `date` in the same breath, like exit codes.
2. **Evidence-pointer fabrication, caught mid-flight (fixed).** The first write of eval-1's `output.md` claimed "full markdown preserved in git history of this file from first write" — while containing only a condensed version. Nothing had ever been written verbatim; the pointer was to a fiction. Caught ~30 s later, fixed by appending the true verbatim output before any commit. Same class as the 2026-09-08 trashed-ground-truth incident the SESSION-START file explicitly warns about.
3. **`question` tool malformed first call.** Nested the `questions` array wrong; wasted a round trip. Trivial, self-corrected, but it broke "one batch" optics.
4. **capability-map-diff.sh shipped wrong twice before right.** v1: case-sensitive `BuildFlow` vs meta key `buildflow`, and the gone-check diffed against the lib-FILTERED set instead of all keys (false "gone" rows). Both found by running it, both fixed same session. The fix loop worked; shipping v1 wrong twice still cost a cycle.
5. **Grading written with the answer sheet visible.** Plan P2.4 wanted assertions drafted "while runs execute"; the agent tool blocks until completion, so I graded outputs I had already read. Mitigation that WAS present: assertions map 1:1 to yesterday's pre-written `expected_output` fields, and each verdict cites evidence. Mitigation that was MISSING: grading.json does not disclose the non-blind condition. (Logged as e2 rather than silently patched — writing the disclosure now would grade my own homework twice.)

## e) WHAT WE SHOULD IMPROVE (ranked)

1. **Blind-grading protocol for evals.** Future eval runs: write assertions to a file BEFORE spawning subagents (even if the tool blocks — the file timestamp proves precedence), or have a second subagent grade against assertions it did not write. Cheap, kills the confirmation-bias question permanently.
2. **Timestamps/counts by command, always.** `date` for report headers, `git show -s --format=%ci` for commit-referencing claims. One line in SESSION-START.md would codify it (it already does this for exit codes — extend the same rule).
3. **Register `docs/decisions/` as a convention.** A new directory + genre appeared (decision records) with no entry in AGENTS' Project Documentation Files table and no mention in §2 structure. Future sessions will discover it only by luck. Add: purpose (enduring decision records with verdicts), NOT-for (plans, status).
4. **Cross-check FEATURES rows after EVERY SKILL.md edit** (SESSION-START step 6 says this; I checked 3 of 8 edited skills). The other five (brutal-self-review, architecture-review, naming-review, nix-review, full-code-review) had gloss-wording edits only — their FEATURES rows very likely don't mention glosses, but "very likely" is not verification.
5. **drift-check false negative**: a lib mentioned in STACK.md prose ABOVE the excluded split (e.g. in the profile or wiring-order text) counts as "declared chosen" though it has no chosen-table row. Tighten: grep only between `## Chosen foundation` and the next `##` heading.
6. **Trigger-eval 3× sampling** + a query set authored by someone other than the judge (second subagent can draft near-misses).
7. **Commit-race handling**: the auto-daemon took index.lock mid-commit (62c6ac0 landed between my add and commit). Rule of thumb: commit session artifacts immediately after each P-block instead of one mega-commit at the end — smaller races, better history.
8. **The status-report format rule now lives in 5 places** (skill canonical, decision doc, ROADMAP note, FEATURES, CHANGELOG). The four non-canonical ones all cite the decision — acceptable — but the NEXT format change must edit exactly one canonical + pointers, or this becomes the next 8-recurrence fight.

## f) NEXT — up to 50, ranked (impact/effort)

**Unblocked builds (the 20%→100% tail of the plan):**

1. P7/T57: create `~/projects/website-template` (private) from templ-components Go SSG; strip specifics; parametrize name/assets (Q1/Q4 decided).
2. P7: close parity gaps in template (editLink, per-page lastUpdated; pin standalone tailwindcss, nodeless CI).
3. P7: clean-checkout acceptance build (local clone → build → dry-run) — no push needed for THIS acceptance.
4. P7: request push + GitHub remote creation (needs user).
5. P7: iterate CI to green after push.
6. P8/T58: `websitelaunch` CLI scaffold (Go stdlib-only, doctor/init/check).
7. P8: `doctor` = website-launch Phase 0 checks as code.
8. P8: `init` = scaffold from template; smoke-test on scratch repo.
9. P8: `check` = DoD/Phase 4 as code (lockfile consistency, license 4-file, og:image, mp4 cache headers).
10. P8: validate `check` against the templ-components site; fix findings.
11. P9/T59: website-launch Phase 3 → scaffold instructions pointing at CLI.
12. P9: absorb references per the disposition tables; re-run `evals/`.
13. P9: close the ROADMAP 848-line question with resolution note.
14. P12/T33: rebuild emeet-pixyd HyperFrames composition from surviving MP4 (commit under `website/video/`).
15. P12: first 20–30 s product video — pick site (see g), script beats.
16. P12: render + embed product video on chosen site.
17. P12: go-atomic-write + go-filewatcher video flows.
18. P12: emeet og:image-from-poster upgrade.
19. P12: CI deploy workflow decision (may fold into template CI once it exists, per Q5).

**Honesty/verification hardening (session-born):**
20. Blind-grading protocol (e2/improvement 1) applied to the NEXT eval iteration; backfill disclosure note into iteration-2 grading.json.
21. Trigger-eval 3× sampling + independent near-miss authoring.
22. SESSION-START.md: extend the exit-code rule to timestamps (`date` for headers).
23. Register `docs/decisions/` in AGENTS docs table + §2 tree.
24. Verify FEATURES rows for the 5 gloss-edited skills (one grep each).
25. drift-check: restrict chosen-grep to the chosen-table section (improvement 5) + add a prose-mention fixture.
26. Consider `meta set` exercise: register a real/trial project to test stack-selection Phase 6's last bullet (the only never-exercised step).
27. Run `stack-drift-check.sh` against the FIRST real project that adopts STACK.md; record run note.
28. First real stack-selection trigger ages it 🟡→🟢 (two-stage rule; watch for it and flip FEATURES/README).

**Repo hygiene / small fixes:**
29. AGENTS §2 directory tree: add `docs/decisions/` (same as 23 — one edit).
30. linter-building evals: iteration-2 items (eval-4/5) predate the two-stage rule — confirm their FEATURES evidence wording matches the new legend.
31. README: "Eight 🆕 + two eval'd" prose now hardcodes names — recheck on every skill status change (or derive from FEATURES by script).
32. capability-map: combined-row caveat could be fixed properly by splitting the typespec row into 4 rows (kills the script's false-positive class).
33. `capability-map-diff.sh`: emit the map's verified-on date so stale stamps are visible in the diff itself.
34. Consider gitignoring `stack-selection-workspace/*/iteration-*/**/timing.json` N/A placeholders or standardizing them.
35. Sweep `docs/reviews/2026-10-27_21-44_*` self-review HTML: its T60–T63 findings are now DONE — annotate resolved items (docs-health ANNOTATE).
36. The 2026-10-17 and 2026-10-27 plans: mark their P1 (decision package) as executed (ANNOTATE, done-at markers).

**Bigger, still-open items carried in TODO/ROADMAP:**
37. T30: flip jj-fork-pr README 🆕→🟢 after first real green upstream PR (external event).
38. ROADMAP: "How does Crush's skill-selection disambiguate?" — the trigger-eval matcher simulation partially informs this; could be closed with a small experiment doc.
39. ROADMAP: performance-tuning granularity (own skill vs reference) — untouched, user decision pending.
40. ROADMAP: FEATURES legend canon question — now PARTIALLY superseded by the two-stage note; reconcile wording.
41. ROADMAP: formatter scope (dprint full-repo vs scoped) — untouched.
42. ROADMAP: alias-guidance home / go-type-design skill — untouched.
43. ROADMAP: skill-creator upstream guidance (teaches the description anti-pattern) — untouched.
44. ROADMAP: go-release eval artifacts (`rm -rf` authenticity) — untouched.
45. ROADMAP: website-launch video policy g1–g3 (click-to-play, 9:16 tier, API-lib mandatory) — interacts with P12; decide before video work.
46. ROADMAP: `how-to-write-skills.md` location (skill dir vs docs/) — untouched.
47. ROADMAP: "jj mergemerge" origin — user-only answer, still open.
48. Aggregation repo: eventually land master + reconcile the `docs-health-verify-legs` WIP (67 files) — not mine to do unasked.
49. `stack-selection` description: after first REAL trigger, revisit whether the eval'd wording still fires (real-world beats simulation).
50. meta tag-hygiene: consider a `meta set` batch adding `lib` tags to the verified foundations (go-daemon, erraudit, template-*) so the `lib` filter stops lying — one-time, ~10 commands.

## g) Questions I cannot answer myself

1. **Product-video site (P12/T33):** which site gets the first 20–30 s product video — the Q0 decision made templ-components/Go the template baseline, but T33's video site choice ("open question, ROADMAP") was never part of the 14. Candidates: a Go-lib site (templ-components), a high-traffic Astro site (gogenfilter), or lars.software itself?
2. **Push authorizations:** may I (a) create the `website-template` GitHub repo and push it when P7's local acceptance passes, and (b) push the aggregation repo's master (4100313) so the fan-out ledger is remotely durable? Both are pushes I won't do unasked.
3. **Blind-grading backfill:** should I add the non-blind disclosure note to iteration-2's grading.json now (making the historical record honest about method), or leave committed evidence untouched and apply the protocol only forward? I cannot know your evidentiary-integrity preference here — it trades "amend the record" against "never touch committed evidence".

## Self-review answers (skill questions, condensed)

Forgot: FEATURES re-checks for 5 of 8 edited skills; `docs/decisions/` convention registration; the report timestamp (caught late). Stupid-we-do-anyway: mega-commit at session end (daemon race bait); timestamps from memory. Better: blind grading, immediate per-block commits. Still improve: e1–e8 above. Lied: no — but two accuracy defects (d1, d2) were fabricated-adjacent and both fixed before anyone relied on them; the grading caveat (d5) is disclosed here rather than hidden. Less stupid: codify the timestamp rule (f22). Ghost systems: none created — every new artifact (drift-check, map-diff, hook, decisions doc) has a wired reader; the pre-existing ghost (STACK.md unread anywhere) is exactly what T62 killed. Scope creep: resisted P7 execution at session tail (Verschlimmbesserung guard held). Removed-useful: nothing removed. Split brains: minor — the format rule restated in 5 places (all citing canonical), aging rule in 3 (same pattern); flagged as e8. Tests: no new test harness beyond the 4 drift fixtures + fixture-tested gates; the drift fixtures are the model to copy for future script assets.

_Verschlimmbesserung guard held: the only mid-report edit was fixing my own fresh timestamp defect (d1, fix-on-sight rule, AGENTS "Trivial, already-understood doc staleness"). Everything else waits for instructions._
