# Nix Best Practices Reference

Read this section when you need specific guidance on how to write excellent Nix code. Based on official Nix documentation, community best practices, and analysis of 88+ real production .nix files.

## Table of Contents

- [Flake Structure](#flake-structure)
- [Input Management](#input-management)
- [NixOS Module Structure](#nixos-module-structure)
- [Systemd Service Hardening](#systemd-service-hardening)
- [Source Filtering](#source-filtering)
- [Overlay Patterns](#overlay-patterns)
- [DevShell Patterns](#devshell-patterns)
- [Performance Patterns](#performance-patterns)
- [App Definitions](#app-definitions)

---

## Flake Structure

### The Ideal Go Project Flake

Based on 126+ projects standardized across 3 sessions. This is the canonical pattern.

```nix
{
  description = "Brief description of the project";

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

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
      ];

      perSystem = { config, pkgs, lib, ... }:
        let
          goPkg = pkgs.go_1_26;
          buildGoModule = pkgs.buildGoModule.override { go = goPkg; };
          version = self.rev or self.dirtyRev or "dev";
          vendorHash = "sha256-..."; # Single source of truth
        in
        {
          packages.default = buildGoModule {
            pname = "my-project";
            inherit version vendorHash;
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./go.mod
                ./go.sum
                ./main.go
                ./cmd
                ./internal
              ];
            };
            ldflags = [ "-s" "-w" "-X main.version=${version}" ];
            meta = with lib; {
              description = "Project description";
              license = licenses.mit;
              maintainers = [ maintainers.larsartmann ];
              mainProgram = "my-project";
            };
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              goPkg
              gopls
              golangci-lint
              templ
            ];
            GOWORK = "off";
            GOPRIVATE = "github.com/larsartmann";
          };

          devShells.ci = pkgs.mkShellNoCC {
            packages = with pkgs; [ goPkg golangci-lint templ ];
            GOWORK = "off";
            GOPRIVATE = "github.com/larsartmann";
          };

          treefmt.programs = {
            gofumpt.enable = true;
            goimports.enable = true;
            nixfmt.enable = true;
            templ.enable = true;
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

### Key Flake Principles

1. **Use `flake-parts`** for anything beyond a trivial single-package flake — it scales better than raw `eachDefaultSystem` or `flake-utils`
2. **Use `nix-systems/default`** for system lists — avoid hardcoding `["x86_64-linux" "aarch64-darwin"]`
3. **Always set `follows`** on inputs that use nixpkgs — prevents dependency duplication
4. **Standard stack for Go projects** — `flake-parts` + `treefmt-nix` + `systems` + `git-hooks-nix`
5. **Derive version from git** — `self.rev or self.dirtyRev or "dev"`
6. **Extract vendorHash to `let`** — single source of truth, not duplicated
7. **Pin Go version** — `goPkg = pkgs.go_1_26;` + `buildGoModule.override { go = goPkg; }`
8. **Define `formatter`** via `treefmt-nix` — `nixfmt` for Nix, `gofumpt`/`goimports` for Go, `templ` when applicable
9. **Define `checks`** — `checks.format = config.treefmt.build.check self;` + `checks.build = config.packages.default;`
10. **Export `overlays.default`** — `final: _prev: { project-name = self.packages.${final.stdenv.system}.default; }`
11. **Complete `meta`** — description, license, mainProgram, maintainers
12. **CI devShell** — `mkShellNoCC` with only build/test tools, no interactive tools
13. **`nixosModules` at top level** — `flake.nixosModules`, never inside `perSystem`

### Go Version Pinning Pattern

Always pin the Go version to avoid surprise breakages when nixpkgs updates.

```nix
perSystem = { config, pkgs, ... }:
  let
    goPkg = pkgs.go_1_26;
    buildGoModule = pkgs.buildGoModule.override { go = goPkg; };
  in
  {
    packages.default = buildGoModule { ... };

    devShells.default = pkgs.mkShellNoCC {
      packages = with pkgs; [ goPkg gopls golangci-lint ];
    };
  }
```

**Why**: `pkgs.go` changes silently when nixpkgs updates. Pinning ensures reproducible builds across time and machines.

---

## CI DevShell Pattern

A minimal devShell for CI that excludes interactive tools (gopls, editors) to reduce closure size and startup time.

```nix
devShells.ci = pkgs.mkShellNoCC {
  packages = with pkgs; [ goPkg golangci-lint templ ];
  GOWORK = "off";
  GOPRIVATE = "github.com/larsartmann";
};
```

**Rules**:
- Use `mkShellNoCC` — no C compiler needed for pure Go
- Only build/test tools in `packages`
- Propagate `GOPRIVATE` if project has private Go dependencies
- Include `templ` if the project uses templ templates
- Never include `gopls`, editors, or interactive tooling

---

## treefmt-nix Configuration

Standard formatter stack for Go projects:

```nix
treefmt = {
  projectRootFile = "go.mod";
  programs = {
    gofumpt.enable = true;
    goimports.enable = true;
    nixfmt.enable = true;
    templ.enable = true;  # when project uses templ
  };
};
```

**Notes**:
- `projectRootFile` should match the project's primary marker (`go.mod` for Go, `package.json` for Node, etc.)
- `templ.enable` only when the project has `.templ` files
- `nixfmt` (RFC 166 style) is the standard Nix formatter — never `nixpkgs-fmt`

---

## `nixosModules` Placement

NixOS modules must be at `flake.nixosModules`, never inside `perSystem`.

```nix
outputs = inputs @ { self, flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    # CORRECT — top level
    flake.nixosModules.default = import ./module.nix;

    perSystem = { config, pkgs, ... }: {
      # WRONG — modules are not per-system
      # nixosModules.default = ...;
    };
  };
```

**Why**: NixOS modules are system-agnostic configuration definitions. They are imported and evaluated by the target NixOS system, not by the flake's `perSystem`.

---

## Input Management

### follows Pattern

Every input that internally uses nixpkgs should follow your top-level nixpkgs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-parts = {
    url = "github:hercules-ci/flake-parts";
    inputs.nixpkgs-lib.follows = "nixpkgs";
  };
};
```

### Private Dependencies

For private Go repos, use the `overrideModAttrs` + `preBuild` pattern:

```nix
let
  dummyDep = pkgs.runCommand "dummy" {} "mkdir $out";
  realSrc = inputs.my-private-dep;
in
pkgs.buildGoModule {
  src = ./.;
  vendorHash = "sha256-...";

  overrideModAttrs = {
    preBuild = ''
      mkdir -p vendor/my-private-dep
      cp -r ${dummyDep}/* vendor/my-private-dep/
    '';
  };

  preBuild = ''
    rm -rf vendor/my-private-dep
    mkdir -p vendor/my-private-dep
    cp -r ${realSrc}/* vendor/my-private-dep/
  '';
}
```

### Input URL Formats

| Format                                  | Use When                      |
| --------------------------------------- | ----------------------------- |
| `"github:owner/repo"`                   | Public GitHub repos — fastest |
| `"github:owner/repo/ref"`               | Pin to branch/tag/commit      |
| `"git+ssh://git@github.com/owner/repo"` | Private repos                 |
| `"path:./relative"`                     | Local development only        |
| `"https://example.com/archive.tar.gz"`  | Tarball archives              |

**Avoid**: `path:/absolute/path` — non-portable, only works on your machine.

---

## NixOS Module Structure

### The Ideal Service Module

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.my-service;
in
{
  options.services.my-service = {
    enable = lib.mkEnableOption "My Service";

    package = lib.mkPackageOption pkgs "my-service" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = "my-service";
      description = "User account under which the service runs";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "TCP port the service listens on";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional settings passed to the service";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
      home = "/var/lib/my-service";
    };
    users.groups.${cfg.user} = {};

    systemd.services.my-service = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --port ${toString cfg.port}";
        User = cfg.user;
        Group = cfg.user;
        StateDirectory = "my-service";
        WorkingDirectory = "/var/lib/my-service";
      }
      // harden { MemoryMax = "512M"; }
      // serviceDefaults {};
    };

    assertions = [
      {
        assertion = cfg.port > 0;
        message = "Port must be positive";
      }
    ];
  };
}
```

### Module Design Principles

1. **Always use `cfg = config.services.*`** — shorter, clearer references
2. **Always declare `type`** — prevents silent type coercion bugs
3. **Always add `description`** — `nixos-option` and documentation need it
4. **Use `mkPackageOption`** for package options — provides default, description, example
5. **Wrap config in `mkIf cfg.enable`** — don't activate services unless explicitly enabled
6. **Add `assertions`** for cross-option constraints — catch configuration errors at build time
7. **Use `lib.mkMerge`** to compose `serviceConfig` from multiple sources (base + hardening + defaults)
8. **Never hardcode usernames** — always make them configurable via options

---

## Systemd Service Hardening

### Baseline Hardening Template

Every long-running service should apply these directives. Use `systemd-analyze security <service>` to verify.

```nix
{
  # Filesystem protection
  ProtectSystem = "full";     # /boot, /etc, /usr read-only
  ProtectHome = "yes";        # /home, /root, /run/user as tmpfs
  PrivateTmp = true;          # Private /tmp and /var/tmp

  # Kernel protection
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectKernelLogs = true;
  ProtectControlGroups = true;
  ProtectClock = true;

  # Device access
  PrivateDevices = true;      # No physical devices

  # Privilege escalation prevention
  NoNewPrivileges = true;
  RestrictSUIDSGID = true;

  # Process restrictions
  RestrictNamespaces = "yes";
  LockPersonality = true;
  MemoryDenyWriteExecute = true;
  RestrictRealtime = true;

  # Syscall filtering
  SystemCallArchitectures = "native";
  SystemCallFilter = "~@clock @cpu-emulation @debug @obsolete @module @mount @raw-io @reboot @swap";

  # Capability restrictions
  CapabilityBoundingSet = "~CAP_SYS_TIME CAP_SYS_ADMIN CAP_NET_RAW";
}
```

### Network Service Additions

For services that need network access:

```nix
{
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
  # If binding to privileged ports (< 1024):
  AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
}
```

### Service Defaults (Restart Behavior)

```nix
{
  Restart = "always";
  RestartSec = "5s";
  StartLimitBurst = 3;
  StartLimitIntervalSec = 60;
}
```

### When to Disable Hardening

Only disable a directive when the service genuinely cannot function without it. Always document why:

```nix
{
  ProtectHome = false; # Needs to read user config files in /home
  ProtectSystem = false; # Needs to write to /etc/machine-id
}
```

---

## Source Filtering

### Modern Approach: `lib.fileset`

```nix
# Precise, composable, efficient
src = lib.fileset.toSource {
  root = ./.;
  fileset = lib.fileset.unions [
    ./go.mod
    ./go.sum
    ./main.go
    ./internal
    ./cmd
  ];
};
```

### Git-Tracked Source (Only Committed Files)

```nix
src = lib.fileset.toSource {
  root = ./.;
  fileset = lib.fileset.gitTracked ./.;
};
```

### Legacy Approach: `cleanSourceWith`

```nix
# Still common, but prefer fileset for new code
src = pkgs.lib.cleanSourceWith {
  src = pkgs.lib.cleanSource ./.;
  filter = name: type:
    let baseName = baseNameOf name;
    in
      pkgs.lib.hasSuffix ".go" name ||
      baseName == "go.mod" ||
      baseName == "go.sum";
};
```

### Reusable Source Filter Function

```nix
mkSrc = { root, suffixes }:
  pkgs.lib.cleanSourceWith {
    src = pkgs.lib.cleanSource root;
    filter = name: _type:
      any (suf: pkgs.lib.hasSuffix suf name) suffixes ||
      baseNameOf name == "go.mod" ||
      baseNameOf name == "go.sum";
  };
```

### Fixed Store Path Name

```nix
# Without this, the store path includes the parent directory name
src = builtins.path {
  path = ./.;
  name = "myproject";
};
```

---

## Overlay Patterns

### Overlay-First Pattern (for Reusable Packages)

Define the overlay first, then use it everywhere:

```nix
let
  overlay = final: _prev: {
    my-tool = self.packages.${final.stdenv.system}.default;
  };
in
{
  overlays.default = overlay;

  packages = pkgs.lib.genAttrs supportedSystems (system:
    let pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
    in { default = pkgs.my-tool; }
  );
}
```

### Overlay `final`/`prev` Rules

| Context                        | Use                | Why                       |
| ------------------------------ | ------------------ | ------------------------- |
| Overriding an existing package | `prev.package`     | Avoids infinite recursion |
| Referencing dependencies       | `final.dependency` | Respects other overlays   |
| Adding new packages            | `prev.callPackage` | Standard pattern          |
| System reference               | `final.stdenv.system` | Correct system in overlay context |
| Unused parameter               | `_prev`            | Signals `prev` is intentionally ignored |

```nix
final: _prev: {
  # New package from flake's own packages — use final for system ref
  my-project = self.packages.${final.stdenv.system}.default;
}
```

### Overlay Naming Convention

The overlay attribute name should match the project directory name for clarity:

```nix
# Directory: my-project/
# CORRECT
flake.overlays.default = final: _prev: {
  my-project = self.packages.${final.stdenv.system}.default;
};

# WRONG — confusing mismatch
flake.overlays.default = final: _prev: {
  my-server = self.packages.${final.stdenv.system}.default;
};
```

**Exception**: When the binary name intentionally differs from the directory name (e.g., `index` directory produces `indexer` binary), document the mismatch in a comment.

### Scoped Overlays (for Package Sets)

```nix
final: prev: {
  gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
    mutter = gnomePrev.mutter.overrideAttrs (old: {
      patches = old.patches ++ [ ./mutter-fix.patch ];
    });
  });
}
```

---

## DevShell Patterns

### Minimal DevShell

```nix
devShells.default = pkgs.mkShellNoCC {
  packages = with pkgs; [ goPkg gopls golangci-lint ];
  GOWORK = "off";
};
```

### DevShell Without C Compiler

```nix
# Faster shell entry when no C/C++ compilation needed
devShells.default = pkgs.mkShellNoCC {
  packages = with pkgs; [ nodejs yarn ];
};
```

### Composed DevShell with inputsFrom

```nix
devShells.full = pkgs.mkShellNoCC {
  inputsFrom = [ config.devShells.frontend config.devShells.backend ];
  packages = with pkgs; [ just ];
};
```

### CI DevShell (Minimal)

```nix
devShells.ci = pkgs.mkShellNoCC {
  packages = with pkgs; [ goPkg golangci-lint templ ];
  GOWORK = "off";
  GOPRIVATE = "github.com/larsartmann";
};
```

### DevShell Best Practices

1. Use `packages` (not `buildInputs`) for tools
2. Use `mkShellNoCC` when no C compiler needed (most Go projects)
3. Keep `shellHook` lightweight — no network access, no heavy installs
4. Use `inputsFrom` to compose shells in monorepos
5. Export environment variables as direct attributes (`GOWORK = "off"`) not in shellHook
6. Create a separate `ci` devShell with only build/test tools
7. Propagate `GOPRIVATE` to CI devShell when project has private Go dependencies
8. Include `templ` in CI devShell when project uses templ templates

---

## Performance Patterns

### Avoid IFD (Import From Derivation)

```nix
# SLOW - blocks evaluation until build completes
let
  version = builtins.readFile (pkgs.runCommand "version" {} ''
    echo "1.0.0" > $out
  '');
in ...

# FAST - evaluation and building separate
let
  versionFile = pkgs.runCommand "version" {} ''
    echo "1.0.0" > $out
  '';
in
pkgs.runCommand "app" { inherit versionFile; } ''
  cp $versionFile $out
''
```

### Enable Evaluation Caching

```bash
nix flake check --eval-cache
```

### Enable Store Optimization

```nix
nix.settings.auto-optimise-store = true;
```

### Reuse `goModules` in Checks

```nix
perSystem = { config, pkgs, ... }:
  let
    goPkg = pkgs.go_1_26;
    buildGoModule = pkgs.buildGoModule.override { go = goPkg; };
    pkg = buildGoModule {
      vendorHash = "sha256-...";
      # ...
    };
  in
  {
    packages.default = pkg;

    checks = {
      format = config.treefmt.build.check self;
      build = pkg;
      test = pkg.overrideAttrs (_: {
        doCheck = true;
      });
    };
  };
```

---

## App Definitions

### Use `writeShellApplication` for Safety

```nix
apps.deploy = {
  type = "app";
  program = pkgs.writeShellApplication {
    name = "deploy";
    runtimeInputs = with pkgs; [ gcloud jq ];
    text = ''
      gcloud run deploy --source .
    '';
  };
};
```

**Benefits**: Proper runtime isolation, input validation, no PATH pollution.

### Use `lib.getExe` for Package References

```nix
# Instead of string interpolation
ExecStart = "${pkgs.my-service}/bin/my-service";

# Use getExe for type safety
ExecStart = lib.getExe pkgs.my-service;
```
