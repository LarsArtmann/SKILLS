#!/usr/bin/env bash
#
# check-agents-md.sh — Score AGENTS.md files against the quality rubric.
#
# WHY THIS EXISTS
#   AGENTS.md files across project ecosystems accumulate temporal pollution,
#   content misplacement, and structural decay. This script packages the grep
#   patterns from docs-health/references/agents-quality-guide.md into a
#   standalone scorer so any project can check its AGENTS.md without loading
#   the full skill into context.
#
# WHAT IT CHECKS (mapped to the 5-tier anti-pattern catalog)
#   1. Size budget — flags files over 30 KB (bloated) or under 1 KB (skeleton)
#   2. Content misplacement — changelog entries, TODO refs, phase markers,
#      completion percentages
#   3. Temporal pollution — dated headings, sprint numbers, commit hashes,
#      "as of v..." qualifiers, "was X, now Y" narratives
#   4. Structural decay — bullet walls (100+ consecutive), missing "What This
#      Is" / "Commands" sections, gotcha tables > 20 rows
#
# USAGE
#   scripts/check-agents-md.sh                    # check ./AGENTS.md
#   scripts/check-agents-md.sh /path/to/project   # check that project's AGENTS.md
#   scripts/check-agents-md.sh /parent            # scan recursively for AGENTS.md

set -euo pipefail

target="${1:-.}"

# Collect AGENTS.md files
mapfile -t files < <(
	if [[ -f "$target/AGENTS.md" ]]; then
		echo "$target/AGENTS.md"
	elif [[ -f "$target" && "$(basename "$target")" == "AGENTS.md" ]]; then
		echo "$target"
	elif [[ -d "$target" ]]; then
		find "$target" -name AGENTS.md -type f -not -path "*/.git/*" -not -path "*/node_modules/*" | sort
	else
		echo ""
	fi
)

