**Release shape: single-module library** (one `go.mod`, consumed via `go get`, one tag). Bug fix since v1.2.0 → **PATCH bump: v1.2.0 → v1.2.1**.

> **THE #1 RULE: tags are immutable.** Once `proxy.golang.org` caches the tag and `sum.golang.org` records its checksum, the version is permanent. No re-tagging, ever. If v1.2.1 turns out broken, the fix is v1.2.2 + a `retract` directive.

## Phase 0 — Confirm what's in the release

```bash
LAST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]' | head -1)   # → v1.2.0
git log "${LAST_TAG}..HEAD" --oneline
echo "Fixes: $(git log "${LAST_TAG}..HEAD" --oneline | grep -ci 'fix')"
```

## Phase 1 — Version

Bug fix only → **v1.2.1** (PATCH).

## Phase 2 — CHANGELOG

```bash
grep '## \[' CHANGELOG.md | head -10   # check v1.2.0 section exists (fix drift first)
```

- Move `[Unreleased]` entries into `## [1.2.1] - 2026-08-21` under `### Fixed`.
- Leave `[Unreleased]` empty with placeholder categories.

## Phase 3 — Prepare go.mod

```bash
grep '^replace' go.mod || echo "Clean — no replace directives"
grep '00010101' go.mod && echo "ERROR: pseudo-version detected" || echo "Clean"
head -1 go.mod   # must be: module github.com/myorg/myrepo
go mod tidy
go mod verify
```

## Phase 4 — Pre-push verification (cheap to fix now, permanent after push)

```bash
go build ./...
go vet ./...
go test -race -count=1 ./...
golangci-lint run --timeout=10m ./...   # if configured
git status                              # must be clean — commit CHANGELOG etc. first
gh run list --limit=5                   # CI green on the exact commit being tagged
```

**The tag must point at a commit that includes ALL release changes** (CHANGELOG, go.mod, go.sum).

## Phase 5 — Tag and push

```bash
VERSION="1.2.1"

git tag -a "v${VERSION}" -m "Release v${VERSION}

Key changes:
- Fix: <one-line summary of the bug fix>
"

# Verify before pushing
git tag --points-at HEAD
git show "v${VERSION}:go.mod" | head -5

git push origin master
git push origin "v${VERSION}"
```

Always annotated (`-a`), never lightweight. Proxy propagation takes 2–10 minutes.

## Phase 6 — Post-push verification

```bash
go list -m -versions github.com/myorg/myrepo

# Definitive consumer test — clean directory:
trash /tmp/release-verify 2>/dev/null; mkdir -p /tmp/release-verify && cd /tmp/release-verify
go mod init test
go get github.com/myorg/myrepo@v1.2.1
```

- `unknown revision` → wait a few minutes, retry.
- `checksum mismatch` → serious; cut a new version, never re-tag.

Trigger docs: `https://pkg.go.dev/fetch/github.com/myorg/myrepo@v1.2.1`, then verify CI: `gh run list --limit=3`.

## Phase 7 — GitHub Release

```bash
gh release create "v${VERSION}" \
  --title "v${VERSION}" \
  --notes-file /tmp/release-notes.md \
  --latest
```

## Phase 8 — Cleanup

- `[Unreleased]` in CHANGELOG has empty placeholders.
- Check `README.md` badge / install instructions.
- Consumers bump via the go-ecosystem-upgrade process.

**If v1.2.1 ships broken:** do NOT delete/re-tag. Cut v1.2.2 and add `go mod edit -retract=v1.2.1` in that release's go.mod.
