# TODO List

> Short-term, actionable, bounded work items. This list holds only what
> remains verified-open (checked against the repo 2026-09-18 by the
> docs-health pass; evidence per row). For long-term vision and unrefined
> ideas, see `ROADMAP.md`. Historical waves: T1–T20 (2026-08-21),
> T21–T32 (2026-09-08/09), wave-3 (2026-09-09) — all executed; see
> `CHANGELOG.md`.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed — external dependency or decision needed.    |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

---

## Open items

| ID  | Task                                                                                                                                                            | Status     | Impact | Effort | Evidence                                                                                                                                                              |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------ | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| T30 | After the first real upstream PR kept green via the jj sync loop: flip README status 🆕→🟢 with a documented run note                                            | 🔵 BLOCKED | Low    | Low    | `docs/status/2026-09-08_20-39_*` c3/f15 — needs a real-world run; trigger test already passed both directions (wave-2 T27)                                            |
| T33 | Site-repo follow-ups REMAINING: recreate emeet-pixyd's HyperFrames composition from the surviving MP4 (commit under `website/video/`); first real 20-30s product video (site choice = open question, ROADMAP); video flows for go-atomic-write/go-filewatcher; emeet og:image-from-poster upgrade; CI deploy workflow to kill the manual-deploy class | 🔴 TODO | Medium | M/site | `docs/status/2026-09-09_02-31_wave-3-execution-session.md` (quick items closed live); `TODO_LIST` history; `2026-09-08_23-53_*` f7-f11                              |
| T34 | linter-building open questions: Go-first vs multi-language depth (g1), synthetic-eval aging vs wait-for-real-trigger (g2), commit-ownership convention (g3) — user decisions needed            | 🔵 BLOCKED | Medium | S      | `docs/status/2026-09-09_20-08_linter-building-session-self-review.md` g1-g3; eval iteration-1 already ran (`linter-building/evals/`)                                    |
| T36 | Fix the live "every comment across all repos" overclaim in `github-voice/SKILL.md:26` (own-repo coverage is a 1,500-of-6,508 sample) — replace with copy-paste from `summary.json` collection parameters | 🔴 TODO | High (honesty) | XS | `docs/status/2026-09-12_10-55_*` f1/d2 (fix never applied — verified live 2026-09-18 by the 18-47 evidence pass and this pass)                                       |
| T37 | Add the canonical `## Verification status` table to `buildflow/SKILL.md` (claim → status → source; the canon guard warns about the current shape)               | 🔴 TODO    | Medium | S      | `docs/status/2026-09-14_12-25_*` f2; grep verified absent 2026-09-18                                                                                                   |
| T38 | Rewrite the `naming-review` description (measured 1021/1024 chars — no headroom) tightening to ~800, then add data-model-review ↔ naming-review mutual disambiguation | 🔴 TODO    | Medium | S      | `docs/status/2026-09-14_11-25_*` open item + `11-36` f1/f7; length measured 2026-09-18                                                                                 |
| T39 | Harden check 14 to row-level first-column matching + reverse direction (FEATURES rows naming nonexistent skills FAIL) — kills false negatives and deleted-skill residue | 🔴 TODO  | Medium | S      | `docs/status/2026-09-16_18-17_*` b4/f1/f2; any-mention grep verified in `scripts/check-skills.sh` 2026-09-18                                                            |
| T40 | Audit README per-skill 🆕/🟢 markers for drift vs FEATURES.md; consider gating README↔FEATURES row parity (twin drift surface, currently ungated)               | 🔴 TODO    | Medium | S–M    | `docs/status/2026-09-16_18-17_*` c4/e5/f4                                                                                                                             |
| T41 | `link-skills-to-agents.sh`: add `--selftest` (automate the sandbox matrix) and wire `--check` into `check-skills.sh` so one gate covers structure + links        | 🔴 TODO    | Medium | S      | `docs/status/2026-09-13_14-29_*` f4/f5; both verified absent 2026-09-18 (grep: no selftest, not wired)                                                                 |
| T42 | Make check 15 fence- and quote-aware (a skill teaching against throat-clearing inside fences must not hard-fail) + add the negative fixture; replace the `It.s` regex with explicit alternatives; print the remediation line | 🔴 TODO | High | S | `docs/status/2026-09-18_05-39_*` d1/d5, e1, f1-f4; `filler_re` at `scripts/check-skills.sh:232` verified still `It.s` 2026-09-18                                   |
| T43 | Fixture-test `--signal` itself (seed a file with known preamble/prose/jargon counts and assert them; mirror the `annotate-rows_test.py` precedent)              | 🔴 TODO    | Medium | S      | `docs/status/2026-09-18_05-39_*` b3/f2                                                                                                                                |
| T44 | Preserve the communication-doctrine source as `originals/communication-doctrine.md` with a note on what it seeded (Principle 7)                                 | 🔴 TODO    | Low    | XS     | `docs/status/2026-09-18_05-39_*` c2/f17                                                                                                                               |
| T45 | Build `scripts/site-dod-check.sh <site>`: HEAD cache (mp4+js), `id="demo"`, og:image presence + 1200x630 dimensions, firebase.json block-order lint — replaces the throwaway /tmp scripts written three sessions running | 🔴 TODO | High | M | `docs/status/2026-09-09_03-58_*` f1; `2026-09-08_23-53_*` f3                                                                                                        |
| T46 | `run-eval.sh <eval-id>` — reproducible eval harness (fresh sessions, fictional repo, output capture); makes old-vs-new rewrite evals a one-command operation     | 🔴 TODO    | Medium | M      | `docs/status/2026-09-08_23-53_*` f15; harness shape proven twice (go-release 79%→95%, website-launch 35%→100%)                                                          |
| T47 | `check-skills.sh` self-test in a subshell (assert exit 0 AND the final OK line; fixture tree of pass/fail skills) so the gate can never silently die again      | 🔴 TODO    | High    | S      | `docs/status/2026-09-09_20-08_*` f1 (the 2026-09-09 silent-exit incident)                                                                                              |
| T48 | linter-building: fresh-session trigger test ("write a linter" must activate it) + the negative-prompt eval ("lint my project" must route to code-quality-scan) — the round-3 f29 item that was marked CLOSED without running | 🔴 TODO | High | S | `docs/status/2026-09-09_23-26_*` d1/f1/f5                                                                                                                          |
| T49 | Verify-or-mark the ~10 research-sourced specifics still unmarked in `linter-building/references/*` (round-3 b1 list: ledger retention, loop caps, H001 signals, normLit, ADR-0001, ContinueOnError, RunWithSuggestedFixes, tag scheme, RuleMeta.Validate, black-box `_test`) | 🔴 TODO | Medium | M | `docs/status/2026-09-09_23-26_*` b1/f3; per-reference verification tables verified absent 2026-09-18 (grep)                                                        |
| T50 | `check-skills.sh` guards for the marker-vocabulary contract: verify HARVEST references the ANNOTATE-owned markers structurally (not just that the strings exist somewhere) | 🔴 TODO | Low    | M      | `docs/status/2026-08-04_04-16_*` b6; current guard greps literals only                                                                                                 |
| T51 | Align the 7 shipped first-use glosses verbatim to the Principle 7 table (or amend the rule to "meaning identical" per ROADMAP g-question, then skip) — gated on the glossary-lockstep decision | 🔵 BLOCKED | High | S | `docs/status/2026-09-18_05-44_*` d1/f1/f12/g2                                                                                                                          |
| T52 | `--signal` long tail, restraint-disciplined: github-voice preamble=28 audit first; then website-launch (9 prose blocks), go-ecosystem-upgrade, docs-health, verify-before-filing, buildflow, go-release | 🔴 TODO | Medium | M | `docs/status/2026-09-18_05-44_*` b1/f3/f9-f1; `2026-09-17_21-45_*` b                                                                                                 |
| T53 | Fold "tell them what they get / why it's worth the effort" into the description quick-test table (`how-to-write-skills.md` §1)                                  | 🔴 TODO    | Medium | S      | `docs/status/2026-09-18_05-44_*` c1/f4                                                                                                                                |
| T54 | Fix the entombed-gloss grammar slip: "file no later session reads" → "file **that** no later session reads" (2 files)                                           | 🔴 TODO    | Low    | XS     | `docs/status/2026-09-18_05-44_*` f15                                                                                                                                  |
| T55 | Fix SC2319 ×6 in `jj-fork-pr-workflow/scripts/validate-workflow.sh` (`$?` after conditions) and SC2089/90 in `naming-review/scripts/naming-smells.sh`; prove with one real run | 🔴 TODO | Medium | S | `docs/status/2026-09-10_02-55_*` f4/f5; shellcheck advisories documented in AGENTS §5.11                                                                              |
| T56 | Add a self-test for `annotate-prose.py` mirroring the rows test (assert `h/v/p/w` markers incl. the UTC default); dedupe `marker_for` across the two annotate scripts | 🔴 TODO | Medium | S | `docs/status/2026-09-10_02-55_*` f7/f8                                                                                                                                |

---

<!-- Guidance:
  - Source of truth is the CODE and git log. Verify each item before starting.
  - One task per row. If it takes more than ~2 hours, split it.
  - Cite evidence (file paths, report sources) so the next person can verify.
  - DONE items should be REMOVED, not kept. Use CHANGELOG.md for history.
  - If a task is vague, refine it into concrete steps or move to ROADMAP.md.
  - For 80/20 impact prioritization, use the pareto-planning skill AFTER
    building the list here.
  - Deduplicate by semantic intent, not by text match.
-->
