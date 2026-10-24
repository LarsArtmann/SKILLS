# Worked Example — One Micro-SaaS Through All 8 Steps

One fictional product carried through the entire loop, so every framework in
this skill resolves to a concrete artifact you can imitate. **The product and
its outcome numbers are invented teaching values, not benchmarks** — the
medians quoted alongside are real and sourced in their own reference files.

**The product:** StatusHawk — status pages + uptime monitoring for small web
agencies managing 5-20 client sites. Solo EU-based developer, MVP built over
6 weekends, zero customers. Swap in your product and segment as you read.

## Step 0 — Diagnose

| Fact | Value |
| --- | --- |
| Product | built (MVP) |
| Sales page | exists, generic: "Uptime monitoring for everyone" |
| Traffic | ~40 visitors/month (founder's own posts) |
| Signups | 3 (two are friends) |
| Payers | 0 |

Diagnosis: under 100 visitors/month AND under 2% signup → the bottleneck is
**channel first, then page/positioning**. Nothing downstream (onboarding,
pricing tiers, checkout polish) gets touched until those two move. This is
the step most founders skip — they redesign the pricing page nobody reaches.

## Step 1 — Research ([./market-research.md](./market-research.md))

Review-mined ~200 reviews of StatusCake, UptimeRobot, BetterStack on
G2/TrustPilot + r/webdev and r/agency threads (Sales Safari). Harvest:

| Bucket | Mined phrases (verbatim) |
| --- | --- |
| Pain | "client called ME when their site was down", "checking 30 dashboards every morning", "I look unprofessional forwarding Cloudflare emails" |
| Outcome | "one place for all client sites", "client stops asking me if it's them or the host", "look like a real agency" |
| Objections | "another dashboard to babysit", "SMS alerts cost extra everywhere", "what happens when YOU go down?" |

Awareness: **solution aware** (agencies know monitoring exists; they use
spreadsheet + Cloudflare pings) → headline leads with the MECHANISM.
Sophistication: **stage 3** (every competitor claims "99.9% uptime alerts")
→ a named mechanism, not a louder claim.

## Step 2 — Position ([./positioning.md](./positioning.md))

Dunford run, compressed:

- Alternatives clients would use without us: Cloudflare free alerts +
  forwarding emails, UptimeRobot free tier, a spreadsheet the agency checks
  manually, doing nothing (the client emails when angry — the real
  competitor).
- Unique attributes: per-client branding of every status page; one
  agency-level dashboard; client-facing incident updates written for
  non-technical clients.
- Who cares most: 1-10 person agencies whose clients ask "is it down for
  you too?"
- Category: not "uptime monitoring" (red ocean of giants) — **"status pages
  for agencies"**.

Positioning statement:

```
For small web agencies juggling 5-20 client sites, StatusHawk is a
status-page and monitoring hub that shows every client's uptime on one
branded page clients can check themselves. Unlike free uptime alerts that
email the agency at 3am, StatusHawk makes the CLIENT self-serve the answer,
so the agency stops being the middleman for "is it down?".
```

## Step 3 — Offer ([./offer-and-pricing.md](./offer-and-pricing.md))

MOAT: differentiated strategy (niche, pricier than free tiers), red-ish
ocean, makers (agency owners try before buying), TTV ~10 minutes →
**14-day free trial, no card required**.

- Value metric: client sites monitored (grows with the agency; free tiers
  cap at 5).
- One price to start: **$19/month** (up to 25 sites, unlimited status
  pages). Second tier only when users ask.
- Founding offer: first 25 agencies get **$12/month forever** — real
  scarcity (the count), honest urgency.
- Hormozi levers before price: outcome named ("clients check the status
  page instead of calling you"), likelihood (live demo + 30-day guarantee),
  time ("first status page live in 10 minutes"), effort ("we import your
  UptimeRobot monitors").

## Step 4 — Sales page ([./sales-page-anatomy.md](./sales-page-anatomy.md))

9-section arc, each section's draft thesis:

1. Hero. Headline candidates (drafted 20, kept mechanism-led for the
   solution-aware audience): "Your clients check your status page — not
   your phone" / "One branded status page per client. Zero 3am 'is it
   down?' texts." Subhead: mechanism — "StatusHawk watches every client
   site and gives each one its own page your client can read." CTA: "Start
   my 14-day trial" + "No credit card · first page live in 10 minutes".
2. Proof strip: none yet → founder identity line ("Built by one solo dev
   — face, name, public changelog") + live demo link.
3. Problem: the 3am call, the 30-dashboards morning — in mined words.
4. Mechanism: GIF of monitor → branded page publish; "how it works" 3 steps.
5. Features → benefits: per-client branding → "look like a real agency";
   one dashboard → "one morning check instead of thirty".
6. Proof: 3 beta-user quotes with role + agency size; the "what if
   StatusHawk goes down" FAQ points here too.
7. Pricing: single $19 tier (founding $12 struck-through with the honest
   counter), annual $190.
8. FAQ: every mined objection as a question ("Do alerts cost extra?",
   "What happens if StatusHawk itself is down?" → hosted on separate infra
   + export).
9. Final CTA + P.S. restating the guarantee.

## Step 5 — Proof, trust, payment ([./proof-and-trust.md](./proof-and-trust.md))

- Ladder rungs used at zero customers: founder face + about page (rung 5),
  build-in-public receipts (rung 3), interactive live demo status page —
  the product proving itself (rung 4), 3 beta quotes (rung 2).
- 30-day unconditional money-back, one paragraph, linked at pricing.
- Payments: EU solo founder → Merchant of Record (Lemon Squeezy 5% + 50¢,
  verified 2026-10) so EU VAT is handled; full buy-path tested in live mode
  with a real card BEFORE launch day.

## Step 6 — Launch ([./channels-and-launch.md](./channels-and-launch.md))

Two-week calendar:

| When | Action |
| --- | --- |
| T-14 | Page rewritten to the arc above; founding offer published |
| T-10 | Warm soft launch: 14 personal emails to agency contacts from the beta ("you're in the first 25") |
| T-7 | r/agency + r/webdev build-story post (problem → numbers → demo link in comments) |
| T-3 | Waitlist emailed: launch date, founding offer count |
| Day 0 | Show HN morning (playable product, maker answering all day) |
| Day +3 | Product Hunt (GIF demo, maker first comment, warm audience notified — no upvote asks) |
| Day +7 | Directories batch (Uneed, SaaSHub, AlternativeTo, niche lists); retro |

Expected shape (illustrative): warm + community ≈ 60 visitors and 2-3
trials; Show HN spike ≈ 800-2,000 visitors, 3-8% try it; PH spike ≈ 1-3k
visitors. Launch spikes convert worse than warm traffic — that is normal,
not failure.

## Step 7 — Activation ([./activation.md](./activation.md))

- Aha action: **first status page published** (cohort of beta users who
  published in session 1 all returned; those who only added monitors
  didn't).
- TTV budget: signup → publish in ≤10 minutes; onboarding is a 3-item
  checklist (add site → pick template → publish), SSO via Google.
- Trigger emails: day 0 "publish your first page (2 steps left)", +48h
  blocker email, activated → founder check-in (PQL-style, ~25% conversion
  vs ~9% baseline, ProductLed 2022), day 7 dormant one-liner.

## Step 8 — Measure ([./metrics-and-payments.md](./metrics-and-payments.md))

Weekly cohort ritual, 30 minutes: visitors → signups → activated → paid,
vs medians (SaaS LP 3.8% Unbounce 2024; free→paid ~9% ProductLed 2022):

| Week reality (illustrative) | Diagnosis | Move |
| --- | --- | --- |
| 1,400 visitors, 41 signups (2.9%) | page slightly under median | watch 5 replays; clarity fix, not redesign |
| 41 signups, 9 activated (22%) | onboarding leak | shorten checklist; blocker email rewrite |
| 9 activated, 2 paid (22% of activated) | at/better than ~25% PQL shape | keep going; ask the 7 why not |

At these volumes: NO A/B tests (10k visitors per variant needed) — replays
and replies only. First month target: **3 paying agencies**, not 30.

## Deliverables checklist (what YOU produce per step)

1. Diagnosis one-liner (bottleneck + which steps are blocked)
2. Phrase bank table (pain / outcome / objection, verbatim)
3. Positioning statement (filled template)
4. Offer card (model, price, metric, founding terms, guarantee)
5. Page outline (9 sections, thesis per section, headline shortlist)
6. Proof plan (ladder rungs usable today) + payments decision
7. Launch calendar + per-channel post drafts
8. Activation definition (aha action, TTV budget, trigger emails)
9. Metrics dashboard (5 events) + weekly ritual slot
