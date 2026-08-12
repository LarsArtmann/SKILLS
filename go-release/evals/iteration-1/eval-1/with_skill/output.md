Releasing `v1.2.1` of `github.com/myorg/myrepo`. This is a single-module Go library and the change is a bug fix, so the bump is **PATCH**: `v1.2.0 → v1.2.1`.

Run these commands from the repo root on `master`.

**1. Verify what is unreleased**

```bash
LAST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]' | head -1)
echo "Last tag: ${LAST_TAG}"
git log "${LAST_TAG}..HEAD" --oneline
```

Confirm the bug-fix commit is present.

**2. Update CHANGELOG**

```bash
grep '## \[' CHANGELOG.md | head -5
```

Move entries from `[Unreleased]` into a new `## [1.2.1] - YYYY-MM-DD` section with a `### Fixed` category. Leave `[Unreleased]` empty with placeholder categories.

**3. Clean `go.mod`**

```bash
grep '^replace' go.mod || echo "Clean — no replace directives"
grep '00010101' go.mod && echo "ERROR: pseudo-version detected" || echo "Clean — no pseudo-versions"
head -1 go.mod
```

Run:

```bash
go mod tidy
go mod verify
```

**4. Pre-push verification**

```bash
go build ./...
go vet ./...
go test -race -count=1 ./...
```

If the project uses `golangci-lint`:

```bash
golangci-lint run --timeout=10m ./...
```

Ensure the tree is clean:

```bash
git status
```

Commit the CHANGELOG and any `go.mod`/`go.sum` changes:

```bash
git add CHANGELOG.md go.mod go.sum
git commit -m "chore(release): prepare v1.2.1"
```

**5. Tag and push**

```bash
VERSION="1.2.1"

git tag -a "v${VERSION}" -m "Release v${VERSION}

### Fixed
- <brief bug-fix description>
"
```

Verify the tag is on HEAD and points at the correct tree:

```bash
git tag --points-at HEAD
git show "v${VERSION}:go.mod" | head -5
```

Push:

```bash
git push origin master
git push origin "v${VERSION}"
```

Wait 2–10 minutes for `proxy.golang.org` / `sum.golang.org` propagation.

**6. Post-push verification**

Check the proxy sees the version:

```bash
MODULE_PATH=$(head -1 go.mod | cut -d' ' -f2)
go list -m -versions "${MODULE_PATH}"
```

Test `go get` in a clean directory:

```bash
rm -rf /tmp/release-verify
mkdir -p /tmp/release-verify && cd /tmp/release-verify
go mod init test
go get "${MODULE_PATH}@v${VERSION}"
```

Trigger pkg.go.dev docs:

```bash
echo "Visit: https://pkg.go.dev/fetch/${MODULE_PATH}@v${VERSION}"
```

Verify CI is green:

```bash
gh run list --limit=3
```

**7. Create the GitHub Release**

Write release notes to a file, then:

```bash
gh release create "v${VERSION}" \
  --title "v${VERSION}" \
  --notes-file /tmp/release-notes.md \
  --latest
```

**8. Post-release cleanup**

Ensure `CHANGELOG.md` `[Unreleased]` has empty `### Added` / `### Fixed` placeholders. Update `README.md` version badge or installation notes if applicable.

---

If anything is wrong after push, **never re-tag**. Cut `v1.2.2`, add a `retract v1.2.1` directive in `go.mod`, and push the new tag.
