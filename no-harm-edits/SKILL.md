---
name: no-harm-edits
description: >
  Prevents Verschlimmbesserung — well-intentioned batch edits that make the
  codebase or docs WORSE. Apply whenever a task asks to modify, annotate,
  label, banner, stamp, or transform MANY files or items at once: "update all
  the status reports", "annotate every file", "add a header/banner to all
  docs", "stamp a note on each report", "batch update", "refactor all the
  handlers", "add X to every file", "mark each report as done", "add a license
  preamble to every source file". Enforces restraint ("all" does NOT mean
  every file must change), per-item judgment over blanket scripts, the
  "so what?" value test, and non-destructive annotation (appendix or inline
  edits, never intrusive top-of-file banners). Use BEFORE any bulk or
  multi-file transformation to avoid generating noise, duplication, or
  misleading content that the user has to roll back.
metadata:
  tags: editing, restraint, batch, annotation, anti-patterns, quality, verification, verschlimmbesserung
---

# No-Harm Edits

_Edit at scale without making things worse._

A **Verschlimmbesserung** is an improvement that makes things worse. Multi-file
editing tasks — "annotate all reports", "add a banner to every status file",
"refactor all the handlers" — are the single most reliable way to produce one.
The failure mode is always the same: optimize for "touched every file" instead
of "every change helped", and you ship 58 identical banners that say nothing
and have to be rolled back.

The rest of this skill is how to avoid that. READ, UNDERSTAND, RESEARCH,
REFLECT before every action — then edit with restraint.

## Core principle: restraint is success

**"Update all the files" means "no file that NEEDS updating is missed." It does
NOT mean "every file gets a change."** A doctor does not operate on every
patient in the waiting room just because the instruction said "see all
patients."

Leaving a file untouched because it is already clear, already correct, or
because no change would add value is the CORRECT outcome — not a failure.
Measure success by **value added per change**, not by **files touched**. The
number of files you left untouched is a metric of good judgment, not of laziness.

## When this applies

Activate before any task that transforms, annotates, or modifies a SET of
existing files or items:

- "annotate/update all the `*2026-07-1*` status reports"
- "add a resolution banner to each report"
- "stamp a 'done' note on every file in `docs/status/`"
- "add a header/preamble to all the markdown / source files"
- "refactor all the handlers to the new signature"
- "mark each TODO as complete in the reports"

If the task touches ONE file, this skill does not apply — just edit it well.
The danger is **scale**: scale rewards batching, and batching rewards skipping
judgment.

---

## The workflow

### Step 1 — Read everything before touching anything

Before modifying a single file, read and understand EVERY target. Use
sub-agents to parallelize the reads when there are many. Do not annotate,
edit, or write any script until you can answer for each file: _what does it
currently say, and what does it currently lack?_

This is non-negotiable. The Verschlimmbesserung happens when you decide the
transformation before understanding the targets.

### Step 2 — Classify each target (per-item judgment)

For every file, make exactly ONE of three decisions:

| Decision        | Apply when                                                                                         |
| --------------- | -------------------------------------------------------------------------------------------------- |
| **CHANGE**      | A reader/viewer of this file would clearly benefit, and the value is NOT already present in it     |
| **SKIP**        | The file is already clear — it has its own resolution section, status table, correct content       |
| **LEAVE ALONE** | The file describes rejected / deferred / abandoned work where a "this was done" note would mislead |

Record this list. The list IS the plan. _"I will change 24 of the 89 files and
skip 65"_ is a complete, correct plan.

### Step 3 — Write specific changes, not generic ones

Every change must be **specific enough that it could only apply to THIS file.**
A change that could be pasted unchanged onto any file in the set adds no value —
it is noise. See _Annotation placement_ below for where doc annotations go, and
[./references/annotation-placement.md](./references/annotation-placement.md) for
the full before/after guide.

### Step 4 — The "so what?" test (mandatory, per change)

After writing each change, re-read it and ask: **"So what? What does a reader
DO with this?"**

| Fails "so what?"                               | Passes "so what?"                                                  |
| ---------------------------------------------- | ------------------------------------------------------------------ |
| "See TODO_LIST.md for current state."          | "Committed as `a7b8159`. Open: embed media worker (TODO_LIST A1)." |
| "✅ Update: this is a point-in-time snapshot." | "Done in `a7b8159`; the reconnect assertion (B4) is still open."   |
| "Items were acted on; see git history."        | "Rejected: SQLViewStore dropped; DM support deferred."             |

If a change could apply to ANY file, delete it. If you cannot write something
specific, **leave the file alone.** Unannotated is better than noise.

### Step 5 — Verify output quality, not just process quality

