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

| ID  | Task                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | Status     | Impact | Effort | Evidence                                                                                                                    |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------ | ------ | --------------------------------------------------------------------------------------------------------------------------- |
| T30 | After the first real upstream PR kept green via the jj sync loop: flip README status 🆕→🟢 with a documented run note                                                                                                                                                                                                                                                                                                                                                           | 🔵 BLOCKED | Low    | Low    | `docs/status/2026-09-08_20-39_*` c3/f15 — needs a real-world run; trigger test already passed both directions (wave-2 T27)  |
| T33 | Site-repo follow-ups REMAINING: recreate emeet-pixyd's HyperFrames composition from the surviving MP4 (commit under `website/video/`); first real 20-30s product video (site choice = open question, ROADMAP); video flows for go-atomic-write/go-filewatcher; emeet og:image-from-poster upgrade; CI deploy workflow to kill the manual-deploy class (DECIDED Q5: stays separate from the template chain; only the CI-deploy item may migrate into template CI once it exists) | 🔴 TODO    | Medium | M/site | `docs/status/2026-09-09_02-31_wave-3-execution-session.md`; decision Q5 2026-10-27                                          |
| T57 | website-launch stage 1: extract the templ-components Go SSG into canonical private repo `website-template` (Q0=Go, Q1=name, Q4=private decided; close parity gaps editLink/lastUpdated; acceptance: builds from a clean checkout)                                                                                                                                                                                                                                               | 🔴 TODO    | High   | M      | Decided 2026-10-27: `docs/decisions/2026-10-27_open-decisions.md` §A Q0–Q5; `docs/status/2026-10-11_08-30_*` reconciliation |
| T58 | website-launch template overhaul, stage 2 — `websitelaunch` CLI in the template repo: `doctor` (Phase 0 checks), `init` (scaffold), `check` (DoD/Phase 4 as code); stdlib-only, hard-capped small; validate `check` by running it against the extraction-source site                                                                                                                                                                                                            | 🔵 BLOCKED | Medium | M      | T57; 04:29 proposal §5.2/§6.4; reconciliation plan step 2–4                                                                 |
| T59 | website-launch template overhaul, stage 3 — skill slim: Phase 3 → scaffold instructions, absorb references per disposition tables, update FEATURES row, re-run `evals/`, close the ROADMAP 848-line refactor question                                                                                                                                                                                                                                                           | 🔵 BLOCKED | Medium | S-M    | T58; reconciliation plan step 5; ROADMAP ~line 149                                                                          |
| T60 | Modern Web Guidance uninstall proof: snapshot `~/.agents/skills/modern-web-guidance` + `~/skills-lock.json`, run `pnpx modern-web-guidance@latest uninstall`, confirm the directory and the lock entry both disappear, then restore the snapshot (the update half is verified 2026-10-30: `update` printed "All project skills are up to date", exit 0, zero tree delta)                                                                                                        | 🔴 TODO    | Low    | S      | `docs/status/2026-10-30_02-29_*` f#10; update evidence 2026-10-30                                                           |
| T62 | Land the "install, don't wrap" rule in authoring docs: add the add-URL → check-for-an-installer decision rule to `how-to-write-skills.md`, add one-way pointers from `html-report-kit` + `website-launch` that web-platform behaviour is owned by the installed skill, and audit remaining skills for restating a third-party `SKILL.md`                                                                                                                                        | 🔴 TODO    | High   | M      | `docs/status/2026-10-30_02-29_*` f#4, f#17, f#20; AGENTS §5.10                                                              |
| T63 | First real triggered web task: build the modal/`<dialog>` case end-to-end, record the `search` → `retrieve` trail, and decide whether upstream's mandatory "### Modern Web Guidance" disclosure block stays in every response or is waived as noise                                                                                                                                                                                                                             | 🔴 TODO    | High   | M      | `docs/status/2026-10-30_02-29_*` f#3, f#16                                                                                  |
| T67 | Encode markdown-table safety for formatters: never leave a literal pipe inside a table cell (escape it or describe it), and after every formatter run verify with `git diff -w` that only whitespace changed — `dprint` truncated one evidence cell on 2026-10-30 and the loss was caught only by luck                                                                                                               | 🔴 TODO    | High   | S      | `docs/status/2026-10-30_03-48_*` d2, e1                                                                                     |
| T68 | Decide the `agent-skills` branch policy: the 194-file MWG inventory commit `3479122` (plus 67 pending third-party updates) sits on `docs-health-verify-legs` — move it to the default branch or declare the feature branch intentional                                                                                                                                                                        | 🔵 BLOCKED | High   | S      | `docs/status/2026-10-30_03-48_*` d4, g1                                                                                     |
| T69 | Triage the standing advisory findings and record them as deliberate non-fixes in AGENTS §5.11: `art-dupl` (6), `jscpd` (3), `file-size-check` (4) — currently unexplained noise every run                                                                                                                                                                                                                     | 🔴 TODO    | Medium | S      | `docs/status/2026-10-30_03-48_*` e9, f#10, f#12                                                                             |
| T70 | Resolve the AGENTS.md size advisory (41,403 B vs the 30 KB threshold): trim, or record a justified project-specific threshold instead of leaving a WARN nobody acts on                                                                                                                                                                                                                                         | 🔴 TODO    | Medium | M      | `docs/status/2026-10-30_03-48_*` b6, e6, f#11; `scripts/check-agents-md.sh`                                                 |

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
