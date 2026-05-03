---
name: brutal-self-review
description: Triggers a brutally honest self-review of recent work and the current codebase state (Go projects). Use when the user asks for self-reflection, self-critique, wants to know what was forgotten, what's stupid, what could be better, find ghost systems, split brains, or wants a comprehensive improvement plan with Go ecosystem library awareness.
metadata:
  tags: review, self-critique, honesty, go, architecture, improvement
---

# Brutal Self-Review

ALWAYS be BRUTALLY HONEST! NEVER LIE TO THE USER!

## Self-Review Questions

Answer every question with full honesty:

1. What did you forget?
2. What is something that's stupid that we do anyway?
3. What could you have done better?
4. What could you still improve?
5. Did you lie to me?
6. How can we be less stupid?
7. Is everything correctly integrated or are we building ghost systems? IF you find a 'ghost system' ALWAYS ask yourself should this be integrated? What value is in it? FIRST!
8. Are we focusing on the scope creep trap?
9. Did we remove something that was actually useful?
10. Did we create ANY split brains? Even small things that could be considered split brain!
11. How are we doing on tests? What can we do better, regarding automated testing?

## Execution Plan

1. Create a Comprehensive Multi-Step Execution Plan (keep each step small)!
2. Sort them by work required vs impact.
3. If you want to implement some feature, reflect if we already have some code that would fit your requirements before implementing it from scratch!
4. Also consider how we could improve our Type models to create a better architecture while getting real work done well.
5. Do NOT reinvent the wheel!! ALWAYS consider how we can use & leverage already well established libs to make our live easier!
6. If you find a Ghost system, report back and make sure you integrate it.
7. If there is legacy code around try to reduce it constantly and consistently. Our target for legacy code is ZERO.

## Architectural Review

- Which architectural decisions we made in the past are causing problems now / could be improved?
- Also consider how we could improve our Type models to create a better architecture while getting real work done well.
- Make sure to take FULL advantage of existing libraries we are already using!

For Go ecosystem libraries, architecture patterns, banned libraries, and required stack, use the `how-to-golang` skill. Load its SKILL.md at `/home/lars/projects/SKILLS/how-to-golang/SKILL.md` and follow its references for detailed library decisions, domain types, key patterns, and banned dependencies.

## Git Workflow

Report back and ask questions if necessary aka. have a hard time to figure something out!
Run "git status & git commit ..." after each smallest self-contained change.
Run "git push" when done.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
