# go-pixelwand — Website Launch Plan

Launch plan for the public documentation website of **go-pixelwand**, a Go
library for zero-allocation chained image transforms. Produced by following the
`website-launch` skill (SKILL.md + all references: readme-template,
content-patterns, file-manifest, color-palette, dependency-versions,
website-creation-details, design-inspiration, demo-video, go-live-runbook,
ci-workflow, common-pitfalls, definition-of-done).

**This document is a plan only.** No deploys, network calls, or file creation
(except this document) have been executed.

---

## 1. Project facts (verified against source, Phase 1)

Read from `/tmp/eval-fictional/go-pixelwand`:

| Fact               | Value                                                                                                                  | Consequence                                                                                                                                     |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Module path        | `github.com/fictional-dev/go-pixelwand`                                                                                | All badges/links use `fictional-dev`, NOT `LarsArtmann` (skill default) — substitute everywhere                                                 |
| Go version         | `go 1.26`                                                                                                              | Prerequisite line in Install docs                                                                                                               |
| Project type       | **Library** (no `main` package, no `cmd/`)                                                                             | pkg.go.dev links, Go Reference + Go Report Card badges, `pkgGoDev` in `config.ts`, hero code = Go import + call                                 |
| Public API         | `Wand` struct; `(*Wand).Resize(w2, h int) *Wand`; `(*Wand).Gray() *Wand`; `(*Wand).Render(src []byte) ([]byte, error)` | Verified signatures — see hero code + API table below                                                                                           |
| Constructor        | **None exported.** Zero-value `&pixelwand.Wand{}` is the entry point                                                   | Do NOT fabricate `pixelwand.New()` in any example (top code-example trap)                                                                       |
| Dependencies       | None (`go.mod` has zero requires)                                                                                      | "Zero dependencies" is a selling point; empty dependencies table                                                                                |
| `encoding/json/v2` | Not used                                                                                                               | The #1 forgotten requirement (GOEXPERIMENT) was checked → **N/A**, no build-constraint docs needed                                              |
| Existing README    | Title, tagline, `Why?` (intermediate-allocation pain), minimal comparison table                                        | Rewrite per template; keep the existing `Why?` narrative as the canonical sales narrative                                                       |
| LICENSE file       | **Missing**                                                                                                            | Blocker for the license badge (never assume MIT) — user decision, see §3                                                                        |
| Git                | **Not a git repo yet**                                                                                                 | `git init` + initial commit required before `nix flake lock` (flakes only operate on git-tracked files) and before any skill checkpoint commits |
| `Render` behavior  | Currently returns `src` unchanged (stub)                                                                               | Honesty gate on benchmarks/evidence — see §12                                                                                                   |

---

## 2. Pre-flight decisions (Phase 0) — require user confirmation BEFORE any commit

Skill gate: **no commits until the domain is confirmed** (a rename after commit
touches 8+ files).

| Decision          | Proposal (default per skill)                                                                                                                                                                | Alternative                                          | Status                                  |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | --------------------------------------- |
| Hosting target    | **Firebase Hosting** (custom domain, headers/CSP, DNS pipeline)                                                                                                                             | GitHub Pages (zero infra; skips Phases 5 DNS + 7 SA) | Propose Firebase                        |
| Firebase project  | **Shared `lars-software`** with hosting target `go-pixelwand`                                                                                                                               | Standalone project                                   | Propose shared                          |
| Subdomain         | **`go-pixelwand.lars.software`** (full repo slug; no collision risk expected — verify via `grep` in `~/projects/domains/lars.software.tf` + `gh repo list`)                                 | —                                                    | **Needs user confirmation**             |
| Firebase site ID  | **`go-pixelwand`** (immutable after creation)                                                                                                                                               | —                                                    | **Needs user confirmation** (same gate) |
| License           | Ask user; create `LICENSE` + matching badge                                                                                                                                                 | —                                                    | **Blocker for README badge**            |
| Default branch    | Ask user (repo has no git yet); affects `editLink` + ALL branch refs in CI workflow                                                                                                         | `main` recommended                                   | **Needs user confirmation**             |
| Path substitution | Skill assumes `~/projects/{repo}`; actual repo is `/tmp/eval-fictional/go-pixelwand` — substitute in every command                                                                          | —                                                    | Noted                                   |
| Org substitution  | Skill templates hardcode `LarsArtmann`; this module lives under `fictional-dev`. Also confirm the `lars.software` domain is the right home for a `fictional-dev` project (domain ownership) | Project GitHub Pages or fictional-dev-owned domain   | **Needs user confirmation**             |

