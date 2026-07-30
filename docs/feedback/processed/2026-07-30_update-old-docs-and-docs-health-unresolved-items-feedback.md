# Feedback: update-old-docs + docs-health — 1,688 Unresolved Items Across 42 "Done" Files

**Date:** 2026-07-30
**Session:** SystemNix docs-health + update-old-docs pass (76 historical files, Jul 2026)
**Skills involved:** `update-old-docs`, `docs-health`
**Severity:** High — the user had to intervene twice to get what they wanted

---

## What Went Wrong

### The core failure: list-item resolution was treated as optional

The update-old-docs skill describes the `~~<original>~~ DONE: <hash>;` pattern in a section titled **"Lists of actionable items (TODO lists within old reports)"**. It's presented as ONE annotation technique among several (alongside inline edits and appendix notes). It reads as "here's a nice pattern you can use for lists" — **not** as "every numbered action item in the file MUST be resolved before you're done."

**What happened:** I annotated stale opening claims (inline corrections) and appended resolution summaries, then declared the files "annotated" and moved them to `archived/`. But **1,688 numbered action items across 42 files had zero resolution markers** — not a single `DONE:`, `REJECTED:`, or `OPEN:`. The user had to explicitly point this out by showing a reference file (`IMPROVEMENT_IDEAS.md`) and asking whether the TODOs were resolved.

### Contributing failure: archiving was disconnected from item resolution

The user asked to "move fully-done files to `archived/`." I moved 75 files based on whether the **report's core work** was done (the bug was fixed, the deploy happened). But I never checked whether every numbered TODO/NEXT item in those files was individually resolved. The skills don't establish that "all items resolved" is a **prerequisite** for archiving.

### Contributing failure: appendix-only annotations where the opening is stale

The skill explicitly calls appendix-only annotation **"the highest-rated failure mode."** I read this rule, understood it, and then violated it on ~8 files because batch-appending was faster than finding each file's exact opening text. The skill warns about the failure but has no **hard gate** that forces a check.

### Contributing failure: sub-agent reads lost context

I used sub-agents to read all 76 files. The summaries were accurate but paraphrased — they lost the exact opening text needed for inline edits and didn't surface the numbered-item completeness gap. The skill says "read every file before touching any" but doesn't say "read them yourself, don't delegate."

---

## What the User Actually Wanted

The user's mental model (clarified through intervention):

1. **Read every historical file** ✓ (I did this)
2. **Annotate stale openings** ✓ (I did this for ~24 files)
3. **Resolve EVERY numbered action item** in each file — mark each as `~~DONE: <hash>;`, `~~REJECTED: <reason>;`, or `OPEN: in TODO_LIST "<section>"` ✗ (I skipped this entirely — 1,688 items)
4. **Move fully-done files to `archived/`** — but ONLY after step 3 is complete for every item ✗ (I archived before resolving items)
5. **Rebuild living docs** ✓ (I did this well)

The user expected steps 2+3 to be **one atomic operation per file**, not two separate passes. The skills describe them as separate techniques, which is why I treated them as independent.

---

## Suggestions for Skill Improvement

### 1. Make list-item resolution MANDATORY, not optional (update-old-docs)

**Current state:** The `~~DONE: <hash>;` pattern is in a subsection under "Annotation placement," presented as one option alongside inline edits and appendices.

**Suggested change:** Promote it to a **hard requirement** in the main workflow. Add to Step 2 (Classify each target):

> Before classifying a file as ANNOTATE or SKIP, you MUST resolve every numbered action item in its NEXT/TODO/"NOT STARTED" sections. "Resolve" means marking each item as:
>
> - `~~<original line>~~ DONE: <commit-hash>;` — shipped
> - `~~<original line>~~ REJECTED: <one-line reason>;` — intentionally not pursued
> - `~~<original line>~~ OPEN: tracked in TODO_LIST "<section>";` — still open, harvested into living docs
>
> A file is NOT "annotated" until every numbered item has one of these three markers. A file with 50 "NEXT" items and only an appendix resolution summary is **not annotated** — it is **partially annotated**.
>
> For files with 5+ items, a **resolution table** at the end is acceptable IN ADDITION TO (not instead of) per-item markers if the items are too numerous to strike through individually. But every item must appear in the table with a status column.

### 2. Add a "Completeness Gate" verification step (update-old-docs)

**Suggested addition** to the Verification Gate section:

> - [ ] **Every numbered action item is resolved.** Before declaring a file annotated, scan for any section containing numbered lists of tasks/next-steps/TODOs. Every item must have a `DONE:`/`REJECTED:`/`OPEN:` marker or appear in a resolution table. Run: `sed -n '/## .*NEXT\|## .*TODO\|NOT STARTED/,$ p' <file> | grep -c '^\s*[0-9]\+\.'` — if the count of un-marked items > 0, the file is NOT done.
> - [ ] **No file is archived with unresolved items.** Moving a file to `archived/` requires ALL numbered items resolved first. Archiving a file with 50 unresolved TODO items is a failure — the archive implies "this is finished history" but the items are silently abandoned.

### 3. Define "archive-readiness" as a concept (update-old-docs + docs-health)

**Current state:** Neither skill defines when a historical file is "archive-ready." The user's request to "move done files to archived/" was interpreted as "the report's core work is done" rather than "every item in the report is resolved."

**Suggested addition** (shared concept, referenced by both skills):

