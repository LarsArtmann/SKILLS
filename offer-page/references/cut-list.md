# The Cut List — what an offer page does NOT need

A selling page loses more from what it includes than from what it omits. Cut in
three tiers:

- **Tier A** — measurably hurts conversion. Delete on sight.
- **Tier B** — neutral noise that wastes the reader's attention. Delete unless
  it earns its place.
- **Tier C** — can lift short-term conversion but destroys trust (and is
  increasingly illegal). Refuse on principle.

Audit any existing page against this list top to bottom; build any new page so
no item on it survives to launch.

## Tier A — measurably hurts

| #  | Cut                                                                | Why (evidence)                                                                                                                                      | Replace with                                                                  |
| -- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| 1  | Extra costs revealed late                                          | 40% of reason-giving US abandoners cite "extra costs too high" (Baymard, 4,532-adult survey)                                                        | The FULL price (incl. tax/shipping/fees) on the offer page itself             |
| 2  | Site navigation / header links                                     | Attention ratio must be 1:1 — every extra clickable is a leak (Oli Gardner/Unbounce)                                                                | Logo + the one CTA; legal/footer links only                                   |
| 3  | Competing CTAs / second offer                                      | Choice dilution (Hick's law); top-converting pages isolate one goal (Unbounce CBR, 6.6% median)                                                     | ONE goal. Exception: a ranked secondary for a genuinely different intent      |
| 4  | Forced account creation before buying                              | Top-4 abandonment reason in Baymard checkout research                                                                                               | Guest checkout / email-as-account                                             |
| 5  | Hero carousels / auto-rotating slides                              | Users see only slide 1 and scroll past the rest (NN/g); Runyon's Notre Dame study: ~1% engage the carousel at all (commonly cited; primary offline) | One static hero: one message + the CTA                                        |
| 6  | "Contact us for pricing" / chatbot price wall (under ~$10k offers) | Converts the price question into a qualification gate; top B2B-buyer frustration (qualitative, G2/Baymard)                                          | Visible price, or a floor ("from $X"). Exception: negotiated enterprise deals |
| 7  | Form bloat                                                         | Average US checkout: 23.48 form elements vs an ideal 12-14 (Baymard); label clarity beats raw field count (CXL)                                     | Only fields the order needs; rewrite labels before cutting wanted fields      |
| 8  | Double-entry email fields                                          | Documented typo-trap users resent (Baymard, qualitative)                                                                                            | One field + paste-safe validation                                             |
| 9  | Jargon, "difficult words", professional register                   | Difficult words correlate with lower conversion; plain pages win (Unbounce CBR; see voice gates)                                                    | 5th-7th grade language, verbs over nouns                                      |
| 10 | Slow pages                                                         | 0.1s speed improvement → +8.4% retail conversions (Deloitte, pinned in page-anatomy.md)                                                             | <2s load, slim scripts                                                        |

## Tier B — wasted attention

| #  | Cut                                                    | Why                                                                                                              | Replace with                                                             |
| -- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| 11 | About-us / mission / team photos in screen one         | Readers scan for what's-in-it-for-me; boilerplate is skipped (NN/g F-pattern)                                    | The offer outcome in screen one; one short founder block below the fold  |
| 12 | Stock photos, decorative imagery                       | Users treat generic photos as filler and ignore them (NN/g)                                                      | Real product screenshots, real faces                                     |
| 13 | Trust-badge piles                                      | No evidence >1-2 genuine marks help; clutter reads as insecurity                                                 | 1-2 real marks (payment processor, SSL)                                  |
| 14 | Autoplay video with sound                              | Motion outside user control triggers banner blindness (NN/g); Chrome blocks unmuted autoplay anyway              | Click-to-play, captioned, 60-120s                                        |
| 15 | Exit-intent popups on the offer page                   | Interrupts the exact moment of decision; competes with the CTA (attention ratio); vendor lift numbers unverified | Nothing. (Discount capture belongs on content pages, not the offer page) |
| 16 | Cookie consent walls                                   | Coercive consent is a dark pattern (EU DSA Art. 25); CNIL fined Google/Meta over reject-all friction             | Soft banner; reject-as-easy-as-accept                                    |
| 17 | Cookie-cutter AI copy ("In today's fast-paced world…") | Buyer fatigue with template AI prose (qualitative, 2024-2026); reads as filler                                   | One human writing to one human — see voice gates                         |

## Tier C — refuse on principle

May lift this week's numbers; destroys the trust a solo founder or small
product lives on, and regulators are catching up.

| #  | Refuse                                             | Why                                                                                      | The honest version                                                   |
| -- | -------------------------------------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| 18 | Fake countdown timers / fabricated scarcity        | Resets on reload = fraud-adjacent; EU DSA Art. 25 bans choice-manipulating dark patterns | Real deadlines: founding-price sunset, true cohort caps, real stock  |
| 19 | Fabricated testimonials / invented review scores   | FTC final rule 16 CFR Part 465 (effective 2024-10-21) makes fake reviews actionable      | Only verifiable testimonials with names/links; borrow trust if young |
| 20 | Confirm-shaming ("No thanks, I hate saving money") | Dark pattern under the same rules; destroys voice trust                                  | Plain "No thanks"                                                    |

## Cut order when auditing an existing page

1, 2, 5, 3 (attention leaks first — the reader must have nowhere to go but the
CTA), then 4, 6, 7, 8 (buying friction), then the Tier C sweep (18-20), then
Tier B polish. Every cut gets stated in the fix list as: what was cut → the
finding that motivated it.

## Verification status

| Claim                                                                                                       | Status                                                           | Source                                                                                                       |
| ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| 40% "extra costs too high" abandonment; 23.48 avg form elements vs 12-14 ideal; 70.22% avg cart abandonment | Verified (fetched live)                                          | [Baymard cart abandonment](https://baymard.com/lists/cart-abandonment-rate)                                  |
| Attention ratio 1:1                                                                                         | Verified (framework)                                             | [Unbounce attention ratio](https://unbounce.com/conversion-glossary-definition/attention-ratio/)             |
| Carousel slide-1 fixation; users skip carousels                                                             | Verified (fetched live)                                          | [NN/g carousels](https://www.nngroup.com/articles/designing-effective-carousels/)                            |
| Runyon: ~1% carousel engagement, 84% of clicks on slide 1                                                   | Unverified (primary offline; listicle-only)                      | erunyon.com defunct; directionally consistent with NN/g                                                      |
| Landing-page median 6.6%; difficult words correlate with lower conversion                                   | Verified (repo-pinned)                                           | Unbounce Conversion Benchmark Report (see page-anatomy.md)                                                   |
| EU DSA Art. 25 dark-pattern ban                                                                             | Verified (fetched live)                                          | [EUR-Lex 2022/2065](https://eur-lex.europa.eu/eli/reg/2022/2065/oj)                                          |
| FTC fake-reviews rule 16 CFR Part 465, effective 2024-10-21                                                 | Verified (rule exists; press page blocked to bots)               | [FTC legal library](https://www.ftc.gov/legal-library/browse/rules/fake-reviews-rule)                        |
| CNIL cookie fines Google €150M / Meta €60M (2022)                                                           | Secondary (well-documented press; not re-fetched)                | [CNIL](https://www.cnil.fr/en/cookies-cnil-fines-google-and-facebook-total-150-million-and-60-million-euros) |
| CXL 9-field label-rewrite (+19.2%)                                                                          | Verified (repo-pinned in page-anatomy.md)                        | [CXL form fields](https://cxl.com/blog/reduce-form-fields/)                                                  |
| "Contact us for pricing" hurts B2B                                                                          | Qualitative only (G2/Baymard buyer surveys; no controlled study) | —                                                                                                            |
| Exit-intent popup lift numbers                                                                              | Vendor-supplied, unverified                                      | (OptinMonster/Sumo marketing pages)                                                                          |
| Deloitte 0.1s → +8.4%                                                                                       | Verified (repo-pinned in page-anatomy.md)                        | Deloitte "Milliseconds Make Millions"                                                                        |
