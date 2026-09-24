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

| ID  | Task                                                                                                                                                                                                                                                                                                                                                  | Status     | Impact         | Effort | Evidence                                                                                                                               |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| T30 | After the first real upstream PR kept green via the jj sync loop: flip README status 🆕→🟢 with a documented run note                                                                                                                                                                                                                                 | 🔵 BLOCKED | Low            | Low    | `docs/status/2026-09-08_20-39_*` c3/f15 — needs a real-world run; trigger test already passed both directions (wave-2 T27)             |
| T33 | Site-repo follow-ups REMAINING: recreate emeet-pixyd's HyperFrames composition from the surviving MP4 (commit under `website/video/`); first real 20-30s product video (site choice = open question, ROADMAP); video flows for go-atomic-write/go-filewatcher; emeet og:image-from-poster upgrade; CI deploy workflow to kill the manual-deploy class | 🔴 TODO    | Medium         | M/site | `docs/status/2026-09-09_02-31_wave-3-execution-session.md` (quick items closed live); `TODO_LIST` history; `2026-09-08_23-53_*` f7-f11 |
| T34 | linter-building open questions: Go-first vs multi-language depth (g1), synthetic-eval aging vs wait-for-real-trigger (g2), commit-ownership convention (g3) — user decisions needed                                                                                                                                                                   | 🔵 BLOCKED | Medium         | S      | `docs/status/2026-09-09_20-08_linter-building-session-self-review.md` g1-g3; eval iteration-1 already ran (`linter-building/evals/`)   |
| T51 | Align the 7 shipped first-use glosses verbatim to the Principle 7 table (or amend the rule to "meaning identical" per ROADMAP g-question, then skip) — gated on the glossary-lockstep decision                                                                                                                                                        | 🔵 BLOCKED | High           | S      | `docs/status/2026-09-18_05-44_*` d1/f1/f12/g2                                                                                          |

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
