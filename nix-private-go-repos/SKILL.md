---
name: nix-private-go-repos
description: |
  Use when building Go projects with Nix flakes that depend on private GitHub repositories. Triggers on phrases like "private Go repo in Nix", "vendor/ in Nix", "mkPreparedSource", "GOPRIVATE", "publicDeps", "validatePrivateDeps", "could not read Username", "410 Gone from proxy.golang.org", or when migrating a Go project from committed vendor/ to a hermetic Nix build. Covers flake inputs, mkPreparedSource, vendorHash, GOPRIVATE in devShells, and CI token authentication.
allowed-tools: bash view edit grep
metadata:
  tags: nix, flakes, go, golang, private-repos, github, vendor, mkPreparedSource, GOPRIVATE, reproducibility
---

# Private Go GitHub Repositories in Nix

Private Go modules (`github.com/LarsArtmann/*`) cannot be fetched inside the Nix sandbox. The common workaround is committing a `vendor/` directory, which produces massive diffs, stale dependencies, merge conflicts, and bloated repositories. A better approach is `mkPreparedSource` + `GOPRIVATE`.

You need **both** parts:

- **`mkPreparedSource`** for hermetic `nix build` — it copies private deps into the source tree and injects `replace` directives before the build derivation.
- **`GOPRIVATE` in devShell** for local development — it stops `go mod tidy` / `go get` from hitting the public Go proxy for private paths.

## Verification status (read first)

Canonical block format per `verify-external-claims/SKILL.md` §5. All claims verified against the `go-nix-helpers` source (2026-08-12).

| Claim                                                                                                                                                                                                    | Status      | Source                                                           |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------------------------------------------- |
| `GOPRIVATE`, `vendorHash`, `buildGoModule`, `replace` directives, and `github:` flake inputs with `access-tokens` auth                                                                                   | ✅ Verified | Public, documented Nix and Go concepts                           |
| The `mkPreparedSource` function, the `flakeModules.go-standard` module, and their specific APIs (`deps` map, `validatePrivateDeps`, `publicDeps`, `postPatchExtra`, `privateGlobPattern`, `requireDeps`) | ✅ Verified | Current source in `/home/lars/projects/go-nix-helpers`           |
| The `go-standard` module has 39 options total (this skill covers the private-dep subset)                                                                                                                 | ✅ Verified | `go-nix-helpers` source (2026-08-12)                             |
| Committed `vendor/` problems (massive diffs, stale deps, merge conflicts, repo bloat)                                                                                                                    | ✅ Verified | Widely documented; independently observed in this repo's history |

## 1. Diagnose

Confirm you are hitting this problem:

```bash
nix build .#default
# error: could not read Username for 'https://github.com'
# or: 410 Gone from proxy.golang.org
```

Or check whether the project commits `vendor/`:

```bash
ls vendor/
git ls-files | grep '^vendor/' | wc -l
```

## 2. Apply the Two-Part Solution

### Option A: Using `flakeModules.go-standard` (recommended for LarsArtmann projects)

**`github.com/LarsArtmann/go-nix-helpers`** is a shared Nix library repo that provides a flake-parts
module called `flakeModules.go-standard`. When a project uses this module, private deps are fully
auto-wired — just set `deps` in the go-standard config:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  flake-parts = {
    url = "github:hercules-ci/flake-parts";
    inputs.nixpkgs-lib.follows = "nixpkgs";
  };
  go-nix-helpers = {
    url = "github:LarsArtmann/go-nix-helpers/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # Private deps (flake = false)
  go-cqrs-lite = {
    url = "github:LarsArtmann/go-cqrs-lite/master";
    flake = false;
  };
};

outputs = inputs@{ self, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ inputs.go-nix-helpers.flakeModules.go-standard ];

    go-standard = {
      pname = "my-project";
      vendorHash = "sha256-...";
      description = "What it does";
      deps = {
        "github.com/larsartmann/go-cqrs-lite" = inputs.go-cqrs-lite;
      };
      # GOPRIVATE is auto-injected (controlled by autoGoPrivate + privateGlobPattern).
      # mkPreparedSource is auto-wired. Sub-modules are auto-discovered.
      # GOTOOLCHAIN=local and GOWORK=off are set in all devShells.
      # publicDeps = [ "github.com/larsartmann/go-atomic-write" ]; # exclude public repos from validation
    };
  };
