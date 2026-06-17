---
name: status-report
description: Generates a full comprehensive status update of the project. Use when the user asks for a status update, progress report, "STATUS UPDATE", "WHAT'S THE STATUS", or wants to know what's done, what's broken, and what's next. Writes a styled HTML dashboard to docs/status/.
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

## Output

Write a **self-contained styled HTML dashboard** — not a flat Markdown file. A status
report is a point-in-time snapshot meant for human consumption, so it gets the full visual
treatment: stat cards, severity badges, color-coded sections.

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
3. `git status & git commit <-- with VERY DETAILED commit message(s)`
4. WAIT FOR FURTHER INSTRUCTIONS!

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
