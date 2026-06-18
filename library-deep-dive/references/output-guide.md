# Output Guide — Library Deep Dive HTML Report

Defines the section structure, component mapping, and content guidance for the
library deep dive report. This complements the shared design system — read
[../assets/html-report-kit/references/html-output-guide.md](../assets/html-report-kit/references/html-output-guide.md)
for the CSS spec, tokens, and component catalog first.

## Table of Contents

- [Template Choice](#template-choice)
- [Report Sections](#report-sections)
- [Component Mapping](#component-mapping)
- [Content Quality Rules](#content-quality-rules)
- [Code Example Highlighting](#code-example-highlighting)

---

## Template Choice

Use the **editorial light** template (`report-template-editorial.html`) as the starting
point. Library deep dives are long-form research findings — the editorial theme's warm,
readable layout, sticky sidebar TOC, and issue-card vocabulary fit this report type best.

Copy the template, keep the CSS design tokens and component styles intact, and write
the report-specific content into the body.

---

## Report Sections

The report has these sections, in order. Each maps to the editorial template's
component vocabulary.

### 1. Hero

The opening frame. Sets the library, version, date, and scope.

```html
<header class="hero">
  <div class="eyebrow">LIBRARY DEEP DIVE &middot; YYYY-MM-DD</div>
  <h1><Library Name> — Adoption &amp; Utilization Audit</h1>
  <p class="subtitle">One or two sentences: what this library is, why it matters to the project, and the headline finding.</p>
  <div class="meta">
    <span class="tag amber">Version: 5.3.2</span>
    <span class="tag">Latest: 5.4.1</span>
    <span class="tag teal">Adoption Score: 64/100</span>
  </div>
</header>
```

### 2. Scorecard

The at-a-glance metrics row. Use `.scorecard` / `.score-card`.

Include 4–5 cards:

| Card                 | Score source                       | State class                   |
| -------------------- | ---------------------------------- | ----------------------------- |
| Adoption Score       | 0–100 from Phase 4                 | color by band (good/warn/bad) |
| Features Leveraged   | fully-leveraged / total applicable | `.score-good` if > 60%        |
| Missed Opportunities | count of 🔴 findings               | `.score-bad` if > 5           |
| Anti-Patterns        | count of ⚠️ findings               | `.score-bad` if > 0           |
| Version Gap          | versions behind latest             | `.score-warn` if major behind |

### 3. Summary (the bottom line)

A short prose section with one `.callout-amber` callout stating the single most
important takeaway. Example:

```html
<div class="callout callout-amber">
  <strong>The bottom line</strong>
  The project uses Zod for input validation but misses schema composition, discriminated unions, and
  the .transform() pipeline — all of which would eliminate ~200 lines of hand-rolled validation
  across 12 files.
</div>
```

### 4. Current Usage (what the project does today)

A `.strengths` list of how the library is currently used — the established baseline.
Each `.strength` item names a usage pattern and the files where it appears. This shows
the audit is grounded in the actual codebase, not generic library docs.

Follow with a prose paragraph describing the architecture of the current usage: how
the library is imported, configured, wrapped, and called.

### 5. Capability Assessment (the core — feature by feature)

This is the heart of the report. Each capability gets an `.issue` card graded by
adoption status:

```html
<div class="issue issue-critical" id="missed-streaming">
  <span class="severity severity-critical">Missed Opportunity &middot; High impact</span>
  <h3>Streaming API unused — all queries load fully into memory</h3>
  <div class="where">src/db/queries.go:45-89 &middot; 4 call sites</div>
  <p>
    What the library offers, what the project does instead, and the impact of the gap. Cite the doc
    reference and the code location.
  </p>
  <div class="callout callout-teal">
    <strong>Recommendation</strong>
    Concrete code example showing the recommended usage.
  </div>
  <pre><code>// Before: loads everything
rows := db.Find(&amp;results)

// After: streams lazily
db.FindInBatches(&amp;results, 1000, func(tx) error {
    return process(results)
})</code></pre>
</div>
```

Map each adoption status to the issue card variant:

| Status                            | Card class         | Severity class        | Use for                            |
| --------------------------------- | ------------------ | --------------------- | ---------------------------------- |
| Missed Opportunity                | `.issue-critical`  | `.severity-critical`  | High-impact unused features        |
| Missed Opportunity (lower impact) | `.issue-important` | `.severity-important` | Useful but not urgent              |
| Partially Used                    | `.issue-important` | `.severity-important` | Weaker API in use, stronger exists |
| Misused / Anti-Pattern            | `.issue-critical`  | `.severity-critical`  | Active harm — deprecated, footgun  |
| Fully Leveraged                   | `.issue-nice`      | `.severity-nice`      | Done right — builds confidence     |

Order the cards by impact (highest first). Group related findings together.

Every card must have:

- A `.where` div citing the file(s) and line(s) in the project (or "not used anywhere" for missed features)
- A `<p>` explaining the gap with doc reference
- A `.callout-teal` recommendation block
- A `<pre><code>` before/after example (for actionable findings)

### 6. Version Currency

A `.compare` table showing what's changed between the installed version and the latest:

```html
<table class="compare">
  <thead>
    <tr>
      <th>Version</th>
      <th>Type</th>
      <th>Notable Change</th>
      <th>Relevance</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>5.4.0</td>
      <td>Feature</td>
      <td>Added streaming query API</td>
      <td class="yes">High — see finding above</td>
    </tr>
    <tr>
      <td>5.3.0</td>
      <td>Breaking</td>
      <td>Renamed <code>.Chain()</code> to <code>.Pipe()</code></td>
      <td class="no">Migration needed</td>
    </tr>
  </tbody>
</table>
```

If the project is on the latest version, state that with a `.callout-teal` callout.

### 7. Top Opportunities (prioritized action plan)

The Pareto-ranked action list from Phase 4. Present as a `.compare` table:

```html
<table class="compare">
  <thead>
    <tr>
      <th>#</th>
      <th>Opportunity</th>
      <th>Impact</th>
      <th>Ease</th>
      <th>Priority</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>Enable connection pooling (config change)</td>
      <td class="yes">5</td>
      <td class="yes">5</td>
      <td><span class="highlight">25</span></td>
    </tr>
    <!-- ... -->
  </tbody>
</table>
```

Sort descending by Priority (impact × ease). Include 10–15 items max.

### 8. Conclusion

A short closing paragraph summarizing the adoption posture and the single highest-
leverage next step. Keep it to 3–4 sentences.

### 9. Footer

The standard template footer with the generation date and tool attribution.

---

## Component Mapping

Quick reference for which editorial component serves which purpose in this report:

| Component                           | Purpose in this report                             |
| ----------------------------------- | -------------------------------------------------- |
| `.hero` + `.eyebrow` + `.meta` tags | Library name, version, date, score                 |
| `.scorecard` / `.score-card`        | At-a-glance metrics                                |
| `.callout-amber`                    | The bottom line, warnings, key takeaways           |
| `.callout-teal`                     | Recommendations, positive notes                    |
| `.strengths` / `.strength`          | Current usage baseline                             |
| `.issue` + `.severity` + `.where`   | Feature-by-feature assessment                      |
| `.compare` table                    | Version gap, priority matrix                       |
| `<pre><code>`                       | Before/after code examples                         |
| `.highlight`                        | Inline emphasis on scores/numbers                  |
| `.dep-tree`                         | (If useful) import/dependency graph of the library |

---

## Content Quality Rules

Every finding in the report must be **evidence-backed**:

1. **Cite the code.** Every claim about current usage includes a `file:line` reference
   (use `.where`). "The project doesn't use X" is acceptable for missed opportunities,
   but "the project hand-rolls X" must cite where.

2. **Cite the docs.** Every claim about library capabilities references where it's
   documented — official docs URL, Context7 query result, or changelog entry. Do not
   assert a feature exists without a source.

3. **Show the fix.** Every actionable finding (Partially Used, Missed Opportunity,
   Misused) includes a concrete before/after code example. The "after" must use the
   library's real API, verified via docs — not a guessed API.

4. **Quantify impact.** Where possible, state the impact numerically: "~200 lines of
   hand-rolled code eliminated", "3× faster bulk inserts", "eliminates 4 potential
   nil-pointer paths". Vague "improves performance" is low quality.

5. **Be honest about relevance.** Not every feature is a missed opportunity. Use the
   "Not Applicable" judgment liberally — a library with 100 features where 30 are
   relevant and 25 of those are well-used is a strong adoption, not a failure.

---

## Code Example Highlighting

Use manual `.tok-*` syntax highlighting classes from the shared kit for code examples.
Wrap keywords, types, strings, and comments:

```html
<pre><code><span class="tok-keyword">const</span> <span class="tok-function">schema</span> = z.<span class="tok-function">object</span>({
  <span class="tok-property">email</span>: z.<span class="tok-type">string</span>().<span class="tok-function">email</span>(),
  <span class="tok-property">age</span>: z.<span class="tok-type">number</span>().<span class="tok-function">min</span>(<span class="tok-number">18</span>),
})</code></pre>
```

Keep examples short and focused on the specific capability being demonstrated. Full
file context is not needed — the reader wants to see the pattern, not a complete module.
