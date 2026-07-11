# Build Guide: Creating or Rebuilding Each Doc

> Detailed procedures for creating each project doc from code.
> Code is the source of truth. Docs, commit messages, and roadmaps are
> leads, not evidence.

## Table of contents

1. [README.md](#readmemd)
2. [AGENTS.md](#agentsmd)
3. [FEATURES.md](#featuresmd)
4. [TODO_LIST.md](#todo_listmd)
5. [ROADMAP.md](#roadmapmd)
6. [CHANGELOG.md](#changelogmd)
7. [docs/DOMAIN_LANGUAGE.md](#docsdomain_languagemd)

---

## README.md

**Audience:** End-users who do not know the project. This is the sales page.

### What to study

1. Read the project's entry points (main module, CLI commands, package exports).
2. Read the dependency file (go.mod, package.json, requirements.txt) to
   understand what the project IS.
3. Read existing docs (if any) for tone and claims, but verify against code.

### Structure

Copy [../../assets/README-template.md](../../assets/README-template.md) and fill in:

1. **One-line hook.** What this project does, in plain English. No jargon.
2. **Why it exists.** The problem it solves, in one paragraph.
3. **Installation.** Exact commands. Test them mentally against the dependency file.
4. **Quick start.** The simplest path from install to working result. 3 to 5 steps.
5. **Usage examples.** 2 to 3 concrete examples of the most common use cases.

### Quality checklist

- [ ] Install commands would actually work on a clean machine
- [ ] No internal architecture, no AI context, no developer notes
- [ ] Feature claims match `FEATURES.md` (if it exists)
- [ ] Links point at files that exist

---

## AGENTS.md

**Audience:** AI agents starting a new session in this project.

### What to study

1. Walk the directory structure. Note what each top-level directory does.
2. Read the build/task system (flake.nix, Makefile, package.json scripts).
3. Find non-obvious patterns: naming conventions, error handling style, test
   structure, framework choices.
4. Find gotchas: things that would surprise a new contributor. Hidden config,
   implicit dependencies, platform-specific behavior.
5. Check for project-specific instructions or conventions.

### Structure

Copy [../../assets/AGENTS-template.md](../../assets/AGENTS-template.md) and fill in:

1. **Project type and purpose.** One paragraph: what kind of project, what it
   produces, what it does NOT produce.
2. **Directory structure.** Tree diagram with one-line annotations.
3. **Conventions.** Naming patterns, code style, error handling approach.
4. **Build/test/lint commands.** Exact commands. Point at flake.nix or
   equivalent.
5. **Gotchas.** Non-obvious behaviors, workarounds, platform quirks.
6. **High-value references.** Links to the most important docs or files.

### Quality checklist

- [ ] Every referenced path exists
- [ ] Commands actually work
- [ ] No change logs, no task lists, no feature status (those have other homes)
- [ ] Lean: only things hard to discover from code
- [ ] Counts are computed, not hardcoded

---

## FEATURES.md

**Audience:** Developers, PMs, and contributors who need an honest inventory.

### What to study

1. Walk entry points (main, routers, handlers, CLI commands, exported packages).
   Map what the system actually does, not what docs claim.
2. Read implementations, not just signatures.
3. For each feature, open the code and confirm it works (tests pass or you
   exercised it).

### Structure

Copy [../../assets/FEATURES-template.md](../../assets/FEATURES-template.md) and
fill in. Group by domain area. One row per user-visible feature (not per
function or endpoint).

### Status vocabulary

| Status                    | When it applies                                              |
| ------------------------- | ------------------------------------------------------------ |
| FULLY_FUNCTIONAL          | Code present AND working (tests pass or you exercised it).   |
| PARTIALLY_FUNCTIONAL      | Ships but has known gaps, edge-case bugs, or missing pieces. |
| BROKEN                    | Code exists but does not work / is disabled / fails.         |
| PLANNED                   | Designed or documented but **no code exists yet**.           |

### Quality checklist

- [ ] Never round up: if you cannot confirm, it is `PARTIALLY_FUNCTIONAL` at best
- [ ] `PLANNED` items have genuinely no code (verified)
- [ ] `FULLY_FUNCTIONAL` items have been exercised or tested
- [ ] Notes cite evidence (`file:line`)
- [ ] If `README.md` or `TODO_LIST.md` claim features that the code contradicts,
      flag the discrepancy

### Granularity guidance

- "Rate limiting" IS a feature (user-visible behavior).
- "Database connection pooling" is NOT a feature (infrastructure detail).
- "OAuth login" IS a feature.
- "Refactored auth middleware" is NOT a feature (internal change).
- When in doubt: would a user recognize this name on a feature list?

---

## TODO_LIST.md

**Audience:** Developers and agents who need to know what to work on next.

### What to study

1. Read EVERY `.md` file in the project. Extract every TODO, action item,
   implicit task, and planned improvement.
2. For large projects, use sub-agents (one per file, sequentially, never
   parallel).
3. Verify each TODO against code. Many documented TODOs are already done.

### Sub-agent guidance

When dispatching a sub-agent to read a file, tell it:

> "Read file X. Extract every TODO, action item, planned improvement, and
> implicit task. Return a structured list with source line numbers. Do NOT
> interpret or judge. Extract verbatim first."

### Structure

Copy [../../assets/TODO_LIST-template.md](../../assets/TODO_LIST-template.md)
and fill in. Rank by impact (High / Medium / Low). Estimate effort.

### Quality checklist

- [ ] Each item verified against code (is it already done?)
- [ ] Deduplicated by semantic intent, not by text match
- [ ] Vague items ("improve X") either refined or relegated to `ROADMAP.md`
- [ ] No long-term vision items (those go in `ROADMAP.md`)
- [ ] Evidence cited (`file:line`)
- [ ] For deeper 80/20 prioritization, the `pareto-planning` skill can rank
      the resulting list. But enumeration happens here first.

---

## ROADMAP.md

**Audience:** Stakeholders who need to understand long-term direction.

### What to study

1. Read `TODO_LIST.md` for items that were too vague or too long-term.
2. Read project discussions, issues, and any planning docs.
3. Read git history for patterns of investment (where has the team been
   spending effort?).
4. Look at the codebase architecture for natural next directions.

### Structure

Copy [../../assets/ROADMAP-template.md](../../assets/ROADMAP-template.md) and
fill in:

1. **Themes.** 3 to 5 high-level directions (not tasks).
2. **Raw ideas per theme.** Unrefined concepts, not bounded tasks.
3. **Explicit non-goals.** What is deliberately NOT being pursued.

### Quality checklist

- [ ] No bounded, actionable tasks (those go in `TODO_LIST.md`)
- [ ] No status indicators on individual items (this is vision, not inventory)
- [ ] Ideas are raw and unrefined by design
- [ ] Still relevant to current project direction

---

## CHANGELOG.md

**Audience:** Consumers upgrading between versions.

### What to study

1. Read `git log` since the last tagged release.
2. Read `FEATURES.md` for shipped features that may not be logged yet.
3. Read breaking changes (API removals, config format changes, behavior changes).

### Structure

Copy [../../assets/CHANGELOG-template.md](../../assets/CHANGELOG-template.md)
and fill in. Follow the [Keep a Changelog](https://keepachangelog.com/) format:

```
## [version] - date

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Vulnerability fixes
```

### Quality checklist

- [ ] Every entry matches a real change in git history
- [ ] Version numbers match tags
- [ ] Breaking changes are prominent
- [ ] No planning, no feature status, no internal context

---

## docs/DOMAIN_LANGUAGE.md

**Audience:** Developers and agents who need to understand the project's
ubiquitous language.

### What to study

1. Extract domain terms from type names, function names, and business logic.
2. Read existing docs, README, and comments for domain vocabulary.
3. Look for terms used inconsistently (same concept, different names in
   different modules).
4. Look for terms used in code that have no documented definition.

### Structure

Copy [../../assets/DOMAIN_LANGUAGE-template.md](../../assets/DOMAIN_LANGUAGE-template.md)
and fill in:

1. **Glossary table.** Term, definition, where used in code.
2. **Bounded contexts.** Terms that have different meanings in different parts
   of the system.
3. **Deprecated terms.** Old vocabulary still in code but being phased out.

### Quality checklist

- [ ] Every term still used in the codebase
- [ ] No code terms missing definitions
- [ ] Definitions accurate and agreed upon
- [ ] No implementation details (this is domain language, not API docs)
