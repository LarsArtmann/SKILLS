# Concrete Example — Monolith to Multi-module

> Reference for [../SKILL.md](../SKILL.md). Loaded on demand.

## Before — Monolith

```
github.com/org/eventstore/
├── go.mod                  # single module, everything coupled
├── cmd/
│   └── eventstore/
│       └── main.go         # imports everything
├── event/
│   ├── event.go            # domain types: Event, StreamID, Metadata
│   ├── store.go            # Store interface
│   ├── bus.go              # Bus interface + implementation
│   ├── codec.go            # JSON codec
│   └── snapshot.go         # snapshot logic
├── postgres/
│   ├── store.go            # postgres implementation of Store
│   └── migrations.go
├── projection/
│   ├── handler.go
│   └── registry.go
├── memory/
│   ├── store.go            # in-memory Store for testing
│   └── bus.go              # in-memory Bus for testing
└── testhelpers/
      ├── fixtures.go
      └── builders.go
```

## After — Multi-module with go.work + replace

```
github.com/org/eventstore/
├── go.work                           # workspace: domain + storage + memory + projection + testhelpers
├── go.work.sum
├── cmd/
│   └── eventstore/
│       └── main.go                   # wires domain + storage
│
├── domain/                           # MODULE 1 — domain types + interfaces
│   ├── go.mod                        # module: github.com/org/eventstore/domain/v3
│   │                                 #   zero internal deps, replace directives for none
│   └── event/
│       ├── event.go                  # Event, StreamID, Metadata
│       ├── store.go                  # Store interface
│       ├── bus.go                    # Bus interface
│       ├── errors.go                 # ErrNotFound, ErrStreamExists (owned by domain)
│       └── codec.go                  # Codec interface + JSON impl
│
├── storage/                          # MODULE 2 — postgres implementation
│   ├── go.mod                        # module: github.com/org/eventstore/storage/v3
│   │                                 #   depends on domain/v3, replace => ../domain
│   └── postgres/
│       ├── store.go                  # implements domain.event.Store
│       │                             #   var _ domain.Store = (*Store)(nil)  ← compile-time assertion
│       └── migrations.go
│
├── projection/                       # MODULE 3 — projection engine
│   ├── go.mod                        # module: github.com/org/eventstore/projection/v3
│   │                                 #   depends on domain/v3, replace => ../domain
│   └── projection/
│       ├── handler.go
│       └── registry.go
│
├── memory/                           # MODULE 4 — in-memory adapters (testing)
│   ├── go.mod                        # module: github.com/org/eventstore/memory/v3
│   │                                 #   depends on domain/v3, replace => ../domain
│   └── memory/
│       ├── store.go                  # implements domain.Store
│       └── bus.go                    # implements domain.Bus
│
└── testhelpers/                      # MODULE 5 — shared test utilities
      ├── go.mod                      # module: github.com/org/eventstore/testhelpers/v3
      │                               #   depends on domain/v3, replace => ../domain
      └── testhelpers/
          ├── fixtures.go
          └── builders.go
```

### go.work

```
go 1.26.4

use (
    .
    ./domain
    ./storage
    ./projection
    ./memory
    ./testhelpers
)
```

### domain/go.mod (leaf — no replace directives needed)

```
module github.com/org/eventstore/domain/v3

go 1.26.4
```

### storage/go.mod (uses dual strategy: replace for GOWORK=off)

```
module github.com/org/eventstore/storage/v3

go 1.26.4

require github.com/org/eventstore/domain/v3 v0.0.0

replace github.com/org/eventstore/domain/v3 => ../domain
```

## Key decisions in this example

| Decision                                  | Rationale                                                                                         |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `domain/` has zero internal deps          | Domain types must not depend on infrastructure (Unix: mechanism, not policy)                      |
| `errors.go` in `domain/`                  | `ErrNotFound` must be importable by storage consumers without importing storage                   |
| `memory/` is separate from `storage/`     | Test adapters should not force production deps on consumers                                       |
| `testhelpers/` depends only on domain     | Prevents transitive dep from domain → storage through test helpers                                |
| `cmd/` stays in root                      | Leaf node — nothing imports it, shares deps with root                                             |
| `codec.go` in domain, not separate module | JSON codec is small and tightly coupled to domain types — splitting would be over-modularization  |
| `/v3` suffix in all module paths          | Go major version convention — explicit version pinning for consumers                              |
| `replace` + `go.work` both used           | go.work for development, replace for `GOWORK=off` CI/consumer builds (see real-world-patterns.md) |
| `v0.0.0` for internal requires            | Eliminates pseudo-version churn — replace makes the version irrelevant for resolution             |
| Compile-time assertions in impl modules   | `var _ domain.Store = (*Store)(nil)` catches missing methods at build time                        |

## When the gate fails — a worked gate-2 dissolution

A developer proposes extracting a `validate` engine into its own module:
"validation is reusable, someone will want it someday." Run the gate, not the
vibe:

