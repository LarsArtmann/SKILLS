# Docs Site Refresh Plan (6-Month Maintenance Pass)

Per the website-launch skill, this is **maintenance mode**: read the existing site, audit, and retrofit — no rebuild, no overwriting your existing customization without confirming with you first.

## 1. Survey what exists (before touching anything)

- Inventory `website/` — config, components, docs pages, `public/demo.mp4`, `video/` composition
- Confirm the Firebase pattern in use (shared `lars-software` target vs standalone) from `.firebaserc` / `firebase.json`
- Read the current `README.md`, `CHANGELOG.md`, and `go.mod` to establish what's changed in 6 months

## 2. Content accuracy audit (the big rot risk at 6 months)

- Verify every Go code example (hero, quick-start, usage) against current source: function signatures, pointer-vs-value types, time units (`ms` not `s`)
- For an app/server: re-verify CLI flags, HTTP endpoints, Docker claims against actual `Dockerfile`
- Check version numbers, install commands, badges, and the changelog link reflect the current release
- Check for stale root-level docs (old `HOW_TO_USE.md`-style files) overlapping the site

## 3. Value-prop drift check (README ↔ landing hero ↔ demo video)

- Compare the landing headline against the README's "Why?" and one-paragraph summary — the video, hero, and README must tell **one narrative**
- The demo video gets a **narrative audit, not a remake**: does its hook still speak the current pain? Does its value claim still match? Does the evidence show current product behavior (old UI/output = re-render from the committed `website/video/` composition, ~one command)?

## 4. "Nice docs" retrofit checklist (add only what's missing)

- [ ] README: "Who is this for?" (3–5 named personas) and "When NOT to use this" (specific exclusions + alternatives)
- [ ] Every docs page ends with a curated 4–6 link "Where to go next" (annotated, ordered by reader path)
- [ ] Comparison table repeated inside the relevant docs page with prose (same rows as the landing matrix)
- [ ] `astro.config.mjs`: `lastUpdated: true` + `editLink` enabled
- [ ] Bold-text warnings swapped for `:::caution` / `:::tip` callouts

## 5. Demo video integration audit

- Visible without scrolling on 1440×900; container has `id="demo"`
- README link bar has "Watch the {N}s demo" with an **accurate runtime**
- Poster frame is a selling frame (result moment, not the title card) and doubles as a 1200×630 `og:image`
- `firebase.json` cache glob covers `mp4|webm|mov`; `VideoObject` JSON-LD present

## 6. Housekeeping

- Dependency refresh only against the verified version matrix (no speculative bumps; no `vite` override)
- License consistency across `LICENSE`, `.goreleaser.yaml`, `flake.nix`, `package.json`
- Lockfile/package-manager match with CI

## 7. Build, verify, ship

- `astro check` (0 errors) → `astro build` → `html-validate dist/**/*.html`
- Visual QA gate: preview server, HTTP 200 checks, headless screenshot of the landing page (hero, icons, dark theme, video placement)
- Commit at each checkpoint, deploy, then verify live: landing 200, `HEAD /demo.mp4` with long-cache headers

**Order rationale:** accuracy before polish — a beautiful page with stale code examples is worse than an honest one. I'll report findings and proposed edits before changing anything substantive.
