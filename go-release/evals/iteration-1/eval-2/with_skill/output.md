Push these two annotated tags, both pointing at the **same commit**:

```text
v1.3.0
cli/v1.3.0
```

The order of tag creation does not matter for the Go proxy; push them together. If you use GoReleaser, set `GORELEASER_CURRENT_TAG=v1.3.0` so it does not pick `cli/v1.3.0` alphabetically.

Step-by-step:

```bash
VERSION="1.3.0"

# 1. If cli/go.mod requires github.com/myorg/mono, bump it now
#    (do NOT run 'go mod tidy' in cli/ before tags are pushed)
(cd cli && go mod edit -require="github.com/myorg/mono@v${VERSION}")

# 2. Verify no local replace directives leaked into published modules
grep '^replace' go.mod cli/go.mod   # must return nothing

# 3. Commit the release prep
git add -A
git commit -m "chore(release): prepare v${VERSION}"

# 4. Create both annotated tags on the same commit
COMMIT=$(git rev-parse HEAD)
git tag -a "v${VERSION}"      -m "Release v${VERSION}"      "${COMMIT}"
git tag -a "cli/v${VERSION}"  -m "Release cli/v${VERSION}"  "${COMMIT}"

# 5. Verify both tags point at HEAD
git tag --points-at HEAD
# expected: v1.3.0  cli/v1.3.0

# 6. Push
git push origin main
git push origin "v${VERSION}" "cli/v${VERSION}"
```

Wait 2–10 minutes, then fix the sub-module checksums and verify:

```bash
# Update cli/go.sum now that the tags exist on the remote
cd cli && GOWORK=off go mod tidy -e && cd ..

git add cli/go.sum
git commit -m "chore(release): update go.sum for v${VERSION}"
git push origin main

# Verify consumers can install both modules
mkdir -p /tmp/verify-mono && cd /tmp/verify-mono && go mod init test
go get github.com/myorg/mono@v1.3.0
go get github.com/myorg/mono/cli@cli/v1.3.0
```
