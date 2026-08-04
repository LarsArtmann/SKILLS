# Architecture Assessment Rubric

> Score each dimension on a 1-5 scale. Use the criteria as evidence checkpoints —
> every score must cite specific code paths or structural patterns.

## Contents

1. [Coupling](#coupling)
2. [Cohesion](#cohesion)
3. [Modularity](#modularity)
4. [Composability](#composability)
5. [Scalability](#scalability)
6. [Service Orientation](#service-orientation)
7. [Dependency Direction](#dependency-direction)
8. [Overall scoring](#overall-scoring)

---

## Coupling

**Question:** How tightly do modules depend on each other's internal details?

| Score | Description                                                                                                                    |
| ----- | ------------------------------------------------------------------------------------------------------------------------------ |
| 5     | Modules communicate through well-defined interfaces; no knowledge of internal implementation. Dependency injection throughout. |
| 4     | Mostly interface-driven; occasional concrete-type dependencies in non-critical paths.                                          |
| 3     | Mix of interface and concrete dependencies; some circular or bidirectional coupling.                                           |
| 2     | Heavy concrete dependencies; changes ripple across modules. Tight coupling to specific implementations.                        |
| 1     | God objects, import cycles, everything depends on everything. Changes break unrelated modules.                                 |

**What to check:**

- Import graph: are there cycles? Use `go mod graph` or dependency analysis tools
- Interface vs concrete type usage in function signatures
- Shared mutable state across module boundaries
- "Hidden" coupling via global state, singletons, or config shared across modules

---

## Cohesion

**Question:** How focused is each module/package on a single responsibility?

| Score | Description                                                                              |
| ----- | ---------------------------------------------------------------------------------------- |
| 5     | Every package has a clear single purpose; all types and functions serve that purpose.    |
| 4     | Mostly focused; minor leakage of unrelated utilities.                                    |
| 3     | Some packages mix 2-3 concerns but are mostly organized.                                 |
| 2     | Several packages are grab-bags of unrelated functionality.                               |
| 1     | Most packages contain unrelated code; `utils`, `common`, or `helpers` packages dominate. |

**What to check:**

- Package names: do they describe what the package does? (`utils`, `common`, `helpers` are anti-patterns)
- Types within each package: do they relate to each other?
- Functions within each package: do they operate on the same domain concepts?
- The "one paragraph test": can you describe what a package does in one sentence without using "and"?

---

## Modularity

**Question:** How well are boundaries defined and enforced?

| Score | Description                                                                                     |
| ----- | ----------------------------------------------------------------------------------------------- |
| 5     | Clear bounded contexts; module boundaries align with domain boundaries. Independently testable. |
| 4     | Well-defined boundaries; minor cross-cutting concerns leak across.                              |
| 3     | Boundaries exist but are porous; some modules reach into others' internals.                     |
| 2     | Boundaries are unclear; refactoring one module requires understanding many others.              |
| 1     | Monolithic — no meaningful module separation. Everything is interconnected.                     |

**What to check:**

- Can you draw a module dependency diagram that matches the domain model?
- Are there clear "public API" surfaces per module, or does everything export everything?
- Can a module be tested in isolation without extensive mocking of other modules?
- Does the directory structure reflect the architecture, or is it arbitrary?

---

## Composability

**Question:** How easily can components be recombined to form new functionality?

| Score | Description                                                                                                       |
| ----- | ----------------------------------------------------------------------------------------------------------------- |
| 5     | Components are designed for composition (small, focused, interface-driven). New features combine existing pieces. |
| 4     | Most components are composable; some require adaptation.                                                          |
| 3     | Moderate composability; new features require moderate refactoring of existing code.                               |
| 2     | Components are designed for specific use cases; reuse requires copy-paste or deep modification.                   |
| 1     | Code is written for one scenario; reuse is impossible without rewriting.                                          |

**What to check:**

- Are there shared abstractions (interfaces, mixins, traits) that multiple implementations satisfy?
- Can you compose a new workflow by wiring existing components together?
- Is configuration externalized, allowing the same component to be used in different contexts?
- Are there composable patterns (middleware, decorators, pipelines) or is everything hardcoded?

---

## Scalability

**Question:** How well will the architecture handle growth (features, traffic, team size)?

| Score | Description                                                                                               |
| ----- | --------------------------------------------------------------------------------------------------------- |
| 5     | Architecture scales linearly — new features extend without restructuring. Horizontal scaling is built-in. |
| 4     | Scales well with minor friction points at known thresholds.                                               |
| 3     | Scales adequately for current needs; some structural debt will impede future growth.                      |
| 2     | Architecture actively resists scaling — adding features requires touching many modules.                   |
| 1     | Architecture is at its scaling limit — every new feature is painful and risky.                            |

**What to check:**

- Database access patterns: are there N+1 queries, missing indexes, or shared-state bottlenecks?
- State management: is state distributed safely, or are there single-points-of-failure?
- Team scaling: can multiple teams work in parallel without stepping on each other?
- Feature scaling: does adding a new feature require touching >3 packages?

---

## Service Orientation

**Question:** Are concerns properly separated into independent services or service-like modules?

| Score | Description                                                                                             |
| ----- | ------------------------------------------------------------------------------------------------------- |
| 5     | Clear bounded contexts with independent lifecycles. Each service owns its data and exposes a clean API. |
| 4     | Service boundaries are clear; some shared infrastructure or databases.                                  |
| 3     | Monolith with clear internal module boundaries; ready for extraction if needed.                         |
| 2     | Monolith with unclear boundaries; extraction would require significant refactoring.                     |
| 1     | Big ball of mud — no separation of concerns.                                                            |

**What to check:**

- Data ownership: does each service/module own its data, or is there a shared mutable database?
- API contracts: are inter-service/inter-module contracts explicit (interfaces, schemas)?
- Deployment: could a module be deployed independently if needed?
- Domain alignment: do service boundaries align with DDD bounded contexts?

---

## Dependency Direction

**Question:** Do dependencies point in the right direction (toward stability, away from volatility)?

| Score | Description                                                                                                      |
| ----- | ---------------------------------------------------------------------------------------------------------------- |
| 5     | Dependencies always point toward stable abstractions. Business logic depends on interfaces, not implementations. |
| 4     | Mostly correct direction; minor violations in non-critical areas.                                                |
| 3     | Some dependencies point toward volatile modules; refactoring needed.                                             |
| 2     | Dependencies are arbitrary; business logic depends on infrastructure details.                                    |
| 1     | Dependencies are inverted — infrastructure controls business logic. Framework lock-in.                           |

**What to check:**

- Does business/domain logic depend on infrastructure packages (database, HTTP, framework)?
- Are there abstract interfaces in the domain layer that infrastructure implements (dependency inversion)?
- Is the codebase framework-agnostic, or is the framework woven throughout?
- Are third-party dependencies isolated behind interfaces?

---

## Overall scoring

Compute the average across all dimensions. Use the result to prioritize the action roadmap:

| Average | Verdict   | Action                                                                                       |
| ------- | --------- | -------------------------------------------------------------------------------------------- |
| 4.5-5.0 | Excellent | Maintain current architecture; document patterns for replication                             |
| 3.5-4.4 | Good      | Address lowest-scoring dimension; no urgent restructuring needed                             |
| 2.5-3.4 | Fair      | Targeted refactoring of the bottom 2 dimensions; structural debt is accumulating             |
| 1.5-2.4 | Poor      | Architecture is actively impeding development; restructuring is urgent                       |
| 1.0-1.4 | Critical  | The architecture may not be salvageable; consider a greenfield rewrite for the worst modules |
