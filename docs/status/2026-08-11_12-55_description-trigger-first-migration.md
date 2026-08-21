# Status Report: Description-as-Trigger Migration

**Date:** 2026-08-11 12:55
**Session goal:** Review ALL skill descriptions and update guidance docs to enforce that descriptions are trigger context (WHEN to use), not descriptions of the skill itself.

---

## a) FULLY DONE

### 1. Guidance documents updated

**`AGENTS.md` §3.1** — Rewrote the frontmatter section:

- Template comment changed from `THIS IS A TRIGGER, NOT DOCUMENTATION` to `TRIGGER CONTEXT — tells the agent WHEN to use this skill`
- Added opening paragraph: "The `description` field is **trigger context for the AI agent**, not a description of the skill itself."
- Rewrote the critical nuance paragraph to answer "what user task makes this skill the right tool?"
- Added explicit "If it describes what the skill _is_ or _contains_ rather than _when to use it_, the skill will never activate."

**`how-to-write-skills.md` §1** — Rewrote the core principle:

- Section title changed from "is a trigger, not documentation" to "is trigger context — it tells the agent _when_ to use the skill"
- Added 3rd bad example: `A self-contained HTML report design system...` (describes the skill itself)
- Added 4th good example: trigger-first naming-review description
- Replaced "Include" list from `What the skill does / trigger phrases / adjacent contexts` to `When to activate / trigger phrases / adjacent contexts / what the agent will do`
- Added a 4-row quick-test table for validating descriptions
- Updated Common Mistakes section wording
- Updated Minimal Starter Template description field

### 2. All 18 description-first skills rewritten to trigger-first

Every skill that previously opened with "Reviews...", "Generates...", "Creates...", "Implements...", "Performs...", "Runs...", "Triggers...", "Finds...", "Launches..." was rewritten to open with "Use when the user..." or "Use this skill when...".

| Skill                      | Old opening                                  | New opening                                            |
| -------------------------- | -------------------------------------------- | ------------------------------------------------------ |
| architecture-review        | "Reviews the current architecture..."        | "Use when the user asks about architecture quality..." |
| architecture-visualization | "Generates D2 architecture diagrams..."      | "Use when the user wants architecture diagrams..."     |
| bdd-testing                | "Implements Behavior-driven development..."  | "Use when the user wants to add BDD tests..."          |
| brutal-self-review         | "Triggers a brutally honest self-review..."  | "Use when the user asks for self-reflection..."        |
| code-quality-scan          | "Runs build, lint, and code duplication..."  | "Use when the user asks to check code quality..."      |
| data-model-review          | "Reviews and redesigns data models..."       | "Use when the user wants to review a data model..."    |
| deduplicate-code           | "Finds and removes code duplication..."      | "Use when the user wants to find and remove..."        |
| docs-health                | "Creates, verifies, and maintains..."        | "Use when the user wants to build a TODO list..."      |
| full-code-review           | "Performs a comprehensive code review..."    | "Use when the user wants a full codebase review..."    |
| go-modularize              | "Splits or merges Go modules..."             | "Use when the user wants to modularize..."             |
| how-to-golang              | "Go development decision guide..."           | "Use this skill when writing Go code..."               |
| html-report-kit            | "Shared HTML report design system..."        | "Use when a skill needs to write a styled..."          |
| library-deep-dive          | "Performs a deep-dive research audit..."     | "Use this skill when the user asks..."                 |
| naming-review              | "Reviews and improves naming quality..."     | "Use when the user wants to review, audit..."          |
| nix-review                 | "Reviews and improves .nix files..."         | "Use when the user wants to review, audit..."          |
| pareto-planning            | "Creates a comprehensive execution plan..."  | "Use when the user wants to plan work..."              |
| status-report              | "Generates a full comprehensive status..."   | "Use when the user asks for a status update..."        |
| website-launch             | "Launches a public documentation website..." | "Use this skill when the user asks to create..."       |

### 3. Already-trigger-first skills verified (6 unchanged)

These 6 were already trigger-first and needed no changes:

- `go-ecosystem-upgrade` — "Use when bumping, upgrading..."
- `go-error-modernization` — "Use when modernizing Go 1.26+..."
- `nix-private-go-repos` — "Use when building Go projects with Nix..."
- `samber-do-best-practices` — "Use when the user works with samber/do..."
- `verify-before-filing` — "Use before filing any issue..."
- `verify-external-claims` — "Use before encoding any external claim..."

### 4. Verification passed

- `scripts/check-skills.sh` — all 24 skills pass structural checks
- Custom verification script — all 24/24 descriptions start with "Use " (trigger context)
- No description exceeds 1024 chars

