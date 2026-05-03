# SKILLS

A collection of [Agent Skills](https://agentskills.io) for [Crush](https://crush.land) — converted from raw prompt snippets into structured, discoverable skill directories.

## What's Here

15 skills, each a self-contained directory with a `SKILL.md` entrypoint:

| Skill                          | What It Does                                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| **architecture-review**        | Reviews architecture for scalability, modularity, and composability                                          |
| **architecture-visualization** | Generates D2 architecture diagrams — current state vs ideal                                                  |
| **bdd-testing**                | BDD tests with onsi/ginkgo for Go projects                                                                   |
| **brutal-self-review**         | Brutally honest self-review of codebase state (Go projects)                                                  |
| **code-quality-scan**          | Build, lint, and duplication analysis                                                                        |
| **deduplicate-code**           | Semantic code de-duplication                                                                                 |
| **docs-freshness-check**       | Verifies docs are up-to-date with code                                                                       |
| **execution-mode**             | Two modes: deep reflection (`READ, UNDERSTAND, RESEARCH, REFLECT`) or aggressive execution (`GET SHIT DONE`) |
| **features-audit**             | Creates/updates `FEATURES.md` from actual code                                                               |
| **full-code-review**           | Comprehensive code review visiting every file                                                                |
| **nix-review**                 | Reviews and improves .nix files — 50 problems, 52 checklist items, systemd hardening                        |
| **nix-flake-migration**        | Migration proposals from justfile/shell scripts to nix flakes                                                |
| **pareto-planning**            | 80/20 execution plans with D2 graphs                                                                         |
| **status-report**              | Full project status updates written to `docs/status/`                                                        |
| **todo-list-builder**          | Builds `TODO_LIST.md` from docs, verified against code                                                       |

## Skill Structure

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable helpers
├── references/       # Optional: detailed docs loaded on demand
├── rules/            # Optional: domain-specific constraints
└── assets/           # Optional: templates, images
```

## Installation

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

Or copy individual skill directories into your project's `.agents/skills/` or global `~/.config/crush/skills/`.

## Writing New Skills

See [`how-to-write-skills.md`](how-to-write-skills.md) for a comprehensive guide on crafting effective skills.

## Status

All 15 skills are complete with validated frontmatter and metadata. See [`docs/status/`](docs/status/) for detailed progress reports.
