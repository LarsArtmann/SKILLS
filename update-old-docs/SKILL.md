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
  tags: documentation, annotation, historical, status-reports, freshness, restraint, non-destructive, anti-patterns
---

# Update Old Docs

_Keep old documents current without destroying their history._

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

If the task is about maintaining a **living** doc (rewriting `README.md`,
rebuilding `FEATURES.md`, refreshing `TODO_LIST.md`), that is `docs-health`,
not this skill. The distinction: **living docs get rewritten; old docs get
annotated.**

---

## The workflow

### Step 1 — Read everything before touching anything

Before annotating a single file, read and understand EVERY target. Use
sub-agents to parallelize the reads when there are many. Do not annotate or
write any script until you can answer for each file: _what does it currently
say, and what does it currently lack?_

This is non-negotiable. The Verschlimmbesserung happens when you decide the
annotation before understanding the targets.

### Step 2 — Classify each target (per-file judgment)

For every file, make exactly ONE of three decisions:

| Decision        | Apply when                                                                                         |
| --------------- | -------------------------------------------------------------------------------------------------- |
| **ANNOTATE**    | A reader of this old file would clearly benefit, and the value is NOT already present in it        |
| **SKIP**        | The file is already clear — it has its own resolution section, status table, or correct content    |
| **LEAVE ALONE** | The file describes rejected / deferred / abandoned work where a "this was done" note would mislead |

Record this list. The list IS the plan. _"I will annotate 24 of the 89 files
and skip 65"_ is a complete, correct plan.

### Step 3 — Write specific annotations, not generic ones

Every annotation must be **specific enough that it could only apply to THIS
file.** An annotation that could be pasted unchanged onto any file adds no
value — it is noise.

An annotation that adds value cites concrete evidence:

- A **commit hash** for what shipped (`a7b8159`)
- A **TODO_LIST item ID** for what's still open (`B3`, `A1`)
- A **decision** for rejected work ("SQLViewStore dropped — see ADR 7")

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

---

## Annotation placement

Old documents are historical artifacts. Where you PUT the annotation matters
as much as what it says.

**Never inject a banner, blockquote, or note between the title and the original
opening paragraph.** That changes the document's character: it becomes a
snapshot with a sticky note slapped on the cover, pushing the original content
down and breaking the structure the original author wrote. Even a _specific_
banner is still a banner.

In order of preference:

1. **Non-destructive inline edit (BEST)** — correct the stale claim in place. If
   the report says "Nothing committed" and the work is now committed, edit that
   line: `~~Nothing committed.~~ Committed as a7b8159 (2026-07-17).` The reader
   never leaves the flow of the document.
2. **Appendix at the end (GOOD)** — add a clearly marked `## Resolution (date)`
   section at the BOTTOM of the file. The reader finishes the original report,
   then sees the resolution.
3. **Leave it alone** — if neither an inline edit nor an appendix adds enough
   value, do not annotate.

For before/after examples and the full reasoning, load
[./references/annotation-placement.md](./references/annotation-placement.md).

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

## Verification gate (before declaring done)

- [ ] For EVERY annotation: does it pass the "so what?" test? Delete any that do not.
- [ ] Count the files you LEFT UNTOUCHED. That number being > 0 is correct and expected.
- [ ] No annotation is generic — each could only apply to its own file.
- [ ] No annotation sits between a title and the original opening paragraph.
- [ ] If you scripted, the script ran only on your curated list, not a blanket glob.
- [ ] No inline styles / handlers were added to CSP-compliant HTML.
- [ ] Run the project's quality gate (`nix run .#quality`, `scripts/check-skills.sh`, `make test`, etc.).

## Anti-patterns (do not do these)

- Stamping the same "✅ Update" banner on every old file because the task said "all"
- Generic "see TODO_LIST.md / CHANGELOG.md for current state" with no specifics
- An annotation that could be pasted unchanged onto any file in the set
- Injecting a banner/blockquote between a title and the opening paragraph
- Writing a blanket script and hoping a per-file `if` catches the edge cases
- Modifying HTML with inline styles in CSP-compliant projects
- Treating "files modified" as the success metric instead of "value per annotation"
- Removing a batch annotation with a script instead of `git restore`
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
