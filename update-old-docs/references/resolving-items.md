# Resolving Numbered Items Inline — The Primary Work

> Companion to the _Numbered action items_ section in
> [../SKILL.md](../SKILL.md). Load this when a file has numbered action items
> (prose lists OR table rows) and you need the full pattern catalog, variant
> forms, rules, and multi-item table format.
>
> **Resolving numbered items is the primary work of this skill.** An appendix
> adds context; it does not resolve items. If you write an appendix without any
> inline `done at` markers, you have hit the #1 failure mode — go back.

## Contents

1. [What "resolving" means](#what-resolving-means)
2. [The format grammar](#the-format-grammar)
3. [Worked example: prose numbered list](#worked-example-prose-numbered-list)
4. [Variant catalog](#variant-catalog)
5. [Rules for the strikethrough pattern](#rules-for-the-strikethrough-pattern)
6. [Multi-item resolutions (5+): prefer a table](#multi-item-resolutions-5-prefer-a-table)
7. [Tables with numbered rows](#tables-with-numbered-rows)

---

## What "resolving" means

Old status reports and plans often contain numbered items — either as prose
lists (`1. 2. 3.`) or as table rows (`| 1 | | 2 |`) — under headings like
"Things to Do Next", "Open issues", "Next steps". Both forms are the most
common thing a reader wants resolved: _which of these are done now?_

**You must RESOLVE every numbered item** — not just the ones you already know
about. (_Annotate_ = file-level context; _resolve_ = a per-item verdict — both
in one pass.) Each item gets a verdict:

- `done at <hash>` — shipped
- `Won't implement` / `NOT-DO` — closed without shipping
- left untouched — still open (you still CHECK it; never skip the check)

Skipping is the #1 failure mode: 10 marked and 40 never checked is **not
annotated**.

## The format grammar

```text
~~<original line, unchanged>~~ done at <set-of-short-git-hashes>
```

Wrap each hash in backticks; separate multiple with commas
(`a7b8159`, or `a7b8159`, `fe81dd2`).

## Worked example: prose numbered list

```markdown
1. ~~Fix warmup store pollution — use separate Bundle or document the inflation~~ done at `a7b8159`
2. ~~Fix estimateJSONSize — marshal-and-measure instead of template guess~~ done at `a7b8159`, `fe81dd2`
3. Add negative tests: factory returning nil Bundle, nil EventSink, closed store
4. ~~Add test for Config.Duration actually aborting a long-running phase~~ done at `fe81dd2`
```

Items 1, 2, and 4 are resolved (struck through + commit hashes). Item 3 is left
untouched — the absence of a marker IS the "still open" signal. This pattern
wins over an appendix table because the resolution lives right next to the
claim: a reader scanning the list sees the status without context-switching.

## Variant catalog

Keep wording consistent within a single file:

```text
~~<line>~~ done at `a7b8159`                          # one commit; several: `a7b8159`, `fe81dd2`
~~<line>~~ done (existing rule)                       # already existed; or: done (covered by C019)
~~<line>~~ **Won't implement — <one-line reason>.**   # investigated, decided against
**NOT-DO/DUPLICATE — <line>** <one-line reason>       # subsumed by / duplicates another item
```

`done at` means it shipped. `Won't implement` means you investigated and
decided against. `NOT-DO/DUPLICATE` means it overlaps another item so it was
never separately actioned. All three are **closed**; the reader needs to know
whether an item shipped or was closed without shipping — not merely forgotten.

## Rules for the strikethrough pattern

- **Strike through the ENTIRE original line** — the reader must be able to
  identify what the item was. Never replace the text; wrap it in `~~...~~`.
  Keep the original formatting (bold, links) inside the strikethrough.
- **Cite the commit hash(es)** that closed the item. Wrap each hash in
  backticks; separate multiple with commas (`a7b8159`, or `a7b8159`, `fe81dd2`).
- **Leave open items untouched** — do not mark them, do not add "OPEN" or
  "TODO" labels. The absence of a `done at` marker IS the signal that the item
  is still open. Adding labels to open items is noise (see anti-patterns).
- **One `done at` per completed item** — never batch multiple items into one
  annotation.
- **If an item was rejected/abandoned** (closed without shipping), mark it so
  the reader knows it will NOT ship (see variant catalog above).
- **Do not renumber.** Keep the original numbering/ordering intact. The
  numbers are how readers cross-reference items across documents.

## Multi-item resolutions (5+): prefer a table

When a file has 5+ resolved items, a table with explicit **Commit** and
**Release** columns lets a reader scan "what shipped and when" in seconds.
Prose bullets are fine for 1–4 items; tables win at 5+.

```markdown
| Item | Claim in report    | Resolution                               | Commit  | Release |
| ---- | ------------------ | ---------------------------------------- | ------- | ------- |
| §d.1 | Envelope FP bug    | FIXED: reserved-bytes-zero               | fe81dd2 | v0.2.0  |
| §b.3 | Fuzz crate not run | Still open — TODO_LIST "fuzz follow-ups" | —       | —       |
```

In a table, an open item gets a "Still open" cell — a table has an explicit
status column, so naming the open state there is correct (unlike an inline
list, where the absence of a marker IS the open signal).

## Tables with numbered rows

When a status report uses **markdown tables** for action items (not prose
numbered lists), apply the same per-item resolution inline. Two patterns:

### Pattern A — strikethrough the resolved cells

Use when the table already exists and you want minimal structural change:

```markdown
| ~~#~~ | ~~Task~~ | ~~Effort~~ | ~~Evidence~~ |
| ~~1~~ | ~~Run `nix run .#verify`~~ done at `f72c7b40` | ~~5m~~ | ~~Skipped~~ |
| 2 | Add Prometheus alert for orphan files | 15m | TODO_LIST |
```

The resolved row is fully struck through with the `done at` marker appended.
The open row is left untouched — absence of a marker IS the "open" signal.

### Pattern B — add a Status column

Use when most rows are resolved and a status column makes the table more
scannable:

```markdown
| # | Task | Status | Evidence |
| 1 | Run `nix run .#verify` | Done `f72c7b40` | — |
| 2 | Add Prometheus alert | Open | TODO_LIST |
```

Either way: **every numbered row gets a verdict** — `done`, `Won't implement`,
or left untouched (open). A table with 30 rows and zero inline markers is the
appendix-only trap, just in table form.
