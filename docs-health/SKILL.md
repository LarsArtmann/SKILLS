---
name: docs-health
description: >
  Creates, verifies, and maintains ALL core project documentation — FEATURES.md,
  TODO_LIST.md, README.md, AGENTS.md, ROADMAP.md, CHANGELOG.md,
  docs/DOMAIN_LANGUAGE.md. Understands which file owns which information and
  enforces consistency between them. Use when the user wants to build a TODO
  list, audit features, check if docs are up-to-date or fresh, create or rebuild
  any project doc, detect documentation drift, split brains, or misplaced
  information, or says "docs health", "feature audit", "build TODO list",
  "docs up to date", "documentation audit", "fix my docs", "are my docs current".
metadata:
  tags: documentation, freshness, features, todo, audit, consistency, verification
---

# Docs Health

Create missing docs, verify freshness against code, and enforce consistency
between files. Documentation that lies is worse than missing documentation —
it actively misleads every reader (human and agent) who trusts it.

## The documentation model

Each file has ONE job. Each fact lives in exactly ONE place. When the same
fact appears in multiple files, they drift — and the reader cannot tell which
is current.

| File                      | Owns                                           | Lifecycle   |
| ------------------------- | ---------------------------------------------- | ----------- |
| `README.md`               | What this is, why it exists, how to start      | Living      |
| `docs/DOMAIN_LANGUAGE.md` | Domain terms and definitions                   | Living      |
| `AGENTS.md`               | Non-obvious context for AI sessions            | Living      |
| `FEATURES.md`             | What features exist + honest status            | Living      |
| `TODO_LIST.md`            | Short-term actionable work                     | Living      |
| `ROADMAP.md`              | Long-term vision, raw ideas not yet actionable | Living      |
| `CHANGELOG.md`            | What changed in each version                   | Append-only |

For the full ownership rules — what goes where, what does NOT go where,
anti-patterns, and how information flows between files as it matures — load
[./references/doc-ownership.md](./references/doc-ownership.md).

## Determine the task

Identify what the user needs from their request:

| User says                                        | Task       | Action                                          |
| ------------------------------------------------ | ---------- | ----------------------------------------------- |
| "Build TODO list" / "create FEATURES.md"         | **BUILD**  | Generate a specific doc from code               |
| "Are docs up to date?" / "check freshness"       | **VERIFY** | Check all docs against code, fix drift in place |
| "Full doc audit" / "fix my docs" / "docs health" | **AUDIT**  | BUILD missing docs, then VERIFY everything      |

If the intent is ambiguous, default to AUDIT — it covers everything.

---

## BUILD: create or rebuild a doc from code

Code is the source of truth. Docs, commit messages, and roadmaps are leads,
not evidence. Open the files and confirm.

### FEATURES.md

1. **Study the code.** Walk entry points (main, routers, handlers, CLI
   commands, exported packages). Map what the system actually does, not what
   docs claim. Read implementations, not just signatures.

2. **Enumerate user-visible features.** Group by domain area (Authentication,
   Billing, Search…). One row per feature a user would recognize — not per
   function or endpoint. If three endpoints serve one feature, that is one row.

3. **Verify each status by opening the code:**

   | Status                    | When it applies                                              |
   | ------------------------- | ------------------------------------------------------------ |
   | 🟢 `FULLY_FUNCTIONAL`     | Code present AND working (tests pass or you exercised it).   |
   | 🟡 `PARTIALLY_FUNCTIONAL` | Ships but has known gaps, edge-case bugs, or missing pieces. |
   | 🔴 `BROKEN`               | Code exists but does not work / is disabled / fails.         |
   | ⚪ `PLANNED`              | Designed or documented but **no code exists yet**.           |

4. **Copy the template** from
   [./assets/FEATURES-template.md](./assets/FEATURES-template.md), fill it in.
   If the file already exists, update rows in place rather than rewriting.

5. **Never round up.** If you cannot confirm a feature works, it is
   `PARTIALLY_FUNCTIONAL` at best. Honesty is the entire point of this file.

6. **Reconcile.** If `README.md` or `TODO_LIST.md` claim features that the
   code contradicts, flag the discrepancy — do not silently copy claims.

### TODO_LIST.md

1. **Read every .md file** in the project. Extract every TODO, action item,
   implicit task, and planned improvement. For large projects, use sub-agents
   (one per file, sequentially — never parallel).

2. **Verify each TODO against code.** Many documented TODOs are already done.
   Grep for mentioned symbols, check if referenced files exist, look for tests
   that cover the described gap. Mark findings.

3. **Deduplicate by semantic intent**, not by text match. Merge items that
   describe the same underlying work from different angles.

