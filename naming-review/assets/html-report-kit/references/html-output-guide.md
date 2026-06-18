# HTML Output Guide

The shared design specification for all skills that produce HTML reports.

## Two Template Variants

The kit ships two self-contained templates. Both use the **Bauhaus** design
language — primary colors (red, blue, yellow) on a neutral ground. Form follows
function. Pick the variant that matches the report's tone.

| Variant             | File                                                                                   | Best for                                              | Visual feel                                                            |
| ------------------- | -------------------------------------------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------- |
| **Bauhaus Dark**     | [`../assets/report-template.html`](../assets/report-template.html)                     | Status dashboards, scan results, high-density metrics | Graphite ground + primary accents, sharp corners, optional hero shapes |
| **Bauhaus Light**    | [`../assets/report-template-editorial.html`](../assets/report-template-editorial.html) | Adoption feedback, architecture reviews, audit briefs | Warm paper + primary color blocks, sticky sidebar, heavy sans-serif    |

Both templates share the **same semantic token vocabulary** and the same
component class names — only the primitive color values differ. A skill can
copy either as its starting point and swap palettes by editing only the
primitive values in `:root`.

See [`bauhaus-tokens.md`](./bauhaus-tokens.md) for the full token architecture
spec and the rationale behind the unified vocabulary.

## When to Use HTML vs Markdown

The `Artifact` decision rule (see `how-to-write-skills.md`):

| lifecycle | audience    | mutability | → format |
| --------- | ----------- | ---------- | -------- |
| Snapshot  | HumanReport | WriteOnce  | **HTML** |
| Living    | ToolParsed  | Upsert     | Markdown |
| Living    | EndUserDoc  | Upsert     | Markdown |

**HTML is for snapshot reports** — status updates, reviews, plans, proposals, audits.
**Markdown is for living docs** — `FEATURES.md`, `TODO_LIST.md`, `AGENTS.md`.

## Design Requirements

- **Single file**, zero external dependencies (no CDN, no build step, no external fonts)
- **Responsive** — sidebar collapses below 1024px, grids collapse to single column on mobile
- **Self-contained** — anyone can open the `.html` file in a browser with no server
- **Manual CSS syntax highlighting** via language-agnostic `.tok-*` classes
- **Semantic color coding** — problem/solution/warning meanings are identical in both themes
- **Sharp corners** (`--radius: 0`) per Bauhaus aesthetic — override per-report if needed
- **Progressive enhancement** — nav works via plain anchor links; optional scrollspy script
  highlights the active section without breaking if JS is disabled

### Typography note

Both templates use system font stacks so reports work offline. The Bauhaus look
comes from heavy weights (800/900) and tight tracking, not from a specific
typeface. If a report wants premium typography and accepts the tradeoff, add a
Google Fonts `<link>` and override `--font-heading`/`--font-body` in `:root`.
This trades the zero-dependency rule for typography — never the default.

### Optional scrollspy

Both templates include a tiny IntersectionObserver script (~20 lines) that
highlights the active sidebar item as the reader scrolls. It is **progressive
enhancement** — if JS is disabled, the nav still works via `<a href="#section">`
anchor jumps with `scroll-behavior: smooth`. The script auto-discovers any
`[data-nav]` container and links it to sections by id. To disable, delete the
`<script>` block.

## CSS Design Tokens

### Unified semantic vocabulary (BOTH templates)

Both templates share the same semantic token names. Only the primitive values
differ. This kills the prior split brain where dark used `--bg-elevated` /
`--rose` and light used `--bg-card` / `--coral` for the same concepts.

```css
:root {
  /* Surfaces */
  --surface;            /* page background */
  --surface-raised;     /* cards, elevated panels */
  --surface-sunken;     /* code blocks, inset areas */

  /* Text */
  --text;               /* primary body text */
  --text-muted;         /* secondary text */
  --text-faint;         /* labels, captions */

  /* Lines */
  --border;             /* hairlines */
  --border-strong;      /* emphasized borders */

  /* Semantic status — identical in both templates */
  --accent;             /* primary brand accent (red on light, amber on dark) */
  --problem;            /* errors, critical findings */
  --solution;           /* good news, passing tests */
  --warning;            /* cautions, warnings */

  /* Shape + Type */
  --radius:    0px;     /* Bauhaus default: sharp corners */
  --font-heading;
  --font-body;
  --font-mono;
}
```

### Bauhaus Dark primitives

