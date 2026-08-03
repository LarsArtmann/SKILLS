# How to Write Great Skills for Crush

Crush follows the [Agent Skills](https://agentskills.io) open standard. A skill is simply a **directory containing a `SKILL.md`** file.

## File Structure

```
my-skill/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable helpers (run without loading into context)
├── references/       # Optional: detailed docs loaded on demand
├── rules/            # Optional: domain-specific rules loaded on demand
└── assets/           # Optional: templates, images, fonts
```

### Subdirectory Guide

| Directory     | When to use                                                               | How the agent accesses it             |
| ------------- | ------------------------------------------------------------------------- | ------------------------------------- |
| `scripts/`    | Deterministic/repetitive tasks (formatters, generators, validators)       | Executes directly — no context cost   |
| `references/` | Large docs the agent may or may not need (framework docs, API references) | Agent reads with `view` when relevant |
| `rules/`      | Domain-specific constraints the agent should follow conditionally         | Agent reads with `view` when relevant |
| `assets/`     | Files used in output (templates, icons, sample data)                      | Agent reads/copies as needed          |

## SKILL.md Format

```yaml
---
name: my-skill # REQUIRED: lowercase, hyphens, matches folder name
description: ... # REQUIRED: what it does AND when to use it (max 1024 chars)
license: ... # Optional
metadata: # Optional
  tags: foo, bar
allowed-tools: ... # Optional: space-separated pre-approved tools
---
# Skill Title

[Instructions the agent follows when this skill activates]
```

## Where to Place Skills

| Scope         | Path                                                   |
| ------------- | ------------------------------------------------------ |
| Project-local | `.agents/skills/`, `.crush/skills/`, `.claude/skills/` |
| Global        | `~/.config/crush/skills/`                              |
| Custom        | Set `options.skills_paths` in `crush.json`             |

## Key Principles

### 1. The `description` is a trigger, not documentation.

It tells the agent _when_ to activate the skill. Agents tend to under-trigger — they skip skills even when they'd be useful. Combat this by being explicit and slightly pushy:

```yaml
# Bad — too vague
description: Helps with React

# Bad — describes what the skill contains
description: A collection of React patterns and best practices.

# Good — specific trigger conditions with pushy language
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI.
```

Include:

- **What the skill does** (so the agent can match the task)
- **Specific trigger phrases** (exact words users might say)
- **Adjacent contexts** (related tasks where the skill should still fire)

### 2. The SKILL.md body is the procedure.

The agent reads the full body _only after_ the description triggers activation. Write it as **step-by-step instructions** — the agent follows them literally:

```markdown
# Bad — describes knowledge

This skill knows about architecture patterns.

# Good — tells the agent what to do

1. Read the project's CONTEXT.md and docs/adr/ first.
2. Use the Agent tool to walk the codebase.
3. Present a numbered list of deepening opportunities.
4. Ask the user which to explore before proceeding.
```

### 3. Use progressive disclosure.

Skills use a three-level loading system:

| Level                 | What's loaded                       | Cost                                |
| --------------------- | ----------------------------------- | ----------------------------------- |
| **Metadata**          | name + description                  | ~100 words, always in context       |
| **SKILL.md body**     | Full instructions                   | <500 lines ideal, loaded on trigger |
| **Bundled resources** | `references/`, `rules/`, `scripts/` | Unlimited, loaded on demand         |

Keep `SKILL.md` under ~500 lines. Move detailed material into subdirectories and reference them with relative links:

```markdown
For silence detection, load the [./rules/silence-detection.md](./rules/silence-detection.md) file.
```

The agent will use `view` to read these files on demand, keeping initial context small.

For large reference files (>300 lines), include a table of contents at the top.

### 4. Explain the why, not just the what.

Modern agents are smart — they benefit from understanding _why_ a step matters, not just being told to do it:

```markdown
# Bad — rigid rule

ALWAYS read package.json before editing dependencies.

# Good — explained reasoning

Read package.json before editing dependencies. This avoids version conflicts
and ensures you're using libraries the project already has rather than
introducing new ones.
```

Avoid heavy-handed `ALWAYS`/`MUST`/`NEVER` directives when a clear explanation achieves the same goal. The agent follows reasoned instructions more reliably than rigid rules.

### 5. Constrain the agent's decision space.

The best skills narrow what the agent has to figure out on its own:

- **Exact commands**: `npx create-video@latest --yes --blank --no-tailwind` instead of "set up a Remotion project"
- **Glossaries**: define domain terms so the agent uses consistent terminology
- **Decision trees**: map out common scenarios with clear branches
- **Anti-patterns**: state what NOT to do explicitly

### 6. Define output formats with examples.

When the skill produces structured output, define the exact format:

```markdown
## Report structure

**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

Templates and examples eliminate ambiguity and produce consistent results across sessions.

#### Choosing the Output Format: HTML vs Markdown

Not all output should be Markdown. Use this decision rule:

| lifecycle | audience    | mutability | → format |
| --------- | ----------- | ---------- | -------- |
| Snapshot  | HumanReport | WriteOnce  | **HTML** |
| Living    | ToolParsed  | Upsert     | Markdown |
| Living    | EndUserDoc  | Upsert     | Markdown |

- **Snapshot reports** (status updates, reviews, plans, proposals, audits) are written
  once, read by humans, and never edited again → **HTML** with the shared
  [`html-report-kit`](./html-report-kit/SKILL.md) design system.
- **Living docs** (`FEATURES.md`, `TODO_LIST.md`, `AGENTS.md`) are continuously edited,
  parsed by tooling, and kept up-to-date → **Markdown**.

Never convert a living doc to HTML — it breaks tools that grep, upsert, or
incrementally edit the file.

**Referencing the kit from a consumer skill:** consumer skills must NOT point at
`../html-report-kit/` — that sibling path breaks under per-skill install
(`bunx skills add <repo>@<one-skill>` copies only one directory, so the sibling
vanishes). The kit is **vendored** into each consumer's `assets/html-report-kit/`;
reference it intra-skill as `./assets/html-report-kit/references/html-output-guide.md`
and `./assets/html-report-kit/assets/report-template.html`. Edit the canonical
`html-report-kit/` at the repo root, then run `./scripts/sync-html-kit.sh` to
propagate to all consumers (use `--check` in CI). See `AGENTS.md` §5.9.

## Organizing Multi-Domain Skills

When a skill covers multiple frameworks or variants, organize by domain so the agent loads only what's relevant:

```
cloud-deploy/
├── SKILL.md              # Workflow + framework selection logic
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

In SKILL.md, include decision logic:

```markdown
## Select the right reference

1. Check which cloud provider the project uses (look for config files, deployment scripts).
2. Load only the matching reference file:
   - AWS: [./references/aws.md](./references/aws.md)
   - GCP: [./references/gcp.md](./references/gcp.md)
   - Azure: [./references/azure.md](./references/azure.md)
```

## Proven Patterns from Real Skills

| Pattern                                        | Example                                                                            | Why It Works                                                |
| ---------------------------------------------- | ---------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| **Design thinking framework**                  | `frontend-design` — defines aesthetic analysis steps before coding                 | Forces the agent to think before acting                     |
| **Glossary + domain language**                 | `improve-codebase-architecture` — enforces precise terms                           | Consistent output across sessions                           |
| **Multi-phase process**                        | Explore → Present candidates → Iterate loop                                        | Structures complex tasks                                    |
| **Rule files per topic**                       | `remotion-best-practices` — 30+ `rules/*.md` files                                 | Progressive disclosure; agent loads only what's needed      |
| **Bundled scripts**                            | `skill-creator` — grading, benchmarking, packaging scripts                         | Eliminates redundant work on every invocation               |
| **Pre-flight checks**                          | `website-launch` — verifies credentials before writing any files                   | Surfaces blockers early, prevents wasted work               |
| **Common mistakes reference**                  | `docs-health` — `references/common-mistakes.md`                                    | Prevents the same errors from recurring across sessions     |
| **Commit checkpoints**                         | `website-launch` — defines mandatory commit points per phase                       | Prevents catastrophic loss of uncommitted work              |
| **Visual QA gate**                             | `website-launch` — verifies rendered output before declaring done                  | Catches broken layouts, missing assets, CSS errors          |
| **Restraint / Verschlimmbesserung prevention** | `update-old-docs` — "so what?" test, per-file judgment, non-destructive annotation | Stops well-intentioned batch edits from making things worse |

## Essential Skill Patterns (Learned from Real Sessions)

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
recurring failure mode — well-documented in the `update-old-docs` incident —
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

Example: `update-old-docs` applies all four when bringing many old status
reports current. `docs-health` cross-links to it whenever AUDIT mode touches
many files. The rule "all" means "no file that NEEDS updating is missed," NOT
"every file gets a change." Restraint is success.

### Pattern 8: Cross-Skill Handoff Notes

When a skill produces a **point-in-time artifact** (a status report, plan,
review, audit) whose most valuable output is **forward-looking** — "next
tasks," recommendations, an action roadmap, "debt to ticket" — that output is
the primary input for another skill. If the producing skill ends with "WAIT
FOR INSTRUCTIONS" and never names the consumer, the forward items get
**entombed** in a timestamped file no later session reads. This is the #1
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
   handoff (HARVEST pulls items OUT) and the backward handoff (`update-old-docs`
   annotates the report itself) are different directions, both needed.

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

The canonical incident: `update-old-docs` had "appendix-only is the #1 failure
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

Known skills currently exhibiting this anti-pattern (as of 2026-08-04):
`go-ecosystem-upgrade` (build-only verification buried at line 148) and
`docs-health` (HARVEST-skipping buried at line 172). Both need the failure mode
surfaced in their intro.

---

## Common Mistakes

- **Vague descriptions** — the agent never activates the skill because it doesn't know when to
- **Description as documentation** — describing what the skill _contains_ instead of when to _use_ it
- **Too long SKILL.md** — wastes context tokens on every activation; split into `references/`
- **Narrative/prose instructions** — write imperative steps, not essays
- **Missing trigger keywords** — if users say "refactor" but your description only says "architecture", the agent won't match
- **No file references** — cramming everything into one file instead of using progressive disclosure
- **Heavy-handed MUSTs** — overusing ALL CAPS directives instead of explaining reasoning
- **No examples** — describing output formats without showing concrete examples

## Testing Your Skill

Skills benefit from iteration. After drafting:

1. **Write 2-3 realistic test prompts** — the kind of thing a real user would say, not abstract unit tests
2. **Run them against the skill** — use the skill yourself or use the `skill-creator` skill to automate this
3. **Evaluate both qualitatively and quantitatively** — does the output meet expectations? Does the skill trigger when it should?
4. **Iterate** — fix issues, generalize from feedback, re-test

For skills with objectively verifiable outputs (file transforms, data extraction, code generation), set up test cases with assertions. For subjective outputs (writing style, design quality), rely on human review.

Use the `skill-creator` skill for a full eval/benchmarking workflow with automated iteration.

## Minimal Starter Template

```yaml
---
name: my-skill
description: Use this skill when the user asks to [specific trigger]. Provides [what it provides].
---

# My Skill

## When to use
[Clarify trigger conditions beyond the description]

## Process
1. [Step 1 — what to read/examine first]
2. [Step 2 — what to do]
3. [Step 3 — how to present results]

## Rules
- [Specific constraints]
- [What to avoid]

## References
- [./references/details.md](./references/details.md) — [when to load this]
```
