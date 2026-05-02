---
name: execution-mode
description: Sets the agent into a focused execution mode with two variants. Use when the user says "READ, UNDERSTAND, RESEARCH, REFLECT" or wants deep reflective planning before action, OR when the user says "GET SHIT DONE" or wants aggressive full-list execution without stopping.
---

# Execution Mode

Two complementary execution modes. Activate when the user signals either one.

## Mode 1: Reflect

Trigger: User says "READ, UNDERSTAND, RESEARCH, REFLECT" or similar reflective intent.

```
READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
```

### Behavior

1. **READ** — Consume all relevant context before touching anything
2. **UNDERSTAND** — Build a mental model of the system, not just surface knowledge
3. **RESEARCH** — Search for existing solutions, patterns, similar code before implementing
4. **REFLECT** — Think critically about the approach before committing to it

Then:
- Break the task into multiple actionable steps
- Think about the steps again (second pass)
- Execute and verify one step at a time
- Repeat until done
- Keep going until everything works and you are confident in the quality

## Mode 2: Execute

Trigger: User says "GET SHIT DONE" or "NOW GET SHIT DONE" or signals aggressive execution.

```
NOW GET SHIT DONE! The WHOLE TODO LIST! Keep going until everything works and you think you did a great job!
WE HAVE ALL THE TIME IN THE WORLD, DO NOT STOP UNTIL THE ENTIRE LIST IS FINISHED and VERIFIED!
```

### Behavior

- Execute the ENTIRE TODO list without stopping
- Do not pause for confirmation between tasks
- Do not stop until every item is finished AND verified
- If something breaks, fix it and keep going
- Only stop when the entire list is complete and everything works
- Use MULTIPLE Tasks to get multiple Todos done at the same time when possible
- DO NOT BREAK BUILD
