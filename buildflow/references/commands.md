# BuildFlow Command Reference

Command surface verified against `buildflow --help` (2026-09-14). When this file drifts from the binary, trust the binary — regenerate from `buildflow --help`.

## Subcommands

| Command                    | What it does                                                                         |
| -------------------------- | ------------------------------------------------------------------------------------ |
| `buildflow`                | Run the pipeline (default; `--build-mode` selects profile)                           |
| `buildflow doctor`         | Diagnose environment and suggest fixes (19 checks: env, workspace, vendor, system…)  |
| `buildflow format`         | Run all formatting, fix, and modernization steps                                     |
| `buildflow update`         | Update all project dependencies across ecosystems (Go, Rust, npm/pnpm)               |
| `buildflow diff`           | Show only findings introduced by changes vs a base branch                            |
| `buildflow list steps`     | Every available step (live count — never trust hardcoded numbers)                    |
| `buildflow list tools`     | External tool dependencies + install status (`--available` / `--missing` / `--json`) |
| `buildflow list providers` | Pipeline providers with project match status (`--matched` / `--missing` / `--json`)  |
| `buildflow explain <x>`    | A build step, a past run ID, or the full DAG (`--registration` for per-tool wiring)  |
| `buildflow timings`        | Step timing history, regressions, flaky steps (`--regressions`, `--top`, `--info`)   |
| `buildflow history`        | Build-level health trends (pass rate, top failing steps, sparklines)                 |
| `buildflow fleet`          | Failure hotspots across ALL repositories (fleet-wide)                                |
| `buildflow digest`         | Cross-repo markdown digest report                                                    |
| `buildflow trace`          | List/open flight-recorder trace snapshots (`go tool trace`)                          |
| `buildflow watch`          | Watch for file changes, re-run matching steps                                        |
| `buildflow config`         | `init` / `view` / `validate` project configuration                                   |
| `buildflow setup`          | Interactive setup wizard                                                             |
| `buildflow precommit`      | Install/manage the git pre-commit hook                                               |
| `buildflow verify-config`  | Validate config, provider registration, trigger matching — without running           |
| `buildflow language`       | Detect/list project languages                                                        |
| `buildflow docs --check`   | Verify documentation consistency against the live registry                           |
| `buildflow upgrade`        | Check for and install the latest BuildFlow release                                   |
| `buildflow telemetry`      | Manage/check telemetry configuration                                                 |
| `buildflow version`        | Version and runtime info                                                             |

## Key flags

| Flag                       | Meaning                                                                                                                                |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `--build-mode`             | `full` (default) / `fast` / `pre-commit` / `dev` / `lightning`; `ci` is a deprecated alias for `full`                                  |
| `--fix`                    | Enable auto-fix (detect → repair → verify topology)                                                                                    |
| `-s, --step <name>`        | Run ONE step; does NOT accumulate (last `-s` wins). Module qualifier: `"tool [module]"` or `tool@module`                               |
| `-d, --dry-run`            | Preview what would execute (includes `skip_steps`)                                                                                     |
| `-v, --verbose`            | Debug-level logging (NOT "show findings" — use `--format finding` for that)                                                            |
| `--staged-only`            | Only process git-staged files (what the pre-commit hook uses)                                                                          |
| `--failed-only`            | Rerun ONLY the steps that failed in the last recorded run                                                                              |
| `--resume`                 | Skip steps that succeeded in the previous run                                                                                          |
| `--format`                 | `console` / `json` / `silent` / `sarif` / `finding` / `html` / `ci`                                                                    |
| `--fail-on`                | Remaining-finding severity gate: `info`/`warning`/`error`/`critical`/`none`. Empty = error (default)                                   |
| `--strict`                 | Shorthand for `--fail-on=warning`                                                                                                      |
| `--fail-on-findings`       | Exit non-zero when findings remain after auto-fix (CI catch-all)                                                                       |
| `--lint-priority`          | golangci-lint-auto-configure depth: `critical`/`high`/`medium`/`optional` (higher = fewer linters)                                     |
| `--step-timeout`           | Per-tool timeout override, repeatable: `golangci-lint=5m`                                                                              |
| `--budget` / `--max-time`  | Soft warn / hard terminate limits (e.g. `30s`, `2m`)                                                                                   |
| `--max-concurrency`        | Parallel steps (0 = CPU count; default caps at min(NumCPU, 4))                                                                         |
| `--exclude`                | Exclude patterns (repeatable)                                                                                                          |
| `--semantic`               | Semantic mode for art-dupl (renamed-variable clones)                                                                                   |
| `--result-cache`           | Content-addressed detector cache, default on (`--no-result-cache-for <tool>` per tool; env `BUILDFLOW_NO_RESULT_CACHE=1` disables all) |
| `--live-dashboard`         | SSE HTTP dashboard during execution (`--live-dashboard-addr`, `--live-dashboard-open`)                                                 |
| `--flight-recorder`        | Go execution trace snapshot on step failure (`.buildflow-traces/`, `buildflow trace`)                                                  |
| `--progress`               | `auto` / `plain` / `scroll` / `inline` / `tui` (scroll for SSH/CI)                                                                     |
| `--no-tui`                 | Full-screen TUI off, scroll mode on                                                                                                    |
| `--circuit-breaker-action` | `warn` (default) or `skip` for chronically failing steps                                                                               |
| `--profile`                | Performance profile: `lightning`/`balanced`/`thorough`/`ci`/`full`                                                                     |

All flags also work as `BUILDFLOW_*` environment variables (`BUILDFLOW_BUILD_MODE`, `BUILDFLOW_VERBOSE`, …).

## `.buildflow.yml` canonical keys

Unknown top-level keys are silently ignored — but since the unknown-key warning shipped, every load prints a Warn listing them. Write ONLY non-default values; pure default-restatement files were deleted fleet-wide on principle.

`auto_fix`, `build_mode`, `color`, `default_step_timeout`, `dep_update_mode`, `disable`, `dry_run`, `dupl_threshold`, `exclude`, `env`, `fail_on`, `go_mod_ignore_dirs`, `language`, `log_level`, `max_concurrency`, `max_file_size`, `output_mode`, `retry_budget`, `retry_modifier`, `skip_steps`, `strict`, `todo_min_severity`, `tool_paths`, `verbose` (+ deprecated alias `exclude_patterns`).

Notes:

- `disable` is a merged alias for `skip_steps`; both warn if used together.
- `skip_steps` is whole-tool only — qualified entries like `tool:repair` or `tool [module]` never match (they warn now).
- Deprecated tool aliases in `skip_steps` resolve with a warning (e.g. `hierarchical-errors` → `erraudit`).
- `env:` injects environment into all tool subprocesses (the standard way to set `GOEXPERIMENT: jsonv2` per project).

## Output format guidance

- `--format finding` — full findings list (what the summary hints point at). Use for CI annotations and drill-downs.
- `--format json` — machine-readable run summary including `detectFindings` for detect-only tools.
- `--format sarif` — for code-scanning uploads.
- `--no-summary` — suppress the human summary in CI pipelines that parse stdout.
