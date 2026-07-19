# Feedback: update-old-docs Skill — Buried Annotations, Missing Format Guidance

**Date:** 2026-07-19
**Project:** segment-buffer
**Skill:** `update-old-docs`
**Severity:** Medium — user had to explicitly tell me the annotations weren't visible, then had to specify the format they wanted
**Trigger prompt:** "update-old-docs AND docs-health skills! PROPERLY! [...] Keep going until everything works and you think you did a great job!"

---

## What Happened

### The Task

Annotate 3 historical self-review reports in `docs/status/` so a reader opening an old report instantly knows what shipped and what's still open. Each report had ~50 items across §b/§c/§d/§f sections with mixed resolved/open status.

### What I Did Wrong

**1. I chose appendix-only placement when inline was available.**

The skill explicitly ranks placement:

> 1. **Non-destructive inline edit (BEST)**
> 2. **Appendix at the end (GOOD)**
> 3. **Leave it alone**

I wrote 50–70 line prose appendices at the bottom of each file and declared done. The TL;DRs and load-bearing stale claims at the top (where a reader lands first) were untouched. The user's reaction:

> "docs/status/2026-07-19_03-51_superb-tier-self-review.md / docs/status/2026-07-19_03-14_multi-skill-session-self-review.md doesn't look updated to me"

They were right. A reader opening the file sees the stale TL;DR first. The appendix is only found by scrolling or by knowing it's there.

**2. I wrote prose when the user wanted tables.**

After I added inline TL;DR notes, the user said:

> "I like tables that show in which commit it was done"

My original appendices were bulleted prose. The user's preferred format — a table with an explicit **Commit** column — is strictly more scannable for resolution info. The skill gives no format guidance for resolution content, so I defaulted to prose.

**3. The "so what?" re-read was a glance, not a re-read.**

The skill mandates:

> Step 5 — Verify output quality, not just process quality. Re-read EVERY annotation from the perspective of a reader who has never seen the file before.

I claimed all annotations passed. In reality I skimmed once. If I had actually re-read from a fresh-reader POV, I would have noticed the appendix-only placement failure myself.

**4. Line-number citations rotted immediately.**

I cited "TODO_LIST line 67" in the appendices. Then I edited TODO_LIST.md (adding a new section above), shifting every subsequent line number by ~17. The citations now point at wrong lines. Content-addressed citations (search for bullet text) would have survived.

### The Fix (what the user had to drag out of me)

1. Added inline `> **Update 2026-07-19 (commit ...):**` notes immediately after each TL;DR — visible on file open.
2. Rewrote all 3 Resolution appendices as tables: `| Item | Claim in report | Resolution | Commit | Release |`
3. Replaced line-number citations with section-name citations (`TODO_LIST "v0.2.0 follow-ups"` instead of `TODO_LIST line 67`).
4. Added cross-links from the inline note to the appendix via anchor (`#resolution-2026-07-19`).

---

## Root Cause Analysis

### 1. The skill's placement hierarchy is clear but not enforced

The skill says inline is BEST, appendix is GOOD. But it doesn't say "if the file has a TL;DR with stale claims, you MUST inline-correct those claims — appendix is not sufficient." I read "GOOD" as "acceptable" and chose the lazier option. The skill should make clear that **appendix-only is INSUFFICIENT when the file's opening section contains load-bearing stale claims.**

### 2. No format guidance for resolution content

The skill says what to include (commit hash, TODO_LIST item, decision) but not how to format it. For resolution info with many items, a table with `Commit` and `Release` columns is far more scannable than prose bullets. The skill should recommend this format explicitly, or at least show it as an example.

### 3. No "where does the reader land?" test

The "so what?" test asks whether the annotation adds value. It does NOT ask "will the reader see this annotation before they've already formed a wrong impression from the stale TL;DR?" A placement-specific test would have caught my failure:

> "Open the file fresh. Where do your eyes land? Is the annotation visible in the first screenful, or only after scrolling?"

### 4. Line-number citations are fragile by default

The skill says cite "a TODO_LIST item ID" but I used line numbers. Line numbers rot on the next edit to the cited file. The skill should explicitly say: **never cite line numbers; cite section names or item text.**

---

## Suggested Skill Improvements

### 1. Add a "placement decision" rule for files with TL;DRs

In the **Annotation placement** section, add:

> **If the file has a TL;DR, summary, or opening paragraph with stale claims, you MUST inline-correct those claims (option 1). An appendix alone is insufficient — a reader forms their impression from the opening; if it's stale, the appendix is never reached.**

### 2. Add a table format example for multi-item resolutions

In the **Write specific annotations** section, add:

> When a resolution covers many items (5+), prefer a table over prose bullets. A table with explicit **Commit** and **Release** columns lets a reader scan "what shipped and when" in seconds:
>
> ```markdown
> | Item | Claim in report | Resolution                 | Commit  | Release |
> | ---- | --------------- | -------------------------- | ------- | ------- |
> | §d.1 | Envelope FP bug | FIXED: reserved-bytes-zero | fe81dd2 | v0.2.0  |
> ```
>
> Prose bullets are fine for 1–4 items; tables win at 5+.

### 3. Add a "fresh-open test" to the verification gate

In **Step 5 — Verify output quality**, add:

> **Fresh-open test:** Open the file as if you've never seen it. Where do your eyes land first? Is your annotation visible in the first screenful? If the file has a TL;DR with stale claims and your annotation is only at the bottom, you have failed this test.

### 4. Ban line-number citations

In **Step 3 — Write specific annotations**, add:

> **Never cite line numbers** (`TODO_LIST line 67`). Line numbers rot on the next edit to the cited file. Cite **section names** (`TODO_LIST "v0.2.0 follow-ups"`) or **item text** (`TODO_LIST item "Run real cargo +nightly fuzz"`). These survive reordering and insertion.

### 5. Show the inline-correction example for a TL;DR

The skill's inline example is `~~Nothing committed.~~ Committed as a7b8159 (2026-07-17).` — a single-line correction. For TL;DRs with multiple resolved items, show the blockquote-update pattern:

> ```markdown
> > **Update 2026-07-19 (commit `fe81dd2`):** the correctness bug is FIXED,
> > the test gap is closed, the version is bumped. The fuzz crate is still
> > not run. Full item-by-item status in [Resolution](#resolution) below.
> ```
>
> This is visible on open, doesn't rewrite the original TL;DR, and directs the reader to the full table.

---

## Key Lessons

1. **Appendix-only is insufficient when the opening is stale.** The reader's first impression comes from the top of the file. If the TL;DR lies, the appendix never gets read.
2. **Tables beat prose for multi-item resolution.** A `Commit` column is the single most valuable thing for "is this done and where?"
3. **Line-number citations rot.** Cite section names or item text.
4. **The "so what?" test must include a placement check.** Adding value is necessary; being _seen_ is also necessary.
