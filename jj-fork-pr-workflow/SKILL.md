---
name: jj-fork-pr-workflow
description: >
  Use when contributing to an open-source repository the user does not own —
  forking a repo, opening a pull request, maintaining multiple open PRs, or
  updating PR branches after upstream moved. Triggers on "fork with jj",
  "open a PR", "multiple PRs", "keep my PRs up to date", "rebase my PRs",
  "contribute to <repo>", "charmbracelet", or any jj/jujutsu question in the
  context of GitHub contributions. Also use when the user says "jj
  mergemerge" — that command does not exist; this skill provides the real
  sync loop (fetch + rebase + push) that keeps every open PR current.
metadata:
  tags: jj, jujutsu, vcs, github, open-source, pull-requests, fork, charmbracelet
allowed-tools: jj gh
---

# Contributing Upstream with jj — Fork + Multi-PR Workflow

Keep every open PR in a fork permanently up to date with upstream, using
[Jujutsu (jj)](https://github.com/jj-vcs/jj), a Git-compatible VCS whose
change-ID model makes multi-PR maintenance dramatically cheaper than Git.

**Set this workflow up BEFORE the second PR exists.** Review iterations,
stacked fixes, and follow-up bugs almost always turn one PR into several.
Retrofitting a fork workflow mid-review is possible but messy; the setup cost
is four commands. For `github.com/charmbracelet/*` repos: always use this
workflow. For any other repo you lack push access to: default to it too.

## The "jj mergemerge" correction

`jj mergemerge` does not exist (verified against jj 0.45.1's command list,
the official CLI reference, and the source — there is no `merge` subcommand
at all in current versions). When the user asks for "jj mergemerge", they
mean the **sync loop** in Phase 4: `jj git fetch` + `jj rebase` +
`jj git push`. Map the intent to that loop and say so.

## Why jj beats Git for multi-PR upstream work

Each point changes what is practical, not just what is pleasant:

1. **Change IDs survive rebases.** A PR pushed with `jj git push -c <id>`
   targets a branch name derived from the change ID. Rebase the change, run
   the same command, and the PR updates — no force flags, no bookmark
   bookkeeping, ever.
2. **Parallel PRs need no branch switching.** The working copy is itself a
   commit. Sibling changes sit side by side in one directory; `jj edit`
   switches between them instantly. No stashing, no dirty-tree dances.
3. **Force-push safety is always on.** `jj git push` behaves like
   `git push --force-with-lease` by default; there is no `--force` flag to
   misuse.
4. **Conflicts are first-class.** A rebase that conflicts still completes.
   You can rebase ten PRs in one command, then resolve conflicts one by one,
   while every other PR stays current and green.
5. **Revsets enable mass operations.** One `jj rebase -s 'roots(mine() &
   mutable())' -o main@upstream` moves every PR chain you own onto fresh
   trunk in a single step.

## Agent safety rules

- **Detect the VCS first.** A `.jj` directory at the repo root means jj is
  in charge: use jj for ALL history operations (`new`, `describe`, `rebase`,
  `push`). Never run `git commit`, `git push`, `git rebase`, or `git pull`
  manually — git-side history writes bypass jj's operation log and confuse
  colocation. Read-only git commands are fine.
- If the repo has `.git` but no `.jj`, it is a Git-only checkout. Do not
  convert it (`jj git init --colocate`) without asking — that changes the
  user's repo layout.
- In non-interactive contexts, pass `--no-pager` to every jj command so the
  agent never blocks on a pager.
- **Push only to the fork** (`origin` by default). Never target the upstream
  remote.

## Phase 0 — Pre-flight checks

Run before touching anything:

1. `jj --version` — this skill's commands are verified against **jj 0.45.1**.
   On jj < 0.44, rebase's `--onto/-o` flag is spelled `-d` (still a hidden
   alias in 0.45). Substitute accordingly.
