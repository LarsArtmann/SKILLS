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
├── <skill-name>/                # One directory per skill (run scripts/check-skills.sh for the current count)
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

The `description` field is **trigger context for the AI agent**, not a description of the skill itself. It must tell Crush _when_ to load and use this skill. If it reads like a feature list or a README sentence, rewrite it.

```yaml
---
name: skill-name # lowercase, hyphens, MUST match directory name
description: > # TRIGGER CONTEXT — tells the agent WHEN to use this skill
  WHEN the user asks about X, says Y, or needs Z.
  Include exact trigger phrases + adjacent contexts + what the agent will do.
  Be explicit and slightly pushy; agents under-trigger.
  Max ~1024 chars.
metadata:
  tags: foo, bar # comma-separated, helps with discovery
---
```

**Critical nuance:** The `description` is read by Crush's skill selection system. It must answer "what user task makes this skill the right tool?" If it is vague, the skill will never activate. If it describes what the skill _is_ or _contains_ rather than _when to use it_, the skill will never activate. Study existing good descriptions in `go-modularize`, `nix-review`, `how-to-golang`, `naming-review`.

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

The `full-code-review` skill now delegates planning to `pareto-planning` (previously inlined the same Pareto breakdown — a split brain). `status-report` hands its "next tasks" section (f) to `docs-health` HARVEST — the canonical "run HARVEST after a status report" rule lives **only** in `docs-health` → "When to run HARVEST"; `status-report` links rather than restates (do not duplicate the rationale in both). Several skills reference the shared `html-report-kit` design system for consistent HTML output — the authoritative consumer list is produced by `scripts/sync-html-kit.sh --list` (see 5.9). Do not hardcode that list in prose; it drifts. The Go release pair is bidirectional: `go-release` owns the full release procedure (supply side); `go-ecosystem-upgrade` Phase 6 is a thin pointer to it (demand side) with only ecosystem-specific rules inline. `website-launch/references/demo-video.md` defers story doctrine to the third-party `hyperframes-creative` skill — the one repo↔third-party pair; re-check it when either side changes. When adding cross-references, check this graph first.

`docs-health` ANNOTATE and HARVEST modes form a two-way loop over the same status reports and MUST share vocabulary. ANNOTATE resolves items **backward** (marks each `done at` / `Won't implement` / `NOT-DO`, then archives fully-resolved files to `<dir>/archived/`). HARVEST pulls items **forward** into TODO_LIST — and it must **skip any item already carrying a resolution marker** (those are closed; route to CHANGELOG, never re-harvest into TODO_LIST). The marker vocabulary (`done at`, `Won't implement`, `NOT-DO/DUPLICATE`) is owned by ANNOTATE; HARVEST references it, never restates a rival format. (Previously two separate skills — `update-old-docs` and `docs-health` — merged 2026-08-04 to eliminate cross-reference maintenance and the 3× boundary restatement.)

`verify-external-claims` and `verify-before-filing` form an **epistemic-hygiene pair** covering opposite directions of the same failure mode (unverified claims). `verify-external-claims` is **inbound** — verify external tool/library claims before encoding them into your own work. `verify-before-filing` is **outbound** — verify your own diagnosis before proposing changes to an external project. Each skill names the other explicitly; do not duplicate the rationale in both (the inbound/outbound split is stated once in `verify-external-claims/SKILL.md` and once in `verify-before-filing` §8). When adding a new verification-flavored skill, check whether it overlaps this pair before introducing a third angle.

### 5.6 `how-to-write-skills.md` Location

This file is currently at the repo root. The status report recommends either converting it to a proper skill directory (`skill-creator/` or `how-to-write-skills/`) or moving it to `docs/`. It is not currently installed as a skill.

### 5.7 No `crush.json` Present

There is no `crush.json` in this repo, so Crush does not auto-discover these skills. Users install them via `pnpm dlx skills add`, `skills_paths` in their own `crush.json`, or by copying directories into `~/.config/crush/skills/`.

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

### 5.10 Runtime Sync Model — Symlinks, Not Copies

`/home/lars/projects/SKILLS/` is the **only** copy of these skills. The runtime dir `~/.agents/skills/` holds a **relative symlink** per repo skill (`../../projects/SKILLS/<skill>`), so an edit in the repo is live in every agent (Crush, Codex, Cursor, ...) instantly — there is no sync step and no drift is possible. `~/.config/crush/skills/<skill>` chains through `~/.agents/skills/` (double indirection resolves fine).

