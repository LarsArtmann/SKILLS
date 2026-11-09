# Status Report — offer-page skill: deep research, three-layer Growth & Sales stack, and a corrected CTA myth

**Session:** 2026-11-10, ~23:45–00:46 CET
**Author:** Crush agent session
**Report type:** point-in-time snapshot (this file goes stale; bring current via docs-health → ANNOTATE)

## Scope line — what this report verified vs. did not

**Verified this session, with which artifact:**

- Research findings: 3 fan-out subagents (needs / cut-list / voice), each
  required to trace numbers to primary sources; the three reports (in-session
  `<subagent-report>` messages) carry per-claim confidence labels, and the
  encoded claims live in `offer-page/references/*.md` with source URLs +
  verification-status tables.
- Gates: `scripts/check-skills.sh` exit 0, "all 35 skills pass structural
  checks", 188 markdown files link-checked; `link-skills-to-agents.sh` ran
  clean (new `offer-page` symlink created in the aggregation layer).
- Anatomy/copy-brief move: `git mv` (rename detection), inbound references
  updated in first-customers SKILL.md + positioning.md + worked-example.md;
  no dangling `[./sales-page-anatomy.md]` links remain (link-check green).
- Trigger probe: dispatched in a fresh `crush run` session (probe pending at
  write time — see NOT verified).
- Pre-existing gate FAIL fixed: how-to-golang description 1242 → 955 chars
  (gate exit 0 after).

**NOT verified, and why:**

- **Trigger probe result** — the `crush run` probe was still running at
  report-writing time; the probe transcript is not persisted to disk.
  `evals/trigger-eval.json` is authored but NOT executed (FEATURES row says
  so explicitly).
- **Conversion numbers marked secondary/unverified** — Deloitte 0.1s → +8.4%
  (primary unreachable this session; number was already repo-pinned),
  Runyon carousel figures (primary site offline; listicle-only), HubSpot
  "+202%", Crazy Egg "+64%", Basecamp "60 seconds", Spiegel "270%" (banned
  from citation in the unverified-number ledger).
- **Runtime sync through `~/.config/crush/skills/`** — symlink chain resolves
  (`link-skills-to-agents.sh` green), but no fresh Crush session beyond the
  probe was consulted.

## TL;DR

| Question                                        | Answer                                                                     |
| ----------------------------------------------- | -------------------------------------------------------------------------- |
| What was built?                                  | `offer-page` skill — page assembly for any paid offer (108-line SKILL.md, 3 references, 1 asset) |
| What changed around it?                          | first-customers' page anatomy + copy-brief git-mv'd in; Step 4 + teardown now hand off by skill name; two-way description disambiguation |
| Split brains?                                    | None created, one prevented — page knowledge now has exactly one owner    |
| Research quality?                                | Every number primary-traced or explicitly flagged; one circulating myth corrected (+68% → +213.16%) |
| Biggest save                                     | The voice agent caught that the repo's existing "+68%" CTA figure contradicts the archived primary |
| Biggest operational annoyance                    | 3 provider failures in a row for the cut-list agent (zai rate-limit → gemini prepay-depleted → huggingface prepay-depleted → zai flash worked) |
| Repo state at write time                         | Gates green; trigger probe pending; commits by this session listed below   |

## What the session did

1. **Session-start checklist executed**: feedback/new empty; newest status
   report read; TODO_LIST/ROADMAP grepped (ROADMAP §8 anticipated exactly
   this second GTM skill — marked, not duplicated); check-skills run revealed
   a pre-existing FAIL (how-to-golang description 1242 chars) — fixed first
   (955 chars, every trigger phrase preserved).
2. **Deep research fan-out**: 3 subagents (needs / cut-list / voice), each
   with per-claim source-tracing rules. Key primary-verified arrivals:
   Lindgaard 50ms credibility, NN/g 57%/74% attention + ≤28% read, Chartbeat
   35%-never-scroll, BrightLocal 2026 review-trust factors (49% trust reviews
   like personal recs), J. Retailing 2016 guarantee meta-analysis (leniency ↑
   purchase intent), decoy effect field-validated (Marketing Science 2020),
   center-stage effect (JCP 2009), web.dev speed cases (Vodafone +8% sales,
   Rakuten +53% rev/visitor), Unbounce 83% mobile share, Baymard 40%
   extra-costs / 23.48-vs-12-14 fields / 70.22% abandonment, EU DSA Art. 25,
   FTC 16 CFR 465. Cut-list agent survived three provider failures.
3. **Skill authored** (`offer-page/SKILL.md`, 108 lines): inputs table →
   10-step build procedure (5-second contract first; skeleton; hero; body;
   proof; offer block; FAQ; voice gates; cut-list pass; QA) → audit mode →
   honesty rules → related skills.
4. **References**: `page-anatomy.md` (moved + enriched: choice-overload
   nuance, length-by-temperature, copy-sequence doctrines, proof/pricing/
   speed evidence); `cut-list.md` (20 items in tiers A/B/C + cut order +
   verification-status table); `voice-and-gates.md` (10 mechanical gates,
   source ledger, unverified-number ledger, worked micro-example).
5. **Split-brain prevention**: page knowledge consolidated under offer-page;
   first-customers keeps funnel-level rules only; handoffs by skill name
   (cross-skill file paths would dangle under per-skill installs).
6. **Wiring**: README row + "Nine skills 🆕" count, FEATURES rows (both
   skills), CHANGELOG entry, AGENTS §5.5 graph entry, ROADMAP §8 update,
   `evals/trigger-eval.json` (20 queries), symlink linked into the
   aggregation layer.
7. **Myth corrected in place**: "+68%" gym-CTA lift → +213.16% (archived
   ContentVerve primary); "+38.26%" identified as the sister-site replication
   of +14.79%.

## Open items / handoff

- **Trigger probe result** (pending at write time) and **trigger-eval
  execution** — offer-page stays 🆕 until a real triggered run; the aging
  rule from first-customers applies ("aged only after a real launch run").
- **Aggregation-layer commit** — `~/.agents/skills` shows the new untracked
  symlink; commit it there (`git -C ~/.agents/skills status --short`).
- first-customers FEATURES row now claims 10 refs + 1 asset — re-verify
  counts if that skill gains references back.

## Decisions made (and why)

- **New skill over extending first-customers**: ROADMAP §8 deferred the
  second GTM skill until requested; this request was it. A dedicated concise
  skill also matches the user's explicit ask; first-customers remains the
  funnel playbook.
- **Move (git mv) over copy**: copying the anatomy would have created a
  two-anatomy split brain — the exact rot the 2026-09-14 merge assessment
  warns about.
- **You ≥ 3× we as heuristic, not physics**: the We-We ratio has no published
  A/B (tool offline); encoded with honest confidence labels in the ledger.
- **Jam-study nuance included**: the 2010 meta-analysis (average effect
  small) prevents cargo-culting "fewer choices always wins" while keeping
  the limit-decisions rule.
