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
#     [--kicker "GO SDK"] [--output-dir assets/branding] [--animate typing]
#
#   All flags except --title are optional; empty tagline/install/kicker skip
#   their block. Writes <output-dir>/social-preview.svg and .png, renders a
#   card-size thumbnail to a temp path for the eyeball check, and prints the
#   manual upload click path (GitHub has no API for social previews).
#   --animate typing additionally writes social-preview-animated.gif: a
#   delta-optimized typing loop that plays on Discord/Slack/Telegram and
#   degrades to its first frame everywhere else. The static card stays the
#   upload candidate; the static design is the animation's final frame.
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
    [--kicker "GO SDK"] [--output-dir assets/branding] [--animate typing]

All flags except --title are optional; empty tagline/install/kicker skip
their block. Writes social-preview.svg + .png into --output-dir, renders a
card-size thumbnail for the eyeball check, and machine-checks GitHub's
documented limits (1280x640, under 1 MB). --animate typing adds a
delta-optimized typing-loop GIF.
USAGE
}

title="" tagline="" install_path="" kicker="GO SDK" outdir="assets/branding" animate=""

while [ $# -gt 0 ]; do
	case "$1" in
	--title)
		title="$2"
		shift 2
		;;
	--tagline)
		tagline="$2"
		shift 2
		;;
	--install)
		install_path="$2"
		shift 2
		;;
	--kicker)
		kicker="$2"
		shift 2
		;;
	--output-dir)
		outdir="$2"
		shift 2
		;;
	--animate)
		animate="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "error: unknown flag: $1" >&2
		usage >&2
		exit 2
		;;
	esac
done

if [ -z "$title" ]; then
	echo "error: --title is required" >&2
	exit 2
fi
if [ -n "$animate" ] && [ "$animate" != "typing" ]; then
	echo "error: --animate supports only 'typing' (got: $animate)" >&2
	exit 2
fi
if [ -n "$animate" ] && [ -z "$install_path" ]; then
	echo "error: --animate typing requires --install" >&2
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
	tag_block=$(
		cat <<EOF
  <text x="96" y="402" font-family="Noto Sans" font-size="${tag_size}" fill="#9aa7b3">${esc_tagline}</text>
EOF
	)
fi

