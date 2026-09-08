# go-pixelwand — Website Launch Plan

Planning document only. Nothing here has been executed: no deploys, no network
calls, no files created in the project repo. It follows the `website-launch`
skill (SKILL.md + all 13 references) phase by phase, adapted to what was
actually verified in `/tmp/eval-fictional/go-pixelwand`.

**Goal:** a public documentation website that _sells_ go-pixelwand — the
intermediate-allocation pain story from the README "Why?" section becomes the
landing page's spine, backed by a demo video, honest comparison table, and
trust patterns ("Who is this for?" / "When NOT to use this").

---

## Verified project findings (skill Phase 1, executed read-only)

Everything below was read from the actual repo — the plan's code examples,
links, and claims are grounded in it.

| Item                                  | Verified value                                                                                                                                                                                                  |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Module path                           | `github.com/fictional-dev/go-pixelwand` (go.mod)                                                                                                                                                                |
| Go version                            | `go 1.26`, **zero dependencies** (stdlib only)                                                                                                                                                                  |
| Project type                          | **Library** — no `main.go`, no `cmd/` (per skill decision branch)                                                                                                                                               |
| Public API                            | `type Wand struct` (unexported `ops` field); `(*Wand).Resize(w2, h int) *Wand`; `(*Wand).Gray() *Wand`; `(*Wand).Render(src []byte) ([]byte, error)`                                                            |
| Constructor                           | **There is NO `New()`** — the zero value `&pixelwand.Wand{}` is the entry point. Chain via pointer receivers: `w.Resize(...).Gray().Render(src)`                                                                |
| README today                          | Tagline "Zero-allocation chained image transforms for Go.", a good `## Why?` (intermediate allocation pain), a 3-column comparison (imaging / bild / go-pixelwand). No badges, no install, no usage, no license |
| LICENSE file                          | **Missing** — blocks the license badge, README license section, and part of GitHub metadata                                                                                                                     |
| CI workflow                           | **Missing** (`.github/` does not exist) — a CI badge would 404 today                                                                                                                                            |
| CHANGELOG.md / benchmarks / examples/ | **Missing**                                                                                                                                                                                                     |
| `GOEXPERIMENT=jsonv2`                 | Not used — no `encoding/json` anywhere. Requirement N/A (checked per skill Phase 1 step 4)                                                                                                                      |
| Existing website / old static site    | None (`website/` and `site/` absent) → fresh creation, not maintenance mode                                                                                                                                     |

### Code-example verification (skill Phase 1, the #1 trap)

All future hero/quickstart code MUST use this verified shape:

```go
import "github.com/fictional-dev/go-pixelwand"

w := &pixelwand.Wand{}                       // no New() exists — zero value
out, err := w.Resize(1920, 1080).Gray().Render(src)
```

Rules derived from source: pointer receivers throughout; `Render` takes
`[]byte` and returns `([]byte, error)` — bytes-in/bytes-out, not
`image.Image`. Writing `pixelwand.New(...)` anywhere is the classic
fabricated-API mistake and must not appear. No time-unit traps apply (no
duration parameters exist).

**Honesty check on the core claim:** the README says "queues operations and
fuses them into a single pass" and "0 (fused)" allocations, but `Render` is
currently a stub that returns `src` unchanged. Before the website publishes
allocation/benchmark numbers, real benchmarks must exist (see Phase 2,
Benchmarks). Until then any animated output in the demo video is _labeled
illustrative_ per the skill's "fabricated hero output" pitfall.

---

## Phase 0 — Pre-flight decisions (before any file is written)

| Check                 | Result / decision                                                                                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.0 Existing website  | None — greenfield launch                                                                                                                                                                                            |
| 0.0.1 Old static site | None — nothing to migrate                                                                                                                                                                                           |
| 0.1 Firebase project  | **Shared `lars-software` with a hosting target** (skill default for new projects). Standalone only if the org wants isolated infra — surface as an option                                                           |
| 0.2 Credentials       | To be verified at execution: domains repo Namecheap key, `firebase projects:list`, `hosting:sites:list` collision scan, upload-endpoint reachability                                                                |
| 0.3 Domain naming     | Candidate subdomain `pixelwand` (short form acceptable — no sibling repo/DNS collision expected; verify via grep in `domains/lars.software.tf` + `gh repo list`). **Site ID: full slug `go-pixelwand`** (immutable) |
| 0.4 Confirm with user | **BLOCKING GATE.** Nothing is committed until the user confirms `pixelwand.lars.software` + site ID `go-pixelwand`. A rename after commit touches 8+ files                                                          |
| 0.5 Collision check   | `grep -r "pixelwand" ~/projects/domains/lars.software.tf` at execution time                                                                                                                                         |
| 0.6 Hosting target    | **Firebase Hosting** (default) — custom domain, security headers/CSP, DNS pipeline. GitHub Pages stays the fallback if the org declines Firebase infra                                                              |

