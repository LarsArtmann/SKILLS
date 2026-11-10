---
name: offer-page
description: >-
  Use when the user asks to build, rewrite, or tear down a page that SELLS
  one paid offer — sales page, offer page, landing page, pricing page,
  waitlist page. Triggers on "offer page", "sales page", "landing page", "pricing page", "build a page that
  sells/converts", "perfect offer page", "what does my page need", "what
  should I remove from my page", "nobody buys from my page", "tear down this
  sales page", "why doesn't my page convert". Delivers the non-negotiable
  sections, the cut list, mechanical voice gates, and pre-launch QA. The
  offer strategy (what to sell, positioning, pricing design, the 0-to-1
  funnel) belongs to first-customers; line-level prose polish to copywriting;
  visual/frontend implementation to design-to-code.
metadata:
  tags: sales, conversion, landing-page, offer, copywriting, marketing, pricing
allowed-tools: view bash edit write fetch grep
---

# Offer Page — build a page that sells

One page, ONE goal, ONE reader. The #1 failure mode is the page that
**describes** (feature tour, company story, jargon) instead of **sells**
(one reader, one promised outcome, one action). Guard: every section either
advances the promise, proves it, or removes a blocker — everything else gets
cut. A mediocre page selling a sharp offer beats a beautiful page selling a
foggy one; if the offer is the problem, stop and fix it upstream
(first-customers) before touching copy.

## Inputs — do not start prose without them

| Missing input                                           | Get it from                                                         |
| ------------------------------------------------------- | ------------------------------------------------------------------- |
| The offer: what they get, price, guarantee              | first-customers Step 3 (offer-and-pricing)                          |
| ONE reader: ICP, their verbatim words, awareness stage  | first-customers Steps 1-2 (research, positioning)                   |
| ONE goal: buy / start trial / join waitlist / book demo | decide now — exactly one; a page for two goals converts for neither |
| Proof that actually exists today                        | the proof ladder — borrow trust if zero customers                   |

## Build procedure

0. **Write the 5-second contract first**: three plain sentences — what is it,
   who is it for, what happens next. If you cannot write them, an input is
   missing; go upstream. Every section below exists to serve these three
   sentences.
1. **Skeleton** — pick sections from the 9-section persuasion arc with its
   skip rules, and set length by traffic temperature (colder and pricier =
   longer; zero padding): [./references/page-anatomy.md](references/page-anatomy.md).
2. **Hero** — headline matched to the reader's awareness stage (draft 25-50
   variants, keep the clearest, not the cleverest), subhead = the mechanism
   ("how"), the product itself as visual, CTA that names the get + a friction
   reducer ("No credit card · 2-minute setup"), one micro-proof line.
3. **Body** — problem in the reader's verbatim words, then mechanism, then
   features each translated into an outcome the reader wants.
4. **Proof** — only what exists. Valuable = named, ICP-matching, recent,
   outcome-specific. Worthless = vague, anonymous, outcome-free. Zero
   customers → founder identity + live demo + guarantee on your name.
5. **Offer block** — enumerate the value stack (core + named bonuses with
   values), anchor, dated unconditional guarantee adjacent to the price,
   ~3 tiers with the recommended one centered. Urgency only with a true
   reason-why.
6. **FAQ** — one entry per real objection, mined from reviews/support/communities,
   never invented; each answer points back to the CTA.
7. **Final CTA + P.S.** — restate the promise and the risk reversal.
8. **Voice gates** — run all ten mechanical pass/fail tests (grade ≤ 7,
   you ≥ 3× we, verbatim customer phrase, specificity, CTA shape, skim path,
   rhythm, honesty): [./references/voice-and-gates.md](references/voice-and-gates.md).
   A page that fails a gate is not done, whatever it looks like.
9. **Cut-list pass** — delete everything on the three-tier cut list:
   attention leaks (nav, carousels, competing CTAs), buying friction (late
   costs, forced registration, form bloat), and trust destroyers (fake
   urgency, fabricated proof): [./references/cut-list.md](references/cut-list.md).
10. **QA before launch** — fresh-reader 5-second test (test clarity only);
    load < 2s; check mobile first (83% of landing-page visits are mobile);
    click the FULL buy path with a real payment; confirm every claim on the
    page is checkable.

For line-by-line prose polish after the structure passes, fill
[./assets/copy-brief.md](assets/copy-brief.md) and hand it to the copywriting
skill — the brief pins WHAT the page argues; copywriting decides HOW each
line reads.

## Mode: audit (page already exists)

Audit before proposing anything; do not rewrite during the audit. Order:
(1) 5-second test; (2) headline vs the traffic's actual awareness stage;
(3) section gaps vs the arc; (4) proof claimed vs proof legitimately
available; (5) offer sharpness — stack, anchor, guarantee; (6) friction and
leaks vs the cut list; (7) voice gates; (8) FAQ: researched or invented.
Output: a numbered fix list ordered by expected impact — one fix per item,
each citing the finding that motivated it. Rewrite only after the user picks
fixes. If the page is fine but there is no traffic or no activation, that is
a funnel problem — first-customers.

## Honesty rules (always)

- No fabricated testimonials, user counts, review scores, or urgency — an
  honest page from a checkable person is the compounding asset.
- Every deadline, cap, and founding price is real and honored exactly.
- Name the limitations and who the offer is NOT for — disqualification sells.

## Related skills

- **first-customers** — owns the funnel: the offer, positioning, pricing
  design, proof ladder, launch channels. This skill consumes its outputs.
- **copywriting** (third-party) — prose polish per line, via the copy brief.
- **design-to-code** / **frontend-design** — visual and frontend
  implementation once the persuasive structure passes its gates.
- **product-launch-video** — a demo video's hook must restate the page's
  headline promise; video and page telling different stories depress both.
