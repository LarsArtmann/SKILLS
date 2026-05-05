---
name: nix-review
description: Reviews and improves .nix files to make them truly superb. Use when the user wants to review, audit, improve, or fix Nix files — including flake.nix, NixOS modules, overlays, devShells, packages, or any .nix file. Also trigger when the user asks about nix quality, nix anti-patterns, nix best practices, wants to make their flakes excellent, or says "nix review", "review nix", "review .nix", "improve flake". Covers build correctness, security hardening, reproducibility, module design, source filtering, overlay architecture, performance, systemd hardening, and common pitfalls.
metadata:
  tags: nix, flakes, review, quality, best-practices, nixos, modules, overlays, systemd, performance
---

# Nix Review

A comprehensive review skill for making .nix files truly superb. Based on analysis of 88+ real .nix files across production codebases and community best practices from nix.dev, NixOS Wiki, Nixcademy, flake-parts docs, and systemd hardening guides.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT before each action.

### Step 1: Discovery

Find all `.nix` files in the target scope:

```bash
find . -name "*.nix" -type f | head -50
```

Read every file. Do not skip any. Understanding the full picture is essential for catching cross-cutting issues like overlay duplication, inconsistent patterns, and import cycles.

### Step 2: Categorize

Classify each file into its role:

| Category                | Examples                         |
| ----------------------- | -------------------------------- |
| **Flake entry**         | `flake.nix`                      |
| **Package definitions** | `pkgs/*.nix`, `package.nix`      |
| **NixOS modules**       | `modules/**/*.nix`               |
| **Home Manager**        | `home.nix`, `programs/*.nix`     |
| **Library functions**   | `lib/*.nix`                      |
| **Dev shells**          | `devShells` sections             |
| **Tests/Checks**        | `checks` sections, `tests/*.nix` |
| **Templates**           | `templates/*/flake.nix`          |

### Step 3: Review Against Checklist

For each file, check ALL categories below. Read `references/common-problems.md` for detailed explanations and fixes of each issue.

#### Critical (Build Breakers)

- [ ] **No placeholder hashes** — `fakeHash`, `sha256-AAA...`, empty `vendorHash` when deps exist
- [ ] **No impure constructs** — `builtins.getEnv`, `@latest` installs, network access in builds
- [ ] **No hardcoded absolute paths** — `/home/user/...` in inputs or derivations
- [ ] **Correct systemd types** — `ProtectHome`/`RestrictNamespaces` use strings not booleans

#### Purity & Reproducibility

- [ ] **No `<nixpkgs>` lookups** — use flake inputs instead
- [ ] **All URLs quoted** — `url = "github:..."` not `url = github:...`
- [ ] **`builtins.path` for reproducible store paths** — `builtins.path { path = ./.; name = "..."; }`
- [ ] **No IFD** — `builtins.readFile` on derivation outputs blocks evaluation
- [ ] **No shallow `//` on nested attrs** — use `lib.recursiveUpdate` or `lib.mkMerge`

#### Structural

- [ ] **No unnecessary nixpkgs re-instantiation** — use `legacyPackages.${system}` instead of `import nixpkgs {}`
- [ ] **No duplicated hashes** — extract `vendorHash` to a `let` binding
- [ ] **Files under ~300 lines** — split monoliths into focused modules
- [ ] **No overlay duplication** — same overlay defined in multiple contexts will drift
- [ ] **Consistent `follows`** — all inputs that use nixpkgs should `follows = "nixpkgs"`
- [ ] **Complete `meta` section** — description, license, mainProgram

#### Correctness

- [ ] **Security hardening justified** — every `ProtectHome = false` has a comment explaining why
- [ ] **No race conditions** — ExecStartPre/ExecStartPost dependencies are properly ordered
- [ ] **Source filtering is appropriate** — not too broad (includes `.git`) or too narrow
- [ ] **Version derived from git** — `self.rev or "dev"`, not hardcoded `"0.1.0"`

#### Consistency

- [ ] **Formatter defined** — `nixfmt` (preferred) or `treefmt-nix`, never `nixpkgs-fmt`
- [ ] **Single nixpkgs channel** — all inputs use same channel (`nixos-unstable` or `nixpkgs-unstable`)
- [ ] **Checks defined** — at minimum: format check and build
- [ ] **No `rec` attrsets** — use `let ... in` for explicit dependencies
- [ ] **No top-level `with`** — use explicit `inherit (pkgs)` for scoped imports

#### NixOS Modules (if applicable)

