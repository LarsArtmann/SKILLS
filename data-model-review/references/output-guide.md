# HTML Output Guide

The data-model-review skill produces a self-contained HTML presentation at `docs/brainstorming/YYYY-MM-DD_<slug>.html`.

## Design Requirements

- **Single file**, zero external dependencies (no CDN, no JS, no build step)
- **Dark theme** with semantic color coding
- **Manual CSS syntax highlighting** for Go
- **Responsive grid layouts** for comparisons
- **Cards** with left-border color coding:
  - `var(--rose)` = problem
  - `var(--emerald)` = solution
  - `var(--amber)` = warning

## Required Sections

1. **Hero** — Title, subtitle, "Architecture Deep-Dive" badge
2. **Table of Contents** — sticky nav
3. **Current State** — type count, problem count, severity breakdown as stat cards
4. **Problem Catalog** — each problem as a card with severity badge and Go fix
5. **The Vision** — 6 bullet points on what perfection looks like
6. **Go Data Model** — full type definitions with syntax highlighting
7. **Composition in Action** — side-by-side before/after comparisons
8. **Validation Layer** — how invalid states become unrepresentable
9. **Decision Log** — why each design choice was made
10. **Anti-Patterns** — traps to avoid when adopting the new model
11. **Migration Roadmap** — numbered incremental steps with tooling
12. **Conclusion** — summary quote

## Go Syntax Highlighting CSS Classes

```css
.go-keyword { color: #c678dd; }   /* package, func, type, struct, interface */
.go-type    { color: #e5c07b; }   /* int, string, bool, error, time.Time */
.go-string  { color: #98c379; }   /* "quoted strings" */
.go-comment { color: #5c6370; font-style: italic; } /* // comments */
.go-func    { color: #61afef; }   /* function names */
.go-number  { color: #d19a66; }   /* 42, 3.14 */
.go-generic { color: #e06c75; }   /* T, ID in generics */
.go-builtin { color: #56b6c2; }   /* make, len, cap, append */
```

## Example Filename

`docs/brainstorming/2026-06-05_user-domain-redesign.html`
