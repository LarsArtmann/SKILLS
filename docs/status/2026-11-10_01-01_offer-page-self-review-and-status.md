# Status Report + Brutal Self-Review — offer-page session: what shipped, what I broke, what I missed

**Session:** 2026-11-10, 23:45–01:01 CET (continuation of the offer-page skill session; second report — the build report is `2026-11-10_00-46_*`)
**Author:** Crush agent session
**Report type:** point-in-time snapshot + self-critique (goes stale; bring current via docs-health → ANNOTATE)

## Scope line — verified vs. not

**Verified this session (command → result):**

- `date` → Tue Nov 10 01:01:47 AM CET 2026 (report naming).
- `python3 -c "import textstat"` → **ModuleNotFoundError** — the tool named in
  `voice-and-gates.md` is NOT installed on this machine.
- `grep -rn -i "live chat" first-customers/ offer-page/ originals/` (no pipe)
  → exit 1, zero matches — the live-chat conversion guidance that existed in
  the old `sales-page-anatomy.md` is **gone from the entire repo**.
- `./scripts/check-skills.sh --triggers` → offer-page markers=15 STRONG,
  first-customers 18 STRONG, how-to-golang 19 STRONG (all touched
  descriptions healthy). This run was a MISS during the build session
  (only `--signal` was run; SESSION-START item 5 says run `--triggers` when
  descriptions are touched) — caught in this review.
- `git status` → clean; session commits verified by hash: 6 daemon bundles
  (0ef1523..4417e70, all files mine, nothing foreign) + 66db125 (docs) in
  SKILLS; 847df5b in the agent-skills aggregation repo.
- `git worktree list` → single worktree, clean.
- Trigger probe result (from the build session): fresh `crush run` printed
  `SKILLS-USED: offer-page` — PASSED, but see (d)1: the transcript is not on
  disk.

**NOT verified, and why:**

- **Probe transcript persistence** — the probe output exists only in the
  session transcript; nothing under `offer-page/evals/` holds it. The
  FEATURES row claims the pass on chat evidence alone (trophy-case-adjacent).
- **Research numbers** — taken from the three subagent reports on their
  provenance labels (primary-fetched / secondary / unverified); I did not
  independently re-fetch any of the ~15 pinned numbers myself.
- **Trigger-eval execution** — 20 queries authored, zero run.
- **Negative triggering** — never probed that first-customers still wins
  funnel-only queries after the split.

---

## a) FULLY DONE

| Item                                                                                                                                                                         | Evidence                                                 |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `offer-page` skill: 108-line SKILL.md, 3 references, 1 asset, trigger-eval fixture                                                                                           | gates green; tree committed                              |
| Deep research, 3 streams (needs / cut-list / voice), per-claim provenance + unverified-ledgers                                                                               | subagent reports; encoded in references with source URLs |
| Restructure without split brain: anatomy + copy-brief git-mv'd into offer-page; first-customers Step 4 + teardown hand off by skill name; two-way description disambiguation | link-check green; no dangling intra-skill paths          |
| CTA myth corrected repo-wide (+68% → +213.16%, archived primary; +38.26% identified as replication)                                                                          | page-anatomy.md, voice-and-gates.md ledger               |
| Full wiring: README row + count, FEATURES rows (both skills), CHANGELOG, AGENTS §5.5 graph entry, ROADMAP §8                                                                 | files committed                                          |
| Runtime: symlink linked + aggregation repo committed                                                                                                                         | `link-skills-to-agents.sh --check` OK                    |
| Pre-existing gate FAIL fixed en route (how-to-golang description 1242 → 955 chars, triggers preserved)                                                                       | gate exit 0                                              |
| Positive trigger probe PASSED in a fresh session                                                                                                                             | `SKILLS-USED: offer-page` (transcript caveat above)      |
| Build-session status report written + committed                                                                                                                              | `2026-11-10_00-46_*`                                     |

## b) PARTIALLY DONE

1. **Eval story** — trigger-eval.json authored (10 should / 10 should-not)
   but unexecuted; probe passed but unpersisted; no negative probes.
