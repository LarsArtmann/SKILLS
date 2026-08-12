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
- [Docker image publishing](#docker-image-publishing)
- [Homebrew cask publishing](#homebrew-cask-publishing)
- [Scoop bucket publishing](#scoop-bucket-publishing)
- [Release branch strategies](#release-branch-strategies)
- [Snapshot builds for testing](#snapshot-builds-for-testing)
- [Common GoReleaser failure modes](#common-goreleaser-failure-modes)

---

## GoReleaser basics

GoReleaser automates cross-compilation, archiving, checksum generation, and GitHub
Release publishing. The pipeline runs: before hooks → builds → archives → checksums
→ signing → SBOMs → publish → after hooks.

GoReleaser v2 requires `version: 2` at the top of the config file.

### When to use GoReleaser vs gh CLI

| Use case                      | Tool                                                  |
| ----------------------------- | ----------------------------------------------------- |
| Library (no binaries)         | `gh release create` — no artifacts to build           |
| Application/CLI with binaries | GoReleaser — builds cross-platform archives           |
| Need checksums, signing, SBOM | GoReleaser — automates all of it                      |
| Quick release, dirty tree     | `gh release create` — GoReleaser requires clean state |

---

## Minimal .goreleaser.yml

```yaml
version: 2

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
      - -trimpath # removes filesystem paths for reproducible builds
    ldflags:
      - -s -w # strip debug info and DWARF
      - -X main.version={{ .Version }}
      - -X main.commit={{ .ShortCommit }}
      - -X main.date={{ .Date }}

archives:
  - format_overrides:
      - goos: windows
        formats: [zip] # zip for Windows, tar.gz for everything else
    files:
      - README.md
      - LICENSE

checksum:
  name_template: "checksums.txt"

changelog:
  use: github-native # use GitHub's auto-generated release notes
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"
      - "^chore:"
      - "Merge pull request"
      - "Merge branch"

release:
  prerelease: auto # auto-detect pre-releases from tag name
```

### Key ldflags explained

| Flag                              | Purpose                                                |
| --------------------------------- | ------------------------------------------------------ |
| `-s`                              | Strip symbol table (smaller binary)                    |
| `-w`                              | Strip DWARF debug info (smaller binary)                |
| `-X main.version={{.Version}}`    | Inject version at build time                           |
| `-X main.commit={{.ShortCommit}}` | Inject commit hash                                     |
| `-X main.date={{.Date}}`          | Inject build date                                      |
| `-trimpath`                       | Remove filesystem paths (reproducible builds, privacy) |

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
      - "v*"

permissions:
  contents: write # required to create GitHub releases
  id-token: write # required for cosign keyless signing

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # full history for changelog generation
          persist-credentials: false

      - uses: actions/setup-go@v5
        with:
          go-version: "stable"
          check-latest: true
          cache: true

      - run: go test ./...

      - uses: goreleaser/goreleaser-action@v6
        with:
          distribution: goreleaser
          version: "~> v2"
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Key workflow settings

| Setting                        | Why                                                          |
| ------------------------------ | ------------------------------------------------------------ |
| `fetch-depth: 0`               | GoReleaser needs full git history for changelog between tags |
| `persist-credentials: false`   | Security — prevents token leakage                            |
| `permissions: contents: write` | GoReleaser needs to create releases                          |
| `permissions: id-token: write` | Required for keyless cosign signing (OIDC)                   |
| `--clean`                      | Removes `dist/` before building (prevents stale artifacts)   |

### Manual trigger with validation

For projects that want a validation step before tagging:

```yaml
on:
  push:
    tags: ["v*"]
  workflow_dispatch:
    inputs:
      version:
        description: "Version (e.g., 1.2.3)"
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
          go-version: "stable"

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
      - "--output-certificate=${certificate}"
      - "--output-signature=${signature}"
      - "${artifact}"
      - "--yes"
    artifacts: checksum
```

**Cosign v3 note:** Cosign v3+ deprecated `--output-signature` /
`--output-certificate` in favor of the required `--bundle` flag. If using
cosign v3+, replace the args above with:

```yaml
args:
  - "sign-blob"
  - "--bundle=${artifact}.bundle.json"
  - "${artifact}"
  - "--yes"
```

Pin `sigstore/cosign-installer` to a compatible version for your cosign
major version. The `--yes` flag replaces the removed `--force` and skips the
transparency-log confirmation prompt.

Required CI setup:

```yaml
- name: Install cosign
  uses: sigstore/cosign-installer@v4
```

Required permissions:

```yaml
permissions:
  id-token: write # OIDC token for keyless signing
  contents: write
```

### Including verification instructions in release notes

````yaml
release:
  header: |
    ### Verify checksums file signature

    The checksums file is signed using [Cosign](https://docs.sigstore.dev/) with GitHub OIDC.
    ```shell
    curl -LO https://github.com/{{ .Env.GITHUB_REPOSITORY }}/releases/download/{{ .Tag }}/checksums.txt
    curl -LO https://github.com/{{ .Env.GITHUB_REPOSITORY }}/releases/download/{{ .Tag }}/checksums.txt.pem
    curl -LO https://github.com/{{ .Env.GITHUB_REPOSITORY }}/releases/download/{{ .Tag }}/checksums.txt.sig

    cosign verify-blob checksums.txt \
      --certificate checksums.txt.pem \
      --signature checksums.txt.sig \
      --certificate-identity-regexp=https://github.com/{{ .Env.GITHUB_REPOSITORY_OWNER }} \
      --certificate-oidc-issuer=https://token.actions.githubusercontent.com

    sha256sum -c checksums.txt --ignore-missing
    ```
````

---

## SLSA provenance

SLSA (Supply-chain Levels for Software Artifacts) provenance provides cryptographic
proof of build origin. This is the highest tier of supply-chain security.

```yaml
- name: Attest build provenance
  uses: actions/attest-build-provenance@v2
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

## Docker image publishing

Use `dockers_v2` (not the deprecated `dockers` section) to build and push OCI
images. GoReleaser v2's Docker v2 pipeline uses the Docker buildx backend.

### Minimal Docker v2 config

```yaml
dockers_v2:
  - images:
      - "ghcr.io/myorg/myrepo"
    tags:
      - "v{{ .Version }}"
      - "latest"
    extra_files:
      - scripts/entrypoint.sh
    labels:
      "org.opencontainers.image.description": "My Go service"
      "org.opencontainers.image.created": "{{.Date}}"
      "org.opencontainers.image.revision": "{{.FullCommit}}"
      "org.opencontainers.image.version": "{{.Version}}"
    annotations:
      "org.opencontainers.image.source": "{{.GitURL}}"
```

### Required CI setup

The GitHub Actions runner needs Docker buildx and registry login:

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Login to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

### Multi-platform images

Add `platforms` to build for multiple architectures. You must also list the
matching build targets in the `builds` section and set `CGO_ENABLED=0`.

```yaml
dockers_v2:
  - images:
      - "ghcr.io/myorg/myrepo"
    tags:
      - "v{{ .Version }}"
      - "latest"
    platforms:
      - linux/amd64
      - linux/arm64
```

---

## Homebrew cask publishing

GoReleaser v2 deprecated the `brews` (formula) section in favor of
`homebrew_casks`. Configure a separate tap repository — GoReleaser will commit
the generated cask file to it.

```yaml
homebrew_casks:
  - repository:
      owner: myorg
      name: homebrew-tap
      token: "{{ .Env.GH_PAT }}"
    homepage: https://github.com/myorg/myrepo
    description: "My CLI tool"
    license: MIT
    conflicts:
      - cask: myrepo-pro
```

### Required CI secrets

`GH_PAT` must have `contents: write` permission on the tap repository. The
workflow that runs GoReleaser must pass it as an environment variable:

```yaml
env:
  GH_PAT: ${{ secrets.GH_PAT }}
```

---

## Scoop bucket publishing

Scoop is the Windows-native package manager. GoReleaser can publish a
`myrepo.json` manifest to a Scoop bucket repository.

```yaml
scoops:
  - repository:
      owner: myorg
      name: scoop-bucket
      token: "{{ .Env.GH_PAT }}"
    directory: bucket
    homepage: https://github.com/myorg/myrepo
    description: "My CLI tool"
    license: MIT
```

Like Homebrew, this requires `GH_PAT` with write access to the bucket repo.

---

## Release branch strategies

For most projects, releases are cut from the default branch (`master` or `main`).
When you need to maintain multiple major or minor versions, use release branches.

### When to use release branches

- **Long-term support**: v1.x keeps getting security patches while v2.x is developed
- **Hotfix without shipping unreleased main**: main has v2.0.0-beta work, but you
  need to release v1.2.5 now
- **Stable release cadence**: monthly patch releases from a `release/v1.2` branch

### Release branch workflow

1. Create the branch from the tag you want to patch:

   ```bash
   git checkout -b release/v1.2 v1.2.4
   ```

2. Cherry-pick the fix from main:

   ```bash
   git cherry-pick <fix-commit-hash>
   ```

3. Run the full release verification pipeline on the branch.

4. Tag from the release branch, not from main:

   ```bash
   git tag -a v1.2.5 -m "Release v1.2.5"
   git push origin release/v1.2
   git push origin v1.2.5
   ```

### Critical rule: do not merge release branches back into main

A release branch contains older code. Merging it back into main can downgrade
dependencies or revert already-merged changes. Treat release branches as
one-way: cherry-pick fixes **from** main **to** the release branch, then tag and
push. If you need to bring a release-branch-specific fix back to main, cherry-pick
it separately.

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

| Error                                                | Cause                                  | Fix                                                       |
| ---------------------------------------------------- | -------------------------------------- | --------------------------------------------------------- |
| `git is currently in a dirty state`                  | Uncommitted changes                    | Commit all changes, or wait for auto-commit daemon        |
| `git doesn't contain any tags`                       | No tags, or shallow clone missing tags | Use `fetch-depth: 0` in checkout; create a tag first      |
| `only configurations files on the version: 2 schema` | Config uses v1 schema                  | Add `version: 2` to top of `.goreleaser.yml`              |
| `github: token could not be created`                 | Missing GITHUB_TOKEN or permissions    | Add `permissions: contents: write` and `GITHUB_TOKEN` env |
| `gcc: error: unrecognized command-line option`       | CGO enabled without cross-compiler     | Set `CGO_ENABLED=0` in build env                          |
| `getting key from fulcio: getting cert: oidc`        | Missing `id-token: write` permission   | Add `permissions: id-token: write`                        |
| Wrong tag selected                                   | Multiple tags at same commit           | Set `GORELEASER_CURRENT_TAG=vX.Y.Z`                       |
| Build matrix timeout                                 | Too many platforms                     | Reduce targets or split into parallel jobs                |
| `could not read Username for 'https://github.com'`   | Private deps not authenticated         | Set GOPRIVATE + git URL rewriting (above)                 |
| Hook fails with "command not found" or shell errors | GoReleaser OSS invokes `exec.CommandContext` directly, not a shell | Wrap shell features in `sh -c "..."` (e.g., `sh -c 'foo && bar \| baz'`) |