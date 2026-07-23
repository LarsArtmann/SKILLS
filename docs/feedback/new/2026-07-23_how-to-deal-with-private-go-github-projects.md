# Dealing with Private Go GitHub Repos in Nix — The Definitive Guide

**Created:** 2026-07-23
**Context:** LarsArtmann ecosystem — 11+ Go projects using `vendorHash = null` with committed `vendor/` directories
**Verdict:** Stop committing `vendor/`. Use `mkPreparedSource` + `GOPRIVATE` in devShells.

---

## The Problem

Private Go repos (`github.com/larsartmann/*`) can't be fetched inside the Nix sandbox — no SSH, no network. The ecosystem currently has **11 projects** working around this by committing `vendor/` directories, producing massive diffs, stale dependencies, merge conflicts, and 60MB+ repos.

This is unnecessary. A better solution already exists and is battle-tested across BuildFlow (15 private deps), DiscordSync, Cyberdom, and mr-sync.

---

## The Two-Part Solution

You need **both** parts. They solve different problems:

| Part                        | Solves                                                  | Where                        |
| --------------------------- | ------------------------------------------------------- | ---------------------------- |
| **`mkPreparedSource`**      | `nix build` — hermetic sandbox builds without network   | `flake.nix` build derivation |
| **`GOPRIVATE` in devShell** | `go mod tidy`, `go get`, `go build` — local development | `flake.nix` devShells        |

Without `GOPRIVATE`, local `go mod tidy` tries to hit the Go proxy for your private repos and fails. Without `mkPreparedSource`, `nix build` can't resolve private deps in the sandbox.

---

## Part 1: `mkPreparedSource` (Build-Time)

### How It Works

1. Each private dep is added as a **flake input** with `git+ssh://` URL and `flake = false`
2. `nix flake update` fetches them via SSH **outside** the sandbox (where you have keys)
3. `mkPreparedSource` copies them into `_local_deps/` and injects `replace` directives into `go.mod`
4. The Go toolchain resolves everything locally — zero network needed inside the sandbox

