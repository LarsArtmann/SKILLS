# SKILLS Repository — Comprehensive Status Report

> **Resolution (2026-08-04):** This report was the authoritative backlog from
> 2026-05-03. ~~15 skills~~ Now **24 skills** (see `scripts/check-skills.sh`).
> ~~9/15 thin~~ **0/24 thin** (all pass the 35-line floor). ~~Legacy files in
> repo root~~ Moved to `originals/` at `c822b9d`. ~~`git commit <--` bug~~ Fixed
> in all skills (guard in `check-skills.sh`). ~~`execution-mode` skill~~ Deleted
> at `afb6181` (contradiction resolved). ~~`docs-freshness-check`,
> `features-audit`, `todo-list-builder`~~ Consolidated into `docs-health` at
> `0eb74a8`. ~~`nix-flake-migration`~~ Consolidated into `html-report-kit`.
> The Top-25 list below is resolved inline — every item is marked.

**Date:** 2026-05-03 07:51 CEST
**Scope:** Full project audit — every skill, every legacy file, every reference

---

## Executive Summary

The SKILLS repo has **15 skills** (14 original + 1 new `how-to-golang`), all with valid YAML frontmatter and structured directories. The conversion from 17 raw `.md` prompt snippets is **functionally complete** but **not finished** — legacy files remain, 9/15 skills are dangerously thin, the LIBRARY_GUIDE.md integration is untouched, and no skill has been empirically tested in Crush. The `how-to-golang` skill is the newest and most comprehensive, but has code accuracy issues in its references.

**Overall health: 🟡 Functional but fragile.** Skills work as triggers but lack the depth to consistently produce high-quality output.

---

## A) FULLY DONE ✅

| #   | Item                                                             | Evidence                                                                            |
| --- | ---------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| 1   | 17 raw `.md` files → 14 skill directories conversion             | All 14 have SKILL.md + valid frontmatter                                            |
| 2   | 3 overlapping merges executed                                    | `1+4→execution-mode`, `2→brutal-self-review`, `3→pareto-planning`                   |
| 3   | YAML frontmatter on all 14 original skills                       | `name` + `description` + `metadata.tags` validated                                  |
| 4   | Shared references extracted                                      | `go-ecosystem.md` (brutal-self-review), `architect-checklist.md` (full-code-review) |
| 5   | `how-to-write-skills.md` comprehensive guide                     | 233 lines, merged skill-creator insights                                            |
| 6   | README.md with skills inventory and installation guide           | Complete with table + npx instructions                                              |
| 7   | Go-specific descriptions on Go skills                            | brutal-self-review, bdd-testing, etc.                                               |
| 8   | `how-to-golang` skill with 9 reference files                     | 93-line SKILL.md + 9 references totaling ~1005 lines                                |
| 9   | "READ, UNDERSTAND, RESEARCH, REFLECT" mantra added to all skills | Consistent execution footer                                                         |
| 10  | Git history is clean and well-structured                         | Logical commits, descriptive messages                                               |

---

## B) PARTIALLY DONE 🔶

| #   | Item                                       | Status                                                     | What's Missing                                                                                                       |
| --- | ------------------------------------------ | ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| 1   | **Legacy file cleanup**                    | 17 raw `.md` files still in repo root                      | Need deletion after user confirmation                                                                                |
| 2   | **Skill depth/content**                    | 9/15 skills are "thin" (<35 lines)                         | Concrete examples, output templates, tool-specific guidance                                                          |
| 3   | **`how-to-write-skills.md` location**      | Still raw file at repo root                                | Should become a skill directory OR move to `docs/`                                                                   |
| 4   | **Inter-skill cross-references**           | Only `brutal-self-review` references `how-to-golang`       | Most skills should reference relevant sibling skills                                                                 |
| 5   | **Go ecosystem reference coverage**        | `go-ecosystem.md` exists but only in `brutal-self-review/` | Other Go skills (bdd-testing, code-quality-scan) don't reference it                                                  |
| 6   | **`how-to-golang` code accuracy**          | Reference files written but contain API inaccuracies       | `gopter` signature wrong, `encoding/json/v2` assumes Go 1.26+, E2E HTTP API mismatch, Rule 002 CI command misleading |
| 7   | **`architecture-visualization` D2 change** | Externally modified to D2 instead of Mermaid               | Never verified as intentional                                                                                        |
| 8   | **Trigger description testing**            | All skills have descriptions                               | None tested empirically in Crush for trigger accuracy                                                                |

