---
name: status-report
description: Generates a full comprehensive status update of the project — what's done, what's broken, what's partially complete, and what to do next. Use when the user asks for a status update, progress report, project status, "STATUS UPDATE", "WHAT'S THE STATUS", "where are we", "what's the state of the project", "project health", "progress check", "what's done", "what's left", or wants a snapshot of current project state. Also fires when the user wants to know what's fucked up or what to prioritize next. Distinct from docs-health (maintains TODO_LIST/FEATURES/CHANGELOG/ROADMAP — use status-report for a point-in-time snapshot, docs-health for ongoing doc maintenance).
metadata:
  tags: status, report, progress, tracking
---

# Status Report

FULL COMPREHENSIVE & DETAILED STATUS UPDATE! RIGHT NOW! THEN WAIT FOR INSTRUCTIONS!

## Format

INCLUDE WORK:

- a) FULLY DONE
- b) PARTIALLY DONE
- c) NOT STARTED
- d) TOTALLY FUCKED UP!
- e) WHAT WE SHOULD IMPROVE!
- f) Top #25 things we should get done next!
- g) Ask your Top #1 question you can NOT figure out yourself!

**"Top #25" is a default, not a ceiling.** If the user asks for more (e.g.
"up to 50"), their instruction wins — but a larger N is a brainstorm, not a
commitment list: most extra items are ROADMAP fuel, and `docs-health` HARVEST
must apply extra routing rigor to them. See the HARVEST anti-patterns in
[`docs-health`](../docs-health/SKILL.md).

## Output

Write a **self-contained styled HTML dashboard** — not a flat Markdown file. A status
report is a point-in-time snapshot meant for human consumption, so it gets the full visual
treatment: stat cards, severity badges, color-coded sections.

> **HTML is the canonical format.** If the user explicitly requests another
> format (e.g. `.md`), honor it — the user's explicit instruction wins. Flag
> the override in your closing message so the spec/usage divergence is
> visible, and do **not** propagate a one-off override back into this skill
> as a new default.

1. Load the shared design system: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
2. Copy the template: [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html)
3. Map each status category to a visual component:
   - **Stat cards** for counts (done / partial / broken / fucked up)
   - **`.card-problem`** for TOTALLY FUCKED UP items
   - **`.card-warning`** for PARTIALLY DONE
   - **`.card-solution`** for FULLY DONE
   - **Badge-coded table** for the Top #25 next tasks (sorted by impact)
4. Write to `docs/status/<YYYY-MM-DD_HH-MM_WELL-NAMED>.html`

## Process

1. Run: `date` (cli) to get the current date-time
2. Write a full status report at `docs/status/<YYYY-MM-DD_HH-MM_WELL-NAMED>.html`
3. Run `git status`, then commit the report with a very detailed message.
4. WAIT FOR FURTHER INSTRUCTIONS!

> Status reports are point-in-time snapshots that go stale. When a later task
> asks to bring old status reports current, use
> [`docs-health`](../docs-health/SKILL.md) → **ANNOTATE** mode — annotate
> non-destructively (inline correction or end-of-file appendix), never rewrite.

> **After the report is written, the loop is not closed.** Section **(f) Top N
> things to get done next** is the primary input for `docs-health` HARVEST — it
> belongs in `TODO_LIST.md` / `ROADMAP.md`, not entombed in this timestamped
> file. If the session continues and `TODO_LIST.md` was not updated from this
> report, run HARVEST now:
> [`docs-health`](../docs-health/SKILL.md) → **HARVEST** (the canonical rule
> for why and how lives there — do not restate it here).
