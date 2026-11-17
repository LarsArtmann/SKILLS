#!/usr/bin/env bash
#
# check-shell.sh — shellcheck quality gate for every .sh shipped in this repo.
#
# WHY THIS EXISTS
#   Skill scripts run inside other people's sessions with minimal review
#   (docs-only repo, no CI). The unquoted-variable bug class that hit
#   nix-private-go-repos' list-private-deps.sh (TODO_LIST T62) is exactly
#   what shellcheck catches statically. shfmt (AGENTS.md §1) only reformats;
#   this gate catches semantics: unquoted expansions, word-splitting loops,
#   missing braces, fragile find/grep pipes.
#
# WHAT IT CHECKS
#   Every *.sh in the repo (skill scripts/ dirs, repo-level scripts/, test
#   harnesses) with shellcheck at full severity (style included). The
#   baseline is clean: intentional style exceptions must carry an inline
#   `# shellcheck disable=SCxxxx  # reason` comment, never a repo-wide
#   exclusion.
#
# USAGE
#   scripts/check-shell.sh             # check all repo .sh files
#   scripts/check-shell.sh <file>...   # check specific files
#   scripts/check-shell.sh --root DIR  # scan DIR instead of the repo
#   exit 0 = clean, exit 1 = findings, exit 2 = usage/tool error

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${1:-}" == "--root" ]]; then
	if [[ $# -lt 2 ]]; then
		echo "Usage: $0 [--root DIR] [file...]" >&2
		exit 2
	fi
	repo_root="$2"
	shift 2
fi
repo_root="$(cd "$repo_root" && pwd)"
cd "$repo_root"

# Prefer a shellcheck on PATH; fall back to nix so the gate runs on any
# Nix machine without a global install.
if command -v shellcheck >/dev/null 2>&1; then
	run_shellcheck() { shellcheck "$@"; }
elif command -v nix >/dev/null 2>&1; then
	run_shellcheck() { nix --quiet run nixpkgs#shellcheck -- "$@"; }
else
	echo "ERROR: neither shellcheck nor nix found — install shellcheck (or Nix) to run this gate." >&2
	exit 2
fi

if [[ $# -gt 0 ]]; then
	files=("$@")
else
	mapfile -t files < <(
		find . -name '*.sh' -type f \
			! -path "*/.git/*" |
			sort
	)
fi

if [[ ${#files[@]} -eq 0 ]]; then
	echo "check-shell: no .sh files found — nothing to check."
	exit 0
fi

failed=0
for f in "${files[@]}"; do
	if run_shellcheck "$f"; then
		echo "OK ${f#./}"
	else
		failed=1
	fi
done

if [[ $failed -ne 0 ]]; then
	echo "FAIL check-shell: shellcheck findings above — fix them, or add an inline" >&2
	echo "'# shellcheck disable=SCxxxx  # reason' where the pattern is intentional." >&2
fi
exit "$failed"
