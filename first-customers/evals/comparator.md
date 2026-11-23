# Comparator flow — blind-compare a guided output vs a no-skill baseline

The flow (authored 2026-11-23 from T92; the 2026-10-24 report routed
"comparator.md flow" but never defined it — this file is that definition,
derived from the skill-creator two-arm pattern and the doctrine-eval
protocol's honest-grading rules).

## Steps

1. **Pick a real-shaped task prompt** in the skill's core territory (0→1
   sales), concrete enough that general knowledge has a fair shot — the
   comparison is only honest if the baseline arm is allowed to be good.
2. **Two fresh subagents, same turn:** arm A reads the skill directory
   (SKILL.md + references on demand) and answers as the skill dictates;
   arm B gets the identical prompt with NO skill access. Neither knows the
   other exists.
3. **Grade both against the same assertion list**, derived from the
   skill's own method sections (stage diagnosis, VoC recipe, positioning,
   offer design, pricing mechanics, proof ladder, channel sequencing,
   activation, measurement discipline, ordered next actions). Full/Partial/
   Missing per assertion, with verbatim evidence quotes.
   Blinding note: the grading agent knows which arm is which (it dispatched
   them); assertions-based scoring with quoted evidence is the honest
   substitute for true blinding — grade BOTH arms completely before
   comparing, and credit the baseline wherever it earns it.
4. **Record the delta, not just the scores**: which assertions moved, and
   what the skill ADDS over good general knowledge. A skill that only
   matches the baseline on a topic its references don't cover is a finding
   about the references.
5. **Persist**: both full outputs under
   `evals/blind-compare-YYYY-MM-DD/{with_skill,baseline}/output.md` + the
   grading table in the run record. An eval that lives only in the session
   does not exist.

## Run 2026-11-23 (T92) — godup 0→1 task

Prompt (both arms identical): "I built godup, a CLI tool that finds
duplicated Go code using semantic analysis. Open source, 40 stars, $19
'Pro' on Gumroad, 2 months zero sales, no email list. How do I get my
first 10 paying customers?"

| # | Assertion (from the skill's method) | with_skill | baseline |
| - | ----------------------------------- | ---------- | -------- |
| 1 | Stage diagnosis with the traffic/conversion/offer tree + anchor numbers | ✅ "no visitors (<100/mo) → channel problem"; 3.8%/9% medians | ◐ funnel math (1–3% conversion, zero sales expected) but no stage tree |
| 2 | Zero-customer VoC recipe: review mining (verbatim pain/outcome/objection buckets), community mining, Mom-Test discipline | ✅ all three + phrase-bank deliverable + awareness/sophistication read | ◐ interviews + Mom-test rules + adjacent-tool study; no verbatim-bucket discipline |
| 3 | Positioning: alternatives → unique attribute → narrowed ICP → category | ✅ named steps (Dunford), "narrow until it hurts", draft statement | ✅ two segments + mechanism-led claim + benchmark-table proof |
| 4 | Offer as a job with a wall + value metric (not feature bag) | ✅ "the Refactor Kit", wall at the CI/team moment, value metric = team/repo usage | ✅ CI/PR product + DFY audit (strong instinct, no value-metric language) |
| 5 | Pricing mechanics: levers before price, honest scarcity mechanism, guarantee | ✅ 4 levers + $19 founding (first 25) → announced rise + 30-day guarantee | ◐ price reasoning ($19 awkward; $99–299; $499 audit) without levers/mechanism/guarantee |
| 6 | Proof ladder + pre-sell validation test with a count | ✅ founder identity/public receipts/famous-repo report; "~3 of 40 pay" pre-sell gate | ◐ benchmark table + GIF; no ladder, no countable pre-sell test |
| 7 | Channel sequencing: one at a time, community rules (9:1, link-in-comment), launch events | ✅ warm → r/golang → Show HN → PH → directories; 9:1 rule; re-launch events; outreach cap | ◐ outreach-first + proof-of-work post + plugin channels; no sequencing discipline |
| 8 | Activation: aha action, TTV budget, empty state, founder-as-sales | ✅ all four named | ✗ absent |
| 9 | Measurement discipline: medians as anchors only, qualitative at low volume, no premature A/B | ✅ weekly ritual; "no A/B until ~10k/variant" | ◐ 30-conversation decision gate (honest, but no ritual/anchors) |
| 10 | Ordered next actions + honest first target (3, not 30) | ✅ 6 steps + "3 paying customers, not 30" | ✅ 3–4 week plan + decision gate |

**Score: with_skill 10/10 · baseline 3 full + 4 partial (≈5/10).**

## Delta — what the skill adds over good general knowledge

The baseline (a strong general model) already covers diagnosis instinct,
segment narrowing, offer-as-CI-workflow, and channel choice — general
knowledge is GOOD at this genre. The skill's measurable delta concentrates
in **method discipline**: anchor numbers and stage trees instead of vibes
(#1), verbatim phrase-bank mining instead of "interview people" (#2),
pricing MECHANICS (levers, honest scarcity, guarantee) instead of price
picking (#5), a countable pre-sell gate (#6), sequencing and community
rules (#7), activation/TTV as a named section (#8), and measurement
discipline (#9). Where the skill matched the baseline (#3, #4, #10), its
references are not adding over the model's priors — acceptable for
positioning/offer (the skill's job is to sequence them, not out-write the
model), worth watching if a future re-run shows no delta on more rows.

Full outputs: `with_skill/output.md`, `baseline/output.md`.
