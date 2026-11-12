# Full Status + Session Self-Review: first-customers deep-research session

**Date:** 2026-10-24 17:28 (Saturday) — `date` run per format
**Scope:** this session only (the "MORE RESEARCH / perfect playbook" run +
this report). No unrelated investigation performed.
**Format note:** `.md` at the operator's explicit `docs/status/*.md` demand —
status-report skill's HTML canonical default intentionally overridden, not
propagated back (same precedent as 2026-10-17_00-52 report).

---

## a) FULLY DONE

~~1. **Session-start checklist executed** (all 6 steps): feedback/new empty;~~ done — historical: all 6 steps executed 2026-10-24
   newest status report read (2026-10-17 cmdguard); TODO_LIST/ROADMAP grepped
   (no pre-existing sales-skill item); AGENTS §8/§9 applied; check-skills exit 0
   at start (31 skills).
~~2. **Deep research wave 1 — 4 of 4 successful digests, each with source URLs:**~~ done — historical: 4 digests with source URLs landed in first-customers references
   Copyhackers conversion-copywriting methodology; landing-page CRO evidence
   (Unbounce 2024: SaaS median 3.8%, readability 12.9% vs 2.1%; CXL forms/CTA
   numbers; Wistia/Wyzowl video; Deloitte speed); Schwartz awareness ×
   sophistication (+ Hopkins/Halbert); 0→1 indie playbooks (Walling, 30x500,
   levels.io, Marc Lou, Mom Test, IH 497-interview aggregate).
~~3. **Primary-source fetches read in full:** HN official Show HN guidelines~~ done — historical findings encoded in the skill references
   (verbatim); ProductLed — PLG benchmarks (600+ SaaS), PLG definition, MOAT
   trial-vs-freemium + Tettra case, onboarding best practices, ICP 5-step
   guide; aprildunford.com (definition; templates newsletter-gated);
   LemonSqueezy blog — verified 2026 payments state: Stripe acquired Lemon
   Squeezy (2024) + "Stripe Managed Payments" update.
~~4. **`first-customers/` skill created** — SKILL.md (137 lines) + 8 references~~ done — commits 82bcf4b, ea121ac, 36bbbea, 5d4252d; skill live 2026-11-10
   (931 lines), 1,068 total. Commits: 82bcf4b (4 refs), ea121ac (2 refs),
   36bbbea (market-research/positioning), 5d4252d (SKILL.md + wiring + report).
