# TODO List

> Short-term, actionable, bounded work items. Verified against the actual code
> and harvested from recent status reports in `docs/status/`. For long-term
> vision and unrefined ideas, see `ROADMAP.md`. Items are ranked by impact.
>
> **Source of truth is the code and the git log.** Each item was checked against
> the current state before adding — many documented TODOs from older reports are
> already done and were excluded.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed — external dependency or decision needed.    |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

---

## P0 — Skill Quality & Reliability

These affect whether skills trigger correctly and produce trustworthy output.

| ID  | Task                                                                     | Status    | Impact   | Effort | Evidence                                                                                                |
| --- | ------------------------------------------------------------------------ | --------- | -------- | ------ | ------------------------------------------------------------------------------------------------------- |
| T1  | Run trigger collision analysis across all 25 skills                      | 🔴 `TODO` | Critical | Med    | 9 descriptions broadened 2026-08-02; never tested for overlap. Report: `docs/status/2026-08-02_03-39_*` |
| T2  | Add disambiguation text between overlapping skill pairs                  | 🔴 `TODO` | High     | Low    | `code-quality-scan` vs `full-code-review`; `deduplicate-code` vs `code-quality-scan`; `architecture-review` vs `full-code-review`; `status-report` vs `docs-health` |
| T3  | Audit `verify-before-filing/SKILL.md` body and claims                   | 🔴 `TODO` | High     | Low    | Committed blind from a parallel session (`3a7cc56`); never reviewed. Report: `docs/status/2026-08-02_03-39_*` |
| T4  | Validate `how-to-golang` code snippets for accuracy                     | 🔴 `TODO` | High     | Med    | Known issues: gopter signature, `encoding/json/v2` Go version, E2E HTTP API. Files: `how-to-golang/references/testing-strategy.md`, `required-libraries.md`, `rules.md` |

## P1 — Structural Improvements (prevent recurring failure modes)

These address patterns that have caused repeated problems across multiple sessions.

| ID  | Task                                                                     | Status    | Impact | Effort | Evidence                                                                                                |
| --- | ------------------------------------------------------------------------ | --------- | ------ | ------ | ------------------------------------------------------------------------------------------------------- |
| T5  | Refactor `docs-health/SKILL.md` references-first (500→~350 body)        | 🔴 `TODO` | High   | Med    | At exactly 500/500 lines — same pressure that forced `update-old-docs` refactor. Report: `docs/status/2026-08-04_01-00_*` |
| T6  | Add TOC-integrity guard to `check-skills.sh`                            | 🔴 `TODO` | Med    | Low    | Count `## ` headings vs TOC entries, fail on mismatch. Hit by 2 consecutive sessions. Current guards: structural, hardcoded-count, handoff only |
| T7  | Add marker-vocabulary guard to `check-skills.sh`                        | 🔴 `TODO` | Med    | Low    | Verify docs-health HARVEST references `update-old-docs`-owned markers (`done at`, `Won't implement`, `NOT-DO`). AGENTS.md §5.5 contract |
| T8  | Reconcile scoring systems in docs-health                                | 🔴 `TODO` | Med    | Low    | `agents-quality-guide.md` has 5-dimension rubric; `health-report-format.md` has 2-score (Accuracy+Fitness). Split brain. Report: `docs/status/2026-08-04_00-35_*` |
| T9  | Create `scripts/check-agents-md.sh` linting script                      | 🔴 `TODO` | Med    | Med    | Package temporal-pollution grep patterns into standalone scorer. Currently only in `agents-quality-guide.md` as documented commands |
| T10 | Append appendix-only incident to `update-old-docs/references/case-study.md` | 🔴 `TODO` | Low    | Low    | 4th failure-mode round (currently covers banner Verschlimmbesserung only). Report: `docs/status/2026-08-04_01-00_*` |
| T11 | Add condensing checklist to `how-to-write-skills.md`                    | 🔴 `TODO` | Low    | Low    | Rule: move examples to references FIRST, then trim prose. Prevents the condensing-erodes-teaching-weight cycle |

## P2 — Deepen Thin Skills

These skills pass structural checks but would produce richer output with deeper reference material. Pattern to follow: `how-to-golang` (lean entrypoint + dense references).

| ID  | Task                                                                     | Status    | Impact | Effort | Evidence                                                       |
| --- | ------------------------------------------------------------------------ | --------- | ------ | ------ | -------------------------------------------------------------- |
| T12 | Deepen `architecture-review` — add assessment rubric, methodology       | 🔴 `TODO` | Med    | Med    | 54 lines; flagged thin since 2026-05-03 audit. No rubric       |
| T13 | Deepen `code-quality-scan` — richer references, tool guidance           | 🔴 `TODO` | Med    | Med    | 37 lines; flagged thin since 2026-05-03 audit                  |
| T14 | Deepen `bdd-testing` — ginkgo syntax reference, test structure template | 🔴 `TODO` | Med    | Med    | 40 lines; flagged thin since 2026-05-03 audit                  |
| T15 | Deepen `status-report` — deeper output guidance, template variants      | 🔴 `TODO` | Low    | Med    | 70 lines; flagged functional since 2026-05-03 audit            |
| T16 | Refactor `website-launch` (1106 lines → move content to references)     | 🔴 `TODO` | Low    | Med    | Allowlisted past 500-line guideline; largest skill in repo     |

## P3 — Polish

| ID  | Task                                                                     | Status    | Impact | Effort | Evidence                                                                |
| --- | ------------------------------------------------------------------------ | --------- | ------ | ------ | ----------------------------------------------------------------------- |
| T17 | Update comprehensive audit doc to reflect current state                 | 🔴 `TODO` | Low    | Low    | `docs/status/2026-05-03_07-51_*` predates 10+ sessions of work          |
| T18 | Add "competing skills" disambiguation section to `how-to-write-skills.md` | 🔴 `TODO` | Low    | Low    | Pattern of adjacent skills stepping on triggers is now a real problem |

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
