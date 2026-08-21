## Demo video placement (landing page)

- **Visible without scrolling** — on a 1440x900 viewport the video must be on screen at page load: either embedded **in the hero, next to the headline + primary CTA**, or as the **first section directly below the hero**. "Above the feature grid" alone is too weak. Keep the existing `ShowcaseSection.astro` as the vehicle; just move it up.
- Give the video container `id="demo"` so README/social posts can deep-link `{subdomain}.lars.software/#demo`.
- Player markup:
  ```html
  <video controls preload="metadata" poster="/screenshots/demo-poster.png">
    <source src="/demo.mp4" type="video/mp4">
    <!-- fallback text node -->
  </video>
  ```
  Default is click-to-play with a styled poster; muted autoplay/loop only if you ask for it.
- Caption it with the runtime, phrased to earn the click: *"See it work end-to-end — 25 seconds."* — not "demo.mp4".

## Poster frame

- Pick the **strongest selling frame — the transformation/result moment, not the title card**. It must contain readable product visuals (never blank or text-only).
- Only match the video's first paint if it autoplays (avoids the flash).
- It doubles as the landing page's `og:image` — crop/letterbox to **1200x630** so link unfurls show the money shot.

## README link bar (once the video exists)

Append a third link to the documentation bar (below the tagline, before the `---` separator), with the **real runtime**:

```markdown
<p align="center">
<a href="https://{subdomain}.lars.software">Documentation</a> · <a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}">API Reference</a> · <a href="https://{subdomain}.lars.software/#demo">Watch the 25s demo</a>
</p>
```

(Swap `API Reference` → `Changelog` for applications; replace `25s` with the actual runtime.)

Source: `/home/lars/projects/SKILLS/website-launch/references/demo-video.md` ("Landing-page integration"), `/home/lars/projects/SKILLS/website-launch/references/readme-template.md` ("Documentation Link Bar"), SKILL.md §3.11.
