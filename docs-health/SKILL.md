---
name: docs-health
description: >
  Creates, verifies, and maintains ALL core project documentation: FEATURES.md,
  TODO_LIST.md, README.md, AGENTS.md, ROADMAP.md, CHANGELOG.md,
  docs/DOMAIN_LANGUAGE.md. Understands which file owns which information and
  enforces consistency between them. Use when the user wants to build a TODO
  list, audit features, check if docs are up-to-date or fresh, create or rebuild
  any project doc, detect documentation drift, split brains, or misplaced
  information, or says "docs health", "feature audit", "build TODO list",
  "docs up to date", "documentation audit", "fix my docs", "are my docs current".
metadata:
  tags: documentation, freshness, features, todo, audit, consistency, verification
---

# Docs Health

Create missing docs, verify freshness against code, and enforce consistency
between files. Documentation that lies is worse than missing documentation: it
actively misleads every reader (human and agent) who trusts it.

## The documentation model

Each file has ONE job. Each fact lives in exactly ONE place. When the same
fact appears in multiple files, they drift, and the reader cannot tell which
is current.

| File                                              | Owns                                             | Lifecycle   |
| ------------------------------------------------- | ------------------------------------------------ | ----------- |
| `README.md`                                       | What this is, why it exists, how to start        | Living      |
| `docs/DOMAIN_LANGUAGE.md`                         | Domain terms and definitions                     | Living      |
| `AGENTS.md`                                       | Non-obvious context for AI sessions              | Living      |
| `FEATURES.md`                                     | What features exist + honest status              | Living      |
| `TODO_LIST.md`                                    | Short-term actionable work                       | Living      |
| `ROADMAP.md`                                      | Long-term vision, raw ideas not yet actionable   | Living      |
| `CHANGELOG.md`                                    | What changed in each version                     | Append-only |
| `docs/adr/`                                       | Architecture decisions (context, decision, why)  | Optional    |
| `docs/status/`, `docs/planning/`, `docs/reviews/` | Point-in-time snapshots (reports, plans, audits) | Historical  |

**Living vs Historical:** Living rows get rewritten in place by docs-health
when they drift. **Historical** rows (`docs/status/`, `docs/planning/`, etc.)
cannot be rewritten without destroying their value as a record — they are
brought current by the [`update-old-docs`](../update-old-docs/SKILL.md) skill
via non-destructive annotation.

For the full ownership rules, anti-patterns, information lifecycle, and a
"where agents store what" matrix, load
[./references/doc-ownership.md](./references/doc-ownership.md).

### Adapt to project type

Not every project needs all docs. Detect the project type and adapt:

| Project type      | Must-have docs                       | Optional docs                       |
| ----------------- | ------------------------------------ | ----------------------------------- |
| Content repo      | README, AGENTS                       | FEATURES (adapted), CHANGELOG       |
| Library / package | README, CHANGELOG, FEATURES          | AGENTS, DOMAIN_LANGUAGE             |
| Web app / service | README, FEATURES, TODO_LIST          | AGENTS, DOMAIN_LANGUAGE, ROADMAP    |
| Monorepo          | README, AGENTS, FEATURES per package | DOMAIN_LANGUAGE per bounded context |

---

## Determine the task

Identify what the user needs from their request:

| User says                                        | Task       | Action                                          |
| ------------------------------------------------ | ---------- | ----------------------------------------------- |
| "Build TODO list" / "create FEATURES.md"         | **BUILD**  | Generate a specific doc from code               |
| "Are docs up to date?" / "check freshness"       | **VERIFY** | Check all docs against code, fix drift in place |
| "Full doc audit" / "fix my docs" / "docs health" | **AUDIT**  | BUILD missing docs, then VERIFY everything      |

If the intent is ambiguous, default to AUDIT (it covers everything).

---

## BUILD: create or rebuild a doc from code

Code is the source of truth. Docs, commit messages, and roadmaps are leads,
not evidence. Open the files and confirm.

For detailed BUILD procedures, examples, and quality checklists for each doc
type, load [./references/build-guide.md](./references/build-guide.md).

### Quick reference: which template to use

