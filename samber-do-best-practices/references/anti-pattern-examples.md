# samber/do Anti-Patterns: Before/After

These are the DO-1 → DO-6 rules from `branching-flow/pkg/doanalyzerv2`, plus two structural smells. Concrete examples are taken from the workspace report at `/home/lars/projects/samber-do-auditlog/docs/research/samber-do-best-practices-and-anti-patterns.md`.

## DO-1: `Must*` in runtime paths

`do.MustInvoke*`, `do.MustAs`, `do.MustAsNamed` panic on missing services. Use them only in `main()`, `init()`, or provider closures that run at container build time. Never in HTTP handlers, CLI actions, or other runtime paths.

**Bad:**

```go
func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    db := do.MustInvoke[*Database](h.injector) // runtime panic risk
    // ...
}
```

**Good:**

```go
func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    db, err := do.Invoke[*Database](h.injector)
    if err != nil {
        http.Error(w, "database unavailable", 500)
        return
    }
    // ...
}
```

Or inject the dependency into the handler struct at startup.

## DO-2: Missing container shutdown

Every `do.New()` must have a matching `.Shutdown()` call. Unclosed containers leak DB connections, goroutines, file handles, and HTTP clients.

**Bad:**

```go
func main() {
    injector := do.New()
    // ... run ...
    // never calls Shutdown()
}
```

**Good:**

```go
func main() {
    injector := do.New()
    defer injector.Shutdown()

    app, _ := do.Invoke[*App](injector)
    app.Run()
}
```

If ownership is transferred to a caller, return the injector or a cleanup function so the caller can shut it down.

## DO-3: Override outside container setup

`samber/do` explicitly warns: _"We strongly discourage using this helper in production. Please use service aliasing instead."_ `do.Override*` is acceptable only in `_test.go` files, setup/wire/configure functions, or options-style configuration APIs.

**Bad:**

```go
func (h *Handler) HandleRequest(ctx context.Context) {
    do.OverrideValue(h.injector, newRateLimiter()) // runtime mutation
}
```

**Good:**

```go
func WithRateLimiter(lim RateLimiter) Option {
    return func(i do.Injector) {
        do.OverrideValue(i, lim)
    }
}
```

## DO-4: Global injector

Global mutable state prevents parallel tests, makes lifecycle management impossible, and hides dependencies. Do not build application logic on `do.DefaultRootScope`.

**Bad:**

```go
var Injector = do.New()

func GetUserRepo() *UserRepository {
    return do.MustInvoke[*UserRepository](Injector)
}
```

**Good:**

```go
func NewApp() (*App, func()) {
    injector := do.New()
    // register ...
    return &App{injector: injector}, func() { injector.Shutdown() }
}
```

## DO-5: Invoke inside loops

Repeatedly invoking inside a loop is usually accidental and wasteful. Resolve the service once and reuse it.

**Bad:**

```go
for _, id := range ids {
    svc, _ := do.Invoke[*Service](injector)
    svc.Process(id)
}
```

**Good:**

```go
svc, _ := do.Invoke[*Service](injector)
for _, id := range ids {
    svc.Process(id)
}
```

## DO-6: Shutdown accesses other services

Shutdown ordering is **non-deterministic** (samber/do issue #219). A `Shutdown()` method that invokes another service may run after that service is already shut down.

**Bad:**

```go
func (s *Server) Shutdown() error {
    db := do.MustInvoke[*Database](s.injector)
    return db.Close() // db may already be shut down
}
```

**Good:**

```go
func (s *Server) Shutdown() error {
    // Self-contained: close only resources this service owns.
    return s.listener.Close()
}
```

If cleanup must be coordinated, use a parent lifecycle manager rather than cross-service calls inside `Shutdown()`.

## Service-locator smell

Do not pass the injector deep into business logic and resolve dependencies ad-hoc. Consumers should receive their dependencies at construction time.

**Bad:**

```go
func (h *BaseHandler) Handle(w http.ResponseWriter, r *http.Request) {
    repo, _ := do.Invoke[*UserRepo](h.injector)
    repo.Save(...)
}
```

**Good:**

```go
type Handler struct {
    repo *UserRepo // injected at construction
}

func NewHandler(repo *UserRepo) *Handler { return &Handler{repo: repo} }
```

## Storing the injector inside a service

A service should receive its dependencies at construction time, not hold a reference to the container.

**Bad:**

```go
type MyService struct {
    injector do.Injector
}

func NewMyService(i do.Injector) (*MyService, error) {
    return &MyService{injector: i}, nil
}
```

**Good:**

```go
type MyService struct {
    dep *MyDependency
}

func NewMyService(i do.Injector) (*MyService, error) {
    dep, err := do.Invoke[*MyDependency](i)
    if err != nil {
        return nil, err
    }
    return &MyService{dep: dep}, nil
}
```

This is the pattern the official `samber/do` docs explicitly recommend.
