# Skill Forks & Third-Party Skill Provenance

> Extracted from AGENTS.md §5.5/§5.10 (2026-11-22, TODO T148) so the always-loaded
> context file stays lean. This file carries the FULL provenance of local forks
> and third-party skill relationships. AGENTS.md keeps one-line pointers.

## architecture-deepening — local fork of improve-codebase-architecture (2026-11-15)

`architecture-deepening` is a **local fork, not a wrapper** of the third-party
`improve-codebase-architecture` skill (mattpocock/skills), and that third-party
copy was removed from the skills-CLI install the same day (aggregation commit
`fa4aeec`). Three findings forced the fork:

1. **Missing siblings.** The upstream skill's first instruction is to call
   sibling skills `codebase-design`, `grilling`, and `domain-modeling`, which a
   per-skill `skills add` never installs — observed missing on this machine, so
   the skill had no vocabulary and no interview loop. (Upstream issue candidate:
   TODO T141.)
2. **tmpdir artifact.** It hard-codes the report to the OS temp directory
   (`/tmp` on Linux, tmpfs), so the artifact dies at reboot — filed upstream as
   mattpocock/skills#1437. The local copy writes to `docs/architecture-understanding/`
   with `ARCH_DEEPENING_OUT` as override.
3. **CDN rendering.** It renders through CDN Tailwind + Mermaid, which conflicts
   with this repo's self-contained HTML doctrine (AGENTS §5.9); the local copy
   uses the vendored `html-report-kit`.

The three sibling skills' necessary content lives in the fork at
`references/deepening-vocabulary.md` (glossary including **port**, deletion
test, dependency categories with a worked internal-seam-vs-port example,
replace-don't-layer testing), `references/design-it-twice.md` (the
parallel-subagent interview), and SKILL.md step 5 (frontier-round grilling).
Do not re-install the upstream family without first reconciling, or the two
designs will diverge.

- Brief shape fixture: `architecture-deepening/assets/sample-candidate-brief.html`
- Routing evidence: `architecture-deepening/evals/probe-2026-11-17.md`
  (fresh-session probes after the removal: discovery + three routing prompts, 3/3 correct)
- Ownership boundary: `architecture-review` grades the whole structure,
  `architecture-visualization` draws current vs target with D2,
  `architecture-deepening` shortlists refactor candidates and grills the chosen
  one — all three share `docs/architecture-understanding/` and cross-reference
  each other in both directions.
- Open: T150 (stay upstream-synchronised via periodic diff vs freeze as
  owned-here), T151 (keep the third-party original removed globally or
  reinstall for other agents/machines).

## Third-party install channel: modern-web-guidance (MWG)

`modern-web-guidance` — Google Chrome's web-platform guide library
(`search` / `list` / `retrieve` over ~192 Baseline-aware use cases) — is a real
directory in `~/.agents/skills/`, installed by its own installer and lockfile
(`~/skills-lock.json`, NOT the skills-CLI lockfile): "third-party" means
upstream-owned, not "tracked by one particular tool". Install/update from
`$HOME`: `pnpx modern-web-guidance@latest install|update` (`pnpx` verified;
`npx -y …` fallback where pnpm is absent). Uninstall verified 2026-11-22
(TODO T60): removes the directory AND empties the lockfile entry; snapshot
restored byte-identical afterwards.

- The installer is **project-scoped**: running it inside a repo writes that
  repo's `./.agents/skills/<skill>` plus `skills-lock.json` (done by mistake
  2026-10-30; both trashed). `skills update -g` never touches the global copy.
- Do not author a wrapper skill here: upstream's `SKILL.md` is the instruction
  set, and a local copy would stale against a library Google ships continuously.
  It shells out to the CLI for `search`/`retrieve` (the installed `guides/`
  tree is not read directly); `pnpx --offline … retrieve <id>` works without
  network thanks to pnpm caching.
- MWG policy (2026-10-30): one global install at `$HOME`; the installed tree
  is committed to the aggregation repo so it stays a complete machine
  inventory; telemetry off via `export DISABLE_TELEMETRY=1` in `~/.env.private`
  (sourced by home-manager's `~/.config/zsh/.zshenv`).

## skills-CLI operational findings (third-party skill management)

- **`skills update` can report a false green** (hit 2026-11-03): "All global
  skills are up to date" while `anthropics/skills` HEAD had evolved ~7 months
  past the installed `frontend-design`. Reliable refresh = re-add:
  `skills add <owner>/<repo>@<skill> -g -y`. Verify freshness by diffing the
  installed file against `gh api repos/<owner>/<repo>/contents/<path> -H
  "Accept: application/vnd.github.raw"`, never by trusting update output.
- **Mechanism caveat (2026-11-03, verify-before-filing pass):** the first
  diagnosis ("compares installed-folder hashes, no ref pin") was WRONG against
  the CLI source read the same evening (`vercel-labs/skills`, `src/update.ts` +
  AGENTS.md "Update Checking System"): the current check fetches the live
  upstream tree SHA per locked path and supports ref pinning; a live
  `skills check -g` run correctly flagged 6 stale skills. The actual trigger is
  unconfirmed — candidates: older CLI version, lock entry predating
  `skillFolderHash`/`skillPath` (silently skipped), transient tree-fetch
  failure. Do not file upstream on the old mechanism claim; if the false green
  recurs on the current CLI, capture `skills check -g` output + the lockfile
  entry first.
- **Upstream moves can strand local copies:** after upstream moved references
  from `hyperframes-core/` into `hyperframes/`, the CLI warned that 7
  hyperframes-suite skills "appear to have been deleted upstream" and skipped
  deletion in non-interactive mode — a future interactive `skills update -g`
  could remove locally-installed copies; re-add per skill if that happens.
- **Skill discovery is a session-start snapshot:** an install is invisible to
  already-running sessions. Verified 2026-10-30 via `crush logs` + a fresh
  `crush run` probe. Never judge an install by the current session's skill
  list — probe a new session.
