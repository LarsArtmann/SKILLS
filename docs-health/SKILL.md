---
name: docs-health
description: >
  Use when the user wants to build a TODO list, audit features, check if docs are
  up-to-date or fresh, create or rebuild any project doc, detect documentation drift,
  split brains, harvest a status report, pull next tasks into TODO_LIST, update or
  annotate old status reports, mark old reports as done, bring old audits up to date,
  or says "docs health", "feature audit", "build TODO list", "docs up to date",
  "documentation audit", "fix my docs", "are my docs current", "harvest status report",
  "update old docs", "annotate status reports", "mark these reports as done". Creates,
  verifies, and maintains ALL project documentation — living docs (README, FEATURES,
  TODO_LIST, ROADMAP, CHANGELOG, AGENTS) AND historical snapshots (status reports,
  plans, audits). Four modes: BUILD (create from code), HARVEST (pull forward items
  from status reports into TODO_LIST), VERIFY (check claims against code), ANNOTATE
  (resolve numbered items in old reports inline — not appendix-only).
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

**`<dir>/archived/` is closed history — do not open archived files.** A report lands there only when ANNOTATE resolved EVERY item (each line carries `done at` / `Won't implement` / `NOT-DO`); the content is settled and already routed. Reading archived files during HARVEST/VERIFY/AUDIT burns context and tempts you to re-open closed work. Open one only for a concrete need: the user names the file, a provenance question (when/why was this decided?) needs the original wording and the archive manifest plus commit message are insufficient, or a completeness gate flagged it.

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

1. **Select reports.** Most recent 1–3 in `docs/status/`. Go further back only if sparse. Reading all 100+ historical reports produces duplication, not coverage. Never descend into `archived/` subdirectories — those reports are fully resolved and hold zero open items (see "The documentation model").
2. **Extract forward-looking items.** "Next tasks" / "Top N", "partially done" with open work, actionable "improvements."
   - **Drop resolved items.** If a report carries `done at` / `Won't implement` markers (from ANNOTATE), those are closed — route to CHANGELOG (if missing), never TODO_LIST. Harvest only items with NO marker.
   - **Questions are not tasks.** Unresolved questions route to the user or ROADMAP "Open questions", never TODO_LIST.
