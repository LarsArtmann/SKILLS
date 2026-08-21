# Changelog

All notable changes to this project are documented in this file.

This is a **content repository** (no compiled code, no semantic versioning, no git
tags). Instead of fabricated version numbers, changes are grouped by **milestone
waves** — each wave corresponds to a real session or sustained push, dated from
the commits it spans. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
adapted for a versionless content repo. Run `git log --oneline` for the full,
authoritative commit history.

Skill counts cited below are verifiable with `scripts/check-skills.sh`.

## [Unreleased]

### Added (2026-08-21 — TODO wave T1–T20 fully executed)

- `scripts/check-skill-links.sh`: CI-grade broken-internal-link detector for
  ALL skill markdown (file links, in-file anchors, GitHub-style slug rules,
  inline-code and HTML-anchor aware); wired into `check-skills.sh` as check 12
  and fixed the one genuine broken anchor it found (performance-tuning TOC)
- Trigger-first regression guard in `scripts/check-skills.sh` (check 6):
  hard-fails 3rd-person-verb and trigger-less description openings, warns
  non-canonical ones — negative-tested in three modes
- `how-to-golang/SKILL.md`: "Choosing alias vs definition" decision tree +
  trigger phrases ("type alias", "type definition", "type X = Y")
- `how-to-golang/references/domain-types.md`: five compiler-verified
  alias-vs-definition nuances (method loss vs structural interface
  satisfaction, operator preservation, untyped-constant asymmetry, reflect
  divergence, embedding-vs-aliasing-vs-definition table) — 16 positive
  assertions + 4 negative compile cases run against go1.26.5
- `performance-tuning.md`: REAL worked examples, run not invented — the
  `-cpu` sweep (knee at 16 on a 32-thread Ryzen, reverses at 32) and the
  false-sharing before/after with `benchstat` verdict
  `-80.21% (p=0.002 n=6)`
- `go-release/evals/iteration-2/`: evals re-run after the binary-v2.0.0 fix
  with a normalized subagent prompt + new safety assertion (no `rm -rf`);
  with-skill 21/22 (95%, up from 79%), the miss and the safety fix both stuck
- `website-launch/evals/iteration-1/`: old-skill-vs-new-skill eval of the
  2026-08-21 sales-video rewrite — new 20/20 (100%) vs old 7/20 (35%);
  the rewrite's behavioral changes are measured, not reasoned
- `how-to-write-skills.md`: eval harness shapes (with/without vs
  old-vs-new), "an eval is not done until it is on disk", and a Hard-Won
  Process Lessons section (Questions-tool 200-char limit, verify-before-you-
  write, verification-status tables, trash-for-scratch-dirs)
- `verify-external-claims/SKILL.md`: §0 chat-time gate — applies at the
  moment any sentence about external tool behavior is written, not only at
  skill-creation time
- `scripts/scratch.sh`: scratch-dir helper (create + manifest + `--clean`
  via trash) making the no-`rm -rf` rule the path of least resistance
- `CONTRIBUTING.md`: "Adding a New Skill" flow (authoring guide, html-kit
  vendoring, symlink step via `link-skills-to-agents.sh`, inventory, checks)

### Changed (2026-08-21 — TODO wave T1–T20 fully executed)

- `how-to-golang/references/`: all 31 Go blocks compile-checked in a scratch
  module; six real bugs fixed — branded-ID imports moved to
  `go-branded-id` + `sixafter/nanoid` (old subpackages no longer exist),
  fabricated uniflow pipeline API removed (module is
  `github.com/LarsArtmann/uniflow`, uncompilable at @latest), koanf env via
  `providers/env/v2`, go-snaps `/snaps` package path, `GinkgoT()` in
  snapshot specs, `db.ExecContext`; `required-libraries.md`, `banned-
  libraries.md`, `rules.md`, and AGENTS.md §10 aligned
- `website-launch/SKILL.md` 848 → 799 lines: Phase 6 link-bar split brain
  fixed (points at canonical readme-template bar) and Phase 2 badge/link-bar
  markup extracted into `readme-template.md` (which gains the applications
  badge variant + `{LICENSE}` placeholder)
- `website-launch/references/demo-video.md`: HyperFrames claims corrected
  against the actual skill bodies — routing quote verified, `npx`-wrapper
  failure scoped to `render`, 9:16 re-render reframed as a resized
  composition (root hardcodes `data-width`/`data-height`)
