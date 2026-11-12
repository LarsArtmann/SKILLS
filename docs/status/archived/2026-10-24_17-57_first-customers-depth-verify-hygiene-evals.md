# 2026-10-24 17:57 — first-customers wave 2: depth, verify-hygiene, evals

Follows `2026-10-24_17-28_first-customers-session-full-status-self-review.md`
(the a-g report whose open questions gated this session). The user answered
"Make the SKILL as superb as possible" — read as: execute the full task list,
deciding the three open questions autonomously.

## Decisions on the three open questions

1. **First exercising product:** fictional evals. No real product was
   offered; the worked example (StatusHawk) is the fictional exercise.
2. **Trigger precedence:** kept as designed — "improve my landing page
   copy" (prose-level) belongs to `copywriting`; strategy/diagnosis/funnel
   questions to `first-customers`. The description's disambiguation line and
   the new 6 copywriting-collision negatives in the trigger set encode it.
3. **Budget:** both research-hardening AND depth/evals were attempted —
   research was quota-blocked (below); depth and evals completed.

## What was done

### Verify-hygiene (all six items closed)

- **PH downrank claim**: deleted from `channels-and-launch.md` (unsourced;
  replaced with the honest "launch-day visitors must be able to try it").
- **ProductLed benchmarks**: date-stamped "2022" in all three citing files
  (`metrics-and-payments.md` table, `offer-and-pricing.md`, SKILL.md Step 7).
- **A/B floor**: the "~1,000 visitors/mo" heuristic replaced with the
  arithmetic it stands on — ~10k visitors PER VARIANT to detect a 20%
  relative lift on a 4% baseline, Evan Miller essay linked. SKILL.md Step 8
  synced.
- **Refund-rate claim**: relabeled an explicit heuristic (no rigorous public
  dataset; track your own) in `proof-and-trust.md`.
- **Payments URLs**: Lemon Squeezy **5% + 50¢/txn verified live** from
  lemonsqueezy.com/pricing (2026-10) and pinned in the fee table;
  paddle.com/pricing cited as the verify point (page is JS-rendered, number
  deliberately NOT claimed).
- **Research retry**: 3 spaced `agentic_fetch` attempts across the session,
  ALL 429 (synthetic.new subscription-level cap, not a transient window).
  Every research-dependent claim is now sourced, deleted, date-stamped,
  arithmetic, or labeled — nothing ships on an unverified number.

### Depth (5 new files + SKILL.md teardown mode)

- `references/worked-example.md` (175 lines): fictional StatusHawk
  status-page-for-agencies micro-SaaS through all 8 steps — diagnosis,
  phrase bank, positioning statement, offer card, 9-section page outline,
  proof plan, 14-day launch calendar, activation definition, metrics
  rituals + a deliverables checklist. Invented outcome numbers explicitly
  labeled as teaching values; real medians cited to their sources.
- `references/cold-outreach.md` (80): B2B no-audience channel — 50-prospect
  cap, 3-5-sentence anatomy, 3-touch sequence, Mom-Test replies, compliance
  floor, anti-patterns. Heuristics labeled.
- `references/waitlist-emails.md` (90): 6-email capture→launch sequence,
  launch-email skeleton, labeled open/click expectations, boundary drawn vs
  activation.md's post-signup sequence.
- `assets/launch-checklist.md` (58): T-14 → T+7 tick-box checklist.
- `assets/copy-brief.md` (60): the strategy→copywriting handoff template
  (empty-field gate: no prose before strategy).
- SKILL.md: new **"Mode: page teardown"** (audit order, diagnosis-tree-
  ordered fix list, no rewriting during teardown); worked-example pointer in
  the intro; copy-brief handoff + demo-video-hook==headline alignment in
  Step 4; cold-outreach/waitlist-emails/launch-checklist wiring in Step 6.
  166 lines total (limit 500).

### Wiring

- README/FEATURES rows updated (11 refs + 2 assets, teardown mode, worked
  example); CHANGELOG "Changed (2026-10-24 — depth + verify-hygiene wave 2)"
  entry; AGENTS §5.5 paragraph extended (wave-2 inventory, ProductLed 2022,
  Lemon Squeezy fee verification); ROADMAP Theme 8 records the Growth & Sales
  category decision: **deferred** until a second GTM skill is requested twice.
- website-launch cross-check: **no split brain** (it hosts the demo video;
  one-way alignment note added in Step 4 instead of restating doctrine).
- external-dependencies.md: no entries needed (skill references no CLIs).

### Evals & triggers

- `evals/evals.json`: 3 prompts (diagnosis case, greenfield launch case,
  teardown case) in the skill-creator schema.
- `evals/trigger-eval.json`: 20 queries, 10/10 split, including 6
  copywriting-collision negatives and near-misses (retention-at-scale, CRO-
  at-scale, docs-site, promo video).
- `quick_validate.py` (skill-creator's own validator): **passes**.
- **Blocked in this environment:** with-skill/baseline subagent runs (the
  agent tool here is search-only) and the `run_loop.py` description
  optimizer (shells out to `claude -p`; no claude CLI on PATH). Artifacts
  are staged for a future Claude-Code session.

### Aggregation repo (~/.agents/skills)

- Found the repo checked out on a stale stash-WIP branch
  (`docs-health-verify-legs` @ 6ddb0a2); the symlink commit initially landed
  there. Fixed surgically via a temp worktree: cherry-picked onto **master**
  (now 990f493 on 1d897b7), reset the WIP branch back to 6ddb0a2 (mixed),
  left the pre-existing third-party churn and stash untouched, removed the
  worktree. Symlink on disk unchanged and correct (relative target).

## Gates (all green at close)

- `check-skills.sh` exit 0 (32 skills, 0 thin, 168 md files, no broken
  links; pre-existing WARNs: naming-review description form, website-launch
  line count, shellcheck absent)
- `--signal`: first-customers filler=0, jargon=0; the 10 prose advisories
  reviewed and KEPT — each is a dense step summary whose every line maps to
  a decision or tool action, not decoration
- `--triggers`: STRONG, 21 markers, description 804 chars
- `git worktree list`: main only; working tree swept by the auto-commit
  daemon

## Self-critique

- The three 429s cost ~0 value beyond confirming the cap is subscription-
  level; Paddle's exact fee remains deliberately unpinned (correct, but it
  means the payments table cites one verified vendor + one "check the page"
  pointer).
- Eval runs remain unexecuted in ANY environment — the skill's empirical
  validation is still zero; the 🆕→🟢 aging criterion (a real launch run)
  is correctly still unmet.
- The teardown mode and worked example are reasoned, not test-driven; a real
  first run may reveal the teardown output format needs tightening.

## Next tasks (HARVEST input)

1. First real run of the skill on an actual product (the 🆕→🟢 gate).
2. Execute evals.json + trigger-eval.json in a Claude-Code-capable session.
3. Pin Paddle's fee + Stripe Managed Payments fees when research quota
   returns; delete the "check the page" pointer for at most one of them.
4. Aggregation repo: unrelated third-party churn + stash@{0} still
   uncommitted on the WIP branch — user's call, untouched deliberately.
