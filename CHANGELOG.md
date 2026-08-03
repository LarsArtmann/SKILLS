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

### Added

- `TODO_LIST.md`, `FEATURES.md`, `ROADMAP.md` — the three missing living docs from
  the docs-health documentation model, built from code and harvested status reports
- Living-docs consistency: `CONTRIBUTING.md` corrected (was pointing at Go test
  commands for a content repo with no code)

### Changed

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
