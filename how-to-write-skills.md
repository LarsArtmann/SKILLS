# How to Write Great Skills for Crush

Crush follows the [Agent Skills](https://agentskills.io) open standard. A skill is simply a **directory containing a `SKILL.md`** file.

## File Structure

```
my-skill/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable helpers
├── references/       # Optional: detailed docs
├── rules/            # Optional: domain-specific rules (see remotion skill)
└── assets/           # Optional: templates, images
```

## SKILL.md Format

```yaml
---
name: my-skill          # REQUIRED: lowercase, hyphens, matches folder name
description: ...         # REQUIRED: what it does AND when to use it (max 1024 chars)
license: ...             # Optional
metadata:                # Optional
  tags: foo, bar
allowed-tools: ...       # Optional: space-separated pre-approved tools
---

# Skill Title

[Instructions the agent follows when this skill activates]
```

## Where to Place Skills

| Scope | Path |
|---|---|
| Project-local | `.agents/skills/`, `.crush/skills/`, `.claude/skills/` |
| Global | `~/.config/crush/skills/` |
| Custom | Set `options.skills_paths` in `crush.json` |

## Key Principles for Writing Effective Skills

### 1. The `description` is a trigger, not documentation.

It tells the agent *when* to activate the skill. Be specific about triggering conditions:

```yaml
# Bad — too vague
description: Helps with React

# Good — specific trigger conditions
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI.
```

### 2. The SKILL.md body is the actual procedure.

The agent reads the full body *only after* activation. Write it as **step-by-step instructions** — the agent follows them literally:

- What to read first
- What commands to run
- What patterns to follow
- Decision trees for different scenarios

### 3. Use progressive disclosure.

Keep `SKILL.md` under ~500 lines. Move detailed reference material into `references/` or `rules/` subdirectories and reference them with relative links:

```markdown
For silence detection, load the [./rules/silence-detection.md](./rules/silence-detection.md) file.
```

The agent will use `view` to read these files on demand, keeping initial context small.

### 4. Write imperative instructions, not descriptions.

```markdown
# Bad — describes knowledge
This skill knows about architecture patterns.

# Good — tells the agent what to do
1. Read the project's CONTEXT.md and docs/adr/ first.
2. Use the Agent tool to walk the codebase.
3. Present a numbered list of deepening opportunities.
4. Ask the user which to explore before proceeding.
```

### 5. Constrain and guide the agent's behavior.

The best skills narrow the agent's decision space:

- Specify exact commands (`npx create-video@latest --yes --blank --no-tailwind`)
- Define a glossary so the agent uses consistent terminology
- Provide decision trees for common scenarios
- State what NOT to do explicitly

## Proven Patterns from Real Skills

| Pattern | Example | Why It Works |
|---|---|---|
| **Design thinking framework** | `frontend-design` — defines aesthetic analysis steps before coding | Forces the agent to think before acting |
| **Glossary + domain language** | `improve-codebase-architecture` — enforces precise terms | Consistent output across sessions |
| **Multi-phase process** | Explore → Present candidates → Grilling loop | Structures complex tasks |
| **Rule files per topic** | `remotion-best-practices` — 30+ `rules/*.md` files | Progressive disclosure; agent loads only what's needed |
| **References to external files** | `./references/INTERFACE-DESIGN.md` | Keeps SKILL.md focused |

## Common Mistakes

- **Vague descriptions** — the agent never activates the skill because it doesn't know when to
- **Too long SKILL.md** — wastes context tokens on every activation; split into `references/`
- **Narrative/prose instructions** — write imperative steps, not essays
- **Missing trigger keywords** — if users say "refactor" but your description only says "architecture", the agent won't match
- **No file references** — cramming everything into one file instead of using progressive disclosure

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
