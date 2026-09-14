# BuildFlow Failure Triage

Detailed triage for the failure classes an agent actually hits in covered projects. Sources: consumer AGENTS.md entries (httputil, wise-go, erraudit, monitor365) and BuildFlow gotchas — all verified against real incidents, not speculation.

## 1. A step failed

1. Read the summary — each failure block prints the exact re-run command (`buildflow -s <tool>`).
2. Re-run with logs: `buildflow -s <tool> -v`.
3. For findings context: `buildflow -s <tool> --format finding`.
4. **Before "fixing" what the tool reported, check the project's AGENTS.md for a known-tool-bug entry.** Real documented examples:
   - `gomod-check` "direct and indirect requires are mixed" false positive (erraudit repo) — tool bug, go.mod is fine.
   - `nix-checker` oscillating a flake-input version every commit (erraudit repo) — known flip-flop, don't fight it.
   - Detect-only findings that are **policy-rejected, not debt** (branching-flow/erraudit/go-structure-linter findings contradicting documented decisions) — re-read the decision docs before bulk-fixing.
5. If the tool's behavior contradicts its docs, suspect a stale binary (next section) before suspecting the code.

## 2. Stale binary (the #1 silent root cause)

The globally installed `buildflow` (`~/.local/bin/buildflow`) can be a plain copy, not a symlink — it lags BuildFlow HEAD while the tool keeps evolving.

- **Detect:** `buildflow doctor` — the `binary-freshness` check flags staleness; `buildflow --version` vs the BuildFlow repo HEAD.
- **Fix:** `buildflow upgrade`, or from the BuildFlow repo: `nix build .` then copy `./result/bin/buildflow` to `~/.local/bin/buildflow` and verify `buildflow --version`.
- **Rule:** a finding or behavior that contradicts current documentation is more likely an old binary than a documentation lie. Verify the binary version FIRST.

## 3. Nix hash mismatch / FOD failures

- `nix build` fails with `got: sha256-…, expected: …` → `buildflow -s nix-hash-fix --fix`. It repairs stale FOD hashes, stale modules, vendor inconsistency, and stale go.mod (with build gates and rollback). Never paste hashes by hand.
- Compile errors during nix build are classified (not hash-repaired) — they indicate flake-input/local-replace version skew; fixing that is a BuildFlow-repo-level task (repin inputs), not a covered-project task.
- Doctor's `fod-hash-freshness` warns at pipeline setup — including pre-commit — when lock files are newer than hash files, with the remedy in the message.
- Multi-package flakes: green nix-build of only `packages.default` proves little; BuildFlow discovers and builds `packages.*` AND `checks.*` targets.

## 4. Result cache weirdness

The detector result cache is content-addressed (SHA-256 over matched input files + config files + tool binary + BuildFlow binary identity), 7-day TTL, on by default. Its blind spot: findings that depend on filesystem state OUTSIDE matched files (e.g. an untracked directory's existence) replay until TTL even after you delete the cause.

- **Bypass for one run:** `BUILDFLOW_NO_RESULT_CACHE=1` (or `--result-cache=false`).
- **Note:** a no-cache run does NOT overwrite the stale entry (tracked as a BuildFlow gap). Surgical purge:
  `nix shell nixpkgs#sqlite -c sqlite3 ~/.cache/buildflow/buildflow.db "DELETE FROM result_cache WHERE value LIKE '%<finding text>%';"`
- After upgrading/rebuilding BuildFlow, all cache entries miss by design (binary hash is part of the key) — a full re-run after upgrade is expected, not a bug.

## 5. Pre-commit hook issues

The hook runs `buildflow --build-mode pre-commit --staged-only` (~5-10s budget) and re-stages formatted files. It does NOT auto-commit or push.

- **Blocked commit:** fix the reported findings and re-stage; the hook re-ran only essential checks.
- **Changelog-only (or otherwise formatter-excluded) commits fail** because every formatter gets zero files → exit 14. Fold the edit into a commit touching at least one covered file.
- **flake.nix must be git-tracked:** `nix fmt` inside the hook reads from the git index — `git add flake.nix` before committing it, or the hook fails.
- **Hook missing/mutated:** `buildflow precommit install` regenerates it.

## 6. Auto-commit daemon (pma)

A daemon commits working trees continuously across `~/projects/*`. Consequences and rules:

- Commits you didn't make are EXPECTED (author `Unknown Author`); never revert them on sight.
- **Known blind spot:** it can report "No uncommitted changes" while `git status` shows modifications/untracked files — never gate anything on the daemon. Before ending a session or tagging a release, run `git status` and commit critical artifacts MANUALLY.
- Repairs executed by the pre-commit run (formatter fixes, nix-checker repairs) can be auto-committed with generic messages — verify with `git log --stat` that a daemon commit contains what you intended.
- Verify each bulk edit in the SAME tool cycle that applies it; the daemon can fossilize a botched edit into history before you notice.

## 7. Findings gate / exit-code semantics

- Default: exit non-zero when error-severity findings REMAIN after repairs (verify-confirmed fixes don't count). `--strict` → warning threshold; `--fail-on none` → off.
- A failed exit with all-steps-succeeded means: read the "N tool(s) reported findings" section, then `buildflow -s <tool> --format finding`.
- `golangci-lint --fix` exiting 1 inside BuildFlow logs at Debug — "unfixable findings remain", not a crash. The custom errcheck fixer runs after it.
- Cancelled runs (Ctrl-C) surface as skipped, not failed — in-flight steps never finished semantically.

## 8. Environment problems

`buildflow doctor` covers: GOEXPERIMENT, dead GOCACHE/mount paths (rewritten at pipeline start by the env guard), go.work path validity, stale go.mod (`go mod tidy -diff` canary), vendor freshness, FOD hash freshness, disk space (project + /tmp), git identity/remote, network reachability, AGENTS.md size.

- Slow `go` spawns (~25s stalls, D-state) → dead `/mnt/buildcache` automount; the env guard rewrites to defaults automatically; doctor explains.
- Missing binaries: tools without their binary are filtered with a visible reason (not a failure). `buildflow list tools --missing` + `nix develop buildflow#tools` (a shell with every orchestrated tool on PATH) to fix availability.

## 9. When triage implicates BuildFlow itself

If the diagnosis is a genuine BuildFlow bug (not a stale binary, not a documented tool quirk):

1. Reproduce minimally (`buildflow -s <tool> -v` output).
2. Record it in the PROJECT's AGENTS.md as a known tool bug (that's where consumers keep them).
3. The fix belongs in the BuildFlow repo — for filing upstream, the verify-before-filing and github-voice skills apply.
