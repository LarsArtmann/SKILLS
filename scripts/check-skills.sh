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
#     9. TOC-integrity guard: any .md with a Contents section must have every
#        ## heading accounted for in the TOC (AGENTS.md §5.4 thin-skills).
#    10. Marker-vocabulary guard: docs-health ANNOTATE/HARVEST must share the
#        resolution-marker vocabulary (done at, Won't implement, NOT-DO).
#    11. Trigger-first guard: every description must open with trigger
#        context. Hard-fails the pre-2026-08-11 style ("Reviews...",
#        "Generates...") and any opening sentence with no trigger word;
#        warns on valid-but-non-canonical openings (AGENTS.md §3.1).
#    12. Internal-link integrity across ALL skill .md files via the dedicated
#        scripts/check-skill-links.sh (file links + in-file anchors).
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
	# Check 6: trigger-first guard — description must open with trigger context
	# (AGENTS.md §3.1). The 2026-08-11 migration rewrote 18 description-first
	# skills because "Reviews X" describes the skill instead of telling the
	# agent WHEN to use it, and such skills never activate. Strictness (per
	# 08-11 report g2): hard-fail the known 3rd-person-verb anti-pattern and
	# any trigger-less opening; accept-but-warn other phrasings so future
	# valid openings are not blocked. If a new style is adopted on purpose,
	# extend the patterns below — do not silence the guard.
	desc_text=$(awk '
    BEGIN { block=0; done=0; desc="" }
    !done && /^description:[[:space:]]*[>|]/ {
      line=$0; sub(/^description:[[:space:]]*[>|]-?[[:space:]]*/, "", line)
      desc=line; block=1; next
    }
    !done && /^description:/ {
      line=$0; sub(/^description:[[:space:]]*/, "", line)
      sub(/[[:space:]]+$/, "", line)
      desc=line; done=1; next
    }
    block && !done {
      if ($0 !~ /^[[:space:]]/) { done=1; next }
      line=$0; sub(/^[[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (desc != "") desc = desc " " line; else desc = line
    }
    END { print desc }
  ' "$f")
	first_sentence="${desc_text%%.*}"
	first_sentence="${first_sentence#"${first_sentence%%[![:space:]]*}"}"
	[[ ${#first_sentence} -gt 200 ]] && first_sentence="${first_sentence:0:200}"
	anti_re='^(Reviews|Generates|Creates|Implements|Performs|Runs|Triggers|Finds|Launches|Audits|Scans|Builds|Produces|Provides|Converts|Analyzes|Validates|Maintains|Updates|Writes|Migrates|Renames|Refactors|Splits|Merges|Displays|Shows|Lists|Reads|Parses|Fetches|Downloads|Installs|Configures|Helps|Allows|Enables)[[:space:]]'
	if [[ -z "$desc_text" ]]; then
		: # missing description already flagged by check 3
	elif [[ "$desc_text" == "Use "* ]]; then
		: # canonical trigger-first opening (all current skills)
	elif [[ "$first_sentence" =~ $anti_re ]]; then
		echo "FAIL $skill: description opens with a 3rd-person verb ('$first_sentence...') — rewrite to open with trigger context, 'Use when...' (AGENTS.md §3.1)"
		failed=1
	elif [[ ! "$first_sentence" =~ ([Ww]hen|before|after|while|during|whenever|any[[:space:]]time|anytime) ]]; then
		echo "FAIL $skill: description opening has no trigger context (no when/before/after/... in first sentence) — say WHEN the skill applies, not what it is (AGENTS.md §3.1)"
		failed=1
	else
		echo "WARN $skill: description carries trigger context but does not open with the canonical 'Use ...' form — consider aligning (AGENTS.md §3.1)"
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

# --- TOC-integrity guard --------------------------------------------------------
# For any .md file (SKILL.md or references/*.md) that has a "## Contents" or
# "## Table of Contents" section, verify every ## heading outside code blocks
# is accounted for in the TOC. The failure mode: an agent adds a ## heading but
# forgets to update the TOC, silently breaking navigation. This guard catches
# that drift. It checks: headings <= toc_entries (extra TOC entries for ###
# subsections are fine; missing headings from the TOC is a FAIL).
for f in \
	$(find "${skill_dirs[@]}" -name '*.md' -type f \
		-exec grep -liE '^## (Contents|Table of [Cc]ontents)' {} \;); do
	heading_count=$(awk '
		BEGIN { in_code = 0 }
		/^```/ { in_code = !in_code; next }
		!in_code && /^## / {
			line = tolower($0)
			if (line !~ /^## (contents|table of contents)/) c++
		}
		END { print c + 0 }
	' "$f")
	toc_count=$(grep -cE '^\s*[-0-9].*\[.+\]\(#[^)]+\)' "$f" 2>/dev/null || echo 0)
	if [[ "$heading_count" -gt "$toc_count" ]]; then
		echo "FAIL ${f#./}: TOC drift — $heading_count ## headings but only $toc_count TOC entries. Add missing headings to the TOC."
		failed=1
	fi
done

# --- Marker-vocabulary guard ----------------------------------------------------
# docs-health ANNOTATE owns the marker vocabulary (done at, Won't implement,
# NOT-DO/DUPLICATE). HARVEST must reference these markers, not invent rival
# formats (AGENTS.md §5.5 contract). This guard catches silent drift if either
# mode is rewritten.
dh="docs-health/SKILL.md"
if [[ -f "$dh" ]]; then
	for marker in "done at" "Won't implement" "NOT-DO"; do
		if ! grep -qF "$marker" "$dh"; then
			echo "FAIL docs-health: marker '$marker' missing from SKILL.md — ANNOTATE and HARVEST modes MUST share the resolution-marker vocabulary (AGENTS.md §5.5)"
			failed=1
		fi
	done
fi

# --- Internal-link integrity (delegated) -----------------------------------------
# The dedicated checker covers ALL skill .md files (SKILL.md + references/),
# file links AND in-file anchors, with GitHub-style slug rules. It supersedes
# the SKILL.md-only backlink loop above (kept as a belt-and-braces subset).
if ! "$(dirname "${BASH_SOURCE[0]}")/check-skill-links.sh"; then
	failed=1
fi

if [[ "$failed" -ne 0 ]]; then
	echo
	echo "FAIL: one or more skill checks failed." >&2
	exit 1
fi

echo "OK: all ${#skill_dirs[@]} skills pass structural checks."
