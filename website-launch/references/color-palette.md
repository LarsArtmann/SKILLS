# Accent Color Palette — Pre-Computed CSS Tokens

> Each accent color requires ~25 CSS custom properties across `global.css`
> and `starlight.css` for both dark and light mode. This table eliminates
> manual `rgba()` computation.
>
> **Note:** This reference covers accent tokens only. The base palette
> (`--color-bg-primary`, `--color-text-primary`, `--color-border`, etc.)
> also needs to be set in `global.css`. See the "Non-Accent CSS Tokens"
> section in [file-manifest.md](./file-manifest.md) for base palette
> guidance per project.

## Color Palette Table

```css
/* global.css — dark mode */
--color-accent: #10b981;
--color-accent-hover: #34d399;
--color-accent-dim: rgba(16, 185, 129, 0.08);
--color-accent-light: #6ee7b7;
--color-border-accent: rgba(16, 185, 129, 0.3);

/* global.css — light mode */
--color-accent: #059669;
--color-accent-hover: #10b981;
--color-accent-dim: rgba(5, 150, 105, 0.06);
--color-accent-light: #34d399;
--color-border-accent: rgba(5, 150, 105, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #064e3b;
--sl-color-accent: #10b981;
--sl-color-accent-high: #34d399;

/* starlight.css — light mode */
--sl-color-accent-high: #059669;
--sl-color-accent: #10b981;
--sl-color-accent-low: #ecfdf5;
```

Theme color: `#10b981`

```css
/* global.css — dark mode */
--color-accent: #22d3ee;
--color-accent-hover: #67e8f9;
--color-accent-dim: rgba(34, 211, 238, 0.08);
--color-accent-light: #a5f3fc;
--color-border-accent: rgba(34, 211, 238, 0.3);

/* global.css — light mode */
--color-accent: #0e7490;
--color-accent-hover: #06b6d4;
--color-accent-dim: rgba(14, 116, 144, 0.06);
--color-accent-light: #67e8f9;
--color-border-accent: rgba(14, 116, 144, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #083344;
--sl-color-accent: #22d3ee;
--sl-color-accent-high: #67e8f9;

/* starlight.css — light mode */
--sl-color-accent-high: #0e7490;
--sl-color-accent: #06b6d4;
--sl-color-accent-low: #ecfeff;
```

Theme color: `#22d3ee`

```css
/* global.css — dark mode */
--color-accent: #7c3aed;
--color-accent-hover: #8b5cf6;
--color-accent-dim: rgba(124, 58, 237, 0.08);
--color-accent-light: #a78bfa;
--color-border-accent: rgba(124, 58, 237, 0.3);

/* global.css — light mode */
--color-accent: #6d28d9;
--color-accent-hover: #7c3aed;
--color-accent-dim: rgba(109, 40, 217, 0.06);
--color-accent-light: #8b5cf6;
--color-border-accent: rgba(109, 40, 217, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #4c1d95;
--sl-color-accent: #7c3aed;
--sl-color-accent-high: #a78bfa;

/* starlight.css — light mode */
--sl-color-accent-high: #6d28d9;
--sl-color-accent: #7c3aed;
--sl-color-accent-low: #f5f3ff;
```

Theme color: `#7c3aed`

```css
/* global.css — dark mode */
--color-accent: #e8a838;
--color-accent-hover: #f0bc5c;
--color-accent-dim: rgba(232, 168, 56, 0.08);
--color-accent-light: #f5cd7c;
--color-border-accent: rgba(232, 168, 56, 0.3);

/* global.css — light mode */
--color-accent: #c4861e;
--color-accent-hover: #e8a838;
--color-accent-dim: rgba(196, 134, 30, 0.06);
--color-accent-light: #f0bc5c;
--color-border-accent: rgba(196, 134, 30, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #2a2014;
--sl-color-accent: #e8a838;
--sl-color-accent-high: #f0bc5c;

/* starlight.css — light mode */
--sl-color-accent-high: #c4861e;
--sl-color-accent: #e8a838;
--sl-color-accent-low: #fffbeb;
```

Theme color: `#e8a838`

