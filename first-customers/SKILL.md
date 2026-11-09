---
name: first-customers
description: >-
  Use when the user wants their FIRST paying customers for a (micro-)SaaS or
  indie product — the full 0-to-1 online sales loop: demand research,
  positioning, offer/pricing design, proof & trust, launch channels,
  activation, funnel diagnosis. Triggers on: "get my first customers", "first
  10 paying users", "nobody is signing up", "nobody buys", "not converting",
  "launch my SaaS", "validate demand", "pre-sell", "waitlist", "freemium vs
  free trial", "lifetime deal?", "Product Hunt launch", "build in public",
  "0 to 1 sales". This skill owns the strategy, the offer, and the measurement
  loop. For BUILDING or REWRITING the sales/offer/landing/pricing page itself
  use the offer-page skill; for page prose polish use copywriting; for docs
  site deployment use website-launch; for promo videos use product-launch-video.
metadata:
  tags: sales, saas, conversion, pricing, launch, marketing, indie, growth
allowed-tools: view bash edit write fetch grep
---

# First Customers — the 0→1 Sales Playbook

Take a (micro-)SaaS from zero to first paying customers. The loop is
diagnose → research → position → offer → page → channels → activation →
measure → repeat. Marketing is not a step after building: "if you build it,
they will come" is false by default (Rob Walling) — the only real validation
is someone paying (Pieter Levels). A complete fictional walkthrough of all
steps (StatusHawk, a status-page micro-SaaS):
[./references/worked-example.md](./references/worked-example.md) — imitate its
artifacts, not its invented numbers.

## Step 0 — Diagnose the stage first

Ask: what exists today (product? page? traffic? signups? payers?). Then jump
to the failing stage — never optimize a stage the funnel never reaches:

| Situation                                                                                                      | Bottleneck       | Go to                                 |
| -------------------------------------------------------------------------------------------------------------- | ---------------- | ------------------------------------- |
| Nothing built yet                                                                                              | demand unknown   | Step 1, then pre-sell before building |
| Built, no page/offer                                                                                           | no way to buy    | Steps 3-5                             |
| Page, <100 visitors/mo                                                                                         | channel          | Step 6                                |
| Visitors, <2% signup                                                                                           | page/positioning | Steps 2, 4, 5                         |
| Signups, no activation                                                                                         | onboarding       | Step 7                                |
| Activated, no upgrades                                                                                         | offer/wall       | Steps 3, 7                            |
| Full diagnosis tree + benchmarks: [./references/metrics-and-payments.md](./references/metrics-and-payments.md) |                  |                                       |

## Step 1 — Mine the market's words (before any copy)

Load [./references/market-research.md](./references/market-research.md). In
short: review-mine competitors/adjacent products (the zero-customer recipe —
500 reviews in ~3 hours beats any brainstorm), Sales Safari the communities,
interview with Mom Test rules (past behavior, never "would you buy"), and
diagnose the audience's awareness + market sophistication stages — they decide
the headline strategy. Deliverable: a phrase bank (pain words, outcome words,
objections) reused verbatim on every asset.

## Step 2 — Position

Load [./references/positioning.md](./references/positioning.md). Run Dunford's
five steps: competitive alternatives (incl. spreadsheets/do-nothing) → unique
attributes clustered into value themes → which segment cares most → market
category → one-paragraph positioning statement. Narrow the ICP until the page
can truthfully say "for \<specific segment\>". A page for everyone converts
for no one.

## Step 3 — Design the free model + the offer

Load [./references/offer-and-pricing.md](./references/offer-and-pricing.md).
Decide trial vs freemium vs demo with the MOAT questions (TAM, ocean,
makers/shakers, time-to-value) — micro-SaaS default is trial or paid-only +
refund window, freemium only with huge TAM. Price with a value metric, 1-3
tiers (one price is fine at the start), founding-member pricing for honest
launch urgency. Pull the four Hormozi levers before cutting price: outcome,
likelihood, time, effort. Refuse fake countdowns — real scarcity only.

## Step 4 — Build the sales page

