# SKILLS

A curated collection of [Agent Skills](https://agentskills.io) for [Crush](https://crush.land) — structured, discoverable skill directories that turn raw expertise into repeatable, high-quality agent workflows.

## What Are Agent Skills?

An Agent Skill is a self-contained directory with a `SKILL.md` entrypoint. Crush loads it in three stages — metadata first, full instructions on trigger, bundled references on demand — keeping context lean while delivering depth exactly when needed.

## The Collection

**24 skills** organized by domain. Quality indicators reflect current state: **🟢 Solid** (comprehensive, production-ready), **🟡 Functional** (works but thin), **🔴 Draft** (needs fleshing out), **🆕 New** (structurally valid, never yet triggered against real work — ages into 🟢 after a documented successful run).

### Shared Assets

| Skill               | What It Does                                                                       | Status   |
| ------------------- | ---------------------------------------------------------------------------------- | -------- |
| **html-report-kit** | Shared HTML report design system with dark-dashboard and editorial-light templates | 🟢 Solid |

> **Vendored, not cross-referenced.** Consumer skills don't reach into a sibling `html-report-kit/` directory (that breaks under per-skill install via `bunx skills add <repo>@<one-skill>`). Instead, the kit is vendored into each consumer's `assets/html-report-kit/`. Edit the canonical `html-report-kit/` at the repo root, then run `./scripts/sync-html-kit.sh` to propagate (use `--check` in CI). See `AGENTS.md` §5.9.

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

### Skill Authoring & Verification

| Skill                      | What It Does                                                                        | Status |
| -------------------------- | ----------------------------------------------------------------------------------- | ------ |
| **verify-before-filing**   | Verify your diagnosis before filing issues/PRs to external projects                 | 🆕 New |
| **verify-external-claims** | Verify external tool/library claims before encoding them into skills, code, or docs | 🆕 New |

### Go Ecosystem

| Skill                        | What It Does                                                                                                                              | Status           |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| **bdd-testing**              | BDD tests with `onsi/ginkgo` for Go projects                                                                                              | 🟢 Solid         |
| **go-ecosystem-upgrade**     | Protocol for bumping/releasing/migrating Go library versions across many consumers — 18 failure modes extracted from 14 real self-reviews | 🟢 Comprehensive |
| **go-modularize**            | Splits Go monorepos into semi-independent sub-modules                                                                                     | 🟢 Comprehensive |
| **go-error-modernization**   | Go 1.26+ error-matching modernization — prevents cargo-cult `errors.As`/`errors.Is` regressions (`erraudit` CLI not publicly findable)    | 🆕 New           |
| **how-to-golang**            | Go development decision guide — what to use, not how                                                                                      | 🟢 Comprehensive |
| **samber-do-best-practices** | Correct samber/do v2 DI usage — lifecycle, scopes, anti-patterns DO-1 → DO-6                                                              | 🆕 New           |

### Nix & DevOps

| Skill                    | What It Does                                                                         | Status           |
| ------------------------ | ------------------------------------------------------------------------------------ | ---------------- |
| **nix-private-go-repos** | Build Go projects with private GitHub deps in Nix — `mkPreparedSource` + `GOPRIVATE` | 🆕 New           |
| **nix-review**           | Reviews and improves `.nix` files — 50+ problems, checklist-driven                   | 🟢 Comprehensive |

### Library & Dependency Research

| Skill                 | What It Does                                                                         | Status           |
| --------------------- | ------------------------------------------------------------------------------------ | ---------------- |
| **library-deep-dive** | Deep-dive audit: is the project using a library to its full potential? → HTML report | 🟢 Comprehensive |

### Project Intelligence

| Skill              | What It Does                                                                                                                 | Status           |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| **docs-health**    | Creates, verifies, and maintains all project docs (living AND historical) — BUILD, HARVEST, VERIFY, ANNOTATE modes           | 🟢 Solid         |
| **status-report**  | Full project status updates as styled HTML dashboards                                                                        | 🟡 Functional    |
| **website-launch** | Launches documentation websites (Astro + Starlight + Firebase) with pre-flight checks, color palettes, and go-live checklist | 🟢 Comprehensive |

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

New skills should follow the pattern of [`how-to-golang/`](how-to-golang/) (lean entrypoint + rich references) or [`architecture-visualization/`](architecture-visualization/) (focused, single-purpose).

## Quality & Status

This repository is honest about its state. **19 of 24 skills are solid, comprehensive, or functional** — every established skill has either rich references and templates (the comprehensive ones) or a focused, complete procedure (the solid ones). A handful are still **functional** (`architecture-review`, `code-quality-scan`, `deduplicate-code`, `status-report`) — they work and trigger correctly but would benefit from deeper reference material. **Five skills are 🆕 New** (`go-error-modernization`, `nix-private-go-repos`, `samber-do-best-practices`, `verify-before-filing`, `verify-external-claims`) — structurally valid and based on real concepts, but they have not yet been triggered against real work. Three of these carry verification-status blocks (`go-error-modernization` for its `erraudit` CLI that is not publicly findable, `nix-private-go-repos` for its private `go-nix-helpers` dependency, `samber-do-best-practices` for its private `branching-flow/pkg/doanalyzerv2` reference) — the skills' value rests on durable concepts, not on the specific private tooling. Validate the repo anytime with `scripts/check-skills.sh`.

See [`docs/status/`](docs/status/) for detailed audit reports, including a comprehensive breakdown of every skill's strengths, gaps, and recommended next steps.

## Contributing

Improvements welcome. The highest-impact contributions:

1. **Deepen functional skills** — `architecture-review`, `code-quality-scan`, and `status-report` work but would benefit from richer `references/` and output templates
2. **Fix cross-skill references** — when one skill finds an issue, point to the sibling skill that fixes it
3. **Validate code snippets** — wrong examples are worse than no examples
4. **Test trigger descriptions** — verify skills activate on realistic user prompts

Read `how-to-write-skills.md` before authoring new skills. Run `scripts/check-skills.sh` to validate structure and catch regressions (it fails on the `git commit <--` artifact, frontmatter mismatches, and missing fields).