### Full Example

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

    # --- The helper itself ---
    go-nix-helpers = {
      url = "git+ssh://git@github.com/LarsArtmann/go-nix-helpers?ref=master";
      flake = false;
    };

    # --- Private deps (flake = false, fetched via SSH) ---
    go-cqrs-lite = {
      url = "git+ssh://git@github.com/LarsArtmann/go-cqrs-lite?ref=master";
      flake = false;
    };
    go-branded-id = {
      url = "git+ssh://git@github.com/LarsArtmann/go-branded-id?ref=master";
      flake = false;
    };
    wise-go = {
      url = "git+ssh://git@github.com/LarsArtmann/wise-go?ref=master";
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
              "github.com/larsartmann/wise-go" = inputs.wise-go;
            };
            # Sub-modules auto-discovered — no manual list needed.
            # /vN version suffixes handled automatically.
          };
        in
        {
          packages.default = pkgs.buildGoModule {
            pname = "my-app";
            inherit version;
            src = preparedSrc;
            vendorHash = "sha256-..."; # Run nix build, copy from error
            nativeBuildInputs = [ go ];
            ldflags = [ "-s" "-w" ];
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [ go gopls golangci-lint ];
            GOWORK = "off";
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

### Key Features of `mkPreparedSource`

| Feature                   | What It Does                                                                                                                           |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Auto-discovery**        | Recursively scans each dep source for ALL `go.mod` files at any depth. No manual `subModules` list.                                    |
| **Build-time validation** | Verifies every private module in `go.mod` has a replace directive. Fails with a clear message instead of `"could not read Username"`.  |
| **`/vN` suffix handling** | Strips version suffixes from local paths (`event/v3/eventtest` → `event/eventtest`) while keeping the full path in replace directives. |
| **Stale replace cleanup** | Removes dev-machine `/home/...` and `../sibling` replaces before injecting its own.                                                    |
| **`privateDepPattern`**   | Default `github\.com/[Ll]ars[Aa]rtmann/`. Override for non-LarsArtmann deps.                                                           |

### `vendorHash` — How to Get It

After wiring up `mkPreparedSource`, set `vendorHash = pkgs.lib.fakeHash` initially, then:

```bash
nix build .#default
# Nix will fail with the correct hash — copy it into flake.nix
```

---

## Part 2: `GOPRIVATE` in DevShells (Development-Time)

Without `GOPRIVATE`, local `go mod tidy` / `go get` will try to hit `proxy.golang.org` for your private repos and fail with `410 Gone` or `could not read Username`.

```nix
devShells.default = pkgs.mkShellNoCC {
  GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";
};
```

### Case Sensitivity — Critical

GitHub URLs are case-insensitive but Go module paths are **case-sensitive**. `GOPRIVATE` must cover **both** casings:

```bash
# WRONG — only covers uppercase
GOPRIVATE = "github.com/LarsArtmann"

# WRONG — only covers lowercase
GOPRIVATE = "github.com/larsartmann"

# RIGHT — covers both
GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*"
```

This is the **most common bug** in the ecosystem. BuildFlow (lines 333, 366) still uses the uppercase-only form.

### `GONOSUMDB` / `GONOSUMCHECK`

`GOPRIVATE` automatically implies `GONOSUMDB` and `GONOPROXY` for matching paths. You do **not** need to set them separately. `GOPRIVATE` is the single knob.

---

## Part 3: Local Machine Setup (One-Time)

For `go mod tidy` / `go get` to resolve private repos via SSH on your dev machine:

```bash
# Rewrite HTTPS Go module URLs to SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

This makes `go mod download` use SSH (where you have keys) instead of HTTPS (where you don't). Without this, Go tries HTTPS and gets a `could not read Username` error.

For CI, see section below.

---

## Migration Guide: `vendor/` → `mkPreparedSource`

### Step-by-Step (per project)

1. **Identify private deps** — grep `go.mod` for `github.com/larsartmann` and `github.com/LarsArtmann`:

   ```bash
   grep -E 'github\.com/[Ll]ars[Aa]rtmann' go.mod | awk '{print $1}' | sed 's|/v[0-9]*||' | sort -u
   ```

2. **Add flake inputs** — one per unique private repo (not per sub-module):

   ```nix
   go-cqrs-lite = {
     url = "git+ssh://git@github.com/LarsArtmann/go-cqrs-lite?ref=master";
     flake = false;
   };
   ```

3. **Wire `mkPreparedSource`** — add the helper import and `deps` map.

4. **Set `vendorHash = pkgs.lib.fakeHash`** temporarily.

5. **Remove `vendor/` from src** — delete the `./vendor` entry from the fileset.

6. **Remove `vendor/` from git tracking:**

   ```bash
   trash vendor/
   # Or if vendor/ is gitignored (not tracked), just delete it:
   rm -rf vendor/
   ```

7. **Remove `!vendor/` overrides from `.gitignore`** (if any exist).

8. **Run `nix build .#default`** — copy the correct `vendorHash` from the error.

9. **Add `GOPRIVATE` to both devShells** if not already present.

10. **Verify: `nix build .#default && nix flake check`**

11. **Verify local dev: `nix develop -c bash -c 'go mod tidy && go build ./...'`**

### Current State — 11 Projects to Migrate

| Project                       | Truly Committed?  | Private Deps                                                                                  | Complexity |
| ----------------------------- | ----------------- | --------------------------------------------------------------------------------------------- | ---------- |
| StopTube                      | Yes               | go-branded-id, go-cqrs-lite, go-error-family                                                  | Medium     |
| oxlint-auto-configure         | Yes               | go-finding, gogenfilter                                                                       | Low        |
| project-dependency-graph      | Yes               | cmdguard, go-output, go-branded-id, project-discovery-sdk, samber-do-auditlog, go-filewatcher | High       |
| bank-sync                     | No (gitignored)   | go-cqrs-lite, go-branded-id, wise-go, cqrs-htmx, templ-components, go-error-family            | High       |
| github-local-sync             | No (gitignored)   | go-cqrs-lite, cqrs-htmx, go-localsync, go-branded-id                                          | Medium     |
| Code-Quality-Agent            | No (gitignored)   | go-branded-id, go-finding                                                                     | Low        |
| KeyCountdown                  | No (gitignored)   | cqrs-htmx, go-cqrs-lite, go-error-family                                                      | Medium     |
| KeyHolderAI                   | No (gitignored)   | go-must, cqrs-htmx, go-cqrs-lite                                                              | Medium     |
| go-localsync                  | No (gitignored)   | go-cqrs-lite, go-branded-id, go-error-family                                                  | Low        |
| storbi                        | No (gitignored)   | go-cqrs-lite, go-branded-id, go-error-family                                                  | Low        |
| terraform-diagrams-aggregator | No vendor/ exists | cmdguard, go-branded-id, go-output                                                            | Low        |

**Recommended order:** Start with low-complexity projects (oxlint-auto-configure, Code-Quality-Agent, go-localsync) to validate the pattern, then tackle the high-complexity ones.

---

## CI Authentication

### The Problem

CI runners need to resolve `git+ssh://` flake inputs. They don't have your SSH keys.

### Solution: GitHub Deploy Keys + SSH Agent

In GitHub Actions:

```yaml
- uses: actions/checkout@v4
- uses: cachix/install-nix-action@v27
  with:
    nix_path: nixpkgs=channel:nixos-unstable
    extra_nix_config: |
      accept-flake-config = true

- name: Configure SSH for private repos
  run: |
    mkdir -p ~/.ssh
    echo "${{ secrets.DEPLOY_KEY }}" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    ssh-keyscan github.com >> ~/.ssh/known_hosts

- name: Update flake inputs
  run: nix flake update

- name: Build
  run: nix build .#default
```

**Deploy key setup:** Create a single SSH key pair, add the public key as a deploy key to each private repo (with read access). Store the private key as a GitHub Actions secret (`DEPLOY_KEY`).

Alternatively, use `GITHUB_TOKEN` with `git config insteadOf`:

```yaml
- name: Configure git for private repos
  run: |
    git config --global url."https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "git@github.com:"
    git config --global url."https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "ssh://git@github.com/"
```

This rewrites SSH URLs to HTTPS with token auth. No deploy keys needed.

---

## Why Not the Other Approaches?

| Approach                                 | Why Not                                                                                                                                   |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **Committed `vendor/`**                  | Massive diffs, stale deps, merge conflicts, repo bloat. The thing we're eliminating.                                                      |
| **`--impure` builds**                    | Destroys reproducibility. Can't cache results.                                                                                            |
| **SSH keys in derivation**               | World-readable in `/nix/store`. Security disaster.                                                                                        |
| **`overrideModAttrs` + netrc**           | Requires `impureEnvVars`. Token in process list. Not pure.                                                                                |
| **Athens proxy**                         | Infrastructure overhead. Overkill for solo/small team.                                                                                    |
| **`--sandbox-paths` netrc**              | Manual file management. Token in `/tmp`. Forgets cleanup.                                                                                 |
| **`netrc-file` in `nix.conf`**           | Doesn't work with `buildGoModule`. Dead end.                                                                                              |
| **go-overlay**                           | Third-party. Not in nixpkgs. Unproven.                                                                                                    |
| **Raw replace directives in `preBuild`** | Fails with "illegal path references in fixed-output derivation". `mkPreparedSource` solves this by doing the replacement outside the FOD. |

---

## Known Gotchas

### 1. Public LarsArtmann repos

Some LarsArtmann repos are **public** (e.g., `go-finding`, `go-output`, `go-error-family`). `mkPreparedSource` validates that every private-pattern require has a replace directive. If a public LarsArtmann repo is in `go.mod` but not in `deps`, set `validatePrivateDeps = false`:

```nix
preparedSrc = mkPreparedSource {
  # ...
  validatePrivateDeps = false; # Some LarsArtmann deps are public
};
```

BuildFlow uses this.

### 2. Transitive private deps

If private dep A depends on private dep B, B must **also** be a flake input. `mkPreparedSource` only injects deps you explicitly list. If B's `go.mod` requires C (also private) and C isn't listed, the build fails.

Solution: list ALL transitive private deps, or set `validatePrivateDeps = false` and accept that validation won't catch missing transitives.

### 3. `tools/go.mod` (secondary modules)

If your project has a `tools/go.mod` (for tooling deps), you need `postPatchExtra` to inject replaces there too:

```nix
postPatchExtra = ''
  if [ -f tools/go.mod ]; then
    # Same replace directives for tools/go.mod
  fi
'';
```

BuildFlow does this at flake.nix:238-245.

### 4. `vendorHash` updates

When you add/remove deps or change versions:

```bash
nix build .#default
# Copy the hash from the error message
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

### 5. `GOWORK` interaction

If using Go workspace mode (`go.work`), set `GOWORK = "off"` in devShells to prevent workspace resolution from interfering with module-based builds.

### 6. Mixed case in import paths

Go module paths are case-sensitive. `github.com/larsartmann/go-cqrs-lite` and `github.com/LarsArtmann/go-cqrs-lite` are **different modules** to Go. Your `deps` map keys must match the exact case used in `go.mod`.

---

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
