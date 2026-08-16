---
name: go-release
description: >
  Use when the user wants to release, publish, tag, or cut a new version of a Go
  project — library, application, or multi-module monorepo. Triggers on "release",
  "new version", "cut a release", "ship it", "tag and release", "publish", "should
  we release", "what's changed since last release", "pkg.go.dev", "checksum
  mismatch", "version retraction", "retract a version", "major version bump", "v2
  migration", "module path change", "GoReleaser", "release workflow", "GitHub
  release". Covers the complete release lifecycle: version determination, CHANGELOG
  cutting, pre-release verification, annotated tag creation, push, module proxy
  propagation, pkg.go.dev verification, GitHub Releases, go get validation, and
  recovery from botched releases. Handles single-module, multi-module (go.work), and
  binary releases, plus v2+ module-path migrations. Distinct from
  go-ecosystem-upgrade (consumer-side dependency bumps) — this skill is the supply
  side: publishing YOUR module for others to consume.
metadata:
  tags: go, release, publish, version, tag, semver, module-proxy, goreleaser,
    github-actions, multi-module, monorepo, changelog, pkg.go.dev, retraction,
    supply-chain, go.work
allowed-tools: goreleaser gh
---

# Go Release

The definitive guide to cutting, pushing, and verifying Go module releases. Every
rule here exists because a real release broke something — a poisoned proxy, a
checksum mismatch, a tag on the wrong commit, a `replace` directive that leaked
into production. Follow it precisely.

This skill handles three release shapes:

| Shape                     | What                                             | Tags                            |
| ------------------------- | ------------------------------------------------ | ------------------------------- |
| **Single-module library** | One `go.mod`, consumed via `go get`              | One tag: `vX.Y.Z`               |
| **Multi-module monorepo** | Multiple `go.mod` files linked by `go.work`      | One tag per module, same commit |
| **Application/binary**    | A CLI or server distributed as compiled binaries | One tag + GoReleaser artifacts  |

**Which shape is this?** Count the `go.mod` files: one → single-module. Multiple
linked by `go.work` → multi-module (load [./references/multi-module.md](./references/multi-module.md)).
Has a `cmd/` directory or produces binaries → application (load
[./references/goreleaser-and-ci.md](./references/goreleaser-and-ci.md)). Planning
a v2+ release → also load [./references/major-versions.md](./references/major-versions.md),
**but only for libraries**: a binary-only v2.0.0 is just a SemVer major bump, not a
module path migration.

For what goes wrong and how to recover, load
[./references/failure-modes.md](./references/failure-modes.md).

Table of Contents:

