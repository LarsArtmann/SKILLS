# Multi-Module Monorepo Releases

Table of Contents:

- [The problem](#the-problem)
- [The chicken-and-egg solution](#the-chicken-and-egg-solution)
- [Phase-by-phase: releasing a multi-module monorepo](#phase-by-phase-releasing-a-multi-module-monorepo)
- [The go.work interplay](#the-gowork-interplay)
- [GORELEASER_CURRENT_TAG](#goreleaser_current_tag)
- [Verification strategy](#verification-strategy)

---

## The problem

A multi-module Go monorepo has several `go.mod` files linked by a `go.work` file.
Each module is independently versioned and has its own import path:

```
myrepo/
├── go.mod          # github.com/myorg/myrepo
├── go.work         # links all modules locally
├── core/
│   └── go.mod      # github.com/myorg/myrepo/core
├── api/
│   └── go.mod      # github.com/myorg/myrepo/api
└── cli/
    └── go.mod      # github.com/myorg/myrepo/cli
```

Or the modules may be at the root with sub-modules in subdirectories:

```
myrepo/
├── go.mod          # github.com/myorg/myrepo        (core module)
├── go.work
├── viz/
│   └── go.mod      # github.com/myorg/myrepo/viz    (depends on core)
└── live/
    └── go.mod      # github.com/myorg/myrepo/live   (depends on core + viz)
```

Each module gets its own git tag at the same commit:

| Module | Import path                    | Tag format    |
| ------ | ------------------------------ | ------------- |
| Core   | `github.com/myorg/myrepo`      | `vX.Y.Z`      |
| Viz    | `github.com/myorg/myrepo/viz`  | `viz/vX.Y.Z`  |
| Live   | `github.com/myorg/myrepo/live` | `live/vX.Y.Z` |

The Go module proxy discovers each module's versions from its corresponding tag prefix.

---

## The chicken-and-egg-solution

Sub-module `go.mod` files must declare a `require` for their sibling modules at the
version being released. But `go mod tidy` can't resolve that version from the module
proxy until the tags are pushed. Running `go mod tidy` before pushing tags **will
corrupt `go.mod`** — it strips all require blocks because nothing resolves.

**Solution**: use `go mod edit -require` to set the version string directly.
This writes the require line without resolving it against the proxy, avoiding
the chicken-and-egg problem. Never run `go mod tidy` on sub-modules until after
tags are pushed.

```bash
VERSION="1.2.4"
MODULE="github.com/myorg/myrepo"

# In viz/go.mod: set the core module require line
(cd viz && go mod edit -require="${MODULE}@v${VERSION}")

# In live/go.mod: set both core and viz require lines
(cd live && go mod edit -require="${MODULE}@v${VERSION}" \
                  -require="${MODULE}/viz@v${VERSION}")
```

`go mod edit` is preferred over `sed` because it's a Go-native tool that
understands go.mod syntax. It writes the require line without attempting
resolution, so the unpublished version doesn't cause errors.

### Verify the bump

```bash
grep 'myrepo' viz/go.mod live/go.mod
# viz/go.mod should show: github.com/myorg/myrepo v${VERSION}
# live/go.mod should show: github.com/myorg/myrepo v${VERSION}
#                         github.com/myorg/myrepo/viz v${VERSION}
```

If a require line didn't update, `go mod edit` may have added a new line
instead of replacing the existing one. Check for duplicates with `grep -c`.

### CRITICAL: Verify no replace directives

```bash
grep '^replace' viz/go.mod live/go.mod go.mod
# MUST return nothing. replace directives in sub-modules produce
# pseudo-versions (v0.0.0-00010101000000-000000000000) that
# completely break consumer go get.
```

### Do NOT run `go mod tidy` yet

`go.sum` files will remain stale (old version checksums). This is expected. They will
be fixed after tags are pushed. Running `go mod tidy` or `go mod tidy -e` on sub-modules
before tags exist on the remote will strip all require blocks and produce a broken commit.

---

## Phase-by-phase: releasing a multi-module monorepo

### Step 1: Determine the version (same for all modules)

All modules in a coordinated release get the same version number and the same bump
type. See SKILL.md Phase 1.

### Step 2: Prepare CHANGELOG and bump versions

1. Cut the CHANGELOG (SKILL.md Phase 2)
2. Bump sub-module go.mod versions with `go mod edit` (above)
3. Verify no replace directives

### Step 3: Pre-push verification (workspace mode)

Verify in **workspace mode** (using `go.work` — NOT `GOWORK=off`). The workspace
resolves all modules from local directories, so the unpublished tag doesn't matter.

```bash
# Core module
go vet ./...
go test -race -count=1 ./...

# Viz module (workspace mode — go.work resolves core from local dir)
go vet ./viz/...
go test -race -count=1 ./viz/...

# Live module
go vet ./live/...
go test -race -count=1 ./live/...
```

Note: `nix run .#check` or equivalent CI that tests sub-modules in `GOWORK=off` mode
**will fail** at this point — it requires the published tag. This is expected. Use
workspace-mode verification for pre-push confidence; run the full standalone check
post-push.

### Step 4: Commit the release prep

```bash
git add CHANGELOG.md viz/go.mod live/go.mod   # and any other changed go.mod files
git commit -m "chore(release): prepare v${VERSION} — bump sub-module deps and CHANGELOG"
```

### Step 5: Create one annotated tag per module

All tags point at the same commit:

```bash
COMMIT=$(git rev-parse HEAD)

git tag -a "v${VERSION}"         -m "Release v${VERSION}"         "${COMMIT}"
git tag -a "viz/v${VERSION}"     -m "Release viz/v${VERSION}"     "${COMMIT}"
git tag -a "live/v${VERSION}"    -m "Release live/v${VERSION}"    "${COMMIT}"
```

Verify all tags are on the same commit:

```bash
git tag --points-at HEAD
# Should show all module tags
```

### Step 6: Push

```bash
git push origin master
git push origin "v${VERSION}" "viz/v${VERSION}" "live/v${VERSION}"
```

Wait 2-10 minutes for proxy propagation.

### Step 7: Fix go.sum checksums (post-push)

Now that tags are on the remote, the module proxy can resolve the new version. Run
`go mod tidy -e` on the sub-modules:

```bash
cd viz && GOWORK=off go mod tidy -e && cd ..
cd live && GOWORK=off go mod tidy -e && cd ..
```

The `-e` flag continues past resolution errors for dependencies with broken `replace`
directives in their own published go.mod files (e.g., a dependency that ships
`replace => ./testhelpers`). This is harmless — `-e` proceeds past it.

**Verify the require blocks are intact** (tidy should NOT have stripped them):

```bash
grep 'myrepo' viz/go.mod   # should show v${VERSION}
grep 'myrepo' live/go.mod  # should show v${VERSION} for core and viz
```

If tidy stripped the require blocks (chicken-and-egg still biting), restore from git
and manually add the checksum lines. Then commit:

```bash
git add viz/go.sum live/go.sum
git commit -m "chore(release): update go.sum checksums for v${VERSION}"
git push origin master
```

### Step 8: Verify standalone builds

```bash
cd viz  && GOWORK=off go test -count=1 ./... && cd ..
cd live && GOWORK=off go test -count=1 ./... && cd ..
```

These prove the sub-modules resolve without `go.work` — the same conditions consumers
experience.

### Step 9: Verify go get in clean directories

```bash
# Core
trash /tmp/test-core 2>/dev/null; mkdir -p /tmp/test-core && cd /tmp/test-core
GONOSUMDB='*' go mod init test && GONOSUMDB='*' go get github.com/myorg/myrepo@v${VERSION}

# Viz (standalone — proves no replace-directive leak)
trash /tmp/test-viz 2>/dev/null; mkdir -p /tmp/test-viz && cd /tmp/test-viz
GONOSUMDB='*' go mod init test && GONOSUMDB='*' go get github.com/myorg/myrepo/viz@viz/v${VERSION}

# Live
trash /tmp/test-live 2>/dev/null; mkdir -p /tmp/test-live && cd /tmp/test-live
GONOSUMDB='*' go mod init test && GONOSUMDB='*' go get github.com/myorg/myrepo/live@live/v${VERSION}
```

`GONOSUMDB='*'` makes these checks independent of sum.golang.org propagation
delays (a just-pushed tag may not be in the checksum DB yet, and a checksum
DB hiccup should never read as a release failure — that's a proxy-side
symptom, not a bad tag).

If any `go get` fails with `unknown revision 000000000000`, a sub-module go.mod has a
`replace` directive that wasn't caught in Step 2. Fix it, amend, re-tag, re-push.

---

## The go.work interplay

`go.work` is for **local development only**. It is never published. It overrides
`go.mod` `replace` directives locally, which is why workspace-mode builds pass even
when go.mod has issues.

Key behaviors:

- `go.work` uses filesystem paths, not module proxy versions. Local tags are irrelevant.
- `GOWORK=off` disables workspace mode, forcing go.mod-only resolution. This simulates
  the consumer experience.
- Creating local tags before pushing can break workspace builds because go.work forces
  proxy resolution of local tags. Don't create tags until ready to push.
- If the project has `go.work`, consumers never see it — they use `go.mod` directly
  with `GOWORK=off` (the default outside the workspace).

---

## GORELEASER_CURRENT_TAG

When multiple tags point at the same commit, GoReleaser uses `git describe` to
determine the current tag. If tags `v1.2.4`, `viz/v1.2.4`, and `live/v1.2.4` all
point at one commit, `git describe` returns the alphabetically-last tag
(`viz/v1.2.4`), which may not be the tag GoReleaser should build from.

**Always set `GORELEASER_CURRENT_TAG` explicitly for multi-module releases:**

```bash
GORELEASER_CURRENT_TAG="v${VERSION}" \
GITHUB_TOKEN="$(gh auth token)" \
  goreleaser release --clean
```

This forces GoReleaser to use the core module's tag, bypassing `git describe`.

---

## Verification strategy

The two-phase verification approach is essential for multi-module releases:

| Phase     | Mode                      | What it proves                                           | When                          |
| --------- | ------------------------- | -------------------------------------------------------- | ----------------------------- |
| Pre-push  | Workspace (`go.work`)     | Code compiles and tests pass locally                     | Before tagging                |
| Post-push | Standalone (`GOWORK=off`) | Modules resolve from the proxy like consumers experience | After tag push + checksum fix |

Pre-push workspace-mode verification is sufficient confidence to tag and push. The
standalone verification is the definitive proof that the release works for consumers.