| Doc                       | Template (copy into project, fill in)                                        |
| ------------------------- | ---------------------------------------------------------------------------- |
| `README.md`               | [./assets/README-template.md](./assets/README-template.md)                   |
| `AGENTS.md`               | [./assets/AGENTS-template.md](./assets/AGENTS-template.md)                   |
| `FEATURES.md`             | [./assets/FEATURES-template.md](./assets/FEATURES-template.md)               |
| `TODO_LIST.md`            | [./assets/TODO_LIST-template.md](./assets/TODO_LIST-template.md)             |
| `ROADMAP.md`              | [./assets/ROADMAP-template.md](./assets/ROADMAP-template.md)                 |
| `CHANGELOG.md`            | [./assets/CHANGELOG-template.md](./assets/CHANGELOG-template.md)             |
| `docs/DOMAIN_LANGUAGE.md` | [./assets/DOMAIN_LANGUAGE-template.md](./assets/DOMAIN_LANGUAGE-template.md) |

### Status vocabulary for FEATURES.md

| Status               | When it applies                                              |
| -------------------- | ------------------------------------------------------------ |
| FULLY_FUNCTIONAL     | Code present AND working (tests pass or you exercised it).   |
| PARTIALLY_FUNCTIONAL | Ships but has known gaps, edge-case bugs, or missing pieces. |
| BROKEN               | Code exists but does not work / is disabled / fails.         |
| PLANNED              | Designed or documented but **no code exists yet**.           |

Never round up. If you cannot confirm a feature works, it is
`PARTIALLY_FUNCTIONAL` at best. Honesty is the entire point of this file.

### BUILD rules

- **Code wins.** When doc and code disagree, fix the doc.
- **Cite evidence** (`path/to/file.go:NN`) so the next reader can verify.
- **Verify each claim.** Many documented TODOs are already done. Grep before
  trusting a doc claim.
- **Per-doc lifecycle, not blanket upsert.** The right update action depends
  on the doc's job. Treating all living docs the same causes TODO_LIST rot:
  done items pile up because "upsert" never deletes, until the file is a
  trophy case rather than a TODO list. Use the per-doc rules:
  - `FEATURES.md`: **Upsert** — rows evolve status (PLANNED →
    FULLY_FUNCTIONAL). Update in place.
  - `TODO_LIST.md`: **Delete done items.** A completed TODO is not "upserted
    to done" — it is removed, because it now lives in CHANGELOG. The only
    exception: an item kept explicitly marked "retained as historical note"
    with a one-line rationale (e.g. a rejected spike with an ADR reference).
  - `CHANGELOG.md`: **Append-only.** Never edit prior entries.
  - `ROADMAP.md`: **Update in place.** Raw ideas graduate to TODO_LIST when
    they become actionable.
- **Never batch without judgment.** When a BUILD touches many files, make a
  per-file decision (update/skip) based on reading each first. Do not script a
  blanket transformation. For old/historical files in particular, defer to the
  [`update-old-docs`](../update-old-docs/SKILL.md) skill — annotate, do not rewrite.

---

## VERIFY: check freshness and consistency

A doc is fresh only when you can confirm its concrete claims against the code.
"Looks fine" is not a freshness check. Open the files it names and verify.

For per-file verification checklists (what to check in each doc type), load
[./references/verify-checklist.md](./references/verify-checklist.md).

### Job fitness before factual accuracy (mandatory first step)

Before checking any concrete claim, state in one line what the doc's job is
and what content does NOT belong there. This forces job-fitness into scope
before factual verification begins. The failure mode it prevents: certifying
a doc as "100% accurate and 100% useless." Example for TODO_LIST:

> "TODO_LIST.md owns short-term actionable work. Completed/rejected/resolved
> items do NOT belong here — they go in CHANGELOG/ADRs. Deferred items belong
> in ROADMAP. I will flag any content outside the job scope before checking
> factual accuracy."

