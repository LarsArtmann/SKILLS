# Architecture & Code Style

## Project Structure

```
cmd/                    # Entrypoints only
internal/
  domain/               # Core logic, no external deps. Interfaces only for repos
  application/          # Use cases, services, commands, queries
  infrastructure/       # External: persistence, messaging, HTTP
  ports/                # Interface definitions
  scanner/              # Project-specific scanners
pkg/                    # Public packages (shared across services)
```

## Architecture Patterns

| Pattern            | Where                                                  |
| ------------------ | ------------------------------------------------------ |
| Clean Architecture | domain → application → infrastructure → interfaces     |
| DDD Aggregates     | Consistency boundaries around entities                 |
| Event Sourcing     | State = append-only events, read models via projection |
| Streaming          | Channels + backpressure over in-memory loading         |
| Plugin System      | Micro-kernel + `Plugin` interface + hot-reload         |

## Non-Negotiables

| Rule                                   | Threshold                           |
| -------------------------------------- | ----------------------------------- |
| Max file length                        | 300 lines                           |
| Max function length                    | 30 lines                            |
| No `any` types                         | Use generics or concrete interfaces |
| No magic strings/numbers               | Extract to named constants          |
| No nested conditionals                 | >3 levels → early returns           |
| No duplicated code                     | >3 instances → shared utility       |
| No primitive types for domain concepts | Use branded types                   |

## Code Style

```
Packages:  lowercase, single word
Files:     snake_case
Errors:    ErrPrefix (ErrNotFound, ErrUnauthorized)
Constants: UPPER_CASE or MixedCase for unexported
Acronyms:  HTTPServer not HttpServer, URLParser not UrlParser
Imports:   stdlib → blank line → external → blank line → internal
```

## Common Commands

```bash
go build -o bin/server ./cmd/server              # Dev build
go build -ldflags="-s -w" -trimpath -o bin/...   # Production build
go test ./...                                     # All tests
go test -coverprofile=coverage.out ./...          # With coverage
go test -bench=. -benchmem ./...                  # Benchmarks
sqlc generate                                     # Generate SQL types
templ generate                                    # Generate HTML types
go generate ./...                                 # Generate all (sqlc + templ + govalid)
```

## Rule 008: Clean Project Root

Root should contain only: `go.mod`, `go.sum`, `flake.nix`, `README.md`, `LICENSE`, `.gitignore`, and top-level directories (`cmd/`, `internal/`, `pkg/`, `docs/`).
Everything else belongs in a subdirectory.

## Rule 001-002: Latest Versions

Always use the latest stable Go version and dependencies.
Security patches, performance, and language features (like `encoding/json/v2` in Go 1.26+) require it.
Use Dependabot or Renovate for automated dependency updates.
