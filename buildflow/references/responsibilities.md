# BuildFlow Responsibilities — Detailed Mapping

What BuildFlow owns in a covered project, per area, with the delegation rule and the boundary (what stays in the project). Step names come from `buildflow list steps` — the live registry is authoritative.

## Formatting

BuildFlow is the sole quality formatter. File-type ownership is exclusive by design (enforced by regression test): oxfmt owns JS/TS/JSX/TSX/MJS/CJS/JSONC, prettier owns CSS/HTML/Vue/Svelte/Astro, dprint owns JSON/YAML/Markdown/Dockerfile, ruff/black/isort own Python (mutually exclusive via `pyproject.toml`), plus templ-fmt, nix-fmt, shfmt, d2-fmt. Go formatting (goimports/gofumpt/golines) runs inside golangci-lint v2's `formatters:` block.

- **Project owns:** nothing. Not even `dprint.json` — BuildFlow generates a default config (4 plugins, known-good versions) when missing, and defers to repo-owned treefmt when `treefmt.toml` exists.
- **Delegation rule:** if you want something formatted, run `buildflow format` or the specific formatter step. Never install a repo-local formatter pipeline (husky, lint-staged, format CI jobs) — that recreates the multi-config drift BuildFlow eliminated.

## Linting & linter configuration

`golangci-lint` (110-linter config), `shellcheck`, `hadolint`, `markdownlint`, `lychee`, `oxlint`, `buf-lint`, `buf-breaking`, `protolint`, `sqlc-check`, `ruff-check`, `mypy`, `bandit`, `vulture`, `interrogate`, plus in-process SDK checkers (`todo-check`, `nix-checker`, `flake-meta-checker`, `gitignore-check`, `gomod-check`, erraudit, branching-flow, go-structure-linter, go-auto-upgrade).

- **Config generation is a BuildFlow responsibility:** `golangci-lint-auto-configure` writes/optimizes `.golangci.yml`, `oxlint-auto-configure` writes `.oxlintrc.json`, `clippy-auto-configure` writes Cargo lint tables. Detect and repair use the same priority threshold (`--lint-priority`) so they converge instead of looping.
- **Project owns:** deliberate exceptions — a curated linter set, documented suppressions, `skip_steps` with rationale in `.buildflow.yml` + AGENTS.md. Review auto-configure diffs; if it removes a block, check `git log -S` before re-adding (removal may have been deliberate and documented).
- **Delegation rule:** run `buildflow -s golangci-lint` rather than `golangci-lint run`. BuildFlow fans out per Go module with isolated caches (concurrent golangci processes corrupt a shared cache) and treats `--fix` exit 1 (unfixable findings remain) as a normal signal.

## Go module hygiene

`go-mod-tidy`, `go-work-sync`, `go-mod-normalize`, `go-mod-update`, `go-mod-vendor`/`go-work-vendor`, `workspace-build-verify`, `gomod-check` (43 structural checks), `go-mod-ignore-check`.

- **Repairs BuildFlow performs automatically (with build gates + rollback):** obsolete version-pinning replace directives, stale require floors, missing sub-module replace directives, non-canonical internal pseudo-versions, `go` directive patch-pins and toolchain lines, vendoring drift.
- **Project owns:** nothing — this class of go.mod surgery is exactly what the gomod-check repairer is for. Hand-editing these is how multi-module replace crises started historically.
- **Delegation rule:** after changing dependencies, run `buildflow -s gomod-check --fix` (or a plain full run) instead of hand-tidying. For dependency bumps across ecosystems: `buildflow update`.

## Nix

`nix-build`, `nix-hash-fix`, `nix-build-verify`, `nix-flake-check`, `nix-flake-update`, `deadnix`, `statix`, `nix-fmt`, `vulnix`.

