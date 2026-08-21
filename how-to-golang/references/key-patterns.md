# Key Patterns (Quick Reference)

## DI Constructor (samber/do/v2)

```go
func NewUserService(i do.Injector) (*UserService, error) {
    repo, err := do.Invoke[UserRepository](i)
    if err != nil {
        return nil, fmt.Errorf("failed to resolve UserRepository: %w", err)
    }
    logger, err := do.Invoke[*slog.Logger](i)
    if err != nil {
        return nil, fmt.Errorf("failed to resolve Logger: %w", err)
    }
    return &UserService{repo: repo, logger: logger}, nil
}
```

Lifecycle: implement `do.Shutdowner` and/or `do.HealthcheckerWithContext`.

For the full DI audit checklist (DO-1 → DO-6 anti-patterns, canonical provider patterns, lifecycle wiring), see the **samber-do-best-practices** skill.

## Error Handling

```go
// Sentinel errors + wrapping (cockroachdb/errors — verified compiling 2026-08-21)
var ErrNotFound = errors.New("not found")
return nil, errors.Wrap(err, "failed to get user")
if errors.Is(err, ErrNotFound) { ... }
```

> **uniflow status (verified 2026-08-21):** the module path is
> `github.com/LarsArtmann/uniflow` (capital L and A — the lowercase path is
> unfetchable), its public API is a config-driven message-flow engine
> (`core.NewUniflow(&core.Config{...})`), and at @latest (v0.0.0-2026-05-16)
> it does not compile at all — a broken `charmbracelet/x/cellbuf` transitive
> pin. There is no `NewPipeline().Then(...)` chain API. Do not copy pipeline
> snippets from memory; check the library source first.

> **Go 1.26+ modernization:** `errors.As` is being superseded by the generic `errors.AsType[E]`. `errors.Is` is NOT legacy — it remains the correct API for sentinel matching. See the [`go-error-modernization` skill](../../go-error-modernization/SKILL.md) for the migration decision tree and the cargo-cult trap to avoid when an agent drives a linter to zero.

## Config (koanf)

Priority: defaults → config file → env vars (`APP_` prefix, `_` → `.`).
Import paths (verified compiling 2026-08-21): core at `github.com/knadh/koanf/v2`;
providers/parsers are separate modules at the v1 module path — `github.com/knadh/koanf/providers/{confmap,file}` and `github.com/knadh/koanf/parsers/yaml` — except env, whose `Opt` API lives only in `github.com/knadh/koanf/providers/env/v2`:

```go
k := koanf.New(".")
k.Load(confmap.Provider(defaults, "."), nil)
k.Load(file.Provider(path), yaml.Parser())
k.Load(env.Provider(".", env.Opt{Prefix: "APP_"}), nil) // import .../providers/env/v2
k.Unmarshal("", &cfg)
```

## Logging

```go
import "charm.land/log/v2"

handler := log.NewWithOptions(os.Stdout, log.Options{
    ReportTimestamp: true, ReportCaller: true, Level: log.DebugLevel,
})
logger := slog.New(handler)
// Per-service: logger.With("service", "user")
// Per-request: log.WithContext(ctx, requestLogger)
```

## CLI (fang)

```go
import "charm.land/fang/v2"

fang.Execute(ctx, rootCmd,
    fang.WithVersion("1.0.0"),
    fang.WithCommit(buildCommit),
)
```

## Testing (Ginkgo/Gomega)

```go
var _ = Describe("UserService", func() {
    It("creates a user", func() {
        user, err := service.Create(ctx, cmd)
        Expect(err).NotTo(HaveOccurred())
        Expect(user.ID).NotTo(BeZero())
    })
})
```

## HTTP API (Gin + Huma)

```go
import (
    "github.com/gin-gonic/gin"
    "github.com/danielgtaylor/huma/v2"
    "github.com/danielgtaylor/huma/v2/adapters/humagin"
)

router := gin.Default()
api := humagin.New(router, huma.DefaultConfig("My API", "1.0.0"))

huma.Register(api, huma.Operation{
    Method: http.MethodPost,
    Path:   "/users",
}, CreateUserHandler)
```

## Validation (govalid)

```go
type CreateUserRequest struct {
    //govalid:required
    //govalid:email
    Email string `json:"email"`

    //govalid:required
    //govalid:min_len=2
    //govalid:max_len=100
    Name string `json:"name"`
}
```

Run `go generate ./...` to generate validation code. Zero allocations at runtime.
