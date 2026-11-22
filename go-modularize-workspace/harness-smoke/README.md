# run-eval.sh harness smoke (2026-11-22)

End-to-end validation of the T127 extension: paired arms
(`--skill-dir architecture-visualization --old-skill HEAD`), per-arm fresh
fixture workdirs, git-archived old arm, meta.json provenance (arm, skill_ref,
pair_id, prompt hash), and `--grade` template seeding. Prompt was a trivial
"Reply with exactly: SMOKE-OK" (harness test, not a doctrine eval). Both arms
answered SMOKE-OK; artifacts under `2026-11-22T19-21-51Z/{new,old}/`.