2. `gh auth status` — the workflow creates the fork and PRs via `gh`.
3. `jj config get user.email` — this email must match an email registered on
   the GitHub account that pushes. `mine()` (used by the sync loop) matches
   on it, and GitHub attributes commits by it. A mismatch silently breaks
   both: revsets miss your PRs, and commits show the wrong author.
4. Check whether a fork already exists: `gh repo view YOU/<repo>` exits 1
   → create the fork in Phase 1; exits 0 → skip `gh repo fork` and clone
   directly. Do NOT probe the upstream (`gh repo view <owner>/<repo>`) — it
   succeeds whether or not you have a fork and tells you nothing. `gh repo
   fork` is also idempotent: run it with an existing fork and it just
   reports the fork.

## Phase 1 — Fork-first setup (one time per repo)

```bash
gh repo fork <owner>/<repo> --clone=false
jj git clone --colocate git@github.com:YOU/<repo>.git
cd <repo>
jj git remote add upstream https://github.com/<owner>/<repo>.git
jj git fetch --all-remotes
```

Why each choice:

- **Clone the fork, not upstream.** jj's default push remote is `origin`;
  cloning the fork makes it impossible to accidentally push branches to
  upstream. (Cloning upstream first also works — then set `git.push` — but
  fork-first is simpler.)
- **`--colocate`.** The checkout stays a valid git repo, so IDEs, gopls, and
  git-only tooling keep working. jj auto-imports git-side changes.
- **`upstream` remote added explicitly.** The trunk you rebase onto is
  `<default-branch>@upstream` (usually `main@upstream`), never `main@origin`
  — the fork's copy lags until synced.

