# Trigger-eval battery — 2026-11-23 (T139)

The full 20-query `trigger-eval.json` battery, one fresh `crush run` session
per query (real sessions; the installed skill list is visible, mirroring the
2026-11-17 probe method). Prompt: name the ONE skill you would load, or NONE.
10 positive + 10 negative arms, run in two parallel batches of 10.

## Results: 20/20 correct

| # | expect | routed to | verdict |
| - | ------ | --------- | ------- |
| 1 | trigger | architecture-deepening | ✅ |
| 2 | trigger | architecture-deepening | ✅ |
| 3 | trigger | architecture-deepening | ✅ |
| 4 | trigger | architecture-deepening | ✅ |
| 5 | trigger | architecture-deepening | ✅ |
| 6 | trigger | architecture-deepening | ✅ |
| 7 | trigger | architecture-deepening | ✅ |
| 8 | trigger | architecture-deepening | ✅ |
| 9 | trigger | architecture-deepening | ✅ |
| 10 | trigger | architecture-deepening | ✅ |
| 11 | other | architecture-review | ✅ |
| 12 | other | architecture-visualization | ✅ |
| 13 | other | full-code-review | ✅ |
| 14 | other | data-model-review | ✅ |
| 15 | other | pareto-planning | ✅ |
| 16 | other | naming-review | ✅ |
| 17 | none | NONE | ✅ |
| 18 | other | stack-selection | ✅ |
| 19 | none | NONE | ✅ |
| 20 | other | status-report | ✅ |

All 10 negative arms routed to their legitimate owners (or NONE), none
absorbed by architecture-deepening; all 10 positive arms hit it. The
companion-skills disambiguation in the fork's description holds under the
full battery, not just the 3-prompt probe.

Runs: `/tmp/t139-runs/` (q01–q20 prompt+output files; scratch, cleaned after
report persistence). Battery method note: parallel batches of 10 `crush run`
processes; no session shared state.

Per the probe snapshot rule: a later description edit to any of
architecture-deepening / architecture-review / architecture-visualization /
full-code-review re-runs at minimum the negative arms 11–13.
