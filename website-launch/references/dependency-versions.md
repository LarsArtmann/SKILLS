# Dependency Version Matrix — Verified Working

> These versions are verified to work together, taken directly from the
> gogenfilter `package.json` (the most complete reference baseline).
> Do NOT bump versions without testing — several combinations are known
> to break.
>
> **Last verified:** 2026-07-13 against gogenfilter (full-feature) and
> go-workflow-auditlog (simple, no OG/CSP) — both built successfully with
> these versions on Node.js 24 via Nix.

## Verified Working (gogenfilter baseline — Astro 7)

gogenfilter runs Astro 7 successfully with OG images, CSP, and CI/CD.
This is the canonical version set:

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
    "vite": "7.3.2",
    "yaml": "2.8.3"
  }
}
```

**Build script:** `"build": "astro build && node scripts/fix-csp.mjs"`

## go-atomic-write baseline (simpler — no OG images, no CSP)

If you don't need OG images or CSP, this simpler set also works with
Astro 7:

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
    "brace-expansion": "5.0.6"
  }
}
```

## The Astro 6 vs 7 History (resolved)

A prior session (go-output) hit a Rollup error
(`rollupOptions.input should not be an html file when building for SSR`)
when using `astro-og-canvas@0.11.1` with Astro 7. That session concluded
Astro 6 was required.

**This is resolved.** gogenfilter runs `astro@^7.0.3` with
`astro-og-canvas@^0.12.0` successfully. The fix was upgrading og-canvas
from 0.11.x to 0.12.0, which added Astro 7 support.

**Lesson:** Use `astro-og-canvas@^0.12.0` (not 0.11.x) with Astro 7.
If you hit the Rollup error, check the og-canvas version first.

## Overrides: Copy gogenfilter's Exactly or Omit Entirely

gogenfilter pins `vite: 7.3.2` in overrides and it works. go-atomic-write
has no vite override and it also works. The failure mode is **partially
customizing** overrides — picking a different vite version or mixing
incompatible pins.

Two safe options:

1. **Copy gogenfilter's overrides verbatim** (recommended for full-feature sites)
2. **Use only `brace-expansion`** (for simpler sites without OG/CSP)

Do NOT invent your own override combinations.

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

| Task                 | Tool                               | Why                                                                        |
| -------------------- | ---------------------------------- | -------------------------------------------------------------------------- |
| Install dependencies | `npm install` or `bun install`     | Both work for install                                                      |
| Build                | `npm run build` or `bun run build` | Both work for build                                                        |
| Deploy to Firebase   | Real Node.js (not bun)             | `firebase deploy` uses `re2` native module — bun's node shim can't load it |

### Deploying with real Node.js under bun

```bash
PATH=$(nix build nixpkgs#nodejs --no-link --print-out-paths)/bin:$PATH \
  npx firebase-tools deploy --only hosting:{siteId} --project lars-software
```

Or use the Nix devShell (which provides real Node.js).

## firebase-tools is NOT a dependency

`firebase-tools` should NOT be in `package.json` dependencies or
devDependencies. It comes from:

1. The Nix devShell (`flake.nix`), or
2. `bunx firebase-tools` / `npx firebase-tools` for one-off commands

If you accidentally `bun add firebase-tools` while debugging, remove it
before committing:

```bash
npm remove firebase-tools   # or: bun remove firebase-tools
```

Reference websites do NOT have `firebase-tools` as a dependency.
