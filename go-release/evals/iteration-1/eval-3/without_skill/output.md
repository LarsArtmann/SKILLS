**Fix**

GoReleaser picks the current tag from git. When multiple tags point to the same commit, force the right one with `GORELEASER_CURRENT_TAG`.

1. Clean the previous build:
   ```bash
   rm -rf dist
   ```

2. If a wrong release already exists on GitHub, delete it:
   ```bash
   gh release delete <wrong-tag> --yes
   ```

3. Run the release with the correct tag:
   ```bash
   GORELEASER_CURRENT_TAG=v2.0.0 goreleaser release --clean
   ```

4. In GitHub Actions, set the env var:
   ```yaml
   env:
     GORELEASER_CURRENT_TAG: v2.0.0
   ```

**.goreleaser.yml**

```yaml
project_name: tool

before:
  hooks:
    - go mod tidy

builds:
  - env:
      - CGO_ENABLED=0
    goos:
      - linux
      - windows
      - darwin
    goarch:
      - amd64
      - arm64
    ldflags:
      - -s -w -X main.version={{.Version}} -X main.commit={{.Commit}} -X main.date={{.Date}}

archives:
  - format: tar.gz
    format_overrides:
      - goos: windows
        format: zip
    name_template: "{{ .ProjectName }}_{{ .Version }}_{{ .Os }}_{{ .Arch }}"

checksum:
  name_template: "checksums.txt"

snapshot:
  name_template: "{{ incpatch .Version }}-next"

changelog:
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"

release:
  github:
    owner: myorg
    name: tool
  draft: false
  prerelease: false
```
