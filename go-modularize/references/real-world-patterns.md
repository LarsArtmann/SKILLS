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

Some guides say "pick one: go.work OR replace directives, never mix both."
Production Go projects do the opposite — they use BOTH deliberately, and for
good reason.

### Why both?

| Mode                 | Purpose                                                                          | When                                          |
| -------------------- | -------------------------------------------------------------------------------- | --------------------------------------------- |
| `go.work`            | Fast local development — shared build cache, no `go mod tidy` churn              | Developer workstations                        |
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
# Collect all internal module version references and flag disagreements
internal_modules=$(find . -name go.mod -not -path './vendor/*' -exec dirname {} \; | sort -u)
for mod in $internal_modules; do
  mod_path=$(head -1 "$mod/go.mod" | cut -d' ' -f2)
  # Find all go.mod files that require this module and extract their version
  versions=$(grep -rh "$mod_path " $(find . -name go.mod -not -path './vendor/*') | \
    awk '{print $NF}' | sort -u)
  if [[ $(echo "$versions" | wc -l) -gt 1 ]]; then
    echo "DRIFT: $mod_path referenced at multiple versions: $versions"
    failed=1
  fi
done
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

Automate with a normalization script (replace `github.com/org` with your module prefix):

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

| Pattern                      | Example                       | Dependencies                 |
| ---------------------------- | ----------------------------- | ---------------------------- |
| Zero-dep test fixtures       | `testutil/` or `testhelpers/` | stdlib only                  |
| Domain-aware test utils      | `testutils/`                  | domain, model, testhelpers   |
| Module-specific test helpers | `event/eventtest/`            | event, id (nested submodule) |

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

### The test-dep leak: minimize, don't accept

Go has no separate test-only `require` block. `ginkgo`, `gomega`, `rapid` appear as
direct `require` entries even when only used in `_test.go` files. This is a **language
limitation** — but "accept the leak" is the wrong response. The goal is to minimize test
framework deps in production `go.mod` to as close to zero as possible.

**The Test Module Pattern** — split test code by what it accesses:

| Test type | What it tests | Where it lives | Test framework deps |
| --- | --- | --- | --- |
| White-box (internal) | Unexported symbols, internals | `_test.go` in production module (`package foo`) | stdlib `testing` only — **zero external deps** |
| Black-box (external) | Exported API, integration | Companion test module (`package foo_test`) | ginkgo, gomega, rapid — **in test module's go.mod, not production's** |

```
domain/                              # Production module
├── go.mod                           # ZERO test framework deps
├── event.go
├── store.go
├── event_test.go                    # White-box: package event, stdlib testing only
└── store_test.go                    # White-box: tests unexported helpers

domain_test/                         # Companion test module
├── go.mod                           # Imports domain/v3 + ginkgo + gomega
├── event_bdd_test.go               # Black-box: package event_test, BDD specs
├── store_integration_test.go       # Black-box: integration tests via exported API
└── contract_test.go                 # Black-box: interface contract tests
```

**Why this works**: Go's `package foo_test` (external test package) can access all
exported symbols but lives in a separate module. The production module's `go.mod`
only has deps for white-box tests — which should use stdlib `testing` and `testing/quick`
only, not ginkgo/gomega.

**The companion module's go.mod**:

```
module github.com/org/eventstore/domain_test

go 1.26.4

require (
    github.com/org/eventstore/domain/v3 v0.0.0
    github.com/onsi/ginkgo/v2 v2.0.0
    github.com/onsi/gomega v1.30.0
)

replace github.com/org/eventstore/domain/v3 => ../domain
```

The test module imports the production module as a dependency (via replace) and
owns the test framework deps. The production module's `go.mod` stays clean.

**When you can't avoid the leak**: If a white-box test absolutely needs ginkgo (e.g., BDD
spec for internal behavior), that test framework dep goes in production `go.mod`. This
should be rare — most internal logic can be tested with table-driven stdlib tests.

**Acceptance criteria**: production `go.mod` has test framework deps ONLY if the module
has white-box tests that need them. Most modules should have zero test framework deps.

**Additional mitigations**:

- **Script-based detection**: CI script that identifies deps only imported from
  `_test.go` files and subtracts them from the "production dependency budget"
