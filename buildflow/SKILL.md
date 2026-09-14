---
name: buildflow
description: Use when working in any LarsArtmann project covered by BuildFlow — before manually running golangci-lint, any formatter (gofmt, oxfmt, dprint, prettier, ruff), go mod tidy, nix build/nix fmt, dependency updates, or writing lint/format scripts and CI jobs. Also triggers on "buildflow", `.buildflow.yml` config questions, pre-commit hook problems, vendorHash / nix hash-mismatch errors, failed buildflow steps, remaining-findings exit codes, or any task that would duplicate one of BuildFlow's orchestrated steps (Go, Rust, Nix, JS/TS, Python). Covers what BuildFlow takes over from covered projects, the run/fix/verify loop, build modes, and failure triage. Not for developing BuildFlow itself.
metadata:
  tags: buildflow, linting, formatting, ci, automation, quality
---

# BuildFlow — Usage & Responsibility Delegation

BuildFlow is a DAG-based build-automation CLI that owns quality automation across the LarsArtmann project fleet. In any covered project it auto-detects languages and tools, runs only what applies, and auto-fixes what it can — every fix verified by re-running detection (detect → repair → verify), so a "fixed!" claim is always measured, never self-reported.

This skill is for **using** BuildFlow in covered projects. For **developing** BuildFlow itself, the BuildFlow repo's own `AGENTS.md` is authoritative; this skill deliberately does not duplicate it.

A project is "covered" when it has a `.buildflow.yml` (even a minimal one) and/or a BuildFlow-generated pre-commit hook. Dozens of `~/projects/*` repos qualify.

## The core rule: delegate, don't duplicate

Before manually running a quality tool in a covered project, check whether BuildFlow already owns that responsibility (table below). Hand-rolling a wrapper script, justfile target, Makefile target, or CI job for something BuildFlow orchestrates creates a split brain: two configs, two orders of execution, two sources of truth for "is this repo clean". The project's flake may own builds for distribution, but quality enforcement (lint, format, test, repair) belongs to BuildFlow.

**Default answer:** run `buildflow`, not the underlying tool.

## What BuildFlow takes over from covered projects

| Responsibility                                                                 | Don't do this by hand                                                                 | Run instead                                              |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Formatting (oxfmt, prettier, dprint, ruff/black/isort, templ-fmt, nix-fmt, shfmt) | Formatter wrapper scripts, `nix fmt` for quality runs, per-repo format CI jobs        | `buildflow format` (all formatting + fix + modernize)    |
| Linter configuration (`.golangci.yml`, `.oxlintrc.json`, clippy lints)         | Curating linter lists from scratch each repo                                          | `buildflow -s golangci-lint-auto-configure --fix`        |
| Linting itself (golangci-lint, shellcheck, hadolint, markdownlint, oxlint, …)   | `golangci-lint run --fix` directly (bypasses verify; exit 1 on unfixable is normal)   | `buildflow -s golangci-lint` / plain `buildflow`          |
| go.mod/go.work hygiene (tidy, sync, normalize, replace directives, require floors) | Manual `go mod tidy`, hand-normalizing pseudo-versions, hunting obsolete replaces | `buildflow -s gomod-check --fix`, `go-mod-normalize`      |
| Nix hash repair (vendorHash FOD mismatches)                                     | Pasting `got: sha256-…` hashes by hand                                                | `buildflow -s nix-hash-fix --fix`                         |
| Nix builds & checks in the pipeline (nix-build, deadnix, statix, flake check)   | Running each nix lint separately for quality verdicts                                 | `buildflow` (nix tools trigger on `flake.nix`)            |
| Dependency updates (Go, Rust, npm/pnpm)                                         | Per-ecosystem update commands                                                          | `buildflow update`                                        |
| Dependabot config (`.github/dependabot.yml` sync with real modules)            | Hand-editing dependabot entries when modules are added/removed                        | `buildflow -s dependabot-auto-configure --fix`            |
| Code generation (templ, sqlc, govalid, tailwind, go generate)                   | Remembering which generators exist and in what order                                  | `buildflow` (they trigger on their config files)          |
| Modernization (`go fix`, go-auto-upgrade, pyupgrade)                            | One-off migration scripts                                                             | `buildflow --fix`                                         |
| Security scans (pip-audit, pnpm-audit, cargo-audit, vulnix)                     | Ad-hoc audit commands with inconsistent flags                                         | `buildflow` (gitleaks/codespell are on-demand: `-s <t>`)  |
| Tests (test-race, test-coverage, pytest, jest, vitest) per build mode           | Hand-picking when tests run                                                           | `buildflow --build-mode full`                             |
| Pre-commit quality gate                                                        | Hand-written hook scripts                                                             | `buildflow precommit install`                             |
| Environment diagnosis (19 doctor checks: env, workspace, vendor, disk, network) | Debugging tool availability yourself                                                  | `buildflow doctor`                                        |
| Timing/regression analytics                                                    | Guessing why the build got slower                                                     | `buildflow timings --regressions`, `buildflow history`    |