~~5. **Full new-skill wiring** (session-start #6): README "Growth & Sales"~~ done — README/FEATURES/CHANGELOG/AGENTS §5.5 wiring confirmed present 2026-11-10
   section, FEATURES row (🆕 NEW), CHANGELOG [Unreleased] entry, AGENTS §5.5
   graph entry (strategy-vs-prose layering over third-party `copywriting`;
   answers copywriting's dangling `offers` pointer), ROADMAP note on the
   copywriting fork question — all in 5d4252d.
~~6. **Gates green:** `check-skills.sh` exit 0 (32 skills, 0 thin, no broken~~ done — check-skills.sh re-confirmed EXIT=0 in the 2026-11-10 sweep
   links in 165 files); `--signal` clean (filler=0, jargon=0);
   `--triggers` STRONG (21 markers, desc 804 chars — run 17:28, see d3);
   `link-skills-to-agents.sh` clean, symlink resolves; `git worktree list`
   clean (no stale worktrees, checked 17:28); working tree clean (daemon
   committed everything).
~~7. **Session report #1** written 17:19~~ done — 2026-10-24_first-customers-skill-research-and-authoring.md exists; archived in this sweep
   (`2026-10-24_first-customers-skill-research-and-authoring.md`); this file is
   report #2.

## b) PARTIALLY DONE

~~1. **Deep research overall: 4 of 11 planned topics got agent-grade research.**~~ done — historical; remaining topics routed to TODO_LIST 2026-11-10
   Works: the four digests above + all raw fetches. Missing: pricing/offers
   (ProfitWell/Paddle value-metric data, LTD evidence), proof/guarantees
   (money-back conversion data), Dunford's step-by-step detail (templates
   gated), Product Hunt current mechanics. Blocker: sub-agent provider
   (synthetic.new) rate-capped after the first burst — 7 of 11 calls rejected.
   Effort to finish: M (retry when quota resets).
~~2. **Reference sourcing depth uneven.** market-research / sales-page-anatomy /~~ routed to TODO_LIST 2026-11-10
   activation / metrics are source-pinned inline; offer-and-pricing and
   proof-and-trust lean on book citations (Hormozi, Van Westendorp) and
   labeled heuristics (annual-discount band, refund rates, A/B floor). Gap:
   two of eight references are below the session's own sourcing bar. Effort: M.
~~3. **Evals: not entered.** skill-creator's draft → test-prompt → baseline loop~~ done — evals/evals.json + trigger-eval.json now exist (verified 2026-11-10); baseline runs still routed to TODO_LIST 2026-11-10
   was deliberately skipped for time; consequence: the skill has never been
   triggered or exercised (honest 🆕 in FEATURES). Effort: M.
~~4. **Aggregation-repo link:** symlink live and resolving, but left **untracked**~~ routed to TODO_LIST 2026-11-10
   in `~/.agents/skills` git repo — doctrine calls this cosmetic, but the
   2026-09-13 session committed exactly this class of change (1d897b7
   precedent). Effort: S.

## c) NOT STARTED

~~1. Test prompts + with-skill/baseline runs + eval metadata (skill-creator~~ done — evals.json written (verified 2026-11-10); baseline runs routed to TODO_LIST 2026-11-10
   steps 1-3). Deprioritized for time, still wanted.
~~2. Description-optimization trigger loop — 20-query should/should-not set,~~ routed — trigger-eval.json exists; copywriting collision ruling routed to ROADMAP 2026-11-10
   especially the `copywriting` collision cases ("improve my landing page
   copy" — both skills plausibly trigger; ROADMAP already holds the open
   question of how Crush disambiguates).
~~3. Worked end-to-end example (fictional micro-SaaS walked through all 8 steps)~~ done — references/worked-example.md exists (verified 2026-11-10)
   — references are tables/rules; an exemplar would materially improve agent
   execution.
~~4. Page-review/teardown mode — skill covers build-from-scratch; "review my~~ done — SKILL.md "Mode: page teardown" section exists (verified 2026-11-10)
   sales page" is only implicitly Step 0/4.
~~5. assets/ — launch-day checklist, copy-brief handoff template (positioning~~ done — assets/launch-checklist.md exists (verified 2026-11-10); copy-brief/outreach/emails landed as references (verified 2026-11-10)
   output → copywriting input), cold-outreach templates, waitlist→launch email
   sequence.
~~6. `website-launch` demo-video sales doctrine ↔ `first-customers` page doctrine~~ routed to TODO_LIST 2026-11-10
   cross-check (possible minor split brain: both advise on what a landing page
   must sell).
~~7. Vendor-page verification for the payments table (Paddle/Stripe pricing~~ done — vendor pricing URLs (lemonsqueezy/paddle) present in metrics-and-payments.md (verified 2026-11-10)
   URLs — both vendor blogs were JS-shells this session).
~~8. Aging 🆕 → 🟢 — blocked on a real 0→1 launch run by design.~~ routed to TODO_LIST 2026-11-10

## d) TOTALLY FUCKED UP

~~1. **An unverified claim shipped as fact.** `channels-and-launch.md` says~~ done — claim removed from channels-and-launch.md (verified 2026-11-10: no "downranks" text remains)
   "PH now downranks non-launchable pages" — no source was ever fetched for
   this; it is exactly the hallucination class `verify-external-claims`
   exists to block. Severity: medium (trust in the skill's numbers). Fix: S —
   delete or source. Root cause: writing flowed from training knowledge while
   research-fattened sections surrounded it, masking the gap.
~~2. **Research budget mismanagement.** After the first rate-limit rejections I~~ routed to TODO_LIST 2026-11-10
   burned 4 more agent calls in bursts before adapting to raw fetches; then —
   worse — **never retried the capped agents during the ~30-minute synthesis
   phase** when the quota might have reset. The two least-sourced references
   (offer-and-pricing, proof-and-trust) could likely have been hardened.
   Severity: quality debt on the deliverable's weakest files. Root cause: no
   rate-limit protocol (adapt-once, never revisit).
~~3. **Missed a SESSION-START step-5 sub-instruction:** the day's core work was~~ routed — historical process miss; --triggers ran STRONG same day
   descriptions, yet `--triggers` was not run at session end — only at 17:28
   during this report (retroactively STRONG/green). Process miss, no damage.
~~4. **Missed the session-end worktree check** in session 1; done retroactively~~ done — ran clean retroactively 2026-10-24
   17:28 (clean). Trivial, but it was on the checklist.
~~5. **Commit-message convention violated by proxy:** repo wants detailed~~ routed — historical/structural; CHANGELOG carries the detailed record
   messages; the skill landed as three daemon "chore: auto-commit" blobs. The
   daemon is expected (global AGENTS), but I made no attempt to land a proper
   commit before it fired, and the CHANGELOG entry is now the only detailed
   record. Minor/structural.

## e) WHAT WE SHOULD IMPROVE

~~1. **Rate-limit protocol for research agents:** on first 429 → single-call~~ routed to TODO_LIST 2026-11-10
   mode + schedule one spaced retry every ~10 min during other work; record
   quota state in the session report. (Would have closed gap b1/d2.)
~~2. **JS-shell blacklist:** when raw fetch returns nav-only/empty twice for a~~ routed to TODO_LIST 2026-11-10
   domain, stop fetching it this session (3 near-identical LemonSqueezy index
   dumps were wasted context).
~~3. **Unverified-claim pass for content skills:** before finishing any~~ routed to TODO_LIST 2026-11-10
   research-based skill, one dedicated pass flagging every assertion without
   an inline source — soften, label, or cut (would have caught d1).
~~4. **Date-stamp survey data at cite time:** ProductLed benchmark is a~~ done — ProductLed benchmarks now stamped 2022 in metrics-and-payments.md (verified 2026-11-10)
   2022-vintage survey; noticed only while writing this report (the skill
   cites it yearless). Fix in f2; make stamping habitual.
~~5. **Enter the skill-creator loop even for subjective-output skills:** 2-3~~ done — evals entered (evals.json + trigger-eval.json verified 2026-11-10)
   cheap test prompts would have surfaced the copywriting trigger collision
   before it becomes a live misfire.

## f) Next tasks (22 real ones — capped where the honest list ends, no padding)

**Verify-hygiene (do first):**

~~1. Delete or source the "PH downranks non-launchable pages" claim — Critical, S, Bug.~~ done — claim deleted; no "downranks" text remains in channels-and-launch.md (verified 2026-11-10)
~~2. Date-stamp ProductLed benchmarks (2022 survey) in metrics-and-payments.md + SKILL.md benchmark mentions — High, S, Documentation.~~ done — benchmarks stamped 2022 in metrics-and-payments.md (verified 2026-11-10)
~~3. Retry capped research agents (pricing/offers, proof/guarantees) when quota resets; merge verified findings; relabel surviving heuristics — High, M, Quality.~~ routed to TODO_LIST 2026-11-10
~~4. Source or cut "refund rates low single digits" in proof-and-trust.md — Medium, S, Bug.~~ done — softened to labeled practitioner-experience phrasing in proof-and-trust.md (verified 2026-11-10)
~~5. Source or soften the "~1,000 visitors/month, don't A/B" floor in metrics-and-payments.md — Medium, S, Bug.~~ done — softened to labeled arithmetic rationale in metrics-and-payments.md (verified 2026-11-10)
~~6. Add vendor pricing URLs (Paddle, Stripe Managed Payments) + verify product scope; keep the verify-before-relying note — Medium, S, Documentation.~~ done — lemonsqueezy + paddle pricing URLs present in metrics-and-payments.md (verified 2026-11-10)

**Skill depth:**

~~7. Worked end-to-end example reference (one fictional micro-SaaS through all 8 steps) — High, M, Feature.~~ done — references/worked-example.md exists (verified 2026-11-10)
~~8. Page-review/teardown mode in SKILL.md (audit an existing page vs build) — High, S/M, Feature.~~ done — SKILL.md "Mode: page teardown" exists (verified 2026-11-10)
~~9. assets/launch-checklist.md — launch-day runbook (PH/HN/Reddit posts, maker comment, badge) — Medium, S, Feature.~~ done — assets/launch-checklist.md exists (verified 2026-11-10)
~~10. assets/copy-brief.md — positioning→copywriting handoff template — Medium, S, Feature.~~ routed to TODO_LIST 2026-11-10
~~11. Cold-outreach mini-reference (3 templates + reply handling + volume rules) — Medium, S, Feature.~~ routed — references/cold-outreach.md exists (verified 2026-11-10)
~~12. Waitlist→launch email sequence reference — Medium, S, Feature.~~ routed — references/waitlist-emails.md exists (verified 2026-11-10)
~~13. Cross-check website-launch demo-video doctrine vs first-customers page doctrine; link or de-dupe — Medium, S, Quality.~~ routed to TODO_LIST 2026-11-10

**Evals/process:**

~~14. Write 3 test prompts to first-customers/evals/evals.json (per skill-creator schema) — High, S, Feature.~~ done — first-customers/evals/evals.json exists (verified 2026-11-10)
~~15. Run with-skill vs baseline subagent runs on those prompts; review outputs — High, M, Quality.~~ routed to TODO_LIST 2026-11-10
~~16. Build the 20-query trigger set (incl. 6 copywriting-collision cases); run description optimization if tooling available — High, M, Quality.~~ routed to TODO_LIST 2026-11-10
~~17. Fresh-session smoke test: say "nobody signs up to my SaaS" and confirm first-customers loads over copywriting — High, S, Quality.~~ routed to TODO_LIST 2026-11-10
~~18. Commit the aggregation-repo symlink (precedent 1d897b7) — Low, S, Cleanup.~~ routed to TODO_LIST 2026-11-10
~~19. Re-read --signal prose advisories (SKILL.md lines 22-26, 45-51, 55-60); tighten if flabby — Low, S, Quality.~~ routed to TODO_LIST 2026-11-10
~~20. After first real launch run: age 🆕→🟢 in README + FEATURES with run evidence — Medium, M, Documentation.~~ routed to TODO_LIST 2026-11-10

**Repo:**

~~21. ROADMAP: decide whether a "Growth & Sales" theme is warranted if more GTM-adjacent skills are planned (offers-fork question interacts) — Low, S, Documentation.~~ routed to ROADMAP 2026-11-10
~~22. docs/external-dependencies.md: confirm first-customers has no external-CLI deps to list (it shouldn't) — Low, S, Cleanup.~~ routed to TODO_LIST 2026-11-10

> (f) is the HARVEST input — `docs-health` HARVEST should route these into
> TODO_LIST.md (actionable) vs ROADMAP (theme-level), skipping none as
> resolved.

## g) Questions I cannot answer myself (3)

~~1. **Which product exercises this skill first?** The skill ages 🆕→🟢 and its~~ routed to ROADMAP 2026-11-10
   evals only mean something against a real run: is there a concrete
   (micro-)SaaS of yours that should go through the 0→1 loop next, or should
   evals stay fictional? I cannot see your product pipeline.
~~2. **Trigger precedence preference:** when you say "improve my landing page~~ routed to ROADMAP 2026-11-10
   copy" with no sales context — should `first-customers` (strategy layer) or
   third-party `copywriting` (prose layer) win? I read both descriptions;
   precedence is a preference only you hold (and ROADMAP's open question about
   Crush's disambiguation mechanism makes it non-self-answerable).
~~3. **Research-retry vs evals — where does the next session's budget go?**~~ routed to ROADMAP 2026-11-10
   Hardening offer-and-pricing/proof-and-trust with the capped agents (quota
   may already be reset) vs spending that time on the skill-creator eval loop.
   Both are (f) items; priority is your call, not discoverable.
