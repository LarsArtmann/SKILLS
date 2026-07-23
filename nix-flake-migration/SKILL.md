---
name: nix-flake-migration
description: Creates a migration proposal from justfile and shell scripts to nix flakes. Use when the user wants to plan or start migrating a project from justfile/makefile/shell scripts to nix flake-based build automation, or says "nix flake migration". Also use when converting from flake-utils/forEachSystem to flake-parts, adding treefmt-nix to an existing flake, or standardizing an ad-hoc flake to the ecosystem standard. Covers migration planning, standard stack adoption, and concrete flake templates.
metadata:
  tags: nix, flakes, migration, build, justfile, flake-parts, treefmt, standardization, go-nix-helpers, go-standard
allowed-tools: bash view edit write grep
---

# Nix Flake Migration

Migrate projects to the standard Nix flake stack. Based on patterns validated across 126+ projects.

## Standard Stack

The ecosystem standard for Go projects:

- `flake-parts` (not `flake-utils` or raw `eachDefaultSystem`)
- `treefmt-nix` with `nixfmt`, `gofumpt`, `goimports`, `templ`
- `systems` input (not hardcoded system lists)
- `git-hooks.nix` for pre-commit hooks
- `nixos-unstable` channel (not `nixpkgs-unstable`, unless nix-darwin system flake)

## Migration Types

| From                            | To                            | Key Changes                                                |
| ------------------------------- | ----------------------------- | ---------------------------------------------------------- |
| `justfile` / `Makefile`         | `flake.nix`                   | Commands become `apps` or `checks`; deps become `packages` |
| `flake-utils` / `forEachSystem` | `flake-parts`                 | Replace `eachDefaultSystem` with `flake-parts.lib.mkFlake` |
| Raw `flake.nix`                 | `flake-parts` + `treefmt-nix` | Add modules, extract per-system logic                      |
| **Manual 5-input flake.nix**    | **`go-standard` module**      | **Replace 80+ lines with `imports + go-standard = { ... }`** |
| No formatter                    | `treefmt-nix`                 | Add `imports`, configure `treefmt.programs`                |
| No checks                       | Standard checks               | Add `checks.format` + `checks.build`                       |
| `mkShell` CI                    | `mkShellNoCC` CI              | Use `mkShellNoCC` for faster CI shells                     |

## Process

1. **Discovery**: Read existing build files (`justfile`, `Makefile`, `.sh` scripts, current `flake.nix`)
2. **Decision**: If `docs/proposals/nix-flake-migration.html` or any `docs/proposals/<YYYY-MM-DD_nix-flake-migration.html` exists, STOP — do not overwrite. Otherwise proceed.
3. **Check for go-nix-helpers**: If this is a LarsArtmann Go project, check whether it already uses `flakeModules.go-standard`. If not, recommend migrating to the 3-input pattern (see below). Only use the full manual template for non-LarsArtmann projects or those needing full control.
4. **Map commands**: Translate `just` recipes / `make` targets to Nix constructs:
   - Build → `packages.default` via `buildGoModule`
   - Test → `checks.test` (override `doCheck = true`)
   - Lint → `checks.format` via `treefmt`
   - Run → `apps.default`
   - Dev setup → `devShells.default`
   - CI → `devShells.ci` (minimal, `mkShellNoCC`)
5. **Write proposal** as a self-contained styled HTML file at `docs/proposals/<YYYY-MM-DD_nix-flake-migration.html`. Load the shared design system from [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md) and copy [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html). Include: migration type (from the table above), before/after comparison of build commands, the full `flake.nix` template with Nix syntax highlighting (`.tok-*` classes), and the post-migration checklist as badge-coded items.
6. **Write `flake.nix`** using the template below
7. **Remove `just` from devShell** — `justfile` is deprecated in this ecosystem
8. **Verify**: `nix flake check --no-build` must pass

## Go Project Template

### LarsArtmann Go projects: use `flakeModules.go-standard` (3 inputs, ~20 lines)

