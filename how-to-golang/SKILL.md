---
name: how-to-golang
description: Use this skill when writing Go code, choosing Go libraries, setting up a Go project, reviewing Go dependencies, or when the user asks about Go best practices, Go library choices, banned Go libraries, Go architecture patterns, Go project structure, Go domain types, Go DI patterns, Go testing strategy, Go security, Go performance, or says "how to golang", "go policy", "go stack", "go libraries", "go architecture", "go code style", "go rules", "go testing", "go security", or any Go development question. Also use when reviewing go.mod for banned dependencies or choosing between Go libraries for any category. A decision guide for WHAT to use, not HOW.
metadata:
  tags: go, golang, libraries, architecture, policy, banned, decisions, testing, security, performance, rules
allowed-tools: bash view edit grep go
---

# How to Golang

Decision guide for Go development. Tells WHAT to use, not HOW.
For HOW, read the library docs.

## Principles

- **Errors as values** — no panics in library code
- **Type safety first** — make impossible states unrepresentable
- **Composition over inheritance** — always
- **Generated over handwritten** — sqlc, templ, govalid for boilerplate
- **Observability built-in** — OpenTelemetry from day one

## Process

When working on a Go project:

1. Check `go.mod` against the banned libraries list — load [./references/banned-libraries.md](references/banned-libraries.md) and verify no banned dependencies are present. This catches security CVEs and deprecated packages before they cause problems.
2. Verify the project uses the required stack — load [./references/required-libraries.md](references/required-libraries.md) and confirm the project aligns. If a required library is missing, suggest adoption.
3. For domain types (IDs, Email, Money, etc.), use `go-composable-business-types` — load [./references/domain-types.md](references/domain-types.md) for the branded ID pattern and type catalog. Never use primitive strings for domain identifiers.
4. For implementation patterns (DI, config, logging, CLI, testing, HTTP API), follow the canonical patterns — load [./references/key-patterns.md](references/key-patterns.md).
5. For project structure, code style, and architecture patterns — load [./references/architecture.md](references/architecture.md).
6. For testing strategy (TDD, integration, E2E, property-based, load, snapshot) — load [./references/testing-strategy.md](references/testing-strategy.md). Minimum 80% coverage; use Ginkgo/Gomega for BDD, real databases for integration, go-snaps for snapshots.
7. For security (auth, API security, encryption, OWASP, container hardening) — load [./references/security.md](references/security.md). Never roll your own auth; run `gosec` + `govulncheck` in CI.
8. For development rules (latest Go version, clean root, performance first, observability) — load [./references/rules.md](references/rules.md).
9. For performance tuning (GOMAXPROCS economics, measuring the concurrency knee, container CPU quotas, GC knobs, cache-aware data layout, sync contention, IO/network/DB tuning, NUMA) — load [./references/performance-tuning.md](references/performance-tuning.md).
10. For engineering philosophy (why behind the rules, from real-world experience) — load [./references/philosophy.md](references/philosophy.md).

## Decision Trees

### Choosing an ID type

- External system mandates UUID → `google/uuid`
- DB primary key → `oklog/ulid` (sortable, better index performance)
- URL-safe public identifier → `sixafter/nanoid`
- Event log / time-ordered → `segmentio/ksuid`
- Domain entity with compile-time safety → `go-composable-business-types/id.ID[Brand, V]`

### Choosing a cache

- In-memory, single process → `maypok86/otter/v2`
- Anything else is banned (ristretto, bigcache, go-cache, freecache, hashicorp/lru)

### Choosing a validation library

- Struct validation with code generation → `sivchari/govalid` (zero allocations)
- API request validation → Huma struct tags
- Everything else is banned (go-playground/validator, ozzo, zog, asaskevich)

### Choosing JSON handling

- Go 1.25+ → `encoding/json/v2`
- All third-party JSON libs (json-iterator, sonic, easyjson, go-json) are superseded by stdlib v2
- Exception: transitive dependencies from gin/huma are acceptable

### Choosing a testing approach

- Behavior specification → Ginkgo/Gomega (BDD)
- Pure function verification → table-driven tests
- API response regression → go-snaps (snapshot testing)
- Invariant verification → property-based testing (gopter)
- Real dependency verification → integration tests (testcontainers)
- Critical user journeys → E2E tests
- Performance verification → benchmarks in CI

### Choosing security tools

- Static analysis → `gosec`
- Vulnerability scanning → `govulncheck`
- Secret leak detection → `gitleaks`
- Container scanning → `trivy`

### Choosing a concurrency level

- Compute-bound → scale to GOMAXPROCS
- Bandwidth-bound (stream/hash/copy large buffers) → measure the knee with a `-cpu` benchmark sweep, cap workers below it (`errgroup.SetLimit`)
- Latency-bound service with p99 SLOs → cap below the knee; oversubscription inflates tail latency first
- Container with CPU quota → Go 1.25+ derives GOMAXPROCS from the cgroup quota automatically; older → set `GOMAXPROCS` env
- Allocation-heavy on multi-socket → check the NUMA section of [./references/performance-tuning.md](references/performance-tuning.md)

## Quick Bans Reference

These are the most common violations. For the complete list, load [./references/banned-libraries.md](references/banned-libraries.md).

| Banned                  | Use Instead                     |
| ----------------------- | ------------------------------- |
| testify                 | ginkgo/v2 + gomega              |
| gorm                    | sqlc                            |
| viper                   | koanf                           |
| gorilla/mux             | gin                             |
| pkg/errors              | cockroachdb/errors + uniflow    |
| logrus/zerolog          | slog + charm.land/log/v2        |
| go-playground/validator | govalid                         |
| yaml.v2/v3              | go-faster/yaml                  |
| charm v1 libs           | charm.land/\*/v2 vanity imports |