- `website-launch/references/content-patterns.md`: demo-video item added to
  the retrofit checklist (eight patterns) + launch-post copy mini-template
- `website-launch/references/file-manifest.md`: og:image 1200×630 rule +
  poster-as-og:image override for the landing page
- `go-release/references/`: `trash` item in quick-reference checklist;
  `GONOSUMDB='*'` made explicit in multi-module Step 9 (semantics verified
  against `go help environment`)
- `scripts/link-skills-to-agents.sh`: `AGENTS_DIR` override documented in
  header + `--help` sed range fixed; `--force` recovery path proven
  end-to-end on a scratch skill (real dir preserved as
  `.replaced-<timestamp>`, data never deleted)
- AGENTS.md §5.10: skills-CLI facts corrected empirically — lockfile is 14
  entries (not 5), `skills ls -g` lists ALL skills with per-skill sources,
  `skills update -g` leaves the 25 own-skill symlinks untouched
- httputil (external): `DOMAIN_LANGUAGE.md` Middleware row now shows the
  actual alias declaration (with `=`) instead of the pre-fix definition
- `bdd-testing/SKILL.md`: one-way "Benchmarks are not specs" cross-link to
  `performance-tuning.md` methodology
- `TODO_LIST.md` rebuilt: T1–T20 all done and removed; six remaining
  verified-open items (T21–T26) with evidence

### Added (2026-08-21 — docs-health full audit, this session)

- `TODO_LIST.md` rebuilt via HARVEST: 19 verified-open items (T1-T19) from the
  2026-08-11 → 2026-08-21 status reports; every item carries code + report
  evidence
- `CHANGELOG.md` waves for 2026-08-11 → 2026-08-21 (this entry and those below
  — six sessions of work previously undocumented here)
- `ROADMAP.md` refreshed: resolved raw ideas pruned (TOC guard, check-agents-md,
  legacy snippet fixes), new themes (snippet discipline, go-release depth),
  10 open questions routed from reports' g-sections
- Archive verdict: **no 2026-08-1x report qualified** — every one retains
  verified-open items (all now tracked in `TODO_LIST.md`/`ROADMAP.md`), so none
  was moved to an `archived/` directory

### Changed (2026-08-21 — docs-health full audit, this session)

- `FEATURES.md` rebuilt: `go-release` row added (was missing entirely),
  line counts re-verified, `verify-external-claims` 🆕 → 🟢 (proven 2026-08-16),
  `website-launch` 1106 → 848, `how-to-golang` 10 references, stale "no
  assessment rubric" note fixed
- `README.md`: counts corrected to 21-of-25 solid/functional (bdd-testing
  aligned to 🟡, verify-external-claims to 🟢), website-launch row mentions the
  demo-video sales engine
- `AGENTS.md` drift fixed: §5.5 cross-reference graph now records the
  `go-release` ↔ `go-ecosystem-upgrade` and `website-launch` ↔
  `hyperframes-creative` pairs; §5.10 gains the canonical-path rule (hit twice
  by sessions) and the three one-off crush-skills exceptions; §6 count 9 → 10
  references; §10 gains goreleaser/gh and the six verified performance tools;
  stale "known accuracy issues" note corrected (fixed 2026-08-04)
- `how-to-write-skills.md` Pattern 11 template fixed:
  `[what it does + trigger phrases]` → `[trigger phrases + what the agent will
  do]` (leftover from pre-2026-08-11 style, flagged in the 08-11 report)
- All nine 2026-08-1x status reports annotated inline (every numbered item
  resolved with `done at` / `Won't implement` / verified-open verdicts)

### Added (2026-08-11 — trigger-first description migration) — `b0e96c7`

- All 18 description-first skills rewritten to open with trigger context
  ("Use when…"); 6 already-trigger-first skills verified unchanged; 24/24
  confirmed to start with "Use " and stay under 1024 chars
- `AGENTS.md` §3.1 and `how-to-write-skills.md` §1 rewritten to teach
  description-as-trigger (when to activate, not what the skill is)

### Added (2026-08-12 — go-release skill, four-session arc) — `f8baf43`–`66ff020`

- `go-release` skill (skill count 24 → 25): 10-phase release workflow for
  single-module, multi-module, and binary releases; 5 references (multi-module,
  major-versions, goreleaser-and-ci, failure-modes R1-R17, quick-reference)
- `scripts/pre-release-check.sh` — automates replace/pseudo-version/dirty-tree
  gates plus tidy/verify/build/test/vet
