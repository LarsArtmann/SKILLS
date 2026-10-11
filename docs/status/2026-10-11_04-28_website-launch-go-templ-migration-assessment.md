# Assessment: Migrate website-launch Template to Go + templ + templ-components

**Date:** 2026-10-11 04:28 · **Scope:** `website-launch` skill vs the Go SSG at
`~/projects/templ-components/website/` · **Mode:** exploration (user asked
"what do you think?" — analysis only, **no files were edited**)

> **Extended (08:30):** a parallel proposal (04:29 — Astro template repo +
> SDK, different author/session) and the reconciliation composing both live at
> `2026-10-11_04-29_website-launch-template-sdk-proposal.md` and
> `2026-10-11_08-30_website-launch-two-proposal-reconciliation.md`. Read those
> before acting on this report alone — the unified plan is gated on one
> decision (extraction baseline) tracked as TODO T57.

## TL;DR

**Migrate — yes.** The deciding fact: the target stack is not a proposal, it
is already live. `templcomponents.lars.software` has run a pure Go
static-site generator (templ + goldmark + chroma + the library's own
components) since **2026-09-13**, with golden tests, hash-pinned CSP, a
link/anchor checker, and `llms.txt`. Meanwhile the skill still describes
Astro + Starlight as "the pattern shared across all LarsArtmann projects" —
already false. Every new Astro launch from this skill adds to future
migration debt.

The real blocker is not the skill rewrite — it is that the Go SSG is bespoke
to the templ-components repo (replace directives, `--repo-root ..` scanning,
hardcoded landing/sales sections). Phase the migration: extract → parameterize
→ pilot on one site → surgical skill rewrite.

---

## 1. Current State (measured, not assumed)

### 1.1 The skill today

