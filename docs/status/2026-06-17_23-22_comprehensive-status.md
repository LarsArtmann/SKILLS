# SKILLS Repository — Comprehensive Status Report

**Date:** 2026-06-17 23:22 CEST
**Scope:** Full project audit — every skill, the vendoring fix landed this session, and a re-verification of every finding from the 2026-05-03 audit against current reality.
**Previous audit:** `2026-05-03_07-51_comprehensive-skills-audit.md`

---

## Executive Summary

The repo has grown from **15 → 19 skills** since the last audit (+5 new comprehensive skills: `data-model-review`, `go-modularize`, `html-report-kit`, `naming-review`, `nix-review`; −1 removed: `execution-mode`). The thinness problem has mostly been solved: **9 thin skills → 3**. Two of the worst offenders (`deduplicate-code` 27→144 lines, `nix-flake-migration` 21→163 lines) were fleshed out substantially. Legacy `1.md`–`17.md` files were moved into `originals/` and the `PARTIALLY_FUNTIONAL` typo was fixed.

**Overall health: 🟢 Solid and shipping.** This session fixed a structural defect that broke every HTML-producing skill under per-skill install (`bunx skills add <repo>@<one-skill>`): the `html-report-kit` was referenced via sibling paths that dangle when only one skill is copied out. The kit is now **vendored** into each of its 10 consumers and kept in sync by `scripts/sync-html-kit.sh`.

**What's still fucked:** the `git commit <--` typo persists in 3 skills (6 occurrences); the README/AGENTS.md skill counts are stale (claim 20/18, reality 19); an empty `brainstorm-data-model/` orphan lingers; and the vendored kit copies from this session are **uncommitted**.

---

## A) FULLY DONE ✅

| #   | Item                                                                  | Evidence                                                                                                                                                              |
| --- | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **19 skills, all with valid YAML frontmatter**                        | `name` + `description` + `metadata.tags` present on every `SKILL.md`                                                                                                  |
| 2   | **5 new comprehensive skills since May**                              | `data-model-review` (147), `go-modularize` (872), `html-report-kit` (82), `naming-review` (266), `nix-review` (231)                                                   |
| 3   | **Thinness crisis resolved**                                          | 9 thin → 3 thin. `deduplicate-code` 27→144, `nix-flake-migration` 21→163                                                                                              |
| 4   | **Legacy root files moved to `originals/`**                           | `1.md`–`17.md` gone from root; 17 files in `originals/`, documented as non-canonical                                                                                  |
| 5   | **`PARTIALLY_FUNTIONAL` typo fixed**                                  | `features-audit/SKILL.md` now reads `PARTIALLY_FUNCTIONAL`                                                                                                            |
| 6   | **`html-report-kit` shared design system**                            | Two template variants (dark-dashboard + editorial-light), full component vocabulary, referenced by 10 consumers                                                       |
| 7   | **`html-report-kit` per-skill install breakage FIXED (this session)** | Vendored into `<consumer>/assets/html-report-kit/`; all refs rewritten `../` → `./assets/`; `scripts/sync-html-kit.sh` (sync/check/list); `--check` passes for all 10 |
| 8   | **`execution-mode` removed → parallelism contradiction resolved**     | The "1 sub-agent at a time" vs "multiple tasks" split brain no longer exists; one side is gone                                                                        |
| 9   | **`full-code-review` Pareto split brain resolved**                    | Planning now delegates to `pareto-planning` instead of inlining a duplicate                                                                                           |
| 10  | **Inter-skill reference graph maturing**                              | 10 skills wired to `html-report-kit`; `full-code-review`→`pareto-planning`; multiple Go skills→`how-to-golang`                                                        |
| 11  | **`how-to-golang` reference-heavy pattern established**               | 93-line entrypoint + 9 reference files — the template for rich skills                                                                                                 |
| 12  | **Clean git history**                                                 | Logical, descriptive commits throughout                                                                                                                               |

---

## B) PARTIALLY DONE 🔶

