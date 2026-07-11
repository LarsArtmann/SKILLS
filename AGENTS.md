# AGENTS.md — SKILLS Repository

> _Context for AI agents working in this repository._

**Project:** A collection of [Agent Skills](https://agentskills.io) for [Crush](https://crush.land) — structured, discoverable skill directories converted from raw prompt snippets.

---

## 1. Project Type & Purpose

This is a **documentation-only content repository**. There is no build system, no package manager, no test suite, no CI config. Every skill is a self-contained directory of markdown files (and optionally scripts/assets).

If you are looking for source code to build, test, or lint: **there is none**. The "product" is the markdown content itself.

---

## 2. Directory Structure

```
SKILLS/
├── README.md                    # Project overview, skills table, installation
├── how-to-write-skills.md       # Authoritative guide for writing new skills (currently at root)
├── originals/                   # Legacy raw prompt source material. DO NOT EDIT.
│   └── <skill-name>.md            #   Raw prompts named after the skill they seeded.
│                                 #   Two legacy source prompts produced
│                                 #   multiple files (execution-mode,
│                                 #   pareto-planning). Skills/ directories
│                                 #   are canonical (see docs/status/).
│
├── <skill-name>/                # One directory per skill (18 total)
│   ├── SKILL.md                 # Required: YAML frontmatter + agent instructions
│   ├── scripts/                 # Optional: executable helpers (run without loading into context)
│   ├── references/              # Optional: detailed docs loaded on demand via `view`
│   ├── rules/                   # Optional: domain-specific constraints loaded on demand
│   └── assets/                  # Optional: templates, images, sample data
│
└── docs/
    └── status/                  # Comprehensive audit reports (high-value historical context)
```

### Which files to edit

| File/Dir                       | Action                                                        |
| ------------------------------ | ------------------------------------------------------------- |
| `<skill-name>/SKILL.md`        | Edit freely — this is the work product                        |
| `<skill-name>/references/*.md` | Edit freely — supporting docs                                 |
| `<skill-name>/scripts/*`       | Edit freely — but keep executable                             |
| `originals/*.md`               | **NEVER EDIT** — legacy source material, superseded by skills |
| `README.md`                    | Update when adding/removing skills                            |
| `how-to-write-skills.md`       | Update when skill-writing guidance changes                    |

---

## 3. Skill Format Conventions

### 3.1 `SKILL.md` Frontmatter (Required)

```yaml
---
name: skill-name # lowercase, hyphens, MUST match directory name
description: > # THIS IS A TRIGGER, NOT DOCUMENTATION
  Tells the agent WHEN to activate. Be explicit and pushy.
  Include what it does + exact trigger phrases + adjacent contexts.
  Max ~1024 chars.
metadata:
  tags: foo, bar # comma-separated, helps with discovery
---
```

**Critical nuance:** The `description` is read by Crush's skill selection system. If it is vague, the skill will never activate. If it describes what the skill _contains_ rather than when to _use_ it, the skill will never activate. Study existing good descriptions in `go-modularize`, `nix-review`, `how-to-golang`, `naming-review`.

### 3.2 Body Style

- **Imperative steps**, not essays. The agent follows instructions literally.
- **Keep under ~500 lines**. Move detailed material to `references/` or `rules/`.
- **Reference sibling files** with relative links: `[./references/details.md](./references/details.md)` — the agent will `view` them on demand.
- **Explain the why**, not just the what. Agents follow reasoned instructions more reliably than rigid `ALWAYS`/`MUST`/`NEVER` directives.
- **Define output formats with examples** when producing structured output (reports, plans, etc.).

### 3.3 Progressive Disclosure

| Level             | What's loaded                                  | Cost                                |
| ----------------- | ---------------------------------------------- | ----------------------------------- |
| Metadata          | `name` + `description`                         | ~100 words, always in context       |
| SKILL.md body     | Full instructions                              | <500 lines ideal, loaded on trigger |
| Bundled resources | `references/`, `rules/`, `scripts/`, `assets/` | Unlimited, loaded on demand         |

Large reference files (>300 lines) should include a table of contents at the top.

---

## 4. Authoring a New Skill

1. Read `how-to-write-skills.md` at repo root — the authoritative guide.
2. Create `my-skill/SKILL.md` with valid YAML frontmatter.
3. Add optional `references/`, `scripts/`, `rules/`, `assets/` subdirectories as needed.
4. Update `README.md` to include the new skill in the inventory table.
5. Follow the pattern of `how-to-golang` for rich skills (lean SKILL.md + dense references) or `architecture-visualization` for focused skills (short, single-purpose).

---

## 5. Known Gotchas & Non-Obvious Patterns

### 5.1 Legacy Files (`originals/<skill-name>.md`)

The `originals/` directory holds the raw prompt snippets that seeded
this repository, one per skill directory plus a few sub-variants
(`execution-mode-reflective` / `execution-mode-aggressive`,
`pareto-planning` / `pareto-planning-execution-plan` /
`pareto-planning-12min-task-decomposition`). Files are named after the
skill they originally produced, so you can read the seed prompt that
generated any given skill. They are **source material, not canonical**: any edits are wasted work. The skills in `<skill-name>/SKILL.md` are
the canonical versions.

Three original files (`todo-list-builder.md`, `features-audit.md`,
`docs-freshness-check.md`) now seed skills that were consolidated into
`docs-health`. They are kept for historical reference; the canonical
skill is `docs-health/SKILL.md`.

### 5.2 `git commit <--` Syntax Bug (resolved)

Historically four skills used the phrase `git commit <-- with VERY DETAILED commit message(s)`. The `<--` is **not** a git flag — it was a typo/artifact from the original prompts that should read "commit with a very detailed message". **All occurrences have been fixed** to clear prose. A guard (`scripts/check-skills.sh`) now fails if the typo reappears in any `SKILL.md`. If you encounter it in `originals/`, leave it — those are frozen source material.

### 5.3 Parallelism (resolved)

`brutal-self-review` instructs "Use 1 Sub Agent per file. ONLY 1 at a time." This previously contradicted the removed `execution-mode` skill, which said "Use MULTIPLE Tasks to get multiple Todos done at the same time." With `execution-mode` deleted, the contradiction no longer exists. Do not reintroduce conflicting parallelism guidance when editing either skill. The `docs-health` skill (which absorbed `todo-list-builder`) also instructs sequential sub-agent use for TODO_LIST.md builds.

### 5.4 Thin Skills

Skill depth varies. The authoritative status is the line count and a quality read of each `SKILL.md`; run `scripts/check-skills.sh` to surface the current thin ones. The comprehensive audit in `docs/status/2026-06-17_23-22_comprehensive-status.md` grades every skill and lists what each thin skill is missing. **Read the latest audit before attempting to flesh out a skill** — it contains specific, actionable findings (e.g., "`bdd-testing` needs ginkgo syntax reference, test structure template, file naming conventions").

### 5.5 Inter-Skill References

The `full-code-review` skill now delegates planning to `pareto-planning` (previously inlined the same Pareto breakdown — a split brain). Several skills reference the shared `html-report-kit` design system for consistent HTML output — the authoritative consumer list is produced by `scripts/sync-html-kit.sh --list` (see 5.9). Do not hardcode that list in prose; it drifts. When adding cross-references, check this graph first.

### 5.6 `how-to-write-skills.md` Location

This file is currently at the repo root. The status report recommends either converting it to a proper skill directory (`skill-creator/` or `how-to-write-skills/`) or moving it to `docs/`. It is not currently installed as a skill.

### 5.7 No `crush.json` Present

There is no `crush.json` in this repo, so Crush does not auto-discover these skills. Users install them via `npx skills add`, `skills_paths` in their own `crush.json`, or by copying directories into `~/.config/crush/skills/`.

### 5.8 `allowed-tools` Frontmatter Field

`pareto-planning` uses `allowed-tools: d2` to pre-approve the D2 CLI for graph rendering. Consider adding it to other skills that rely on specific CLI tools (e.g., `art-dupl` for `deduplicate-code`, `d2` for `architecture-visualization`).

### 5.9 Shared HTML Design System (`html-report-kit`)

Skills that produce point-in-time reports write self-contained HTML files instead of Markdown, using a shared design system so every report shares the same visual language. The kit uses the **Bauhaus** design language: primary colors (red, blue, yellow) on a neutral ground. Two variants: **Bauhaus Dark** (status dashboards, scan results, high-density metrics — graphite ground + primary accents) and **Bauhaus Light** (adoption feedback, architecture reviews, audit briefs — warm paper + primary color blocks). Both share the same component vocabulary: stat/score cards, issue cards, severity badges, callouts, strengths lists, dep-trees, tables, before/after comparisons, syntax highlighting, hero with optional geometric shape cluster (circle/square/triangle/bar).

**Unified token vocabulary (post-Bauhaus migration):** both templates share the same semantic token names — `--surface`, `--surface-raised`, `--surface-sunken`, `--text`, `--text-muted`, `--text-faint`, `--border`, `--border-strong`, `--accent`, `--problem`, `--solution`, `--warning`. Only the primitive values differ between dark and light. The previous split-brain tokens (`--bg-elevated`/`--rose` in dark vs `--bg-card`/`--coral` in light) are preserved as **backward-compatible aliases** so consumer skills that reference old names keep working. See [`html-report-kit/references/bauhaus-tokens.md`](html-report-kit/references/bauhaus-tokens.md) for the full spec.

**`color-mix()` replaces glow tokens:** instead of paired `--rose` + `--rose-glow` tokens (8 redundant, drift-prone values), translucent variants derive on demand via `color-mix(in srgb, var(--problem) 15%, transparent)`. Browser support: Chrome 111+, Safari 16.2+, Firefox 113+.

**Optional scrollspy:** both templates ship a tiny IntersectionObserver script (~20 lines) that highlights the active sidebar item. It's progressive enhancement — plain `<a href="#section">` anchor links work without JS. Auto-discovers any `[data-nav]` container.

**Sharp corners:** `--radius: 0` is the Bauhaus default. Override per-report if needed.

**The Artifact decision rule** (encoded in `how-to-write-skills.md`): Snapshot + HumanReport → HTML; Living + ToolParsed/EndUserDoc → Markdown. Never convert living docs (`FEATURES.md`, `TODO_LIST.md`) to HTML.

#### Vendoring model (fixes per-skill install)

The Agent Skills spec has **no dependency system** — each skill is installed as a flat, self-contained unit. `bunx skills add LarsArtmann/SKILLS@<one-skill>` copies only that one directory, so a `../html-report-kit/...` sibling path dangles and the kit appears not to exist. To make every consumer work in every install mode (per-skill add/update, clone, `skills_paths`), the kit is **vendored** into each consumer:

| Role                      | Path                                 | Edit?                               |
| ------------------------- | ------------------------------------ | ----------------------------------- |
| Canonical source of truth | `html-report-kit/`                   | **Yes** — edit here                 |
| Vendored copy             | `<consumer>/assets/html-report-kit/` | **No** — regenerated build artifact |

Consumer skills reference the kit intra-skill via `./assets/html-report-kit/references/html-output-guide.md` and `./assets/html-report-kit/assets/report-template.html`. The canonical `html-report-kit/SKILL.md` is **excluded** from vendored copies so the skills CLI never mistakes a vendored directory for a standalone skill.

#### Sync workflow

After editing the canonical kit, re-vendor into every consumer and verify:

```bash
./scripts/sync-html-kit.sh          # regenerate all vendored copies
./scripts/sync-html-kit.sh --check  # CI: exit 1 if any copy drifted
./scripts/sync-html-kit.sh --list  # show consumers (authoritative list)
```

When a new skill needs HTML reports: (1) reference `./assets/html-report-kit/...` from its `SKILL.md`, (2) run `./scripts/sync-html-kit.sh` to populate the vendored copy — the script auto-discovers any `SKILL.md` that mentions `html-report-kit`.

---

## 6. High-Value Reference Files

| File                                                         | Why It Matters                                                                                                                           |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `how-to-write-skills.md`                                     | Complete guide for skill authoring — frontmatter rules, description-as-trigger, progressive disclosure, common mistakes                  |
| `docs/status/2026-05-03_07-51_comprehensive-skills-audit.md` | Master audit: every skill graded, every issue catalogued, top 25 next tasks ranked by impact. Read this before any bulk improvement work |
| `go-modularize/SKILL.md`                                     | Best example of a rich, well-structured skill with concrete examples, decision tables, and failure mode catalog                          |
| `nix-review/SKILL.md`                                        | Best example of a checklist-driven review skill with severity guide                                                                      |
| `how-to-golang/SKILL.md`                                     | Best example of a reference-heavy skill: 93-line entrypoint + 9 reference files                                                          |
| `how-to-golang/references/`                                  | Pattern to emulate for domain-specific deep dives                                                                                        |
| `naming-review/SKILL.md`                                     | Best example of a multi-step review with automated detection → manual review pipeline                                                    |

---

## 7. Git Conventions

- **Main branch:** `master`
- **Remote:** `git@github.com:LarsArtmann/SKILLS.git`
- **Commit style:** Very detailed commit messages (this is explicitly requested in several skills)
- **Clean history:** Logical commits, descriptive messages (the project values this)

---

## 8. When Improving This Repo

Before making changes:

1. Read `docs/status/2026-05-03_07-51_comprehensive-skills-audit.md` — it contains the authoritative backlog.
2. If fleshing out a thin skill, study `how-to-golang` or `go-modularize` as the pattern.
3. If adding cross-references, check the audit's "Inter-skill cross-references" section for the intended graph.
4. If fixing the `git commit <--` bug, check all four affected skills.
5. If converting `how-to-write-skills.md` to a skill, read the guide itself — it describes the expected directory structure.

---

## 9. What NOT to Do

| Don't                                                            | Why                                                |
| ---------------------------------------------------------------- | -------------------------------------------------- |
| Add a build system (Makefile, package.json, go.mod)              | This repo has no compilable code                   |
| Edit `originals/*.md`                                            | Legacy source material; skills are canonical       |
| Add tests or CI                                                  | No runnable code to test                           |
| Rename skill directories without updating `name:` in frontmatter | Crush matches directory name to frontmatter `name` |
| Write vague `description` fields                                 | The skill will never activate                      |
| Put >500 lines in a single `SKILL.md`                            | Wastes context tokens; use `references/`           |
| Use rigid `ALWAYS`/`MUST`/`NEVER` without explaining why         | Agents follow reasoning better than commandments   |

---

## 10. External Dependencies Referenced by Skills

These tools are referenced by skills but are **not** bundled in this repo. Agents should verify their availability or install them:

| Tool                       | Referenced By                           | Purpose                             |
| -------------------------- | --------------------------------------- | ----------------------------------- |
| `d2` CLI                   | `architecture-visualization`            | Render `.d2` diagrams to `.svg`     |
| `art-dupl`                 | `deduplicate-code`, `code-quality-scan` | Semantic code duplication detection |
| `nix` / `nix flake check`  | `code-quality-scan`, `nix-review`       | Nix build/lint                      |
| `revive` / `golangci-lint` | `naming-review`                         | Go naming lint                      |
| `onsi/ginkgo`              | `bdd-testing`                           | BDD testing framework               |

**Note:** `how-to-golang` contains Go code snippets in its references. Some have known accuracy issues (flagged in the status report: `gopter` signature, `encoding/json/v2` Go version, E2E HTTP API). Validate code snippets before relying on them.

## Note

- This is a content repository -- no traditional build/test system
- Validation: check YAML frontmatter format and skill structure manually
