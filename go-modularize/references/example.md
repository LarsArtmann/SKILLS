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
