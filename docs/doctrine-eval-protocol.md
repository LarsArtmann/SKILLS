# Doctrine-Eval Protocol — the bar for shipping a gate or doctrine change

> **Scope:** any change to a skill's decision gates, doctrine, or other
> high-leverage instructions — the text that flips verdicts in future
> sessions. Pure prose polish, reference additions, and typo fixes are out
> of scope. **This doc is the bar; `scripts/run-eval.sh` is the mechanics.**
>
> Origin: 2026-11-15 go-modularize gate-2 two-currency repair (single-probe
> flip demo, 2/4 → 4/4) and its self-review (T128), which found the
> single-probe bar too weak to claim doctrine quality. The 2026-11-15 eval
> remains valid evidence; this protocol is what FUTURE doctrine ships must
> exceed it with.

## Why a protocol (the failure modes it exists to prevent)

1. **Single-probe luck.** One fresh-session probe can flip 2/4 → 4/4 by
   chance phrasing. Variance across runs is unmeasured until you run ≥3.
   skill-creator's own benchmarking treats one run as an anecdote.
2. **Author-grader bias.** The session that wrote the doctrine also wrote
   the assertions and grades its own output — it knows what "passing" looks
   like and unconsciously forgives. The grader must be a different context
   that sees only assertions + outputs (the skill-creator grader-agent
   pattern: `~/.agents/skills/skill-creator/agents/grader.md`).
3. **One-model blind spots.** A doctrine that reads as intended to the
   model that wrote it may read differently to a second model. The
   cross-model arm catches doctrine that only one model applies.
4. **Assertion drift.** Assertions living in two places (catalog vs run
   metadata) rot apart. Single home: the eval catalog (for go-modularize:
   `go-modularize/evals/evals.json`, `assertions` array). Run-workspace
   `eval_metadata.json` files are frozen provenance, never updated.

## The bar (all four required before the change is called shipped)

| # | Requirement | Why |
| - | ----------- | ---- |
| 1 | **≥3 runs per arm** (new skill, old skill) with the same prompt and fixture | measures variance; a flip that appears in 2 of 3 runs is signal, 1 of 3 is noise |
| 2 | **Old arm from git** — the archived pre-change skill (`run-eval.sh --old-skill <ref>`), never a hand-copied approximation | the baseline is exactly what users ran yesterday; approximations drift |
| 3 | **One cross-model arm** — at least one new-skill run on a different model than the authoring session (`--model <id>`) | catches single-model readable doctrine |
| 4 | **Independent grader** — a fresh session that receives assertions + `output.md` only, never the doctrine diff, the session's rationale, or the expected verdict | removes author-grader bias |

Plus the standing rule from the 2026-11-15 eval: **cover both directions.**
A gate relaxation needs a probe that shows it does NOT become a license
(e.g. eval-5: the policy-payoff currency must not self-ratify), and a gate
tightening needs a probe that it still admits the cases it should.

## Procedure

```bash
# 1. Materialize the eval dir from the catalog (single home of prompts +
#    assertions; adapt path + id):
jq -r '.evals[] | select(.id == 4) | .prompt' go-modularize/evals/evals.json \
  > go-modularize-workspace/iteration-2/eval-4/prompt.txt
jq '.evals[] | select(.id == 4) | .assertions' go-modularize/evals/evals.json \
  > go-modularize-workspace/iteration-2/eval-4/assertions.json

# 2. Run a paired arm (repeat ≥3× — one invocation per run; each invocation
#    runs both arms back-to-back, which is the same-turn pairing rule):
scripts/run-eval.sh <eval-dir> --skill-dir <skill-dir> \
  --old-skill <pre-change-ref> --grade

# 3. Cross-model arm (one of the ≥3 new-skill runs):
scripts/run-eval.sh <eval-dir> --skill-dir <skill-dir> --model <other-model> --grade

# 4. Grade INDEPENDENTLY (per-run): spawn a fresh grader session with the
#    grader-agent role — inputs: assertions (from the catalog) + the arm's
#    output.md; it fills grading.template.json → grading.json with evidence
#    quotes per assertion, flags weak assertions, and does not know which
#    arm is which (arm names in grading: arm-a / arm-b).
```

## Grading rules (from the skill-creator grader pattern, binding here)

- PASS requires **quoted evidence from the output**, not a vibe. The burden
  of proof is on the expectation; uncertain → FAIL.
- Superficial compliance (right filename, wrong content) is a FAIL.
- The grader **critiques the assertions**: an assertion any output passes
  trivially, or an uncovered important outcome, goes back to the catalog —
  this is the only path by which assertions change after runs.
- Score = passed/total per arm per run, reported WITH variance (e.g.
  "new: 4/4, 4/4, 3/4; old: 2/4, 2/4, 2/4; cross-model: 4/4").

## Ship decision

Ship only if: every new-skill run ≥ old-skill run on the same prompt AND
the cross-model arm passes AND no negative-direction probe (anti-license
eval) regresses. A single mixed result is not a ship; it is a finding.

## Persisted evidence (an eval is not done until it is on disk)

Every run lands in `<eval-dir>/runs/<ts>/…` with `meta.json` provenance
(model, git ref, prompt hash). Iteration summaries + grading verdicts live
in the skill's workspace (`<skill>-workspace/iteration-<N>/`), committed
like the 2026-11-15 iteration-1. Workspace `eval_metadata.json` files are
frozen run provenance; the catalog is the living single home.
