# HTML Output Guide

The shared design specification for all skills that produce HTML reports.

## Design Requirements

- **Single file**, zero external dependencies (no CDN, no JS, no build step, no external fonts)
- **Dark theme** with semantic color coding
- **Manual CSS syntax highlighting** via language-agnostic `.tok-*` classes
- **Responsive grid layouts** for comparisons and stats
- **Self-contained** — anyone can open the `.html` file in a browser with no server

## CSS Design Tokens

```css
:root {
  --bg: #0f172a;
  --bg-elevated: #1e293b;
  --bg-sunken: #020617;
  --text: #e2e8f0;
  --text-dim: #94a3b8;
  --text-faint: #64748b;
  --accent: #6366f1;
  --accent-glow: rgba(99, 102, 241, 0.15);
  --rose: #f43f5e;
  --rose-glow: rgba(244, 63, 94, 0.15);
  --emerald: #10b981;
  --emerald-glow: rgba(16, 185, 129, 0.15);
  --amber: #f59e0b;
  --amber-glow: rgba(245, 158, 11, 0.15);
  --cyan: #06b6d4;
  --border: #334155;
  --radius: 12px;
  --font-mono: ui-monospace, "Cascadia Code", "Source Code Pro", Menlo, Consolas, monospace;
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}
```

## Semantic Color Coding

| Color   | Token        | Meaning         | CSS class              |
| ------- | ------------ | --------------- | ---------------------- |
| Rose    | `--rose`     | Problem / error | `.card-problem`        |
| Emerald | `--emerald`  | Solution / good | `.card-solution`       |
| Amber   | `--amber`    | Warning / risky | `.card-warning`        |
| Indigo  | `--accent`   | Highlight       | `.stat-value`, `.toc` |

## Component Catalog

All components are defined in `../assets/report-template.html`. Copy what you need.

### Hero

Title block with radial-gradient glow. Every report starts with one.

```html
<div class="hero">
  <div class="hero-badge">Report Type</div>
  <h1>Report Title</h1>
  <p class="hero-subtitle">Short description of what this report covers.</p>
</div>
```

### Stat Cards

For metrics dashboards (issue counts, pass/fail, totals).

```html
<div class="stat-grid">
  <div class="stat-card">
    <div class="stat-value">42</div>
    <div class="stat-label">Label</div>
  </div>
</div>
```

### Cards with Severity Borders

For individual findings, problems, recommendations.

```html
<div class="card card-problem">  <!-- rose left border -->
<div class="card card-solution">  <!-- emerald left border -->
<div class="card card-warning">   <!-- amber left border -->
<div class="card">                <!-- neutral -->
```

### Badges

Inline severity indicators for tables and cards.

```html
<span class="badge badge-critical">Critical</span>
<span class="badge badge-high">High</span>
<span class="badge badge-medium">Medium</span>
<span class="badge badge-low">Low</span>
<span class="badge badge-fixed">Fixed</span>
```

### Tables

Full-width, dark-themed, hover-highlighted. Use badges inside cells for severity.

```html
<table>
  <thead><tr><th>Column</th></tr></thead>
  <tbody><tr><td>Value</td></tr></tbody>
</table>
```

### Before/After Comparison

Side-by-side grid with colored headers.

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

### Numbered Steps

For migration roadmaps, execution plans.

```html
<div class="migration-step">
  <div class="migration-num">1</div>
  <div class="migration-content">
    <h4>Step title</h4>
    <p>Step description.</p>
  </div>
</div>
```

### Table of Contents

Sticky navigation for long reports.

```html
<nav class="toc">
  <h3>Contents</h3>
  <ul>
    <li><a href="#section">Section Name</a></li>
  </ul>
</nav>
```

### Diagrams

Inline visual structures using styled nodes and arrows (for lightweight diagrams;
use D2→inline SVG for complex architectures).

```html
<div class="diagram">
  <span class="node node-core">Core</span>
  <span class="arrow">→</span>
  <span class="node">Module</span>
</div>
```

### Grid Layouts

```html
<div class="grid-2">  <!-- 2 columns, collapses on mobile -->
<div class="grid-3">  <!-- 3 columns, collapses on mobile -->
```

## Syntax Highlighting

Use **language-agnostic** `.tok-*` classes (not `.go-*` or `.ts-*`):

```css
.tok-keyword  { color: #c678dd; }  /* func, type, struct, if, return */
.tok-type     { color: #e5c07b; }  /* int, string, bool, error */
.tok-string   { color: #98c379; }  /* "quoted strings" */
.tok-comment  { color: #5c6370; font-style: italic; }
.tok-func     { color: #61afef; }  /* function names */
.tok-number   { color: #d19a66; }  /* 42, 3.14 */
.tok-generic  { color: #e06c75; }  /* T, ID in generics */
.tok-builtin  { color: #56b6c2; }  /* make, len, append */
```

Apply manually by wrapping tokens in spans:

```html
<pre><code><span class="tok-keyword">func</span> <span class="tok-func">main</span>() {
  <span class="tok-builtin">fmt</span>.<span class="tok-func">Println</span>(<span class="tok-string">"hello"</span>)
}</code></pre>
```

## Filename Convention

```
docs/<category>/<YYYY-MM-DD>_<short-slug>.html
```

Categories: `status/`, `planning/`, `architecture-understanding/`, `brainstorming/`,
`reviews/`, `proposals/`.