**Additional user decisions surfaced by this plan (not in the skill, but
blocking):**

1. **License** — no LICENSE file exists. The skill forbids hardcoding "MIT".
   User must pick one; it gates the license badge, README §License, and repo
   metadata.
2. **CI** — no workflow exists. Either add `.github/workflows/ci.yml`
   (`go build ./... && go test ./...`) so the CI badge is real, or omit the
   badge. Plan assumes we add it (a library site without CI loses credibility).
3. **Benchmarks** — approve writing a small `bench_test.go` so the 0-alloc
   claim ships with numbers instead of marketing prose.

---

## Phase 2 — README rewrite (BEFORE the website)

The README defines the value proposition the site visualizes. Rewrite the
existing 19 lines into the skill's standard structure (readme-template.md),
keeping the existing Why? prose as the seed.

### Target section order and content plan

1. Centered `h1` header: **go-pixelwand**
2. Centered tagline: _Zero-allocation chained image transforms for Go._
3. Centered badge row (library set, adapted to the real org):
   `pkg.go.dev/github.com/fictional-dev/go-pixelwand` (Go Reference) · CI
   (`github.com/fictional-dev/go-pixelwand/actions/workflows/ci.yml`) · Go
   Report Card · License (**pending user decision**)
4. Centered doc links: `Documentation` (site URL, pending domain
   confirmation) · `API Reference` (pkg.go.dev)
5. `---` separator
6. One-paragraph summary — stdlib-only library that queues resize/grayscale
   ops and fuses them into a single pass over the input
7. `## Why?` — keep the existing text; it is already concrete (per-op
   intermediate buffers, 3-op 4K pipeline = hundreds of MB of GC churn)
8. `## Who is this for?` — 3–5 named personas, e.g.:
   - **Image-service backend engineers** whose thumbnail pipelines GC-thrash
     under load
   - **API authors** processing user uploads who pay per allocated MB
   - **CLI tool authors** who want one-pass resize+grayscale without manual
     buffer reuse
   - **Teams currently chaining imaging/bild calls** and paying N allocations
     per pipeline
9. `## Comparison` — expand the existing table, glyph style, same row set as
   the website:

   |                     | imaging |  bild   | stdlib | go-pixelwand |
   | ------------------- | :-----: | :-----: | :----: | :----------: |
   | Intermediate allocs |  1/op   |  1/op   |  1/op  | ✓ 0 (fused)  |
   | Chained/builder API |    ✓    |         |        |      ✓       |
   | Dependencies        | several | several |  none  |     none     |
   | Ops today           |  many   |  many   | manual | resize, gray |

10. `## How it works` — numbered: construct zero-value `Wand` → queue ops
    (`Resize`, `Gray`) → `Render` fuses the queue into one pass, bytes to bytes
11. `## When NOT to use this` — honest exclusions + alternatives:
    - One-shot single transform — the `image` stdlib is enough
    - Need `image.Image` in/out (decode/inspect pixels) — `Render` is
      bytes-in/bytes-out; use imaging/bild
    - Need the full op catalog (rotate, blur, draw) today — use imaging until
      pixelwand grows ops
    - Offline batch where allocation cost is irrelevant
12. `## Install` — `go get github.com/fictional-dev/go-pixelwand`
13. `## Usage` — the verified snippet above
14. `## API` — table of `Wand`, `Resize`, `Gray`, `Render` with real
    signatures from pixelwand.go
15. `## Benchmarks` — **only after writing bench_test.go**; publish real
    `go test -bench -benchmem` output (0 allocs/op target); until then the
    section is omitted, not faked
16. `## Dependencies` — "None. Standard library only." (a selling point —
    state it as a one-row table)
17. `## Design Decisions` — bytes-in/bytes-out; builder chaining on pointer
    receivers; queue-then-fuse instead of per-op materialization
