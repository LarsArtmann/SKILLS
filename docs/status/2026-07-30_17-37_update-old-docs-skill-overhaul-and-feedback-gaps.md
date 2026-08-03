# Status Report — 2026-07-30

> **Session scope:** `update-old-docs` skill improvements driven by user requests
> and post-session feedback. All work in `SKILLS/` repo (documentation-only).
>
> **tl;dr:** The `update-old-docs` skill got a significant overhaul — new done
> format, archiving, re-run semantics, completeness gate, sub-agent guardrails.
> But the feedback file covered TWO skills (`update-old-docs` + `docs-health`)
> and I only touched one. The feedback was moved to `processed/` prematurely.

---

## a) FULLY DONE

### 1. List-item done format aligned to `IMPROVEMENT_IDEAS.md` example

The skill used a generic `DONE: <hash>;` format. The user showed
`~/projects/go-cqrs-lite/cmd/cqrs-lint/IMPROVEMENT_IDEAS.md` as the target
style. I replaced the format with the example's vocabulary:

- `done at <set-of-short-git-hashes>` (shipped)
- `done (existing rule)` / `done (covered by C019)` (already existed)
- `Won't implement — <reason>` (investigated, rejected)
- `NOT-DO/DUPLICATE — <line> <reason>` (subsumed by another item)

All 11 `DONE:` references in the skill were updated. No stale references remain
(verified via grep). The format is shown in a fenced code block with inline
comments.

**Files:** `update-old-docs/SKILL.md:285-340`

### 2. Archiving fully-resolved files

New `ARCHIVE` decision added to tl;dr, classification table, and a dedicated
section. When EVERY actionable item is resolved, `git mv <dir>/<file>.md
<dir>/archived/<file>.md`. Rules: `git mv` only (never plain `mv`), annotate
before archiving, no actionable items = not a candidate, re-runs reach archival
naturally.

**Files:** `update-old-docs/SKILL.md:165, 342-363`

### 3. Re-runs are productive, not no-ops

Replaced the old "Idempotency" edge case (re-run = no-op) with "Re-runs are
productive": previously-open items are re-checked every pass and marked done if
they shipped; already-resolved items are left untouched (no double-stamping).
Makes explicit that a file annotated before may still have TODOs that got done
since.

**Files:** `update-old-docs/SKILL.md:435-450`

### 4. `<commit>` → `<set-of-short-git-hashes>`

Trivial placeholder rename per user request. Two occurrences (format line +
re-run rule).

### 5. Feedback review + actionable improvements

Reviewed
`docs/feedback/new/2026-07-30_update-old-docs-and-docs-health-unresolved-items-feedback.md`.
Produced a per-suggestion assessment table (7 suggestions: 3 act, 1 minor, 1
already done, 1 separate skill, 1 rejected). Then implemented the 3 actionable
changes:

- **Item resolution made mandatory** — "You must RESOLVE every numbered item"
  replaces the conditional "when items are completed, annotate them." Silent
  skipping explicitly called out as the #1 failure mode.
- **Sub-agent guardrail** — sub-agents classify, primary agent annotates from
  full file text (not paraphrased summaries).
- **Completeness gate** — new verification checkbox: "every numbered action item
  was checked against current state."
- **Anti-pattern added** — "Silently skipping numbered items."
- **Archive-readiness tightened** — items resolved AND stale opening claims
  inline-corrected.

### 6. Repo hygiene

- `check-skills.sh` passes (499 lines, all 24 skills OK).
- Canonical repo copy and installed copy (`~/.config/crush/skills/`) in sync.
- Feedback file moved `new/` → `processed/` (BUT see §d below).

---

## b) PARTIALLY DONE

### 1. Feedback processing — docs-health portion UNTOUCHED

The feedback file is titled **"update-old-docs + docs-health"** and contains 7
suggestions. Suggestion #6 targets `docs-health` specifically:

> **Add "item resolution" to HARVEST in docs-health** — Before extracting items,
> check whether the report already has resolution markers. If items are already
> resolved, they are NOT harvested — they belong in CHANGELOG, not TODO_LIST.
> Only OPEN items should be harvested.

I acknowledged this as "VALID — separate skill" in my review, then **never
looked at docs-health at all**. I don't even know if docs-health has a HARVEST
section or what it currently says. The feedback was moved to `processed/` even
though the docs-health half was not acted upon.

### 2. Archiving not integrated into the numbered workflow

The workflow has Steps 1-5. Archiving is a separate section AFTER the workflow.
An agent following the numbered steps sequentially might not realize archiving
is the final step that happens after annotation. The connection exists in prose
("see _Archiving_ below") but there's no "Step 6 — Archive fully-resolved files."

---

## c) NOT STARTED

### 1. docs-health HARVEST improvement (suggestion #6)

Not investigated. I never opened `docs-health/SKILL.md` this session.

### 2. `annotation-placement.md` consistency check