4. **Rank by impact** (High / Medium / Low) and estimate effort. For deeper
   80/20 prioritization, the `pareto-planning` skill can rank the resulting
   list — but enumeration happens here first.

5. **Enforce boundaries.** Exclude anything that belongs in `ROADMAP.md`
   (long-term, unrefined ideas). `TODO_LIST.md` is for bounded, actionable
   work only. If a task is vague ("improve X"), refine it or relegate it to
   `ROADMAP.md`.

6. **Copy the template** from
   [./assets/TODO_LIST-template.md](./assets/TODO_LIST-template.md), fill it
   in. If the file already exists, update in place.

**Sub-agent guidance:** when dispatching a sub-agent to read a file, tell it:
"Read file X. Extract every TODO, action item, planned improvement, and
implicit task. Return a structured list with source line numbers. Do NOT
interpret or judge — extract verbatim first."

---

## VERIFY: check freshness and consistency

A doc is fresh only when you can confirm its concrete claims against the code.
"Looks fine" is not a freshness check — open the files it names and verify.

### Failure modes (ranked by severity)

| Severity    | Failure mode     | Example                                                        |
| ----------- | ---------------- | -------------------------------------------------------------- |
| 🔴 Critical | Points at ghosts | References a deleted file, renamed symbol, or dead command     |
| 🔴 Critical | Wrong commands   | Build/test/run instructions that fail when executed            |
| 🟡 Medium   | Contradicts code | Doc says X works; code shows X is broken, disabled, or removed |
| 🟡 Medium   | Stale status     | Claims an issue is open when it is fixed (or vice versa)       |
| 🟡 Medium   | Missing reality  | A shipped feature or new file the doc does not mention         |
| 🟢 Low      | Counted wrong    | "18 skills" when there are 19                                  |
| 🟢 Low      | Cosmetic         | Typos, broken links, stale dates                               |

### Process

1. **Inventory the docs.** List the files from the documentation model that
   exist in this project. Note any that are missing but should exist.

2. **Read each doc, then verify against code.** For every concrete claim — a
   count, a file path, a command, a status, a feature — open the referenced
   code and confirm. Treat doc claims as hypotheses to test, not facts.

3. **Classify each finding.** Record: the file, the line, what it says, what
   reality is, the severity, and the fix. This makes the work auditable and
   prevents half-fixes.

4. **Fix drift in place.** Update the doc to match the code (the code is the
   source of truth). Prefer computing counts and paths from the actual repo
   over hardcoding numbers — hardcoded counts rot the fastest.

5. **Check cross-file consistency** (docs vs docs):

   | Check              | What to verify                                                         |
   | ------------------ | ---------------------------------------------------------------------- |
   | Status consistency | `FEATURES.md` says `BROKEN` but `README.md` markets it as working      |
   | No duplication     | The same fact stated in multiple files (will drift)                    |
   | Correct ownership  | TODOs leaking into `FEATURES.md`; features leaking into `TODO_LIST.md` |
   | Valid cross-refs   | `README.md` links to files that exist; `AGENTS.md` paths are real      |

### Rebuild vs patch

If a single doc has drift exceeding ~50% of its claims, rebuild it from
scratch using BUILD mode instead of patching line by line. A patch-heavy doc
accumulates scars; a rebuild starts from truth.

### Fix rules

- **Code wins.** When doc and code disagree, fix the doc.
- **Never hardcode counts** that the repo can compute (`wc -l`, `ls`,
  `scripts/check-skills.sh`). Point at a command that recomputes the number.
- **Fix ghosts immediately** — a reference to a deleted file misleads every
  reader. It is a 10-second fix with outsized value.

---

## AUDIT: full documentation health check

1. **Inventory.** List which docs exist, which are missing. Note any that
   should exist but do not.

2. **BUILD missing docs.** If `FEATURES.md` or `TODO_LIST.md` do not exist,
   build them using BUILD mode before proceeding.

3. **VERIFY all docs.** Run the full VERIFY process on every doc in the
   documentation model.

4. **Check cross-file consistency.** Run every consistency check. The most
   common rot: the same feature listed in both `TODO_LIST.md` (as done) and
   `FEATURES.md` (as planned) because nobody removed it when it shipped.

5. **Report honestly.** Group findings by severity. State what was stale and
   fixed, what was already fresh, and what you could not verify (and why). Do
   not claim "all docs verified" if you skipped any.

---

## Process

READ, UNDERSTAND, RESEARCH, REFLECT — never trust a doc at face value.

Break the work into actionable steps. Think about them again. Execute and
verify one step at a time. Repeat until done. Keep going until everything
works and you think you did a great job!
