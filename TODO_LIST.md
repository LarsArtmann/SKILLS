# TODO List

> Short-term, actionable, bounded work items. The 2026-08-21 harvest (T1–T20)
> was fully executed on 2026-08-21 (see CHANGELOG and
> `docs/status/2026-08-21_21-57_todo-execution-wave.md`); the T21–T32 wave
> was executed 2026-09-08 (`docs/status/2026-09-08_23-40_todo-wave-2.md`);
> the 2026-09-09 wave-3 session closed report-section-f items and T33's
> quick site fixes (`docs/status/2026-09-09_02-31_wave-3-execution-
> session.md`). This list holds only what remains verified-open. For
> long-term vision and unrefined ideas, see `ROADMAP.md`.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed — external dependency or decision needed.    |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

---

## Open items

| ID  | Task                                                                                                                                                                                                                                                                                                                                            | Status     | Impact | Effort | Evidence                                                                                                                                                                                          |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------ | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| T30 | After the first real PR kept green via the sync loop: flip README status 🆕→🟢 with a documented run note                                                                                                                                                                                                                                       | 🔵 BLOCKED | Low    | Low    | `docs/status/2026-09-08_20-39_*` c3/f15 — needs a real-world run to happen first                                                                                                                  |
| T33 | Site-repo follow-ups REMAINING: recreate emeet-pixyd's HyperFrames composition from the surviving MP4 (commit under `website/video/`); first real 20-30s product video (site choice = open question g1); video flows for go-atomic-write/go-filewatcher; emeet og:image-from-poster upgrade; CI deploy workflow to kill the manual-deploy class | 🔴 TODO    | Medium | M/site | 2026-09-09 wave-3 session CLOSED the quick items (headers fixed+live-verified on all four sites, `id="demo"`, README badge, redeploy): `docs/status/2026-09-09_02-31_wave-3-execution-session.md` |

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