- `evals/` with 3 graded prompts: with-skill 74% vs baseline 30%
- Every external claim verified against primary sources (GoReleaser v2.17.1
  source, `go help mod edit`, sigstore/SLSA docs); two fabricated details
  corrected before encoding
- Safety: 5 `rm -rf` occurrences replaced with `trash`; `+incompatible`
  draft-think paragraph rewritten; release-shape decision tree + ToC +
  `allowed-tools: goreleaser gh` added
- `go-ecosystem-upgrade` Phase 6 thinned to 2 ecosystem-specific rules + a
  pointer to `go-release` (split-brain cleanup)

### Added (2026-08-14 — alias guidance, corpus sync, symlink model) — `2108cd1`–`6efb022`

- `how-to-golang/references/domain-types.md` — type-alias vs type-definition
  section with the real httputil middleware case
- Full corpus comparison repo ↔ `~/.agents`: 7 broken asset links fixed,
  `html-report-kit` description sharpened to trigger-first, all frontmatter
  validated
- **Runtime symlink model**: `scripts/link-skills-to-agents.sh` (idempotent
  repair / `--check` / `--list` / `--force`) replaces the rsync copy script;
  own skills symlinked (no sync step, no drift possible), lockfile split to
  5 third-party entries; documented in `AGENTS.md` §5.10

### Added (2026-08-16 — performance-tuning reference) — `60c799c`

- `how-to-golang/references/performance-tuning.md` (263 lines, 13 sections):
  concurrency decision tree, profiling methodology, GOMAXPROCS knee
  measurement, container GOMAXPROCS (Go 1.25+), GC knobs, cache-aware
  modeling, NUMA facts — 24/24 claims verified against primary sources, 4
  fabrications caught before encoding
- `go-release`: green-CI-before-tagging rule — `8482246`

### Added (2026-08-18 — annotation tooling, demo-video standard) — `560ddb3`, `c08b917`

- `docs-health` batch annotation tooling: `annotate-rows.py` + `annotate-prose.py`
  (section-scoped, atomic, refuse already-annotated lines, `--dry-run`) and
  health-report math-discipline rules
- `website-launch`: HyperFrames demo video made standard for every launch

### Changed (2026-08-21 — website-launch sales engine) — `817ed58`

- Demo video repositioned from showcase asset to the launch's sales engine:
  §3.11 rewritten (hook/value/CTA beats), Phase 2 one-narrative rule,
  maintenance-mode video audit, `references/demo-video.md` rewritten 153 → 249
  lines, definition-of-done demo items 4 → 9, README-template demo-link variant

### Added (2026-08-04 full TODO_LIST execution)

- `scripts/check-agents-md.sh` — standalone AGENTS.md quality scorer packaging
  the temporal-pollution and content-misplacement grep patterns from
  agents-quality-guide.md (5-tier anti-pattern catalog, size budget, structural
  decay checks)
- `architecture-review/references/assessment-rubric.md` — 7-dimension rubric
  (Coupling, Cohesion, Modularity, Composability, Scalability, Service
  Orientation, Dependency Direction) with 1-5 scoring and evidence checkpoints
- `architecture-review/references/review-methodology.md` — step-by-step
  methodology: structural mapping, dependency analysis, domain alignment check,
  pain point identification, recommendation framework with priority levels
- `code-quality-scan/references/tool-guidance.md` — per-language tool matrix
  (Go, TS/JS, Rust, Python, Nix) with specific lint/duplication commands
- `status-report/references/section-quality-guide.md` — per-section quality
  guide for all 7 status report sections with common pitfalls
- `website-launch/references/go-live-runbook.md` — extracted 10-step deployment
  sequence from SKILL.md body (lock files → Firebase deploy → custom domain →
  DNS → SSL → verification)
- `website-launch/references/website-creation-details.md` — extracted favicon/logo
  design, MDX escaping, section components, creation order, Starlight config
- `website-launch/references/definition-of-done.md` — extracted complete launch
  checklist (build, README, GitHub, DNS, files)
- `docs-health/references/case-study.md` Incident 2 — the appendix-only trap
  (2026-08-03): 7 status reports annotated with appendix-only `## Resolution`
  sections and ZERO inline `done at` markers. Added as a second case study with
  root cause analysis and fix description
- Two new patterns in `how-to-write-skills.md`:
  - Pattern 10: "Condense Without Eroding Teaching Weight" — move examples to
    references FIRST, then trim prose. Prevents the condensing-erodes-teaching
    cycle
  - Pattern 11: "Disambiguate Competing Skills in the Description" — add
    "Distinct from X" clause when skills have overlapping trigger phrases
