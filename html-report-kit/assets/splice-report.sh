#!/usr/bin/env bash
#
# splice-report.sh — write kit report bodies without ever touching template CSS.
#
# WHY THIS EXISTS
#   ~830 of the ~1080 lines in each kit template are one <style> block the report
#   author must not modify. The splice workflow splits authorship at that seam:
#   the agent writes ONLY the body fragment, this script injects it into the
#   untouched template shell (head, CSS, scrollspy script, document close), and
#   transcription token-drift becomes structurally impossible. Successor to the
#   2026-11-22 go-legalparty splice_report.py prototype (removed 2026-11-24 —
#   this repo carries no Python script assets).
#
# SPAN CONTRACT (both template variants share the same body scaffold)
#   START anchor: the exact line '    <div class="top-bar">'
#   END anchor:   the exact line '      </main>'
#   The fragment replaces the template span INCLUSIVE of both anchor lines, so
#   the fragment must open and close its own <main> (its last non-blank line
#   must be exactly '      </main>'). Dropping the optional top-bar inside the
#   fragment is allowed — anchors only have to exist in the TEMPLATE. The shell
#   still supplies everything around the span: the layout-closing </div>, the
#   scrollspy <script>, </body>, </html>.
#
# USAGE
#   splice-report.sh --extract <template.html>
#       Print the template's current span to stdout — the starting fragment to
#       edit (scaffold: top-bar, sidebar TOC, <main>, footer).
#   splice-report.sh <template.html> <output.html> <body.html>
#       Write the spliced report to <output.html>. body.html is scratch input;
#       the spliced .html file is the artifact.
#   splice-report.sh --self-test
#       Fixture tests plus a round-trip identity check against every shipped
#   template in this directory (extract the span, splice it back unmodified,
#   require byte-identical output). Run after any template or anchor change.
#
# Fails loudly (exit 1) whenever an anchor is missing or non-unique, the span
# is inverted, or the fragment violates the contract — never guess spans.
#
# Implementation note: anchor validation happens in resolve_span in the CALLER
# context, never inside a $(...) substitution — a die() inside command
# substitution only exits the subshell, and under an if-condition (errexit
# suspended) the caller would continue with empty line numbers (hit during
# self-test development 2026-11-24).

set -euo pipefail

START_ANCHOR='    <div class="top-bar">'
END_ANCHOR='      </main>'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() {
	echo "ERROR: $*" >&2
	exit 1
}

require_file() {
	[[ -f "$1" ]] || die "not a file: $1"
}

# Resolve the span for $1 into globals span_start/span_end, validating anchors
# in caller context so die() terminates the script, not a subshell.
resolve_span() {
	local template="$1" matches
	matches="$(grep -c -F -x -- "$START_ANCHOR" "$template" || true)"
	[[ "$matches" == "1" ]] ||
		die "start anchor not unique/missing in $template (expected 1, found ${matches:-0}): [$START_ANCHOR]"
	matches="$(grep -c -F -x -- "$END_ANCHOR" "$template" || true)"
	[[ "$matches" == "1" ]] ||
		die "end anchor not unique/missing in $template (expected 1, found ${matches:-0}): [$END_ANCHOR]"
	span_start="$(grep -n -F -x -- "$START_ANCHOR" "$template" | cut -d: -f1)"
	span_end="$(grep -n -F -x -- "$END_ANCHOR" "$template" | cut -d: -f1)"
	[[ "$span_start" =~ ^[0-9]+$ && "$span_end" =~ ^[0-9]+$ ]] ||
		die "unresolvable span in $template"
	[[ "$span_start" -lt "$span_end" ]] ||
		die "inverted span in $template: start line $span_start >= end line $span_end"
}

splice() {
	local template="$1" output="$2" body="$3"
	require_file "$template"
	require_file "$body"
	resolve_span "$template"

	local last_line
	last_line="$(grep -v '^[[:space:]]*$' "$body" | tail -n 1)"
	[[ "$last_line" == "$END_ANCHOR" ]] ||
		die "body fragment must end on a line exactly matching [$END_ANCHOR] (last non-blank line: [$last_line])"

	{
		head -n "$((span_start - 1))" "$template"
		cat "$body"
		tail -n "+$((span_end + 1))" "$template"
	} >"$output"
	echo "spliced $template -> $output ($(wc -c <"$body" | tr -d ' ') body bytes; shell lines 1-$((span_start - 1)) and $((span_end + 1))-$(wc -l <"$template" | tr -d ' ') untouched)"
}

