---
name: docs-health
description: >
  Creates, verifies, and maintains ALL core project documentation: FEATURES.md,
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
between files. Documentation that lies is worse than missing documentation: it
actively misleads every reader (human and agent) who trusts it.

## The documentation model

Each file has ONE job. Each fact lives in exactly ONE place. When the same
fact appears in multiple files, they drift, and the reader cannot tell which
is current.

| File                      | Owns                                            | Lifecycle   |
| ------------------------- | ----------------------------------------------- | ----------- |
| `README.md`               | What this is, why it exists, how to start       | Living      |
| `docs/DOMAIN_LANGUAGE.md` | Domain terms and definitions                    | Living      |
| `AGENTS.md`               | Non-obvious context for AI sessions             | Living      |
| `FEATURES.md`             | What features exist + honest status             | Living      |
| `TODO_LIST.md`            | Short-term actionable work                      | Living      |
| `ROADMAP.md`              | Long-term vision, raw ideas not yet actionable  | Living      |
| `CHANGELOG.md`            | What changed in each version                    | Append-only |
| `docs/adr/`               | Architecture decisions (context, decision, why) | Optional    |

For the full ownership rules, anti-patterns, information lifecycle, and a
"where agents store what" matrix, load
[./references/doc-ownership.md](./references/doc-ownership.md).

### Adapt to project type

Not every project needs all docs. Detect the project type and adapt:

| Project type      | Must-have docs                       | Optional docs                       |
| ----------------- | ------------------------------------ | ----------------------------------- |
| Content repo      | README, AGENTS                       | FEATURES (adapted), CHANGELOG       |
| Library / package | README, CHANGELOG, FEATURES          | AGENTS, DOMAIN_LANGUAGE             |
| Web app / service | README, FEATURES, TODO_LIST          | AGENTS, DOMAIN_LANGUAGE, ROADMAP    |
| Monorepo          | README, AGENTS, FEATURES per package | DOMAIN_LANGUAGE per bounded context |

---

## Determine the task

Identify what the user needs from their request:

| User says                                        | Task       | Action                                          |
| ------------------------------------------------ | ---------- | ----------------------------------------------- |
| "Build TODO list" / "create FEATURES.md"         | **BUILD**  | Generate a specific doc from code               |
| "Are docs up to date?" / "check freshness"       | **VERIFY** | Check all docs against code, fix drift in place |
| "Full doc audit" / "fix my docs" / "docs health" | **AUDIT**  | BUILD missing docs, then VERIFY everything      |

If the intent is ambiguous, default to AUDIT (it covers everything).

---

## BUILD: create or rebuild a doc from code

Code is the source of truth. Docs, commit messages, and roadmaps are leads,
not evidence. Open the files and confirm.

For detailed BUILD procedures, examples, and quality checklists for each doc
type, load [./references/build-guide.md](./references/build-guide.md).

### Quick reference: which template to use

| Doc                       | Template (copy into project, fill in)                                        |
| ------------------------- | ---------------------------------------------------------------------------- |
| `README.md`               | [./assets/README-template.md](./assets/README-template.md)                   |
| `AGENTS.md`               | [./assets/AGENTS-template.md](./assets/AGENTS-template.md)                   |
| `FEATURES.md`             | [./assets/FEATURES-template.md](./assets/FEATURES-template.md)               |
| `TODO_LIST.md`            | [./assets/TODO_LIST-template.md](./assets/TODO_LIST-template.md)             |
| `ROADMAP.md`              | [./assets/ROADMAP-template.md](./assets/ROADMAP-template.md)                 |
| `CHANGELOG.md`            | [./assets/CHANGELOG-template.md](./assets/CHANGELOG-template.md)             |
| `docs/DOMAIN_LANGUAGE.md` | [./assets/DOMAIN_LANGUAGE-template.md](./assets/DOMAIN_LANGUAGE-template.md) |

### Status vocabulary for FEATURES.md

| Status               | When it applies                                              |
| -------------------- | ------------------------------------------------------------ |
| FULLY_FUNCTIONAL     | Code present AND working (tests pass or you exercised it).   |
| PARTIALLY_FUNCTIONAL | Ships but has known gaps, edge-case bugs, or missing pieces. |
| BROKEN               | Code exists but does not work / is disabled / fails.         |
| PLANNED              | Designed or documented but **no code exists yet**.           |

Never round up. If you cannot confirm a feature works, it is
`PARTIALLY_FUNCTIONAL` at best. Honesty is the entire point of this file.

### BUILD rules

- **Code wins.** When doc and code disagree, fix the doc.
- **Cite evidence** (`path/to/file.go:NN`) so the next reader can verify.
- **Verify each claim.** Many documented TODOs are already done. Grep before
  trusting a doc claim.
- **Upsert, do not rewrite.** If the file already exists, update rows in place
  rather than rewriting from scratch.

---

## VERIFY: check freshness and consistency

A doc is fresh only when you can confirm its concrete claims against the code.
"Looks fine" is not a freshness check. Open the files it names and verify.

For per-file verification checklists (what to check in each doc type), load
[./references/verify-checklist.md](./references/verify-checklist.md).

### Failure modes (ranked by severity)