The `go-nix-helpers` repository provides a shared flake-parts module that bundles
treefmt-nix and systems internally. Consumers need only **3 inputs** instead of 5.

This is the **recommended** approach for all LarsArtmann Go projects. It generates:
packages, apps (default/test/lint), devShells (default/ci), checks, treefmt,
overlay, private dep injection (mkPreparedSource), and GOPRIVATE auto-injection.

```nix
{
  description = "Project description";

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
  };

  outputs = inputs@{ self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.go-nix-helpers.flakeModules.go-standard ];

      go-standard = {
        pname = "my-project";
        vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        description = "What this project does";
      };
    };
}
```

That's the **entire** flake.nix. No perSystem boilerplate, no treefmt-nix input,
no systems input. See [go-nix-helpers README](https://github.com/LarsArtmann/go-nix-helpers)
for all options (enableTempl, deps, ldflags, extraBuildAttrs, etc.).

### Non-LarsArtmann or manual projects: full template

For projects outside the LarsArtmann ecosystem, or those needing full manual control,
use this template. It requires 5 inputs and ~80 lines of perSystem config:

```nix
{
  description = "Project description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.treefmt-nix.flakeModule inputs.git-hooks.flakeModule ];

      perSystem = { config, pkgs, lib, ... }:
        let
          goPkg = pkgs.go_1_26;
          buildGoModule = pkgs.buildGoModule.override { go = goPkg; };
          version = self.rev or self.dirtyRev or "dev";
          vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # run `nix build` to get real hash
        in
        {
          packages.default = buildGoModule {
            pname = "my-project";
            inherit version vendorHash;
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./go.mod ./go.sum ./cmd ./internal
              ];
            };
            ldflags = [ "-s" "-w" "-X main.version=${version}" ];
            meta = with lib; {
              description = "...";
              license = licenses.mit;
              maintainers = [ maintainers.{maintainer} ];
              mainProgram = "my-project";
            };
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [ goPkg gopls golangci-lint templ ];
            GOWORK = "off";
            GOPRIVATE = "github.com/{maintainer}";
          };

          devShells.ci = pkgs.mkShellNoCC {
            packages = with pkgs; [ goPkg golangci-lint templ ];
            GOWORK = "off";
            GOPRIVATE = "github.com/{maintainer}";
          };

          treefmt = {
            projectRootFile = "go.mod";
            programs = {
              gofumpt.enable = true;
              goimports.enable = true;
              nixfmt.enable = true;
              templ.enable = true;
            };
          };

          checks = {
            format = config.treefmt.build.check self;
            build = config.packages.default;
          };
        };

      flake.overlays.default = final: _prev: {
        my-project = self.packages.${final.stdenv.system}.default;
      };
    };
}
```

## Post-Migration Checklist

- [ ] `nix flake check --no-build` passes
- [ ] `nix build` produces the expected output
- [ ] `nix develop` enters the devShell successfully
- [ ] `nix fmt` formats all files correctly
- [ ] `just` removed from devShell (if present)
- [ ] `go_1_26` pinned via `goPkg` variable
- [ ] `checks.format` and `checks.build` defined
- [ ] `overlays.default` exported with correct naming
- [ ] `meta.maintainers` populated
- [ ] **LarsArtmann projects**: using `flakeModules.go-standard` (3 inputs, not 5)
- [ ] **LarsArtmann projects**: `inputs.nixpkgs.follows` set on go-nix-helpers

## Common Pitfalls

- **vendorHash**: Start with `lib.fakeHash`, run `nix build`, copy the expected hash
- **Private Go deps**: Set `GOPRIVATE` in both default and CI devShells
- **templ projects**: Include `templ` in devShell packages and enable `templ` in treefmt
- **CGO projects**: Use `mkShell` (not `mkShellNoCC`) if `gcc` is needed; note in comments
- **Monorepos**: Use `inputsFrom` to compose devShells; set `projectRootFile` appropriately