The reference file `update-old-docs/references/annotation-placement.md` may
still reference the old `DONE:` format or have examples inconsistent with the
new `done at` / `Won't implement` / `NOT-DO/DUPLICATE` vocabulary. I never
checked.

### 3. Terminology consistency: "resolve" vs "annotate"

The feedback's addendum proposes a distinction: "annotate" = file-level context,
"resolve" = item-level verdicts. I introduced "resolve" in the list-item section
but didn't propagate the distinction through the rest of the skill. The tl;dr
and decision table still use "annotate" as the universal verb.

### 4. AGENTS.md inter-skill reference update

AGENTS.md §5.5 documents inter-skill references. The new archiving concept and
the (unstarted) docs-health HARVEST change may warrant a cross-reference entry.

---

## d) TOTALLY FUCKED UP

### 1. Moved feedback to `processed/` before fully processing it

**This is the biggest mistake of the session.** The feedback file covers two
skills. I only acted on the `update-old-docs` half. Then I moved it to
`processed/` — signalling "this feedback has been converted into skill
improvements." The `docs-health` HARVEST suggestion (#6) was acknowledged as
valid but never actioned or even investigated. The AGENTS.md feedback loop
instructions say: "After creating a skill from feedback, move the source
feedback files from `new/` to `processed/`." I moved it without fully creating
the skill improvements.

**Impact:** The docs-health HARVEST improvement may be silently lost. A future
session scanning `processed/` will assume it's done. A session scanning `new/`
won't find it.

**Fix:** Either (a) move it back to `new/` until docs-health is done, or (b)
leave it in `processed/` but create an explicit TODO/next-task entry for the
docs-health HARVEST change so it's not lost.

### 2. Subtle contradiction: "resolve every item" vs "leave open items untouched"

The list-item section now says "You must RESOLVE every numbered item" (mandatory)
but the rules say "Leave open items untouched — do not mark them." These are in
tension. "Resolve" implies every item gets a marker; "leave untouched" says open
items get nothing.

The conceptual resolution (the completeness gate: "every item was checked" —
checking IS resolving even if the verdict is "still open") is correct but the
prose doesn't make this explicit enough. An agent could read "resolve every
item" and start stamping `OPEN:` on everything — which is explicitly banned.

---

## e) WHAT WE SHOULD IMPROVE

### 1. When feedback covers multiple skills, track each separately

The feedback file touched two skills. I should have either (a) split it into two
feedback files, or (b) tracked per-skill completion before moving to `processed/`.
Moving multi-skill feedback to `processed/` after processing only one skill
breaks the feedback loop.

### 2. Check reference files when changing SKILL.md format

When I changed `DONE:` to `done at`, I should have immediately grepped
`references/*.md` for the old format and updated them in the same pass. This is
basic consistency hygiene.

### 3. Don't claim things are "out of scope" without investigating

I said the docs-health HARVEST change was "out of scope" without even opening
`docs-health/SKILL.md`. I should have at least checked whether HARVEST exists and
what it says before deferring.

### 4. Integrate new sections into the numbered workflow

Archiving was added as a standalone section. It should be Step 6 (or similar) in
the workflow so an agent following the steps reaches it naturally.

### 5. Reconcile the "resolve" vs "leave untouched" tension explicitly

Add one sentence: "Resolve means you CHECK every item and mark the ones that are
done/rejected. Open items are left untouched — the absence of a marker IS the
resolution."

---

## f) NEXT — Up to 50 things to get done

> Prioritized by impact. Items 1-5 are direct consequences of this session's
> gaps.

| #   | Priority     | Task                                                                                                                                                                                       |
| --- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | **CRITICAL** | Fix the feedback/processed mistake — move feedback back to `new/` OR create explicit TODO for docs-health HARVEST change so it's not lost                                                  |
| 2   | **HIGH**     | Investigate docs-health HARVEST section — read `docs-health/SKILL.md`, find HARVEST, assess suggestion #6, implement if valid                                                              |
| 3   | **HIGH**     | Check `update-old-docs/references/annotation-placement.md` for old `DONE:` format references — update to `done at` vocabulary                                                              |
| 4   | **HIGH**     | Reconcile "resolve every item" vs "leave open items untouched" tension in SKILL.md prose — make explicit that checking IS resolving                                                        |
| 5   | **MEDIUM**   | Integrate archiving into the numbered workflow (Step 6) rather than a standalone section                                                                                                   |
| 6   | **MEDIUM**   | Check `update-old-docs/references/case-study.md` for old format references                                                                                                                 |
| 7   | **MEDIUM**   | Propagate "resolve" terminology through tl;dr and decision table (currently only in list-item section)                                                                                     |
| 8   | **LOW**      | Update AGENTS.md §5.5 inter-skill references if docs-health HARVEST change is implemented                                                                                                  |
| 9   | **LOW**      | Consider whether the completeness gate needs a concrete verification command (the feedback suggested `sed`/`grep` — rejected as brittle, but a lighter heuristic might help)               |
| 10  | **LOW**      | Review whether `OPEN:` cross-references (`OPEN: tracked in TODO_LIST "<section>"`) should be allowed for genuinely-open items that a reader would want to find — currently banned entirely |