- Scoring system reconciliation cross-references between
  `agents-quality-guide.md` (5-dimension per-file rubric) and
  `health-report-format.md` (2-score per-set Accuracy+Fitness)
- `TODO_LIST.md`, `FEATURES.md`, `ROADMAP.md` — the three missing living docs from
  the docs-health documentation model, built from code and harvested status reports
- Living-docs consistency: `CONTRIBUTING.md` corrected (was pointing at Go test
  commands for a content repo with no code)

### Changed (2026-08-04 full TODO_LIST execution)

- **Trigger collision analysis completed** — systematic analysis of all 24
  skill descriptions: zero real collisions found. All high-overlap pairs (4+
  shared keywords) disambiguated with "Distinct from" text in descriptions
  (code-quality-scan ↔ full-code-review ↔ deduplicate-code, architecture-review
  ↔ full-code-review, status-report ↔ docs-health, verify-external-claims ↔
  verify-before-filing)
- **how-to-golang code snippets fixed** — all 4 known accuracy issues corrected:
  gopter API (NewGopter→NewProperties + prop.ForAll + generators), encoding/json/v2
  (Go 1.26+→1.25+ experimental GOEXPERIMENT=jsonv2), E2E HTTP API (fabricated
  client→real net/http), Rule 002 CI command (nonsensical pipe→working go list)
- **how-to-golang status upgraded** — 🟡 PARTIALLY_FUNCTIONAL → 🟢 FULLY_FUNCTIONAL
  after all code-accuracy issues fixed. README and FEATURES aligned.
- **website-launch refactored** — 1106→799 lines (28% reduction) by extracting
  Phase 3 details, Phase 5 go-live runbook, and Definition of Done to references
- **8 TOC drifts fixed** — nix-review/best-practices, naming-review/common-naming-problems,
  docs-health/verify-checklist, docs-health/case-study, go-error-modernization
  (3 files) all had missing TOC entries for existing ## headings
- **TOC-integrity guard added** to `check-skills.sh` — counts ## headings vs TOC
  entries for any .md with a Contents section, fails on mismatch
- **Marker-vocabulary guard added** to `check-skills.sh` — verifies docs-health
  ANNOTATE/HARVEST share the resolution-marker vocabulary (done at, Won't
  implement, NOT-DO)
- `code-quality-scan` deepened — removed "RESEARCH the best golang code
  duplication finder" instruction, replaced with explicit art-dupl guidance,
  removed deprecated justfile reference
- `architecture-review` deepened — process steps now reference specific
  methodology phases instead of generic "analyze and assess"
- `bdd-testing` deepened — added file naming conventions table
- `status-report` deepened — added pointer to section quality guide
- `docs-health/references/case-study.md` stale reference fixed — "This is why
  ../SKILL.md says: undo batch edits with git restore" guidance was cut in
  nuclear merge; now owned by the case study itself
- **2026-05-03 comprehensive audit annotated** — all 25 Top-Tasks resolved
  inline with `done at`/`Won't implement`/`NOT-DO` markers

### Changed (earlier this session)

- **Merged `update-old-docs` into `docs-health`** — eliminated the cross-reference
  maintenance burden and 3× boundary restatement. docs-health now has four modes:
  BUILD, HARVEST, VERIFY, ANNOTATE (formerly update-old-docs). Body went from
  500→166 lines (67% cut) via the "nuclear" approach: each rule stated once, all
  warnings/edge cases/anti-patterns pushed to references. Skill count: 25→24.
  Moved 3 reference files (resolving-items, annotation-placement, case-study) into
  `docs-health/references/`. Created `harvest-guide.md`. Updated all cross-refs in
  status-report, common-mistakes, doc-ownership, how-to-write-skills, README,
  AGENTS, FEATURES, TODO_LIST, ROADMAP.

## 2026-08-04 — update-old-docs structural refactor & AGENTS.md quality analysis

**Commits:** `b01bbbc`–`c3e6371` · **Skills:** 25

### Added

- `update-old-docs/references/resolving-items.md` (146 lines) — consolidated
  numbered-item resolution pattern catalog (format grammar, variant catalog,
  multi-item table format, table-row patterns)
- Pattern 9 ("Surface the Primary Failure Mode in the tl;dr") in
  `how-to-write-skills.md`, with the appendix-only incident as the worked example
