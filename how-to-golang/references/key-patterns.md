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

## Error Handling

```go
// Railway pipeline
return uniflow.NewPipeline().
    Then(validate).Then(create).Then(emit).Run(ctx, input)

// Sentinel errors + wrapping
var ErrNotFound = errors.New("not found")
return nil, errors.Wrap(err, "failed to get user")
if errors.Is(err, ErrNotFound) { ... }
```

## Config (koanf)

Priority: defaults → config file → env vars (`APP_` prefix, `_` → `.`).

```go
k := koanf.New(".")
k.Load(confmap.Provider(defaults, "."), nil)
k.Load(file.Provider(path), yaml.Parser())
k.Load(env.Provider(".", env.Opt{Prefix: "APP_"}), nil)
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
