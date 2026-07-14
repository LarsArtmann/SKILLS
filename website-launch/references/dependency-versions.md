# Dependency Version Matrix — Verified Working

> These versions are verified to work together as of 2026-07-13. Do NOT
> bump versions without testing — several combinations are known to break.

## Verified Working (gogenfilter baseline)

```json
{
  "dependencies": {
    "@astrojs/sitemap": "^3.7.3",
    "@astrojs/starlight": "^0.41.1",
    "astro": "^7.0.3",
    "astro-og-canvas": "^0.11.1",
    "tailwindcss": "^4.3.1",
    "@tailwindcss/vite": "^4.3.1"
  }
}
```

## Known Incompatibilities

### Astro 7.x + astro-og-canvas (Vite/Rollup conflict)

**Status:** Incompatible with certain Vite overrides.

If `astro-og-canvas` fails with a Rollup error about `rollupOptions.input`,
check for a `vite` pin in `overrides`. **Remove it** — Astro 7 manages its
own Vite version internally.

```json
// BAD — this breaks Astro 7 builds
{
  "overrides": {
    "vite": "7.3.2"
  }
}

// GOOD — let Astro manage Vite
{
  // no overrides section needed
}
```

### npm v11+ install scripts blocked

npm v11+ blocks install scripts by default (`esbuild`, `sharp` need them).
After `npm install`, run:

```bash
npm approve-scripts esbuild sharp
```

Without this, the Astro build fails with missing native binaries.

If using bun: `bun install` handles this automatically, but `firebase
deploy` will fail under bun's node shim (see common-pitfalls.md).

### `--legacy-peer-deps` trap

If peer dependency conflicts force `--legacy-peer-deps`, create a `.npmrc`
file in the same commit:

```ini
legacy-peer-deps=true
```

Without this, anyone cloning the repo and running plain `npm install` will
get `ERESOLVE` errors. The lockfile works only because it was generated
with the flag.

**Better approach:** Pin compatible versions (see matrix above) so
`--legacy-peer-deps` is unnecessary.

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
