# Roadmap

> Long-term direction and raw ideas. Items here are NOT actionable tasks — they
> lack clear scope, effort estimates, or confirmed value. When an idea is
> refined into bounded work, it moves to `TODO_LIST.md`.

## Themes

### 1. Empirical skill validation

Most skills have never been empirically tested against Crush's actual
triggering mechanism; descriptions are reasoned improvements, not measured
ones. Two exceptions now exist: `go-release` subagent evals (74% with-skill vs
30% baseline, 2026-08-12) and `verify-external-claims` exercised for real
(2026-08-16, four fabricated specifics caught).

Raw ideas:

- Expand the `go-release` eval matrix: version retraction, private-dependency
  release, v2+ migration, multi-module GoReleaser, release-branch hotfix,
  wrong-tag recovery, checksum-mismatch recovery, `-rc.1` handling
- Run the full `skill-creator` evaluation loop (`run_eval.py` / `run_loop.py`,
  variance analysis, blind comparison) once `claude -p` is available in this
  environment — the go-release run approximated it with subagents
- Establish a "graduated from 🆕 to 🟢" criterion: a skill ages into 🟢 only
  after a documented successful run against real work, not just structural
  validation
- Quantify trigger collisions empirically rather than by manual matrix
  inspection
- Spot-check that Crush loads the right skill for representative user prompts
  (top-5 most-used skills first)

### 2. Automated quality gates beyond structural checks

`check-skills.sh` now validates frontmatter, line counts, name-dir match, the
`<--` artifact, TOC integrity, and the docs-health marker-vocabulary contract;
`check-agents-md.sh` scores AGENTS.md quality. Remaining content-level gaps:

Raw ideas:

- A "description quality" scorer that flags documentation-creep (describing
  contents vs stating trigger conditions) beyond the TODO T1 trigger-first
  guard
- A combined `skill-quality-check.sh` gate: frontmatter + links + line counts
  + description heuristics in one command
- Decide enforcement level for `link-skills-to-agents.sh --check` (manual,
  pre-commit hook, or GitHub Action) — blocked on the user decision in Open
  Questions

### 3. Feedback loop maturity

The feedback loop (`docs/feedback/new/` → `processed/`) has converted 22+
feedback files into skill improvements; `new/` is currently empty. The loop is
still manual: an agent must remember to scan `new/`, and there is no automated
detection of recurring patterns (the "appears 2+ times → create a skill" rule).

Raw ideas:

- Automated feedback pattern detection: scan `docs/feedback/` for recurring
  themes and surface candidates for skill creation
- A "feedback-to-skill" checklist that enforces: read feedback → encode into
  skill → archive feedback, with no "report and move on" escape hatch
- Track which feedback rounds produced which skill edits, so future readers
  can trace why a rule exists (the docs-health/references/case-study.md model)

### 4. Inter-skill architecture

The skill graph is documented in AGENTS.md §5.5 but not enforced or
visualized. Several skills form intentional pairs
(`verify-external-claims` ↔ `verify-before-filing`, `go-release` ↔
`go-ecosystem-upgrade`), but the broader dependency and delegation graph is
prose, not a checked artifact.

Raw ideas:

- A dependency graph of skill cross-references, generated and checked by script
- Formalize the "pair skills" pattern: when two skills cover opposite
  directions of the same failure mode, they must name each other and share
  vocabulary
- Detect orphaned cross-references: skill A links to skill B, but B doesn't
  acknowledge the relationship

### 5. how-to-golang snippet discipline

The legacy snippet-accuracy issues (gopter, json/v2, E2E HTTP, Rule 002) were
fixed 2026-08-04. The 2026-08-16 `performance-tuning.md` reference added a new
batch of idiomatic-but-untested snippets, so the debt regrew. Wrong code in a
reference is worse than no code.

Raw ideas:

- A tiny `how-to-golang/scripts/check-snippets.sh` that compiles all fenced Go
  snippets in references (would pay down the AGENTS.md §10 caveat repo-wide)
- A "code snippet accuracy" convention: snippets cite the source they were
  verified against, with a date stamp
- If more machines get GOMAXPROCS-knee measurements, record the numbers
  somewhere durable instead of one anecdotal row (current data is
  machine-specific: 32 CPU, knee ≈ 20)
