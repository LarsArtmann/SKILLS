# Status Report — SKILLS Project: Session 2

**Date:** 2026-05-02 22:50
**Project:** SKILLS — Crush Agent Skills knowledge base
**Session scope:** Review of `how-to-write-skills.md` against `skill-creator` skill + comparison

---

## a) FULLY DONE

| # | Item                                                           | Details                                                    |
| - | -------------------------------------------------------------- | ---------------------------------------------------------- |
| 1 | All 14 skills created with SKILL.md                            | Each in its own directory with YAML frontmatter            |
| 2 | Skills refactored for consistent formatting                    | Commit `5c3a09b` — metadata, mantra, structure unified     |
| 3 | Markdown formatting consistency pass                           | Commit `be1a2af` — tables, indentation, blank lines        |
| 4 | Extracted `references/go-ecosystem.md`                         | Used by `brutal-self-review`                               |
| 5 | Extracted `references/architect-checklist.md`                  | Used by `full-code-review`                                 |
| 6 | `how-to-write-skills.md` comprehensive rewrite                 | 138 → 233 lines; merged insights from `skill-creator`      |
| 7 | Full comparison of `how-to-write-skills.md` vs `skill-creator` | Identified gaps, overlaps, and improvements                |
| 8 | Previous status report                                         | `docs/status/2026-05-02_22-50_skills-conversion-status.md` |

### What the `how-to-write-skills.md` rewrite added

