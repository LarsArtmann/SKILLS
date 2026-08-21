# Demo Video (HyperFrames) — the launch's sales engine

> Every project website gets a demo video by default — not as proof-of-life
> but as the single most persuasive element on the page. Prose claims can be
> doubted; 25 seconds of the thing actually working cannot. This reference
> distills the proven pipeline (first productionized on emeet-pixyd,
> 2026-08-17: 25s, 1920x1080, 1.4 MB, rendered in ~30s) and the selling
> discipline around it.

## The one-narrative rule

The launch has ONE sales narrative, written once in Phase 2 (the README's
one-paragraph summary + "Why?" section) and expressed three ways:

1. **README** — the narrative in full
2. **Landing page** — headline + hero + video
3. **Video** — the narrative compressed to 20-30s of motion

If the video's hook and the landing page's headline tell different stories,
the page fights itself. Derive both from the same sentence.

## When to make one

| Project type                          | Video?     | Content                                            |
| ------------------------------------- | ---------- | -------------------------------------------------- |
| CLI/daemon application                | **Always** | Terminal flows + UI recreation + state transitions |
| Library with a visual result          | **Yes**    | Input → transform → output                         |
| Library, pure API                     | Optional   | Animated "before/after" code or data-flow diagram  |
| Docs-only retrofit (maintenance mode) | Retrofit   | Add one during any landing-page overhaul           |

Budget: ~30-60 min of session time. If the session is already deep in a launch,
ship the site first, then produce the video as an immediate follow-up commit —
but do NOT skip it. Treat it like OG images: part of the launch, not a bonus.

## Script before pixels

Write the script BEFORE opening the composition. The known failure mode is a
feature tour: delete the value beats and a feature tour still "works" — which
is exactly why it does not sell. Derive every beat from Phase 2 outputs:

| Beat           | Window | Source                | Rule                                                                                                     |
| -------------- | ------ | --------------------- | -------------------------------------------------------------------------------------------------------- |
| Hook           | 0-3s   | README "Why?" pain    | Outcome language only — no feature names, no API names. Numbers only when they carry stakes.             |
| Value claim    | 3-8s   | One-paragraph summary | One sentence: what the viewer gains or avoids.                                                           |
| Evidence       | 8-20s  | Real product behavior | 2-3 scenes max: real terminal output, real UI, real data flowing. Captured output beats fabricated demo. |
| Call to action | 20-25s | Install section       | Name + site URL + the one command to start.                                                              |

Self-check the finished beat list:

- **Value test** — delete every evidence beat; the remaining beats must still
  state the value on their own. If they do not, the script is a tour, not a
  story.
- **Muted test** — every scene must communicate without audio. Most viewers
  watch muted; on-screen text carries the argument. If a voiceover is added
  later, burn captions — but never rely on audio for the core message.

Present the storyboard as a proposal table (frame / beat / on-screen / why)
and get agreement before animating. A frame change at proposal costs 30
seconds; the same change after build costs minutes. When the
`hyperframes-creative` skill is loaded, its story-spine doctrine governs —
this section is the website-launch lens on the same rules, not a rival.

## Routing: prefer the HyperFrames workflow

