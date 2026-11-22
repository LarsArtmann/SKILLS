# R16 eval run — how to execute these prompts (skill-creator protocol)

The prompts in `evals.json` follow the `skill-creator` skill's benchmarking
protocol. Read that skill before running. The essentials, so the loop cannot
skip them:

- **Workspace:** `go-modularize-workspace/` as a SIBLING of this skill
  directory (i.e. `/home/lars/projects/SKILLS/go-modularize-workspace/`),
  organized as `iteration-<N>/eval-<descriptive-name>/{with_skill,old_skill}/outputs/`.
- **Baseline = the OLD skill, not no-skill** (this is an improvement-eval):
  before any run, snapshot the current skill
  (`cp -r go-modularize go-modularize-workspace/skill-snapshot/`) and point
  baseline subagents at the snapshot.
- **Spawn with-skill AND baseline runs in the same turn** — never
  sequentially.
- **Assertions live in `evals.json` and ONLY there** (added 2026-11-22,
  T131): each eval carries one expected-behavior field — `assertions`
  (machine-checkable, the graded form) or `expected_output` (prose, not yet
  converted). Draft them during the runs if you must, but they land in
  `evals.json`. The `eval_metadata.json` files inside
  `go-modularize-workspace/` are FROZEN run provenance — they record what
  was asserted at that run's grading time and are never updated; when they
  and `evals.json` disagree, `evals.json` is canonical going forward and the
  workspace file is the historical record. Grade with a fresh grader session
  per the doctrine-eval protocol
  ([`../../../docs/doctrine-eval-protocol.md`](../../../docs/doctrine-eval-protocol.md));
  `scripts/run-eval.sh --grade` seeds the grading file.

Owner gate: runs happen only after the R15/R16 push answers (R-plan §11).

**2026-11-15 exception:** iteration-1 (evals 4–5, the gate-2 two-currency
flip test) ran under the owner's direct commission ("last change to
perfect the skill", executing f1 of the 13-22 self-review). The R16 full
battery remains owner-gated.
