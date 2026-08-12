# Status Report — MD→HTML Output Conversion Initiative

**Date:** 2026-06-17 20:02
**Scope:** Self-review of the 2026-06-17 MD→HTML analysis + Pareto execution plan for converting report-producing skills.
**Triggered skills:** `brutal-self-review` + `pareto-planning` + `status-report`

> **Irony flag (read first):** This very report is a point-in-time dashboard artifact —
> exactly the category my analysis recommends converting to HTML. It is written as `.md`
> because the `status-report` skill contract has **not yet been updated**. Unilaterally
> emitting HTML here would create a split-brain between the skill text and the output.
> Converting this report's own producer is Task #4 below. Until then: follow the contract
> as written, do not pre-empt it.

---

## 0. Brutal Self-Review of the Analysis

Answered with full honesty per the `brutal-self-review` rubric.

### What did I forget?

1. **The `pareto-planning` ⇄ `full-code-review` ghost system.** Both skills write the
   _same_ artifact — a Pareto plan with a D2 graph to `docs/planning/<date>.md`. The audit
   already flags "inlined Pareto" as a known smell. I listed both for HTML conversion
   independently but **missed that the real fix is consolidation**: `full-code-review`
   should _delegate_ planning to `pareto-planning`, not re-implement it. Converting two
   copies of a duplicate just produces two prettier duplicates.

2. **Reuse of the existing `d2` pipeline.** `architecture-visualization` already runs
   `.d2` → `.svg` via the `d2` CLI. For HTML outputs that embed graphs, the natural path is
   `d2` render → inline `<svg>`. I mentioned embedding but didn't name the reusable tool
   or add `allowed-tools: d2` to the converted skills (AGENTS.md §5.8 endorses this).

3. **`brutal-self-review` itself emits a report.** I excluded it as "inline only," but it
   produces a structured improvement plan. It belongs in Tier 2, not off the list.

### What is stupid that we do anyway?

- **Siloed design system.** `data-model-review/references/output-guide.md` is a complete
  HTML design spec that ~7 skills could share. It lives inside one skill. Every future
  report skill will either reinvent it or copy-paste it. That's the actual stupidity — not
  the `.md` vs `.html` question, but the lack of a **shared asset**.

### What could I have done better?

- **Verify before claiming.** Last turn I said the existing HTML design system is
  "extractable" after reading only 80/300+ lines. This turn I read lines 80–220 and
  **confirmed**: `:root` tokens, `.hero`, `.card` + `.card-problem|-solution|-warning`,
  `pre`/`code`, table styles — fully reusable. The claim holds, but it should have been
  verified _before_ asserting it.

### What could I still improve?

- **Replace the hand-wavy "dashboard vs living doc" heuristic with a real type model**
  (see §3). That is the durable improvement — a decision criterion, not a vibe.

### Did I lie?

No. But I **overstated confidence** on one point (the extractability claim) without
evidence in-hand. Corrected now.

### Split brains / ghost systems

1. **`output-guide.md` says `.go-*` syntax classes; the realized HTML uses `.ts-*`.** The
   shared design system must use **language-agnostic** token names (`.tok-keyword`,
   `.tok-type`, etc.) or this split brain multiplies across every converted skill.
2. **`pareto-planning` ⇄ `full-code-review` duplicate plan output** (above).
3. **Temporary**: skill text says `.md`, this report is `.md`, the proposal says `.html`.
   Resolves itself once Task #4 lands; flagged here so it isn't forgotten.

### Scope creep check

The user asked for reflection + plan + status, **not implementation**. I am deliberately
**not** editing any of the 7 skills in this pass. The skills say "THEN WAIT." Honoring that
boundary is the anti-VERSCHLIMMBESSER move.

---

## 1. Type Model — "Report Artifact" (the honest decision criterion)

The `.md` vs `.html` choice is not aesthetic. It falls out of a small domain model:

```text
Artifact
├── lifecycle : Snapshot | Living          # write-once vs continuously edited
├── audience  : HumanReport | ToolParsed | EndUserDoc
├── format    : HTML | Markdown | SVG | D2
└── mutability: WriteOnce | Append | Upsert
```

**Decision rule (replaces the vibe):**

