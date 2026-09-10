# Status Report — docs-health Annotation Scripts Buildflow-Lint Fix

**Date:** 2026-09-10 02:45 (Thursday)
**Scope:** fix the 4 ruff findings that failed buildflow's `ruff-check-fix`
repair run in `docs-health/assets/` (EXE001 ×2, DTZ011 ×2), verify
end-to-end, and record the buildflow-over-this-repo knowledge.

**TL;DR:** buildflow's repair run failed because both annotation scripts
carried shebangs without the exec bit (EXE001) and used naive
`date.today()` for the `p`-kind pass-date default (DTZ011). Fixed with
`chmod +x` and `datetime.now(tz=UTC).date()`; verified by the step itself
(0 findings, exit 0), the script's self-test, dry-run/live fixtures, and a
full `buildflow format` (18 success / 0 failed). Knowledge encoded as
AGENTS §5.11 + CHANGELOG entry. Residuals (shellcheck/markdownlint
advisories, three buildflow environment warnings) are pre-existing,
green-exit noise — documented, not actioned.

---

## What failed (user-pasted buildflow output)

```
ruff-check-fix
  tool ruff failed during execution: exit status 1 (37 fixed)
  EXE001 Shebang is present but file is not executable
    --> docs-health/assets/annotate-prose.py:1:1
    --> docs-health/assets/annotate-rows.py:1:1
  DTZ011 `datetime.date.today()` used
    --> docs-health/assets/annotate-prose.py:34:69
    --> docs-health/assets/annotate-rows.py:49:69
  Found 4 errors.
```

## Root cause

1. **EXE001** — `annotate-prose.py` / `annotate-rows.py` were committed as
   mode 644 while starting with `#!/usr/bin/env python3`. Repo convention
   is 755 for every shebang script (verified: `git ls-files -s` shows all
   12 other `*.sh`/`*.py`-with-shebang files at 100755; only these two were
   100644). `annotate-rows_test.py` has no shebang and was correctly 644.
2. **DTZ011** — `marker_for("p", "-")` defaulted to `date.today().isoformat()`
   (timezone-naive). ruff bans `datetime.date.today()`.

## Fix (commit `5f67dfc`, captured by the auto-commit daemon)

- `chmod +x` on both scripts (git: `100644 => 100755`).
- Both files: `from datetime import date` → `from datetime import UTC, datetime`;
  `date.today().isoformat()` → `datetime.now(tz=UTC).date().isoformat()`.
  Chose the `UTC` alias (not `timezone.utc`) so ruff's UP017 can't fire on
  it either. Minimal diff — no restructuring of the long f-string line
  (E501 does not fire in this setup; the original line was already 97 chars).

## Verification (each step executed, not assumed)

| Check | Result |
| --- | --- |
| `python3 -m py_compile` both files | OK |
| `annotate-rows_test.py` self-test (docstring's importlib one-liner) | "all passed" (incl. `p default` case) |
| Direct shebang execution (exec bit effective) | usage printed |
| Dry-run fixture, rows `1:p:-` | `done (docs-health pass 2026-09-10)` — UTC date rendered |
| Live write, rows `2:p:2026-08-01` | annotated, "(shape verified)" — read-back guard intact |
| Dry-run fixture, prose `1:p:-` | `1. ~~alpha~~ done (docs-health pass 2026-09-10)` |
| `buildflow -s ruff-check-fix --format finding` | exit 0, `"findings": []`, `ruff> All checks passed!` |
| Full `buildflow format` | `FORMAT_EXIT=0`, `18 success, 0 failed, 0 skipped (+25 via config)` |
| Repo-wide exec-bit audit (`git ls-files -s` on all `*.py`/`*.sh`) | no further 644-with-shebang files |
| `scripts/check-skills.sh` | exit 0, 27/27 skills pass, 140 files link-clean |
| `git status` / `git worktree list` | clean / master only (buildflow fsprobe temp file self-cleaned) |

## Knowledge encoded

- **AGENTS §5.11 "buildflow Runs Over This Repo (external tool)"** — ruff
  linting of Python assets with nix fallback; EXE001/DTZ011 conventions
  (755 + tz-aware); the ruff `--fix` "green tail can still fail" trap;
  full-pipeline runs may skip ruff via language detection ("project: go")
  so the reliable check is `buildflow -s ruff-check-fix --format finding`;
  markdownlint/shellcheck exit ✔ despite advisory output; the
  `annotate-rows_test.py` self-test invocation.
- **CHANGELOG** — `### Fixed (2026-09-10 — docs-health annotation scripts
  buildflow-lint clean)` under `[Unreleased]`.

## Residuals (observed, pre-existing, NOT actioned this session)

1. **buildflow preflight warnings (user's global tool env, not repo):**
   `GOEXPERIMENT=jsonv2` redundant in a `.buildflow.yml` that is NOT in
   this repo; binary built at `a3168a2` vs HEAD (rebuild is a system
   action on Lars' tool, not done unasked); `go-licenses` not in PATH
   (devShell tool).
2. **shellcheck advisories, steps still ✔:** SC2319 ×6 in
   `jj-fork-pr-workflow/scripts/validate-workflow.sh` (`$?` after a
   condition), SC2089/SC2090 in `naming-review/scripts/naming-smells.sh`
   (quoted-variable-as-opts). Real (if latent) bugs in validation scripts
   — candidate for a future session.
3. **markdownlint noise:** hundreds of MD013/MD010/MD031 advisories across
   `website-launch/` and others; step exits ✔ as configured. Stylistic
   sweep, out of scope.
4. **ruff language-detection quirk:** in the full pipeline ruff was
   skipped ("language mismatch: project: go") though the repo is Python +
   markdown. Did not debug buildflow's detector (external tool, binary
   older than HEAD — see residual 1). Single-step invocation is the
   reliable ruff verification.

## Session-start checklist (executed, not recalled)

feedback/new empty · newest status report (round-3 self-review) TL;DR read
· TODO_LIST read (T30/T33/T34/T35 — none touched by this task) ·
check-skills.sh exit 0 · AGENTS §8/§9 followed. This task adds no TODO
items (it is closed) and touches no skill descriptions or inter-skill
graph edges.
