# Revision Lessons — What Lars's Edits Reveal

> Source: 271 GitHub items with 2+ saved versions (GraphQL
> `userContentEdits`, fetched 2026-09-12). Versions are full snapshots;
> changes below are diffs between consecutive snapshots. These patterns
> are what "first draft → his second draft" looks like — draft the second
> version directly.

## 1. He appends `Edit:` instead of rewriting

Once a thread has moved on, corrections arrive as appended lines, not
silent rewrites:

```markdown
<original comment>

Edit: Didn't find a better one though :(
```

```markdown
<original comment>

Edit: Thx
```

**Why:** preserves conversational history; repliers stay coherent.
**Draft rule:** if the comment is a follow-up to your own earlier
comment, append `Edit: ...` rather than recomposing.

## 2. He adds the @mention after the fact

Multiple revisions show the same single change — prepending the
addressee:

- `What do you men with?` → `@DevSnox What do you men with?`
- `wie hast du die Velocity hinbekommen?` → `@DevSnox wie hast du die
  Velocity hinbekommen?`

**Draft rule:** when a comment is aimed at one person in a busy thread,
start with the `@mention` on the first try.

## 3. He adds status words and precision

- `Added <url>` → `In progress (<url>)`
- `#35` → `#35 help wanted`
- `PR #3319 fixes this ...` → `PR #3319 fixes this ... If merged:
  DiscoverWithStates resolves symlinks ...`

The arrow always points toward **more precise state**: not just what,
but what state it is in and under which condition it holds.

## 4. He condenses and swaps promises for evidence

The strongest modern pattern. From a mindwalk PR-series comment:

- Before: "I've been extending mindwalk locally with support for..."
  plus a paragraph listing what comes next.
- After: "I extended mindwalk with support for..." plus:
  `` `go test ./... -count=1` is green at every slice boundary, `-race`
  on the server-heavy ones. The full series is up; review in merge order. ``

Perfect tense tightens (`I've been extending` → `I extended`), the
forward-looking paragraph is deleted, and a **verification statement
replaces the roadmap**.

**Draft rule:** end with proof that exists now, not with what will
exist next.

## 5. He restructures into labeled verdicts

A crush issue comment evolved across three versions from prose into:

```markdown
The reasoning effort picker was implemented but is blocked when the
agent is running — `ActionSelectReasoningEffort` has an `isAgentBusy()`
guard (`internal/ui/model/ui.go`).

**Fix:** Remove the `isAgentBusy()` guard from ...
```

Prose → observation with `file:symbol` → bold-labeled **Fix:** section.
When a comment carries analysis + recommendation, he edits until the
recommendation is a separate bolded line.

## 6. He splits stacked mentions into their own paragraph

- Before: `@mario-guerra happy to share ... @fmvilas your review offer
  still stands?` (one block)
- After: same text, `@fmvilas ...` broken onto its own paragraph with a
  softened tail: `your review offer still stands, I hope?`

**Draft rule:** one @mention block per person; soften a second ask with
`, I hope?`.

## 7. Grammar errors survive edits

- "Does anybody this care about this PR?" — kept, and the edit ADDED
  more words around it, not fixes.
- "Atmosphere is an Interface..." → edited to "a Interface" — a rewrite
  that made grammar _worse_ and stayed.

**Draft rule:** never spend an edit on grammar. Spend it on precision,
state, or structure (patterns 3–5).

## 8. AI-drafted comments get regenerated, not line-edited

Own-repo comments with 5–10 versions are agent-era regenerations (whole
body changes each time, e.g. the Mermaid-diagram iterations). Not a
human editing pattern — do not imitate "edit by regenerate" for external
repos; there he edits surgically.

## Applying this when drafting

1. Write the first draft fast, in his register (terse, evidence-first).
2. Do ONE revision pass applying patterns 3–5: add status word, add
   file:line precision, swap any promise for existing proof, bold the
   recommendation.
3. Skip the grammar pass entirely.
4. If it is a follow-up to your own comment, consider `Edit:` appending
   instead of a new comment or a rewrite.
