# Feedback Loop — `docs/feedback/`

> Moved verbatim from `AGENTS.md` §11 (2026-10-11) to keep the agent context
> file small. Update this file, not AGENTS.md. The compact §11 in AGENTS.md
> carries the operative rules and links here.

## The Problem This Section Solves

Prior to 2026-07-13, agents wrote detailed feedback files after sessions,
documenting what went wrong and what skills would have prevented it. **None
of those feedback files were ever converted into skills.** Each subsequent
session ignored the feedback, repeated the same research, made the same
mistakes, and wrote the same feedback. Six sessions created the same
website-launch workflow, each wasting 45-90 minutes rediscovering the
pattern. The feedback loop was broken: feedback was written but never
acted upon.

## How the Feedback Loop Works Now

```
Session produces feedback  →  Feedback lives in docs/feedback/new/
                             ↓
Agent reads feedback       →  Before starting similar work, scan docs/feedback/
                             ↓
Feedback converted to skill →  When a pattern appears 2+ times, create a skill
                             ↓
Feedback archived           →  Move to docs/feedback/processed/
```

## Directory Structure

```
docs/feedback/
├── new/           # Unprocessed feedback — read before starting similar work
└── processed/     # Feedback that has been converted into a skill or resolved
```

## Agent Instructions

1. **Before starting work** on a multi-step task (website creation, Firebase
   setup, DNS configuration, CI pipeline setup), scan `docs/feedback/new/`
   for relevant feedback. The feedback files contain hard-won knowledge
   about what goes wrong.

2. **After creating a skill** from feedback, move the source feedback files
   from `new/` to `processed/` to indicate they have been acted upon.

3. **When a pattern appears 2+ times** across feedback files, convert it
   into a skill. Do not write a third feedback file saying "we should
   create a skill for this" — create the skill instead.

4. **Feedback files are not status reports.** A feedback file documents
   what went wrong and what would prevent it. A status report documents
   what was done. Write feedback only when there are actionable lessons
   that should be encoded into skills.

## What Makes Good Feedback

Good feedback is specific enough to act on:

- **What happened** — the exact symptom, error message, or time sink
- **Why it's a problem** — the impact (wasted time, broken output, missed
  step)
- **What a skill should contain** — the exact commands, decision trees,
  checklists, or pitfalls that would prevent it
- **Impact estimate** — minutes saved per session, number of sessions
  affected

Bad feedback is vague: "The process was inefficient and could be improved."
