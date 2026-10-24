# Offer & Pricing Design

The offer is what the visitor actually buys; the page merely communicates it.
A mediocre page with a sharp offer beats a great page with a foggy one.
Hormozi's framing (*$100M Offers*): make the offer so good people feel stupid
saying no — then the page only has to be clear.

## Free model choice — the MOAT framework (Wes Bush / ProductLed)

Pick trial vs freemium vs demo with four questions, not habit:

| Question | Answer pushes toward |
| --- | --- |
| **M**arket strategy: dominant (better AND cheaper, huge TAM) / differentiated (specialized, pricier, small TAM) / disruptive (simpler + cheaper for over-served users) | Dominant + disruptive → freemium-friendly; differentiated → trial/demo |
| **O**cean: red (existing demand, buyers know the category) vs blue (you must educate) | Red ocean → self-serve product-led; blue ocean → sales/marketing-led first |
| **A**udience: makers (end users who try before buying) vs shakers (execs who buy big-picture) | Makers → self-serve; shakers → demo/sales |
| **T**ime-to-value: how fast can a NEW user hit the "aha" moment unaided? | Fast TTV → trial/freemium; slow or data-heavy → demo or paid pilot |

Model definitions: free trial = partial/full product for limited time;
freemium = limited product forever. Benchmarks (ProductLed 2022 survey of 600+
SaaS, [PLG benchmarks](https://productled.com/blog/product-led-growth-benchmarks)):
median free→paid conversion ≈ **9%** overall; visitor→signup converts at 12%
median for freemium vs 5% for free trials; PQL-driven free trials convert ~25%
(3×). Jason Lemkin's counterpoint (SaaStr): freemium needs massive volume to
work — with a TAM of a few hundred customers, a free tier gives away the
product to exactly the people who would pay. Micro-SaaS default: **free trial
or paid-only with a refund window**, not freemium, unless acquisition (not
revenue) is the bottleneck.

Case worth knowing: Tettra switched 15-day trial → freemium and signups rose
~2.5×, upgrades tripled within 5 quarters, retention never dipped below 70%
([full case](https://productled.com/blog/free-trial-vs-freemium)) — the model
matters less than whether users can reach the aha moment inside the free
experience. Trial length rule: as long as it takes a realistic user to reach
value (often 7-14 days); a trial that ends before the aha moment converts
nothing.

Credit card at signup: raises trial quality and free→paid conversion but cuts
trial starts. At 0→1 you want volume of REAL usage signals more than clean
conversion optics — start without card requirement, revisit once activation is
healthy.

## Pricing construction

1. **Value metric** — price per the unit value grows with (seats, projects,
   tracked events, API calls). The right value metric grows with the customer
   (ProfitWell/Paddle research direction: value metric choice is the single
   highest-leverage pricing decision). Micro-SaaS sanity check: if your only
   metric is "1 flat plan", the metric is "business exists" — fine to start.
2. **Tier count** — 2-3 tiers. One entry tier that solves the core problem, one
   pro tier with the things power users outgrow, optional enterprise/contact.
   For a tiny product, ONE price is honest and converts fine (Marc Lou's
   products ship single one-time prices); add the second tier when users ask
   for more, not before.
3. **Anchoring** — order high→low or highlight the middle "most popular" tier
   (decoy effect). If one plan: show the anchor as the alternative's cost
   ("an agency charges $2k/month for this").
4. **Annual option** — offer annual at a meaningful discount (10-20% is the
   common band; treat as heuristic, not law) mainly to pull cash forward and
   kill monthly churn for committed users.
5. **Price endings** — charm pricing ($29) is standard in B2C; for B2B SaaS,
   round confident numbers ($30/$50/$100) read more professional. Low-stakes
   choice; don't sweat it.
6. **Founding-member pricing** — at launch, a labeled early-adopter price
   ("first 50 customers get $9/mo forever") converts your warmest leads, is
   honest urgency (real scarcity: the count), and gives you your first
   testimonials. Honor it forever — that trust is the asset.

## Van Westendorp Price Sensitivity Meter

Four questions to a slice of your ICP (n≥20 for a usable read, fewer still
beats guessing):

1. At what price would you consider it too expensive to consider?
2. At what price would you consider it so cheap you'd doubt quality?
3. At what price would it start to feel expensive but still worth considering?
4. At what price would it be a bargain?

Plot the cumulative curves; the intersections give the acceptable range
(too-cheap floor, bargain, expensive, ceiling). Launch near the upper-middle
of the range — cutting price later is easy, raising it is painful. (Method:
Van Westendorp 1976; standard reference in pricing research.)

## Hormozi's value equation

Perceived value = (Dream outcome × Perceived likelihood of success) ÷
(Time delay × Effort & sacrifice). Four levers to pull before touching price:

| Lever | Page/offer move |
| --- | --- |
| Dream outcome | Name the specific end-state, quantified |
| Perceived likelihood | Proof: testimonials, demos, guarantees, "here's exactly how it works" |
| Time delay | "First result in 10 minutes" — compress promised time-to-value honestly |
| Effort & sacrifice | "We migrate your data", templates included, "no code, no config" |

Guarantees (see [./proof-and-trust.md](./proof-and-trust.md) for evidence):
unconditional money-back (conversion-max), conditional/results-based
("X outcome in 30 days or refund" — strong when you control usage), and the
anti-guarantee for premium positioning (no refund, priced with swagger).
Bonuses: each bonus should kill a NAMED objection ("onboarding call" kills
"will I figure it out alone?"). Name the offer; generic "Pro plan" is weaker
than "The Audit Kit".

## Lifetime deals (LTD) — the honest tradeoff

Pro: instant cash, first 100 users, testimonials, ranking on deal platforms.
Con: bargain-hunter cohorts churn-adjacent, review-bomb leverage, permanently
anchors your product at $39 when you need $39/month, and support load at the
exact moment you're weakest. Rule of thumb from the indie community: LTDs are
a financing decision, not a growth strategy — take them only if you
specifically need cash/validation NOW and cap the count (real scarcity again).

## Honesty rules (non-negotiable)

- Fake countdown timers and fabricated "only 3 left" destroy the founder-trust
  asset and are illegal in many jurisdictions (dark-pattern regulation trend).
- Real scarcity = real limits: founding-cohort size, launch-week bonus, price
  rises on a public date you then actually execute.
- Every price change: announce, grandfather existing customers, execute on the
  announced date. Each kept promise compounds trust; each broken one ends the
  referral channel.

## Sources

- MOAT framework + Tettra case: <https://productled.com/blog/free-trial-vs-freemium>
- PLG conversion benchmarks: <https://productled.com/blog/product-led-growth-benchmarks>
- SaaStr freemium caution: <https://www.saastr.com/you-need-50-million-users-for-freemium-to-actually-work/>
- Pricing model overview: <https://www.lemonsqueezy.com/blog/saas-pricing-models>
- Hormozi: *$100M Offers* (2021) — value equation + guarantee stack are book
  content; cite the book, not blog summaries.
