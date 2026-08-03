#!/usr/bin/env bash
#
# check-skills.sh — Validate skill directories and guard against known regressions.
#
# WHY THIS EXISTS
#   This is a content repository: the markdown IS the product. There is no build
#   system or test suite. This script fills that gap with structural validation:
#     1. Every <skill>/SKILL.md has valid YAML frontmatter (name + description).
#     2. Every frontmatter `name:` matches its directory (Crush matches them).
#     3. The `git commit <--` / bare `<--` prompt artifact never returns in a
#        SKILL.md (see AGENTS.md §5.2). originals/ is exempt — frozen source.
#     4. Surface "thin" skills (<35 lines) so they get attention.
#     5. Description field stays under 1024 chars (Crush refuses to load skills
#        that exceed this limit — the skill silently never triggers).
#     6. SKILL.md length gate at 500 lines (push detail to references/; see
#        AGENTS.md §3.2). Allowlisted skills warn instead of fail.
#     7. Feedback-loop staleness: docs/feedback/new/ files older than 30 days
#        fail (the feedback loop is broken again — see AGENTS.md §11).
#     8. Cross-skill handoff guard: known handoff links (e.g. status-report →
#        docs-health HARVEST) must exist, or the loop reopens (AGENTS.md §5.5).
#
# USAGE
#   scripts/check-skills.sh            # run all checks, exit 1 on any failure
#   scripts/check-skills.sh --thin     # list thin skills only (always exit 0)

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

mode="${1:-check}"
thin_only=0
case "$mode" in
--thin) thin_only=1 ;;
check | "") ;;
*)
	echo "Usage: $0 [--thin]" >&2
	exit 2
	;;
esac

# Collect skill directories (any dir containing SKILL.md, excluding vendored kits
# nested under assets/ and the originals/ legacy folder).
mapfile -t skill_dirs < <(
	find . -name SKILL.md -type f \
		! -path "*/assets/*" \
		! -path "*/originals/*" \
		-exec dirname {} \; | sort -u
)

# --- Thin-skill report (informational) -----------------------------------------
echo "Skill inventory (${#skill_dirs[@]} skills):"
thin_count=0
for d in "${skill_dirs[@]}"; do
	lines=$(wc -l <"$d/SKILL.md")
	flag=""
	if [[ "$lines" -lt 35 ]]; then
		flag="  [THIN]"
		thin_count=$((thin_count + 1))
	fi
	printf "  %-28s %4s lines%s\n" "${d#./}" "$lines" "$flag"
done
echo "Thin skills (<35 lines): $thin_count"
echo

if [[ "$thin_only" -eq 1 ]]; then exit 0; fi

# --- Structural checks ---------------------------------------------------------
failed=0