**If the session has `hyperframes*` skills available, route through them.**
Start with the `hyperframes` entry-point skill; the route is
`/product-launch-video` ("market or showcase a website, product site, app,
or company" — quoted from the entry skill's routing table). Those skills own
the composition craft: story doctrine (`hyperframes-creative`), motion rules
and scene blueprints (`hyperframes-animation`), media (`media-use`),
publishing and hosted/distributed renders (`publish`/`cloud`/`lambda`/
`cloudrun` in `hyperframes-cli`) — verified against the skill bodies
2026-08-21.

Pre-fill the workflow's brief from Phase 2 so the intent interview is short:

- **message** — the README one-paragraph summary sharpened to one sentence
- **angle** — recommend one from the README's positioning; the intent is
  "sell" (a launch asset), not a neutral tour
- **audience** — the README "Who is this for?" personas
- **destination** — 16:9 website embed
- **length** — 20-30s

This reference owns what the workflow does not know: the website integration
(below), the canonical composition location, and the NixOS invocation
constraints. **Apply the NixOS constraints to every CLI call the workflow
prescribes** — the `npx hyperframes` / `pnpm exec` wrappers have failed in
approve-builds prompt loops (observed on `render`; untested on other
subcommands, so assume the failure is subcommand-independent) — invoke the
CLI directly via node.

## Tool: HyperFrames (HTML/CSS/GSAP → deterministic MP4)

Repo: `github.com/heygen-com/hyperframes`. You author a normal HTML page with
GSAP animations; HyperFrames renders every frame headlessly and muxes an MP4.
Deterministic and seek-safe — no screen recording, no flaky captures.

When no `hyperframes*` skills are available, this pipeline is the complete
fallback.

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

**Sales gate on top of the technical gate:** extract the frame at t≈2s (the
hook) and t≈10s (the evidence). The hook frame must contain readable text or
a recognizable product visual — a blank or title-only frame at 2s means the
hook is late and the video loses skimmers. The evidence frame must show the
product, not decoration.

## Location: commit the composition INTO the repo

**Canonical home: `{repo}/website/video/`** containing `index.html` (the
composition), `package.json`, and the rendered output copied to
`website/public/demo.mp4`.

The emeet-pixyd session kept the composition in `/tmp` and lost it on reboot —
the MP4 survived only because it was committed. A committed composition makes
every future edit (copy tweak, new scene) a one-command re-render. A 9:16
social cut is more work than a render flag: the composition hardcodes its
size on the root (`data-width`/`data-height`, per `hyperframes-core`'s
"Root must be sized" rule) with px-authored layout, so a vertical variant
needs a resized composition, not a CLI argument. Never stage HyperFrames work
in `/tmp`.

Add to `website/.gitignore`:

```
video/node_modules/
```

## Landing-page integration (the selling surface)

1. **Placement: visible without scrolling.** On a 1440x900 viewport the video
   must be on screen at page load — embedded in the hero next to the
   headline + primary CTA, or as the first section directly below the hero.
   "Above the feature grid" alone is too weak: a video the visitor must
   scroll to find is a video most visitors never see. Keep the existing
   `ShowcaseSection.astro` component as the vehicle; move it up.
2. **Deep-link anchor.** Give the video container `id="demo"` so the README
   and social posts can link `{subdomain}.lars.software/#demo`.
3. **Player markup** — framed `<video>` element:
   `<video controls preload="metadata" poster="/screenshots/demo-poster.png">`
   with a `<source src="/demo.mp4" type="video/mp4">` and a fallback text
   node. Default is click-to-play with a styled poster; use muted
   autoplay/loop only if the user asks for it.
4. **Poster frame that sells.** Pick the strongest selling frame — usually
   the transformation/result moment, not the title card. It must contain
   readable product visuals (never blank or text-only). Only when the video
   autoplays should the poster match the first paint (avoids the flash).
   The poster doubles as the landing page's `og:image` — crop/letterbox to
   1200x630 for link unfurls, so shares of the site show the money shot.
5. **Caption copy.** Caption with runtime, phrased to earn the click:
   "See it work end-to-end — 25 seconds." Not "demo.mp4".
6. **README link.** Append a link to the documentation bar (Phase 2) once
   the video exists, with the real runtime:
   `<a href="https://{subdomain}.lars.software/#demo">Watch the 25s demo</a>`
   — one click from GitHub to the product in motion.
7. **Cache headers** — extend the `firebase.json` asset glob or the video will
   serve with no long-cache header:
   ```json
   "source": "**/*.@(css|js|jpg|jpeg|gif|png|svg|ico|webp|avif|woff|woff2|mp4|webm|mov)"
   ```
8. **SEO:** add a `VideoObject` JSON-LD block (name, thumbnailUrl,
   contentUrl, uploadDate) to the landing layout alongside the
   SoftwareApplication JSON-LD.
9. Verify live after deploy: `HEAD /demo.mp4` → 200/206 with
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

## Distribution tiers

A video that only lives on the landing page sells only to people who already
arrived. Ship in tiers — never let a tier block the launch:

| Tier                   | Items                                                                                                                                             | When                               |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| 1 — Launch-blocking    | Hero embed + poster + `#demo` anchor + README link + `og:image` + JSON-LD + cache headers                                                         | Part of the launch commit sequence |
| 2 — Same-day follow-up | 9:16 vertical cut for Shorts/TikTok (adapt the committed composition to a resized variant — same narrative; not a render flag, see "Location") + launch post copy derived from the README summary | Immediately after the launch lands |
| 3 — Optional later     | TTS voiceover + burned captions, animated GIF teaser for the README (≤6s, 480p, watch the size), YouTube version                                  | When the launch gets traction      |

The launch post copy reuses the one narrative: hook sentence (the README
"Why?" pain), the link, and one proof point. Do not write a fresh pitch.

## Production checklist

- [ ] Script beats derived from the README value prop: hook → value → evidence → CTA
- [ ] Value test + muted test pass on the beat list
- [ ] Composition committed under `website/video/` (never `/tmp`)
- [ ] `lint` 0 errors, `check` passing (WCAG AA contrast included)
- [ ] Rendered MP4 in `website/public/demo.mp4`, < 3 MB, verified frames
- [ ] Hook frame (t≈2s) shows readable text or product — not blank/title-only
- [ ] Poster frame is a selling frame, extracted from the video
- [ ] Video visible without scrolling; container has `id="demo"`
- [ ] README documentation bar links the demo with accurate runtime
- [ ] `og:image` set from the poster (1200x630)
- [ ] `firebase.json` cache glob covers `mp4|webm|mov`
- [ ] `VideoObject` JSON-LD added
- [ ] Live `HEAD /demo.mp4` verified after deploy
- [ ] `video/node_modules/` gitignored
