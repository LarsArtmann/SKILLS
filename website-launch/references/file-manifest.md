# File Manifest — Website Template Classification

## Copy Verbatim (zero changes needed)

These files are identical across all project websites. Copy them as-is.

| File                                 | Notes                                         |
| ------------------------------------ | --------------------------------------------- |
| `tsconfig.json`                      | TypeScript config                             |
| `.node-version`                      | Node version pin                              |
| `.gitignore`                         | Ignores node_modules, dist, .firebase         |
| `.htmlvalidate.json`                 | HTML validation rules                         |
| `src/content.config.ts`              | Starlight content collection config           |
| `public/js/theme-init.js`            | Theme initialization (prevents FOUC)          |
| `public/js/animations.js`            | Scroll animations                             |
| `public/js/header.js`                | Header scroll behavior                        |
| `public/js/copy-code.js`             | Copy-to-clipboard for code blocks             |
| `src/components/Section.astro`       | Layout section wrapper                        |
| `src/components/SectionHeader.astro` | Section heading                               |
| `src/components/Card.astro`          | Feature card                                  |
| `src/components/Sections.astro`      | Section renderer                              |
| `src/layouts/LandingLayout.astro`    | Landing page layout (custom theme-color meta) |
| `src/pages/index.astro`              | Landing page assembly                         |
| `flake.nix`                          | Nix flake for dev shell + deploy              |

## Customize Specific Fields

These files need targeted edits — change project name, URLs, accent color,
sidebar structure.

| File                               | What to change                                                                                                                                           |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `package.json`                     | `name`, `description`, `keywords`, `homepage`, `repository.url`, `bugs`                                                                                  |
| `astro.config.mjs`                 | `site` URL, Starlight `title`, sidebar structure, social `href`, head `description`, fonts                                                               |
| `.firebaserc`                      | `target` name (or `default` project for standalone)                                                                                                      |
| `firebase.json`                    | `target` name (or `public` dir for standalone)                                                                                                           |
| `src/data/config.ts`               | `name`, `title`, `description`, `siteUrl`, `github`. Include `pkgGoDev` ONLY for libraries                                                               |
| `src/data/types.ts`                | Icon name union type (if adding/removing icons)                                                                                                          |
| `src/components/Header.astro`      | Consumes `config.ts` but styling/markup differs per project — do NOT copy verbatim                                                                       |
| `src/components/Footer.astro`      | Consumes `config.ts` but links/styling differ per project. **Libraries:** include pkg.go.dev link. **Applications:** omit pkg.go.dev, add Changelog link |
| `src/styles/global.css`            | All accent color tokens (see color-palette.md) **AND** bg/text/border tokens (see below)                                                                 |
| `src/styles/starlight.css`         | All `sl-color-accent-*` tokens (see color-palette.md)                                                                                                    |
| `.npmrc`                           | Create ONLY if `--legacy-peer-deps` was needed: `legacy-peer-deps=true`                                                                                  |
| `src/components/HeroSection.astro` | GitHub API URL, repo name for stars badge                                                                                                                |
| `src/components/Logo.astro`        | Project-specific SVG monogram                                                                                                                            |
| `public/manifest.json`             | `name`, `description`, `theme_color`                                                                                                                     |
| `public/robots.txt`                | Sitemap URL                                                                                                                                              |
| `scripts/fix-csp.mjs`              | CSP SHA-256 hash injection (if using CSP)                                                                                                                |

## Write Fresh (project-specific content)

These files require original content based on the specific project.