| Step              | Evidence requested                                       | What the proposal has                     |
| ----------------- | -------------------------------------------------------- | ----------------------------------------- |
| Gate 2, "real"    | A consumer in code that imports `validate` alone         | Only `validate`'s own tests import it     |
| Gate 2, "planned" | A NAMED consumer in a committed artifact, with a trigger | "Someone might" — no artifact, no trigger |

Verdict: FAIL. "Someone will want it someday" is not a credibly planned
consumer — the evidence bar demands a committed plan row, ADR, issue, or TODO
that names the consumer and the trigger that fires it. Dissolve: keep
`validate` as a package inside the parent (gates 1–4 still police it — one
purpose, enumerable surface, clean direction), and delete the module
boilerplate (go.mod, CI job, replace directives) that priced a boundary
nobody composes across.

The same seam PASSES six months later when the committed plan row "dashboard
consumes the engine via wire types only (pipe payoff)" lands its consumer:
now a real second composition exists that imports `validate` without any
sibling — the boundary earns its keep, and the extraction is mechanical
because the packages already passed gates 1–4.

Lesson: gates fail boundaries, not ambitions. A failed gate 2 is a deferral
with a named trigger, not a rejection — re-run the gate when the trigger
fires.

## When policy payoff pays — the carve no consumer will ever justify

The dissolution above is a library story. The app-monorepo story is its
mirror image, and applying only the pipe currency there dissolves everything
at any size:

A single-binary monorepo carries a committed root-slim policy ("keep the
root under 20k LOC") while its root module sits at 84k. A session gates the
strongest candidate, `internal/agent` (4,900 LOC, cohesive, direction-clean):

| Step                  | Evidence requested                                  | What the repo has                                         |
| --------------------- | --------------------------------------------------- | --------------------------------------------------------- |
| Gate 2, pipe payoff   | A consumer composing `agent` without siblings       | Structurally none — one binary consumes everything; every |
|                       |                                                     | consumer is a root-side sibling by definition             |
| Gate 2, policy payoff | A committed policy the boundary measurably advances | The root-slim policy: −4,900 LOC from a root 4× over its  |
|                       |                                                     | own ceiling, plus per-module CI for the brain             |

Verdict: PASS on the policy currency — and the pipe currency being
unavailable in a one-app repo cannot count against the candidate. The other
gates still bite: purpose ("own the agent brain"), direction (fix any
feature-layer imports first, as packages), surface (`internal/`), solo build
(`GOWORK=off`). Had the repo no committed policy, the same candidate
dissolves — but the dissolution then carries the FM#11 finding (an 84k root
bundling unrelated sub-domains is under-modularized by the skill's own
catalog) plus the owner question: ratify a size policy or accept the
monolith on the record. Never a silent "nothing to do".

Lesson: gate 2 prices a boundary in one of two currencies — pipe payoff
(someone composes across it) or policy payoff (a committed policy it
advances). A gate-2 that only ever weighs the first is not direction
neutrality; it is a keep-the-monolith bias wearing a gate's clothes.

## When gate 5 fails — a workspace fiction caught by the solo build

A team splits a monolith into `acme-core` and `acme-tools`. The proposal
reads well: two sentences of purpose, clean direction, everything sensible
`internal/`. Gate 5 is the mechanical one — run it, don't debate it:

```bash
cd acme-tools && GOWORK=off go build ./... && GOWORK=off go test ./...
```

It fails: `acme-tools` imports `github.com/acme/acme-core/internal/config`.
Inside the workspace the import resolves and everything builds — the split
LOOKS done. Outside it, the module cannot compile at all: the boundary only
exists while `go.work` is holding it up. That is the "workspace fiction"
failure: the module never earned independence, it borrowed it.

Two honest outcomes:

1. **Fix, then keep the split.** Promote the needed config to a real
   exported contract in `acme-core` (the consumer imports `config`, not
   `internal/config`), re-run gate 5 inside `acme-tools` until it is green
   with `GOWORK=off`. The module now stands alone — the workspace is
   convenience, not a load-bearing wall.
2. **Merge.** If nothing can be promoted without dragging half the parent's
   internals along, the seam has no surface of its own — fold `acme-tools`
   back as a package and re-run the gates on a smaller proposal.

Lesson: gate 5 is the cheapest gate and the one teams skip most, because the
workspace masks it. A module that only builds inside `go.work` is not a
module — it is a directory with a go.mod.

### Variant: facade instead of contract module

When exactly one repo will ever consume the thin surface — a monolith
serving its own extraction, or a federation member pinning the library —
extracting `config/` as a shared contract module is not the only move.
Keep everything in ONE module behind `internal/` and re-export the needed
symbols from a facade package at the root, pinned by a freeze test. The
compiler wall plays the role the go.mod boundary played in outcome 1
above; renames inside stay free; no new module, version pin, or release
staircase to maintain.

Pick the contract module when a SECOND consumer wants a different slice of
the same code. Pick the facade while there is one consumer and the surface
is small. Full pattern with the freeze-test mechanics:
[./real-world-patterns.md](./real-world-patterns.md) §Curated Facade over internal/.