Page assembly belongs to the **offer-page** skill: it owns the section
anatomy, the cut list, the voice gates, and page QA — run it with this
funnel's outputs (phrase bank, positioning statement, offer, proof ladder).
Two rules stay here because they are funnel-level, not page-level: (1) a
demo video (product-launch-video / website-launch) must restate the page
headline promise — video and page telling different stories depress both;
(2) page, onboarding, and email are one conversation — feed every observed
objection back into the page FAQ and headline vocabulary.

## Step 5 — Wire proof, trust, and payment

Load [./references/proof-and-trust.md](./references/proof-and-trust.md) and
the payments half of
[./references/metrics-and-payments.md](./references/metrics-and-payments.md).
At zero customers the proof ladder is: founder identity (name/face/about) +
build-in-public receipts + live demo + beta quotes — never fabricated counts.
Add an unconditional money-back guarantee + readable refund policy. Payments:
EU solo founder default is a Merchant of Record (Paddle, or Stripe via Lemon
Squeezy/Managed Payments — Stripe acquired Lemon Squeezy in 2024) so VAT and
global sales tax are handled; test the full buy path before launch day.

## Step 6 — Launch and distribute

Load [./references/channels-and-launch.md](./references/channels-and-launch.md).
Sequence: pre-launch email capture → warm soft launch (network + one
community) → public launches (Product Hunt, Show HN, Reddit — each with its
own post; Show HN requires something playable, no landing pages, maker
answering comments, no vote-asking) → re-launch every meaningful update. First
10 customers come from warm network + one niche community + a launch spike —
not ads, not SEO (both later). One channel at a time until repeatable. B2B
with no audience and no community: founder-to-founder
[./references/cold-outreach.md](./references/cold-outreach.md). The waitlist
sequence that primes launch day:
[./references/waitlist-emails.md](./references/waitlist-emails.md); execute
the two weeks with [./assets/launch-checklist.md](./assets/launch-checklist.md).

## Step 7 — Activate

Load [./references/activation.md](./references/activation.md). Find the aha
action (cohort divergence or watching 5 sessions), compress time-to-value, run
the five onboarding practices (desire-driven copy, progress, human welcome,
bumpers, helpful empty states) and the 4-email trigger sequence. Personal
check-in with every activated trial user — at 0→1, you ARE the sales team
(PQL ~25% conversion vs 9% baseline, ProductLed 2022).

## Step 8 — Measure and iterate

Instrument the five events (visit → signup_start → signed_up → activated →
paid) + session replay. Compare against the benchmark table weekly; when a
stage leaks, apply the diagnosis tree in
[./references/metrics-and-payments.md](./references/metrics-and-payments.md)
top-down. A/B testing needs ~10k visitors per variant to detect a 20% lift —
before that, qualitative only (watch sessions, email the leak) — do not A/B
test noise. Feed every observed blocker back into the page FAQ and headline
vocabulary: page, onboarding, and email are one conversation.

## Mode: page teardown (page already exists)

First diagnose the FUNNEL stage (Step 0 table) — never optimize a stage the
funnel never reaches. If the leak is the page itself, run the **offer-page**
skill's audit mode (5-second test, awareness match, section gaps, proof
claimed vs legitimately available, offer sharpness, friction, FAQ sourcing)
and keep only the funnel framing here: which stage leaks, and which upstream
inputs (mined words, positioning, offer) each page fix presupposes. Output: a
numbered fix list ordered by the diagnosis tree — leakiest reachable stage
first, one fix per item, each citing the finding that motivated it. Do not
rewrite the page during a teardown; that is Step 4 (or the copywriting skill,
for prose) after the user picks fixes.

## Honesty rules (always)

- No fabricated testimonials, user counts, or urgency. Founder trust is the
  core 0→1 asset; every kept promise compounds it.
- Every claim on the page must be checkable or provable on request.
- Honor founding-member pricing and announced price rises exactly.

## Related skills

- **offer-page** — page assembly (sections, cut list, voice gates, QA) once
  this skill's strategy work has produced the offer, the reader, and the
  proof ladder; hands line-level prose to copywriting.
- **website-launch** — docs-site build/deploy; **product-launch-video** — the
  promo video asset.
- **find-skills** — when the user wants additional GTM-adjacent skills.
