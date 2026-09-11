# Social Preview (GitHub repo card image)

The social preview is the image GitHub renders when the repo is linked in
cards, tweets, Slack/Discord, and mobile share sheets. It is repo metadata,
not a website asset — this reference covers the verified constraints, the
upload path, and a render workflow that survives real card sizes.

All GitHub constraints below were verified against docs.github.com
("Customizing your repository's social media preview", 2026-09-11).

## Verified constraints

| Constraint  | Value                                                                                    |
| ----------- | ---------------------------------------------------------------------------------------- |
| Formats     | PNG, JPG, GIF                                                                            |
| Size limit  | under 1 MB                                                                               |
| Minimum     | 640 x 320 px                                                                             |
| Recommended | 1280 x 640 px (2x minimum, renders crispest)                                             |
| Background  | solid recommended; transparency works but looks unpredictable across light/dark surfaces |

## Upload path (manual; no API exists)

`https://github.com/<owner>/<repo>/settings` -> scroll to **Social preview**
-> **Edit** -> **Upload an image...**

There is NO deep sub-URL. Guessing `/settings/social-preview` returns a 404
(verified the hard way 2026-09-11: the guessed link was handed to the user
and failed). GitHub has no API for this setting, so this step is always
manual — hand the user the exact click path, never a constructed deep link.

After upload, verify the loop closed: fetch the repo page and confirm the
`og:image` meta tag points at the new asset.

## Platform matrix (link previews outside GitHub)

Verified 2026-09-11 unless noted. The gatekeeper is each platform's crawler,
not the browser: crawlers fetch og:image, re-process it, and serve their own
copy — so format support below is what the crawler accepts, and animation
survives only where the platform plays motion in the card.

| Platform   | Formats                     | Recommended size / ratio | Max size | Animated GIF in card? |
| ---------- | --------------------------- | ------------------------ | -------- | --------------------- |
| GitHub     | PNG, JPG, GIF               | 1280x640 (2:1)           | 1 MB     | unverified            |
| X/Twitter  | JPG, PNG, WEBP, GIF         | 1200x628+ (2:1)          | 5 MB     | No — official: "Only the first frame of an animated GIF will be used" |
| LinkedIn   | JPG, PNG, GIF (no WebP)     | 1200x627 (1.91:1)        | 5 MB     | No — static first frame |
| Discord    | JPG, PNG, WebP, GIF         | 1200x630 works           | —        | **Yes** (official `IS_ANIMATED` embed flag) |
| Slack      | GIF, JPEG, PNG, WebP        | ~1200x630 works          | —        | **Yes** (media unfurl behavior) |
| Telegram   | JPG, PNG, WEBP, GIF         | 1.91:1; downscales >2560px | —      | **Yes** — converts GIF to looping MP4 (Instant View manual: "GIF would be converted into Video type"); autoplay per user setting |
| Mastodon   | JPG, PNG, WEBP, static GIF  | 1.91:1, min ~400x210     | —        | No — static thumbnail (source-level: FetchLinkCardService) |
| Reddit     | JPG, PNG, WEBP              | n/a (140x140 thumbs)     | —        | No — static thumbnail (community-observed) |

Mastodon/Reddit behavior is community/source-observed, not officially
documented; Slack animation is documented media behavior but untested with
our cards.

**Format verdicts:** animated SVG — no platform accepts it as og:image (and
SVGs do not rasterize in crawler pipelines at all); WebP/APNG/animated AVIF —
universally supported by browsers (~90-97%, caniuse 2026-09-11) but rejected
or unaccepted by most crawlers; LinkedIn notably lacks WebP. **Animated GIF
is the only format that carries motion, and only Discord/Slack/Telegram play
it.** Everywhere else the first frame shows — which is why the animation
design rule is "first frame pixel-identical to the static card".

**Size strategy:** GitHub wants 2:1 (1280x640); the OG standard and
LinkedIn/Mastodon want 1.91:1 (1200x630). The two are within ~5% — design
with safe margins (keep content ~60px inside every edge) and a single
1280x640 card survives center-crop everywhere; generate a separate 1200x630
only for pixel-perfect LinkedIn/OG cards.

## Design workflow (validated 2026-09-11 on linter-autoconfigure-sdk)

The bundled generator automates everything in this section:
[generate.sh](../scripts/social-preview/generate.sh) with
`--title/--tagline/--install/--kicker/--output-dir`. It computes the font-fit
math below (monospace advance is exactly 0.6em), renders, and machine-checks
GitHub's limits. The steps document what it does — and are the manual
fallback when working outside the script.

1. **Keep the source versioned next to the PNG.** Author an SVG
   (`assets/branding/social-preview.svg`), render to
   `assets/branding/social-preview.png`. Git preserves every revision; the
   SVG keeps future edits editable instead of reverse-engineered.
2. **Render with librsvg** (present on the NixOS host as ImageMagick's SVG
   delegate, or call `rsvg-convert` directly):
   `rsvg-convert -w 1280 -h 640 social-preview.svg -o social-preview.png`
3. **Verify at card size, not just full size.** Render a ~320x160 thumbnail
   and view it. Text that looks great at 1280px turns to mush in an actual
   repo card; the thumbnail is the honest test.
4. **Machine-check the output:** dimensions (PNG IHDR bytes or
   `magick identify`) and file size (< 1 MB).

### Design rules that survived the 2026-09-11 iteration

- **Hierarchy over completeness.** Four competing text blocks read as noise
  at card size. One kicker chip, one title, one one-liner, one actionable
  element is enough.
- **Never repeat information.** The original image showed the module path
  twice (install command + footer); the footer was pure noise at card size.
- **Solid GitHub-dark background** (`#0d1117`) reads on both GitHub light
  and dark UI. Avoid transparency.
- **A terminal chip reads as "developer tool" even when too small to read**:
  traffic-light dots, green `$`, white command, blue path. Semantic
  color-coding survives size reduction; raw text does not.
- **Fonts on the NixOS host:** JetBrainsMono Nerd Font (Regular through
  ExtraBold) and Noto Sans are installed; use mono for the artifact name and
  sans for prose lines.

### SVG gotcha

`xml:space` defaults to collapsing: leading/trailing spaces inside `<tspan>`
elements disappear (`$ go get` renders as `$go get`). Set
`xml:space="preserve"` on text elements that mix tspans with spaces, or the
prompt spacing silently breaks.
