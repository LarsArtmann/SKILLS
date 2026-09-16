# BuildFlow Skill Creation — Session Status Report

**Date:** 2026-09-14 12:25
**Session scope:** Creating the `buildflow` skill in the SKILLS repo (how to use BuildFlow + what responsibilities it absorbs from covered projects), per user request `/home/lars/projects/SKILLS/?`.
**Format note:** User explicitly requested `.md` at `docs/status/` — overrides the status-report skill's HTML default (flagged per that skill's override rule).

---

## a) FULLY DONE

1. **Research phase (verified sources only):**
   - SKILLS repo conventions: `AGENTS.md` (§1–§5.5), `how-to-write-skills.md`, `check-skills.sh` internals (13 checks), symlink model (`link-skills-to-agents.sh` → `~/.agents/skills`).
   - BuildFlow user-facing surface: live `buildflow --help` output (captured 2026-09-14, both flag pages), README. **Rejected `docs/HOW_TO_USE.md` as source — verified stale** (justfile era, removed steps `modernize`/`dupl`/`goimports`).
   - Consumer-side contract: AGENTS.md entries of 4 covered projects (wise-go, httputil, erraudit, monitor365), a real generated pre-commit hook, `.buildflow.yml` examples. Counted **41 covered projects** (have `.buildflow.yml`).
