# Common Nix Problems Catalogue

This reference documents real problems found across Nix codebases and community best practices, organized by category. Read this when evaluating specific aspects of a flake or NixOS module.

## Table of Contents

- [Critical Issues (Build Breakers)](#critical-issues-build-breakers)
- [Purity & Reproducibility](#purity--reproducibility)
- [Structural Issues](#structural-issues)
- [Correctness Issues](#correctness-issues)
- [Consistency Issues](#consistency-issues)
- [NixOS Module Issues](#nixos-module-issues)
- [Secret Management Issues](#secret-management-issues)
- [Source Management Issues](#source-management-issues)
- [Performance Issues](#performance-issues)
- [Overlay Issues](#overlay-issues)
- [DevShell Issues](#devshell-issues)
- [Systemd Hardening Issues](#systemd-hardening-issues)
- [Ecosystem Standardization Issues (Session 3 Findings)](#ecosystem-standardization-issues-session-3-findings)

---

## Critical Issues (Build Breakers)

### 1. Placeholder/Fake Hashes

Flakes that won't build because hashes are placeholders.

```nix
# BROKEN - placeholder hash
vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
# BROKEN - fake hash
vendorHash = pkgs.lib.fakeHash;
# BROKEN - empty when deps exist
vendorHash = "";
```

**Fix**: Run `nix build`, copy the expected hash from the error message. For `null` vendor hash (no deps), only use when the project truly has zero Go dependencies.

### 2. Impure Constructs in Build Derivations

Anything that reaches outside the Nix sandbox breaks reproducibility.

```nix
# BROKEN - reads HOME at build time
GOPATH = builtins.getEnv "HOME";
# BROKEN - network access during build
preBuild = "go install github.com/some/tool@latest";
# BROKEN - pip install at deploy time
ExecStartPre = "${pip} install structlog";
```

**Fix**: All build-time dependencies must be declared as Nix derivations. Use `buildGoModule`, `callPackage`, or explicit `fetchurl`/`fetchTarball`.

### 3. Hardcoded Absolute Local Paths

Completely non-portable — only works on one machine.

```nix
# BROKEN - only works for one user on one machine
inputs.cmdguard = { url = "path:/home/lars/projects/cmdguard"; flake = false; };
```

**Fix**: Use `git+ssh://` for private repos, or `path:./relative-path` for local development with a fallback.

---

## Purity & Reproducibility

### 4. `<nixpkgs>` Lookup Paths

Lookup paths depend on system state (`$NIX_PATH`) — different results on different machines.

```nix
# ANTI-PATTERN - depends on $NIX_PATH
import <nixpkgs> {}
```

**Fix**: Use flake inputs. If you must use `import`, always pass explicit `config` and `overlays`:

```nix
# Acceptable with explicit config
import nixpkgs { config = {}; overlays = []; }
```

### 5. Unquoted URLs

RFC 45 deprecates unquoted URLs — they cause subtle parsing issues.

```nix
# ANTI-PATTERN
url = github:user/repo;
# CORRECT
url = "github:user/repo";
```

### 6. `builtins.path` vs Bare Paths

Without `builtins.path`, the derivation depends on the parent directory name — breaks reproducibility.

```nix
# ANTI-PATTERN - parent directory name leaks into store path
src = ./.;
# CORRECT - fixed store path name
src = builtins.path { path = ./.; name = "myproject"; };
```

### 7. IFD (Import From Derivation)

Using `builtins.readFile`, `builtins.import`, or `builtins.hashFile` on a derivation output blocks evaluation. Nix evaluation is single-threaded, so IFD serializes everything.

```nix
# ANTI-PATTERN - blocks evaluation until build completes
let
  generatedConfig = pkgs.runCommand "config" {} ''
    echo "some_value = 42" > $out
  '';
  configValue = builtins.readFile generatedConfig;  # IFD!
in
pkgs.writeText "app-config" configValue
```

```nix
# CORRECT - evaluation and building stay separate
let
  generatedConfig = pkgs.runCommand "config" {} ''
    echo "some_value = 42" > $out
  '';
in
pkgs.runCommand "app-config" { inherit generatedConfig; } ''
  cp $generatedConfig $out
''
```

### 8. Shallow `//` Merge on Nested Attrs

The `//` operator is shallow — it replaces entire nested attribute sets rather than merging them.

```nix
# BROKEN - loses { b = 1; }
{ a = { b = 1; }; } // { a = { c = 3; }; }
# Result: { a = { c = 3; }; }  -- b is gone!
```

**Fix**: Use `lib.recursiveUpdate` for deep merging, or `lib.mkMerge` in module contexts.

---

## Structural Issues

### 9. Re-instantiating nixpkgs

Each `import nixpkgs {}` creates a separate evaluation — slow and can cause inconsistencies.

```nix
# ANTI-PATTERN - re-instantiates nixpkgs per system
eachDefaultSystem (system: let pkgs = import nixpkgs { inherit system; }; in ...)
```

```nix
# CORRECT - use the existing instance
eachDefaultSystem (system: let pkgs = nixpkgs.legacyPackages.${system}; in ...)
```

**Exception**: Explicit re-instantiation is OK when you need custom `config` (e.g., `allowUnfree`), but document why.

### 10. Duplicated vendorHash

When the same hash appears in multiple derivations, updates require changing multiple locations.

```nix
# ANTI-PATTERN - same hash in two places
packages.server = buildGoModule { vendorHash = "sha256-abc..."; };
checks.test = buildGoModule { vendorHash = "sha256-abc..."; };
```

```nix
# CORRECT - extract to a let binding
let vendorHash = "sha256-abc...";
in {
  packages.server = buildGoModule { inherit vendorHash; };
  checks.test = buildGoModule { inherit vendorHash; };
}
```

### 11. Monolithic Files

Files over ~300 lines should be split. Real examples found:

- 872 lines: niri compositor config (should be 5+ files)
- 755 lines: SystemNix flake.nix (overlays should be extracted)
- 741 lines: SigNoz service (should be split by component)
- 550 lines: Gitea service (should be split into server/repos/runner)
- 439 lines: projects-management-automation flake.nix (should use flake-parts modules)
- 433 lines: Yazi file manager config (should use external files)

### 12. Overlay Duplication Across Contexts

When the same overlay is defined in two separate lists, they can drift.

```nix
# ANTI-PATTERN - same overlay in two places
sharedOverlays = [ (final: prev: { myTool = ...; }) ];
perSystem._module.args.pkgs = import nixpkgs {
  overlays = [ (final: prev: { myTool = ...; }) ]; # MUST stay in sync
};
```

**Fix**: Define overlays once in a shared `let` binding or use flake-parts' native overlay module.

### 13. Missing `meta` Section

Package derivations without `meta` lack discoverability and documentation.

```nix
# ANTI-PATTERN - no metadata
packages.default = pkgs.buildGoModule { ... };
```

```nix
# CORRECT - complete meta
packages.default = pkgs.buildGoModule {
  ...
  meta = with pkgs.lib; {
    description = "Brief description";
    homepage = "https://github.com/user/repo";
    license = licenses.mit;
    mainProgram = "my-binary";
    maintainers = [ maintainers.myself ];
  };
};
```

---

## Correctness Issues

### 14. Wrong Systemd Option Types

Systemd expects specific string values, not booleans.

```nix
# BROKEN - systemd expects strings
ProtectHome = true;       # Should be "yes", "no", "read-only", or "tmpfs"
RestrictNamespaces = true; # Should be "yes", "no", or specific namespaces
```

```nix
# CORRECT
ProtectHome = "yes";
RestrictNamespaces = "yes";
```

### 15. Disabled Security Hardening

Overriding sandbox options to `false` should have documented justification.

```nix
# WEAKENING - must be justified with a comment
ProtectHome = false;
ProtectSystem = false;
NoNewPrivileges = lib.mkForce false;
```

**Review criterion**: Every `= false` on a security option needs a comment explaining why it's necessary for that specific service.

### 16. Race Conditions in ExecStartPre/ExecStartPost

Scripts that depend on services not yet ready.

```nix
# FRAGILE - token might not exist yet
ExecStartPre = "${cfg.package}/bin/generate-token";
ExecStart = "${cfg.package}/bin/use-token";
```

**Fix**: Use `BindsTo` + `After` ordering, or `ExecStartPre` with retry loops, or separate systemd dependencies.

### 17. `version` Hardcoded Instead of Git-Derived

Hardcoded versions become stale and don't reflect actual code state.

```nix
# ANTI-PATTERN
version = "0.1.0";
```

```nix
# CORRECT
version = self.rev or self.dirtyRev or "dev";
```

---

## Consistency Issues

### 18. Inconsistent Formatter Choice

Multiple formatters across projects defeats the purpose.

| Formatter                | Status                                   |
| ------------------------ | ---------------------------------------- |
| `nixfmt` (RFC 166 style) | **Recommended** — Nix project official   |
| `alejandra`              | Acceptable but declining — prefer nixfmt |
| `nixpkgs-fmt`            | Deprecated — migrate to nixfmt           |
| None                     | **Must add**                             |

### 19. Inconsistent nixpkgs Channel

Some projects use `nixos-unstable`, others `nixpkgs-unstable`. These are different channels.

```nix
# Inconsistent across projects
url = "github:NixOS/nixpkgs/nixos-unstable";   # NixOS channel
url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # Standalone channel
```

**Fix**: Standardize on one. `nixos-unstable` has more packages and is more tested.

### 20. Missing `checks` or `formatter`

Every flake should define at minimum:

- `formatter` (use `nixfmt` or `treefmt-nix`)
- `checks` (format check, build check, test)

### 21. Missing `follows` for Shared Inputs

Without `follows`, each input brings its own nixpkgs — duplicated dependencies, bloated closure.

```nix
# ANTI-PATTERN - each input has its own nixpkgs
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager";
  treefmt-nix.url = "github:numtide/treefmt-nix";
};
```

```nix
# CORRECT - single nixpkgs instance
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

---

## NixOS Module Issues

### 22. Hardcoded Usernames

The username `lars` (or any specific name) appearing in NixOS modules makes them non-reusable.

```nix
# ANTI-PATTERN
users.users.lars = { ... };
systemd.services.myapp.Service.User = "lars";
```

**Fix**: Create an option `services.myapp.user` with a default, or use `config.users.users.${cfg.user}`.

### 23. Missing Option Types

Options without `type` accept any value — bugs hide until runtime.

```nix
# ANTI-PATTERN - no type
options.myService.port = lib.mkOption { default = 8080; };
```

```nix
# CORRECT
options.myService.port = lib.mkOption {
  type = lib.types.port;
  default = 8080;
  description = "Port the service listens on";
};
```

### 24. Relative Path Fragility

Deep relative imports break when files move.

```nix
# FRAGILE - breaks if this file moves
import ./../../../lib/systemd.nix
```

**Fix**: Use module system imports or `inputs.self.outPath`-based paths. At minimum, document the dependency clearly.

### 25. Double Import / Redundant Module Loading

Importing the same module from multiple places is confusing even though Nix deduplicates.

```nix
# In home-base.nix
imports = [ ./programs/fish.nix ./programs/bash.nix ];
# Also in darwin/programs/shells.nix
imports = [ ../../common/programs/fish.nix ../../common/programs/bash.nix ];
```

**Fix**: Import each module in exactly one place. Use the module system's natural composition.

### 26. Missing Assertions

Options with constraints (port ranges, required co-services) should validate at build time.

```nix
# CORRECT
assertions = [
  {
    assertion = cfg.port >= 1024 && cfg.port <= 65535;
    message = "Port must be in range 1024-65535, got ${toString cfg.port}";
  }
  {
    assertion = cfg.enable -> config.services.database.enable;
    message = "${moduleName} requires the database service to be enabled";
  }
];
```

### 27. Missing `mkPackageOption` for Package Options

When a module takes a package parameter, use `mkPackageOption` for consistency.

```nix
# ANTI-PATTERN
options.myService.package = lib.mkOption {
  type = lib.types.package;
  default = pkgs.myService;
};
```

```nix
# CORRECT - provides default, description, and example automatically
options.myService.package = lib.mkPackageOption pkgs "myService" { };
```

---

## Secret Management Issues

### 28. Secrets in Plain Text

SSH keys, API keys, passwords in Nix configs are visible in the Nix store.

```nix
# DANGEROUS - visible in /nix/store (world-readable)
syncEncryptionSecret = builtins.hashString "sha256" "known-string";
apiKey = "sk-...";
hashedPassword = "$argon2id$v=19$m=...";
```

**Fix**: Use `sops-nix`, `agenix`, or `pass` for all secrets. The Nix store is world-readable.

### 29. Inconsistent Secret Management

Some secrets via sops, some hardcoded, some in plaintext files.

**Fix**: Establish one secrets strategy project-wide. Document it in the project README or AGENTS.md.

### 30. Sensitive Infrastructure in Nix Configs

IPs, hostnames, and internal network topology in Nix files reveal infrastructure details.

```nix
# ANTI-PATTERN - infrastructure details in source control
services.caddy.virtualHosts."internal.company.com" = {
  serverName = "192.168.1.100";
};
```

**Fix**: Move infrastructure details to sops templates or generated configs.

---

## Source Management Issues

### 31. `rec` Attrset Anti-Pattern

`rec` makes dependencies implicit — hard to read and can cause surprising evaluation order issues and infinite recursion.

```nix
# ANTI-PATTERN
rec {
  a = 1;
  b = a + 2; # implicit dependency on a
}
```

```nix
# CORRECT - explicit dependencies
let
  a = 1;
  b = a + 2;
in { inherit a b; }
```

### 32. `with` Statement Anti-Pattern

`with` breaks static analysis, makes variable sources unclear, and has non-intuitive scoping (the `with` scope is not available inside function arguments).

```nix
# ANTI-PATTERN - where does curl come from?
with pkgs; [ curl jq git ]

# WORSE - top-level with spans entire file
with (import <nixpkgs> {});
# ... 200 lines of code ...
```

```nix
# CORRECT - explicit imports
buildInputs = builtins.attrValues {
  inherit (pkgs) curl jq git;
};
```

**Exception**: `with pkgs;` inside a small, scoped list is acceptable.

### 33. `builtins.readFile` for Dynamic Configs

Reading files at evaluation time that might not exist — also triggers IFD if the path is a derivation.

```nix
# FRAGILE - fails if file is missing
plugins = builtins.readFile ./plugins/.plugins-list;
```

**Fix**: Use `lib.filesystem.listFilesRecursive` or declare the list explicitly.

### 34. `builtins.getEnv` in Derivations

Environment variables are impure — different results on different machines.

```nix
# IMPURE
HOME = builtins.getEnv "HOME";
```

**Fix**: Use explicit paths or pass values as derivation arguments.

### 35. Not Using `lib.fileset` for Source Filtering

The modern `lib.fileset` API is more efficient and compositional than `lib.sources` or raw `cleanSource`.

```nix
# OLD WAY - limited filtering
src = lib.sources.cleanSource ./.;

# MODERN WAY - precise, composable
src = lib.fileset.toSource {
  root = ./.;
  fileset = lib.fileset.unions [
    ./go.mod
    ./go.sum
    ./main.go
    ./internal
  ];
};
```

**Benefit**: Only copies files you need, reducing cache invalidation and build times.

---

## Performance Issues

### 36. Excessive `mkIf` Wrapping

Unnecessary `mkIf` adds overhead for simple boolean assignments.

```nix
# ANTI-PATTERN
services.myService.enable = mkIf cfg.enable true;

# CORRECT - direct assignment
services.myService.enable = cfg.enable;
```

### 37. No Garbage Collection Configuration

Without GC, the Nix store grows unbounded.

```nix
# CORRECT
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};
nix.optimise.automatic = true;
```

### 38. Missing Binary Cache Configuration

Not configuring caches means rebuilding everything from source.

```nix
# CORRECT
nix.settings = {
  substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

---

## Overlay Issues

### 39. Infinite Recursion in Overlays

Using `final` to reference the symbol you're overriding causes infinite recursion.

```nix
# BROKEN - infinite recursion
final: prev: {
  hello = final.hello.overrideAttrs (old: { ... });
}

# CORRECT - use prev for the base package
final: prev: {
  hello = prev.hello.overrideAttrs (old: { ... });
}
```

### 40. Using `rec` in Overlays

Using `rec` to cross-reference overlay packages breaks composability with other overlays.

```nix
# ANTI-PATTERN
final: prev: rec {
  pkg-a = prev.callPackage ./a { };
  pkg-b = prev.callPackage ./b { dependency-a = pkg-a; };
}

# CORRECT - use final for cross-references
final: prev: {
  pkg-a = prev.callPackage ./a { };
  pkg-b = prev.callPackage ./b { dependency-a = final.pkg-a; };
}
```

### 41. External Parameters in Overlays

Overlays should be parameter-free — they're composed by the package set.

```nix
# ANTI-PATTERN - breaks composability
{ boost }:
final: prev: {
  myPackage = prev.callPackage ./package { inherit boost; };
}

# CORRECT - resolve dependencies within the overlay
final: prev: {
  myPackage = prev.callPackage ./package { boost = final.boost185; };
}
```

### 42. Using `prev` for Dependencies Instead of `final`

When a package depends on other packages that may be overridden by other overlays, use `final`.

```nix
# ANTI-PATTERN - ignores other overlays' overrides
final: prev: {
  myPackage = prev.callPackage ./package {
    stdenv = prev.clangStdenv;  # Won't see other overlays' changes
  };
}

# CORRECT - respects the full overlay chain
final: prev: {
  myPackage = prev.callPackage ./package {
    stdenv = final.clangStdenv;
  };
}
```

**Rule of thumb**: Use `prev` for the package you're overriding, `final` for everything else.

---

## DevShell Issues

### 43. Using `buildInputs` Instead of `packages`

In modern nixpkgs, `packages` is the preferred attribute in `mkShell`.

```nix
# OLD STYLE
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [ go golangci-lint ];
};

# MODERN STYLE
devShells.default = pkgs.mkShell {
  packages = with pkgs; [ go golangci-lint ];
};
```

### 44. Heavy Operations in shellHook

shellHook runs on every shell entry — keep it fast. No `pnpm install`, no network access.

```nix
# ANTI-PATTERN - blocks shell startup
shellHook = ''
  pnpm install   # Could take minutes
  go mod download  # Network access
'';

# CORRECT - keep it lightweight
shellHook = ''
  export GOWORK=off
  echo "Development environment ready"
'';
```

### 45. `mkShellNoCC` When No Compiler Needed

If your devShell doesn't need a C compiler, use `mkShellNoCC` for faster shell entry.

```nix
# CORRECT - faster shell when no C/C++ compilation needed
devShells.default = pkgs.mkShellNoCC {
  packages = with pkgs; [ nodejs yarn ];
};
```

### 46. Missing `inputsFrom` for Shared Shells

In monorepos or multi-project setups, use `inputsFrom` to compose shells.

```nix
# CORRECT - inherit packages from other shells
devShells.full = pkgs.mkShell {
  inputsFrom = [ config.devShells.frontend config.devShells.backend ];
  packages = with pkgs; [ just ];
};
```

---

## Systemd Hardening Issues

### 47. Minimal Hardening Applied

Most services should have at least basic systemd security directives. Use `systemd-analyze security <service>` to measure.

```nix
# CORRECT - baseline hardening for any service
serviceConfig = {
  ProtectSystem = "full";
  ProtectHome = "yes";
  PrivateTmp = true;
  NoNewPrivileges = true;
  ProtectClock = true;
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectControlGroups = true;
  PrivateDevices = true;
  RestrictNamespaces = "yes";
  LockPersonality = true;
  MemoryDenyWriteExecute = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
  SystemCallArchitectures = "native";
};
```

### 48. Network Services Missing `RestrictAddressFamilies`

Services that need network access should explicitly declare which address families they use.

```nix
# CORRECT - only allow IP networking
serviceConfig = {
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
};
```

### 49. Missing `MemoryMax` on Services

Without memory limits, a buggy service can consume all system memory.

```nix
# CORRECT
serviceConfig = {
  MemoryMax = "512M";
};
```

### 50. Using `DynamicUser` for Simple Services

For services that don't need a persistent user or home directory, `DynamicUser = true` is simpler and more secure.

```nix
# CORRECT - automatic, isolated user
serviceConfig = {
  DynamicUser = true;
  StateDirectory = "my-service";
};
```

---

## Ecosystem Standardization Issues (Session 3 Findings)

Issues found across 126 projects during systematic standardization.

### 51. Empty Overlays

Empty overlays clutter the flake and can mask evaluation errors.

```nix
# ANTI-PATTERN — serves no purpose
flake.overlays.default = final: prev: { };
```

**Fix**: Remove the overlay entirely if no packages are exported.

### 52. `inputs.self.packages` Anti-Pattern

Referencing packages through `inputs.self` is redundant and confusing.

```nix
# ANTI-PATTERN
my-project = inputs.self.packages.${system}.default;

# CORRECT
my-project = self.packages.${system}.default;
```

### 53. `prev.system` in Overlays

Using `prev.system` in overlays is wrong — `prev` is the package set before overlays, not a system accessor.

```nix
# BROKEN
flake.overlays.default = final: prev: {
  my-project = self.packages.${prev.system}.default;
};

# CORRECT
flake.overlays.default = final: _prev: {
  my-project = self.packages.${final.stdenv.system}.default;
};
```

### 54. CI DevShell Uses `mkShell` Instead of `mkShellNoCC`

CI devShells that use `mkShell` unnecessarily pull in a C compiler toolchain, bloating closure size and startup time.

```nix
# ANTI-PATTERN — slower CI, larger closure
devShells.ci = pkgs.mkShell { packages = [ go golangci-lint ]; };

# CORRECT — minimal, fast
devShells.ci = pkgs.mkShellNoCC { packages = [ go golangci-lint ]; };
```

### 55. `pkgs.lib.licenses` Instead of `lib.licenses`

In `perSystem`, `lib` is already available as a parameter. Using `pkgs.lib` is redundant.

```nix
# ANTI-PATTERN
meta = with pkgs.lib; { license = licenses.mit; };

# CORRECT
meta = with lib; { license = licenses.mit; };
```

### 56. `nixpkgs.lib.platforms` Instead of `lib.platforms`

Same issue as above — `lib` is already in scope in `perSystem`.

```nix
# ANTI-PATTERN
meta = with lib; { platforms = nixpkgs.lib.platforms.all; };

# CORRECT
meta = with lib; { platforms = lib.platforms.all; };
```

### 57. Mixed `goPkg` Variable and Inline `pkgs.go_1_26`

Mixing both styles in the same project (or across projects) creates inconsistency and confusion.

```nix
# ANTI-PATTERN — mixed styles in same file
let goPkg = pkgs.go_1_26; in
{
  packages.default = pkgs.buildGoModule.override { go = pkgs.go_1_26; } { ... };
  devShells.default = pkgs.mkShellNoCC { packages = [ goPkg ]; };
}

# CORRECT — single style throughout
let
  goPkg = pkgs.go_1_26;
  buildGoModule = pkgs.buildGoModule.override { go = goPkg; };
in
{
  packages.default = buildGoModule { ... };
  devShells.default = pkgs.mkShellNoCC { packages = [ goPkg ]; };
}
```

### 58. `checks.fmt` Instead of `checks.format`

Inconsistent naming for the format check makes scripts and CI harder to write.

```nix
# ANTI-PATTERN — non-standard name
checks.fmt = config.treefmt.build.check self;

# CORRECT — standard name
checks.format = config.treefmt.build.check self;
```

### 59. `programs.nixfmt.enable` Instead of `nixfmt.enable`

`treefmt-nix` uses `nixfmt.enable`, not `programs.nixfmt.enable`.

```nix
# ANTI-PATTERN — wrong attribute path
treefmt.programs.nixfmt.enable = true;

# CORRECT
treefmt.programs.nixfmt.enable = true;
```

Wait — that's the same. The actual issue is:

```nix
# ANTI-PATTERN (old API)
treefmt.config.programs.nixfmt.enable = true;

# CORRECT (current API)
treefmt.programs.nixfmt.enable = true;
```

### 60. `treefmt.config` Instead of `treefmt.settings`

Older treefmt-nix versions used `treefmt.config`. Current API uses `treefmt.settings` for formatter configuration and `treefmt.programs` for enablement.

```nix
# ANTI-PATTERN — old API
treefmt.config = { programs.gofumpt.enable = true; };

# CORRECT — current API
treefmt.settings = { ... };
treefmt.programs.gofumpt.enable = true;
```

### 61. `go.work` With Absolute Paths

Absolute paths in `go.work` break on CI, other machines, and Nix builds.

```
// BROKEN — only works on one machine
use /home/lars/projects/foo
use /home/lars/projects/bar

// CORRECT — portable
use ./foo
use ./bar
```

### 62. Missing `maintainers` in `meta`

Empty or missing `maintainers` fields reduce accountability and discoverability.

```nix
# ANTI-PATTERN — empty maintainers
meta = with lib; {
  description = "...";
  license = licenses.mit;
  maintainers = [ ];  # or missing entirely
};

# CORRECT
meta = with lib; {
  description = "...";
  license = licenses.mit;
  maintainers = [ maintainers.larsartmann ];
};
```

### 63. Overlay Attr Name Doesn't Match Directory

When the overlay attribute name differs from the project directory name, it confuses consumers and breaks conventions.

```nix
# Directory: blog/
# ANTI-PATTERN — confusing mismatch
flake.overlays.default = final: _prev: {
  blog-server = self.packages.${final.stdenv.system}.default;
};

# CORRECT — matches directory
flake.overlays.default = final: _prev: {
  blog = self.packages.${final.stdenv.system}.default;
};
```

**Exception**: When the binary name intentionally differs (e.g., `index/` directory produces `indexer` binary), document with a comment.
