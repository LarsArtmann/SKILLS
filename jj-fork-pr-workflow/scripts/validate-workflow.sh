#!/usr/bin/env bash
#
# validate-workflow.sh — Hermetic end-to-end validation of jj-fork-pr-workflow's
# documented lifecycle.
#
# WHY THIS EXISTS
#   The skill's Phase 4/5 workflows were originally reasoned from `--help`
#   text. Flags verified != workflow verified. This script executes the whole
#   lifecycle against throwaway LOCAL remotes (no network, no GitHub), so any
#   jj upgrade that changes rebase/push/bookmark semantics fails loudly here.
#
# WHAT IT VALIDATES
#   1. Fork-first setup: jj clone --colocate, upstream remote, fetch
#   2. Two sibling PR changes + one stacked change, pushed via `jj git push -c`
#   3. The bulk sync loop after upstream moves:
#      `jj rebase -s 'roots(mine() & mutable())' -o main@upstream`
#   4. Re-pushing rebased PRs with the SAME `-c` commands (stable names)
#   5. Squash-merge simulation -> change shows as empty() -> abandon +
#      bookmark delete + `jj git push --deleted`
#
# USAGE
#   jj-fork-pr-workflow/scripts/validate-workflow.sh     # exits 0 = all green
#
# Requires: jj >= 0.44 (uses rebase --onto), git. Leaves a scratch dir in
# /tmp (mktemp) — inspect on failure, delete at will.

set -euo pipefail

command -v jj >/dev/null || {
	echo "FAIL: jj not found"
	exit 1
}
command -v git >/dev/null || {
	echo "FAIL: git not found"
	exit 1
}

scratch="$(mktemp -d /tmp/jj-fork-pr-validate.XXXXXX)"
trap 'echo "scratch dir (kept for inspection): $scratch"' EXIT
cd "$scratch"

ALPHA='description(substring:"feat: add alpha")'
BETA='description(substring:"fix: beta fix")'
STACKED='description(substring:"chore: stacked on beta")'
GAMMA='description(substring:"feat: gamma true sibling")'

pass=0
fail=0
check() { # check <label> <rc>
	local label="$1" rc="$2"
	if [[ "$rc" -eq 0 ]]; then
		echo "PASS: $label"
		pass=$((pass + 1))
	else
		echo "FAIL: $label"
		fail=$((fail + 1))
	fi
}

# --- Fake upstream (bare) + seed commit --------------------------------------
git init --bare --initial-branch=main upstream.git >/dev/null
git clone -q "$scratch/upstream.git" upstream-work
git -C "$scratch/upstream-work" config user.email "validator@example.com"
git -C "$scratch/upstream-work" config user.name "Validator"
echo "base" >"$scratch/upstream-work/file.txt"
git -C "$scratch/upstream-work" add file.txt
git -C "$scratch/upstream-work" commit -qm "base"
git -C "$scratch/upstream-work" push -q origin main

# --- Fake fork: bare copy of upstream -----------------------------------------
git clone --bare -q "$scratch/upstream.git" fork.git

# --- Phase 1: jj clone the fork, add upstream remote ---------------------------
jj git clone --colocate "$scratch/fork.git" jjwork >/dev/null 2>&1
jj -R "$scratch/jjwork" git remote add upstream "$scratch/upstream.git"
jj -R "$scratch/jjwork" git fetch --all-remotes
jj -R "$scratch/jjwork" log --no-pager -r 'main@upstream' >/dev/null
check "Phase 1: colocated clone + upstream remote + fetch (main@upstream visible)" $?

# --- Phase 2: two sibling PR changes + one stacked change ----------------------
cd "$scratch/jjwork"
jj new main@upstream -m "feat: add alpha" >/dev/null
echo "alpha" >>file.txt
jj new >/dev/null
jj new main@upstream -m "fix: beta fix" >/dev/null
echo "beta" >beta.txt
jj new -m "chore: stacked on beta" >/dev/null
echo "stacked" >stacked.txt
jj new >/dev/null

changes=$(jj log --no-pager --no-graph -r 'mine() & mutable() & ~empty()' -T 'description ++ "\n"' | grep -c .)
[[ "$changes" -eq 3 ]]
check "Phase 2: three described changes exist (2 siblings + 1 stacked)" $?

# --- Phase 3: push all three PRs with -c ----------------------------------------
jj git push -c "$ALPHA" -c "$BETA" -c "$STACKED" >/dev/null 2>&1
fork_branches=$(git --git-dir="$scratch/fork.git" branch --format='%(refname:short)' | grep -c '^push-')
[[ "$fork_branches" -eq 3 ]]
check "Phase 3: three push-* bookmarks created on the fork remote" $?

# --- Upstream moves (touches a different file than any PR) ----------------------
echo "upstream line" >>"$scratch/upstream-work/other.txt"
git -C "$scratch/upstream-work" add other.txt
git -C "$scratch/upstream-work" commit -qm "chore: upstream moves"
git -C "$scratch/upstream-work" push -q origin main

# --- Phase 4: the sync loop ------------------------------------------------------
jj git fetch --all-remotes >/dev/null 2>&1
jj rebase -s 'roots(mine() & mutable())' -o main@upstream >/dev/null
jj log --no-pager -r 'mine() & mutable()' >/dev/null
check "Phase 4: bulk rebase of roots(mine() & mutable()) onto new main@upstream ran" $?