Other Phase 0 checks to run at execution time (not run in this planning
session): existing-website check (`website/package.json` — none exists: fresh
build, not maintenance mode), old static site check (`site/`, root
`firebase.json`), Namecheap API key validity in `~/projects/domains`,
`firebase projects:list | grep lars-software`, `firebase hosting:sites:list`
collision check.

---

## 3. The ONE sales narrative (written once in Phase 2, reused everywhere)

The value proposition is authored once and expressed three ways (README, hero,
video). Derived from the existing `Why?` section:

> **One-paragraph summary (canonical):** Chaining image transforms in Go
> allocates an intermediate image buffer for every step — a 3-step pipeline
> (resize → crop → grayscale) on a 4K frame can push hundreds of megabytes
> through the GC. go-pixelwand queues your transforms on a `Wand` and fuses
> them into a single pass over the source pixels: one sweep, zero
> intermediate allocations.

- **Hero headline:** "One pass over the pixels. Zero intermediate allocations."
- **Tagline (keep):** "Zero-allocation chained image transforms for Go."
- **Video hook (outcome language, no API names):** "Every step of your image
  pipeline allocates another full frame."
- **Video value claim (summary compressed to one sentence):** "go-pixelwand
  fuses the whole chain into one pass — no intermediate buffers."
- **Launch-post hook:** same sentence as the video hook; proof point = one
  comparison row ("0 intermediate allocations vs 1 per op") or one real
  benchmark row once measured.

---

## 4. Phase 2 — README rewrite (BEFORE the website)

Restructure `README.md` to the canonical section order from
`readme-template.md`. Current content maps into it; the rest is written fresh.

| #     | Section                                                         | Content plan                                                                                                                                                               |
| ----- | --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1–2   | Centered header + tagline                                       | `<h1 align="center">go-pixelwand</h1>` + centered tagline                                                                                                                  |
| 3     | Badge row                                                       | Library set, template order: **Go Reference \| CI \| Go Report Card \| License** — all URLs use `github.com/fictional-dev/go-pixelwand`; `{LICENSE}` pending user decision |
| 4     | Documentation link bar                                          | `Documentation · API Reference` (pkg.go.dev); a third link `Watch the 25s demo` is appended once the video exists                                                          |
| 5–6   | Separator + one-paragraph summary                               | §3 canonical paragraph                                                                                                                                                     |
| 7     | `## Why?`                                                       | Keep/extend existing intermediate-allocation narrative (concrete failure mode: 3-op 4K pipeline, hundreds of MB GC churn)                                                  |
| 8     | `## Who is this for?`                                           | 4 personas (drafted in §5)                                                                                                                                                 |
| 9     | `## Comparison`                                                 | Existing table upgraded to glyph style, stdlib column added, same rows reused on landing page + docs page                                                                  |
| 10    | `## How it works`                                               | 1. Queue ops on a `Wand` → 2. `Render(src)` fuses the queue → 3. single pass, one output buffer                                                                            |
| 11    | `## When NOT to use this`                                       | 4 honest exclusions (drafted in §5)                                                                                                                                        |
| 12    | `## Install`                                                    | `go get github.com/fictional-dev/go-pixelwand` (Go 1.26+)                                                                                                                  |
| 13    | `## Usage`                                                      | The verified hero snippet (below)                                                                                                                                          |
| 14    | `## API`                                                        | Table of `Wand`, `Resize`, `Gray`, `Render` with real signatures                                                                                                           |
| 17    | `## Benchmarks`                                                 | **Real runs only** — see honesty gate §12                                                                                                                                  |
| 18    | `## Dependencies`                                               | "None." — stated explicitly as a feature                                                                                                                                   |
| 19–23 | Design decisions / Error handling / Development / API stability | Written per template; Development section must match the repo's actual (currently absent) flake/tooling — keep minimal or add flake first                                  |
| 24    | `## License`                                                    | Matches the user-confirmed LICENSE file                                                                                                                                    |

