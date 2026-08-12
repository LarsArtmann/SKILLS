# GoReleaser and CI/CD for Go Releases

Table of Contents:
- [GoReleaser basics](#goreleaser-basics)
- [Minimal .goreleaser.yml](#minimal-goreleaseryml)
- [GitHub Actions release workflow](#github-actions-release-workflow)
- [Multi-module monorepo configuration](#multi-module-monorepo-configuration)
- [Private dependency authentication](#private-dependency-authentication)
- [SBOM generation](#sbom-generation)
- [Cosign signing](#cosign-signing)
- [SLSA provenance](#slsa-provenance)
- [Snapshot builds for testing](#snapshot-builds-for-testing)
- [Common GoReleaser failure modes](#common-goreleaser-failure-modes)

---

## GoReleaser basics

GoReleaser automates cross-compilation, archiving, checksum generation, and GitHub
Release publishing. The pipeline runs: before hooks → builds → archives → checksums
→ signing → SBOMs → publish → after hooks.

GoReleaser v2 requires `version: 2` at the top of the config file.

### When to use GoReleaser vs gh CLI

| Use case | Tool |
|----------|------|
| Library (no binaries) | `gh release create` — no artifacts to build |
| Application/CLI with binaries | GoReleaser — builds cross-platform archives |
| Need checksums, signing, SBOM | GoReleaser — automates all of it |
| Quick release, dirty tree | `gh release create` — GoReleaser requires clean state |

---

## Minimal .goreleaser.yml

```yaml
version: 2

before:
  hooks:
    - go mod tidy

builds:
  - env:
      - CGO_ENABLED=0          # critical for cross-compilation
    goos:
      - linux
      - darwin
      - windows
    goarch:
      - amd64
      - arm64
    flags:
      - -trimpath               # removes filesystem paths for reproducible builds
    ldflags:
      - -s -w                   # strip debug info and DWARF
      - -X main.version={{ .Version }}
      - -X main.commit={{ .ShortCommit }}
      - -X main.date={{ .Date }}

archives:
  - format_overrides:
      - goos: windows
        formats: [zip]          # zip for Windows, tar.gz for everything else
    files:
      - README.md
      - LICENSE

checksum:
  name_template: 'checksums.txt'

changelog:
  use: github-native             # use GitHub's auto-generated release notes
  sort: asc
  filters:
    exclude:
      - '^docs:'
      - '^test:'
      - '^chore:'
      - 'Merge pull request'
      - 'Merge branch'

release:
  prerelease: auto               # auto-detect pre-releases from tag name
```

### Key ldflags explained

| Flag | Purpose |
|------|---------|
| `-s` | Strip symbol table (smaller binary) |
| `-w` | Strip DWARF debug info (smaller binary) |
| `-X main.version={{.Version}}` | Inject version at build time |
| `-X main.commit={{.ShortCommit}}` | Inject commit hash |
| `-X main.date={{.Date}}` | Inject build date |
| `-trimpath` | Remove filesystem paths (reproducible builds, privacy) |

### Build targets

GoReleaser cross-compiles using Go's native `GOOS`/`GOARCH`. Key points:

- `CGO_ENABLED=0` is essential — with CGO enabled, you need C cross-compilers
- Use `ignore` to remove invalid combinations:

```yaml
builds:
  - goos: [linux, darwin, windows, freebsd]
    goarch: [amd64, arm64, arm, "386"]
    ignore:
      - goos: windows
        goarch: arm
      - goos: freebsd
        goarch: arm64
```

---

## GitHub Actions release workflow

### Minimal workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write        # required to create GitHub releases
  id-token: write        # required for cosign keyless signing

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0          # full history for changelog generation
          persist-credentials: false

      - uses: actions/setup-go@v5
        with:
          go-version: 'stable'
          check-latest: true
          cache: true

      - run: go test ./...

      - uses: goreleaser/goreleaser-action@v6
        with:
          distribution: goreleaser
          version: '~> v2'
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Key workflow settings

| Setting | Why |
|---------|-----|
| `fetch-depth: 0` | GoReleaser needs full git history for changelog between tags |
| `persist-credentials: false` | Security — prevents token leakage |
| `permissions: contents: write` | GoReleaser needs to create releases |
| `permissions: id-token: write` | Required for keyless cosign signing (OIDC) |
| `--clean` | Removes `dist/` before building (prevents stale artifacts) |

### Manual trigger with validation

For projects that want a validation step before tagging:

```yaml
on:
  push:
    tags: ['v*']
  workflow_dispatch:
    inputs:
      version:
        description: 'Version (e.g., 1.2.3)'
        required: true

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-go@v5
        with:
          go-version: 'stable'

      - name: Resolve version
        id: version
        run: |
          if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
            echo "VERSION=v${{ inputs.version }}" >> "$GITHUB_OUTPUT"
          else
            echo "VERSION=${GITHUB_REF#refs/tags/}" >> "$GITHUB_OUTPUT"
          fi

      - name: Validate release build (dry run)
        if: github.event_name == 'workflow_dispatch'
        uses: goreleaser/goreleaser-action@v6
        with:
          args: release --clean --snapshot --skip=publish
        env:
          GORELEASER_CURRENT_TAG: ${{ steps.version.outputs.VERSION }}

      - name: Run GoReleaser
        if: github.event_name == 'push'
        uses: goreleaser/goreleaser-action@v6
        with:
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GORELEASER_CURRENT_TAG: ${{ steps.version.outputs.VERSION }}
```

---

## Multi-module monorepo configuration

For monorepos with multiple modules, each module needs its own build configuration.
Use the `dir` field to set the build directory per module:

```yaml
builds:
  - id: myapp
    main: ./cmd/myapp
    dir: ./services/app
    binary: myapp
    env:
      - CGO_ENABLED=0

  - id: worker
    main: ./cmd/worker
    dir: ./services/worker
    binary: worker
    env:
      - CGO_ENABLED=0
```

**Always set `GORELEASER_CURRENT_TAG`** for multi-module releases. When multiple
tags share one commit, `git describe` picks the alphabetically-last tag. See
[./multi-module.md#goreleaser_current_tag](./multi-module.md#goreleaser_current_tag).

---

## Private dependency authentication

When your Go module depends on private GitHub repositories, the Go module proxy
returns 404 for them. GoReleaser and CI builds need authenticated access.

### Three-layer solution

#### Layer 1: GOPRIVATE

```bash
go env -w GOPRIVATE=github.com/myorg/*
```

This tells Go to skip the public proxy and checksum database for matching modules.

#### Layer 2: Git URL rewriting (the critical piece)

Even with GOPRIVATE, `go mod download` uses git to clone private repos. In CI,
there's no interactive credential prompt. Git URL rewriting injects the token:

```bash
git config --global url."https://x-access-token:${GH_PAT}@github.com/".insteadOf "https://github.com/"
```

GitHub Actions step:

```yaml
- name: Configure private repo access
  env:
    GH_PAT: ${{ secrets.GH_PAT }}
  run: |
    git config --global url."https://x-access-token:${GH_PAT}@github.com/".insteadOf "https://github.com/"
    go env -w GOPRIVATE=github.com/myorg/*
```

#### Layer 3: GH_PAT secret

```bash
gh secret list              # check if GH_PAT exists
gh secret set GH_PAT        # create it (needs classic PAT with repo scope)
```

The default `GITHUB_TOKEN` works for repos within the same org. For cross-org
private deps, use a Personal Access Token.

### Nix-specific private deps

For Nix flake builds with private Go deps, see the `nix-private-go-repos` skill —
it covers `mkPreparedSource`, `vendorHash`, and SSH-based auth in Nix sandboxes.

---

## SBOM generation

Software Bill of Materials (SBOM) lists all dependencies and their versions. Modern
supply-chain best practice.

### Built-in SBOM (uses syft internally)

```yaml
sboms:
  - artifacts: archive
    documents:
      - "${artifact}.spdx.json"
```

Requires syft in CI:

```yaml
- name: Install syft
  uses: anchore/sbom-action/download-syft@v0
```

---

## Cosign signing

Keyless signing with GitHub OIDC — no key management needed. Signs the checksums file
cryptographically, proving the release came from your CI.

```yaml
signs:
  - cmd: cosign
    signature: "${artifact}.sig"
    certificate: "${artifact}.pem"
    args:
      - "sign-blob"
      - "--oidc-issuer=https://token.actions.githubusercontent.com"
      - "--output-certificate=${certificate}"
      - "--output-signature=${signature}"
      - "${artifact}"
      - "--yes"
    artifacts: checksum
```

Required CI setup:

```yaml
- name: Install cosign
  uses: sigstore/cosign-installer@v4
```

Required permissions:

```yaml
permissions:
  id-token: write      # OIDC token for keyless signing
  contents: write
```

### Including verification instructions in release notes

```yaml
release:
  header: |
    ### Verify checksums file signature

    ```shell
    cosign verify-blob checksums.txt \
      --certificate checksums.txt.pem \
      --signature checksums.txt.sig \
      --certificate-identity-regexp=https://github.com/myorg \
      --certificate-oidc-issuer=https://token.actions.githubusercontent.com

    sha256sum -c checksums.txt --ignore-missing
    ```
```

---

## SLSA provenance

SLSA (Supply-chain Levels for Software Artifacts) provenance provides cryptographic
proof of build origin. This is the highest tier of supply-chain security.

```yaml
- name: Generate subject hashes for SLSA
  id: hash
  env:
    ARTIFACTS: "${{ steps.goreleaser.outputs.artifacts }}"
  run: |
    checksum_file=$(echo "$ARTIFACTS" | jq -r '.[] | select(.type=="Checksum") | .path')
    echo "hashes=$(cat "$checksum_file" | base64 -w0)" >> "$GITHUB_OUTPUT"

- name: Attest build provenance
  uses: actions/attest-build-provenance@v1
  with:
    subject-checksums: ./dist/checksums.txt
```

Required permissions:

```yaml
permissions:
  id-token: write
  attestations: write
  contents: write
```

---

## Snapshot builds for testing

Test the release pipeline without publishing:

```bash
goreleaser release --clean --snapshot --skip=publish
```

`--snapshot` bypasses tag requirements and skips validations. `--skip=publish`
prevents uploading anything. Use this to validate the release config in CI without
creating a real release.

---

## Common GoReleaser failure modes

| Error | Cause | Fix |
|-------|-------|-----|
| `git is currently in a dirty state` | Uncommitted changes | Commit all changes, or wait for auto-commit daemon |
| `git doesn't contain any tags` | No tags, or shallow clone missing tags | Use `fetch-depth: 0` in checkout; create a tag first |
| `only configurations files on the version: 2 schema` | Config uses v1 schema | Add `version: 2` to top of `.goreleaser.yml` |
| `github: token could not be created` | Missing GITHUB_TOKEN or permissions | Add `permissions: contents: write` and `GITHUB_TOKEN` env |
| `gcc: error: unrecognized command-line option` | CGO enabled without cross-compiler | Set `CGO_ENABLED=0` in build env |
| `getting key from fulcio: getting cert: oidc` | Missing `id-token: write` permission | Add `permissions: id-token: write` |
| Wrong tag selected | Multiple tags at same commit | Set `GORELEASER_CURRENT_TAG=vX.Y.Z` |
| Build matrix timeout | Too many platforms | Reduce targets or split into parallel jobs |
| `could not read Username for 'https://github.com'` | Private deps not authenticated | Set GOPRIVATE + git URL rewriting (above) |
