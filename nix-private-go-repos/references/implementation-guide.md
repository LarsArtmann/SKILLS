# Private Go Repos in Nix: Implementation Guide

Full annotated example and gotcha catalog for using `mkPreparedSource` + `GOPRIVATE` instead of committed `vendor/`.

## Full `flake.nix` Example

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The helper itself
    go-nix-helpers = {
      url = "git+ssh://git@github.com/LarsArtmann/go-nix-helpers?ref=master";
      flake = false;
    };

    # Private deps (flake = false, fetched via SSH outside the sandbox)
    go-cqrs-lite = {
      url = "git+ssh://git@github.com/LarsArtmann/go-cqrs-lite?ref=master";
      flake = false;
    };
    go-branded-id = {
      url = "git+ssh://git@github.com/LarsArtmann/go-branded-id?ref=master";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { system, lib, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          go = pkgs.go_1_26;
          version = self.rev or self.dirtyRev or "dev";

          mkPreparedSource = import (inputs.go-nix-helpers + "/mkPreparedSource.nix") {
            inherit pkgs lib;
            goPkg = go;
          };

          preparedSrc = mkPreparedSource {
            name = "my-app";
            inherit version;
            src = ./.;
            deps = {
              "github.com/larsartmann/go-cqrs-lite" = inputs.go-cqrs-lite;
              "github.com/larsartmann/go-branded-id" = inputs.go-branded-id;
            };
            # Some LarsArtmann repos are public; disable validation only when
            # a public repo in go.mod is intentionally not listed in deps.
            validatePrivateDeps = false;
          };
        in
        {
          packages.default = pkgs.buildGoModule {
            pname = "my-app";
            inherit version;
            src = preparedSrc;
            vendorHash = "sha256-..."; # Set pkgs.lib.fakeHash first, run nix build, copy from error
            nativeBuildInputs = [ go ];
            ldflags = [ "-s" "-w" ];
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [ go gopls golangci-lint ];
            GOWORK = "off";
            # Case-sensitive: cover both lowercase and uppercase import paths.
            GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";
          };

          devShells.ci = pkgs.mkShellNoCC {
            packages = with pkgs; [ go golangci-lint ];
            GOWORK = "off";
            GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";
          };
        };
    };
}
```

## How `mkPreparedSource` Works

1. Each private dep is added as a flake input with `git+ssh://` URL and `flake = false`.
2. `nix flake update` fetches them via SSH **outside** the sandbox (where your keys work).
3. `mkPreparedSource` copies the deps into `_local_deps/` and injects `replace` directives into `go.mod`.
4. The Go toolchain resolves everything locally — zero network inside the sandbox.

## Key Features of `mkPreparedSource`

| Feature               | What it does                                                                        |
| --------------------- | ----------------------------------------------------------------------------------- |
| Auto-discovery        | Recursively scans each dep for all `go.mod` files at any depth                      |
| Build-time validation | Verifies every private module in `go.mod` has a `replace` directive                 |
| `/vN` suffix handling | Strips version suffixes from local paths while keeping them in `replace` directives |
| Stale replace cleanup | Removes dev-machine `/home/...` and `../sibling` replaces before injecting its own  |
| `privateDepPattern`   | Default `github\\.com/[Ll]ars[Aa]rtmann/`; override for other private hosts         |

## Getting `vendorHash`

Set `vendorHash = pkgs.lib.fakeHash;` first, then run:

```bash
nix build .#default
# Nix will fail with the correct hash in the error output — copy it.
```

Some projects automate this with an app:

```nix
apps.update-vendor-hash = {
  type = "app";
  program = pkgs.writeShellApplication {
    name = "update-vendor-hash";
    text = ''
      nix build .#default 2>&1 | grep "got:" | sed 's/.*got: *//' || true
    '';
  };
};
```

## Local Machine Setup (One-Time)

Rewrite HTTPS Go module URLs to SSH so `go mod download` uses your keys:

```bash
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

Without this, Go tries HTTPS and fails with `could not read Username`.

## Why Other Approaches Fail

| Approach                               | Why not                                                         |
| -------------------------------------- | --------------------------------------------------------------- |
| Committed `vendor/`                    | Massive diffs, stale deps, merge conflicts, repo bloat          |
| `--impure` builds                      | Destroys reproducibility and caching                            |
| SSH keys in derivation                 | World-readable in `/nix/store`                                  |
| `overrideModAttrs` + netrc             | Requires `impureEnvVars`; token visible in process list         |
| Athens proxy                           | Infrastructure overhead                                         |
| `--sandbox-paths` netrc                | Manual file management; token in `/tmp`                         |
| `netrc-file` in `nix.conf`             | Does not work with `buildGoModule`                              |
| go-overlay                             | Third-party, not in nixpkgs, unproven                           |
| Raw `replace` directives in `preBuild` | Fails with "illegal path references in fixed-output derivation" |

## Gotcha Catalog

### 1. Public LarsArtmann repos

Some LarsArtmann repos are public. If a public repo is in `go.mod` but not in `deps`, set `validatePrivateDeps = false;`.

### 2. Transitive private deps

If private dep A depends on private dep B, B must also be a flake input. `mkPreparedSource` only injects the deps you explicitly list. Add all transitive private deps, or disable validation and accept that missing transitives will not be caught.

### 3. `tools/go.mod` (secondary modules)

If your project has a `tools/go.mod`, use `postPatchExtra` to inject replaces there too:

```nix
postPatchExtra = ''
  if [ -f tools/go.mod ]; then
    # Same replace directives for tools/go.mod
  fi
'';
```

### 4. `vendorHash` updates

Whenever deps change, set `vendorHash = pkgs.lib.fakeHash;` and run `nix build .#default` again to get the new hash.

### 5. `GOWORK` interaction

If using Go workspace mode, set `GOWORK = "off";` in devShells to prevent workspace resolution from interfering with module-based builds.

### 6. Mixed case in import paths

Go module paths are case-sensitive. `github.com/larsartmann/go-cqrs-lite` and `github.com/LarsArtmann/go-cqrs-lite` are different modules. `deps` map keys must match the exact case used in `go.mod`, and `GOPRIVATE` must cover both casings.

### 7. `GONOSUMDB` / `GONOSUMCHECK`

`GOPRIVATE` automatically implies `GONOSUMDB` and `GONOPROXY` for matching paths. Do not set them separately.

## Quick Reference Card

```bash
# Add a new private dep
# 1. Add flake input
# 2. Add to deps map in mkPreparedSource
# 3. nix flake update <dep-name>
# 4. nix build .#default → fix vendorHash

# Update all deps
nix flake update
nix build .#default  # may need new vendorHash

# Local dev
nix develop
go mod tidy
go build ./...

# Verify build
nix build .#default && nix flake check
```