- [Relationship to other skills](#relationship-to-other-skills)
- [THE #1 RULE: Tags are immutable](#the-1-rule-tags-are-immutable)
- [Phase 0: Assess whether a release is needed](#phase-0-assess-whether-a-release-is-needed)
- [Phase 1: Determine the version bump](#phase-1-determine-the-version-bump)
- [Phase 2: Prepare the CHANGELOG](#phase-2-prepare-the-changelog)
- [Phase 3: Prepare go.mod files](#phase-3-prepare-gomod-files)
- [Phase 4: Pre-push verification](#phase-4-pre-push-verification)
- [Phase 5: Tag and push](#phase-5-tag-and-push)
- [Phase 6: Post-push verification](#phase-6-post-push-verification)
- [Phase 7: Create the GitHub Release](#phase-7-create-the-github-release)
- [Phase 8: Post-release cleanup](#phase-8-post-release-cleanup)
- [Phase 9: Recovery — when a release goes wrong](#phase-9-recovery--when-a-release-goes-wrong)
- [Quick reference](#quick-reference)
- [Reference files](#reference-files)

## Relationship to other skills

- **go-ecosystem-upgrade** — The demand side: bumping consumer dependencies AFTER
  a release. Use go-release to publish, then go-ecosystem-upgrade to propagate.
- **how-to-golang** — General Go project conventions, testing strategy, library
  choices that govern release readiness.

---

## THE #1 RULE: Tags are immutable

Before anything else, internalize this. It is the most expensive lesson in the Go
ecosystem, learned the hard way across dozens of real releases:

**Once `proxy.golang.org` fetches a tag and `sum.golang.org` records its checksum,
the version's content is cryptographically permanent. You cannot move it, delete
it, or override it. There is no force-push, no cache-invalidation API.**

This immutability is enforced at three layers:

1. **The proxy** (`proxy.golang.org`) caches the module `.zip` and serves it forever
2. **The checksum database** (`sum.golang.org`) records the content hash in a signed
   Merkle-tree transparency log that cannot be altered
3. **Every Go client** verifies downloads against that database — a mismatch produces
   a hard `SECURITY ERROR`

If you publish a broken release, the fix is **always** a new version number (patch
or minor), never a re-tag. See Phase 7 (Recovery) and
[./references/failure-modes.md](./references/failure-modes.md).

---

## Phase 0: Assess whether a release is needed

```bash
# Latest tags
git tag --sort=-v:refname | head -10

# Commits since last release
LAST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]' | head -1)
git log "${LAST_TAG}..HEAD" --oneline

# Count by type
echo "Features: $(git log "${LAST_TAG}..HEAD" --oneline | grep -ci 'feat')"
echo "Fixes:    $(git log "${LAST_TAG}..HEAD" --oneline | grep -ci 'fix')"
echo "Breaks:   $(git log "${LAST_TAG}..HEAD" --oneline | grep -ci 'breaking\|break')"
echo "Total:    $(git log "${LAST_TAG}..HEAD" --oneline | wc -l)"
```

Recommend a release when there are feature commits (`feat:`), breaking changes, or
significant fixes. If only docs/chore commits exist, tell the user it's not worth a
release yet.

---

## Phase 1: Determine the version bump

Go modules use Semantic Versioning: `vMAJOR.MINOR.PATCH`.

| Bump                 | When                                                                                                                                                                    | Example         |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| **PATCH** (`v1.2.4`) | Bug fixes, dependency bumps, toolchain/security fixes, additive non-breaking changes                                                                                    | v1.2.3 → v1.2.4 |
| **MINOR** (`v1.3.0`) | New features, new API additions, new exported symbols. In 0.x: also breaking changes                                                                                    | v1.2.4 → v1.3.0 |
| **MAJOR** (`v2.0.0`) | Post-1.0 breaking changes for libraries — requires `/v2` module path migration. For binary-only releases, it is just a SemVer major bump; no module path change needed. | v1.3.0 → v2.0.0 |

**0.x projects**: breaking changes are MINOR bumps (`v0.2.0` → `v0.3.0`). The project
is pre-stability; SemVer permits breaking changes between minor versions in 0.x.

**Pre-release versions** (`v1.0.0-rc.1`, `v1.0.0-alpha.2`, `v1.0.0-beta.1`): valid
SemVer, but excluded from `@latest` resolution. Consumers must request them
explicitly (`go get foo@v1.0.0-rc.1`). Use them for release candidates. Tag all
v0.x releases as `--prerelease` on GitHub.

State the version number to the user before proceeding. Example: "There are 3
features and 1 breaking change since v0.8.2 — this is a MINOR bump to v0.9.0."

---

## Phase 2: Prepare the CHANGELOG

If the project has a CHANGELOG (Keep a Changelog format is the Go ecosystem standard):

1. **Check for drift** — verify the last release tag has a matching CHANGELOG section.
   Ad-hoc releases often skip the CHANGELOG. Fix gaps before creating a new section.

```bash
grep '## \[' CHANGELOG.md | head -10
```

2. **Create the new version section** — move `[Unreleased]` entries into a new
   `[X.Y.Z] - YYYY-MM-DD` section using categories: Added, Changed, Removed, Fixed.

3. **Leave `[Unreleased]` empty** with placeholder categories so future work has a home:

```markdown
## [Unreleased]

### Added

- Nothing yet.

### Fixed

- Nothing yet.
```

4. **Curate release notes** — write a shorter, user-focused summary for the GitHub
   Release page. Highlight breaking changes first, then headline features.

---

## Phase 3: Prepare go.mod files

### 3.1 Clean up replace directives

`replace` directives pointing at local paths (`=> ../foo`) are **poison** in
published tags. They produce pseudo-versions
(`v0.0.0-00010101000000-000000000000`) that break every external consumer's `go get`.

```bash
grep '^replace' go.mod
# If any point at local paths, remove them before tagging
```

This is the single most common cause of broken library releases. If you need
`replace` for local development, use `go.work` instead — it overrides `go.mod`
locally without leaking into published tags.

### 3.2 Run go mod tidy

For a single-module project:

```bash
go mod tidy
go mod verify
```

For multi-module projects, `go mod tidy` on sub-modules **will fail** before the
new tag is pushed — the proxy can't resolve the unpublished version. See
[./references/multi-module.md](./references/multi-module.md) for the chicken-and-egg
solution.

### 3.3 Verify go.mod is clean

```bash
# No replace directives on local paths
grep '^replace' go.mod || echo "Clean — no replace directives"

# No pseudo-versions (00010101 sentinel = replace directive leak)
grep '00010101' go.mod && echo "ERROR: pseudo-version detected" || echo "Clean — no pseudo-versions"

# Module path is correct
head -1 go.mod
```

---

## Phase 4: Pre-push verification

Run all checks before tagging. A failed check here is cheap to fix; a failed check
after push may require a new version number (see the immutability rule).

**Use the helper script** to automate the gate checks:

```bash
./scripts/pre-release-check.sh        # standard checks
./scripts/pre-release-check.sh --race # include -race tests
./scripts/pre-release-check.sh --lint # also run golangci-lint
```

The script checks for local `replace` directives, pseudo-version placeholders, a
dirty git tree, and runs `go mod tidy`, `go mod verify`, `go build`, `go test`, and
`go vet`.

### 4.1 Build, vet, test, lint

```bash
go build ./...
go vet ./...
go test -race -count=1 ./...
golangci-lint run --timeout=10m ./...   # if configured
```

`-race` catches data races that basic tests miss. `-count=1` disables test result
caching, ensuring tests actually re-run.

### 4.2 Coverage check (if the project has a coverage gate)

```bash
go test -race -coverprofile=cover.out -covermode=atomic ./...
go tool cover -func=cover.out | tail -1
```

### 4.3 Git hygiene

```bash
git status   # should be clean — all changes committed
```

If the tree is dirty, commit all release prep (CHANGELOG, go.mod, go.sum) before
tagging. **The tag must point at a commit that includes ALL release changes.**
Tagging before committing the CHANGELOG or go.mod fix is the most common release
mistake.

### 4.4 CI is green on the exact commit being tagged

Local gates are not enough: CI runs environment-dependent checks (vendor-hash
drift, govulncheck against a fresh vuln DB, OS matrices) that local runs skip.
A red tag-CI run is permanent — the workflow file at the tag commit is frozen,
so the release shows a failed check forever. Never tag while the latest run on
the release branch is red or still in progress.

```bash
gh run list --limit=5   # latest run on the release branch must be success
```

If the failing job is govulncheck flagging stdlib CVEs that are fixed in a Go
patch release setup-go did not install, pin the toolchain explicitly:
`setup-go`'s version manifest lags `go.dev` by hours, so `go-version: "1.26.x"`
can resolve to yesterday's patch. Go's own toolchain switching downloads the
exact version regardless of what setup-go installed:

```yaml
env:
  GOTOOLCHAIN: go1.26.6   # step-, job-, or workflow-level
```

---

## Phase 5: Tag and push

### 5.1 Create the annotated tag

Annotated tags carry metadata (author, date, message). Always use `-a`, never
lightweight tags for releases.

```bash
VERSION="1.2.4"   # adjust to your version

git tag -a "v${VERSION}" -m "Release v${VERSION}

Key changes:
- feature1: description
- feature2: description
"
```

The tag message should summarize headline features, not list every commit. Look at
the CHANGELOG `[X.Y.Z]` section for the summary.

### 5.2 Verify the tag points at the right commit

```bash
# Confirm the tag is on HEAD (or your intended commit)
git tag --points-at HEAD

# Verify key symbols exist in the tagged tree (catches wrong-commit tagging)
git show "v${VERSION}:go.mod" | head -5
```

### 5.3 Push

```bash
git push origin master        # or main
git push origin "v${VERSION}"
```

The Go module proxy discovers new versions from git tags automatically. Wait 2-10
minutes for `proxy.golang.org` and `sum.golang.org` to propagate.

If `sum.golang.org` returns 500 or 404, it's propagation delay — not an error. Wait
a few minutes and retry. The checksum database needs time to index the new version.

---

## Phase 6: Post-push verification

### 6.1 Verify the module proxy has indexed the version

```bash
# Check the proxy serves the version
go list -m -versions "$(head -1 go.mod | cut -d' ' -f2)"

# Or query the proxy directly
MODULE_PATH=$(head -1 go.mod | cut -d' ' -f2)
# Use the fetch tool (NOT curl — it's banned in Crush):
# https://proxy.golang.org/${MODULE_PATH}/@v/v${VERSION}.info
```

### 6.2 Verify go get works in a clean directory

This is the definitive test that the release works for consumers.

```bash
MODULE_PATH=$(head -1 go.mod | cut -d' ' -f2)

trash /tmp/release-verify 2>/dev/null; mkdir -p /tmp/release-verify && cd /tmp/release-verify
go mod init test
go get "${MODULE_PATH}@v${VERSION}"
```

If `go get` fails with `unknown revision`, the tag hasn't propagated yet — wait and
retry. If it fails with `checksum mismatch`, something is seriously wrong — see
[./references/failure-modes.md](./references/failure-modes.md).

### 6.3 Trigger pkg.go.dev documentation

Visit these URLs (or use the `fetch` tool) to trigger documentation generation:

```
https://pkg.go.dev/fetch/${MODULE_PATH}@v${VERSION}
```

pkg.go.dev generates docs on-demand. First fetch takes seconds to minutes once the
proxy has indexed the version.

### 6.4 Verify CI is green

```bash
gh run list --limit=3
```

---

## Phase 7: Create the GitHub Release

### Option A: gh CLI (simple, no binary artifacts)

```bash
gh release create "v${VERSION}" \
  --title "v${VERSION}" \
  --notes-file /tmp/release-notes.md \
  --latest
```

Add `--prerelease` for v0.x releases or release candidates.

### Option B: GoReleaser (builds cross-platform binaries + checksums)

Load [./references/goreleaser-and-ci.md](./references/goreleaser-and-ci.md) for the
full GoReleaser configuration guide. The minimal invocation:

```bash
GITHUB_TOKEN="$(gh auth token)" \
  goreleaser release --clean
```

For multi-module monorepos, you **must** set `GORELEASER_CURRENT_TAG` — when
multiple tags share one commit, `git describe` picks the alphabetically-last tag.
See [./references/multi-module.md](./references/multi-module.md).

---

## Phase 8: Post-release cleanup

### 8.1 CHANGELOG

Ensure `[Unreleased]` has empty placeholders (see Phase 2.3).

### 8.2 Documentation sync

Check whether these need updating:

- `CHANGELOG.md` — already done in Phase 2
- `README.md` — version badge, installation instructions
- `AGENTS.md` — source file inventory, test counts, coverage numbers
- Migration guides — breaking change documentation

### 8.3 Consumer propagation

After a successful release, consumers need to bump their dependencies. Use the
**go-ecosystem-upgrade** skill for the consumer-side bump process.

---

## Phase 9: Recovery — when a release goes wrong

### The release is broken (wrong commit, missing files, bug)

**NEVER delete and re-create the tag.** See the immutability rule above. Instead:

1. Cut a new version (`v1.2.4` → `v1.2.5` for fixes, `v1.3.0` for significant)
2. Add a `retract` directive for the broken version in the new release's go.mod:

```go
// go.mod
retract v1.2.4 // Wrong commit published — use v1.2.5
```

Or via command: `go mod edit -retract=v1.2.4`

3. The `retract` directive causes `go get` to skip the broken version by default
   (explicit `@v1.2.4` still works but shows a warning). It does NOT delete the
   version from the proxy — that's permanent. It's advisory deprecation.

### Checksum mismatch in consumers

This means a tag was moved after the proxy cached it. The proxy serves old content
forever. The fix is on the publisher side: cut a new version. As a consumer, you
can work around it temporarily with `GONOSUMDB` but should report it upstream.

### go get fails with "unknown revision"

The tag hasn't propagated to the proxy yet (2-10 min delay), or the tag format is
wrong (must be `vX.Y.Z` with the `v` prefix and exactly three numeric components).

For the full failure-mode catalog and recovery procedures, load
[./references/failure-modes.md](./references/failure-modes.md).

---

## Quick reference

The condensed checklist and common-gotchas table live in
[./references/quick-reference.md](./references/quick-reference.md). Use it as a
pre-flight checklist before cutting any release.

---

## Reference files

- [./references/multi-module.md](./references/multi-module.md) — Multi-module
  monorepo releases: the chicken-and-egg version-bump problem, `go.work` interplay,
  three-tag-at-one-commit mechanics, `GOWORK=off` verification strategy.
- [./references/major-versions.md](./references/major-versions.md) — Major version
  v2+ module-path migration: changing `module` directives, rewriting imports,
  major-version branches, avoiding `+incompatible`.
- [./references/goreleaser-and-ci.md](./references/goreleaser-and-ci.md) — GoReleaser
  configuration (`.goreleaser.yml`), GitHub Actions release workflows, private
  dependency authentication, SBOM generation, cosign signing, SLSA provenance.
- [./references/failure-modes.md](./references/failure-modes.md) — Comprehensive
  failure-mode catalog with root-cause analysis and recovery procedures for every
  known Go release failure pattern.
