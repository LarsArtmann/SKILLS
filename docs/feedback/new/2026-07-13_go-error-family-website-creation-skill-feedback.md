# Feedback: go-error-family Public Presence Overhaul

**Date:** 2026-07-13
**Task:** Create README updates, documentation website (Astro+Starlight+Firebase), GitHub metadata, and DNS config for go-error-family
**Session Outcome:** Website builds successfully (13 pages), but not deployed. DNS config written but not applied. Several gaps discovered in post-session self-review.

---

## What I Did

### Phase 1: Research (3 sub-agent calls, ~50 files read)

Dispatched 3 parallel sub-agents to read:

- Agent 1: go-error-family project (README, AGENTS.md, SKILL.md, go.mod, CHANGELOG.md, all Go source files, API surface)
- Agent 2: Both reference websites (go-atomic-write/website/ and gogenfilter/website/) — read ALL 60+ files verbatim: package.json, astro.config.mjs, every component, every data file, every style sheet, every JS helper, every .mdx doc page
- Agent 3: domains/ Terraform project — read all .tf files, module structure, Firebase hosting patterns

Plus parallel `gh repo view` and `git remote -v` calls.

**This was the most expensive part.** Reading 60+ verbatim files across two reference websites took the vast majority of the session's tool budget.

### Phase 2: Website Creation (40+ files written)

Created the entire `website/` directory from scratch:

- Config: package.json, astro.config.mjs, tsconfig.json, .firebaserc, firebase.json, flake.nix, .node-version, .gitignore, .htmlvalidate.json
- Data: config.ts, features.ts, hero-code.ts, sections.ts, types.ts, content.config.ts
- Styles: global.css (violet theme), starlight.css (violet Starlight overrides)
- Components: 14 Astro components (Header, Footer, HeroSection, FeatureGrid, Section, SectionHeader, Sections, Card, Icon, Logo, CTASection, ComparisonSection, HowItWorksSection, UseCasesSection)
- Layout: LandingLayout.astro with SEO meta, JSON-LD, ClientRouter
- Pages: index.astro
- Public assets: favicon.svg, manifest.json, robots.txt, 4 JS files
- Docs: 11 .mdx files (installation, quick-start, classification, error-types, http-and-cli, diagnostics, benchmarks, api-reference, changelog, contributing, related-tools)

### Phase 3: Build Verification

`npm install` + `npm run build` — 13 pages, sitemap, pagefind search index, 0 errors.

### Phase 4: GitHub + DNS

Updated description, homepage URL, added 4 topics. Added CNAME to Terraform. Validated Terraform (fmt + validate).

### Phase 5: Status Report

Wrote comprehensive self-review identifying gaps and next steps.

---

## Where a SKILL.md Would Have Made Me Faster and Better

### 1. `website-creation` Skill — Eliminates 80% of the Work

**The core problem:** I reverse-engineered a deterministic pattern by reading 60+ files across 3 sub-agent calls. The Astro+Starlight+Tailwind+Firebase website structure is IDENTICAL across go-atomic-write, gogenfilter, and now go-error-family. The only variables are:

| Variable          | go-atomic-write                                                                  | gogenfilter                                                             | go-error-family                                                                                      |
| ----------------- | -------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Project name      | `go-atomic-write`                                                                | `gogenfilter`                                                           | `go-error-family`                                                                                    |
| Subdomain         | `atomicwrite`                                                                    | `gogenfilter`                                                           | `errorfamily`                                                                                        |
| Accent color      | `#10b981` (emerald)                                                              | `#22d3ee` (cyan)                                                        | `#7c3aed` (violet)                                                                                   |
| GitHub URL casing | `larsartmann` (lowercase)                                                        | `LarsArtmann` (capitalized)                                             | `LarsArtmann` (capitalized)                                                                          |
| Hero code         | Fingerprint + Write                                                              | Generator detection                                                     | Classify + IsRetryable                                                                               |
| Features          | 6 project-specific                                                               | 6 project-specific                                                      | 6 project-specific                                                                                   |
| Comparison matrix | Rows specific to project                                                         | Same                                                                    | Same                                                                                                 |
| Docs pages        | Installation, Quick Start, Error Handling, Platform Support, Benchmarks, API Ref | Installation, Quick Start, Filter Options, Pattern Matching, SQLC, etc. | Installation, Quick Start, Classification, Error Types, HTTP & CLI, Diagnostics, Benchmarks, API Ref |
| Logo SVG          | "A" monogram (emerald)                                                           | Filter funnel (cyan)                                                    | Generic bars (violet)                                                                                |

**What the SKILL.md should contain:**

