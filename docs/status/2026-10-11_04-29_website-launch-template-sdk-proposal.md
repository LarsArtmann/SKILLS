# Website-Launch Template → Real SDK: Analysis & Proposal

**Date:** 2026-10-11 04:29 · **Scope:** the `website-launch` skill's site-creation
mechanism (Phase 3 + file manifest + version/color references) and how an
actual template + SDK would replace it · **Mode:** proposal / architecture
decision document — nothing implemented yet · **Trigger:** user question
"How can we improve our website-launch template? Maybe with an actual SDK?"

> Every claim below was verified this session (verification log in the
> Appendix) or is attributed to its source document. Claims inherited from
> older reports are marked as such.

---

## TL;DR

The skill has **no actual template**. Phase 3 instructs the agent to copy
~47 files out of the **live gogenfilter repository** (94 files on disk) and
edit them by hand — the skill even documents the resulting drift failure
(pitfall #4: copying gogenfilter's stale `vite: 7.3.2` pin breaks Astro 7
builds). Meanwhile the existing template ecosystem (`templates` CLI hub,
`template-CLI` SDK) is not a viable foundation: **re-verified today**, the
`templates` CLI still fails its own tests on hardcoded macOS paths (the
exact failure the 2026-05-22 review documented, unfixed after 5 months),
and `template-CLI` has **zero consumers** (no `go.mod` in `~/projects`
imports it except its own).

**Recommendation (Option A):** a new canonical `website-template` repo
(gogenfilter's Astro site extracted and parameterized, kept permanently
CI-green) plus a small purpose-built `websitelaunch` CLI
(`doctor`/`init`/`check`/`retrofit`) living in that repo. The skill sheds
~1,000 lines of mechanics to the tool, keeps the judgment work, and 18
launched sites gain a mechanical retrofit path. This also answers the
ROADMAP's standing "should website-launch be refactored?" question — the
prior trim attempts kept losing because they moved prose nowhere; the SDK
moves the load out of the skill entirely.

---

## 1. Problem Statement: The "Template" Is a Live Sibling Repo

### 1.1 What Phase 3 actually does today

`website-launch/SKILL.md` (797 lines) + 16 references (3,267 lines) =
4,064 lines of instruction. Phase 3 ("Create the Website") delegates to
`references/file-manifest.md` (196 lines), which classifies the ~47 files
of a website into:

| Class            | Count | Mechanism                                             |
| ---------------- | ----- | ----------------------------------------------------- |
| Copy verbatim    | ~12   | Copy as-is from `~/projects/gogenfilter/website/`     |
| Customize fields | ~15   | Copy from gogenfilter, edit name/URLs/accent/sidebar  |
| Write fresh      | ~20   | Project-specific content, "follow gogenfilter pattern"|

So the de-facto template is **gogenfilter's working tree**, read at launch
time. Three structural consequences:

