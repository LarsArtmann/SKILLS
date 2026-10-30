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
- **Assertions are drafted DURING the runs**, then added to
  `eval_metadata.json` per eval; grade with `eval-viewer/generate_review.py`
  (see skill-creator SKILL.md "Running and evaluating test cases").

Owner gate: runs happen only after the R15/R16 push answers (R-plan §11).
