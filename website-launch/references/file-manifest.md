# File Manifest — Website Template Classification

## Copy Verbatim (zero changes needed)

These files are identical across all project websites. Copy them as-is.

| File                                 | Notes                                           |
| ------------------------------------ | ----------------------------------------------- |
| `tsconfig.json`                      | TypeScript config                               |
| `.node-version`                      | Node version pin                                |
| `.gitignore`                         | Ignores node_modules, dist, .firebase           |
| `.htmlvalidate.json`                 | HTML validation rules                           |
| `src/content.config.ts`              | Starlight content collection config             |
| `public/js/theme-init.js`            | Theme initialization (prevents FOUC)            |
| `public/js/animations.js`            | Scroll animations                               |
| `public/js/header.js`                | Header scroll behavior                          |
| `public/js/copy-code.js`             | Copy-to-clipboard for code blocks               |
| `src/components/Section.astro`       | Layout section wrapper                          |
| `src/components/SectionHeader.astro` | Section heading                                 |
| `src/components/Card.astro`          | Feature card                                    |
| `src/components/Header.astro`        | Site header (may need GitHub URL tweak)         |
| `src/components/Footer.astro`        | Site footer (may need link updates)             |
| `src/components/Sections.astro`      | Section renderer                                |
| `src/layouts/LandingLayout.astro`    | Landing page layout (may need theme-color meta) |
| `src/pages/index.astro`              | Landing page assembly                           |
| `flake.nix`                          | Nix flake for dev shell + deploy                |

## Customize Specific Fields

These files need targeted edits — change project name, URLs, accent color,
sidebar structure.

| File                               | What to change                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------------ |
| `package.json`                     | `name`, `description`, `keywords`, `homepage`, `repository.url`, `bugs`                    |
| `astro.config.mjs`                 | `site` URL, Starlight `title`, sidebar structure, social `href`, head `description`, fonts |
| `.firebaserc`                      | `target` name (or `default` project for standalone)                                        |
| `firebase.json`                    | `target` name (or `public` dir for standalone)                                             |
| `src/data/config.ts`               | `name`, `title`, `description`, `siteUrl`, `github`, `pkgGoDev`                            |
| `src/data/types.ts`                | Icon name union type (if adding/removing icons)                                            |
| `src/styles/global.css`            | All accent color tokens (see color-palette.md)                                             |
| `src/styles/starlight.css`         | All `sl-color-accent-*` tokens (see color-palette.md)                                      |
| `.npmrc`                           | Create ONLY if `--legacy-peer-deps` was needed: `legacy-peer-deps=true`                    |
| `src/components/Header.astro`      | GitHub URL, nav links (consumes `config.ts` but styling differs per project)               |
| `src/components/Footer.astro`      | Links, project name (consumes `config.ts` but styling differs per project)                 |
| `src/components/HeroSection.astro` | GitHub API URL, repo name for stars badge                                                  |
| `src/components/Logo.astro`        | Project-specific SVG monogram                                                              |
| `public/manifest.json`             | `name`, `description`, `theme_color`                                                       |
| `public/robots.txt`                | Sitemap URL                                                                                |
| `scripts/fix-csp.mjs`              | CSP SHA-256 hash injection (if using CSP)                                                  |

## Write Fresh (project-specific content)

These files require original content based on the specific library.

| File                                     | What to write                                                                              |
| ---------------------------------------- | ------------------------------------------------------------------------------------------ |
| `src/data/features.ts`                   | 6 feature cards with icon, title, description                                              |
| `src/data/hero-code.ts`                  | Go code example for hero section (verify against source!)                                  |
| `src/data/sections.ts`                   | How-it-works steps, comparison matrix, use cases                                           |
| `public/favicon.svg`                     | Project-specific SVG favicon                                                               |
| `src/components/CTASection.astro`        | Call-to-action section (follow gogenfilter pattern, customize markup)                      |
| `src/components/ComparisonSection.astro` | Comparison section (layout varies: gogenfilter uses card grid, go-atomic-write uses table) |
| `src/components/HowItWorksSection.astro` | Steps section (optional — gogenfilter uses PhaseSection instead; choose what fits)         |
| `src/components/UseCasesSection.astro`   | Use cases section (follow gogenfilter pattern, customize markup)                           |
| `src/components/FeatureGrid.astro`       | Feature grid (consumes `features.ts`, but styling differs per project)                     |
| `src/components/Icon.astro`              | Icon path map (add project-specific icons, source from Lucide/Heroicons)                   |
| `src/pages/og/[...slug].ts`              | OG image generation (if using astro-og-canvas — customize border color to match accent)    |
| All `.mdx` docs pages                    | installation, quick-start, guides, api-reference, changelog, contributing, related-tools   |

