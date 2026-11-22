#!/usr/bin/env bash
# run-eval.sh — reproducible skill-eval harness.
#
# WHY THIS EXISTS
#   Skill evals ran as throwaway sessions twice (go-release 79%->95%,
#   website-launch 35%->100%) before this script existed: prompts lived in
#   chat history, fixtures in /tmp, outputs in whatever file the session
#   remembered to save. This makes an eval a one-command, re-runnable
#   operation: prompt + fixture are versioned next to the skill, every run
#   lands in a timestamped runs/ dir with its metadata, and old-vs-new
#   comparisons run BOTH arms inside one invocation (same-turn pairing).
#
# PROTOCOL
#   Multi-run variance, cross-model arms, and independent grading are
#   specified in docs/doctrine-eval-protocol.md — this script is the
#   mechanics, that doc is the bar.
#
# Usage:
#   scripts/run-eval.sh <eval-dir> [options]
#     <eval-dir>/prompt.txt        required: the user prompt
#     <eval-dir>/fixture/          optional: copied to a fresh temp dir per
#                                  arm as the session's cwd (a fictional repo)
#     <eval-dir>/assertions.json   optional: JSON array of assertion strings;
#                                  required by --grade (seed it from a
#                                  catalog with the jq command in the
#                                  protocol doc)
#
#   Options:
#     --skill-dir DIR   Doctrine-eval mode: point the session at an explicit
#                       skill directory (a load instruction is prepended to
#                       the prompt so the skill is READ, not triggered —
#                       use for measuring doctrine, not discovery).
#                       Default: the session's installed skills decide.
#     --old-skill REF   Pair the current skill against its past self:
#                       git-archive the skill directory from git REF into a
#                       temp dir and run a second arm against it. Both arms
#                       run back-to-back in THIS invocation (the same-turn
#                       pairing rule: no human turn between arms that could
#                       bias the second), each in its own fresh fixture copy.
#                       Output: runs/<ts>/{new,old}/. Not combinable with
#                       --cwd.
#     --model ID        Model for the arm(s), passed to `crush run -m` (the
#                       cross-model arm of the protocol).
#     --grade           Seed grading.template.json in every arm dir from
#                       assertions.json — passed=null, evidence="" — for the
#                       grader to fill and save as grading.json.
#
#   Output:
#     single arm:  <eval-dir>/runs/<UTC-timestamp>/{output.md,stderr.log,meta.json}
#     paired:      <eval-dir>/runs/<UTC-timestamp>/{new,old}/{...}
#     with --grade, each arm dir also gets grading.template.json.
#
# Requirements: `crush` on PATH; `jq` for --grade; git repo containing the
# skill dir for --old-skill. Sessions run non-interactively in a throwaway
# cwd — never point --cwd at a real repo.

set -euo pipefail

usage() {
	echo "Usage: $0 <eval-dir> [--skill-dir DIR] [--old-skill GIT-REF] [--model ID] [--grade] [--cwd DIR]" >&2
	exit 2
}

eval_dir="${1:-}"
[[ -d "$eval_dir" ]] || usage
case "$eval_dir" in
-*) usage ;;
esac
# Absolute from here on: this host's jq 1.8.2 resolves file arguments against
# the CHILD-ENV $PWD (the shell's launch dir), not the post-cd cwd — relative
# jq paths break under any cd. Absolute paths are immune.
eval_dir="$(cd "$eval_dir" && pwd)"
prompt_file="$eval_dir/prompt.txt"
[[ -f "$prompt_file" ]] || {
	echo "error: $prompt_file missing" >&2
	exit 2
}
command -v crush >/dev/null 2>&1 || {
	echo "error: crush not on PATH" >&2
	exit 2
}

