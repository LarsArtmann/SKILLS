# Case Study — The Docs-Health Generic Banner Verschlimmbesserung

> The real incident that created this skill. Read this when you want to
> understand WHY every rule in [../SKILL.md](../SKILL.md) exists — not just
> WHAT it says. Distilled from a live session so the lesson survives even if
> the source feedback file is archived or deleted.
>
> **Why this is an old-docs story:** the failed task was bringing a set of OLD
> status reports up to date so a reader could tell what had shipped. The
> failure was not in fixing living docs — it was in annotating historical
> snapshots. Every lesson below is about the care required when updating old
> documents without destroying their history.

## Contents

1. [The setup](#the-setup)
2. [What went wrong](#what-went-wrong)
3. [The user's reaction](#the-users-reaction)
4. [The fix (round 1)](#the-fix-round-1)
5. [The fix (round 2) — banner placement](#the-fix-round-2--banner-placement)
6. [Root causes (the five that matter)](#root-causes-the-five-that-matter)
7. [The one-line summary](#the-one-line-summary)

## The setup

A user asked an agent to update TODO_LIST.md, CHANGELOG.md, and all
`*2026-07-1*` status/planning files (~89 files) so that viewing any old status
report would make it instantly clear what had already been done.

The intent was good and specific: _"I want to look at ANY status report from
this week and INSTANTLY know — is this done? where is it NOW?"_

## What went wrong

The agent wrote a Python script that stamped an identical **generic banner** on
58 of the files:

```markdown
> **✅ Update (2026-07-17):** This is a point-in-time snapshot from that session.
> Items that were acted on are in the committed history; deferred/blocked items
> are carried in [`TODO_LIST.md`](../../TODO_LIST.md). Shipped changes are in
> [`CHANGELOG.md`](../../CHANGELOG.md) `[Unreleased]`. The code is the source of truth.
```

Every flaw in [../SKILL.md](../SKILL.md) is present in this one block:

1. **It said nothing specific.** No commit hash, no item ID, no "what's done",
   no "what's open." It failed the "so what?" test completely — a reader still
   had to go read two other files and still didn't know if THIS work was done.
2. **It was identical across 58 files** — including planning docs full of
   _rejected/deferred_ ideas, where a "things were acted on" banner actively
   misled by implying the rejected work had shipped.
3. **It duplicated information already in the file.** Many files already had
   their own execution-status tables, "RESOLVED SINCE" headers, or "✅ Done"
   markers. A second banner on top was pure noise.
4. **It violated the project skill's own principle:** _"Documentation that lies
   is worse than missing documentation."_

The agent also stamped inline-styled `<div>` banners into 4 HTML dashboard
files, which:

- Added inline styles, violating the project's CSP-compliant,
  zero-inline-handler architecture.
- Were later "removed" by a second script that used a naive
  `txt.find('</div>')` — which matched the _wrong_ closing tag and duplicated
  the file body 1452+ times, corrupting the files. Recovery required
  `git restore` from HEAD.

## The user's reaction

> "How does the Update (2026-07-17) make sense? Did you even read? Are you a
> lazy bastard that verschlimmbessers??!?!!????"
>
> "It's the same header here [another file]!!! I AM VERY PISSED!!!!!!"

The user was right. The banner was lazy, generic, and added negative value.

## The fix (round 1)

The agent removed all 58 generic markdown banners and the 4 HTML banners. It
kept only the **specific** banners — the ones that cited exact commits and
remaining gaps. The specific banners were valuable because they answered the
reader's actual question: _"is this done, and if so, where?"_

Lesson: **24 specific annotations > 58 generic ones.** Restraint is success.

## The fix (round 2) — banner placement

After the cleanup, the user pushed back on something deeper:

> "Also I am not a fan of banners I like Appendixes or best proper
> non-destructive edits of the original content."

Even the surviving "specific" banners were still **banners** — blockquotes
injected between the H1 title and the original opening paragraph. That is
destructive to the reading experience (see
[./annotation-placement.md](./annotation-placement.md) for the full reasoning).
The agent then converted the remaining banners to inline edits and appendices.

## Root causes (the five that matter)

### 1. Optimized for "done" instead of "useful"

"Annotate all 89 files" became a checkbox to clear. Success was measured as
"every file has an annotation" instead of "a reader of any file can instantly
know the current status." These are very different goals.

### 2. Verified process quality, not output quality

The agent checked: _did the banner insert correctly? (link depth, no dupes,
idempotent)_. It never checked: _would a reader of THIS file actually benefit
from this banner?_ The second question is the only one that matters.

### 3. Interpreted "all" as "every file must be modified"

The user said "update all files." The agent read "all" as "every single file
gets an annotation." But files that already have resolution sections, files
describing rejected work, and files that are fine as-is do not need
modification. **"All" means "no file is missed where annotation would help."
It does NOT mean "every file gets modified."**

### 4. Batched without judgment

Writing a Python script to stamp 58 files in one go felt efficient. But
efficiency without judgment is just fast waste. Each file deserved a 5-second
_"does this need anything?"_ decision — made by the agent, not by a script's
`if` branch.

### 5. Sloppy scripting corrupted the HTML

The removal script's naive `txt.find('</div>')` matched the wrong closing tag.
The agent saw "5138 insertions" in `git diff --stat` and initially did not
question it, because focus was on the markdown banners, not the HTML files.
This is why [../SKILL.md](../SKILL.md) says: undo batch edits with
`git restore`, never with a second removal script.

## The one-line summary

> The agent confused _"I touched every file"_ with _"every change helped."_
> Scale rewarded batching; batching rewarded skipping judgment; skipping
> judgment produced a Verschlimmbesserung. Every rule in this skill exists to
> break one link in that chain.
