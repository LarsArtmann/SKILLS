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
#   scripts/link-skills-to-agents.sh --check    # exit 1 if a link is missing or wrong
#   scripts/link-skills-to-agents.sh --list     # show repo skills and their link state
#   scripts/link-skills-to-agents.sh --force    # replace a conflicting real dir (DANGEROUS)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents/skills}"

if [[ ! -d "$AGENTS_DIR" ]]; then
	echo "error: runtime skills directory not found at $AGENTS_DIR" >&2
	exit 1
fi

mapfile -t repo_skills < <(find "$REPO_DIR" -maxdepth 2 -name 'SKILL.md' -printf '%h\n' | sort)

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
	sed -n '2,14p' "$0"
	exit 0
fi

link_target_for() {
	local skill_name="$1"
	realpath --relative-to="$AGENTS_DIR" "$REPO_DIR/$skill_name"
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
		echo "  created $skill_name -> $target"
	fi
done

echo "Done."
