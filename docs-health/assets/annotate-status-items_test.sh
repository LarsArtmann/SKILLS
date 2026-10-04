#!/usr/bin/env bash
# check-annotator.sh — fixture tests for annotate-status-items.py.
# Exercises: numbered/table/checkbox/any:/@-disambiguation strikes, duplicate-key
# refusal, banned-verdict refusal, atomicity (one miss = no write), --verify
# (prints, writes nothing), and --emit-keys. Exit 0 = all fixtures pass.
#
# Fixture doc line map (1-based):
#   3: "1. First item alpha"          8: "1. First item gamma" (restart list)
#  13: "| 3 | Table row three | open |"
#  16: "- [ ] checkbox one"           17: "- [ ] checkbox two" (stays bare)
#  19: "Free prose mentioning item beta for any-mode."
set -euo pipefail
cd "$(dirname "$0")"

ANN="$(dirname "$0")/annotate-status-items.py"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
pass=0

expect() { # expect <desc> <want> <got>
	if [ "$2" = "$3" ]; then
		pass=$((pass + 1))
	else
		echo "FIXTURE FAIL: $1" >&2
		echo "  want: $2" >&2
		echo "  got:  $3" >&2
		exit 1
	fi
}

cat >"$WORK/doc.md" <<'EOF'
## List one

1. First item alpha
2. Second item beta

## List two (restarts numbering)

1. First item gamma
2. Second item delta

| # | Task | Status |
| --- | --- | --- |
| 3 | Table row three | open |
| 4 | Table row four | open |

- [ ] checkbox one
- [ ] checkbox two

Free prose mentioning item beta for any-mode.
EOF
cp "$WORK/doc.md" "$WORK/doc.pristine"

# --- emit-keys: keys generated mechanically from line numbers ---
python3 "$ANN" --emit-keys "$WORK/doc.md" 3 8 13 16 >"$WORK/keys.out" 2>"$WORK/keys.preview"
expect "emit-keys count" "4" "$(wc -l <"$WORK/keys.out")"
expect "emit-keys disambiguates restart" "1@First item gamma" "$(sed -n 2p "$WORK/keys.out")"
expect "emit-keys preview names line 8" "8: 1. First item gamma" "$(sed -n 2p "$WORK/keys.preview")"
expect "emit-keys checkbox shape" "checkbox one" "$(sed -n 4p "$WORK/keys.out")"

# --- build the real spec from emitted keys + hand verdicts ---
{
	sed -n '1p' "$WORK/keys.out" | sed 's/$/\t/'
	sed -n '2p' "$WORK/keys.out" | sed 's/$/\t/'
	sed -n '3p' "$WORK/keys.out" | sed 's/$/\tdone — table verdict/'
	sed -n '4p' "$WORK/keys.out" | sed 's/$/\t/'
	printf 'any:prose mentioning\t\n'
} >"$WORK/spec.tsv"

# --- duplicate-key refusal: BEFORE any file read, nothing written ---
cp "$WORK/doc.pristine" "$WORK/doc.md"
cat "$WORK/spec.tsv" >"$WORK/dup.tsv"
sed -n '1p' "$WORK/spec.tsv" >>"$WORK/dup.tsv"
rc=0
python3 "$ANN" "$WORK/doc.md" "$WORK/dup.tsv" >"$WORK/dup.out" 2>&1 || rc=$?
expect "dup-key exit" "1" "$rc"
grep -q "duplicate spec key" "$WORK/dup.out"
expect "dup-key message" "0" "$?"
cmp -s "$WORK/doc.pristine" "$WORK/doc.md"
pass=$((pass + 1))

# --- banned-verdict refusal ---
printf 'checkbox two\topen\n' >"$WORK/banned.tsv"
rc=0
python3 "$ANN" "$WORK/doc.md" "$WORK/banned.tsv" >/dev/null 2>&1 || rc=$?
expect "banned verdict refuses" "1" "$rc"
cmp -s "$WORK/doc.pristine" "$WORK/doc.md"
pass=$((pass + 1))

