# File Manifest — Website Template Classification

> The Astro + Starlight + Tailwind v4 website structure is identical across
> all LarsArtmann project websites. This manifest eliminates the need to
> read 60+ reference files via sub-agents.

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
| `src/components/HeroSection.astro` | GitHub API URL, repo name for stars badge                                                  |
| `src/components/Logo.astro`        | Project-specific SVG monogram                                                              |
| `public/manifest.json`             | `name`, `description`, `theme_color`                                                       |
| `public/robots.txt`                | Sitemap URL                                                                                |
| `scripts/fix-csp.mjs`              | CSP SHA-256 hash injection (if using CSP)                                                  |

## Write Fresh (project-specific content)

These files require original content based on the specific library.

| File                                     | What to write                                                                            |
| ---------------------------------------- | ---------------------------------------------------------------------------------------- |
| `src/data/features.ts`                   | 6 feature cards with icon, title, description                                            |
| `src/data/hero-code.ts`                  | Go code example for hero section (verify against source!)                                |
| `src/data/sections.ts`                   | How-it-works steps, comparison matrix, use cases                                         |
| `public/favicon.svg`                     | Project-specific SVG favicon                                                             |
| `src/components/CTASection.astro`        | Call-to-action section                                                                   |
| `src/components/ComparisonSection.astro` | Comparison table                                                                         |
| `src/components/HowItWorksSection.astro` | Steps section                                                                            |
| `src/components/UseCasesSection.astro`   | Use cases section                                                                        |
| `src/components/FeatureGrid.astro`       | Feature grid (may need icon set tweaks)                                                  |
| `src/components/Icon.astro`              | Icon path map (add project-specific icons)                                               |
| All `.mdx` docs pages                    | installation, quick-start, guides, api-reference, changelog, contributing, related-tools |

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
