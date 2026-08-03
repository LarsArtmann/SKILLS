# HARVEST Guide — When to Run, Anti-Patterns, and the Two-Way Loop

> Companion to the HARVEST section in [../SKILL.md](../SKILL.md). Load this
> for timing rules, the full anti-pattern catalog, and the forward/backward
> loop between HARVEST and ANNOTATE.

## When to run HARVEST

_This is the **single source of truth** for the "run HARVEST after a status
report" rule. Other skills (`status-report`) link here rather than restating
the rationale — edit the rule here, not in the callers._

- **After every `status-report` session.** The report's "next tasks"
  section is a TODO_LIST input, not its final resting place. **If you just
  wrote a status report and TODO_LIST was not updated, run HARVEST now** —
  otherwise the items rot in a timestamped file no later session reads.
- **As a step in AUDIT.** A full docs-health run that skips HARVEST will
  declare TODO_LIST "fresh" while dozens of planned items rot in the most
  recent snapshot.
- **On explicit request:** "harvest the latest status report", "pull the
  next tasks into TODO_LIST", "extract open items from recent reports".

## Anti-patterns

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
- **Harvesting open questions as tasks.** An unanswered question is not
  actionable. Route it to the user or to ROADMAP, not TODO_LIST.
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

## The two-way loop (HARVEST ↔ ANNOTATE)

Status reports have a two-way relationship with docs-health:

- **Forward (HARVEST):** the report's "next tasks" section is pulled OUT of
  the snapshot INTO `TODO_LIST.md` / `ROADMAP.md`.
- **Backward (ANNOTATE):** the report itself is annotated to reflect what
  later shipped ("this item was resolved in commit X").

Both directions are needed; neither replaces the other. A common failure is
to run ANNOTATE on a pile of old reports (backward) while never running
HARVEST (forward) — the reports say "resolved" but TODO_LIST still doesn't
contain the items that were NOT resolved, because nobody pulled them out in
the first place.

### Shared marker vocabulary

HARVEST and ANNOTATE MUST share vocabulary. ANNOTATE resolves items
**backward** (marks each `done at` / `Won't implement` / `NOT-DO`, then
archives fully-resolved files). HARVEST pulls items **forward** into
TODO_LIST — and it must **skip any item already carrying a resolution
marker** (those are closed; route to CHANGELOG, never re-harvest). The
marker vocabulary is owned by ANNOTATE; HARVEST references it, never
restates a rival format.