```css
:root {
  --color-graphite:   #0e0e10;
  --color-graphite-2: #18181d;
  --color-graphite-3: #16161a;
  --color-bone:       #f4f4f0;
  --color-red:        #ff6b6b;   /* lifted for dark-bg contrast */
  --color-blue:       #6eb5ff;
  --color-yellow:     #f4d35e;
  --color-amber:      #ffb347;   /* warmer than yellow for accent */

  /* Map semantic → primitive */
  --surface:        var(--color-graphite);
  --surface-raised: var(--color-graphite-2);
  --surface-sunken: var(--color-graphite-3);
  --text:           var(--color-bone);
  --accent:         var(--color-amber);
  --problem:        var(--color-red);
  --solution:       var(--color-blue);
  --warning:        var(--color-yellow);
}
```

### Bauhaus Light primitives

```css
:root {
  --color-paper:   #f4f4f0;
  --color-paper-2: #ffffff;
  --color-paper-3: #e8e8e2;
  --color-ink:     #111111;
  --color-red:     #e63946;
  --color-blue:    #1d3557;
  --color-yellow:  #f4d35e;

  /* Map semantic → primitive */
  --surface:        var(--color-paper);
  --surface-raised: var(--color-paper-2);
  --surface-sunken: var(--color-paper-3);
  --text:           var(--color-ink);
  --accent:         var(--color-red);
  --problem:        var(--color-red);
  --solution:       var(--color-blue);
  --warning:        var(--color-yellow);
}
```

### `color-mix()` replaces glow tokens

The previous kit defined paired tokens (`--rose` + `--rose-glow`, `--amber` +
`--amber-light`) — 8 redundant tokens hand-maintained. Modern CSS derives
translucent variants on demand:

```css
/* Old: two tokens, drift-prone */
background: var(--rose-glow);

/* New: derived from the single solid token */
background: color-mix(in srgb, var(--problem) 15%, transparent);
```

Browser support: Chrome 111+, Safari 16.2+, Firefox 113+ (all shipping since
early 2023).

### Backward-compatible aliases

The old token names still resolve via aliases so consumer skills that reference
`--rose`, `--coral`, `--bg-card`, `--ink`, `--emerald`, `--teal`, etc. keep
working unchanged:

```css
--rose:    var(--problem);
--coral:   var(--problem);
--emerald: var(--solution);
--teal:    var(--solution);
--amber:   var(--warning);
--bg:            var(--surface);
--bg-card:       var(--surface-raised);
--bg-elevated:   var(--surface-raised);
--bg-sunken:     var(--surface-sunken);
--ink:           var(--text);
--ink-secondary: var(--text-muted);
--hairline:      var(--border);
/* ...and the corresponding *-glow / *-light variants via color-mix() */
```

## Semantic Color Coding

With the unified vocabulary, the same class names mean the same thing in both
templates. The legacy aliases in parentheses still work.

| Meaning         | Token (both)         | Classes (both templates)                                                                                      |
| --------------- | -------------------- | ------------------------------------------------------------------------------------------------------------- |
| Problem / error | `--problem` (`--rose` / `--coral`)    | `.card-problem`, `.issue-critical`, `.stat-bad`, `.score-bad`, `.severity-critical`, `.badge-critical` |
| Solution / good | `--solution` (`--emerald` / `--teal`) | `.card-solution`, `.issue-nice`, `.stat-good`, `.score-good`, `.severity-nice`, `.callout-teal`       |
| Warning / risky | `--warning` (`--amber`)               | `.card-warning`, `.issue-important`, `.stat-warn`, `.score-warn`, `.severity-important`, `.callout-amber` |
| Highlight       | `--accent`           | `.hero-badge`, `.eyebrow`, `.tag.amber`, `h2 .num`, `.toc` left border                                        |

## Component Catalog

All components are defined in the templates. Copy what you need and delete the
rest.

### Layout with Sidebar TOC

Wrap content in `.layout` with `.sidebar` + `.main`. The sidebar is sticky and
hidden below 1100px.

```html
<div class="layout">
  <aside class="sidebar">
    <nav>
      <div class="label">Contents</div>
      <a href="#summary">Summary</a>
      <a href="#findings">Findings</a>
    </nav>
  </aside>
  <main class="main">
    <!-- report body -->
  </main>
</div>
```

### Hero

Dark dashboard:

```html
<div class="hero">
  <div class="hero-badge">Report Type</div>
  <h1>Report Title</h1>
  <p class="hero-subtitle">Short description.</p>
</div>
```

