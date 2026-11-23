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
- **Sandboxed probe battery (2026-11-23, T103; CLI pinned
  `pnpm dlx skills@1.5.22`, fake `$HOME` + `$XDG_STATE_HOME`):**
  - **`skills remove --all -g` is symlink-safe but lockfile-leaky.** The
    scan adds only `entry.isDirectory()` entries, so untracked symlinks
    (the repo-skill fan-out shape) are invisible to it: real-dir skills
    are removed from the canonical dir and per-agent dirs, symlinks in
    both `~/.agents/skills/` and agent config dirs survive, and the
    removed skill's LOCKFILE ENTRY SURVIVES too — `remove --all -g`
    leaves a stale entry (v1.5.22). Also: `remove` without `-g` scans
    the CWD, silently finding 0 — always pass `-g` for global work.
  - **The false-green trigger is REPRODUCED and confirmed: per-source
    tree-fetch failure.** With a lock entry whose source cannot be
    fetched, `update -g` prints `✗ Failed to fetch tree for <source>`
    and then concludes `✓ All global skills are up to date` — a fetch
    failure is treated as no-change, not an error. And `skillFolderHash`
    is never consulted by update (local mutations go undetected); the
    hash is bookkeeping, not a drift check. Update the 2026-11-03
    mechanism caveat above: "transient tree-fetch failure" is now the
    confirmed candidate, not just a hypothesis.
  - **"Well-known" providers decoded from source:** when `skills add
    <https-url>` gets a non-github/gitlab/huggingface URL, it probes
    `{origin}/.well-known/agent-skills/index.json` then
    `/.well-known/skills/index.json` (at the URL path and at the root;
    10s timeout; `X-Skills-Update-Check: 1` header) per the
    agentskills.io discovery schema 0.2.0 — i.e. any self-hosted site
    can be a skills source by publishing that index.
  - **Lockfile location:** `$XDG_STATE_HOME/skills/.skill-lock.json`,
    fallback `~/.agents/skill-lock.json` — a probe HOME alone does NOT
    relocate the lockfile; export `XDG_STATE_HOME` too (this machine's
    real path is `~/.local/state/skills/`, so the owner env sets it).

## 2026-09-14 merge assessment — full record (moved from AGENTS §5.5, T148)

The assessment found NO further skill-directory merges warranted but closed
three gaps, in full detail:

1. **architecture-review ↔ architecture-visualization** — companion pair
   sharing the `docs/architecture-understanding/` output directory — review
   judges (rubric + roadmap), visualization draws (D2); two-way
   disambiguation added in both descriptions + Related Skills sections.
2. **status-report ↔ brutal-self-review** — trigger-collision zone ("what's
   fucked up" vs "what's stupid/could be better") and empirically blended
   (16 of 66 `docs/status/` reports are session self-reviews, e.g. the
   2026-09-13 report is literally both in one document) — kept separate
   (state inventory vs quality critique are different questions) with
   two-way disambiguation added; the blending frequency was measured once
   (2026-09-14: 16 of 66 reports carried "self-review" in the filename) —
   a point-in-time observation, not a maintained count.
3. **brutal-self-review/references/go-ecosystem.md** — an orphaned stale
   fork of `how-to-golang`'s library domain: it still recommended
   `LarsArtmann/uniflow` as the errors library after how-to-golang's
   2026-08-21 correction marked it uncompilable at @latest; deleted
   (SKILL.md's delegation to how-to-golang, line ~63, is the only path and
   was already in place).

## Growth & Sales stack — sourcing doctrine detail (moved from AGENTS §5.5, T148)

- **first-customers**: page-conversion and PLG numbers are pinned to their
  sources inline (Unbounce 2024, CXL, ProductLed 2022); the payments
  reference records the 2026 market state (Stripe acquired Lemon Squeezy
  2024, Stripe Managed Payments; Lemon Squeezy 5% + 50¢/txn verified from
  the live pricing page 2026-10) with a verify-before-relying note.
- **offer-page**: every conversion number traces to a named primary
  (Unbounce CBR, Baymard, NN/g, Journal of Retailing / Marketing Science
  DOIs, EU DSA Art. 25, FTC 16 CFR 465) or carries an explicit
  unverified/secondary marker; `voice-and-gates.md` carries the
  unverified-number ledger (HubSpot "+202%", Crazy Egg "+64%", Basecamp
  "60 seconds", Spiegel "270%") and page-anatomy.md owns the corrected CTA
  myth (the circulating "+68%" is wrong; the archived ContentVerve primary
  says +213.16%).
