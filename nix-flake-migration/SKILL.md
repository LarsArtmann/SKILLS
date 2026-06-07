---
name: nix-flake-migration
description: Creates a migration proposal from justfile and shell scripts to nix flakes. Use when the user wants to plan or start migrating a project from justfile/makefile/shell scripts to nix flake-based build automation, or says "nix flake migration". Also use when converting from flake-utils/forEachSystem to flake-parts, adding treefmt-nix to an existing flake, or standardizing an ad-hoc flake to the ecosystem standard. Covers migration planning, standard stack adoption, and concrete flake templates.
metadata:
  tags: nix, flakes, migration, build, justfile, flake-parts, treefmt, standardization
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

| From | To | Key Changes |
|------|-----|-------------|
| `justfile` / `Makefile` | `flake.nix` | Commands become `apps` or `checks`; deps become `packages` |
| `flake-utils` / `forEachSystem` | `flake-parts` | Replace `eachDefaultSystem` with `flake-parts.lib.mkFlake` |
| Raw `flake.nix` | `flake-parts` + `treefmt-nix` | Add modules, extract per-system logic |
| No formatter | `treefmt-nix` | Add `imports`, configure `treefmt.programs` |
| No checks | Standard checks | Add `checks.format` + `checks.build` |
| `mkShell` CI | `mkShellNoCC` CI | Use `mkShellNoCC` for faster CI shells |

## Process

1. **Discovery**: Read existing build files (`justfile`, `Makefile`, `.sh` scripts, current `flake.nix`)
2. **Decision**: If `MIGRATION_TO_NIX_FLAKES_PROPOSAL.md` exists, STOP — do not overwrite. Otherwise proceed.
3. **Map commands**: Translate `just` recipes / `make` targets to Nix constructs:
   - Build → `packages.default` via `buildGoModule`
   - Test → `checks.test` (override `doCheck = true`)
   - Lint → `checks.format` via `treefmt`
   - Run → `apps.default`
   - Dev setup → `devShells.default`
   - CI → `devShells.ci` (minimal, `mkShellNoCC`)
4. **Write `flake.nix`** using the template below
5. **Remove `just` from devShell** — `justfile` is deprecated in this ecosystem
6. **Verify**: `nix flake check --no-build` must pass

## Go Project Template

Use this as the starting point for all Go project migrations:

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
              maintainers = [ maintainers.larsartmann ];
              mainProgram = "my-project";
            };
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [ goPkg gopls golangci-lint templ ];
            GOWORK = "off";
            GOPRIVATE = "github.com/larsartmann";
          };

          devShells.ci = pkgs.mkShellNoCC {
            packages = with pkgs; [ goPkg golangci-lint templ ];
            GOWORK = "off";
            GOPRIVATE = "github.com/larsartmann";
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
- [ ] `systems` input used (not hardcoded list)
- [ ] `checks.format` and `checks.build` defined
- [ ] `overlays.default` exported with correct naming
- [ ] `meta.maintainers` populated

## Common Pitfalls

- **vendorHash**: Start with `lib.fakeHash`, run `nix build`, copy the expected hash
- **Private Go deps**: Set `GOPRIVATE` in both default and CI devShells
- **templ projects**: Include `templ` in devShell packages and enable `templ` in treefmt
- **CGO projects**: Use `mkShell` (not `mkShellNoCC`) if `gcc` is needed; note in comments
- **Monorepos**: Use `inputsFrom` to compose devShells; set `projectRootFile` appropriately

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