A doc can pass every factual check and still fail its job. The dominant
shape: a living doc (especially `TODO_LIST.md`) that has slowly accumulated
historical cruft across sessions — "Previously Completed" sections duplicating
CHANGELOG, struck-through resolved items, rejected spikes kept "for reference,"
"- DONE" backlog items duplicating ROADMAP. Every fact is true; the doc is
still useless as a TODO list. This is **structural decay**, distinct from
factual drift, and it has its own severity (see the table below). For the
concrete per-doc-type structural checks, load
[./references/verify-checklist.md](./references/verify-checklist.md) and run
the regression scenarios at the bottom of that file.

### Failure modes (ranked by severity)

| Severity    | Failure mode     | Example                                                                  |
| ----------- | ---------------- | ------------------------------------------------------------------------ |
| Critical    | Points at ghosts | References a deleted file, renamed symbol, or dead command               |
| Critical    | Wrong commands   | Build/test/run instructions that fail when executed                      |
| Medium-High | Structural decay | Living doc (esp. TODO_LIST) accumulated completed/resolved/rejected      |
|             |                  | content that belongs in CHANGELOG/ADRs; doc is no longer fit for purpose |
| Medium      | Contradicts code | Doc says X works; code shows X is broken, disabled, or removed           |
| Medium      | Stale status     | Claims an issue is open when it is fixed (or vice versa)                 |
| Medium      | Missing reality  | A shipped feature or new file the doc does not mention                   |
| Low         | Counted wrong    | "18 skills" when there are 19                                            |
| Low         | Cosmetic         | Typos, broken links, stale dates                                         |

### VERIFY process

1. **Inventory the docs.** List the files from the documentation model that
   exist. Note any that are missing but should exist.

2. **Read each doc, then verify against code.** For every concrete claim (a
   count, a file path, a command, a status, a feature), open the referenced
   code and confirm. Treat doc claims as hypotheses to test, not facts.

3. **Classify each finding.** Record: the file, the line, what it says, what
   reality is, the severity, and the fix. This makes the work auditable.

4. **Fix drift in place.** Update the doc to match the code. Prefer computing
   counts and paths from the actual repo over hardcoding numbers: hardcoded
   counts rot the fastest.

5. **Check cross-file consistency** (docs vs docs). The most common rot: a
   shipped feature still listed in `TODO_LIST.md` while `FEATURES.md` says
   `FULLY_FUNCTIONAL`. See the cross-file consistency table in
   [./references/verify-checklist.md](./references/verify-checklist.md).
   Minimum checks (state which you ran and which you skipped — never declare
   "clean" without enumerating what was checked):

   - [ ] Every internal markdown link resolves (`grep -roE '\]\([^)]+\)' *.md docs/` → verify each target exists)
   - [ ] Every test/source count claim is verified by command, not trusted from a doc (e.g. `grep -c '#[test]' src/*.rs`, not "FEATURES.md says 32")
   - [ ] Every file referenced from a doc exists (`examples/*.rs`, `benches/support.rs`, `fuzz/Cargo.toml`, etc.)
   - [ ] Every command in AGENTS.md/CONTRIBUTING.md runs without error (at least `--help` or dry-run)
   - [ ] CHANGELOG version/compare links match the repo URL pattern
   - [ ] No feature is listed as both PLANNED (in TODO_LIST.md) and FULLY_FUNCTIONAL (in FEATURES.md)
   - [ ] No completed item in TODO_LIST is also in CHANGELOG `[Unreleased]` (split brain: which is the source of truth?)
   - [ ] No deferred/backlog item in TODO_LIST duplicates a ROADMAP entry
   - [ ] TODO_LIST has no "Previously Completed" / "Resolved" / "Done" section (belongs in CHANGELOG)

6. **Verify output quality, not just process quality.** After any batch fix,
   re-read each change from a skeptical reader's perspective: "would someone who
   finds this doc benefit from this change?" A change that could apply to any
   file adds no value — delete it. This is the failure mode that
   [`update-old-docs`](../update-old-docs/SKILL.md) exists to prevent.

