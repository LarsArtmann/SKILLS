# eval-1 re-run (2026-09-08) — asymmetry fixed

The original eval-1 run gave the new-skill configuration a REAL repo
(go-filewatcher) while the old-skill side ran in a different mode; TODO_LIST
T24 asked for a re-run on a fully fictional repo so the configurations are
comparable.

This rerun runs BOTH configurations in fresh `crush run` sessions against the
same fictional repo (`go-pixelwand`, builds clean, deliberately flawed: no
LICENSE, no CI, stub `Render`). Both sessions produced a launch plan; graded
against the same 7 assertions as the original.

**Result: old 4/7, new 7/7 — same outcome as 2026-08-21; scores were
unaffected by the asymmetry (as the TODO predicted).** The original
`eval-1/` artifacts are kept untouched (point-in-time).

**Mechanical cross-check (2026-09-09):** `mechanical-grade.sh <output.md>`
re-grades the regex-checkable assertions with no LLM in the loop; results in
`mechanical-grading.txt` agree EXACTLY with the LLM verdicts above (old 4/7,
new 7/7). Use it as the objective floor for future re-runs; fuzzy narrative
judgments stay with the judge.
