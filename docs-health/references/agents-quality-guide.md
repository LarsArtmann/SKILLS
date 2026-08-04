# AGENTS.md Quality Guide

> How to create, maintain, and prune AGENTS.md files that actually help AI
> agents. Built from analyzing 150+ real AGENTS.md files across a diverse
> project ecosystem.
>
> Load this guide when BUILD-ing or VERIFY-ing AGENTS.md. The main SKILL.md
> cross-references it; this file has the detail.

## Table of contents

1. [What AGENTS.md is](#what-agentsmd-is)
2. [What AGENTS.md is NOT](#what-agentsmd-is-not)
3. [Size budget](#size-budget)
4. [The anti-pattern catalog](#the-anti-pattern-catalog)
5. [The endurance test](#the-endurance-test)
6. [Quality scoring rubric](#quality-scoring-rubric)
7. [Pruning a bloated AGENTS.md](#pruning-a-bloated-agentsmd)
8. [Good vs bad examples](#good-vs-bad-examples)

---

## What AGENTS.md is

AGENTS.md is **concise, enduring context** for every AI session working in
this repository. The audience is an AI agent (or a new human contributor)
starting fresh with zero prior context.

The value test: **does this save the next session 10+ minutes of code
exploration?** If not, it does not belong here.

The strongest AGENTS.md files have these sections (adapt names to fit):

| Section               | What it contains                                            |
| --------------------- | ----------------------------------------------------------- |
| What This Is          | One paragraph: project type, purpose, what it is NOT        |
| Commands              | Build, test, lint — exact commands, verified to work        |
| Architecture          | Key design decisions, invariants, data flow — not full docs |
| Conventions           | Naming patterns, code style, error handling, test structure |
| Gotchas               | Non-obvious behaviors, workarounds, platform quirks         |
| Dependencies          | Key libraries and why they were chosen                      |
| High-Value References | Links to the most important docs or files                   |

---

## What AGENTS.md is NOT

Every fact has exactly ONE home. AGENTS.md is NOT:

| Content type                         | Where it belongs                | Why it rots here                                |
| ------------------------------------ | ------------------------------- | ----------------------------------------------- |
| What changed in version X            | CHANGELOG.md                    | Becomes a stale duplicate the moment it ships   |
| Feature status (done/partial/broken) | FEATURES.md                     | Splits the inventory across two files           |
| Next tasks / TODOs                   | TODO_LIST.md                    | Nobody actions them; they accumulate            |
| Domain terms and definitions         | docs/DOMAIN_LANGUAGE.md         | Scattered prose, not greppable                  |
| Getting started / why it exists      | README.md                       | That is end-user marketing, not AI context      |
| Full code examples / API cookbooks   | Source files, godoc, SKILL refs | Duplicates source; massive context cost         |
| Config field tables                  | config structs / example files  | Drifts on every field add/rename                |
| API endpoint catalogs                | Route registration code         | Duplicates the router; rots on every endpoint   |
| Deployment / ops state               | ops docs / runbooks             | Firebase project names, DNS status, deploy URLs |
| Incident post-mortems                | docs/status/ or git history     | Resolved incidents have zero future value       |

---

## Size budget

| Size range | Verdict                                                     |
| ---------- | ----------------------------------------------------------- |
| < 1 KB     | **Skeleton** — too thin to be useful. Needs real content.   |
| 1-5 KB     | **Lean** — ideal for simple projects, libraries, templates. |
| 5-15 KB    | **Sweet spot** — enough room for architecture + gotchas.    |
| 15-30 KB   | **Acceptable** for complex projects, but review for bloat.  |
| 30-50 KB   | **Bloated** — likely contains temporal pollution or code    |
|            | dumps. Needs pruning.                                       |
| 50-100 KB  | **Severely bloated** — major rewrite needed.                |
| > 100 KB   | **Broken** — this is no longer AGENTS.md, it is an archive. |

If your AGENTS.md exceeds 30 KB, you are almost certainly duplicating
content that belongs elsewhere. Run the pruning guide below.

---

## The anti-pattern catalog

Analyzing 150+ real AGENTS.md files revealed five tiers of anti-patterns,
from most to least destructive.

### Tier 1: Content misplacement (information belongs in another file)

The most fundamental failure. AGENTS.md becomes a changelog, TODO list, or
feature tracker — destroying its value as enduring context.

| Anti-pattern           | Example from the wild                                      |
| ---------------------- | ---------------------------------------------------------- |
| Changelog entries      | "go-output was bumped from v0.32.0 to v0.34.0 in bc9d0086" |
| Feature status reports | "All three aggregates are fully implemented with handlers" |
| TODO references        | "actor/ is a 68-file god-package — see TODO #33"           |
| Phase/progress markers | "Phase 5 complete, Phase 7 in progress"                    |
| Completion percentages | "~90% complete. See TODO_LIST.md"                          |
| Resolved incidents     | "### Lint Action Version Mismatch (Fixed)"                 |

**Rule:** If the content answers "what happened?" or "what's the status?",
it does not belong here. AGENTS.md answers "what do I need to know to work
effectively RIGHT NOW?"

### Tier 2: Temporal pollution (content that rots immediately)

The second most common failure. Content is technically on-topic but will
be stale within days.

| Anti-pattern                        | Example from the wild                              |
| ----------------------------------- | -------------------------------------------------- |
| Dated section headings              | `## API Surface (v0.10.0)` or `(added 2026-07-05)` |
| Sprint/session numbers              | "(Sprint 52)", "(session 3)" on gotcha entries     |
| Commit hashes inline                | "Fixed in commit 58ae68d03"                        |
| Coverage percentages                | "97.1% coverage, 0 lint issues, 0 race conditions" |
| File/test counts                    | "67 test files out of 277 Go files"                |
| "As of v..." qualifiers             | "As of v0.31.1, the flake pins are..."             |
| "Was X, now Y" narratives           | "Violations() → Findings() renamed (Sprint 53)"    |
| Ecosystem adoption counts           | "~750 call sites across 50+ projects"              |
| "Previously/currently" descriptions | "previously used testify, now uses stdlib"         |

**Rule:** Remove the date/version/sprint qualifier and state the CURRENT
truth. If there is no current truth (the thing was removed), delete the
entry entirely.

### Tier 3: Implementation duplication (duplicates what's in code)

The most context-wasteful failure. AGENTS.md becomes a second copy of the
source code.

| Anti-pattern                    | Example from the wild                                          |
| ------------------------------- | -------------------------------------------------------------- |
| Code example cookbooks          | 891 lines of commented Go code "explaining every API pattern"  |
| Full config field tables        | 37-row table duplicating a config struct's fields and defaults |
| API endpoint catalogs           | 20-line endpoint list duplicating router registration          |
| Directory trees >3 levels deep  | 95-line tree annotating every file in every subdirectory       |
| Full function inventories       | Enumerating 16 fuzz test function names                        |
| Metric/event name lists         | Full Prometheus metric name inventory                          |
| CSS class / design token tables | Duplicating the CSS variable definitions from source           |

**Rule:** If the content can be regenerated by reading the source, link to
the source instead. An agent can `grep` and `view` code; it does not need
code pre-loaded into the AGENTS.md context window. Maximum 5 lines of
inline code per example; beyond that, link to the file.

### Tier 4: Structural decay (content organization is broken)

The file has the right kind of content but is organized so poorly that no
agent can extract value from it.

| Anti-pattern                      | Example from the wild                                      |
| --------------------------------- | ---------------------------------------------------------- |
| 100+ undifferentiated bullets     | A single `## Conventions` section with 100 flat bullets    |
| 80+ row gotchas tables            | A gotchas table where 40 rows document completed refactors |
| No "What This Is" section         | Jumps straight to details without establishing context     |
| Missing commands section          | An AGENTS.md with no build/test/lint commands              |
| Feature docs disguised as gotchas | "Activity page charts" listed under "Critical Gotchas"     |
| Buried critical info              | Build-breaking constraint on line 200 of a 400-line file   |

**Rule:** Gotchas tables should have at most 15-20 rows. If a section
exceeds 30 bullets, split it into themed subsections. Lead with the most
important information (What This Is, Commands).

### Tier 5: Scope creep (wrong project's content)

Content from another project or concern leaks into this project's file.

| Anti-pattern                        | Example from the wild                                         |
| ----------------------------------- | ------------------------------------------------------------- |
| Website/deploy ops in library repos | Firebase project IDs, DNS status, deploy URLs in a Go library |
| External tool bug reports           | "BuildFlow daemon does X (tool bug)" in a templ library       |
| Cross-project dependency narratives | "go-output went v0.30→v0.31→v0.32 across these projects..."   |
| Duplicate project AGENTS.md         | Two directories with near-identical 150KB files               |

**Rule:** Each AGENTS.md serves ONE repository. If the content is about
another tool or another project, it belongs there, not here.

---

## The endurance test

Before adding any content to AGENTS.md, apply this test:

> **Will this statement still be true 6 months from now, regardless of what
> changes in the codebase?**

| Content                            | Passes? | Why                                        |
| ---------------------------------- | ------- | ------------------------------------------ |
| "Build with `nix build`"           | YES     | Build system doesn't change                |
| "The Broadcaster owns fan-out"     | YES     | Architectural decision, not implementation |
| "Coverage is 97.1%"                | NO      | Changes on every commit                    |
| "Was renamed in Sprint 52"         | NO      | Historical fact, not current truth         |
| "GOEXPERIMENT=jsonv2 is required"  | YES     | Build constraint that persists             |
| "go-output is at v0.34.0"          | NO      | Version changes on every release           |
| "Error handling uses error-family" | YES     | Library choice, stable                     |
| "Fixed in commit abc123"           | NO      | The fix exists; the hash adds nothing      |

**If it fails the endurance test, it does not belong in AGENTS.md.**
Route it to the appropriate file (CHANGELOG for what changed, TODO_LIST for
what's next, docs/status/ for snapshots) or delete it.

---

## Quality scoring rubric

> **Relationship to the AUDIT health report:** The [health-report-format.md](./health-report-format.md)
> scores the ENTIRE doc SET with two independent numbers: **Accuracy** (are claims
> true?) and **Fitness** (do docs serve their jobs?). The rubric below is a
> DRILL-DOWN that scores a SINGLE AGENTS.md file. During an AUDIT, Accuracy+Fitness
> covers the set; when AGENTS.md has issues, this rubric explains the detail behind
> the per-file findings. They do not compete — they operate at different scopes.

When VERIFY-ing AGENTS.md, score on these dimensions:

| Dimension         | Weight | What to check                                               |
| ----------------- | ------ | ----------------------------------------------------------- |
| Content ownership | 30%    | No changelogs, TODOs, feature status, domain terms          |
| Endurance         | 25%    | No dated headings, commit hashes, sprint numbers, "was/now" |
| Leanness          | 20%    | Under size budget; no code dumps, config tables, catalogs   |
| Completeness      | 15%    | Has What-This-Is, Commands, Gotchas (if applicable)         |
| Structure         | 10%    | Scannable sections, no 100+ bullet walls, gotchas ≤20 rows  |

| Grade | Score   | Verdict                                        |
| ----- | ------- | ---------------------------------------------- |
| A     | 90-100% | Excellent — lean, enduring, well-scoped        |
| B     | 75-89%  | Good — minor issues, salvageable               |
| C     | 50-74%  | Needs work — significant anti-patterns         |
| D     | 25-49%  | Bloated — major rewrite needed                 |
| F     | < 25%   | Broken — skeleton or absurdly bloated (>100KB) |

---

## Pruning a bloated AGENTS.md

When AGENTS.md exceeds its size budget or fails the endurance test, prune
it. This is not a rewrite — you are removing rot, not changing the
enduring content.

### Step 1: Inventory temporal pollution

Search for patterns that indicate non-enduring content:

```
grep -nE 'RESOLVED|FIXED 20[0-9]|sprint [0-9]|session [0-9]|was .*, now|previously|renamed from|removed in|deleted in|as of v[0-9]|added 20[0-9]|audited 20[0-9]' AGENTS.md
```

Each match is a candidate for deletion or rewriting to current truth.

### Step 2: Delete resolved incidents

Remove any entry that documents a resolved problem. The resolution exists
in git history. If the lesson is enduring (e.g., "always run X before
committing"), distill it to a one-line rule without the incident narrative.

**Before:** "### Lint Action Version Mismatch (Fixed). In v0.3.1, the CI
failed because golangci-lint action v6 was pinned but the local version
was v5. Resolved by pinning both to v6."

**After:** Delete entirely. Or if the constraint is still relevant: "Pin
golangci-lint action version to match local version."

### Step 3: Strip version qualifiers

Remove "as of v...", "since v...", "(added DATE)", version numbers from
section headings. State the current truth without the temporal anchor.

**Before:** `## API Surface (v0.10.0)` with "Consumer-Feedback APIs (added
2026-07-05)"

**After:** `## API Surface` with "Consumer-Feedback APIs" (no date — if
they exist now, the date is irrelevant)

### Step 4: Remove code dumps

Any inline code block longer than 5 lines is a candidate for removal.
Replace with a pointer to the source file.

**Before:** 30-line Go code block showing the Decider pattern

**After:** "Decider pattern: see `internal/command/decider.go` — every
command handler implements `Handle(cmd) ([]Event, error)`"

### Step 5: Cap gotchas tables

If the gotchas section has more than 20 rows, keep only:

- Build-breaking constraints (without these, the build fails)
- Data-loss risks (without these, data can be corrupted)
- Non-obvious behaviors that violate expectations

Delete rows that document completed refactors, resolved bugs, or
historical context.

### Step 6: Relocate misplacd content

| If you find...          | Move it to...                 |
| ----------------------- | ----------------------------- |
| Feature status / phases | FEATURES.md                   |
| TODO references         | TODO_LIST.md (or delete)      |
| Version history         | CHANGELOG.md                  |
| Domain definitions      | docs/DOMAIN_LANGUAGE.md       |
| Incident post-mortems   | Delete (lives in git history) |
| Deployment / ops state  | ops docs or delete            |

### Step 7: Verify commands still work

After pruning, confirm that the Commands section is intact and every
command still runs. Pruning should never remove verified build/test/lint
commands — those are the highest-value enduring content.

---

## Good vs bad examples

### Good: lean library AGENTS.md (~5 KB, all enduring)

```markdown
# AGENTS.md — go-retry

> Context for AI agents working in this repository.

## What This Is

A Go library providing composable retry policies with exponential
backoff, jitter, and context-aware cancellation. It is NOT a
circuit-breaker library — see go-circuit for that.

## Commands

nix build # build
nix run .#test # test
nix run .#lint # lint

## Architecture

Retry takes a Policy and a Func. Policy controls timing; Func is the
operation. Policies compose: Delay → MaxAttempts → Jitter → ContextAware.

## Dependencies

- go-error-family: classification of retryable vs non-retryable errors

## Gotchas

- GOEXPERIMENT=jsonv2 is required (see flake.nix)
- Retry does not swallow context.Cancellation — callers must handle it
- The default jitter is full (0-100%), not equal (50% ± 25%)
```

### Bad: bloated AGENTS.md (same project, after temporal pollution)

```markdown
# AGENTS.md — go-retry

## Status: ALPHA (as of v0.3.2, 2026-07-28)

Coverage: 97.1%. 0 lint issues. 23 tests pass.

## Version History

v0.3.0 shipped go 1.26.5 support. v0.3.1 reverted due to json/v2
mismatch (fixed in commit abc123). v0.3.2 re-bumped.

## API Surface (v0.3.2)

[30 lines of Go code showing every API pattern...]

## Dogfooding Results (Sprint 9)

[14-row table of violation counts per sprint...]

## Gotchas (80+ rows)

[Sprint-dated entries documenting every refactoring decision...]

## TODO

- See TODO #12: Add circuit breaker integration
- See TODO #13: Fix context propagation edge case
```

The bad version is 5x longer and 90% of its content will be stale within
a week. The good version will be accurate for years.
