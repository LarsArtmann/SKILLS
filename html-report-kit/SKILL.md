---
name: html-report-kit
description: >
  Use when a skill needs to write a styled, self-contained HTML report, dashboard,
  proposal, audit, or review — instead of a flat Markdown file. Triggers on phrases
  like "HTML report", "styled report", "dashboard", "audit output", " Bauhaus design",
  "dark theme report", or "generate HTML". Loads the shared Bauhaus CSS tokens,
  report templates, and copy-paste components from this kit.
metadata:
  tags: html, report, design-system, template, dark-theme, light-theme, editorial, shared-assets
---

# HTML Report Kit

A shared design system so every skill that produces a point-in-time report uses the **same
visual language** — semantic colors, consistent components, responsive layout — rather than each
reinventing its own.

## Canonical Source & Vendoring

This directory is the **single source of truth** for the kit. Consumer skills do NOT reference it
via sibling paths (`../html-report-kit/`) — that breaks under per-skill install
(`bunx skills add LarsArtmann/SKILLS@<one-skill>`, which copies only one directory). Instead, the
kit is **vendored** into each consumer's own `assets/html-report-kit/`, and consumers reference it
intra-skill via `./assets/html-report-kit/...`.

To propagate edits to all consumers, run from the repo root:

```bash
./scripts/sync-html-kit.sh          # regenerate vendored copies in all consumers
./scripts/sync-html-kit.sh --check  # CI: exit 1 if any vendored copy drifted
./scripts/sync-html-kit.sh --list   # list consumer skills
```

The vendored copy excludes this `SKILL.md` so the skills CLI doesn't detect a nested skill.
**Edit the kit here; never hand-edit `<consumer>/assets/html-report-kit/`.**

## Two Template Variants

| Variant             | File                                                                               | Best for                                                                  |
| ------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Dark dashboard**  | [./assets/report-template.html](./assets/report-template.html)                     | Status dashboards, scan results, high-density metrics                     |
| **Editorial light** | [./assets/report-template-editorial.html](./assets/report-template-editorial.html) | Adoption feedback, architecture reviews, audit briefs, long-form findings |

Both templates include the same component vocabulary (hero, stat/score cards, issue cards,
callouts, strengths list, dep-tree, before/after, numbered steps, footer). Pick the variant
whose tone matches the report audience.

## When to Use HTML vs Markdown

The `Artifact` decision rule (see `how-to-write-skills.md`):

| lifecycle | audience    | mutability | → format |
| --------- | ----------- | ---------- | -------- |
| Snapshot  | HumanReport | WriteOnce  | **HTML** |
| Living    | ToolParsed  | Upsert     | Markdown |
| Living    | EndUserDoc  | Upsert     | Markdown |

**HTML is for snapshot reports** — status updates, reviews, plans, proposals, audits.
**Markdown is for living docs** — `FEATURES.md`, `TODO_LIST.md`, `AGENTS.md`.

## How Other Skills Use This Kit

1. Read [./references/html-output-guide.md](./references/html-output-guide.md) for the full
   design spec: required sections, color tokens, component catalog, syntax highlighting.
2. Choose a starting template:
   - Dashboard-style reports → [./assets/report-template.html](./assets/report-template.html)
   - Editorial/review-style reports → [./assets/report-template-editorial.html](./assets/report-template-editorial.html)
3. Look at [./references/example-editorial-report.html](./references/example-editorial-report.html) for a fully rendered example.
4. Strip components you don't need; keep the CSS design tokens intact.
5. Write report-specific content into the body.
6. Output to the skill's designated path (typically `docs/<category>/<date>_<slug>.html`).

## Design Principles

- **Single file, zero dependencies** — no CDN, no JS, no build step, no external fonts by default
- **Two themes** — dark dashboard and warm editorial light, both using CSS custom properties
- **Semantic color coding** — problem/solution/warning meanings are consistent across both themes
- **Responsive** — sidebar collapses on narrow viewports, grids collapse on mobile
- **Manual syntax highlighting** via `.tok-*` classes (language-agnostic)