#### a) A Single Scaffolding Command

```bash
nix run github:LarsArtmann/SKILLS#create-website -- --name go-error-family --subdomain errorfamily --color violet
```

This should generate the entire `website/` directory with all 40+ files, all correctly parameterized. I should NOT need to manually write 40 files and customize each one.

#### b) The Full Accent Color Palette Map

The single most tedious part was manually computing the violet palette. There are ~25 CSS custom properties across `global.css` and `starlight.css` that ALL need to change for a new accent color, in BOTH dark and light mode:

```css
/* global.css dark mode */
--color-accent: #7c3aed;
--color-accent-hover: #8b5cf6;
--color-accent-dim: rgba(124, 58, 237, 0.08);
--color-accent-light: #a78bfa;
--color-border-accent: rgba(124, 58, 237, 0.3);

/* global.css light mode */
--color-accent: #6d28d9;
--color-accent-hover: #7c3aed;
--color-accent-dim: rgba(109, 40, 217, 0.06);
--color-accent-light: #8b5cf6;
--color-border-accent: rgba(109, 40, 217, 0.25);

/* starlight.css dark mode */
--sl-color-accent-low: #4c1d95;
--sl-color-accent: #7c3aed;
--sl-color-accent-high: #a78bfa;

/* starlight.css light mode */
--sl-color-accent-high: #6d28d9;
--sl-color-accent: #7c3aed;
--sl-color-accent-low: #f5f3ff;
```

A skill should include a **pre-computed palette table** for common colors:

| Color   | Hex (dark) | Hex (light) | Dim rgba                | Border rgba            | SL-low    | SL-high   |
| ------- | ---------- | ----------- | ----------------------- | ---------------------- | --------- | --------- |
| Emerald | `#10b981`  | `#059669`   | `rgba(16,185,129,0.08)` | `rgba(16,185,129,0.3)` | `#064e3b` | `#34d399` |
| Cyan    | `#22d3ee`  | `...`       | `...`                   | `...`                  | `...`     | `...`     |
| Violet  | `#7c3aed`  | `#6d28d9`   | `rgba(124,58,237,0.08)` | `rgba(124,58,237,0.3)` | `#4c1d95` | `#a78bfa` |
| Amber   | `#f59e0b`  | `...`       | `...`                   | `...`                  | `...`     | `...`     |
| Rose    | `#f43f5e`  | `...`       | `...`                   | `...`                  | `...`     | `...`     |
| Blue    | `#3b82f6`  | `...`       | `...`                   | `...`                  | `...`     | `...`     |

Plus the theme-color meta tag, manifest.json theme_color, and favicon.svg fill color.

**Impact:** Would have saved 15 minutes of manual palette computation and eliminated the risk of a mismatched token.

#### c) The File Manifest with Copy-vs-Customize Annotations

Out of ~45 files in the website, most are boilerplate. A skill should explicitly list:

| File                              | Action                                                      | What to customize                                                           |
| --------------------------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------- |
| `package.json`                    | Customize                                                   | name, description, keywords, homepage, repository.url, bugs                 |
| `astro.config.mjs`                | Customize                                                   | site URL, starlight title, sidebar structure, social href, head description |
| `tsconfig.json`                   | **Copy verbatim**                                           |                                                                             |
| `.firebaserc`                     | Customize                                                   | target name                                                                 |
| `firebase.json`                   | Customize                                                   | target name                                                                 |
| `flake.nix`                       | **Copy verbatim**                                           |                                                                             |
| `.node-version`                   | **Copy verbatim**                                           |                                                                             |
| `.gitignore`                      | **Copy verbatim**                                           |                                                                             |
| `.htmlvalidate.json`              | **Copy verbatim**                                           |                                                                             |
| `src/data/config.ts`              | Customize                                                   | name, title, description, siteUrl, github, pkgGoDev                         |
| `src/data/features.ts`            | **Full rewrite**                                            | 6 project-specific features                                                 |
| `src/data/hero-code.ts`           | **Full rewrite**                                            | Project-specific Go code                                                    |
| `src/data/sections.ts`            | **Full rewrite**                                            | steps, comparisons, useCases                                                |
| `src/data/types.ts`               | **Copy verbatim**                                           |                                                                             |
| `src/content.config.ts`           | **Copy verbatim**                                           |                                                                             |
| `src/styles/global.css`           | Customize                                                   | All accent color tokens                                                     |
| `src/styles/starlight.css`        | Customize                                                   | All accent color tokens                                                     |
| `src/layouts/LandingLayout.astro` | Customize                                                   | theme-color meta, JSON-LD name                                              |
| `src/pages/index.astro`           | **Copy verbatim**                                           |                                                                             |
| All 14 components                 | **Copy verbatim** (except HeroSection.astro GitHub API URL) |
| `public/favicon.svg`              | **Full rewrite**                                            |                                                                             |
| `public/manifest.json`            | Customize                                                   | name, description, theme_color                                              |
| `public/robots.txt`               | Customize                                                   | sitemap URL                                                                 |
| All 4 JS files                    | **Copy verbatim**                                           |                                                                             |
| All .mdx docs                     | **Full rewrite**                                            |                                                                             |