2. **`buildflow/SKILL.md`** (121 lines, under the 500 gate): trigger-first description (694 chars, trigger-density **STRONG**, 5 markers), core "delegate, don't duplicate" rule, **16-row responsibility table** (don't-do-by-hand → run-instead), standard loop (dry-run → doctor → run → fix → `-s` drill-down → `--failed-only`), build modes table, findings-gate semantics, "what the project still owns" split, short-form triage table, anti-patterns, extending-coverage rule, related skills, decision checklist.
3. **Three references:** `commands.md` (full subcommand + flag reference, canonical `.buildflow.yml` keys, header date-stamped "verified against `buildflow --help` 2026-09-14"), `responsibilities.md` (per-ecosystem delegation detail), `failure-triage.md` (9 classes: stale binary, cache purge SQL, pre-commit edges, pma daemon blind spot — sourced from real documented incidents).
4. **Inventory wiring:** README.md new "Build Automation" section; AGENTS.md §5.5 inter-skill graph paragraph (buildflow ↔ code-quality-scan disambiguation, scope boundary vs developing BuildFlow).
5. **Verification:** `check-skills.sh` green — **30 skills pass, exit status 0 (quoted, not inferred)**, 149 markdown files no broken links, no banned artifacts; dprint formatting applied; `check-agents-md.sh` run (1 advisory WARN, pre-existing bloat — see e5).
6. **Live installation:** `~/.agents/skills/buildflow` symlink created and verified; aggregation repo committed (by daemon — status verified clean).
7. **In-session defect fixes (found by self-review, fixed and re-gated):** split the merged `--failed-only` + `--profile` table row into two rows; removed the duplicate `--failed-only` row my first fix introduced.

## b) PARTIALLY DONE

1. **Session bootstrap protocol:** read AGENTS.md only through §5.5 — **§8 ("When Improving This Repo") and §9 ("What NOT to Do") were never read**. `SESSION-START.md` (the repo's mandatory checklist) was **not executed at session start** — discovered and read during this self-review. Retro-verification closed the gaps with zero impact: `docs/feedback/new/` is empty; ROADMAP.md/TODO_LIST.md contain zero buildflow mentions (no pre-existing idea to reconcile — checked now, not then).
2. **Two-way description disambiguation:** the buildflow → code-quality-scan reference exists in my skill, but the **back-reference (code-quality-scan naming buildflow) was not added** — the repo convention for skill pairs is two-way (verify-external-claims ↔ verify-before-filing pattern).
3. **Fact provenance:** `--help`-derived content verified today; README-derived numbers ("19 doctor checks", "43 gomod-check checks", "110 linters", mode durations, `-s` last-one-wins semantics — sourced from httputil's verified investigation, grep of BuildFlow source inconclusive since flags are cmdguard-defined) are **date-stamped claims, not re-verified against binary behavior**.
4. **Skill-creator eval loop:** not run; only the repo's heuristic trigger-density check. The skill-creator flow says to _offer_ test prompts and let the user decide — I never offered (see g1).
5. **Commits:** every change landed via pma daemon auto-commits with junk messages (`chore: auto-commit N changed file(s) (heuristic)`) — expected per repo norms, but no curated commit documents the skill's rationale. Two mid-session edit attempts raced the daemon ("file modified since read"); both recovered correctly by re-reading.

## c) NOT STARTED

1. Behavioral validation that the skill triggers and loads in a **fresh Crush session** (impossible from inside this session).
2. skill-creator test prompts + with/without-skill baseline runs + eval viewer.
3. Trigger-description optimization loop (`run_loop.py`, 20-query trigger evals).
4. `evals/evals.json` skeleton.
5. docs-health HARVEST of section (f) into TODO_LIST.md / ROADMAP.md (user instructed report-then-wait; harvest pending).
6. ROADMAP reconciliation entry for the new skill (nothing pre-existing to mark — verified — but no forward entry added).
7. BuildFlow-side documentation staleness fixes (`docs/HOW_TO_USE.md` is badly outdated; README "auto-installs missing tools" vs doctor's actual "suggest fixes").

## d) TOTALLY FUCKED UP

Nothing catastrophic shipped. Honest failures and near-misses:

1. **Ignored `SESSION-START.md` entirely** — the repo's own mandatory pre-task checklist, written precisely because "memory of 'I know the rules' is not execution". Biggest process failure of the session. Impact luckily zero (retro-verified: empty feedback dir, no roadmap collision), but that is luck, not discipline.
2. **Consumed `check-skills.sh` through `| tail` without quoting exit status** on the first run — the exact anti-pattern SESSION-START step 5 documents from the 2026-09-09 silent-fail incident. Later runs quoted `exit: 0` properly.
3. **Shipped a malformed table row** (`--failed-only` + `--profile` merged into one row), and the first fix introduced a duplicate row. Both caught in self-review, fixed, re-gated.
4. **Raced the daemon twice** with edits after stale reads — predictable (I had _just documented_ the daemon's behavior in the skill I was writing).

## e) WHAT WE SHOULD IMPROVE

1. **Execute repo bootstrap checklists when they exist** — a `SESSION-START.md` is a contract; read it before task work, not during the post-mortem.
2. **Two-way disambiguation is the pair convention** — when adding a skill that references another, wire both directions in the same change.
3. **Prefer the binary over the README as fact source**, and date-stamp everything else (done for commands.md; extend the habit).
4. **Offer the eval loop explicitly** instead of silently skipping it — the skill-creator flow makes that the user's call.
5. **SKILLS `AGENTS.md` is >30 KB** (`check-agents-md.sh` WARN: "bloated, likely temporal pollution") — my §5.5 paragraph grew it further. Needs a docs-health pass to split living context from history.
6. **`commands.md` will drift** as BuildFlow evolves — it says "the binary is authoritative" but names no regen command (`buildflow --help` → regenerate) and has no freshness guard.
7. Quoting pipeline-masked exit codes (`echo $?` after pipes) must be reflexive, not remembered after the fact.

## f) Next tasks (prioritized)

| #  | Task                                                                                                        | Why / size                                    |
| -- | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| 1  | Add back-reference: `code-quality-scan` description/SKILL.md names `buildflow` for covered projects         | Two-way pair convention (P0, 2 lines)         |
| 2  | Add `## Verification status` table to `buildflow/SKILL.md` (claim → status → source, canon format)          | Repo canon guard nudged a WARN-adjacent shape |
| 3  | Re-verify README-derived numbers against live binary (doctor check count, gomod-check check count, linters) | Kill date-stamped uncertainty (15 min)        |
| 4  | Run skill-creator eval loop: 2-3 realistic test prompts, with/without-skill baselines, eval viewer          | Await user decision (g1)                      |
| 5  | Trigger-description optimization loop (`run_loop.py`, 20 trigger evals)                                     | After evals, if user wants (g1)               |
| 6  | Fresh-session trigger validation (user opens new Crush session in a covered project, asks a lint question)  | Only real proof the skill fires               |
| 7  | Add a regen note + freshness hint to `commands.md` (regenerate from `buildflow --help`; date-stamp)         | Drift defense (5 min)                         |
| 8  | Consider `evals/evals.json` skeleton with the 2-3 prompts from #4                                           | Makes iteration cheap later                   |
| 9  | docs-health HARVEST: route section (f) items into TODO_LIST.md / ROADMAP.md                                 | Close the loop this report opened             |
| 10 | Add ROADMAP entry for the buildflow skill (status, future directions: per-project tuning, drift guard)      | Reconciliation (5 min)                        |
| 11 | Split SKILLS `AGENTS.md` history from living context (docs-health pass, target <30 KB)                      | check-agents-md WARN                          |
| 12 | Fix or delete BuildFlow `docs/HOW_TO_USE.md` (justfile-era, removed steps) — it misleads agents             | Upstream doc rot (g3)                         |
| 13 | Correct BuildFlow README "auto-installs required tools" claim if wrong vs doctor behavior                   | Same rot class                                |
| 14 | Verify `-s` last-one-wins semantics in BuildFlow source (cmdguard flag def) and cite precisely              | Provenance hardening (10 min)                 |
| 15 | Consider `references/step-catalog.md` generated from `buildflow list steps --json`                          | Auto-derived, no hand-maintained list         |
| 16 | Document the skill in BuildFlow's AGENTS.md (session agents there could point covered-project work at it)   | Cross-repo discoverability                    |
| 17 | Age the README status marker 🆕 New → 🟢 after first documented successful trigger                          | Repo convention                               |
| 18 | Re-run `check-skill-links.sh` + `--triggers` after any description back-reference (#1)                      | Gate discipline                               |
| 19 | Curated commit for the skill (if authorized) replacing the daemon's heuristic message                       | History tells the story (g2)                  |
| 20 | Session-end checklist from SESSION-START.md: `git worktree list`, scratch-artifact disclaimer               | Was not run this session                      |
| 21 | Add a "when the binary surface changes" note to the skill's Related Skills section pointing at regen (#7)   | Cheap reminder                                |
| 22 | If evals run (#4): benchmark.md + analyst pass per skill-creator                                            | Quantitative evidence                         |
| 23 | Consider pre-approving `allowed-tools: buildflow` frontmatter for the skill                                 | One less permission round-trip                |
| 24 | Review whether `--semantic` (art-dupl) and other niche flags deserve their commands.md rows                 | Trim to load-bearing flags                    |
| 25 | Post-first-trigger: prune any reference content the evals show agents never open                            | Progressive-disclosure hygiene                |

## g) Questions I cannot figure out myself

1. **Should the eval loop run for this skill?** skill-creator says objective-output skills get test cases, subjective/reference ones often don't, and the user decides. The buildflow skill is reference/procedural — but a behavioral test (does an agent in a covered project reach for `buildflow` instead of hand-running golangci-lint?) is measurable. Run evals, or accept the structural gate as sufficient for now?
2. **Commit policy for this repo's sessions:** the link script and repo norms lean on the pma daemon, but the daemon has a documented blind spot and writes junk messages. Do you want explicit curated commits at session end (i.e., you authorize "commit at session end" as a standing instruction), or keep 100% daemon delegation?
3. **Scope: BuildFlow's own stale user docs** (`docs/HOW_TO_USE.md`, README claims) — this session verified they mislead, and the skill now documents usage better than the tool's own docs. Should fixing them become tracked work (mine to schedule), or is that BuildFlow-repo territory you want handled in a dedicated session there?

---

**Session verdict:** the deliverable is live, gate-green, and honestly sourced; the process misses (SESSION-START skipped, one-way disambiguation, tail-piped exit codes, malformed table row) were all caught in self-review and either fixed or listed with owners above. WAITING FOR INSTRUCTIONS.
