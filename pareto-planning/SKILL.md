---
name: pareto-planning
description: Use when the user wants to plan work, break down a TODO list, identify high-impact tasks, prioritize work, or says "MAKE A PLAN", "PARETO", "comprehensive plan", "prioritize", "what should I work on first", "impact analysis", "task prioritization", "what's the 80/20", "break this down", or wants tasks sorted by impact and effort. Creates a comprehensive execution plan using the Pareto principle (80/20 breakdown).
metadata:
  tags: planning, pareto, prioritization, d2, execution-graph
allowed-tools: d2
---

# Pareto Planning

> **Input:** Takes an existing `TODO_LIST.md` (or task list) and ranks it.
> To create or verify `TODO_LIST.md` first, use the `docs-health` skill.

## Process

### Step 1: Pareto Breakdown

Let's figure out what we should really do!

- What are the 20% that deliver 80% of the result??! — BREAK IT DOWN!
- What are the 4% that deliver 64% of the result??! — BREAK IT DOWN!
- What are the 1% that deliver 51% of the result??! — BREAK IT DOWN!
- Start with 1%, then do 4%, then do the 20% — Then report back with everything else we still need to get done!

### Step 2: Comprehensive Plan (Medium granularity)

MAKE SURE TO CREATE A VERY COMPREHENSIVE PLAN FIRST!
Split the TODOs into small tasks 100min to 30min each (up to 27 tasks total)! It should include ALL TODOS! UNDERSTAND???!
Sort all by importance/impact/effort/customer-value.
REPORT BACK WITH A TABLE VIEW WHEN DONE!

### Step 3: Detailed Breakdown (Fine granularity)

THEN BREAK DOWN THE VERY COMPREHENSIVE & DETAILED PLAN INTO EVEN SMALLER TODOs!
EACH tasks max 15min each (up to 150 tasks total)! It should include ALL TODOS! UNDERSTAND???!
Sort all by importance/impact/effort/customer-value.
REPORT BACK WITH A TABLE VIEW WHEN DONE!

### Step 4: Write Plan to File

WRITE YOUR PLAN as a **self-contained styled HTML report** — not a flat Markdown file.
A Pareto plan is a point-in-time snapshot with rich structure (tiers, tables, execution
graphs) that benefits from visual treatment.

1. Load the shared design system: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
2. Copy the template: [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html)
3. Render the D2 execution graph to SVG via `d2 plan.d2 plan.svg`, then inline the SVG
   directly in the HTML `<body>` (no external file dependency).
4. Map plan structure to components:
   - **Stat cards** for task counts per Pareto tier (1% / 4% / 20%)
   - **Badge-coded tables** for tasks sorted by impact/effort
   - **`.card-problem`** for blockers, **`.card-solution`** for quick wins
5. Write to `docs/planning/<YYYY-MM-DD_HH_MM-SUPERB_NAME>.html`

NOTE: Use the cli to get the current date.

## Execution

BE SMART! Use your Brain! Let's go!

> Plans are point-in-time artifacts that go stale. When a later task asks to
> bring old plans current, use [`docs-health`](../docs-health/SKILL.md) →
> **ANNOTATE** mode — annotate non-destructively, never rewrite the original plan.

> **If this plan surfaced NEW tasks** not already in `TODO_LIST.md`, add them
> there (the plan is a snapshot; `TODO_LIST.md` is the living source). To pull
> items out of this plan in bulk, run [`docs-health`](../docs-health/SKILL.md)
> → **HARVEST**.

Remember: If you VERSCHLIMMBESSER this system, I will cut off your balls! I hope we understand each other!

## Git Workflow

1. Before you start, make sure our repo/git is clean. Run `git status`, then commit any pending work with a very detailed message.
2. After each significant change: run `git status`, then commit with a very detailed message.
3. Do not push unless the user explicitly requests it.

## Full Execution Mode

After the plan is approved:

```
NOW GET SHIT DONE! The WHOLE TODO LIST! Keep going until everything works and you think you did a great job!
WE HAVE ALL THE TIME IN THE WORLD, DO NOT STOP UNTIL THE ENTIRE LIST IS FINISHED and VERIFIED!
BTW: DO NOT BREAK BUILD & Use MULTIPLE Tasks to get multiple of your Todos done at the same time!
```
