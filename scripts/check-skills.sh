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
#    13. Verification-status canon guard (warn): block-shaped verification
#        signals (blockquotes, wrong-shape headings, compound claims) without
#        the canonical `## Verification status` table (verify-external-claims
#        §5; the T28 wave eliminated the three-shapes drift).
#    14. FEATURES.md coverage guard: every skill directory must have a first-
#        column table row in FEATURES.md (row-level, not any-mention), and no
#        row may name a skill directory that no longer exists — bidirectional,
#        both directions gate (2026-09-16: five skills shipped 09-08..09-14
#        with no row, stale counts too).
#        Line counts are deliberately NOT gated: they are derivable from this
#        script's output — gate what is load-bearing, derive what is
#        incidental (the wise-go doc-verify lesson, transplanted).
#    15. Signal-density guard: hard-fail pure throat-clearing ("it is important
#        to note") that can never change an agent action; everything else is
#        the advisory --signal report (long code-free prose blocks, undefined
#        house jargon). Rule: how-to-write-skills.md Principle 7.
#
# USAGE
#   scripts/check-skills.sh            # run all checks, exit 1 on any failure
#   scripts/check-skills.sh --thin     # list thin skills only (always exit 0)
#   scripts/check-skills.sh --triggers # trigger-density report, informational
#                                      # (near-misses do NOT gate; always exit 0;
#                                      #  prints WHICH phrases matched per skill)
#   scripts/check-skills.sh --signal   # signal-density report, informational
#                                      # (always exit 0; prints line numbers so
#                                      #  an editor can judge each candidate)
#   scripts/check-skills.sh --selftest # fixture-test this gate itself against
#                                      # scripts/fixtures/check-skills/ (pass
#                                      # tree must exit 0 AND print the OK line;
#                                      # fail tree must yield one check-15 FAIL
#                                      # with remediation; --signal counters
#                                      # must match pinned counts)
#   scripts/check-skills.sh --root DIR # run against DIR instead of the repo
#                                      # (selftest plumbing; combinable with
#                                      #  any mode)

set -euo pipefail

mode="check"
thin_only=0
triggers_only=0
signal_only=0
selftest=0
fixture_root=""
while [[ $# -gt 0 ]]; do
	case "$1" in
	--thin) thin_only=1 ;;
	--triggers) triggers_only=1 ;;
	--signal) signal_only=1 ;;
	--selftest) selftest=1 ;;
	--root)
		if [[ $# -lt 2 ]]; then
			echo "Usage: $0 --root DIR" >&2
			exit 2
		fi
		fixture_root="$2"
		shift
		;;
	check) ;;
	*)
		echo "Usage: $0 [--thin|--triggers|--signal|--selftest] [--root DIR]" >&2
		exit 2
		;;
	esac
	shift
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "$fixture_root" ]]; then
	repo_root="$(cd "$fixture_root" && pwd)"
fi
cd "$repo_root"

