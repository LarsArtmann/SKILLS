# design-to-code — behavioral evals

Evidence that the skill changes agent behavior, not just that it parses.
Iteration 1 ran 2026-11-03. Layout follows the third-party `skill-creator`
schema (evals.json / eval_metadata.json / grading.json / benchmark.json),
adapted to Crush: each arm is a fresh `crush run` session instead of a
Claude-Code subagent (Crush's subagent tool cannot write files).

## Results (iteration-1)

| Eval                         | With-skill | Baseline | Discriminating?                                                                      |
| ---------------------------- | ---------- | -------- | ------------------------------------------------------------------------------------ |
| theme-token-encoding         | 4/4        | 4/4      | no — model priors already produce correct v4 `@theme`                                |
| v3-to-v4-migration           | 5/5        | 4/5      | **yes** — baseline kept runtime class concatenation (safelisted around, trap intact) |
| status-badge-dynamic-classes | 4/4        | 4/4      | no — baseline independently knows the scanner gotcha                                 |

Aggregate: with-skill **13/13 (1.00)** vs baseline **12/13 (0.93)**, n=1 per
arm (directional, not significant — iteration-2 should run 3× per arm).

## What the eval actually shows

1. **On greenfield idiom production the baseline is already strong.** Ten of
   thirteen assertions pass in both arms. The skill's value on these tasks is
   not correctness — it is _process_: the with-arm compile-verified its token
   utilities (eval 1), reasoned explicitly from Step 4.3 (eval 3), and
   declined to invent tokens after a Step 1 inspection found no existing
   system (eval 3).
2. **On trap-heavy work the skill changes the outcome.** In the v3→v4
   migration the baseline produced working-today code that still constructs
   class names at runtime (`"bg-" + tone + "-500"`) and papers over it with
   `@source inline(...)` — exactly the silent-failure class the skill exists
   to kill. The with-arm replaced it with complete static class names and
   additionally caught two silent v4 changes _not in the reference_
   (`shadow`→`shadow-sm`, `rounded`→`rounded-sm`, preflight dropping
   `cursor: pointer`) by verifying against live docs — the inspect-first
   posture generalizing past the shipped reference.
3. **The gotchas reference is load-bearing but not sufficient.** The with-arm
   went beyond it productively; the reference should gain the
   shadow/rounded rename + preflight cursor rows it was missing (already
   fixed in `references/tailwind-v4-gotchas.md` — see the 2026-11-03 eval
   addendum rows).

## Harness (reproduction)

Each arm ran in its own directory with a timing.json + transcript.txt:

```bash
# with-skill arm (example, eval 1)
crush run --quiet "First read <skill>/SKILL.md and follow it for this task; \
the task involves Tailwind v4 syntax, so also load the reference file it \
points to. Task: <prompt>. Write all deliverables into <outputs>."
# baseline arm: same prompt, prefixed "Do not consult or load any skills
# for this task; work from your own knowledge only."
```

Fixtures: `fixtures/card-v3.{html,css}` (v3 syntax: `@tailwind` directives,
`!bg-white` prefixes, `bg-[--card-muted]` brackets, runtime concatenation).

## Caveats

- n=1 per arm; single-sample deltas are directional. Run iteration-2 at 3×
  per arm before quoting the +0.067 pass-rate delta anywhere.
- The baseline arm still has the skill ambiently installed (global fan-out);
  the "do not consult skills" instruction is honor-system. Session
  transcripts show no skill loads in baseline arms.
- 7 concurrent sessions tripped a provider rate limit; the natural-trigger
  probe was re-run serially afterwards (result recorded in
  `iteration-1/trigger-probe.md`).
- `tokens` not captured (crush run does not report them).