The full per-ecosystem step catalog and the "what the project still owns" split live in [./references/responsibilities.md](./references/responsibilities.md) — read it when deciding whether a new task belongs in the project or in BuildFlow.

## The standard loop

Imperative workflow for any quality task in a covered project:

1. **See what applies** — `buildflow --dry-run --verbose`. Filtered tools are listed with reasons ("missing prerequisites", "no matching files", "deferred to repo toolchain"). Don't assume a tool ran.
2. **Diagnose the environment when anything feels off** — `buildflow doctor`. It surfaces GOEXPERIMENT, dead cache mounts, stale vendor, disk space, git identity, and **binary freshness** (see triage below).
3. **Run** — `buildflow` (full mode) or pick a mode (table below).
4. **Fix** — `buildflow --fix`. Repairs run as detect → repair → verify; the summary honestly reports what was fixed vs. what remains.
5. **Drill into one tool** — `buildflow -s <tool>` (does NOT accumulate across multiple `-s` flags — last one wins). Use `--format finding` for the full findings list, `-v` for step logs. Module fan-out tools accept a qualifier: `-s "golangci-lint [tools]"` or `golangci-lint@tools`.
6. **Recover** — `buildflow --failed-only` reruns exactly the steps that failed last run; `--resume` skips previously succeeded steps.

### Build modes

| Mode         | Duration   | Use for                          | test-race / coverage |
| ------------ | ---------- | -------------------------------- | -------------------- |
| `full`       | ~5-10 min  | CI, releases, nightly            | run / run            |
| `fast`       | ~5-30 sec  | Quick local iteration            | skip                 |
| `pre-commit` | ~5-10 sec  | Git hook (nix builds blocklisted) | skip                |
| `dev`        | ~5-30 sec  | Local development                | run / run            |
| `lightning`  | ~1-2 sec   | Active coding, essentials only   | skip                 |

`dev` is a build MODE, not a command: `buildflow --build-mode dev`.

## Exit codes and the findings gate

A green run can still exit non-zero: by default BuildFlow **fails when findings at `error` severity or above remain** after repairs, even if every step succeeded. This is intentional — it is the project's quality gate.

- Findings a verify step confirms repaired don't count; unfixable and detect-only findings do.
- `--strict` promotes the threshold to `warning`; `--fail-on none` opts out; `--fail-on info` is maximally strict.
- When the gate trips, the message names each tool with its remaining count. Follow up with `buildflow -s <tool> --format finding`.
- **gitleaks and codespell are on-demand only** — they never run in pipeline modes; invoke explicitly (`buildflow -s gitleaks`) when you want them.

## What the project still owns

