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
  };

  outputs = inputs @ { self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem = { config, pkgs, ... }:
        let
          version = self.rev or self.dirtyRev or "dev";
          vendorHash = "sha256-..."; # Single source of truth
        in
        {
          packages.default = pkgs.buildGoModule {
            pname = "my-project";
            inherit version vendorHash;
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./go.mod ./go.sum ./main.go ./internal
              ];
            };
            ldflags = [ "-s" "-w" "-X main.version=${version}" ];
            meta = with pkgs.lib; {
              description = "Project description";
              license = licenses.mit;
              mainProgram = "my-project";
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ go gopls golangci-lint ];
            GOWORK = "off";
          };

          checks = {
            build = config.packages.default;
            test = config.packages.default.overrideAttrs (_: { doCheck = true; });
          };
        };

      flake.overlays.default = final: prev: {
        my-project = final.callPackage ./package.nix { };
      };
    };
}
```

### Key Flake Principles

1. **Use `flake-parts`** for anything beyond a trivial single-package flake — it scales better than raw `eachDefaultSystem`
2. **Use `nix-systems/default`** for system lists — avoid hardcoding `["x86_64-linux" "aarch64-darwin"]`
3. **Always set `follows`** on inputs that use nixpkgs — prevents dependency duplication
4. **Derive version from git** — `self.rev or self.dirtyRev or "dev"`
5. **Extract vendorHash to `let`** — single source of truth, not duplicated
6. **Define `formatter`** — `nixfmt` or `treefmt-nix`
7. **Define `checks`** — at minimum build and test
8. **Export `overlays.default`** — enables consumption by other flakes
9. **Complete `meta`** — description, license, mainProgram

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

| Format | Use When |
|--------|----------|
| `"github:owner/repo"` | Public GitHub repos — fastest |
| `"github:owner/repo/ref"` | Pin to branch/tag/commit |
| `"git+ssh://git@github.com/owner/repo"` | Private repos |
| `"path:./relative"` | Local development only |
| `"https://example.com/archive.tar.gz"` | Tarball archives |

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
  overlay = final: prev: {
    my-tool = final.callPackage ./package.nix { };
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

| Context | Use | Why |
|---------|-----|-----|
| Overriding an existing package | `prev.package` | Avoids infinite recursion |
| Referencing dependencies | `final.dependency` | Respects other overlays |
| Adding new packages | `prev.callPackage` | Standard pattern |

```nix
final: prev: {
  # Override existing — use prev
  hello = prev.hello.overrideAttrs (old: { patches = old.patches ++ [ ./fix.patch ]; });

  # New package depending on other overlays — use final
  myApp = prev.callPackage ./my-app.nix { boost = final.boost185; };
}
```

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
devShells.default = pkgs.mkShell {
  packages = with pkgs; [ go gopls golangci-lint ];
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
devShells.full = pkgs.mkShell {
  inputsFrom = [ self.devShells.x86_64-linux.frontend ];
  packages = with pkgs; [ just ];
};
```

### CI DevShell (Minimal)

```nix
devShells.ci = pkgs.mkShell {
  packages = with pkgs; [ go golangci-lint ];
  # No interactive tools — smaller closure, faster
};
```

### DevShell Best Practices

1. Use `packages` (not `buildInputs`) for tools
2. Use `mkShellNoCC` when no C compiler needed
3. Keep `shellHook` lightweight — no network access, no heavy installs
4. Use `inputsFrom` to compose shells in monorepos
5. Export environment variables as direct attributes (`GOWORK = "off"`) not in shellHook
6. Create a separate `ci` devShell with only build/test tools

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
    pkg = pkgs.buildGoModule {
      vendorHash = "sha256-...";
      # ...
    };
  in
  {
    packages.default = pkg;

    checks.test = pkg.overrideAttrs (_: {
      doCheck = true;
    });
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
