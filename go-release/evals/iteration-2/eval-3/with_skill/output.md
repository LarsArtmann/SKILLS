# v2.0.0 Release — `github.com/myorg/tool` (GoReleaser)

**Release shape:** Application/binary (CLI with `cmd/`, distributed as compiled binaries). A binary-only v2.0.0 is a plain SemVer major bump — **no `/v2` module path migration needed**.

## Why GoReleaser keeps picking the wrong tag

When multiple tags point at the same commit, GoReleaser falls back to `git describe`, which returns the **alphabetically-last** tag — so it builds/releases the wrong one. The fix is to always set `GORELEASER_CURRENT_TAG` explicitly. Since the bad release already shipped, do **not** delete/re-create tags (tags are write-once); instead, ship the corrected v2.0.0.

## Checklist

**Phase 0–1: Assess & version**
- [ ] `git tag --sort=-v:refname | head -10`; review `git log <last-tag>..HEAD --oneline` — breaking changes → **v2.0.0** confirmed.

**Phase 2: CHANGELOG**
- [ ] Move `[Unreleased]` into `## [2.0.0] - YYYY-MM-DD` (Added/Changed/Removed/Fixed), breaking changes first; leave `[Unreleased]` empty.

**Phase 3: go.mod**
- [ ] `grep '^replace' go.mod` — no local-path replaces; `go mod tidy && go mod verify`. (Module path stays `github.com/myorg/tool` — no `/v2`.)

**Phase 4: Pre-push verification**
- [ ] `go build ./... && go vet ./... && go test -race -count=1 ./...`
- [ ] `git status` clean — the tag must point at a commit containing all release changes.
- [ ] `gh run list --limit=5` — CI green on the exact commit to be tagged.

**Phase 5: Tag and push**
- [ ] One tag only, annotated:
  ```bash
  git tag -a v2.0.0 -m "Release v2.0.0

  Key changes:
  - breaking: ...
  "
  git tag --points-at HEAD   # verify v2.0.0 is the tag on your commit
  git push origin main && git push origin v2.0.0
  ```

**Phase 6–7: Release with GoReleaser — the fix**
- [ ] Set `GORELEASER_CURRENT_TAG` so the shared-commit ambiguity is eliminated:
  ```bash
  GITHUB_TOKEN="$(gh auth token)" \
  GORELEASER_CURRENT_TAG="v2.0.0" \
    goreleaser release --clean
  ```
- [ ] In CI (tag-triggered), set it from the triggering ref (see workflow below). Never rely on `git describe` when a commit carries more than one tag.
- [ ] Validate the config first without publishing: `goreleaser release --clean --snapshot --skip=publish`

**Cleanup of the botched release**
- [ ] Delete only the mistaken **GitHub Release** objects if they carry wrong-tag artifacts (`gh release delete <wrong-tag>`), never re-create a git tag. v2.0.0 is the permanent fix going forward.

**Phase 8: Post-release**
- [ ] Update README install instructions/badge; empty `[Unreleased]` placeholders; `gh run list --limit=3` green.

## `.goreleaser.yml`

```yaml
version: 2 # required by GoReleaser v2

before:
  hooks:
    - go mod tidy

builds:
  - env:
      - CGO_ENABLED=0 # critical for cross-compilation
    goos:
      - linux
      - darwin
      - windows
    goarch:
      - amd64
      - arm64
    flags:
      - -trimpath # reproducible builds
    ldflags:
      - -s -w # strip symbol table and DWARF
      - -X main.version={{ .Version }}
      - -X main.commit={{ .ShortCommit }}
      - -X main.date={{ .Date }}

archives:
  - format_overrides:
      - goos: windows
        formats: [zip] # zip for Windows, tar.gz otherwise
    files:
      - README.md
      - LICENSE

checksum:
  name_template: "checksums.txt"

changelog:
  use: github-native # GitHub auto-generated release notes
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"
      - "^chore:"
      - "Merge pull request"
      - "Merge branch"

release:
  prerelease: auto
```

## `.github/workflows/release.yml` (with the wrong-tag fix)

```yaml
name: Release
on:
  push:
    tags: ["v*"]

permissions:
  contents: write # create GitHub releases
  id-token: write # keyless cosign signing, if used

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # full history for changelog
          persist-credentials: false

      - uses: actions/setup-go@v5
        with:
          go-version: "stable"
          check-latest: true

      - run: go test ./...

      - name: Resolve version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> "$GITHUB_OUTPUT"

      - uses: goreleaser/goreleaser-action@v6
        with:
          distribution: goreleaser
          version: "~> v2"
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GORELEASER_CURRENT_TAG: ${{ steps.version.outputs.VERSION }} # <- picks the pushed tag, not git describe
```

**Bottom line:** the wrong-tag problem is fixed by `GORELEASER_CURRENT_TAG` (locally and in CI), and the bad release is remedied by shipping v2.0.0 correctly — never by re-tagging.