- [ ] **No hardcoded usernames** — use options for user configuration
- [ ] **All options have `type`** — no bare `mkOption { default = ...; }` without type
- [ ] **All options have `description`** — enables documentation generation
- [ ] **Use `mkPackageOption`** for package options
- [ ] **No deep relative imports** — `import ./../../../lib/...` is fragile
- [ ] **No double imports** — each module imported in exactly one place
- [ ] **Assertions for constraints** — port ranges, required services, incompatible options
- [ ] **`mkIf cfg.enable` pattern** — conditional activation, not always-on

#### Security

- [ ] **No secrets in Nix store** — use sops-nix, agenix, or pass
- [ ] **Consistent secret strategy** — not mixing sops + plaintext + hardcoded
- [ ] **No sensitive IPs/hostnames** — infrastructure details should be in secrets
- [ ] **Systemd hardening applied** — ProtectSystem, ProtectHome, PrivateTmp, NoNewPrivileges, MemoryMax
- [ ] **`RestrictAddressFamilies`** for network services
- [ ] **`MemoryMax` set** on all long-running services

#### Performance

- [ ] **No IFD in critical paths** — `builtins.readFile` on derivation outputs
- [ ] **No excessive `mkIf` wrapping** — direct assignment for simple booleans
- [ ] **GC configured** — `nix.gc.automatic = true`
- [ ] **Binary caches configured** — `nix.settings.substituters`
- [ ] **`goModules` reused** in checks — not rebuilt separately

#### DevShells (if applicable)

- [ ] **Uses `packages` not `buildInputs`** — modern mkShell convention
- [ ] **Uses `mkShellNoCC`** when no C compiler needed
- [ ] **Lightweight `shellHook`** — no network access, no heavy installs
- [ ] **Env vars as attributes** — `GOWORK = "off"` not `shellHook = "export GOWORK=off"`
- [ ] **`inputsFrom`** for composed shells in monorepos

#### Overlays (if applicable)

- [ ] **`prev` for base packages, `final` for dependencies** — avoids infinite recursion
- [ ] **No `rec` in overlays** — use `final` for cross-references
- [ ] **No external parameters** — overlays should be self-contained
- [ ] **Overlay exported** — `overlays.default` for external consumption

### Step 4: Generate Report

Produce a structured report with these sections:

```markdown
# Nix Review Report

## Executive Summary

- X files reviewed
- Y critical issues (build breakers)
- Z structural issues
- W consistency issues

## Critical Issues (Must Fix)

| #   | File      | Line | Issue                  | Fix                      |
| --- | --------- | ---- | ---------------------- | ------------------------ |
| 1   | flake.nix | 42   | Placeholder vendorHash | Replace with actual hash |

## Structural Issues (Should Fix)

| #   | File        | Issue     | Recommendation                         |
| --- | ----------- | --------- | -------------------------------------- |
| 1   | service.nix | 550 lines | Split into server/repos/runner modules |

## Consistency Issues

| #   | Files    | Issue             | Fix                           |
| --- | -------- | ----------------- | ----------------------------- |
| 1   | 3 flakes | Formatter missing | Add `formatter = pkgs.nixfmt` |

## Best Practice Violations

| #   | File | Violation | Better Approach |
| --- | ---- | --------- | --------------- |

## Strengths (What's Done Well)

- Good use of X pattern
- Clean Y structure
```

### Step 5: Fix (When Requested)

When the user asks to fix issues:

1. Fix critical issues first (build breakers)
2. Fix structural issues (duplicated hashes, monoliths)
3. Fix consistency issues (formatters, channels)
4. Fix best practice violations

After each fix, verify:

- `nix flake check` passes (or `nix build` for package flakes)
- `nix fmt -- --check` passes (if formatter defined)
- No regressions in other files

## Key Principles

The reason for each check matters more than the check itself. A review that explains "why" is far more valuable than one that just says "fix this." When reporting issues, always include:

1. **What** the issue is
2. **Why** it matters (performance, correctness, security, maintainability)
3. **How** to fix it (concrete code example)

## Severity Guide

| Severity        | Meaning                                             |
| --------------- | --------------------------------------------------- |
| 🔴 **Critical** | Won't build, security vulnerability, data loss risk |
| 🟠 **High**     | Wrong behavior, impurity, non-reproducible          |
| 🟡 **Medium**   | Maintainability, consistency, structural debt       |
| 🔵 **Low**      | Style, naming, minor improvements                   |

## References

- `references/common-problems.md` — Detailed catalogue of 50 common problems with fixes, organized by category
- `references/best-practices.md` — Ideal patterns for flake structure, modules, overlays, source filtering, systemd hardening, devShells, and performance

Read these files when you need specific examples or deeper guidance on a particular issue category.

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