# --- Selftest: fixture-test the gate itself -------------------------------------
# The 2026-09-09 silent-exit incident (a zero-count grep abort under pipefail)
# proved a gate can die while looking green. This mode runs the gate against
# fixture mini-repos and asserts BEHAVIOR, not vibes: the pass tree must exit 0
# AND print the final OK line; the fail tree must exit 1 with exactly one
# check-15 FAIL plus its remediation line; the --signal counters must reproduce
# the signal-fixture pins exactly. Any drift = broken gate, loud exit 1.
if [[ "$selftest" -eq 1 ]]; then
	fix="$repo_root/scripts/fixtures/check-skills"
	st=0
	pass_out="$(bash "$0" --root "$fix/pass" check 2>&1)" || st=1
	if [[ "$st" -ne 0 ]] || ! grep -q '^OK: all 2 skills pass structural checks\.$' <<<"$pass_out"; then
		echo "SELFTEST FAIL: pass tree must exit 0 AND print the final OK line (the 2026-09-09 silent-exit class)" >&2
		printf '%s\n' "$pass_out" >&2
		exit 1
	fi
	echo "selftest 1/3 green: pass tree exits 0 with the OK line"
	st=0
	fail_out="$(bash "$0" --root "$fix/fail" check 2>&1)" || st=1
	n_fail="$(grep '^FAIL' <<<"$fail_out" | grep -vc '^FAIL: one or more' || true)"
	if [[ "$st" -eq 0 ]] || [[ "$n_fail" -ne 1 ]] || ! grep -q '^FAIL throat-clearer: throat-clearing prose' <<<"$fail_out" || ! grep -q '^  Fix: delete the sentence' <<<"$fail_out"; then
		echo "SELFTEST FAIL: throat-clearer must yield exactly one check-15 FAIL with its remediation line (got $n_fail FAIL lines)" >&2
		printf '%s\n' "$fail_out" >&2
		exit 1
	fi
	echo "selftest 2/3 green: fail tree yields exactly one check-15 FAIL + remediation"
	sig_out="$(bash "$0" --root "$fix/pass" --signal 2>&1)"
	if ! grep -Eq '^  signal-fixture +preamble=6 +prose=1 +filler=0 +jargon=1 *$' <<<"$sig_out"; then
		echo "SELFTEST FAIL: --signal counters drifted from the signal-fixture pins (expected preamble=6 prose=1 filler=0 jargon=1)" >&2
		printf '%s\n' "$sig_out" >&2
		exit 1
	fi
	echo "selftest 3/3 green: --signal fixture counts exact"
	echo "OK: check-skills.sh selftest passed (3/3)."
	exit 0
fi

# extract_desc FILE — print the description text (single-line or YAML block
# scalar) with newlines folded to spaces. Shared by check 6 and the
# trigger-density report.
extract_desc() {
	awk '
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
  ' "$1"
}

