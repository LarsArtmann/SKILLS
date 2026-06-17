---
name: docs-freshness-check
description: Checks if core project documentation files are up-to-date with the current codebase state. Use when the user asks to verify docs, check if TODO_LIST.md, FEATURES.md, README.md, or AGENTS.md are current, or says "docs up to date".
metadata:
  tags: documentation, freshness, verification, docs
---

# Docs Freshness Check

Verify that the project's core documentation reflects the **current** codebase, then fix what has drifted. Documentation that lies is worse than missing documentation — it actively misleads every reader (human and agent) who trusts it.

## What "stale" means

A doc is stale when its claims contradict the code. Check each file against these specific failure modes:

| Failure mode         | Example                                                           |
| -------------------- | ----------------------------------------------------------------- |
| **Counted wrong**    | "18 skills" when there are 19; "see `foo.go`" when it's renamed   |
| **Points at ghosts** | References a file, symbol, command, or path that no longer exists |
| **Missing reality**  | A shipped feature or new file the doc doesn't mention             |
| **Contradicts code** | Doc says X works; code shows X is broken, disabled, or removed    |
| **Wrong commands**   | Build/test/run instructions that fail when executed               |
| **Stale status**     | Claims a known issue is open when it's fixed (or vice versa)      |

A doc is **fresh** only when you can confirm its concrete claims against the code. "Looks fine" is not a freshness check — open the files it names and verify.

## Files to check

Start with the canonical doc set, then extend to anything the project keeps current:

| File                                  | What to verify against the code                                        |
| ------------------------------------- | ---------------------------------------------------------------------- |
| `README.md`                           | Install/run commands work; feature/status claims match reality         |
| `AGENTS.md`                           | Architecture, conventions, gotchas, counts, and tool lists are current |
| `FEATURES.md`                         | Every listed feature's status matches what the code actually does      |
| `TODO_LIST.md`                        | Completed items removed; no item already done; no missing obvious work |
| `flake.nix` / `justfile` / `Makefile` | Documented commands exist and run                                      |

Extend this list per project: any doc the team treats as authoritative belongs here. If the project has `docs/DOMAIN_LANGUAGE.md`, `ROADMAP.md`, or ADRs, include them.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT — never trust a doc at face value.

1. **Inventory the docs.** List the files above that exist in this project. Note any that are missing but should exist.

2. **Read each doc, then verify against code.** For every concrete claim — a count, a file path, a command, a status, a feature — open the referenced code and confirm. Treat doc claims as hypotheses to test, not facts.

3. **Classify each finding.** For each stale item, record: the file, the line, what it says, what reality is, and the fix. This makes the report auditable and prevents half-fixes.

4. **Fix drift in place.** Update the doc to match the code (the code is the source of truth). Prefer computing counts/paths from the actual repo over hardcoding numbers — hardcoded counts rot the fastest. If a count must be stated, point at a command that recomputes it.

5. **Report honestly.** State what was stale and fixed, what was already fresh, and anything you could not verify (and why). Do not claim "all docs verified" if you skipped any.

## Rules

- **Code is the source of truth.** When doc and code disagree, the code wins — fix the doc.
- **Never hardcode counts** that the repo can compute (`scripts/check-skills.sh`, `wc -l`, `ls`). Numbers are the first thing to rot.
- **Fix ghosts immediately.** A reference to a deleted file or renamed symbol misleads every reader; it's a 10-second fix with outsized value.
- **One pass, one report.** Don't edit piecemeal without tracking — a classified finding list ensures nothing is missed and makes the work reviewable.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
