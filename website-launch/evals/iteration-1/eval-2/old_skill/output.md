# Website Refresh Plan (Maintenance Mode)

The site already exists and has a demo video, so this is a **maintenance-mode refresh**, not a rebuild: I'll audit and retrofit, never overwriting existing customization without confirming with you first.

## 1. Orient (before touching anything)

- Read `website/` end to end: `astro.config.mjs`, `firebase.json`, `.firebaserc` (shared `lars-software` target vs standalone — determines deploy commands), `src/data/*.ts`, landing components, all docs pages.
- Read the last 6 months of `CHANGELOG.md`, `README.md`, `go.mod`, `AGENTS.md` to inventory what changed since launch — this drives everything below.

## 2. Content drift audit (docs vs. actual code)

The biggest risk after 6 months is documentation that no longer matches the source. I'll verify, page by page:

- **Every Go code example** against real signatures (function exists, pointer vs value, parameter types, receivers — and time units, the #1 typo).
- **Version numbers, install commands, import paths** (including `/v2` suffixes if any).
- For applications: CLI flags, HTTP routes, Docker claims, framework claims vs `go.mod`.
- `GOEXPERIMENT=jsonv2` build constraint documented if the library uses `encoding/json/v2`.
- License consistency across `LICENSE`, `README`, `.goreleaser.yaml`, `package.json`.
- Features shipped in the changelog but missing from docs/feature grid → add pages/sections for them.

## 3. "Nice docs" retrofit checklist

Audit and add any missing (these retrofit without a rebuild):

- [ ] README: **"Who is this for?"** (3–5 named personas) and **"When NOT to use this"** (3–5 specific exclusions + the alternative to reach for)
- [ ] At least one docs page repeats the **comparison table** with prose explaining the differentiator row
- [ ] Every docs page ends with a curated **4–6 link "Where to go next"**, each link annotated with *why* you'd click it
- [ ] `astro.config.mjs`: **`lastUpdated: true`** (git-based, zero maintenance) and **`editLink`** ("Edit this page" — #1 contributor lever), branch name matching the repo's default
- [ ] Bold-text warnings/tips swapped for **`:::caution` / `:::tip` callouts** (one idea per callout; `:::danger` only for data-loss/security)

## 4. Demo video freshness (exists → verify, don't recreate)

- Confirm the HyperFrames **composition is committed under `website/video/`** (not just the MP4) — if it isn't, that's a gap to fix; a committed composition makes any update a one-command re-render.
- Check the tour still reflects the **current** product (flags, UI, feature names). If it's stale, edit the composition, re-render, and re-extract the poster frame.
- Verify `firebase.json` cache glob covers `mp4|webm|mov`, `VideoObject` JSON-LD exists, and live `HEAD /demo.mp4` returns `Cache-Control: public, max-age=31536000, immutable`.

## 5. Housekeeping

- **Stale docs:** root-level `HOW_TO_USE.md`/`USAGE.md` overlapping the website → consolidate, archive, or link.
- **Parity with the gogenfilter baseline:** security headers in `firebase.json`, CSP hash injection (`fix-csp.mjs`), OG images, two-job CI (`build-website` → `deploy-website` with `FIREBASE_SERVICE_ACCOUNT`) — add anything missing.
- **Dependencies:** refresh only against the verified pin matrix; no ad-hoc bumps, and no `vite` override (breaks Astro 7 builds). Lockfiles committed and consistent with CI's package manager.
- **README/badges/metadata:** correct badge set (library vs application), docs link bar, `gh repo` description/homepage/topics current, no topics for unused frameworks.

## 6. Verify & ship

1. `pnpm install` + `pnpm run build` (via `nix shell nixpkgs#nodejs -c ...`), `astro check` and `html-validate` — 0 errors.
2. **Visual QA gate:** preview server, HTTP 200s on key pages, headless Chromium screenshots of the landing page (hero, feature icons, dark theme, ShowcaseSection video player) reviewed before deploy.
3. Deploy via CI; confirm the site and `/demo.mp4` live and healthy. Rollback available via `firebase hosting:rollback` if anything breaks.
4. Commits at each checkpoint (content fixes → config/retrofit → video update → deploy confirmed), `git status` clean in project repo (and domains repo if touched).

**I'll report back before changing anything beyond the checklist above** — especially anything that touches your existing customization, the demo video re-render, or dependency updates.