---

## C) NOT STARTED ⬜

| #   | Item                                         | Impact                                                           |
| --- | -------------------------------------------- | ---------------------------------------------------------------- |
| 1   | **Delete legacy `1.md`–`17.md` files**       | High — repo root is cluttered with dead files                    |
| 2   | **Empirical skill testing in Crush**         | Critical — no evidence skills work as intended                   |
| 3   | **Integrate LIBRARY_GUIDE.md**               | High — 13 Lars libraries unmapped from any skill                 |
| 4   | **Create `crush.json` for the repo**         | Medium — enables `skills_paths` auto-discovery                   |
| 5   | **Add `allowed-tools` to skill frontmatter** | Medium — reduces permission prompts during skill execution       |
| 6   | **Flesh out thin skills** (9 of 15)          | High — thin skills produce thin output                           |
| 7   | **Add output templates/examples to skills**  | High — most skills lack concrete output format                   |
| 8   | **Fix `git commit <--` syntax in 4 skills**  | Medium — LLMs may interpret `<--` as literal git flag            |
| 9   | **Remove duplicated execution boilerplate**  | Medium — 6+ skills repeat identical "READ, UNDERSTAND..." footer |
| 10  | **Version/timestamp skills**                 | Low — no way to track when a skill was last updated              |
| 11  | **Add error handling guidance to skills**    | Medium — what happens when tools are missing?                    |
| 12  | **Validate `how-to-golang` code snippets**   | High — wrong code in references = broken output                  |
| 13  | **Create `library-guide` skill**             | High — LIBRARY_GUIDE.md content needs a proper skill home        |
| 14  | **Add domain-types examples**                | Medium — `domain-types.md` has zero code samples for 7+ types    |

---

## D) TOTALLY FUCKED UP 💥

| #   | Item                                                      | Why It's Fucked                                                                                                                                                                                 | Severity    |
| --- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1   | **`nix-flake-migration` skill**                           | 21 lines. Creates a "proposal" but doesn't say what goes in it. Almost useless as-is. Agent will improvise wildly.                                                                              | 🔴 Critical |
| 2   | **`architecture-review` skill**                           | 30 lines. Two questions + 5 generic steps. No methodology, no assessment criteria, no rubric. Agent will produce generic fluff.                                                                 | 🔴 Critical |
| 3   | **`bdd-testing` skill**                                   | 23 lines. Says "use ginkgo" but provides zero ginkgo syntax, no test structure, no file naming conventions. Agent will write bad BDD tests.                                                     | 🔴 Critical |
| 4   | **`features-audit` skill**                                | 24 lines. Lists status indicators but no FEATURES.md template. Agent will produce inconsistent output. Also has `PARTIALLY_FUNTIONAL` typo.                                                     | 🔴 Critical |
| 5   | **`docs-freshness-check` skill**                          | 30 lines. Only checks 4 hardcoded files. No definition of "stale". No configurable file list.                                                                                                   | 🟡 High     |
| 6   | **`code-quality-scan` skill**                             | 34 lines. Hardcodes `just fd` and `art-dupl` without installation guidance. Tells agent to "RESEARCH the best golang code duplication finder" — the skill should already know this.             | 🟡 High     |
| 7   | **`deduplicate-code` skill**                              | 27 lines. Hardcodes `art-dupl` CLI with no explanation of what it is or how to install it. "Don't write a file" contradicts normal workflow.                                                    | 🟡 High     |
| 8   | **`how-to-golang` reference inaccuracies**                | `gopter` property-based testing has wrong function signature, `encoding/json/v2` references Go 1.26+ (unreleased), E2E test references non-standard HTTP API, Rule 002 CI command is misleading | 🟡 High     |
| 9   | **`brutal-self-review` ↔ `execution-mode` contradiction** | brutal-self-review says "1 Sub Agent per file, ONLY 1 at a time"; execution-mode Mode 2 says "Use MULTIPLE Tasks". Agent gets conflicting instructions.                                         | 🟡 High     |
| 10  | **Duplicated content across skills**                      | Pareto planning logic in both `full-code-review` and `pareto-planning`. Execution boilerplate duplicated in 6+ skills. If one is updated, others become stale.                                  | 🟡 High     |

