---
name: design-to-code
description: >-
  Use WHEN writing CSS/HTML/Tailwind for a page or component, implementing a
  design plan, encoding design tokens, or debugging why a Tailwind class
  doesn't work — turn the design direction into production frontend code:
  encode the plan as real tokens (@theme vs :root), pick the right abstraction
  level, and avoid Tailwind v4 syntax traps. Also WHEN the user says
  "implement the design", "encode the design tokens", "set up the theme",
  "audit my CSS", "make the UI production-ready", or WHEN a frontend-design
  plan exists and it is time to write code. Owns the design-to-code bridge:
  token encoding, the utility-first abstraction ladder, quality-floor audits,
  and verified Tailwind v4 gotchas. Distinct from frontend-design (aesthetic
  direction, ends before code), modern-web-guidance (web-platform APIs, not
  framework mechanics), website-launch (docs-site deployment pattern), and
  html-report-kit (its own report-specific design system).
metadata:
  tags: frontend, css, tailwind, design-systems, tokens, quality-audit
---

# Design to Code

**#1 failure mode: cargo-cult CSS.** Writing hand-rolled styles or inventing
tokens in a project that already has a design system — the code compiles, the
page looks fine, and six months later every color exists twice and has drifted
apart. Inspect before you write (Step 1). The project's existing design
language always wins over the generic one you would produce from memory.

## When this skill is the right tool

| Task                                                                             | Use                   |
| -------------------------------------------------------------------------------- | --------------------- |
| Distinctive aesthetic direction, palette/type choices, avoiding AI-default looks | `frontend-design`     |
| Implement that direction in markup + CSS, tokens, Tailwind mechanics             | **this skill**        |
| Which web-platform API fits (dialog, container queries, View Transitions)        | `modern-web-guidance` |
| Deploying a docs site, Firebase, DNS                                             | `website-launch`      |
| Styling a point-in-time HTML report with the shared Bauhaus system               | `html-report-kit`     |

## Step 1 — Inspect the project's design system first

1. Find the Tailwind entry CSS: search for `@import "tailwindcss";` (v4) or
   `@tailwind base/components/utilities` (v3). The version decides which
   syntax is legal — load the gotchas reference before writing any v4.
2. Inventory what already exists: `@theme` blocks (tokens), `@utility`
   definitions, `@layer components` classes, and the spacing/type conventions
   in real markup.
3. Reuse beats invention. A new token that duplicates an existing one is a
   split brain (the same concept defined or configured in two places, so the
   two drift apart) — extend the existing scale instead of adding a parallel
   one.

## Step 2 — Encode the design plan as tokens

Input: a design plan with a palette (4–6 named hex values) and type roles —
typically from the `frontend-design` plan phase. If no plan exists, stop and
get one first: colors chosen while writing markup always come out generic.

Decision rule (verified against the v4 docs, see the gotchas reference):

- `@theme` when the token should **generate a utility class** — colors,
  fonts, breakpoints, spacing the markup will use as `bg-*`, `font-*`, and
  so on. Theme variables are required to be **top-level**: never nested
  under selectors or media queries.
- `:root` for plain CSS variables that should **not** create utilities —
  one-off layout values, z-index scales, internal component constants.
- Name by **role where semantics matter**: `--color-danger`, `--color-surface-muted`,
  `--color-primary`. A brand color may keep its brand name; a red used for
  errors must not be named `red-500-copy` — the name must survive a redesign
  that changes the hue.

Promote an arbitrary value (e.g. `mt-[117px]`) to a token when it: appears
more than once, carries product meaning, or should change everywhere at once
in a redesign. Otherwise a one-off arbitrary value is fine — do not
prematurely tokenize.

## Step 3 — The abstraction ladder

Default to the lowest rung that works; climb only when repetition forces it.

1. **Compose utilities in markup** — the default; compose the UI where it is used.
2. **Repeated markup** → extract into the project's native reuse abstraction
   (component, partial, include, template) — reuse the markup, not the CSS.
3. **Repeated values missing from the system** → add `@theme` tokens (Step 2).
4. **Missing low-level reusable behavior** → add a custom utility with
   `@utility` (it works with variants like `hover`, `focus`, `lg`).
5. **Stable named visual primitive** (`card`, `btn`, `badge`) → component
   class in `@layer components` — still overridable by utilities in markup.
6. **`@apply`** only as a narrow adapter (e.g. inside one component class).
   An `@apply`-heavy stylesheet is rung 6 doing rung 1's job.

Stop climbing when the code is clear. Every rung above 1 adds indirection a
reader must resolve.

## Step 4 — Quality floor and self-audit

Before declaring done, verify — a successful build proves nothing about the
rendered page (Pattern: Visual QA gate):

1. **Screenshots when a browser is available** — check mobile width, hover
   states, focus outline visibility.
2. **DOM audit fallback** (no browser): for each interactive element, confirm
   a focus style exists; for each animation, confirm reduced-motion handling;
   for each layout-critical section, confirm a mobile breakpoint exists.
3. **Scan for dynamically constructed class names** (template literals,
   conditional concatenation like `` `text-${color}-600` ``). Tailwind scans
   source files as plain text and cannot see these — the class silently does
   not exist in the build. Fix: write complete class names and select between
   them.
4. **Hover-only affordances**: `hover:` compiles to `@media (hover: hover)` —
   touch devices never trigger it. Any hover-revealed control needs a
   reachable non-hover path.

## References

- [./references/tailwind-v4-gotchas.md](./references/tailwind-v4-gotchas.md) —
  the verified v4 syntax and behavior gotchas (v3→v4 moves, scanning rules,
  directive rules) with a verification-status table. Load before writing or
  reviewing any Tailwind v4 CSS; the syntax traps live there.