```css
/* global.css — dark mode */
--color-accent: #f43f5e;
--color-accent-hover: #fb7185;
--color-accent-dim: rgba(244, 63, 94, 0.08);
--color-accent-light: #fda4af;
--color-border-accent: rgba(244, 63, 94, 0.3);

/* global.css — light mode */
--color-accent: #be123c;
--color-accent-hover: #f43f5e;
--color-accent-dim: rgba(190, 18, 60, 0.06);
--color-accent-light: #fb7185;
--color-border-accent: rgba(190, 18, 60, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #4c0519;
--sl-color-accent: #f43f5e;
--sl-color-accent-high: #fb7185;

/* starlight.css — light mode */
--sl-color-accent-high: #be123c;
--sl-color-accent: #f43f5e;
--sl-color-accent-low: #fff1f2;
```

Theme color: `#f43f5e`

```css
/* global.css — dark mode */
--color-accent: #6366f1;
--color-accent-hover: #818cf8;
--color-accent-dim: rgba(99, 102, 241, 0.08);
--color-accent-light: #a5b4fc;
--color-border-accent: rgba(99, 102, 241, 0.3);

/* global.css — light mode */
--color-accent: #4f46e5;
--color-accent-hover: #6366f1;
--color-accent-dim: rgba(79, 70, 229, 0.06);
--color-accent-light: #818cf8;
--color-border-accent: rgba(79, 70, 229, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #312e81;
--sl-color-accent: #6366f1;
--sl-color-accent-high: #818cf8;

/* starlight.css — light mode */
--sl-color-accent-high: #4f46e5;
--sl-color-accent: #6366f1;
--sl-color-accent-low: #eef2ff;
```

Theme color: `#6366f1`

```css
/* global.css — dark mode */
--color-accent: #3b82f6;
--color-accent-hover: #60a5fa;
--color-accent-dim: rgba(59, 130, 246, 0.08);
--color-accent-light: #93c5fd;
--color-border-accent: rgba(59, 130, 246, 0.3);

/* global.css — light mode */
--color-accent: #2563eb;
--color-accent-hover: #3b82f6;
--color-accent-dim: rgba(37, 99, 235, 0.06);
--color-accent-light: #60a5fa;
--color-border-accent: rgba(37, 99, 235, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #1e3a5f;
--sl-color-accent: #3b82f6;
--sl-color-accent-high: #60a5fa;

/* starlight.css — light mode */
--sl-color-accent-high: #2563eb;
--sl-color-accent: #3b82f6;
--sl-color-accent-low: #eff6ff;
```

Theme color: `#3b82f6`

### Violet (`#8b5cf6`)

Used by: go-filewatcher

```css
/* global.css — dark mode */
--color-accent: #8b5cf6;
--color-accent-hover: #a78bfa;
--color-accent-dim: rgba(139, 92, 246, 0.08);
--color-accent-light: #c4b5fd;
--color-border-accent: rgba(139, 92, 246, 0.3);

/* global.css — light mode */
--color-accent: #7c3aed;
--color-accent-hover: #8b5cf6;
--color-accent-dim: rgba(124, 58, 237, 0.06);
--color-accent-light: #a78bfa;
--color-border-accent: rgba(124, 58, 237, 0.25);

/* starlight.css — dark mode */
--sl-color-accent-low: #4c1d95;
--sl-color-accent: #8b5cf6;
--sl-color-accent-high: #a78bfa;

/* starlight.css — light mode */
--sl-color-accent-high: #7c3aed;
--sl-color-accent: #6d28d9;
--sl-color-accent-low: #f5f3ff;
```

Theme color: `#8b5cf6`

## Color Derivation Formula

If you need a color not listed above, derive the full palette from the base
hex:

| Token                  | Formula                                             |
| ---------------------- | --------------------------------------------------- |
| `accent` (dark)        | Base hex                                            |
| `accent-hover`         | +10% lightness (Tailwind 400 → 300 equivalent)      |
| `accent-dim`           | `rgba(r, g, b, 0.08)` (dark) / `0.06` (light)       |
| `accent-light`         | +20% lightness                                      |
| `border-accent`        | `rgba(r, g, b, 0.3)` (dark) / `0.25` (light)        |
| `accent` (light)       | -10% lightness (darker shade for contrast on white) |
| `sl-color-accent-low`  | Tailwind 900 equivalent (darkest)                   |
| `sl-color-accent-high` | Tailwind 300 equivalent (lightest, dark mode)       |

Use a tool like [Tint and Shade Generator](https://maketintsandshades.com)
to compute precise values from a hex code.
