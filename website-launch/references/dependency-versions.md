# Dependency Version Matrix — Verified Working

> These versions are verified to work together.
> Do NOT bump versions without testing — several combinations are known
> to break.
>
> **Last verified:** 2026-07-13 against samber-do-auditlog (simple,
> no OG/CSP, no `astro-og-canvas`) and gogenfilter (full-feature). Both
> built successfully with Astro 7 on Node.js 22/24 via Nix.
>
> **CRITICAL:** The `vite` override MUST be removed for Astro 7.
> Astro 7 resolves Vite 8 internally. Pinning `vite: 7.3.2` (from
> gogenfilter's older lockfile) causes a fatal Rollup error. See the
> "Vite Override — Critical Fix" section below.

## Verified Working — Simple (samber-do-auditlog baseline — Astro 7)

The recommended starting point for new sites. No OG images, no CSP.
Verified 2026-07-13 with a clean `npm install` + `npm run build`:

```json
{
	"dependencies": {
		"@astrojs/sitemap": "^3.7.3",
		"@astrojs/starlight": "^0.41.1",
		"@tailwindcss/vite": "^4.3.1",
		"astro": "^7.0.3",
		"tailwindcss": "^4.3.1"
	},
	"devDependencies": {
		"@astrojs/check": "^0.9.9",
		"html-validate": "^11.5.3",
		"typescript": "^6.0.3"
	},
	"overrides": {
		"brace-expansion": "5.0.6",
		"devalue": "5.8.1",
		"yaml": "2.8.3"
	}
}
```

## Verified Working — Full-Feature (gogenfilter baseline — Astro 7)

For sites with OG images, CSP, and CI/CD. Add `astro-og-canvas` and
`jscpd` to the simple set above:

```json
{
	"dependencies": {
		"@astrojs/sitemap": "^3.7.3",
		"@astrojs/starlight": "^0.41.1",
		"@tailwindcss/vite": "^4.3.1",
		"astro": "^7.0.3",
		"astro-og-canvas": "^0.12.0",
		"tailwindcss": "^4.3.1"
	},
	"devDependencies": {
		"@astrojs/check": "^0.9.9",
		"html-validate": "^11.5.3",
		"jscpd": "^5.0.11",
		"typescript": "^6.0.3"
	},
	"overrides": {
		"brace-expansion": "5.0.6",
		"devalue": "5.8.1",
		"yaml": "2.8.3"
	}
}
```

**Build script:** `"build": "astro build && node scripts/fix-csp.mjs"`

## Vite Override — Critical Fix

**Problem:** gogenfilter's `package.json` has `"vite": "7.3.2"` in
overrides. This was valid when gogenfilter ran Astro 6. When used with
Astro 7, which resolves Vite 8 internally, the pin causes:

```
rollupOptions.input should not be an html file when building for SSR.
```

**Fix:** **REMOVE the `vite` key from overrides entirely.** Keep only:

```json
"overrides": {
  "brace-expansion": "5.0.6",
  "devalue": "5.8.1",
  "yaml": "2.8.3"
}
```

**This was the #1 build failure in the samber-do-auditlog session
(2026-07-13).** If you copy gogenfilter's `package.json` as a starting
point, delete the `"vite"` line from overrides before running
`npm install`.

## The Astro 6 vs 7 History (resolved)

A prior session (go-output) hit a Rollup error when using
`astro-og-canvas@0.11.1` with Astro 7. The root cause was twofold:

1. `astro-og-canvas@0.11.x` did not support Astro 7 (fixed in 0.12.0)
2. The `vite: 7.3.2` override conflicted with Astro 7's Vite 8

**Both issues are now resolved.** Use `astro-og-canvas@^0.12.0` with
Astro 7, and **never pin `vite` in overrides**.

## npm v11+ Install Scripts

npm v11+ blocks install scripts by default (`esbuild`, `sharp` need them).
After `npm install`, run:

```bash
npm approve-scripts esbuild sharp
```

Without this, the Astro build fails with missing native binaries.

If using bun: `bun install` handles this automatically, but `firebase
deploy` will fail under bun's node shim (see common-pitfalls.md).

## `--legacy-peer-deps` Trap

If peer dependency conflicts force `--legacy-peer-deps`, create a `.npmrc`
file in the same commit:

```ini
legacy-peer-deps=true
```

Without this, anyone cloning the repo and running plain `npm install` will
get `ERESOLVE` errors. The lockfile works only because it was generated
with the flag.

**Better approach:** Use the verified version matrix above — these
versions are compatible without `--legacy-peer-deps`.

## Package Manager Guidance

| Task                 | Tool                   | Why                                                                        |
| -------------------- | ---------------------- | -------------------------------------------------------------------------- |
| Install dependencies | `npm install`          | Recommended — CI uses `npm ci` with `package-lock.json`                    |
| Build                | `npm run build`        | Works under both npm and bun                                               |
| Deploy to Firebase   | Real Node.js (not bun) | `firebase deploy` uses `re2` native module — bun's node shim can't load it |

**Default to `npm`.** Use `bun` only for fast iteration during development,
then switch to real Node.js (via Nix) for deploy.

### Lockfile Decision

Commit `package-lock.json` (not `bun.lock`). The CI workflow uses `npm install`
with `cache: npm`, which requires `package-lock.json`. If both lockfiles exist,
add `bun.lock` to `.gitignore` (the gogenfilter `.gitignore` does this).

```gitignore
# .gitignore
bun.lock
```

### Deploying with real Node.js

```bash
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase deploy --only hosting:{siteId} --project lars-software
```

Or use the Nix devShell (which provides real Node.js).

## firebase-tools is NOT a dependency

`firebase-tools` should NOT be in `package.json` dependencies or
devDependencies. It comes from:

1. The Nix devShell (`flake.nix`), or
2. `nix shell nixpkgs#firebase-tools` for one-off commands

If you accidentally `npm install firebase-tools` while debugging, remove it
before committing:

```bash
npm remove firebase-tools
```

Reference websites do NOT have `firebase-tools` as a dependency.
