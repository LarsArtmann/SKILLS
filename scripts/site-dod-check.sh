#!/usr/bin/env bash
# site-dod-check.sh — mechanical Definition-of-Done checker for launched sites.
#
# WHY THIS EXISTS
#   Three sessions running (2026-09-08 emeet-pixyd redeploy, wave-2, wave-3)
#   wrote throwaway /tmp curl scripts to answer the same questions: is the demo
#   video cached-immutable, is the demo anchor on the page, does og:image have
#   REAL 1200x630 dimensions (existence-only checks missed a wrong-size image
#   in the T21 audit), and is firebase.json's header block ordered so the
#   catch-all can't shadow the immutable globs (the 2026-09-12 root cause).
#   This is the permanent version. See AGENTS.md §5.11 and website-launch.
#
# Usage:
#   scripts/site-dod-check.sh <https://site> [--repo DIR]
#     <https://site>   live site root (no trailing slash)
#     --repo DIR       optional: also lint DIR/firebase.json block order
#
# Checks:
#   1. Landing HTML contains id="demo" (the demo video anchor)
#   2. og:image present AND decodes to 1200x630 (PNG/JPEG/WebP; else WARN)
#   3. HEAD /demo.mp4 returns Cache-Control with `immutable`
#   4. First script asset returns Cache-Control with `immutable`
#   5. With --repo: firebase.json headers put the catch-all LAST
#      (catch-all-first shadows immutable globs — the pitfall #33 class)
#
# Exit 0 = no FAIL (WARNs allowed); exit 1 = at least one FAIL.
# Requires: curl, python3.

set -euo pipefail

usage() {
	echo "Usage: $0 <https://site> [--repo DIR]" >&2
	exit 2
}

