# Skill Patterns (Learned from Real Sessions)

> Moved verbatim from the SKILL.md entry point (2026-11-23, T94): the eleven
> pattern bodies are detail-on-demand; the entry point keeps the summary table.

These patterns were identified from analyzing 80+ session feedback files
across the LarsArtmann project ecosystem. Each pattern prevents a class of
recurring mistake. Include them in skills where applicable.

### Pattern 1: Pre-flight Checks

Skills that depend on external infrastructure (credentials, API keys,
network access, tool availability) MUST verify those dependencies before
investing time in work. This is the single highest-impact pattern — it
prevents "discovered too late" blockers.

```markdown
## Phase 0: Pre-flight Checks

Before writing any code, verify:

1. Are the required credentials present and valid?
2. Are the required tools installed?
3. Are there naming collisions with existing resources?

If any check fails, surface it to the user immediately.
```

Example: The `website-launch` skill checks Namecheap API keys, Firebase
project existence, and domain collisions before creating any website
files. Prior sessions discovered credential blockers only after writing
50+ files.

### Pattern 2: Commit Checkpoints

Skills that produce significant work (file creation, multi-phase
processes) MUST define mandatory commit points. Multiple sessions have
ended with all work existing only on disk — one unexpected session end
and everything is lost.

```markdown
## Commit Discipline

Commit at these checkpoints:

1. After Phase 1 is verified stable
2. After Phase 2 builds successfully
3. After deployment is confirmed live

Never leave a session with uncommitted work. Even WIP commits are better
than none.
```

### Pattern 3: Common Mistakes Reference

Every skill that covers a repeatable workflow SHOULD have a
`references/common-pitfalls.md` file documenting known failure modes.
This prevents the same mistakes from recurring across sessions.

The pattern is simple: when a session hits a problem, document it in the
skill's common-pitfalls reference. The next session loads the skill and
avoids the trap.

Example: `docs-health/references/common-mistakes.md` documents
README-claim inflation, TODO vs ROADMAP confusion, and verification
shortcuts. `website-launch/references/common-pitfalls.md` documents Vite
override breakage, MDX escaping, missing lock files, and 13 more.

### Pattern 4: Visual QA Gate

Skills that produce visual output (websites, HTML reports, diagrams) MUST
include a verification step that checks the rendered output, not just the
build success. A successful build does not mean the output is correct.

```markdown
### Visual QA (mandatory)

After building, verify at minimum:

- Key pages return HTTP 200
- CSS variables resolved (grep for expected tokens)
- No broken asset references

If browser access is available, visually check layout, icons, and
responsive behavior.
```

### Pattern 5: Verify Code Examples Against Source

Skills that involve writing code examples in documentation MUST instruct
the agent to verify function signatures against the actual source code.
The #1 documentation mistake is writing code from memory that doesn't
compile.

```markdown
Before writing any code example:

1. grep the function signature from the source
2. Check return type (pointer vs value)
3. Check parameter types (struct vs \*struct)
4. Check method receiver type (value vs pointer)
```

### Pattern 6: Feedback-Driven Skill Creation

When the same workflow is performed 2+ times and produces feedback files
documenting the same problems, that workflow MUST be encoded as a skill.
Leaving feedback unconverted means every future session repeats the same
mistakes.

The feedback-to-skill conversion process:

1. Identify the recurring workflow (appears in 2+ feedback files)
2. Extract the deterministic parts (copy verbatim, customize fields)
3. Extract the known gotchas (pre-flight checks, common pitfalls)
4. Create the skill with references for detailed material
5. Mark feedback files as processed

### Pattern 7: Restraint & Verschlimmbesserung Prevention

When a skill modifies MANY files at once, it MUST enforce restraint. The
recurring failure mode — well-documented in the docs-health ANNOTATE incident —
is an agent optimizing for "touched every file" instead of "every change
helped," shipping 58 identical generic banners that say nothing and have to be
rolled back.

Include these guardrails in any bulk-edit skill:

1. **Read all targets before editing any** — understand before transforming
2. **Per-file decision** (CHANGE / SKIP / LEAVE ALONE) recorded as a list — the
   list IS the plan
3. **The "so what?" test** — every change must answer "what does a reader DO
   with this?" Generic changes that could apply to any file are noise; delete them
4. **Verify output quality, not process quality** — re-read each change from a
   skeptical reader's perspective

Example: `docs-health` ANNOTATE mode applies all four when bringing many old status
reports current. The rule "all" means "no file that NEEDS updating is missed," NOT
"every file gets a change." Restraint is success.

### Pattern 8: Cross-Skill Handoff Notes

