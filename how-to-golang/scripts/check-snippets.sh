#!/usr/bin/env bash
#
# check-snippets.sh — parse-sweep the Go snippets in this skill's markdown
# and in the references/<topic>-NN example files.
#
# WHY THIS EXISTS
#   A guide whose snippets do not parse rots silently. The one-off
#   compile-check of 2026-08-21 caught real drift (uniflow uncompilable at
#   @latest, since banned); this script makes that check repeatable on
#   demand instead of a hand-rolled awk pipeline per session.
#
# WHAT IT DOES
#   1. Extracts every ```go block from SKILL.md + references/*.md.
#      Almost all are illustrative fragments, so each is parsed under up
#      to five wrappers (as-is / +package p / func _ body / imports
#      hoisted + decls / imports hoisted + func _ body) — a snippet the
#      guide shows as "usage after import" is valid under a wrapper and
#      passes. A block that still fails AND contains `...` is a
#      deliberate placeholder snippet -> SKIP (counted, never silently
#      dropped); anything else that fails is a real guide defect.
#   2. references/<topic>-NN/main.go example files get the same parse
#      treatment. The rare example that IS a complete program (has a
#   `package` clause) is compiled in its own temp module; deps that
#      cannot be fetched (offline / private auth) are SKIPs with the
#      reason, not failures.
#
#   gofmt -e is the parser: exit 0 = syntactically valid Go.
#
# USAGE
#   how-to-golang/scripts/check-snippets.sh    # from anywhere; exit 1 = FAIL
#
# OUTPUT
#   One line per FAIL/SKIP with file:line, then a machine-greppable
#   summary: "check-snippets: PASS 64 OK, 0 fail, N skip".
#
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
skill_dir=$(cd "$here/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

blocks_dir=$tmp/blocks
mkdir -p "$blocks_dir"

pass=0
fail=0
skip=0
failed_labels=()

parses() { printf '%s' "$1" | gofmt -e /dev/stdin >/dev/null 2>&1; }

# build_wrappers FILE — read a Go fragment and set w1..w5 candidate texts.
# w4/w5 hoist single-line `import x` and parenthesized import groups to the
# top (markdown snippets legitimately show imports mid-block or followed by
# bare usage statements).
build_wrappers() {
	local src line imports_text rest_text in_group
	src=$(cat "$1")
	imports_text=""
	rest_text=""
	in_group=0
	while IFS= read -r line; do
		if ((in_group)); then
			imports_text+="$line"$'\n'
			[[ "$line" =~ ^\) ]] && in_group=0
		elif [[ "$line" =~ ^import[[:space:]]*\($ ]]; then
			imports_text+="$line"$'\n'
			in_group=1
		elif [[ "$line" =~ ^import[[:space:]] ]]; then
			imports_text+="$line"$'\n'
		else
			rest_text+="$line"$'\n'
		fi
	done <<<"$src"
	w1=$src
	w2=$(printf 'package p\n\n%s' "$src")
	w3=$(printf 'package p\n\nfunc _() {\n%s}\n' "$src")
	w4=$(printf 'package p\n\n%s\n%s' "$imports_text" "$rest_text")
	w5=$(printf 'package p\n\n%sfunc _() {\n%s}\n' "$imports_text" "$rest_text")
}

check_fragment() { # $1 = file, $2 = label
	build_wrappers "$1"
	if parses "$w1" || parses "$w2" || parses "$w3" || parses "$w4" || parses "$w5"; then
		pass=$((pass + 1))
	elif grep -q '\.\.\.' "$1"; then
		skip=$((skip + 1))
		echo "SKIP  $2 (placeholder \`...\` snippet)"
	else
		fail=$((fail + 1))
		failed_labels+=("$2")
		echo "FAIL  $2"
		printf 'package p\n\n%s' "$(cat "$1")" | gofmt -e /dev/stdin 2>&1 |
			head -2 | sed 's/^/      /' || true
	fi
}

# --- 1. Extract ```go blocks with their opening line numbers ---
for md in "$skill_dir/SKILL.md" "$skill_dir"/references/*.md; do
	[[ -f "$md" ]] || continue
	rel=${md#"$skill_dir"/}
	awk -v dir="$blocks_dir" -v rel="$rel" '
		function safe(s) { gsub(/\//, "__", s); return s }
		/^```go[[:space:]]*$/ {
			inb = 1
			n++
			f = sprintf("%s/%s.%03d", dir, safe(rel), n)
			meta = sprintf("%s:%d", rel, NR)
			m = sprintf("%s/%s.%03d.meta", dir, safe(rel), n)
			print meta > m
			close(m)
			next
		}
		/^```/ {
			if (inb) { inb = 0; close(f) }
			next
		}
		inb { print > f }
	' "$md"
done

# --- 2. Parse each markdown block ---
for meta in "$blocks_dir"/*.meta; do
	[[ -e "$meta" ]] || continue
	label=$(cat "$meta")
	check_fragment "${meta%.meta}" "$label"
done

# --- 3. Example files: complete programs compile, fragments parse ---
example_n=0
for d in "$skill_dir"/references/*/; do
	[[ -f "$d/main.go" ]] || continue
	example_n=$((example_n + 1))
	rel=${d#"$skill_dir"/}
	rel=${rel%/}
	if ! grep -q '^package ' "$d/main.go"; then
		check_fragment "$d/main.go" "$rel/main.go (fragment)"
		continue
	fi
	ex_tmp=$tmp/ex$example_n
	mkdir -p "$ex_tmp"
	cp "$d"/*.go "$ex_tmp/"
	if ! gomod_out=$(
		cd "$ex_tmp" &&
			go mod init "example.com/fixture/ex$example_n" 2>&1 &&
			go mod tidy 2>&1 &&
			go build . 2>&1
	); then
		skip=$((skip + 1))
		reason=$(printf '%s' "$gomod_out" | grep -Ev '^(go: downloading|go: found)' | tail -1)
		echo "SKIP  $rel (dep unavailable: ${reason:-unknown})"
	else
		pass=$((pass + 1))
	fi
done

# --- Summary ---
for label in "${failed_labels[@]}"; do
	echo "  failing: $label"
done
if [[ $fail -gt 0 ]]; then
	echo "check-snippets: FAIL $pass OK, $fail fail, $skip skip"
	exit 1
fi
echo "check-snippets: PASS $pass OK, $fail fail, $skip skip"