# Kicker chip: width from mono advance + 4px letter-spacing + 80px padding.
kicker_block=""
if [ -n "$kicker" ]; then
	k_len=${#kicker}
	k_w=$(((156 * k_len / 10) + 4 * (k_len - 1) + 80))
	k_cx=$((96 + k_w / 2))
	kicker_block=$(
		cat <<EOF
  <rect x="96" y="148" width="${k_w}" height="58" rx="29" fill="#161b22" stroke="#30363d" stroke-width="2"/>
  <text x="${k_cx}" y="186" text-anchor="middle" font-family="JetBrainsMono Nerd Font" font-weight="600" font-size="26" letter-spacing="4" fill="#00ADD8">${esc_kicker}</text>
EOF
	)
fi

# Terminal chip geometry: "$" + " go get " + <path> = 9 + len(path) mono
# chars at x=214, 36px right padding; shrink font when the path is long
# (floor 16px).
i_size=26 i_chars=9
if [ -n "$install_path" ]; then
	i_chars=$((9 + ${#install_path}))
	i_size=$((958 * 10 / (6 * i_chars)))
	[ "$i_size" -gt 26 ] && i_size=26
	[ "$i_size" -lt 16 ] && i_size=16
fi
i_text_w=$((6 * i_size * i_chars / 10))
chip_w=$((154 + i_text_w))
i_baseline=$((502 + i_size * 36 / 100))
i_adv=$((6 * i_size / 10))

# emit_frame <typed-chars> <cursor 0|1> <png-out>
#
# Single source of truth for the card: the static card IS the final
# animation frame (full text, cursor off), so the two artifacts can never
# drift apart. The typed text has two color segments — " go get " (white,
# bold) then the module path (blue) — matching the static design.
W_SEG=" go get "
total_chars=$(( ${#W_SEG} + ${#install_path} ))
emit_frame() {
	local k=$1 cursor=$2 out=$3
	local vis_w="" vis_p="" cur_rect="" install_text="" tsvg
	if [ -n "$install_path" ]; then
		vis_w="${W_SEG:0:k}"
		if [ "$k" -gt ${#W_SEG} ]; then
			vis_w="$W_SEG"
			vis_p="${esc_install:0:k - ${#W_SEG}}"
		fi
		if [ "$cursor" = "1" ]; then
			local cx=$((214 + i_adv * k))
			cur_rect="<rect x=\"${cx}\" y=\"$((i_baseline - i_size * 73 / 100))\" width=\"$((i_size * 14 / 26))\" height=\"${i_size}\" fill=\"#f0f6fc\" opacity=\"0.85\"/>"
		fi
		install_text="  <rect x=\"96\" y=\"458\" width=\"${chip_w}\" height=\"88\" rx=\"16\" fill=\"#010409\" stroke=\"#30363d\" stroke-width=\"2\"/>
  <circle cx=\"130\" cy=\"502\" r=\"6.5\" fill=\"#ff5f56\"/>
  <circle cx=\"157\" cy=\"502\" r=\"6.5\" fill=\"#ffbd2e\"/>
  <circle cx=\"184\" cy=\"502\" r=\"6.5\" fill=\"#27c93f\"/>
  <text x=\"214\" y=\"${i_baseline}\" xml:space=\"preserve\" font-family=\"JetBrainsMono Nerd Font\" font-size=\"${i_size}\"><tspan fill=\"#3fb950\">\$</tspan><tspan fill=\"#f0f6fc\" font-weight=\"600\">${vis_w}</tspan><tspan fill=\"#79c0ff\">${vis_p}</tspan></text>
  ${cur_rect}"
	fi
	tsvg="${out%.png}.svg"
	cat >"$tsvg" <<EOF
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

${install_text}
</svg>
EOF
	render_svg "$tsvg" "$out"
}

render_svg() {
	if command -v rsvg-convert >/dev/null 2>&1; then
		rsvg-convert -w 1280 -h 640 "$1" -o "$2"
	elif command -v magick >/dev/null 2>&1; then
		magick "$1" "$2"
	else
		echo "error: need rsvg-convert or magick (librsvg) to render" >&2
		exit 1
	fi
}

mkdir -p "$outdir"
svg_path="$outdir/social-preview.svg"
png_path="$outdir/social-preview.png"

# The static card is the completed animation frame: full text, cursor off.
emit_frame "$total_chars" 0 "$png_path"
if [ "${png_path%.png}.svg" != "$svg_path" ]; then
	mv "${png_path%.png}.svg" "$svg_path"
fi

# Motion variant: typing loop as delta-optimized GIF (validated 2026-09-11:
# 32 frames, ~37 KB at 1280x640 — under 4% of GitHub's 1 MB budget).
animated_gif=""
if [ -n "$animate" ]; then
	frames_dir="$(mktemp -d)"
	trap 'rm -rf "$frames_dir"' EXIT
	n=0
	for ((k = 1; k <= total_chars; k += 2)); do
		printf -v f "%s/t%03d.png" "$frames_dir" $n
		emit_frame "$k" 1 "$f"
		n=$((n + 1))
	done
	for blink in 1 0 1 0; do
		printf -v f "%s/t%03d.png" "$frames_dir" $n
		emit_frame "$total_chars" $blink "$f"
		n=$((n + 1))
	done
	typing=()
	for ((i = 0; i < n - 4; i++)); do
		printf -v f "%s/t%03d.png" "$frames_dir" $i
		typing+=("$f")
	done
	hold=()
	for ((i = n - 4; i < n; i++)); do
		printf -v f "%s/t%03d.png" "$frames_dir" $i
		hold+=("$f")
	done
	animated_gif="$outdir/social-preview-animated.gif"
	magick -loop 0 -delay 4 "${typing[@]}" -delay 70 "${hold[@]}" -layers optimize -colors 64 "$animated_gif"
fi

# Machine-check GitHub's documented limits before handing this to the user.
bytes=$(wc -c <"$png_path" | tr -d ' ')
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
if [ -n "$animated_gif" ]; then
	gif_bytes=$(wc -c <"$animated_gif" | tr -d ' ')
	gif_frames=$(magick identify "$animated_gif" 2>/dev/null | wc -l | tr -d ' ')
	if [ "$gif_bytes" -ge 1048576 ]; then
		echo "error: $animated_gif is ${gif_bytes} bytes; GitHub rejects previews of 1 MB or more" >&2
		exit 1
	fi
	echo "   motion: $animated_gif (${gif_bytes} bytes, ${gif_frames} frames) — plays on Discord/Slack/Telegram; first frame elsewhere"
fi
echo "   upload (manual, no API, no deep URL):"
echo "     https://github.com/<owner>/<repo>/settings -> Social preview -> Edit -> Upload an image..."
