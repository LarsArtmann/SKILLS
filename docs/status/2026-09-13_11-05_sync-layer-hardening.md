# Sync-Layer Audit & Hardening — 2026-09-13

**Session type:** improvement (user: "How do we make sure this project and .agents is in sync?!" → "Can we improve anything!?")
**Scope:** the §5.10 runtime-sync model end to end, plus encoding the one unprocessed feedback file.

## TL;DR

Sync model verified healthy (all 29 repo skills symlinked, `--check` green), then
three real gaps in the guard script were found and closed, and the 2026-09-11
feedback file's four incidents were encoded into the skills they implicate.
Quality gate green (`check-skills.sh` exit 0).

## Findings

### f1. Third-party layer had drifted from documentation

- Lockfile grew 14 → 15 entries since the 2026-08-21 verification documented in
  AGENTS.md §5.10: `product-launch-video` (heygen-com/hyperframes) was added,
  making it a 10-skill HeyGen suite.
- **`~/.agents/skills/.git` was undocumented**: the aggregation dir is itself a
  git repo (remote `git@github.com:LarsArtmann/agent-skills.git`, single commit
  "feat: version the skill aggregation layer", 2026-09-05, 504 tracked files —
  own skills as symlink entries, third-party as real files). Four newer repo
  skills (`collector-extraction`, `github-voice`, `jj-fork-pr-workflow`,
  `linter-building`) are untracked there. Cosmetic, not drift — but future
  sessions would have misread it. Both facts now in AGENTS.md §5.10.

### f2. `link-skills-to-agents.sh --check` was one-directional

It verified repo → runtime only. Three failure modes were unguarded:

| Guard                                                    | Failure mode it closes                                                                                              | Evidence                                                                                 |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Reverse orphan sweep (`--check` exit 1, `--list` ORPHAN) | Rule-5 leftover: skill `git rm`'d from repo but symlink left in runtime                                             | sandbox: aliased + dangling symlinks both caught                                         |
| Lockfile collision guard (`--check` exit 1)              | Rule-2 precondition: an own skill tracked by the skills CLI gets its symlink `rm -rf`'d by the next `skills update` | sandbox: fake lockfile with `code-quality-scan` detected; override via `SKILLS_LOCKFILE` |
| Aggregation-repo hint (repair mode)                      | New/changed symlinks silently untracked in the `agent-skills` repo                                                  | sandbox: NOTE printed only when `.git` present AND something changed                     |

All sandbox-tested via `AGENTS_DIR=/tmp/lk-test`; live `--check` against the real
runtime dir still exits 0. Test sandbox discarded (disposable state, no evidence
cited from it beyond the behaviors above).

### f3. Feedback `2026-09-11_quality-session-four-failure-modes.md` was unprocessed

All four incidents encoded, file archived to `docs/feedback/processed/`:

| Incident                                           | Encoded in                                                                                         |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 1 — agent-summarized fetch hallucinated exact URLs | `verify-external-claims` §0 (new fabrication class, alongside constructed URLs)                    |
| 2 — `grep -q` + pipefail SIGPIPE trap              | `how-to-write-skills.md` → Hard-Won Process Lessons                                                |
| 3 — stale cache served green after tool upgrade    | `code-quality-scan` step 5                                                                         |
| 4 — scripted edit silently deleted code            | `how-to-write-skills.md` → Hard-Won Process Lessons (diff accountability + shellcheck-before-done) |

## Verification

- `./scripts/link-skills-to-agents.sh --check` → exit 0 (live dir)
- Sandbox matrix: clean pass / orphan fail / lockfile-collision fail / hint on
  change-with-.git — all as designed
- `scripts/check-skills.sh` → exit 0 (29 skills, no broken links)
- shfmt + `bash -n` on the modified script

## Open items

- ROADMAP g-lines about `--check` enforcement level (manual vs CI) remain user
  decisions — untouched.
- The `agent-skills` aggregation repo has 4 untracked symlinks; owner action
  (commit there) — the script now hints at this whenever it changes links.