- Consider whether `how-to-golang` should absorb a `library-guide` (the
  `LIBRARY_GUIDE.md` content covering 13 Lars-authored libraries) or whether
  that deserves its own skill

### 6. go-release content depth

The release lifecycle has sections that exist as failure modes but not as
first-class guidance.

Raw ideas:

- Sections on: release incident response, announcement/communication
  checklist, nightly/snapshot cadence, LTS releases, CVE handling,
  reproducible builds, release health metrics
- HTML eval report via `html-report-kit` + `eval-viewer/generate_review.py`
- A `go-release-check` CI gate wrapping `pre-release-check.sh`

## Open Questions

These are blockers that need a human decision before they can become tasks:

- **How does Crush's skill-selection mechanism actually disambiguate?** When
  two skills match the same prompt, which wins? This determines whether
  trigger collision analysis is a real problem or self-resolving.
- **Should `website-launch` stay at 848 lines or be refactored?** It is
  allowlisted past the 500-line guideline (trimmed 1106 → 799 in 2026-08-04,
  regrew to 848 with the sales-video expansion). Trim path exists (TODO T11);
  it keeps losing to feature work.
- **Backup retention** (`2026-08-14_15-04` g1): trash
  `~/.agents/.backup-skills-20260814/` (25 full skill copies) and the lockfile
  `.bak` now that symlinks are verified, or keep for N days? Deletion is
  irreversible — user's call.
- **Third-party policy long-term** (`2026-08-14_15-04` g2): should the 5
  third-party skills stay upstream-managed forever, or do you want any of them
  eventually vendored/forked into this repo (e.g. if you start customizing
  `skill-creator` or `copywriting`)? Decides whether edits to them are ever
  legitimate.
- **Link-state enforcement level** (`2026-08-14_15-04` g3): is
  `link-skills-to-agents.sh --check` as a manual command enough, or do you
  want a pre-commit hook / minimal GitHub Action that fails on drift?
- **Performance-tuning granularity** (`2026-08-16` g1): stay a reference
  inside `how-to-golang`, or graduate to its own `go-performance-tuning` skill
  owning triggers like "profile my service", "why is p99 high", "GC tuning"?
  Splitting adds a trigger surface; keeping it adds depth.
- **Status-report default format** (`2026-08-16` g2, `2026-08-21` e5): the
  skill's canonical output is a styled HTML dashboard, but recent reports were
  `.md` per explicit user request. One-off overrides, or change the default?
- **skill-creator upstream guidance** (`2026-08-11` g1): the third-party
  `skill-creator` skill still teaches "include both what the skill does AND
  when to trigger" — the upstream source of the description-first
  anti-pattern this repo eliminated. Update it on this machine, leave it, or
  override locally?
- **go-release evals** (`2026-08-12_12-15` g1-g3): keep raw eval artifacts
  containing `rm -rf` as authentic evidence or sanitize them; is the
  subagent-based eval sufficient to call the skill tested; should
  `pre-release-check.sh` be promoted to an installable standalone tool?
- **website-launch video policy** (`2026-08-21` g1-g3): click-to-play vs
  muted autoplay+loop; is the 9:16 social cut Tier 1 (launch-blocking) or
  Tier 2 (same-day); mandatory video for pure-API libraries or stay Optional?

## Non-goals

Things we are deliberately NOT pursuing and why:

- **A build system (Makefile, package.json, go.mod).** This is a content repo —
  the markdown IS the product. Adding compilable code would change the
  project's nature.
- **Tests or CI beyond the guard scripts.** No runnable code exists to test.
  Structural guards (`check-skills.sh`, `sync-html-kit.sh --check`,
  `link-skills-to-agents.sh --check`) are sufficient; content quality is
  enforced by the skills themselves (docs-health). A GitHub Action remains an
  open question above, not a plan.
- **Semantic versioning / git tags.** The repo evolves in session waves, not
  releases. The CHANGELOG uses date-based milestones because there is no
  release process to version against. Faking semver would be dishonest.
- **Renaming skill directories casually.** Crush matches directory name to
  frontmatter `name:` — renames require coordinated updates across all cross-
  references (see the `hierarchical-errors` → `go-error-modernization` rename).