| #   | Item                                | Status                                                     | What's Missing                                                                                                                                                                       |
| --- | ----------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | **This session's vendoring fix**    | All 10 consumers synced and `--check` passes; docs updated | **Vendored copies + `scripts/` are uncommitted** — `git status` shows them as untracked                                                                                              |
| 2   | **`architecture-review` flesh-out** | 30 → 51 lines; references `html-report-kit`                | Still no assessment rubric, criteria, or methodology in a `references/` file — agent will produce generic output                                                                     |
| 3   | **`status-report` flesh-out**       | 36 → 52 lines; references kit                              | Output template is the kit, but the skill body still embeds the literal "FULL COMPREHENSIVE..." prompt; `git commit <--` typo remains (1 occ.)                                       |
| 4   | **`code-quality-scan` flesh-out**   | 34 → 43 lines                                              | Still thin; tool list (`art-dupl`) not documented; no install guidance                                                                                                               |
| 5   | **`how-to-golang` code accuracy**   | 9 reference files written                                  | May-3 audit flagged 4 inaccuracies (gopter signature, `encoding/json/v2` Go version, E2E HTTP API, Rule 002 CI cmd) — **not re-verified this session**, likely still partially wrong |
| 6   | **`docs-freshness-check`**          | 30 → 29 lines (essentially unchanged)                      | Still checks a hardcoded file list; no definition of "stale"; no configurable list                                                                                                   |
| 7   | **Skill count documentation**       | README/AGENTS exist                                        | README says "20 skills", AGENTS says "18 total" / "9 of 18 thin" — **all stale**, reality is 19                                                                                      |
| 8   | **Cross-skill references**          | `html-report-kit` graph is solid                           | `full-code-review`→`deduplicate-code`, `brutal-self-review`→`architecture-review` still not wired                                                                                    |

---

## C) NOT STARTED ⬜

| #   | Item                                                      | Impact                                                                            |
| --- | --------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 1   | **Commit this session's vendoring work**                  | 🔴 Critical — the fix is done but uncommitted; a checkout loses it                |
| 2   | **Empirical trigger-description testing**                 | 🔴 Critical — zero skills tested in Crush; every description is an educated guess |
| 3   | **`library-guide` skill from `LIBRARY_GUIDE.md`**         | 🟡 High — 13 Lars-authored Go libraries unmapped from any skill                   |
| 4   | **`crush.json` for the repo**                             | 🟠 Medium — enables `skills_paths` auto-discovery                                 |
| 5   | **`allowed-tools` frontmatter** on CLI-dependent skills   | 🟠 Medium — `d2`, `art-dupl` still prompt for permission                          |
| 6   | **Eval test suite** (≥2 prompts/skill, automated grading) | 🟠 Medium — no way to detect regressions in skill quality                         |
| 7   | **Error-handling guidance** for missing tools             | 🟠 Medium — what if `d2`/`art-dupl` isn't installed?                              |
| 8   | **Version/timestamp frontmatter** on skills               | ⚪ Low — no way to track freshness of a given skill                               |

---

## D) TOTALLY FUCKED UP! 💥

| #   | Item                                                | Why It's Fucked                                                                                                                                                                                                                                                                          | Severity    |
| --- | --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1   | **`git commit <--` typo in 3 skills**               | `full-code-review` (×3), `pareto-planning` (×2), `status-report` (×1). The `<--` is **not a git flag** — it's an artifact from the original prompts. An LLM may interpret it as a literal flag and error out or improvise a broken command. Flagged in May, **still not fixed in June**. | 🔴 Critical |
| 2   | **3 dangerously thin skills remain**                | `bdd-testing` (23 lines, zero ginkgo syntax), `features-audit` (24 lines, no FEATURES.md template), `docs-freshness-check` (29 lines, hardcoded file list). Each will produce thin, inconsistent output.                                                                                 | 🔴 Critical |
| 3   | **`brainstorm-data-model/` empty orphan directory** | Zero files. Not referenced anywhere. Not git-trackable (git ignores empty dirs). Pure cruft that signals "half-finished work" to anyone browsing the repo.                                                                                                                               | 🟡 High     |
| 4   | **Stale counts in canonical docs**                  | README: "20 skills" (reality 19). AGENTS.md §2: "18 total" (reality 19). AGENTS.md §5.4: "9 of 18 skills thin" (reality 3 of 19). These are the docs agents read first — they mislead every session.                                                                                     | 🟡 High     |
| 5   | **`how-to-golang` reference code may be wrong**     | 4 flagged inaccuracies from May not re-verified. Wrong code in a reference is worse than no code — it teaches the wrong pattern.                                                                                                                                                         | 🟡 High     |
| 6   | **Vendored kit uncommitted**                        | The fix is correct and verified, but 11 untracked dirs + `scripts/` are sitting in the working tree.                                                                                                                                                                                     | 🟡 High     |

