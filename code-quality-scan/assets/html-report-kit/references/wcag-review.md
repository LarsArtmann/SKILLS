# WCAG 2.1/2.2 AA review — Bauhaus templates

Mechanical review, 2026-11-23 (T96): contrast ratios computed from the
resolved CSS token values (rgba blends flattened over their surface);
landmarks, focus, heading order, and table headers checked by inspection of
both templates. Not a screen-reader pass — keyboard/SR behavior beyond
focus-visibility is untested.

## Contrast (computed)

| Pair                              | Dark    | Light            | Verdict                                          |
| --------------------------------- | ------- | ---------------- | ------------------------------------------------ |
| text / surface                    | 17.49:1 | 17.13:1          | PASS both                                        |
| text / surface-raised             | 16.04:1 | 18.88:1          | PASS both                                        |
| muted text / surface              | 9.28:1  | 7.21:1           | PASS both                                        |
| faint text / surface              | 4.24:1  | 3.49:1           | **FAIL both** at normal size (needs 4.5:1)       |
| problem(red) as text / surface    | 6.95:1  | 3.78:1           | Dark PASS; light large-text-only                 |
| accent as text / surface          | 10.83:1 | 3.78:1           | Dark PASS; light **FAIL at small sizes**         |
| solution as text / surface        | 8.92:1  | 11.21:1          | PASS both                                        |
| warning(yellow) as text / surface | 13.16:1 | 1.33:1           | Dark PASS; light never used as text (shapes only) |

Concrete light-template AA failures (SC 1.4.3), both small bold text in
`--accent` (#e63946, 3.78:1 on paper):

- `.eyebrow` — 0.72rem bold uppercase
- `h2 .num` — 0.82rem bold mono section numbers

Fix options for future series (a palette change alters every future report —
owner call): darken light `--accent` to ≥4.5:1 (e.g. #c11f2c ≈ 4.9:1), or
restrict accent to ≥18.66px bold / 24px text and use `--text` for eyebrow
and section numbers.

`--text-faint` (4.24:1 dark / 3.49:1 light) is fine for decorative labels
but must not carry meaningful small text; keep captions in `--text-muted`.

## Structure

| Check                          | Dark | Editorial | Notes                                             |
| ------------------------------ | ---- | --------- | ------------------------------------------------- |
| Landmarks (nav/main/aside/footer) | ✅  | ✅ (+header) |                                                  |
| `lang="en"`                    | ✅   | ✅        |                                                   |
| Focus visibility (`:focus-visible`) | ✅ | ✅       |                                                   |
| Heading order                  | h1→h3 skip | ✅    | Dark: sidebar h3 ("Contents") appears between h1 and first h2 — demote to a styled `<p class="label">` or accept (TOC is a nav region, not content flow) |
| Multiple `<nav>` without `aria-label` | ⚠️ 2 navs | 1 nav | Dark: label the TOC nav (`aria-label="Table of contents"`) |
| `<th>` without `scope="col"`   | ⚠️ 5 | ⚠️ 5      | Advisory; add scope for AT table navigation      |
| `scroll-behavior: smooth` without `prefers-reduced-motion` guard | ❌ | ❌ | FIXED 2026-11-23: guard added to both templates |

## Applied fixes (2026-11-23)

1. Both templates: `@media (prefers-reduced-motion: reduce)` guard disabling
   `scroll-behavior: smooth` (and transitions) — WCAG 2.3.3.

## Open items (owner-flavored design decisions)

1. Light accent contrast (eyebrow, h2 .num) — palette vs size-restriction
   decision above.
2. Dark faint-text usage sweep in consumer reports (rule: muted for meaning,
   faint for decoration only) — enforce at authoring time via this file.
