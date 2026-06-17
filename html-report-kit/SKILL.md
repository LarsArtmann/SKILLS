---
name: html-report-kit
description: >
  Shared HTML report design system for skills that produce point-in-time visual reports.
  Use when a skill needs to write a styled, self-contained HTML report, dashboard, proposal,
  or audit output — instead of a flat Markdown file. Provides the design spec, CSS tokens,
  and a copy-paste template with dark theme, semantic color coding, cards, badges, stat grids,
  tables, before/after comparisons, and syntax highlighting. Other skills reference this kit
  via [./references/html-output-guide.md](references/html-output-guide.md) and
  [./assets/report-template.html](assets/report-template.html).
metadata:
  tags: html, report, design-system, template, dark-theme, shared-assets
---

# HTML Report Kit

A shared design system so every skill that produces a point-in-time report uses the **same
visual language** — dark theme, semantic colors, consistent components — rather than each
reinventing its own.

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

1. Read [./references/html-output-guide.md](references/html-output-guide.md) for the full
   design spec: required sections, color tokens, component catalog, syntax highlighting.
2. Copy [./assets/report-template.html](assets/report-template.html) as the starting point.
3. Strip components you don't need; keep the CSS design tokens intact.
4. Write report-specific content into the body.
5. Output to the skill's designated path (typically `docs/<category>/<date>_<slug>.html`).

## Design Principles

- **Single file, zero dependencies** — no CDN, no JS, no build step, no external fonts
- **Dark theme** with CSS custom properties (design tokens)
- **Semantic color coding** — rose = problem, emerald = solution, amber = warning, accent = highlight
- **Responsive** — grid layouts collapse on mobile
- **Manual syntax highlighting** via `.tok-*` classes (language-agnostic)