# --- atomicity: one unmatched key aborts the whole spec set ---
cp "$WORK/doc.pristine" "$WORK/doc.md"
{
	cat "$WORK/spec.tsv"
	printf '999\t\n'
} >"$WORK/atomic.tsv"
rc=0
python3 "$ANN" "$WORK/doc.md" "$WORK/atomic.tsv" >/dev/null 2>&1 || rc=$?
expect "atomic aborts" "1" "$rc"
cmp -s "$WORK/doc.pristine" "$WORK/doc.md"
pass=$((pass + 1))

# --- verify mode: resolves and prints, writes nothing ---
python3 "$ANN" --verify "$WORK/doc.md" "$WORK/spec.tsv" >"$WORK/verify.out" 2>&1
expect "verify exit" "0" "$?"
expect "verify resolves 5 keys" "VERIFY OK doc.md: 5 keys resolved (nothing written)" \
	"$(tail -1 "$WORK/verify.out")"
cmp -s "$WORK/doc.pristine" "$WORK/doc.md"
pass=$((pass + 1))

# --- strike mode: all five keys land, restart list disambiguated ---
python3 "$ANN" "$WORK/doc.md" "$WORK/spec.tsv" >"$WORK/strike.out" 2>&1
expect "strike exit" "0" "$?"
expect "strike reports 5" "OK doc.md: annotated 5 items" "$(cat "$WORK/strike.out")"
expect "list-one 1 struck" "~~1. First item alpha~~" "$(sed -n 3p "$WORK/doc.md" | sed 's/\t.*//')"
expect "list-two restart struck" "~~1. First item gamma~~" "$(sed -n 8p "$WORK/doc.md" | sed 's/\t.*//')"
expect "table row verdict" "~~| 3 | Table row three | open |~~ done — table verdict" \
	"$(sed -n 13p "$WORK/doc.md" | sed 's/ $//')"
expect "checkbox struck" "~~- [ ] checkbox one~~" "$(sed -n 16p "$WORK/doc.md" | sed 's/\t.*//')"
expect "unspecified checkbox stays bare" "- [ ] checkbox two" "$(sed -n 17p "$WORK/doc.md")"
expect "any-mode prose struck" "~~Free prose mentioning item beta for any-mode.~~" \
	"$(sed -n 19p "$WORK/doc.md" | sed 's/\t.*//')"

# --- bold-wrapped key cell (sweep-6 emitter bug, fixed 2026-10-04): a row
# whose key cell is `**C34**` must key and strike like a bare `C34` row.
# Before the fix both --emit-keys and resolve() saw no row pattern here,
# forcing hand-written `any:` anchors.
cat >"$WORK/bold.md" <<'EOF'
| Item | Detail | Status |
| --- | --- | --- |
| **C34** | Health-architecture hardening batch (R1-R6) | open |
EOF
cp "$WORK/bold.md" "$WORK/bold.pristine"
python3 "$ANN" --emit-keys "$WORK/bold.md" 3 >"$WORK/bold.keys" 2>"$WORK/bold.err"
expect "bold-cell emit-key" "C34@Health-architecture hardening ba" "$(cat "$WORK/bold.keys")"
printf 'C34@Health-architecture hardening ba\tDONE — struck via bold cell\n' >"$WORK/bold.tsv"
python3 "$ANN" --verify "$WORK/bold.md" "$WORK/bold.tsv" >"$WORK/bold.verify" 2>&1
expect "bold-cell verify" "VERIFY OK bold.md: 1 keys resolved (nothing written)" "$(tail -1 "$WORK/bold.verify")"
python3 "$ANN" "$WORK/bold.md" "$WORK/bold.tsv" >"$WORK/bold.strike" 2>&1
expect "bold-cell strike" "OK bold.md: annotated 1 items" "$(cat "$WORK/bold.strike")"
expect "bold-cell struck line" "~~| **C34** | Health-architecture hardening batch (R1-R6) | open |~~ DONE — struck via bold cell" \
	"$(sed -n 3p "$WORK/bold.md" | sed 's/ $//')"
cmp -s "$WORK/bold.pristine" "$WORK/bold.md" && {
	echo "bold-cell strike did not write" >&2
	exit 1
}

echo "annotator fixtures OK ($pass assertions)"
