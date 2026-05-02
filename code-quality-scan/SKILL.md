---
name: code-quality-scan
description: Runs build, lint, and code duplication analysis to surface all code quality issues. Use when the user asks to check code quality, run build and lint, find code duplication, or wants a sorted list of all issues. Also checks for nix flake availability.
---

# Code Quality Scan

## Process

0. Check if `nix build` / `nix flake check` / `nix run .#test` / `nix run .#lint` are available. If so, use those instead of justfile. If neither exists, use whatever build system the project has.

1. Run the build command
2. Run the lint command
3. Run the duplicate code finder (if available)

## Code Duplication

If "just fd" does not exist yet: Add "just find-duplicates" with "fd" as a native justfile alias — RESEARCH the best golang code duplication finder before you implement it! — Do NOT reinvent the wheel!! ALWAYS consider how we can use & leverage already well established libs to make our live easier!

## Output

Create a sorted list of all our issues!
Max 250 small tasks.

## Execution

```
READ, UNDERSTAND, RESEARCH, REFLECT. Break this down into multiple actionable steps.
Think about them again. Execute and Verify them one step at the time. Repeat until done.
Keep going until everything works and you think you did a great job!
```

[!WARNING] NEEDS TO BE UPDATED TO USE nix flakes!