---

## E) WHAT WE SHOULD IMPROVE

### Correctness & Hygiene

1. **Commit the vendoring work immediately.** It's verified, it's correct, it's the highest-value change in the repo right now, and it's one `git add` away from being lost.
2. **Kill the `git commit <--` typo forever.** It's a 5-minute fix across 3 files and it's been open for 6 weeks. Add a grep to the sync script (or a pre-commit hook) so it can never return.
3. **Fix the skill counts in README and AGENTS.md.** 19 skills. 3 thin. Make AGENTS.md §5.4 reference the real numbers, or better — stop hardcoding counts and point at a command that computes them.
4. **Delete `brainstorm-data-model/`.** Empty orphan. `trash` it (per the global AGENTS safety rule — never bare `rm`).

### Content Depth

5. **Finish the last 3 thin skills.** `bdd-testing` needs a ginkgo syntax reference + test structure template. `features-audit` needs a FEATURES.md template. `docs-freshness-check` needs a "stale" definition and configurable file list. The pattern is proven (`how-to-golang`, `go-modularize`) — apply it.
6. **Re-verify `how-to-golang` code snippets.** Compile any Go sample that's feasible; fix or remove the ones that are wrong.
7. **Add output templates to the 3 thin skills + `todo-list-builder`.** Concrete templates with examples beat prose instructions every time.

### Architecture & Integration

8. **Add a drift guard for vendored copies.** Wire `scripts/sync-html-kit.sh --check` into CI (even a simple git hook) so the kit can't silently desync.
9. **Wire the remaining cross-references.** `full-code-review`→`deduplicate-code`, `brutal-self-review`→`architecture-review`, Go skills→`library-guide` (once it exists).
10. **Decide `how-to-write-skills.md`'s home.** Still an orphaned root file. The guide itself says it should be a skill dir or under `docs/`. Eat your own dog food.

### Validation

11. **Test trigger descriptions.** The `skill-creator` skill has a description-optimization loop. Run real prompts against the 19 descriptions and measure activation accuracy.
12. **Build an eval harness.** ≥2 test prompts per skill with pass/fail grading. This is the only way to catch quality regressions as skills evolve.

---

## F) TOP 25 THINGS TO DO NEXT

Ranked by impact × urgency. Items #1–#8 are the Pareto front — they cover ~80% of the remaining value.