Removals from current README: none needed (no emoji, no ToC) — it is sparse,
everything is additive.

**Code examples — verification checklist applied (all pass):**
functions exist (`grep 'func' pixelwand.go`), pointer receivers chain
correctly (`*Wand` returns), parameter types match, no time units involved,
import path matches `go.mod`.

Verified hero snippet (NO invented constructor — the source exports none):

```go
import "github.com/fictional-dev/go-pixelwand"

w := &pixelwand.Wand{}
out, err := w.Resize(1920, 1080).Gray().Render(src)
```

API table content (from source):

| Symbol | Signature                                      | Notes                                        |
| ------ | ---------------------------------------------- | -------------------------------------------- |
| `Wand` | `type Wand struct`                             | Transform queue; zero-value is usable        |
| Resize | `(w *Wand) Resize(width, height int) *Wand`    | Queues resize; returns receiver for chaining |
| Gray   | `(w *Wand) Gray() *Wand`                       | Queues grayscale                             |
| Render | `(w *Wand) Render(src []byte) ([]byte, error)` | Fuses + applies all queued ops in one pass   |

---

## 5. Drafted content (Phase 2 outputs feeding Phase 3)

**Who is this for? (personas, not "developers")**

- **Image-service backend engineers** resizing uploads per request, where GC
  pauses blow up tail latency.
- **Thumbnail-pipeline authors** running resize+crop+grayscale chains over
  millions of objects.
- **CLI tool authors** doing batch image processing who want a small,
  predictable memory footprint.
- **Edge/embedded Go developers** processing camera frames under tight memory
  ceilings.

**When NOT to use this**

- You run a **single transform** — the stdlib (`image` +
  `golang.org/x/image/draw`) is enough; fusion earns nothing on one op.
- You **need each intermediate result** (e.g. persisting every step) — fusion
  deliberately never materializes intermediates; chain `imaging`/`bild` instead.
- You need **transforms the Wand cannot queue yet** (see API table) — use
  `imaging` or `bild` today.
- You need **GPU acceleration or streaming decode of huge formats** — a fused
  CPU pass over `[]byte` is the wrong tool.

**Comparison table (glyphs; identical row set on landing page and docs page)**

|                          | stdlib `x/image/draw` | imaging  |    bild    | go-pixelwand |
| ------------------------ | :-------------------: | :------: | :--------: | :----------: |
| Chained ops in one pass  |                       |          |            |      ✓       |
| Intermediate allocations |       1 per op        | 1 per op |  1 per op  |    **0**     |
| Builder API              |                       |  fluent  | functional |      ✓       |
| Dependencies             |          low          |   few    |    few     |    **0**     |

Sentence under the table: the differentiator row is _intermediate
allocations_ — every other library materializes a full image per step;
go-pixelwand never does.

**Six feature cards (features.ts)**: Zero intermediate allocations ·
Single-pass fusion · Builder-chain API · Zero dependencies · `[]byte`
in/`[]byte` out (drop into HTTP handlers) · Predictable memory footprint.

---

## 6. Phase 3 — Create the website

**Baseline:** gogenfilter (`~/projects/gogenfilter/website/`) — CSP hardening,
OG images, two-job CI. (go-atomic-write is the older pattern; not used.)