| File                                     | What to write                                                                                                |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `src/data/features.ts`                   | 6 feature cards with icon, title, description                                                                |
| `src/data/hero-code.ts`                  | **Library:** Go import + function call (verify against source!) **Application:** Shell command or Docker run |
| `src/data/sections.ts`                   | How-it-works steps, comparison matrix, use cases                                                             |
| `public/favicon.svg`                     | Project-specific SVG favicon                                                                                 |
| `src/components/CTASection.astro`        | Call-to-action section (follow gogenfilter pattern, customize markup)                                        |
| `src/components/ComparisonSection.astro` | Comparison section (layout varies: gogenfilter uses card grid, go-atomic-write uses table)                   |
| `src/components/HowItWorksSection.astro` | Steps section (optional — gogenfilter uses PhaseSection instead; choose what fits)                           |
| `src/components/UseCasesSection.astro`   | Use cases section (follow gogenfilter pattern, customize markup)                                             |
| `src/components/FeatureGrid.astro`       | Feature grid (consumes `features.ts`, but styling differs per project)                                       |
| `src/components/Icon.astro`              | Icon path map (add project-specific icons, source from Lucide/Heroicons)                                     |
| `src/pages/og/[...slug].ts`              | OG image generation (if using astro-og-canvas — customize border color to match accent)                      |
| All `.mdx` docs pages                    | installation, quick-start, guides, api-reference, changelog, contributing, related-tools                     |

**Section components are open-ended.** The list above shows known examples
across repos, but you can create any section that fits the project (e.g.
`OutputFormatsSection`, `GeneratorGrid`, `PhaseSection`). Follow the
data-driven pattern: import data from `../data/sections.ts`, use
`SectionHeader`, map over data, use Tailwind CSS tokens.

## Standard Docs Page Set

Every project website should have these docs pages at minimum:

| Page                | Library content                   | Application content                             |
| ------------------- | --------------------------------- | ----------------------------------------------- |
| `installation.mdx`  | Go install, `go get`, import path | Docker, binary download, Nix, build from source |
| `quick-start.mdx`   | Minimal Go import + function call | Minimal server run command or Docker run        |
| `api-reference.mdx` | Go function/type signatures       | HTTP endpoints, CLI flags table                 |
| `changelog.mdx`     | Link to CHANGELOG.md or inline    | Link to CHANGELOG.md or inline                  |
| `contributing.mdx`  | How to contribute, dev setup      | How to contribute, dev setup                    |
| `related-tools.mdx` | Sibling projects, alternatives    | Sibling projects, alternatives                  |

**Application-specific docs pages** may include: configuration, Docker,
cloud storage, markdown features, API endpoints — depending on the project.

Project-specific guides vary (e.g. `classification.mdx`, `error-types.mdx`
for go-error-family; `detection-methods.mdx`, `pattern-matching.mdx` for
art-dupl; `cloud-storage.mdx`, `docker.mdx` for dynamic-markdown-site).

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

1. **build-website** — `pnpm install --frozen-lockfile`, `astro check`, `astro build`, HTML
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

**og:image sizing rule (1200×630):** link unfurls (Slack, X, LinkedIn,
Discord) crop or letterbox anything that is not 1200×630. The generated
per-page OG images should render at that size, and once the demo video
exists, the **landing page's `og:image` should be the video poster** (the
strongest selling frame), not the generic generated image — shares of the
landing page then show the product in motion's money shot. Configure this in
the landing layout's `<meta property="og:image">` (override the per-page
default for `/` only); see `demo-video.md` "Landing-page integration".

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

## Non-Accent CSS Tokens (bg/text/border)

The color palette reference covers accent tokens. But `global.css` also
defines the base palette: `--color-bg-primary`, `--color-bg-card`,
`--color-bg-card-solid`, `--color-bg-code`, `--color-border`,
`--color-border-hover`, `--color-text-primary`, `--color-text-secondary`,
`--color-text-muted`, and `--color-code-inline-bg`.

These follow a **warm dark base** pattern. Copy them from the closest
reference project and adjust the base darkness if needed:

| Project            | bg-primary (dark) | Character                |
| ------------------ | ----------------- | ------------------------ |
| go-atomic-write    | `#0a0908`         | Very dark charcoal       |
| gogenfilter        | `#0c0a09`         | Dark charcoal            |
| samber-do-auditlog | `#14110d`         | Warm dark brown-charcoal |

The light-mode counterparts are warm off-whites (`#faf8f5` to `#fafaf9`).

**Rule of thumb:** Start with `#0a0908` (dark) / `#faf8f5` (light) and
adjust only if the project has a specific aesthetic (samber-do-auditlog
uses a warmer `#14110d` to match its "Container Telemetry" amber theme).
