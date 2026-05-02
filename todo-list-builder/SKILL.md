---
name: todo-list-builder
description: Creates or updates TODO_LIST.md by reading all .md files in the project using sub-agents, then verifies which TODOs are already done by checking the actual code. Use when the user wants to build a comprehensive TODO list from existing documentation, verify TODO status against code, or says "build TODO list".
---

# TODO List Builder

## Phase 1: Build from Documentation

Your job is to create a `TODO_LIST.md`!

1. READ ALL .md files 1 at the time!
2. After you read ONE .md file: UPSERT the existing `TODO_LIST.md`!
3. Then READ THE NEXT .md file!
4. Also document inside the `TODO_LIST.md` which files you already read and which you know you still need to READ!

Use 1 Sub Agent per file. ONLY 1 Agent at the same time. If an Agent does not respond properly, ask again with a smaller / split up request.

```
READ, UNDERSTAND, RESEARCH, REFLECT. Break this down into multiple actionable steps.
Think about them again. Execute and Verify them one step at the time. Repeat until
done. Keep going until everything works and you think you did a great job!
```

## Phase 2: Verify Against Code

Now your job is to:

A) Figure out, by reading the actual code file, if some of these TODOs are already done
B) How much they were done, are they properly integrated and so on and so forth...
C) Update each `TODO_LIST.md` to represent all these accordingly AND make sure to de-duplicate the TODOs
D) Repeat until all files are done

## Internal TODO Structure

WHEN YOU CREATE YOUR OWN INTERNAL TODO LIST FOR THIS SESSION, MAKE SURE TO structure it like this:

- Let Agent READ FILE X, and verify/research the current code based on the claims
- Update TODO_LIST.md with critical findings from file X
- git commit TODO_LIST.md
- Let Agent READ FILE Y, and ...
- Update TODO_LIST.md with critical findings from file Y
- git commit TODO_LIST.md
- ...
