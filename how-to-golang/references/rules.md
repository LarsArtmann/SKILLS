# Go Development Rules

Distilled from the 50 formal rules at `/home/lars/projects/rules/`.
Rules already covered in other reference files are linked, not duplicated.

## Already Covered

| Rule | Topic                               | Where                                                                                               |
| ---- | ----------------------------------- | --------------------------------------------------------------------------------------------------- |
| 003  | Strong types only                   | [./architecture.md](./architecture.md) — No `any`, no primitives for domains                        |
| 005  | Functions under 30 lines            | [./architecture.md](./architecture.md) — Max 30 lines                                               |
| 009  | No magic numbers                    | [./architecture.md](./architecture.md) — Extract to named constants                                 |
| 010  | Compiler-enforced impossible states | [./philosophy.md](./philosophy.md) — Type safety first                                              |
| 011  | No split-brain types                | [./domain-types.md](./domain-types.md) — Canonical branded types                                    |
| 012  | Consistent library usage            | [./required-libraries.md](./required-libraries.md) + [./banned-libraries.md](./banned-libraries.md) |
| 021  | Consistent package structure        | [./architecture.md](./architecture.md) — cmd/internal/pkg                                           |
| 029  | ID strategy                         | SKILL.md — ID decision tree                                                                         |
| 025  | No re-exports                       | [./architecture.md](./architecture.md) — Explicit imports                                           |

## Rule 001: Latest Language Version

Always use the latest stable Go version. Security patches, performance, and language features (like `encoding/json/v2`, experimental in Go 1.25+ behind `GOEXPERIMENT=jsonv2`) require it.

Check in CI:

```yaml
- name: Check Go version
  run: |
    latest_go=$(curl -s https://golang.org/VERSION?m=text)
    current_go=$(grep "^go " go.mod | cut -d' ' -f2)
    if [[ "$current_go" != "$latest_go" ]]; then
      echo "Using Go $current_go, latest is $latest_go"
      exit 1
    fi
```

## Rule 002: Latest Dependencies

Run `go mod tidy` and update dependencies regularly. Use Dependabot or Renovate for automation.

```bash
go list -m -u all 2>/dev/null | grep '\[' || echo "All dependencies up to date"
```

## Rule 007: No Binary Files in Git

Never commit binaries (images, compiled assets, .db files) to Git. Use Git LFS or external storage.

Check in CI:

```bash
binary_extensions="png jpg jpeg gif ico pdf zip tar gz db sqlite exe dll so dylib"
for ext in $binary_extensions; do
  if git ls-files --ignored --exclude-standard | grep -q "\.$ext$"; then
    echo "Binary file detected: use Git LFS"
    exit 1
  fi
done
```

## Rule 008: Clean Project Root

Project root should contain only: `go.mod`, `go.sum`, `flake.nix`, `README.md`, `LICENSE`, `.gitignore`, and top-level directories (`cmd/`, `internal/`, `pkg/`, `docs/`).

Everything else belongs in a subdirectory.

## Rule 013: Performance First

Performance is a feature, not an afterthought. Build systems that are inherently fast.

### Go-Specific Performance Rules

| Rule                                                             | Why                                                 |
| ---------------------------------------------------------------- | --------------------------------------------------- |
| Use `otter/v2` for caching, never add Redis without benchmarking | In-memory is 100x faster and zero infrastructure    |
| Add DB indexes before adding caching layers                      | Index scans are O(log n); sequential scans are O(n) |
| Use streaming (channels) over in-memory loading                  | Constant memory vs O(n) memory                      |
| Use `encoding/json/v2`                                           | 10x faster than v1                                  |
| Use `go-faster/yaml`                                             | 2-3x faster than yaml.v3                            |
| Use `xxh3` for non-crypto hashing                                | SIMD-optimized, GB/s throughput                     |
| Use `blake3` for crypto hashing                                  | 4-10x faster than SHA-256                           |
| Use `failsafe-go` for retries                                    | 10x lower overhead than avast/retry-go              |
| Profile before optimizing                                        | `go test -cpuprofile`, `go tool pprof`              |

Performance tuning beyond library choice (GOMAXPROCS vs measured bandwidth knee, containers, GC knobs, cache-aware layout, sync, IO/network/DB) has its own guide: [./performance-tuning.md](./performance-tuning.md).

### Continuous Benchmarking

```go
func BenchmarkUserService_Create(b *testing.B) {
    b.ReportAllocs()
    for i := 0; i < b.N; i++ {
        _, err := service.Create(ctx, cmd)
        if err != nil { b.Fatal(err) }
    }
}
```

Run in CI: `go test -bench=. -benchmem ./...`

## Rule 014: Necessary Information First

Prioritize necessary info over comprehensive details. Give users what they need immediately with paths to deeper information.

- Error messages: actionable first, technical second
- API responses: requested data first, metadata after
- Logs: structured with level-based filtering

## Rule 023: Up-to-Date Documentation

Documentation drifts from code. Counter this:

- Generate API docs: Huma produces OpenAPI 3.1 from Go types
- Generate event docs: TypeSpec → AsyncAPI
- Architecture decisions: `docs/adr/` with ADR templates
- README must reflect current `go.mod` dependencies

## Rule 045: Database Design

- Normalize data, use appropriate indexes
- Use ULID (`CHAR(26)`) for primary keys, not UUID or auto-increment
- Enforce constraints at DB level (CHECK, NOT NULL, UNIQUE)
- Version all schema changes with migration tools
- Use sqlc for type-safe queries — no ORM magic

```sql
CREATE TABLE users (
    id          CHAR(26) PRIMARY KEY,  -- ULID
    email       VARCHAR(255) UNIQUE NOT NULL,
    name        VARCHAR(100) NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT users_status_check CHECK (status IN ('active', 'inactive', 'suspended'))
);

CREATE INDEX idx_users_status_created_at ON users(status, created_at DESC);
```

## Rule 006: Centralized Error Package

Every domain error defined once, imported from single source of truth.

```go
package errors

import "github.com/cockroachdb/errors"

var (
    ErrNotFound       = errors.New("not found")
    ErrUnauthorized   = errors.New("unauthorized")
    ErrValidation     = errors.New("validation failed")
    ErrAlreadyExists  = errors.New("already exists")
)
```

Use `cockroachdb/errors` for wrapping and sentinel matching. (`uniflow` was previously recommended for pipeline-style composition — it does not compile at @latest as of 2026-08-21 and has no pipeline-chain API; see key-patterns.md error-handling note.)

## Rule 015-019: Observability & Health

These rules overlap with [./philosophy.md](./philosophy.md) ("Build for Observability").

Go-specific implementation:

- `do.HealthcheckerWithContext` for service health checks
- `do.Shutdowner` for graceful shutdown
- OpenTelemetry middleware on all HTTP handlers
- Structured logging with `slog` + `charm.land/log/v2`
