# Activation — Trials, Onboarding & the Path to First Value

"Zero sales" is usually not a page problem alone: visitors sign up, never
reach value, and churn silently. Between 40-60% of new users who sign up never
come back after the first session, and without onboarding a SaaS can lose 75%
of new users in week one (ProductLed/announcekit-cited stats). Activation is
where those losses are recovered.

## The core sequence (ProductLed / Wes Bush)

Sales-led: acquire → monetize → engage. Product-led flips it: **acquire →
engage → monetize**. The upgrade becomes the natural consequence of a user
solving a costly problem inside the product. Consequence for the founder: the
trial/freemium experience IS the product's most important feature at 0→1.

## Time-to-Value and the aha moment

- **Aha moment**: the action after which retention jumps ("sent first invoice",
  "connected first repo" — Slack's classic: 2,000 messages exchanged).
- **Time-to-Value (TTV)**: time from signup to that moment. Reduce it before
  anything else; a longer trial never compensates for slow TTV.
- Find yours with a cohort split: users who did action X in session 1 vs not —
  if retention diverges, X is your activation metric. You have product
  analytics or 20 users? Ask/watch them — at 0→1, watching five real sessions
  (screen share) finds the blocker faster than any dashboard.
- BJ Fogg behavior model applied to onboarding: behavior = motivation ×
  ability × trigger. You control ability (make it easy) and triggers
  (prompts/emails) far more than motivation — so remove friction first
  (ProductLed onboarding guide).

## Onboarding — the five practices (ProductLed, distilled from 150+ teardowns)

1. **Speak to desires, not features** — every screen word answers "get paid
   3× faster" (Wave), not "invoice module".
2. **Show progress** — checklists/progress bars exploit the Zeigarnik effect
   (unfinished tasks nag); Canva's 4-step tour is the model.
3. **Welcome like a human** — a personal founder note/video; 85% say they're
   more loyal to businesses that welcome/educate after signup.
4. **Visual cues / product bumpers** — tooltips, hotspots, guided tours that
   push toward the OUTCOME, not UI labels ("this button changes font" is the
   anti-pattern). Don't add a tour to fix bad UX.
5. **Helpful empty states** — direct the next action; avoid both blank canvases
   (Mailchimp-style) and confusing fake dummy data.

Checklist items with outsized effect: SSO signup (Google/GitHub), no blocking
email verification, segment users by intent during signup (asks 1-2 questions,
feeds personalization AND your ICP data), and trigger-based emails.

## Trial/freemium conversion mechanics

- Median free→paid is ~9% overall; freemium visitor→signup converts 12% vs 5%
  for trials, but free→paid is flat across models (ProductLed benchmarks — see
  [./metrics-and-payments.md](./metrics-and-payments.md)).
- Trial length: long enough to reach the aha moment, short enough to create
  decision pressure. If users activate in 20 minutes, a 30-day trial is
  procrastination fuel — 7-14 days fits most micro-SaaS. Tettra's 15-day trial
  failed because the product's value accrues over months of accumulated
  content; they switched to freemium and upgrades tripled
  ([case](https://productled.com/blog/free-trial-vs-freemium)).
- End-of-trial behavior: reminder at T-3 days ("your data stays, payments
  start"), downgrade-to-view mode (data preserved, actions locked) converts
  better than hard locks, and an honest "not ready?" exit survey feeds both
  product and page objections.
- PQL (product-qualified lead): free accounts that crossed the aha moment —
  convert ~25% vs 9% baseline. For a solo founder this degenerates to a
  to-do list: every activated trial user gets a personal check-in email.

## Onboarding email sequence (day 0-7, trigger-based beats time-based)

| Trigger               | Email job                                                      |
| --------------------- | -------------------------------------------------------------- |
| Signup (day 0)        | One action to reach aha; personal founder voice                |
| Not activated +24-48h | Address the top blocker (from watching sessions); offer help   |
| Activated             | Upgrade path tied to the value they just experienced           |
| Day 7 dormant         | One-line "does X still matter to you?" honesty beats drip spam |

Every email: one CTA, plain text vibes, from the founder's name. Open rates
25-40% are achievable to a warm signup list (30x500 benchmark) — the sequence
is often where a "no sales" diagnosis actually leaks.

## FAQ/objection echo

Every activation blocker you observe live becomes a page FAQ answer and a
headline candidate. The page, onboarding, and emails are one conversation with
the same person — keep the vocabulary identical across all three.

## Sources

- Onboarding best practices + checklist: <https://productled.com/blog/5-best-practices-for-better-saas-user-onboarding>
- Free trial vs freemium (MOAT + Tettra): <https://productled.com/blog/free-trial-vs-freemium>
- PLG benchmarks (free→paid, PQL): <https://productled.com/blog/product-led-growth-benchmarks>
- PLG metrics definitions (TTV, activation, aha): <https://productled.com/blog/product-led-growth-definition>