I had to discover this classification myself by reading every file. A skill would have told me upfront: "12 files copy verbatim, 8 files customize specific fields, 25 files need project-specific content."

**Impact:** Would have eliminated the need to read 12 files verbatim via sub-agents. Would have made the work explicit instead of exploratory.

#### d) The Go-Live Checklist

After files are created and build passes, there's a specific sequence that must happen:

```
1. Generate flake.lock:        nix flake lock
2. Create Firebase site:       firebase hosting:sites:create {name} --project lars-software
3. Deploy:                     cd website && nix run .#deploy
4. Add custom domain:          Firebase console or REST API
5. Get ACME challenge:         From domain creation response
6. Add DNS records:            CNAME + TXT _acme-challenge in Terraform
7. Apply Terraform:            cd domains && terraform apply
8. Wait for SSL:               Poll domain status until CERT_OK
9. Verify:                     curl -I https://{subdomain}.lars.software
```

I missed steps 1-2 entirely. A skill would have this as a mandatory post-build checklist.

**Impact:** Would have prevented the "website builds but isn't reachable" gap.

#### e) The Common Pitfalls List

Things I missed that a skill would have caught:

1. **README must mention `GOEXPERIMENT=jsonv2`** — The root module uses `encoding/json/v2`. This is a hard requirement for consumers. The README had zero mentions. A skill for Go library websites should flag: "check if the library requires special env vars and document them in README."

2. **`flake.lock` must be generated** — For reproducible Nix builds. The reference sites all have it. I created `flake.nix` but never ran `nix flake lock`.

3. **`package-lock.json` must be committed** — For reproducible npm builds in CI. I generated it via `npm install` but didn't flag it for committing.

4. **CSP headers** — gogenfilter has Content-Security-Policy in astro.config.mjs with a `fix-csp.mjs` post-build script. go-atomic-write doesn't. A skill should include CSP as the default (more secure) and document the `fix-csp.mjs` pattern.

5. **OG images** — gogenfilter has `astro-og-canvas` for social media cards. A skill should include this as a standard integration.

6. **Logo design** — I made generic horizontal bars. A skill should include logo design guidance or at minimum a prompt: "Design an SVG that represents the project's domain concept."

7. **GitHub URL casing consistency** — go-atomic-write uses lowercase `larsartmann`, gogenfilter uses capitalized `LarsArtmann`. A skill should standardize on one.

8. **MDX character escaping** — `<`, `>`, `<=`, `>=` break Starlight MDX files. Must use `&lt;`, `&gt;`, or rephrase. (The go-filewatcher feedback already documented this.)

**Impact:** Would have prevented at least 5 gaps discovered in post-session review.

---

### 2. `firebase-hosting-multi-site` Skill

**The problem:** I created `.firebaserc` and `firebase.json` with the correct target name, but never created the actual Firebase hosting site. The config files reference a site that doesn't exist.

**What the SKILL.md should contain:**

1. **The site creation command** — `firebase hosting:sites:create {name} --project lars-software`
2. **The multi-site pattern** — All LarsArtmann websites live in the `lars-software` Firebase project as separate hosting sites. The `.firebaserc` targets map site IDs to names.
3. **The deploy command** — `nix run .#deploy` (which runs `npm run build && firebase deploy --only hosting`)
4. **The custom domain flow** — Console UI steps or REST API script (the go-filewatcher feedback already documented the REST API shape)
5. **The ACme challenge pattern** — Firebase generates a TXT record value for `_acme-challenge.{subdomain}` that must be added to DNS before SSL provisioning completes
6. **The verification step** — `curl -I https://{subdomain}.lars.software` should return 200 after SSL is provisioned

**Impact:** Would have ensured the site was created before deploy was attempted.

---

### 3. `domains-terraform` Skill

**The problem:** I correctly added the CNAME record to Terraform, but didn't know:

- Whether `terraform apply` could be run (credentials status)
- The full go-live sequence (CNAME must point to an existing Firebase site)
- Whether to use the `firebase-hosting` module or manual CNAME records

