---
name: code-quality-scan
description: Runs build, lint, and code duplication analysis to surface all code quality issues. Use when the user asks to check code quality, run build and lint, find code duplication, or wants a sorted list of all issues.
metadata:
  tags: quality, build, lint, duplication, issues, scan
---

# Code Quality Scan

## Process

0. Check available build systems:
   - If `flake.nix` exists: use `nix build`, `nix flake check`, `nix run .#test`, `nix run .#lint`
   - Else if `justfile` exists: use `just build`, `just lint`
   - Else: use whatever build system the project has

1. Run the build command
2. Run the lint command
3. Run the duplicate code finder:
   - If "just fd" does not exist yet: Add "just find-duplicates" with "fd" as a native justfile alias
   - RESEARCH the best golang code duplication finder before you implement it!
   - Do NOT reinvent the wheel!! ALWAYS consider how we can use & leverage already well established libs!

## Output

Write a **self-contained styled HTML report** — a sorted issue dashboard.

1. Load the shared design system: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
2. Copy the template: [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html)
3. Write to `docs/reviews/<YYYY-MM-DD_HH-MM_code-quality-scan.html`
4. Map issues to visual components:
   - **Stat cards** for counts (total issues / critical / high / medium / low)
   - **Badge-coded table** with columns: #, Severity, File, Line, Issue, Suggested Fix
   - Sort by severity (critical first), then by file
   - Max 250 issues
5. Use `date` CLI for the filename timestamp

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