1. **The baseline is a moving target.** gogenfilter evolves for
   gogenfilter. Every launch inherits whatever state that repo happens to
   be in — including stale pins, as pitfall #4 documents ("Pinning
   `vite: 7.3.2` (copied from gogenfilter's older lockfile) causes a build
   failure"). That is not a one-off: it is the *designed* failure mode of
   copy-from-a-live-repo.
2. **The version matrix is prose.** `references/dependency-versions.md`
   (186 lines) duplicates, in markdown, what a canonical `package.json`
   would say once. Two sources of truth = guaranteed split brain.
3. **Verification is re-invented per launch.** Phase 4's build check,
   visual QA gate, and `references/definition-of-done.md` (74 lines) are
   executed by agent discipline every time, from instructions, not from a
   tool that fails loudly.

### 1.2 The skill carries mechanics it shouldn't

The 22-item Common Pitfalls list (`SKILL.md` lines 730–797) is largely a
bug catalog of mechanical steps: nix-shell invocation shapes (#3), which
lockfile to commit (#7, #20), branch names in workflow YAML (#18),
license consistency across 4 files (#19), Firebase REST endpoint details
(#14). Each of these is a check or a code path begging to exist — prose
is the wrong medium for them.

### 1.3 Prior art in the repo agrees

- **ROADMAP open question** (line ~148): "Should `website-launch` stay at
  848 lines or be refactored? … Trim path exists (TODO T11); it keeps
  losing to feature work." The trim keeps losing because deleting prose
  without relocating the load is pure loss. This proposal relocates it.
- **TODO T33** overlaps: "CI deploy workflow to kill the manual-deploy
  class" and "emeet og:image-from-poster upgrade" are both template-level
  concerns that a canonical template solves once for all repos.

---

## 2. Existing Template Ecosystem: Audited, Not Usable (yet)

`~/projects/` contains a whole template ecosystem the skill ignores.
Verified state today:

### 2.1 `templates` (CLI hub) — broken on this machine

- 26,617 Go lines, discovers/applies `template-*` repos
  (per `review-templates-vs-template-CLI.md`, 2026-05-22).
- **Re-verified 2026-10-11:** `go test ./...` FAILS —
  `template_integration_basic_test.go:28: Expected default templates dir
  '/Users/larsartmann/projects', got "/home/lars/projects"` (plus the same
  class in `pkg/types`). The exact hardcoded-macOS-path failures the May
  review documented as P0 #1, **unfixed after 5 months**. The hub cannot
  be a dependency for anything until its own tests run on Linux.

### 2.2 `template-CLI` (the "SDK") — zero consumers

- 51,706 Go lines, graded C+ by the May review: "a well-engineered SDK
  searching for a user base", 13 packages at 0% coverage.
- **Re-verified 2026-10-11:** grepping every `~/projects/*/go.mod` for
  `LarsArtmann/template-CLI` matches **only its own go.mod**. Still zero
  consumers.
- The May review's own P2 recommendation is that `templates` should
  become the *first* consumer — not website-launch. Making a content
  workflow the first dependency injection testbed of an unstable SDK
  couples two bets.

### 2.3 `go-website-template` — a different stack

- Verified from its README: Go + Templ + HTMX + Tailwind on **Cloud Run**
  with a server binary — the dynamic-site pattern (emeet-class product
  sites), not the Astro + Starlight + Firebase static docs pattern. Not a
  candidate baseline; naming collision risk for the new repo (§7 Q1).

### 2.4 `template-*` repos — heavyweight ceremony

- e.g. `template-readme` carries `baseline_*.log` files, BDD test
  reviews, AUTHORS, coverage dir. Joining this family means inheriting
  its conventions (and, eventually, the hub's orchestrator). Fine later;
  not a prerequisite.

**Conclusion:** the ecosystem exists but its center is broken and its SDK
is unconsumed. Website-launch should not couple to either today (§4
Option B), but should leave the door open (§7 Q1).

---

## 3. Scale of the Win: 18 Launched Sites

Verified: `ls -d ~/projects/*/website` → **18 repositories** with a
`website/` dir (art-dupl, clean-wizard, cmdguard, dynamic-markdown-site,
emeet-pixyd, go-atomic-write, go-branded-id, go-error-family,
go-filewatcher, gogenfilter, go-output, go-workflow-auditlog,
hermes-agent, learnings, md-go-validator, + 3 more past the sample).

Today every one of them is retrofitted via the skill's §0.0
maintenance-mode **manual** checklist ("audit for nice-docs patterns…
demo video retrofit…"). With a canonical template:

- `websitelaunch retrofit` diffs a site against the current template and
  reports drift (missing CSP headers, stale pins, missing og:image-from-
  poster, missing cache headers for `mp4|webm`) — the §0.0 audit becomes
  a command with exit codes.
- Template improvements propagate visibly: one PR in one repo, then a
  per-site diff instead of 18 re-reads of gogenfilter.

---

## 4. Options Considered

| # | Option | Verdict | Reason |
| - | ------ | ------- | ------ |
| A | **New `website-template` repo + small purpose-built `websitelaunch` CLI** | **PICK** | Fixes drift at the root (canonical, CI-green baseline); pitfall list becomes code; skill shrinks; no coupling to broken ecosystem |
| B | Build the scaffold **on `template-CLI`** (the literal "actual SDK") | Reject (for now) | Zero consumers, C+ grade, 0% coverage in 13 packages; wrong first consumer (May review P2 says `templates` goes first). Revisit after that integration lands |
| C | **Vendor the template into the skill** as `assets/` (html-report-kit model) | Reject | Vendoring exists so per-skill installs work for third parties; website-launch is Lars-machine-only (already assumes `~/projects/domains`, gogenfilter). A 94-file Astro project + `pnpm-lock.yaml` inside a docs-only repo violates §9 spirit and bloats every install |
| D | Keep skill-only; add `scripts/` (`preflight.sh`, `verify.sh`) to the skill dir | Partial | The cheap subset of A — but the template *repo* is the part that fixes the drift class; scripts without a canonical baseline just polish the copy step. Fold into A |

---

## 5. Recommended Architecture (Option A)

### 5.1 `website-template` repo — the canonical skeleton

- **Source:** gogenfilter's `website/` extracted verbatim, then
  parameterized. Placeholders shrink to ONE data file (`src/data/config.ts`)
  plus a handful of template variables (`{{SUBDOMAIN}}`, `{{SITE_ID}}`,
  `{{BRANCH}}` in the workflow YAML, `{{TARGET}}` in firebase configs).
- **Self-test in CI:** every PR runs `pnpm install --frozen-lockfile`,
  `astro check`, `astro build`, `html-validate dist/**`. The template
  **cannot rot silently** — pitfall #4's class dies here, permanently.
- **Version matrix dies:** `dependency-versions.md` (186 lines of prose
  pins) is replaced by the template's committed `pnpm-lock.yaml`. One
  bump = one PR = visible to every future launch.
- **Color palette dies as prose:** `color-palette.md` (314 lines of
  precomputed token tables) becomes a `palettes/` dir in the template —
  `--accent amber` copies the precomputed token set, unchanged.
- **Nix-first:** `flake.nix` with a devShell and the CLI as an app
  (`nix run github:LarsArtmann/website-template#websitelaunch -- …`).

### 5.2 `websitelaunch` CLI — small, purpose-built, in the template repo

Go, stdlib-only, single module, hard-capped small (see Risks R3). Four
subcommands, each mapping to a skill phase:

| Subcommand | Replaces | What it does |
| ---------- | -------- | ------------ |
| `doctor`   | Phase 0 (§0.0–0.5) | Existing-site detection, credential/API-key checks, `firebase projects:list` + hosting-site collision, DNS + `gh repo` name-collision grep, `gh secret list` (pitfall #16 pre-check). Prints blockers as What/Why/Fix |
| `init`     | Phase 3 + file-manifest.md | Clone/copy template into `{repo}/website/`, substitute flags: `--name --repo --type library\|application --accent --subdomain --site-id --firebase shared\|standalone --branch [--csp] [--og]`. Emits `.npmrc` only when needed (pitfall #5), correct `.firebaserc`/`firebase.json` shape per shared-vs-standalone table (§0.1) |
| `check`    | Phase 4 + definition-of-done.md + visual-QA gate | `astro check` = 0 errors, `html-validate`, lockfile present + package-manager consistency (#7, #20), `GOEXPERIMENT=jsonv2` documented if `go.mod` needs it (#8), license consistency across LICENSE/`.goreleaser.yaml`/`flake.nix`/`package.json` (#19), og:image 1200×630, mp4 cache headers, video-present-on-landing. **Advanced:** extract `hero-code.ts` and compile the snippet in a scratch module (pitfall #15, mechanized) |
| `retrofit` | §0.0 maintenance audit | Diff an existing site against current template; report drift as actionable checklist |

All nix-shell wrapping (`pnpm`/`node`/`firebase` not in PATH, pitfall #3;
re2-vs-bun #11; terraform unfree #2) lives **inside the CLI**, so the
skill stops repeating invocation shapes per command.

### 5.3 What the skill keeps vs sheds

**Keeps (agent judgment work):**

- Phase 1 research + code-example verification discipline (grep-driven)
- Phase 2 README rewrite (value proposition, one sales narrative)
- §0.4 domain-confirmation human gate — stays a human gate
- §3.11 demo video (routing to HyperFrames) — creative work
- The ~20 write-fresh content files (features, hero copy, docs pages)
- Common-pitfall entries that are *content* mistakes, not mechanics (#6
  MDX escaping, #13 commit-before-confirm, #15 honesty rule, #17 stale
  root docs, #21 wrong-framework claims, #22 video in /tmp)

**Sheds (→ template or CLI):**

| Skill artifact | Lines | Goes where |
| -------------- | ----- | ---------- |
| `references/file-manifest.md` | 196 | `init` (classification becomes code) |
| `references/dependency-versions.md` | 186 | template `pnpm-lock.yaml` |
| `references/color-palette.md` | 314 | template `palettes/` dir |
| `references/definition-of-done.md` | 74 | `check` |
| `references/ci-workflow.md` | 151 | template `.github/workflows/website.yml` |
| Phase 3 body in SKILL.md | ~150 | `init` + "write the fresh files" |
| `references/website-creation-details.md` | 119 | mostly (favicon/MDX bits stay) |
| `references/common-pitfalls.md` | 588 | mechanical half → CLI checks |

Fully-absorbed references alone: ~921 lines; with partials, well over
1,200 lines move out of agent context into executable form. SKILL.md
drops under the 500-line guideline with room for the sales-video
expansion to *stay*.

### 5.4 Answers the ROADMAP refactor question

"Trim path exists; it keeps losing to feature work" — because trimming
was zero-sum. Option A is positive-sum: the lines don't get deleted, they
get **executed**. Recommend closing that open question with this decision.

---

## 6. Migration Plan (incremental, reversible at every step)

1. **Extract** — create `website-template` from gogenfilter's website;
   parameterize; CI green from a clean checkout (this is the
   acceptance test: it must build on a machine that has never seen
   gogenfilter).
2. **`doctor`** — standalone value even before `init`; Phase 0 as code.
3. **`init`** — scaffold end-to-end; smoke-test by scaffolding a scratch
   repo and building it.
4. **`check`** — codify DoD + Phase 4; run against gogenfilter itself as
   the first guinea pig (its drift findings validate the checker).
5. **Skill slim** — one session: Phase 3 → scaffold instructions, absorb
   references, update FEATURES.md row, re-run `scripts/check-skills.sh`,
   update ROADMAP (close the 848-lines question) and TODO T33 (fold the
   CI-deploy-workflow item into template work).
6. **Dogfood** — next real launch uses it exclusively; fixes flow back
   to the template repo, not the skill.
7. **`retrofit` sweep** — run across the 18 sites; prioritize
   security-header/CSP gaps and og:image-from-poster (T33 overlap).

Rollback at any step = keep using the skill as-is; the template repo
existing harms nothing.

---

## 7. Risks & Open Questions

### Risks

| # | Risk | Mitigation |
| - | ---- | ---------- |
| R1 | Template itself ossifies into a new stale baseline | CI builds every PR; every `init` consumes latest; gogenfilter can later be rebuilt ON the template so there is only one baseline |
| R2 | Two baselines during transition (gogenfilter + template) | Time-boxed: template becomes the sole baseline at the dogfood launch (step 6); skill drops gogenfilter-as-baseline, keeps it as design reference only |
| R3 | CLI scope-creeps into a `template-CLI`-scale SDK (51k lines, 0 users) | Hard constraints: stdlib-only, single module, ~<2k lines, four subcommands. The 2026-05-22 review is the cautionary tale pinned in the repo's AGENTS |
| R4 | Astro/Tailwind major bumps churn the template | That's the point: one PR in one repo replaces N manual per-launch migrations; CI proves each bump |
| R5 | Name collision with `go-website-template` confuses humans | Pick a distinct name (Q1) |

### Open questions (need Lars' decision before step 1)

1. **Repo name:** `website-template`? `template-website` (joins the
   `template-*` family, implies eventual hub integration)? Something
   else that avoids the `go-website-template` collision?
2. **CLI language:** Go (preferred — flag parsing, Firebase REST calls,
   single binary via nix, matches the repo's stdlib-only Go convention)?
   Or start as plain bash in the template repo (faster, less structure)?
3. **gogenfilter's fate:** eventually rebuild it on the template (one
   baseline), or leave it hand-maintained as the "design playground"?
4. **Visibility:** private (embeds lars.software conventions, domains
   repo paths) — publishable later once placeholders are clean?
5. **Sequencing vs T33:** fold T33's CI-deploy-workflow and og:image
   items into template milestones, or keep them separate?

---

## 8. Appendix: Verification Log (all run 2026-10-11 ~04:00–04:30)

| # | Claim in this report | How verified |
| - | -------------------- | ------------ |
| 1 | SKILL.md = 797 lines; 16 references = 3,267; total 4,064 | `wc -l website-launch/SKILL.md references/*.md` |
| 2 | Phase 3 copies from live gogenfilter; 94 files on disk | `SKILL.md` §3.1/§3.2 + `file-manifest.md`; `find ~/projects/gogenfilter/website -type f` (excl. node_modules/dist/.firebase) = 94 |
| 3 | Pitfall #4 vite-pin drift documented | `SKILL.md` lines 742–747 |
| 4 | 18 repos have `website/` | `ls -d ~/projects/*/website \| wc -l` = 18 |
| 5 | `templates` CLI tests fail on hardcoded macOS paths, today | `cd ~/projects/templates && go test ./...` → FAIL (`Expected default templates dir '/Users/larsartmann/projects', got "/home/lars/projects"`) |
| 6 | `template-CLI` has zero consumers | `grep -rl LarsArtmann/template-CLI ~/projects/*/go.mod` → only its own go.mod |
| 7 | `go-website-template` is Go+Templ+HTMX on Cloud Run (different stack) | its README, read this session |
| 8 | May review grades/quotes (B- templates, C+ template-CLI, "searching for a user base") | `~/projects/review-templates-vs-template-CLI.md` (2026-05-22) — point-in-time doc; items 5 & 6 above re-verified the load-bearing parts |
| 9 | ROADMAP open question "848 lines / refactor?" | `ROADMAP.md` ~line 148, quoted this session |
| 10 | TODO T33 overlap (CI deploy workflow, og:image) | `TODO_LIST.md`, read this session |

**Not verified this session** (and marked as such above): the template-*
repo ceremony description is from directory listings only; the May
review's per-package coverage numbers were not re-measured.

---

## 9. Decision Requested

Approve Option A (template repo + purpose-built CLI) and answer §7 Q1–Q5?
On approval, this becomes TODO_LIST rows (per docs-health: this file is a
proposal, not a task list) and step 1 (extraction) can start immediately —
it touches no existing repo beyond reading gogenfilter.
