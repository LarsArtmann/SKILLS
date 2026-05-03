# Engineering Philosophy

Core principles distilled from real-world frustration and aspirational architecture.
These apply across languages and projects — they're the "why" behind every rule.

## Make the Wrong Thing Hard

If it's easy to shoot yourself in the foot, the API is wrong.

- Banned libraries exist because they make bad patterns easy (gorm → N+1, viper → global state)
- Branded types exist because `string` can be anything — empty, whitespace, 5 bytes or 100GB
- `id.ID[Brand, V]` makes `ProcessUser(orderID)` a compile error, not a runtime bug
- Unsigned types for non-negative values: if a value can never be < 0, the type should say so

## Errors as Values, Not Excuses

Errors should be isolated, recovered, and communicated — never swallowed or panicked.

- No panics in library code — ever
- Every error gets context: `errors.Wrap(err, "failed to get user")`
- User-facing errors follow What/Reassure/Why/Fix/Escape
- Multiple errors when it makes sense (validation returns all problems, not just the first)
- Dead-letter queues for failed async operations — never silently drop

## Never Lose Data

Append-only event logs, not destructive CRUD.

- Event sourcing: state = fold(events), not mutable rows
- Bitemporal tracking: validFrom/Until + recorded timestamp
- Audit trails: who accessed what, when — no exceptions
- Idempotency: safe retries on every write operation
- What-if time-travel: not just "state 5 days ago" but "what should have happened but didn't"

## Performance Is a Feature, Not an Afterthought

"Don't just add Redis" — think about data locality first.

- Consider in-memory cache (otter/v2) before adding infrastructure
- Add database indexes before adding caching layers
- Use proper data structures (graphs, trees, bloom filters) before optimizing loops
- Streaming over loading: channels + backpressure > in-memory loading
- Data locality: L1/L2/L3 cache, SIMD, moving data costs more energy than computing on it
- Batch fetching: network isn't cheap; parallel > concurrent > synchronous

## Zero Unexpected Behavior

The system should behave exactly as it appears.

- No fake states: if something failed, show failure — don't pretend success
- No silent fallbacks: if a dependency fails, say so
- Config hot-reload: no restarts for config changes
- Deployment independence: same code runs as single binary in RAM or k8s cluster

## Build for Observability, Not Debugging

If you need to debug in production, you've already lost.

- OpenTelemetry from day one: traces, metrics, logs
- Architecture linting: enforce layer boundaries automatically
- Visualizations: if nobody knows how data flows, the architecture is broken
- Continuous benchmarking: performance budgets in CI
- Deterministic simulation testing: if FoundationDB can do it, so can you
- Health checks with recovery algorithms, not just "is it up?"

## Compiler > Tests > Documentation

Prevention in order of effectiveness:

1. **Compiler enforcement**: make invalid states unrepresentable (branded types, discriminated unions)
2. **Generated code**: sqlc, templ, govalid — eliminate hand-written boilerplate
3. **Architecture linting**: go-arch-lint, custom linters — enforce boundaries
4. **BDD tests**: Ginkgo/Gomega — test behavior, not implementation
5. **Integration tests**: real databases, real queues — not mocks
6. **Property-based tests**: verify invariants across wide input ranges
7. **E2E tests**: critical user journeys before every release
8. **Load tests**: performance budgets in CI
9. **Deterministic simulation**: full system simulation with controlled concurrency

## Smart Defaults, Explicit Config

- Zero config for simple: `go run .` should work
- Environment variables for deployment: `APP_` prefix, `_` → `.`
- Koanf priority: defaults → config file → env vars
- Hot reload: change config without restart

## The Multi-Frontend Principle

Backend owns the logic; frontend is presentation.

- CLI, TUI, and WebApp should all consume the same backend
- Backend defines queries; frontend requests them
- CSS over JavaScript; container queries over viewport sizes
- Server-side rendering (templ) when possible

## Plugin Architecture

Monoliths become unmaintainable; microservices become distributed nightmares.

- Micro-kernel + hot-reloadable plugins: best of both worlds
- Plugins follow predefined package structure with TypeSpec definitions
- Fallback on failure: if a plugin crashes, the kernel survives
- Event-driven: plugins communicate through events, not direct calls
