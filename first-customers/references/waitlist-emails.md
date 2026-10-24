# Waitlist → Launch Email Sequence

The pre-launch page's only job is capturing emails
([./channels-and-launch.md](./channels-and-launch.md)); this sequence
converts the capture into launch-day traffic. A waitlist that goes silent
until launch day converts a fraction of what a warmed one does — the
emails between signup and launch ARE the build-in-public marketing.

Boundary: this sequence ends when the product onboarding begins — from
the first product signup on, use the trigger sequence in
[./activation.md](./activation.md).

## The sequence

| # | Trigger | Job | One CTA |
| --- | --- | --- | --- |
| 0 | Signup | Confirm + deliver the promised thing (checklist, early access date, teaser) | confirm |
| 1 | Signup +5 min | The story: why this exists, what problem it kills (phrase-bank words) | reply "does this match your situation?" |
| 2 | Every 1-2 weeks until launch | Build-in-public update: one real detail (screenshot, number, mistake learned) | reply / nothing |
| 3 | Launch day, morning | "It's live" + founding offer + what to try first | try the product |
| 4 | Launch day, evening or +24h | The receipt: rank/numbers/thank-you ("we hit #7 on PH, 214 people tried it") | try the product |
| 5 | Offer deadline −48h | Last call on the founding price/bonus (a REAL deadline only) | upgrade/buy |

Rules that hold the sequence together:

- **Plain text, founder name, one link max per email.** Designed-in-a-tool
  emails read as marketing; the waitlist joined a person.
- **Same vocabulary as the page** (the phrase bank) — the emails pre-load
  the headline so the launch page feels recognized, not new.
- **Frequency discipline:** pre-launch, one email per 1-2 weeks maximum;
  launch week is the one legitimate burst (3 emails in 3 days).
- Every email #2 that has nothing real to show is skipped — silence beats
  filler.

## Copy skeletons

Email 3 (launch morning), whole thing:

```
Subject: it's live — [product]

[Name], [product] is up.

[One sentence: what it does, in the phrase-bank words.]

First 25 get [founding terms — real scarcity]. That's [n] left as of
this morning.

Try it: [link] — [the single aha action, e.g. "your first status page
takes ~10 minutes"].

Reply and tell me what breaks. I'm answering everything today.

— [Founder]
```

Email 5 (last call): restate the offer terms and the exact deadline date,
one proof line from launch week ("41 agencies started pages"), then stop
talking. The deadline must be one you execute
([./offer-and-pricing.md](./offer-and-pricing.md) honesty rules).

## Numbers to expect (labeled heuristics)

- Open rates 25-40% on a warm, self-selected waitlist (30x500-cited
  band); below ~20% the list is stale or the subject line is hiding the
  content.
- Launch-email click rate to product: treat 10-30% of opens as a good
  day. A 300-name waitlist realistically produces 30-90 launch-day
  visitors — which is why the waitlist is one input to launch day, never
  the whole plan.
- Reply rates to email #1's question: a few percent — but each reply is a
  positioning data point worth more than the click it didn't produce.

## Segmentation before launch day

Tag by signup source (community, Show HN, ad, personal) at capture —
launch-day email #3 gets one extra sentence per segment ("saw you in
r/agency — the agency dashboard is the part for you"). One sentence of
recognition, not bespoke emails.

## Anti-patterns

- Adding people who didn't sign up (the fastest way to land in spam and
  burn trust simultaneously)
- Double opt-in loops that silently eat signups — if used, make the
  confirmation the value delivery, not a barrier
- "Two weeks left!" sent three times at two-week intervals — fake
  deadlines poison every future real one
- A launch email with three CTAs (product, PH upvote, share tweet) —
  one ask per email, the product
