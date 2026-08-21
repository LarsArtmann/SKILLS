# go-filewatcher — Launch Plan

**Pre-flight findings (already verified):**
- `~/projects/go-filewatcher/website/` already exists (Astro + Starlight, full component set) → **maintenance mode**: audit + retrofit, no rebuild
- Firebase: shared `lars-software` project, hosting target/site `filewatcher`, URL `https://filewatcher.lars.software` already wired into the README → no domain-rename gate
- **No demo video exists anywhere** (no `ShowcaseSection`, no `public/demo.mp4`) → produce one; it's the launch's sales engine
- README is strong on Why?/Comparison/API tables but missing the two highest-leverage trust sections

---

## Phase 0 — Pre-flight checks
- Confirm shared-Firebase pattern (`.firebaserc`: `lars-software` + `filewatcher` target) — done
- Check `~/projects/domains` credentials and existing DNS record for `filewatcher`; surface blockers (placeholder Namecheap key → DNS staged, not applied) before starting
- Confirm with you: keep `filewatcher.lars.software` as-is

## Phase 1 — Research & verification
- Confirm **library** type (no `cmd/`, no `package main`) → pkg.go.dev link, Go hero code, Go Reference/Report Card badges, `pkgGoDev` in config (already present)
- Read `README.md`, `AGENTS.md`, `go.mod`, `CHANGELOG.md`; check for `GOEXPERIMENT=jsonv2`
- Verify every README claim against source: grep function signatures (`New`, `With*`, `Filter*`, `Middleware*`), confirm the "17+ filters / 18 middleware" counts, and check time units (`WithDebounce(500*time.Millisecond)` — the #1 typo source)

## Phase 2 — README rewrite (the sales narrative, written ONCE)
The README summary + "Why?" become the canonical narrative reused by hero headline, video, and launch post — never re-invented per surface.
- Keep "Why?" (fsnotify pain: recursion, filtering, debouncing, ENOSPC, observability) as the hook
- **Add "Who is this for?"** — 3–5 named personas (e.g. dev-tool/live-reload authors, data-pipeline engineers watching drop directories, platform teams hitting inotify limits)
- **Add "When NOT to use this"** — ≥3 honest exclusions + the alternative to reach for (e.g. single-file local watch → raw fsnotify)
- Add missing Go Report Card badge; append "Watch the {N}s demo" link once the video exists
- Commit checkpoint after README verified against source

## Phase 3 — Website retrofit (maintenance mode)
- Audit against the content patterns: "Where to go next" on every docs page, comparison table repeated in docs, `lastUpdated: true` + `editLink` in `astro.config.mjs`, `:::caution`/`:::tip` callouts
- **Add `ShowcaseSection.astro`** for the video, placed **visible without scrolling** (hero or first section below it), container `id="demo"` for deep links
- Extend `firebase.json` cache glob to cover `mp4|webm|mov`; add `VideoObject` JSON-LD

## Demo video — where it fits and how its content is decided
**Fit:** launch-blocking centerpiece (Tier 1): hero embed + poster (`/screenshots/demo-poster.png`, doubles as 1200×630 `og:image`) + `#demo` anchor + README link + cache headers + JSON-LD. Verified live via `HEAD /demo.mp4` → 200 with immutable cache headers.

**Content: derived entirely from Phase 2, script-before-pixels.** Beat table:

| Beat | Window | Source | Draft for go-filewatcher |
|---|---|---|---|
| Hook | 0–3s | README "Why?" pain, outcome language only | "Your editor fires 5 events per save. Raw fsnotify gives you events — and nothing else." |
| Value claim | 3–8s | One-paragraph summary compressed to one sentence | "Recursion, filtering, debouncing, and crash-resilience — production file watching in one `New()` call." |
| Evidence | 8–20s | Real product behavior, 2–3 scenes max | Real terminal run of `examples/demo`: 5 raw fsnotify events coalescing into one debounced event; `.gitignore`-aware recursive watch; a composable filter chain |
| CTA | 20–25s | Install section | `go get github.com/larsartmann/go-filewatcher/v2` + `filewatcher.lars.software` |

- Self-checks before animating: **value test** (delete evidence beats — the story must still sell) and **muted test** (on-screen text carries everything)
- Storyboard presented as a proposal table for your sign-off before any pixels — cheap to change at proposal, expensive after build
- Pipeline: route through the HyperFrames `/product-launch-video` workflow if `hyperframes*` skills are in session (pre-filled brief: message/angle/audience/16:9/20–30s); otherwise the hand-rolled HyperFrames fallback with NixOS constraints (`HYPERFRAMES_BROWSER_PATH`, direct `node .../cli.js`, no `.call()`, no `text:` plugin, transforms only)
- Composition committed to `~/projects/go-filewatcher/website/video/` (never `/tmp`), rendered to `website/public/demo.mp4`, <3 MB; verify without eyes via ffmpeg frame extraction + **sales gate**: hook frame at t≈2s must show readable text/product, evidence frame at t≈10s must show the product
- Order: ship the site first, video as an immediate follow-up commit — never skipped

## Phase 4 — Build verification + visual QA gate
- `pnpm install` / `pnpm run build` via `nix shell nixpkgs#nodejs`; `astro check` = 0 errors; `html-validate` on `dist/**`
- Preview server + fetch checks (200s, `color-accent` present); headless Chromium screenshot of the landing page reviewed for hero, icons, dark theme; video visible without scrolling
- Commit checkpoint

## Phase 5 — Go-live (per runbook)
Deploy `--only hosting:filewatcher --project lars-software` → verify `filewatcher.web.app` → confirm custom domain/SSL on `filewatcher.lars.software` → stage/apply DNS Terraform if changes are needed → verify live.

## Phase 6 — GitHub metadata
`gh repo edit` — description from the one-liner, homepage `https://filewatcher.lars.software`, topics: `go`, `golang`, `file-watcher`, `fsnotify`, `inotify`, `live-reload`.

## Phase 7 — CI/CD (after manual launch verified)
`FIREBASE_SERVICE_ACCOUNT` secret for `lars-software` + two-job workflow (build → deploy) from the CI reference; rollback commands on hand.

## Commit discipline
After: README rewrite → successful build → deploy live → DNS staged. Final pass against the Definition of Done checklist before declaring complete.

**What I need from you before Phase 2:** confirm the subdomain stays `filewatcher.lars.software`, and (when we reach the video) approve the storyboard beat table above.
