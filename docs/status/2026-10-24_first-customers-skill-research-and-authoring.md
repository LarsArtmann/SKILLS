# Status: first-customers skill — deep research + authoring session

**Date:** 2026-10-24
**Task:** "What does a Sales page need? What does a good 0-to-1 online Sales
SKILL for (micro-)SaaS need?" — escalated to a deep-dive research project with
the deliverable being a complete, research-backed skill.
**Result:** `first-customers/` created (SKILL.md 137 lines + 8 references,
1,068 lines total), fully wired, `check-skills.sh` exit 0 (32 skills), symlink
into `~/.agents/skills/` live.

## Research conducted

Deep agents (4 of 11 attempted returned before the sub-agent provider quota
capped; each with source URLs): Copyhackers conversion-copywriting methodology;
landing-page CRO evidence (CXL/Unbounce/Wistia/Wyzowl/Deloitte numbers);
Schwartz awareness × sophistication (+ Hopkins/Halbert); 0→1 indie playbooks
(Walling, 30x500, levels.io, Marc Lou, Mom Test, IH 497-interview channel
aggregate).

Direct primary fetches compensating for the capped agents (all content read in
full): HN official Show HN guidelines (news.ycombinator.com/showhn.html);
ProductLed — PLG benchmarks (600+ SaaS survey), PLG definition, MOAT
trial-vs-freemium framework + Tettra case, onboarding best practices +
checklist, target-customer-profile 5-step guide; aprildunford.com
(positioning definition; templates are newsletter-gated — steps cited to the
book); LemonSqueezy blog index — verified the 2026 payments state: **Stripe
acquired Lemon Squeezy (2024)**, "2026 Update: Lemon Squeezy + Stripe Managed
Payments", MoR positioning intact.

Failed paths (documented, not retried into the ground): Paddle blog and CXL
article bodies are JS-rendered (empty/404 via raw fetch); aprildunford.com
templates gated; Failory/ProductPlan slugs 404; 7 agentic_fetch calls rejected
with the provider rate limit.

## Sourcing discipline

Every conversion/PLG number in the skill is pinned inline to its source
(Unbounce 2024: SaaS median 3.8%, 5th-7th-grade 12.9% vs 2.1%; ProductLed:
9% median free→paid, PQL ~25%, freemium 12% vs trial 5%; levels.io PH ~10k
visits <10%). Book frameworks (Hormozi value equation, Van Westendorp,
Dunford's steps) cite the books — no invented URLs. The payments reference
carries a verify-before-relying note because vendor boundaries drift
quarterly. Trust-badge and annual-discount claims were NOT verifiable this
session and are phrased as heuristics, not sourced facts.

## Wiring completed (session-start #6 checklist)

README (new "Growth & Sales" section), FEATURES row (🆕 NEW), CHANGELOG
[Unreleased] entry, AGENTS §5.5 graph entry (strategy-vs-prose layering over
third-party `copywriting`; also answers copywriting's dangling `offers`
pointer), ROADMAP note on the copywriting fork question, `link-skills-to-agents.sh`
run, `check-skills.sh` exit 0, `--signal` clean (filler=0, jargon=0).

## Open items

- The new symlink shows **untracked** in the `~/.agents/skills` aggregation
  repo — cosmetic per AGENTS §5.10; commit there when convenient.
- Skill ages 🆕→🟢 only after a real 0→1 launch run exercises it.
- Two-way description disambiguation with `copywriting` is one-way by
  necessity (third-party skill, must-not-edit) — boundary lives in
  first-customers' description + AGENTS §5.5.
