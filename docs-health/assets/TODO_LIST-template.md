<!-- TODO_LIST.md template, copy into the project root and fill in.
     This is a LIVING document (Markdown), kept up-to-date as work is done.
     Never convert it to HTML, tools upsert and grep it. See docs-health/SKILL.md. -->

# TODO List

> Short-term, actionable, bounded work items, verified against the actual code.
> For long-term vision and unrefined ideas, use ROADMAP.md.
> Items are ranked by impact. Status is verified, not assumed.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed, external dependency or decision needed.     |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

## High Impact

| Task                       | Status    | Impact | Effort | Evidence                                 |
| -------------------------- | --------- | ------ | ------ | ---------------------------------------- |
| Fix session revocation 500 | 🔴 `TODO` | High   | 30min  | `auth/revoke.go:42`, panics on nil token |
| Add OAuth (Google) flow    | 🔴 `TODO` | High   | 2h     | Referenced in README; no code yet        |

## Medium Impact

| Task                     | Status    | Impact | Effort | Evidence                               |
| ------------------------ | --------- | ------ | ------ | -------------------------------------- |
| Add password reset retry | 🔴 `TODO` | Med    | 1h     | `auth/reset.go:42`, retry loop missing |

## Low Impact

| Task                       | Status    | Impact | Effort | Evidence                                          |
| -------------------------- | --------- | ------ | ------ | ------------------------------------------------- |
| Update README install step | 🔴 `TODO` | Low    | 10min  | `README.md:15`, still references old package name |

---

<!-- Guidance for the builder filling this in:
  - Source of truth is the CODE. Verify each item before adding, many
    documented TODOs are already done.
  - One task per row. If it takes more than ~2 hours, split it into smaller
    tasks.
  - Cite evidence (file:line) so the next person can verify without re-deriving.
  - DONE items should be REMOVED, not kept. Use CHANGELOG.md for history.
  - If a task is vague ("improve X"), refine it into concrete steps or move
    it to ROADMAP.md.
  - Deduplicate by semantic intent, not by text match.
  - For 80/20 impact prioritization, use the pareto-planning skill AFTER
    building the list here.
-->
