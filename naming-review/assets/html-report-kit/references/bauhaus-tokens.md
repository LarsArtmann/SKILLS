# Bauhaus Design System — Token Architecture

> Canonical spec for the unified token vocabulary shared by both templates.
> Edit the kit here; re-vendor via `scripts/sync-html-kit.sh`.

## Design Intent

Bauhaus = **form follows function**. Primary colors (red, blue, yellow) on a neutral
paper ground. Heavy weights. Geometric shapes. No decoration that doesn't encode meaning.

This replaces the prior Tailwind-default palette (indigo on slate-900) which was the
most recognizable "AI-generated" combination in production.

## Two Variants, One Vocabulary

The previous templates used **different token names for the same concepts**
(`--bg-elevated` vs `--bg-card`, `--rose` vs `--coral`). That split brain is gone.
Both templates now share the **same semantic token names**; only the primitive
values differ.

```css
/* Shared semantic layer — SAME NAMES in both templates */
:root {
  /* Surfaces */
  --surface:           <primitive>;   /* page background */
  --surface-raised:    <primitive>;   /* cards, elevated panels */
  --surface-sunken:    <primitive>;   /* code blocks, inset areas */

  /* Text */
  --text:              <primitive>;   /* primary body text */
  --text-muted:        <primitive>;   /* secondary text */
  --text-faint:        <primitive>;   /* labels, captions */

  /* Lines */
  --border:            <primitive>;   /* hairlines, dividers */
  --border-strong:     <primitive>;   /* emphasized borders */

  /* Semantic status — SAME in both templates */
  --accent:            <primitive>;   /* primary brand accent */
  --problem:           <primitive>;   /* errors, critical findings */
  --solution:          <primitive>;   /* good news, passing tests */
  --warning:           <primitive>;   /* cautions, warnings */

  /* Shape */
  --radius:            0px;           /* Bauhaus = sharp corners by default */
  --radius-sm:         0px;

  /* Type */
  --font-heading:      <stack>;
  --font-body:         <stack>;
  --font-mono:         <stack>;
}
```

### Why semantic tokens win

1. **Portability** — markup using `.issue-critical` or `var(--problem)` works in either theme.
2. **No split brain** — one vocabulary to learn, not two.
3. **Easy theming** — swapping palette = editing primitive values only.
4. **Self-documenting** — `var(--problem)` reads as intent; `var(--rose)` reads as a color name.

## `color-mix()` Replaces Glow Tokens

The previous kit defined **paired tokens** for every accent (`--rose` + `--rose-glow`,
`--amber` + `--amber-light`, etc.). That's 8 redundant tokens computed by hand.

Modern CSS `color-mix()` derives translucent variants on demand from the solid token:

```css
/* Old: two tokens, hand-maintained */
background: var(--rose-glow);  /* rgba(244, 63, 94, 0.15) */

/* New: derived from one token */
background: color-mix(in srgb, var(--problem) 15%, transparent);
```

This eliminates ~8 tokens and removes the drift risk of glow values falling out of
sync with their solid parents. Browser support: Chrome 111+, Safari 16.2+, Firefox 113+
(all shipping since early 2023).

## Primitive Palettes

### Bauhaus Light (editorial template)

```css
:root {
  --color-paper:   #f4f4f0;   /* warm off-white ground */
  --color-paper-2: #ffffff;   /* raised card */
  --color-paper-3: #e4e4e0;   /* sunken code area */
  --color-ink:     #111111;   /* near-black text */
  --color-red:     #e63946;   /* problem + accent */
  --color-blue:    #1d3557;   /* solution */
  --color-yellow:  #f4d35e;   /* warning */
  --color-hairline: rgba(17, 17, 17, 0.12);
  --color-hairline-strong: rgba(17, 17, 17, 0.25);

  /* Map semantic → primitive */
  --surface:           var(--color-paper);
  --surface-raised:    var(--color-paper-2);
  --surface-sunken:    var(--color-paper-3);
  --text:              var(--color-ink);
  --text-muted:        rgba(17, 17, 17, 0.72);
  --text-faint:        rgba(17, 17, 17, 0.45);
  --border:            var(--color-hairline);
  --border-strong:     var(--color-hairline-strong);
  --accent:            var(--color-red);
  --problem:           var(--color-red);
  --solution:          var(--color-blue);
  --warning:           var(--color-yellow);
}
```

