---
name: full-code-review
description: Performs a comprehensive code review visiting every single code and test file as a Senior Software Architect. Use when the user wants a full codebase review, every file reviewed, deep quality audit, or says "visit every file", "review everything", "full review". Checks type safety, architecture, split brains, duplications, and fixes or adds TODOs on the spot. Includes Pareto-based planning and prioritization.
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

## Mindset

You are a Software Architect with the Highest possible standards. With everything you do, you ONLY do a great Job! Nothing less!

READ. REVIEW. CRITICISE. THINK.

## Architect Checklist

For the full checklist of questions to ask per file, load [./references/architect-checklist.md](references/architect-checklist.md).

## Planning Phase

1. Before you start, make sure our repo/git is clean. Run: `git status & git commit <-- with VERY DETAILED commit message(s) & git push`

2. **Delegate planning to the `pareto-planning` skill.** Do not re-implement Pareto
   breakdown, task splitting, or the D2 execution graph here — that duplication is a
   split brain. Load `pareto-planning/SKILL.md` and follow its process. It produces a
   styled HTML plan with stat cards, badge-coded task tables, and an inline D2 execution
   graph at `docs/planning/<YYYY-MM-DD_HH_MM-NAME>.html`.

3. Once the plan is written, return here and continue with the code review execution.

4. Remember: If you VERSCHLIMMBESSER this system, I will cut off your balls! I hope we understand each other!

5. BE SMART! Use your Brain! Let's go!

## Git Workflow

- Before starting: `git status & git commit <-- with VERY DETAILED commit message(s) & git push`
- After each significant change: `git status & git commit <-- with VERY DETAILED commit message(s) & git push`
- When done: `git push`
- WAIT FOR FURTHER INSTRUCTIONS!

NOTE: Use the cli to get the current date.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
