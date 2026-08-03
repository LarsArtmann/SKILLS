<!-- AGENTS.md template, copy into the project root and fill in.
     This is CONCISE, ENDURING CONTEXT for AI agents.
     Only things hard to discover from code. No changelogs, no task lists.

     SIZE BUDGET: 5-15 KB sweet spot. Under 1 KB = skeleton. Over 30 KB =
     bloated (you are duplicating content that belongs elsewhere).

     ENDURANCE TEST: every line must be true 6 months from now. If it
     references a version, date, sprint, or commit hash, it fails.

     See docs-health/references/agents-quality-guide.md for the full
     anti-pattern catalog, pruning guide, and quality scoring rubric. -->

# AGENTS.md, Project Name

> Context for AI agents working in this repository.

## What This Is

One paragraph: what kind of project, what it produces, what it does NOT
produce. This is the single most important section — a fresh session reads
this first to orient.

## Directory Structure

```
project/
├── src/            # one-line annotation (top-level only, ≤10 entries)
├── tests/          # one-line annotation
└── flake.nix       # build and task automation
```

Do NOT annotate every file. Top-level directories only, one line each.
A 95-line tree annotating every file rots on every rename.

## Commands

```bash
nix build          # build
nix run .#test     # test
nix run .#lint     # lint
```

These are the highest-value content. Verify every command actually works.

## Architecture

Key design decisions, invariants, and data flow — NOT full API docs.
Maximum 5 lines of inline code per example; beyond that, link to source.
If an agent could regenerate this by reading the code, delete it.

## Conventions

- **Naming:** patterns used in the codebase
- **Code style:** functional/imperative, error handling approach
- **Testing:** framework, file naming, test structure

## Gotchas

Non-obvious behaviors, workarounds, platform quirks. Cap at 15-20 entries.
Each entry must be a CURRENT constraint, not a resolved incident.

Do NOT put here: resolved bugs, sprint-dated refactors, "was X, now Y".
Those belong in CHANGELOG.md or git history, not enduring context.

## Dependencies

Key libraries and WHY they were chosen. One line each.

## High-Value References

| File                      | Why it matters                       |
| ------------------------- | ------------------------------------ |
| `docs/DOMAIN_LANGUAGE.md` | Domain vocabulary                    |
| `FEATURES.md`             | Feature inventory with honest status |

---

<!-- Guidance for the builder:
  - Every referenced path must exist. Verify after writing.
  - Commands must actually work. Test them.
  - Counts must be computed, not hardcoded. Point at a command.
  - Keep it LEAN: only things hard to discover from code.
  - TARGET SIZE: 5-15 KB. If you exceed 15 KB, review for bloat.
  - Do NOT put: change logs (CHANGELOG.md), tasks (TODO_LIST.md),
    feature status (FEATURES.md), domain terms (DOMAIN_LANGUAGE.md),
    version numbers in headings, commit hashes, sprint numbers,
    code blocks >5 lines, resolved incidents, coverage percentages.
  - ENDURANCE TEST: would this be true in 6 months? If not, cut it.
-->