Optional hygiene so GitHub's UI shows the fork as current:
`gh repo sync` (syncs the fork's default branch from its parent).

## Phase 2 — Work in changes, not branches

```bash
jj new main@upstream          # start work on fresh trunk
# ... edit files (snapshots are automatic; no staging area exists) ...
jj describe -m "feat: ..."    # describe the change
jj new                        # finish it, start the next empty change
# (equivalent one-step: jj commit -m "feat: ..." = describe + new)
```

- **One PR = one change = one logical concern.** If a change grows two
  concerns, split it: `jj split` (interactive file selection).
- **Commit messages use Conventional Commits** (`feat:`, `fix:`, `docs:`,
  `chore:`...). Repos that squash-merge — charmbracelet does — turn the PR
  title into the history commit, so the title IS the commit message.
- **Parallel (independent) PRs:** run `jj new main@upstream` again. The new
  change is a sibling; both can be pushed and reviewed independently. Move
  between them with `jj edit <change-id>`.
- **Stacked PRs:** `jj new` on top of change 1, implement change 2. Open PR
  2 with PR 1's branch as its base on GitHub; when PR 1 merges, the sync
  loop drops it under PR 2 automatically.
- **Describe every change as you go.** An undescribed stray `jj new` commit
  that ends up BELOW a stacked change blocks `jj git push -c` for the whole
  stack — jj refuses to push commits with empty descriptions. `jj commit
  -m "..."` describes and starts the next change in one step, making strays
  impossible.

## Phase 3 — Push and open the PR

```bash
jj git push -c @-             # push the described change; branch = push-<changeid>
# or with a human-readable branch name:
jj bookmark set fix-tui-rerender -r @-
jj git push -b fix-tui-rerender
```

- `-c/--change` accepts a change ID or revset and can be repeated. The
  generated branch name (`push-` + short change ID, customizable via
  `templates.git_push_bookmark`) is stable across rebases — that stability
  is what makes Phase 4 a two-liner.
- Open the PR: in a colocated repo, plain `gh pr create` works (gh detects
  the fork's parent as the PR target). In a non-colocated checkout, point gh
  at jj's underlying git dir first: `GIT_DIR="$(jj git root)" gh pr create`.
- Write the PR body to the target repo's template (GitHub auto-inserts it
   for empty bodies; an explicit `gh pr create --body` bypasses it). For
   charmbracelet the template is just two checkboxes, so structure the body
   yourself — see
   [./references/charmbracelet.md](./references/charmbracelet.md).
- **Before filing, verify the diagnosis**: the `verify-before-filing` skill
  owns that step. A rebased, green, well-described PR whose premise is wrong
  still wastes a maintainer's time.

## Phase 4 — The sync loop (the real "jj mergemerge")

Run whenever upstream moved, a review requested changes, or CI broke on new
trunk commits. This is the loop that keeps ALL PRs current:

```bash
jj git fetch --all-remotes
jj rebase -s 'roots(mine() & mutable())' -o main@upstream
jj log -r 'mine() & mutable()' --no-pager     # review: conflicts show here
jj git push -c <change-id-1> -c <change-id-2> # repeatable; names are stable
```

Step by step:

1. **Fetch both remotes** so `main@upstream` is fresh.
2. **Rebase every PR chain at once.** `roots(mine() & mutable())` selects
   the bottom of each chain you authored; `-s` carries each root's
   descendants along, so stacked PRs keep their internal structure while
   their base moves to the new trunk. For just the current stack, plain
   `jj rebase -o main@upstream` suffices.
3. **Review the log.** Conflicted changes are marked in the log — they are
   not broken; the conflict lives inside the commit until you resolve it.
4. **Re-push every PR.** Because `-c` derives branch names from change IDs,
   the same command that opened each PR now updates it. jj's built-in
   force-with-lease handles the history rewrite; there is no `--force` flag.
5. Check CI: `gh pr checks` (or the PR pages).

Conflict resolution: `jj edit <change-id>`, fix the conflicted files (jj
marks them in place), then proceed — the snapshot picks up the fix. Pushing
a commit that still contains conflicts requires an explicit
`jj git push --allow-conflicts`; GitHub will show the PR as conflicted. Prefer
resolving before pushing.

Flag notes: `-o/--onto` is the current spelling (jj ≥ 0.44; older versions
use `-d`). `-A/--insert-after` and `-B/--insert-before` exist for inserting
between commits — you rarely need them for trunk syncs.

The whole loop is encoded and execution-verified as
[./scripts/sync-all-prs.sh](./scripts/sync-all-prs.sh) — run it instead of
retyping. It re-pushes with `-b 'push-*'`, which works because rebase
carries bookmarks to the rebased commits (verified: local push-* bookmarks
already sit at the new tips after step 2, marked `*` = diverged from remote
until pushed).

## Phase 5 — Post-merge cleanup

Squash-merge repos (all of charmbracelet) make the local change _empty_
after upstream absorbs it: main receives a new squashed commit, so the
rebased change's diff vanishes while its description survives. Clean up:

```bash
jj git fetch --all-remotes
jj rebase -s 'roots(mine() & mutable())' -o main@upstream
jj log -r 'mine() & mutable() & empty()' --no-pager   # REVIEW this list
jj abandon 'mine() & mutable() & <change-or-id>'     # the mutable() guard is REQUIRED — see pitfalls
jj bookmark delete <branch-name>                      # named and push-<id> bookmarks alike
jj git push --deleted                                 # propagate the branch deletion
```

Why the explicit review step: `empty()` also matches a fresh, undescribed
working-copy commit (`@`). Abandoning that is harmless but sloppy; the
log-then-abandon pattern keeps cleanup deliberate. `jj abandon` rebases
descendants onto the abandoned change's parents automatically — stacked PRs
stay intact after their parent PR merges.

## Pitfalls

- **`mine()` matches on `user.email`.** If commits were authored under a
  different email, the sync loop's revsets silently miss them. Set
  `user.email` correctly FIRST (Phase 0). Existing commits can be re-stamped
  from the corrected config with `jj metaedit --update-author`.
- **Squash-merged commits keep YOUR authorship.** After your PR is
  squash-merged (GitHub and cherry-pick both preserve the PR author), the
  upstream commit carries your email AND your PR title — so `mine()` and
  `description()` match it too. Guard every cleanup revset with
  `& mutable()`; only that separates your local change from upstream's
  copy. Verified: a bare `mine() & description(...)` abandon fails with
  "Commit ... is immutable" — jj protecting shared history, correctly.
- **`description("x")` is exact match against `"x\n"`.** Descriptions end
  with a newline, so the intuitive form returns an empty revset ("Empty
  revision set"). Use `description(substring:"x")`.
- **Stray undescribed `jj new` commits block `push -c`** for anything
  stacked above them (empty-description commits are unpushable by default).
  Describe every change; `jj commit -m` does describe + new in one step.
- **Long change-id prefixes do not resolve as revsets.** `change_id.short()`
  templates emit 12-24 hex chars, and longer hex strings parse as COMMIT-id
  prefixes. Use the short form `jj log` displays, or a guarded revset.
- **Bare `jj git push` can skip PRs** (execution-verified). It only pushes
  tracking bookmarks reachable from `@` (`remote_bookmarks(remote)..@`).
  Sibling PR chains are not ancestors of `@`, so after a bulk rebase, push
  per change with repeated `-c` flags, or with the `-b 'push-*'` glob the
  helper script uses.
- **`--allow-new` does not exist** on current `jj git push` (older tutorials
  mention it). `-c` and `--named` create new bookmarks on the fly.
- **There is no `--force`.** jj always pushes with force-with-lease
  semantics; if the remote moved since the last fetch, jj refuses and asks
  for a fetch first.
- **`push-<id>` branch names look ugly but are correct.** The change ID
  makes the PR↔change mapping self-maintaining. Use `--named` or
  `bookmark set` only when humans need readable branch names.
- **Never `git pull` / `git rebase` / `git push` in a colocated repo.** jj
  imports git-side changes automatically; manual git history writes are the
  one thing that desyncs colocation.
- **charmbracelet squash-merges**, so never "merge main into the PR branch"
  to update it — that pollutes the squash with merge commits. Rebase
  instead (Phase 4).

## Verification status

Evidence levels for every claim in this skill (all 2026-09-08):

- **Execution-verified** against jj 0.45.1 in hermetic two-remote scratch
  repos — the full Phase 1-5 lifecycle, 11/11 assertions: colocated clone +
  upstream remote, sibling + stacked changes, `push -c` bookmark creation,
  the bulk `roots(mine() & mutable())` rebase (stacks intact, siblings
  parallel), same-`-c` re-push of rebased PRs (stable branch names), bare
  push skipping true siblings (why `-b 'push-*'`), squash-merge →
  `empty()`, `mine() & mutable()`-guarded abandon, bookmark delete +
  `--deleted` push. Rerun anytime (e.g. after a jj upgrade):
  [./scripts/validate-workflow.sh](./scripts/validate-workflow.sh).
- **Flag-verified** against jj 0.45.1 `--help`: all other commands and revset
  functions (`heads()`, `description()`, `author()`...).
- **gh-verified** against gh 2.99.0: `gh repo fork --clone=false`,
  `gh repo sync`, `gh repo view` exit codes (1 = missing), `gh pr checks`
  argument semantics (PR selector or current branch — not `owner/repo`).
- **Raw-source-verified** via the GitHub API: charmbracelet CONTRIBUTING.md,
  the org-level PR template (two checkboxes), and `bubbletea` merge history
  (single-parent `(#NNNN)` commits ⇒ squash-merge). An earlier draft's
  "Problem/Fix/Validation template" claim was summarizer fabrication,
  caught and corrected by raw verification.
- `jj mergemerge` confirmed nonexistent (local command list + official docs
  - source search).
- Official docs: <https://docs.jj-vcs.dev/latest/github/>

## Cross-skill handoffs

- **`verify-before-filing`** — run before opening any upstream PR; it owns
  diagnosis verification. This skill owns the VCS mechanics only.
- **`verify-external-claims`** — this skill's own claims are verified above;
  apply the same bar before extending it.