- **Self-healing chain:** nix-build failure gates `nix-hash-fix` (repair classes: hash-mismatch, stale-module, vendor-inconsistency, gomod-stale), then `nix-build-verify` confirms. Compile errors are classified and surfaced immediately (no pointless hash retries).
- **Doctor catches drift at commit time:** the `fod-hash-freshness` pre-flight warns when lock files changed after the hash files — the remedy line names `buildflow -s nix-hash-fix --fix`.
- **Project owns:** flake outputs for distribution (packages, devShells, NixOS modules), input pinning decisions, release tagging. BuildFlow verifies builds and repairs hashes; it does not own your flake's shape.
- **Delegation rule:** `got: sha256-…` means run nix-hash-fix, never paste hashes manually. `vulnix` findings are warnings by design (nixpkgs-current CVEs are upstream-pending); waive accepted advisories in `vulnix-whitelist.toml`.

## Dependency & config sync

`dependabot-auto-configure` (keeps `.github/dependabot.yml` in sync with real modules — it never deletes user entries; orphans are info-severity suggestions), `license-sync` (LICENSE/flake/README/go.mod/package.json against `.config/metadata.yaml`), `gitignore-check` (upserts ignore patterns), `pnpm-update`, `cargo-update`, `go-mod-update`, `uv-lock`/`uv-sync`.

- **Project owns:** the source of truth files BuildFlow syncs against (`.config/metadata.yaml`), and orphan-entry decisions dependabot defers to the human.
- **Delegation rule:** when modules are added/removed, let the sync tools regenerate their config files; don't hand-maintain the generated parts.

## Code generation & modernization

`templ-generate`, `sqlc-generate`, `govalid-generate`, `tailwind-build`, `go-generate`, `go-tool-run`, plus modernizers `go-fix`, `go-auto-upgrade`, `pyupgrade`.

- **Delegation rule:** run the step, don't remember the command. Generators trigger on their config files and fan out per module. Some projects deliberately `skip_steps: [go-auto-upgrade]` with rationale (migrator bugs, banned replacement deps) — respect documented skips; don't run the tool standalone to "help".

## Security

`gitleaks` and `codespell` are **on-demand only**: they never run in any pipeline mode; invoke with `buildflow -s gitleaks` / `-s codespell` when wanted. Always-on: `pip-audit`, `pnpm-audit`, `cargo-audit`, `cargo-deny`, `vulnix`.

- **Delegation rule:** an on-demand tool's absence from a run is policy, not a gap. If a project needs it always, that's a BuildFlow policy change, not a project CI job.

## Tests & CI

`test-race`, `test-coverage` (full/dev modes), `pytest-test`, `jest-test`, `vitest-test`, `ginkgo-version-check`.

- **Project owns:** the CI workflow skeleton, coverage thresholds beyond BuildFlow's checks, release jobs.
- **Delegation rule:** don't duplicate the test invocation in CI with different flags/env (race detector env like `CGO_ENABLED=1` is handled inside the steps). Consume BuildFlow's exit code and `--format sarif`/`json` output instead of re-running tools.

## Pre-commit hook

`buildflow precommit install` generates `.git/hooks/pre-commit` running `buildflow --build-mode pre-commit --staged-only` (~5-10s; nix builds deliberately blocklisted — too slow for commit hooks), then re-stages files the formatters touched.

- **Project owns:** nothing; hand-written hooks that re-implement this are legacy and should be migrated.
- **Known edge:** a commit touching ONLY files excluded from every formatter (e.g. changelog-only commits) can fail the hook (formatter gets zero files). Fold such edits into a commit that also touches a covered file.

## Observability & analytics

`timings` (P50/P95 per step, regression detection correlated to git HEAD, flaky steps, retry stats), `history` (run-level health trends), `fleet` (cross-repo failure hotspots), `explain <run_id>` (single-run deep dive with per-step outputs), `digest`, `--live-dashboard` (SSE DAG dashboard), `--flight-recorder` (Go trace on failure).

- **Delegation rule:** before profiling or "optimizing the build", read what the timings DB already recorded — `buildflow timings --regressions` names the step AND the commit where the regression started.
