# TODO List

> Short-term, actionable, bounded work items. This list holds only what
> remains verified-open. For long-term vision and unrefined ideas, see
> `ROADMAP.md`. Historical waves: T1–T20 (2026-08-21), T21–T32
> (2026-09-08/09), wave-3 (2026-09-09), T36–T56 execution wave (2026-09-24)
> — all executed; see `CHANGELOG.md`.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed — external dependency or decision needed.    |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

---

## Open items

> T36–T50 and T52–T56 were executed 2026-09-24 (see `CHANGELOG.md` and
> `docs/status/2026-09-24_*` for evidence per item).

| ID  | Task                                                                                                                                                                                                                                                                                                                                                  | Status     | Impact | Effort | Evidence                                                                                                                               |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------ | ------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| T30 | After the first real upstream PR kept green via the jj sync loop: flip README status 🆕→🟢 with a documented run note                                                                                                                                                                                                                                 | 🔵 BLOCKED | Low    | Low    | `docs/status/2026-09-08_20-39_*` c3/f15 — needs a real-world run; trigger test already passed both directions (wave-2 T27)             |
| T33 | Site-repo follow-ups REMAINING: recreate emeet-pixyd's HyperFrames composition from the surviving MP4 (commit under `website/video/`); first real 20-30s product video (site choice = open question, ROADMAP); video flows for go-atomic-write/go-filewatcher; emeet og:image-from-poster upgrade; CI deploy workflow to kill the manual-deploy class | 🔴 TODO    | Medium | M/site | `docs/status/2026-09-09_02-31_wave-3-execution-session.md` (quick items closed live); `TODO_LIST` history; `2026-09-08_23-53_*` f7-f11 |
| T34 | linter-building open questions: Go-first vs multi-language depth (g1), synthetic-eval aging vs wait-for-real-trigger (g2), commit-ownership convention (g3) — user decisions needed                                                                                                                                                                   | 🔵 BLOCKED | Medium | S      | `docs/status/2026-09-09_20-08_linter-building-session-self-review.md` g1-g3; eval iteration-1 already ran (`linter-building/evals/`)   |
| T51 | Align the 7 shipped first-use glosses verbatim to the Principle 7 table (or amend the rule to "meaning identical" per ROADMAP g-question, then skip) — gated on the glossary-lockstep decision                                                                                                                                                        | 🔵 BLOCKED | High   | S      | `docs/status/2026-09-18_05-44_*` d1/f1/f12/g2                                                                                          |
| T57 | website-launch template overhaul, stage 1 — user decision package Q0 (extraction baseline: templ-components Go SSG vs gogenfilter Astro) + Q1–Q5 (repo name, CLI language, gogenfilter fate, visibility, T33 sequencing), then extract the chosen baseline into a canonical CI-green template repo (acceptance: builds from a clean checkout)         | 🔵 BLOCKED | High   | M      | `docs/status/2026-10-11_04-28_*`, `04-29_*`, `08-30_website-launch-two-proposal-reconciliation.md` (claims verified there)             |
| T58 | website-launch template overhaul, stage 2 — `websitelaunch` CLI in the template repo: `doctor` (Phase 0 checks), `init` (scaffold), `check` (DoD/Phase 4 as code); stdlib-only, hard-capped small; validate `check` by running it against the extraction-source site                                                                                  | 🔵 BLOCKED | Medium | M      | T57; 04:29 proposal §5.2/§6.4; reconciliation plan step 2–4                                                                            |
| T59 | website-launch template overhaul, stage 3 — skill slim: Phase 3 → scaffold instructions, absorb references per disposition tables, update FEATURES row, re-run `evals/`, close the ROADMAP 848-line refactor question                                                                                                                                 | 🔵 BLOCKED | Medium | S-M    | T58; reconciliation plan step 5; ROADMAP ~line 149                                                                                     |
| T60 | stack-selection evals 1–2 in subagent mode + draft assertions per skill-creator (eval 2, the cqrs-htmx event-sourced-web-app path, is the hard multi-lib competition case — the degraded run only covered the easy YAGGI exclusion case)                                                                                                              | 🔴 TODO    | High    | S      | `stack-selection/evals/evals.json`; degraded self-run fixture `stack-selection-workspace/iteration-1/`; `docs/status/2026-10-27_21-40_*` |
| T61 | stack-selection trigger-eval set (should-trigger/should-not pairs incl. near-misses vs how-to-golang and library-deep-dive) + description optimization loop                                                                                                                          | 🔴 TODO    | Medium  | S      | skill-creator Description Optimization; first-customers `evals/trigger-eval.json` is the pattern                                          |
| T62 | STACK.md consumer wiring: drift check that go.mod deps ⊆ STACK.md choices (script asset in stack-selection or a buildflow step) + consider full-code-review reading STACK.md as declared-architecture ground truth — otherwise STACK.md is written once and never read | 🔴 TODO    | High    | S-M    | `docs/reviews/2026-10-27_*_brutal-self-review.html` ghost-system finding; brutal-self-review Q7                                          |
| T63 | Commit the aggregation-layer repo (`~/.agents/skills`) new `stack-selection` symlink once `master` is checked out there (currently stale branch `docs-health-verify-legs` with third-party WIP — do not mix)                                                                          | 🔴 TODO    | Low     | S      | `git -C ~/.agents/skills branch --show-current` output 2026-10-27; AGENTS §5.10 (cosmetic, symlinks are what matter)                    |

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