18. `## Error Handling` — document what `Render` can return (currently only
    `nil`; keep truthful to source)
19. `## Development` — `nix flake check` / `go test ./...` (create flake.nix
    only if the repo adopts Nix; otherwise plain go commands)
20. `## API Stability` — v0 statement until 1.0
21. `## License` — **blocked on user decision** (no LICENSE file exists)

**What gets removed:** nothing — the current README has no emoji headers, no
TOC, no footer cruft. It is simply incomplete.

---

## Phase 3 — Create the website

### 3.1 Baseline and stack

Copy from **gogenfilter** (`~/projects/gogenfilter/website/`) — it carries the
full-feature baseline: security headers, CSP hash injection, OG images,
two-job CI. Stack: Astro 7 + Starlight + Tailwind v4, static output, Pagefind
search.

### 3.2 File plan (per file-manifest.md)

- **Copy verbatim (~15 files):** `tsconfig.json`, `.node-version`,
  `.gitignore`, `.htmlvalidate.json`, `src/content.config.ts`,
  `public/js/{theme-init,animations,header,copy-code}.js`,
  `src/components/{Section,SectionHeader,Card,Sections}.astro`,
  `src/layouts/LandingLayout.astro`, `src/pages/index.astro`, `flake.nix`,
  `scripts/fix-csp.mjs`, `.github/workflows/website.yml` (then customize)
- **Customize (~15 files):** `package.json` (name/description/repo URLs →
  fictional-dev), `astro.config.mjs` (site URL, title "go-pixelwand", sidebar,
  `lastUpdated: true`, `editLink` →
  `github.com/fictional-dev/go-pixelwand/edit/{branch}/website`), `.firebaserc`
  - `firebase.json` (shared-project hosting target `go-pixelwand`, security
    headers, CSP, **cache glob extended to `mp4|webm|mov`**),
    `src/data/config.ts` (include `pkgGoDev` — library), `src/styles/global.css`
  - `starlight.css` (accent tokens below; warm dark base `#0a0908` /
    light `#faf8f5`), `HeroSection.astro` (GitHub stars fetch → fictional-dev
    repo; hero code = verified snippet), `Logo.astro`, `public/manifest.json`,
    `public/robots.txt`, OG endpoint border color
- **Write fresh (~20 files):** `src/data/features.ts` (6 cards — zero
  intermediate allocations, single fused pass, builder chaining, bytes-to-bytes
  API, zero dependencies, tiny API surface), `src/data/hero-code.ts`
  (verified), `src/data/sections.ts` (how-it-works steps, comparison matrix
  above, use cases), `public/favicon.svg` (28x28 rounded square, accent fill,
  monogram "W"/pixel motif), section components:
  `ShowcaseSection.astro` (video, above the feature grid), `FeatureGrid`,
  `ComparisonSection`, `HowItWorksSection` (3-op pipeline: naive buffers vs
  fused pass), `UseCasesSection`, `CTASection`, `Icon.astro` (Lucide paths),
  all docs `.mdx` pages

**Creation order** per website-creation-details.md: config → firebase → data →
styles → public assets → shared components → section components → layout/page
→ docs content.

### 3.3 Accent color

All hues in the palette table are taken by sibling projects. Choose **Fuchsia
`#d946ef`** (distinct from emerald/cyan/ambers/violet/rose/indigo/blue; fits a
"wand" identity) and derive the full token set with the reference's
documented derivation formula: hover `#e879f9` (+10% lightness), light
`#f0abfc` (+20%), dim `rgba(217,70,239,0.08)` dark / `0.06` light,
border-accent `0.3` / `0.25`, light-mode accent `#c026d3` (-10%),
`--sl-color-accent-low` fuchsia-900 `#4a044e`, high fuchsia-300. Favicon uses
the literal dark-mode hex; Logo.astro uses CSS variables.

### 3.4 Dependencies

