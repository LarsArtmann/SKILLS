# Real-World Patterns from Production Go Multi-Module Projects

> Reference for [../SKILL.md](../SKILL.md). Patterns distilled from three production
> Go multi-module projects (46, 18, and 26 modules respectively).

## Table of Contents

- [Dual Strategy: go.work + replace Together](#dual-strategy-gowork--replace-together)
- [CI Verification Patterns](#ci-verification-patterns)
- [Version Management](#version-management)
- [Interface Extraction Patterns](#interface-extraction-patterns)
- [Test Infrastructure Patterns](#test-infrastructure-patterns)
- [Error Architecture Patterns](#error-architecture-patterns)
- [Layer Enforcement](#layer-enforcement)
- [Module Naming Conventions](#module-naming-conventions)

---

## Dual Strategy: go.work + replace Together

**The old wisdom was wrong.** Earlier Go modularization guides said "pick one: go.work
OR replace directives, never mix both." Production projects do the opposite — they use
BOTH deliberately, and it's the correct approach.

### Why both?

| Mode | Purpose | When |
| --- | --- | --- |
| `go.work` | Fast local development — shared build cache, no `go mod tidy` churn | Developer workstations |
| `replace` directives | Standalone builds — CI, `GOWORK=off`, Nix, external consumers who clone the repo | CI, releases, `go mod tidy` without workspace |

Without `replace` directives, `GOWORK=off go build ./...` fails — the module can't
resolve sibling dependencies. Without `go.work`, developers must run `go mod tidy`
after every local change, and the shared build cache is lost.

### How to maintain both

1. **Every module with internal deps gets replace directives** for each sibling it
   imports (directly or transitively). Use relative paths: `replace github.com/org/mod/v3 => ../mod`
2. **go.work lists every module** with `use ./mod` directives
3. **CI tests both modes**: `go build ./...` (workspace) AND `GOWORK=off go build ./...`
   per module (isolation)
4. **Add a sync check**: verify `go.work` `use` directives match the actual `go.mod`
   files on disk — no stale entries, no missing modules

### Anti-pattern: go.work-only

A project with `go.work` but no `replace` directives works locally but breaks for:
- CI builds that set `GOWORK=off` (common in Nix, Docker, release pipelines)
- External consumers who `go get` the module (go.work is ignored by consumers)
- `go mod tidy` run without the workspace active

---

## CI Verification Patterns

### Per-module isolation testing

Test every module independently with `GOWORK=off`:

```bash
# For each module directory:
cd module/
GOWORK=off go build ./...   # Must build without workspace
GOWORK=off go test ./...     # Must test without workspace
GOWORK=off go vet ./...      # Must vet without workspace
```

This catches:
- Missing `replace` directives (module can't resolve siblings)
- Version mismatches (module references an old version of a sibling)
- Stale `go.work` entries (workspace masks a deleted module)

### Workspace sync idempotency

Verify `go work sync` + `go mod tidy` produces no changes:

```bash
go work sync
go mod tidy
git diff --exit-code go.work go.work.sum */go.mod */*/go.mod
```

If this produces changes, someone forgot to sync after a structural change.

### Replace directive audit

Verify no absolute paths in replace directives (they break portability):

```bash
for mod in $(find . -name go.mod -not -path './vendor/*'); do
  awk '/^replace / && /=> *\/[A-Za-z]/ { print FILENAME": "$0; bad=1 }' "$mod"
done
[[ "$bad" == "1" ]] && exit 1
```

### Version drift detection

Detect when sibling modules reference different versions of the same internal
dependency:

```bash
# For each internal module, collect all version references across go.mod files.
# Flag if any sibling is referenced at different versions.
```

Version drift creates subtle bugs: module A tests with `sibling/v3 v3.1.0` while
module B tests with `sibling/v3 v3.0.0`. Workspace mode hides this; `GOWORK=off`
exposes it.

---

## Version Management

### v0.0.0 normalization

Pin all internal module references to `v0.0.0`:

```
require github.com/org/sibling/v3 v0.0.0
replace github.com/org/sibling/v3 => ../sibling
```

Since `replace` makes the version irrelevant for resolution, `v0.0.0` eliminates
pseudo-version churn (e.g., `v0.0.0-20240115120000-abcdef123456`) that pollutes
every `go mod tidy` and PR diff.

Automate with a normalization script:

```bash
# Pin all internal requires to v0.0.0
for mod in $(find . -name go.mod -not -path './vendor/*'); do
  # Replace internal pseudo-versions with v0.0.0
  sed -i -E 's/(github\.com\/org\/[a-z-]+\/v[0-9]+) v0\.0\.0-[0-9a-f-]+/\1 v0.0.0/g' "$mod"
done
```

### Monorepo tagging

A single `v*` git tag bumps all modules together. Simpler than independent module
versioning, appropriate when modules are tightly coupled and consumers typically
import multiple modules.

### Major version in module path

Use `/v2`, `/v3` suffixes in module paths for major version bumps:

```
module github.com/org/eventstore/domain/v3
```

This follows Go's module versioning convention and allows consumers to pin a
major version without ambiguity.

---

## Interface Extraction Patterns

### Compile-time interface assertions

Verify implementations at compile time, not runtime:

```go
// In the implementation module — not the interface module
var (
    _ event.Store           = (*MemoryStore)(nil)
    _ event.Journal         = (*MemoryStore)(nil)
    _ event.SeekableJournal = (*MemoryStore)(nil)
    _ io.Closer             = (*MemoryStore)(nil)
)
```

This catches missing methods immediately — the build fails if the implementation
doesn't satisfy the interface. Place the assertion in the implementation module,
not the interface module, so the interface module stays dependency-free.

### Interface Segregation in bundles

When composing a bundle of capabilities, store segregated interfaces rather than
fat composites:

```go
// Good: segregated — consumers that only write don't pull read-side code
type Bundle struct {
    EventSink   event.EventSink      // write side only
    EventSource event.EventSource    // read side only
    Journal     event.Journal        // cross-aggregate reads
    Publisher   event.Publisher      // pub/sub
}

// Bad: fat composite — forces all consumers to depend on everything
type Bundle struct {
    Store event.Store  // = EventSink + EventSource + Journal + ...
}
```

### Function adapters

Follow the `http.HandlerFunc` pattern for simple tools:

```go
type Detector interface {
    Detect(ctx context.Context, in DetectInput) (FindingReport, error)
}

type DetectorFunc func(ctx context.Context, in DetectInput) (FindingReport, error)

func (f DetectorFunc) Detect(ctx context.Context, in DetectInput) (FindingReport, error) {
    return f(ctx, in)
}
```

Simple tools register as functions, not structs. No boilerplate.

### Capability composition via optional interfaces

Hold capability interfaces as optional fields; nil means "not capable":

```go
type Tool struct {
    Detector      // nil if not capable
    Repairer       // nil if not capable
    Generator     // nil if not capable
}

func (t *Tool) CanDetect() bool  { return t.Detector != nil }
func (t *Tool) CanRepair() bool  { return t.Repairer != nil }
```

---

## Test Infrastructure Patterns

### Separate test helper modules

Create dedicated modules for shared test utilities:

| Pattern | Example | Dependencies |
| --- | --- | --- |
| Zero-dep test fixtures | `testutil/` or `testhelpers/` | stdlib only |
| Domain-aware test utils | `testutils/` | domain, model, testhelpers |
| Module-specific test helpers | `event/eventtest/` | event, id (nested submodule) |

**Zero-dep test helpers** use stdlib `testing.TB` only — no ginkgo, no gomega.
This means any module can import them without pulling test framework deps:

```go
// testhelpers/assertions.go — uses testing.TB, not gomega
func AssertFinding(t testing.TB, got, want Finding) {
    t.Helper()
    // ...
}
```

### Nested test submodules

For test helpers that belong to a specific domain module, nest them as a
submodule:

```
event/
├── go.mod                         # module: github.com/org/event/v3
├── event.go
├── store.go
└── eventtest/
    ├── go.mod                     # module: github.com/org/event/v3/eventtest
    ├── fake_store.go              # FakeStore implementing event.Store
    └── fake_bus.go                # FakeBus implementing event.Bus
```

This keeps test helpers discoverable (they live next to the domain module) while
maintaining a separate `go.mod` so consumers don't pull test deps transitively.

### The test-dep leak reality

Go has no separate test-only `require` block. `ginkgo`, `gomega`, `rapid` appear
as direct `require` entries even when only used in `_test.go` files. This is a
**language limitation**, not a project mistake.

Mitigations:
- **Script-based detection**: CI script that identifies deps only imported from
  `_test.go` files and subtracts them from the "production dependency budget"
- **Zero-dep test helpers**: Keep at least one test helper module stdlib-only
- **Accept the leak**: For test frameworks specifically, the leak is unavoidable.
  Document it and move on. Don't merge modules to "hide" test deps (see FM#3).

### Mock/double placement

**Anti-pattern**: Test doubles in production package code:

```go
// runner/mock_command.go — in PRODUCTION package, not _test.go
type MockCommandRunner struct { ... }
```

Any consumer of `runner` transitively pulls in mock infrastructure. Keep mocks
in `_test.go` files or in dedicated test helper modules.

---

## Error Architecture Patterns

### Pattern 1: Centralized error hub

Define all sentinel errors and error constructors in the domain/interface module.
Implementation modules import the domain module to create errors:

```go
// domain/errors.go — the hub
var (
    ErrNotFound      = errors.New("not found")
    ErrAlreadyExists = errors.New("already exists")
)

// Custom error type with classification
type CodedError struct {
    Code    string
    Message string
    Cause   error
}
func (e *CodedError) Error() string { return e.Message }
func (e *CodedError) Unwrap() error  { return e.Cause }
```

```go
// storage/store.go — implementation uses domain errors
return domain.ErrNotFound  // not storage.ErrNotFound
```

**Why**: Consumers need `errors.Is(err, domain.ErrNotFound)` to work across module
boundaries. If the error lives in `storage/`, consumers must import `storage/`
just to check the error — breaking the interface/implementation split.

### Pattern 2: Error classification interface

Define an interface in the domain module; let implementations tag their errors:

```go
// domain/errors.go
type ErrorCoder interface {
    ErrorCode() ErrorCode
}

type ErrorCode string

const (
    CodeValidation  ErrorCode = "validation"
    CodeConflict    ErrorCode = "conflict"
    CodeTransient   ErrorCode = "transient"
)

func NewCodedError(code ErrorCode, msg string) *CodedError {
    return &CodedError{Code: code, Message: msg}
}
```

```go
// enrichment/git/enricher.go — tags errors with codes
var ErrGitFailed = domain.NewCodedError(domain.CodeTransient, "git operation failed")

// Batch processor categorizes without importing enricher packages:
for _, err := range errors {
    if coder, ok := err.(domain.ErrorCoder); ok {
        category := coder.ErrorCode()  // "transient" — no import needed
    }
}
```

**Why**: The batch processor can categorize errors by code without importing
every enricher module. The interface decouples error classification from error
construction.

### Pattern 3: Error family classification

Use a structured error library (e.g., `errorfamily`) with severity categories:

```go
// domain/errors.go — re-export from error library
const (
    Rejection      = errorfamily.Rejection      // client error, don't retry
    Conflict       = errorfamily.Conflict       // optimistic concurrency
    Transient      = errorfamily.Transient      // retry
    Infrastructure = errorfamily.Infrastructure  // system error
)

func NewRejection(code, msg string) *Error  { return errorfamily.NewRejection(code, msg) }
func NewConflict(code, msg string) *Error   { return errorfamily.NewConflict(code, msg) }
```

**Why**: Retry logic, error reporting, and user-facing messages can branch on
error family without inspecting specific error types. A `Transient` error gets
retried; a `Rejection` doesn't. This works across all modules that use the family.

### Anti-pattern: Plain errors.New in higher layers

When lower layers use classified errors but higher layers use plain
`errors.New()`, the classification is lost:

```go
// domain/errors.go — uses classified errors
func NewRejection(code, msg string) *Error { ... }

// stack/bundle.go — uses PLAIN errors (loses classification)
var ErrEmpty = errors.New("bundle is empty")  // what family? retryable? client error?
```

Be consistent: if the domain module uses classified errors, all modules that
depend on it should too.

---

## Layer Enforcement

### Script-based layer model

Define explicit dependency layers and enforce them with a CI script:

```bash
# check-module-layers.sh
# Each module is assigned a layer. A module may only depend on modules
# in the same or lower layers.

declare -A LAYER=(
    [id]=0 [codec]=0 [dispatcher]=0 [kv]=0
    [event]=1 [command]=1 [query]=1
    [projection]=2 [snapshot]=2 [schema]=2
    [decider]=3
    [signing]=4 [encryption]=4 [otel]=4 [storage/memory]=4
    [storage]=5 [storage/pebble]=5 [storage/turso]=5
    [stack]=6 [stack/memory]=6 [stack/postgres]=6
    [integration]=7 [catalog]=7
)

# For each module, verify its dependencies are in the same or lower layer
for mod in "${!LAYER[@]}"; do
    mod_layer=${LAYER[$mod]}
    for dep in $(get_deps "$mod"); do
        dep_layer=${LAYER[$dep]:-99}
        if [[ "$dep_layer" -gt "$mod_layer" ]]; then
            echo "VIOLATION: $mod (layer $mod_layer) depends on $dep (layer $dep_layer)"
            failed=1
        fi
    done
done
```

### Architecture linting

Use `go-arch-lint` to enforce dependency rules declaratively:

```yaml
# .go-arch-lint.yml
deps:
  domain:
    anyVendorDeps: true
    mayDependOn: []          # Pure contracts — imports NOTHING internal
  providers:
    anyVendorDeps: true
    mayDependOn: [domain]    # Plugins implement domain contracts
  execution:
    mayDependOn: [domain, model, runner, tools]
```

### Documented exceptions

When a layer violation is necessary, document it explicitly in the enforcement
script:

```bash
# Exception: event depends on storage/memory for test helpers
EXCEPTIONS[event]="storage/memory"
EXCEPTIONS[command]="storage/memory"
```

Undocumented exceptions are technical debt. Documented exceptions are
architecture decisions.

---

## Module Naming Conventions

### Version suffix in module path

For major version 2+, include the version in the module path:

```
module github.com/org/eventstore/domain/v3
```

This follows Go's module versioning convention. Consumers import
`github.com/org/eventstore/domain/v3` explicitly, and major version
bumps require a conscious import path change.

### Nested module families

Group related modules under a directory prefix:

```
storage/
├── go.mod              # module: .../storage/v3 (SQL store)
├── memory/
│   └── go.mod          # module: .../storage/memory/v3 (in-memory)
├── pebble/
│   └── go.mod          # module: .../storage/pebble/v3 (PebbleDB)
└── turso/
    └── go.mod          # module: .../storage/turso/v3 (Turso)
```

The `storage/` prefix groups implementations of the same interface family.
Consumers can see all storage options at a glance.

### Plugin/module prefix

For plugin-like extensions, use a `modules/` or `enrichment/` prefix:

```
modules/
├── errors/             # Shared error system
├── binary-checker/     # Binary file detection
├── nix-checker/        # Nix file validation
└── gomod-checker/      # go.mod validation

enrichment/
├── git/                # Git metadata
├── codestats/          # Code statistics
└── version/            # Version detection
```

This keeps plugins discoverable and separates them from core domain modules.
