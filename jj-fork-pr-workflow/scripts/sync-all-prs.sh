#!/usr/bin/env bash
#
# sync-all-prs.sh — the Phase 4 sync loop from SKILL.md, executable.
#
# WHY THIS EXISTS
#   The loop is three commands an agent can mistype (and whose flag spellings
#   drift across jj versions). This script is the canonical, execution-verified
#   form (validated by scripts/validate-workflow.sh against jj 0.45.1):
#
#     1. jj git fetch --all-remotes
#     2. jj rebase -s 'roots(mine() & mutable())' -o <trunk>   # every PR chain at once
#     3. jj git push -b 'push-*'                                # all PR bookmarks
#
#   Step 3 relies on two verified behaviors: rebase carries bookmarks to the
#   rebased commits (so the local push-* bookmarks already point at the new
#   tips), and push uses force-with-lease semantics (no --force exists).
#
# USAGE
#   jj-fork-pr-workflow/scripts/sync-all-prs.sh              # trunk = main@upstream
#   jj-fork-pr-workflow/scripts/sync-all-prs.sh master@upstream
#
#   Run it from inside the colocated jj checkout of your fork. PRs pushed with
#   NAMED bookmarks (jj bookmark set ...) are not covered by the push-* glob —
#   push those explicitly with `jj git push -b <name>` afterwards.
#
# NOTES
#   - Conflicts abort nothing: jj stores them inside the commits. Resolve with
#     `jj edit <change>`, fix files, re-run this script.
#   - If a PR was squash-merged upstream, after this loop it shows as empty():
#     clean it up per SKILL.md Phase 5 (guard abandons with mine() & mutable()).
#   - Requires jj >= 0.44 (rebase --onto).

set -euo pipefail

command -v jj >/dev/null || { echo "FAIL: jj not found" >&2; exit 1; }

trunk="${1:-main@upstream}"

jj --no-pager git fetch --all-remotes
jj --no-pager rebase -s 'roots(mine() & mutable())' -o "$trunk"

echo "--- Your changes after rebase (review for conflicts) ---"
jj --no-pager log -r 'mine() & mutable()'

bookmarks=$(jj --no-pager bookmark list 2>/dev/null | grep -oE 'push-[a-z0-9]+' || true)
if [[ -z "$bookmarks" ]]; then
	echo "No push-* bookmarks — nothing to push. (Named bookmarks need a manual 'jj git push -b <name>'.)"
	exit 0
fi

echo "--- Pushing PR bookmarks (force-with-lease) ---"
jj --no-pager git push -b 'push-*'