| #   | Task                                                                                                         | Impact | Effort | Category     |
| --- | ------------------------------------------------------------------------------------------------------------ | ------ | ------ | ------------ |
| 1   | **Commit this session's vendoring fix** (11 dirs + `scripts/` + doc edits)                                   | 🔴     | 2min   | Critical     |
| 2   | **Fix `git commit <--` in 3 skills** → clear prose; add a grep guard                                         | 🔴     | 10min  | Correctness  |
| 3   | **Fix stale skill counts** in README ("20"→19) + AGENTS.md ("18"/"9 of 18"→19/3)                             | 🔴     | 5min   | Docs         |
| 4   | **Delete empty `brainstorm-data-model/`**                                                                    | 🟡     | 1min   | Cleanup      |
| 5   | **Flesh out `bdd-testing`** — ginkgo syntax ref, test structure template, file naming                        | 🔴     | 45min  | Content      |
| 6   | **Flesh out `features-audit`** — FEATURES.md template with status badges + examples                          | 🔴     | 30min  | Content      |
| 7   | **Flesh out `docs-freshness-check`** — define "stale", configurable file list, methodology                   | 🟡     | 30min  | Content      |
| 8   | **Wire `sync-html-kit.sh --check` into CI / pre-commit**                                                     | 🔴     | 15min  | Drift guard  |
| 9   | **Re-verify `how-to-golang` code snippets** (gopter, json/v2, E2E HTTP, Rule 002)                            | 🟡     | 45min  | Quality      |
| 10  | **Convert `how-to-write-skills.md` to a skill dir** (eat our own dog food)                                   | 🟡     | 20min  | Architecture |
| 11  | **Create `library-guide` skill** from `LIBRARY_GUIDE.md` (13 Go libs)                                        | 🟡     | 45min  | New skill    |
| 12  | **Wire remaining cross-refs** (full-code-review→deduplicate-code, brutal-self-review→architecture-review)    | 🟡     | 15min  | Integration  |
| 13  | **Test trigger descriptions** with skill-creator's optimization loop                                         | 🟠     | 60min  | Validation   |
| 14  | **Add `allowed-tools`** to CLI-dependent skills (`d2`, `art-dupl`)                                           | 🟠     | 15min  | Config       |
| 15  | **Add output templates** to `todo-list-builder` and the 3 thin skills                                        | 🟡     | 30min  | Quality      |
| 16  | **Create `crush.json`** for repo-level `skills_paths` auto-discovery                                         | 🟠     | 10min  | Config       |
| 17  | **Add error-handling guidance** for missing external tools                                                   | 🟠     | 30min  | Robustness   |
| 18  | **Add `architecture-review` rubric** — assessment criteria + methodology in `references/`                    | 🟡     | 30min  | Content      |
| 19  | **Build eval test suite** — ≥2 prompts/skill, automated grading                                              | 🟠     | 2hr    | Validation   |
| 20  | **Add version/timestamp** frontmatter to track skill freshness                                               | ⚪     | 10min  | Maintenance  |
| 21  | **Document `html-report-kit` Artifact decision rule** centrally (it's in how-to-write-skills.md, surface it) | ⚪     | 10min  | Docs         |
| 22  | **Audit `originals/`** — confirm 17 files map 1:1 to skills, prune orphans                                   | ⚪     | 15min  | Cleanup      |
| 23  | **Add `.gitignore`** for any build artifacts if vendoring moves to generated-only                            | ⚪     | 5min   | Hygiene      |
| 24  | **Standardize execution footer** — reference a shared block instead of copy-pasting                          | ⚪     | 15min  | DRY          |
| 25  | **Generate a repo skill-dependency graph** (D2) showing the reference graph                                  | ⚪     | 20min  | Docs         |

---

## G) TOP #1 QUESTION I CANNOT FIGURE OUT MYSELF

**Should the vendored `html-report-kit` copies be committed to git, or regenerated by a pre-install/build step?**

The vendoring model I implemented works in all install modes, but it duplicates ~40 files (the kit × 10 consumers) into the repo. Two valid approaches with real tradeoffs:

| Approach                                                     | Pro                                                                                                                | Con                                                                                                                                                                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Commit vendored copies** (current working-tree state)      | Works even when a user clones a _single_ skill directory with no repo context; no tooling required at install time | 40 duplicate files in git; drift risk (mitigated by `--check`, but still a maintenance surface)                                                                                                              |
| **Regenerate via `sync-html-kit.sh` + gitignore the copies** | Single source of truth in git; no duplication                                                                      | Breaks `bunx skills add <repo>@<one-skill>` — the CLI copies from the repo working tree, so if the copy isn't committed, the consumer ships without its `assets/html-report-kit/` and the path dangles again |

The skills CLI has no build hook and no post-install step — it copies files verbatim from the repo. That **forces** committing the vendored copies if per-skill install must work. But I want to confirm: is per-skill install (`bunx skills add <repo>@<one-skill>`) actually a flow you use, or do you always install the whole repo / use `skills_paths`? If you only ever use the whole repo, the duplication is unnecessary and we could gitignore the copies and regenerate on demand.

**The answer determines whether I commit the 40 files or gitignore them — and I won't commit until you say which.**

---

## Skill-by-Skill Status Matrix (current)

| Skill                        | Lines | Quality          | `references/` | Thin?      | Notes                             |
| ---------------------------- | ----- | ---------------- | ------------- | ---------- | --------------------------------- |
| `architecture-review`        | 51    | 🟡 Thin+         | ❌            | borderline | Needs rubric/methodology ref      |
| `architecture-visualization` | 46    | 🟢 Solid         | ❌            | No         | No error handling if `d2` missing |
| `bdd-testing`                | 23    | 🔴 Thin          | ❌            | Yes        | Zero ginkgo syntax                |
| `brutal-self-review`         | 75    | 🟢 Solid         | ✅            | No         | `git commit <--` fixed here       |
| `code-quality-scan`          | 43    | 🟡 Thin+         | ❌            | borderline | `art-dupl` undocumented           |
| `data-model-review`          | 147   | 🟢 Comprehensive | ✅            | No         | New                               |
| `deduplicate-code`           | 144   | 🟢 Solid         | ❌            | No         | Was 27 lines — big improvement    |
| `docs-freshness-check`       | 29    | 🔴 Thin          | ❌            | Yes        | Hardcoded file list               |
| `features-audit`             | 24    | 🔴 Thin          | ❌            | Yes        | No FEATURES.md template           |
| `full-code-review`           | 78    | 🟢 Comprehensive | ✅            | No         | `git commit <--` ×3               |
| `go-modularize`              | 872   | 🟢 Comprehensive | ❌            | No         | New; largest skill                |
| `how-to-golang`              | 93    | 🟢 Comprehensive | ✅ 9          | No         | Code accuracy unverified          |
| `html-report-kit`            | 82    | 🟢 Solid         | ✅            | No         | Canonical kit; vendored to 10     |
| `naming-review`              | 266   | 🟢 Comprehensive | ✅            | No         | New                               |
| `nix-flake-migration`        | 163   | 🟢 Solid         | ❌            | No         | Was 21 lines — huge improvement   |
| `nix-review`                 | 231   | 🟢 Comprehensive | ✅            | No         | New                               |
| `pareto-planning`            | 79    | 🟢 Solid         | ❌            | No         | `git commit <--` ×2               |
| `status-report`              | 52    | 🟡 Functional    | ❌            | No         | `git commit <--` ×1               |
| `todo-list-builder`          | 46    | 🟢 Solid         | ❌            | No         | Clean                             |

**Summary:** 13 🟢 solid/comprehensive, 3 borderline, 3 🔴 thin. 0 skills empirically tested.

---

## Metrics (now vs May-3 audit)

| Metric                                      | May-3    | Now               | Δ        |
| ------------------------------------------- | -------- | ----------------- | -------- |
| Total skills                                | 15       | 19                | +4       |
| Skills with `references/`                   | 3 (20%)  | 7 (37%)           | +4       |
| Thin skills (<35 lines)                     | 9 (60%)  | 3 (16%)           | **−6**   |
| Comprehensive skills (>60 lines)            | 4 (27%)  | 13 (68%)          | +9       |
| Skills with output templates                | 2 (13%)  | 10 (53%, via kit) | +8       |
| `git commit <--` occurrences                | 4 skills | 3 skills (6 occ.) | −1 skill |
| Cross-skill references                      | 1        | 11+               | +10      |
| Skills empirically tested                   | 0        | 0                 | —        |
| `html-report-kit` install-safe under `bunx` | ❌ broke | ✅ vendored       | fixed    |

---

_Report generated from a full re-audit of all 19 skill directories, verification of every May-3 finding against current files, and the vendoring work landed this session._