extract() {
	local template="$1"
	require_file "$template"
	resolve_span "$template"
	sed -n "${span_start},${span_end}p" "$template"
}

self_test() {
	local tmp fixture_tpl body out expected broken badbody
	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' RETURN

	fixture_tpl="$tmp/fixture.html"
	cat >"$fixture_tpl" <<EOF
<!doctype html>
<html>
  <head>
    <style>/* shell css */</style>
  </head>
  <body>
$START_ANCHOR
      <span>fixture scaffold</span>
$END_ANCHOR
    </div>
    <script>/* scrollspy */</script>
  </body>
</html>
EOF

	body="$tmp/body.html"
	{
		echo "$START_ANCHOR"
		echo "      <p>report content</p>"
		echo "$END_ANCHOR"
	} >"$body"

	out="$tmp/out.html"
	splice "$fixture_tpl" "$out" "$body" >/dev/null
	expected="$tmp/expected.html"
	cat >"$expected" <<EOF
<!doctype html>
<html>
  <head>
    <style>/* shell css */</style>
  </head>
  <body>
$START_ANCHOR
      <p>report content</p>
$END_ANCHOR
    </div>
    <script>/* scrollspy */</script>
  </body>
</html>
EOF
	cmp -s "$out" "$expected" || die "fixture: spliced output != expected head+body+tail concatenation"

	extract "$fixture_tpl" | cmp -s - <(sed -n '7,9p' "$fixture_tpl") ||
		die "fixture: --extract did not print exactly the span lines"

	# Failure paths run in subshells: a die() inside them must terminate only
	# the subshell, surfacing as a non-zero if-condition here.
	broken="$tmp/broken.html"
	sed 's/top-bar/no-bar/' "$fixture_tpl" >"$broken"
	if (splice "$broken" "$tmp/x.html" "$body") >/dev/null 2>&1; then
		die "fixture: splice must fail on missing start anchor"
	fi
	sed "s|$END_ANCHOR|      </main>\\n      </main>|" "$fixture_tpl" >"$broken"
	if (splice "$broken" "$tmp/x.html" "$body") >/dev/null 2>&1; then
		die "fixture: splice must fail on duplicate end anchor"
	fi
	badbody="$tmp/badbody.html"
	echo "      <p>fragment that never closes main</p>" >"$badbody"
	if (splice "$fixture_tpl" "$tmp/x.html" "$badbody") >/dev/null 2>&1; then
		die "fixture: splice must fail when fragment does not end on </main>"
	fi

	# Round-trip identity against every shipped template: extract the span,
	# splice it back unmodified, require byte-identical output. Guards the
	# anchors against template drift.
	local template roundtrip checked=0
	for template in "$script_dir"/report-template*.html; do
		[[ -f "$template" ]] || continue
		roundtrip="$tmp/roundtrip.html"
		extract "$template" >"$body"
		splice "$template" "$roundtrip" "$body" >/dev/null
		cmp -s "$template" "$roundtrip" ||
			die "round-trip not byte-identical for $template — anchors drifted from the template scaffold"
		checked=$((checked + 1))
	done
	[[ "$checked" -gt 0 ]] ||
		die "no report-template*.html found in $script_dir — round-trip not verified"

	echo "self-test OK: fixture splice/extract/failure paths + round-trip identity for $checked template(s)"
}

case "${1:-}" in
--extract)
	[[ $# -eq 2 ]] || die "usage: $0 --extract <template.html>"
	extract "$2"
	;;
--self-test)
	[[ $# -eq 1 ]] || die "usage: $0 --self-test"
	self_test
	;;
-h | --help | "")
	awk 'NR > 1 { if ($0 ~ /^#/) { sub(/^# ?/, ""); print } else exit }' "${BASH_SOURCE[0]}"
	;;
*)
	[[ $# -eq 3 ]] || die "usage: $0 <template.html> <output.html> <body.html>"
	splice "$1" "$2" "$3"
	;;
esac
