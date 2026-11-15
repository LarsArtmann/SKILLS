---
name: architecture-deepening
description: Use when the user wants to find architecture worth refactoring, not score it — says "deepen the architecture", "improve codebase architecture", "deepening opportunities", "shallow module", "where should the seam go", "make this testable", "architecture refactor candidates", or asks which nearby modules should be collapsed. Scans for shallow modules and misplaced seams, presents ranked candidates as a self-contained HTML brief with before/after diagrams, then grills the design of the one the user picks. Local successor to mattpocock's improve-codebase-architecture, whose copy needs three sibling skills this repo does not install. Distinct from architecture-review (rubric scorecard), architecture-visualization (D2 pictures), data-model-review (type redesign) and full-code-review (every-file audit).
metadata:
  tags: architecture, refactoring, deep-modules, seams, testability, design
---

# Architecture Deepening

Depth is leverage at the interface: a lot of behaviour behind a small interface, sitting at a clean seam, testable through that interface. This skill finds where the codebase is shallow and proposes the deepening. It does not grade the architecture (that is `architecture-review`) and it does not draw the target state (that is `architecture-visualization`).

## Vocabulary is load-bearing

Read [./references/deepening-vocabulary.md](./references/deepening-vocabulary.md) before writing any candidate. Use its nouns exactly: **module**, **interface**, **implementation**, **depth**, **seam**, **adapter**, **leverage**, **locality**. "Component", "service", "API", "signature", and "boundary" are banned here because they blur the decision the review is about. Report structure, card schema, and diagram patterns: [./references/candidate-report.md](./references/candidate-report.md).

## 0. Read the project model first

- `GLOSSARY.md`, or `docs/DOMAIN_LANGUAGE.md` in this repo's convention; read `GLOSSARY-MAP.md` when it exists (multi-context repos).
- ADRs in `docs/adr/` for the area you will touch. An ADR records a decision this review must not re-litigate unless the friction is material; when it is, say so in the card instead of silently proposing the opposite.

A term the glossary already names is usually a real seam. A concept with no name is usually the friction.

## 1. Scope before you scan (YAGNI)

Deepening pays off by making future change easier, so weight what has changed recently:

- The user named a direction (module, subsystem, pain point) → take it.
- Otherwise `git log --oneline -n 100` and rank the paths that keep appearing; start at those hot spots.
- Changes are scattered with no hot spot → widen to module boundaries.

State the scope you picked in one line before spawning the scan.

## 2. Explore with a fresh-context sub-agent

Dispatch a read-only sub-agent (`agent_dispatch`, access `read`) with the scope and this friction checklist:

- Where does understanding one concept require bouncing between many small modules?
- Where is a module **shallow** — its interface nearly as complex as its implementation?
- Where were pure functions extracted for testability while the real bugs live in how they are called (locality lost)?
- Where do tightly coupled modules leak across their seams?
- Which parts are untested, or hard to test through the current interface?

Apply the **deletion test** to every suspected shallow module: imagine deleting it. If the complexity vanishes, it was a pass-through. If it reappears across N callers, it was earning its keep — leave it alone.

Ask the sub-agent to return `file:line` evidence, the seam location, and one sentence of friction per finding. No proposals yet.

## 3. Write the candidate brief

Destination: `docs/architecture-understanding/YYYY-MM-DD_HH-mm_<slug>-deepening.html` in the repo under review. Honor `ARCH_DEEPENING_OUT` (or the older `ARCH_REVIEW_OUT`) when set to a directory or file path. Never default to the OS temp directory: reports are artifacts the user keeps, reviews the candidate, and references later — upstream's `/tmp` default is why this skill was forked locally.

Follow the kit's series discipline: list the target directory, skim the most recent 1-3 reports (TOC + findings), and copy the template — never transcribe CSS.

- Template: [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html) (editorial-light suits a brief)
- Design spec: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)

One card per candidate: title naming the deepening, strength badge (`Strong` / `Worth exploring` / `Speculative`), files, before/after diagram pair, one-sentence problem, one-sentence solution, wins as bullets of six words or fewer, and an ADR-conflict callout when relevant. End with **Top recommendation** and why. Then open it (`xdg-open` / `open` / `start`) and report the absolute path.

Do not design interfaces in this step. The brief exists to choose a candidate, not to pre-commit the answer.

## 4. Stop and ask

Ask exactly one question: "Which of these do you want to deepen?" Do not start designing every candidate.

## 5. Grill the chosen candidate

Run a design tree in rounds. The **frontier** is every decision whose prerequisites are settled — the questions you can ask now without guessing. Put the whole frontier in one round: number each question, give your recommended answer, and word it so "yes" accepts the recommendation. Wait for answers, recompute the frontier, ask the next round. A question that depends on another open question belongs to a later round.

Facts are your job: dispatch a read-only sub-agent for anything the filesystem can answer. Decisions are the user's: put each one to them.

Cover at least: the constraint that makes this hurt, the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`), the shape of the module behind the seam, what stays outside it, which tests survive, and what the interface promises to callers.

Make no edits and no TODO_LIST rows until the user confirms a shared understanding.

## 6. Record what crystallised

- A deepened module named after a concept missing from the glossary → add the term now, lazily creating the file if needed.
- A rejected candidate with a load-bearing reason → offer an ADR only when the decision is hard to reverse, surprising without context, and the result of a real trade-off. Skip ephemeral ("not now") reasons.
- The chosen refactor → run [`docs-health`](../docs-health/SKILL.md) → **HARVEST** so it lands in `TODO_LIST.md` or `ROADMAP.md`. The canonical "when to run HARVEST" rule lives there; do not restate it.

## 7. Hand off

| Next question                         | Skill                                                          |
| ------------------------------------- | -------------------------------------------------------------- |
| How healthy is the architecture now?  | [`architecture-review`](../architecture-review/SKILL.md)       |
| Draw current vs target structure      | [`architecture-visualization`](../architecture-visualization/SKILL.md) |
| Sequence the refactor into small wins | [`pareto-planning`](../pareto-planning/SKILL.md)               |
| Reshape the module's types/invariants | [`data-model-review`](../data-model-review/SKILL.md)           |
| Audit every file, not just structure  | [`full-code-review`](../full-code-review/SKILL.md)             |

## Anti-patterns

| Don't                                                    | Why                                                                     |
| -------------------------------------------------------- | ----------------------------------------------------------------------- |
| Propose interfaces in the brief                          | Step 5 exists to compare alternatives; pre-committing kills them        |
| Introduce a seam with one adapter                        | One adapter is a hypothetical seam; two adapters make it real           |
| Rewrite an ADR into a "fix" without flagging it          | Reopen it explicitly, with the friction that justifies it               |
| Score or grade modules                                   | That is architecture-review; here the output is candidates              |
| Write to `/tmp`                                          | The report is the deliverable, not a scratch file                       |
| Pad with "component", "service", "API", "boundary"       | Vocabulary drift hides the actual design decision                       |
| Deepen modules that have not changed in years            | YAGNI: depth pays back only where future change will cross the interface |
