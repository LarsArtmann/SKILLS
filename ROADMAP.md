# Roadmap

> Long-term direction and raw ideas. Items here are NOT actionable tasks — they
> lack clear scope, effort estimates, or confirmed value. When an idea is
> refined into bounded work, it moves to `TODO_LIST.md`.

## Themes

### 1. Empirical skill validation

No skill in this repository has been empirically tested against Crush's actual
triggering mechanism. Every description is a reasoned improvement, not a measured
one. The `skill-creator` skill ships an eval framework (test prompts, baseline
comparison, viewer) that has never been used on any skill here.

Raw ideas:

- Build a behavioral eval harness: 2-3 test prompts per skill, automated grading
  of output quality, regression detection across skill edits
- Run the `skill-creator` description-optimization loop (`run_loop.py`) on the
  thinnest descriptions to measure trigger accuracy
- Establish a "graduated from 🆕 to 🟢" criterion: a skill ages into 🟢 only after
  a documented successful run against real work, not just structural validation
- Quantify trigger collisions empirically rather than by manual matrix inspection

### 2. Automated quality gates beyond structural checks

`check-skills.sh` validates structure (frontmatter, line count, name-dir match,
the `<--` artifact guard, cross-skill handoff links). This catches regressions
but not content-level problems: dead anchor links, TOC drift, stale cross-
references, documentation-creep in descriptions, or the marker-vocabulary
contract between `update-old-docs` and `docs-health` HARVEST.

Raw ideas:

- Content-aware linting: TOC integrity, anchor resolution, broken internal links
- A "description quality" scorer that flags documentation-creep (describing
  contents vs stating trigger conditions)
- AGENTS.md quality scoring as a standalone script (`check-agents-md.sh`) —
  package the temporal-pollution grep patterns from `agents-quality-guide.md`
- CI integration: run all guards on every push, fail on drift

### 3. Feedback loop maturity

The feedback loop (`docs/feedback/new/` → `processed/`) has converted 22+
feedback files into skill improvements. But the loop is still manual: an agent
must remember to scan `new/` before starting work, and there is no automated
detection of recurring patterns (the "appears 2+ times → create a skill" rule).

Raw ideas:

- Automated feedback pattern detection: scan `docs/feedback/` for recurring
  themes and surface candidates for skill creation
- A "feedback-to-skill" checklist that enforces: read feedback → encode into
  skill → archive feedback, with no "report and move on" escape hatch
- Track which feedback rounds produced which skill edits, so future readers can
  trace why a rule exists (the `update-old-docs` case-study.md model)

### 4. Inter-skill architecture

The skill graph is documented in AGENTS.md §5.5 but not enforced or visualized.
Several skills form intentional pairs (`update-old-docs` ↔ `docs-health`,
`verify-external-claims` ↔ `verify-before-filing`), but the broader dependency
and delegation graph is prose, not a checked artifact.

Raw ideas:

- A dependency graph of skill cross-references, generated and checked by script
- Formalize the "pair skills" pattern: when two skills cover opposite directions
  of the same failure mode, they must name each other and share vocabulary
- Detect orphaned cross-references: skill A links to skill B, but B doesn't
  acknowledge the relationship

### 5. how-to-golang accuracy and depth

The `how-to-golang` skill is the flagship reference-heavy skill (94-line
entrypoint + 9 reference files), but it has known code-accuracy issues flagged
since the 2026-05-03 audit and never resolved. Wrong code in a reference is
worse than no code — it teaches the wrong pattern.

Raw ideas:

- Systematic validation pass: every code snippet in every reference file
  checked against the actual library API (gopter, encoding/json/v2, E2E HTTP)
- A "code snippet accuracy" convention: snippets cite the source they were
  verified against, with a date stamp
- Consider whether `how-to-golang` should absorb a `library-guide` (the
  `LIBRARY_GUIDE.md` content covering 13 Lars-authored libraries) or whether
  that deserves its own skill

## Open Questions

These are blockers that need a human decision before they can become tasks:

- **How does Crush's skill-selection mechanism actually disambiguate?** When two
  skills match the same prompt, which wins? This determines whether trigger
  collision analysis (TODO T1) is a real problem or self-resolving.
- **Should `website-launch` stay at 1106 lines or be refactored?** It is
  allowlisted past the 500-line guideline. Refactoring is safe but low-impact
  unless the skill is actively painful to maintain.
- **Is the 500-line limit right for feedback-sink skills?** `update-old-docs`
  (477 lines) and `docs-health` (500 lines) both absorb the most feedback and
  are both at capacity. Either raise the limit for these or enforce the
  references-only-examples discipline harder.

## Non-goals

Things we are deliberately NOT pursuing and why:

- **A build system (Makefile, package.json, go.mod).** This is a content repo —
  the markdown IS the product. Adding compilable code would change the project's
  nature.
- **Tests or CI beyond `check-skills.sh`.** No runnable code exists to test. The
  structural guard is sufficient; content quality is enforced by the skills
  themselves (docs-health, update-old-docs).
- **Semantic versioning / git tags.** The repo evolves in session waves, not
  releases. The CHANGELOG uses date-based milestones because there is no release
  process to version against. Faking semver would be dishonest.
- **Renaming skill directories casually.** Crush matches directory name to
  frontmatter `name:` — renames require coordinated updates across all cross-
  references (see the `hierarchical-errors` → `go-error-modernization` rename).
