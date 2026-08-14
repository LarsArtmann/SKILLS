#!/usr/bin/env bash
# Sync project-repo skills to the Crush runtime skills directory.
#
# The project repo at /home/lars/projects/SKILLS is the canonical source of
# truth for skills. Crush loads skills from ~/.config/crush/skills/, which
# symlinks into /home/lars/.agents/skills/. This script copies the canonical
# project-repo skills into the runtime directory so Crush uses the latest
# versions.
#
# Usage:
#   scripts/sync-skills-to-agents.sh          # sync
#   scripts/sync-skills-to-agents.sh --check  # exit 1 if runtime is out of sync
#   scripts/sync-skills-to-agents.sh --list    # show which skills would be synced

set -euo pipefail

REPO_DIR="/home/lars/projects/SKILLS"
AGENTS_DIR="/home/lars/.agents/skills"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    sed -n '2,10p' "$0"
    exit 0
fi

if [[ ! -d "$REPO_DIR" ]]; then
    echo "error: project repo not found at $REPO_DIR" >&2
    exit 1
fi

if [[ ! -d "$AGENTS_DIR" ]]; then
    echo "error: agents skills directory not found at $AGENTS_DIR" >&2
    exit 1
fi

# Collect skill directories from the project repo (directories containing SKILL.md)
mapfile -t repo_skills < <(find "$REPO_DIR" -maxdepth 2 -name 'SKILL.md' -printf '%h\n' | sort)

if [[ "${1:-}" == "--list" ]]; then
    echo "Skills that would be synced from $REPO_DIR to $AGENTS_DIR:"
    for skill_dir in "${repo_skills[@]}"; do
        skill_name=$(basename "$skill_dir")
        echo "  $skill_name"
    done
    exit 0
fi

if [[ "${1:-}" == "--check" ]]; then
    drift=0
    for skill_dir in "${repo_skills[@]}"; do
        skill_name=$(basename "$skill_dir")
        target_dir="$AGENTS_DIR/$skill_name"
        if [[ ! -d "$target_dir" ]]; then
            echo "missing in runtime: $skill_name"
            drift=1
            continue
        fi
        diff_output=$(diff -rq "$skill_dir" "$target_dir" 2>&1 || true)
        if [[ -n "$diff_output" ]]; then
            echo "drift: $skill_name"
            echo "$diff_output" | sed 's/^/  /'
            drift=1
        fi
    done
    if [[ $drift -eq 0 ]]; then
        echo "OK: runtime skills are in sync with project repo"
        exit 0
    else
        exit 1
    fi
fi

echo "Syncing skills from $REPO_DIR to $AGENTS_DIR ..."
for skill_dir in "${repo_skills[@]}"; do
    skill_name=$(basename "$skill_dir")
    target_dir="$AGENTS_DIR/$skill_name"
    rsync -a --delete "$skill_dir/" "$target_dir/"
    echo "  synced $skill_name"
done

echo "Done."