| Asset                     | Size / state                                                                                                            |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `website-launch/SKILL.md` | 797 lines (ROADMAP's "848" figure is stale; measured 2026-10-11)                                                        |
| 15 reference files        | 3,267 lines (4,064 total with SKILL.md)                                                                                 |
| `evals/iteration-1/`      | old-skill vs new-skill output comparisons + grading — **any stack migration must re-run these**                         |
| Baseline repo (Phase 3.1) | `gogenfilter/website` (CSP hardening, OG images, two-job CI); `go-atomic-write` is the older simple pattern             |
| Stack-pinned claims       | description + body name "Astro + Starlight + Tailwind v4 + Firebase Hosting ... shared across all LarsArtmann projects" |

### 1.2 Where sibling project sites actually live (verified 2026-10-11)

| Repo                  | Stack                                                                                | Evidence                                |
| --------------------- | ------------------------------------------------------------------------------------ | --------------------------------------- |
| go-atomic-write       | Astro (pnpm)                                                                         | `website/package.json` exists           |
| gogenfilter           | Astro (pnpm)                                                                         | `website/package.json` exists           |
| go-output             | Astro (pnpm)                                                                         | `website/package.json` exists           |
| go-workflow-auditlog  | Astro (pnpm)                                                                         | `website/package.json` exists           |
| dynamic-markdown-site | Astro (pnpm)                                                                         | `website/package.json` exists           |
| art-dupl              | Astro (pnpm)                                                                         | `website/package.json` exists           |
| samber-do-auditlog    | Astro (pnpm) — plus an unrelated in-app `html.templ` (audit viewer UI, not the site) | `website/package.json` exists           |
| **templ-components**  | **Pure Go SSG** (since 2026-09-13)                                                   | `website/go.mod`, **no** `package.json` |

**7 Astro sites, 1 Go site.** The "shared pattern" claim in the skill is
already inaccurate, and the one Go site is the newest, most heavily tested
site in the portfolio.

### 1.3 The existing Go SSG (`~/projects/templ-components/website/`)

Read directly; this is the reference implementation a migration would
generalize.

- **Stack:** `cmd/site` single binary; `a-h/templ v0.3.1020`, `goldmark v1.8.6`
  - `goldmark-highlighting/v2` (chroma v2.27.0), `templ-components v1.21.0`
    (+ errorpage, icons, utils modules). Tailwind CSS v4 via the standalone
    `tailwindcss` CLI (nix devShell locally; CI currently installs
    `@tailwindcss/cli`).
- **Self-description:** "the site is the library's largest dogfood consumer" —
  every page renders through the library's own components. The old
  Astro/Starlight/pnpm site was fully removed 2026-09-13.
- **Structure:** `internal/build` (build, csp, links, llms, search — each with
  `_test.go`), `internal/md` (goldmark pipeline), `internal/pages` (9 `.templ`
  files: landing, docs, hero, header, footer, base, sales, sections,
  notfound), content in `content/docs/**/*.md`.
- **Quality machinery already shipped:**
  - Golden-file tests (`testdata/*.golden` for landing/docs/sales/notfound).
  - CSP hash pinning: `go run ./cmd/site --update-csp` refreshes the pinned
    header in `firebase.json`; **the build fails on drift**. This replaces the
    Astro pattern's `fix-csp.mjs` HTML post-processor with a first-class,
    tested mechanism.
  - Link/anchor checker (`links.go`).
  - Client-side search: `dist/search-index.json` (lazily fetched by
    `/assets/js/search.js`) with per-heading `SearchSection` anchors;
    `PlainText()` strips scripts/styles/tags, decodes entities.
  - `llms.txt` (llmstxt.org shape) generated from the same parsed metadata as
    the search index "so the two indexes can never disagree". **Starlight has
    no equivalent — this is an upgrade, not parity.**
  - Deterministic-build discipline: GitHub stars badge defaults to a
    deterministic fallback (`--skip-stars`); live count (`SITE_LIVE_STARS=1`)
    is production-only, because a live count "flakes every route golden
    containing the badge".
  - Deploy target: same Firebase Hosting (`firebase.json` in `website/`) — the
    skill's Phases 5–7 (DNS/Terraform/domain) are untouched by the migration.

---

## 2. Parity Analysis: Starlight features vs Go SSG

| Starlight feature                       | Go SSG status                                                                                                                                                             |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Full-text search (Pagefind)             | ✅ Equivalent shape: prebuilt JSON index + section anchors, no third-party binary                                                                                         |
| Dark mode                               | ✅ `ThemeScript` (FOUC-safe) + `ThemeToggle` from the library                                                                                                             |
| Syntax highlighting                     | ✅ chroma via goldmark-highlighting                                                                                                                                       |
| Sidebar docs navigation                 | ✅ `docs.templ` + `SidebarNav`/`Nav` components                                                                                                                           |
| Sitemap + lastmod                       | ✅ registered per-page (`internal/pages/doc.go`)                                                                                                                          |
| OG images                               | ✅ per-page `OGImage` (`/og/{slug}.png`, `/og/home.png`, `/og/sales.png`)                                                                                                 |
| Security headers / CSP                  | ✅ Better: hash-pinned CSP with drift-failing build vs post-hoc `fix-csp.mjs`                                                                                             |
| `editLink` ("edit this page on GitHub") | ⚠️ **Missing — the only gap that matters.** Trivial to add (repo URL + file path per page)                                                                                 |
| `lastUpdated` display on page           | ⚠️ Present in sitemap lastmod; per-page display needs wiring to git log                                                                                                    |
| RSS                                     | ⚠️ Missing; no current site has a blog — defer until one does                                                                                                              |
| i18n                                    | ❌ Missing; no current site uses it — accept the loss explicitly                                                                                                          |
| MDX                                     | ❌ Gone — and good riddance: MDX-escaping pitfalls are a recurring pain class in `common-pitfalls.md`; plain goldmark markdown + templ components for rich blocks instead |

**Verdict:** the parity gap is `editLink` + per-page lastUpdated display.
Everything else is equal or better. The MDX/i18n losses are features.

---

## 3. Why Migrate (benefits, ranked)

1. **The reference implementation already exists and is live.** This is not a
   greenfield bet — the riskiest part (can a pure Go SSG run a production docs
   site well?) was answered 2026-09-13.
2. **Environment friction disappears.** The skill dedicates a whole section to
   "Nix + Crush constraints": `pnpm`/`node` not in PATH (every build needs
   `nix shell nixpkgs#nodejs -c pnpm ...`), `firebase-tools` shelling, etc. A
   Go SSG builds with `go run ./cmd/site` inside every project's existing
   devShell — same toolchain as the code being documented. CI loses the
   pnpm install/lockfile layers entirely (and can go fully nodeless by pinning
   the standalone `tailwindcss` binary instead of `@tailwindcss/cli`).
3. **Dogfooding flywheel.** Every project site exercises templ-components —
   same argument the library's own README makes. Breaking library changes
   surface as site build failures (compile-time visibility) instead of silent
   runtime drift.
4. **Dependency rot shrinks by an order of magnitude.** `dependency-versions.md`
   (186 lines of hand-verified pnpm pins "known to work together") collapses
   to a Go module matrix + one tailwind CLI pin, all nix-verifiable.
5. **`llms.txt` for free** — machine-readable site index for AI agents/crawlers;
   a real edge for an audience of agents reading his libraries' docs.
6. **Agent-session efficiency.** A large share of `common-pitfalls.md` (588
   lines) is Astro/pnpm/MDX pain. Those sessions get cheaper and the pitfalls
   simply evaporate; new Go-specific pitfalls (templ generation step, `@source`
   scanning, `GOEXPERIMENT=jsonv2`) are already documented in the SSG's own
   README/doc.go and can be lifted.

## 4. Costs, Risks, Tradeoffs (eyes open)

1. **Extraction work is the blocker.** The SSG is repo-coupled: `replace`
   directives to `../`, `--repo-root ..` scanning (its `@source` directives
   scan the _library's_ generated components), hardcoded landing/sales/hero
   sections, `SITE_LIVE_STARS` badge logic tied to one repo. A template needs
   parameterization: project name, accent color, sidebar config, hero content,
   data files — the same "data-driven, copy then customize" contract the skill
   already has for gogenfilter (`src/data/*.ts` → site data).
2. **7 Astro sites remain on the old stack.** Migration creates a two-pattern
   split brain unless handled like §0.0.1 ("Old Static Site Migration") — an
   explicit "Astro legacy maintenance mode" branch: retrofits still apply,
   sites migrate opportunistically, no big-bang rewrite of live sites.
3. **Dogfood coupling cuts both ways.** A breaking templ-components change
   breaks every site build simultaneously. Accepted as a feature (visibility),
   but worth stating: version pins per site, and the replace-directive dev
   pattern catches breakage early.
4. **Eval regression risk.** `evals/iteration-1` graded this skill. A Phase 3
   rewrite must re-run the eval harness on the new baseline before the skill's
   claims are honest again.
5. **One JS-adjacent dependency survives**: the Tailwind v4 CLI. Locally it is
   the standalone binary in the nix devShell (no Node); only CI still installs
   the npm package — solvable by pinning the standalone binary there too.
6. **Skill-rewrite effort is real but bounded** (see §6 disposition table):
   roughly half the reference corpus survives untouched.

---

## 5. Recommended Phased Plan

### Phase A — Extract + parameterize (in the templ-components repo, not SKILLS)

- Extract the SSG from `templ-components/website` into a reusable template:
  either a sibling template repo (e.g. `LarsArtmann/go-site-template`) the
  skill's Phase 3 copies from, or a `cmd/site init` scaffold. Prefer whichever
  keeps the skill's existing copy-based contract (the file-manifest pattern).
- Parameterize: project identity, accent color, sidebar/docs tree, hero and
  landing sections, data files. Keep the golden-test + CSP-pin + link-check
  machinery in the template — every consumer inherits it.
- Close the parity gaps: `editLink`, per-page lastUpdated (git log wiring).
  RSS only when a blog exists. Pin standalone `tailwindcss` in CI.

### Phase B — Pilot (one site, not a fleet)

- Launch the next new project site on the template, or migrate the smallest
  existing one (go-output). Success criteria: Lighthouse parity, search works,
  CSP pinned, deploy green on the same Firebase/DNS pipeline (Phases 5–7 of
  the skill are stack-independent and must pass unchanged).

### Phase C — Surgical skill rewrite

- Add the "Astro legacy maintenance mode" branch (mirrors §0.0.1) for the 7
  existing sites; the retrofit audit stays available to them.
- Swap Phase 3 baseline: template repo replaces gogenfilter as the copy source.
- Rewrite the stack-coupled references (see §6); leave stack-agnostic ones
  byte-identical.
- Re-run `evals/` on the new baseline; only then update the description's
  stack claim.
- Restructure while touching it (answers ROADMAP open question "should
  website-launch stay at 848 lines?"): SKILL.md keeps decision phases
  (0–2, 5–7) and trims toward the 500-line guideline; stack mechanics move to
  references.

### Phase D — Opportunistic fleet migration

- Migrate remaining Astro sites per-site when touched for other reasons
  (content refresh, CSP work, dependency breakage). No calendar-driven
  big-bang; the legacy branch retires when the last Astro site does.

---

## 6. Reference-by-Reference Disposition

| Reference                     | Lines | Disposition                                                                                                                            |
| ----------------------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `readme-template.md`          | 194   | **Survives untouched** (stack-agnostic)                                                                                                |
| `content-patterns.md`         | 232   | **Survives** — minus Astro-component mentions in retrofit section                                                                      |
| `dns-terraform.md`            | 238   | **Survives untouched**                                                                                                                 |
| `firebase-rest-api.md`        | 302   | **Survives untouched**                                                                                                                 |
| `go-live-runbook.md`          | 145   | **Survives** — build command updated                                                                                                   |
| `demo-video.md`               | 276   | **Survives untouched** (HyperFrames → MP4 is stack-independent)                                                                        |
| `social-preview.md`           | 160   | **Survives** — generator script already stack-independent                                                                              |
| `color-palette.md`            | 314   | **Survives** (Tailwind tokens unchanged)                                                                                               |
| `definition-of-done.md`       | 74    | **Survives** — add SSG checks (goldens, CSP pin) to the checklist                                                                      |
| `design-inspiration.md`       | 92    | **Survives** — reframe "Starlight reaches it via theme tuning"                                                                         |
| `common-pitfalls.md`          | 588   | **Split**: Astro/pnpm/MDX pitfalls evaporate; Go pitfalls (templ gen, `@source`, jsonv2, CSP-pin drift) lifted from the SSG's own docs |
| `file-manifest.md`            | 196   | **Rewrite** — new baseline = template repo                                                                                             |
| `dependency-versions.md`      | 186   | **Rewrite** — Go module matrix + tailwind CLI pin                                                                                      |
| `ci-workflow.md`              | 151   | **Rewrite** — `build.sh` + firebase deploy, no pnpm/lockfile layers                                                                    |
| `website-creation-details.md` | 119   | **Rewrite** — content contract from `internal/pages/doc.go`                                                                            |

Roughly 2,025 of 3,267 reference lines survive as-is.

---

## 7. Open Decisions (user calls)

1. **Template shape:** sibling template repo vs `cmd/site init` scaffold
   (Phase A fork in the road).
2. **Pilot target:** next new launch vs migrating go-output first.
3. **Fleet policy:** opportunistic-only (recommended) vs time-boxed migration
   of all 7 Astro sites.
4. **i18n/RSS:** formally accept as out-of-scope for the template (recorded
   here), or block on them.
5. Whether this assessment's Phase A starts now — this session made no edits.

## 8. Verification Log (all claims checked against local sources, 2026-10-11)

- Skill line counts: `wc -l` over `website-launch/SKILL.md` + 15 references.
- Astro evidence: `website/package.json` existence per sibling repo (7/7
  checked, results in §1.2).
- Go SSG facts: read `website/go.mod`, `build.sh`, `README.md`,
  `internal/build/{search,llms}.go` heads, `internal/pages/*.go` grep for
  OGImage; Astro-removal date 2026-09-13 from the site's own README.
- Live URL claim (`templcomponents.lars.software`) is from that README; not
  fetched this session.
- ROADMAP open questions and TODO T33 read from `ROADMAP.md` / `TODO_LIST.md`.
- No files were modified; `docs/status/` is the only artifact of this session
  (this report).

## 9. Not Done (deliberately)

- No edits to `website-launch/SKILL.md` (including the now-stale "shared
  across all LarsArtmann projects" line — it gets rewritten by Phase C anyway;
  flagging rather than churning the file mid-decision).
- No extraction/scaffold work (Phase A) — awaits the go decision.
- No eval runs — meaningless until the new baseline exists.
