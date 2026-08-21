# TODO List

> Short-term, actionable, bounded work items. The 2026-08-21 harvest (T1–T20)
> was fully executed on 2026-08-21 (see CHANGELOG and
> `docs/status/2026-08-21_21-57_todo-execution-wave.md`); this list now holds
> only what remains verified-open. For long-term vision and unrefined ideas,
> see `ROADMAP.md`.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed — external dependency or decision needed.    |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

---

## P0 — External ground truth

| ID | Task                                                                                                                     | Status | Impact | Effort | Evidence                                                                        |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------ | ------ | ------ | ------------------------------------------------------------------------------- |
| T21 | Retro-audit existing live sites (gogenfilter, go-atomic-write, emeet-pixyd, ...) against the new demo-video Definition of Done | 🔴 TODO | Medium | Medium/site | `docs/status/2026-08-21_12-06_*` f10 (open since 08-21, untouched by the wave)  |
| T22 | HyperFrames ground-truth: one real demo-video render through the corrected guidance (incl. a 9:16 resized-composition variant) | 🔴 TODO | High   | Medium | `docs/status/2026-08-21_12-06_*` c2; the 9:16 correction is doc-verified only   |

## P1 — Verification debt

| ID | Task                                                                                                                       | Status | Impact | Effort | Evidence                                                            |
| -- | -------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------ | ------------------------------------------------------------------- |
| T23 | Verify the `govalid` generator flow end-to-end (struct tags compile — proven 2026-08-21 — but `go generate` output was never run) | 🔴 TODO | Medium | Low    | AGENTS.md §10 note (2026-08-21 compile-check record, generator untested) |
| T24 | Re-run the website-launch eval-1 with a fully fictional repo (the 08-21 run had a real-repo/maintenance-mode asymmetry between configs) | 🔴 TODO | Low    | Low    | `website-launch/evals/iteration-1/grading.json` notes (scores unaffected) |

## P2 — Polish

| ID | Task                                                                                                                       | Status | Impact | Effort | Evidence                                                       |
| -- | -------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------ | --------------------------------------------------------------- |
| T25 | Make `website-launch/SKILL.md` length gate progress permanent: 799 lines now; next trim target is the Phase 2 structure list (duplicates readme-template.md §"Standard Section Order") | 🔴 TODO | Low | Low | `scripts/check-skills.sh` WARN (allowlisted); recurring since 2026-08-14 |
| T26 | Consider a trigger-density lint mode for `check-skills.sh` (report near-miss descriptions without gating) — follow-up to the T1 guard | 🔴 TODO | Low | Low | `docs/status/2026-08-21_21-57_*` e5                             |

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