| Severity | Failure mode     | Example                                                        |
| -------- | ---------------- | -------------------------------------------------------------- |
| Critical | Points at ghosts | References a deleted file, renamed symbol, or dead command     |
| Critical | Wrong commands   | Build/test/run instructions that fail when executed            |
| Medium   | Contradicts code | Doc says X works; code shows X is broken, disabled, or removed |
| Medium   | Stale status     | Claims an issue is open when it is fixed (or vice versa)       |
| Medium   | Missing reality  | A shipped feature or new file the doc does not mention         |
| Low      | Counted wrong    | "18 skills" when there are 19                                  |
| Low      | Cosmetic         | Typos, broken links, stale dates                               |

### VERIFY process

1. **Inventory the docs.** List the files from the documentation model that
   exist. Note any that are missing but should exist.

2. **Read each doc, then verify against code.** For every concrete claim (a
   count, a file path, a command, a status, a feature), open the referenced
   code and confirm. Treat doc claims as hypotheses to test, not facts.

3. **Classify each finding.** Record: the file, the line, what it says, what
   reality is, the severity, and the fix. This makes the work auditable.

4. **Fix drift in place.** Update the doc to match the code. Prefer computing
   counts and paths from the actual repo over hardcoding numbers: hardcoded
   counts rot the fastest.

5. **Check cross-file consistency** (docs vs docs). The most common rot: a
   shipped feature still listed in `TODO_LIST.md` while `FEATURES.md` says
   `FULLY_FUNCTIONAL`. See the cross-file consistency table in
   [./references/verify-checklist.md](./references/verify-checklist.md).

### Rebuild vs patch

If a single doc has drift exceeding ~50% of its claims, rebuild it from
scratch using BUILD mode instead of patching line by line. A patch-heavy doc
accumulates scars; a rebuild starts from truth. For the full decision tree,
load [./references/common-mistakes.md](./references/common-mistakes.md).

### Fix rules

- **Code wins.** When doc and code disagree, fix the doc.
- **Never hardcode counts** that the repo can compute (`wc -l`, `ls`,
  `scripts/check-skills.sh`). Point at a command that recomputes the number.
- **Fix ghosts immediately.** A reference to a deleted file misleads every
  reader. It is a 10-second fix with outsized value.

---

## AUDIT: full documentation health check

### Process

1. **Inventory.** List which docs exist, which are missing. Note any that
   should exist but do not.

2. **BUILD missing docs.** If `FEATURES.md` or `TODO_LIST.md` do not exist,
   build them using BUILD mode before proceeding.

3. **VERIFY all docs.** Run the full VERIFY process on every doc in the
   documentation model.

4. **Check cross-file consistency.** Run every consistency check. The most
   common rot: the same feature listed in both `TODO_LIST.md` (as done) and
   `FEATURES.md` (as planned) because nobody removed it when it shipped.

5. **Report.** Present findings using the health report format below.

### Health report format

Print an inline summary table to the conversation (do NOT write to a file):

```
## Documentation Health Report

**Health Score: 7/10**

| Doc                  | Exists | Fresh | Critical | Medium | Low |
|----------------------|--------|-------|----------|--------|-----|
| README.md            | Yes    | Yes   | 0        | 0      | 1   |
| AGENTS.md            | Yes    | Yes   | 0        | 0      | 0   |
| FEATURES.md          | Yes    | No    | 0        | 2      | 0   |
| TODO_LIST.md         | Yes    | No    | 1        | 1      | 0   |
| DOMAIN_LANGUAGE.md   | No     | -     | -        | -      | -   |
| ROADMAP.md           | No     | -     | -        | -      | -   |
| CHANGELOG.md         | Yes    | Yes   | 0        | 0      | 0   |

### Findings by severity

#### Critical (1)
- TODO_LIST.md:15 references deleted file `auth/old.go` (ghost)

#### Medium (3)
- FEATURES.md:12 says FULLY_FUNCTIONAL but tests fail for password reset
- FEATURES.md:18 missing OAuth feature that shipped in v1.2
- TODO_LIST.md:8 already done (session revocation fixed in commit abc123)

#### Low (1)
- README.md:25 typo: "instalation" should be "installation"
```

**Health Score formula:** Start at 10. Subtract:

- 1 point per Critical finding
- 0.5 points per Medium finding
- 0.25 points per Low finding
- 1 point per missing must-have doc

Floor at 0. This gives a trackable metric across audits.

### Report rules

- State what was stale and fixed, what was already fresh, and what you could
  not verify (and why).
- Do NOT claim "all docs verified" if you skipped any.
- If you fixed issues during the audit, report both the original finding and
  the fix applied.

---

## Common mistakes and decision trees

For detailed examples (good vs bad doc entries), decision trees (TODO vs
ROADMAP, AGENTS.md vs DOMAIN_LANGUAGE.md, rebuild vs patch), and common
mistakes per doc type, load
[./references/common-mistakes.md](./references/common-mistakes.md).

---

## Process

READ, UNDERSTAND, RESEARCH, REFLECT. Never trust a doc at face value.

Break the work into actionable steps. Think about them again. Execute and
verify one step at a time. Repeat until done. Keep going until everything
works and you think you did a great job!
