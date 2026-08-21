## 1. Where the video goes

- **Landing page position:** in a `ShowcaseSection.astro` component, **above the feature grid** (above the fold) — a framed video player flanked by 2 real screenshots, captioned with its runtime (e.g. "demo.mp4 — 25s product tour").
- **Markup:**
  ```html
  <video controls preload="metadata" poster="/screenshots/{poster}.png">
    <source src="/demo.mp4" type="video/mp4">
    <!-- fallback text node -->
  </video>
  ```
- **Files:** rendered MP4 at `website/public/demo.mp4` (target < 3 MB, 20–30 s, 1080p); HyperFrames composition committed at `website/video/` (never `/tmp`), with `video/node_modules/` gitignored.
- **Supporting requirements:** extend the `firebase.json` cache glob to include `mp4|webm|mov`, add a `VideoObject` JSON-LD block next to the `SoftwareApplication` one, and after deploy verify `HEAD /demo.mp4` → 200/206 with `Cache-Control: public, max-age=31536000, immutable`.

## 2. Poster frame

Extract a **real frame from the video's title scene** with `ffmpeg -ss <t> -frames:v 1` — do **not** reuse a screenshot. It matches the video's first paint and avoids an autoplay jank flash. Save it under `website/public/screenshots/{poster}.png` and reference it via the `poster` attribute above.

## 3. README link bar once the video exists

The skill's link bar (below the tagline, before the `---` separator) does **not** gain a video-specific entry — the video lives on the landing page, so it's reached via the Documentation link:

**Libraries:**
```markdown
**[Documentation](https://{subdomain}.lars.software)** ·
**[pkg.go.dev](https://pkg.go.dev/github.com/LarsArtmann/{repo})** ·
**[Changelog](CHANGELOG.md)**
```

**Applications/servers** (omit pkg.go.dev):
```markdown
**[Documentation](https://{subdomain}.lars.software)** ·
**[Changelog](CHANGELOG.md)**
```

Source: `/tmp/old-wl/website-launch/references/demo-video.md` ("Landing-page integration", "Production checklist"), `/tmp/old-wl/website-launch/SKILL.md` §3.11 + Phase 6 "Documentation link bar", `/tmp/old-wl/website-launch/references/definition-of-done.md` ("Demo video" checklist).