**Stack:** Astro 7 + Starlight + Tailwind v4 + Firebase Hosting, versions from
the verified dependency matrix only (no version guessing; `vite` REMOVED from
overrides; `astro-og-canvas@^0.12.0`; `firebase-tools` never in
`package.json`).

**Accent color:** every color in the pre-computed table is taken by a sibling
project (emerald, cyan, 2× amber, 2× violet, rose, indigo, blue). New color
via the documented **Color Derivation Formula**: **Fuchsia `#d946e8`**
(distinct pixel/neon identity for an image library). Derive
`accent-hover`/`accent-dim`/`accent-light`/`border-accent` (light+dark) and the
`sl-color-accent-*` triple per the formula table; do not hand-wave `rgba()`
values. Base palette per rule of thumb: `#0a0908` dark / `#faf8f5` light,
dark-first.

**File plan (per file-manifest):**

- **Copy verbatim (~12):** `tsconfig.json`, `.node-version`, `.gitignore`,
  `.htmlvalidate.json`, `src/content.config.ts`, the 4 `public/js/*.js`,
  `Section.astro`, `SectionHeader.astro`, `Card.astro`, `Sections.astro`,
  `LandingLayout.astro`, `src/pages/index.astro`, `flake.nix`.
- **Customize (~15):** `package.json` (name/description/keywords/repo URLs),
  `astro.config.mjs` (`site: https://go-pixelwand.lars.software`, title,
  sidebar, social, description, fonts, `lastUpdated: true`, `editLink` to
  `github.com/fictional-dev/go-pixelwand/edit/{branch}/website`),
  `.firebaserc` + `firebase.json` (shared-project target `go-pixelwand`;
  headers incl. HSTS/X-Frame-Options/CORP/COOP; cache glob extended to
  `...|mp4|webm|mov`), `src/data/config.ts` (**include `pkgGoDev`** — library),
  `Header.astro`/`Footer.astro` (library link bar: Documentation, pkg.go.dev,
  Changelog), `global.css` + `starlight.css` (fuchsia tokens + base palette),
  `HeroSection.astro` (GitHub API URL → fictional-dev repo), `Logo.astro`
  (28×28 rounded-rect monogram, CSS-var fill), `public/manifest.json`,
  `public/robots.txt`, `scripts/fix-csp.mjs` (CSP SHA-256 injection; build
  script becomes `astro build && node scripts/fix-csp.mjs`).
- **Write fresh (~20):** `src/data/features.ts`, `src/data/hero-code.ts`
  (verified snippet from §4), `src/data/sections.ts` (queue→fuse→render steps,
  comparison matrix, use cases), `public/favicon.svg` (literal fuchsia hex,
  monogram in `#0a0908`), `Icon.astro` additions (Lucide paths, verify SVG
  render), section components — `FeatureGrid`, `HowItWorksSection`,
  `ComparisonSection`, `UseCasesSection`, `ShowcaseSection` (the video, moved
  up to be visible without scrolling), `CTASection`; `src/pages/og/[...slug].ts`
  (border color = fuchsia); all docs `.mdx` pages.

**Docs pages (sidebar):**

- Getting Started: `installation.mdx` (`go get`, import path, Go 1.26+),
  `quick-start.mdx` (hero snippet walked through)
- Guides: `how-fusion-works.mdx` (queue→fuse→single-pass; repeats the
  comparison table with prose per row), `benchmarks.mdx` (real data only)
- Reference: `api-reference.mdx` (the API table, every symbol)
- Meta: `changelog.mdx` (link/inline CHANGELOG — repo has none yet; start
  one), `contributing.mdx`, `related-tools.mdx` (imaging, bild, stdlib)

Every docs page: curated 4–6 link **"Where to go next"** with annotated
reasons, callouts (`:::tip`/`:::caution`, not bold), MDX escaping for
`<`/`>`/`<=`/`>=`. Nextra-class calibration per design-inspiration: density,
one accent, dark-first, typography pairing.