Use the verified full-feature matrix verbatim: `astro ^7.0.3`,
`@astrojs/starlight ^0.41.1`, `@astrojs/sitemap ^3.7.3`, `tailwindcss` +
`@tailwindcss/vite` `^4.3.1`, `astro-og-canvas ^0.12.0`, devDeps
`@astrojs/check ^0.9.9`, `html-validate ^11.5.3`, `typescript ^6.0.3`.
**Overrides: `brace-expansion`, `devalue`, `yaml` only — never pin `vite`**
(#1 build failure). No `firebase-tools` in package.json. pnpm v11+:
`approve-scripts esbuild sharp` if blocked.

### 3.5 Docs page set (library variant, all `.mdx`, `<`/`>` escaped)

- `installation.mdx` — `go get`, import path
- `quick-start.mdx` — verified snippet
- `why-zero-alloc.mdx` — expands the README Why? (project-specific guide);
  repeats the comparison table with prose per content-patterns §3
- `api-reference.mdx` — Wand/Resize/Gray/Render signatures
- `performance.mdx` — benchmark methodology + numbers once they exist
- `changelog.mdx` — link to CHANGELOG.md (create it, even if "v0.1.0
  initial"), otherwise link stub is dishonest
- `contributing.mdx`, `related-tools.mdx` (imaging, bild, stdlib)
- Every page ends with a curated 4–6 link `## Where to go next`;
  feedback link with pre-filled issue title; `:::tip`/`:::caution` callouts
  instead of bold warnings

### 3.11 Demo video — the centerpiece of "make the launch sell"

go-pixelwand is an image-transform library → "library with a visual result"
row: **video is mandatory**, ~25s, 1920x1080, target < 3 MB, produced with
HyperFrames (composition committed at `website/video/`, never `/tmp`).

Storyboard (each scene = stacked opacity layers, seek-safe, no `.call()`
callbacks, no GSAP `text:` plugin, transform-only motion):

1. **Title** (0–3s): "go-pixelwand" + tagline on the warm dark base, fuchsia
   accent
2. **The pain** (3–10s): a 3-op pipeline (resize → crop → grayscale) shown as
   buffer blocks popping into existence between ops; an "intermediate
   allocations" counter climbing toward "hundreds of MB @ 4K" — the README
   Why? visualized
3. **The fix** (10–17s): same pipeline collapsing into one fused pass; the
   Wand builder chain `Resize(1920,1080).Gray().Render(src)` types out; the
   allocation counter holds at **0**
4. **Proof + CTA** (17–25s): zero-dependency badge, `go get` command, docs URL

Gates: `lint` 0 errors, `check` passes (WCAG AA), frame verification via
ffmpeg extraction at 2s/12s (distinct scene signatures), duration/resolution/
size via ffprobe. Poster frame extracted from the title scene
(`ffmpeg -ss 3 -frames:v 1`). Landing integration: `ShowcaseSection` above
the feature grid, `<video controls preload="metadata" poster=...>`, caption
"demo.mp4 — 25s product tour", `VideoObject` JSON-LD next to
`SoftwareApplication` JSON-LD, `firebase.json` cache glob includes mp4,
post-deploy `HEAD /demo.mp4` → 200 with `Cache-Control: public,
max-age=31536000, immutable`. If `Render` remains a stub, scene 3 renders the
_concept_ (counter/diagram) and the video is labeled illustrative — no
fabricated output imagery.

Order: ship the site first if the session runs long, then land the video as
an immediate follow-up commit — but it is not skipped.

---

## Phase 4 — Build verification (execution-time commands)

```bash
cd website
nix shell nixpkgs#nodejs -c pnpm install        # (+ approve-scripts esbuild sharp if blocked)
nix shell nixpkgs#nodejs -c pnpm run build      # 0 errors; N pages, sitemap, pagefind
nix shell nixpkgs#nodejs -c pnpm dlx astro check          # 0 errors, 0 warnings
nix shell nixpkgs#nodejs -c pnpm dlx html-validate "dist/**/*.html"
```

Then the **mandatory visual QA gate**: preview server on :4321, fetch-tool
checks that `/` and `/getting-started/installation/` return 200 and that
`color-accent` appears in the HTML; headless Chromium screenshot at
1440x900 viewed to confirm hero code mockup, icons, dark theme, no overflow;
otherwise explicitly report visual QA as incomplete.

---

## Phase 5 — Go-live (runbook order, all steps sequential)

1. Lock files: `git add flake.nix` → `pnpm install` → `nix flake lock`;
   commit `package-lock.json` + `flake.lock`
2. Create hosting site: `firebase hosting:sites:create go-pixelwand --project
   lars-software` (site ID immutable — full slug)
3. Pre-check upload endpoint reachability
   (`upload-firebasehosting.googleapis.com` via Node https), then
   `firebase deploy --only hosting:go-pixelwand --project lars-software`
4. Verify `https://go-pixelwand.web.app` → 200 (fetch tool; curl is banned)
5. Add custom domain via REST `customDomains` endpoint (body `{}`, domain in
   query param, `x-goog-user-project` header, Bearer token from gcloud)
6. Extract ACME challenge → CNAME `pixelwand` → `go-pixelwand.web.app.` and
   TXT `_acme-challenge.pixelwand`
7. Stage both records in `domains/lars.software.tf` (append before closing
   brace, grouped comment `# go-pixelwand website (Firebase Hosting)`);
   `terraform fmt` + `validate` (via `NIXPKGS_ALLOW_UNFREE=1 nix shell
   --impure nixpkgs#terraform` or opentofu)
8. Targeted `terraform apply -target=namecheap_domain_records.lars_software`
   (stage-only + flag as manual if the Namecheap key/IP is blocked — never
   create the Firebase custom domain before DNS is applied)
9. Poll domain status to `CERT_ACTIVE` (10–60 min)
10. Verify `https://pixelwand.lars.software` → 200

---

## Phase 6 — GitHub metadata

```bash
gh repo edit fictional-dev/go-pixelwand \
  --description "Zero-allocation chained image transforms for Go — fused single-pass pipelines" \
  --homepage "https://pixelwand.lars.software" \
  --add-topic go,golang,image-processing,allocations,performance,zero-allocation
```

README link bar: **Documentation** · **pkg.go.dev** · **Changelog** (library
variant — pkg.go.dev stays, applications would omit it).

## Phase 7 — CI/CD (only after the custom domain is verified live)

1. Service account key for `firebase-adminsdk@lars-software` → GitHub secret
   `FIREBASE_SERVICE_ACCOUNT` (temp key file deleted after)
2. Add `.github/workflows/website.yml` (two-job: build with `astro check` +
   build + html-validate + artifact upload → deploy via
   `GOOGLE_APPLICATION_CREDENTIALS`), customizing: target `go-pixelwand`,
   project `lars-software`, and **all branch references** to the repo's real
   default branch
3. Also add the Go `ci.yml` workflow (Phase 0 decision) so the README CI badge
   is real; rollback path: `firebase hosting:rollback`

---

## Commit checkpoints and Definition of Done

Commits (never end a session with uncommitted work): (1) after user confirms
domain — Phase 0.4 gate; (2) after README rewrite verified against source;
(3) after `astro check`/`astro build` pass; (4) after deploy is live (HTTP
200); (5) after DNS staged with `fmt`+`validate` clean. Two repos to keep
clean: project + domains.

Definition of Done (from definition-of-done.md), plus this project's extras:
build/astro-check/html-validate clean; web.app + custom domain 200; all
sidebar links resolve; README badges real (CI workflow exists, license
decided); benchmarks real or absent; GitHub description/homepage/topics set;
DNS records staged and validated; demo.mp4 < 3 MB embedded via
ShowcaseSection with immutable cache headers verified live; composition
committed under `website/video/`; lock files committed; no stray deps
(`firebase-tools` absent); `git status` clean in both repos.

## Pitfall register for this launch

Vite override removed; no `vite` pin · MDX `<`/`>` escaped · hero code uses
`&pixelwand.Wand{}` not a fabricated `New()` · no `curl` (fetch tool /
Node https) · terraform via unfree workaround or opentofu · deploy with real
Node.js (re2 breaks under bun) · video composition in the repo, not `/tmp` ·
mp4 in the cache glob · license verified against the actual LICENSE file
once created · branch name updated in the deploy workflow · status reports
use "pixelwand.lars.software (pending DNS propagation)" until verified.

---

## Why this launch sells the project

The product story is unusually clean: **one painful, universal problem
(per-op intermediate buffers eating hundreds of MB per 4K pipeline) and one
measurable answer (0 allocations, single fused pass, zero dependencies).**
Every launch asset carries that single message: the hero shows the 3-line
builder chain; the demo video shows allocation counters climbing (pain) and
flatlining at zero (fix); the comparison table makes "0 (fused)" the
rightmost, check-marked column; the honest "When NOT to use this" section and
real benchmarks make the claim trustworthy rather than promotional. The
launch sequence (README → site → deploy → metadata → CI → video) ships the
story in the order the skill has proven across 6+ prior launches.
