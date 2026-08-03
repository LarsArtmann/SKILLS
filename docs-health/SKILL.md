---
name: docs-health
description: >
  Creates, verifies, and maintains ALL project documentation — living docs
  (README, FEATURES, TODO_LIST, ROADMAP, CHANGELOG, AGENTS) AND historical
  snapshots (status reports, plans, audits). Four modes: BUILD (create from
  code), HARVEST (pull forward items from status reports into TODO_LIST),
  VERIFY (check claims against code), ANNOTATE (resolve numbered items in old
  reports inline — not appendix-only). Use when the user wants to build a TODO
  list, audit features, check if docs are up-to-date or fresh, create or
  rebuild any project doc, detect documentation drift, split brains, harvest a
  status report, pull next tasks into TODO_LIST, update or annotate old status
  reports, mark old reports as done, bring old audits up to date, or says
  "docs health", "feature audit", "build TODO list", "docs up to date",
  "documentation audit", "fix my docs", "are my docs current", "harvest
  status report", "update old docs", "annotate status reports", "mark these
  reports as done".
metadata:
  tags: documentation, freshness, features, todo, audit, consistency, verification, annotation, historical, harvest
---

# Docs Health

Create, verify, and maintain ALL project documentation — living docs AND historical snapshots. Documentation that lies is worse than missing documentation.

## The documentation model

Each file has ONE job. Each fact lives in exactly ONE place. When the same fact appears in multiple files, they drift.

| File                                              | Owns                                   | Lifecycle   |
| ------------------------------------------------- | -------------------------------------- | ----------- |
| `README.md`                                       | What this is, why, how to start        | Living      |
| `AGENTS.md`                                       | Non-obvious context for AI sessions    | Living      |
| `FEATURES.md`                                     | What features exist + honest status    | Living      |
| `TODO_LIST.md`                                    | Short-term actionable work (open only) | Living      |
| `ROADMAP.md`                                      | Long-term vision, raw ideas            | Living      |
| `CHANGELOG.md`                                    | What changed in each version           | Append-only |
| `docs/DOMAIN_LANGUAGE.md`                         | Domain terms and definitions           | Living      |
| `docs/status/`, `docs/planning/`, `docs/reviews/` | Point-in-time snapshots                | Historical  |

**Living docs** get rewritten in place when they drift. **Historical docs** cannot be rewritten without destroying their value — they get annotated non-destructively (see ANNOTATE). For the full ownership matrix, load [./references/doc-ownership.md](./references/doc-ownership.md).

## Which mode?

| Situation                                                     | Mode     | Does                                   |
| ------------------------------------------------------------- | -------- | -------------------------------------- |
| Doc doesn't exist                                             | BUILD    | Generate from code, cite evidence      |
| Just wrote a status report / TODO_LIST looks thin             | HARVEST  | Pull forward items from recent reports |
| "Are docs current?" / "check freshness"                       | VERIFY   | Check claims against code              |
| "Update old reports" / "mark these done" / "is this current?" | ANNOTATE | Resolve numbered items inline          |
| "Full audit" / "fix my docs" / "docs health"                  | AUDIT    | BUILD + HARVEST + VERIFY               |

If ambiguous, default to AUDIT.

---

## HARVEST — pull forward items from status reports

_The primary mode for most runs._ Status reports capture what a session did AND what should happen next. The "next" part is forward-looking intent. If it lives only in the timestamped report, it is lost — subsequent sessions never read old reports as a backlog source.

1. **Select reports.** Most recent 1–3 in `docs/status/`. Go further back only if sparse. Reading all 100+ historical reports produces duplication, not coverage.
2. **Extract forward-looking items.** "Next tasks" / "Top N", "partially done" with open work, actionable "improvements."
   - **Drop resolved items.** If a report carries `done at` / `Won't implement` markers (from ANNOTATE), those are closed — route to CHANGELOG (if missing), never TODO_LIST. Harvest only items with NO marker.
   - **Questions are not tasks.** Unresolved questions route to the user or ROADMAP "Open questions", never TODO_LIST.
3. **Verify against code.** Many "next tasks" are already done by a later session. Grep before adding — an item already shipped goes to CHANGELOG (if missing) or is dropped.
4. **Route each surviving item:** bounded + short-term → `TODO_LIST.md`; vague / long-term → `ROADMAP.md`; already in TODO_LIST (semantic match) → dedupe, keep the better entry.
5. **Cite the source.** Every item carries evidence: code path (`file:line`) AND report (`docs/status/<file>.md`).
6. **Do NOT rewrite the source report.** HARVEST reads forward; it never edits the historical file.

For anti-patterns and detail, load [./references/harvest-guide.md](./references/harvest-guide.md).

---

## BUILD — create or rebuild a doc from code

Code is the source of truth. Docs are leads, not evidence.

**Per-doc lifecycle (different update actions — not blanket upsert):**

- `FEATURES.md` — **Upsert**: rows evolve status (PLANNED → FULLY_FUNCTIONAL). Update in place.
- `TODO_LIST.md` — **Delete done items.** A completed TODO is removed; it now lives in CHANGELOG. Done items NEVER stay in TODO_LIST. No "Previously Completed" / "Resolved" sections.
- `CHANGELOG.md` — **Append-only.** Never edit prior entries.
- `ROADMAP.md` — **Update in place.** Raw ideas graduate to TODO_LIST when actionable.

**Status vocabulary (FEATURES.md):**

