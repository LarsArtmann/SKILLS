# Documentation Ownership Model

> Authoritative rules for which project file owns which information.
> The cardinal rule: **each fact has exactly ONE home.**

## File ownership

| File                      | Purpose                                                                                                                              | NOT for                                                               |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| `README.md`               | **Sales page for end-users**: what this does, why it exists, how to get started                                                      | Internal architecture, developer notes, AI session context            |
| `docs/DOMAIN_LANGUAGE.md` | Domain-driven design glossary: ubiquitous language, bounded context terms, project-specific vocabulary                               | Implementation details, API docs, architecture decisions              |
| `AGENTS.md`               | Concise, enduring context for every AI session: important information, unexpected behaviors, things hard to discover from code alone | Change logs, task lists, feature status, future plans, marketing copy |
| `FEATURES.md`             | Honest feature inventory by status: `FULLY_FUNCTIONAL`, `PARTIALLY_FUNCTIONAL`, `BROKEN`, `PLANNED`                                  | Implementation details, architecture notes, change history            |
| `TODO_LIST.md`            | Interactive short- and mid-term improvement tasks, actionable, bounded, with status                                                  | Long-term vision, vague ideas, completed work, unowned requests       |
| `ROADMAP.md`              | Long-term direction and raw ideas not yet refined into actionable tasks                                                              | Short-term work, well-scoped features, completed milestones           |
| `CHANGELOG.md`            | Chronological record of what changed in each version                                                                                 | Planning, feature status, internal context                            |
| `docs/adr/`               | Architecture Decision Records: context, decision, consequences for each significant architectural choice                             | Feature status, task tracking, getting-started docs                   |

## Anti-patterns

| Don't                                       | Why                                                   | Instead                                       |
| ------------------------------------------- | ----------------------------------------------------- | --------------------------------------------- |
| Put TODOs in `AGENTS.md`                    | Rots fast, nobody actions it                          | `TODO_LIST.md`                                |
| Put feature status in `README.md`           | Marketing tone drifts from reality                    | `FEATURES.md`                                 |
| Put architecture decisions in `FEATURES.md` | Mixes inventory with rationale                        | `AGENTS.md` (brief) + `docs/adr/` (detail)    |
| Put domain terms in `AGENTS.md` prose       | Scattered, not greppable                              | `docs/DOMAIN_LANGUAGE.md`                     |
| Duplicate a fact across files               | They will drift; readers cannot tell which is current | State it once, link from elsewhere            |
| Put completed work in `TODO_LIST.md`        | Clutters the active list                              | Remove it; log in `CHANGELOG.md`              |
| Put raw ideas in `TODO_LIST.md`             | Dilutes actionable work                               | `ROADMAP.md` until refined into bounded tasks |
| Put short-term tasks in `ROADMAP.md`        | Roadmap becomes a dumping ground                      | `TODO_LIST.md`                                |

## Information lifecycle

A feature moves through files as it matures. It should appear in exactly ONE
stage at any given time:

```
ROADMAP.md                TODO_LIST.md              FEATURES.md               CHANGELOG.md
-------------             -------------             -----------              ------------
raw idea            ->    actionable task    ->    shipped feature    ->    release entry
unrefined                 verified against code      honest status             logged once
```

**Stage 1 (Idea):** Lives in `ROADMAP.md` as a raw, unrefined concept.

**Stage 2 (Actionable):** Refined into a bounded task in `TODO_LIST.md` with
clear scope and effort estimate.

**Stage 3 (Shipped):** Appears in `FEATURES.md` with an honest status
(`FULLY_FUNCTIONAL`, `PARTIALLY_FUNCTIONAL`, etc.). Removed from `TODO_LIST.md`.

**Stage 4 (Released):** Logged in `CHANGELOG.md` under the version it shipped in.

### The most common rot

A feature ships and gets added to `FEATURES.md`, but nobody removes it from
`TODO_LIST.md`. Now both files claim different states for the same thing.
Readers cannot tell which is current. This is the #1 documentation split brain.

**Prevention:** When marking a feature as shipped in `FEATURES.md`, immediately
remove the corresponding item from `TODO_LIST.md` and add a `CHANGELOG.md` entry.

## Where agents store what

| Information type                     | Goes in                                  | NOT in                        |
| ------------------------------------ | ---------------------------------------- | ----------------------------- |
| Non-obvious gotchas, quirks          | `AGENTS.md`                              | `README.md`, `CHANGELOG.md`   |
| Architecture decisions / ADRs        | `AGENTS.md` (brief) + `docs/adr/`        | `FEATURES.md`, `TODO_LIST.md` |
| Domain term definitions              | `docs/DOMAIN_LANGUAGE.md`                | `AGENTS.md` prose             |
| Build/test/lint commands             | `flake.nix` / `AGENTS.md` (pointer only) | Scattered across skills       |
| Feature status (done/partial/broken) | `FEATURES.md`                            | `AGENTS.md`                   |
| Next actionable work                 | `TODO_LIST.md`                           | `AGENTS.md`, `CHANGELOG.md`   |
| Long-term ideas not yet actionable   | `ROADMAP.md`                             | `TODO_LIST.md`                |
| What changed in version X            | `CHANGELOG.md`                           | `AGENTS.md`                   |
| How to get started / why it exists   | `README.md`                              | `AGENTS.md`                   |

## Relationship to other skills

| Skill             | Boundary with this model                                                                                                                                                                                                                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pareto-planning` | Takes a `TODO_LIST.md` and ranks it by impact (80/20). Does not create or verify the list itself.                                                                                                                                                                                                                                                 |
| `status-report`   | Produces a point-in-time snapshot. Its \"next tasks\" section is a primary INPUT to `TODO_LIST.md` / `ROADMAP.md` via HARVEST (forward direction). The report itself is never rewritten — annotating it to reflect what later shipped is the backward direction (ANNOTATE mode). Both directions live in docs-health; neither replaces the other. |
