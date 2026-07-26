# Skill Feedback: docs-health × status-report × workflow chain

**Date:** 2026-07-26
**Source session:** go-filewatcher LOW-priority TODO clearance + self-review
**Feedback author:** Crush (the agent that failed, then was caught by the user)
**Tone:** Honest, evidence-based, specific. These skills are excellent in isolation; the failure is in how they connect (or don't).

---

## TL;DR

The skills individually work. The **gap between them** is where work falls through. In this session I wrote a status report with 50 forward-looking items, then moved done TODOs to CHANGELOG — and left TODO_LIST with **6 items** while 27 actionable items rotted in the report. The user had to ask "why is the TODO_LIST so pathetic?" The skills **document this exact failure mode** (docs-health line 51-53: "Without HARVEST, every status report's 'next tasks' section is entombed...") but **nothing forces the agent to act on it**.

---

## 1. `status-report`: The handoff to HARVEST is missing

### What happened

The status-report skill (50 lines) produced an excellent report with section f) "Top 25/50 things to get done next." Then it said `WAIT FOR FURTHER INSTRUCTIONS`. I obeyed. The forward-looking items sat in a timestamped file. The user caught the gap two turns later.

### The problem

The skill **produces the primary input for docs-health HARVEST** but doesn't say so. It ends with:

```
4. WAIT FOR FURTHER INSTRUCTIONS!
```

There is no step 5: "If this report contains forward-looking items, the next natural action is `docs-health HARVEST`." The cross-link at the bottom (line 47-50) points to `update-old-docs` (backward annotation), not to HARVEST (forward extraction). The one skill that consumes this report's most valuable section is invisible from inside it.

### Fix

Add a "After the report" note — parallel to the existing `update-old-docs` note:

```markdown
> The "next tasks" section (f) above is the primary input for `docs-health
HARVEST`. If the session continues after this report, run HARVEST to pull
> those items into `TODO_LIST.md` / `ROADMAP.md` — otherwise they are entombed
> in this timestamped file. See [`docs-health`](../docs-health/SKILL.md) →
> HARVEST.
```

This mirrors what `docs-health` already says from its side (line 51-53). Both skills acknowledge the relationship, but only `docs-health` acts on it. `status-report` should too.

---

## 2. `docs-health`: HARVEST is the most valuable section and the most buried

### What happened

When the user said "why is the TODO_LIST so pathetic?", I loaded docs-health (535 lines). The HARVEST process (lines 148-232) is excellent — routing rules, dedup, verify-against-code, cite-source. But I only found it because the user forced me to run AUDIT. In a normal flow, I would never have read this deep.

### The problem

**Line count and structure make the critical section easy to miss.** The skill is 535 lines. HARVEST starts at line 148 — past the documentation model table, the project-type table, the task-determination table, the entire BUILD section, the BUILD rules, and the BUILD quick-reference table. An agent skimming for "what do I do" hits BUILD first and may never reach HARVEST.

The **anti-patterns** (lines 213-231) are the best part of HARVEST — "Dumping all 50 items verbatim," "Treating the report as code," "Harvesting open questions as tasks" — they prevented me from making the obvious mistakes. But they're 60+ lines into the HARVEST section.

### Fixes

1. **Add a 5-line "Quick start" at the top of the skill** (before "## The documentation model"):

   ```markdown
   ## Quick start: which mode do I need?

   | Situation                                        | Mode    | Key rule                                       |
   | ------------------------------------------------ | ------- | ---------------------------------------------- |
   | User wrote a status report, TODO_LIST looks thin | HARVEST | Pull forward-looking items from recent reports |
   | User says "are docs current?"                    | VERIFY  | Open each doc, check claims against code       |
   | A doc file doesn't exist                         | BUILD   | Generate from code, cite evidence              |
   | User says "full audit" / "fix my docs"           | AUDIT   | BUILD + HARVEST, then VERIFY everything        |
   ```

   This table is different from the existing "Determine the task" table (line 72-83) because it's **situation-first** (what triggered the agent) not **verb-first** (what the user said). Agents arrive at skills via context, not always via explicit commands.

2. **Add a "After every status-report" trigger to HARVEST** (line 172, "When to run HARVEST"):

   The first bullet already says "After every status-report session." Make it impossible to miss by **bolding it** and adding a one-line consequence:

   ```markdown
   - **After every `status-report` session.** The report's "next tasks"
     section is a TODO_LIST input, not its final resting place. **If you just
     wrote a status report and TODO_LIST was not updated, run HARVEST now.**
   ```

