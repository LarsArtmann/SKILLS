#!/usr/bin/env bash
#
# scratch.sh — create and clean up /tmp scratch directories using trash.
#
# WHY THIS EXISTS
#   Verification work (compile harnesses, eval scratch modules, link tests)
#   creates many /tmp directories, and sessions keep cleaning them with
#   `rm -rf` — a documented repeat-offense (2026-08-12 and 2026-08-21 status
#   reports). This helper makes `trash` the path of least resistance: created
#   dirs are registered, and --clean trashes them all. No path exceptions.
#
# USAGE
#   scripts/scratch.sh <name>     # print path of /tmp/scratch-<name> (created)
#                                 #   usage: dir=$(scripts/scratch.sh mytest)
#   scripts/scratch.sh --list     # show registered scratch dirs
#   scripts/scratch.sh --clean    # trash every registered scratch dir
#
# REQUIRES: trash (trash-cli). Refuses to run anything destructive without it.

set -euo pipefail

manifest="${SCRATCH_MANIFEST:-/tmp/.scratch-manifest}"

if ! command -v trash >/dev/null 2>&1; then
	echo "error: 'trash' not found — install trash-cli; this helper never uses rm" >&2
	exit 1
fi

case "${1:-}" in
--list)
	[[ -f "$manifest" ]] && cat "$manifest" || echo "(no scratch dirs registered)"
	;;
--clean)
	if [[ ! -f "$manifest" ]]; then
		echo "(no scratch dirs registered)"
		exit 0
	fi
	while IFS= read -r dir; do
		[[ -z "$dir" ]] && continue
		if [[ -e "$dir" ]]; then
			trash "$dir" && echo "trashed $dir"
		else
			echo "gone already: $dir"
		fi
	done <"$manifest"
	: >"$manifest"
	;;
--help | -h | "")
	sed -n '2,15p' "$0"
	;;
-*)
	echo "unknown option: $1" >&2
	exit 2
	;;
*)
	name="$1"
	[[ "$name" == */* ]] && {
		echo "error: name must not contain '/'" >&2
		exit 2
	}
	dir="/tmp/scratch-$name"
	mkdir -p "$dir"
	touch "$manifest"
	grep -qxF "$dir" "$manifest" 2>/dev/null || echo "$dir" >>"$manifest"
	echo "$dir"
	;;
esac
