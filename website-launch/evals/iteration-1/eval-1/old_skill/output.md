# go-filewatcher Website Launch Plan

**Goal:** full public presence for the library — rewritten README, Astro/Starlight docs site at `go-filewatcher.lars.software`, demo video on the landing page — with the fsnotify pain-point story as the spine of the sales pitch.

## Phase 0 — Pre-flight (before any file is written)

- Check `/home/lars/projects/go-filewatcher/website/` for an existing site (→ maintenance mode if present) and `site/`, root `firebase.json`/`.firebaserc` for old static-site migration.
- Hosting: **Firebase Hosting** (default), shared `lars-software` project with a hosting target.
- Domain: propose **`go-filewatcher.lars.software`** + site ID `go-filewatcher` (full repo slug, no collision risk). Collision-check `~/projects/domains/lars.software.tf` and GitHub repos.
- **Gate: you confirm the subdomain before I commit anything** — it's immutable and touches 8+ files.
- Verify domains repo credentials and Firebase project access; flag blockers early.

## Phase 1 — Research

- Read `README.md` (especially the **Why?** fsnotify pain points), `AGENTS.md`, `go.mod`, `CHANGELOG.md`, and the source.
- Confirm **library** type (no `cmd/` + `package main`) → pkg.go.dev links, `go get` hero code, Go Reference badge apply.
- Verify every code example against the actual API: signatures, pointer-vs-value, and time units (`500*time.Millisecond`, not `Seconds` — the #1 typo).
- Check for `GOEXPERIMENT=jsonv2` build constraints.

## Phase 2 — README rewrite (defines the pitch the site will visualize)

Standard 24-section structure, centered header + badges (Go Reference | CI | Go Report Card | License-verified). The selling sections:

- **Why?** — sharpened from your existing fsnotify pain points into concrete failure modes (event spam on editor saves, no recursion, CHMOD noise, hand-rolled debounce).
- **Who is this for?** — 3–5 named personas (e.g. dev-tool authors, hot-reload/live-reload builders, asset-pipeline teams), each with one concrete pain.
- **Comparison table** — raw fsnotify vs. other wrappers vs. go-filewatcher, glyph-based, same row set reused on the website.
- **When NOT to use this** — 3+ honest exclusions + what to reach for instead (the trust signal).
- Install/Usage with source-verified minimal example, options/API tables, benchmarks, dependencies, license (verified, not assumed MIT).

## Phase 3 — Build the website (`/home/lars/projects/go-filewatcher/website/`)

Astro + Starlight + Tailwind v4, **gogenfilter as baseline** (security headers, CSP hash injection via `fix-csp.mjs`, OG images, two-job CI). Per the file manifest: ~12 files copied verbatim, ~15 customized (config, accent color, Header/Footer, HeroSection, logo/favicon), ~20 written fresh:

- **Landing page:** hero with verified Go import + watcher snippet, **ShowcaseSection (demo video) above the feature grid**, 6 feature cards (one per fsnotify pain point solved), comparison matrix, how-it-works pipeline, use cases, CTA.
- **Docs:** installation, quick-start, API reference, comparison-in-prose page, changelog, contributing, related tools, plus watcher-specific guides (debouncing, filtering, recursion).
- **Content patterns on every page:** personas callout, curated 4–6 link "Where to go next", `:::tip`/`:::caution` callouts, `lastUpdated`, `editLink`, feedback links.

## Demo video — where it fits and how I decide its content

**Fit:** part of the launch, not a bonus — a 20–30s HyperFrames (HTML/CSS/GSAP → deterministic MP4) tour embedded via `ShowcaseSection` above the feature grid. Order: **site ships first**, video lands as an immediate follow-up commit.

**Content decision:** go-filewatcher is a **pure-API library**, so per the demo-video matrix the video is an animated **before/after code sequence**, not screen capture — and the script is your README's **Why? section + comparison table**:

1. *Before:* raw fsnotify handler drowning in an event flood from one editor save (Create/Write/Chmod/Rename spam, duplicate triggers).
2. *After:* the same save through go-filewatcher → one clean, debounced callback (the hero quick-start snippet).
3. Close on the comparison-table checkmarks + `go get` line.

**Mechanics:** composition committed in `website/video/` (never `/tmp`), rendered to `website/public/demo.mp4` (<3 MB), `lint`/`check` gates, poster frame extracted from the video, `firebase.json` cache glob extended to `mp4|webm|mov`, `VideoObject` JSON-LD, frame-level ffmpeg verification, live `HEAD /demo.mp4` check after deploy.

## Phase 4 — Build verification + Visual QA gate

`pnpm install` / `pnpm run build` / `astro check` / `html-validate` — 0 errors. Then the mandatory visual gate: preview server, fetch-verify 200s and CSS tokens, headless Chromium screenshot of the landing page that I actually inspect (hero, icons, dark theme, video player).

## Phase 5 — Go-live runbook

Firebase site creation → deploy → verify `{siteId}.web.app` → custom domain via Firebase REST API → ACME TXT → DNS staged in Terraform in `/home/lars/projects/domains` → apply (opentofu / `NIXPKGS_ALLOW_UNFREE`) → SSL wait + verify custom domain.

## Phase 6 — GitHub metadata

`gh repo edit`: description, homepage = `https://go-filewatcher.lars.software`, topics `go, golang, fsnotify, file-watching, hot-reload, debouncing`.

## Phase 7 — CI/CD (after domain verified live)

`FIREBASE_SERVICE_ACCOUNT` secret from gogenfilter's firebase-adminsdk key + two-job workflow (build: frozen-lockfile, astro check, build, HTML validation → deploy via `GOOGLE_APPLICATION_CREDENTIALS`), with rollback commands noted.

## Commits & Definition of Done

Commits at: domain confirmed → README verified → site builds clean → deploy live → DNS staged. Final pass over the full Definition of Done checklist (build/deploy, README, GitHub, DNS, demo-video items, lockfiles committed, `git status` clean in **both** repos).

**I need from you:** confirmation of the `go-filewatcher.lars.software` subdomain and site ID before I commit anything.