**Creation order** (per website-creation-details): config layer → firebase
layer → data layer → style layer → public assets → shared components →
section components → layout + landing page → docs content.

---

## 7. Phase 3.11 — Demo video (the launch's sales engine; default, not bonus)

"Make the launch sell the project" makes this the centerpiece. 20–30s,
16:9, library-with-visual-result category ("input → transform → output").

**Routing:** this session has `hyperframes*` skills → route through the
`hyperframes` entry point → `/product-launch-video` workflow, with the brief
pre-filled from Phase 2 so the intent interview is short:

- **message:** "go-pixelwand fuses chained image transforms into one
  allocation-free pass."
- **angle:** sell (launch asset), pain-first (intermediate allocations)
- **audience:** the four personas from §5
- **destination:** 16:9 website embed · **length:** 20–30s

**Storyboard (proposal table — get user agreement before animating):**

| Frame  | Beat        | On-screen                                                                                                                                                          | Source                                    |
| ------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------- |
| 0–3s   | Hook        | A 4K image duplicating per pipeline step; allocation counter climbing into hundreds of MB. Text: "Every step of your image pipeline allocates another full frame." | README `Why?` pain, outcome language      |
| 3–8s   | Value claim | The duplicates collapse into one pass arrow. Text: "go-pixelwand fuses the whole chain into one pass — no intermediate buffers."                                   | One-paragraph summary                     |
| 8–20s  | Evidence    | 2 scenes: (a) the real hero code typing itself; (b) **real captured** `go test -bench` output with allocs/op for chained ops                                       | Real product behavior only — see §12 gate |
| 20–25s | CTA         | "go get github.com/fictional-dev/go-pixelwand" + `go-pixelwand.lars.software/#demo`                                                                                | Install section                           |

Self-checks on the beat list: **value test** — delete evidence beats, hook +
value + CTA still state the value ✓. **Muted test** — every scene carries the
argument in on-screen text ✓.

**Production constraints (NixOS, from demo-video.md):** composition lives in
`{repo}/website/video/` from the first command (never `/tmp`); install
hyperframes under real Nix node (`nix shell nixpkgs#nodejs -c pnpm add
hyperframes`); make puppeteer's cached chrome-headless-shell work via
`LD_LIBRARY_PATH` from ~25 NixOS store lib paths; invoke the CLI directly
(`node node_modules/hyperframes/bin/hyperframes.mjs`), never `npx`/`pnpm exec`;
`check` takes a directory. Seek-safe rules: no `.call()` timeline callbacks, no
GSAP `text:` plugin (clipPath wipes), no `left`/`top` motion, tween between
pre-laid-out layers.

**Verification without eyes:** ffprobe duration/resolution/size (< 3 MB for
~25s at 1080p); extract frames at t≈2s and t≈10s — hook frame must show
readable text/product visual (not blank/title-only), evidence frame must show
the product; distinct color signatures per scene.

**Landing integration (launch-blocking tier):** video visible without
scrolling on 1440×900 (`ShowcaseSection` directly below/beside the hero);
container `id="demo"`; framed `<video controls preload="metadata"
poster="/screenshots/demo-poster.png">` with fallback text; poster = strongest
selling frame (the collapse-into-one-pass moment), doubles as `og:image`
cropped to 1200×630 (overrides the generated per-page OG image for `/` only);
caption "See it work end-to-end — 25 seconds."; `firebase.json` cache glob
covering `mp4|webm|mov`; `VideoObject` JSON-LD beside the SoftwareApplication
block; README bar gains `Watch the 25s demo` (real runtime); post-deploy
`HEAD /demo.mp4` → 200 with `Cache-Control: public, max-age=31536000,
immutable`; `video/node_modules/` gitignored.

**Order of operations:** ship the site first, video as an immediate follow-up
commit — do not skip it.

