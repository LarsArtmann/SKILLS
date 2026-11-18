#!/usr/bin/env bash
# stack-drift-check.sh — enforce go.mod ⊆ STACK.md for first-party deps.
#
# The stack-selection skill writes STACK.md as the project's declared
# foundation. Without a reader it is a ghost system (written once, never
# checked). This script is the reader: every direct github.com/larsartmann/*
# require in each go.mod must appear in the "Chosen foundation" section of
# STACK.md. Third-party deps are how-to-golang's domain, not checked here.
#
# Multi-module projects: every go.mod at depth ≤2 under the project dir
# (root + member sub-modules) is checked and labeled, so the pin matrix
# is enforced per module, not just at the root. Requires of the project's
# OWN module tree (sibling product modules like profileagent/cloudbrowser)
# are checked against the "## Wiring order" section instead of Chosen
# foundation — siblings are structure, not library choices. The sibling
# boundary is the PROJECT ROOT module path: portalapply requiring
# profileagent/cloudbrowser is still a sibling of the project.
#
# Per-module wiring matrix: if STACK.md carries a "## Wiring order"
# section, every extracted require must ALSO be named in that module's
# wiring entry. Projects without the section skip this check (single-lib
# repos need no matrix).
#
# Usage: stack-drift-check.sh [project-dir]   (default: cwd)
#
# Exit codes:
#   0  clean — every first-party dep is declared (and wired, if matrixed)
#   1  drift — undeclared first-party dep, contradiction with Deliberately
#              excluded, or missing wiring entry
#   2  no STACK.md / no go.mod in the project dir

set -euo pipefail

project_dir="${1:-.}"
stack_file="$project_dir/STACK.md"

# All go.mods at depth ≤2: root + one level of member sub-modules.
go_mod_files="$(find "$project_dir" -maxdepth 2 -name go.mod \
	-not -path '*/vendor/*' -not -path '*/testdata/*' | sort)"

if [[ -z "$go_mod_files" ]]; then
	echo "ERROR: no go.mod in $project_dir — nothing to check"
	exit 2
fi

if [[ ! -f "$stack_file" ]]; then
	echo "DRIFT(no-stack): $project_dir has a go.mod but no STACK.md — run the stack-selection skill and commit the decision record"
	exit 2
fi

# STACK split: above "## Deliberately excluded" = chosen, below = excluded.
chosen_section="$(sed -n '/^## Deliberately excluded/q;p' "$stack_file")"
excluded_section="$(sed -n '/^## Deliberately excluded/,$p' "$stack_file")"

# The Wiring order section (if present) + its numbered entry blocks.
wiring_section=""
if sed -n '/^## Wiring order/,/^## /p' "$stack_file" | head -n -1 | grep -q .; then
	wiring_section="$(sed -n '/^## Wiring order/,/^## /p' "$stack_file" | head -n -1)"
fi

# Sibling boundary: the PROJECT ROOT module path. Requires under it are
# sibling product modules (structure), not library choices.
if [[ -f "$project_dir/go.mod" ]]; then
	project_module="$(awk '/^module / { print $2; exit }' "$project_dir/go.mod")"
else
	project_module="$(awk '/^module / { print $2; exit }' "$(echo "$go_mod_files" | head -1)")"
fi

# Extract the wiring entry text for one module label. Entry blocks start
# at `<n>. **<label>…`; a block runs until the next numbered entry.
wiring_entry() {
	local label="$1"
	[[ -z "$wiring_section" ]] && return 0
	awk -v label="$label" '
		/^[[:space:]]*[0-9]+\. \*\*/ {
			in_block = ($0 ~ ("\\*\\*" label))
		}
		in_block { print }
	' <<<"$wiring_section"
}

total_failures=0

while IFS= read -r go_mod_file; do
	[[ -z "$go_mod_file" ]] && continue

	module_dir="$(dirname "$go_mod_file")"
	if [[ "$module_dir" == "$project_dir" ]]; then
		label="root"
	else
		label="$(basename "$module_dir")"
	fi

	# Direct first-party requires: strip github.com/larsartmann/, keep the
	# first path segment, drop /vN major suffixes. Requires inside the
	# project's own module tree are tagged "sibling:<name>".
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
			while IFS= read -r req; do
				if [[ -n "$project_module" && "$req" == "$project_module"* ]]; then
					echo "sibling:${req#"$project_module"/}"
				else
					echo "${req#github.com/larsartmann/}"
				fi
			done |
			sed -E 's#^github\.com/larsartmann/##; s#^([^/]+)/.*#\1#' |
			sort -u
	)"

	if [[ -z "$first_party_libs" ]]; then
		echo "OK: $label — no first-party (larsartmann/*) requires"
		continue
	fi

	failures=0
	while IFS= read -r lib; do
		[[ -z "$lib" ]] && continue

		entry="$(wiring_entry "$label")"

		if [[ "$lib" == sibling:* ]]; then
			sib="${lib#sibling:}"
			sib="${sib%%/*}"
			if grep -qF "$sib" <<<"$entry"; then
				echo "OK: $label — sibling $sib wired in Wiring order"
			elif [[ -z "$wiring_section" ]]; then
				echo "OK: $label — sibling $sib (no Wiring order section; matrix not opted in)"
			else
				echo "DRIFT(wiring): $label requires sibling module $sib but the Wiring order entry for $label does not name it"
				failures=$((failures + 1))
			fi
			continue
		fi

		lib_name="${lib%%/*}"
		if grep -qF "$lib_name" <<<"$chosen_section"; then
			if [[ -n "$wiring_section" ]] && ! grep -qF "$lib_name" <<<"$entry"; then
				echo "DRIFT(wiring): $label requires $lib_name (declared in Chosen foundation) but the Wiring order entry for $label does not name it"
				failures=$((failures + 1))
			else
				echo "OK: $label — $lib_name declared in Chosen foundation"
			fi
		elif grep -qF "$lib_name" <<<"$excluded_section"; then
			echo "DRIFT(contradiction): $label requires $lib_name but STACK.md lists it as deliberately excluded — either the exclusion is stale or the import is accidental"
			failures=$((failures + 1))
		else
			echo "DRIFT(undeclared): $label requires $lib_name but it appears nowhere in STACK.md — add a Chosen foundation row (with why-this-not-that) or drop the dep"
			failures=$((failures + 1))
		fi
	done <<<"$first_party_libs"

	if [[ "$failures" -gt 0 ]]; then
		echo "FAIL: $failures drift finding(s) in $label ($go_mod_file)"
	fi

	total_failures=$((total_failures + failures))
done <<<"$go_mod_files"

if [[ "$total_failures" -gt 0 ]]; then
	echo "FAIL: $total_failures drift finding(s) across $(echo "$go_mod_files" | wc -l) module(s) in $project_dir"
	exit 1
fi

echo "PASS: all go.mod first-party deps ⊆ STACK.md ($project_dir)"
