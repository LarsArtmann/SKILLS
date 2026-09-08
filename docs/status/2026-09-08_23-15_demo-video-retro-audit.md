# Status Report — Demo-Video DoD Retro-Audit of Live Sites (T21)

**Date:** 2026-09-08 ~23:15
**Scope:** Audit every live `*.lars.software` site against the demo-video
section of `website-launch/references/definition-of-done.md` (the 2026-08-21
sales-video reimagining, item f10). Four sites found via each repo's GitHub
homepage field; all checks executed against repo HEAD (GitHub API) and the
live sites (HTTP fetch + HEAD via bun).

**TL;DR:** Only emeet-pixyd has a video at all (4/9 demo-video items pass);
the other three sites — including both reference baselines the skill
teaches from — predate the video bar entirely. The single most actionable
finding is not about videos: emeet-pixyd's live site serves
`Cache-Control: max-age=0` for EVERY asset because `firebase.json` deploys
are manual and the 2026-09-04 config never shipped.

## Per-site scores (demo-video DoD, 9 items)

| Site                                        | Score | Verdict                                                                          |
| ------------------------------------------- | ----- | -------------------------------------------------------------------------------- |
| emeet-pixyd.lars.software                   | 4/9   | Only site with a video; fails placement id, composition, README link, live cache |
| gogenfilter.lars.software                   | 0/9   | No video anywhere; og:image exists (astro-og-canvas, not poster-derived)         |
| atomicwrite.lars.software (go-atomic-write) | 0/9   | No video; static og-image.png; no video infra                                    |
| filewatcher.lars.software (go-filewatcher)  | 0/9   | No video; cache glob lacks mp4                                                   |

## emeet-pixyd detail (the only non-trivial case)

| DoD item                                         | Result                                                                                                       |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| `website/public/demo.mp4` < 3 MB, ~20-30s        | ✅ 1,488,233 bytes; page label says "25s product tour" (runtime accuracy ✅ where linked)                    |
| Script beats from README value prop              | ⚠️ Unverifiable — composition was lost in `/tmp` (the incident that created this DoD item); only MP4 survived |
| Visible without scrolling; container `id="demo"` | ⚠️ Video sits directly under the hero ("The real control panel…") — placement ✅; `id="demo"` ❌ missing      |
| Composition committed under `website/video/`     | ❌ No `website/video/` in repo tree — composition still lost                                                 |
| Poster is a selling frame                        | ✅ `/screenshots/webui-viewport.png` — real product UI, not a title card                                     |
| README docs bar links demo with runtime          | ❌ README has Documentation badge + footer link only; no "Watch the demo"                                    |
| `og:image` from poster (1200x630)                | ⚠️ `og/home.png` exists (astro-og-canvas template) — not poster-derived                                       |
| `firebase.json` glob covers `mp4\|webm\|mov`     | ✅ In repo HEAD (committed 2026-09-04)                                                                       |
| Live `HEAD /demo.mp4` returns immutable caching  | ❌ Live returns `public, max-age=0, must-revalidate` — as does EVERY asset (js/svg/png too)                  |

## Cross-cutting findings

1. **Stale manual deploy (new pitfall #33).** emeet-pixyd's repo config
   promises immutable caching; the live site honors it for nothing. Deploys
   are manual; no CI gate exists. The DoD's `HEAD /demo.mp4` check exists
   precisely for this — run it after every config change, not just at
   launch. Encoded in `website-launch/references/common-pitfalls.md` §33.
2. **The two "reference baseline" repos fail the video bar they teach.**
   gogenfilter is the skill's recommended baseline and has no demo video;
   next session that touches either site should add the full video flow,
   which would also produce the ground-truth render T22 asks for.
3. **`id="demo"` + README link are cheap fixes** for emeet-pixyd and make
   its existing video actually discoverable per the DoD.

## Follow-ups (for the site repos, not this repo)

| # | Task                                                                                          | Repo                            | Effort |
| - | --------------------------------------------------------------------------------------------- | ------------------------------- | ------ |
| 1 | Redeploy hosting; verify `HEAD /demo.mp4` + one JS asset return immutable                     | emeet-pixyd                     | S      |
| 2 | Add `id="demo"` to the video container; add "Watch the 25s demo" to README docs bar           | emeet-pixyd                     | S      |
| 3 | Recreate the HyperFrames composition from the surviving MP4 and commit under `website/video/` | emeet-pixyd                     | M      |
| 4 | Full demo-video flow (first implementation of T22's corrected guidance)                       | gogenfilter                     | L      |
| 5 | Video flow + og:image upgrade                                                                 | go-atomic-write, go-filewatcher | L      |

_Point-in-time snapshot; annotate, never rewrite. Evidence: GitHub trees API

- live HTTP checks 2026-09-08._