| Status               | When it applies                                              |
| -------------------- | ------------------------------------------------------------ |
| FULLY_FUNCTIONAL     | Code present AND working (tests pass or you exercised it).   |
| PARTIALLY_FUNCTIONAL | Ships but has known gaps, edge-case bugs, or missing pieces. |
| BROKEN               | Code exists but does not work / is disabled / fails.         |
| PLANNED              | Documented but no code exists yet.                           |

Never round up. If you cannot confirm a feature works, it is PARTIALLY_FUNCTIONAL at best.

**Rules:** Code wins when doc and code disagree. Cite evidence (`path/to/file:NN`). Verify each claim — many documented TODOs are already done. Detect project type and adapt which docs are needed.

For BUILD procedures, examples, quality checklists, and AGENTS.md scoring, load [./references/build-guide.md](./references/build-guide.md) and [./references/agents-quality-guide.md](./references/agents-quality-guide.md). Templates: [./assets/](./assets/) — one per doc type.

---

## VERIFY — check freshness and consistency

A doc is fresh only when you confirm its concrete claims against code. "Looks fine" is not a check.

1. **Inventory** the docs. Note any missing.
2. **Read each doc, verify against code.** For every concrete claim (count, path, command, status, feature), open the referenced code and confirm.
3. **Classify findings:** Critical (ghosts, wrong commands), Medium-High (structural decay — completed items in TODO_LIST, "Previously Completed" sections), Medium (contradicts code, stale status), Low (cosmetic).
4. **Fix drift in place.** Prefer computing counts from the repo over hardcoding.
5. **Cross-file consistency:** no feature PLANNED in TODO_LIST and FULLY_FUNCTIONAL in FEATURES; no completed item in both TODO_LIST and CHANGELOG; every internal markdown link resolves; TODO_LIST not suspiciously thin vs recent reports.
6. **Run the project's quality gate.** Detect the build system (`nix flake check`, `cargo test`, `npm test`, `scripts/check-skills.sh`) and run the canonical command — do not substitute. If no build system, state that explicitly.

For the full per-doc verification checklist and cross-file table, load [./references/verify-checklist.md](./references/verify-checklist.md).

---

## ANNOTATE — resolve items in historical docs

> ⚠️ **#1 FAILURE MODE: Appendix-only (or prependix-only) annotations.**
> Writing a `## Resolution` section at the end (or a banner at the top) while
> leaving every numbered item in the body unmarked is **a complete failure**.
> The reader scans the list, sees no `done at` markers, and assumes everything
> is still open. **Inline edits are MANDATORY.** Every numbered item must be
> resolved in place: `~~item~~ done at `hash``. The appendix is supplementary
> context ONLY — if you wrote an appendix but zero inline markers, go back.

Old reports go stale. A reader opening one wants to know: _is this done? where is it NOW?_ You cannot rewrite history — annotate non-destructively. **If the user did not specify which files or time range, ask before touching anything.**

### The primary work: resolve every numbered item inline

Old reports contain numbered items (lists `1. 2. 3.` or table rows). **You must resolve every one — not just the ones you know about.** Each item gets a verdict:

```markdown
1. ~~Fix warmup store pollution~~ done at `a7b8159`
2. ~~Fix estimateJSONSize~~ done at `a7b8159`, `fe81dd2`
3. Add negative tests: factory returning nil Bundle ← untouched = still open
```

**Format:** `~~<original line, unchanged>~~ done at <short-git-hashes>`. Variants: `Won't implement — <reason>`, `NOT-DO/DUPLICATE — <reason>`. Leave open items untouched — absence of a marker IS the "open" signal. Strike the ENTIRE original line; cite hashes; never renumber.

**Skipping items you didn't check is the #1 failure mode.** For the full format catalog (variants, table-row patterns, multi-item tables 5+), load [./references/resolving-items.md](./references/resolving-items.md).

### Classify each file before annotating

| Decision    | Apply when                                                |
| ----------- | --------------------------------------------------------- |
| ANNOTATE    | A reader would benefit; value not already present         |
| ARCHIVE     | EVERY item resolved → `git mv` to `<dir>/archived/<file>` |
| SKIP        | Already clear — has its own resolution or correct content |
| LEAVE ALONE | Describes rejected / deferred work where a note misleads  |

### Placement: inline before appendix

Correct stale claims **in place**: `~~Nothing committed.~~ Committed as a7b8159.` If the opening/TL;DR has stale claims, inline-correct them — a reader forms their impression from the opening. An end-of-file `## Resolution (date)` appendix is supplementary context, **never the only annotation. Appendix-only on a file with numbered items = the #1 failure mode.**

For placement examples, scope-asking, HTML edge cases, and undo procedures, load [./references/annotation-placement.md](./references/annotation-placement.md). For the Verschlimmbesserung origin incident, load [./references/case-study.md](./references/case-study.md).

### "So what?" test

Every annotation must cite concrete evidence (commit hash, TODO_LIST ID, decision). If it could apply to ANY file, delete it — unannotated is better than noise. Measure success by value added per annotation, not files touched.

---

## AUDIT — full documentation health check

1. BUILD missing docs.
2. HARVEST recent status reports.
3. VERIFY all docs + cross-file consistency.
4. Report using the health report format — two independent scores (**Accuracy** + **Fitness**), per-doc findings table, visible math. Print **inline** to the conversation; do not write to a file. Load [./references/health-report-format.md](./references/health-report-format.md).

---

## Process

Read before writing. Verify, don't trust. Fix on sight.