**Distribution tiers:** Tier 1 (launch-blocking): everything above. Tier 2
(same-day): 9:16 vertical cut (a resized composition, not a render flag) +
launch post copy from the mini-template (§3 hook + one link + one proof
point). Tier 3 (later): TTS voiceover + burned captions, ≤6s GIF teaser,
YouTube.

---

## 8. Phase 4 — Build verification + Visual QA gate

All via Nix wrappers, run from `website/` (never repo root):

1. `nix shell nixpkgs#nodejs -c pnpm install` → `nix shell nixpkgs#nodejs -c
   pnpm run build` (approve-scripts for esbuild/sharp if pnpm v11+ blocks).
   Expect: N pages, sitemap, pagefind index, 0 errors.
2. `pnpm dlx astro check` → 0 errors/0 warnings; `pnpm dlx html-validate
   "dist/**/*.html"`.
3. **Visual QA (mandatory gate):** preview server + `fetch` tool on `/` and
   `/getting-started/installation/` (HTTP 200, `color-accent` present in
   HTML); headless Chromium screenshot at 1440×900, viewed to confirm hero
   code mockup, icons, dark default, video above the fold, no overflow. If no
   browser is available, flag visual QA incomplete and hand the checklist to
   the user.

---

## 9. Phase 5 — Go-live sequence (runbook order, each step depends on the prior)

1. Lock files: `git add website/flake.nix` (requires the repo to BE a git repo
   — see §11 prerequisite), `pnpm install` → commit `package-lock.json` +
   `flake.lock`.
2. Create the Firebase hosting site: `firebase hosting:sites:create
   go-pixelwand --project lars-software` (**immutable ID**).
3. Verify the upload endpoint (`upload-firebasehosting.googleapis.com`,
   Node `https.request` — never curl), then `firebase deploy --only
   hosting:go-pixelwand --project lars-software` (real Node via Nix; `re2`
   fails under bun).
4. Verify `https://go-pixelwand.web.app` → 200 (fetch tool).
5. Add custom domain via REST: `POST .../sites/go-pixelwand/customDomains?
   customDomainId=go-pixelwand.lars.software`, empty body `{}`, headers
   `Authorization` + `x-goog-user-project` + `Content-Type`. (Not the legacy
   `domains` endpoint.)
6. Extract ACME challenge → CNAME `go-pixelwand` → `go-pixelwand.web.app.` +
   TXT `_acme-challenge.go-pixelwand`.
7. Stage both records in `~/projects/domains/lars.software.tf` (grouped comment
   header, before the closing `}`, unique edit context + `git diff` after
   every edit), `terraform fmt` + `validate` (unfree: `NIXPKGS_ALLOW_UNFREE=1
   nix shell --impure` or `opentofu`).
8. `terraform plan`/`apply -target=namecheap_domain_records.lars_software` —
   if credentials are a placeholder/not whitelisted, stage records and flag as
   a manual user step (pre-check in Phase 0 avoids discovering this late).
9. Wait for SSL: `OWNERSHIP_MISSING` → `CERT_VALIDATING` → `CERT_ACTIVE`
   (10–60 min). Note the ~90-day ACME renewal caveat.
10. Verify `https://go-pixelwand.lars.software` → 200; then `HEAD /demo.mp4`
    cache headers.

---

## 10. Phases 6–7 — GitHub metadata + CI/CD

**Phase 6 (after custom domain live):**

```bash
gh repo edit fictional-dev/go-pixelwand \
  --description "Zero-allocation chained image transforms for Go — fused single-pass pipelines" \
  --homepage "https://go-pixelwand.lars.software" \
  --add-topic go,golang,image-processing,image,zero-allocation,graphics
```

Remove any topics for frameworks not used (none expected). README carries the
library badge set and the documentation bar from Phase 2 — verify the shipped
bar matches the template exactly (no split-brain bold variant).

