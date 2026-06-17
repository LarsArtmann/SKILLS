---
name: features-audit
description: Creates or updates FEATURES.md by studying the actual code to find all features the project has. Use when the user wants a feature inventory, feature list, wants to know what features exist and their status, or says "FEATURES.md" or "feature audit". Includes honest status indicators for each feature.
metadata:
  tags: features, audit, inventory, documentation, honesty
---

# Features Audit

Produce an **honest, code-grounded** inventory of every user-visible feature and its real status. The output is `FEATURES.md` — a living Markdown document that end users and contributors can trust because every status is backed by evidence from the code, not by hopes, README claims, or commit messages.

## Output

`FEATURES.md` is a **living document (Markdown)**, never HTML. It is continuously upserted as features ship, change, or break — tools grep and incrementally edit it. Start from the template: [./assets/FEATURES-template.md](assets/FEATURES-template.md).

## Status vocabulary

Use exactly these statuses so the document stays machine-greppable and unambiguous:

| Status                    | When to use                                                           |
| ------------------------- | --------------------------------------------------------------------- |
| 🟢 `FULLY_FUNCTIONAL`     | Works as intended; you can point to the code **and** confirm it runs. |
| 🟡 `PARTIALLY_FUNCTIONAL` | Ships but has known gaps, edge-case bugs, or missing pieces.          |
| 🔴 `BROKEN`               | Code exists but does not work / is disabled / fails.                  |
| ⚪ `PLANNED`              | Designed or documented but **no code exists yet**.                    |

Never round up. If you cannot confirm a feature works, it is `PARTIALLY_FUNCTIONAL` at best. Honesty is the entire point of this file.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT — the code is the only source of truth.

1. **Study the code.** Walk entry points (main, routers, handlers, CLI commands, exported packages). Map what the system actually _does_, not what docs claim. Read the implementations, not just the signatures.

2. **Enumerate user-visible features.** Group by domain area (Authentication, Billing, Search…). One row per feature a user would recognize — not per function or endpoint. If three endpoints serve one feature, that's one row.

3. **Verify each status against code.** For every feature, open the file and confirm:
   - `FULLY_FUNCTIONAL` → code present **and** working (tests pass or you exercised it).
   - `PARTIALLY_FUNCTIONAL` → cite the specific gap (file:line, missing edge case).
   - `BROKEN` → cite where it fails and why.
   - `PLANNED` → confirm there is genuinely **no** implementation, despite docs implying otherwise.

4. **Upsert `FEATURES.md`.** Copy the template, fill in the matrix, keep notes actionable (cite `file:line` and the concrete gap). If the file already exists, update rows in place rather than rewriting from scratch.

5. **Reconcile with reality.** If `README.md` or `TODO_LIST.md` claim features that the code contradicts, flag the discrepancy — do not silently copy the claim into `FEATURES.md`.

## Rules

- **Code is the source of truth.** Docs, commit messages, and roadmaps are leads, not evidence.
- **Be brutally honest.** A `BROKEN` or `PLANNED` status that surprises the maintainer is a success; an inflated `FULLY_FUNCTIONAL` is a failure.
- **Cite evidence** in Notes (`path/to/file.go:NN`) so the next reader can verify without re-deriving the audit.
- **Markdown, not HTML.** This is a living doc; never convert it.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