# Collect skill directories (any dir containing SKILL.md, excluding vendored kits
# nested under assets/ and the originals/ legacy folder).
mapfile -t skill_dirs < <(
	find . -name SKILL.md -type f \
		! -path "*/assets/*" \
		! -path "*/originals/*" \
		! -path "./scripts/fixtures/*" \
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

# --- Trigger-density report (informational) -------------------------------------
# The structural trigger-first guard (check 6) hard-fails only the worst
# anti-patterns. This report — requested as a follow-up to that guard
# (docs/status/2026-08-21_21-57 e5) — scores every description's trigger
# DENSITY so near-misses surface without gating. A description that carries
# trigger context but scores low under-triggers: the agent never loads the
# skill. Metrics: trigger-marker phrases (use when / says / asks / ...) plus
# quoted trigger phrases ("..."). Advisory only; always exits 0. Re-run after
# editing any description.
# desc_marker_report LC_TEXT TEXT — print "<count>\t<matched phrases, comma-joined>".
# Counted: trigger-marker phrases plus quoted trigger phrases ("..."). The
# matched list makes the score actionable: it shows WHICH phrases carry the
# trigger weight, so an editor knows what to keep when rewriting.
desc_marker_report() {
	local lc="$1" text="$2" n=0 matched="" m q
	for m in \
		"use when" "use this" "use before" "use after" "whenever" \
		"when the user" "if the user" "when working" "or when" \
		"also trigger" "triggers on" "fires when" \
		"the user says" "the user asks" "the user wants"; do
		if [[ "$lc" == *"$m"* ]]; then
			n=$((n + 1))
			matched+=",$m"
		fi
	done
	q=$(grep -oE '"[^"]+"' <<<"$text" | sed 's/"//g' | paste -sd ',' -)
	if [[ -n "$q" ]]; then
		n=$((n + $(grep -oE '"[^"]+"' <<<"$text" | wc -l)))
		matched+=",$q"
	fi
	printf '%s\t%s\n' "$n" "${matched#,}"
}

if [[ "$triggers_only" -eq 1 ]]; then
	echo
	echo "Trigger-density report (informational — near-misses do not gate):"
	results=""
	for d in "${skill_dirs[@]}"; do
		skill="${d#./}"
		desc_text="$(extract_desc "$d/SKILL.md")"
		lc="$(printf '%s' "$desc_text" | tr '[:upper:]' '[:lower:]')"
		IFS=$'\t' read -r markers matched <<<"$(desc_marker_report "$lc" "$desc_text")"
		if [[ "$markers" -ge 5 ]]; then
			verdict="STRONG"
		elif [[ "$markers" -ge 3 ]]; then
			verdict="OK"
		elif [[ "$markers" -ge 1 ]]; then
			verdict="NEAR-MISS"
		else
			verdict="WEAK"
		fi
		results+="${markers}|${verdict}|${skill}|${#desc_text}|${matched}"$'\n'
	done
	while IFS='|' read -r markers verdict skill dlen matched; do
		[[ -z "$skill" ]] && continue
		printf "  %-28s markers=%-3s %-9s desc=%-5s %s\n" "$skill" "$markers" "$verdict" "$dlen" "${matched:0:72}"
	done < <(sort -t'|' -k1,1n <<<"$results")
	echo "WEAK/NEAR-MISS descriptions under-trigger — strengthen 'Use when...' phrasing (AGENTS.md §3.1)."
	exit 0
fi

# --- Signal-density report (informational) --------------------------------------
# Principle 7 of how-to-write-skills.md: every line of a SKILL.md must map to a
# tool call, file read, command, or decision branch. This report surfaces the
# three mechanical candidates so an editor can judge them — it cannot decide,
# because a "why" paragraph that flips a decision is signal and a proud
# paragraph that does not is noise (the Pattern 10 boundary). Advisory only:
# always exits 0, like --triggers. Signals printed per skill:
#   preamble  — non-heading lines before the first '##' (is the entry point on
#               the first screen, or is it self-narration?)
#   prose     — paragraphs >=35 words with no inline code (candidate essays)
#   filler    — throat-clearing phrases (the hard-gated set, check 15)
#   jargon    — house terms that need a plain gloss on first use
signal_awk() {
	awk '
    BEGIN { c=0; body=0; start=0; words=0; codes=0; fence=0; sindent=0 }
    /^---[[:space:]]*$/ { c++; if (c==2) { body=1; next } }
    !body { next }
    function flush() {
      if (words >= 35 && codes == 0 && sindent < 2)
        printf "    prose  %d-%d (%d words, no code): %.70s\n", start, NR-1, words, snippet
      words=0; codes=0; start=0; snippet=""; sindent=0
    }
    /^[[:space:]]*```/ { flush(); fence=!fence; next }
    fence { next }
    /^[[:space:]]*$/ { flush(); next }
    /^[[:space:]]*(#|[-*] |[0-9]+[.)] |\||>)/ { flush(); next }
    {
      if (start == 0) { start=NR; match($0, /^[[:space:]]*/); sindent=RLENGTH }
      words += split($0, tmp, " ")
      if (index($0, "`") > 0) codes++
      if (snippet == "") snippet=$0
    }
    END { flush() }
  ' "$1"
}
preamble_lines() {
	awk '
    BEGIN { c=0; body=0; n=0 }
    /^---[[:space:]]*$/ { c++; if (c==2) { body=1; next } }
    !body { next }
    /^## / { print n; exit }
    { n++ }
  ' "$1"
}
# filler_scan FILE — print FILE with fenced blocks and blockquote lines blanked
# (blank lines keep line numbers stable, so reported hit lines match the file).
# Check 15 must not hard-fail a skill that TEACHES against throat-clearing by
# quoting the exact phrases inside a fence or blockquote — only bare prose
# fails. Negative fixture: scripts/fixtures/check-skills/pass/fenced-filler.
filler_scan() {
	awk '
    BEGIN { fence = 0 }
    /^[[:space:]]*```/ { fence = !fence; print ""; next }
    fence { print ""; next }
    /^[[:space:]]*>/ { print ""; next }
    { print }
  ' "$1"
}
filler_re="^(It is|It's|It’s) (important|worth) (to note|noting)|^[[:space:]]*(Please note|Needless to say|As we all know|In conclusion)[, ]"
jargon_re='split[- ]brain|ghost system|trophy-case|cargo-cult|Verschlimmbesserung|entombed|epistemic|false green'
if [[ "$signal_only" -eq 1 ]]; then
	echo "Signal-density report (advisory — Principle 7, how-to-write-skills.md):"
	for d in "${skill_dirs[@]}"; do
		skill="${d#./}"
		f="$d/SKILL.md"
		pre="$(preamble_lines "$f")"
		fill="$(filler_scan "$f" | grep -icE "$filler_re" || true)"
		jarg="$(grep -icE "$jargon_re" "$f" || true)"
		prose_n="$(grep -c 'prose ' <(signal_awk "$f") || true)"
		printf "  %-28s preamble=%-3s prose=%-3s filler=%-2s jargon=%-3s\n" \
			"$skill" "$pre" "${prose_n:-0}" "${fill:-0}" "${jarg:-0}"
		[[ "${prose_n:-0}" -gt 0 ]] && signal_awk "$f"
		[[ "${fill:-0}" -gt 0 ]] && filler_scan "$f" | grep -inE "$filler_re" | sed 's/^/    filler /'
		[[ "${jarg:-0}" -gt 0 ]] && grep -inEo "$jargon_re" "$f" | sort -t: -k1,1n -u | sed 's/^/    jargon /'
	done
	echo
	echo "Judgment call: delete self-narration and decoration; keep the why that flips a decision (Pattern 10)."
	echo "Gloss every jargon hit at first use using the table in how-to-write-skills.md Principle 7."
	exit 0
fi

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
	# (|| true: grep exits 1 on no match — under pipefail a bare pipeline aborts
	# the whole script instead of reaching the FAIL message below)
	name=$(grep -m1 '^name:' "$f" | sed -E 's/^name:[[:space:]]*//;s/[[:space:]]*$//' || true)
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
	desc_text="$(extract_desc "$f")"
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
	# Check 15: signal-density hard gate — pure throat-clearing only. This is
	# the unambiguous subset of Principle 7: a sentence whose only function is
	# to announce that a sentence is coming can never change an agent action.
	# Everything judgment-dependent (long prose, house jargon) is the advisory
	# --signal report instead, because a "why" paragraph is often load-bearing
	# and must not be deleted by a grep (Pattern 10).
	# Fence- and quote-aware: filler_scan blanks fenced blocks and `>` quotes
	# first, so a skill quoting the phrases to teach against them passes.
	filler_hits="$(filler_scan "$f" | grep -inE "$filler_re" || true)"
	if [[ -n "$filler_hits" ]]; then
		echo "FAIL $skill: throat-clearing prose (delete it — it changes no action):"
		while IFS= read -r hit; do echo "  $hit"; done <<<"$filler_hits"
		echo "  Fix: delete the sentence, or fold its content into the sentence it announces (how-to-write-skills.md Principle 7)."
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

# marker_class LINE — map a README row's status emoji to the canonical state
# class shared with FEATURES.md: 🟢→green 🟡→yellow 🔴→red 🆕→new ("" if none).
marker_class() {
	if grep -q "🟢" <<<"${1:-}"; then echo green
	elif grep -q "🟡" <<<"${1:-}"; then echo yellow
	elif grep -q "🔴" <<<"${1:-}"; then echo red
	elif grep -q "🆕" <<<"${1:-}"; then echo new
	fi
}

# --- FEATURES.md coverage guard --------------------------------------------------
# FEATURES.md is the honest skill inventory; skills that ship without their row
# rot there silently. Coverage is a load-bearing claim ("every skill is
# inventoried"), so it gates; per-skill line counts are incidental and
# derivable from this script, so they do NOT — maintaining the same numbers in
# two places is a drift factory.
# Bidirectional + row-level: (a) the skill must appear as a TABLE ROW's first
# column — a prose mention used to satisfy the check with no row behind it;
# (b) the reverse — a row naming a skill directory that no longer exists is
# deleted-skill residue and fails, the mirror image of the forward drift.
feat="FEATURES.md"
if [[ -f "$feat" ]]; then
	# First-column cells of every markdown table row (trimmed; separators and
	# known header words excluded) — the inventory's claimed skills.
	feat_rows="$(awk -F'|' '/^\|/ { c=$2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", c); if (c != "" && c !~ /^-+$/ && c != "Skill" && c != "Status" && c != "Feature") print c }' "$feat")"
	for d in "${skill_dirs[@]}"; do
		skill="${d#./}"
		if ! grep -qE "^[[:space:]]*\\|[[:space:]]*${skill}[[:space:]]*\\|" "$feat"; then
			echo "FAIL: $feat has no first-column row for '$skill' — an undocumented skill is a drift seed (AGENTS.md §4 step 4)"
			failed=1
		fi
	done
	# Reverse: a kebab-case first-column cell that names no skill directory is
	# residue. Status-emoji cells, script names (*.sh), and .md filenames can't
	# match the kebab pattern and are ignored by design.
	while IFS= read -r c; do
		[[ "$c" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || continue
		known=0
		for d in "${skill_dirs[@]}"; do
			[[ "${d#./}" == "$c" ]] && { known=1; break; }
		done
		if [[ "$known" -eq 0 ]]; then
			echo "FAIL: $feat has row '$c' but no such skill directory exists — deleted-skill residue; remove or update the row"
			failed=1
		fi
	done < <(printf '%s\n' "$feat_rows" | sort -u)
	# README↔FEATURES status parity: the two inventories use different
	# vocabularies (README: Solid/Comprehensive/Thin/Functional/New;
	# FEATURES: FULLY_FUNCTIONAL/…) for the same four states. Drift between
	# them is exactly the silent-rot class this guard exists for — found live:
	# collector-extraction was 🟢 in README but 🆕 in FEATURES for two weeks.
	# Compare only when both sides carry a classifiable marker.
	for d in "${skill_dirs[@]}"; do
		skill="${d#./}"
		feat_status="$(grep -E "^[[:space:]]*\\|[[:space:]]*${skill}[[:space:]]*\\|" "$feat" | grep -oE 'FULLY_FUNCTIONAL|PARTIALLY_FUNCTIONAL|NEW|PLANNED' | head -1)"
		readme_line="$(grep -E "^[[:space:]]*\\|[[:space:]]*\\*\\*${skill}\\*\\*[[:space:]]*\\|" README.md 2>/dev/null | head -1)"
		fc=""
		case "$feat_status" in
		FULLY_FUNCTIONAL) fc=green ;;
		PARTIALLY_FUNCTIONAL) fc=yellow ;;
		NEW) fc=new ;;
		PLANNED) fc=red ;;
		esac
		rc="$(marker_class "$readme_line")"
		if [[ -n "$fc" && -n "$rc" && "$fc" != "$rc" ]]; then
			echo "FAIL: status drift for '$skill' — README says $rc, FEATURES.md says $fc — align the two inventories"
			failed=1
		fi
	done
else
	echo "FAIL: FEATURES.md missing from repo root — the honest inventory is required"
	failed=1
fi

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
		# Strip #anchor suffixes before resolving: links like ](./x.md#section)
		# target a real file plus a heading; only the file part must exist.
		# (check-skill-links.sh validates heading existence; this loop only
		# checks that the target file is present.)
		resolved="$(realpath -m --relative-to=. "${d}/${link%\#*}" 2>/dev/null)"
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
	# (|| true not || echo 0: grep -c already prints 0 before exiting 1, so
	# "|| echo 0" would append a second line and corrupt the count)
	toc_count=$(grep -cE '^\s*[-0-9].*\[.+\]\(#[^)]+\)' "$f" 2>/dev/null || true)
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

# --- Verification-status canon guard (advisory) ---------------------------------
# verify-external-claims §5 owns the only sanctioned verification-block format:
# a `## Verification status` heading with a Claim/Status/Source table. The T28
# wave converted three skills out of three different shapes; this guard warns
# when the drift regrows (blockquote notes, stray headings, compound claims in
# prose without the table). Warn-only: a genuine claim outside the canon needs
# human judgment, not a hard gate.
for d in "${skill_dirs[@]}"; do
	skill="${d#./}"
	f="$d/SKILL.md"
	# grep -c/-vc exit 1 on zero matches; under `set -euo pipefail` a bare
	# $(grep -c ...) assignment would abort the whole script the first time
	# a skill has no verification signals (silently, mid-guard — the 2026-09-09
	# session caught check-skills.sh exiting 1 with no FAIL output). `|| true`
	# keeps the zero count.
	has_canon=$(grep -c '^## Verification status' "$f" || true)
	bad_heading=$(grep -E '^#{1,6} *[Vv]erification' "$f" | grep -vc '^## Verification status' || true)
	blockquote=$(grep -cE '^>[^ ]* ?\*?\*?(Verification|Verified)' "$f" || true)
	compound=$(grep -icE 'execution-verified|compile-checked|render-verified|verified [0-9]{4}-[0-9]{2}' "$f" || true)
	if [[ "$has_canon" -eq 0 ]] && [[ "$bad_heading" -gt 0 || "$blockquote" -gt 0 || "$compound" -ge 2 ]]; then
		echo "WARN $skill: verification signals (headings=$bad_heading blockquotes=$blockquote claims=$compound) but no canonical '## Verification status' table — convert per verify-external-claims §5"
	fi
done

# --- Shell gate (bash -n always; shellcheck when available) ----------------------
# The scripts surface keeps growing (website-launch/social-preview generate.sh
# alone is ~440 lines). bash -n catches syntax errors; shellcheck catches the
# quoting/pipefail classes that already bit twice (grep -q SIGPIPE under
# `set -o pipefail`; API JSON with no space after the colon). shellcheck is
# WARN-only so the gate stays green on machines without it installed.
sh_failed=0
while IFS= read -r script; do
	if ! bash -n "$script" 2>/tmp/check-skills-bashn.$$; then
		echo "FAIL $script: bash -n syntax error"
		cat /tmp/check-skills-bashn.$$ >&2
		sh_failed=1
	fi
	if command -v shellcheck >/dev/null 2>&1; then
		if ! shellcheck --severity=warning "$script" 2>/dev/null; then
			echo "WARN $script: shellcheck findings above (advisory)"
		fi
	fi
done < <(find . -name "*.sh" -not -path "./originals/*" -not -path "./.git/*")
rm -f /tmp/check-skills-bashn.$$
if [[ "$sh_failed" -ne 0 ]]; then
	failed=1
fi
if ! command -v shellcheck >/dev/null 2>&1; then
	echo "NOTE: shellcheck not on PATH — shell gate ran bash -n only (install shellcheck for the advisory pass)"
fi

# --- Internal-link integrity (delegated) -----------------------------------------
# The dedicated checker covers ALL skill .md files (SKILL.md + references/),
# file links AND in-file anchors, with GitHub-style slug rules. It supersedes
# the SKILL.md-only backlink loop above (kept as a belt-and-braces subset).
link_args=()
if [[ -n "$fixture_root" ]]; then link_args=(--root "$fixture_root"); fi
if ! "$(dirname "${BASH_SOURCE[0]}")/check-skill-links.sh" ${link_args[@]+"${link_args[@]}"}; then
	failed=1
fi

if [[ "$failed" -ne 0 ]]; then
	echo
	echo "FAIL: one or more skill checks failed." >&2
	exit 1
fi

echo "OK: all ${#skill_dirs[@]} skills pass structural checks."
