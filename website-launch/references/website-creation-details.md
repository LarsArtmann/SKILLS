# Website Creation Details

> Detailed implementation guidance for Phase 3 (website creation). Load this
> reference when building the website files — favicon, logo, MDX escaping,
> section components, creation order, and Starlight config tuning.

## Favicon and Logo Design

Both use the same design constraints:

- **Dimensions:** 28x28 viewBox
- **Shape:** Rounded rectangle (`rx="6"`) filled with the accent color
- **Foreground:** Simple monogram or icon in `bg-primary` color (`#0a0908`)
- **favicon.svg:** Use the literal hex value of the accent color (not CSS
  variables, since SVGs viewed as tabs don't resolve them). Use the **dark-mode
  `--color-accent` value** from the color palette.
- **Logo.astro:** Use CSS variables (`fill-[var(--color-accent)]`) so it adapts
  to light/dark theme.

## MDX Gotcha

Characters `<`, `>`, `<=`, `>=` break Starlight `.mdx` file parsing. In `.mdx`
files, escape them as `&lt;`, `&gt;`, or rephrase the sentence to avoid them.
This does not affect `.md` files.

## Section Components Are Open-Ended

The file manifest lists standard section components (CTASection,
ComparisonSection, HowItWorksSection, UseCasesSection, FeatureGrid). These
are NOT a fixed set — create whatever sections fit the project's features.

Examples of project-specific sections across repos:

- `OutputFormatsSection.astro` (art-dupl — 7 output formats grid)
- `GeneratorGrid.astro` (gogenfilter — supported generators)
- `PhaseSection.astro` (gogenfilter — lifecycle phases)

Follow the same data-driven pattern for any new section: import data from
`../data/sections.ts`, use `SectionHeader` for the title, map over the data
array, use Tailwind CSS tokens.

## Creation Order

Create files in this order to avoid back-tracking:

1. **Config layer** — `package.json`, `astro.config.mjs`, `tsconfig.json`,
   `.node-version`, `.gitignore`, `.htmlvalidate.json`, `content.config.ts`,
   `flake.nix`
2. **Firebase layer** — `firebase.json`, `.firebaserc`
3. **Data layer** — `src/data/config.ts`, `src/data/types.ts`,
   `src/data/features.ts`, `src/data/sections.ts`, `src/data/hero-code.ts`
4. **Style layer** — `src/styles/global.css`, `src/styles/starlight.css`
   (paste from color palette reference)
5. **Public assets** — `public/js/*.js` (4 files, verbatim),
   `public/favicon.svg`, `public/manifest.json`, `public/robots.txt`
6. **Shared components** — `Section.astro`, `SectionHeader.astro`,
   `Card.astro`, `Icon.astro`, `Logo.astro`, `Header.astro`, `Footer.astro`,
   `Sections.astro`
7. **Section components** — `HeroSection.astro` (most complex), `FeatureGrid.astro`,
   `HowItWorksSection.astro`, `ComparisonSection.astro`, `UseCasesSection.astro`,
   `CTASection.astro`
8. **Layout and page** — `LandingLayout.astro`, `index.astro`
9. **Docs content** — all `.mdx` files in `src/content/docs/`

## Section Component Patterns

All section components follow the same data-driven pattern:

1. Import data from `../data/*.ts`
2. Import `SectionHeader` for the section title
3. Map over the data array to render cards/items
4. Use `Card.astro` or raw `<div>` with Tailwind classes
5. Consume CSS tokens via Tailwind: `text-accent`, `bg-bg-card`,
   `border-border`, `text-text-primary`, etc.

**HeroSection** is the most complex component. It contains:

- GitHub stars fetch at build time (server-side `await fetch()`)
- A highlighted code preview (manual `<span>` wrapping with color classes)
- A copy-to-clipboard button
- Metrics row
- Dual CTA buttons

When writing HeroSection, always:

- Set the GitHub API URL to match the actual repo
- Set the import path to match `go.mod` (include `/v2` if applicable)
- Verify the hero code compiles (Phase 1 verification)
- Set the `theme-color` meta to the accent hex

## Starlight config knobs (the "nice docs" enablers)

These `astro.config.mjs` Starlight options are one-line additions that
are the difference between a site that feels polished and one that feels
scaffolded. They are easy to forget and they are free.

```js
starlight({
	title: "{Project}",
	// Show git-based "last updated" on every page — zero authoring cost,
	// always accurate, signals the page is alive.
	lastUpdated: true,
	// "Edit this page" link on every doc — the #1 contributor-acquisition
	// lever. Adjust master -> main if the project's default branch differs.
	editLink: {
		baseUrl: "https://github.com/LarsArtmann/{repo}/edit/master/website",
	},
	// Pagination and breadcrumbs are on by default — do not disable them.
});
```

Pair `editLink` with a curated feedback link on each page (issue tracker
with a pre-filled title). See the
[content patterns reference](./content-patterns.md) §5. For
the visual/aesthetic calibration that makes a Starlight site read as
"Nextra-class nice", see the
[design inspiration reference](./design-inspiration.md) —
the gap to best-in-class docs is theme tuning and content patterns, not
a framework switch.
