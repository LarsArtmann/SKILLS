# Nix Review Skill — Comprehensive Status Report

**Date:** 2026-05-03 07:52
**Session:** nix-review skill creation + Google research expansion
**Author:** Crush (assisted by GLM-5.1)

---

## Executive Summary

Created a comprehensive `nix-review` skill that reviews and improves `.nix` files. The skill was built in two phases:

1. **Phase 1**: Read and analyzed ALL 88+ `.nix` files across `/home/lars/projects/` — extracted real patterns, anti-patterns, and issues
2. **Phase 2**: Googled and researched Nix best practices from official docs, wikis, and community resources — expanded the skill with community-validated knowledge

**Result**: A skill with 50 documented problems, 52 checklist items, and 10 best-practice sections covering the full Nix ecosystem.

---

## a) FULLY DONE ✅

### Skill Creation (Phase 1 — Codebase Analysis)

- [x] Read ALL 88+ `.nix` files across all projects using 5 parallel subagents
- [x] Analyzed `SystemNix/flake.nix` (755 lines, 3 machine configs, 30+ inputs)
- [x] Analyzed `SystemNix/lib/` (2 files — found critical type bugs: `ProtectHome = true`)
- [x] Analyzed `SystemNix/modules/` (29 service modules — found patterns, anti-patterns)
- [x] Analyzed `SystemNix/platforms/` (40+ files across darwin/nixos/common/shared)
- [x] Analyzed `SystemNix/pkgs/` (8 package definitions)
- [x] Analyzed 28 standalone project flakes (go-cqrs-lite, art-dupl, BuildFlow, etc.)
- [x] Analyzed `treefmt-full-flake/` (22 .nix files — most sophisticated nix project)
- [x] Catalogued all patterns, anti-patterns, and cross-cutting issues
- [x] Designed skill structure (SKILL.md + 2 reference files)
- [x] Wrote SKILL.md with 5-step review process
- [x] Wrote `references/common-problems.md` (22 problems initially)
- [x] Wrote `references/best-practices.md` (5 sections initially)

### Google Research (Phase 2 — Community Knowledge)

- [x] Researched nix.dev official best practices (anti-patterns: `with`, `rec`, `<nixpkgs>`, `builtins.path`)
- [x] Researched NixOS Wiki overlays page (final/prev rules, infinite recursion, scoped overlays)
- [x] Researched NixOS Wiki NixOS modules page (option types, mkPackageOption, assertions, submodule patterns)
- [x] Researched flake-parts documentation (perSystem patterns, nixpkgs instantiation approaches)
- [x] Researched systemd hardening (NixOS Wiki, Rocky Linux docs, notashelf.dev — baseline template, network services, DynamicUser)
- [x] Researched Nix evaluation performance (IFD, eval caching, GC, binary caches)
- [x] Researched devShell best practices (packages vs buildInputs, mkShellNoCC, inputsFrom, shellHook)
- [x] Researched Nixpkgs source filtering (lib.fileset modern API, gitTracked pattern)
- [x] Researched overlay anti-patterns (rec in overlays, external params, prev vs final misuse)
- [x] Expanded common-problems.md: 22 → 50 problems across 12 categories
- [x] Expanded best-practices.md: 5 → 9 sections with complete code templates
- [x] Expanded SKILL.md checklist: 30 → 52 items across 10 categories

### Deliverables

| File                            | Lines    | Content                                                                    |
| ------------------------------- | -------- | -------------------------------------------------------------------------- |
| `SKILL.md`                      | 207      | 5-step review process, 52 checklist items, severity guide, report template |
| `references/common-problems.md` | 768      | 50 documented problems with anti-pattern + fix code examples               |
| `references/best-practices.md`  | 573      | 9 sections with ideal code templates for all major Nix patterns            |
| **Total**                       | **1548** |                                                                            |

### Installation Location

```
~/.config/crush/skills/nix-review/
├── SKILL.md                          (207 lines)
└── references/
    ├── common-problems.md            (768 lines, 50 problems, 12 categories)
    └── best-practices.md             (573 lines, 9 sections)
```

---

## b) PARTIALLY DONE ⚠️

### Nothing partially done — both phases completed fully.

---

## c) NOT STARTED ❌

1. **Skill NOT added to SKILLS repo** (`/home/lars/projects/SKILLS/`) — only exists at `~/.config/crush/skills/nix-review/`. The skill should be copied to the SKILLS repo for version control.
2. **No eval/test cases run** — the skill-creator recommends running test prompts through the skill and evaluating results. No test cases have been defined or executed.
3. **No description optimization** — the skill description could be optimized for triggering accuracy using the skill-creator's `run_loop.py` tool.
4. **README.md in SKILLS repo not updated** — should add nix-review to the skills inventory.
5. **No `how-to-nix` skill created** — the how-to-golang skill exists but there's no equivalent for Nix (a teaching/learning skill, distinct from the review skill).
6. **Actual fixes NOT applied** to any of the 88+ .nix files — the skill was built but the issues found (placeholder hashes, type bugs, etc.) were not fixed in the actual codebase.

---

## d) TOTALLY FUCKED UP 💥

1. **None** — the skill creation went smoothly. No critical errors encountered. The only issue was that the NixOS Wiki returned 403 on some pages, but alternative sources were found.

---

## e) WHAT WE SHOULD IMPROVE

### Skill Quality

