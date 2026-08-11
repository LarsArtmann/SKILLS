---
name: architecture-review
description: Use when the user asks about architecture quality, scalability, modularity, coupling and cohesion, service orientation, composability, or says "architecture review", "review my architecture", "architecture audit", "architecture quality", "how modular is this", "coupling analysis", or wants to assess the structural health of a codebase. Reviews the current architecture and gives a structural assessment. Distinct from full-code-review (covers all issue types file-by-file, not just architecture) and code-quality-scan (automated tools only, no architectural judgment).
metadata:
  tags: architecture, scalability, modularity, service-oriented, composable
---

# Architecture Review

## Questions to Answer

1. How scalable/modular is the current Architecture?
2. How can we make this repo more:
   - Service oriented?
   - Composable?

## Output

Write the review to `docs/architecture-understanding/YYYY-MM-DD_HH-mm_<name>.html` where
`<name>` is a short descriptive slug for the review focus (e.g. `modularity`,
`service-orientation`, `coupling`). Use the current timestamp for the date prefix. Create
the directory if it doesn't exist.

Use the shared design system from the `html-report-kit` skill:

- Design spec: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
- Template: [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html)

Map the review to visual components:

- **Stat cards** for module/package count, coupling score, interface count
- **`.card-problem`** for coupling hotspots, scalability blockers
- **`.card-solution`** for composability wins and concrete recommendations
- **Before/after comparison** for current vs. proposed architecture
- **Numbered-step components** for the action roadmap

> Architecture reviews are point-in-time snapshots. When a later task asks to
> bring old reviews current, use [`docs-health`](../docs-health/SKILL.md) →
> **ANNOTATE** mode — annotate non-destructively, never rewrite.
>
> **The action roadmap above is forward-looking work.** If it isn't already in
> `TODO_LIST.md` / `ROADMAP.md`, run [`docs-health`](../docs-health/SKILL.md) →
> **HARVEST** to pull it out — otherwise the roadmap rots in this timestamped
> file. (The canonical "when to run HARVEST" rule lives in docs-health; do not
> restate it here.)

## Process

1. **Map the structure** — generate the dependency graph, identify layers, catalog public API surfaces, measure module sizes. See [./references/review-methodology.md](./references/review-methodology.md) → Structural mapping.
2. **Analyze dependencies** — detect cycles, measure coupling metrics (afferent/efferent), check dependency direction (domain should NOT import infrastructure). See [./references/review-methodology.md](./references/review-methodology.md) → Dependency analysis.
3. **Check domain alignment** — map domain concepts to code modules, look for split-brain patterns, evaluate naming against domain language. See [./references/review-methodology.md](./references/review-methodology.md) → Domain alignment.
4. **Identify pain points** — change ripple analysis, god modules, dead code, testing pain. See [./references/review-methodology.md](./references/review-methodology.md) → Pain point identification.
5. **Score each dimension** — Coupling, Cohesion, Modularity, Composability, Scalability, Service Orientation, Dependency Direction. See [./references/assessment-rubric.md](./references/assessment-rubric.md) for the 1-5 rubric.
6. **Write the action roadmap** — concrete recommendations with priority levels (P0-P3), impact, effort, and ordering constraints. See [./references/review-methodology.md](./references/review-methodology.md) → Recommendation framework.