shift || true
skill_dir=""
old_skill_ref=""
model=""
want_grade=false
cwd_override=""
while [[ $# -gt 0 ]]; do
	case "$1" in
	--skill-dir)
		[[ $# -ge 2 ]] || usage
		skill_dir="$2"
		shift 2
		;;
	--old-skill)
		[[ $# -ge 2 ]] || usage
		old_skill_ref="$2"
		shift 2
		;;
	--model)
		[[ $# -ge 2 ]] || usage
		model="$2"
		shift 2
		;;
	--grade)
		want_grade=true
		shift
		;;
	--cwd)
		[[ $# -ge 2 ]] || usage
		cwd_override="$2"
		shift 2
		;;
	*) usage ;;
	esac
done

assertions_file="$eval_dir/assertions.json"
if [[ "$want_grade" == true ]]; then
	command -v jq >/dev/null 2>&1 || {
		echo "error: jq required for --grade" >&2
		exit 2
	}
	[[ -f "$assertions_file" ]] || {
		echo "error: $assertions_file missing (required by --grade)" >&2
		exit 2
	}
	jq -e 'type == "array" and length > 0' "$assertions_file" >/dev/null || {
		echo "error: $assertions_file must be a non-empty JSON array of strings" >&2
		exit 2
	}
fi

arm_names=("new")
arm_skill_dirs=("")
if [[ -n "$skill_dir" ]]; then
	skill_dir_abs="$(cd "$skill_dir" && pwd)"
	arm_skill_dirs=("$skill_dir_abs")
fi

old_tmp=""
cleanup_dirs=()
cleanup() {
	local d
	for d in ${cleanup_dirs[@]+"${cleanup_dirs[@]}"}; do
		if [[ -d "$d" && "$d" == "${TMPDIR:-/tmp}"/* ]]; then
			trash "$d" 2>/dev/null || rm -rf "$d"
		fi
	done
}
trap cleanup EXIT

if [[ -n "$old_skill_ref" ]]; then
	[[ -n "$skill_dir" ]] || {
		echo "error: --old-skill needs --skill-dir (which skill's history to archive)" >&2
		exit 2
	}
	[[ -z "$cwd_override" ]] || {
		echo "error: --cwd cannot be combined with --old-skill (each arm gets its own fresh fixture copy)" >&2
		exit 2
	}
	repo_root="$(git -C "$skill_dir_abs" rev-parse --show-toplevel)"
	skill_rel="$(realpath --relative-to="$repo_root" "$skill_dir_abs")"
	git -C "$repo_root" cat-file -e "${old_skill_ref}^{commit}" 2>/dev/null || {
		echo "error: git ref '$old_skill_ref' not found in $repo_root" >&2
		exit 2
	}
	old_tmp="$(mktemp -d)"
	cleanup_dirs+=("$old_tmp")
	git -C "$repo_root" archive "$old_skill_ref" -- "$skill_rel" | tar -x -C "$old_tmp"
	[[ -d "$old_tmp/$skill_rel" ]] || {
		echo "error: $skill_rel not present in ref $old_skill_ref" >&2
		exit 2
	}
	arm_names=("new" "old")
	arm_skill_dirs=("${arm_skill_dirs[0]}" "$old_tmp/$skill_rel")
fi

ts="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
pair_id="$(basename "$eval_dir")-$ts"
prompt="$(cat "$prompt_file")"
prompt_sha="$(printf '%s' "$prompt" | sha256sum | cut -d' ' -f1)"

run_arm() {
	local arm="$1" arm_skill_dir="$2" run_dir="$3" workdir
	if [[ -n "$cwd_override" ]]; then
		workdir="$(cd "$cwd_override" && pwd)"
	else
		workdir="$(mktemp -d)"
		cleanup_dirs+=("$workdir")
		if [[ -d "$eval_dir/fixture" ]]; then
			cp -r "$eval_dir/fixture/." "$workdir/"
		fi
	fi

	local full_prompt="$prompt"
	if [[ -n "$arm_skill_dir" ]]; then
		full_prompt="Load and apply the agent skill at $arm_skill_dir/SKILL.md before answering: read SKILL.md first and follow any references it directs you to load. Then answer the user request below.

$prompt"
	fi

	mkdir -p "$run_dir"
	echo "arm:     $arm (skill: ${arm_skill_dir:-installed-skills})"
	echo "cwd:     $workdir"
	echo "run dir: $run_dir"
	[[ -n "$model" ]] && echo "model:   $model"
	prompt_preview="${prompt:0:120}"
	[[ ${#prompt} -gt 120 ]] && prompt_preview+="..."
	echo "prompt:  $prompt_preview"
	echo

	local cmd=(crush run --quiet)
	[[ -n "$model" ]] && cmd+=(-m "$model")
	local start exit_code end
	start=$(date +%s)
	set +e
	(
		cd "$workdir"
		"${cmd[@]}" "$full_prompt"
	) >"$run_dir/output.md" 2>"$run_dir/stderr.log"
	exit_code=$?
	set -e
	end=$(date +%s)

	jq -n \
		--arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
		--arg arm "$arm" \
		--arg pair_id "$pair_id" \
		--arg eval_dir "$eval_dir" \
		--arg cwd "$workdir" \
		--arg skill_dir "${arm_skill_dir:-installed-skills}" \
		--arg skill_ref "$([[ $arm == old ]] && printf '%s' "$old_skill_ref" || printf 'WORKTREE')" \
		--arg model "${model:-default}" \
		--arg prompt_sha256 "$prompt_sha" \
		--argjson exit_code "$exit_code" \
		--argjson duration $((end - start)) \
		'{timestamp_utc: $ts, arm: $arm, pair_id: $pair_id, eval_dir: $eval_dir,
			cwd: $cwd, skill_dir: $skill_dir, skill_ref: $skill_ref, model: $model,
			prompt_sha256: $prompt_sha256, exit_code: $exit_code, duration_seconds: $duration,
			harness: "crush run --quiet (fresh non-interactive session)"}' \
		>"$run_dir/meta.json"

	if [[ "$want_grade" == true ]]; then
		jq --arg rid "$pair_id-$arm" \
			'{run_id: $rid, graded: null,
				expectations: [.[] | {text: ., passed: null, evidence: ""}],
				score: null,
				grade_instructions: "docs/doctrine-eval-protocol.md — fill every expectation, cite evidence from output.md, save as grading.json"}' \
			"$assertions_file" >"$run_dir/grading.template.json"
	fi

	echo "exit:    $exit_code (arm $arm: $((end - start))s)"
	echo "saved:   $run_dir/output.md"
	[[ $exit_code -eq 0 ]] || {
		echo "note: non-zero session exit — see $run_dir/stderr.log" >&2
	}
	echo
}

echo "eval:    $eval_dir"
[[ -n "$old_skill_ref" ]] && echo "pair:    new (worktree) vs old (git $old_skill_ref)"
echo

for i in "${!arm_names[@]}"; do
	if [[ ${#arm_names[@]} -gt 1 ]]; then
		run_arm "${arm_names[$i]}" "${arm_skill_dirs[$i]}" "$eval_dir/runs/$ts/${arm_names[$i]}"
	else
		run_arm "${arm_names[$i]}" "${arm_skill_dirs[$i]}" "$eval_dir/runs/$ts"
	fi
done
