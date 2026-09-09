#!/usr/bin/env bash
#
# hf-env.sh — run HyperFrames on NixOS: real nix node + chrome-headless-shell libs.
#
# WHY: the machine's `node` is a shim into bun (@img/sharp refuses to load
# under bun, so bunx/pnpm-dlx fail at startup), and the CLI insists on
# puppeteer's cached chrome-headless-shell, which needs ~21 NixOS shared
# libraries. Store paths change with every nixpkgs bump, so this script
# resolves them at RUNTIME instead of hardcoding them in prose (the wave-2
# report's e5 finding). It gates on `ldd` showing zero unresolved libraries
# before any render, so a lib drift fails loudly here, not as a mystery
# browser crash. Pipeline docs: website-launch/references/demo-video.md
# (execution-verified 2026-09-08, hyperframes 0.8.31).
#
# USAGE
#   scripts/hf-env.sh --libs                 # print the LD_LIBRARY_PATH
#   scripts/hf-env.sh --install <dir>        # pnpm init + pnpm add hyperframes in <dir> (real node)
#   scripts/hf-env.sh -- <cmd...>            # run cmd with real nix node + LD_LIBRARY_PATH, e.g.:
#     scripts/hf-env.sh -- node node_modules/hyperframes/bin/hyperframes.mjs check
#     scripts/hf-env.sh -- node node_modules/hyperframes/bin/hyperframes.mjs render --quality draft --output out.mp4
set -euo pipefail

pkgs=(
	glib.out dbus.lib systemd nss nspr atk at-spi2-core cups alsa-lib expat
	libxkbcommon libgbm mesa.drivers
	xorg.libX11 xorg.libXcomposite xorg.libXdamage xorg.libXext
	xorg.libXfixes xorg.libXrandr xorg.libxcb xorg.libXtst
	stdenv.cc.cc.lib
)

build_libs() {
	local paths
	paths="$(nix build "${pkgs[@]/#/nixpkgs#}" --no-link --print-out-paths 2>/dev/null)"
	printf '%s\n' "$paths" | sed -E 's|/?$|/lib|' | paste -sd ':' -
}

gate_browser() {
	local bin missing
	bin="$(ls -t ~/.cache/puppeteer/chrome-headless-shell/*/chrome-headless-shell-linux64/chrome-headless-shell 2>/dev/null | head -1 || true)"
	if [[ -z "$bin" ]]; then
		echo "ERROR: puppeteer's cached chrome-headless-shell not found under ~/.cache/puppeteer." >&2
		echo "Run any hyperframes command once (first run downloads it), then retry." >&2
		echo "(Note: 'hyperframes browser clear' empties ~/.cache/hyperframes/chrome, NOT this cache.)" >&2
		return 1
	fi
	missing="$(LD_LIBRARY_PATH="$1" ldd "$bin" 2>/dev/null | grep 'not found' || true)"
	if [[ -n "$missing" ]]; then
		echo "ERROR: chrome-headless-shell has unresolved libraries with the current package set:" >&2
		echo "$missing" >&2
		echo "Map each missing lib to its nixpkgs package and extend \$pkgs in this script." >&2
		return 1
	fi
}

case "${1:-}" in
--libs)
	build_libs
	;;
--install)
	dir="${2:?usage: hf-env.sh --install <dir>}"
	mkdir -p "$dir"
	cd "$dir"
	nix shell nixpkgs#nodejs -c pnpm init
	nix shell nixpkgs#nodejs -c pnpm add hyperframes
	;;
"")
	sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
	;;
--)
	shift
	libs="$(build_libs)"
	gate_browser "$libs"
	exec nix shell nixpkgs#nodejs -c env LD_LIBRARY_PATH="$libs" "$@"
	;;
*)
	echo "Unknown mode: $1 (see header for usage)" >&2
	exit 2
	;;
esac
