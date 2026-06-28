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

## After — Multi-module with go.work

```
github.com/org/eventstore/
├── go.work                           # workspace: domain + postgres + memory + projection + testhelpers
├── go.work.sum
├── cmd/
│   └── eventstore/
│       └── main.go                   # wires domain + postgres
│
├── domain/                           # MODULE 1 — domain types + interfaces
│   ├── go.mod                        # zero internal deps
│   └── event/
│       ├── event.go                  # Event, StreamID, Metadata
│       ├── store.go                  # Store interface
│       ├── bus.go                    # Bus interface
│       ├── errors.go                 # ErrNotFound, ErrStreamExists
│       └── codec.go                  # Codec interface + JSON impl
│
├── storage/                          # MODULE 2 — postgres implementation
│   ├── go.mod                        # depends on core only
│   └── postgres/
│       ├── store.go                  # implements core.Store
│       └── migrations.go
│
├── projection/                       # MODULE 3 — projection engine
│   ├── go.mod                        # depends on core only
│   └── projection/
│       ├── handler.go
│       └── registry.go
│
├── memory/                           # MODULE 4 — in-memory adapters (testing)
│   ├── go.mod                        # depends on core only
│   └── memory/
│       ├── store.go                  # implements core.Store
│       └── bus.go                    # implements core.Bus
│
└── testhelpers/                      # MODULE 5 — shared test utilities
      ├── go.mod                      # depends on core only
      └── testhelpers/
          ├── fixtures.go
          └── builders.go
```

## Key decisions in this example

| Decision                                | Rationale                                                                                        |
| --------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `domain/` has zero internal deps        | Domain types must not depend on infrastructure (Unix: mechanism, not policy)                     |
| `errors.go` in `domain/`                | `ErrNotFound` must be importable by storage consumers without importing storage                  |
| `memory/` is separate from `storage/`   | Test adapters should not force production deps on consumers                                      |
| `testhelpers/` depends only on core     | Prevents transitive dep from core → storage through test helpers                                 |
| `cmd/` stays in root                    | Leaf node — nothing imports it, shares deps with root                                            |
| `codec.go` in core, not separate module | JSON codec is small and tightly coupled to domain types — splitting would be over-modularization |
