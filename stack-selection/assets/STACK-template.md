# STACK — <project name>

> The deliberate foundation of this project: every significant dependency was
> chosen, not accumulated. Generated <YYYY-MM-DD> by the stack-selection skill
> (profile: <shape>, e.g. "Go CLI tool" / "event-sourced web service").
> This is a LIVING document — update the row when the reason changes, delete
> the row when the dependency goes.
> Enforced by `stack-selection/scripts/stack-drift-check.sh <project-dir>`:
> every direct github.com/larsartmann/* require must have a Chosen foundation
> row. Exit 0 = consistent; exit 1 = undeclared or contradicted dep; exit 2 =
> this file is missing.

## Profile

| Axis          | Answer |
| ------------- | ------ |
| Shape         | <CLI / library / HTTP service / web app / daemon / collector> |
| Domain        | <one line> |
| Persistence   | <none / SQLite / Postgres / event store> |
| Interfaces    | <terminal / HTTP+HTMX / JSON API / SSE / unix socket> |
| Scale target  | <single user / small team / production service> |
| Constraints   | <nix build, private deps, offline, ...> |

## Chosen foundation

| Category              | Choice (first-party = ★)          | Why this, not that                                     | Owning skill / docs              | Revisit when                       |
| --------------------- | --------------------------------- | ------------------------------------------------------ | -------------------------------- | ---------------------------------- |
| CLI framework         | ★ cmdguard                        | typed flags + DI + exit-code contract; raw cobra leaks | `cmdguard` skill                 | command set stabilizes differently |
| Output rendering      | ★ go-output                       | one data structure → every format                      | README + pkg.go.dev              | output needs exceed its formats    |
| Validation            | sivchari/govalid                  | codegen, zero allocs (how-to-golang policy)            | how-to-golang                    | —                                  |
| ...                   | ...                               | ...                                                     | ...                              | ...                                 |

Rules for this table:

- One row per concern actually needed by the profile — not per category in
  the capability map. Absent concern = absent row.
- "Why this, not that" must name the rejected alternative. A choice without
  a rejected alternative was not a decision.
- First-party libs are marked ★ and MUST have been verified to exist
  (README + go.mod + tagged version) before this table was written.

## Deliberately excluded

| Candidate        | Reason                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| go-cqrs-lite     | CRUD without event-history invariants — sqlc is simpler (YAGNI)        |
| ...              | ...                                                                     |

Every high-importance candidate the profile plausibly touched belongs here
with a reason — silence about a known candidate is an unmade decision, not a
decision.

## Wiring order

1. <e.g. go.mod init + `go get` the chosen libs — pinned versions>
2. <e.g. load the `cmdguard` skill for command wiring>
3. <e.g. flake.nix via go-nix-helpers; private deps via nix-private-go-repos skill>
4. <e.g. buildflow quality gate — load `buildflow` skill>

## Decision log

- <YYYY-MM-DD> — Initial selection (stack-selection skill, session <context>).