## Standard Docs Page Set

Every project website should have these docs pages at minimum:

| Page                | Content                                           |
| ------------------- | ------------------------------------------------- |
| `installation.mdx`  | Go install, go get, import path                   |
| `quick-start.mdx`   | Minimal working example (verified against source) |
| `api-reference.mdx` | Function/type reference                           |
| `changelog.mdx`     | Link to CHANGELOG.md or inline                    |
| `contributing.mdx`  | How to contribute, dev setup                      |
| `related-tools.mdx` | Sibling projects, alternatives                    |

Project-specific guides vary (e.g. `classification.mdx`, `error-types.mdx`
for go-error-family; `detection-methods.mdx`, `pattern-matching.mdx` for
art-dupl).

## Icon Path Catalog

The `Icon.astro` component uses a hardcoded map of SVG path data. When
adding project-specific icons, verify the SVG path data renders correctly.
Known-good icons across projects:

- `check`, `x`, `arrow-right`, `github`, `copy`, `sun`, `moon`
- `bolt`, `shield`, `code`, `terminal`, `package`, `book`
- `layers`, `git-branch`, `zap`, `globe`, `lock`, `eye`

For new icons, source from [Lucide](https://lucide.dev) or
[Heroicons](https://heroicons.com) — both use 24x24 viewBox with stroke
paths compatible with the Icon component.

Copy `.github/workflows/website.yml` from gogenfilter. It uses a two-job
pattern:

1. **build-website** — `npm ci`, `astro check`, `astro build`, HTML
   validation, upload artifact
2. **deploy-website** — download artifact, deploy to Firebase via
   `GOOGLE_APPLICATION_CREDENTIALS` secret

Customize: Firebase target name, repo trigger paths.

## CSP Patching (fix-csp.mjs)

gogenfilter's build script runs `astro build && node scripts/fix-csp.mjs`.
The `fix-csp.mjs` script post-processes the built HTML to inject SHA-256
hashes for inline scripts into the CSP header. This is needed because
Astro's CSP support doesn't cover all inline scripts automatically.

If you include CSP (recommended), copy `fix-csp.mjs` from gogenfilter and
ensure the build script includes the post-build step:

```json
"build": "astro build && node scripts/fix-csp.mjs"
```

## OG Image Generation

gogenfilter uses `astro-og-canvas` to generate social media preview images.
The endpoint lives at `src/pages/og/[...slug].ts` and generates one image
per doc page plus a home page.

To customize for a new project:

1. Copy `src/pages/og/[...slug].ts` from gogenfilter
2. Update the border color to match the project accent
3. Update the `bgGradient` if desired
4. Ensure `astro-og-canvas` is in dependencies (see dependency-versions.md)

## Multi-Color Design Systems (Secondary Colors)

Some projects (e.g. go-output) use secondary accent colors alongside the
primary accent. For example, go-output uses cyan as primary with amber and
violet as secondarys for the Build/Freeze/Render phase cards.

To add secondary colors:

1. Add the secondary color as a CSS custom property in `global.css`:
   ```css
   --color-amber: #fbbf24;
   --color-violet: #a78bfa;
   ```
2. Use opacity-based utility classes in components (e.g. `bg-amber/10`,
   `text-violet`) — Tailwind v4 generates these from the CSS variables.
3. Do NOT add secondary colors to `starlight.css` — Starlight only uses one
   accent color for its chrome. Secondary colors are landing-page-only.
4. Do NOT add secondary colors to the color-palette.md reference — it only
   covers the primary accent system.
