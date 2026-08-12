For a v2.0.0 Go CLI release, first migrate the module path and then force GoReleaser to use the correct tag with `GORELEASER_CURRENT_TAG`.

## Step-by-step fix

### 1. Migrate to v2 module path

```bash
go mod edit -module github.com/myorg/tool/v2
gofmt -r '"github.com/myorg/tool" -> "github.com/myorg/tool/v2"' -w .
gofmt -r '"github.com/myorg/tool/" -> "github.com/myorg/tool/v2/"' -w .
go mod tidy
go build ./...
go vet ./...
go test -race -count=1 ./...
```

### 2. Verify no bad tags or wrong releases

If GoReleaser already published under the wrong tag:

- Do not delete `v2.0.0` if `proxy.golang.org` may have fetched it.
- Delete the wrong **GitHub Release** only, then rerun with the env var below.

### 3. Force the correct tag

```bash
git tag -a v2.0.0 -m "Release v2.0.0"
git push origin v2.0.0

GORELEASER_CURRENT_TAG=v2.0.0 \
GITHUB_TOKEN="$(gh auth token)" \
  goreleaser release --clean
```

If running via CI, set `GORELEASER_CURRENT_TAG: v2.0.0` in the workflow env.

### 4. Verify

```bash
go list -m -versions github.com/myorg/tool/v2
gh release view v2.0.0
```

## `.goreleaser.yml`

```yaml
version: 2

before:
  hooks:
    - go mod tidy

builds:
  - id: tool
    main: ./cmd/tool
    binary: tool
    env:
      - CGO_ENABLED=0
    goos:
      - linux
      - darwin
      - windows
    goarch:
      - amd64
      - arm64
    flags:
      - -trimpath
    ldflags:
      - -s -w
      - -X main.version={{ .Version }}
      - -X main.commit={{ .ShortCommit }}
      - -X main.date={{ .Date }}

archives:
  - format: tar.gz
    format_overrides:
      - goos: windows
        formats: [zip]
    files:
      - README.md
      - LICENSE

checksum:
  name_template: "checksums.txt"

changelog:
  use: github-native
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