3. **Verify against code.** Many "next tasks" are already done by a later session. Grep before adding — an item already shipped goes to CHANGELOG (if missing) or is dropped.
   - **Park-landed pre-check (added 2026-10-12).** Before re-rowing any harvested PARK (a report's parked batch of items), grep `CHANGELOG.md` + `AGENTS.md` for the park's key nouns: a done disposition in either closes the item inline (→ DONE with the evidence cited) instead of minting a fresh dispatch. Inline `done at` markers cannot catch this class — the disposition was recorded in the CHANGELOG, not the source report (origin: the 2026-10-10 tq-micros re-row, a paid no-op re-dispatch of work a same-week CHANGELOG entry already closed).
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

**Status vocabulary (FEATURES.md):** every label answers ONE question — _does working code exist, and if not, why not?_

| Status               | When it applies                                                                                                                                                                                                                                    |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FULLY_FUNCTIONAL     | Code present AND working (tests pass or you exercised it).                                                                                                                                                                                         |
| PARTIALLY_FUNCTIONAL | Ships but has known gaps, edge-case bugs, or missing pieces.                                                                                                                                                                                       |
| BROKEN               | Code exists but fails. Keep BROKEN nameable — "zero BROKEN rows" is itself information about the project's health.                                                                                                                                 |
| DISABLED             | Code exists and is correct, but execution is externally switched off (feature flag, missing credentials, workflow turned off). Unblock it and the row flips to FULLY_FUNCTIONAL — a switch, not a fix. Never fold into BROKEN: the remedy differs. |
| PLANNED              | No code yet; genuinely next on the build path (completes an already-shipped family).                                                                                                                                                               |

When the surface is large (SDK endpoints, API families), split the no-code cases by blocker instead of letting PLANNED become a dumping ground: **DEMAND_GATED** (whole family unshipped; built only on a real consumer demand signal), **ON_HOLD** (a pending scope/design decision — not demand — blocks it), **OUT_OF_SCOPE** (intentionally not targeted; revisit only on a demand signal).

Never round up. If you cannot confirm a feature works, it is PARTIALLY_FUNCTIONAL at best.

**Rules:** Code wins when doc and code disagree. Cite evidence (`path/to/file:NN`) — a dedicated Evidence column beats burying it in Notes. Verify each claim — many documented TODOs are already done. Compute counts from the repo, date-stamp any sweep against an external source of truth (e.g. "audited 2026-09-16 against the upstream API reference"), and prefer a standing gate that re-derives doc numbers over hand-maintained ones — duplicated counts rot. Detect project type and adapt which docs are needed.

For BUILD procedures, examples, quality checklists, and AGENTS.md scoring, load [./references/build-guide.md](./references/build-guide.md) and [./references/agents-quality-guide.md](./references/agents-quality-guide.md). Templates: [./assets/](./assets/) — one per doc type.

---

## VERIFY — check freshness and consistency

A doc is fresh only when you confirm its concrete claims against code. "Looks fine" is not a check.

1. **Inventory** the docs. Note any missing.
2. **Read each doc, verify against code.** For every concrete claim (count, path, command, status, feature), open the referenced code and confirm.
3. **Classify findings:** Critical (ghosts, wrong commands), Medium-High (structural decay — completed items in TODO_LIST, "Previously Completed" sections), Medium (contradicts code, stale status), Low (cosmetic).
4. **Fix drift in place.** Prefer computing counts from the repo over hardcoding.
5. **Cross-file consistency:** no feature PLANNED in TODO_LIST and FULLY_FUNCTIONAL in FEATURES; no completed item in both TODO_LIST and CHANGELOG; every internal markdown link resolves; TODO_LIST not suspiciously thin vs recent reports. (A repo can mechanize arms of this — see [./references/drift-alarm-port-evaluation.md](./references/drift-alarm-port-evaluation.md) for the reference implementation and the port trigger.)
6. **External-claims leg (added 2026-10-09):** factual accuracy against YOUR code is not enough — claims about OTHERS rot silently and no internal guard sees it. Grep the live docs (not archived/) for competitor/external product names and third-party numbers; every claim cluster must (a) carry a verify date, (b) link its source, (c) be within its re-verify cadence. A stale competitor claim is Medium-High even when every internal count is perfect — the 2026-10-08 templ-components incident shipped a false competitor claim to production because the drift guard only checked internal counts. For the row-level checks, load [./references/verify-checklist.md](./references/verify-checklist.md).
7. **Job-fitness leg:** for each doc ask "is this doc still doing its job for its audience?" BEFORE fact-checking — a factually-perfect doc can be unfit (TODO_LIST all-struck with nothing pulled forward, README selling removed features, a status report that answers yesterday's question). Load [./references/verify-checklist.md](./references/verify-checklist.md) for the per-doc fitness questions and the failure-mode table.
8. **Run the project's quality gate.** Detect the build system (`nix flake check`, `cargo test`, `pnpm test`, `scripts/check-skills.sh`) and run the canonical command — do not substitute. If no build system, state that explicitly.

For the full per-doc verification checklist and cross-file table, load [./references/verify-checklist.md](./references/verify-checklist.md).

---

## ANNOTATE — resolve items in historical docs

> ⚠️ **#1 FAILURE MODE: Appendix-only (or prependix-only) annotations.**
> Writing a `## Resolution` section at the end (or a banner at the top) while
> leaving every numbered item in the body unmarked is **a complete failure**.
> The reader scans the list, sees no `done at` markers, and assumes everything
> is still open. **Inline edits are MANDATORY.** Every numbered item must be
> resolved in place: `~~item~~ done at`hash``. The appendix is supplementary
> context ONLY — if you wrote an appendix but zero inline markers, go back.

Old reports go stale. A reader opening one wants to know: _is this done? where is it NOW?_ You cannot rewrite history — annotate non-destructively. **If the user did not specify which files or time range, ask before touching anything.**

> ⚠️ **QUOTE THE VERDICT BEFORE ROUTING A DECISION DOC (2026-10-05 rule).**
> Before archiving a report as "superseded"/"never decided", QUOTE its
> verdict/conclusion section verbatim in your working notes. A decision
> doc whose Verdict-up-front says the opposite of its title HAS fooled a
> session into routing "never decided" (the httputil analysis: title said
> proposal, verdict section had DECIDED keep-local) — corrected only
> because a reviewer diff-read the manifest. The quote is the check: if
> you cannot quote the verdict, you have not read the doc.

### The primary work: resolve every numbered item inline

Old reports contain numbered items (lists `1. 2. 3.` or table rows). **You must resolve every one — not just the ones you know about.** Each item gets a verdict:

```markdown
1. ~~Fix warmup store pollution~~ done at `a7b8159`
2. ~~Fix estimateJSONSize~~ done at `a7b8159`, `fe81dd2`
3. Add negative tests: factory returning nil Bundle ← untouched = still open
```

**Format:** `~~<original line, unchanged>~~ done at <short-git-hashes>`. Variants: `Won't implement — <reason>`, `NOT-DO/DUPLICATE — <reason>`. Leave open items untouched — absence of a marker IS the "open" signal. Strike the ENTIRE original line; cite hashes; never renumber.

**Tooling (do not hand-roll):** batch annotations use one Go program, [./assets/annotate.go](./assets/annotate.go) — `go run ./assets/annotate.go rows ...` (numbered table rows) and `go run ./assets/annotate.go prose ...` (numbered prose lists). Both are section-scoped (`## f)` by default / explicit prefix), atomic (write only if every spec matched), refuse already-annotated lines, and support `--dry-run` — ALWAYS dry-run the first spec against a new file shape before mutating (that omission shipped a marker-placement bug on 2026-08-18). rows scoping is LEVEL-AWARE (upstreamed 2026-09-14): the section ends at the next heading of the same-or-higher level, so `--section "### sub"` annotates inside one sub-section without colliding with sibling `###` tables that repeat row numbers; a `#N` suffix (`--section "### a)#2"`) picks the Nth occurrence of a repeated heading. Spec grammar: `<n>:<kind>:<value>` with kinds `h` (hashes), `v` (verified evidence), `p` (docs-health pass), `w` (won't implement), `n` (NOT-DO — decided-against, upstreamed 2026-09-27), `r` (routed verdict, no strike); quote values containing spaces. Completeness gate after an annotate sweep: run it over the files MOVED IN THIS SWEEP (`grep -L '~~' <moved-file>...` each must print nothing) — every newly archived file carries at least one strikethrough resolution. Do NOT run it over the whole `<archived-dir>/`: a long-lived archive legitimately holds pre-canon files (archived before the marker canon existed) with no `~~` markers, and a whole-dir grep re-flags them forever (the 2026-10-14 corpus-batch discrepancy).

**Bulk strikethrough sweeps** (whole-f-section strikes with per-item verdicts, the art-dupl 2026-09-28/29 pattern): `go run ./assets/annotate.go status-items ...` (keys via `go run ./assets/annotate.go emit-keys <file> <lineno...>`). Different job from rows: it strikes numbered/table/checkbox lines as `~~line~~ verdict` (the exact form the `grep '~~'` completeness gate counts), across a WHOLE file, with `N@substring` disambiguation for files with restarting numbered lists. Hardened after the June-batch incident (silent dict-overwrite mis-struck 4 files): duplicate spec keys are a HARD ERROR, open-family verdicts are refused (open items stay BARE), specs are generated mechanically via emit-keys (never hand-typed from memory), and `--verify` prints every key's matched line before any write. Atomic per file; fixture tests: [./assets/annotate-status-items_test.sh](./assets/annotate-status-items_test.sh) (run it after edits — 26 assertions; `annotate.go self-test` covers markers + rows/prose guards).
`go run ./assets/annotate.go check-rows <file>...` (row-level completeness gate) classifies every data row of every table as COMPLETE (uniformly struck), UNTOUCHED, or PARTIAL (mixed struck/unstruck cells or rows — the planted-miss class behind the 2026-09-16 F12.3 miss); exit 1 lists offenders. Run it over every annotated file before declaring a pass done: the grep gate above proves presence, check-rows proves uniformity. A `<!-- check-rows:ledger -->` line above a table exempts exactly that table — for LEDGER tables whose open rows are the point (per-row inline verdicts, e.g. upstream-issue or clone ledgers; blank lines between marker and table are allowed, the exemption never leaks to a following table). The exemption is reported as a `LEDGER-EXEMPT` note per table, never silent.

**Batch repair (2026-10-15, ported from the go-aichat corpus pass):** `go run ./assets/annotate.go repair [--dry-run] <specfile>` applies a whole corpus of verdicts from one TSV spec (`path<TAB>lines<TAB>kind[<TAB>value]`, lines `18` or `18-27`, ranges allowed, later specs override earlier per line). It strikes table rows per-cell (dropping the malformed `| ~~ |` placeholder first cell the 2026-10-15 corpus carried), wraps prose items whole, honors the routed kind (append, no strike), and skips already-annotated lines — re-runs are no-ops. `go run ./assets/annotate.go unwrap [--dry-run] <file>:<lines>...` rebuilds struck rows a formatter re-wrapped (verdict fragments spilled into extra cells — the dprint-damage class that makes check-rows flag PARTIAL). `check-rows --normalize` repairs the sibling damage conservatively: trailing EMPTY cells beyond the table's separator column count are dropped, nothing else. All three are atomic and dry-run-first; `annotate.go self-test` covers them (placeholder drop, unwrapped rebuild, normalize trim, re-run no-op, and the emit-keys line-accuracy pin: every emitted key must round-trip into the exact line it came from — the 2026-10-15 07-21 off-by-one lesson, now a regression test).


**Doc-damage triage: inspect raw bytes first (`cat -A`), then pick the tool.** The three repair paths are for three DIFFERENT shapes and a wrong choice makes the state worse: `--normalize` for beyond-count trailing empties (padding), `unwrap` for formatter re-wraps (verdict fragments in extra cells), `repair-mangle` for double-strike/collapse shapes. `unwrap` on double-strike damage makes it worse (learned 2026-10-15); hand-rolled sed/perl against an unrecorded shape is how the corpus got 7 files deep before anyone noticed — extend `repair-mangle` with a fixture instead. Canonical empty-struck-cell form: `~~ ~~` — VERIFIED formatter-stable 2026-10-15 (a `buildflow format` pass left it byte-intact); the corpus `| ~~~~ |` collapse came from the original 19-22 mangling event, not a reproducible dprint bug, so no upstream issue — re-run the repro only if a fresh format pass ever produces `~~~~` from `~~ ~~`.
`go run ./assets/annotate.go repair-mangle [--dry-run] <file>...` repairs the THIRD damage class (2026-10-15 corpus, 7 archived files): a formatter pass doubling strikes (`~~~~x~~~~`), collapsing empty struck cells (`||`, `| ~~~~ |`), and gluing quad boundaries — the mechanical shapes repair to `~~ ~~`/single pairs; a tilde quad AT a cell boundary (`gosec ~~~~ |`) is content-loss (the swallowed text is unrecoverable mechanically) and is reported, exit 1, for hand repair. Idempotent. `self-test` covers all shapes; it validated clean against the repaired go-aichat corpus and found + repaired 8 REAL leftover mangles the corpus-wide check-rows gate cannot see (it proves uniformity, not shape).

**Skipping items you didn't check is the #1 failure mode.** For the full format catalog (variants, table-row patterns, multi-item tables 5+), load [./references/resolving-items.md](./references/resolving-items.md).

### Classify each file before annotating

| Decision    | Apply when                                                |
| ----------- | --------------------------------------------------------- |
| ANNOTATE    | A reader would benefit; value not already present         |
| ARCHIVE     | EVERY item resolved → run `check-rows` on the file FIRST (gate BEFORE `git mv` — the 21:00 2026-10-15 pass moved 9 files and only gated after, hiding shape damage) → `git mv` to `<dir>/archived/<file>` |
| SKIP        | Already clear — has its own resolution or correct content |
| LEAVE ALONE | Describes rejected / deferred work where a note misleads  |

**Archive manifest for bulk audits (2026-10-01):** when an AUDIT/ANNOTATE
sweep archives MORE THAN ONE file in one pass, the sweep's report (or the
archive dir's README) carries a one-line-per-file manifest: filename →
classification (from the table above) + the deciding reason. A bulk archive
without a manifest is invisible history — the next audit cannot tell a
resolved-and-archived file from one that was never classified. Single-file
archives skip this (the commit message is the manifest).

### Placement: inline before appendix

Correct stale claims **in place**: `~~Nothing committed.~~ Committed as a7b8159.` If the opening/TL;DR has stale claims, inline-correct them — a reader forms their impression from the opening. An end-of-file `## Resolution (date)` appendix is supplementary context, **never the only annotation. Appendix-only on a file with numbered items = the #1 failure mode.**

For placement examples, scope-asking, HTML edge cases, and undo procedures, load [./references/annotation-placement.md](./references/annotation-placement.md). For the Verschlimmbesserung (a well-intentioned edit that makes things worse) origin incident, load [./references/case-study.md](./references/case-study.md).

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