When a skill produces a **point-in-time artifact** (a status report, plan,
review, audit) whose most valuable output is **forward-looking** — "next
tasks," recommendations, an action roadmap, "debt to ticket" — that output is
the primary input for another skill. If the producing skill ends with "WAIT
FOR INSTRUCTIONS" and never names the consumer, the forward items get
**entombed** in a timestamped file that no later session reads. This is the #1
cause of `TODO_LIST.md` staleness across long sessions.

Include a handoff note at the end of any report/plan/review skill:

1. **Name the consumer** — "section (f) is the primary input for
   `docs-health` HARVEST," not a vague "consider updating your TODO list."
2. **State the rule once, canonically, in the consuming skill** — and have
   every producer **link rather than restate**. Duplicate rationale across N
   skills is a split brain: edit one, the rest drift. Mark the canonical
   location (e.g. docs-health "When to run HARVEST") as the single source of
   truth.
3. **Pair it with the backward note** — reports also go stale; the forward
   handoff (HARVEST pulls items OUT) and the backward handoff (ANNOTATE
   annotates the report itself) are different directions within docs-health, both needed.

Example: `status-report`, `pareto-planning`, `full-code-review`, and
`architecture-review` each end with a short HARVEST pointer linking to
`docs-health`. The regression guard in `scripts/check-skills.sh` (the
"cross-skill handoff guard") fails if any of these links disappears, so the
loop cannot silently reopen.

### Pattern 9: Surface the Primary Failure Mode in the tl;dr

When a skill has a named **#1 failure mode** — a specific mistake that recurs
across sessions and that the skill's entire structure is designed to prevent —
that failure mode MUST appear in the tl;dr or the first ~10 lines. Agents plan
from the tl;dr; a failure mode buried 200 lines deep is functionally invisible
under execution pressure.

The canonical incident: docs-health ANNOTATE (formerly `update-old-docs`) had "appendix-only is the #1 failure
mode" buried at line 278. An agent processing a 41-file batch read the tl;dr
("inline edits or end-of-file appendices"), concluded both were equal, and
produced zero inline markers across all 41 files. The fix was rewriting tl;dr
line 5 to name the hierarchy explicitly: "Resolve numbered items inline first
... Appendix-only is the #1 failure mode."

Audit checklist for any skill with a named failure mode:

1. **Name it in the tl;dr** — if the failure mode has a name (Verschlimmbesserung,
   trophy-case, appendix-only, cargo-cult), use it. A named failure mode is
   easier to remember and self-check against.
2. **State the ranking** — "the #1 failure mode" or "the dominant mistake" tells
   the agent where to focus vigilance. An unranked list of anti-patterns invites
   equal attention to minor and major risks.
3. **Give the one-line guardrail** — the tl;dr should contain the single
   sentence that prevents the failure, not just the label.

Fixed examples (as of 2026-08-04): `docs-health` ANNOTATE (appendix-only trap
surfaced in body), `go-ecosystem-upgrade` (build-only verification
surfaced in intro), `docs-health` (HARVEST-skipping surfaced in intro).

### Pattern 10: Condense Without Eroding Teaching Weight

When a SKILL.md exceeds the 500-line budget, the instinct is to start cutting
prose until the line count drops. This is the #1 condensing mistake: agents cut
the _teaching weight_ (analogies, concrete numbers, named examples) that makes
rules stick, leaving behind correct-but-flat instructions that an agent can skim
past under execution pressure.

The condensing checklist (do these IN ORDER):

1. **Move all worked examples to `references/`** — before touching a single line
   of body prose, identify every code block, before/after example, and worked
   scenario. Relocate them to reference files. Leave a one-line pointer in the
   body: `See [./references/examples.md](./references/examples.md)`.
2. **Move anti-pattern catalogs to `references/`** — anti-pattern lists grow
   with every feedback round. They are lookup material, not planning material.
   Keep the top 1–2 in the body (the named failure modes); push the rest to a
   reference file.
3. **THEN trim prose** — only after examples and anti-patterns are extracted,
   review the remaining body for redundancy. Now you are cutting duplication,
   not teaching weight.
4. **Verify nothing was lost** — re-read the condensed body end-to-end. Does it
   still give enough guidance for an agent to execute? Are the named failure
   modes still visible? If the condensing removed the _reason_ behind a rule,
   restore it — rules without reasons are ignored.

The root cause of the condensing-erodes-teaching cycle: every feedback round
adds ~40-60 lines of worked examples and anti-patterns to the body. The 500-line
budget cannot hold them all. The structural fix is _references-first_, not
_trimming harder_.

Example: `docs-health` ANNOTATE went from 500→166 lines by moving all worked
examples, anti-pattern catalogs, and format-variant guides to `references/`.
The body kept only: decision logic, the format grammar, the #1 failure mode, and
pointers. Each rule is stated exactly once.

