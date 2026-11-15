# Candidate Report Format

The report is a brief for choosing one refactor, not an assessment. It renders as a single self-contained HTML file (no CDN, no network at read time), using the shared `html-report-kit`.

Destination: `docs/architecture-understanding/YYYY-MM-DD_HH-mm_<slug>-deepening.html`. Honor `ARCH_DEEPENING_OUT` / `ARCH_REVIEW_OUT` when set. Never the OS temp directory.

## Before writing

1. List the destination directory and skim the most recent 1-3 reports: reused candidates, resolved findings, and earlier recommendations change what counts as new.
2. Copy [`../assets/html-report-kit/assets/report-template.html`](../assets/html-report-kit/assets/report-template.html) and edit it. Never re-type CSS from memory or from a rendered report — transcription drift reintroduces bugs the kit already fixed.
3. Pick the **editorial-light** variant: a brief reads better on paper stock than on a dashboard ground.

Vendored kit files:

- Template: `../assets/html-report-kit/assets/report-template.html`
- Design spec and component catalog: `../assets/html-report-kit/references/html-output-guide.md`

Edit the canonical `html-report-kit/` at the repo root and run `scripts/sync-html-kit.sh`; the copy inside `assets/` is a build artifact.

## Page structure

| Section            | Content                                                                                      |
| ------------------ | -------------------------------------------------------------------------------------------- |
| Hero               | Repo name, date, commit scanned, one-line scope statement (what was looked at, what was not) |
| Legend             | Solid box = module, dashed line = seam, red arrow = leakage, thick box = deep module         |
| Candidate cards    | One per candidate, ordered by recommendation strength                                        |
| Top recommendation | One card: candidate name, one sentence on why, anchor link to its card                       |
| Footer             | `Generated YYYY-MM-DD · Reviewed against <commit>`                                           |

No introduction paragraph. No executive summary. The cards carry the report.

## Candidate card

Each candidate is one `<article class="card">`:

- **Title** — names the deepening, not the symptom: "Collapse the Order intake pipeline", not "Order code is messy".
- **Badge row** — recommendation strength via `.badge`: `Strong` → `.badge-critical`, `Worth exploring` → `.badge-high`, `Speculative` → `.badge-low`. Add a second badge for the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files** — monospaced list with `.where` styling.
- **Before / after** — the centrepiece, two columns (`.compare-header` + `.compare-row`, or `.grid-2` with hand-built diagram divs).
- **Problem** — one sentence: what hurts, in glossary terms.
- **Solution** — one sentence: what changes.
- **Wins** — at most six bullets of six words or fewer: "Tests hit one interface", "Pricing stops leaking", "Deletes four shallow wrappers".
- **ADR callout** — only when the candidate contradicts a recorded decision: a `.callout` stating the ADR id and the friction that justifies reopening it.

If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate; vary them across cards so the page does not become wallpaper.

**Before/after pair (default).** Two equal columns. Left shows the shallowness, right shows the deepening.

**Mass diagram (interface vs implementation).** Two stacked rectangles per module: one for interface surface, one for implementation. Shallow: interface height nearly matches implementation. Deep: interface is a thin band over a tall body. Build with `.diagram`/`.node` plus inline heights.

**Cross-section (layered shallowness).** Stack horizontal bands for the layers a call passes through. Before: six thin bands, each doing nothing. After: one thick band labelled with the consolidated responsibility.

**Call-graph collapse.** Before: nested boxes approximating the call tree. After: one box with the same calls faded inside it, showing they became internal.

**Inline node-and-arrow.** For "one caller, many modules" shapes, use `.diagram` + `.node` + `.arrow` rather than a custom SVG.

Diagrams stay around 320px tall so a pair fits side by side without scrolling. Module labels use small caps or letter-spacing so they read as schematic, not as UI.

For graph-shaped relationships that genuinely need layout (long dependency cycles, sequence timing), do not import Mermaid: hand the diagram to [`architecture-visualization`](../../architecture-visualization/SKILL.md) and render D2 SVG into the page.

## Language discipline

Domain nouns come from the project's glossary (`GLOSSARY.md` or `docs/DOMAIN_LANGUAGE.md`); architecture nouns come from `deepening-vocabulary.md`.

Use exactly: module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

Never substitute: component, service, unit (for module) · API, signature (for interface) · boundary (for seam) · layer, wrapper (for module, when module is meant).

Phrasings that fit:

- "Order intake module is shallow: the interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in production, in-memory in tests."

Wins name the gain in glossary terms — "locality: bugs concentrate in one module", "leverage: one interface, N call sites", "interface shrinks, implementation absorbs the wrappers". "Easier to maintain" and "cleaner code" name no mechanism and do not earn a bullet.

No hedging, no throat-clearing. If a sentence could be a bullet, make it a bullet; if a bullet could be cut, cut it.
