---
name: full-code-review
description: Use when the user wants a full codebase review, every file reviewed, deep quality audit, or says "visit every file", "review everything", "full review", "audit my code", "code review", "review the whole codebase", "deep review", "comprehensive review", or wants every file checked for type safety, architecture issues, split brains, duplications, and code smells. Performs a comprehensive code review visiting every single code and test file as a Senior Software Architect. Distinct from code-quality-scan (automated tool scan, no manual reading) and architecture-review (structural focus only, not file-by-file).
metadata:
  tags: code-review, architecture, audit, type-safety, quality, architect, go
---

# Full Code Review

## DO

1. List all files, by line count and all files by bytes.
2. To figure out what's really going on, visit every single code and test file 1 at the time.
3. READ. REVIEW. CRITICISE. THINK.
4. Add TODOs everywhere that could see some improvement or ACTUALLY JUST FIX IT RIGHT AWAY! Be super nitpicky!
5. MAKE SURE TO VALUE TYPE-SAFETY VERY HIGHLY!

## Architect Checklist

For the full checklist of questions to ask per file, load [./references/architect-checklist.md](references/architect-checklist.md).

## Planning Phase

1. Before you start, make sure our repo/git is clean. Run `git status`, then commit any pending work with a very detailed message.

2. **Delegate planning to the `pareto-planning` skill.** Do not re-implement Pareto
   breakdown, task splitting, or the D2 execution graph here — that duplication is a
   split brain (the same concept maintained in two places, so the two drift apart). Load
   `pareto-planning/SKILL.md` and follow its process. It produces a
   styled HTML plan with stat cards, badge-coded task tables, and an inline D2 execution
   graph at `docs/planning/<YYYY-MM-DD_HH_MM-NAME>.html`.

3. Once the plan is written, return here and continue with the code review execution.

4. Do not verschlimmbessern — a well-intentioned edit that makes things worse. No speculative rewrites; every change must leave the system demonstrably no worse than you found it.

## Output

Write the review findings as a **self-contained styled HTML report** at
`docs/reviews/<YYYY-MM-DD_HH-MM_full-code-review.html`.

A full code review produces a point-in-time audit of every file — issues,
split brains, type-safety concerns, duplications — which benefits from
visual treatment.

1. **Read prior reports in the series.** List `docs/reviews/*.html` and skim the
   most recent 1-3 (TOC + findings tables) — cross-reference prior reviews and
   their unresolved findings instead of re-discovering them as new.
2. Load the shared design system: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
3. **Copy the template, never transcribe.** Start from [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html) by copying the file and editing its content — never re-type CSS or structure from memory or another report's rendered source; hand-transcribed CSS drifts from the kit and re-introduces bugs the kit already fixed.
4. Map findings to visual components:
   - **Stat cards** for files reviewed / issues found / split brains / TODOs added / fixed on the spot
   - **`.card-problem`** for type-safety issues, split brains, duplications
   - **`.card-warning`** for smaller improvements, naming smells, debt to ticket
   - **`.card-solution`** for strong patterns and good work to preserve
   - **Badge-coded tables** with columns: #, Severity, File, Line, Issue, Fix
5. If you identified significant duplications, reference and delegate to the
   `deduplicate-code` skill.
6. If documentation drift is a major finding, reference and delegate to the
   `docs-health` skill for a full documentation audit.
7. This review's HTML report is a point-in-time snapshot; it goes stale. When a
   later task asks to bring old review reports current, use the `docs-health`
   ANNOTATE mode (annotate non-destructively — never rewrite history).
   Likewise, when adding TODOs/annotations across many files during this review,
   apply its restraint discipline: specific over generic, per-file judgment over
   blanket scripting.

> **Unfixed findings are forward-looking work.** Recommendations and "debt to
> ticket" that were not fixed on the spot or added as inline TODOs belong in
> `TODO_LIST.md`, not entombed (written into a timestamped file no later
> session reads) in `docs/reviews/`. Run
> [`docs-health`](../docs-health/SKILL.md) → **HARVEST** to pull them out of
> this snapshot.

## Git Workflow

- Before starting: run `git status`, then commit any pending work with a very detailed message.
- After each significant change: run `git status`, then commit with a very detailed message.
- Do not push unless the user explicitly requests it.
- WAIT FOR FURTHER INSTRUCTIONS!

NOTE: Use the cli to get the current date.