| lifecycle | audience    | mutability | → format                |
| --------- | ----------- | ---------- | ----------------------- |
| Snapshot  | HumanReport | WriteOnce  | **HTML**                |
| Living    | ToolParsed  | Upsert     | Markdown                |
| Living    | EndUserDoc  | Upsert     | Markdown                |
| Snapshot  | HumanReport | (graph)    | SVG/D2 → inline in HTML |

This makes the exclusions provable, not opinions:
`features-audit`→`FEATURES.md`, `todo-list-builder`→`TODO_LIST.md`,
`docs-freshness-check` are all `Living + Upsert` → **stay Markdown**. Anything that would
break a tool that greps/upserts the file stays `.md`.

---

## 2. Reuse / Libraries (do NOT reinvent)

- **No runtime libs** — the zero-dependency single-file constraint (from `output-guide.md`)
  forbids CDN/JS/build. "Libraries" here means **one shared CSS design-token block**.
- **Reuse `d2` CLI** for graph rendering (already a dependency of `architecture-visualization`).
- **Reuse the existing `output-guide.md`** as the shared spec — do not write a new one.
- **Delegation, not duplication**: `full-code-review` planning → `pareto-planning`.

---

## 3. Status

### a) FULLY DONE ✅

- **Identification pass**: all 18 skills scanned; every output destination catalogued.
- **Decision criterion**: the `Artifact` type model above replaces the heuristic.
- **Precedent validated**: the existing HTML design system (tokens, cards, hero, syntax
  classes, tables) confirmed extractable — `skill-data-model-redesign.html:1-220`.
- **Exclusion list justified**: living docs (`FEATURES.md`, `TODO_LIST.md`) provably stay
  Markdown via the type model.

### b) PARTIALLY DONE 🟡

- **Shared design system**: spec exists (`data-model-review/references/output-guide.md`)
  but is siloed in one skill and has a `.go-*` vs `.ts-*` naming split brain.
- **Tier 1 / Tier 2 conversion list**: identified and ranked, but **zero skills edited**.

### c) NOT STARTED ⬜

- Extracting the shared `assets/report.html` + `references/html-output-guide.md`.
- Editing any of: `status-report`, `pareto-planning`, `full-code-review`, `go-modularize`,
  `code-quality-scan`, `naming-review`, `nix-flake-migration`, `brutal-self-review`.
- Consolidating `full-code-review`'s inlined Pareto into a delegation to `pareto-planning`.
- Adding `allowed-tools: d2` to graph-producing skills.

### d) TOTALLY FUCKED UP! 💥

Nothing destructive. The worst defect is the **latent split-brain**: if we convert skills
to HTML output _before_ extracting the shared design system, we get 7 divergent HTML
dialects instead of 1. **Order matters: shared template first, conversions second.**

### e) WHAT WE SHOULD IMPROVE! 📈

1. Make the design system a **shared asset**, not a per-skill copy.
2. Fix the `.go-*`/`.ts-*` class naming → language-agnostic tokens.
3. Kill the `pareto-planning`/`full-code-review` duplication by delegation.
4. Encode the `Artifact` decision rule into `how-to-write-skills.md` so future authors
   don't re-litigate it.

---

## 4. Execution Plan (Pareto, work-vs-impact sorted)

### The 1% → 51% (do FIRST, unblocks everything)

| # | Task                                                                                                                                                  | Impact  | Effort | Ratio      |
| - | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ---------- |
| 1 | Extract shared `assets/report.html` + `references/html-output-guide.md` from existing HTML + `output-guide.md`; use language-agnostic `.tok-*` tokens | 🔴 High | 30min  | ⭐⭐⭐⭐⭐ |

### The 4% → 64% (highest-leverage conversions + the consolidation)

| # | Task                                                                                                    | Impact  | Effort | Ratio      |
| - | ------------------------------------------------------------------------------------------------------- | ------- | ------ | ---------- |
| 2 | Convert `status-report` → HTML output + point at shared guide                                           | 🔴 High | 20min  | ⭐⭐⭐⭐⭐ |
| 3 | Convert `pareto-planning` → HTML; embed D2→inline SVG; add `allowed-tools: d2`                          | 🔴 High | 25min  | ⭐⭐⭐⭐⭐ |
| 4 | **Consolidate**: make `full-code-review` delegate planning to `pareto-planning` (delete inlined Pareto) | 🔴 High | 20min  | ⭐⭐⭐⭐⭐ |
| 5 | Convert `go-modularize` `PROPOSAL.md`/`EXECUTION_PLAN.md`/`DEPENDENCY_GRAPH.md` → single HTML proposal  | 🟡 Med  | 30min  | ⭐⭐⭐⭐   |