| Addition                                                     | Source                                   |
| ------------------------------------------------------------ | ---------------------------------------- |
| Subdirectory guide table (when/how agent accesses each dir)  | Synthesized                              |
| Three-level progressive disclosure system with context costs | From `skill-creator`                     |
| "Explain the why, not just the what" principle (#4)          | From `skill-creator` writing philosophy  |
| "Define output formats with examples" principle (#6)         | From `skill-creator` patterns            |
| Multi-domain skill organization section                      | From `skill-creator` domain organization |
| Pushy description guidance (under-triggering)                | From `skill-creator`                     |
| Testing your skill section                                   | From `skill-creator` eval workflow       |
| Expanded common mistakes (3 new entries)                     | Gap analysis                             |
| "Bundled scripts" proven pattern                             | From `skill-creator`                     |

### Known remaining gaps in `how-to-write-skills.md`

Two items identified but not yet added:

1. ~~**Triggering mechanism explanation**~~ done — documented in how-to-write-skills.md §1 (trigger-context doctrine, 2026-08-11)
2. ~~**"When to use" template section purpose** — ambiguous~~ Won't implement — superseded: the description-as-trigger doctrine (2026-08-11) dissolved the distinction

---

## b) PARTIALLY DONE

| Item                                             | What's Done                      | What's Left                                                                            |
| ------------------------------------------------ | -------------------------------- | -------------------------------------------------------------------------------------- |
| `how-to-write-skills.md` vs `skill-creator` sync | Major improvements committed     | ~~2 minor gaps above~~ both closed                                                     |
| `architecture-visualization`                     | D2 change was externally applied | ~~Still not verified as intentional~~ verified — D2 is canonical (`allowed-tools: d2`) |

---

## c) NOT STARTED

| #      | Item                                                                                                                                                     | Priority     | Notes                                          |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ---------------------------------------------- |
| ~~1~~  | ~~Test all 14 skills in Crush~~ done — superseded by behavioral trigger tests (jj T27) + --triggers density checks                                       | ~~Critical~~ | ~~Verify they activate on correct triggers~~   |
| ~~2~~  | ~~Create `crush.json` with `skills_paths`~~ **Won't implement — NOT-DO — intentional: skills installed via skills_paths or skills add (AGENTS §5.7).**   | ~~Critical~~ | ~~Needed for Crush to discover these skills~~  |
| ~~3~~  | ~~Write README.md for the SKILLS project~~ done — README.md shipped 2026-05-03                                                                           | ~~High~~     | ~~Explain project, list all skills~~           |
| ~~4~~  | ~~Remove original `1.md`–`17.md` files~~ **Won't implement — resolved by decision — originals/ kept as frozen source material.**                         | ~~Medium~~   | ~~Waiting on user confirmation~~               |
| ~~5~~  | ~~Refine descriptions from activation testing~~ done — descriptions rewritten trigger-first 2026-08-11                                                   | ~~High~~     | ~~Depends on #1~~                              |
| ~~6~~  | ~~Add cross-references between related skills~~ done — inter-skill graph documented in AGENTS §5.5                                                       | ~~Medium~~   | ~~e.g., brutal-self-review → pareto-planning~~ |
| ~~7~~  | ~~Flesh out thin skills (nix-flake-migration: 21L, architecture-review: 30L)~~ done — thin-skill waves 2026-06/08; zero thin since                       | ~~Medium~~   | ~~Currently very sparse~~                      |
| ~~8~~  | ~~Add `allowed-tools` to skills where appropriate~~ done — allowed-tools adopted (AGENTS §5.8)                                                           | ~~Low~~      | ~~Experimental feature~~                       |
| ~~9~~  | ~~Reference `go-ecosystem.md` from full-code-review and code-quality-scan~~ done — go-ecosystem content absorbed by how-to-golang + go-ecosystem-upgrade | ~~Medium~~   | ~~Currently only in brutal-self-review~~       |
| ~~10~~ | ~~Add CHANGELOG.md or version tracking~~ done — CHANGELOG.md created 2026-08-04                                                                          | ~~Low~~      | ~~No versioning exists~~                       |
| ~~11~~ | ~~Move `how-to-write-skills.md` to better location~~ done — routed to ROADMAP Open Questions — location decision                                         | ~~Low~~      | ~~Currently in project root~~                  |
| ~~12~~ | ~~Add `.gitignore` if needed~~ **Won't implement — not applicable — no build artifacts.**                                                                | ~~Low~~      | ~~Housekeeping~~                               |
| ~~13~~ | ~~Test with non-Go projects (false-positive check)~~ **Won't implement — ROADMAP-shaped — false-positive check folded into empirical-validation theme.** | ~~Low~~      | ~~Go-specific skills may falsely trigger~~     |

---

## d) TOTALLY FUCKED UP

Nothing. No known issues with the current files. All 14 skills have valid frontmatter, matching names, and committed improvements.

---

## e) WHAT WE SHOULD IMPROVE

### Structural

1. ~~**Skill descriptions need real-world trigger testing**~~ done in part — jj behavioral test (T27) + --triggers density checks; full loop is ROADMAP §1 — We wrote descriptions based on best guesses. Only actual Crush usage reveals if the agent activates the right skill at the right time. The `skill-creator` has a full description optimization loop (20 eval queries, automated A/B testing) that we should run on each skill.

2. ~~**Thin skills need fleshing out**~~ done — zero thin skills since 2026-06 (35-line floor guarded) — `nix-flake-migration` (21 lines) and `architecture-review` (30 lines) are prompts, not full skills. They lack decision trees, examples, and error handling that the `how-to-write-skills.md` guide itself recommends.

3. ~~**No inter-skill references**~~ done — AGENTS §5.5 graph + handoff guard — Skills that chain naturally (brutal-self-review → pareto-planning → execution-mode → status-report) don't reference each other. The agent discovers this only from descriptions.

4. ~~**Go-ecosystem reference is siloed**~~ done — absorbed by how-to-golang + go-ecosystem-upgrade — Only `brutal-self-review` uses `go-ecosystem.md`. `full-code-review`, `code-quality-scan`, and `bdd-testing` would also benefit.

### Content Quality

5. ~~**Original prompts had personality**~~ resolved by decision — tone is deliberate authorial voice; signal pass (2026-09-17) kept energy where it names instructions — We cleaned up formatting but may have lost some raw energy (e.g., "VERSCHLIMMBESSER" threats). The cleaned-up tone is more neutral. May or may not reduce effectiveness.

6. ~~**No examples in most skills**~~ done — html-report-kit templates + per-skill references — The `how-to-write-skills.md` guide now recommends "Define output formats with examples" as principle #6, but most existing skills don't follow this yet.

7. ~~**No versioning**~~ done — CHANGELOG date-based waves (deliberate non-semver) — When skills evolve, there's no record of what changed or when.

### Documentation

8. ~~**No README.md**~~ done — shipped 2026-05-03 — The project has no entry point explaining what it is, what skills exist, and how to use them.

9. ~~**`how-to-write-skills.md` still has 2 gaps**~~ done — both closed (see above) — Missing triggering mechanism explanation and "When to use" section clarification.

10. ~~**Original `.md` files (1–17) still exist**~~ done — relocated to originals/ at `c822b9d` — They're superseded by the skill directories but haven't been cleaned up.

---

## f) Top #25 Things We Should Get Done Next

| #      | Task                                                                                                                                                                              | Impact       | Effort     | Depends On              |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ---------- | ----------------------- |
| ~~1~~  | ~~Test all 14 skills in Crush — verify correct activation~~ done — superseded by behavioral trigger tests + --triggers                                                            | ~~Critical~~ | ~~30min~~  | ~~`crush.json` config~~ |
| ~~2~~  | ~~Create `crush.json` with `skills_paths` pointing to this repo~~ **Won't implement — NOT-DO — AGENTS §5.7 documents the deliberate omission.**                                   | ~~Critical~~ | ~~5min~~   | ~~—~~                   |
| ~~3~~  | ~~Write README.md for the SKILLS project~~ done — README.md exists                                                                                                                | ~~High~~     | ~~15min~~  | ~~—~~                   |
| ~~4~~  | ~~Refine descriptions based on activation test results~~ done — descriptions rewritten 2026-08-11                                                                                 | ~~High~~     | ~~30min~~  | ~~#1~~                  |
| ~~5~~  | ~~Run `skill-creator` description optimizer on all 14 skills~~ **Won't implement — ROADMAP-shaped — skill-creator optimizer needs claude CLI (ROADMAP §1).**                      | ~~High~~     | ~~2hr~~    | ~~#1, #2~~              |
| ~~6~~  | ~~Remove original `1.md`–`17.md` after user confirmation~~ **Won't implement — resolved by decision — originals/ retained.**                                                      | ~~Medium~~   | ~~2min~~   | ~~User OK~~             |
| ~~7~~  | ~~Flesh out `nix-flake-migration` with decision tree, examples~~ done — nix-flake-migration consolidated into html-report-kit                                                     | ~~Medium~~   | ~~15min~~  | ~~—~~                   |
| ~~8~~  | ~~Flesh out `architecture-review` with detailed process steps~~ done — architecture-review references added 2026-08-04                                                            | ~~Medium~~   | ~~15min~~  | ~~—~~                   |
| ~~9~~  | ~~Add cross-references between chained skills~~ done — cross-references wired (§5.5 graph)                                                                                        | ~~Medium~~   | ~~20min~~  | ~~—~~                   |
| ~~10~~ | ~~Reference `go-ecosystem.md` from full-code-review, code-quality-scan, bdd-testing~~ done — absorbed by how-to-golang/go-ecosystem-upgrade                                       | ~~Medium~~   | ~~5min~~   | ~~—~~                   |
| ~~11~~ | ~~Add examples/output formats to each skill that lacks them~~ done — output templates ship via html-report-kit                                                                    | ~~Medium~~   | ~~30min~~  | ~~—~~                   |
| ~~12~~ | ~~Add "When to use" clarification to `how-to-write-skills.md` template~~ **Won't implement — moot — the template section question was resolved in later guide versions.**         | ~~Low~~      | ~~5min~~   | ~~—~~                   |
| ~~13~~ | ~~Add triggering mechanism explanation to `how-to-write-skills.md`~~ done — triggering mechanism documented in how-to-write-skills §1                                             | ~~Low~~      | ~~10min~~  | ~~—~~                   |
| ~~14~~ | ~~Verify `architecture-visualization` D2 change was intentional~~ done — D2 canonical (allowed-tools: d2)                                                                         | ~~Low~~      | ~~2min~~   | ~~User input~~          |
| ~~15~~ | ~~Consider splitting `execution-mode` into reflect vs execute skills~~ done — execution-mode split into brutal-self-review + pareto-planning                                      | ~~Low~~      | ~~15min~~  | ~~—~~                   |
| ~~16~~ | ~~Add `allowed-tools` to skills that need specific tools~~ done — AGENTS §5.8                                                                                                     | ~~Low~~      | ~~15min~~  | ~~—~~                   |
| ~~17~~ | ~~Add CHANGELOG.md~~ done — CHANGELOG.md (2026-08-04)                                                                                                                             | ~~Low~~      | ~~10min~~  | ~~—~~                   |
| ~~18~~ | ~~Move `how-to-write-skills.md` to `docs/`~~ done — routed to ROADMAP Open Questions — location decision                                                                          | ~~Low~~      | ~~2min~~   | ~~—~~                   |
| ~~19~~ | ~~Add `.gitignore`~~ **Won't implement — not applicable.**                                                                                                                        | ~~Low~~      | ~~2min~~   | ~~—~~                   |
| ~~20~~ | ~~Test with non-Go projects (false-positive check)~~ **Won't implement — ROADMAP-shaped — empirical validation theme.**                                                           | ~~Low~~      | ~~15min~~  | ~~#1~~                  |
| ~~21~~ | ~~Create a `scripts/` helper for any skill that does repetitive work~~ done — skills now bundle scripts/ (naming-smells, pre-release-check, validate-workflow, social-preview...) | ~~Low~~      | ~~Varies~~ | ~~Usage testing~~       |
| ~~22~~ | ~~Write integration tests for skill triggering accuracy~~ **Won't implement — ROADMAP-shaped — empirical validation theme.**                                                      | ~~Low~~      | ~~1hr~~    | ~~#1, #2~~              |
| ~~23~~ | ~~Add `metadata.tags` that are more specific/useful~~ done — tags curated                                                                                                         | ~~Low~~      | ~~10min~~  | ~~—~~                   |
| ~~24~~ | ~~Consider a skill registry/index that maps user intents → skills~~ **Won't implement — declined — descriptions are the index.**                                                  | ~~Low~~      | ~~20min~~  | ~~—~~                   |
| ~~25~~ | ~~Archive or git-tag the pre-conversion state for history~~ done — originals/ preserves the pre-conversion state                                                                  | ~~Low~~      | ~~2min~~   | ~~—~~                   |

---

## g) Top #1 Question I Can NOT Figure Out Myself

**~~Should these skills live in this repo (SKILLS), in `~/.config/crush/skills/` globally, or be distributed to individual project repos?~~** RESOLVED 2026-08-14 — the hybrid runtime-symlink model: this repo is canonical; `~/.agents/skills/` holds relative symlinks per skill; `~/.config/crush/skills/` chains through (AGENTS §5.10).

The answer changes everything about how we configure discovery:

| Location                                                 | Pros                                                    | Cons                                                  |
| -------------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------- |
| **This repo + `skills_paths`**                           | Centralized, version-controlled, single source of truth | Every project needs `crush.json` config               |
| **`~/.config/crush/skills/`**                            | Zero config, globally available                         | Go-specific skills falsely trigger on non-Go projects |
| **Per-project `.agents/skills/`**                        | Auto-discovered, project-scoped                         | Duplicated across repos, no single source of truth    |
| **Hybrid: generic skills global, Go skills per-project** | Best of both worlds                                     | More complex to maintain                              |

I genuinely cannot determine the right deployment strategy without your input.

---

_Report generated by Crush._
