# Trigger probe — iteration 1, re-run 2026-11-22

The original 2026-11-10 authoring-session probe passed but was never
persisted (finding c4/f4); per the rule "an eval is not done until it is on
disk", the probe was re-run 2026-11-22 in fresh sessions (`crush run`, one
invocation per prompt, cwd `/home/lars/projects/SKILLS`). Each prompt asked
the agent to name the ONE skill it would load and why, in three lines.

## Routing

| Prompt (condensed)                                                     | Answer             | Verdict |
| ---------------------------------------------------------------------- | ------------------ | ------- |
| "what does my sales page need before I launch my $29 notion template pack? stripe checkout is ready" | `offer-page`       | correct |
| "get my first 10 paying customers for my micro saas, I don't even have a page yet" | `first-customers` (explicitly NOT offer-page) | correct |
| "set up a documentation website for my Go library with astro starlight and firebase hosting" | `website-launch`   | correct |

## Verbatim answers

1. "**offer-page** — the request is exactly its trigger ("what does my page
   need", one paid offer, a page that sells), and with Stripe checkout ready
   the gap is the page itself, not payments. `first-customers` is the
   fallback only if the page audit finds the offer, positioning or proof
   inputs missing, since offer-page hands those back to it."
2. "**first-customers** — its trigger list names this request verbatim
   ("first 10 paying users", "nobody is signing up", 0 to 1 sales) and it
   owns the pre-page work: demand validation, positioning, offer and pricing,
   launch channels. `offer-page` is the wrong first pick: it assembles a page
   from offer, positioning and proof inputs you don't have yet, and it routes
   those back to `first-customers`."
3. "**website-launch** — it owns exactly this: the Astro + Starlight +
   Tailwind v4 + Firebase Hosting documentation-site pattern for Go projects.
   It also covers DNS, GitHub metadata, and the default HyperFrames
   demo-video centerpiece."

The boundary arms matter more than the positive one: `first-customers` is
the skill that would silently absorb page work if offer-page's description
drifted, and it named the split correctly in both directions.

## Not yet run

- The full query set in `trigger-eval.json` (20 prompts, fresh session each)
  — owner-gated on eval spend (TODO T75).

Probes are a snapshot: a later description edit must re-run at least the
three routing prompts above.