2. **textstat path in voice-and-gates.md** — instruction shipped, tool absent
   locally; a hand-count fallback sentence exists, but the primary mechanical
   path fails on this machine (verified ModuleNotFoundError).
3. **docs/external-dependencies.md row** — offer-page now references external
   tooling (textstat, Hemingway/readable as web tools); no row added per the
   §10 convention.
4. **first-customers evals drift** — its trigger-eval.json still contains
   page-build queries ("my landing page converts 0.8%, something is wrong
   with the page") that my split routes to offer-page now; fixture not
   reconciled with the new boundary.

## c) NOT STARTED

1. `evals/evals.json` task prompts for offer-page (first-customers has one).
2. Two-arm behavioral eval (with/without skill) on a build prompt.
3. Audit-mode probe (teardown query against an existing page).
4. HARVEST of this report's section (f) into TODO_LIST (held per "WAIT FOR
   INSTRUCTIONS").
5. Independent spot-verification of the subagent-pinned numbers.

## d) TOTALLY FUCKED UP

1. **Silently deleted useful content during a "move + enrich".** The old
   `sales-page-anatomy.md` carried the live-chat conversion block
   (live chat lifts conversion ~20%; chatters 2.8× more likely to buy; 50%
   abandon when they can't get a quick answer — Forrester/CampaignMonitor
   sourced). My wholesale rewrite of the file dropped it instead of
   relocating it to first-customers (it is funnel/solo-founder material, not
   page anatomy). Verified gone repo-wide. This is Verschlimmbesserung by
   rewrite — the guide's scripted-edit rule ("diff before/after and account
   for EVERY removed line") was applied to my surgical edits but not to my
   one full-file rewrite.
2. **Violated verify-external-claims with my own authoring.** I required
   source-tracing from the research agents, then shipped a tool instruction
   (`textstat.flesch_kincaid_grade()`) without checking availability — on a
   machine where it is not installed. Doctrine applied to others, not to me.
3. **Repeated the documented pipefail mistake twice during this very
   review** (`grep ... | head -5; echo $?` reports head's exit, not grep's) —
   the exact lesson written in how-to-write-skills.md Hard-Won Process
   Lessons. Third attempt (no pipe) produced the real exit 1.
4. **Let the daemon eat the milestone commits.** AGENTS §7 says the agent
   commits session artifacts with detailed messages; I left the tree dirty
   between milestones, so the actual skill content rides six heuristic
   "chore: auto-commit" bundles (0ef1523..4417e70) and only the final docs
   commit (66db125) carries a real message. Known §5.12 behavior — walked
   into it anyway.
5. **SESSION-START item 5 half-executed** — descriptions were touched in
   THREE skills (offer-page, first-customers, how-to-golang) but only
   `--signal` was run during the build; `--triggers` ran in this review
   (all STRONG — no damage, but the process step was late).

## e) WHAT WE SHOULD IMPROVE

- **Relocate, never delete, during restructures** — a full-file `write`
  bypasses the diff-accounting discipline that surgical edits get. Rule
  candidate: any `write` over an existing file must be followed by
  `git diff` on that file with every removed block consciously re-homed or
  explicitly disclaimed.
- **Availability-check tool instructions before shipping them** — one
  import/command probe per tool named in a skill; register in
  `docs/external-dependencies.md` at authoring time, not later.
- **Persist eval evidence at probe time** — "an eval is not done until it is
  on disk" is written doctrine; the probe transcript should have been
  tee'd into `offer-page/evals/iteration-1/` as it ran.
- **Stagger subagent cold starts** — three simultaneous starts on one
  provider triggered the rate limit that cost 3 failed dispatches across 2
  dead providers (gemini and huggingface both prepay-depleted; zai flash
  worked). Cheaper: start 1, then fan out; check provider health first.
- **Commit at milestones, not at session end** — the daemon window is
  minutes; a commit after each green gate keeps history readable.
- **Session-start item 6 checklist gap** — new-skill wiring should include:
  external-deps row, `--triggers` for touched descriptions, and negative
  probe against the sibling skill whose triggers were narrowed.

## f) Next tasks (impact-ordered; 30 real items — not padded to 50, per "no unrelated research")

1. Restore the live-chat guidance into `first-customers/references/proof-and-trust.md` (or activation.md) with its sources — content loss fix.
2. Fix `voice-and-gates.md`: textstat marked not-installed-locally; hand-count + Hemingway promoted to primary local path.
3. Add `textstat` row to `docs/external-dependencies.md` with verification note.
4. Persist the trigger-probe transcript to `offer-page/evals/iteration-1/trigger-probe.md` (re-run if unrecoverable).
5. Run `offer-page/evals/trigger-eval.json` (20 queries, fresh sessions).
6. Negative probe: "get my first 10 paying customers, no page yet" must load first-customers, not offer-page.
7. Reconcile `first-customers/evals/trigger-eval.json` with the new boundary (queries 1, 4, 7 now page-build flavored).
8. Audit-mode probe: teardown query against an existing page URL.
9. Author `offer-page/evals/evals.json` task prompts (2-3, per skill-creator flow).
10. Two-arm eval (with/without skill) on one build prompt.
11. Independent spot-fetch of 5 pinned numbers (Baymard 40%, NN/g 57%, DSA Art. 25, FTC rule page, J. Retailing DOI).
12. Deduplicate the +213.16% correction (5 mentions today → 2 canonical + links).
13. first-customers worked-example Step 4: add one line "rules live in offer-page; this is the worked instance".
14. Decide + document: non-SaaS worked example for offer-page (course/service), or stay lean.
15. Add a B2B/technical voice-gates micro-example (current one is freelancer invoicing).
16. README "counts below are live-derived, never hardcoded" vs. the hardcoded name list — derive it or soften the claim.
17. CHANGELOG: add Unreleased line for the how-to-golang description fix (it rode a heuristic daemon commit).
18. Cold-query probe variant ("nobody buys from my page") alongside the warm one.
19. Check TODO_LIST/FEATURES/README (living docs only) for stale "sales-page-anatomy" references; leave docs/status archives alone.
20. HARVEST this report's (f) into TODO_LIST once instructed.
21. Record the subagent provider lesson (stagger starts; credits deplete quarterly) — candidate for crush-config `references/lessons.md` (cross-project) vs. this repo's AGENTS (single-repo) — decide owner.
22. Commit the aggregation repo on skill edits too (only the link-add was committed; content edits propagate via symlink anyway — document that).
23. Re-read offer-page SKILL.md end-to-end for the condensing checklist step 4 (teaching weight survived?) — not done since writing.
24. Voice-gate tooling fallback: decide whether a tiny syllable-count script belongs in `offer-page/scripts/` or hand-count suffices.
25. Consider whether `website-launch`'s "sales-video expansion" sections reference page anatomy and should link offer-page by name.
26. Offer-page audit mode: define what evidence output looks like on disk (fix list file? chat only?) — currently chat-only.
27. Add offer-page to the check-skills `--signal` followup: confirm no throat-clearing survived (passed check 15; advisory pass not re-read).
28. Sync-html-kit N/A check: offer-page mentions no HTML report — confirm no vendoring expected (it doesn't produce reports — skip is correct; document the decision).
29. Re-verify FEATURES count claims after any of the above edits (10 refs + 1 asset / 3 refs + 1 asset) — they drift with every file move.
30. Age the skill: plan the first REAL page build through offer-page (the 🆕→🟢 aging rule requires real work, not probes).

## g) Questions I cannot figure out myself

1. **The live-chat deletion (d)1:** restore that guidance into first-customers,
   or do you consider it obsolete noise that was fair to cut? I deleted
   content I didn't author during a move — your content, your call.
2. **Eval investment (f)4-10:** run the full battery now (trigger eval +
   negative probes + two-arm build eval — several subagent sessions of
   spend), or age the skill on real page work first and only fix the
   transcript persistence? I cannot judge your spend appetite.
3. **Scope of offer-page (f)14:** keep it lean and SaaS-agnostic as built, or
   grow a non-SaaS worked example (course/service page) next? That is a
   product-direction call, not a discoverable fact.
