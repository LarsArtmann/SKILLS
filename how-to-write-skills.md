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

| lifecycle | audience    | mutability | → format   |
| --------- | ----------- | ---------- | ---------- |
| Snapshot  | HumanReport | WriteOnce  | **HTML**   |
| Living    | ToolParsed  | Upsert     | Markdown   |
| Living    | EndUserDoc  | Upsert     | Markdown   |

- **Snapshot reports** (status updates, reviews, plans, proposals, audits) are written
  once, read by humans, and never edited again → **HTML** with the shared
  [`html-report-kit`](./html-report-kit/SKILL.md) design system.
- **Living docs** (`FEATURES.md`, `TODO_LIST.md`, `AGENTS.md`) are continuously edited,
  parsed by tooling, and kept up-to-date → **Markdown**.

Never convert a living doc to HTML — it breaks tools that grep, upsert, or
incrementally edit the file.

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

| Pattern                        | Example                                                            | Why It Works                                           |
| ------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------ |
| **Design thinking framework**  | `frontend-design` — defines aesthetic analysis steps before coding | Forces the agent to think before acting                |
| **Glossary + domain language** | `improve-codebase-architecture` — enforces precise terms           | Consistent output across sessions                      |
| **Multi-phase process**        | Explore → Present candidates → Iterate loop                        | Structures complex tasks                               |
| **Rule files per topic**       | `remotion-best-practices` — 30+ `rules/*.md` files                 | Progressive disclosure; agent loads only what's needed |
| **Bundled scripts**            | `skill-creator` — grading, benchmarking, packaging scripts         | Eliminates redundant work on every invocation          |

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