site=""
repo=""
while [[ $# -gt 0 ]]; do
	case "$1" in
	--repo)
		[[ $# -ge 2 ]] || usage
		repo="$2"
		shift 2
		;;
	http*url*) usage ;;
	*)
		if [[ -z "$site" ]]; then site="$1"; else usage; fi
		shift
		;;
	esac
done
[[ -n "$site" && "$site" =~ ^https?:// ]] || usage
command -v curl > /dev/null 2>&1 || { echo "error: curl not on PATH" >&2; exit 2; }
command -v python3 > /dev/null 2>&1 || { echo "error: python3 not on PATH" >&2; exit 2; }

site="${site%/}"
fails=0
warns=0

note() { printf '  %s\n' "$1"; }
pass() { printf 'PASS %s\n' "$1"; note "$2"; }
fail() {
	printf 'FAIL %s\n' "$1"
	note "$2"
	fails=$((fails + 1))
}
warn() {
	printf 'WARN %s\n' "$1"
	note "$2"
	warns=$((warns + 1))
}

# image_size FILE -> "WxH" or "" (PNG IHDR, JPEG SOF, WebP VP8/VP8L/VP8X)
image_size() {
	python3 - "$1" <<'EOF'
import struct, sys
d = open(sys.argv[1], 'rb').read()
if d[:8] == b'\x89PNG\r\n\x1a\n' and d[12:16] == b'IHDR':
    w, h = struct.unpack('>II', d[16:24]); print(f"{w}x{h}")
elif d[:2] == b'\xff\xd8':
    i = 2
    while i + 9 < len(d):
        if d[i] != 0xFF: i += 1; continue
        m = d[i+1]
        if m in (0xC0, 0xC1, 0xC2, 0xC3):
            h, w = struct.unpack('>HH', d[i+5:i+9]); print(f"{w}x{h}"); break
        i += 2 + struct.unpack('>H', d[i+2:i+4])[0]
elif d[:4] == b'RIFF' and d[8:12] == b'WEBP':
    fourcc, sz = d[12:16], d[16:20]
    body = d[20:]
    if fourcc == b'VP8 ' and body[3:6] == b'\x9d\x01\x2a':
        w, h = struct.unpack('<HH', body[6:10]); print(f"{w & 0x3FFF}x{h & 0x3FFF}")
    elif fourcc == b'VP8L' and body[0] == 0x2F:
        b = struct.unpack('<I', body[1:5])[0]
        print(f"{(b & 0x3FFF) + 1}x{((b >> 14) & 0x3FFF) + 1}")
    elif fourcc == b'VP8X':
        w = int.from_bytes(body[4:7], 'little') + 1
        h = int.from_bytes(body[7:10], 'little') + 1
        print(f"{w}x{h}")
EOF
}

tmp="$(mktemp -d)"
trap 'trash "$tmp" 2>/dev/null || rm -rf "$tmp"' EXIT

# --- 1+2: landing HTML -----------------------------------------------------------
html="$(curl -fsSL --max-time 30 "$site/" )" || {
	fail "landing page fetch" "curl could not fetch $site/ — is the site deployed?"
	echo
	echo "RESULT: FAIL (fetch error)"
	exit 1
}
printf '%s' "$html" > "$tmp/index.html"
if grep -q 'id="demo"' "$tmp/index.html"; then
	pass "demo anchor" 'id="demo" present in landing HTML'
else
	fail "demo anchor" 'no id="demo" in landing HTML — the DoD requires the video anchor (website-launch §demo)'
fi

og="$(grep -oE '<meta[^>]+property="og:image"[^>]*>' "$tmp/index.html" | head -1 || true)"
og_url="$(sed -nE 's/.*content="([^"]+)".*/\1/p' <<<"$og")"
if [[ -z "$og_url" ]]; then
	fail "og:image presence" 'no og:image meta tag on the landing page'
else
	case "$og_url" in
	http*) og_fetch="$og_url" ;;
	*) og_fetch="$site${og_url:-/}" ;;
	esac
	code="$(curl -fsSL --max-time 30 -o "$tmp/og.img" -w '%{http_code}' "$og_fetch" 2>/dev/null || true)"
	if [[ "$code" != "200" ]]; then
		fail "og:image fetch" "og:image $og_fetch returned HTTP $code"
	else
		dims="$(image_size "$tmp/og.img")"
		if [[ -z "$dims" ]]; then
			warn "og:image dimensions" "downloaded $og_fetch but could not decode dimensions (format unsupported by the pure-python parser) — verify 1200x630 by hand"
		elif [[ "$dims" == "1200x630" ]]; then
			pass "og:image dimensions" "$og_fetch is 1200x630"
		else
			fail "og:image dimensions" "$og_fetch is ${dims}, DoD requires 1200x630 (og:image-from-poster, not the template default)"
		fi
	fi
fi

# --- 3+4: cache headers ----------------------------------------------------------
cache_of() { curl -fsSI --max-time 30 "$1" 2>/dev/null | tr -d '\r' | grep -i '^cache-control:' | head -1 || true; }
demo_cc="$(cache_of "$site/demo.mp4")"
if grep -qi 'immutable' <<<"$demo_cc"; then
	pass "demo.mp4 cache" "$demo_cc"
else
	fail "demo.mp4 cache" "HEAD $site/demo.mp4 lacks immutable in Cache-Control (got: ${demo_cc:-<none>}) — header block order in firebase.json shadows the immutable glob (pitfall #33)"
fi
js_src="$(grep -oE '<script[^>]+src="[^"]+"' "$tmp/index.html" | head -1 | sed -E 's/.*src="([^"]+)".*/\1/' || true)"
if [[ -z "$js_src" ]]; then
	warn "JS asset cache" "no <script src> found on the landing page — nothing to check"
else
	case "$js_src" in
	http*) js_url="$js_src" ;;
	/*) js_url="$site$js_src" ;;
	*) js_url="$site/$js_src" ;;
	esac
	js_cc="$(cache_of "$js_url")"
	if grep -qi 'immutable' <<<"$js_cc"; then
		pass "JS asset cache" "$js_url: $js_cc"
	else
		fail "JS asset cache" "$js_url lacks immutable in Cache-Control (got: ${js_cc:-<none>}) — one immutable hit is luck; two prove the header block order"
	fi
fi

# --- 5: firebase.json block-order lint -------------------------------------------
if [[ -n "$repo" ]]; then
	fbj="$repo/firebase.json"
	if [[ ! -f "$fbj" ]]; then
		warn "firebase.json lint" "$fbj not found — pass --repo pointing at the site repo checkout"
	else
		order="$(python3 - "$fbj" <<'EOF'
import json, sys
try:
    host = json.load(open(sys.argv[1]))["hosting"]
except Exception as e:
    print(f"PARSE_ERROR {e}"); raise SystemExit
if isinstance(host, list): host = host[0]
hdrs = host.get("headers", [])
globs = [h.get("source", "") for h in hdrs]
catchalls = [i for i, g in enumerate(globs) if g == "/**"]
print("OK" if not catchalls or catchalls[-1] == len(globs) - 1 else "CATCHALL_FIRST")
EOF
)"
		if [[ "$order" == "OK" ]]; then
			pass "firebase.json block order" "catch-all /** is last (or absent) — immutable globs cannot be shadowed"
		elif [[ "$order" == CATCHALL_FIRST* ]]; then
			fail "firebase.json block order" "catch-all /** is NOT last in headers[] — it matches first and every later immutable glob is dead (the 2026-09-12 root cause)"
		else
			fail "firebase.json lint" "$order"
		fi
	fi
fi

echo
if [[ "$fails" -eq 0 ]]; then
	echo "RESULT: PASS ($warns warn(s)) — $site meets the site DoD"
	exit 0
fi
echo "RESULT: FAIL ($fails fail(s), $warns warn(s)) — $site"
exit 1
