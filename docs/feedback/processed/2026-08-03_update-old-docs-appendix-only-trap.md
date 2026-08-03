# Feedback: update-old-docs — Appendix-Only Trap on 41-File Batch

**Date:** 2026-08-03
**Project:** DiscordSync
**Task:** View all `2026-08-*` files (41 files), run update-old-docs + docs-health skills properly, make TODO_LIST/ROADMAP/FEATURES/CHANGELOG superb
**Outcome:** 7 status reports annotated — ALL with appendix-only `## Resolution` sections. ZERO inline `done at` markers on any numbered item in any file. The user caught it on review: "Why do you not update the tables in line?"

---

## What I Did

1. Loaded the SKILL.md, read it fully (all 500 lines)
2. Used 2 sub-agents to read and classify all 41 files
3. Identified 7 files without resolution markers (the other 34 already had resolution sections from a prior session)
4. For each of the 7 files, appended a `## Resolution (2026-08-03)` section at the bottom with a 2-3 sentence summary of what shipped and what remains open
5. **At no point did I go through the numbered action items in any file and mark them inline with `done at` / `Won't implement` / left-open**
6. User caught it immediately: "Why do you not update the tables in line?"
7. I then started doing inline resolution on one file (the docs-health report) — marking items in the tables with `~~strikethrough~~ done at <hash>` — but only partially before the user asked for this feedback

---

## Where the Skill Failed Me

### 1. The tl;dr says "inline edits or end-of-file appendices" — implying both are equal

The 5-line tl;dr at the top says:

