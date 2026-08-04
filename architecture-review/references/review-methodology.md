# Review Methodology

> Step-by-step process for conducting an architecture review. Each step builds
> on the previous one — do not skip ahead. The goal is evidence-based findings,
> not impressions.

## Contents

1. [Structural mapping](#structural-mapping)
2. [Dependency analysis](#dependency-analysis)
3. [Domain alignment check](#domain-alignment-check)
4. [Pain point identification](#pain-point-identification)
5. [Recommendation framework](#recommendation-framework)

---

## Structural mapping

Before judging the architecture, understand what it IS.

1. **Generate the module/package dependency graph.**
   - For Go: `go mod graph` for module-level, or use `go dependency` analysis tools for package-level.
   - For JS/TS: `madge --circular --extensions ts src/`
   - Draw it (D2, Mermaid) — visual patterns reveal problems text hides.

2. **Identify the layer structure.**
   - Are there clear layers (domain, application, infrastructure, presentation)?
   - Does each layer have a single direction of dependency?
   - Are there cross-layer shortcuts that bypass the layering?

3. **Catalog the public API surface per module.**
   - How many exported types/functions does each package have?
   - Are exports intentional (documented interfaces) or accidental (everything exported)?
   - Which packages are imported by the most other packages? (high fan-in = stability dependency)

4. **Measure module sizes.**
   - Lines of code per package/module.
   - Number of files per package.
   - Flag any module >1000 lines or >20 files for review — it may be a god-module.

---

## Dependency analysis

The import graph is the architecture's skeleton. Problems here propagate everywhere.

1. **Detect cycles.**
   - Circular dependencies (A imports B imports A) are the #1 architecture smell.
   - For Go: `go mod graph | grep -c "^"` then cross-reference; or use cycle detection tools.
   - For JS/TS: `madge --circular --extensions ts src/`

2. **Measure coupling metrics.**
   - **Afferent coupling (Ca):** how many modules depend on this one. High = stable, hard to change.
   - **Efferent coupling (Ce):** how many modules this one depends on. High = fragile, many breakage vectors.
   - **Instability (I):** `Ce / (Ca + Ce)`. I=0 means maximally stable (dependents only). I=1 means maximally unstable (dependencies only).
   - Rule: stable packages (low I) should be at the bottom of the dependency stack.

3. **Check dependency direction.**
   - Domain/business packages should NOT import infrastructure packages.
   - Use the "highlight test": highlight all domain-layer imports. Any that point to `database`, `http`, `crypto`, or framework packages are violations.
   - Dependency inversion: are there interfaces in the domain layer that the infrastructure layer implements?

---

## Domain alignment check

Architecture should follow domain boundaries, not technical convenience.

1. **Map domain concepts to code modules.**
   - List the top 5-10 domain concepts (Order, Customer, Payment, etc.).
   - For each, find the code module that implements it.
   - If a concept spans multiple modules or a module implements multiple concepts → misalignment.

2. **Check for "split brain" patterns.**
   - Same domain concept defined in two places (e.g., `User` in both `auth` and `user` packages).
   - Same business logic duplicated across services.
   - Two types that represent the same entity with different names.

3. **Evaluate naming against domain language.**
   - Do module names use domain terms or technical jargon?
   - Would a domain expert understand the package structure?
   - Are there generic names (`service`, `manager`, `handler`) that could be more specific?

---

## Pain point identification

Find the places where the architecture actively hurts development.

1. **Ask the "change ripple" question for recent features.**
   - Pick the last 3-5 features added.
   - How many files/packages did each touch?
   - If a "small" feature touched >5 packages, the architecture is fighting the team.

2. **Identify "god" modules.**
   - Any module imported by >50% of other modules.
   - Any module with >1000 lines or >30 exported symbols.
   - Any module whose name is `common`, `util`, `core`, or `shared`.

3. **Find dead code and orphaned modules.**
   - Packages with no importers (except `main`).
   - Exported functions never called.
   - Entire modules that exist only for backwards compatibility.

4. **Locate testing pain.**
   - Which modules require the most mocking/setup to test?
   - Are there modules with 0% test coverage due to architectural constraints?
   - Integration tests that require a full system boot indicate tight coupling.

---

## Recommendation framework

Every recommendation must be concrete, prioritized, and traceable to evidence.

### Priority levels

| Priority | Criteria | Example |
|----------|----------|---------|
| P0 — Critical | Architecture actively blocking development or causing production incidents | Circular dependency causing deploy ordering issues |
| P1 — High | Architecture debt accumulating rapidly; will block within 1-3 months | God module growing with every feature |
| P2 — Medium | Structural friction; slows development but not blocking | Missing interface abstraction in a stable module |
| P3 — Low | Improvement opportunity; nice-to-have but no urgency | Rename misleadingly named package |

### Recommendation format

Each recommendation in the report should follow:

1. **Finding:** What is wrong (1 sentence, cite evidence — file paths, metrics)
2. **Impact:** Why it matters (what breaks, what slows down, what it costs)
3. **Recommendation:** What to do (concrete, actionable, with the target state)
4. **Effort:** Rough estimate (S/M/L) with the primary cost driver
5. **Dependencies:** What else must happen first (ordering constraint)

### Anti-patterns in recommendations

- **"Consider refactoring X"** — not actionable. Say WHAT to refactor it INTO.
- **"Improve modularity"** — too vague. Name the specific module and the specific split.
- **"Use design patterns"** — which pattern, where, and why?
- **"Reduce coupling"** — between which modules, using what technique?
