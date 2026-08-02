---
name: architecture-review
description: Reviews the current architecture for scalability, modularity, service orientation, and composability. Use when the user asks about architecture quality, scalability, modularity, coupling and cohesion, how to make the codebase more service-oriented or composable, or says "architecture review", "review my architecture", "architecture audit", "architecture quality", "how modular is this", "coupling analysis", or wants to assess the structural health of a codebase.
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
> bring old reviews current, defer to [`update-old-docs`](../update-old-docs/SKILL.md)
> — annotate non-destructively, never rewrite.
>
> **The action roadmap above is forward-looking work.** If it isn't already in
> `TODO_LIST.md` / `ROADMAP.md`, run [`docs-health`](../docs-health/SKILL.md) →
> **HARVEST** to pull it out — otherwise the roadmap rots in this timestamped
> file. (The canonical "when to run HARVEST" rule lives in docs-health; do not
> restate it here.)

## Process

1. Thoroughly research the codebase structure
2. Analyze module boundaries, dependencies, coupling
3. Assess scalability of current patterns
4. Evaluate composability and service orientation
5. Provide concrete, actionable recommendations
6. Write findings to the output file
