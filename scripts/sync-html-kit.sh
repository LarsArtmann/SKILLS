#!/usr/bin/env bash
#
# sync-html-kit.sh — Vendor the canonical html-report-kit/ into every consumer skill.
#
# WHY THIS EXISTS
#   The Agent Skills spec (and the `pnpm dlx skills` / `bunx skills` CLI) treats each
#   skill as a flat, self-contained unit. There is no dependency system, no
#   `dependencies:` frontmatter field, and no shared-asset resolution. When a
#   user runs `bunx skills add LarsArtmann/SKILLS@status-report`, ONLY
#   status-report/ is copied out — its `../html-report-kit/...` sibling path
#   dangles and the kit appears not to exist.
#
#   This script fixes that by copying the canonical kit into each consumer's own
#   assets/html-report-kit/ so references resolve intra-skill
#   (./assets/html-report-kit/...), which works in every install mode:
#   per-skill add/update, clone, and skills_paths.
#
# CANONICAL SOURCE OF TRUTH
#   html-report-kit/ at the repo root. Edit the kit there. Re-run this script to
#   propagate changes to all consumers. The vendored copies under
#   <consumer>/assets/html-report-kit/ are build artifacts — never hand-edit them.
#
# WHY SKILL.md IS EXCLUDED FROM VENDORED COPIES
#   The skills CLI discovers skills by walking directories for SKILL.md files.
#   If a vendored copy contained SKILL.md, the CLI could mistake
#   <consumer>/assets/html-report-kit/ for a standalone skill. We exclude it so
#   only the canonical html-report-kit/SKILL.md is ever detected as a skill.
#
# USAGE
#   scripts/sync-html-kit.sh            # sync all consumers (default)
#   scripts/sync-html-kit.sh --check    # exit 1 if any vendored copy drifted (CI)
#   scripts/sync-html-kit.sh --list     # list detected consumers, make no changes
#
# CONSUMER DISCOVERY
#   Any SKILL.md (other than the kit's own) that mentions "html-report-kit".
#   This catches both the legacy ../html-report-kit/ form and the vendored
#   ./assets/html-report-kit/ form, so discovery works during and after migration.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kit_name="html-report-kit"
kit_src="$repo_root/$kit_name"
vendored_dirname="assets/$kit_name" # relative to each consumer skill dir

if [[ ! -d "$kit_src" ]]; then
	echo "ERROR: canonical $kit_name/ not found at $kit_src" >&2
	exit 1
fi

mode="${1:-sync}"
case "$mode" in
--check) action="check" ;;
--list) action="list" ;;
sync | "") action="sync" ;;
*)
	echo "Usage: $0 [--check|--list]" >&2
	exit 2
	;;
esac

# --- Discover consumers -------------------------------------------------------
# SKILL.md files (not the kit's own) that mention the kit name.
mapfile -t consumer_files < <(
	grep -rl --include='SKILL.md' -F "$kit_name" "$repo_root" 2>/dev/null |
		grep -v -F "$kit_src/SKILL.md" |
		sort -u ||
		true
)
consumers=()
for f in "${consumer_files[@]}"; do
	consumers+=("$(basename "$(dirname "$f")")")
done

if [[ ${#consumers[@]} -eq 0 ]]; then
	echo "No consumers of $kit_name found." >&2
	exit 0
fi

if [[ "$action" == "list" ]]; then
	echo "Consumers of $kit_name (${#consumers[@]}):"
	for c in "${consumers[@]}"; do printf '  - %s\n' "$c"; done
	exit 0
fi

# --- Helpers ------------------------------------------------------------------

sync_one() {
	local consumer="$1"
	local skill_dir="$repo_root/$consumer"
	local target="$skill_dir/$vendored_dirname"
	if [[ ! -d "$skill_dir" ]]; then
		echo "  SKIP $consumer (skill dir missing at $skill_dir)" >&2
		return 1
	fi
	rm -rf "$target"
	mkdir -p "$target"
	# Copy kit contents verbatim (preserves internal ../assets/ relative refs),
	# including dotfiles, then strip any SKILL.md so the CLI won't see a nested skill.
	cp -r "$kit_src"/. "$target/"
	find "$target" -name SKILL.md -delete
	return 0
}

check_one() {
	# Returns 0 if the vendored copy matches canonical (minus SKILL.md), else 1.
	local consumer="$1"
	local target="$repo_root/$consumer/$vendored_dirname"
	local drift=0

	if [[ ! -d "$target" ]]; then
		echo "  MISSING $consumer/$vendored_dirname/"
		return 1
	fi

	# Every canonical file (except SKILL.md) must exist identically under target/.
	while IFS= read -r -d '' src; do
		local rel="${src#"$kit_src"/}"
		[[ "$rel" == "SKILL.md" ]] && continue
		local dst="$target/$rel"
		if [[ ! -f "$dst" ]]; then
			echo "  MISSING $consumer/$vendored_dirname/$rel"
			drift=1
		elif ! diff -q "$src" "$dst" >/dev/null 2>&1; then
			echo "  DRIFT  $consumer/$vendored_dirname/$rel"
			drift=1
		fi
	done < <(find "$kit_src" -type f -print0)

	# Conversely, vendored copy must not contain anything absent from canonical.
	while IFS= read -r -d '' dst; do
		local rel="${dst#"$target"/}"
		local src="$kit_src/$rel"
		if [[ ! -f "$src" ]]; then
			echo "  EXTRA  $consumer/$vendored_dirname/$rel"
			drift=1
		fi
	done < <(find "$target" -type f -print0)

	return $drift
}

# --- Run ----------------------------------------------------------------------

echo "Mode:      $action"
echo "Kit:       $kit_src"
echo "Consumers: ${#consumers[@]} (${consumers[*]})"
echo

case "$action" in
sync)
	for c in "${consumers[@]}"; do
		if sync_one "$c"; then
			echo "  synced  $c/$vendored_dirname/"
		fi
	done
	echo
	echo "Done. Consumers reference ./$vendored_dirname/ (intra-skill, portable)."
	echo "Run with --check in CI to detect drift."
	;;
check)
	failed=0
	for c in "${consumers[@]}"; do
		if ! check_one "$c"; then failed=1; fi
	done
	echo
	if [[ $failed -ne 0 ]]; then
		echo "FAIL: vendored copies differ from canonical $kit_name/." >&2
		echo "      Run scripts/sync-html-kit.sh to regenerate them." >&2
		exit 1
	fi
	echo "OK: all consumers in sync with canonical $kit_name/."
	;;
esac