### Pattern 11: Disambiguate Competing Skills in the Description

When two skills have overlapping trigger phrases, the agent may activate the
wrong one or get paralyzed. This is especially common among review/audit skills
(`full-code-review` vs `code-quality-scan` vs `architecture-review`) and
reporting skills (`status-report` vs `docs-health`).

Add a "Distinct from" clause at the end of the `description` field:

```yaml
description: >
  [trigger phrases + what the agent will do]. Distinct from [competing-skill]
  ([one-sentence difference — what makes THIS skill the right pick]).
```

Rules:

1. **Name the competitor explicitly** — "Distinct from full-code-review" is
   clearer than "Distinct from broader review skills."
2. **State the axis of difference** — "automated tool scan, no manual reading"
   vs "human-style file-by-file review." The user needs to know _which_ skill
   for _which_ job.
3. **Both sides should disambiguate** — if skill A names skill B, skill B
   should name skill A. One-sided disambiguation is half a solution.
4. **Keep it under 1024 chars** — the description limit still applies. The
   disambiguation clause should be 1–2 sentences, not a paragraph.

Example pairs (as of 2026-08-04):

- `code-quality-scan` vs `full-code-review` vs `deduplicate-code` (three-way)
- `architecture-review` vs `full-code-review`
- `status-report` vs `docs-health`

---

## Patterns adopted from humanlayer/skills (2026-11-24)

Patterns 12–17 were distilled from `github.com/humanlayer/skills` (MIT),
not from our session feedback. Every quote below was re-read in a local
clone at commit `4d69d20` before encoding (epistemic hygiene); the full
repo analysis lives in
`docs/status/2026-11-24_06-24_humanlayer-skills-analysis-adopted-patterns.md`.
Adopt only where the trigger applies — they are additions to the canon,
not replacements for Patterns 1–11.

### Pattern 12: Completion criterion per step

Every numbered step in a procedure ends with an observable condition, not
just an action. A step is done when its criterion holds, not when its verbs
have been performed — this makes procedures self-verifying without a
separate test pass.

```markdown
2. Determine the repo's validation commands.
   Completion criterion: you can name the repo's package manager, install
   command, likely validation commands, and existing workflow conventions.
```

Source applies it to every step, including interview steps ("every
placeholder … has a chosen value or an explicit default").

### Pattern 13: Final-answer template

When a skill's closing message matters (phase handoffs, reports, PR
bodies), ship a literal template for it that includes the exact next
command to run. This makes handoffs copy-pasteable and consistent across
sessions — the next phase starts from a known script, not from whatever
the agent improvised last time.

```text
The usual next step is a TDD to describe how to build it:

    <invocation> make a TDD <task-directory>; flow: prd

Run it here, after compaction, or in a new session.
```

Mechanics: a `*_final_answer*.md` template lives next to the phase's
process; the last process step is "Respond using that final answer
template."

### Pattern 14: Findings headers assert what is true

In research/review output, section headers state the finding, not the
topic. "Workers restore pending jobs before accepting new work" carries
the conclusion; "Worker startup" carries only a subject. A reader skimming
headers alone walks away with the findings.

> "Give findings sections headers that assert what is true. A reader should
> understand the main findings by skimming the headers alone."

Apply to status reports, review output, research docs — anywhere headers
summarize sections.

### Pattern 15: Slot budgets in templates

When a skill fills a template, give each slot a size budget and an explicit
empty value. Without a budget every slot balloons to whatever fits the
context window; without an empty convention, absent content becomes
fabricated content.

> "Keep \*\*Why the change\*\* to exactly one sentence." /
> "Write `- None.` when there are no special considerations."

Works with the Artifact decision rule (Principle 6): budgets constrain
human-read output; tool-parsed output needs exact schemas instead.

### Pattern 16: One question per message, with a recommendation

Interview-style skills ask exactly one question per turn, frame it as 2-3
options with tradeoffs plus a recommendation, then wait. Multiple
questions in one message get partial answers; a question without a
recommendation delegates the analysis back to the user.

> "Ask one question per message and wait for the answer."
> "Present one product decision at a time with two or three options,
> tradeoffs, and a recommendation."

Pairs with stop-points: name the condition that must be answered before
the next step runs.

### Pattern 17: Provenance frontmatter on artifacts

Reports pin the code state they were produced against. A claim of
"verified at HEAD" goes stale the moment HEAD moves; a pinned sha keeps
the report falsifiable afterwards.

```yaml
repos:
  - identifier: <repo>
    sha: <commit>
```

Source enforces the field pair structurally (their template test asserts
every `_template.md` carries exactly `identifier` + `sha`). Our status
reports pin the sha in the scope line instead of frontmatter — same rule,
Markdown-native shape.
