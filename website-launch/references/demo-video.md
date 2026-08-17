# Demo Video (HyperFrames) — the standard showcase asset

> Every project website gets a demo video by default. A 20-30s product tour on
> the landing page converts far better than prose or static screenshots alone —
> visitors see the thing working before they read a single paragraph. This
> reference distills the proven pipeline (first productionized on emeet-pixyd,
> 2026-08-17: 25s, 1920x1080, 1.4 MB, rendered in ~30s).

## When to make one

| Project type | Video? | Content |
| ------------ | ------ | ------- |
| CLI/daemon application | **Always** | Terminal flows + UI recreation + state transitions |
| Library with a visual result | **Yes** | Input → transform → output |
| Library, pure API | Optional | Animated "before/after" code or data-flow diagram |
| Docs-only retrofit (maintenance mode) | Retrofit | Add one during any landing-page overhaul |

Budget: ~30-60 min of session time. If the session is already deep in a launch,
ship the site first, then produce the video as an immediate follow-up commit —
but do NOT skip it. Treat it like OG images: part of the launch, not a bonus.

## Tool: HyperFrames (HTML/CSS/GSAP → deterministic MP4)

Repo: `github.com/heygen-com/hyperframes`. You author a normal HTML page with
GSAP animations; HyperFrames renders every frame headlessly and muxes an MP4.
Deterministic and seek-safe — no screen recording, no flaky captures.

**If the session has `hyperframes*` skills available, load them** (start with
the `hyperframes` entry-point skill) — they own composition craft (motion
rules, scene blueprints, media). This reference owns the website integration.

### NixOS invocation (memorize this — nothing else works)

```bash
# 1. Scaffold (website/video/ is the canonical location — see "Location" below)
cd {repo}/website/video
nix shell nixpkgs#nodejs -c npm init -y
nix shell nixpkgs#nodejs -c npm install hyperframes
nix shell nixpkgs#nodejs -c node node_modules/hyperframes/dist/cli.js init

# 2. Quality gates (lint = composition rules; check = WCAG + layout)
HYPERFRAMES_BROWSER_PATH=$(ls -d /nix/store/*-chromium-*/bin/chromium | head -1) \
  nix shell nixpkgs#nodejs -c node node_modules/hyperframes/dist/cli.js lint
HYPERFRAMES_BROWSER_PATH=<same> \
  nix shell nixpkgs#nodejs -c node node_modules/hyperframes/dist/cli.js check

# 3. Render
HYPERFRAMES_BROWSER_PATH=<same> \
  nix shell nixpkgs#nodejs -c node node_modules/hyperframes/dist/cli.js render --output ../public/demo.mp4
```

Hard-won constraints:

- **`HYPERFRAMES_BROWSER_PATH` only.** `PUPPETEER_EXECUTABLE_PATH` does NOT
  work. The bundled chrome-headless-shell lacks NixOS shared libs.
- **Invoke the CLI directly** (`node node_modules/hyperframes/dist/cli.js`).
  `npx hyperframes` and `pnpm exec` wrappers fail in approve-builds prompt
  loops.
- Find a usable chromium once and reuse the store path within the session.

### Seek-safe composition rules (violations silently corrupt renders)

- NO `.call()` timeline callbacks — use stacked opacity layers instead.
- NO GSAP `text:` plugin — animate `clipPath` wipes over pre-rendered text.
- NO `left`/`top` motion (layout snapping) — use `x`/`y` transforms.
- State transitions = tweens between two pre-laid-out layers, not DOM edits.
- The linter catches most of these; fix what it flags rather than suppressing.

### Verify without eyes (the model usually cannot view the MP4)

```bash
# Extract frames at key timestamps and check they differ meaningfully
nix shell nixpkgs#ffmpeg -c ffmpeg -ss 2 -i website/public/demo.mp4 -frames:v 1 /tmp/f2.png
nix shell nixpkgs#ffmpeg -c ffmpeg -ss 12 -i website/public/demo.mp4 -frames:v 1 /tmp/f12.png
# Compare unique-color counts / dominant colors per frame — each scene must
# have a distinct signature; flat/blank frames = broken scene.
```

Also verify duration, resolution, and size: `ffprobe` (or the ffmpeg banner).
Target < 3 MB for 25s at 1080p. Bigger → re-render at higher CRF.

## Location: commit the composition INTO the repo

**Canonical home: `{repo}/website/video/`** containing `index.html` (the
composition), `package.json`, and the rendered output copied to
`website/public/demo.mp4`.

The emeet-pixyd session kept the composition in `/tmp` and lost it on reboot —
the MP4 survived only because it was committed. A committed composition makes
every future edit (copy tweak, new scene, 9:16 social cut) a one-command
re-render. Never stage HyperFrames work in `/tmp`.

Add to `website/.gitignore`:

```
video/node_modules/
```

## Landing-page integration

1. **`ShowcaseSection.astro` component** — framed `<video>` player above the
   feature grid:
   - `<video controls preload="metadata" poster="/screenshots/{poster}.png">`
     with a `<source src="/demo.mp4" type="video/mp4">` and a fallback text
     node.
   - 2 real screenshots beside it (capture recipe below).
   - Caption the video with its runtime ("demo.mp4 — 25s product tour").
2. **Poster frame:** extract a real frame from the title scene
   (`ffmpeg -ss <t> -frames:v 1`) rather than reusing a screenshot — it
   matches the video's first paint and avoids an autoplay jank flash.
3. **Cache headers** — extend the `firebase.json` asset glob or the video will
   serve with no long-cache header:
   ```json
   "source": "**/*.@(css|js|jpg|jpeg|gif|png|svg|ico|webp|avif|woff|woff2|mp4|webm|mov)"
   ```
4. **SEO:** add a `VideoObject` JSON-LD block (name, thumbnailUrl,
   contentUrl, uploadDate) to the landing layout alongside the
   SoftwareApplication JSON-LD.
5. Verify live after deploy: `HEAD /demo.mp4` → 200/206 with
   `Cache-Control: public, max-age=31536000, immutable` and
   `Content-Type: video/mp4`.

## Companion screenshots (same session, same quality gate)

```bash
# Requires the real product running locally (daemon/server on 127.0.0.1)
nix shell nixpkgs#chromium -c chromium --headless=new --no-sandbox --disable-gpu \
  --hide-scrollbars --screenshot=webui-viewport.png --window-size=1440x900 \
  --virtual-time-budget=8000 http://127.0.0.1:{port}/
```

Capture a viewport shot, a full-page shot, and a cropped panel shot. Put them
in `website/public/screenshots/`. If the product has an offline/empty state,
say so in the figure caption — or better, retake when it can show real data.

## Production checklist

- [ ] Composition committed under `website/video/` (never `/tmp`)
- [ ] `lint` 0 errors, `check` passing (WCAG AA contrast included)
- [ ] Rendered MP4 in `website/public/demo.mp4`, < 3 MB, verified frames
- [ ] Poster frame extracted from the video (not a reused screenshot)
- [ ] `ShowcaseSection` on the landing page, above the feature grid
- [ ] `firebase.json` cache glob covers `mp4|webm|mov`
- [ ] `VideoObject` JSON-LD added
- [ ] Live `HEAD /demo.mp4` verified after deploy
- [ ] `video/node_modules/` gitignored

## Future upgrades (nice-to-haves, not launch blockers)

- BGM or TTS voiceover (`hyperframes tts` / media tooling)
- 9:16 vertical cut for social
- Real product footage woven in (screenshots/video capture of the actual UI)