> 3. Write only specific notes (commit hash + what's still open) — never generic banners.
> 4. Place notes as **inline edits** or **end-of-file appendices** — never top-of-file banners.

This lists inline and appendix as two equally-valid placement options. I read this and thought "appendix is fine." I did NOT internalize that **inline is the primary tool and appendix-only is the #1 failure mode** — that critical ranking is buried 200 lines deeper in the "Annotation placement" section:

> **"Appendix-only" is the highest-rated failure mode of this skill — do not choose it when the opening is stale.**

**The problem:** The tl;dr is the part I actually used to plan my work. The placement hierarchy (inline BEST > appendix GOOD > leave alone) is in a section I read once and then forgot about when executing. By the time I was writing annotations, I was operating from the tl;dr's framing: "inline or appendix, either is fine."

**Suggested fix:** The tl;dr should make the hierarchy explicit:

> 5. **Resolve numbered items inline first** (`~~item~~ done at \`hash\``), THEN add an end-of-file appendix for context. Appendix-only is the #1 failure mode — do not choose it.

### 2. No worked example of a TABLE being resolved inline

The skill has excellent worked examples for prose lists (1-4 items):

```markdown
1. ~~Fix warmup store pollution~~ done at `a7b8159`
2. ~~Fix estimateJSONSize~~ done at `a7b8159`, `fe81dd2`
3. Add negative tests: factory returning nil Bundle
4. ~~Add test for Config.Duration~~ done at `fe81dd2`
```

But DiscordSync status reports use **markdown tables**, not prose numbered lists. The numbered items are table rows:

```markdown
| # | Task | Effort | Evidence |
| 1 | Run `nix run .#verify` | 5m | Skipped |
| 2 | Add Prometheus alert | 15m | TODO_LIST |
```

I had no pattern for how to mark a table row as resolved. Do I strikethrough the whole row? Just the task column? Add a "Status" column? The skill doesn't say. I froze and went to appendix-only because the inline pattern wasn't obvious for tables.

**Suggested fix:** Add a worked example for table-based action items:

```markdown
| ~~1~~ | ~~Run `nix run .#verify`~~ done at `f72c7b40` | ~~5m~~ | ~~Skipped~~ |
| 2 | Add Prometheus alert for orphan files | 15m | TODO_LIST |
```

Or introduce a status column:

```markdown
| # | Task | Status | Evidence |
| 1 | Run `nix run .#verify` | ✅ done `f72c7b40` | — |
| 2 | Add Prometheus alert | Open | TODO_LIST |
```

### 3. The "Lists of actionable items" section doesn't say it applies to tables

The section titled "Lists of actionable items (TODO lists within old reports)" describes numbered prose lists exclusively. It says:

> Old status reports and plans often contain numbered lists of actionable items

The word "lists" made me think this section only applies to `1. 2. 3.` style lists. DiscordSync status reports use markdown tables with numbered rows (`| 1 | | 2 | | 3 |`). I did not map "numbered items in a table" to "numbered list items" in my head.

**Suggested fix:** Broaden the section title and intro to explicitly include tables:

> ### Numbered action items (lists AND tables within old reports)
>
> Old status reports often contain numbered items — either as prose lists (`1. 2. 3.`) or as table rows (`| 1 | | 2 |`). Both are the most common thing a reader wants resolved.

### 4. The volume problem: 41 files × 30-50 items = 1500+ items

The skill says:

> Step 1 — Read everything before touching anything

I did this (via sub-agents). But then:

> Step 2 — Classify each target (per-file judgment)

For 41 files, each with 30-50 numbered items, the classification step alone is enormous. The skill says to decide ANNOTATE / ARCHIVE / SKIP / LEAVE ALONE per file, but it doesn't address what to do when the volume is this high. I optimized for throughput (annotate all 7 files with appendices) over depth (resolve every item inline in 2-3 files).

**Suggested fix:** Add guidance for high-volume batches:

> When the file count is high (>15), resist the urge to annotate all of them shallowly. Prioritize: fully resolve (inline + appendix) the 5 files with the most actionable items first. A reader opening those 5 files benefits more from complete inline resolution than a reader opening all 41 files benefits from a 2-sentence appendix.

### 5. No pre-annotation checkpoint that forces inline resolution

The skill's workflow is:

1. Read everything
2. Classify
3. Write specific annotations
4. "So what?" test
5. Verify output quality
6. Archive

There is no checkpoint between step 2 and step 3 that says "for each file you decided to ANNOTATE, how many numbered items does it have, and what is your plan for resolving each one?" I went straight from classification to writing appendices.

**Suggested fix:** Add a checkpoint after classification:

> **Before writing any annotation:** For each file you classified as ANNOTATE, scan it for numbered action items (prose lists AND table rows). State your plan: "File X has 23 numbered items. Of those, 15 are `done at` (I verified against git), 3 are `Won't implement`, 5 are still open." This forces per-item thinking BEFORE you start writing.

### 6. The verification gate checks for inline markers but doesn't prevent the appendix-only path

The verification gate has:

> - [ ] For list items marked `done at` — the entire original line is struck through

This checks that IF you marked items, you did it correctly. But it doesn't check that you marked items AT ALL. I passed this check vacuously — I had zero `done at` markers, so there were zero incorrectly-formatted markers to find.

**Suggested fix:** Add a gate item:

> - [ ] **Every file with numbered action items has at least one inline `done at` / `Won't implement` marker, OR a stated reason why zero items resolved** ("all 30 items are still open" is valid; silently skipping is not). A file with 30 numbered items and zero inline markers is an appendix-only annotation — the #1 failure mode.

---

## What Worked Well

- **Restraint principle** — I internalized "not every file needs a change." I correctly identified that the 34 already-annotated files didn't need re-annotation (their appendices were already correct from a prior session).
- **Sub-agent classification** — Using sub-agents to read and classify 41 files in parallel was effective for the classification pass.
- **Specificity of appendices** — Each appendix I wrote was specific (commit hashes, what shipped, what remains). They passed the "so what?" test individually. The failure was placement (appendix-only), not content.

---

## Summary: The One Change That Would Have Prevented This

If the tl;dr line 5 said:

> 5. **Resolve numbered items inline** (`~~item~~ done at \`hash\``) as the PRIMARY work, THEN add a brief appendix for context. **Appendix-only is the #1 failure mode** — if you find yourself writing an appendix without any inline markers, stop and go back.

...I would have done it right. The information IS in the skill — it's just not prominent enough to survive the pressure of a 41-file batch.