```

That's it. No manual mkPreparedSource import, no GOPRIVATE boilerplate, no postPatch
workarounds. The module handles everything when `deps` is non-empty.

**Auto-behaviors when `deps` is non-empty** (all automatic, no configuration needed):

| Behavior                  | What happens                                                                       |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `mkPreparedSource`        | Auto-wired; source is patched with `replace` directives before build               |
| `GOPRIVATE`               | Auto-injected into all devShells via `autoGoPrivate` + `privateGlobPattern`        |
| `GOWORK = "off"`          | Set in all devShells to prevent workspace interference                             |
| `GOTOOLCHAIN = "local"`   | Set in all devShells to prevent Go toolchain downloads                             |
| `proxyVendor = false`     | Set so vendor/ is produced from local deps, not the Go proxy                       |
| FOD `go mod tidy`         | Runs `go mod tidy` + `go mod vendor` in the FOD, syncs go.mod/go.sum to main build |
| Sub-module auto-discovery | Recursively scans each dep for all `go.mod` files at any depth                     |

**Auth prerequisite for `github:` inputs to private repos:** nix needs a token — `access-tokens = github.com=<token>` in `~/.config/nix/nix.conf` (get one with `gh auth token`). CI uses the same setting via nix-installer's `extra-conf` (see §4). Fleet truth since 2026-10-23: inputs are `github:owner/repo/ref`, not `git+ssh://`.

#### Monorepos: `packages` + private deps

`go-standard.packages` renders each entry as its own `buildGoModule` (own `pname`, `subPackages`, `description`, `meta.mainProgram`), while everything private-dep related stays top-level and repo-wide. Semantics verified against `modules/go-standard.nix` (2026-11-17):

```nix
go-standard = {
  # deps, vendorHash(es), goPkgAttr, src, ... stay top-level and shared
  packages = {
    server.subPackages = [ "cmd/server" ];
    server.description = "API server";
    worker.subPackages = [ "cmd/worker" ];
    worker.extraBuildAttrs.ldflags = [ "-X main.workerMode=true" ];
  };
};
```

| Question                  | Answer                                                                                                                                                                                                                                                                                                                                    |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| What does each entry own? | `subPackages` (default `[ "." ]`), `description`, and `extraBuildAttrs` (static attrset or `pkgs: attrs` function, evaluated with perSystem `pkgs` at render time)                                                                                                                                                                        |
| What is shared?           | The whole private-dep pipeline: `deps` feeds ONE `mkPreparedSource` output and every package builds from that same `_local_deps/`-patched source; `goPkg`, `ldflags`, `enableCheck`, `buildFlags`, and the templ/completion toggles also come from top-level config                                                                       |
| Per-package build tweaks? | `extraBuildAttrs` per entry: the six concat keys (`nativeBuildInputs`, `buildInputs`, `checkInputs`, `configureFlags`, `preBuild`, `postInstall`) append per-package values after top-level values; every other key overrides via `//`, per-package winning over top-level and the merged result sitting on top of the module's own attrs |
| `vendorHashes` scope?     | Per-SYSTEM, not per-package: a `vendorHashes.<system>` entry replaces `vendorHash` for that system and applies to EVERY package in the set (one effective hash for the whole monorepo build set)                                                                                                                                          |
| Per-package vendor hash?  | No typed option, but `vendorHash` is not a concat key, so `extraBuildAttrs.vendorHash` (top-level or per-package) overrides it via the same `//` merge. Rarely needed; treat a diverging hash as a smell first                                                                                                                            |
| Containerizing one entry? | `container.packageName` selects the main package (default) or any `packages` entry by name; the image-push story from §4 applies unchanged                                                                                                                                                                                                |

