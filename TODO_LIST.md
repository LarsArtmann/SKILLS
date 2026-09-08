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

| ID  | Task                                                                                                                           | Status  | Impact | Effort      | Evidence                                                                       |
| --- | ------------------------------------------------------------------------------------------------------------------------------ | ------- | ------ | ----------- | ------------------------------------------------------------------------------ |
| T21 | Retro-audit existing live sites (gogenfilter, go-atomic-write, emeet-pixyd, ...) against the new demo-video Definition of Done | 🔴 TODO | Medium | Medium/site | `docs/status/2026-08-21_12-06_*` f10 (open since 08-21, untouched by the wave) |
| T22 | HyperFrames ground-truth: one real demo-video render through the corrected guidance (incl. a 9:16 resized-composition variant) | 🔴 TODO | High   | Medium      | `docs/status/2026-08-21_12-06_*` c2; the 9:16 correction is doc-verified only  |

## P1 — Verification debt

| ID  | Task                                                                                                                                    | Status  | Impact | Effort | Evidence                                                                  |
| --- | --------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ | ------------------------------------------------------------------------- |
| T23 | Verify the `govalid` generator flow end-to-end (struct tags compile — proven 2026-08-21 — but `go generate` output was never run)       | 🔴 TODO | Medium | Low    | AGENTS.md §10 note (2026-08-21 compile-check record, generator untested)  |
| T24 | Re-run the website-launch eval-1 with a fully fictional repo (the 08-21 run had a real-repo/maintenance-mode asymmetry between configs) | 🔴 TODO | Low    | Low    | `website-launch/evals/iteration-1/grading.json` notes (scores unaffected) |
| T27 | Behavioral trigger test of `jj-fork-pr-workflow` in a fresh Crush session (realistic prompts: "fork bubbletea and fix X", "keep my PRs up to date") | 🔴 TODO | High   | Low    | `docs/status/2026-09-08_20-39_*` b4/f7 — structural guard passed, activation never observed |
| T28 | Align `jj-fork-pr-workflow`'s verification block with `verify-external-claims` (read its SKILL.md; if no canonical block format exists, define one in `how-to-write-skills.md`) | 🔴 TODO | Medium | Low    | `docs/status/2026-09-08_20-39_*` b5/f8 |

## P2 — Polish

| ID  | Task                                                                                                                                                                                   | Status  | Impact | Effort | Evidence                                                                 |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ | ------------------------------------------------------------------------ |
| T25 | Make `website-launch/SKILL.md` length gate progress permanent: 799 lines now; next trim target is the Phase 2 structure list (duplicates readme-template.md §"Standard Section Order") | 🔴 TODO | Low    | Low    | `scripts/check-skills.sh` WARN (allowlisted); recurring since 2026-08-14 |
| T26 | Consider a trigger-density lint mode for `check-skills.sh` (report near-miss descriptions without gating) — follow-up to the T1 guard                                                  | 🔴 TODO | Low    | Low    | `docs/status/2026-08-21_21-57_*` e5                                      |
| T29 | Add a "known upstream jj skills" note (Carbon-lang `.agents/skills/jj/SKILL.md`) to `jj-fork-pr-workflow` references | 🔴 TODO | Low    | Low    | `docs/status/2026-09-08_20-39_*` f13                                     |
| T30 | After the first real PR kept green via the sync loop: flip README status 🆕→🟢 with a documented run note | 🔴 TODO | Low    | Low    | `docs/status/2026-09-08_20-39_*` c3/f15                                  |
| T31 | Flesh out the four thin-flagged skills per the 2026-06-17 audit specifics (architecture-visualization 39, code-quality-scan 41, architecture-review 54, bdd-testing 54 lines — the audit owns the per-skill split) | 🔴 TODO | Medium | Large  | `scripts/check-skills.sh` inventory 2026-09-08; `docs/status/2026-06-17_23-22_*` |
| T32 | Add a repo session-start checklist artifact (scan `docs/feedback/new/`, newest `docs/status/`, AGENTS §8) — two mandatory steps were skipped at session start 2026-09-08 | 🔴 TODO | Medium | Low    | `docs/status/2026-09-08_20-39_*` d6/e4                                   |

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
