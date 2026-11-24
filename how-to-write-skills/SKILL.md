---
name: how-to-write-skills
description: >-
  Use when authoring, editing, or reviewing skills in the LarsArtmann/SKILLS
  repo: creating a new skill directory, writing or fixing a SKILL.md
  frontmatter/description/body, restructuring or splitting references,
  condensing a bloated skill, adding eval harnesses, or deciding where new
  content belongs. Triggers on "how to write skills", "make this a skill",
  "improve this skill", "this skill never activates", "split this SKILL.md",
  "write a good description". Owns the house canon: description-as-trigger,
  progressive disclosure, signal density (Principle 7 + the glossary), the
  eleven session-learned patterns plus six adopted from humanlayer/skills
  (2026-11-24), eval-harness shapes, the Artifact decision
  rule (HTML vs Markdown), and install-don't-wrap. For generic third-party
  skill-creation guidance (the upstream skill-creator skill) this is the
  repo-specific authority — prefer it inside this repo.
metadata:
  tags: skill-authoring, frontmatter, description, progressive-disclosure
---

# How to Write Great Skills for Crush

Crush follows the [Agent Skills](https://agentskills.io) open standard. A skill is simply a **directory containing a `SKILL.md`** file.

## Table of Contents

- [File Structure](#file-structure) — directory layout and the subdirectory guide
- [SKILL.md Format](#skillmd-format) — required frontmatter and body anatomy
- [Where to Place Skills](#where-to-place-skills) — install locations and runtime resolution
- [Key Principles](#key-principles) — the rules behind every good skill, with bad/good examples
- [Organizing Multi-Domain Skills](#organizing-multi-domain-skills) — splitting big domains into SKILL.md + references
- [Proven Patterns from Real Skills](#proven-patterns-from-real-skills) — recurring structural patterns worth copying
- [Essential Skill Patterns](#essential-skill-patterns-learned-from-real-sessions) — session-learned patterns (triggers, disambiguation, condensing)
- [Common Mistakes](#common-mistakes) — the failure modes every new skill author hits
- [Testing Your Skill](#testing-your-skill) — how to verify a skill actually triggers and works
- [Hard-Won Process Lessons](#hard-won-process-lessons) — the most-re-hit rules; full dated catalog in [./references/process-lessons.md](./references/process-lessons.md)
- [Minimal Starter Template](#minimal-starter-template) — copy-paste starting point

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
description: ... # REQUIRED: WHEN to activate — trigger context, not a skill description (max 1024 chars)
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

### The runtime-symlink install model (multi-agent machines)

An agent's global skill dir is a **delivery layer, not a source**. The
scalable pattern on a machine running several agents (Crush, Codex, Cursor,
...): keep ONE editable checkout of your skills repo, and make each runtime
dir hold a **relative symlink** per skill
(`~/.agents/skills/<name>` → `../../projects/SKILLS/<name>`; other runtimes
chain through it). Consequences worth encoding early:

- Edits in the repo are live in every agent instantly — no sync step, no
  drift possible. A copy-based model (`rsync`, duplicate dirs) reintroduces
  exactly the drift the links eliminate.
- The Agent Skills spec has **no dependency system**: a per-skill install
  (`skills add owner/repo@one-skill`) copies only that one directory, so
  never reference sibling skills by `../other-skill/...` file paths — link
  by skill NAME and let each skill vendor what it needs.
- Always read AND edit through the repo path. Editing through a runtime
  symlink path trips "file modified since read" guards and confuses
  diff tracking.
- Skill discovery is a session-start snapshot: a freshly installed skill is
  invisible to already-running sessions — probe a new session before
  concluding an install failed.

### Install, don't wrap: check for an installer before authoring

When a task makes you want a skill around a third-party tool or a URL you
keep pasting, stop: check whether the tool already ships an installer or
official skill first (`skills add <owner>/<repo>`, the tool's own `install`
command, its docs). Author a local skill only when nothing upstream exists.

- **Why:** a wrapper restates the upstream instruction set, so it drifts the
  moment upstream ships. The 2026-10-30 modern-web-guidance wrapper was
  authored, found redundant against the installed CLI's own instruction
  set, and reverted the same day.
- **When layering IS right:** add mechanics the upstream file does not
  contain (design-to-code under frontend-design), or fork deliberately when
  upstream is broken on your machine (architecture-deepening) — then the
  local file owns the job and upstream is not installed alongside.
- **Pointer rule for layered skills:** the repo skill must say which
  installed skill owns the adjacent territory and must NOT restate the
  third-party body — per-skill installs make that body invisible to your
  readers, so any restatement drifts silently.

## Key Principles

### 1. The `description` is trigger context — it tells the agent _when_ to use the skill.

It is **not** a description of the skill itself, its contents, or its purpose. If you read only the `description`, you should know exactly what user task makes this skill load. Agents tend to under-trigger — they skip skills even when they'd be useful — so be explicit and slightly pushy:

```yaml
# Bad — too vague
description: Helps with React

# Bad — describes what the skill contains
description: A collection of React patterns and best practices.

# Bad — describes the skill itself instead of the trigger
description: A self-contained HTML report design system for skill-generated dashboards.

# Good — specific trigger conditions with pushy language
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI.

# Good — trigger-first, then what the agent will do
description: Use when the user asks to write, review, audit, improve, or fix naming in their codebase. Covers data-model names (types, structs, classes, interfaces, enums, fields, properties) and function names (methods, procedures). Triggers on "naming review", "bad names", "rename identifiers", "naming conventions", "naming smells", or any identifier-naming question.
```

Include:

- **When to activate** — the user task, phrase, or context that should load this skill
- **Specific trigger phrases** (exact words users might say)
- **Adjacent contexts** (related tasks where the skill should still fire)
- **What the agent will do** (just enough to confirm it is the right tool)

Use this quick test before finalizing a description:

| Question                                                                | Pass |
| ----------------------------------------------------------------------- | ---- |
| Does it start with the user's task or a trigger phrase?                 | Yes  |
| Could it be mistaken for a README sentence or feature list?             | No   |
| Does it mention concrete words a user would actually say?               | Yes  |
| Does it say what the agent will do, not what the skill _is_?            | Yes  |
| Does it promise the outcome — what the user gets, why worth the effort? | Yes  |

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

- **Exact commands**: `pnpm dlx create-video@latest --yes --blank --no-tailwind` instead of "set up a Remotion project"
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
  [`html-report-kit`](../html-report-kit/SKILL.md) design system.
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

### 7. Signal density: every line must map to a physical action.

A skill exists to change what the agent does. Before any line stays in a
`SKILL.md`, answer one question:

> **What tool call, file read, command, or decision branch does this line produce?**

If the answer is "none — it explains the skill to itself," delete it. Four
consequences:

| Rule                  | Cut                                                                    | Keep                                                                   |
| --------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| **Lead with signal**  | "This skill encodes lessons from 6 prior sessions…" self-justification | the first step the agent executes                                      |
| **Physical action**   | an abstract principle with no corresponding step                       | the exact command, file, or branch the principle implies               |
| **Behavior change**   | prose that reads well but flips no decision                            | the reason behind a rule, compressed into one clause next to that rule |
| **Clear over clever** | invented jargon left undefined                                         | the packaged name **plus a plain gloss on first use** (Pattern 9)      |

**Keep the why, drop the essay.** A compressed reason changes behavior ("run
`go test`, not `go build` — compilation proves nothing about behavior"); a
proud paragraph does not. Attach the reason to its rule, never leave it as a
standalone essay. This is the boundary against Pattern 10: signal density
cuts self-narration and decoration, not teaching weight.

**Review checklist** — run `scripts/check-skills.sh --signal` to surface
candidates (advisory: it points at lines, you make the call):

- [ ] The first screen after the title carries the procedure entry point or the #1 failure mode — not a preamble.
- [ ] Every paragraph implies an action. Paragraphs that only describe the skill are deleted.
- [ ] Every named failure mode carries a plain-language gloss at first use.
- [ ] No sentence survives only because it sounds good.

**Before / After**

Bad — self-justification, zero actions:

> This skill encodes lessons from 6+ prior sessions that each wasted 45–90
> minutes rediscovering the same pattern. Following this skill turns a
> 90-minute multi-agent exploration into a 25-minute scaffold task.

Good — deleted. It told the agent nothing to do. The steps below were already
signal; the paragraph was the noise.

#### House jargon — the canonical glossary

Named failure modes are load-bearing (Pattern 9), but a name the reader cannot
decode is noise. Gloss every one at first use; keep the wording identical to
this table so the same term never gets two definitions (a split brain about
split brains).

| Term                    | Plain meaning                                                                       |
| ----------------------- | ----------------------------------------------------------------------------------- |
| **split brain**         | the same concept defined or configured in two places, so the two drift apart        |
| **ghost system**        | a capability that exists in the repo but was never wired into the product           |
| **cargo-cult**          | copying a fix or pattern without checking whether its original reason applies here  |
| **trophy-case**         | marking work done to look finished without verifying it works                       |
| **Verschlimmbesserung** | a well-intentioned edit that makes things worse (the docs-health ANNOTATE incident) |
| **entombed**            | written into a timestamped file that no later session reads                         |
| **epistemic hygiene**   | verifying a claim before acting on it or repeating it                               |
| **false green**         | a check that reports success without having measured anything                       |

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

| Pattern                                        | Example                                                                                                         | Why It Works                                                               |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| **Design thinking framework**                  | `frontend-design` — defines aesthetic analysis steps before coding                                              | Forces the agent to think before acting                                    |
| **Glossary + domain language**                 | `architecture-deepening` — enforces precise terms                                                               | Consistent output across sessions                                          |
| **Multi-phase process**                        | Explore → Present candidates → Iterate loop                                                                     | Structures complex tasks                                                   |
| **Rule files per topic**                       | `remotion-best-practices` — 30+ `rules/*.md` files                                                              | Progressive disclosure; agent loads only what's needed                     |
| **Bundled scripts**                            | `skill-creator` — grading, benchmarking, packaging scripts                                                      | Eliminates redundant work on every invocation                              |
| **Pre-flight checks**                          | `website-launch` — verifies credentials before writing any files                                                | Surfaces blockers early, prevents wasted work                              |
| **Common mistakes reference**                  | `docs-health` — `references/common-mistakes.md`                                                                 | Prevents the same errors from recurring across sessions                    |
| **Commit checkpoints**                         | `website-launch` — defines mandatory commit points per phase                                                    | Prevents catastrophic loss of uncommitted work                             |
| **Visual QA gate**                             | `website-launch` — verifies rendered output before declaring done                                               | Catches broken layouts, missing assets, CSS errors                         |
| **Restraint / Verschlimmbesserung prevention** | `docs-health` ANNOTATE — "so what?" test, per-file judgment, non-destructive annotation                         | Stops well-intentioned batch edits from making things worse                |
| **Phase-router entry point**                   | `rpi` (humanlayer) — 81-line SKILL.md dispatches to `references/<step>/process.md` per phase                    | Each phase loads alone; the entry point stays a router, not a procedure    |
| **Output review gate**                         | `rpi` (humanlayer) — after writing a doc, re-read it against `references/prose.md` + `show-me.md`               | One cross-cutting quality pass on every artifact, no per-phase restatement |
| **Smallest-view menu**                         | `show-me` (humanlayer) — one exemplar per output shape, "pick the smallest view that makes the key point clear" | Teaching by canonical example fights diagram bloat                         |

## Essential Skill Patterns (Learned from Real Sessions)

Eleven patterns distilled from 80+ session feedback files across the
LarsArtmann ecosystem — each prevents a recurring mistake class. The full
pattern bodies (rationale, examples, anti-patterns) live in
[./references/skill-patterns.md](./references/skill-patterns.md); load a
pattern when writing a skill where it applies.

| #  | Pattern                                  | Prevents                                               |
| -- | ---------------------------------------- | ------------------------------------------------------ |
| 1  | Pre-flight Checks                        | Discovered-too-late credential/tool/infra blockers     |
| 2  | Commit Checkpoints                       | Session-end loss of work that exists only on disk      |
| 3  | Common Mistakes Reference                | New skills repeating known failure modes               |
| 4  | Visual QA Gate                           | Shipping pages nobody rendered and looked at           |
| 5  | Verify Code Examples Against Source      | Stale API examples drifting from the real signatures   |
| 6  | Feedback-Driven Skill Creation           | A third feedback file proposing what should be a skill |
| 7  | Restraint & Verschlimmbesserung          | Unrequested rewrites that make things worse            |
| 8  | Cross-Skill Handoff Notes                | Split brains: two skills restating one doctrine        |
| 9  | Primary Failure Mode in the tl;dr        | Wrong first impression of what the skill fixes         |
| 10 | Condense Without Eroding Teaching Weight | Cuts that delete the WHY behind a rule                 |
| 11 | Disambiguate Competing Skills            | Trigger collisions between adjacent skills             |

Six further patterns — adopted 2026-11-24 from humanlayer/skills
(external provenance; quotes verified against clone `4d69d20`) — live in
the same file as Patterns 12–17: completion criterion per step,
final-answer templates, findings headers that assert what is true, slot
budgets, one-question interviews, provenance frontmatter on artifacts.

## Common Mistakes

- **Vague descriptions** — the agent never activates the skill because it doesn't know when to
- **Description as documentation** — describing what the skill _is_ or _contains_ instead of _when the agent should use it_
- **Too long SKILL.md** — wastes context tokens on every activation; split into `references/`
- **Narrative/prose instructions** — write imperative steps, not essays
- **Missing trigger keywords** — if users say "refactor" but your description only says "architecture", the agent won't match
- **No file references** — cramming everything into one file instead of using progressive disclosure
- **Heavy-handed MUSTs** — overusing ALL CAPS directives instead of explaining reasoning
- **No examples** — describing output formats without showing concrete examples
- **Self-justifying preamble** — "this skill exists because…" paragraphs that change no action; see Principle 7
- **Undefined house jargon** — "ghost system", "split brain", "trophy-case" used with no plain gloss; see the glossary in Principle 7

## Testing Your Skill

Skills benefit from iteration. After drafting:

1. **Write 2-3 realistic test prompts** — the kind of thing a real user would say, not abstract unit tests
2. **Run them against the skill** — use the skill yourself or use the `skill-creator` skill to automate this
3. **Evaluate both qualitatively and quantitatively** — does the output meet expectations? Does the skill trigger when it should?
4. **Iterate** — fix issues, generalize from feedback, re-test

For skills with objectively verifiable outputs (file transforms, data extraction, code generation), set up test cases with assertions. For subjective outputs (writing style, design quality), rely on human review.

Use the `skill-creator` skill for a full eval/benchmarking workflow with automated iteration.

### Eval harnesses: two shapes

- **with/without skill** — measures whether the skill changes agent behavior at all (baseline vs loaded skill, same prompts). Use for new skills.
- **old-skill vs new-skill** — measures whether a _rewrite_ actually improved behavior (check out the pre-rewrite skill to a temp dir, run both, same prompts). Use to justify rewrites; a rewrite that only "reads better" is reasoned, not measured. Proven 2026-08-21 on `website-launch` (old 35% → new 100% on sales-video assertions).

### An eval is not done until it is on disk

Every eval run must persist, immediately per run: `evals/iteration-N/eval-X/{config}/output.md` plus a `grading.json` with per-assertion pass/fail **and evidence quotes**. Persist the RAW transcript at dispatch time (tee as the report arrives) — a summary written later is a weaker artifact (2026-11-23 06-59 report, d5/e2). Outputs that live only in the session transcript are lost — an empty eval directory is invisible to git, and "we ran it" without artifacts is indistinguishable from "we didn't."

### Doctrine changes carry a higher bar

A change to a skill's decision gates or doctrine (text that flips verdicts in future sessions) is not shipped by a single-probe flip demo: it needs ≥3 runs per arm, an old-skill arm archived from git, one cross-model arm, and an independent grader. The full bar and procedure: [`docs/doctrine-eval-protocol.md`](../docs/doctrine-eval-protocol.md); the mechanics are `scripts/run-eval.sh` (`--old-skill`, `--model`, `--grade`).

## Hard-Won Process Lessons

Each of these cost a real session time; all are verified by a status report
in `docs/status/`. The five below are the most re-hit; the full catalog —
grouped by theme (evidence and exit codes, editing, scripts and gates, repo
environment, extractions, carried rules) — lives in
[./references/process-lessons.md](./references/process-lessons.md). Load it
when a session touches its theme.

- **Quote exit codes from redirected runs, never from a pipeline tail.** `$?` after `cmd | head` is `head`'s exit, not the command's; end piped verifications with `> /tmp/x.log 2>&1; echo "exit=$?"` (2026-09-10 02-55 b3, 2026-11-23 02-36 d4).
- **`rg -n` only.** In ripgrep `-r` is `--replace`, not recursive — one run fabricated a repo-wide rename, and a host hook now blocks the flag after 4+ strikes (2026-09-14, 2026-11-23 ×2).
- **Run `date` before naming any timestamped file.** A report was named `19-02` on a 22:23 evening (2026-10-08 d4), and after midnight a session's "today" is stale (2026-11-24).
- **Verify numbers before shipping them, including your own counts.** "7 consumer repos" shipped from `go.mod` greps that never checked `// indirect` (2026-10-08 d5).
- **Commit multi-file rewrites before the auto-commit daemon's next sweep.** Its timer is minutes; heuristic bundles swallowed three of four intended detailed commits in one sweep segment (2026-11-23 06-09 e7, 06-59 d7; AGENTS §7/§5.12 own the daemon rules).

## Minimal Starter Template

```yaml
---
name: my-skill
description: Use this skill when the user asks to [specific trigger]. Then [what the agent does].
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