base_ids=$(jj log --no-pager --no-graph -r 'parents(roots(mine() & mutable() & ~empty()))' -T 'commit_id ++ "\n"' | sort -u)
trunk_id=$(jj log --no-pager --no-graph -r 'main@upstream' -T 'commit_id')
[[ "$base_ids" == "$trunk_id" ]]
check "Phase 4: every PR chain root now sits on new main@upstream (stacks intact, siblings parallel)" $?

# Re-push with the SAME -c commands — bookmark names must be stable through rebase
jj git push -c "$ALPHA" -c "$BETA" -c "$STACKED" >/dev/null 2>&1
alpha_bm="push-$(jj log --no-pager --no-graph -r "$ALPHA" -T 'change_id.short()')"
local_tip=$(jj log --no-pager --no-graph -r "$ALPHA" -T 'commit_id')
remote_tip=$(git --git-dir="$scratch/fork.git" rev-parse "refs/heads/$alpha_bm")
[[ "$local_tip" == "$remote_tip" ]]
check "Phase 4: re-pushing rebased change with same -c moved fork branch $alpha_bm to the new commit" $?

# --- Phase 4b: bare push skips true siblings (why the helper uses -b 'push-*') ---
jj new main@upstream -m "feat: gamma true sibling" >/dev/null
echo "gamma" >gamma.txt
jj new >/dev/null
jj git push -c "$GAMMA" >/dev/null 2>&1
echo "upstream moved again" >>"$scratch/upstream-work/other.txt"
git -C "$scratch/upstream-work" add other.txt
git -C "$scratch/upstream-work" commit -qm "chore: upstream moves again"
git -C "$scratch/upstream-work" push -q origin main
jj git fetch --all-remotes >/dev/null 2>&1
jj rebase -s 'roots(mine() & mutable())' -o main@upstream >/dev/null
bare_out=$(jj git push --dry-run 2>&1 || true)
gamma_bm="push-$(jj log --no-pager --no-graph -r "$GAMMA" -T 'change_id.short()')"
beta_bm="push-$(jj log --no-pager --no-graph -r "$BETA" -T 'change_id.short()')"
if grep -q "$gamma_bm" <<<"$bare_out"; then gamma_rc=0; else gamma_rc=1; fi
if grep -q "$beta_bm" <<<"$bare_out"; then beta_rc=1; else beta_rc=0; fi
[[ "$gamma_rc" -eq 0 && "$beta_rc" -eq 0 ]]
check "Phase 4b: bare jj git push covers only the @-reachable chain — true sibling skipped (use -b 'push-*')" $?
jj git push -b 'push-*' >/dev/null 2>&1

# --- Squash-merge simulation: upstream absorbs alpha as ONE new commit -----------
alpha_sha=$(git --git-dir="$scratch/fork.git" rev-parse "refs/heads/$alpha_bm")
git -C "$scratch/upstream-work" fetch -q "$scratch/fork.git" "+refs/heads/*:refs/remotes/fork/*"
git -C "$scratch/upstream-work" cherry-pick "$alpha_sha" >/dev/null 2>&1
git -C "$scratch/upstream-work" commit --amend -qm "feat: add alpha (#1)" >/dev/null 2>&1
git -C "$scratch/upstream-work" push -q origin main

# --- Phase 5: cleanup --------------------------------------------------------------
jj git fetch --all-remotes >/dev/null 2>&1
jj rebase -s 'roots(mine() & mutable())' -o main@upstream >/dev/null
merged_count=$(jj log --no-pager --no-graph -r "empty() & $ALPHA" -T 'commit_id ++ "\n"' | grep -c . || true)
[[ "$merged_count" -ge 1 ]]
check "Phase 5: squash-merged change rebases to empty() (diff absorbed by upstream)" $?

others=$(jj log --no-pager --no-graph -r 'mine() & mutable() & ~empty()' -T 'description ++ "\n"' | grep -cE 'beta|stacked')
[[ "$others" -eq 2 ]]
check "Phase 5: sibling + stacked changes survived the merge cleanup (still non-empty)" $?

# Abandon guarded by mine() & mutable(). Squash-merge (simulated here by
# cherry-pick; GitHub behaves the same) PRESERVES THE PR AUTHOR — the upstream
# squash commit "feat: add alpha (#1)" carries your email AND your PR title,
# so both mine() and description() match it too. Only mutable() separates your
# local change from upstream's copy; jj rightly refuses: "Error: Commit ...
# is immutable".
rc=0
jj abandon "mine() & mutable() & $ALPHA" >/dev/null 2>&1 || rc=$?
check "Phase 5: abandon merged change via mine() & mutable() guard (squash commits keep your authorship, so mine() alone still matches upstream's copy)" $rc

jj bookmark delete "$alpha_bm" >/dev/null 2>&1
jj git push --deleted >/dev/null 2>&1
still_there=$(git --git-dir="$scratch/fork.git" branch --format='%(refname:short)' | grep -c "^$alpha_bm\$" || true)
[[ "$still_there" -eq 0 ]]
check "Phase 5: bookmark deleted locally and on the fork remote (--deleted push)" $?

echo
echo "RESULT: $pass passed, $fail failed"
[[ "$fail" -eq 0 ]]
