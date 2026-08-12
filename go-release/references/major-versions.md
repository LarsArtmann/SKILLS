# Major Version Migration (v2+)

Table of Contents:
- [When you need this](#when-you-need-this)
- [The module path rule](#the-module-path-rule)
- [Step-by-step: v1 to v2 migration](#step-by-step-v1-to-v2-migration)
- [Major version branches](#major-version-branches)
- [The +incompatible problem](#the-incompatible-problem)
- [Migrating consumers](#migrating-consumers)
- [Coexistence: v1 and v2 side by side](#coexistence-v1-and-v2-side-by-side)

---

## When you need this

Go modules require a `/vN` suffix in the module path for major version 2 and above.
This is the most disruptive version bump — it changes every import path in the module
and every consumer's import statements.

Load this reference when the user says "major version", "v2 migration", "module path
change", "breaking API change release", or asks about `+incompatible` versions.

---

## The module path rule

| Major version | Module path | Import example |
|---------------|-------------|----------------|
| v0, v1 | `github.com/org/module` | `import "github.com/org/module"` |
| v2 | `github.com/org/module/v2` | `import "github.com/org/module/v2"` |
| v3 | `github.com/org/module/v3` | `import "github.com/org/module/v3"` |

v0 and v1 have **no suffix**. v2+ **must** include the suffix. There is no exception.

This means v1 and v2 are **completely separate modules** — they can coexist in the
same build, imported simultaneously. This is by design: it lets consumers migrate
incrementally.

---

## Step-by-step: v1 to v2 migration

### 1. Update the module path in go.mod

```go
// Before (v1):
module github.com/myorg/myrepo

// After (v2):
module github.com/myorg/myrepo/v2
```

### 2. Rewrite all internal imports

Every file in the module that imports a sibling package must update its import path:

```bash
# Find all internal imports
grep -r '"github.com/myorg/myrepo/' --include='*.go' .

# Rewrite them (use word boundaries to avoid partial matches)
find . -name '*.go' -exec sed -i 's|"github.com/myorg/myrepo/|"github.com/myorg/myrepo/v2/|g' {} +

# Also update any self-referencing imports of the root package
find . -name '*.go' -exec sed -i 's|"github.com/myorg/myrepo"|"github.com/myorg/myrepo/v2"|g' {} +
```

**Critical**: scope the `sed` carefully. Use the exact module path to avoid
corrupting unrelated imports that happen to share a prefix. Always verify with `grep`
afterwards:

```bash
# Verify all internal imports now use /v2
grep -r '"github.com/myorg/myrepo/' --include='*.go' . | grep -v '/v2/'
# Should return nothing — every internal import should have /v2/
```

### 3. Update generated code

If the project uses code generators (`templ generate`, `go generate`, protobuf,
etc.), re-run them after the import rewrite. Generated code contains import paths
that must match the new module path.

### 4. Update replace directives (if any)

If go.mod has `replace` directives for sibling modules, update those too:

```go
// Before:
replace github.com/myorg/myrepo => ../myrepo

// After:
replace github.com/myorg/myrepo/v2 => ../myrepo
```

Better: use `go.work` for local development and avoid `replace` entirely.

### 5. Build, test, verify

```bash
go build ./...
go test -race -count=1 ./...
go vet ./...
```

### 6. Commit and tag

```bash
git add -A
git commit -m "feat!: migrate to v2 module path

BREAKING CHANGE: module path changes from github.com/myorg/myrepo
to github.com/myorg/myrepo/v2. All importers must update import paths."

git tag -a v2.0.0 -m "Release v2.0.0 — major version with breaking API changes"
git push origin master
git push origin v2.0.0
```

### 7. Verify go get works

```bash
rm -rf /tmp/test-v2 && mkdir /tmp/test-v2 && cd /tmp/test-v2
go mod init test
go get github.com/myorg/myrepo/v2@v2.0.0
```

---

## Major version branches

Some projects maintain multiple major versions simultaneously (e.g., v1 and v2 both
receive bug fixes). The standard pattern:

```
main branch:     contains the latest major version (e.g., v3)
v2 branch:       contains v2 maintenance
v1 branch:       contains v1 maintenance
```

Each branch has its own module path in go.mod. Tags are cut independently from each
branch. This is the approach used by large projects like `github.com/cli/cli/v2`.

For smaller projects, it's simpler to only maintain the latest major version and let
the old tags serve v1 consumers permanently.

---

## The +incompatible problem

If a repository has a `v2.0.0` git tag but the module path in go.mod does NOT have
the `/v2` suffix, Go appends `+incompatible` to the version:

```
github.com/myorg/myrepo v2.0.0+incompatible
```

This is a legacy compatibility behavior. It means Go treats the v2+ module as if it
were v1 for import path purposes. This works but has drawbacks:

- Consumers can't have v1 and v2 side by side (same import path)
- It signals the module author didn't follow Go's major version convention
- `go mod tidy` may produce warnings

**Avoid `+incompatible` for new releases.** Always migrate the module path when
cutting v2+. If you inherit a project with `+incompatible` versions, migrating to
proper `/v2` is a breaking change — cut `v2.0.0` (not `v3.0.0`) after fixing the path.

Wait — that would conflict with the existing `v2.0.0+incompatible` tag. The first
proper v2 release should be `v2.0.0` on a `/v2` module path. The old
`v2.0.0+incompatible` tag becomes inaccessible through the proper path. This is
acceptable — the `+incompatible` version was never a proper v2 module.

---

## Migrating consumers

After publishing v2, consumers need to update. This is a two-step process:

1. **Update go.mod**: `go get github.com/myorg/myrepo/v2@v2.0.0`
2. **Rewrite imports**: every `import "github.com/myorg/myrepo"` becomes
   `import "github.com/myorg/myrepo/v2"`

The go-ecosystem-upgrade skill covers the consumer-side migration in detail,
including the decision tree for additive vs breaking bumps.

---

## Coexistence: v1 and v2 side by side

Because v1 and v2 have different module paths, they can coexist:

```go
package main

import (
    v1 "github.com/myorg/myrepo"
    "github.com/myorg/myrepo/v2"
)
```

This enables incremental migration: consumers can adopt v2 package-by-package without
a flag-day cutover. This is why the `/vN` suffix exists — it makes breaking changes
non-catastrophic for consumers.
