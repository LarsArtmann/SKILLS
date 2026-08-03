# HARVEST Guide — Anti-Patterns and Edge Cases

> Companion to the HARVEST section in [../SKILL.md](../SKILL.md). The body
> covers the 6-step procedure and the essential rules. Load this ONLY for the
> anti-pattern catalog, the "Top N override" edge case, and the timing rules
> in full detail.

## When to run HARVEST (full detail)

_This is the **single source of truth** for the "run HARVEST after a status
report" rule. Other skills (`status-report`) link here rather than restating._

- **After every `status-report` session.** The report's "next tasks"
  section is a TODO_LIST input, not its final resting place. **If you just
  wrote a status report and TODO_LIST was not updated, run HARVEST now** —
  otherwise the items rot in a timestamped file no later session reads.
- **As a step in AUDIT.** A full docs-health run that skips HARVEST will
  declare TODO_LIST "fresh" while dozens of planned items rot in the most
  recent snapshot.
- **On explicit request:** "harvest the latest status report", "pull the
  next tasks into TODO_LIST", "extract open items from recent reports".

## Anti-patterns (not already stated in the body)

The body covers: drop resolved items, questions aren't tasks, verify against
code, don't rewrite the source. These are the additional failure modes:

- **Dumping all 50 items verbatim into TODO_LIST.** Most "Top 50" lists are
  brainstorms, not commitments. Route, dedupe, and verify before inserting,
  or TODO_LIST becomes a dumping ground that nobody acts on.
- **When the user overrides the "Top N" count** (e.g. asks for 50 instead of
  25). Expect a brainstorm, not a commitment list. The user's instruction
  wins, but apply extra routing rigor: most of the extra items belong in
  ROADMAP, not TODO_LIST.
- **Treating the report as code.** A report saying "we should do X" is
  intent, not evidence that X is undone. A later session may have already
  shipped X. Verify against code.
- **Re-harvesting items already marked resolved.** `done at` /
  `Won't implement` / `NOT-DO` markers mean an item is closed; pulling it
  back into TODO_LIST re-opens settled work. Respect the markers.
- **Skipping HARVEST because "ANNOTATE handles status reports."** It does
  not — different direction. ANNOTATE resolves items backward (marks what
  shipped); HARVEST pulls items forward (what's now on the backlog). Both
  are needed; neither replaces the other.
- **Reading every historical report.** The 100th-oldest report's "next
  tasks" are either done, obsolete, or already captured. Recent reports
  carry the signal; old ones carry noise. Default to the most recent 1–3.