1. **Add `lib.fileset` examples** — the modern fileset API is referenced but could use more real-world examples from the codebase
2. **Add NixOS VM test patterns** — nix-ssh-config has excellent VM tests; these should be documented as a best practice
3. **Add Docker/Podman integration patterns** — several services use Docker Compose inside NixOS; the skill doesn't cover container integration patterns well
4. **Add Home Manager module patterns** — the codebase has extensive HM configs but the skill focuses more on NixOS modules
5. **Add sops-nix integration guide** — used extensively in SystemNix but the skill only says "use sops" without concrete patterns

### Process Improvements

6. **Run eval test cases** — the skill was never tested against real prompts; it should be validated
7. **Iterate on feedback** — the skill-creator recommends a feedback loop; this was skipped
8. **Cross-reference with `nix flake check`** — the skill recommends running checks but wasn't validated against actual `nix flake check` output

---

## f) Top 25 Things We Should Get Done Next

### High Impact (Do First)

1. **Copy nix-review skill to SKILLS repo** for version control
2. **Update SKILLS README.md** with nix-review entry
3. **Fix `ProtectHome = true` → `"yes"`** in `SystemNix/lib/systemd.nix` (runtime bug)
4. **Fix `RestrictNamespaces = true` → `"yes"`** in `SystemNix/lib/systemd.nix` (runtime bug)
5. **Fix placeholder vendorHash** in `project-dependency-graph/flake.nix` (won't build)
6. **Fix placeholder vendorHash** in `BuildFlow/flake.nix` (won't build)
7. **Fix placeholder vendorHash** in `artmann-technologies-website/flake.nix` (won't build)
8. **Add `formatter = pkgs.nixfmt`** to 19 flakes that have no formatter
9. **Standardize nixpkgs channel** across all flakes to `nixos-unstable`
10. **Add `follows = "nixpkgs"`** to all inputs missing it

### Medium Impact

11. **Extract overlays from SystemNix/flake.nix** into `./overlays/` files (755 → manageable)
12. **Split `niri-wrapped.nix`** (872 lines) into focused sub-modules
13. **Split `signoz.nix`** (741 lines) into query/collector/clickhouse modules
14. **Split `gitea.nix`** (550 lines) into server/repos/runner modules
15. **Replace `import nixpkgs {}` with `legacyPackages.${system}`** in 7 flakes
16. **Replace `nixpkgs-fmt` references** with `nixfmt` (deprecated formatter)
17. **Add `checks` to flakes** missing them (10+ flakes)
18. **Fix duplicated vendorHash** in `PapDashboard/flake.nix`
19. **Replace `alegendra` formatter** with `nixfmt` in 3 flakes
20. **Add `meta` sections** to package derivations missing them

### Lower Impact / Polish

21. **Create eval test cases** for the nix-review skill
22. **Run description optimization** for better triggering accuracy
23. **Create a `how-to-nix` learning skill** (analogous to `how-to-golang`)
24. **Add sops-nix integration guide** to best-practices.md
25. **Add Home Manager module patterns** to best-practices.md

---

## g) Top #1 Question I Cannot Figure Out Myself

**Should the nix-review skill live in the SKILLS repo (`/home/lars/projects/SKILLS/`) or only at the installed location (`~/.config/crush/skills/nix-review/`)?**

The SKILLS repo has other skills (code-quality-scan, architecture-review, etc.) but they appear to be separate copies. The nix-review skill was created at the installed location where Crush actually loads it from. I'm not sure if:

- Skills in the SKILLS repo are automatically installed/synced
- The SKILLS repo is just a backup/version-control copy
- Both locations need to be maintained independently
- There's a standard process for "publishing" skills from one to the other

This matters because the skill needs to be version-controlled but also needs to be where Crush can find it.

---

## Sources Researched (Phase 2)

| Source                         | URL                                           | Content Extracted                                         |
| ------------------------------ | --------------------------------------------- | --------------------------------------------------------- |
| nix.dev best practices         | https://nix.dev/guides/best-practices         | `with`, `rec`, `<nixpkgs>`, `builtins.path`, shallow `//` |
| NixOS Wiki — Overlays          | https://wiki.nixos.org/wiki/Overlays          | final/prev rules, infinite recursion, scoped overlays     |
| NixOS Wiki — NixOS Modules     | https://wiki.nixos.org/wiki/NixOS_modules     | mkPackageOption, assertions, submodule patterns           |
| NixOS Wiki — Systemd Hardening | https://wiki.nixos.org/wiki/Systemd_Hardening | Baseline template, network services, DynamicUser          |
| zero-to-nix                    | https://zero-to-nix.com/concepts/flakes       | Flake structure, inputs, outputs patterns                 |
| flake-parts docs               | /websites/flake_parts (Context7)              | perSystem, module system, nixpkgs instantiation           |
| Nixpkgs manual                 | Source filtering docs                         | lib.fileset, lib.sources, gitTracked                      |
| Nixcademy                      | Various posts                                 | Overlay techniques, IFD deep-dive                         |
| Rocky Linux docs               | Systemd hardening guide                       | Security directives, capability management                |
| notashelf.dev                  | NixOS insecurities & remedies                 | Practical hardening patterns                              |

---

## Files Changed This Session

### Created (at `~/.config/crush/skills/nix-review/`)

- `SKILL.md` — 207 lines
- `references/common-problems.md` — 768 lines
- `references/best-practices.md` — 573 lines

### Not Modified (analysis only)

- 88+ `.nix` files across `/home/lars/projects/` — read and analyzed, no changes applied

---

_Arte in Aeternum_
