#!/usr/bin/env bash
# Manage symlinks from the runtime skills dir (~/.agents/skills) into this repo.
#
# MODEL (see AGENTS.md section 5.10):
#   - Own skills live ONLY here. The runtime dir holds symlinks to them, so an
#     edit in this repo is live in every agent immediately — no sync step.
#   - Third-party skills (installed via `skills add`) are real directories in
#     the runtime dir, tracked by ~/.local/state/skills/.skill-lock.json.
#     This script NEVER touches them. Update them manually: `skills update -g`.
#
# Usage:
#   scripts/link-skills-to-agents.sh            # create/repair symlinks (idempotent)
#   scripts/link-skills-to-agents.sh --check    # exit 1 if a link is missing, wrong,
#                                               # orphaned, or an own skill is tracked
#                                               # by the skills-CLI lockfile
#   scripts/link-skills-to-agents.sh --list     # show repo skills and their link state
#   scripts/link-skills-to-agents.sh --force    # replace a conflicting real dir (DANGEROUS)
#   scripts/link-skills-to-agents.sh --selftest # exercise the check matrix in a
#                                               # sandbox (fresh/wrong/dangling/
#                                               # missing/orphan/real-dir), exit 1 on any
#                                               # behavior drift
#
# Environment:
#   AGENTS_DIR      target runtime dir (default: ~/.agents/skills). Override for
#                   isolated testing, e.g. AGENTS_DIR=/tmp/test-agents scripts/...
#   REPO_DIR        source repo dir (default: derived from this script's location).
#                   Override only for sandboxed selftests.
#   SKILLS_LOCKFILE skills-CLI lockfile to guard against (default:
#                   ~/.local/state/skills/.skill-lock.json). A repo skill tracked
#                   there would be rm -rf'd by the next `skills update`.

set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents/skills}"

# --- Selftest: exercise the check matrix in a sandbox ---------------------------
# The 2026-09-13 sync-layer hardening proved these checks by hand; this mode
# automates that sandbox matrix so the guard's behavior is pinned, not recalled:
# fresh repair, wrong target, repair-heals, dangling, missing, orphan, real-dir
# conflict, and repair-without-force refusing to clobber. Any drift = exit 1.
if [[ "${1:-}" == "--selftest" ]]; then
	sbx="$(mktemp -d)"
	trap 'rm -rf "$sbx"' EXIT
	srepo="$sbx/repo"
	sagents="$sbx/agents"
	mkdir -p "$srepo/alpha" "$srepo/beta" "$sagents"
	printf -- '---\nname: alpha\n---\n' > "$srepo/alpha/SKILL.md"
	printf -- '---\nname: beta\n---\n' > "$srepo/beta/SKILL.md"
	st_fail=0
	run() { REPO_DIR="$srepo" AGENTS_DIR="$sagents" bash "$0" "$@"; }
	run > /dev/null 2>&1 || st_fail=1
	run --check > /dev/null 2>&1 || { echo "selftest 1 FAIL: fresh repair must leave --check green"; st_fail=1; }
	ln -sfn "$srepo/alpha" "$sagents/alpha"
	run --check > /dev/null 2>&1 && { echo "selftest 2 FAIL: wrong target must fail --check"; st_fail=1; }
	run > /dev/null 2>&1
	run --check > /dev/null 2>&1 || { echo "selftest 3 FAIL: repair must fix a wrong target"; st_fail=1; }
	ln -sfn "$srepo/gone" "$sagents/beta"
	run --check > /dev/null 2>&1 && { echo "selftest 4 FAIL: dangling link must fail --check"; st_fail=1; }
	rm "$sagents/beta"
	run --check > /dev/null 2>&1 && { echo "selftest 5 FAIL: missing link must fail --check"; st_fail=1; }
	ln -s "$srepo/ghost" "$sagents/ghost"
	run --check > /dev/null 2>&1 && { echo "selftest 6 FAIL: orphan link must fail --check"; st_fail=1; }
	rm "$sagents/ghost"
	mkdir "$sagents/beta"
	run --check > /dev/null 2>&1 && { echo "selftest 7 FAIL: real-dir conflict must fail --check"; st_fail=1; }
	run > /dev/null 2>&1
	run --check > /dev/null 2>&1 && { echo "selftest 8 FAIL: repair without --force must not clobber a real dir"; st_fail=1; }
	if [[ $st_fail -eq 0 ]]; then
		echo "OK: link-skills-to-agents.sh selftest passed (8/8)."
		exit 0
	fi
	exit 1
fi

if [[ ! -d "$AGENTS_DIR" ]]; then
	echo "error: runtime skills directory not found at $AGENTS_DIR" >&2
	exit 1
fi

mapfile -t repo_skills < <(find "$REPO_DIR" -maxdepth 2 -name 'SKILL.md' -printf '%h\n' | sort)

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
	sed -n '2,24p' "$0"
	exit 0
fi

declare -A repo_skill_names=()
for skill_dir in "${repo_skills[@]}"; do
	repo_skill_names["$(basename "$skill_dir")"]=1
done

link_target_for() {
	local skill_name="$1"
	realpath --relative-to="$AGENTS_DIR" "$REPO_DIR/$skill_name"
}