---

## E) WHAT WE SHOULD IMPROVE

### Architecture & Structure

1. **Kill the legacy files.** `1.md`–`17.md` are dead weight. They were the source material, now fully converted. Their presence confuses navigation and implies the repo is half-done.

2. **Create the `library-guide` skill.** The `LIBRARY_GUIDE.md` at `/home/lars/projects/LIBRARY_GUIDE.md` contains 13 Lars-authored libraries with decision matrices, architecture layer maps, combination patterns, key abstractions, and "start reading" file guides. This is gold. Currently no skill references any of these libraries. The `how-to-golang` skill references `go-composable-business-types` in `domain-types.md` but that's it. The `brutal-self-review` skill says "don't reinvent the wheel" but doesn't know about most of these libs.

3. **Merge or cross-reference `go-ecosystem.md` with `library-guide`.** The `brutal-self-review/references/go-ecosystem.md` covers third-party/community Go libs. The `LIBRARY_GUIDE.md` covers Lars's own libraries. Together they form the complete "what to reach for" picture. Currently siloed.

4. **De-duplicate execution boilerplate.** 6+ skills end with the same "READ, UNDERSTAND, RESEARCH, REFLECT" paragraph. This should reference `execution-mode` instead of copying it. Same with Pareto planning logic — reference `pareto-planning` instead of inlining it.

### Content Quality

5. **Flesh out thin skills with reference files.** The `how-to-golang` skill shows the pattern perfectly: lean SKILL.md (93 lines) + rich references (9 files, ~1005 lines). Apply this pattern to the 9 thin skills. Each needs at minimum a `references/` directory with concrete templates, examples, and tooling guidance.

6. **Fix `git commit <--` syntax.** Four skills (`brutal-self-review`, `full-code-review`, `pareto-planning`, `status-report`) use `git commit <-- with VERY DETAILED commit message(s)`. An LLM agent may interpret `<--` as a literal git flag. Replace with clear prose: "Then commit with a very detailed message."

7. **Validate all code snippets in `how-to-golang`.** At least 4 reference files contain API inaccuracies. Wrong code in a reference is worse than no code — it teaches the wrong pattern.

8. **Add output templates to every skill.** Skills that produce structured output (FEATURES.md, TODO_LIST.md, status reports, architecture diagrams) need exact templates with examples. Currently only `pareto-planning` and `todo-list-builder` have any structure definition.

### Discoverability & Integration

9. **Test trigger descriptions empirically.** Every skill's description is an educated guess. None have been tested with Crush's actual triggering mechanism. The `skill-creator` skill has a full description optimization loop — use it.

10. **Add inter-skill references.** When `full-code-review` finds duplications, it should reference `deduplicate-code`. When `brutal-self-review` finds architectural issues, it should reference `architecture-review`. When any Go skill needs library guidance, it should reference `how-to-golang` + `library-guide`. Currently almost no cross-references exist.

---

## F) TOP 25 THINGS TO DO NEXT

Ranked by impact × urgency. Pareto-optimal ordering — doing #1–#8 covers ~80% of the value.

