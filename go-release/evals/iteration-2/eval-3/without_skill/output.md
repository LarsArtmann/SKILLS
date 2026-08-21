## Why it happens

GoReleaser infers the "current tag" from git. When several tags point at the same commit, it can't know which one you mean and may pick the wrong one (GoReleaser aborts with a *multiple tags* error, or silently picks the first match). The fix is to tell it explicitly.

## Fix the release

**Option A — set the tag explicitly (recommended):**

```bash
# if a wrong release got published, delete it first
gh release delete v2.0.0 --yes || true

GORELEASER_CURRENT_TAG=v2.0.0 goreleaser release --clean
```

`GORELEASER_CURRENT_TAG` overrides tag inference entirely, so the extra tags on that commit are ignored.

**Option B — remove the ambiguity:**

```bash
git tag -d other-tag extra-tag
git push origin :refs/tags/other-tag :refs/tags/extra-tag
goreleaser release --clean
```

**In CI:** trigger on the tag push (`on: push: tags: ['v*']`) — the GoReleaser GitHub Action uses the tag from the event, so it's always correct even with co-located tags:

```yaml
name: release
on:
  push:
    tags: ['v*']
jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-go@v5
        with:
          go-version: stable
      - uses: goreleaser/goreleaser-action@v6
        with:
          version: '~> v2'
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## `.goreleaser.yml` (GoReleaser v2)

```yaml
version: 2

project_name: tool

before:
  hooks:
    - go mod tidy

builds:
  - id: tool
    main: .
    binary: tool
    env:
      - CGO_ENABLED=0
    goos: [linux, darwin, windows]
    goarch: [amd64, arm64]
    ldflags:
      - -s -w
      - -X main.version={{ .Version }}
      - -X main.commit={{ .Commit }}
      - -X main.date={{ .Date }}

archives:
  - id: tool
    builds: [tool]
    formats: [tar.gz]
    name_template: >-
      {{ .ProjectName }}_{{ title .Os }}_{{ if eq .Arch "amd64" }}x86_64{{ else }}{{ .Arch }}{{ end }}
    format_overrides:
      - goos: windows
        formats: [zip]

checksum:
  name_template: 'checksums.txt'

changelog:
  sort: asc
  filters:
    exclude:
      - '^docs:'
      - '^test:'
      - '^chore:'

release:
  github:
    owner: myorg
    name: tool
```

Adjust `main:` if your CLI entrypoint is e.g. `./cmd/tool`. `version: 2` is required by GoReleaser v2.x.