Process quality asks: _"Did the change apply cleanly?"_ Output quality asks:
_"Would a skeptical reader who finds this old file benefit from my change?"_
Only the second question matters. Re-read EVERY change from the perspective of
a reader who has never seen the file before. Delete any change that does not
survive that read.

---

## Annotation placement

When the change is a note/annotation on a historical document (status report,
review, plan), where you PUT it matters as much as what it says.

**Never inject a banner, blockquote, or note between the title and the original
opening paragraph.** Status reports are historical artifacts — they capture
what someone knew at a point in time. A banner on top changes the document's
character: it is a snapshot with a sticky note slapped on the cover, pushing
the original content down and breaking the structure. Even a _specific_ banner
is still a banner.

In order of preference:

1. **Non-destructive inline edit (BEST)** — update the stale claim in place. If
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

## Batch scripts: judgment before batching, never instead of it

A script that applies the SAME transformation to every file is the fastest path
to a Verschlimmbesserung. Files are not identical; their changes must not be
either.

| Approach                       | When it is safe                                                                              |
| ------------------------------ | -------------------------------------------------------------------------------------------- |
| **Script the mechanical part** | AFTER you hand-decided the per-file list. Script only files you already classified as CHANGE |
| **Hand-edit each file**        | When the set is small (<~20), or each change is genuinely different                          |
| **Never**                      | A blanket script that reads every file and stamps the same text regardless of content        |

If you write a script, it must operate on your curated list of files — never on
`glob('*')` with a "skip if it doesn't apply" heuristic. The classification
happens in your head, not in an `if`.

## HTML and structured files

HTML (and any structured format — JSON, YAML, templ) needs extra care:

- **Structure is fragile.** A naive `txt.find('</div>')` matches the wrong
  closing tag and corrupts the file (this exact bug duplicated a file's body
  1400+ times in the incident that created this skill).
- **CSP matters.** Many projects forbid inline `style=` / `on*=` handlers.
  Adding inline-styled banners violates their security architecture.
- **Read before edit.** Always `view` the structure first. Use `edit` for
  surgical changes, never a batch string-replace script on HTML.

When in doubt, do not script HTML. Edit it by hand with the Edit tool.

## Undoing a mistake: restore, don't re-transform

If you need to remove a batch edit you just made, the safest path is
`git restore <file>` (or `git restore --source HEAD~1 <file>` if already
committed) — NOT a second removal script. A removal script is a second
transformation, and it can introduce its own bugs. `git restore` returns the
file to a known-good state with no chance of a new mistake.

> Note: per project AGENTS.md, never `git restore` files you did not personally
> change in this session. This rule is about undoing YOUR OWN batch edit only.

---

## Verification gate (before declaring done)

- [ ] For EVERY change: does it pass the "so what?" test? Delete any that do not.
- [ ] Count the files you LEFT UNTOUCHED. That number being > 0 is correct and expected.
- [ ] No change is generic — each could only apply to its own file.
- [ ] No annotation sits between a title and the original opening paragraph.
- [ ] If you scripted, the script ran only on your curated list, not a blanket glob.
- [ ] No inline styles / handlers were added to CSP-compliant HTML.
- [ ] Run the project's quality gate (`nix run .#quality`, `scripts/check-skills.sh`, etc.).

## Anti-patterns (do not do these)

- Stamping the same "✅ Update" banner on every file because the task said "all"
- Generic "see TODO_LIST.md / CHANGELOG.md for current state" with no specifics
- A change that could be pasted unchanged onto any file in the set
- Injecting a banner/blockquote between a title and the opening paragraph
- Writing a blanket script and hoping a per-file `if` catches the edge cases
- Modifying HTML with inline styles in CSP-compliant projects
- Treating "files modified" as the success metric instead of "value per change"
- Removing a batch edit with a script instead of `git restore`

---

## Background

This skill was distilled from a real incident: a session stamped 58 identical
generic banners across status reports (and inline-styled banners into 4 HTML
dashboards), then corrupted the HTML while trying to remove them. The user
called it a Verschlimmbesserung and was right. The full case study — root-cause
analysis, the two rounds of feedback (generic banners, then the banner-vs-appendix
preference), and the exact prompts — is in
[./references/case-study.md](./references/case-study.md). Read it when you want
to understand WHY every rule above exists, not just WHAT it says.

Related skills: [`docs-health`](../docs-health/SKILL.md) (whose AUDIT mode can
trigger bulk annotation), [`full-code-review`](../full-code-review/SKILL.md),
[`naming-review`](../naming-review/SKILL.md), [`deduplicate-code`](../deduplicate-code/SKILL.md)
— any skill that modifies many files should defer to this one for the
edit-at-scale discipline.
