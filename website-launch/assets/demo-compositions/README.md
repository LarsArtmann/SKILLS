# Demo-composition ground-truth fixtures

Two minimal, deterministic HyperFrames compositions that exercise the exact
pipeline `website-launch/references/demo-video.md` documents:

- `16x9/index.html` — 1920x1080 master (composition id `gt-16x9`)
- `9x16/index.html` — 1080x1920 vertical cut, same beats, resized composition
  (composition id `gt-9x16`)

## Why these exist

The 2026-09-08 TODO-wave-2 session rendered ground-truth evidence in /tmp and
then trashed it at cleanup, leaving the wave report's evidence pointers
dangling (`2026-09-08_23-53_todo-wave-2-full-status.md`, section d1). These
fixtures give that evidence a durable home: the compositions are text, so
anyone can rebuild the renders with the documented recipe and compare.

**Rendered MP4s are deliberately NOT committed** — binary-asset policy for
this content repo is an open question (full-status report section g2). The
render transcripts below are the committed evidence.

## How to re-render (NixOS)

```bash
for d in 16x9 9x16; do
  rm scratch -rf 2>/dev/null || true   # scratch OUTSIDE this repo, e.g. /tmp
  mkdir -p /tmp/hf-fixture-$d
  cp $d/index.html /tmp/hf-fixture-$d/
  ~/projects/SKILLS/scripts/hf-env.sh --install /tmp/hf-fixture-$d
  cd /tmp/hf-fixture-$d
  ~/projects/SKILLS/scripts/hf-env.sh -- node node_modules/hyperframes/bin/hyperframes.mjs check
  ~/projects/SKILLS/scripts/hf-env.sh -- node node_modules/hyperframes/bin/hyperframes.mjs \
    render --quality draft --output $d.mp4
  nix shell nixpkgs#ffmpeg -c ffprobe -v error -show_entries \
    stream=width,height,codec_name,duration -of default=noprint_wrappers=1 $d.mp4
  cd - >/dev/null
done
```

## Verification record

Rendered and ffprobe-verified 2026-09-09 (hyperframes via
`scripts/hf-env.sh`, draft quality, ~7s wall clock per render):

| Fixture | Resolution | Codec | Duration | Frames | Size |
| ------- | ---------- | ----- | -------- | ------ | ---- |
| 16x9    | 1920x1080  | h264  | 5.0s     | 150    | see `16x9/render-log.txt` |
| 9x16    | 1080x1920  | h264  | 5.0s     | 150    | see `9x16/render-log.txt` |

Full command transcripts: `16x9/render-log.txt`, `9x16/render-log.txt`.
