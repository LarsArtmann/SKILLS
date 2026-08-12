# Go Release Failure Modes

The comprehensive catalog of what goes wrong during Go releases, why, and how to
recover. Every entry traces to a real incident.

Table of Contents:

- [Tag immutability failures](#tag-immutability-failures)
- [go.mod contamination](#gomod-contamination)
- [Wrong commit / missing changes](#wrong-commit--missing-changes)
- [Multi-module chicken-and-egg](#multi-module-chicken-and-egg)
- [Proxy and checksum issues](#proxy-and-checksum-issues)
- [Private dependency failures](#private-dependency-failures)
- [GoReleaser failures](#goreleaser-failures)
- [Nix-specific failures](#nix-specific-failures)
- [Recovery procedures](#recovery-procedures)

---

## Tag immutability failures

### R1: Deleted and re-created tag with the same version

**Symptom**: Consumers get `SECURITY ERROR: checksum mismatch` after fetching a
version that was "fixed" by re-tagging.

**Root cause**: The Go module proxy (`proxy.golang.org`) caches module content
immutably. Once `sum.golang.org` records a version's hash in its Merkle-tree
transparency log, the hash is permanent. Re-creating a tag with different content
produces a mismatch that every Go client rejects as a supply-chain attack.

**This has no fix.** The poisoned entry persists in the proxy and checksum database
indefinitely. The only path forward:

1. Cut a new version number (`v1.2.4` → `v1.2.5`)
2. Add a `retract` directive for the broken version in the new go.mod
3. Notify consumers to update

**Prevention**: Internalize the rule. Tags are write-once. A bad tag is permanent.
Never delete and re-create.

### R2: Tag moved to a different commit

**Symptom**: GitHub shows the tag at commit B, but `go get` serves content from
commit A (the original).

**Root cause**: Same as R1. The proxy serves the originally-cached zip forever.
Moving the tag in git has no effect on what the proxy serves.

**Fix**: Same as R1 — cut a new version, retract the old one.

---

## go.mod contamination

### R3: replace directive leaked into published tag

**Symptom**: Consumers get `unknown revision 000000000000` or
`v0.0.0-00010101000000-000000000000` pseudo-version when running `go get`.

**Root cause**: A `replace` directive pointing at a local path (`=> ../foo`) in
go.mod was included in the tagged commit. The Go module system interprets local
replace directives as zero-version pseudo-versions, which don't resolve on the proxy.

**Fix**:

1. Remove the `replace` directive from go.mod
2. For local development, use `go.work` instead (it doesn't leak into tags)
3. Cut a new version

**Prevention**: Always check `grep '^replace' go.mod` before tagging. Use go.work
for local development, never replace directives in published modules.

### R4: Pseudo-version in published go.mod

**Symptom**: Consumers see `v0.0.0-20240101000000-abcdef123456` for a dependency in
the published go.mod, making the module fragile and non-reproducible.

**Root cause**: The go.mod was tagged while a dependency was pinned to a commit hash
instead of a tagged release.

**Fix**: Ensure all dependencies are at tagged releases before tagging. Run
`go mod tidy` to resolve to proper versions.

**Detection**:

```bash
grep '00010101\|000000000000' go.mod   # sentinel values for pseudo-versions
```

### R5: Stale go.sum after version bump

**Symptom**: `go mod verify` fails for consumers. Build fails with checksum errors.

**Root cause**: go.sum was not updated after go.mod version bumps. For single-module
releases, `go mod tidy` before tagging fixes this. For multi-module releases, see R6.

**Fix**: Run `go mod tidy` before tagging (single-module). For multi-module, see
[./multi-module.md](./multi-module.md) for the post-push checksum fix procedure.

---

## Wrong commit / missing changes

### R6: Tag cut from a commit before a key change

**Symptom**: Consumers compile against the published tag but find the API surface
doesn't match what they migrated to. Missing symbols, renamed functions, removed types.

**Root cause**: The tag was created from a parent commit that predates a key change
(rename, removal, fix). The published tag contains the OLD API surface.

**Detection**: Before tagging, verify the key changes are in the tagged tree:

```bash
# Verify the commit with your change is an ancestor of HEAD
git merge-base --is-ancestor <key-commit> HEAD && echo "OK" || echo "MISSING"

# Verify the symbol exists in the tagged tree
git show HEAD:path/to/file.go | grep 'func NewSymbolName'
```

**Fix**: Cut a new version from the correct commit. Can't re-tag (immutability).

**Prevention**: Always tag from HEAD after confirming HEAD has what you need. Never
tag from an arbitrary commit hash unless you've verified its contents.

---

## Multi-module chicken-and-egg

### R7: go mod tidy strips all require blocks

**Symptom**: After running `go mod tidy` on a sub-module before pushing tags, all
require blocks for sibling modules disappear. The published go.mod has no dependencies.

**Root cause**: `go mod tidy` tries to resolve the sibling module version from the
proxy. The version doesn't exist yet (tag not pushed). Tidy interprets the unresolvable
dependency as unnecessary and strips it.

**Fix**: Don't run `go mod tidy` on sub-modules before pushing tags. Bump version
strings manually with `sed`. See [./multi-module.md](./multi-module.md) for the
complete procedure.

**Prevention**: The multi-module release process in
[./multi-module.md](./multi-module.md) exists specifically to avoid this. Follow it.

### R8: Sub-module go.sum stale after tag push

**Symptom**: Standalone builds (`GOWORK=off`) fail with checksum errors for sibling
modules.

**Root cause**: go.sum files were not updated after the version bump and tag push.
This is expected in the multi-module workflow — go.sum is updated post-push.

**Fix**: After pushing tags, run `go mod tidy -e` on each sub-module:

```bash
cd viz && GOWORK=off go mod tidy -e && cd ..
cd live && GOWORK=off go mod tidy -e && cd ..
```

The `-e` flag is required when dependencies have broken `replace` directives in their
published go.mod (harmless — `-e` continues past them).

---

## Proxy and checksum issues

### R9: sum.golang.org returns 500 or 404

**Symptom**: `go get` or `go mod tidy` fails with a 500 or 404 from `sum.golang.org`
shortly after pushing a tag.

**Root cause**: The checksum database has a propagation window. After pushing a tag,
the proxy needs time to fetch and index the new version. During this window (typically
2-10 minutes), the checksum may not be available.

**Fix**: Wait and retry. This is not an error — it's expected propagation delay. For
testing during the propagation window, use `GOSUMDB=off` temporarily.

### R10: module lookup disabled by GOPROXY=off

**Symptom**: Build fails with `module lookup disabled by GOPROXY=off` in a sandboxed
or offline environment.

**Root cause**: The build environment has `GOPROXY=off` (common in Nix sandboxes and
CI) and can't reach the module proxy to resolve dependencies.

**Fix**: This is environment-specific, not a release issue. Ensure the build
environment has either network access or a vendored dependency set. For Nix, the
`vendorHash` + vendored deps should be sufficient without `GOPROXY`.

---

## Private dependency failures

### R11: could not read Username for 'https://github.com'

**Symptom**: CI build or GoReleaser fails with `could not read Username for
'https://github.com'` when resolving private dependencies.

**Root cause**: Private GitHub repos are invisible to the Go module proxy. The proxy
returns 404, and git tries to prompt for credentials interactively (which fails in CI).

**Fix**: Configure three layers:

1. `GOPRIVATE=github.com/myorg/*` — skip proxy for private repos
2. `git config --global url."https://x-access-token:${GH_PAT}@github.com/".insteadOf "https://github.com/"` — inject token
3. `GH_PAT` secret in GitHub Actions — a PAT with read access to private repos

See [./goreleaser-and-ci.md#private-dependency-authentication](./goreleaser-and-ci.md#private-dependency-authentication).

### R12: GH_PAT secret missing or expired

**Symptom**: Releases silently produce no artifacts, or CI fails with auth errors.

**Root cause**: The `GH_PAT` secret was never set, or the PAT expired (GitHub PATs
have expiration dates by default).

**Fix**:

```bash
gh secret list                              # check if GH_PAT exists
gh secret set GH_PAT                        # create new one
```

Generate a PAT at https://github.com/settings/tokens with `repo` scope.

---

## GoReleaser failures

### R13: GoReleaser picks wrong tag (multi-module)

**Symptom**: GoReleaser builds from the wrong module or uses the wrong tag name.

**Root cause**: When multiple tags point at the same commit, GoReleaser uses `git
describe` which returns the alphabetically-last tag (e.g., `viz/v1.2.4` instead of
`v1.2.4`).

**Fix**: Always set `GORELEASER_CURRENT_TAG`:

```bash
GORELEASER_CURRENT_TAG="v${VERSION}" goreleaser release --clean
```

### R14: GoReleaser dirty state

**Symptom**: `release failed: git is currently in a dirty state`

**Root cause**: Working tree has uncommitted changes. GoReleaser requires a clean
state to ensure reproducible builds.

**Fix**: Commit all changes before running GoReleaser. If an auto-commit daemon is
running, wait for it. Alternatively, use `gh release create` for a quick release
without binary artifacts.

### R15: Pre-release versions not selected by @latest

**Symptom**: `go get foo@latest` doesn't select your new `v1.0.0-rc.1`.

**Root cause**: This is correct SemVer behavior. Pre-release versions are excluded
from `@latest` resolution. Consumers must request them explicitly.

**Fix**: This is not a bug. For release candidates, document that consumers should use
`go get foo@v1.0.0-rc.1`. For stable releases, use plain semver (`v1.0.0`).

---

## Nix-specific failures

### R16: vendorHash mismatch

**Symptom**: `nix build .#default` fails with a hash mismatch.

**Root cause**: The `vendorHash` in `flake.nix` is stale — dependencies changed but
the hash wasn't updated.

**Fix**:

If the project provides a Nix app for this, use it (the package-manager-native way):

```bash
nix run .#fix-vendor-hash
```

Otherwise, use `lib.fakeHash` to let the Nix evaluator tell you the correct hash:

```nix
# In flake.nix, temporarily set:
vendorHash = lib.fakeHash;
```

```bash
# Build; the error prints the expected hash next to "got:"
nix build .#default --no-link 2>&1 | grep "got:"
```

Copy the hash from the error into `flake.nix`, replacing `lib.fakeHash`. As a
fallback if you cannot edit the file by hand, you can script the update:

```bash
CORRECT_HASH=$(nix build .#default --no-link 2>&1 | grep "got:" | sed 's/.*got: *//; s/ *$//')
sed -i "s|vendorHash = \".*\"|vendorHash = \"$CORRECT_HASH\"|" flake.nix

# Verify
nix build .#default --no-link
```

**Important**: The vendorHash can differ between a clean tree and a dirty tree. Always
commit all changes before computing the hash.

### R17: preBuild = "go mod tidy" breaks Nix sandbox

**Symptom**: Nix build fails with `module lookup disabled by GOPROXY=off`.

**Root cause**: Adding `preBuild = "go mod tidy"` tries to resolve transitive test
deps that `go mod vendor` correctly excluded. In the Nix sandbox (no network), this
fails.

**Fix**: Never add `preBuild = "go mod tidy"` to `extraBuildAttrs`. The vendorHash +
vendored deps should be sufficient without re-running `go mod tidy`.

---

## Recovery procedures

### Procedure A: Published version is broken

**When**: A released version has a bug, wrong commit, or missing files.

**Steps**:

1. **Do NOT delete or move the tag.** The proxy has cached it permanently.

2. Fix the issue on a new commit.

3. Cut a new version:
   - Patch fix → `v1.2.5` (if `v1.2.4` was broken)
   - Significant fix → `v1.3.0`

4. In the new version's go.mod, add a retract directive:
   ```go
   retract v1.2.4 // Wrong commit published — use v1.2.5
   ```
   Or: `go mod edit -retract=v1.2.4`

5. Tag, push, and verify the new version (follow the standard release process).

6. Update the CHANGELOG to document the retraction.

7. Notify consumers.

### Procedure B: go get fails after a seemingly correct release

**When**: Tag is pushed, proxy should have indexed it, but `go get` fails.

**Diagnostic steps**:

1. Check the tag exists on the remote: `git ls-remote --tags origin | grep vX.Y.Z`
2. Check the proxy has indexed it: `go list -m -versions <module-path>`
3. Check for replace directives: `git show vX.Y.Z:go.mod | grep '^replace'`
4. Check for pseudo-versions: `git show vX.Y.Z:go.mod | grep '00010101'`
5. Try with GOSUMDB=off: `GOSUMDB=off go get <module>@vX.Y.Z`
6. Check proxy directly (use the `fetch` tool):
   `https://proxy.golang.org/<module>/@v/vX.Y.Z.info`

**Common causes** (in order of frequency):

- Replace directive in go.mod (R3)
- Proxy propagation delay (R9) — wait 10 minutes
- Wrong commit tagged (R6)
- Private dependency that consumers can't access (R11)

### Procedure C: Checksum mismatch as a consumer

**When**: A consumer reports `SECURITY ERROR: checksum mismatch` for a published
module.

**This means the publisher moved or re-created a tag.** The proxy serves old content,
but the consumer's go.sum (or a different proxy path) is serving new content.

**Consumer workaround** (temporary, not a real fix):

```bash
GONOSUMDB=* go get <module>@vX.Y.Z   # skip checksum verification
```

**Real fix**: The publisher must cut a new version. Report the issue upstream.

### Procedure D: Multi-module release left go.sum stale

**When**: Multi-module release completed but standalone builds fail with checksum
errors for sibling modules.

**Steps**:

1. Tags are already pushed. Run `go mod tidy -e` on each sub-module:
   ```bash
   cd viz && GOWORK=off go mod tidy -e && cd ..
   cd live && GOWORK=off go mod tidy -e && cd ..
   ```

2. Verify require blocks are intact (tidy should NOT have stripped them):
   ```bash
   grep 'myrepo' viz/go.mod live/go.mod
   ```

3. If require blocks were stripped, restore from git and manually fix.

4. Commit the go.sum updates:
   ```bash
   git add viz/go.sum live/go.sum
   git commit -m "chore(release): update go.sum checksums for vX.Y.Z"
   git push origin master
   ```

5. Do NOT re-tag. The tags point at the release commit. The go.sum update is a
   follow-up commit — consumers running `go mod tidy` will resolve correct checksums
   from the proxy regardless.