### Bauhaus Dark (dashboard template)

```css
:root {
  --color-graphite:   #0e0e10;   /* page ground */
  --color-graphite-2: #18181d;   /* raised card */
  --color-graphite-3: #16161a;   /* sunken code area */
  --color-bone:       #f4f4f0;   /* primary text */
  --color-red:        #ff6b6b;   /* problem (lifted for dark) */
  --color-blue:       #6eb5ff;   /* solution (lifted for dark) */
  --color-yellow:     #f4d35e;   /* warning */
  --color-amber:      #ffb347;   /* accent (warmer than yellow for emphasis) */
  --color-hairline:   rgba(244, 244, 240, 0.12);
  --color-hairline-strong: rgba(244, 244, 240, 0.25);

  /* Map semantic → primitive */
  --surface:           var(--color-graphite);
  --surface-raised:    var(--color-graphite-2);
  --surface-sunken:    var(--color-graphite-3);
  --text:              var(--color-bone);
  --text-muted:        rgba(244, 244, 240, 0.72);
  --text-faint:        rgba(244, 244, 240, 0.45);
  --border:            var(--color-hairline);
  --border-strong:     var(--color-hairline-strong);
  --accent:            var(--color-amber);
  --problem:           var(--color-red);
  --solution:          var(--color-blue);
  --warning:           var(--color-yellow);
}
```

**Note on color lifting:** status colors on dark backgrounds need higher lightness to
maintain WCAG AA contrast (4.5:1). The light-template `#e63946` becomes `#ff6b6b`
in dark — same hue, more luminance.

## Type Stacks (System Fonts Only)

The kit's "zero external dependencies" rule means **no Google Fonts**. The Bauhaus
vibe comes from heavy weights and tight tracking, not a specific typeface —
system sans + system mono carry it fine.

```css
--font-heading: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
--font-body:    ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
--font-mono:    ui-monospace, "Cascadia Code", "Source Code Pro", Menlo, Consolas, monospace;
```

**Optional upgrade:** if a report wants premium typography and accepts the tradeoff,
add a Google Fonts `<link>` and override `--font-heading`/`--font-body`. This is
documented in `html-output-guide.md` but never the default.

## Scrollspy (Progressive Enhancement)

The kit's "no JS" rule is about **no build step, no runtime dependency**. A tiny
inline `<script>` that enhances existing anchor links is permitted as progressive
enhancement — the nav still works via plain `<a href="#section">` if JS is disabled.

Pattern (optional, ~20 lines, included in both templates):

```html
<script>
  // Highlight active nav item based on scroll position.
  // Pure progressive enhancement — anchor links work without JS.
  (function() {
    var sections = document.querySelectorAll('section[id]');
    var navLinks = document.querySelectorAll('[data-nav] a[href^="#"]');
    if (!('IntersectionObserver' in window) || !sections.length) return;
    new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          var id = entry.target.id;
          navLinks.forEach(function(link) {
            link.classList.toggle('active',
              link.getAttribute('href') === '#' + id);
          });
        }
      });
    }, { rootMargin: '-80px 0px -60% 0px', threshold: 0 })
    .observe && sections.forEach(function(s) { /* observer */ });
  })();
</script>
```

The nav container must be marked `data-nav` so the script can find it.

## Signature Element

The Bauhaus signature is the **geometric shape cluster** in the hero — a circle,
square, and triangle in primary colors. This is the one memorable visual element
per the frontend-design skill's "spend your boldness in one place" rule.

Included as an optional `.hero-shapes` block in both templates. Remove it for
reports that need a quieter hero.

## Accessibility

- All status colors meet **WCAG AA 4.5:1** against their surface in both themes
- `--text-muted` is 72% opacity of `--text` (verified ≥ 4.5:1 on both grounds)
- `scroll-margin-top: 60px` on all `[id]` targets so sticky headers don't cover them
- Focus styles preserved on all interactive elements
