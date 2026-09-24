#!/usr/bin/env bash
# run-eval.sh — reproducible single-eval harness for skill evals.
#
# WHY THIS EXISTS
#   Skill evals ran as throwaway sessions twice (go-release 79%->95%,
#   website-launch 35%->100%) before this script existed: prompts lived in
#   chat history, fixtures in /tmp, outputs in whatever file the session
#   remembered to save. This makes an eval a one-command, re-runnable
#   operation: prompt + fixture are versioned next to the skill, every run
#   lands in a timestamped runs/ dir with its metadata, and old-vs-new
#   comparisons diff two run dirs.
#
# Usage:
#   scripts/run-eval.sh <eval-dir>            # run one eval
#     <eval-dir>/prompt.txt                   # required: the user prompt
#     <eval-dir>/fixture/                     # optional: copied to a fresh temp
#                                             # dir as the session's cwd (a
#                                             # fictional repo)
#   Output: <eval-dir>/runs/<UTC-timestamp>/{output.md,meta.json}
#
# Requirements: `crush` on PATH. The session runs non-interactively with
# --yolo inside the throwaway cwd — never point --cwd at a real repo.

set -euo pipefail

usage() {
	echo "Usage: $0 <eval-dir> [--cwd DIR]" >&2
	exit 2
}

eval_dir="${1:-}"
[[ -d "$eval_dir" ]] || usage
prompt_file="$eval_dir/prompt.txt"
[[ -f "$prompt_file" ]] || { echo "error: $prompt_file missing" >&2; exit 2; }
command -v crush > /dev/null 2>&1 || { echo "error: crush not on PATH" >&2; exit 2; }

shift || true
cwd_override=""
while [[ $# -gt 0 ]]; do
	case "$1" in
	--cwd)
		[[ $# -ge 2 ]] || usage
		cwd_override="$2"
		shift 2
		;;
	*) usage ;;
	esac
done

workdir=""
cleanup() {
	if [[ -n "$workdir" && -d "$workdir" && "$workdir" == "${TMPDIR:-/tmp}"/* ]]; then
		trash "$workdir" 2> /dev/null || rm -rf "$workdir"
	fi
}
trap cleanup EXIT

if [[ -n "$cwd_override" ]]; then
	workdir="$(cd "$cwd_override" && pwd)"
else
	workdir="$(mktemp -d)"
	if [[ -d "$eval_dir/fixture" ]]; then
		cp -r "$eval_dir/fixture/." "$workdir/"
	fi
fi

ts="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
run_dir="$eval_dir/runs/$ts"
mkdir -p "$run_dir"

prompt="$(cat "$prompt_file")"
model="$(crush stats 2> /dev/null | grep -oE 'model:[[:space:]]*[^ ]+' | head -1 || true)"

echo "eval:    $eval_dir"
echo "cwd:     $workdir"
echo "run dir: $run_dir"
echo "prompt:  $prompt"
echo

start=$(date +%s)
set +e
(
	cd "$workdir"
	crush run --yolo "$prompt"
) > "$run_dir/output.md" 2> "$run_dir/stderr.log"
exit_code=$?
set -e
end=$(date +%s)

python3 - "$run_dir" "$exit_code" "$((end - start))" "$workdir" "$prompt" "${model#model:}" <<'EOF'
import json, sys, datetime
run_dir, code, secs, cwd, prompt, model = sys.argv[1:7]
meta = {
    "timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "eval_dir": run_dir.split("/runs/")[0],
    "prompt": prompt,
    "cwd": cwd,
    "model": model.strip() or "unknown",
    "exit_code": int(code),
    "duration_seconds": int(secs),
    "harness": "crush run --yolo (fresh non-interactive session)",
}
with open(f"{run_dir}/meta.json", "w") as f:
    json.dump(meta, f, indent=2)
EOF

echo
echo "exit:    $exit_code (${0##*/}: $((end - start))s)"
echo "saved:   $run_dir/output.md"
[[ $exit_code -eq 0 ]] || {
	echo "note: non-zero session exit — see $run_dir/stderr.log" >&2
}