if [[ ${#files[@]} -eq 0 ]] || [[ -z "${files[0]}" ]]; then
	echo "No AGENTS.md found under $target"
	exit 0
fi

total_issues=0
total_fail=0

for f in "${files[@]}"; do
	issues=0
	size_kb=$(du -k "$f" | cut -f1)
	size_bytes=$(wc -c <"$f")
	lines=$(wc -l <"$f")

	echo "=== $(realpath --relative-to=. "$f" 2>/dev/null || echo "$f") ==="
	echo "  Size: ${size_kb} KB (${lines} lines)"

	# --- Size budget ---
	if [[ "$size_bytes" -gt 102400 ]]; then
		echo "  FAIL: > 100 KB — this is no longer AGENTS.md, it is an archive"
		total_fail=$((total_fail + 1))
	elif [[ "$size_bytes" -gt 51200 ]]; then
		echo "  WARN: > 50 KB — severely bloated, major rewrite needed"
		issues=$((issues + 1))
	elif [[ "$size_bytes" -gt 30720 ]]; then
		echo "  WARN: > 30 KB — bloated, likely contains temporal pollution or code dumps"
		issues=$((issues + 1))
	elif [[ "$size_bytes" -lt 1024 ]]; then
		echo "  WARN: < 1 KB — skeleton, too thin to be useful"
		issues=$((issues + 1))
	fi

	# Helper: count matches outside code blocks
	count_pattern() {
		local pattern="$1"
		# Strip fenced code blocks, then count pattern matches
		local n
		n=$(awk '/^```/{f=!f; next} !f' "$f" | grep -cE "$pattern" 2>/dev/null || true)
		echo "${n:-0}"
	}

	# --- Tier 1: Content misplacement ---
	changelog_hits=$(count_pattern '(bumped from v|version bump|released v[0-9]|shipped in v[0-9])')
	if [[ "$changelog_hits" -gt 0 ]]; then
		echo "  WARN: $changelog_hits changelog-style entries (belongs in CHANGELOG.md)"
		issues=$((issues + 1))
	fi

	todo_refs=$(count_pattern 'TODO #[0-9]')
	if [[ "$todo_refs" -gt 0 ]]; then
		echo "  WARN: $todo_refs TODO references (belongs in TODO_LIST.md)"
		issues=$((issues + 1))
	fi

	phase_markers=$(count_pattern '(Phase [0-9]+ complete|Phase [0-9]+ in progress)')
	if [[ "$phase_markers" -gt 0 ]]; then
		echo "  WARN: $phase_markers phase/progress markers (temporal, will rot)"
		issues=$((issues + 1))
	fi

	completion_pct=$(count_pattern '~?[0-9]+% (complete|done|implemented)')
	if [[ "$completion_pct" -gt 0 ]]; then
		echo "  WARN: $completion_pct completion percentages (temporal, will rot)"
		issues=$((issues + 1))
	fi

	# --- Tier 2: Temporal pollution ---
	dated_headings=$(count_pattern '^#+\s+.*\((v[0-9]|added [0-9]{4}|[0-9]{4}-[0-9]{2}-[0-9]{2})\)')
	if [[ "$dated_headings" -gt 0 ]]; then
		echo "  WARN: $dated_headings dated/versioned section headings (will rot)"
		issues=$((issues + 1))
	fi

	sprint_refs=$(count_pattern '(Sprint [0-9]+|session [0-9]+)')
	if [[ "$sprint_refs" -gt 0 ]]; then
		echo "  WARN: $sprint_refs sprint/session number references (will rot)"
		issues=$((issues + 1))
	fi

	commit_hashes=$(count_pattern '\b[0-9a-f]{7,40}\b' | head -1)
	if [[ "$commit_hashes" -gt 5 ]]; then
		echo "  WARN: $commit_hashes inline commit-hash-like strings (temporal pollution)"
		issues=$((issues + 1))
	fi

	as_of_refs=$(count_pattern 'As of v[0-9]')
	if [[ "$as_of_refs" -gt 0 ]]; then
		echo "  WARN: $as_of_refs 'As of v...' qualifiers (state the CURRENT truth, remove the qualifier)"
		issues=$((issues + 1))
	fi

	was_now_refs=$(count_pattern '(was .*,? now |previously .*,? now |formerly |renamed from .*)')
	if [[ "$was_now_refs" -gt 0 ]]; then
		echo "  WARN: $was_now_refs 'was X, now Y' narratives (state the CURRENT truth)"
		issues=$((issues + 1))
	fi

	# --- Tier 4: Structural decay ---
	has_what_this_is=$(grep -ciE '^#+\s.*(what this is|about|overview|project (type|overview))' "$f" || echo 0)
	if [[ "$has_what_this_is" -eq 0 ]]; then
		echo "  WARN: no 'What This Is' / 'About' / 'Overview' section — agent has no entry context"
		issues=$((issues + 1))
	fi

	has_commands=$(grep -ciE '^#+\s.*(command|build|test|lint|flake|justfile|make)' "$f" || echo 0)
	if [[ "$has_commands" -eq 0 ]]; then
		echo "  WARN: no 'Commands' / 'Build' / 'Test' section — agent has no build/test instructions"
		issues=$((issues + 1))
	fi

	# Check for bullet walls (100+ consecutive bullet lines)
	max_bullet_run=$(awk '
		/^```/{f=!f; next}
		!f && /^\s*[-*]\s/{run++; if(run>max) max=run; next}
		{run=0}
		END{print max+0}
	' "$f")
	if [[ "$max_bullet_run" -gt 100 ]]; then
		echo "  WARN: longest bullet run is $max_bullet_run lines (split into themed subsections if > 30)"
		issues=$((issues + 1))
	fi

	# Check gotcha table size (rows in a table under a gotcha heading)
	gotcha_rows=$(awk '
		/^```/{f=!f; next}
		!f && /^#+.*[Gg]otcha/{in_gotcha=1; rows=0; next}
		!f && /^#+/{if(in_gotcha && rows>20) print rows; in_gotcha=0; next}
		!f && in_gotcha && /^\|/{rows++}
		END{if(in_gotcha && rows>20) print rows}
	' "$f")
	if [[ -n "$gotcha_rows" ]]; then
		echo "  WARN: gotcha table has $gotcha_rows rows (max 15-20 recommended)"
		issues=$((issues + 1))
	fi

	# --- Summary ---
	if [[ "$issues" -eq 0 ]]; then
		echo "  OK: no anti-patterns detected"
	else
		echo "  RESULT: $issues issue(s) found"
		total_issues=$((total_issues + issues))
	fi
	echo
done

if [[ "$total_fail" -ne 0 ]]; then
	echo "FAIL: $total_fail broken AGENTS.md file(s) (> 100 KB)"
	exit 1
fi

if [[ "$total_issues" -gt 0 ]]; then
	echo "WARN: $total_issues advisory issue(s) across ${#files[@]} AGENTS.md file(s) — review recommended"
fi
echo "OK: all ${#files[@]} AGENTS.md file(s) scanned."