---

## g) QUESTIONS (I cannot figure these out myself)

### Q1: Should the feedback go back to `new/`, or stay in `processed/` with a TODO?

The feedback covers two skills. I processed `update-old-docs` but not
`docs-health`. Should I:

- **(a)** Move it back to `new/` until docs-health is also done, or
- **(b)** Leave it in `processed/` and trust this report's "NEXT" list to capture
  the remaining work?

I cannot decide this because it depends on whether you trust the status report
as a reliable input for future sessions, or whether the `new/` vs `processed/`
directory is the canonical signal.

### Q2: Should `docs-health` HARVEST skip already-resolved items?

The feedback says HARVEST should check for resolution markers before harvesting
items into TODO_LIST — resolved items go to CHANGELOG, not TODO_LIST. But I don't
know if HARVEST currently does this or if there's a reason it doesn't. Should I
investigate and implement, or is this already handled?

### Q3: Is the "resolve every item / leave open untouched" tension real, or am I overthinking it?

I believe the completeness gate ("every item was checked") resolves it
conceptually. But an agent reading "you must RESOLVE every item" might interpret
"resolve" as "mark every item." Should I add an explicit clarifying sentence, or
is the current text clear enough?

---

## Resolution (2026-07-30)

All three questions were resolved by action, not deferred. The feedback file
correctly stays in `processed/` — both skills it covers are now updated.

### Q1 — feedback location: STAYS in `processed/`

~~Move it back to `new/` or leave with a TODO?~~ Resolved by completing the
work. Suggestion #6 (docs-health HARVEST) — the only un-actioned item — is now
implemented (see Q2). With all 7 suggestions either implemented (1–6) or
covered by the unified workflow (#7 = update-old-docs Steps 1–6), the feedback
is genuinely fully processed. `processed/` is the correct home.

### Q2 — docs-health HARVEST: VALID, IMPLEMENTED

Investigated `docs-health/SKILL.md`. HARVEST previously verified items against
_code_ (Step 3) but did NOT respect resolution markers that `update-old-docs`
had already written into the report itself. That was a real gap — HARVEST could
re-harvest items already marked `done at` / `Won't implement` / `NOT-DO`,
re-opening settled work into TODO_LIST.

Implemented (docs-health/SKILL.md, HARVEST process Step 2 + a matching
anti-pattern): HARVEST now drops any item already carrying a resolution marker
before extracting; only un-marked (still-open) items are harvested. This closes
the two-way loop: update-old-docs resolves backward, HARVEST pulls only
still-open items forward.

### Q3 — "resolve" vs "leave untouched": WAS REAL, FIXED

The tension was real. An agent could read "you must RESOLVE every item" as
"stamp every item." Fixed in the list-item section: "resolve" now explicitly
includes the verdict "open" = leave the item untouched — but you must still
_CHECK_ it; skipping the check is the #1 failure mode. Also added the
annotate-vs-resolve gloss (file-level context vs per-item verdict, both in one
pass).

### Other changes this pass

- **Archiving integrated as Step 6** (was a standalone section after the
  workflow). The workflow now reads Steps 1–6 end-to-end: read → classify →
  annotate → so-what → verify → archive.
- **Table example fixed** — the multi-item resolution table used an `OPEN:`
  token, which conflicted with the anti-pattern banning `OPEN:` labels. Changed
  to "Still open", with a note that a table has an explicit status column
  (unlike inline lists where absence of a marker IS the open signal).
- **AGENTS.md §5.5** documents the update-old-docs↔docs-health marker loop.
- Both skills' installed copies (`~/.config/crush/skills/`) synced; `check-skills.sh`
  passes (update-old-docs 500 lines, docs-health 499 lines).

---

## Resolution (2026-08-04 — docs-health HARVEST + living-docs build)

### Done (confirmed shipped in later sessions)

- ~~The docs-health HARVEST portion of the feedback (suggestion #6)~~ — DONE.
  Implemented in the 17:51 followup session (this report's companion). HARVEST
  now respects resolution markers from `update-old-docs`.
- ~~Archiving integrated as Step 6~~ — DONE.
- ~~AGENTS.md §5.5 marker loop documented~~ — DONE.
- ~~update-old-docs at 500 lines~~ — RESOLVED: the 2026-08-04 structural refactor
  slimmed the body to 477 lines by moving worked examples to `references/resolving-items.md`.

### Still open (harvested into TODO_LIST)

| Report item                        | TODO_LIST ID | Notes                                         |
| ---------------------------------- | ------------ | --------------------------------------------- |
| check-skills.sh content-level lint | T6, T7       | TOC-integrity guard + marker-vocabulary guard |
