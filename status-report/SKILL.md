---
name: status-report
description: Use when the user asks for a status update, progress report, project status, "STATUS UPDATE", "WHAT'S THE STATUS", "where are we", "what's the state of the project", "project health", "progress check", "what's done", "what's left", or wants a snapshot of current project state. Also fires when the user wants to know what's fucked up or what to prioritize next. Generates a full comprehensive status update of the project — what's done, what's broken, what's partially complete, and what to do next. Distinct from docs-health (maintains TODO_LIST/FEATURES/CHANGELOG/ROADMAP — use status-report for a point-in-time snapshot, docs-health for ongoing doc maintenance) and from brutal-self-review (critique of recent work quality — ghost systems, split brains, improvement plan; this skill inventories work-item state).
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

For what each section should contain and common pitfalls, see
[./references/section-quality-guide.md](./references/section-quality-guide.md).

**"Top #25" is a default, not a ceiling.** If the user asks for more (e.g.
"up to 50"), their instruction wins — but a larger N is a brainstorm, not a
commitment list: most extra items are ROADMAP fuel, and `docs-health` HARVEST
must apply extra routing rigor to them. See the HARVEST anti-patterns in
[`docs-health`](../docs-health/SKILL.md).

## Output

Write the report as a **Markdown file** at the repo's
`docs/status/YYYY-MM-DD_HH-MM_*.md` convention (DECIDED 2026-10-27, D.g4 —
`docs/decisions/2026-10-27_open-decisions.md` §D: the user demanded `.md`
explicitly twice and the pattern recurred 8×; `.md` is now the default, not
an override).

> **HTML is for dashboard-shaped content.** When the report is metric-heavy —
> scores, counts, severity matrices, before/after visuals — write a
> self-contained styled HTML dashboard instead (stat cards, severity badges,
> color-coded sections) via the design-system steps below. Plain narrative
> status → `.md`; dashboard → HTML. Either way the user's explicit format
> request wins; do **not** propagate a one-off override back into this skill
> as a new default.
>
> **Historical note:** before 2026-10-27 HTML was the canonical format and
> `.md` the flagged exception (8 documented recurrences); the decision
> inverted the default. The Bauhaus HTML kit remains in
> `assets/html-report-kit/` for dashboard use.

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
3. Run `git status`, then commit the report with a very detailed message —
   UNLESS the harness forbids commits without an explicit user request
   (Crush: "NEVER COMMIT unless the user says commit"). In that case skip
   the manual commit: the auto-commit daemon picks the file up within
   seconds, and forcing a commit here would violate the harness contract.
4. WAIT FOR FURTHER INSTRUCTIONS!

> Status reports are point-in-time snapshots that go stale. When a later task
> asks to bring old status reports current, use
> [`docs-health`](../docs-health/SKILL.md) → **ANNOTATE** mode — annotate
> non-destructively (inline correction or end-of-file appendix), never rewrite.

> **After the report is written, the loop is not closed.** Section **(f) Top N
> things to get done next** is the primary input for `docs-health` HARVEST — it
> belongs in `TODO_LIST.md` / `ROADMAP.md`, not entombed (written into a
> timestamped file that no later session reads) in this timestamped
> file. If the session continues and `TODO_LIST.md` was not updated from this
> report, run HARVEST now:
> [`docs-health`](../docs-health/SKILL.md) → **HARVEST** (the canonical rule
> for why and how lives there — do not restate it here).

## Related Skills

- **brutal-self-review** — critique of recent work quality (what was forgotten,
  ghost systems (a capability that exists in the repo but was never wired into
  the product), split brains
  (the same concept defined or configured in two places, so the two drift apart),
  improvement plan), not a state inventory. Sessions
  often run both: this report answers "where are we", the self-review answers
  "what did we get wrong". Their output sections do not overlap.
