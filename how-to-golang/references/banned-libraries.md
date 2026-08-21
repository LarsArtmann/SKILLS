# Banned Libraries

Libraries banned from all Go projects with reasons and replacements.

## Critical Severity (immediate removal)

| Banned                  | Reason                                     | Use Instead                       |
| ----------------------- | ------------------------------------------ | --------------------------------- |
| testify                 | Encourages assert-based testing over BDD   | `onsi/ginkgo/v2` + `onsi/gomega`  |
| gopkg.in/yaml.v2        | CVE-2020-14343, poor performance           | `go-faster/yaml`                  |
| gopkg.in/yaml.v3        | Aging, known CVEs, slower                  | `go-faster/yaml`                  |
| dgrijalva/jwt-go        | CVE-2020-26160                             | `golang-jwt/jwt/v5`               |
| go-ozzo/ozzo-validation | Abandoned since Oct 2020                   | `sivchari/govalid`                |
| mitchellh/mapstructure  | Archived July 2024                         | `encoding/json`                   |
| mitchellh/go-homedir    | Archived July 2024                         | `os.UserHomeDir()`                |
| libgit2/git2go          | CVEs, CGO complexity, deprecated by FluxCD | `go-git/go-git/v5`                |
| crypto/md5              | Broken hash, trivial collisions            | `crypto/sha256` or `zeebo/blake3` |
| crypto/sha1             | Cryptographically broken                   | `crypto/sha256` or `zeebo/blake3` |
| samber/do v1            | Deprecated, use v2                         | `samber/do/v2`                    |

## Moderate Severity (replace when touching code)

| Banned                            | Reason                                      | Use Instead                                  |
| --------------------------------- | ------------------------------------------- | -------------------------------------------- |
| gorm                              | Magic behavior, N+1 queries                 | `sqlc-dev/sqlc`                              |
| gorilla/mux                       | Deprecated                                  | `gin-gonic/gin`                              |
| echo, chi, fiber, beego           | Slower / deprecated / monolithic            | `gin-gonic/gin`                              |
| viper                             | Global state, complex, 4x larger binaries   | `knadh/koanf`                                |
| urfave/cli                        | Less polished TUI                           | `charm.land/fang/v2`                         |
| go-cache, ristretto, bigcache     | Stale APIs, lock contention, poor hit rates | `maypok86/otter/v2`                          |
| pkg/errors                        | Unmaintained                                | `cockroachdb/errors`                         |
| logrus, zerolog                   | Fragmented, slog is standard                | `log/slog` + `charm.land/log/v2`             |
| swaggo                            | Annotations drift from code                 | `danielgtaylor/huma`                         |
| go-playground/validator           | 5-44x slower than govalid                   | `sivchari/govalid`                           |
| satori/uuid                       | 4.6x slower                                 | `google/uuid`                                |
| matoous/go-nanoid                 | 13x slower, no FIPS                         | `sixafter/nanoid`                            |
| avast/retry-go                    | High overhead, race conditions              | `failsafe-go/failsafe-go`                    |
| prometheus/client, jaeger, zipkin | Use OpenTelemetry                           | `go.opentelemetry.io/otel`                   |
| json-iterator, sonic, easyjson    | Superseded by stdlib v2                     | `encoding/json/v2`                           |
| encoding/json v1                  | Slower, less flexible (Go 1.25+)            | `encoding/json/v2`                           |
| fsnotify                          | Use go-filewatcher instead                  | `larsartmann/go-filewatcher`                 |
| blackfriday                       | Unmaintained since 2020                     | `gomarkdown/markdown`                        |
| math/rand                         | Insecure for crypto                         | `crypto/rand`                                |
| tablewriter, go-pretty            | API instability vs lipgloss                 | `charm.land/lipgloss/v2`                     |

## Charm v1 Libraries (upgrade to v2 vanity imports)

| v1 Import Path                       | v2 Import Path            | Key v2 Improvements                                          |
| ------------------------------------ | ------------------------- | ------------------------------------------------------------ |
| `github.com/charmbracelet/lipgloss`  | `charm.land/lipgloss/v2`  | Deterministic styles, LightDark() replacing AdaptiveColor    |
| `github.com/charmbracelet/fang`      | `charm.land/fang/v2`      | Lip Gloss v2, built-in color downsampling, light/dark themes |
| `github.com/charmbracelet/huh`       | `charm.land/huh/v2`       | Bubble Tea v2 + Lip Gloss v2, simplified accessible mode     |
| `github.com/charmbracelet/bubbletea` | `charm.land/bubbletea/v2` | Cursed Renderer, declarative View struct                     |
| `github.com/charmbracelet/bubbles`   | `charm.land/bubbles/v2`   | Bubble Tea v2 + Lip Gloss v2, real cursor support            |
| `github.com/charmbracelet/log`       | `charm.land/log/v2`       | Vanity import, improved slog handler                         |

## Anti-Patterns (Quick Check)

| Anti-Pattern                           | Fix                                                  |
| -------------------------------------- | ---------------------------------------------------- |
| Swallowing errors (`log.Println(err)`) | Return with context: `errors.Wrap(err, "...")`       |
| Panic in library code                  | Return error                                         |
| Hardcoded DB in package var            | Inject via interface                                 |
| Config requiring restart               | koanf hot reload                                     |
| Manual validation ifs                  | Huma struct tags or `sivchari/govalid`               |
| N layers of DTO mapping                | Entity → APIResponse max                             |
| `string` for domain IDs                | Branded `id.ID[Brand, V]`                            |
| `encoding/json` v1                     | `encoding/json/v2`                                   |
| Context stored in struct               | Context as first param, propagate through all layers |
| Custom ID marshal/unmarshal methods    | Branded IDs handle this automatically                |
| Files over 300 lines                   | Split by domain/concern                              |
| Functions over 30 lines                | Extract to focused functions                         |
| `any` types                            | Use generics or concrete interfaces                  |
| Rolling your own auth                  | Use `golang-jwt/v5` + `casbin`                       |
| String concatenation for SQL           | Use sqlc parameterized queries                       |
| `math/rand` for security               | Use `crypto/rand`                                    |

## Rule 007: No Binary Files in Git

Never commit binaries (images, compiled assets, .db files) to Git. Use Git LFS or external storage.
