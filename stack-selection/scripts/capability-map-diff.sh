#!/usr/bin/env bash
# capability-map-diff.sh — re-verify stack-selection's capability map
# against the `meta` project inventory.
#
# The map self-declares as "navigation, not truth; meta is truth". Without
# a cheap re-verification path that claim decays into documented neglect
# (self-review Q4, 2026-10-27). This script is that path: it diffs the lib
# rows in the map against the meta inventory and classifies the deltas.
#
# Usage: capability-map-diff.sh [map-file] [meta-json]
#   map-file  default: <script-dir>/../references/capability-map.md
#   meta-json default: output of `meta list --format json -q` (fetched live)
#
# Output: three classified lists + a verdict line.
#   exit 0 always (a diff is INFORMATION, not a failure — act on it by
#   editing the map, not by breaking CI)

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
map_file="${1:-$script_dir/../references/capability-map.md}"
meta_json="${2:-$(mktemp)}"
fetched_tmp=0
if [[ "${2:-}" == "" ]]; then
	meta list --format json -q >"$meta_json"
	fetched_tmp=1
fi

# Map rows: first table cell is `name (importance)`, `name/subpkg (imp)`,
# or `name` bare (importance optional). Skip header/separator/legend rows
# (they start with capitals, dashes, or bold markers).
map_libs="$(
	grep -E '^\| [a-z][a-zA-Z0-9/_.-]+( \([0-9]+\))?[[:space:]]*\|' "$map_file" |
		sed -E 's/^\| ([a-zA-Z0-9._/-]+).*/\1/' |
		sed -E 's#/v[0-9]+$##' |
		sort -u
)"

# Meta inventory: projects tagged lib, OR name matching the Go/lib
# prefixes (case-insensitive; meta key is `buildflow` lowercase) — the
# tag-hygiene lesson: never trust one tag filter.
meta_libs="$(
	jq -r 'to_entries[]
		| select((.value.tags // [] | index("lib")) or (.key | test("(?i)^(go-|cqrs-|template-|erraudit|gogenfilter|buildflow|samber-do)")))
		| .key' "$meta_json" | sort -u
)"

# All meta keys, for the gone-check (a map row is only "gone" if NO meta
# entry carries its name — not merely if it lacks the lib tag).
meta_all="$(jq -r 'keys[]' "$meta_json" | sort -u)"

echo "== mapped-but-gone-from-meta (map rows with no meta entry at all; verify on disk before deleting the row) =="
comm -23 <(echo "$map_libs") <(echo "$meta_all") || true
echo
echo "== new-in-meta-unmapped (meta lib-tagged/Go-prefixed projects absent from the map; triage: add row or record as known-gap) =="
comm -13 <(echo "$map_libs") <(echo "$meta_libs") || true
echo
map_count="$(echo "$map_libs" | wc -l)"
meta_count="$(echo "$meta_libs" | wc -l)"
echo "== verdict: $map_count map rows vs $meta_count meta candidates — reconcile, then update the map's verified-on date stamp =="
[[ "$fetched_tmp" == "1" ]] && rm -f "$meta_json"
exit 0
