# Required Libraries

Decision guide for WHAT to use. For HOW, read the library docs.

## Stack

| Category      | Library                      | Import                                                                                                                |
| ------------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| HTTP/API      | Gin + Huma (via humagin)     | `github.com/gin-gonic/gin` + `github.com/danielgtaylor/huma/v2` + `github.com/danielgtaylor/huma/v2/adapters/humagin` |
| DI            | samber/do/v2                 | `github.com/samber/do/v2`                                                                                             |
| Config        | Koanf                        | `github.com/knadh/koanf/v2`                                                                                           |
| SQL           | sqlc                         | `github.com/sqlc-dev/sqlc`                                                                                            |
| Logging       | slog + charm.land/log/v2     | `log/slog` + `charm.land/log/v2`                                                                                      |
| CLI           | charm.land/fang/v2           | `charm.land/fang/v2`                                                                                                  |
| TUI/Styling   | Charm v2                     | `charm.land/lipgloss/v2`, `charm.land/huh/v2`, `charm.land/bubbletea/v2`, `charm.land/bubbles/v2`                     |
| Caching       | Otter v2                     | `github.com/maypok86/otter/v2`                                                                                        |
| Testing       | Ginkgo/Gomega                | `github.com/onsi/ginkgo/v2` + `github.com/onsi/gomega`                                                                |
| Testing       | go-snaps                     | `github.com/gkampitakis/go-snaps/snaps` (package path; module root has no Go files) — snapshot testing                        |
| Templates     | Templ                        | `github.com/a-h/templ`                                                                                                |
| Functional    | lo + mo                      | `github.com/samber/lo` + `github.com/samber/mo`                                                                       |
| Errors        | cockroachdb/errors (+ uniflow when it stabilizes) | `github.com/cockroachdb/errors`. `github.com/LarsArtmann/uniflow` (capital L/A; lowercase path is unfetchable) was uncompilable at @latest as of 2026-08-21 — broken cellbuf transitive pin, and no pipeline-chain API exists |
| Resilience    | failsafe-go                  | `github.com/failsafe-go/failsafe-go`                                                                                  |
| YAML          | go-faster/yaml               | `github.com/go-faster/yaml`                                                                                           |
| JSON          | stdlib v2                    | `encoding/json/v2` (Go 1.25+, experimental: `GOEXPERIMENT=jsonv2`)                                                    |
| UUID          | google/uuid                  | `github.com/google/uuid` (only when external systems mandate UUID format)                                             |
| ULID          | oklog/ulid                   | `github.com/oklog/ulid` (prefer for DB primary keys)                                                                  |
| NanoID        | sixafter/nanoid              | `github.com/sixafter/nanoid`                                                                                          |
| KSUID         | segmentio/ksuid              | `github.com/segmentio/ksuid` (event log IDs)                                                                          |
| JWT           | golang-jwt/v5                | `github.com/golang-jwt/jwt/v5`                                                                                        |
| Git           | go-git/v5                    | `github.com/go-git/go-git/v5`                                                                                         |
| Validation    | govalid                      | `github.com/sivchari/govalid`                                                                                         |
| Hashing       | xxh3 + blake3                | `github.com/zeebo/xxh3` + `github.com/zeebo/blake3`                                                                   |
| Rate Limiting | stdlib                       | `golang.org/x/time/rate`                                                                                              |
| Crypto        | stdlib                       | `crypto/rand` + `crypto/sha256`                                                                                       |
| Observability | OpenTelemetry                | `go.opentelemetry.io/otel`                                                                                            |
| Domain Types  | go-composable-business-types | See [./domain-types.md](./domain-types.md)                                                                            |

## Additional Recommended Libraries

| Category               | Library               | Use For                                  |
| ---------------------- | --------------------- | ---------------------------------------- |
| Authorization          | casbin/casbin         | RBAC/ABAC policy enforcement             |
| Email                  | resend/resend-go/v3   | Transactional email                      |
| Architecture Lint      | fe3dback/go-arch-lint | Enforce layer boundaries                 |
| Snapshot Testing       | gkampitakis/go-snaps  | API response / config regression testing |
| SIMD Detection         | klauspost/cpuid/v2    | CPU feature queries                      |
| Scientific Computing   | gonum.org/v1/gonum    | Linear algebra, statistics, graph theory |
| Unit Conversion        | bcicen/go-units       | Weight, length, temperature conversions  |
| Distributed Rate Limit | mennanov/limiters     | Multi-backend distributed rate limiting  |