### The 20% → 80% (Tier 2 conversions)

| # | Task                                                                                    | Impact | Effort | Ratio    |
| - | --------------------------------------------------------------------------------------- | ------ | ------ | -------- |
| 6 | Convert `code-quality-scan` → HTML issue table (also fixes its **missing output path**) | 🟡 Med | 25min  | ⭐⭐⭐⭐ |
| 7 | Convert `naming-review` report → HTML (category-colored tables)                         | 🟡 Med | 25min  | ⭐⭐⭐   |
| 8 | Convert `nix-flake-migration` `MIGRATION_TO_NIX_FLAKES_PROPOSAL.md` → HTML              | 🟡 Med | 20min  | ⭐⭐⭐   |
| 9 | Convert `brutal-self-review` improvement plan → HTML                                    | 🟢 Low | 20min  | ⭐⭐     |

### Polish (the long tail)

| #  | Task                                                                         | Impact | Effort | Ratio    |
| -- | ---------------------------------------------------------------------------- | ------ | ------ | -------- |
| 10 | Encode the `Artifact` type-model decision rule into `how-to-write-skills.md` | 🟡 Med | 15min  | ⭐⭐⭐⭐ |
| 11 | Add `allowed-tools` frontmatter to all graph/CLI-dependent skills            | 🟢 Low | 10min  | ⭐⭐⭐   |
| 12 | Add cross-references: converted skills link the shared guide                 | 🟢 Low | 10min  | ⭐⭐     |
| 13 | Update `AGENTS.md` §5 to document the shared HTML design system              | 🟢 Low | 10min  | ⭐⭐     |
| 14 | Update `README.md` skills table to note HTML-output skills                   | 🟢 Low | 5min   | ⭐⭐     |

### Explicitly OUT OF SCOPE (stay Markdown — proven by the type model)

- `features-audit` → `FEATURES.md` (Living + EndUserDoc + Upsert)
- `todo-list-builder` → `TODO_LIST.md` (Living + ToolParsed + Upsert)
- `docs-freshness-check` (mutates the above living docs)

### Execution order & dependency graph

```text
[1] shared template  ──┬─► [2] status-report
                       ├─► [3] pareto-planning ──► [4] full-code-review delegates
                       ├─► [5] go-modularize
                       ├─► [6] code-quality-scan
                       ├─► [7] naming-review
                       ├─► [8] nix-flake-migration
                       └─► [9] brutal-self-review

[10] type-model rule in how-to-write-skills.md  (independent)
[11..14] polish  (after conversions)
```

**Critical path:** Task 1 gates Tasks 2–9. Do not start any conversion until the shared
template exists, or we manufacture 7 divergent dialects (the "TOTALLY FUCKED UP" risk).

---

## 5. Top #1 Question I Cannot Figure Out Myself 🤔

**Should the shared HTML design system live as a new standalone skill
(e.g. `html-report-kit/`) or as a shared `assets/` directory referenced by all skills?**

- The repo's `AGENTS.md` §2 defines `assets/` as **per-skill** ("One directory per skill").
  There is **no cross-skill shared-assets convention** today.
- A new `html-report-kit` skill would give it a discoverable home + a trigger description,
  but it's not really an "activated" skill — it's a reusable asset + spec.
- A top-level `shared/assets/` + `shared/references/` would match the need but breaks the
  "one dir per skill" rule documented in AGENTS.md.

**I recommend** the `html-report-kit/` skill directory (it's loadable, versionable, and
gets its own trigger for "produce a styled HTML report"), but this is a structural decision
with tradeoffs I'd rather you confirm before I create new top-level directories.

---

## 6. Honest Self-Assessment of THIS Report

- I did **not** implement anything — honoring "THEN WAIT FOR INSTRUCTIONS."
- I grounded every claim with file:line evidence or verified by reading.
- I caught and named the latent split-brains instead of papering over them.
- I replaced a heuristic with a type model (the durable improvement).
- The one unverified assumption remaining is in §5 — and I'm asking, not guessing.

**Next action (yours):** approve the §5 structure decision, then I execute Task 1 → 14 in
the listed order, committing after each self-contained step.
