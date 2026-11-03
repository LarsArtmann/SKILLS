# Tailwind CSS v4 gotchas

Load this file before writing or reviewing Tailwind v4 CSS. Syntax and
behavior traps that silently break builds or styles.

**Claim freshness:** these claims were verified against the official docs on
**2026-11-03** (docs site reported v4.3). Tailwind evolves quickly — before
relying on a claim in an important decision, re-check the linked doc page.
Syntax trap claims from v3-era training data are the most common source of
wrong code here.

## Verification status

| Claim                                                              | Status      | Source (tailwindlabs/tailwindcss.com, `src/docs/`) |
| ------------------------------------------------------------------ | ----------- | ---------------------------------------------------- |
| v4 imports Tailwind with `@import "tailwindcss";` (no `@tailwind` directives) | ✅ Verified | `upgrade-guide.mdx` (fetched 2026-11-03)  |
| Important modifier moved to the END of the class: `bg-red-500!`, `flex!` | ✅ Verified | `upgrade-guide.mdx` |
| Arbitrary CSS variables use parens: `bg-(--brand-color)` (not `bg-[--brand-color]`) | ✅ Verified | `upgrade-guide.mdx` |
| Stacked variants apply left-to-right in v4 (v3: right-to-left)     | ✅ Verified | `upgrade-guide.mdx` |
| `hover:` compiles to `@media (hover: hover)`                       | ✅ Verified | `hover-focus-and-other-states.mdx` |
| `@theme` defines design tokens that generate utility classes; variables must be top-level, not nested; `:root` for plain CSS variables | ✅ Verified | `theme.mdx` |
| `@utility` adds custom utilities that work with variants (`hover`, `focus`, `lg`) | ✅ Verified | `functions-and-directives.mdx` |
| `@source` explicitly registers source files missed by automatic content detection | ✅ Verified | `functions-and-directives.mdx` |
| `@reference` needed to use `@apply`/`@variant` in Vue/Svelte `<style>` blocks or CSS modules | ✅ Verified | `functions-and-directives.mdx` |
| Class detection treats source files as plain text — dynamic concatenation/interpolation is not detected | ✅ Verified | `detecting-classes-in-source-files.mdx` |
| Component classes go in `@layer components` (still overridable by utilities) | ✅ Verified | `adding-custom-styles.mdx` |
| Browser support floor: Chrome 111, Safari 16.4, Firefox 128        | ✅ Verified | `compatibility.mdx` |
| Bare `shadow`/`rounded`/`blur` renamed: bare still compiles but renders at the `-sm` size; the old v3 look is now `-xs` | ✅ Verified | `upgrade-guide.mdx` (rows added 2026-11-03 after eval iteration-1 caught the gap) |
| v4 preflight sets buttons to `cursor: default` (v3: `pointer`); restore via `@layer base` styles | ✅ Verified | `upgrade-guide.mdx` "Buttons use the default cursor" (added 2026-11-03) |
| Prefix syntax: `@import "tailwindcss" prefix(tw);` with `tw:` class prefix | ✅ Verified | `upgrade-guide.mdx` |

## v3 → v4 syntax moves

Agents trained mostly on v3 produce illegal v4. The six moves that bite:

1. **Import**: `@import "tailwindcss";` — `@tailwind base/components/utilities`
   directives are gone.
2. **Important modifier**: suffix, not prefix — `bg-red-500!`, `flex!`,
   `hover:bg-red-600/50!` (v3 was `!bg-red-500`).
3. **Arbitrary CSS variables**: parens, not brackets — `bg-(--brand-color)`
   (v4 rejects `bg-[--brand-color]`; brackets still work for literal values
   like `mt-[117px]`).
4. **Stacked variant order**: v4 applies left-to-right (`dark:hover:*` reads
   like CSS nesting); order-sensitive stacks written for v3 are backwards in
   v4.
5. **Scale renames**: bare `shadow`, `rounded`, `blur` still compile but
   render at the `-sm` size — code that migrates 1:1 silently renders
   smaller. The old v3 look is the new `-xs` (`shadow-xs`, `rounded-xs`).
6. **Button cursor**: v4 preflight sets buttons to `cursor: default` (v3
   preflight used `pointer`). Silent UX regression; restore with a
   `@layer base` rule setting `button:not(:disabled) { cursor: pointer; }`
   if you want v3 behavior.

## Scanning behavior (the silent-failure class)

- Tailwind reads source files as **plain text** — it does not parse your code.
  Any token that *looks* like a class name is picked up; nothing else is.
- **Dynamic class names do not exist**: `` `text-${color}-600` ``, string
  concatenation, and prop-driven construction produce classes the build never
  sees — the page silently loses the style. Fix: write every complete class
  name somewhere static and select between full names.
- Sources outside automatic detection (packages, generated files, unusual
  paths) need `@source "../node_modules/@my-company/ui-lib";` in the entry CSS.

## Directive rules

- `@theme` variables **must be top-level** — nesting them under a selector or
  media query is a hard error, enforced precisely because theme variables do
  double duty as CSS variables AND utility generators.
- Custom utilities that must respond to variants (`hover`, `focus`, `lg`) are
  written with `@utility` — that is the directive's whole point.
- Component classes (`card`, `btn`, `badge`) go in `@layer components` so
  utilities in markup can still override them.
- Using `@apply` or `@variant` inside a Vue/Svelte `<style>` block or a CSS
  module requires `@reference` to the main stylesheet — without it the theme
  variables and custom utilities are not in scope there.

## Environment

- `hover:` compiles to `@media (hover: hover)` — on touch-only devices hover
  styles never apply. Anything reachable only via hover is unreachable there.
- The supported browser floor is modern-only (Chrome 111, Safari 16.4,
  Firefox 128). Utilities built on bleeding-edge platform features
  (`field-sizing`, `@starting-style`) have narrower support — check Can I use
  before relying on them for critical layout.
- A project can namespace everything: `@import "tailwindcss" prefix(tw);`
  gives every utility a `tw:` prefix — relevant when Tailwind must coexist
  with another styling system.