> **Archive-readiness:** A historical file is archive-ready when:
>
> 1. Every numbered action item has a `DONE:`/`REJECTED:`/`OPEN:` resolution
> 2. Every stale opening claim has been inline-corrected
> 3. The file has a `## Item Resolution (<date>)` section (or equivalent)
>
> Moving a file to `archived/` that is not archive-ready is a Verschlimmbesserung — it signals "this is finished" while silently abandoning unresolved work.

### 4. Make the opening-claim check a hard gate, not advice (update-old-docs)

**Current state:** "Appendix-only is insufficient when the file's opening contains load-bearing stale claims" is explained in prose under "Annotation placement."

**Suggested change:** Add a **hard gate** in the Verification Gate:

> - [ ] **Fresh-open test (MANDATORY):** Open the file. Read ONLY the first 10 lines (the TL;DR / Verdict / Outcome / Status). Does any claim there contradict current reality? If YES, you MUST inline-correct it (strikethrough + resolution). An appendix-only annotation on a file with a stale opening is a FAILED annotation, not a partial one. Re-do it.

### 5. Forbid sub-agent delegation for the final annotation pass (update-old-docs)

**Current state:** The skill says "Read every old file before touching any" and "Use sub-agents to parallelize the reads when there are many."

**Suggested change:** Clarify that sub-agents are for the **classification pass** only. The **annotation pass** (writing the actual `DONE:`/`REJECTED:` markers, inline corrections) must be done by the primary agent who has read the full file text, not a paraphrased summary.

> Sub-agents may **classify** files (ANNOTATE/SKIP/LEAVE_ALONE) and extract item lists. But the **annotation itself** — writing `DONE:` markers, inline-correcting stale claims, appending resolution tables — must be done by the primary agent after reading the actual file. Sub-agent summaries paraphrase, losing the exact text needed for precise inline edits.

### 6. Add "item resolution" to HARVEST in docs-health

**Current state:** HARVEST extracts forward-looking items from reports and routes them to TODO_LIST/ROADMAP. But it doesn't check whether the report's items have ALREADY been resolved.

**Suggested change:** Add to HARVEST process:

> Before extracting items, check whether the report already has an `## Item Resolution` section or per-item `DONE:`/`REJECTED:` markers. If items are already resolved, they are NOT harvested — they belong in CHANGELOG, not TODO_LIST. Only `OPEN:` items should be harvested.

### 7. Add a cross-skill checklist for "annotate + archive" combined workflows

When the user asks to both annotate AND archive in one pass (as happened here), neither skill alone covers the full workflow. A combined checklist:

> **When annotating AND archiving historical files in one pass:**
>
> 1. Read every file (classify: ANNOTATE / SKIP / LEAVE_ALONE)
> 2. For each ANNOTATE file: resolve EVERY numbered item (`DONE:`/`REJECTED:`/`OPEN:`)
> 3. For each ANNOTATE file: inline-correct stale opening claims
> 4. For each ANNOTATE file: append `## Item Resolution` section
> 5. Verify: zero un-resolved numbered items remain
> 6. ONLY NOW: move archive-ready files to `archived/`
> 7. Run `grep -c '^\s*[0-9]\+\.' <file>` on each archived file — confirm all items have resolution markers

---

## Summary: The Gap Between Skill Text and User Expectation

The skills describe **techniques** (inline edit, appendix, list-item strikethrough) but don't establish **completeness requirements** (every item must be resolved). The user's expectation is:

> "If you're annotating a file as 'done,' then EVERY TODO in it must be marked as done, rejected, or still-open. If you're archiving it, it must be FULLY resolved first."

The skills need to make this expectation **explicit and enforced via checklist gates**, not implied by the description of a pattern.

---

## Concrete Example of the Failure

A status report has:

```
## f) NEXT — UP TO 50 THINGS
1. Deploy the fix
2. Add monitoring
3. Write regression test
...
50. Consider refactoring X
```

**What I did (WRONG):**

- Appended `## Resolution (2026-07-30): All items resolved in commit abc123.`
- Archived the file

**What the user wanted (RIGHT):**

```
## f) NEXT — UP TO 50 THINGS
1. ~~Deploy the fix~~ DONE: abc123;
2. ~~Add monitoring~~ DONE: def456;
3. ~~Write regression test~~ REJECTED: no test infrastructure;
...
50. ~~Consider refactoring X~~ REJECTED: not worth the effort;
```

OR a resolution table:

```
## Item Resolution (2026-07-30)

| # | Status | Resolution |
|---|--------|------------|
| 1 | DONE | abc123 |
| 2 | DONE | def456 |
| 3 | REJECTED | No test infrastructure |
...
| 50 | REJECTED | Not worth the effort |
```

The difference: **every single item** has an explicit status. No silent abandonment.

---

## Addendum: Terminology — "Annotate" vs "Resolve"

The skill uses "annotate" as the universal verb for touching old files. This is misleading. There are two distinct operations:

1. **Annotate** — add context notes to a file (inline corrections, appendix resolutions). The file's content is enriched but its items are not closed.
2. **Resolve** — close every numbered action item with a definitive verdict (`DONE: <hash>;`, `REJECTED: <reason>;`, `OPEN: tracked in <doc>`). The items are answered, not just noted.

"Annotate" implies "add notes." A reader hearing "I annotated 24 files" assumes notes were added — not that 1,688 items were resolved. The skill should use **"resolve"** for item-level work and **"annotate"** for file-level context work. The todo items in the agent's task list should say "Resolve TODO items" not "Annotate TODO items."