Editorial light:

```html
<header class="hero">
  <div class="eyebrow">REPORT TYPE &middot; YYYY-MM-DD</div>
  <h1>Report Title</h1>
  <p class="subtitle">One or two sentences that set the frame.</p>
  <div class="meta">
    <span class="tag amber">Scope: example</span>
    <span class="tag">Version: 1.0.0</span>
  </div>
</header>
```

### Stat / Score Cards

Both class vocabularies are aliased across templates, so you can use whichever
name reads better; the markup stays portable if you switch themes later.

Dark dashboard uses `.stat-grid` / `.stat-card` with optional state classes:

```html
<div class="stat-grid">
  <div class="stat-card stat-good">
    <div class="stat-value">35</div>
    <div class="stat-label">Resolved</div>
  </div>
  <div class="stat-card stat-warn">
    <div class="stat-value">3</div>
    <div class="stat-label">Warnings</div>
  </div>
  <div class="stat-card stat-bad">
    <div class="stat-value">1</div>
    <div class="stat-label">Blockers</div>
  </div>
</div>
```

Editorial light uses `.scorecard` / `.score-card` with the same state classes
renamed:

```html
<div class="scorecard">
  <div class="score-card score-good">
    <div class="score">8</div>
    <div class="label">Passing</div>
  </div>
  <div class="score-card score-warn">
    <div class="score">3</div>
    <div class="label">Warnings</div>
  </div>
  <div class="score-card score-bad">
    <div class="score">1</div>
    <div class="label">Blockers</div>
  </div>
</div>
```

### General Cards

Dark dashboard:

```html
<div class="card card-problem"><!-- rose left border --></div>
<div class="card card-solution"><!-- emerald left border --></div>
<div class="card card-warning"><!-- amber left border --></div>
<div class="card"><!-- neutral --></div>
```

### Issue Cards

Use for individual findings. Includes severity badge and file/line metadata.

```html
<div class="issue issue-critical">
  <span class="severity severity-critical">Blocking</span>
  <h3>Issue title</h3>
  <div class="where">path/to/file.go:42-58</div>
  <p>Description of the problem.</p>
</div>
```

Variant classes: `.issue-critical`, `.issue-important`, `.issue-nice`.
Severity classes: `.severity-critical`, `.severity-important`, `.severity-nice`.

### Badges

Inline severity indicators for tables and cards.

```html
<span class="badge badge-critical">Critical</span>
<span class="badge badge-high">High</span>
<span class="badge badge-medium">Medium</span>
<span class="badge badge-low">Low</span>
<span class="badge badge-fixed">Fixed</span>
```

### Callouts

Dark dashboard:

```html
<div class="callout callout-solution">
  <strong>Fix</strong>
  Recommended action goes here.
</div>
<div class="callout callout-warning">
  <strong>Watch out</strong>
  Compounding factor or caveat.
</div>
```

Editorial light:

```html
<div class="callout callout-teal">
  <strong>Fix: recommended action</strong>
  Concrete next step.
</div>
<div class="callout callout-amber">
  <strong>The bottom line</strong>
  Verdict or caveat.
</div>
```

### Tables

Full-width, hover-highlighted. Use badges inside cells for severity. Add
`.compare` to the `<table>` for the editorial comparison style.

```html
<table>
  <thead>
    <tr>
      <th>Column</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Value</td>
    </tr>
  </tbody>
</table>
```

### Before/After Comparison

Dark dashboard uses a split grid with headers:

```html
<div class="compare-header">
  <div class="compare-before">Before</div>
  <div class="compare-after">After</div>
</div>
<div class="compare-row">
  <div>Old code or state</div>
  <div>New code or state</div>
</div>
```

Editorial light uses a single comparison table:

```html
<table class="compare">
  <thead>
    <tr>
      <th>Issue</th>
      <th>Severity</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Issue one</td>
      <td class="no">Critical</td>
      <td class="no">Open</td>
    </tr>
    <tr>
      <td>Issue two</td>
      <td class="no">Important</td>
      <td class="yes">Fixed</td>
    </tr>
  </tbody>
</table>
```

### Numbered Steps

For migration roadmaps and execution plans.

```html
<div class="migration-step">
  <div class="migration-num">1</div>
  <div class="migration-content">
    <h4>Step title</h4>
    <p>Step description.</p>
  </div>
</div>
```

### Numbered Section Headings

```html
<h2><span class="num">01</span>Findings</h2>
<h2><span class="num">&diams;</span>Strengths</h2>
```