# True when a runtime symlink resolves (textually, so dangling links count)
# to a path inside this repo — those are ours to report as orphans.
link_points_into_repo() {
	local link="$1" target target_abs
	target=$(readlink "$link")
	case "$target" in
	/*) target_abs=$target ;;
	*) target_abs=$(realpath -m "$AGENTS_DIR/$target") ;;
	esac
	[[ "$target_abs" == "$REPO_DIR"/* ]]
}

if [[ "${1:-}" == "--list" ]]; then
	echo "Repo skills and their state in $AGENTS_DIR:"
	for skill_dir in "${repo_skills[@]}"; do
		skill_name=$(basename "$skill_dir")
		runtime="$AGENTS_DIR/$skill_name"
		if [[ -L "$runtime" && -d "$runtime" ]]; then
			echo "  linked   $skill_name"
		elif [[ -L "$runtime" ]]; then
			echo "  DANGLING $skill_name"
		elif [[ -e "$runtime" ]]; then
			echo "  CONFLICT $skill_name (real dir/file, not a symlink)"
		else
			echo "  missing  $skill_name"
		fi
	done
	while IFS= read -r -d '' link; do
		link_name=$(basename "$link")
		if [[ ! -v "repo_skill_names[$link_name]" ]] && link_points_into_repo "$link"; then
			echo "  ORPHAN   $link_name (points into repo, skill no longer exists)"
		fi
	done < <(find "$AGENTS_DIR" -maxdepth 1 -type l -print0)
	exit 0
fi

if [[ "${1:-}" == "--check" ]]; then
	drift=0
	for skill_dir in "${repo_skills[@]}"; do
		skill_name=$(basename "$skill_dir")
		runtime="$AGENTS_DIR/$skill_name"
		expected=$(link_target_for "$skill_name")
		if [[ -L "$runtime" ]]; then
			actual=$(readlink "$runtime")
			if [[ "$actual" != "$expected" ]]; then
				echo "wrong target: $skill_name -> $actual (expected $expected)"
				drift=1
			elif [[ ! -d "$runtime" ]]; then
				echo "dangling: $skill_name -> $actual"
				drift=1
			fi
		elif [[ -e "$runtime" ]]; then
			echo "not a symlink: $skill_name (refusing to touch; inspect manually or use --force)"
			drift=1
		else
			echo "missing link: $skill_name"
			drift=1
		fi
	done
	# Reverse sweep: runtime symlinks pointing into this repo whose skill is
	# gone from the repo (AGENTS.md rule 5 leftovers). Never touches third-party
	# real dirs or symlinks that point elsewhere.
	while IFS= read -r -d '' link; do
		link_name=$(basename "$link")
		if [[ ! -v "repo_skill_names[$link_name]" ]] && link_points_into_repo "$link"; then
			echo "orphaned link: $link_name (points into repo but skill no longer exists; remove it)"
			drift=1
		fi
	done < <(find "$AGENTS_DIR" -maxdepth 1 -type l -print0)
	# Lockfile guard: an own skill tracked by the skills CLI will have its
	# symlink rm -rf'd by the next `skills update` (AGENTS.md rule 2).
	lockfile="${SKILLS_LOCKFILE:-$HOME/.local/state/skills/.skill-lock.json}"
	if [[ -f "$lockfile" ]]; then
		mapfile -t lock_names < <(jq -r 'if type == "object" then keys[] else empty end' "$lockfile" 2>/dev/null || true)
		for lock_name in "${lock_names[@]}"; do
			if [[ -n "$lock_name" && -v "repo_skill_names[$lock_name]" ]]; then
				echo "own skill tracked by skills-CLI lockfile: $lock_name (next 'skills update' will rm -rf its symlink; AGENTS.md rule 2)"
				drift=1
			fi
		done
	fi
	if [[ $drift -eq 0 ]]; then
		echo "OK: all repo skills symlinked into $AGENTS_DIR"
		exit 0
	fi
	exit 1
fi

force=0
if [[ "${1:-}" == "--force" ]]; then
	force=1
fi

echo "Linking repo skills from $REPO_DIR into $AGENTS_DIR ..."
changed=0
for skill_dir in "${repo_skills[@]}"; do
	skill_name=$(basename "$skill_dir")
	runtime="$AGENTS_DIR/$skill_name"
	target=$(link_target_for "$skill_name")

	if [[ -L "$runtime" ]]; then
		current=$(readlink "$runtime")
		if [[ "$current" == "$target" && -d "$runtime" ]]; then
			echo "  ok $skill_name"
		else
			ln -sfn "$target" "$runtime"
			changed=1
			echo "  repaired $skill_name -> $target"
		fi
	elif [[ -e "$runtime" ]]; then
		if [[ $force -eq 1 ]]; then
			echo "  WARNING: moving real dir aside and linking: $skill_name" >&2
			mv "$runtime" "${runtime}.replaced-$(date +%Y%m%d%H%M%S)"
			ln -s "$target" "$runtime"
			echo "  forced $skill_name -> $target"
		else
			echo "  SKIP (real dir exists, not a symlink; use --force): $skill_name" >&2
		fi
	else
		ln -s "$target" "$runtime"
		changed=1
		echo "  created $skill_name -> $target"
	fi
done

# The runtime dir doubles as a git repo (aggregation layer, AGENTS.md 5.10).
# New/changed symlinks show up untracked there until the owner commits them.
if [[ $changed -eq 1 && -d "$AGENTS_DIR/.git" ]]; then
	echo "NOTE: $AGENTS_DIR is a git repo (aggregation layer); review and commit the changed links:"
	echo "  git -C $AGENTS_DIR status --short"
fi

echo "Done."
