# Tool Guidance by Language

> The code-quality-scan skill runs build, lint, and duplication analysis. This
> reference names the specific tools to use per language and build system. Do
> NOT reinvent the wheel — use established tools.

## Contents

1. [Build systems](#build-systems)
2. [Go linting](#go-linting)
3. [Go duplication](#go-duplication)
4. [TypeScript/JavaScript](#typescriptjavascript)
5. [Rust](#rust)
6. [Python](#python)
7. [Nix](#nix)
8. [Severity classification](#severity-classification)

---

## Build systems

Detect the build system and use its native commands:

| Build system | Detection               | Build             | Lint                    | Test             |
| ------------ | ----------------------- | ----------------- | ----------------------- | ---------------- |
| Nix flakes   | `flake.nix` exists      | `nix build`       | `nix flake check`       | `nix run .#test` |
| Make         | `Makefile` exists       | `make build`      | `make lint`             | `make test`      |
| Go           | `go.mod` exists         | `go build ./...`  | `go vet ./...` + linter | `go test ./...`  |
| pnpm/pnpm     | `package.json` exists   | `pnpm run build`   | `pnpm run lint`          | `pnpm test`       |
| Cargo        | `Cargo.toml` exists     | `cargo build`     | `cargo clippy`          | `cargo test`     |
| Python       | `pyproject.toml` exists | `python -m build` | `ruff check .`          | `pytest`         |

**Precedence:** If `flake.nix` exists, prefer Nix commands (they provide the most hermetic, reproducible environment). In LarsArtmann projects, `flake.nix` is always the canonical build system — never use Makefiles or justfiles.

---

## Go linting

| Tool            | What it catches                                                            | Command                   |
| --------------- | -------------------------------------------------------------------------- | ------------------------- |
| `go vet`        | Common mistakes (printf format, struct tags, unreachable code)             | `go vet ./...`            |
| `golangci-lint` | Meta-linter: aggregates staticcheck, gosec, revive, unused, errcheck, etc. | `golangci-lint run ./...` |
| `staticcheck`   | Advanced static analysis (unused code, simplification, deprecated APIs)    | `staticcheck ./...`       |

**Recommended:** Run `golangci-lint` with a project-specific `.golangci.yml`. If none exists, the default linters (`errcheck`, `gosimple`, `govet`, `ineffassign`, `staticcheck`, `unused`) are a solid baseline.

---

## Go duplication

The canonical tool is **art-dupl** (semantic code duplication detection). It is also used by the `deduplicate-code` skill.

```bash
art-dupl --type-aware --sort total-tokens -t 5 --html
```

- `--type-aware`: match code structurally, not just textually
- `-t 5`: minimum token count for a clone (lower = more results, higher = fewer)
- `--sort total-tokens`: largest clones first
- `--html`: view output in browser

If `art-dupl` is not installed, fall back to `jscpd` (language-agnostic copy-paste detection):

```bash
pnpm dlx jscpd src/ --format "go" --reporters html
```

---

## TypeScript/JavaScript

| Tool     | What it catches                                      | Command                   |
| -------- | ---------------------------------------------------- | ------------------------- |
| `tsc`    | Type errors                                          | `tsc --noEmit`            |
| `eslint` | Code quality, style, best practices                  | `eslint . --ext .ts,.tsx` |
| `biome`  | Fast linter + formatter (replaces eslint + prettier) | `biome check .`           |
| `jscpd`  | Copy-paste detection                                 | `pnpm dlx jscpd src/`          |

---

## Rust

| Tool           | What it catches              | Command                                     |
| -------------- | ---------------------------- | ------------------------------------------- |
| `cargo build`  | Compilation errors           | `cargo build`                               |
| `cargo clippy` | Idiom lints, common mistakes | `cargo clippy --all-targets -- -D warnings` |
| `cargo test`   | Test failures                | `cargo test`                                |

---

## Python

| Tool     | What it catches                                 | Command        |
| -------- | ----------------------------------------------- | -------------- |
| `ruff`   | Fast linter (replaces flake8, isort, pyupgrade) | `ruff check .` |
| `mypy`   | Static type checking                            | `mypy .`       |
| `pytest` | Test runner                                     | `pytest`       |

---

## Nix

| Tool              | What it catches                      | Command           |
| ----------------- | ------------------------------------ | ----------------- |
| `nix flake check` | Build correctness, evaluation errors | `nix flake check` |
| `statix`          | Nix anti-patterns and best practices | `statix check`    |
| `deadnix`         | Dead code (unused let bindings)      | `deadnix`         |

---

## Severity classification

Map tool output to report severity:

| Severity | Criteria                                            | Examples                                     |
| -------- | --------------------------------------------------- | -------------------------------------------- |
| Critical | Build fails, security vulnerability, data loss risk | `go build` exits non-zero, `gosec` CRITICAL  |
| High     | Will cause bugs in production, broken tests         | Unused error return, race condition detected |
| Medium   | Code smell, maintainability issue, style violation  | Inconsistent naming, missing error context   |
| Low      | Minor improvement, formatting, documentation gap    | Missing comment on exported function, typo   |