7. **Run the project's quality gate. Mandatory, not optional.** Detect the
   build system and run the canonical commands:

   - Rust: `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`, `cargo doc`
   - Node: `npm test`, `npm run lint`, `npx tsc --noEmit`
   - Nix: `nix flake check`
   - Python: `pytest`, `ruff check`
   - Other: whatever the project's README/AGENTS.md prescribes

   If the project has no detectable build system, state that explicitly — do
   not skip silently. Doc edits can break builds: a typo in a fenced code
   block, broken rustdoc, malformed YAML frontmatter, a renamed symbol in an
   AGENTS.md snippet. You will not catch these without running the gate.

8. **Verify your own closing claims.** Before declaring done, run `git status`
   and confirm every claim about working-tree state in your closing message.
   "Staged files" requires staged files to exist. "No commit made" requires
   HEAD to be unchanged. "Tests pass" requires tests to have actually run.
   Never describe working-tree state without a fresh `git status` in the same
   message — auto-commit hooks and concurrent sessions change state under you.

### Rebuild vs patch (two independent axes)

Drift comes in two flavors. A doc can need a rebuild on one axis and not the
other. Check both before deciding:

- **Factual drift density** — wrong hashes, ghost files, broken commands,
  stale status. Threshold: **~50%** of concrete claims are wrong → rebuild.
- **Structural decay** — content that belongs in another file (completed
  items in TODO_LIST, "Previously Completed" sections, deferred items
  duplicating ROADMAP). Threshold: **25%** of content is non-job → rebuild.
  A TODO_LIST that is 25% historical content is already failing its job;
  patching it produces a scar pile, not a TODO list.

The "living doc disguised as a trophy case" failure passes the factual axis
with a perfect score and fails the structural axis catastrophically. For the
full decision tree, load
[./references/common-mistakes.md](./references/common-mistakes.md).

### Fix rules

- **Code wins.** When doc and code disagree, fix the doc.
- **Never hardcode counts** that the repo can compute (`wc -l`, `ls`,
  `scripts/check-skills.sh`). Point at a command that recomputes the number.
- **Fix ghosts immediately.** A reference to a deleted file misleads every
  reader. It is a 10-second fix with outsized value.

---

## AUDIT: full documentation health check

### Process

1. **Inventory.** List which docs exist, which are missing. Note any that
   should exist but do not.

2. **BUILD missing docs.** If `FEATURES.md` or `TODO_LIST.md` do not exist,
   build them using BUILD mode before proceeding.

3. **VERIFY all docs.** Run the full VERIFY process on every doc in the
   documentation model.

4. **Check cross-file consistency.** Run every consistency check. The most
   common rot: the same feature listed in both `TODO_LIST.md` (as done) and
   `FEATURES.md` (as planned) because nobody removed it when it shipped. Also
   check the inverse rot — completed items in TODO_LIST duplicating CHANGELOG,
   or deferred items duplicating ROADMAP.

5. **Report.** Present findings using the health report format below.

### Health report format

Print an inline summary table to the conversation (do NOT write to a file):

```
## Documentation Health Report

**Accuracy: 7.75/10** (computed: 10 − 1·1 Critical − 0.5·2 Medium − 0.25·1 Low = 7.75)
**Fitness: 6.5/10** (computed: 10 − 1·1 missing must-have − 0.75·2 structural-decay findings − 1.0·structural ratio [TODO_LIST 75% non-job → 2×(0.75−0.25)] = 6.5)

_Accuracy measures whether claims in existing docs are true. Fitness measures whether the docs serve their jobs. They are independent — a doc can be 100% accurate and 100% useless._

| Doc                  | Exists | Critical | Med-High | Medium | Low |
|----------------------|--------|----------|----------|--------|-----|
| README.md            | Yes    | 0        | 0        | 0      | 1   |
| AGENTS.md            | Yes    | 0        | 0        | 0      | 0   |
| FEATURES.md          | Yes    | 0        | 0        | 2      | 0   |
| TODO_LIST.md         | Yes    | 1        | 2        | 0      | 0   |
| DOMAIN_LANGUAGE.md   | No     | —        | —        | —      | —   |
| ROADMAP.md           | No     | —        | —        | —      | —   |
| CHANGELOG.md         | Yes    | 0        | 0        | 0      | 0   |

### Findings by severity

#### Critical (1) — affects Accuracy
- TODO_LIST.md:15 references deleted file `auth/old.go` (ghost)

#### Medium-High (2) — affects Fitness
- TODO_LIST.md:8 already done (session revocation fixed in commit abc123) — completed item belongs in CHANGELOG, not TODO_LIST
- TODO_LIST.md has "Previously Completed" section (20 lines duplicating CHANGELOG `[Unreleased]`)

#### Medium (2) — affects Accuracy
- FEATURES.md:12 says FULLY_FUNCTIONAL but tests fail for password reset
- FEATURES.md:18 missing OAuth feature that shipped in v1.2

#### Low (1) — affects Accuracy
- README.md:25 typo: "instalation" should be "installation"

#### Missing must-have (1) — affects Fitness
- docs/DOMAIN_LANGUAGE.md does not exist
```

