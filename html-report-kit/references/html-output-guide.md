# HTML Output Guide

The shared design specification for all skills that produce HTML reports.

## Two Template Variants

The kit now ships two self-contained templates. Pick the one that matches the
report's tone and audience.

| Variant | File | Best for | Visual feel |
| ------- | ---- | -------- | ----------- |
| **Dark dashboard** | [`../assets/report-template.html`](../assets/report-template.html) | Status dashboards, scan results, high-density metrics | Dark slate + indigo, glass cards, radial glow |
| **Editorial light** | [`../assets/report-template-editorial.html`](../assets/report-template-editorial.html) | Adoption feedback, architecture reviews, audit briefs | Warm paper + amber/teal, sticky sidebar, editorial typography |

Both templates share the same component vocabulary (issue cards, callouts,
scorecards, dep-trees, etc.) but use different palettes and layouts. A skill can
copy either as its starting point.

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

- **Single file**, zero external dependencies (no CDN, no JS, no build step, no external fonts)
- **Responsive** — sidebar collapses on narrow viewports, grids collapse to single column
- **Self-contained** — anyone can open the `.html` file in a browser with no server
- **Manual CSS syntax highlighting** via language-agnostic `.tok-*` classes
- **Semantic color coding** — problem/solution/warning meanings are the same in both themes

### Typography note

Both templates use system font stacks so reports work offline. If you want the
premium look of external fonts (e.g. Space Grotesk, Inter, JetBrains Mono), add
the Google Fonts `<link>` and update `--font-heading`, `--font-body`, and
`--font-mono` in `:root`. This is optional and trades the zero-dependency rule
for typography.

## CSS Design Tokens

### Dark dashboard theme

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
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}
```

### Editorial light theme

```css
:root {
  --bg: #faf9f7;
  --bg-card: #ffffff;
  --bg-code: #f6f5f3;
  --ink: #1a1a2e;
  --ink-secondary: #475569;
  --ink-muted: #94a3b8;
  --hairline: #e8e6e1;
  --amber: #b45309;
  --amber-light: #fef3c7;
  --teal: #0e7490;
  --teal-light: #ecfeff;
  --coral: #dc2626;
  --coral-light: #fef2f2;
  --font-heading: ui-rounded, "SF Pro Rounded", "Segoe UI Variable Display", system-ui, sans-serif;
  --font-body: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --font-mono: ui-monospace, "Cascadia Code", "Source Code Pro", Menlo, Consolas, monospace;
}
```

## Semantic Color Coding

| Meaning | Dark token | Dark class | Editorial token | Editorial class |
| ------- | ---------- | ---------- | --------------- | --------------- |
| Problem / error | `--rose` | `.card-problem`, `.issue-critical`, `.stat-bad`, `.severity-critical` | `--coral` | `.issue-critical`, `.score-bad`, `.severity-critical` |
| Solution / good | `--emerald` | `.card-solution`, `.issue-nice`, `.stat-good`, `.severity-nice` | `--teal` | `.issue-nice`, `.score-good`, `.severity-nice`, `.callout-teal` |
| Warning / risky | `--amber` | `.card-warning`, `.stat-warn`, `.severity-important` | `--amber` | `.issue-important`, `.score-warn`, `.severity-important`, `.callout-amber` |
| Highlight | `--accent` | `.stat-value`, `.toc` | `--amber` | `.eyebrow`, `.tag.amber`, `h2 .num` |

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
  <div class="score-card score-good"><div class="score">8</div><div class="label">Passing</div></div>
  <div class="score-card score-warn"><div class="score">3</div><div class="label">Warnings</div></div>
  <div class="score-card score-bad"><div class="score">1</div><div class="label">Blockers</div></div>
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
  <thead><tr><th>Column</th></tr></thead>
  <tbody><tr><td>Value</td></tr></tbody>
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
    <tr><th>Issue</th><th>Severity</th><th>Status</th></tr>
  </thead>
  <tbody>
    <tr><td>Issue one</td><td class="no">Critical</td><td class="no">Open</td></tr>
    <tr><td>Issue two</td><td class="no">Important</td><td class="yes">Fixed</td></tr>
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
<div class="dep-tree"><span class="root">root</span>
├── <span class="ok">wanted-dep</span>
└── <span class="unwanted">unwanted-dep</span></div>
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
<footer class="footer">
  Generated YYYY-MM-DD &middot; Reviewed against version X.Y.Z
</footer>
```

## Syntax Highlighting

Use **language-agnostic** `.tok-*` classes (not `.go-*` or `.ts-*`):

```css
.tok-keyword { color: #c678dd; } /* func, type, struct, if, return */
.tok-type    { color: #e5c07b; } /* int, string, bool, error */
.tok-string  { color: #98c379; } /* "quoted strings" */
.tok-comment { color: #5c6370; font-style: italic; }
.tok-func    { color: #61afef; } /* function names */
.tok-number  { color: #d19a66; } /* 42, 3.14 */
.tok-generic { color: #e06c75; } /* T, ID in generics */
.tok-builtin { color: #56b6c2; } /* make, len, append, fmt.Println */
.tok-punct   { color: #abb2bf; } /* { } ( ) ; = : */
.tok-attr    { color: #d19a66; } /* Nix attribute names, struct tags */
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
   fully rendered report using every component.
4. Delete the example sections you don't need.
5. Replace placeholder text, ids, and TOC links.
6. Keep the CSS design tokens intact unless you are intentionally theming.
