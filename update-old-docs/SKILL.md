---
name: update-old-docs
description: >
  Keeps OLD and historical documents current — status reports, plans, reviews,
  audits, snapshots, and other point-in-time files that have gone stale.
  Non-destructive: annotates or corrects WITHOUT rewriting history. Use when
  the user asks to update, mark, annotate, or bring up to date many old/stale
  files at once: "update all the *2026-07-1* status reports", "mark these old
  reports as done", "annotate every status file so it's clear what shipped",
  "add a resolution note to each report", "make the old planning docs reflect
  current reality", "is this still current?", "bring the old audits up to
  date". Enforces non-destructive annotation (inline correction or end-of-file
  appendix, never intrusive top-of-file banners), the "so what?" specificity
  test, per-file judgment over blanket scripts, and restraint ("update all"
  does NOT mean every file must change). DISTINCT from docs-health, which
  maintains LIVING docs by rewriting them in place.
metadata:
  tags: documentation, annotation, historical, status-reports, freshness, restraint, non-destructive, appendix, anti-patterns
---

# Update Old Docs

_Keep old documents current without destroying their history._

> **tl;dr (the whole skill in 5 lines):**
>
> 1. Read every old file before touching any.
> 2. Per file decide: **ANNOTATE** / **ARCHIVE** / **SKIP** / **LEAVE ALONE**.
> 3. Write only specific notes (commit hash + what's still open) — never generic banners.
> 4. Every note must survive the **"so what?"** test.
> 5. **Resolve numbered items inline first** (`~~item~~ done at `hash``) — this is the primary work. Then add an end-of-file appendix for context. **Appendix-only is the #1 failure mode** — if you wrote an appendix but zero inline markers, go back.
> 6. Re-runs are productive: items finished since the last pass get marked `done at` — never re-stamp an already-resolved item. When ALL items resolve, move the file to `archived/`.

Old documents — status reports, plans, reviews, audits, snapshots — capture
what someone knew at a point in time. They go stale. A reader opening an old
status report wants to know: _is this done? where is it NOW?_ Keeping that
report current is the job.

This is a **different problem** from maintaining living docs. Living docs
(`README.md`, `FEATURES.md`, `TODO_LIST.md`) get rewritten in place — that is
[`docs-health`](../docs-health/SKILL.md). Historical snapshots **cannot** be
rewritten without destroying their value as a record, so the only safe tool is
**non-destructive annotation**: inline corrections or end-of-file appendices.
And when you update many old docs at once, the dominant failure mode is a
**Verschlimmbesserung** — a well-intentioned batch edit that makes things worse
(58 identical generic banners that say nothing and have to be rolled back).

READ, UNDERSTAND, RESEARCH, REFLECT before every action.

## Core principle: restraint is success

**"Update all the old files" means "no file that NEEDS updating is missed." It
does NOT mean "every file gets a change."** A doctor does not operate on every
patient in the waiting room just because the instruction said "see all
patients."

Leaving an old file untouched because it is already clear, already correct, or
because no annotation would add value is the CORRECT outcome — not a failure.
Measure success by **value added per annotation**, not by **files touched**.
The number of files you left untouched is a metric of good judgment, not of
laziness.

## When this applies

Activate when the task involves bringing OLD or historical documents up to
date:

- "update all the `*2026-07-1*` status reports so it's clear what's done"
- "mark each old report as resolved / shipped"
- "annotate every status file with the current state"
- "add a resolution note to each planning doc"
- "make the old audits reflect current reality"
- "is this report still current?"

### Scope clarification: ask when the time frame is unspecified

The scope of "which files" is load-bearing. "Update the old status reports"
is ambiguous — _which ones?_ The `docs/status/` directory may contain
hundreds of reports spanning months. Running an annotation pass over the
wrong set wastes work and risks touching files the user did not mean.

**If the user did not specify a time frame or file set, STOP and ASK before
reading or touching any file.** Do not guess "all of them" — that is how a
Verschlimmbesserung starts on a scale the user cannot easily review.

Examples of **explicit scope** (proceed):

- "update all the `*2026-07-1*` status reports" — clear glob pattern
- "annotate the July reports" — clear month
- "update the reports from last week" — clear relative window
- "mark `docs/status/2026-06-17_*.md` as done" — explicit paths

Examples of **unspecified scope** (ask first):

- "update all the old status reports" → ask: _which time range? (e.g. before
  2026-07, last month, specific glob pattern)_
- "mark the old reports as resolved" → ask: _which reports? All of
  `docs/status/`, or a subset by date?_
- "bring the old docs up to date" → ask: _which docs — status reports,
  plans, reviews? And from when?_

Ask once, concisely: name what you found in the directory (file count, date
range), state the ambiguity, and propose a default the user can confirm or
correct. A good ask:

> Found 47 files in `docs/status/` spanning 2026-03 to 2026-07. You said
> "update the old reports" — which time range? I can do all of them, or
> narrow to (e.g.) everything before 2026-07-01. Which set?

**Never proceed on an unspecified scope by picking the broadest
interpretation.** The broadest interpretation maximizes blast radius and
minimizes the chance the user can review every change. Narrow is safe;
broad is not.

If the task is about maintaining a **living** doc (rewriting `README.md`,
rebuilding `FEATURES.md`, refreshing `TODO_LIST.md`), that is `docs-health`,
not this skill. The distinction: **living docs get rewritten; old docs get
annotated.**

### Boundary: living doc with accumulated cruft is NOT this skill

A living doc (especially `TODO_LIST.md`) that has slowly accumulated historical
material across many sessions — "Previously Completed" sections,
struck-through resolved items, rejected spikes kept "for reference," "- DONE"
backlog items duplicating ROADMAP — is **not** a snapshot gone stale. It is a
living doc whose _purpose_ has been diluted. That is
[`docs-health`](../docs-health/SKILL.md) territory (it has explicit
structural-decay handling: rebuild, do not annotate). This skill annotates
point-in-time _snapshots_ non-destructively. Living docs get rewritten, not
annotated.

**Done/completed TODO items belong in `CHANGELOG.md` — NEVER in `TODO_LIST.md`. When a task is finished, remove it from TODO_LIST and record it in CHANGELOG. TODO_LIST is for open work only.** When annotating an old report that references now-completed TODO items, point to the CHANGELOG entry or commit — do not re-list the completed work in TODO_LIST.

If you reach for annotation when rebuild is correct, you will produce a
trophy case with sticky notes on it — still a trophy case.

### Before annotating: confirm the doc is actually a snapshot

State in one line before any work: _"This file is a point-in-time snapshot
(report / plan / audit), so annotation adds value."_ If the file is a living
doc that should be current at all times (`TODO_LIST`, `FEATURES`, `README`),
stop — that is a docs-health rewrite, not an update-old-docs annotation.

---

## The workflow

### Step 1 — Read everything before touching anything

Before annotating a single file, read and understand EVERY target. Use
sub-agents to parallelize the **classification** pass (what's stale, what
items exist) — but the **annotation itself** (writing `done at` markers,
inline-correcting claims) must be done by the primary agent after reading
the actual file text, not a paraphrased summary. Do not annotate or write
any script until you can answer for each file: _what does it currently say,
and what does it currently lack?_

This is non-negotiable. The Verschlimmbesserung happens when you decide the
annotation before understanding the targets.

### Step 2 — Classify each target (per-file judgment)

For every file, make exactly ONE of three decisions:

| Decision        | Apply when                                                                                         |
| --------------- | -------------------------------------------------------------------------------------------------- |
| **ANNOTATE**    | A reader of this old file would clearly benefit, and the value is NOT already present in it        |
| **ARCHIVE**     | EVERY actionable item is resolved (done / rejected / won't-do). Move to `archived/<file-name>`     |
| **SKIP**        | The file is already clear — it has its own resolution section, status table, or correct content    |
| **LEAVE ALONE** | The file describes rejected / deferred / abandoned work where a "this was done" note would mislead |

Record this list. The list IS the plan. _"I will annotate 24 of the 89 files,
archive 3 that are fully resolved, and skip 62"_ is a complete, correct plan.

**Per-item checkpoint (before writing any annotation):** For each file you
classified as ANNOTATE, scan it for numbered action items (prose lists AND
table rows). State your plan per file: _"File X has 23 numbered items: 15
`done at` (verified against git), 3 `Won't implement`, 5 still open."_ This
forces per-item thinking BEFORE you start writing — and makes an
appendix-only annotation impossible to reach for.

### Step 3 — Write specific annotations, not generic ones

Every annotation must be **specific enough that it could only apply to THIS
file.** An annotation that could be pasted unchanged onto any file adds no
value — it is noise.

An annotation that adds value cites concrete evidence:

- A **commit hash** for what shipped (`a7b8159`)
- A **TODO_LIST item ID** for what's still open (`B3`, `A1`)
- A **decision** for rejected work ("SQLViewStore dropped — see ADR 7")

**Never cite line numbers** (`TODO_LIST line 67`). Line numbers rot on the next
edit to the cited file — once you annotate the old doc, any insertion above
your citation shifts it onto the wrong item. Cite **section names** (`TODO_LIST
"v0.2.0 follow-ups"`) or **item text** (`TODO_LIST item "Run real cargo
+nightly fuzz"`). These survive reordering and insertion.

**For multi-item resolutions (5+), prefer a table over prose bullets.** A
table with explicit **Commit** and **Release** columns lets a reader scan
"what shipped and when" in seconds:

```markdown
| Item | Claim in report    | Resolution                               | Commit  | Release |
| ---- | ------------------ | ---------------------------------------- | ------- | ------- |
| §d.1 | Envelope FP bug    | FIXED: reserved-bytes-zero               | fe81dd2 | v0.2.0  |
| §b.3 | Fuzz crate not run | Still open — TODO_LIST "fuzz follow-ups" | —       | —       |
```

Prose bullets are fine for 1–4 items; tables win at 5+. In a table an
open item gets a "Still open" cell — a table has an explicit status column,
so naming the open state there is correct (unlike an inline list, where the
absence of a marker IS the open signal).

See _Annotation placement_ below for WHERE the note goes, and
[./references/annotation-placement.md](./references/annotation-placement.md)
for the full before/after guide.

### Step 4 — The "so what?" test (mandatory, per annotation)

After writing each annotation, re-read it and ask: **"So what? What does a
reader DO with this?"**

| Fails "so what?"                               | Passes "so what?"                                                  |
| ---------------------------------------------- | ------------------------------------------------------------------ |
| "See TODO_LIST.md for current state."          | "Committed as `a7b8159`. Open: embed media worker (TODO_LIST A1)." |
| "✅ Update: this is a point-in-time snapshot." | "Done in `a7b8159`; the reconnect assertion (B4) is still open."   |
| "Items were acted on; see git history."        | "Rejected: SQLViewStore dropped; DM support deferred."             |

If an annotation could apply to ANY file, delete it. If you cannot write
something specific, **leave the file alone.** Unannotated is better than noise.

### Step 5 — Verify output quality, not just process quality

Process quality asks: _"Did the annotation apply cleanly?"_ Output quality
asks: _"Would a skeptical reader who finds this old file benefit from my
annotation?"_ Only the second question matters. Re-read EVERY annotation from
the perspective of a reader who has never seen the file before. Delete any
that do not survive that read.

**Fresh-open test (mandatory):** Open the file as if you've never seen it.
Where do your eyes land first? Is your annotation visible in the first
screenful? If the file has a TL;DR / summary / opening paragraph with stale
claims and your annotation is only at the bottom of the file, **you have
failed this test** — the reader has already formed a wrong impression before
they reach your appendix. Go back and inline-correct the stale opening claims
(see _Annotation placement_ below).

### Step 6 — Archive fully-resolved files (after every item resolves)

When EVERY actionable item in a historical file is resolved — each marked
`done at`, `Won't implement`, or `NOT-DO/DUPLICATE` — AND every stale opening
claim inline-corrected, the file has no live work left. **Move it into an
`archived/` sibling:**

```bash
mkdir -p <dir>/archived
git mv <dir>/<file>.md <dir>/archived/<file>.md
```

Examples:

- `docs/status/2026-06-17_report.md` (all items done) → `docs/status/archived/2026-06-17_report.md`

Rules:

- **`git mv` only, never plain `mv`** — preserve history (per AGENTS.md); create `archived/` first.
- **All actionable items must resolve first.** A file with one open item stays in place (that item is still live) — "almost all done" is not "fully done." A narrative snapshot with no items is not a candidate.
- **Annotate BEFORE archiving** — resolve every item, confirm zero remain, then move. Don't archive on a hunch.
- **Re-runs reach archival this way** — a file with 3 open items last pass may have 0 now; mark them done, then archive (see _Re-runs are productive_ below).

---

## Annotation placement

Old documents are historical artifacts. Where you PUT the annotation matters
as much as what it says.

**Never inject a banner, blockquote, or note between the title and the original
opening paragraph.** That changes the document's character: it becomes a
snapshot with a sticky note slapped on the cover, pushing the original content
down and breaking the structure the original author wrote. Even a _specific_
banner is still a banner.

**If the file has a TL;DR, summary, or opening paragraph with stale claims,
you MUST inline-correct those claims (option 1 below).** An appendix alone is
insufficient: a reader forms their impression from the opening, and if the
opening lies, the appendix is never reached. "Appendix-only" is the
highest-rated failure mode of this skill — do not choose it when the opening
is stale.

In order of preference:

1. **Non-destructive inline edit (BEST)** — correct the stale claim in place. If
   the report says "Nothing committed" and the work is now committed, edit that
   line: `~~Nothing committed.~~ Committed as a7b8159 (2026-07-17).` The reader
   never leaves the flow of the document.

   For a TL;DR / summary with multiple stale claims, place a blockquote update
   immediately AFTER the TL;DR (not inside it, not above it). This is visible
   on open, does not rewrite the original TL;DR, and points the reader to the
   full resolution:

   ```markdown
   > **Update 2026-07-19 (commit `fe81dd2`):** the correctness bug is FIXED,
   > the test gap is closed, the version is bumped. The fuzz crate is still
   > not run. Full item-by-item status in [Resolution](#resolution) below.
   ```

2. **Appendix at the end (GOOD)** — add a clearly marked `## Resolution (date)`
   section at the BOTTOM of the file. The reader finishes the original report,
   then sees the resolution. **Insufficient on its own when the file's opening
   contains load-bearing stale claims** — pair with option 1.
3. **Leave it alone** — if neither an inline edit nor an appendix adds enough
   value, do not annotate.

For before/after examples and the full reasoning, load
[./references/annotation-placement.md](./references/annotation-placement.md).

### Numbered action items (lists AND tables within old reports)

Old status reports and plans often contain numbered items — either as prose
lists (`1. 2. 3.`) or as table rows (`| 1 | | 2 |`) — under headings like
"Things to Do Next", "Open issues", "Next steps". Both forms are the most
common thing a reader wants resolved: _which of these are done now?_ **You must RESOLVE every numbered item** — not just the ones you
already know about. (_Annotate_ = file-level context; _resolve_ = a per-item
verdict — both in one pass.) Each item gets a verdict: `done at <hash>`,
`Won't implement`/`NOT-DO`, or — if still open — **left untouched**, which IS
the "open" verdict (you still CHECK it; never skip the check). Skipping is the
#1 failure mode: 10 marked and 40 never checked is **not annotated**. Mark
completed items **inline** with strike-through + a `done at` marker:

```markdown
1. ~~Fix warmup store pollution — use separate Bundle or document the inflation~~ done at `a7b8159`
2. ~~Fix estimateJSONSize — marshal-and-measure instead of template guess~~ done at `a7b8159`, `fe81dd2`
3. Add negative tests: factory returning nil Bundle, nil EventSink, closed store
4. ~~Add test for Config.Duration actually aborting a long-running phase~~ done at `fe81dd2`
```

**Format:** `~~<original line, unchanged>~~ done at <set-of-short-git-hashes>` (wrap each hash in backticks).
**Variants** (keep wording consistent within a single file):

```text
~~<line>~~ done at `a7b8159`                          # one commit; several: `a7b8159`, `fe81dd2`
~~<line>~~ done (existing rule)                       # already existed; or: done (covered by C019)
~~<line>~~ **Won't implement — <one-line reason>.**   # investigated, decided against
**NOT-DO/DUPLICATE — <line>** <one-line reason>       # subsumed by / duplicates another item
```

Rules for this pattern:

- **Strike through the ENTIRE original line** — the reader must be able to
  identify what the item was. Never replace the text; wrap it in `~~...~~`.
  Keep the original formatting (bold, links) inside the strikethrough.
- **Cite the commit hash(es)** that closed the item. Wrap each hash in backticks; separate multiple with commas (`a7b8159`, or `a7b8159, fe81dd2`).
- **Leave open items untouched** — do not mark them, do not add "OPEN" or
  "TODO" labels. The absence of a `done at` marker IS the signal that the item
  is still open. Adding labels to open items is noise (see anti-patterns).
- **One `done at` per completed item** — never batch multiple items into one annotation.
- **If an item was rejected/abandoned** (closed without shipping), mark it so
  the reader knows it will NOT ship. `Won't implement — <reason>` means you
  investigated and decided against it; `NOT-DO/DUPLICATE` means it overlaps
  another item so it was never separately actioned. Both are distinct from
  `done` — the reader needs to know the item is **closed without shipping**,
  not merely forgotten.
- **Do not renumber.** Keep the original numbering/ordering intact. The
  numbers are how readers cross-reference items across documents.

This pattern is a form of the inline edit (option 1 above) specialized for
list items. It wins over an appendix table here because the resolution lives
right next to the claim — a reader scanning the list sees the status without
context-switching to a separate section.

#### Tables with numbered rows

When the action items are table rows (not a prose list), apply the same
per-item resolution inline. Two patterns:

**Pattern A — strikethrough the resolved cells:**

```markdown
| ~~#~~ | ~~Task~~ | ~~Effort~~ | ~~Evidence~~ |
| ~~1~~ | ~~Run `nix run .#verify`~~ done at `f72c7b40` | ~~5m~~ | ~~Skipped~~ |
| 2 | Add Prometheus alert for orphan files | 15m | TODO_LIST |
```

**Pattern B — add a Status column** (cleaner when most rows are resolved):

```markdown
| # | Task | Status | Evidence |
| 1 | Run `nix run .#verify` | ✅ done `f72c7b40` | — |
| 2 | Add Prometheus alert | Open | TODO_LIST |
```

Use Pattern A when the table already exists and you want minimal structural
change. Use Pattern B when most rows are resolved and a status column makes
the table more scannable. Either way: every numbered row gets a verdict.

---

## Updating many old files at once: judgment before batching

When the set is large, the temptation is a script that stamps the same text on
every file. That is the fastest path to a Verschlimmbesserung. Files are not
identical; their annotations must not be either.

| Approach                       | When it is safe                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------- |
| **Script the mechanical part** | AFTER you hand-decided the per-file list. Script only files you already classified as ANNOTATE |
| **Hand-edit each file**        | When the set is small (<~20), or each annotation is genuinely different                        |
| **Never**                      | A blanket script that reads every file and stamps the same text regardless of content          |

If you write a script, it must operate on your curated list of files — never on
`glob('*')` with a "skip if it doesn't apply" heuristic. The classification
happens in your head, not in an `if`.

### High-volume batches (>15 files): depth over breadth

When the file count is high, resist the urge to annotate all of them
shallowly. A reader opening one file benefits far more from complete inline
resolution (every numbered item checked and marked) than a reader opening
ten files benefits from a 2-sentence appendix on each. **Prioritize: fully
resolve (inline + appendix) the files with the most actionable items first.**
Five files fully resolved inline is a better outcome than 41 files with
appendices and zero inline markers.

## HTML and structured files

Old reports are sometimes HTML dashboards. HTML needs extra care:

- **Structure is fragile.** A naive `txt.find('</div>')` matches the wrong
  closing tag and corrupts the file (this exact bug duplicated a file's body
  1400+ times in the incident that created this skill).
- **CSP matters.** Many projects forbid inline `style=` / `on*=` handlers.
  Adding inline-styled banners violates their security architecture.
- **Read before edit.** Always `view` the structure first. Use `edit` for
  surgical changes, never a batch string-replace script on HTML.

When in doubt, do not script HTML. Edit it by hand with the Edit tool.

## Undoing a mistake: restore, don't re-transform

If you need to remove a batch annotation you just made, the safest path is
`git restore <file>` — NOT a second removal script. A removal script is a
second transformation, and it can introduce its own bugs (this is how the HTML
got corrupted in the source incident). `git restore` returns the file to a
known-good state with no chance of a new mistake.

> Note: per project AGENTS.md, never `git restore` files you did not personally
> change in this session. This rule is about undoing YOUR OWN batch annotation
> only.

---

## Edge cases

### The exception: when a uniform stamp IS correct

This skill is about annotating OLD documents with RESOLUTION information, where
each file's resolution differs. A different task is adding a truly uniform
preamble to every file (license headers, confidentiality notices, "generated by
X" markers). There, the content genuinely IS identical across files, and a
scripted stamp is correct. The distinction: if every file should receive the
same text, batch away — but that is not what this skill covers.

### Generated and locked files

Never annotate machine-generated output (`*.gen.go`, `*_stringer.go`, rendered
diagrams, vendored copies). These are regenerated from source; an annotation
would be erased on the next generation. If a generated file is stale, the fix
is to regenerate it, not to annotate it.

### Re-runs are productive, not no-ops

A file you annotated last week is not frozen. Work has happened since: items that were open are now done, a spike was rejected. **Re-running this skill over a previously-annotated file is expected and correct** — the job is to bring it current, not to skip it.

The rule is per-item, not per-file:

- **Already-resolved item → leave untouched.** Do not re-stamp, re-word, or "upgrade" a correct `done at` / `Won't implement` marker. Re-stamping is a double-stamp.
- **Open item now resolved → mark it** as `done at <set-of-short-git-hashes>` (or the rejected form) exactly as on a first pass.
- **Same-date appendix already exists → don't add a second.** Use a new date (`## Resolution (2026-07-30)`) if warranted.

Every previously-open item must be re-checked against current commits — assume it may have shipped since, because it often has. When a file reaches zero open items, it graduates to ARCHIVE.

---

## Verification gate (before declaring done)

- [ ] **Scope was confirmed before any file was touched.** If the user did not specify a time frame or file set, you asked and waited — you did not guess the broadest interpretation.
- [ ] For EVERY annotation: does it pass the "so what?" test? Delete any that do not.
- [ ] **Fresh-open test:** every file with a stale TL;DR / opening has an inline correction visible in the first screenful.
- [ ] Count the files you LEFT UNTOUCHED. That number being > 0 is correct and expected.
- [ ] For list items marked `done at` — the entire original line is struck through, at least one commit hash is cited, and open items are left untouched (no noise labels).
- [ ] **No appendix-only annotations:** every file with numbered action items has at least one inline `done at` / `Won't implement` marker, OR a stated reason why zero items resolved ("all 30 items are still open" is valid; silently writing an appendix instead is not).
- [ ] **Completeness gate:** every numbered action item in the file was checked against current state. An item you didn't check is an item you silently abandoned. A file with un-checked items is not annotated.
- [ ] **Re-run check:** every previously-open item was re-checked against current commits; items already marked were left untouched (no double-stamping).
- [ ] **Archive check:** every file whose actionable items are ALL resolved was moved to `<dir>/archived/<file-name>` via `git mv`; files with any open item were left in place.
- [ ] No annotation is generic — each could only apply to its own file.
- [ ] No annotation cites line numbers in other files (cite section names or item text).
- [ ] No annotation sits between a title and the original opening paragraph.
- [ ] If you scripted, the script ran only on your curated list, not a blanket glob.
- [ ] No inline styles / handlers were added to CSP-compliant HTML.
- [ ] **Run the project's quality gate. Mandatory, not optional.** Detect the
      build system and run the canonical command (`nix flake check`,
      `cargo test`, `npm test`, `scripts/check-skills.sh`, etc.). If the
      project has no detectable build system, state that explicitly — do not
      skip silently. Annotation edits can break builds (malformed markdown,
      broken anchors, CSP violations in HTML).
- [ ] Run `git status` and verify every claim in your closing message about
      working-tree state ("N files staged", "no commit made") is true. Never
      describe working-tree state without a fresh `git status`.

## Anti-patterns (do not do these)

- Stamping the same "✅ Update" banner on every old file because the task said "all"
- Generic "see TODO_LIST.md / CHANGELOG.md for current state" with no specifics
- An annotation that could be pasted unchanged onto any file in the set
- Injecting a banner/blockquote between a title and the opening paragraph
- Writing a blanket script and hoping a per-file `if` catches the edge cases
- Modifying HTML with inline styles in CSP-compliant projects
- Treating "files modified" as the success metric instead of "value per annotation"
- **Proceeding on an unspecified scope** — "update the old reports" without a time range is ambiguous; guessing "all of them" maximizes blast radius. Ask first.
- Removing a batch annotation with a script instead of `git restore`
- **Silently skipping numbered items** — the #1 failure mode: marking the items you know about and declaring the file done while dozens remain un-checked. Every numbered item must be resolved (done / rejected / left-open-intentionally).
- **Appendix-only on a file with numbered items** — writing a `## Resolution` section at the bottom while leaving every numbered item in the body unmarked. The reader scans the list, sees no `done at` markers, and assumes everything is still open. Inline resolution is the primary work; the appendix is supplementary context.
- **Marking open list items with "OPEN"/"TODO" labels** — absence of a `done at` marker is the signal; adding labels to open items is noise
- **Re-stamping an already-resolved item** — a `done at` / `Won't implement` marker that is already correct must be left untouched on re-run; re-wording it is a double-stamp
- **Archiving a file that still has open items** — only files where ALL actionable items are resolved move to `archived/`
- **Renumbering a list after striking items through** — destroys cross-references; keep original order
- **Rewriting an old document from scratch** — that destroys history; use docs-health for living docs instead

---

## Background

This skill was distilled from a real incident: a session stamped 58 identical
generic banners across old status reports (and inline-styled banners into 4
HTML dashboards), then corrupted the HTML while trying to remove them. The user
called it a Verschlimmbesserung and was right. The full case study — root-cause
analysis, the two rounds of feedback (generic banners, then the banner-vs-appendix
preference), and the exact prompts — is in
[./references/case-study.md](./references/case-study.md). Read it when you want
to understand WHY every rule above exists, not just WHAT it says.
