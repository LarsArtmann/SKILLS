---
name: code-quality-scan
description: Runs build, lint, and code duplication analysis to surface all code quality issues in one pass using automated tools. Use when the user asks to check code quality, scan for issues, run build and lint, find code duplication, or wants a sorted list of all problems. Also triggers on "code quality", "lint my project", "static analysis", "code smells", "technical debt", "what's wrong with my code", "how healthy is this codebase", "quality check", or any request to audit overall codebase health. Distinct from full-code-review (human-style manual file-by-file review including architecture and type safety) and deduplicate-code (deep duplication analysis with harmful-vs-intentional judgment).
metadata:
  tags: quality, build, lint, duplication, issues, scan
allowed-tools: bash view edit grep
---

# Code Quality Scan

## Process

0. **Detect build system and tools.** See [./references/tool-guidance.md](./references/tool-guidance.md) for the full tool matrix per language.
   - If `flake.nix` exists: use `nix build`, `nix flake check`, `nix run .#test`, `nix run .#lint`
   - Else if `go.mod` exists: use `go build ./...`, `go vet ./...`, `go test ./...`
   - Else: detect from the table in tool-guidance.md

1. **Run the build command.** If it fails, every build error is a Critical finding.

2. **Run the lint command.** For Go: `golangci-lint run ./...` (or `go vet ./...` as fallback). Map each finding to a severity using the classification in tool-guidance.md.

3. **Run the duplicate code finder.**
   - Use `art-dupl --type-aware --sort total-tokens -t 5 --html` for Go
   - If `art-dupl` is not installed, fall back to `jscpd`
   - See [./references/tool-guidance.md](./references/tool-guidance.md) → Go duplication

4. **Collect and classify all findings** by severity (Critical / High / Medium / Low).

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