**What the SKILL.md should contain:**

1. **The two patterns for Firebase DNS** — Using the `firebase-hosting` module (for apex domains like `lars.software`) vs manual CNAME records (for subdomains like `errorfamily.lars.software`). I used manual CNAME which is correct for subdomains, but I had to discover this from the existing code.

2. **The prerequisite checklist** — `terraform.tfvars` must have real Namecheap API key, client IP must be whitelisted. Check these BEFORE writing Terraform code.

3. **The naming convention** — Subdomain names: `atomicwrite`, `gogenfilter`, `errorfamily` (shortened from `go-error-family`). Not always the full repo name.

4. **The apply command** — Using Nix: `nix run nixpkgs#opentofu -- plan` / `apply`. Or `terraform plan` / `apply` if in the devShell.

**Impact:** Would have clarified the module-vs-manual decision and surfaced credential requirements early.

---

### 4. `github-repo-metadata` Skill

**The problem:** The existing description said "Persistent" which is not one of the five families. I had to read the AGENTS.md and source code to discover the correct family names. And the topic vocabulary was curated manually.

**What the SKILL.md should contain:**

1. **The standard topic vocabulary** — `go`, `golang`, `error-handling`, `structured-errors`, `protocol`, etc. Plus project-specific topics.
2. **The description format** — `{one-liner} — {key features}. {tagline}.` Under 350 chars for GitHub's limit.
3. **The homepage convention** — `{name}.lars.software` for all project websites.
4. **The badge set** — Go Reference, Go Report Card, License: MIT. Standard order.
5. **The README link bar** — `**[Documentation](url)** · **[pkg.go.dev](url)** · **[Changelog](CHANGELOG.md)**` below the tagline.

**Impact:** Minor, but would have ensured consistency and saved 5 minutes.

---

## Time Analysis: Where the Session Time Went

| Activity                                    | Estimated Time | With Skill                     |
| ------------------------------------------- | -------------- | ------------------------------ |
| Reading 60 reference files via 3 sub-agents | 15 min         | 0 min (template)               |
| Writing 12 verbatim-copy files              | 5 min          | 0 min (generated)              |
| Writing 8 customize-specific-fields files   | 10 min         | 3 min (scaffold + fill)        |
| Manual accent color palette computation     | 10 min         | 0 min (pre-computed table)     |
| Writing 25 project-specific content files   | 25 min         | 20 min (still manual)          |
| npm install + build verification            | 5 min          | 5 min                          |
| README + GitHub + DNS updates               | 10 min         | 5 min                          |
| Self-review and status report               | 10 min         | 5 min (checklist catches gaps) |
| **Total**                                   | **~90 min**    | **~38 min**                    |

The skill would have cut the session time by more than half AND produced a better result (no missed GOEXPERIMENT, no missing flake.lock, proper go-live sequence).

---

## What I Did Well (No Skill Needed)

- Followed the reference pattern faithfully — no architecture improvisation
- Build verified successfully before reporting done
- Used the existing color palette structure correctly (just wrong that I had to compute it manually)
- All 11 docs pages are comprehensive and project-specific, not generic
- Terraform validated (fmt + validate) before reporting
- Parallelized research effectively (3 sub-agents + 2 bash calls simultaneously)
- GitHub settings verified with `gh repo view --json`
- Honest self-review identified real gaps

---

## What I Did Poorly

1. **Forgot GOEXPERIMENT in README** — The most critical gap. Consumers WILL hit build failures. A checklist item would have caught this.
2. **Didn't generate flake.lock** — Broke reproducibility. The reference sites all have it.
3. **Generic logo** — Horizontal bars have no connection to error classification. No design thinking applied.
4. **Didn't create the Firebase site** — Config files reference a nonexistent site. Build-pass != deploy-ready.
5. **No CI integration** — Website build isn't verified in CI. Future changes could break the build silently.
6. **Didn't flag package-lock.json** — Should be committed for reproducible CI builds.
7. **No CSP or OG images** — gogenfilter has both. I chose the go-atomic-write baseline (which lacks them) instead of the more complete gogenfilter baseline.

---

## Recommendation: Priority Skill Creation Order

1. **`website-creation`** (highest impact — eliminates 50+ minutes and 60 file reads per project)
2. **`firebase-hosting-multi-site`** (ensures go-live sequence is complete)
3. **`domains-terraform`** (surfaces credential requirements early)
4. **`github-repo-metadata`** (lowest impact, but ensures consistency)

The `website-creation` skill alone would transform this from a 90-minute multi-agent exploration into a 15-minute scaffold-and-customize operation.