- `docs-health/references/agents-quality-guide.md` (365 lines) — 5-tier
  anti-pattern catalog, endurance test, size budget, 7-step pruning guide
- Expanded AGENTS.md quality checks across docs-health: `verify-checklist.md`
  (6→14 AGENTS.md checks), `common-mistakes.md` (4→15 entries), `build-guide.md`,
  `AGENTS-template.md`

### Changed

- `update-old-docs/SKILL.md`: 544→477 lines — moved worked examples to references,
  restored teaching weight (doctor analogy, "58 identical banners" origin anchor,
  non-negotiable Step 1), added per-item checkpoint, high-volume batch guidance,
  appendix-only anti-pattern
- `docs-health/SKILL.md`: surfaced "HARVEST-skipping is the #1 cause of TODO_LIST
  staleness" in the intro; added AGENTS.md quality section under BUILD rules
- `go-ecosystem-upgrade/SKILL.md`: surfaced "build-only verification is the #1
  failure" in the intro

### Fixed

- Appendix-only trap: every file with numbered items now requires ≥1 inline
  resolution marker (new verification gate)
- `annotation-placement.md` TOC drift after section restructuring

## 2026-08-02 — Name/description overhaul, erraudit rename, verification pair

**Commits:** `dd4f718`–`536bcc7` · **Skills:** 24→25

### Added

- `verify-before-filing` skill — outbound epistemic hygiene (verify your own
  diagnosis before filing issues/PRs to external projects). Pairs with
  `verify-external-claims` (inbound) to form a two-direction verification pair

### Changed

- Renamed `hierarchical-errors` → `go-error-modernization` (directory + name) —
  the old name described a possibly-private CLI; the new name describes the domain
- Rewrote 9 weak trigger descriptions: bdd-testing (+357 chars), code-quality-scan
  (+262), deduplicate-code (+291), status-report (+230), architecture-review
  (+195), pareto-planning (+102), full-code-review (+61), go-ecosystem-upgrade
  (stripped provenance), html-report-kit (stripped non-rendering links)
- Renamed CLI `hierarchical-errors` → `erraudit` across all go-error-modernization
  files; updated `--type-aware` from broken→recommended; added multi-module
  `find . -name go.mod` pattern

### Fixed

- Fabricated `--enforce-go-error-family` documentation removed after research
  (commit `992917a`) — the flag exists in zero public codebases
- Historical practical example restored after sed-replace corrupted it

## 2026-07-30 — update-old-docs overhaul, nix-flake-migration consolidation

**Commits:** `3afad17`–`1f581f0` · **Skills:** 23→24

### Added

- `update-old-docs` skill (renamed from `no-harm-edits`) — keeps old/historical
  documents current via non-destructive annotation

### Changed

- Consolidated `nix-flake-migration` into `html-report-kit` ecosystem
- Cross-referenced docs-health HARVEST ↔ update-old-docs marker vocabulary
  (AGENTS.md §5.5 contract: `done at`, `Won't implement`, `NOT-DO/DUPLICATE`)

## 2026-07-27 — go-ecosystem-upgrade skill

**Commits:** `98d5ffb`–`4f6c964` · **Skills:** 22→23

### Added

- `go-ecosystem-upgrade` skill — protocol for bumping/releasing/migrating Go
  library versions across many consumers, with 18 failure modes extracted from
  real self-reviews

## 2026-07-23 to 2026-07-26 — Feedback closure, HARVEST, status-report, three new skills

**Commits:** `9df82cc`–`0e0a2bd` · **Skills:** 19→22

### Added

- `samber-do-best-practices` skill — correct samber/do v2 DI usage (DO-1→DO-6
  anti-patterns, lifecycle, scopes)
- `nix-private-go-repos` skill — build Go projects with private GitHub deps in
  Nix (`mkPreparedSource` + `GOPRIVATE`)
- `verify-external-claims` skill — inbound epistemic hygiene (verify external
  tool/library claims before encoding them into skills/code/docs)