**Third-party skills are different:** `copywriting`, `find-skills`, `frontend-design`, `improve-codebase-architecture`, `skill-creator` are real directories in `~/.agents/skills/`, installed and tracked by the [skills CLI](https://skills.sh) via `~/.local/state/skills/.skill-lock.json`. They are updated **manually** with `skills update -g` and must never be edited by hand or added to this repo. The 2026-08-14 status report called these "orphans" — they are not; they have upstream sources in the lockfile.

**Rules:**

1. NEVER edit anything under `~/.agents/skills/` or `~/.config/crush/skills/` — the repo is canonical. Editing a runtime copy either edits the repo through the symlink (confusing) or forks a third-party skill (drift).
2. Own skills are **not** in the lockfile (removed 2026-08-14). If a future `skills add` ever reinstalls one, it will `rm -rf` the symlink and leave a real directory — recover with `scripts/link-skills-to-agents.sh --force`.
3. Link state is managed by `scripts/link-skills-to-agents.sh` (`--check` for CI/verification, `--list` to inspect, default mode is idempotent repair). The old `sync-skills-to-agents.sh` rsync script is deleted — copying is exactly the drift this model eliminates.
4. Adding a new skill: create the directory here, run `scripts/link-skills-to-agents.sh`. Done.
5. Removing a skill: `git rm` the directory, then remove the `~/.agents/skills/<skill>` symlink.
6. Always read AND edit skill files through the repo path. Edit tools track paths, not symlink identity — reading via `~/.agents/...` or `~/.config/crush/...` then editing via the repo path fails with "file modified since last read" (hit 2026-08-14 and again 2026-08-21).
7. `~/.config/crush/skills/` also holds three one-off entries that are neither repo skills nor drift: `font-design` (→ a project-local skill), `go-cqrs-lite` (→ nix store), `templ-components` (real directory). Do not "repair" them.

---

## 6. High-Value Reference Files

| File                                                         | Why It Matters                                                                                                                           |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `how-to-write-skills.md`                                     | Complete guide for skill authoring — frontmatter rules, description-as-trigger, progressive disclosure, common mistakes                  |
| `docs/status/2026-05-03_07-51_comprehensive-skills-audit.md` | Master audit: every skill graded, every issue catalogued, top 25 next tasks ranked by impact. Read this before any bulk improvement work |
| `go-modularize/SKILL.md`                                     | Best example of a rich, well-structured skill with concrete examples, decision tables, and failure mode catalog                          |
| `nix-review/SKILL.md`                                        | Best example of a checklist-driven review skill with severity guide                                                                      |
| `how-to-golang/SKILL.md`                                     | Best example of a reference-heavy skill: 103-line entrypoint + 10 reference files (incl. `performance-tuning.md`)                                                       |
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

| Tool                                            | Referenced By                           | Purpose                                                                                                                                                                                                                                                                                                                                                                                                    |
| ----------------------------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `d2` CLI                                        | `architecture-visualization`            | Render `.d2` diagrams to `.svg`                                                                                                                                                                                                                                                                                                                                                                            |
| `art-dupl`                                      | `deduplicate-code`, `code-quality-scan` | Semantic code duplication detection                                                                                                                                                                                                                                                                                                                                                                        |
| `nix` / `nix flake check`                       | `code-quality-scan`, `nix-review`       | Nix build/lint                                                                                                                                                                                                                                                                                                                                                                                             |
| `revive` / `golangci-lint`                      | `naming-review`                         | Go naming lint                                                                                                                                                                                                                                                                                                                                                                                             |
| `onsi/ginkgo`                                   | `bdd-testing`                           | BDD testing framework                                                                                                                                                                                                                                                                                                                                                                                      |
| `erraudit` CLI (formerly `hierarchical-errors`) | `go-error-modernization`                | Go 1.26+ `errors.As`/`errors.Is` → `errors.AsType` linter. **Not publicly findable** — searched GitHub, Sourcegraph, pkg.go.dev (2026-08-02), zero matches. Likely private. Use with `--type-aware`. Run in every dir with a `go.mod`. Related: [`github.com/larsartmann/go-error-family`](https://github.com/LarsArtmann/go-error-family) (verified, v0.10.0). See the skill's verification-status block. |
| `firebase` CLI                                  | `website-launch`                        | Firebase Hosting site management                                                                                                                                                                                                                                                                                                                                                                           |
| `terraform` / `opentofu`                        | `website-launch`                        | DNS record management                                                                                                                                                                                                                                                                                                                                                                                      |
| `go-nix-helpers`                                | `nix-private-go-repos`                  | Private repo (`git+ssh`) providing `mkPreparedSource` and `flakeModules.go-standard`. **Status: private** — not publicly cloneable; verify option names against local source before relying on them. See the skill's verification-status block.                                                                                                                                                            |
| `branching-flow/pkg/doanalyzerv2`               | `samber-do-best-practices`              | Private repo (`git+ssh`) providing the DO-1 → DO-6 analyzer rules. **Status: private** — not publicly cloneable; the anti-patterns themselves are durable DI principles. See the skill's verification-status block.                                                                                                                                                                                        |
| `samber-do-auditlog`                            | `samber-do-best-practices`              | Private repo (`git+ssh`) providing audit hooks for samber/do registration, invocation, health check, and shutdown events. **Status: private.**                                                                                                                                                                                                                                                             |
| `goreleaser` v2, `gh` CLI                       | `go-release`                            | Release automation and GitHub Releases. `allowed-tools: goreleaser gh` pre-approved in frontmatter; config syntax verified against GoReleaser source 2026-08-12.                                                                                                                                                                                                                                           |
| `benchstat`, `goleak`, `x/sys/cpu`, `klauspost/compress`, `automaxprocs`, `fieldalignment` | `how-to-golang` (performance-tuning.md) | Profiling/benchmark/cache tooling. All verified public against primary sources 2026-08-16 (see the reference's verification-status table).                                                                                                                                                                                                                                                                  |

**Note:** `how-to-golang`'s Go snippets were accuracy-corrected 2026-08-04 (gopter, json/v2, E2E HTTP, Rule 002). Newer `performance-tuning.md` snippets (2026-08-16) are idiomatic but not yet compile-tested — validate before relying.

## 11. Feedback Loop — `docs/feedback/`

### The Problem This Section Solves

Prior to 2026-07-13, agents wrote detailed feedback files after sessions,
documenting what went wrong and what skills would have prevented it. **None
of those feedback files were ever converted into skills.** Each subsequent
session ignored the feedback, repeated the same research, made the same
mistakes, and wrote the same feedback. Six sessions created the same
website-launch workflow, each wasting 45-90 minutes rediscovering the
pattern. The feedback loop was broken: feedback was written but never
acted upon.

### How the Feedback Loop Works Now

```
Session produces feedback  →  Feedback lives in docs/feedback/new/
                             ↓
Agent reads feedback       →  Before starting similar work, scan docs/feedback/
                             ↓
Feedback converted to skill →  When a pattern appears 2+ times, create a skill
                             ↓
Feedback archived           →  Move to docs/feedback/processed/
```

### Directory Structure

```
docs/feedback/
├── new/           # Unprocessed feedback — read before starting similar work
└── processed/     # Feedback that has been converted into a skill or resolved
```

### Agent Instructions

1. **Before starting work** on a multi-step task (website creation, Firebase
   setup, DNS configuration, CI pipeline setup), scan `docs/feedback/new/`
   for relevant feedback. The feedback files contain hard-won knowledge
   about what goes wrong.

2. **After creating a skill** from feedback, move the source feedback files
   from `new/` to `processed/` to indicate they have been acted upon.

3. **When a pattern appears 2+ times** across feedback files, convert it
   into a skill. Do not write a third feedback file saying "we should
   create a skill for this" — create the skill instead.

4. **Feedback files are not status reports.** A feedback file documents
   what went wrong and what would prevent it. A status report documents
   what was done. Write feedback only when there are actionable lessons
   that should be encoded into skills.

### What Makes Good Feedback

Good feedback is specific enough to act on:

- **What happened** — the exact symptom, error message, or time sink
- **Why it's a problem** — the impact (wasted time, broken output, missed
  step)
- **What a skill should contain** — the exact commands, decision trees,
  checklists, or pitfalls that would prevent it
- **Impact estimate** — minutes saved per session, number of sessions
  affected

Bad feedback is vague: "The process was inefficient and could be improved."

## Note

- This is a content repository -- no traditional build/test system
- Validation: check YAML frontmatter format and skill structure manually
