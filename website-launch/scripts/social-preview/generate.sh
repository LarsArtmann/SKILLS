#!/usr/bin/env bash
#
# generate.sh — Render a GitHub social preview card (1280x640 PNG) from flags.
#
# WHY THIS EXISTS
#   Every GitHub repo benefits from a designed social preview, but hand-making
#   one per repo invites the failures this script prevents: text too small to
#   read at real card sizes, oversized files GitHub rejects, duplicated module
#   paths, and fabricated deep-link upload instructions. The layout encodes the
#   design rules validated 2026-09-11 (see
#   website-launch/references/social-preview.md): kicker chip, one title, one
#   tagline, one terminal chip, solid GitHub-dark background, no repetition.
#
#   The script also owns the math a hand-authored SVG gets wrong: monospace
#   advance width is exactly 0.6em, so title/install font sizes are computed
#   to fit the canvas instead of eyeballed, and the outputs are
#   machine-checked against GitHub's documented limits (1280x640, < 1 MB).
#
# USAGE
#   generate.sh --title "linter-autoconfigure-sdk" \
#     [--tagline "Shared foundation for ..."] \
#     [--install "github.com/larsartmann/linter-autoconfigure-sdk"] \
#     [--kicker "GO SDK"] [--output-dir assets/branding]
#
#   All flags except --title are optional; empty tagline/install/kicker skip
#   their block. Writes <output-dir>/social-preview.svg and .png, renders a
#   card-size thumbnail to a temp path for the eyeball check, and prints the
#   manual upload click path (GitHub has no API for social previews).
#
# DEPENDENCIES
#   rsvg-convert (librsvg) or ImageMagick 7 with the RSVG delegate; both are
#   preinstalled on the NixOS host. Fonts: JetBrainsMono Nerd Font + Noto Sans.

set -euo pipefail

usage() {
  cat <<'USAGE'
generate.sh — Render a GitHub social preview card (1280x640 PNG).

  generate.sh --title "linter-autoconfigure-sdk"
    [--tagline "Shared foundation for ..."]
    [--install "github.com/larsartmann/linter-autoconfigure-sdk"]
    [--kicker "GO SDK"] [--output-dir assets/branding]

All flags except --title are optional; empty tagline/install/kicker skip
their block. Writes social-preview.svg + .png into --output-dir, renders a
card-size thumbnail for the eyeball check, and machine-checks GitHub's
documented limits (1280x640, under 1 MB).
USAGE
}

title="" tagline="" install_path="" kicker="GO SDK" outdir="assets/branding"

while [ $# -gt 0 ]; do
  case "$1" in
    --title) title="$2"; shift 2 ;;
    --tagline) tagline="$2"; shift 2 ;;
    --install) install_path="$2"; shift 2 ;;
    --kicker) kicker="$2"; shift 2 ;;
    --output-dir) outdir="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown flag: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ -z "$title" ]; then
  echo "error: --title is required" >&2
  exit 2
fi

xml_escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'; }
esc_title="$(printf '%s' "$title" | xml_escape)"
esc_tagline="$(printf '%s' "$tagline" | xml_escape)"
esc_install="$(printf '%s' "$install_path" | xml_escape)"
esc_kicker="$(printf '%s' "$kicker" | xml_escape)"

# Title: usable width 1088px (96px margins); mono advance = 0.6em.
# Cap at 72px for consistent branding; floor at 44px, then fail honestly —
# a two-line layout is deliberately not supported (untested design).
title_len=${#title}
title_size=$((1088 * 10 / (6 * title_len)))
[ "$title_size" -gt 72 ] && title_size=72
if [ "$title_size" -lt 44 ]; then
  echo "error: title too long for one line (${title_len} chars; max ~41). Shorten it — no two-line layout exists." >&2
  exit 1
fi

# Colorize hyphens in the title (validated accent detail): split on '-' and
# rejoin as tspans, hyphens in #58a6ff.
title_tspans="$(printf '%s' "$esc_title" | awk '{ n=split($0, p, "-"); out=p[1]; for(i=2;i<=n;i++) out=out "<tspan fill=\"#58a6ff\">-</tspan>" p[i]; print out }')"

