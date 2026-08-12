---
name: nix-private-go-repos
description: |
  Use when building Go projects with Nix flakes that depend on private GitHub repositories. Triggers on phrases like "private Go repo in Nix", "vendor/ in Nix", "mkPreparedSource", "GOPRIVATE", "publicDeps", "validatePrivateDeps", "could not read Username", "410 Gone from proxy.golang.org", or when migrating a Go project from committed vendor/ to a hermetic Nix build. Covers flake inputs, mkPreparedSource, vendorHash, GOPRIVATE in devShells, and CI SSH authentication.
allowed-tools: bash view edit grep
metadata:
  tags: nix, flakes, go, golang, private-repos, github, vendor, mkPreparedSource, GOPRIVATE, reproducibility
---

# Private Go GitHub Repositories in Nix

Private Go modules (`github.com/LarsArtmann/*`) cannot be fetched inside the Nix sandbox. The common workaround is committing a `vendor/` directory, which produces massive diffs, stale dependencies, merge conflicts, and bloated repositories. A better approach is `mkPreparedSource` + `GOPRIVATE`.

You need **both** parts:

- **`mkPreparedSource`** for hermetic `nix build` — it copies private deps into the source tree and injects `replace` directives before the build derivation.
- **`GOPRIVATE` in devShell** for local development — it stops `go mod tidy` / `go get` from hitting the public Go proxy for private paths.

> ## Verification status (read first)
>
> **All claims verified against `go-nix-helpers` source** (as of 2026-08-12):
>
> - `GOPRIVATE`, `vendorHash`, `buildGoModule`, `replace` directives, and `git+ssh://` flake inputs are public, documented Nix and Go concepts.
> - The `mkPreparedSource` function, the `flakeModules.go-standard` module, and their specific APIs (`deps` map, `validatePrivateDeps`, `publicDeps`, `postPatchExtra`, `privateGlobPattern`, `requireDeps`) are confirmed against the current source in `/home/lars/projects/go-nix-helpers`.
> - The `go-standard` module has 39 options total; this skill covers the subset relevant to private-dep management.
> - The problems with committed `vendor/` (massive diffs, stale deps, merge conflicts) are well-known and widely documented.

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
    url = "git+ssh://git@github.com/LarsArtmann/go-nix-helpers?ref=master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # Private deps (flake = false)
  go-cqrs-lite = {
    url = "git+ssh://git@github.com/LarsArtmann/go-cqrs-lite?ref=master";
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

### Option B: Manual mkPreparedSource (for projects not using go-standard)

For projects not using the `go-standard` module from `github.com/LarsArtmann/go-nix-helpers`:

1. Add each private dependency as a flake input with `git+ssh://` and `flake = false`.
2. Import `mkPreparedSource` from `github.com/LarsArtmann/go-nix-helpers` and list the private deps in the `deps` map.
3. Set `vendorHash` with `pkgs.lib.fakeHash`, run `nix build .#default`, and copy the correct hash from the error.
4. Add `GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";` to **every** devShell and CI shell.
5. Configure local git to rewrite HTTPS GitHub URLs to SSH:

   ```bash
   git config --global url."git@github.com:".insteadOf "https://github.com/"
   ```

For a full annotated `flake.nix` example, load [./references/implementation-guide.md](./references/implementation-guide.md).

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

CI runners need to resolve `git+ssh://` flake inputs but have no SSH keys. Use one of:

- **Deploy keys:** one SSH key pair, public key added as a read-only deploy key to each private repo, private key stored as a GitHub Actions secret.
- **`GITHUB_TOKEN` with `insteadOf`:** rewrite `git@github.com:` and `ssh://git@github.com/` URLs to HTTPS with `x-access-token` auth.

Load [./references/ci-auth.md](./references/ci-auth.md) for copy-paste workflows.

## 5. Common Gotchas

| Gotcha                              | Symptom                                                           | Fix                                                                    |
| ----------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Case-sensitive `GOPRIVATE`          | `go mod tidy` still fails for mixed-case imports                  | Use `GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";` |
| Public LarsArtmann repo in `go.mod` | `mkPreparedSource` validation fails because repo is not in `deps` | Add to `publicDeps` (preferred) or set `validatePrivateDeps = false;`  |
| Transitive private deps             | Build fails on a private dep of a private dep                     | Add the transitive dep as a flake input too, or disable validation     |
| `tools/go.mod`                      | Secondary module lacks `replace` directives                       | Use `postPatchExtra` to inject replaces there too                      |
| `go.work`                           | Workspace resolution interferes with module builds                | Automatic in go-standard; set `GOWORK = "off"` manually for Option B   |

For the full gotcha list, load [./references/implementation-guide.md](./references/implementation-guide.md).

## 6. Verify

After any change, run:

```bash
nix build .#default
nix flake check
nix develop -c bash -c 'go mod tidy && go build ./...'
```

All three must pass before the migration is complete.
