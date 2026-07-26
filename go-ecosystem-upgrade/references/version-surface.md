# The Version Surface — Where a Version Lives

A version number in a Go ecosystem lives in far more places than just `go.mod`. When
"aligning" or "pinning" a version, you must touch every location or accept drift between
them. This inventory was built from the enumeration gaps discovered in the go-mod version
pin report (504 files), the ecosystem-wide bump (77 repos), and the templ-components
upgrade (8 consumers).

## The full inventory

### Tier 1 — Go module system (always check)

| Location | What to grep | Notes |
|----------|-------------|-------|
| `go.mod` (every module) | `^go 1.` or `module-path v` | The canonical declaration. Use `go mod edit`, never sed. |
| `go.work` / `go.work.sum` | `^go ` and `toolchain` | Workspace files carry their own `go` directive. If any exist, they must be aligned with the modules they cover. Often forgotten. |
| `go.sum` | version hash lines | Don't hand-edit. Run `go mod tidy` or `go mod verify`. |
| `vendor/modules.txt` | `# module-path version` | If vendor/ exists, this file must match. Run `go mod vendor`. |
| `vendor/` source trees | actual vendored source | Committed vendor dirs drift silently. A `go mod vendor` syncs the ENTIRE tree, not just one dep. |

### Tier 2 — Toolchain and environment (usually check)

| Location | What to grep | Notes |
|----------|-------------|-------|
| `.github/workflows/*.yml` | `go-version:` | CI Go version pin. Must match the `go.mod` directive or CI uses a different toolchain than local. |
| `flake.nix` | `go` / `buildGoModule` / `buildGo123Module` | Nix Go version pin. `buildGoModule` embeds a Go version in the function name. |
| `.tool-versions` / `mise.toml` / `asdf` | `go 1.x` | Version manager pin. |
| `Dockerfile` / `Dockerfile.*` | `FROM golang:` | Container Go version. |
| `flake.lock` | go version entries | Nix lockfile may pin a Go version; `nix flake update` refreshes. |

### Tier 3 — Documentation and config (sometimes check)

| Location | What to grep | Notes |
|----------|-------------|-------|
| `AGENTS.md` | version numbers in "Dependencies" sections | Session context — future agents read this. Update when bumping. |
| `README.md` / `CONTRIBUTING.md` | `go 1.x` or version numbers | User-facing docs. Stale versions mislead new contributors. |
| `CHANGELOG.md` | version entries | Must accurately reflect what shipped. A lying CHANGELOG is worse than none. |
| Renovate / Dependabot config | `go` in `.github/renovate.json` etc. | Auto-bumper version constraints. |
| Shell scripts (`*.sh`) | `go1.x.y` hardcoded | Some scripts hardcode a Go binary path. |
| Makefiles / justfiles | `GO_VERSION` or similar | Deprecated per AGENTS.md (migrate to flake.nix), but may still exist. |

### Tier 4 — Library-specific (check when relevant)

| Location | What to grep | Notes |
|----------|-------------|-------|
| Generated code (`.templ` → `_templ.go`) | embedded version references | Run `templ generate` after a bump — generated code can embed version info. |
| Golden snapshots / test fixtures | version strings in expected output | A library bump may change rendered HTML. Regenerate with `UPDATE_GOLDEN=1`, then diff-review every changed line. |
| `GOEXPERIMENT` env vars | `GOEXPERIMENT=jsonv2` | Some repos require experimental Go features. Version pinning must account for this. |
| `GOFLAGS` / `CGO_ENABLED` | env var files | Build flags that interact with the Go version. |

## The drift problem

The actual bug class is **drift between these locations**. A `go.mod` that says `go 1.26`
while CI uses `go-version: 1.26.4` and the Nix flake builds with `buildGo124Module` is a
three-way split brain. Each location is individually correct; together they're inconsistent.

When aligning versions, treat all locations as **one version surface**. A change to any one
location without updating the others creates drift. The verification gate (see SKILL.md) is
your defense — grep every location, not just `go.mod`.

## Search commands for completeness

```bash
# Find ALL go.mod files (including gitignored — use --no-ignore-vcs!)
rg --no-ignore-vcs --hidden -l -g 'go.mod' '^go ' .

# Find go.work files
find . -name 'go.work' -o -name 'go.work.sum' 2>/dev/null

# Find CI Go version pins
rg 'go-version:' .github/workflows/ 2>/dev/null

# Find Nix Go version references
rg 'buildGo[0-9]+Module|go = ' *.nix **/*.nix 2>/dev/null

# Find Dockerfile Go versions
rg 'FROM golang:' Dockerfile* 2>/dev/null

# Find stale vendor directories
find . -name 'vendor' -type d 2>/dev/null

# Find replace directives
rg '^replace|=> \.\.' go.mod go.work 2>/dev/null

# Find pseudo-versions (poisoned go.mod)
rg '00010101000000' go.mod 2>/dev/null
```

When the task is "ALL files on version X," use `--no-ignore-vcs --hidden` from the start.
Gitignore is a dev convenience, not a completeness contract.
