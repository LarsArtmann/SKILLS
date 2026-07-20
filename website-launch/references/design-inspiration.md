# Design Inspiration — Calibrating "Nice"

> A short reference so agents building or auditing a project website
> know what best-in-class docs look like, _why_ they look that way, and
> how to reach the same bar on the Astro + Starlight stack without
> switching frameworks.

## Why this reference exists

"This docs site feels nice" is feedback that gets ignored because it is
vague. This file names the aesthetic, lists reference sites, and maps
each quality to a concrete Starlight capability — so "make it nice"
becomes a checklist instead of a vibe.

## The aesthetic: the "Nextra-class" docs look

A recognizable style popularized by **Nextra** (Next.js) and now shared
across many flagship developer docs:

- **SP8D** — `sp8d.github.io` (Nextra v3, the site that prompted this reference)
- **Turborepo**, **Bun**, **SWC**, **Zig**, **tRPC**, **Million** docs
- Dense, calm, monospace-friendly; sticky three-column layout (sidebar · content · "On this page" TOC)

The qualities that make it feel nice, and how each one is achieved:

| Quality                        | Nextra source               | Starlight equivalent (built-in)             |
| ------------------------------ | --------------------------- | ------------------------------------------- |
| Sticky sidebar + collapsible   | `nextra-theme-docs` sidebar | Starlight sidebar (collapsible via `_meta`) |
| Right-rail "On this page" TOC  | `nextra-toc` with scrollspy | Starlight TOC, scrollspy on by default      |
| Breadcrumbs                    | `nextra-breadcrumb`         | Starlight breadcrumbs, on by default        |
| Prev/next pagination           | built-in                    | Starlight pagination, on by default         |
| Dark / light / system theme    | `next-themes`, no FOUC      | Starlight theme toggle, `theme-init.js`     |
| Search                         | Pagefind / Flexsearch       | **Pagefind**, built into Starlight          |
| Code blocks w/ filename + copy | built-in                    | Starlight (Expressive Code), copy default   |
| Callouts (note/tip/caution)    | `:::note` etc.              | Starlight `:::note`/`:::tip`/`:::caution`   |
| Mermaid diagrams               | `mermaid: true`             | `starlight-plugins-modules` mermaid plugin  |
| Last-updated (git)             | `lastUpdated: true`         | Starlight `lastUpdated: true`               |
| Edit-this-page link            | `editLink` config           | Starlight `editLink` config                 |
| Reading time                   | `readingTime: true`         | community plugin (optional)                 |

**Conclusion:** the Astro + Starlight stack matches Nextra feature-for-feature.
The "nicer" feeling is not a framework advantage — it is (a) content
patterns (see [`content-patterns.md`](./content-patterns.md)) and (b)
theme-token tuning. Both are achievable without leaving Astro.

## Why we stay on Astro + Starlight (do not switch to Nextra)

- **Investment:** 6+ sessions and multiple live sites use this pattern.
  Switching abandons that and re-introduces every pitfall in
  [`common-pitfalls.md`](./common-pitfalls.md).
- **Static-first performance:** Astro ships zero JS by default; Nextra
  ships a React runtime on every page. For docs, Astro is faster.
- **Feature parity:** see the table above — there is no Nextra feature
  we lack.
- **The skill's toolchain (Nix flakes, Firebase/DNS, CI) is built around
  the Astro build output.** A switch is a multi-week migration, not an
  improvement.

If a project specifically requests Next.js/Nextra, treat it as a
one-off, not a change to this skill.

## How to approach the Nextra-class aesthetic in Starlight

The gap is _theme tuning_, not features. To close it:

1. **Typography** — set a clean sans + mono pairing in `global.css`.
   Nextra-class sites use system-ui or Inter for body, a mono for code.
2. **Density** — Starlight's default content width and line-height are
   close to Nextra. Resist widening the content column; density reads as
   "professional".
3. **Accent discipline** — one accent color, used sparingly (links, the
   active sidebar item, the logo). Nextra-class sites do not use
   multi-color rainbows. See [`color-palette.md`](./color-palette.md).
4. **Dark-first** — the warm dark base (`#0a0908`) already matches the
   aesthetic. Ensure dark is the default (it is, via `theme-init.js`).
5. **Callouts over bold** — see [`content-patterns.md`](./content-patterns.md) §6.
6. **Enable the "nice docs" knobs** — `lastUpdated`, `editLink`. See
   SKILL.md §3.10.

## Reference sites to open before designing

Before authoring a new site or retrofitting one, open two of these in a
browser tab to calibrate:

- `sp8d.github.io` — content-patterns exemplar (callouts, comparison tables, "when not to use")
- Starlight's own docs (`docs.astro.build/starlight`) — the canonical
  example of what the Starlight chrome looks like at its best
- A sibling project already on this pattern (`gogenfilter.lars.software`)
  — to match the _existing_ LarsArtmann house style rather than diverge

Calibration prevents both "too plain" (skipped the content patterns) and
"over-designed" (chasing trends instead of clarity).