- `status-report` skill — full project status updates as styled HTML dashboards
- HARVEST mode in docs-health — pulls forward-looking items from recent status
  reports into TODO_LIST/ROADMAP (the #1 fix for TODO_LIST staleness)
- docs-health `health-report-format.md` — independent Accuracy + Fitness scores

### Changed

- docs-health VERIFY now checks job-fitness (structural decay), not just factual
  accuracy — catches "living doc disguised as trophy case"
- Bulk refresh of html-report-kit across all consumer skills
- Processed 7+ feedback files (website creation sessions) into skill improvements

## 2026-07-21 — go-error-modernization (as hierarchical-errors)

**Commits:** `830574c`–`e8b20bb` · **Skills:** 18→19

### Added

- `hierarchical-errors` skill (later renamed `go-error-modernization`) — prevents
  cargo-cult `errors.As`/`errors.Is` regressions on Go 1.26+

## 2026-07-17 to 2026-07-20 — update-old-docs origin, docs-health hardening, website-launch content

**Commits:** `1635f3c`–`f192d4e` · **Skills:** 16→18

### Added

- `no-harm-edits` skill (later renamed `update-old-docs`) — safeguards for
  non-destructive bulk edits, born from the banner Verschlimmbesserung incident
- docs-health Health Score (later split into Accuracy + Fitness)
- website-launch content-patterns, design-inspiration references, Starlight knobs

### Fixed

- docs-health + update-old-docs hardened against fabricated-score and
  buried-annotation failure modes

## 2026-07-11 to 2026-07-14 — docs-health skill, website-launch skill, feedback loop

**Commits:** `abe2b1d`–`fd14050` · **Skills:** 14→16

### Added

- `docs-health` skill — consolidated `docs-freshness-check`, `features-audit`, and
  `todo-list-builder` into one skill covering all core project documentation
- `website-launch` skill — Astro + Starlight + Firebase documentation site launcher
- Feedback loop established (`docs/feedback/new/` → `processed/`) with 7 initial
  feedback files from website creation sessions

## 2026-06-28 — go-modularize overhaul, deduplicate-code streamline

**Commits:** `2d77b16`–`dcc0fc8` · **Skills:** 13

### Changed

- `go-modularize` grounded in real-world patterns from 3 production projects;
  added direction-neutral guidance and under-modularization failure mode
- `deduplicate-code` synced to art-dupl statement-level tokenization
- `check-skills.sh` — added description length validation (1024 char limit)

## 2026-06-17 to 2026-06-18 — MD→HTML conversion, html-report-kit, Bauhaus migration

**Commits:** `39df82cc`–`abe2b1d` · **Skills:** 11→13

### Added

- `html-report-kit` — shared HTML report design system with dark-dashboard and
  editorial-light templates (vendored into each consumer for per-skill install)
- `library-deep-dive` skill — audits whether a project uses a library to its full
  potential
- `allowed-tools: d2` frontmatter on graph-producing skills
- Artifact decision rule in `how-to-write-skills.md` (Snapshot+Report→HTML,
  Living+ToolParsed→Markdown)

### Changed

- 8 skills converted from Markdown to styled HTML output (status-report,
  full-code-review, pareto-planning, go-modularize, naming-review, code-quality-scan,
  nix-flake-migration, data-model-review)
- `full-code-review` delegated planning to `pareto-planning` (removed inlined Pareto)
- Both templates rewritten in Bauhaus design language (primary colors on neutral
  ground); re-vendored to all consumers

## 2026-06-03 to 2026-06-07 — data-model-review, README rewrite, legacy cleanup

**Commits:** `bbf3d2a`–`98d5ffb` · **Skills:** 10→11

### Added

- `data-model-review` skill (rewritten as Go-native data model review)
- README.md rewritten with honest quality indicators and domain categories

### Changed

- Legacy prompt snippets relocated to `originals/` subdirectory (renamed by target
  skill)
- nix skills incorporated Session 3 ecosystem standardization findings

### Removed

- `execution-mode` skill (deprecated — its parallelism guidance contradicted
  brutal-self-review)

## 2026-05-02 to 2026-05-07 — Initial conversion, how-to-golang, nix-review, naming-review, go-modularize

**Commits:** `4a70fa3`–`bbf3d2a` · **Skills:** 0→10

### Added

- Initial project: 17 raw markdown prompt snippets converted into structured skill
  directories with YAML frontmatter
- `how-to-golang` skill — Go development decision guide with 9 reference files
- `nix-review` skill — checklist-driven .nix file quality assurance (50+ problems)
- `naming-review` skill — multi-language naming audit with automated detection
- `go-modularize` skill — Go monorepo modularization with failure modes
- Comprehensive skills audit (`docs/status/2026-05-03_07-51_*`)
- `how-to-write-skills.md` — authoritative skill authoring guide
- README.md with skills inventory and installation guide
- `scripts/check-skills.sh` — structural validation
