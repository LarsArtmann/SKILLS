# Annotation Placement — Banners, Appendices, and Inline Edits

> Detailed companion to the ANNOTATE → "Placement: inline before appendix"
> subsection in [../SKILL.md](../SKILL.md). Load this when annotating historical
> documents (status reports, reviews, plans, audits) or when a user asks you to
> "mark", "stamp", "tag", or "add a note to" existing files.

## Contents

1. [Why placement matters](#why-placement-matters)
2. [The three approaches, ranked](#the-three-approaches-ranked)
3. [Before / after examples](#before--after-examples)
4. [What counts as a "banner"](#what-counts-as-a-banner)
5. [When you genuinely have no placement option](#when-you-genuinely-have-no-placement-option)
6. [Resolving numbered items (including table rows)](#resolving-numbered-items-including-table-rows)

---

## Why placement matters

Status reports and reviews are **historical artifacts**. They capture what
someone knew at a point in time. The reader opened the file to see that
snapshot — the original title, the original date, the original opening
paragraph, in the original order.

A **banner** is a blockquote or note injected between the title and that
opening paragraph. It does three kinds of damage:

1. **It pushes the original content down.** A reader opening the file sees the
   banner first, not the report they came to read.
2. **It breaks the visual flow.** The document was written with a structure
   (title → date → context → body). A banner between title and date violates
   that structure.
3. **It is a separate voice.** The banner speaks as a later editor,
   interrupting the original author's narrative.

Even a _specific_ banner (one that cites a real commit hash and a real open
item) is still a banner. The lesson is not "make banners specific" — it is
"don't use banners at all when an inline edit or appendix will do."

## The three approaches, ranked

### 1. Non-destructive inline edit (BEST)

Update the stale claim **in place**, inside the original narrative. The reader
never leaves the flow of the document, and the document's character is
preserved.

Use strikethrough to show what changed, or append a correction in brackets:

```markdown
**Ending state:** ~~Nothing committed.~~ Committed as `a7b8159` (2026-07-17).
```

or

```markdown
**Ending state:** Committed as `a7b8159` (2026-07-17). _[Originally said
"nothing committed" — updated post-commit.]_
```

When inline is best: the stale claim is a single line or short phrase you can
point to. The correction is small and local.

### 2. Appendix at the end (GOOD)

Add a clearly marked section at the **bottom** of the file:

```markdown
---

## Resolution (2026-07-17)

All 19 tasks committed as `a7b8159`. Open follow-ups: embedBorderStyle nil
test (TODO_LIST B3), reconnect log assertion (B4). CHANGELOG.md and AGENTS.md
updated.
```

The reader finishes the original report, then sees the resolution.
Non-destructive, non-interruptive, clearly separated as a later addition.

When appendix is best: the resolution spans many items, or there is no single
stale line to edit — the whole report is "done" and a summary belongs at the
end.

### 3. Leave it alone

If neither an inline edit nor an appendix adds enough value, **do not
annotate.** Unannotated is better than noise. This is always a valid choice.

## Before / after examples

### BAD — banner at the top (do not use)

```markdown
# Status Report — 2026-07-15

> **✅ Update (2026-07-17):** This is a point-in-time snapshot from that session.
> Items acted on are in the committed history; deferred items are in TODO_LIST.md.

This week we focused on the embed pipeline...
```

Why it fails: generic, could apply to any file, pushes the real content down,
interrupts the structure, and adds nothing a reader can act on.

### GOOD — inline edit

```markdown
# Status Report — 2026-07-15

This week we focused on the embed pipeline...

**Ending state:** ~~Nothing committed.~~ Committed as `a7b8159` (2026-07-17).
Open: embedBorderStyle nil test (TODO_LIST B3).
```

Why it passes: the reader stays in the flow, sees exactly what changed, and
gets a specific reference. Survives the "so what?" test.

### GOOD — appendix

```markdown
# Status Report — 2026-07-15

This week we focused on the embed pipeline...
[...original report unchanged...]

---

## Resolution (2026-07-17)

Done: embed pipeline shipped in `a7b8159`. Open: embedBorderStyle nil test
(B3), reconnect assertion (B4).
```

Why it passes: the original report is fully intact; the resolution is clearly
separated at the end.

## What counts as a "banner"

Any block injected between the title (H1) and the original opening content:

- A `>` blockquote "✅ Update" / "ℹ️ Note" / "⚠️ Status" line
- An inline-styled `<div>` alert box
- A horizontal rule + note immediately under the title
- Any "editor's note" in a different voice than the original author

The test: **does this content sit ABOVE the original opening paragraph, or does
it interrupt the title→body structure?** If yes, it is a banner. Move it to an
inline edit or an appendix.

## When you genuinely have no placement option

Sometimes a file is so short or so structural (a config file, a one-line
pointer, an empty stub) that an inline edit has nothing to correct and an
appendix is absurd. In that case the answer is **leave it alone**, or make a
single, minimal, clearly-marked inline edit. Do not reach for a banner just
because inline/appendix felt awkward — the awkwardness is a signal that the
annotation adds no value.

## Resolving numbered items (including table rows)

For the full pattern catalog of per-item resolution — prose numbered lists,
variant forms (`Won't implement`, `NOT-DO/DUPLICATE`), detailed rules,
multi-item table format (5+), and the two table-row patterns (strikethrough
cells vs. Status column) — see
[./resolving-items.md](./resolving-items.md). That is the companion reference
for _how_ to resolve items; this file covers _where_ to place annotations.
