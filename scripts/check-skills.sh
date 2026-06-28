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
  check|"") ;;
  *) echo "Usage: $0 [--thin]" >&2; exit 2 ;;
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
  lines=$(wc -l < "$d/SKILL.md")
  flag=""
  if [[ "$lines" -lt 35 ]]; then flag="  [THIN]"; thin_count=$((thin_count+1)); fi
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
    echo "FAIL $skill: SKILL.md must start with a '---' frontmatter delimiter"; failed=1
  fi
  # Check 2: name field present and matches directory
  name=$(grep -m1 '^name:' "$f" | sed -E 's/^name:[[:space:]]*//;s/[[:space:]]*$//')
  if [[ -z "$name" ]]; then
    echo "FAIL $skill: missing 'name:' in frontmatter"; failed=1
  elif [[ "$name" != "$skill" ]]; then
    echo "FAIL $skill: frontmatter name '$name' != directory '$skill'"; failed=1
  fi
  # Check 3: description field present
  if ! grep -q '^description:' "$f"; then
    echo "FAIL $skill: missing 'description:' in frontmatter"; failed=1
  fi
  # Check 4: no `git commit <--` / bare `<-- ` artifact (see AGENTS.md §5.2)
  if grep -q 'git commit <--' "$f" || grep -qE 'commit[[:space:]]+<--[[:space:]]' "$f"; then
    echo "FAIL $skill: contains the 'git commit <--' prompt artifact — rewrite as clear prose (AGENTS.md §5.2)"; failed=1
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
    echo "FAIL $skill: description is $desc_len chars (limit 1024) — Crush will refuse to load this skill"; failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  echo
  echo "FAIL: one or more skill checks failed." >&2
  exit 1
fi

echo "OK: all ${#skill_dirs[@]} skills pass structural checks."