`deps` cannot be scoped per package: one repo, one `deps` map. Validation (`validatePrivateDeps`, `publicDeps`) runs while preparing the single shared source, so it covers every entry alike.

### Option B: Manual mkPreparedSource (for projects not using go-standard)

For projects not using the `go-standard` module from `github.com/LarsArtmann/go-nix-helpers`:

1. Add each private dependency as a flake input with a `github:` URL and `flake = false`.
2. Import `mkPreparedSource` from `github.com/LarsArtmann/go-nix-helpers` and list the private deps in the `deps` map.
3. Set `vendorHash` with `pkgs.lib.fakeHash`, run `nix build .#default`, and copy the correct hash from the error.
4. Add `GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";` to **every** devShell and CI shell.
5. Let git supply your gh token for the devShell's private `go` fetches (GOPRIVATE forces git transport):

   ```bash
   gh auth setup-git
   ```

For a full annotated `flake.nix` example, load [./references/implementation-guide.md](./references/implementation-guide.md).

### Monorepos with private deps (go-standard)

The go-standard module's monorepo `packages` option and private deps interact
through ONE prepared source:

- Shared config — `deps`, `subModules`, `vendorHash`, `goPkg` — comes from the
  TOP-LEVEL `go-standard` config. Every per-package build shares the same
  prepared source and the same `_local_deps/` replaces; there is no per-package
  dep set.
- Per-package divergence (`ldflags`, `subPackages`, `description`) goes in
  `go-standard.packages.<name>`. The six keys `nativeBuildInputs`,
  `buildInputs`, `checkInputs`, `configureFlags`, `preBuild`, `postInstall`
  APPEND to top-level values; everything else overrides with `//`.
- Per-package `extraBuildAttrs` accepts a `pkgs: attrs` function form when a
  package needs perSystem-built derivations.
- A monorepo entry whose code lives in a separate in-tree Go module still needs
  that module's deps in the top-level `deps` (or auto-discovered via
  `subModules`) — the whole repo builds from one patched source tree.

### Container images with private deps

`go-standard.container.enable` works unchanged with `deps` set: the private
deps are resolved at BUILD time into the image's Go binary, so the shipped
image layers contain only the compiled closure — nothing about `_local_deps/`
or the private repos leaks into the image. `nix run .#<pname>-image-push`
pushes it like any public image.

### Shell scripts in skills

Every shell script a skill ships must pass
`nix run nixpkgs#shellcheck -- scripts/*.sh` — style severity included (one
info-level SC code fails CI in LarsArtmann repos). Repo pre-commit hooks wrap
exactly that command; run it before committing script changes.

## 3. Migrate from `vendor/`

Follow the checklist in [./references/migration-checklist.md](./references/migration-checklist.md). The high-level steps are:

1. Identify unique private deps in `go.mod`.
2. Add one flake input per private repo (not per sub-module).
3. Wire `mkPreparedSource` and the `deps` map.
4. Set `vendorHash = pkgs.lib.fakeHash` temporarily.
5. Remove `vendor/` from the source fileset and from git tracking.
6. Remove `!vendor/` overrides from `.gitignore`.
7. Run `nix build .#default` and copy the correct hash.
8. Verify `nix build .#default && nix flake check`.
9. Verify local dev with `nix develop -c bash -c 'go mod tidy && go build ./...'`.

## 4. CI Authentication

CI runners must resolve `github:` flake inputs for private repos, and the Actions `GITHUB_TOKEN` cannot read sibling private repos. Store a fine-grained PAT (read-only Contents on every private flake-input repo) as a secret and pass it to nix:

```yaml
- uses: DeterminateSystems/nix-installer-action@v16
  with:
    extra-conf: access-tokens = github.com=${{ secrets.FLAKE_PAT }}
```

If a job enters a devShell and runs `go` (private module fetches go over git transport), rewrite the git URLs with the same token:

```yaml
- run: git config --global url."https://x-access-token:${FLAKE_PAT}@github.com/".insteadOf "https://github.com/"
```