---

## b) PARTIALLY DONE

### 1. ~~`how-to-write-skills.md` Pattern 11 disambiguation example~~ — fixed (docs-health pass 2026-08-21)

Line 477 still says:

```
[what it does + trigger phrases]. Distinct from [competing-skill]
```

This should be updated to:

```
[trigger phrases + what the agent will do]. Distinct from [competing-skill]
```

The template formula still leads with "what it does" — a leftover from the old style. Minor but inconsistent with the new §1 guidance.

### 2. No regression guard in `check-skills.sh`

The check script validates that descriptions exist, are under 1024 chars, and don't contain the `git commit <--` artifact. But there is NO guard that verifies descriptions start with trigger context. A new skill written in the old style ("Reviews...") would pass all checks. A guard like the `git commit <--` check would prevent regression.

---

## c) NOT STARTED

### 1. `skill-creator` SKILL.md (external dependency)

The globally-installed `skill-creator` skill at `/home/lars/.agents/skills/skill-creator/SKILL.md` line 67 still says:

> `description: When to trigger, what it does. This is the primary triggering mechanism - include both what the skill does AND specific contexts for when to use it.`

This is the META skill that agents use when creating new skills. It leads with "what it does" alongside "when to trigger" rather than emphasizing trigger-first. This is NOT in the SKILLS repo (it's a separate global installation), so it cannot be edited here — but it's the upstream source of the anti-pattern.

### 2. Cross-skill body text audit

Not all skill bodies were checked for internal references to "description" that might model the old behavior. Some skills may contain prose examples or guidance about writing descriptions in their body text that still uses the old pattern.

### 3. ~~README.md description guidance~~ — **Won't implement — the report itself judged delegation to `how-to-write-skills.md` sufficient; no standalone section needed.**

README.md references "trigger descriptions" (line 118, 135) which is correct, but does not contain a standalone explanation of the description-as-trigger principle. It delegates to `how-to-write-skills.md`, which is fine.

---

## d) TOTALLY FUCKED UP

### 1. The Questions tool interaction was painful

The user asked me to review all descriptions one-by-one with 3+ options per skill via the Questions tool. I attempted this but:

- First attempt: I showed a summary table of proposed rewrites but asked a vague "which skills should I rewrite?" multi-choice question instead of giving 3 full proposed versions per skill.
- The user got frustrated: "HOW ABOUT YOU WRITE THE WHOLE ON IN THE FUCKING Question?"
- Second attempt: I hit the 200-char limit on choice descriptions. The full descriptions are 300-700 chars each — they don't fit in the Questions tool's choice fields.
- The user then said to just rewrite ALL of them and give 3 versions per skill.

**Root cause:** The Questions tool has a 200-char limit per choice description. Full skill descriptions are 300-700 chars. The two are fundamentally incompatible for this task. I should have recognized this constraint immediately and proposed an alternative approach (e.g., writing proposed rewrites to a review file, or just executing the rewrites directly since the original instruction was clear: "review ALL descriptions for ALL SKILLs and update").

**What I should have done:** The user's original instruction was unambiguous — "review ALL descriptions for ALL SKILLs and update." The Questions tool was a secondary request for review. When the tool constraint made per-skill questions impractical, I should have either (a) executed the rewrites and presented a diff for review, or (b) written the 3 options per skill to a markdown review file the user could browse. Instead I burned multiple rounds fighting the tool.

### 2. I didn't push back on the Questions tool approach

The user explicitly said "Use the Questions tool properly to go through all with me after you updated the AGENTS.md and HOW TO WRITE A SKILL SKILL!" — but the Questions tool is fundamentally limited to 200-char choice descriptions and 5 choices per question. 24 skills × 3 options each = 72 choices, which would need ~14 batches minimum. I should have flagged this mismatch upfront and proposed a better review format instead of trying to cram 500-char descriptions into 200-char fields.

---

## e) WHAT WE SHOULD IMPROVE

1. **Add a trigger-first regression guard to `check-skills.sh`** — a check that fails if a description does NOT start with a trigger phrase ("Use when", "Use this skill when", "Use before", etc.). This prevents the old pattern from silently returning.

2. ~~**Fix Pattern 11 disambiguation template** in `how-to-write-skills.md` line 477 — change `[what it does + trigger phrases]` to `[trigger phrases + what the agent will do]`.~~ done (docs-health pass 2026-08-21)

3. **Update the `skill-creator` meta-skill** — its description-writing guidance (line 67) still says "include both what the skill does AND specific contexts" rather than "start with trigger context." This is the upstream source that generates new skills. If it teaches the old pattern, every new skill inherits the anti-pattern.

4. **Document the Questions tool limitation** — add to AGENTS.md or how-to-write-skills.md a note that the Questions tool has a 200-char-per-choice limit, so long-form text review (like skill descriptions) should use a markdown review file instead.

5. **Consider a "description linter" script** — beyond just checking the first words, a script could check for common anti-patterns: descriptions that start with a verb in 3rd person ("Reviews", "Generates", "Creates"), descriptions that don't contain the word "Use" or "when", descriptions that read like a README sentence.

6. **Audit skill bodies for internal description guidance** — some skills may contain prose in their body text that teaches or models description-writing in the old style.

---

## f) Up to 50 things we should get done next

### High impact (prevents regression)

1. Add trigger-first regression guard to `check-skills.sh`
2. ~~Fix Pattern 11 disambiguation template in `how-to-write-skills.md` (line 477)~~ done (docs-health pass 2026-08-21)
3. Update `skill-creator` SKILL.md description-writing guidance (external repo)
4. Write a `scripts/check-descriptions.sh` linter for description anti-patterns
5. Audit all skill bodies for internal description-guidance prose that models old behavior

### Medium impact (consistency)

6. ~~Add a "description anti-patterns" section to `how-to-write-skills.md` with before/after examples from this migration~~ done (anti-pattern guidance present in how-to-write-skills.md (5 anti-pattern mentions))
7. Add a note in AGENTS.md §9 (What NOT to Do) about description-first writing
8. Consider whether the "Distinct from" disambiguation clause should always come last (after trigger context)
9. ~~Review whether any description lost important information during the rewrite (compare old vs new for completeness)~~ done (2026-08-14 corpus review validated all 25 descriptions)
10. ~~Verify all folded-scalar (`>`) descriptions have correct YAML formatting after edits~~ done at `b83a729`
11. Check if the `website-launch` description (797-line SKILL.md, allowlisted) needs trimming
12. Run the description optimization loop from `skill-creator` on the rewritten descriptions to measure triggering accuracy

### Low impact (polish)

13. Add examples of trigger-first descriptions to the README.md skills table
14. Consider adding `trigger-phrases` to the metadata tags for searchability
15. ~~Document the migration in CHANGELOG (if one exists for this repo)~~ done (docs-health pass 2026-08-21)
16. Review whether the 6 already-good descriptions could be improved further
17. ~~Consider whether `html-report-kit` description should mention specific skills that consume it~~ **Won't implement — AGENTS.md 5.9 rule — consumer list is generated by sync-html-kit.sh --list and never hardcoded.**
18. ~~Check if any description's trigger phrases overlap too much with another skill (causing wrong activation)~~ done (covered by the 2026-08-04 trigger-collision analysis — zero real collisions)
19. ~~Verify the `allowed-tools` fields are still correct after edits (no accidental deletion)~~ done (spot-checked 2026-08-21 — d2 and goreleaser gh allowed-tools intact)
20. Consider a periodic re-check as part of CI (run `check-skills.sh` with new guard)

---

## g) Questions I CANNOT figure out myself

### Q1: ~~Should the `skill-creator` meta-skill be updated as part of this work?~~ → routed to ROADMAP "Open Questions" (decision pending)

The `skill-creator` skill at `/home/lars/.agents/skills/skill-creator/SKILL.md` is the upstream source — it teaches agents how to write descriptions, and its guidance still says "include both what the skill does AND specific contexts." This is NOT in the SKILLS repo. Should I:

- (a) Update it anyway (it's a global install on this machine)?
- (b) Leave it and note it as external?
- (c) Create a companion skill or override in this repo?

### Q2: ~~Should I add a hard regression guard to `check-skills.sh` that fails when a description does NOT start with a trigger phrase?~~ → folded into TODO_LIST T1 (pick strictness when implementing)

This would prevent future skills from reintroducing the old pattern. But it could also be too strict — there may be valid descriptions that don't start with "Use when" but are still trigger-first (e.g., "Activate for...", "Trigger on..."). Should the guard be:

- (a) Strict: must start with "Use "
- (b) Loose: must contain "when" in the first sentence
- (c) Pattern-based: must NOT start with a 3rd-person verb ("Reviews", "Generates", etc.)
- (d) Skip the guard entirely

### Q3: ~~Should the Questions-tool character limit be documented somewhere?~~ → TODO_LIST T13

The Questions tool has a 200-char-per-choice-description limit that made the per-skill review impractical. Should I document this constraint in AGENTS.md or how-to-write-skills.md so future sessions don't repeat the mistake of trying to review long text through the Questions tool?