**Phase 7 (after manual launch verified):** create the
`firebase-adminsdk` service-account key for `lars-software` via `gcloud`
(Nix), set the `FIREBASE_SERVICE_ACCOUNT` GitHub secret, verify with
`gh secret list`, delete the temp key. Copy `.github/workflows/website.yml`
from gogenfilter; customize target `go-pixelwand`, project `lars-software`,
and **ALL branch references** to the user-confirmed default branch. Two jobs:
build (`pnpm install --frozen-lockfile`, `astro check`, build, html-validate,
artifact) → deploy (`GOOGLE_APPLICATION_CREDENTIALS`). Rollback available via
`firebase hosting:rollback`. Note: the README's CI badge also expects a Go CI
workflow (`ci.yml`) — out of scope for this skill; flag to the user.

---

## 11. Commit discipline (checkpoints — never end a session with uncommitted work)

Prerequisite: `git init` + initial commit of the existing three files (the
repo is not a git repo yet).

1. After **domain + site ID confirmed by user** (Phase 0.4 gate — before any
   website work is committed)
2. After **README rewrite** (all code examples verified against source)
3. After **website builds successfully** (`astro check` 0 errors, build clean)
4. After **Firebase deploy confirmed live** (HTTP 200 on web.app URL)
5. After **DNS records staged** (`terraform fmt` + `validate` pass)

Two repos always: the project repo AND the domains repo — `git status` clean
in both before done. A video follow-up commit lands immediately after
checkpoint 4/5.

---

## 12. Honesty gate (project-specific risk)

The README claims "0 (fused)" intermediate allocations, but `Render` currently
returns `src` unchanged — the library is a skeleton. The skill's top content
pitfalls are fabricated hero code and fabricated benchmark output. Therefore:

- Landing/README copy may describe the **design** (queue + fuse + single
  pass) — that is the documented intent.
- The **benchmarks** section, the benchmark docs page, and the video's
  evidence beat must contain only **actually captured** numbers
  (`go test -bench . -benchmem` output), or be clearly labeled illustrative
  until the fusion is implemented.
- Decision for the user: (a) implement/verify fusion + benchmarks before the
  public launch, or (b) launch with design-intent copy and no benchmark
  claims. Recommend (a) for a launch whose entire value prop is "zero
  allocations" — the video's evidence beat depends on it.

---

## 13. Definition of Done (verify every item)

- Build: `pnpm run build` 0 errors; `astro check` 0 errors; web.app 200; all
  docs pages 200; no 404s in sidebar; GitHub homepage = `https://go-pixelwand.lars.software`
- README: centered header + 4 library badges (license verified against real
  LICENSE file), docs link bar, pkg.go.dev link (library), no emojis, code
  examples verified, comparison table present
- GitHub: description, homepage, topics `go`/`golang`/domain
- DNS: CNAME + ACME TXT staged, `terraform validate`/`fmt -check` pass
- Demo video: `website/public/demo.mp4` (< 3 MB, 20–30s), beats from the value
  prop, above the fold + `id="demo"`, composition committed under
  `website/video/`, selling poster, README demo link with real runtime,
  `og:image` 1200×630 from poster, cache glob covers `mp4|webm|mov`, live
  `HEAD /demo.mp4` immutable cache verified
- Files: `package-lock.json` + `flake.lock` committed, no `firebase-tools` in
  `package.json`, no temp files, `git status` clean in both repos

---

## 14. Execution order summary

Phase 0 gates (user confirms domain/site ID/license/branch; credential checks)
→ git init → Phase 2 README rewrite (one narrative) → commit 2 → Phase 3
website (gogenfilter baseline, fuchsia accent, library config, 9+ docs pages)
→ Phase 4 build + visual QA → commit 3 → Phase 5 go-live (locks → site →
deploy → domain → DNS → SSL) → commits 4–5 → §3.11 video (HyperFrames via
/product-launch-video, storyboard approved, rendered, integrated) → follow-up
commit → Phase 6 GitHub metadata → Phase 7 CI/CD → Definition of Done audit.
Estimated ~25 min scaffold-and-customize + ~30–60 min video, per the skill's
session benchmarks.