3. **Add an AUDIT-time invariant check** (in VERIFY, step 5 checklist):

   ```markdown
   - [ ] If any file in `docs/status/` is newer than the last TODO_LIST.md
         edit, HARVEST was likely skipped — verify forward-looking items aren't
         trapped in the report.
   ```

   This turns "agent forgot to HARVEST" into a caught drift.

---

## 3. `status-report` × `docs-health`: The "up to 50" vs "Top 25" mismatch

### What happened

The user's prompt said "up to 50 things we should get done next." The status-report skill says "Top #25." I produced 50 (following the user's explicit instruction, which overrides the skill). But HARVEST then had to route/dedup/verify 50 items — and the anti-pattern warning says "Most 'Top 50' lists are brainstorms, not commitments" (line 215-217).

### The problem

The skill's "Top #25" is calibrated for HARVEST-ability. The user override to 50 produces a brainstorm that HARVEST then has to aggressively triage. This isn't wrong (the user's instruction wins), but the skill could acknowledge the tension.

### Fix

Add to the HARVEST anti-patterns section:

```markdown
- **When the user overrides the "Top N" count (e.g. asks for 50 instead of
  25):** expect a brainstorm, not a commitment list. Apply extra routing
  rigor — most items will go to ROADMAP, not TODO_LIST. This is expected, not
  a failure of the report.
```

---

## 4. `docs-health` VERIFY: "Run the project's quality gate" needs to name the exact command

### What happened

docs-health VERIFY step 7 (line 319-331) says: "Run the project's quality gate. Mandatory." It lists examples: `cargo clippy`, `npm test`, `nix flake check`. I read this section during HARVEST but **did not run `nix flake check` or `nix run .#check`** — I ran `go vet`, `golangci-lint`, and `go test` directly instead. These are equivalent for code verification but **bypass the Nix build's fileset and sandbox checks**, which is exactly where the `examples/` fileset gap hides.

### The problem

"Run the project's quality gate" is correct but too abstract for an agent under load. The agent reads it as "run _some_ tests" rather than "run the _canonical_ gate that this specific project defines." In a Nix-first project, `go test` and `nix run .#check` are **not equivalent** — the latter validates the flake fileset, which is a different axis of correctness.

### Fix

Add a **detection step** before the list:

```markdown
### Step 7: Run the project's quality gate. Mandatory, not optional.

**First, detect the canonical gate** — do not substitute. Read `AGENTS.md`
or `flake.nix` (Nix projects) for the project's prescribed commands. If the
project defines `nix run .#check` or `nix flake check`, run THAT, not bare
`go test` / `cargo test` — the Nix gate validates fileset/sandbox integrity
that direct language commands bypass.
```

This is project-type-aware and prevents the substitution I made.

---

## 5. Missing: a "hermeticity check" for Nix projects

### What happened

I shipped `nix run .#bench-diff` using `go run golang.org/x/perf/cmd/benchstat@latest` — a **network-dependent, non-reproducible** command in a project whose entire build philosophy is Nix hermeticity. No skill caught this.

### The problem

The `nix-review` skill reviews `.nix` files. The `how-to-golang` skill advises on Go library choices. Neither has a rule like: **"If this project uses Nix flakes, every new tool dependency must be vendored via a flake input or `buildGoModule`, never `go run pkg@latest` or `npx`."**

### Fix

Add to `nix-review` (or `how-to-golang`'s Nix section) a rule:

```markdown
### Hermeticity invariant

In a project with a `flake.nix`, every tool invoked by a nix app or devShell
MUST come from a flake input or nixpkgs attribute. `go run pkg@latest`,
`npx pkg`, `pip install`, and `cargo install` in app scripts are
**banned** — they break reproducibility silently. If a tool isn't in nixpkgs,
add it as a flake input or `buildGoModule` derivation.
```

---

## 6. `docs-health` AUDIT: Add "structural decay detection" for TODO_LIST specifically

### What happened

The user's complaint was "TODO_LIST is pathetic" — not wrong content, but **insufficient content**. The existing VERIFY checklist (line 303-311) checks for:

- Links resolve ✅
- Counts verified ✅
- No feature in both PLANNED and FULLY_FUNCTIONAL ✅
- No completed item in both TODO_LIST and CHANGELOG ✅
- No "Previously Completed" section ✅

But there is **no check for "TODO_LIST is too thin relative to known open work."** The structural-decay rules (line 267-275) all measure decay as "too much non-job content" — the opposite failure (too little content) isn't covered.

### Fix

Add to the VERIFY checklist:

```markdown
- [ ] TODO_LIST is not suspiciously thin: compare item count against recent
      status reports' "next tasks" sections. If the most recent report has
      20+ forward-looking items and TODO_LIST has <10, HARVEST was likely
      skipped.
```

And add to the failure-modes table (line 267-278):

```markdown
| Medium-High | Under-populated | TODO_LIST has far fewer open items than recent
| | | status reports suggest; HARVEST was skipped |
```

---

## 7. What the skills got RIGHT (keep these)

These worked exactly as designed and should not change:

- **docs-health "Delete done items, never upsert to done"** (line 131-136) — crystal clear, I followed it first try.
- **HARVEST routing rules** (TODO vs ROADMAP vs dedup vs drop) — precise and actionable.
- **HARVEST "verify against code"** (line 189-192) — caught that "Error simulation testing" was already shipped but FEATURES.md still said PLANNED. This is the single most valuable step.
- **HARVEST "cite the source"** (line 201-205) — every harvested item now has `(code: path / src: report)` citations. Auditable.
- **HARVEST "open questions are NOT tasks"** (line 184-187) — correctly routed my 3 questions to a separate "Open questions" section, not the checklist.
- **status-report format (a-g sections)** — produced a genuinely honest, structured self-review. The "TOTALLY FUCKED UP" section forces honesty.
- **docs-health two-score system** (Accuracy vs Fitness) — correctly identifies that a doc can be "100% accurate and 100% useless."

---

## Summary: the three changes that would have prevented this session's failure

| Priority | Change                                                                | Skill                           | Impact                                                            |
| -------- | --------------------------------------------------------------------- | ------------------------------- | ----------------------------------------------------------------- |
| **1**    | Add "after status-report, run HARVEST" handoff note                   | `status-report`                 | Closes the loop — the report's "next tasks" would reach TODO_LIST |
| **2**    | Add AUDIT-time check: "TODO_LIST suspiciously thin vs recent reports" | `docs-health` VERIFY            | Catches the gap even if the agent forgets                         |
| **3**    | Add hermeticity invariant for Nix projects                            | `nix-review` or `how-to-golang` | Prevents `@latest` in Nix app scripts                             |

Everything else is polish. These three are structural.

---

## Resolution (2026-07-26)

All six sections acted upon. No skill was left untouched.

| #   | Section                            | Skill           | Change applied                                                                                                                                                                                                   |
| --- | ---------------------------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | status-report → HARVEST handoff    | `status-report` | Added an "After the report is written, the loop is not closed" note pointing to `docs-health` HARVEST, parallel to the existing `update-old-docs` note.                                                          |
| 2   | HARVEST discoverability            | `docs-health`   | Added a situation-first "Quick start: which mode do I need?" table above the documentation model. Strengthened the "After every `status-report` session" HARVEST trigger with the "run HARVEST now" consequence. |
| 3   | "Top N" override mismatch          | `docs-health`   | Added a HARVEST anti-pattern: when the user overrides Top N to 50, expect a brainstorm and route most extras to ROADMAP.                                                                                         |
| 4   | Quality-gate substitution          | `docs-health`   | VERIFY step 7 now says "detect the canonical gate — do not substitute" and explains that `go test` ≠ `nix run .#check` (fileset/sandbox integrity).                                                              |
| 5   | Hermeticity invariant              | `nix-review`    | Added a "Hermeticity invariant for apps and devShells" subsection + a Purity checklist item banning `go run pkg@latest`, `npx`, `pip install`, `cargo install`, `curl                                            | sh` in app/shell scripts. |
| 6   | Structural decay (under-populated) | `docs-health`   | Added an "Under-populated" Medium-High failure mode, plus two VERIFY checks: TODO_LIST thin vs recent reports, and `docs/status/` newer than the last TODO_LIST edit.                                            |

Verified: `scripts/check-skills.sh` passes (24 skills). Moved to `docs/feedback/processed/`.