**Two independent scores.** A doc set has two health dimensions that diverge:

- **Accuracy** — are the claims in existing docs true? Verified against code.
- **Fitness** — do the docs serve their jobs? Structural decay, missing
  must-haves, forbidden sections, cross-file duplication.

Report both. They are independent: a doc can be 100% accurate and 100%
useless (the trophy-case failure mode). Combining them into one number hides
which axis failed and what kind of fix is needed (fact-check vs rebuild).

**Accuracy formula:** Start at 10. Subtract:

- 1 point per Critical finding
- 0.5 points per Medium finding
- 0.25 points per Low finding

Floor at 0. Missing must-have docs do not affect Accuracy — a doc that does
not exist makes no claims to verify. They affect Fitness instead.

**Fitness formula:** Start at 10. Subtract:

- 1 point per missing must-have doc
- 0.75 points per Medium-High (structural decay) finding
- **Structural decay ratio penalty:** for any living doc where the fraction
  of non-job content exceeds 25%, subtract `2 × (fraction − 0.25)`. Example:
  a TODO_LIST that is 80% historical cruft: `2 × (0.80 − 0.25)` = 1.1 points,
  even with zero factual errors.

Floor at 0.

**Why two scores, not one.** A single composite score cannot represent the
failure mode this skill exists to catch — a TODO_LIST that is factually
flawless but structurally rotten. Under any composite formula, perfect
Accuracy pulls the number up and hides the Fitness collapse. The split tells
you _which_ kind of fix is needed.

**Show the math for both scores, every time.** Print the computation
alongside each score (see the example above). Never invent either score, and
never invent a prior baseline. If this is the first audit, say "first audit —
no baseline"; do not fabricate a "was Accuracy X / Fitness Y" number.
Invented scores and invented baselines are lies.

### Report rules

- State what was stale and fixed, what was already fresh, and what you could
  not verify (and why).
- Do NOT claim "all docs verified" if you skipped any.
- If you fixed issues during the audit, report both the original finding and
  the fix applied.
- **Never invent a prior state.** If there was no prior audit, say "first
  audit — no baseline." Do not write "was Accuracy X / Fitness Y" without a
  prior report to cite. Do not write "improved from X" without evidence of
  the prior state. Invented baselines are lies.

---

## Keeping old/historical documents current (distinct from living docs)

docs-health maintains **living** docs by rewriting them in place. Keeping
**old/historical** documents current (status reports, plans, audits, snapshots)
is a different problem: they cannot be rewritten without destroying history, so
they must be **annotated** non-destructively. When a task asks to "update all
the old status reports", "mark these reports as done", or "annotate every
status file", defer to the [`update-old-docs`](../update-old-docs/SKILL.md)
skill — it enforces per-file judgment, specificity ("so what?" test), and
non-destructive placement (inline/appendix, never top-of-file banners).

---

## Common mistakes and decision trees

For detailed examples (good vs bad doc entries), decision trees (TODO vs
ROADMAP, AGENTS.md vs DOMAIN_LANGUAGE.md, rebuild vs patch), and common
mistakes per doc type, load
[./references/common-mistakes.md](./references/common-mistakes.md).

---

## Process

READ, UNDERSTAND, RESEARCH, REFLECT. Never trust a doc at face value.

Break the work into actionable steps. Think about them again. Execute and
verify one step at a time. Repeat until done. Keep going until everything
works and you think you did a great job!
