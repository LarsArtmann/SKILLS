# Metrics, Diagnosis & Payments

## Funnel benchmarks (know what "normal" is)

| Stage                               | Benchmark                                                           | Source                             |
| ----------------------------------- | ------------------------------------------------------------------- | ---------------------------------- |
| Landing page visitor → signup/trial | SaaS median **3.8%**; 5th-7th grade reading level pages hit ~12.9%  | Unbounce 2024 (41k pages)          |
| Visitor → free account (freemium)   | 12% median                                                          | ProductLed 2022 survey (600+ SaaS) |
| Visitor → trial start               | 5% median                                                           | ProductLed 2022                    |
| Free account → paid                 | **~9% median** overall; $1-5k ACV products ~10%; PQL-qualified ~25% | ProductLed 2022                    |
| Signup → ever returns               | 40-60% churn silently                                               | ProductLed-cited onboarding stats  |
| Product Hunt launch                 | ~10k visits good outcome; <10% even try the product                 | levels.io                          |

Read medians as diagnostic anchors, not targets: a 0→1 funnel with 50 visitors
is noise. The A/B floor is arithmetic, not opinion: detecting a relative 20%
lift on a 4% baseline at standard significance/power needs roughly **10,000
visitors PER VARIANT** (~20k total per test) — a 0→1 site never has that. Below
that volume, optimize qualitatively (watch sessions, ask the 5 who signed up
why the 45 didn't). When volume arrives, sequential testing tools shrink the
sample need but not by 100×.

## The diagnosis tree (where "no sales" actually leaks)

```
No visitors (<100/mo)        → CHANNEL problem. Nothing on the page matters yet.
                                → references/channels-and-launch.md
Visitors, no signups (<2%)   → PAGE/positioning problem.
                                → check: 5-second clarity, awareness-stage match,
                                  reading level, one CTA, proof, speed
Signups, no activation       → ONBOARDING problem (40-60% never return).
                                → references/activation.md; watch 5 sessions
Activated, no upgrade (<5%)  → OFFER/wall problem.
                                → check: paywall placement vs aha moment, price
                                  vs value perception, end-of-trial emails,
                                  PQL-style personal follow-up
Upgrades but immediate churn → EXPECTATION problem.
                                → page over-promised vs product reality; fix the
                                  promise, not just the product
```

Rule: diagnose top-down. Fixing a leak nobody reaches is wasted motion —
traffic first, then page, then activation, then offer.

## Minimal instrumentation (an afternoon, not a stack)

1. **Analytics**: one privacy-light analytics (Plausible/GA4) with 4 events:
   `visit`, `signup_start`, `signed_up`, `activated` (your aha action),
   `paid`.
2. **Session replay** on the landing + signup pages (Hotjar/PostHog free tier)
   — at low volume this beats every dashboard: watch 5 real sessions.
3. **Signup intent question** (optional radio in signup): feeds ICP data and
   objection mining (ProductLed segmentation).
4. **Cohort view weekly**: signups by week → activated → paid. Trends over
   weeks, not days, at 0→1 volumes.
5. **Ask the leak**: one automated email to anyone who signed up but didn't
   activate after 7 days — "what got in the way?" Replies are your roadmap.

## Payments — processor vs Merchant of Record (MoR)

The structural choice for a solo founder:

|                   | Bare processor (Stripe directly)                                                                                                | Merchant of Record (Paddle, Lemon Squeezy)                                                                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| You are           | the seller of record                                                                                                            | the supplier; the MoR sells to the customer                                                                                                                                                                    |
| Sales tax/VAT     | **you** register, collect, remit per country (EU: destination-based VAT via OSS for digital services; US: economic nexus rules) | MoR handles global sales tax/VAT/compliance ("global sales tax & compliance handled for you" — Lemon Squeezy)                                                                                                  |
| Fraud/chargebacks | yours                                                                                                                           | largely MoR's risk ops                                                                                                                                                                                         |
| Fees              | ~2.9%+30¢ class                                                                                                                 | MoR example: Lemon Squeezy **5% + 50¢/transaction** (verified 2026-10, [pricing](https://www.lemonsqueezy.com/pricing)); Paddle posts its current fees at [paddle.com/pricing](https://www.paddle.com/pricing) |
| Control/branding  | full checkout control                                                                                                           | hosted checkout, less control                                                                                                                                                                                  |

2026 state of the market (verified 2026-10): **Stripe acquired Lemon Squeezy**
(2024) and is converging it into **Stripe Managed Payments** (Lemon Squeezy
blog: "Stripe acquires Lemon Squeezy", "2026 Update: Lemon Squeezy + Stripe
Managed Payments") — i.e., Stripe itself now sells an MoR-style option.
Paddle remains the major independent MoR. Fees and product boundaries shift
quarterly: verify on the vendor pricing page before committing.

Decision rule for an EU-based solo founder (Lars's default): **MoR** — EU VAT
on digital services is destination-based from the first sale, and an MoR
erases the entire registration/remittance surface for ~2 points of fee. Use a
bare processor only if checkout customization or unit economics dominate.

## Checkout checklist (conversion + trust)

- Wallet buttons (Apple Pay / Google Pay) surfaced — measurable lift on mobile.
- Show total WITH tax handling clear (MoR: "VAT included/handled").
- One page: plan summary, price, what's included, guarantee restated, refund
  policy link.
- Email receipt that looks like a human sent it; failed-payment retry
  (dunning) enabled from day one — failed cards are involuntary churn you
  never see at 0→1 volumes until you do.
- Test the full buy path with a real card in test + live modes before launch
  day. A broken checkout on launch day burns the spike you spent weeks
  building.

## Sources

- Unbounce SaaS benchmarks: <https://unbounce.com/conversion-benchmark-report/saas-conversion-rate/>
- ProductLed benchmarks (2022 survey): <https://productled.com/blog/product-led-growth-benchmarks>
- A/B sample-size arithmetic: standard two-proportion power calculation; see
  Evan Miller's classic essay <https://www.evanmiller.org/ab-testing/>
- MoR definition + Stripe/Lemon Squeezy consolidation:
  <https://www.lemonsqueezy.com/blog/stripe-acquires-lemon-squeezy>,
  <https://www.lemonsqueezy.com/blog/2026-update>,
  <https://www.lemonsqueezy.com/reporting/merchant-of-record>
- EU VAT for SaaS background: <https://www.lemonsqueezy.com/blog/eu-saas-vat>
  (tax rules drift — confirm current obligations for your own situation)
- Vendor pricing pages (fees drift; check before committing):
  <https://www.lemonsqueezy.com/pricing>, <https://www.paddle.com/pricing>