# Tagline: Noto Sans average advance ~0.53em (heuristic — the 320px thumbnail
# eyeball check is the real gate).
tag_size=36 tag_block=""
if [ -n "$tagline" ]; then
  tag_len=${#tagline}
  est=$((1088 * 100 / (53 * tag_len)))
  [ "$est" -lt 36 ] && tag_size=$est
  [ "$tag_size" -lt 24 ] && tag_size=24
  tag_block=$(cat <<EOF
  <text x="96" y="402" font-family="Noto Sans" font-size="${tag_size}" fill="#9aa7b3">${esc_tagline}</text>
EOF
)
fi

# Kicker chip: width from mono advance + 4px letter-spacing + 80px padding.
kicker_block=""
if [ -n "$kicker" ]; then
  k_len=${#kicker}
  k_w=$(( (156 * k_len / 10) + 4 * (k_len - 1) + 80 ))
  k_cx=$((96 + k_w / 2))
  kicker_block=$(cat <<EOF
  <rect x="96" y="148" width="${k_w}" height="58" rx="29" fill="#161b22" stroke="#30363d" stroke-width="2"/>
  <text x="${k_cx}" y="186" text-anchor="middle" font-family="JetBrainsMono Nerd Font" font-weight="600" font-size="26" letter-spacing="4" fill="#00ADD8">${esc_kicker}</text>
EOF
)
fi

# Terminal chip: "$ go get <path>" = 9 + len(path) mono chars at x=214,
# 36px right padding; shrink font when the path is long (floor 16px).
install_block=""
if [ -n "$install_path" ]; then
  i_chars=$((9 + ${#install_path}))
  i_size=$((958 * 10 / (6 * i_chars)))
  [ "$i_size" -gt 26 ] && i_size=26
  [ "$i_size" -lt 16 ] && i_size=16
  i_text_w=$((6 * i_size * i_chars / 10))
  chip_w=$((154 + i_text_w))
  i_baseline=$((502 + i_size * 36 / 100))
  install_block=$(cat <<EOF
  <rect x="96" y="458" width="${chip_w}" height="88" rx="16" fill="#010409" stroke="#30363d" stroke-width="2"/>
  <circle cx="130" cy="502" r="6.5" fill="#ff5f56"/>
  <circle cx="157" cy="502" r="6.5" fill="#ffbd2e"/>
  <circle cx="184" cy="502" r="6.5" fill="#27c93f"/>
  <text x="214" y="${i_baseline}" xml:space="preserve" font-family="JetBrainsMono Nerd Font" font-size="${i_size}"><tspan fill="#3fb950">\$</tspan><tspan fill="#f0f6fc" font-weight="600"> go get </tspan><tspan fill="#79c0ff">${esc_install}</tspan></text>
EOF
)
fi

mkdir -p "$outdir"
svg_path="$outdir/social-preview.svg"
png_path="$outdir/social-preview.png"

cat > "$svg_path" <<EOF
<svg width="1280" height="640" viewBox="0 0 1280 640" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="${esc_title}">
  <defs>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#00ADD8"/>
      <stop offset="0.55" stop-color="#58a6ff"/>
      <stop offset="1" stop-color="#3fb950"/>
    </linearGradient>
  </defs>

  <rect width="1280" height="640" fill="#0d1117"/>
  <rect width="1280" height="10" fill="url(#accent)"/>

${kicker_block}

  <text x="96" y="330" font-family="JetBrainsMono Nerd Font" font-weight="800" font-size="${title_size}" fill="#f0f6fc">${title_tspans}</text>
${tag_block}

${install_block}
</svg>
EOF

# Render: librsvg directly when available, else ImageMagick's RSVG delegate.
if command -v rsvg-convert >/dev/null 2>&1; then
  rsvg-convert -w 1280 -h 640 "$svg_path" -o "$png_path"
elif command -v magick >/dev/null 2>&1; then
  magick "$svg_path" "$png_path"
else
  echo "error: need rsvg-convert or magick (librsvg) to render" >&2
  exit 1
fi

# Machine-check GitHub's documented limits before handing this to the user.
bytes=$(wc -c < "$png_path" | tr -d ' ')
if [ "$bytes" -ge 1048576 ]; then
  echo "error: $png_path is ${bytes} bytes; GitHub rejects previews of 1 MB or more" >&2
  exit 1
fi
dims=$(magick identify -format '%wx%h' "$png_path" 2>/dev/null || true)
if [ "$dims" != "1280x640" ]; then
  echo "error: rendered ${dims:-unknown}, expected 1280x640" >&2
  exit 1
fi

card_png="$(mktemp /tmp/social-preview-card-size.XXXXXX.png)"
magick "$png_path" -resize 320x160 "$card_png"

echo "OK $png_path (${bytes} bytes, 1280x640, under GitHub's 1 MB limit)"
echo "   source: $svg_path"
echo "   eyeball check (real card size): $card_png"
echo "   upload (manual, no API, no deep URL):"
echo "     https://github.com/<owner>/<repo>/settings -> Social preview -> Edit -> Upload an image..."