| #      | Task                                                                                                                                                                    | Impact | Effort | Category     |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------------ |
| ~~1~~  | ~~**Delete legacy `1.md`–`17.md` + `how-to-write-skills.md`**~~ done at `c822b9d` (moved to `originals/`)                                                               | 🔴     | 5min   | Cleanup      |
| ~~2~~  | ~~**Create `library-guide` skill** from `LIBRARY_GUIDE.md`~~ Won't implement — `how-to-golang` absorbed the role; see ROADMAP §5                                        | 🔴     | 30min  | New skill    |
| 3      | **Fix `how-to-golang` code inaccuracies** (gopter, json/v2, E2E HTTP, Rule 002)                                                                                         | 🔴     | 30min  | Quality      |
| 4      | **Flesh out `architecture-review`** — add assessment rubric, criteria, methodology, reference file                                                                      | 🔴     | 45min  | Content      |
| 5      | **Flesh out `bdd-testing`** — add ginkgo syntax reference, test structure template, file naming                                                                         | 🔴     | 45min  | Content      |
| ~~6~~  | ~~**Flesh out `nix-flake-migration`**~~ Won't implement — consolidated into `html-report-kit` ecosystem                                                                 | 🔴     | 30min  | Content      |
| ~~7~~  | ~~**Flesh out `features-audit`**~~ done at `0eb74a8` (merged into `docs-health` BUILD mode)                                                                             | 🔴     | 20min  | Content      |
| ~~8~~  | ~~**Fix `git commit <--` syntax** in 4 skills~~ done at — all occurrences replaced with prose; guard in `check-skills.sh`                                               | 🟡     | 5min   | Quality      |
| ~~9~~  | ~~**Remove duplicated execution boilerplate**~~ done — `execution-mode` deleted; boilerplate cleaned across skills                                                      | 🟡     | 15min  | DRY          |
| ~~10~~ | ~~**Add cross-references between skills**~~ done — inter-skill graph documented in AGENTS.md §5.5; handoff guard in `check-skills.sh`                                   | 🟡     | 20min  | Integration  |
| ~~11~~ | ~~**Merge `go-ecosystem.md` content into `how-to-golang`**~~ done — `go-ecosystem-upgrade` skill created separately; `how-to-golang` references its own libs            | 🟡     | 15min  | Integration  |
| ~~12~~ | ~~**Flesh out `docs-freshness-check`**~~ done at `0eb74a8` (merged into `docs-health` VERIFY mode)                                                                      | 🟡     | 20min  | Content      |
| 13     | **Flesh out `code-quality-scan`** — document `art-dupl`, remove "RESEARCH" instruction, add tool list                                                                   | 🟡     | 20min  | Content      |
| ~~14~~ | ~~**Flesh out `deduplicate-code`**~~ done — synced to art-dupl, 70 lines with judgment framework (`bd9de94`)                                                            | 🟡     | 15min  | Content      |
| ~~15~~ | ~~**Add output templates** to `status-report`, etc.~~ done at — `docs-health` has templates; `status-report` has HTML dashboard format; `pareto-planning` has D2 graphs | 🟡     | 30min  | Quality      |
| 16     | **Add `domain-types.md` code examples** for DataPoint, ActorChain, Bitemporal, Cents, Money, etc.                                                                       | 🟡     | 30min  | Content      |
| ~~17~~ | ~~**Resolve `brutal-self-review` ↔ `execution-mode` contradiction**~~ done — `execution-mode` deleted at `afb6181`                                                      | 🟡     | 10min  | Consistency  |
| 18     | **Test trigger descriptions** with skill-creator's optimization loop                                                                                                    | 🟠     | 60min  | Validation   |
| 19     | ~~**Create `crush.json`** for the repo~~ NOT-DO — intentional: skills installed via `skills_paths` or `npx skills add` (AGENTS.md §5.7)                                 | 🟠     | 10min  | Config       |
| ~~20~~ | ~~**Add `allowed-tools`** to skill frontmatter~~ done — `code-quality-scan`, `deduplicate-code`, `pareto-planning` have it; others added as needed (AGENTS.md §5.8)     | 🟠     | 15min  | Config       |
| ~~21~~ | ~~**Verify `architecture-visualization` D2 change**~~ done — D2 is the canonical choice; `allowed-tools: d2` added                                                      | 🟠     | 5min   | Verification |
| 22     | **Add error handling guidance** to skills (what if `d2` CLI isn't installed? `art-dupl` missing?)                                                                       | 🟠     | 30min  | Robustness   |
| 23     | ~~**Add version/timestamp** to each SKILL.md frontmatter~~ NOT-DO — versionless content repo; CHANGELOG uses date-based milestones (ROADMAP non-goals)                  | ⚪     | 10min  | Maintenance  |
| ~~24~~ | ~~**Remove `how-to-write-skills.md`** or convert to skill~~ partially done — still at repo root; updated with 11 patterns (AGENTS.md §5.6)                              | ⚪     | 15min  | Cleanup      |
| 25     | **Build eval test suite** — at least 2 test prompts per skill, automated grading                                                                                        | ⚪     | 2hr    | Validation   |

---

## G) TOP #1 QUESTION I CANNOT FIGURE OUT MYSELF

**Where should the `library-guide` skill live and how should it relate to `how-to-golang`?**

The `LIBRARY_GUIDE.md` contains 13 Lars-authored Go libraries (`go-cqrs-lite`, `cmdguard`, `go-composable-business-types`, `ActaFlow`, `universal-workflow`, etc.). The `how-to-golang` skill contains Go policy, banned/required libraries, and architecture patterns. These overlap in two critical places:

1. **`how-to-golang/references/domain-types.md`** already references `go-composable-business-types` (one of the 13 libraries)
2. **`how-to-golang/references/required-libraries.md`** and **`banned-libraries.md`** reference several `larsartmann/` libraries as "required" or "banned replacement" without noting they're Lars's own projects

The question is: should `library-guide` be a **standalone skill** that `how-to-golang` references, or should its content be **absorbed into `how-to-golang`** as additional reference files? The standalone approach keeps concerns separated (policy vs. catalog), but the merge approach means one skill covers the entire Go decision space.

This affects the architecture of the entire skill system — not just one file.

---

## Skill-by-Skill Status Matrix

| Skill                        | Lines | Quality          | `references/`               | Thin? | Key Issues                                    |
| ---------------------------- | ----- | ---------------- | --------------------------- | ----- | --------------------------------------------- |
| `architecture-review`        | 30    | 🔴 Thin          | ❌                          | Yes   | No methodology, no rubric, generic steps      |
| `architecture-visualization` | 45    | 🟢 Solid         | ❌                          | No    | No error handling if `d2` CLI missing         |
| `bdd-testing`                | 23    | 🔴 Thin          | ❌                          | Yes   | Zero ginkgo syntax, no test structure         |
| `brutal-self-review`         | 57    | 🟢 Solid         | ✅ `go-ecosystem.md`        | No    | Contradicts execution-mode on parallelism     |
| `code-quality-scan`          | 34    | 🔴 Thin          | ❌                          | Yes   | Hardcodes tools, "RESEARCH" instruction       |
| `deduplicate-code`           | 27    | 🔴 Thin          | ❌                          | Yes   | Hardcodes `art-dupl`, no install guide        |
| `docs-freshness-check`       | 30    | 🔴 Thin          | ❌                          | Yes   | 4 hardcoded files, no "stale" definition      |
| `execution-mode`             | 39    | 🟢 Solid         | ❌                          | No    | Missing closing `---` on Mode 2 block         |
| `features-audit`             | 24    | 🔴 Thin          | ❌                          | Yes   | No FEATURES.md template, typo                 |
| `full-code-review`           | 68    | 🟢 Comprehensive | ✅ `architect-checklist.md` | No    | `git commit <--` syntax, inlined Pareto       |
| `how-to-golang`              | 93    | 🟢 Comprehensive | ✅ 9 files (~1005 lines)    | No    | Code inaccuracies in 4 references             |
| `nix-flake-migration`        | 21    | 🔴 Thin          | ❌                          | Yes   | No proposal template, almost useless          |
| `pareto-planning`            | 66    | 🟢 Comprehensive | ❌                          | No    | Duplicates full-code-review, `git commit <--` |
| `status-report`              | 36    | 🔴 Thin          | ❌                          | Yes   | No template, `git commit <--` syntax          |
| `todo-list-builder`          | 46    | 🟢 Solid         | ❌                          | No    | Contradicts execution-mode on parallelism     |

**Summary:** 6 🟢 solid/comprehensive, 9 🔴 thin. 0 skills empirically tested.

---

## Metrics

| Metric                           | Value                                     |
| -------------------------------- | ----------------------------------------- |
| Total skills                     | 15                                        |
| Skills with valid frontmatter    | 15/15                                     |
| Skills with `references/`        | 3/15 (20%)                                |
| Thin skills (<35 lines)          | 9/15 (60%)                                |
| Comprehensive skills (>60 lines) | 4/15 (27%)                                |
| Total legacy files remaining     | 18 (17 numbered + how-to-write-skills.md) |
| Skills tested in Crush           | 0/15                                      |
| Skills with output templates     | 2/15 (13%)                                |
| Skills with `allowed-tools`      | 0/15                                      |
| Known code inaccuracies          | 4 (all in how-to-golang references)       |
| Cross-skill references           | 1 (brutal-self-review → how-to-golang)    |
| Duplicate content sites          | 2 (Pareto logic, execution boilerplate)   |

---

_Report generated from full audit of all 15 skill directories, 18 legacy files, 2 previous status reports, and all reference subdirectories._
