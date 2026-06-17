# SKILLS

A curated collection of [Agent Skills](https://agentskills.io) for [Crush](https://crush.land) — structured, discoverable skill directories that turn raw expertise into repeatable, high-quality agent workflows.

## What Are Agent Skills?

An Agent Skill is a self-contained directory with a `SKILL.md` entrypoint. Crush loads it in three stages — metadata first, full instructions on trigger, bundled references on demand — keeping context lean while delivering depth exactly when needed.

## The Collection

**20 skills** organized by domain. Quality indicators reflect current state: **🟢 Solid** (comprehensive, production-ready), **🟡 Functional** (works but thin), **🔴 Draft** (needs fleshing out).

### Shared Assets

| Skill               | What It Does                                                         | Status   |
| ------------------- | -------------------------------------------------------------------- | -------- |
| **html-report-kit** | Shared dark-theme HTML design system for all report-producing skills | 🟢 Solid |

### Architecture & Design

| Skill                          | What It Does                                                        | Status           |
| ------------------------------ | ------------------------------------------------------------------- | ---------------- |
| **architecture-review**        | Reviews architecture for scalability, modularity, and composability | 🟡 Thin          |
| **architecture-visualization** | Generates D2 architecture diagrams — current state vs. ideal target | 🟢 Solid         |
| **data-model-review**          | Reviews and redesigns data models using Go's type system            | 🟢 Comprehensive |
| **pareto-planning**            | 80/20 execution plans with D2 dependency graphs                     | 🟢 Comprehensive |

### Code Quality & Review

| Skill                  | What It Does                                                          | Status           |
| ---------------------- | --------------------------------------------------------------------- | ---------------- |
| **brutal-self-review** | Brutally honest self-review of codebase state (Go projects)           | 🟢 Solid         |
| **code-quality-scan**  | Build, lint, and semantic duplication analysis → HTML issue dashboard | 🟡 Thin          |
| **deduplicate-code**   | Find and eliminate semantic code duplication                          | 🟡 Thin          |
| **full-code-review**   | Comprehensive review visiting every code and test file                | 🟢 Comprehensive |
| **naming-review**      | Audits and improves naming for types, functions, and identifiers      | 🟢 Comprehensive |

### Go Ecosystem

| Skill             | What It Does                                          | Status           |
| ----------------- | ----------------------------------------------------- | ---------------- |
| **bdd-testing**   | BDD tests with `onsi/ginkgo` for Go projects          | 🟡 Thin          |
| **go-modularize** | Splits Go monorepos into semi-independent sub-modules | 🟢 Comprehensive |
| **how-to-golang** | Go development decision guide — what to use, not how  | 🟢 Comprehensive |

### Nix & DevOps

| Skill                   | What It Does                                                         | Status           |
| ----------------------- | -------------------------------------------------------------------- | ---------------- |
| **nix-flake-migration** | Migration proposals from justfile/shell scripts to Nix flakes → HTML | 🟡 Thin          |
| **nix-review**          | Reviews and improves `.nix` files — 50+ problems, checklist-driven   | 🟢 Comprehensive |

### Project Intelligence

| Skill                    | What It Does                                           | Status   |
| ------------------------ | ------------------------------------------------------ | -------- |
| **docs-freshness-check** | Verifies docs are up-to-date with the actual codebase  | 🟡 Thin  |
| **execution-mode**       | Two modes: deep reflection or aggressive execution     | 🟢 Solid |
| **features-audit**       | Creates/updates `FEATURES.md` by studying actual code  | 🟡 Thin  |
| **status-report**        | Full project status updates as styled HTML dashboards  | 🟡 Thin  |
| **todo-list-builder**    | Builds `TODO_LIST.md` from docs, verified against code | 🟢 Solid |

## Quick Start

Install the entire collection:

```bash
npx skills add https://github.com/LarsArtmann/SKILLS
```

Or add to your project's `crush.json`:

```json
{
  "options": {
    "skills_paths": ["/path/to/SKILLS"]
  }
}
```

Or copy individual skill directories into `.agents/skills/` or `~/.config/crush/skills/`.

Once installed, mention a skill's trigger phrase and Crush loads it automatically. Example: say "review my Go architecture" and `architecture-review` activates — no manual lookup needed.

## Skill Anatomy

Every skill follows the same directory convention:

```
skill-name/
├── SKILL.md          # Required: YAML frontmatter + step-by-step instructions
├── scripts/          # Optional: executable helpers (run without loading into context)
├── references/       # Optional: detailed docs loaded on demand via `view`
├── rules/            # Optional: domain-specific constraints loaded on demand
└── assets/           # Optional: templates, images, sample data
```

The best skills keep `SKILL.md` under ~500 lines and move deep material into `references/`. The agent reads these on demand, keeping initial context small.

## Writing New Skills

See [`how-to-write-skills.md`](how-to-write-skills.md) for the authoritative guide on crafting effective skills — frontmatter rules, trigger descriptions, progressive disclosure, and common mistakes.

New skills should follow the pattern of [`how-to-golang/`](how-to-golang/) (lean entrypoint + rich references) or [`execution-mode/`](execution-mode/) (focused, single-purpose).

## Quality & Status

This repository is honest about its state. **12 skills are solid or comprehensive** and ready for daily use. **8 skills are thin** — they trigger correctly but need reference files, concrete examples, and output templates to produce consistently great results.

See [`docs/status/`](docs/status/) for detailed audit reports, including a comprehensive breakdown of every skill's strengths, gaps, and recommended next steps.

## Contributing

Improvements welcome. The highest-impact contributions:

1. **Flesh out thin skills** — add `references/` with concrete examples and output templates
2. **Fix cross-skill references** — when one skill finds an issue, point to the sibling skill that fixes it
3. **Validate code snippets** — wrong examples are worse than no examples
4. **Test trigger descriptions** — verify skills activate on realistic user prompts

Read `how-to-write-skills.md` before authoring new skills. Keep the `git commit <--` typo out of your work.
