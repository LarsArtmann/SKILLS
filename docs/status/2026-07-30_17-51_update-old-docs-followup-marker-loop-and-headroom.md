# Status Report — 2026-07-30 (17:51)

> **Session scope:** Close every open gap left by the previous
> `update-old-docs` overhaul pass (the report at
> `2026-07-30_17-37_*.md` posed 3 questions and listed 10 next-tasks).
> This session answered the questions by acting, then implemented the
> remaining improvements.
>
> **tl;dr:** All three questions resolved by action. The docs-health
> HARVEST gap (feedback #6 — never investigated last session) is now
> implemented. Archiving is Step 6. The resolve/leave-untouched tension
> is reconciled. The two-way marker loop between the skills is wired and
> documented. **But update-old-docs now sits at EXACTLY 500 lines — zero
> headroom — and I repeated my own mistake pattern by not checking
> docs-health's verify-checklist for a matching re-harvest guard.**

---

## a) FULLY DONE

### 1. docs-health HARVEST marker-respect rule (feedback #6)

The single biggest gap from last session: the feedback file covered two
skills, I only touched `update-old-docs`, then moved the feedback to
`processed/` prematurely. This session I investigated and implemented
the missing half.

**Finding:** HARVEST Step 3 already verified items against _code_
("grep before adding; an item already shipped goes to CHANGELOG"). But it
did NOT respect resolution _markers_ that `update-old-docs` had written
_into the report itself_. An item marked `done at a7b8159` in the report
could still be re-harvested into TODO_LIST — re-opening settled work.
That was a real, distinct gap (markers in report ≠ code verification;
both needed).

**Implemented** (`docs-health/SKILL.md`):

- HARVEST process Step 2: new first bullet — drop any item already
  carrying a `done at` / `Won't implement` / `NOT-DO` marker before
  extracting. Only un-marked (still-open) items are harvested. Explains
  the loop in one line ("update-old-docs resolves backward; HARVEST
  pulls only still-open forward").
- HARVEST anti-patterns: "Re-harvesting items already marked resolved."

**Verified:** no marker vocabulary exists in `docs-health/references/`,
so no reference files need follow-through (I checked — see lesson in
§e).

### 2. Archiving integrated as Step 6

Was a standalone section after the workflow. Now `### Step 6 — Archive
fully-resolved files` sits inside "The workflow" after Step 5, so an
agent following the numbered steps reaches it naturally. Compressed the
rules (merged two bullets) to stay under the line limit. Workflow now
reads end-to-end: read → classify → annotate → so-what → verify →
archive.

### 3. "Resolve" vs "leave untouched" tension reconciled (Q3)

The prose said "you must RESOLVE every item" while the rules said "leave
open items untouched." An agent could read "resolve" as "stamp every
item." Fixed in the list-item section: "resolve" now explicitly includes
the verdict _open_ = leave untouched, but you must still _CHECK_ it
(skipping the check is the #1 failure mode).

### 4. Annotate-vs-resolve gloss added

The feedback's addendum proposed a terminology distinction. Added a
parenthetical in the list-item section: _annotate_ = file-level context;
_resolve_ = per-item verdict; both happen in one pass.

### 5. Table `OPEN:` token fixed

The multi-item resolution table example used `OPEN:` — conflicting with
the anti-pattern banning `OPEN:` labels on inline items. Changed to
"Still open", with a note that a table has an explicit status column
(unlike inline lists, where absence of a marker IS the open signal).

### 6. AGENTS.md §5.5 cross-reference

Documents the two-way marker loop: update-old-docs resolves backward +
writes markers; docs-health HARVEST skips marked items forward. The
marker vocabulary is owned by update-old-docs; HARVEST references it.

### 7. Status report questions answered non-destructively

The earlier report (`2026-07-30_17-37_*.md`) posed 3 questions. Rather
than rewrite it, I appended a `## Resolution (2026-07-30)` section with
inline strike-through on the resolved decisions. Practiced what the
skill preaches.

### 8. Repo hygiene

- `check-skills.sh` passes (all 24 skills).
- Both installed copies (`~/.config/crush/skills/`) synced.
- Auto-git daemon committed skill edits (commits `92ac298`, `2d77b16`).

---

## b) PARTIALLY DONE

### 1. Feedback file correctly stays in `processed/` — but only because I finished the work

Last session's mistake was moving it prematurely. This session I
implemented the missing suggestion #6, so all 7 suggestions are now
either implemented (1–6) or absorbed into the unified Steps 1–6
workflow (#7). It is _now_ legitimately fully processed. But the fix
was reactive — the premature move happened first, the work second. The
correct sequence would have been: do the work, then move the file.

### 2. docs-health marker-respect rule is in SKILL.md, not in the verify-checklist

I added the HARVEST process rule + an anti-pattern. But docs-health has
a separate `references/verify-checklist.md` with failure-mode rows, and
I did NOT add a verify row for "TODO_LIST contains items already marked
resolved in recent reports." The rule exists in prose; the verification
lens that would catch its violation does not. See §d.

---

## c) NOT STARTED

### 1. docs-health `verify-checklist.md` — no re-harvest failure-mode row

`verify-checklist.md` has rows like "Unharvested report" (forwards
forgotten). It has no row for the inverse: "Re-harvested resolved items"
(resolved items dragged back into TODO_LIST). My new HARVEST rule makes
that a failure mode, but the checklist that an agent runs to catch
failures doesn't know about it.

### 2. status-report skill — no awareness of marker format

`status-report` produces the "next tasks" section that update-old-docs
later resolves and HARVEST later harvests. The marker vocabulary (`done
at` etc.) is now load-bearing across two consumer skills, but
status-report doesn't structure its output to make future resolution
easy (e.g., numbered items, not prose paragraphs). Not investigated.

---

## d) TOTALLY FUCKED UP

### 1. Repeated my own mistake: edited SKILL.md without checking the sibling references — AGAIN

The #1 lesson from last session's status report (§e.2): "When I changed
`DONE:` to `done at`, I should have immediately grepped `references/*.md`
for the old format." This session I edited `docs-health/SKILL.md` and
did check `docs-health/references/` (good — they were clean). **But I
did NOT check `docs-health/references/verify-checklist.md` for a
\_missing matching check** — a different flavor of the same blindness.
I added a new failure mode (re-harvesting resolved items) to the
SKILL.md prose but never went to the verify-checklist reference and
added the row that would actually _catch_ that failure. The rule and
its enforcement are in two different files; I touched one.

This is the deeper version of the same anti-pattern: **when you add a
rule, trace it to every place that enforces or illustrates it.** I
traced the marker format (and it was clean). I did not trace the new
failure mode to the verify-checklist. Half-diligent.

### 2. update-old-docs is at EXACTLY 500 lines — zero headroom

`check-skills.sh` enforces a 500-line hard limit. My edits landed the
file at exactly 500. The next edit — any edit, even a one-line fix —
will fail validation and force a compression pass before the change can
land. I prioritized "fit everything in" over "leave breathing room."
A senior engineer would have compressed to ~495 to leave a 5-line
buffer. The file is now fragile to maintain.

---

## e) WHAT WE SHOULD IMPROVE

### 1. When adding a failure mode, update the verify-checklist in the same pass

A rule in SKILL.md prose and its enforcement in verify-checklist.md are
_one change_, not two. I should treat "add rule + add matching verify
row" as atomic. The verify-checklist is the thing an agent actually
runs; a rule with no verify row is a suggestion, not a gate.

### 2. Leave line-count headroom, don't max out the limit

500/500 is a maintenance hazard. Budget for ~5 lines of slack so the
next improvement doesn't require a compression detour. When approaching
the limit, compress proactively rather than landing at the exact edge.

### 3. Trace new concepts to ALL consumer skills, not just the one being edited

The marker vocabulary now flows: status-report (produces) →
update-old-docs (resolves, writes markers) → docs-health HARVEST
(respects markers). I wired the middle two. I did not check whether
status-report's output format is marker-friendly. The full loop should
be audited, not just the segment I happened to be editing.

### 4. "Do the work, then move the file" — always in that order

Moving feedback to `processed/` before the work is done breaks the
feedback loop. The directory is the signal. If unsure whether work is
done, leave it in `new/`.

---

## f) NEXT — things to get done

| # | Priority   | Task                                                                                                                                                                   |
| - | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | **HIGH**   | Add a "Re-harvested resolved items" failure-mode row to `docs-health/references/verify-checklist.md` — closes the gap from §d.1                                        |
| 2 | **HIGH**   | Compress `update-old-docs/SKILL.md` to ≤495 lines to restore maintenance headroom (currently 500/500)                                                                  |
| 3 | **MEDIUM** | Audit `status-report/SKILL.md` — does its "next tasks" output format (numbered vs prose) make future `done at` resolution easy? Adjust if marker-unfriendly            |
| 4 | **MEDIUM** | Verify the docs-health HARVEST Step 2/Step 3 ordering reads cleanly to a fresh reader (marker-drop in Step 2 vs code-verify in Step 3 — make the distinction explicit) |
| 5 | **LOW**    | Consider whether `update-old-docs/references/` needs a short "annotate vs resolve" reference doc, or whether the inline gloss is sufficient                            |
| 6 | **LOW**    | Review whether the `done at` marker format should be documented once in a shared location (not just update-old-docs) since HARVEST now depends on it                   |

---

## g) QUESTIONS (I cannot figure these out myself)

### Q1: Should `status-report` emit numbered "next tasks" items to make future resolution mechanical?

The marker vocabulary (`done at <hash>` struck through the original
line) only works cleanly on numbered list items. If `status-report`
writes its section f) as prose paragraphs or unnumbered bullets, a later
`update-old-docs` pass has to reformat before it can resolve items. I
don't know if you want status-report's output shaped by the needs of a
_downstream_ skill. Is that a coupling you accept, or should
update-old-docs handle whatever format it receives?

### Q2: Is "leave 5 lines of headroom" a rule I should encode, or is landing at 500 acceptable?

I treated 500 as the target. You may consider exact-max acceptable
(ships more content). I consider it fragile (next edit breaks). Which
posture should I take as default across all skills?

### Q3: Should the docs-health verify-checklist live as a reference file, or be inlined into SKILL.md?

The verify-checklist is a separate reference that an agent loads on
demand. But the HARVEST failure modes I'm adding need to be visible
_when the agent runs HARVEST_, not after they remember to load a
reference. I can't tell whether the progressive-disclosure model is
serving the verify step or hiding it.

---

## Resolution (2026-08-04 — docs-health HARVEST + living-docs build)

### Done (confirmed shipped in later sessions)

- ~~update-old-docs at exactly 500 lines (zero headroom)~~ — RESOLVED: the
  2026-08-04 structural refactor slimmed the body to 477 lines. The references-first
  pattern broke the feedback-accretion cycle.
- ~~docs-health verify-checklist missing re-harvest guard~~ — DONE: the marker-
  respect rule is now in both `docs-health/SKILL.md` HARVEST and the
  `verify-checklist.md` reference.

### Still open (harvested into TODO_LIST)

| Report item                                       | TODO_LIST ID | Notes                                       |
| ------------------------------------------------- | ------------ | ------------------------------------------- |
| check-skills.sh content-level lint (TOC, anchors) | T6           | Still structural-only                       |
| Marker-vocabulary contract guard                  | T7           | AGENTS.md §5.5 contract not script-enforced |
| docs-health references-first refactor             | T5           | docs-health still at 500/500 lines          |

### Questions — status

- **Q1 (format flexibility):** Resolved — the skill now handles both prose lists
  and table rows (Pattern A + B in `resolving-items.md`).
- **Q2 (500-line headroom rule):** Partially resolved — `update-old-docs` now has
  23-line headroom; `docs-health` still at capacity (T5).
- **Q3 (verify-checklist location):** Resolved — progressive disclosure kept;
  HARVEST markers are in SKILL.md body, detailed checks in reference.
