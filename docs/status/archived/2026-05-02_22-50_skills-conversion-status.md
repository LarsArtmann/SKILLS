# Status Report — Skills Conversion Project

**Date:** 2026-05-02 22:50
**Project:** SKILLS — Converting prompt snippets into Crush Agent Skills

---

## a) FULLY DONE

| Item                                                               | Status  | Details                                                               |
| ------------------------------------------------------------------ | ------- | --------------------------------------------------------------------- |
| Read all 17 original .md files                                     | ✅ Done | All files analyzed and categorized                                    |
| Group and merge overlapping prompts                                | ✅ Done | 3 merges: 1+4→execution-mode, 2→brutal-self-review, 3→pareto-planning |
| Create 14 skill directories                                        | ✅ Done | All directories with SKILL.md created                                 |
| YAML frontmatter validation                                        | ✅ Done | All 14 pass: name matches dir, has description, has closing `---`     |
| Add `metadata.tags` to all skills                                  | ✅ Done | All 14 skills have tags                                               |
| Add "READ, UNDERSTAND, RESEARCH, REFLECT" mantra to all skills     | ✅ Done | All 14 skills include the mantra                                      |
| Extract Go ecosystem libs to `references/go-ecosystem.md`          | ✅ Done | brutal-self-review references it                                      |
| Extract architect checklist to `references/architect-checklist.md` | ✅ Done | full-code-review references it                                        |
| Go-specific descriptions for Go skills                             | ✅ Done | brutal-self-review and bdd-testing mention "(Go projects)"            |
| Remove leftover WARNING from code-quality-scan                     | ✅ Done | Replaced with proper nix/justfile detection                           |
| Standardize skill structure                                        | ✅ Done | All follow: frontmatter → intro → process → execution                 |
| Remove Pareto duplication from full-code-review                    | ✅ Done | Uses own planning steps, references architect-checklist               |
| Write how-to-write-skills.md guide                                 | ✅ Done | Comprehensive guide in project root                                   |
| Final validation — 14/14 pass                                      | ✅ Done | Name match, frontmatter, description, metadata, mantra                |

## b) PARTIALLY DONE

| Item                                                                            | Status            | What's Left                                                                                  |
| ------------------------------------------------------------------------------- | ----------------- | -------------------------------------------------------------------------------------------- |
| architecture-visualization was externally modified to use D2 instead of mermaid | Partially adapted | ~~verify it's intentional~~ done — D2 canonical |

## c) NOT STARTED

| Item                                                            | Priority | Notes                                         |
| --------------------------------------------------------------- | -------- | --------------------------------------------- |
| ~~Remove original 1.md–17.md files~~ | Low      | done — relocated to originals/ at `c822b9d` |
| ~~Write a README.md~~ | Medium   | done — shipped 2026-05-03 |
| ~~Test skills in Crush~~ | High     | done in part — jj behavioral test + --triggers |
| ~~Move how-to-write-skills.md~~ | Low      | routed — ROADMAP Open Questions |
| ~~Create a crush.json~~ | Medium   | Won't implement — deliberate (AGENTS §5.7) |
| ~~Verify descriptions trigger~~ | High     | done in part — trigger-first rewrite + --triggers STRONG |
| ~~Add `allowed-tools`~~ | Low      | done — AGENTS §5.8 |

## d) TOTALLY FUCKED UP

Nothing. No known issues with the current skill files.

## e) WHAT WE SHOULD IMPROVE

1. ~~**Skill descriptions need real-world testing**~~ done in part — jj behavioral test + --triggers; full loop ROADMAP §1 — We wrote descriptions based on our best guess of trigger phrases, but only actual Crush usage will reveal if the agent activates the right skill at the right time.

2. ~~**Some skills are very short**~~ done — consolidation + deepening waves; zero thin — `nix-flake-migration` (21L) and `architecture-review` (30L) are quite thin. They work as prompts but could benefit from more detailed process steps.

3. ~~**No inter-skill references**~~ done — AGENTS §5.5 graph — Skills that naturally chain together (e.g., `brutal-self-review` → `pareto-planning` → `execution-mode`) don't reference each other. The agent has to figure this out from descriptions alone.

4. ~~**Original prompts had personality/raw voice**~~ resolved by decision — tone kept where instructive; signal pass 2026-09-17 calibrated


5. ~~**Go-ecosystem reference is only in brutal-self-review**~~ done — absorbed by how-to-golang + go-ecosystem-upgrade — Other skills like `full-code-review` and `code-quality-scan` could also benefit from the Go lib awareness but don't reference it.

6. ~~**No versioning or changelog**~~ done — CHANGELOG.md date-based waves — Skills have no version tracking. When they evolve, there's no record of what changed.

## f) Top #25 Things We Should Get Done Next

| #  | Task                                                                                     | Impact   | Effort |
| -- | ---------------------------------------------------------------------------------------- | -------- | ------ |
| ~~1~~ | ~~Test all 14 skills in Crush~~ done in part — behavioral + density checks | Critical | 30min |
| ~~2~~ | ~~Create `crush.json`~~ Won't implement — deliberate (AGENTS §5.7) | Critical | 5min |
| ~~3~~ | ~~Write README.md~~ done — 2026-05-03 | High | 15min |
| ~~4~~ | ~~Remove original 1.md–17.md~~ done — relocated to originals/ (`c822b9d`) | High | 2min |
| ~~5~~ | ~~Refine descriptions~~ done — trigger-first rewrite 2026-08-11 | High | 30min |
| ~~6~~ | ~~Add cross-references~~ done — §5.5 graph | Medium | 20min |
| ~~7~~ | ~~Flesh out thin skills~~ done — consolidation + deepening waves | Medium | 20min |
| ~~8~~ | ~~allowed-tools~~ done — AGENTS §5.8 | Medium | 15min |
| ~~9~~ | ~~Reference go-ecosystem.md~~ done — absorbed by how-to-golang | Medium | 5min |
| ~~10~~ | ~~CHANGELOG.md~~ done — 2026-08-04 | Low | 10min |
| ~~11~~ | ~~Move how-to-write-skills.md~~ routed — ROADMAP Open Questions | Low | 2min |
| ~~12~~ | ~~Split execution-mode~~ done — brutal-self-review + pareto-planning | Low | 15min |
| ~~13~~ | ~~Add examples~~ done — templates + references | Low | 30min |
| ~~14~~ | ~~Test with non-Go projects~~ w:ROADMAP-shaped — empirical-validation | Low | 15min |
| ~~15~~ | ~~Verify D2 change~~ done — D2 canonical | Medium | 2min |
| ~~16~~ | ~~Add `.gitignore`~~ w:not applicable | Low | 2min |

## g) Top #1 Question I Can NOT Figure Out Myself

**~~Should these skills live in this repo (SKILLS) or be distributed to individual project repos?~~** RESOLVED 2026-08-14 — hybrid runtime-symlink model (AGENTS §5.10).

- If they stay in this repo: they need `skills_paths` config in each project's `crush.json` to be discoverable
- If they move to `~/.config/crush/skills/`: they become globally available to ALL projects (including non-Go ones where Go-specific skills would falsely trigger)
- If they're copied to each project's `.agents/skills/`: they're auto-discovered but duplicated across repos

The right answer depends on how you work — and I genuinely can't determine this without your input.

---

_Report generated by Crush following the `status-report` skill._
