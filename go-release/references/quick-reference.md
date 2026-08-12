# Quick Reference

## Checklist

```
[ ] Phase 0: Assess — enough unreleased work to justify a release?
[ ] Phase 1: Determine version (PATCH / MINOR / MAJOR)
[ ] Phase 2: CHANGELOG — split [Unreleased], create [X.Y.Z], curate notes
[ ] Phase 3: go.mod clean — no replace directives, no pseudo-versions
[ ] Phase 3: go mod tidy + go mod verify pass
[ ] Phase 4: go vet ./... passes
[ ] Phase 4: go test -race -count=1 ./... passes
[ ] Phase 4: golangci-lint passes (if configured)
[ ] Phase 4: git status clean (all release prep committed)
[ ] Phase 5: Create annotated tag (-a) at the right commit
[ ] Phase 5: Verify tag points at commit with all expected changes
[ ] Phase 5: Push master + tag
[ ] Phase 6: Proxy indexed the version (go list -m -versions)
[ ] Phase 6: go get works in clean /tmp directory
[ ] Phase 6: pkg.go.dev docs triggered
[ ] Phase 6: CI green
[ ] Phase 7: GitHub Release created (gh CLI or GoReleaser)
[ ] Phase 8: CHANGELOG [Unreleased] has empty placeholders
[ ] Phase 8: Docs updated (README, AGENTS.md if needed)
```

## Gotchas

| Issue                                                        | Cause                                                                  | Fix                                                                                                 |
| ------------------------------------------------------------ | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Consumer `go get` fails with `unknown revision 000000000000` | `replace` directive in published go.mod                                | Remove `replace` before tagging. Use `go.work` for local dev.                                       |
| Consumer gets `SECURITY ERROR: checksum mismatch`            | Tag was moved/deleted after proxy cached it                            | Cut a new version. NEVER re-tag. Add `retract` directive.                                           |
| `go mod tidy` strips all require blocks                      | Tags not pushed yet; proxy can't resolve unpublished version           | Don't run tidy on sub-modules before push. See [./multi-module.md](./multi-module.md).              |
| `sum.golang.org` returns 500                                 | Checksum DB propagation delay                                          | Wait 2-10 minutes. Retry. Not an error.                                                             |
| goreleaser picks wrong tag                                   | Multiple tags at same commit; `git describe` picks alphabetically-last | Set `GORELEASER_CURRENT_TAG=vX.Y.Z`. See [./goreleaser-and-ci.md](./goreleaser-and-ci.md).          |
| Pre-release versions not selected by `@latest`               | SemVer pre-release semantics: `v1.0.0-rc.1` excluded from `@latest`    | Consumers must request explicitly: `go get foo@v1.0.0-rc.1`                                         |
| `+incompatible` suffix on versions                           | v2+ module without `/vN` path suffix                                   | Migrate module path. See [./major-versions.md](./major-versions.md).                                |
| Private dep fails with "could not read Username"             | Module proxy can't access private repos                                | Set `GOPRIVATE`, configure git URL rewriting. See [./goreleaser-and-ci.md](./goreleaser-and-ci.md). |
| Hook fails with "command not found" or shell errors          | GoReleaser OSS invokes `exec.CommandContext` directly, not a shell     | Wrap shell features in `sh -c "..."`. See [./goreleaser-and-ci.md](./goreleaser-and-ci.md).         |