- **Zero-dep test helpers**: Keep at least one test helper module stdlib-only
- **Never merge modules to "hide" test deps** (see FM#3) — that's treating the symptom, not the cause

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

### Choosing an error architecture

The key decision: **where do error types live?** There are four options, each with
tradeoffs. The wrong choice creates either a god-module (everything depends on domain
for errors) or broken `errors.Is` chains (consumers can't check errors across boundaries).

#### Option A: Errors in the interface module (default)

Contract errors live where the interface lives. Implementation-specific errors live in
the implementation module.

```go
// domain/errors.go — contract errors (part of the Store interface contract)
var (
    ErrNotFound  = errors.New("not found")
    ErrConflict  = errors.New("version conflict")
)

// storage/errors.go — implementation-specific errors (not part of the contract)
var (
    ErrConnectionFailed = errors.New("connection failed")  // storage-specific
    ErrDiskFull         = errors.New("disk full")          // storage-specific
)
```

| | |
| --- | --- |
| **PRO** | No god-module. Each module owns its own errors. Natural ownership — contract errors travel with the contract, implementation errors with the implementation. |
| **CON** | Consumers may need to import multiple error packages for `errors.Is`. Cross-module error classification requires an interface (see Option C). |
| **When** | Default. Start here. Most modules. |

#### Option B: Dedicated errors module

A standalone `errors/` module that owns the error taxonomy. All other modules import it
for error types and constructors.

```go
// errors/errors.go — standalone module, not part of domain
var (
    ErrNotFound        = errors.New("not found")
    ErrAlreadyExists   = errors.New("already exists")
    ErrConnectionFailed = errors.New("connection failed")
)

// errors/classification.go
type Family string
const (
    Rejection      Family = "rejection"
    Transient      Family = "transient"
    Infrastructure Family = "infrastructure"
)
```

| | |
| --- | --- |
| **PRO** | Domain stays lean — it doesn't own every error. Single import for all error handling. Errors are a separate concern from domain types. |
| **CON** | Still a hub — every module depends on `errors/`. But it's focused on one concern, not domain types + interfaces + errors + everything. |
| **When** | domain would grow too large owning all errors. Error types are extensive and independent of domain types. |

#### Option C: Error classification interface (scales best)

Each module owns its own errors. An `ErrorCoder` interface in domain enables cross-module
classification **without importing the module that created the error**.

```go
// domain/errors.go — minimal: just the interface + codes
type ErrorCoder interface {
    ErrorCode() ErrorCode
}

type ErrorCode string

const (
    CodeValidation ErrorCode = "validation"
    CodeConflict   ErrorCode = "conflict"
    CodeTransient  ErrorCode = "transient"
)

// enrichment/git/enricher.go — owns its errors, tags them with codes
var ErrGitFailed = &CodedError{Code: CodeTransient, Msg: "git operation failed"}

// Batch processor categorizes without importing enricher packages:
for _, err := range errors {
    if coder, ok := err.(domain.ErrorCoder); ok {
        category := coder.ErrorCode()  // "transient" — no import of enrichment/git needed
    }
}
```

| | |
| --- | --- |
| **PRO** | No god-module. Each module owns its errors. Cross-module classification works via the interface. Domain stays minimal (interface + codes, not all error values). |
| **CON** | Slightly more complex. `errors.Is(err, domain.ErrNotFound)` only works for contract errors in domain — implementation-specific errors need their own sentinels in their own modules. |
| **When** | Many modules (10+). Error classification needed across module boundaries. Want to avoid every module depending on a shared errors hub. |

#### Option D: Error family library

External library (e.g., `errorfamily`) with severity categories. Each module creates
errors tagged with a family.

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

| | |
| --- | --- |
| **PRO** | Classification without central ownership. Each module creates its own errors. Retry logic and error reporting branch on family without inspecting specific types. |
| **CON** | External dependency. Still need to decide where the re-exports live (domain? dedicated errors module?). |
| **When** | You need retry logic, error reporting, or user-facing messages that branch on error severity across all modules. |

### Anti-pattern: All errors in domain (god-module risk)

When domain owns errors for 20+ modules, it becomes a god-module that everything touches.
Every new error in any module requires a change to domain, and every module depends on
domain for its error types. This is the centralization trap.

**The fix**: contract errors (part of the interface) live in the interface module.
Implementation-specific errors live in the implementation module. Cross-module
classification uses an interface (Option C), not a shared bag of error values.

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
    mayDependOn: [] # Pure contracts — imports NOTHING internal
  providers:
    anyVendorDeps: true
    mayDependOn: [domain] # Plugins implement domain contracts
  execution:
    mayDependOn: [domain, model, runner, tools]
```

### Exceptions are a smell, not a feature

When a layer violation is "necessary," the first response should be to question the
model, not to document the exception. Exceptions are evidence the layer model doesn't
fit reality. Either the model is wrong or the boundaries are.

```bash
# If you have this:
EXCEPTIONS[event]="storage/memory"
EXCEPTIONS[command]="storage/memory"
EXCEPTIONS[schema]="storage/memory snapshot"
EXCEPTIONS[snapshot]="storage/memory"
EXCEPTIONS[decider]="storage/memory otel"
EXCEPTIONS[query]="snapshot storage/memory"
```

That's 6 exceptions. Each one is a signal: the layer assignment is wrong, the module
boundary is in the wrong place, or a dependency that should be test-only is leaking into
production code.

**Before adding an exception, ask:**

1. **Is the dependency actually production?** If `event` depends on `storage/memory` only
   for test helpers, the fix is moving test helpers to a separate test module — not an
   exception. The exception papers over a test-dep leak (see §Test Infrastructure).
2. **Is the layer assignment wrong?** If `storage/memory` is used by Layer 1 modules,
   maybe `storage/memory` IS Layer 1, not Layer 4. Reassign it.
3. **Is the boundary in the wrong place?** If `event` genuinely needs in-memory
   implementations, maybe the interface and the in-memory implementation belong in the
   same module. Merge them.
4. **Is the abstraction wrong?** If modules keep violating layers to reach a shared
   utility, the utility is at the wrong level of abstraction. Extract it to its own
   leaf module at Layer 0.

**If after all four questions the exception is still necessary**, document it
explicitly — but treat it as known debt with a plan to eliminate it, not as a
permanent architecture decision. Undocumented exceptions are technical debt. Documented
exceptions are technical debt with a name.

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
