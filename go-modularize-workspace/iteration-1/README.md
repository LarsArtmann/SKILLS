# iteration-1 — 2026-11-15 — gate-2 two-currency doctrine flip test

First behavioral probe run for go-modularize (the go-release eval pattern,
applied to a doctrine change). Commissioned by the owner's "last change to
perfect the skill" instruction executing f1 from
`docs/status/2026-11-15_13-22_go-modularize-gate2-fix-self-review.md`.
(The R16 full battery per `go-modularize/evals/README.md` remains
owner-gated — T125.)

## Configurations

| Config    | Skill version                                                          | Source                                      |
| --------- | ---------------------------------------------------------------------- | ------------------------------------------- |
| old_skill | Pre-fix pipe-only gate 2 (rebalance of 2026-10-29/30)                  | git `e1d8a05` via `git archive` → /tmp      |
| with_skill| Two-currency gate 2 + same-day hardening (lapse rule, anti-gaming)     | repo HEAD after `08a64ae`                   |

Probes: fresh subagent sessions, spawned the same turn, skill path pointed
explicitly (doctrine eval, not a trigger test), no access to this repo's
status reports (no anchoring).

## Results

| Eval                        | Config    | Score | Verdict                                                                    |
| --------------------------- | --------- | ----- | -------------------------------------------------------------------------- |
| 4 policy-payoff-carve       | old_skill | 2/4   | Dissolves the seam; rules the committed policy inadmissible ("no LOC ceiling can override a failed gate") |
| 4 policy-payoff-carve       | with_skill| 4/4   | Extracts via policy currency: named artifact + measured advance; flags prior review via dissolve symmetry |
| 5 same-session-policy       | with_skill| 4/4   | Rejects same-session policy as self-ratifying; owner ratify-or-retire question; keep as package |

The flip the repair was built for is demonstrated and measured: the old
doctrine fails exactly the two assertions the two-currency repair targets;
the fixed doctrine passes all four, and the anti-gaming clause holds in the
negative direction (the skill did not become an extraction license).

## Notes

- No eval-viewer run: headless session, two evals, human review happens via
  this file and the status report. `generate_review.py --static` can render
  these artifacts later if wanted (T74-style).
- Old-skill snapshot deliberately NOT committed (reproducible from `e1d8a05`;
  a nested SKILL.md copy would pollute check-skills scope).
