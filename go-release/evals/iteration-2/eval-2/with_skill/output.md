Two tags, both annotated, both on the same commit — the root module's plain tag first, then the sub-module's directory-prefixed tag:

| Module | Import path | Tag |
|---|---|---|
| Root | `github.com/myorg/mono` | `v1.3.0` |
| CLI | `github.com/myorg/mono/cli` | `cli/v1.3.0` |

## Steps

1. **Before tagging** — in `cli/go.mod`, set the sibling require to the version being released (chicken-and-egg: `go mod tidy` can't resolve it yet and will corrupt the file):

   ```bash
   (cd cli && go mod edit -require=github.com/myorg/mono@v1.3.0)
   grep -E '^replace' go.mod cli/go.mod   # MUST return nothing
   ```

   Do **not** run `go mod tidy` on `cli/` until after tags are pushed.

2. **Verify in workspace mode** (`go.work` resolves the unpublished version locally):

   ```bash
   go vet ./... && go test -race -count=1 ./...
   go vet ./cli/... && go test -race -count=1 ./cli/...
   ```

3. **Commit the release prep** (CHANGELOG + `cli/go.mod`).

4. **Create one annotated tag per module, same commit** — root tag first:

   ```bash
   COMMIT=$(git rev-parse HEAD)
   git tag -a v1.3.0     -m "Release v1.3.0"     "$COMMIT"
   git tag -a cli/v1.3.0 -m "Release cli/v1.3.0" "$COMMIT"
   git tag --points-at HEAD   # both tags listed
   ```

5. **Push — root module's tag first, then the sub-module's** (the proxy must be able to resolve `github.com/myorg/mono@v1.3.0` when it later resolves `cli/v1.3.0`'s `go.mod`):

   ```bash
   git push origin master
   git push origin v1.3.0
   git push origin cli/v1.3.0
   ```

6. **After push (2–10 min for proxy propagation)** — fix checksums and verify standalone:

   ```bash
   (cd cli && GOWORK=off go mod tidy -e)
   grep 'mono' cli/go.mod                 # require must still show v1.3.0
   (cd cli && GOWORK=off go test -count=1 ./...)

   # Clean-room consumer checks
   go get github.com/myorg/mono@v1.3.0
   go get github.com/myorg/mono/cli@cli/v1.3.0
   ```

   Commit the regenerated `cli/go.sum` and push.

7. **If you use GoReleaser** for the CLI: with two tags on one commit, `git describe` picks the wrong one — set `GORELEASER_CURRENT_TAG=cli/v1.3.0` explicitly.

Remember: tags are immutable once the proxy fetches them. If anything is wrong, the fix is a new version number, never a re-tag.
