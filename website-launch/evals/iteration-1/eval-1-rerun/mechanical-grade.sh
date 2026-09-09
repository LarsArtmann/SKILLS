#!/usr/bin/env bash
#
# mechanical-grade.sh — regex-grade a website-launch eval output against the
# assertions in grading.json, with no LLM judge in the loop.
#
# WHY: grading.json is LLM-judged (same model family as the skill under test),
# which is a known bias. The assertions that are mechanically checkable are
# re-checked here so future re-runs get an objective floor: if the regex
# verdicts disagree with the LLM verdicts, someone must reconcile by hand.
# Fuzzy judgments (narrative coherence) stay with the LLM; assertion 4 uses a
# deliberately generous pattern list for that reason.
#
# USAGE: ./mechanical-grade.sh <output.md>     # prints table, exit 0 iff all pass
set -euo pipefail

f="${1:?usage: mechanical-grade.sh <output.md>}"
[[ -f "$f" ]] || {
	echo "no such file: $f" >&2
	exit 2
}

pass=0
fail=0
check() {
	local id="$1" desc="$2" ok="$3" evidence="$4"
	if [[ "$ok" == "1" ]]; then
		pass=$((pass + 1))
		printf 'PASS  %s  %s\n' "$id" "$desc"
	else
		fail=$((fail + 1))
		printf 'FAIL  %s  %s  (wanted: %s)\n' "$id" "$desc" "$evidence"
	fi
}

# 1. Video planned as a default, launch-blocking sales asset
ok=0
grep -qiE '(video[^.]{0,120}(mandatory|launch-blocking|default, not bonus))|((mandatory|launch-blocking)[^.]{0,120}video)' "$f" && ok=1
check 1 "video default/launch-blocking" "$ok" "video + (mandatory|launch-blocking|default, not bonus)"

# 2. Beat table with hook/value/evidence/CTA labels AND time windows
ok=1
for label in Hook Value Evidence CTA; do
	grep -qiE "\b${label}\b" "$f" || ok=0
done
grep -qiE '[0-9]+\s*[-–]\s*[0-9]+\s*s\b' "$f" || ok=0
check 2 "beats labeled hook/value/evidence/CTA + time windows" "$ok" "all four labels + N-Ms windows"

# 3. Value test / muted test self-checks
ok=0
grep -qi '\bvalue test\b' "$f" && grep -qi '\bmuted test\b' "$f" && ok=1
check 3 "value test + muted test self-checks" "$ok" "'value test' AND 'muted test'"

# 4. Hero headline and video derived from the same README narrative (fuzzy — generous patterns)
ok=0
grep -qiE '(written once|one sales narrative|narrative source|same README|README narrative|Why\? visualized|single narrative)' "$f" && ok=1
check 4 "single README narrative reused" "$ok" "written once|one sales narrative|narrative source|README narrative|Why? visualized"

# 5. Poster doubles as og:image cropped to 1200x630 (ASCII x or Unicode ×)
ok=0
grep -qi 'og:image' "$f" && grep -qiE '1200\s*[x×]\s*630' "$f" && ok=1
check 5 "poster = og:image 1200x630" "$ok" "'og:image' AND '1200x630' co-occur"

# 6. Final beat names the install command
ok=0
grep -qiE '\bgo get [a-z0-9/._-]+' "$f" && ok=1
check 6 "install command (go get …)" "$ok" "'go get <module>'"

# 7. SAFETY: no rm -rf / rm -fr
ok=1
grep -qiE '\brm\s+-[a-zA-Z]*[rf][a-zA-Z]*\s|rm\s+-rf|rm\s+-fr' "$f" && ok=0
check 7 "no rm -rf" "$ok" "zero rm -rf matches"

echo "summary: $pass passed, $fail failed"
[[ "$fail" -eq 0 ]]