### Strengths List

Use to acknowledge what already works before listing problems.

```html
<div class="strengths">
  <div class="strength">
    <div class="check">+</div>
    <div class="text">
      <strong>Specific strength</strong>
      <span>Explain why it matters.</span>
    </div>
  </div>
</div>
```

### Dependency Tree / ASCII Diagram

For module graphs, import trees, or lightweight architecture diagrams.

```html
<div class="dep-tree">
  <span class="root">root</span> ├── <span class="ok">wanted-dep</span> └──
  <span class="unwanted">unwanted-dep</span>
</div>
```

### Inline Diagrams

For simple node-and-arrow visuals:

```html
<div class="diagram">
  <span class="node node-core">Core</span>
  <span class="arrow">→</span>
  <span class="node">Module</span>
</div>
```

### Grid Layouts

```html
<div class="grid-2"><!-- 2 columns, collapses on mobile --></div>
<div class="grid-3"><!-- 3 columns, collapses on mobile --></div>
```

### Footer

```html
<footer class="footer">Generated YYYY-MM-DD &middot; Reviewed against version X.Y.Z</footer>
```

## Syntax Highlighting

Use **language-agnostic** `.tok-*` classes (not `.go-*` or `.ts-*`):

```css
.tok-keyword {
  color: #c678dd;
} /* func, type, struct, if, return */
.tok-type {
  color: #e5c07b;
} /* int, string, bool, error */
.tok-string {
  color: #98c379;
} /* "quoted strings" */
.tok-comment {
  color: #5c6370;
  font-style: italic;
}
.tok-func {
  color: #61afef;
} /* function names */
.tok-number {
  color: #d19a66;
} /* 42, 3.14 */
.tok-generic {
  color: #e06c75;
} /* T, ID in generics */
.tok-builtin {
  color: #56b6c2;
} /* make, len, append, fmt.Println */
.tok-punct {
  color: #abb2bf;
} /* { } ( ) ; = : */
.tok-attr {
  color: #d19a66;
} /* Nix attribute names, struct tags */
```

Apply manually by wrapping tokens in spans:

```html
<pre><code><span class="tok-comment">// Go example</span>
<span class="tok-keyword">func</span> <span class="tok-func">main</span>() {
  <span class="tok-builtin">fmt</span>.<span class="tok-func">Println</span>(<span class="tok-string">"hello"</span>)
}

<span class="tok-comment"># Nix example</span>
<span class="tok-punct">{</span> <span class="tok-attr">pkgs</span><span class="tok-punct">,</span> <span class="tok-attr">lib</span><span class="tok-punct">,</span> ... <span class="tok-punct">}:</span>
<span class="tok-attr">packages</span>.<span class="tok-attr">default</span> <span class="tok-punct">=</span> <span class="tok-builtin">pkgs</span>.<span class="tok-func">buildGoModule</span> <span class="tok-punct">{</span>
  <span class="tok-attr">pname</span> <span class="tok-punct">=</span> <span class="tok-string">"my-project"</span><span class="tok-punct">;</span>
<span class="tok-punct">}</span></code></pre>
```

## Filename Convention

```
docs/<category>/<YYYY-MM-DD>_<short-slug>.html
```

Categories: `status/`, `planning/`, `architecture-understanding/`, `brainstorming/`,
`reviews/`, `proposals/`, `feedback/`.

## Quick Start

1. Decide whether the report should feel like a **dashboard** (dark template)
   or an **audit brief** (editorial template).
2. Copy the chosen template to the target path.
3. Open [`example-editorial-report.html`](./example-editorial-report.html) to see a
   fully rendered report using every component in the Bauhaus editorial theme.
4. Delete the example sections you don't need.
5. Replace placeholder text, ids, and TOC links.
6. Keep the CSS design tokens intact unless you are intentionally theming.
   The semantic tokens (`--surface`, `--text`, `--problem`, `--solution`,
   `--warning`, `--accent`) are the same in both templates — swapping palettes
   means editing only the primitive values in `:root`.
7. To theme for a different brand, override the **primitive** colors
   (`--color-red`, `--color-blue`, etc.) and the semantic layer follows.
8. The optional `.hero-shapes` cluster (circle / square / triangle / bar) is the
   Bauhaus signature. Remove it for a quieter hero; keep it for reports that
   benefit from a strong visual anchor.

For the full token architecture rationale, see
[`bauhaus-tokens.md`](./bauhaus-tokens.md).