**OCI image push carries no private-dep requirements.** `mkPreparedSource` copies the private deps into the source tree and injects the `_local_deps/` replaces before the Go build, so the private code is compiled into the binary and its layers at build time. The resulting image and the `image-push` app therefore need no SSH keys, no `GOPRIVATE`, and no GitHub tokens at push or runtime; the only credential involved is normal registry auth (what `skopeo` uses to talk to the registry).

Load [./references/ci-auth.md](./references/ci-auth.md) for copy-paste workflows, including the legacy `git+ssh://` + deploy-key strategies.

## 5. Common Gotchas

| Gotcha                               | Symptom                                                                                                                                  | Fix                                                                                                                                                                                                                                                                                                                                       |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Case-sensitive `GOPRIVATE`           | `go mod tidy` still fails for mixed-case imports                                                                                         | Use `GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";`                                                                                                                                                                                                                                                                    |
| Public LarsArtmann repo in `go.mod`  | `mkPreparedSource` validation fails because repo is not in `deps`                                                                        | Add to `publicDeps` (preferred) or set `validatePrivateDeps = false;`                                                                                                                                                                                                                                                                     |
| Transitive private deps              | Build fails on a private dep of a private dep                                                                                            | Add the transitive dep as a flake input too, or disable validation                                                                                                                                                                                                                                                                        |
| `tools/go.mod`                       | Secondary module lacks `replace` directives                                                                                              | Use `postPatchExtra` to inject replaces there too                                                                                                                                                                                                                                                                                         |
| `go.work`                            | Workspace resolution interferes with module builds                                                                                       | Automatic in go-standard; set `GOWORK = "off"` manually for Option B                                                                                                                                                                                                                                                                      |
| nixpkgs `gotools` Go skew            | treefmt `goimports` check fails in-sandbox trying to download a newer toolchain ("no network")                                           | Don't add `goimports` to the sandboxed formatter when `go.mod` requires a newer Go than `gotools` bundles; pin the matching `go_N_M` in devShells and enforce imports via golangci-lint outside the sandbox instead (securitymd 2026-10-09: gotools bundled Go 1.26, `go.mod` required 1.27)                                              |
| Dependency sweep drifts `vendorHash` | `nix build` fails with a hash mismatch days after a deps-only session; preflight WARNs "go.sum was modified after the hash was last set" | External dep BUMPS change `go.sum` exactly like new imports — re-verify the FOD hash (`nix build`) in the SAME session that touched go.mod/go.sum, or route the stale-hash fact into the handoff explicitly (pim-sync 2026-11-10: a cmdguard bump shipped a broken `nix run` to the user; "deps-only diff" never implies "nix-safe diff") |
| The FOD tidies `go.sum` internally   | A hash that verifies for the LOCAL tree fails in the sandbox, or sandbox builds leave `go.sum` differently ordered                       | `buildGoModule` runs its own `go mod` passes inside the fixed-output derivation; go.sum is an OUTPUT of the FOD's environment (toolchain version matters), not a stable input — hash against what the sandbox produces, not what your devShell produced                                                                                   |
| FOD output-path collision            | You changed go.mod or postPatch but nix still compiles stale vendor/ — compile errors ignore your edits                                  | A go-modules FOD's store path derives from the DECLARED vendorHash, not its inputs: once a hash's output path exists, nix silently skips the rebuild. Set `vendorHash = "sha256-AAAA…A="` (exactly 43 chars + `=`), build, paste the real `got:` hash (Code-Quality-Agent 2026-11-11: ~4 wasted build cycles before this was understood)  |
| Duplicate `deps` keys → one repo     | mkPreparedSource fails with an opaque `Permission denied` inside `_local_deps/`                                                          | One `deps` entry per repo; sub-modules are auto-discovered (`autoSubModules`) — never add separate `/submodule` entries for the same input                                                                                                                                                                                                |

For the full gotcha list, load [./references/implementation-guide.md](./references/implementation-guide.md).

## 6. Verify

After any change, run:

```bash
nix build .#default
nix flake check
nix develop -c bash -c 'go mod tidy && go build ./...'
```

All three must pass before the migration is complete.
