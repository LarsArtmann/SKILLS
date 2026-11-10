# Voice & Gates — writing human, direct, action-oriented, audience-matched copy

The page's voice decides whether a well-structured page still feels like a
vendor or like a person. The gates below are mechanical pass/fail tests — a
page passes or fails, no taste required. Run them on every draft (hero first,
then the full page).

## The evidence in one paragraph

SaaS pages at 5th-7th grade reading level convert **12.9%** vs **2.1%** at
professional level; difficult words correlate −24.3% with conversion (Unbounce
CBR 2024). Users read at most **28%** of the words on a page and give an extra
100 words only 4.4 seconds (NN/g). Concise + scannable + objective writing
measured **+124% usability** combined (NN/g, Morkes & Nielsen). Customer-words
beat marketer-words: a headline rebuilt from a verbatim customer phrase lifted
CTA clicks **>400%** (CXL/Wiebe rehab test); naming the audience + outcome in
a subhead lifted conversions **+9.2%** and the audience-matched CTA **+66.3%**
(Learn Visual Studio). Even expert audiences prefer plain language — jargon
never buys credibility (NN/g).

## The ten gates

| #  | Gate           | Pass condition                                                                                                                                             |
| -- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1  | Grade          | Flesch-Kincaid grade ≤ 7 (hero + full page). 12.9% vs 2.1% is the price of failing                                                                         |
| 2  | Hard words     | ≤ 140 three-syllable words total; SaaS band 250-725 words. Count, don't guess                                                                              |
| 3  | You            | you/your ≥ 3× we/our/us; zero "We are… / We offer…" sentences above the fold                                                                               |
| 4  | Audience       | Hero names WHO it's for or their situation; one "This is for X who…" and/or "Not for you if…" line                                                         |
| 5  | Customer words | ≥ 1 verbatim customer phrase (from reviews/support/communities) in the headline, subhead, or bullets                                                       |
| 6  | Specificity    | Every benefit carries a number, timeframe, price, or named proof. Ban "save time", "world-class", "seamless", "cutting-edge"                               |
| 7  | CTA            | Button starts with a verb and names the get ("Start my free trial"), ≤ 5 words; "my vs your" flagged for A/B                                               |
| 8  | Skim           | Headline + subheads + bullets + CTA alone close the sale; a subhead every ≤ 150 words; paragraphs ≤ 3 lines; the first 2 words of every line carry meaning |
| 9  | Rhythm         | Average sentence ≤ ~20 words; at least one one-line sentence per section; passes read-aloud — sounds like speech, not a brochure                           |
| 10 | Honesty        | Refund/cancel/trial terms stated as concrete plain actions ("cancel in one click, no questions asked"); at least one admitted limitation or disqualifier   |

Checking 1-2 mechanically: `textstat` (Python) exposes
`flesch_kincaid_grade()`, `difficult_words()`; the Hemingway app and
readable.com do it interactively. If no tool runs, count syllables by hand on
the hero — the hero alone must pass.

## Why each gate earns its place (source ledger)

| Gate | Finding                                                                                                                                                          | Source                                                                                                                                                                                                                   |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1, 2 | 5th-7th grade = 12.9% SaaS CVR vs 2.1% professional; all-industry 11.1% vs 5.3%; difficult words −24.3%, word count −19.4%, reading time −18.6%                  | [Unbounce CBR 2024](https://unbounce.com/conversion-benchmark-report/) (fetched live)                                                                                                                                    |
| 8    | Users read ≤ 28% of words; +4.4s per extra 100 words; concise +58%, scannable +47%, objective +27%, combined +124% usability                                     | [NN/g how little users read](https://www.nngroup.com/articles/how-little-do-users-read/), [NN/g concise-scannable-objective](https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/) |
| 8    | Layer-cake/F scanning: headings carry the scan; first 2 words of each line matter                                                                                | [NN/g layer-cake](https://www.nngroup.com/articles/layer-cake-pattern-scanning/)                                                                                                                                         |
| 5    | Verbatim customer-phrase headline: >400% CTA clicks, >20% form submissions (single documented test — n=1 caution)                                                | [CXL voice of customer](https://cxl.com/blog/voice-of-customer/)                                                                                                                                                         |
| 4    | Audience+outcome subhead: +9.2% conversions, +24% pricing views; audience-matched CTA +66.3% clicks                                                              | same CXL article                                                                                                                                                                                                         |
| 3    | You:we ratio is doctrine (Eisenbergs' We-We calculator — tool offline, no published A/B); self-referencing "you" increases elaboration (Burnkrant & Unnava 1989) | doctrine + academic; treat 3:1 as heuristic, not physics                                                                                                                                                                 |
| 7    | "Order…" → "Get…": +14.79%, replication +38.26%; scenario-naming CTA +213.16%; "your"→"my" +90% (direction varies)                                               | [ContentVerve button tests](http://contentverve.com/10-call-to-action-case-studies-examples-from-button-tests/) (archived primary)                                                                                       |
| 6    | Numbers on every claim across every verified high-converting page (Basecamp "4,000 companies signed up last week", shipfa.st "$45,000 a month, 8447 makers")     | pattern synthesis, verified live/archived 2026                                                                                                                                                                           |
| 10   | Pratfall effect / two-sided messages (doctrine); Basecamp's "single button to cancel, no questions asked"                                                        | doctrine + archived pages                                                                                                                                                                                                |
| 1    | Plain language persuades experts too — clarity reads as transparency                                                                                             | [NN/g plain language for experts](https://www.nngroup.com/articles/plain-language-experts/)                                                                                                                              |

## Unverified-number ledger (never cite these)

- HubSpot "personalized CTAs convert 202% better" — original page dead.
- Crazy Egg "long-form homepage +64%" — founder-reported, original article
  unretrievable.
- Basecamp "sign up in 60 seconds" — not found on current or archived pages.
- Eisenberg We-We ratio as an effect size — heuristic only, no A/B.
- (Corrected 2026-11-10: the widely-quoted "+68%" gym-CTA lift is wrong; the
  archived primary says +213.16%.)

## Worked micro-example

Before (fails 6 of 10 gates):

> **Revolutionizing Workflow Management** — In today's fast-paced business
> environment, we empower organizations to seamlessly optimize their
> operational workflows through our cutting-edge platform. [Sign Up]

After (passes):

> **Your invoices, paid in 15 days instead of 45.** For freelancers who chase
> payments every month — in your words: "I did the work, then became a
> debt collector." Invoicer sends, reminds, and escalates for you.
> [Send my first invoice — free]

Grade 5 · you:we 6:1 · audience named · verbatim phrase · numbers on the
promise · verb-first CTA naming the get.
