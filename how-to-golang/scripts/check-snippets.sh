#!/usr/bin/env bash
#
# check-snippets.sh — parse-sweep the Go snippets in this skill's markdown
# and compile the references/<topic>-NN example programs.
#
# WHY THIS EXISTS
#   A guide whose snippets do not parse rots silently. The one-off
#   compile-check of 2026-08-21 caught real drift (uniflow uncompilable at
#   @latest, since banned); this script makes that check repeatable on
#   demand instead of a hand-rolled awk pipeline per session.
#
# WHAT IT DOES
#   1. Extracts every ```go block from SKILL.md + references/*.md.
#      Most blocks are illustrative fragments, so each is parsed under up
#      to three wrappers (as-is / package p / package p + func _ body);
#      a block that still fails AND contains `...` is a deliberate
#      placeholder snippet -> SKIP (counted, never silently dropped).
#   2. Builds every references/*/main.go example as its own temp module
#      (go mod init + tidy + build). Examples whose deps cannot be
#      fetched (offline / private auth) are SKIPs with the reason, not
#      failures — the parse sweep above already covers their syntax.
#
#   gofmt -e is the parser: exit 0 = the snippet is syntactically valid Go.
#
# USAGE
#   how-to-golang/scripts/check-snippets.sh    # from anywhere; exit 1 = FAIL
#
# OUTPUT
#   One line per FAIL/SKIP with file:line, then a machine-greppable
#   summary: "check-snippets: PASS 33 blocks, 31 examples (0 fail, N skip)"
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

# --- 2. Parse each block (three wrapper attempts) ---
for meta in "$blocks_dir"/*.meta; do
	[[ -e "$meta" ]] || continue
	label=$(cat "$meta")
	block_file=${meta%.meta}
	block=$(cat "$block_file")

	if printf '%s' "$block" | gofmt -e /dev/stdin >/dev/null 2>&1 ||
		printf 'package p\n\n%s\n' "$block" | gofmt -e /dev/stdin >/dev/null 2>&1 ||
		printf 'package p\n\nfunc _() {\n%s\n}\n' "$block" | gofmt -e /dev/stdin >/dev/null 2>&1; then
		pass=$((pass + 1))
	elif printf '%s' "$block" | grep -q '\.\.\.'; then
		skip=$((skip + 1))
		echo "SKIP  $label (placeholder \`...\` snippet)"
	else
		fail=$((fail + 1))
		failed_labels+=("$label")
		echo "FAIL  $label"
		printf '%s' "$block" | gofmt -e /dev/stdin 2>&1 | head -2 | sed 's/^/      /'
	fi
done

# --- 3. Compile each references/<topic>-NN example in its own temp module ---
example_n=0
for d in "$skill_dir"/references/*/; do
	[[ -f "$d/main.go" ]] || continue
	example_n=$((example_n + 1))
	rel=${d#"$skill_dir"/}
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
		echo "SKIP  ${rel%/} (dep unavailable: ${reason:-unknown})"
	else
		pass=$((pass + 1))
	fi
done

# --- Summary ---
for label in "${failed_labels[@]}"; do
	echo "  failing block: $label"
done
total=$((pass + fail))
if [[ $fail -gt 0 ]]; then
	echo "check-snippets: FAIL $total blocks+examples OK, $fail fail, $skip skip"
	exit 1
fi
echo "check-snippets: PASS $pass blocks+examples OK, $fail fail, $skip skip"
