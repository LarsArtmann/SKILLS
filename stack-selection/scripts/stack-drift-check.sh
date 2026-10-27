#!/usr/bin/env bash
# stack-drift-check.sh — enforce go.mod ⊆ STACK.md for first-party deps.
#
# The stack-selection skill writes STACK.md as the project's declared
# foundation. Without a reader it is a ghost system (written once, never
# checked). This script is the reader: every direct github.com/larsartmann/*
# require in go.mod must appear in the "Chosen foundation" section of
# STACK.md. Third-party deps are how-to-golang's domain, not checked here.
#
# Usage: stack-drift-check.sh [project-dir]   (default: cwd)
#
# Exit codes:
#   0  clean — every first-party dep is declared in STACK.md
#   1  drift — undeclared first-party dep, OR dep present in go.mod but
#              listed only as excluded/mentioned-not-chosen (contradiction)
#   2  no STACK.md in the project dir (run the stack-selection skill)

set -euo pipefail

project_dir="${1:-.}"
stack_file="$project_dir/STACK.md"
go_mod_file="$project_dir/go.mod"

if [[ ! -f "$go_mod_file" ]]; then
	echo "ERROR: no go.mod in $project_dir — nothing to check"
	exit 2
fi

if [[ ! -f "$stack_file" ]]; then
	echo "DRIFT(no-stack): $project_dir has a go.mod but no STACK.md — run the stack-selection skill and commit the decision record"
	exit 2
fi

# Direct first-party requires from go.mod: strip github.com/larsartmann/,
# keep the first path segment, drop /vN major suffixes.
first_party_libs="$(
	awk '
		/^require \(/ { in_req = 1; next }
		/^\)/ && in_req { in_req = 0; next }
		in_req && /github\.com\/larsartmann\// && !/\/\/ indirect/ {
			print $1
		}
		/^require [^ ]/ && /github\.com\/larsartmann\// && !/\/\/ indirect/ {
			print $2
		}
	' "$go_mod_file" |
		sed -E 's#^github\.com/larsartmann/##; s#/.*##; s#/v[0-9]+$##' |
		sort -u
)"

if [[ -z "$first_party_libs" ]]; then
	echo "OK: no first-party (larsartmann/*) requires — nothing to declare"
	exit 0
fi

# Split STACK.md at the "## Deliberately excluded" heading: above = chosen,
# below = excluded. A dep named only below the split is a contradiction.
chosen_section="$(sed -n '/^## Deliberately excluded/q;p' "$stack_file")"
excluded_section="$(sed -n '/^## Deliberately excluded/,$p' "$stack_file")"

failures=0
while IFS= read -r lib; do
	[[ -z "$lib" ]] && continue
	if grep -qF "$lib" <<<"$chosen_section"; then
		echo "OK: $lib declared in Chosen foundation"
	elif grep -qF "$lib" <<<"$excluded_section"; then
		echo "DRIFT(contradiction): $lib is required in go.mod but STACK.md lists it as deliberately excluded — either the exclusion is stale or the import is accidental"
		failures=$((failures + 1))
	else
		echo "DRIFT(undeclared): $lib is required in go.mod but appears nowhere in STACK.md — add a Chosen foundation row (with why-this-not-that) or drop the dep"
		failures=$((failures + 1))
	fi
done <<<"$first_party_libs"

if [[ "$failures" -gt 0 ]]; then
	echo "FAIL: $failures drift finding(s) in $project_dir"
	exit 1
fi

echo "PASS: go.mod first-party deps ⊆ STACK.md ($project_dir)"