for d in "${skill_dirs[@]}"; do
	skill="${d#./}"
	f="$d/SKILL.md"

	# Check 1: frontmatter delimiters
	if ! head -1 "$f" | grep -q '^---$'; then
		echo "FAIL $skill: SKILL.md must start with a '---' frontmatter delimiter"
		failed=1
	fi
	# Check 2: name field present and matches directory
	name=$(grep -m1 '^name:' "$f" | sed -E 's/^name:[[:space:]]*//;s/[[:space:]]*$//')
	if [[ -z "$name" ]]; then
		echo "FAIL $skill: missing 'name:' in frontmatter"
		failed=1
	elif [[ "$name" != "$skill" ]]; then
		echo "FAIL $skill: frontmatter name '$name' != directory '$skill'"
		failed=1
	fi
	# Check 3: description field present
	if ! grep -q '^description:' "$f"; then
		echo "FAIL $skill: missing 'description:' in frontmatter"
		failed=1
	fi
	# Check 4: no `git commit <--` / bare `<-- ` artifact (see AGENTS.md §5.2)
	if grep -q 'git commit <--' "$f" || grep -qE 'commit[[:space:]]+<--[[:space:]]' "$f"; then
		echo "FAIL $skill: contains the 'git commit <--' prompt artifact — rewrite as clear prose (AGENTS.md §5.2)"
		failed=1
	fi
	# Check 5: description does not exceed 1024 characters (Crush validation limit)
	# Handles both single-line and YAML folded (>) / literal (|) block scalars.
	desc_len=$(awk '
    BEGIN { block=0; done=0; desc="" }
    /^description:[[:space:]]*[>|]/ { block=1; next }
    /^description:/ && !block {
      sub(/^description:[[:space:]]*/, "")
      sub(/[[:space:]]+$/, "")
      print length($0); done=1; exit
    }
    block {
      if (/^[^[:space:]]/) { print length(desc); done=1; exit }
      line=$0; sub(/^[[:space:]]+/, "", line)
      if (desc != "") desc = desc " " line; else desc = line
    }
    END { if (block && !done) print length(desc) }
  ' "$f")
	if [[ -n "$desc_len" ]] && [[ "$desc_len" -gt 1024 ]]; then
		echo "FAIL $skill: description is $desc_len chars (limit 1024) — Crush will refuse to load this skill"
		failed=1
	fi
done

# --- Hardcoded-count guard -----------------------------------------------------
# Fail if README.md or AGENTS.md hardcode a skill count that disagrees with the
# discovered count. Hardcoded counts rot; this catches the "N total" / "N skills"
# drift automatically (see AGENTS.md docs-health lesson: never hardcode counts).
# A bare "N skills" is allowed ONLY when it matches the real count.
real_count="${#skill_dirs[@]}"
count_re='([0-9]+)[[:space:]]+(skills|total)'
while IFS= read -r line; do
	if [[ "$line" =~ $count_re ]]; then
		hard="${BASH_REMATCH[1]}"
		if [[ "$hard" != "$real_count" ]]; then
			echo "FAIL: hardcoded skill count '$hard' disagrees with real count '$real_count' — use a pointer to $0 instead (line: $line)"
			failed=1
		fi
	fi
done < <(grep -rnE '[0-9]+[[:space:]]+(skills|total)' README.md AGENTS.md 2>/dev/null)

# --- Line-count gate ------------------------------------------------------------
# SKILL.md files should stay under ~500 lines (AGENTS.md §3.2): push detail to
# references/. The allowlist holds skills where long-form is temporarily
# justified — each entry should carry a trim plan and be revisited.
long_allowlist=(website-launch)
for d in "${skill_dirs[@]}"; do
	skill="${d#./}"
	lines=$(wc -l <"$d/SKILL.md")
	if [[ "$lines" -gt 500 ]]; then
		allowed=0
		for a in "${long_allowlist[@]}"; do [[ "$skill" == "$a" ]] && allowed=1; done
		if [[ "$allowed" -eq 0 ]]; then
			echo "FAIL $skill: SKILL.md is $lines lines (limit 500) — push detail to references/ (AGENTS.md §3.2)"
			failed=1
		else
			echo "WARN $skill: SKILL.md is $lines lines (allowlisted, but should be trimmed)"
		fi
	fi
done

# --- Backlink integrity --------------------------------------------------------
# Verify every markdown relative link of the form ](./path) or ](../path) inside
# a SKILL.md resolves to a real file. Dangling sibling links silently break
# skill discovery. Links inside fenced code blocks are skipped.
for d in "${skill_dirs[@]}"; do
	f="$d/SKILL.md"
	# Use awk to strip fenced code blocks, then grep for relative markdown links
	while IFS= read -r link; do
		[[ -z "$link" ]] && continue
		resolved="$(realpath -m --relative-to=. "${d}/${link}" 2>/dev/null)"
		if [[ -n "$resolved" && ! -e "$resolved" ]]; then
			echo "FAIL ${d#./}: dangling reference '$link' -> '$resolved'"
			failed=1
		fi
	done < <(
		awk 'BEGIN{f=0} /```/{f=!f; next} !f' "$f" |
			grep -oE '\]\((\.+/[^)]+)\)' |
			sed -E 's/^\]\(//; s/\)$//'
	)
done

# --- Feedback-loop staleness ----------------------------------------------------
# docs/feedback/new/ holds unprocessed feedback (AGENTS.md §11). It should move
# to processed/ once converted into a skill. Stale files there mean the feedback
# loop is broken again. Warn on any present; fail if older than 30 days.
if [[ -d docs/feedback/new ]]; then
	while IFS= read -r -d '' fb; do
		[[ -z "$fb" ]] && continue
		age=$((($(date +%s) - $(stat -c %Y "$fb")) / 86400))
		if [[ "$age" -ge 30 ]]; then
			echo "FAIL: unprocessed feedback older than 30 days: ${fb#./} (${age}d) — convert to a skill or move to processed/ (AGENTS.md §11)"
			failed=1
		else
			echo "WARN: unprocessed feedback in docs/feedback/new/: ${fb#./} (${age}d)"
		fi
	done < <(find docs/feedback/new -type f -name '*.md' -print0 2>/dev/null)
fi

# --- Cross-skill handoff guard --------------------------------------------------
# Assert that known cross-skill handoff links exist (regression guard). A
# handoff is the contract that skill A's output feeds skill B. If the link is
# removed, the loop reopens (see AGENTS.md §5.5). Entries are "file|needle".
# If a handoff is intentionally removed/renamed, update this list — do not
# silence the guard by deleting it.
handoffs=(
	"status-report/SKILL.md|HARVEST"
	"docs-health/SKILL.md|## HARVEST — pull forward"
	"full-code-review/SKILL.md|HARVEST"
	"architecture-review/SKILL.md|HARVEST"
	"pareto-planning/SKILL.md|HARVEST"
	"verify-external-claims/SKILL.md|verify-before-filing"
	"verify-before-filing/SKILL.md|verify-external-claims"
)
for h in "${handoffs[@]}"; do
	file="${h%%|*}"
	needle="${h##*|}"
	if [[ -f "$file" ]] && ! grep -qF "$needle" "$file"; then
		echo "FAIL: cross-skill handoff guard — '$file' no longer contains '$needle' (intentional? update the guard list in $0)"
		failed=1
	fi
done

if [[ "$failed" -ne 0 ]]; then
	echo
	echo "FAIL: one or more skill checks failed." >&2
	exit 1
fi

echo "OK: all ${#skill_dirs[@]} skills pass structural checks."