- **`.buildflow.yml`** — minimal, non-default information only (skips with rationale, `env:` like `GOEXPERIMENT`, non-default limits). Unknown keys now warn at every load; the canonical key list is in [./references/commands.md](./references/commands.md). Don't restate defaults.
- **Curated exceptions** — a project's own linter suppressions and `skip_steps` decisions are policy. When auto-configure rewrites `.golangci.yml`, review the diff before accepting it; some projects deliberately curate their linter set.
- **Known-tool-bug documentation** — projects record BuildFlow false positives in their own AGENTS.md (e.g. gomod-check mixed-requires false positive, nix-checker flake-input oscillation). **Check the project's AGENTS.md before "fixing" what a tool reports** — it may be a documented, deliberate non-fix.
- **Build/ship specifics** — flake outputs for distribution, release tagging, deployment. BuildFlow verifies builds; it doesn't own releasing.

## Failure triage (short form)

| Symptom                                                        | First move                                                                                      |
| -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Step failed in summary                                         | Re-run `buildflow -s <tool> -v`; summary prints the exact re-run command per failure             |
| Finding looks wrong                                            | Check project AGENTS.md for a known-tool-bug entry; then suspect a stale binary (`buildflow doctor`) |
| `nix build` hash mismatch (`got: sha256-…`)                    | `buildflow -s nix-hash-fix --fix` — never paste hashes by hand                                   |
| Tool behaves like an old version                               | `buildflow doctor` (binary-freshness check); update with `buildflow upgrade`                     |
| Finding replays after its cause was deleted                    | Result cache keys cover matched files only; bypass with `BUILDFLOW_NO_RESULT_CACHE=1` (details in references) |
| Commit blocked by pre-commit hook                              | It ran `buildflow --build-mode pre-commit --staged-only` and re-staged formatted files; fix the findings, re-stage |

Deep triage (stale-binary update paths, result-cache purge, pre-commit edge cases, daemon interactions) is in [./references/failure-triage.md](./references/failure-triage.md) — read it before improvising a workaround.

## Anti-patterns

- **Don't run `golangci-lint --fix` directly** to clean a repo: it exits 1 for "issues remain that I cannot fix" (normal, not a crash) and it bypasses BuildFlow's verify step and module fan-out cache isolation. Use `buildflow --fix`.
- **Don't hand-fix vendorHash** — that is nix-hash-fix's entire job; manual pasting drifts from the lock state the doctor cross-checks.
- **Don't write lint/format/CI scripts that duplicate steps** BuildFlow already orchestrates — extend coverage instead (see below).
- **Don't bulk-edit generated/managed configs** (`.golangci.yml`, `.oxlintrc.json`, `dprint.json`, clippy lints) without reviewing what auto-configure would produce — and never fight it by re-adding blocks it deliberately removed without checking `git log -S` first.
- **Don't trust a green step that scanned zero files** — check the summary's file counts and the "not applicable" section; a tool with no matching inputs is a no-op, not a pass over your code.
- **Don't assume the auto-commit daemon** (pma) committed your work — it has a known blind spot; verify with `git status` and commit critical artifacts yourself.

## Extending coverage

If a needed check doesn't exist as a step, that is a **BuildFlow development task** (new provider in the BuildFlow repo), not a per-project script. Ask: "should every fleet repo get this?" If yes, it belongs upstream in BuildFlow — possibly via a toolsdk self-registering provider in the relevant sibling repo. Only genuinely project-specific checks belong in the project's own tooling.

## Related skills

- **code-quality-scan** — for repos NOT covered by BuildFlow, or one-off deep quality scans with ad-hoc tool invocations. In covered projects, plain `buildflow` is the canonical quality gate; use code-quality-scan only when you need its HTML issue dashboard over and above BuildFlow's findings.
- **linter-building** — when the extension above means authoring a new linter/analyzer rather than wiring an existing tool.

## Decision checklist

Before writing any quality automation in a covered project, run through this:

1. Does `buildflow list providers` already list a tool for this? → use it.
2. Is the finding/repair wrong? → check project AGENTS.md, then `buildflow doctor`.
3. Is it fleet-wide value? → extend BuildFlow, not this repo.
4. Is it genuinely project-specific? → only then write project-local tooling, and document why in the project's AGENTS.md.
