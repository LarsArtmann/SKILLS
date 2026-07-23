# samber/do v2 Quick Reference

Condensed from the comprehensive report at `/home/lars/projects/samber-do-auditlog/docs/research/samber-do-best-practices-and-anti-patterns.md`.

## Service lifetimes

| Registration | Lifetime | Use for |
| --- | --- | --- |
| `do.Provide` | Lazy singleton | Most services |
| `do.ProvideValue` | Eager singleton | Config, logger, DB connection |
| `do.ProvideTransient` | New instance per `Invoke` | Factories, value objects |
| `do.ProvideNamed` / `do.ProvideNamedValue` | Named singleton | Multiple impls of one type |

## Invocation

```go
v, err := do.Invoke[*Service](injector)          // safe, preferred
v := do.MustInvoke[*Service](injector)           // panic on missing; only in main/init/provider closures
v, err := do.InvokeNamed[*Service](injector, "name")
v := do.MustInvokeNamed[*Service](injector, "name")
```

## Lifecycle interfaces

```go
// Health checks
type Healthchecker           interface { HealthCheck() error }
type HealthcheckerWithContext interface { HealthCheck(context.Context) error }

// Shutdown
type Shutdowner                 interface { Shutdown() }
type ShutdownerWithError         interface { Shutdown() error }
type ShutdownerWithContext       interface { Shutdown(context.Context) }
type ShutdownerWithContextAndError interface { Shutdown(context.Context) error }
```

`injector.Shutdown()` runs shutdowns in **reverse invocation order** and returns a `*do.ShutdownReport`.

## Scopes

```go
root := do.New()
driver := root.Scope("driver")
passenger := root.Scope("passenger")
```

Child scopes can resolve parent services; parent scopes cannot see child services.

## Aliasing

```go
// Implicit — preferred
do.Provide(injector, NewMetricsCounter)
metric := do.MustInvokeAs[Metric](injector)

// Explicit — use only when implicit is ambiguous
do.As[*MetricsCounter, Metric](injector)
metric := do.MustInvoke[Metric](injector)
```

## Packages

```go
var Package = do.Package(
    do.Lazy(NewStore),
    do.LazyNamed("primary", NewPrimaryRepo),
    do.Eager(config),
)

injector := do.New(Package)
```

## Decision checklist when adding a service

| Question | If yes | Pattern |
| --- | --- | --- |
| Long-lived singleton? | yes | `do.Provide` |
| Must exist before first invoke? | yes | `do.ProvideValue` |
| Per-request / per-tenant resource? | yes | `do.ProvideTransient` in a child scope |
| Multiple implementations? | yes | `do.ProvideNamed` + accessor helper |
| Consumers depend on interface? | yes | Provide struct, invoke via `do.InvokeAs` |
| Holds resources? | yes | Implement `do.Shutdowner*` |
| Needs connectivity check? | yes | Implement `do.Healthchecker*` |
| Invoked from request handler? | yes | Inject dependency into handler struct |
| Shutdown order critical? | yes | Use a single lifecycle manager |
| Code in `_test.go`? | yes | `do.Override*` is acceptable |

## Migration from v1 to v2

- `*do.Injector` → `do.Injector` (interface)
- `do.ProvideEager` → `do.ProvideValue`
- `Shutdown()` now returns `*do.ShutdownReport`
- Hooks are slices: `[]func(...)`
- `Service[T]` no longer exported; use `Provider[T]`

All active work should target `github.com/samber/do/v2` v2.1.0.
