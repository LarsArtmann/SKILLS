---
name: website-launch
description: >-
  Launches a public documentation website for a Go project (library OR
  application/server) using the LarsArtmann Astro + Starlight + Tailwind v4 +
  Firebase Hosting
  pattern. Use this skill when the user asks to create a project website, build
  a documentation site, deploy to Firebase, configure DNS, set up GitHub
  metadata for a project, rewrite a README for public presence, "make a
  website", "publish docs", "set up Firebase hosting", configure custom
  domains, or any task involving the sibling-project website pattern
  (go-atomic-write, gogenfilter, dynamic-markdown-site, go-output,
  samber-do-auditlog, go-workflow-auditlog, etc.). Also triggers on "website launch", "public
  presence overhaul", "deploy website", or "lars.software domain".
metadata:
  tags: website, firebase, astro, starlight, dns, deployment, documentation
allowed-tools: bash view edit write grep fetch
---

# Website Launch

Launches a public documentation website for a Go project (library or
application/server) using the deterministic Astro + Starlight + Tailwind v4 +
Firebase Hosting pattern shared across all LarsArtmann projects.

> **Path conventions:** This skill assumes the LarsArtmann project layout:
> `~/projects/{repo}` for project repos and `~/projects/domains` for the DNS
> Terraform repo. If your layout differs, substitute your own paths for
> `{repo-path}` and `{domains-path}` throughout. The `{repo}` placeholder in
> commands means the target repo name, not a shell variable — replace it before
> running.

This skill encodes lessons from 6+ prior sessions that each wasted 45-90
minutes rediscovering the same pattern, making the same mistakes, and writing
the same feedback. Following this skill turns a 90-minute multi-agent
exploration into a 25-minute scaffold-and-customize task.

## Environment: Nix + Crush Constraints

All commands below assume a **Nix-based environment** and **Crush CLI tool
constraints**. These apply throughout:

- **`curl` is BANNED** in Crush. Use the `fetch` tool for HTTP requests, or
  Node.js `https.request` for scripted API calls. Every `curl` in older
  references has been replaced.
- **`npm` / `node` are not in PATH by default.** Use:
  ```bash
  nix shell nixpkgs#nodejs -c npm install
  nix shell nixpkgs#nodejs -c npm run build
  ```
- **`firebase` CLI is not in PATH by default.** Use:
  ```bash
  nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c firebase --version
  ```
- **`terraform` is unfree (BSL license).** `nix shell nixpkgs#terraform` fails.
  Use:
  ```bash
  NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform plan
  ```
  Or use `opentofu` (the open-source fork):
  ```bash
  nix run nixpkgs#opentofu -- plan
  ```
- **`gcloud` is available via:**
  ```bash
  nix shell nixpkgs#google-cloud-sdk -c gcloud auth print-access-token
  ```

---

## Phase 0: Pre-flight Checks (BEFORE writing any files)

Run these checks first. If any fails, surface it to the user immediately before
investing time in website creation.

**First decision (§0.6):** hosting target. The default is Firebase Hosting
(custom domains, headers, the DNS pipeline in Phases 5–7). If the project
needs none of that, GitHub Pages is a zero-infra alternative — decide early,
it changes which phases apply.

### 0.0 Existing Website Check

Before starting any work, check if a website already exists:

```bash
ls ~/projects/{repo}/website/package.json 2>/dev/null \
  && echo "INFO: website/ directory already exists — check if this is an update or a rebuild"
```

If a website exists, **switch to maintenance mode**: read the existing files,
identify what needs updating, and skip Phase 3 (creation). Do NOT overwrite
existing customization without confirming with the user.

**In maintenance mode, always audit for the "nice docs" patterns** that
predate this skill version — they retrofit onto any existing site without a
rebuild:

- README: add "Who is this for?" and "When NOT to use this" if missing.
- Docs pages: add a curated "Where to go next" to each page; repeat the
  comparison table inside the relevant docs page.
- `astro.config.mjs`: enable `lastUpdated: true` and `editLink` (see §3.10).
- Swap bold-text warnings for `:::caution` / `:::tip` callouts.

The full retrofit checklist is in the
[content patterns reference](./references/content-patterns.md)
("Retrofitting existing sites"). Running this audit on every existing site
is how all implementations inherit these improvements.

### 0.0.1 Old Static Site Migration

If the project has an OLD static website (hand-written HTML/CSS/JS, not
Astro), it must be removed cleanly before creating the new `website/`
directory:

```bash
# Check for old static site
ls ~/projects/{repo}/site/index.html 2>/dev/null \
  && echo "INFO: old static site found in site/ — will need removal"

# Check for root-level firebase configs (should live in website/ only)
ls ~/projects/{repo}/firebase.json 2>/dev/null \
  && echo "INFO: root firebase.json found — must be moved to website/"
ls ~/projects/{repo}/.firebaserc 2>/dev/null \
  && echo "INFO: root .firebaserc found — must be moved to website/"
```

Migration steps (when ready):

1. `trash` (not `rm`) the old `site/` directory
2. `trash` root-level `firebase.json` and `.firebaserc` (they now live in `website/`)
3. Remove stale `.gitignore` entries referencing the old site (e.g. `!site/*.html`)
4. Check the old deploy workflow — it likely points to `site/` as the public
   dir and must be replaced entirely

### 0.1 Firebase Project Decision: Shared vs Standalone

Most LarsArtmann websites deploy to the shared `lars-software` Firebase project
using hosting targets. Some projects (e.g. `art-dupl`) have their own
standalone Firebase project. **Decide before writing any config files.**

| Criterion                | Shared (`lars-software`)                          | Standalone                                  |
| ------------------------ | ------------------------------------------------- | ------------------------------------------- |
| Default for new projects | Yes                                               | Only if project needs its own infra         |
| `.firebaserc`            | `"default": "lars-software"` + targets            | `"default": "{projectId}"`                  |
| `firebase.json`          | `"target": "{name}"`                              | `"public": "dist"` (no target)              |
| Deploy command           | `--only hosting:{target} --project lars-software` | `--only hosting --project {projectId}`      |
| GitHub secret            | `FIREBASE_SERVICE_ACCOUNT` (lars-software key)    | `FIREBASE_SERVICE_ACCOUNT` (standalone key) |
| DNS CNAME target         | `{siteId}.web.app.`                               | `{projectId}.web.app.`                      |

Check which pattern the project already uses:

```bash
# Check existing firebase config
cat ~/projects/{repo}/.firebaserc 2>/dev/null | grep -o '"default".*' \
  && echo "INFO: existing Firebase project found"
cat ~/projects/{repo}/firebase.json 2>/dev/null | grep -o '"target".*' \
  && echo "INFO: uses hosting targets (shared project pattern)"

# Or check for a website/-level config
cat ~/projects/{repo}/website/.firebaserc 2>/dev/null | grep -o '"default".*'
```

Throughout this skill, `{firebaseProject}` refers to whichever project you
chose. Replace `lars-software` in all commands with `{firebaseProject}` if
using a standalone project.

### 0.2 Credential and Infrastructure Check

```bash
# Namecheap DNS — can Terraform actually be applied?
cd ~/projects/domains 2>/dev/null || echo "WARN: domains repo not found"

# Check if API key is a placeholder
grep -q "REPLACE_WITH\|your_api_key\|xxx" terraform.tfvars 2>/dev/null \
  && echo "BLOCKED: Namecheap API key is a placeholder — DNS cannot be applied from this session" \
  || echo "OK: API key looks real"

# Firebase project exists?
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase projects:list 2>/dev/null | grep -q {firebaseProject} \
  && echo "OK: {firebaseProject} project exists" \
  || echo "WARN: {firebaseProject} project not found"

# Check for existing hosting site collisions
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase hosting:sites:list --project {firebaseProject} 2>/dev/null
```

### 0.3 Domain Naming

Decide the subdomain and site ID **before** creating anything. These are
immutable after creation.

- **Subdomain convention:** Use the full repo slug when there is any risk of
  collision with sibling projects (e.g. `go-workflow-auditlog`, not `auditlog`
  — because `samber-do-auditlog` also exists).
- **Short subdomains** (e.g. `atomicwrite`, `gogenfilter`) are acceptable only
  when no collision risk exists.
- **Check for collisions:** Search the user's repos for similar names.

```bash
# Check existing DNS records for potential subdomain collisions
grep -r "{candidate-subdomain}" ~/projects/domains/lars.software.tf 2>/dev/null \
  && echo "WARN: DNS record already exists for this subdomain"

# Check user's GitHub repos for name collisions
gh repo list LarsArtmann --limit 100 --json name 2>/dev/null | grep -i "{keyword}"
```

### 0.4 Confirm Domain with User (BEFORE any commit)

**Do not commit anything until the user confirms the subdomain name.** A domain
rename after commit creates stale git history, stale status reports, and
requires touching 8+ files.

Present the proposed subdomain to the user and wait for confirmation:

> "I'll use `{subdomain}.lars.software` as the documentation URL, and `{siteId}`
> as the Firebase hosting site ID. The site ID is immutable. Confirm before I
> proceed?"

### 0.5 Name Collision Check

```bash
# Check existing DNS records for the subdomain
grep -r "{subdomain}" ~/projects/domains/lars.software.tf 2>/dev/null \
  && echo "WARN: DNS record already exists for this subdomain"
```

If pre-flight checks reveal blockers (placeholder credentials, IP not
whitelisted), tell the user immediately:

> "DNS records can be staged in Terraform but cannot be applied from this
> session — the Namecheap API key is a placeholder / the current IP is not
> whitelisted. I will prepare everything else and flag this as a manual step."

### 0.6 Hosting target: Firebase Hosting (default) vs GitHub Pages (alternative)

Most LarsArtmann sites use Firebase Hosting — it gives custom domains,
security headers/CSP, and the DNS/Terraform pipeline in Phases 5–7. For a
project that needs none of that, **GitHub Pages** is a zero-infra
alternative (this is how the SP8D docs ship, for example).

| Criterion              | Firebase Hosting (default)           | GitHub Pages (alternative)                |
| ---------------------- | ------------------------------------ | ----------------------------------------- |
| Custom domain + SSL    | Yes (Phases 5–6)                     | Yes (repo Settings → Pages; slower cert)  |
| Security headers / CSP | Yes (`firebase.json`, `fix-csp.mjs`) | Limited (needs GH Actions to inject)      |
| Cost / infra           | GCP project                          | None                                      |
| Skill phases used      | All                                  | Skip Phase 5 (DNS/Terraform) + Phase 7 SA |

**Pick Firebase unless the project explicitly asks for GitHub Pages.** If
GitHub Pages is chosen: the build is still `astro build` (`output: 'static'`);
deploy `dist/` via a `actions/deploy-pages` step; configure the custom domain
in the repo's Pages settings, not Terraform. The README rewrite (Phase 2),
website creation (Phase 3), and build verification (Phase 4) are identical.

---

## Phase 1: Research the Project

Before writing any website files, understand the actual project:

1. Read the project's `README.md`, `AGENTS.md`, `go.mod`, and `CHANGELOG.md`.
2. Determine the project type (library vs application — see below).
3. Read the source to verify all claims — see the Code Example Verification
   section below.
4. Check for `GOEXPERIMENT=jsonv2` requirements in `go.mod` or `flake.nix`.
   If the library uses `encoding/json/v2`, the README MUST document the
   build constraint. This is the #1 most commonly forgotten requirement.

### Project Type: Library vs Application (CRITICAL decision branch)

This decision affects the hero code, docs pages, badges, links, config.ts
fields, and README structure. Get it wrong and the website will have broken
links to pkg.go.dev or misleading installation instructions.

**How to tell:** Check for a `main.go` or `cmd/` directory:

```bash
# Application: has a main package with func main()
grep -rl "package main" cmd/ 2>/dev/null && echo "APPLICATION"
# Library: no main package, consumers import it
grep -rl "package main" cmd/ 2>/dev/null || echo "LIBRARY (probably)"
```

| Aspect             | Go Library                           | Go Application / Server         |
| ------------------ | ------------------------------------ | ------------------------------- |
| Consumers run      | `go get` + import                    | Download binary / `docker pull` |
| pkg.go.dev         | Yes — include link                   | No — omit entirely              |
| Hero code          | Go import + function call            | Shell command or Docker run     |
| Installation docs  | `go get`, import path                | Binary, Docker, Nix             |
| API reference docs | Go function/type signatures          | HTTP endpoints, CLI flags       |
| `config.ts`        | Include `pkgGoDev` field             | Omit `pkgGoDev` field           |
| Docs link bar      | Documentation, pkg.go.dev, Changelog | Documentation, Changelog        |
| README badges      | Go Reference, Go Report Card         | Docker, GitHub Release          |
| GitHub topics      | `go`, `golang`, library domain       | `go`, `golang`, server domain   |

**Library examples:** go-atomic-write, gogenfilter, go-error-family
**Application examples:** dynamic-markdown-site (binary + Docker + server)

### Code Example Verification (critical)

Every Go code example in the website must be verified against the actual
source. The #1 mistake across sessions is writing code examples from memory
that don't compile.

Before writing any Go code into documentation:

```bash
# Verify function signatures
grep -A2 'func New\|func.*Add\|func.*Create' *.go internal/**/*.go

# Check return types (pointer vs value)
grep 'func.*\*.*{' *.go internal/**/*.go
```

Checklist for every Go code example:

1. Does the function exist? (`grep 'func FunctionName' *.go`)
2. Does the return type match the usage? (pointer vs value)
3. Does the parameter type match the argument? (struct vs \*struct)
4. Does the method receiver match the call? (value vs pointer receiver)

**Common trap:** `NewGraphNode` returns `*GraphNode` but `AddNode` takes
`GraphNode` (value) — you must dereference: `b.AddNode(*node)`.

**Session-derived trap:** Hero code showed `WithDebounce(500*time.Second)`
instead of `500*time.Millisecond`. Always double-check time units in hero
and quick-start examples — this is the #1 most common code typo.

### Application Content Verification

For Go applications/servers (not libraries), verify documentation claims
against actual source:

```bash
# Verify CLI flags against actual flag definitions
grep -r 'flag\.\(String\|Bool\|Int\|Duration\)' internal/ cmd/

# Verify HTTP endpoints against actual route registrations
grep -r 'mux\.Handle\|HandleFunc\|http\.Handle' internal/

# Verify Docker details against the actual Dockerfile
cat Dockerfile

# Verify CI workflows exist
ls .github/workflows/
```

Common README errors for applications:

- Claiming a web framework (e.g. Gin) when code uses `net/http` — verify
  via `grep 'gin-gonic\|gin-gonic' go.mod`
- Describing Docker builds wrong (e.g. "multi-stage" when single-stage) —
  read the actual Dockerfile
- Missing storage backends that exist in code (e.g. S3/GCS via gocloud.dev)
- Listing CLI flags that don't match `flag.StringVar` / `flag.BoolVar` calls
- License mismatches between `.goreleaser.yaml` and `LICENSE` file

---

## Phase 2: README Rewrite

The README is 50% of the public presence. It must match the quality bar
set by go-atomic-write and gogenfilter. Do this BEFORE the website — the
README defines the value proposition, comparison, and API tables that the
website then visualizes.

Load the [README template reference](./references/readme-template.md) for
the complete structure, badge templates, and section ordering.

### Standard README Structure

```
1. Centered header (h1 align="center") with project name
2. Centered tagline (strong)
3. Centered badge row (library: Go Reference | CI | Go Report Card; application: CI | Docker)
4. Centered documentation links (Documentation · API Reference)
5. --- separator
6. One-paragraph summary (what it is, what it's built on)
7. ## Why? — the problem this solves
8. ## Who is this for? — named audience personas (3–5)
9. ## Comparison — table vs alternatives
10. ## How it works — numbered pipeline
11. ## When NOT to use this — specific exclusions + the alternative to reach for
12. ## Install — go get command
13. ## Usage — minimal working example (verified against source)
14. ## Configuration Options — table of all options
15. ## Domain-specific API tables (filters, middleware, etc.)
16. ## Event/Type definitions — struct + rules
17. ## Advanced features — resilience, observability, etc.
18. ## Benchmarks — table
19. ## Dependencies — table
20. ## Design Decisions — bullet list
21. ## Error Handling — sentinel errors, example
22. ## Development — Nix commands
23. ## Examples — table of runnable examples
24. ## API Stability — versioning policy
25. ## License — verify actual license from LICENSE file (NOT hardcoded MIT)
```

**Why "Who is this for?" and "When NOT to use this"?** They are the two
highest-leverage trust signals in technical docs: the first tells a
visitor whether to keep reading, the second proves the project tells the
truth about its own limits. Both cost minutes to write. Load the
[content patterns reference](./references/content-patterns.md) for
copy-paste templates for every section above, plus patterns for docs
pages (curated "Where to go next", comparison tables repeated in docs,
callouts, feedback links).

### What to Remove

If the existing README has any of these, remove them:

- Emoji section headers (`## Features`, `## Zero Boilerplate`)
- Emoji bullet points
- Table of contents (unnecessary for GitHub rendering at <500 lines)
- "Made with heart" footer
- Redundant sections that duplicate the website docs

### Badge Markdown (copy-paste template)

**For Go libraries:**

```markdown
<p align="center">
<a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}"><img src="https://pkg.go.dev/badge/github.com/LarsArtmann/{repo}.svg" alt="Go Reference"></a>
<a href="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml"><img src="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<a href="https://goreportcard.com/report/github.com/LarsArtmann/{repo}"><img src="https://goreportcard.com/badge/github.com/LarsArtmann/{repo}" alt="Go Report Card"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-{LICENSE}-blue.svg" alt="License: {LICENSE}"></a>
</p>
```

**For Go applications/servers:**

Replace Go Reference badge with Docker or GitHub Release badge. Omit
pkg.go.dev (applications are not importable).

```markdown
<p align="center">
<a href="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml"><img src="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<a href="https://github.com/LarsArtmann/{repo}/pkgs/container/{repo}"><img src="https://img.shields.io/badge/docker-ghcr.io-blue.svg" alt="Docker"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-{LICENSE}-blue.svg" alt="License: {LICENSE}"></a>
</p>
```

**License badge:** Replace `{LICENSE}` with the actual license declared in
the LICENSE file. Do NOT assume MIT — verify first. Some projects are
proprietary.

### Documentation Link Bar (below tagline)

**For Go libraries:**

```markdown
<p align="center">
<a href="https://{subdomain}.lars.software">Documentation</a> · <a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}">API Reference</a>
</p>
```

**For Go applications/servers:**

```markdown
<p align="center">
<a href="https://{subdomain}.lars.software">Documentation</a> · <a href="CHANGELOG.md">Changelog</a>
</p>
```

---

## Phase 3: Create the Website

Load the [file manifest](./references/file-manifest.md) to see exactly which
files to copy verbatim, which to customize, and which to write fresh. The
classification eliminates the need to read 60+ reference files via sub-agents.

Before designing, load the [design inspiration reference](./references/design-inspiration.md)
to calibrate what "nice" looks like (the Nextra-class docs aesthetic, and how
Starlight reaches it via theme tuning — not a framework switch).

### 3.1 Choose the Reference Baseline

Two reference repos exist. **Use gogenfilter (`~/projects/gogenfilter/website/`)
as the baseline** — it has CSP hardening, OG images, and a CI/CD pipeline.
go-atomic-write (`~/projects/go-atomic-write/website/`) is the older, simpler
pattern without these features.

| Feature              | go-atomic-write | gogenfilter                                 |
| -------------------- | --------------- | ------------------------------------------- |
| Security headers     | No              | **Yes** (HSTS, X-Frame-Options, CORP, COOP) |
| CSP hash injection   | No              | **Yes** (`fix-csp.mjs`)                     |
| OG images            | No              | **Yes** (`astro-og-canvas`)                 |
| Two-job CI           | No              | **Yes** (build, then deploy)                |
| Service account auth | No              | **Yes** (`GOOGLE_APPLICATION_CREDENTIALS`)  |

**Security headers vs CSP:** These are different things. Security headers
(HSTS, X-Frame-Options, Permissions-Policy, etc.) go in `firebase.json`
`headers` config. Content-Security-Policy (CSP) is a separate header that
restricts script/style/font sources. `fix-csp.mjs` post-processes built HTML
to inject SHA-256 hashes for inline scripts into the CSP header. Include
security headers in `firebase.json` always; add CSP hardening optionally
if the project needs it (copy from gogenfilter).

**Important:** Components are NOT verbatim copies between repos. They share
the same data-driven architecture (consume data from `src/data/*.ts`) but
differ in markup, styling, and sometimes structure. Copy from gogenfilter as
the starting point, then customize per-project.

### 3.2 Build the Website

1. **Copy verbatim** (~12 files) — see file manifest, "Copy verbatim" rows.
   These need zero changes.

2. **Customize specific fields** (~15 files) — change project name, URLs,
   accent color, sidebar structure. See file manifest, "Customize" rows.

3. **Write fresh** (~20 files) — project-specific content: features, hero code,
   sections, all docs pages, logo, favicon, and section components (CTASection,
   ComparisonSection, etc. — these follow the data-driven pattern from
   gogenfilter but need per-project markup and styling).

### 3.3 Accent Color

Load the [color palette reference](./references/color-palette.md) for
pre-computed CSS token sets for each supported accent color. Do NOT manually
compute `rgba()` values — use the table.

### 3.4 Dependencies

Load the [dependency version reference](./references/dependency-versions.md)
for the verified package.json version matrix. Do NOT guess or bump versions —
use the exact pins that are known to work together.

### 3.5 Favicon and Logo Design

Both use the same design constraints:

- **Dimensions:** 28x28 viewBox
- **Shape:** Rounded rectangle (`rx="6"`) filled with the accent color
- **Foreground:** Simple monogram or icon in `bg-primary` color (`#0a0908`)
- **favicon.svg:** Use the literal hex value of the accent color (not CSS
  variables, since SVGs viewed as tabs don't resolve them). Use the **dark-mode
  `--color-accent` value** from the color palette.
- **Logo.astro:** Use CSS variables (`fill-[var(--color-accent)]`) so it adapts
  to light/dark theme.

### 3.6 MDX Gotcha

Characters `<`, `>`, `<=`, `>=` break Starlight `.mdx` file parsing. In `.mdx`
files, escape them as `&lt;`, `&gt;`, or rephrase the sentence to avoid them.
This does not affect `.md` files.

### 3.7 Section Components Are Open-Ended

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

### 3.8 Creation Order

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

### 3.9 Section Component Patterns

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

### 3.10 Starlight config knobs (the "nice docs" enablers)

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
[content patterns reference](./references/content-patterns.md) §5. For
the visual/aesthetic calibration that makes a Starlight site read as
"Nextra-class nice", see the
[design inspiration reference](./references/design-inspiration.md) —
the gap to best-in-class docs is theme tuning and content patterns, not
a framework switch.

---

## Phase 4: Build Verification

```bash
cd website
nix shell nixpkgs#nodejs -c npm install
nix shell nixpkgs#nodejs -c npm run build
```

If using npm v11+, native binary packages need approval:

```bash
nix shell nixpkgs#nodejs -c npx approve-scripts esbuild sharp   # if blocked
```

Expected output: N pages generated, sitemap, pagefind search index, 0 errors.

Run type checking and HTML validation:

```bash
nix shell nixpkgs#nodejs -c npx astro check          # 0 errors, 0 warnings
nix shell nixpkgs#nodejs -c npx html-validate "dist/**/*.html"
```

### Visual QA Gate (mandatory — Phase 4 does not start until this passes)

Across prior sessions, agents built 37+ files rendering to 15+ HTML pages and
NEVER looked at any of them. Broken icons, CSS mismatches, and layout bugs
were all latent. This gate exists because that is the single biggest quality
risk in the entire workflow.

**Step 1: Start preview server and verify HTTP responses**

```bash
# Start preview server
nix shell nixpkgs#nodejs -c npm run preview &
sleep 3

# Verify key pages return 200 (use fetch tool, not curl)
# Check: http://localhost:4321/ — landing page
# Check: http://localhost:4321/getting-started/installation/ — first doc page

# Verify CSS variables resolved (use fetch tool to read the HTML)
# Look for 'color-accent' in the output — if missing, tokens are broken
```

**Step 2: Headless screenshot (if available)**

If Chromium is available via Nix, take a screenshot for visual verification:

```bash
nix shell nixpkgs#chromium -c chromium --headless --no-sandbox \
  --screenshot=/tmp/website-landing.png \
  --window-size=1440,900 http://localhost:4321/
```

Then view the screenshot with the `view` tool to verify:

- Hero section renders with code mockup
- Feature icons are visible (not broken SVG)
- Dark theme is applied by default
- No layout overflow or missing CSS

**Step 3: Manual visual checklist**

If neither headless screenshot nor browser access is available, **flag the
visual QA as incomplete and explicitly tell the user**:

> "I verified HTTP 200 responses and CSS token presence, but could not perform
> visual QA (no browser available). Please check the preview server at
> http://localhost:4321/ to verify: hero code mockup, feature icons, dark/light
> toggle, mobile layout, footer links."

---

## Phase 5: Go-Live Sequence

Follow this exact sequence. Each step depends on the previous one.

### Step 1: Generate lock files

```bash
cd website
git add flake.nix   # nix flake lock requires the file to be tracked by git
nix shell nixpkgs#nodejs -c npm install   # generates package-lock.json
nix flake lock                                # generates flake.lock
# Commit package-lock.json AND flake.lock for reproducible CI builds
```

### Step 2: Create Firebase hosting site

```bash
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase hosting:sites:create {siteId} --project {firebaseProject}
```

Site IDs are **immutable**. Use the full repo slug to avoid collisions.

### Step 3: Deploy

**Before deploying**, verify the Firebase upload endpoint is reachable. This
is a different host from the main Firebase API and may be blocked by
firewalls or network policies:

```bash
nix shell nixpkgs#nodejs -c node -e \
  "require('https').get('https://upload-firebasehosting.googleapis.com', r => { console.log('upload endpoint:', r.statusCode); r.resume() })"
# If this fails or hangs, deploy will fail — flag immediately
```

Then deploy:

```bash
cd website

# Shared project (.firebaserc with targets):
# {
#   "projects": { "default": "lars-software" },
#   "targets": {
#     "lars-software": { "hosting": { "{target}": ["{siteId}"] } }
#   }
# }
# Deploy: firebase deploy --only hosting:{target} --project lars-software

# Standalone project (.firebaserc without targets):
# { "projects": { "default": "{projectId}" } }
# Deploy: firebase deploy --only hosting --project {projectId}

nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase deploy --only hosting:{targetOrBlank} --project {firebaseProject}
```

### Step 4: Verify web.app URL

Use the `fetch` tool to verify `https://{siteId}.web.app` returns HTTP 200.

### Step 5: Add custom domain via REST API

The Firebase CLI has **no command** for adding custom domains. Use the REST
API. The critical details are inline here; load the
[Firebase REST API reference](./references/firebase-rest-api.md) for the full
script templates.

**Endpoint:** `POST https://firebasehosting.googleapis.com/v1beta1/projects/{firebaseProject}/sites/{siteId}/customDomains?customDomainId={subdomain}.lars.software`

**Headers (all required):**

- `Authorization: Bearer {ACCESS_TOKEN}`
- `x-goog-user-project: {firebaseProject}` — omitting this causes `403 "quota project not set"`
- `Content-Type: application/json`

**Body:** `{}` (empty object — the domain is in the query param)

**Access token:**

```bash
ACCESS_TOKEN=$(nix shell nixpkgs#google-cloud-sdk -c \
  gcloud auth print-access-token --project={firebaseProject})
```

### Step 6: Extract ACME challenge

The domain creation response (or the list response) includes the SSL cert
verification challenge under `requiredDnsUpdates.desired[0].records` (CNAME)
and `cert.verification.dns.desired[0].records` (ACME TXT).

Map to DNS:

- CNAME record: hostname = `{subdomain}`, target = `{siteId}.web.app.`
- TXT record: hostname = `_acme-challenge.{subdomain}`, value = ACME token

### Step 7: Stage DNS records in Terraform

Load the [DNS Terraform reference](./references/dns-terraform.md) for the exact
CNAME + TXT record templates.

DNS records for `{name}.lars.software` go in `domains/lars.software.tf`.
Records for `{name}.larsartmann.com` go in `domains/larsartmann.com.tf`.

**Placement:** Insert new records BEFORE the closing `}` of the
`resource "namecheap_domain_records"` block. Place them after the last
existing record, grouped with a comment header matching the existing
pattern (e.g. `# {project} website (Firebase Hosting)`).

```bash
cd ~/projects/domains
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform fmt
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform validate
```

### Step 8: Apply Terraform (requires valid credentials)

```bash
cd ~/projects/domains

# Verify API key is valid FIRST (see Phase 0.2)
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c \
  terraform plan -target=namecheap_domain_records.lars_software

# If plan succeeds, apply
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c \
  terraform apply -target=namecheap_domain_records.lars_software
```

If credentials are blocked (expired API key, IP not whitelisted), stage the
records and flag as a manual step for the user.

### Step 9: Wait for SSL provisioning

Poll the domain status using the Firebase REST API (see reference for the GET
script). Lifecycle: `OWNERSHIP_MISSING` -> `CERT_VALIDATING` ->
`CERT_ACTIVE`.

This can take 10-60 minutes after DNS propagates. Firebase auto-provisions the
SSL certificate once it can verify the ACME TXT record.

### Step 10: Verify custom domain

Use the `fetch` tool to verify `https://{subdomain}.lars.software` returns HTTP 200.

---

## Phase 6: GitHub Metadata

```bash
gh repo edit LarsArtmann/{repo} \
  --description "{one-liner} — {key features}" \
  --homepage "https://{subdomain}.lars.software" \
  --add-topic go,golang,{domain-specific-topics}
```

### Standard topic vocabulary

**For Go libraries:** `go`, `golang`, plus domain-specific topics (e.g.
`error-handling`, `structured-errors`, `code-duplication`, `static-analysis`).

**For Go applications/servers:** `go`, `golang`, plus deployment and domain
topics (e.g. `web-server`, `markdown`, `docker`, `wiki`).

Remove any topics that reference frameworks the project doesn't use (e.g.
remove `gin` if the project uses `net/http`).

### Badge set (README)

Standard order for **libraries**: Go Reference | Go Report Card | CI |
License.

Standard order for **applications**: CI | Docker | License (no Go Reference
or Go Report Card — those are for importable packages only).

### Documentation link bar

**For Go libraries:**

```markdown
**[Documentation](https://{subdomain}.lars.software)** ·
**[pkg.go.dev](https://pkg.go.dev/github.com/LarsArtmann/{repo})** ·
**[Changelog](CHANGELOG.md)**
```

**For Go applications/servers:**

```markdown
**[Documentation](https://{subdomain}.lars.software)** ·
**[Changelog](CHANGELOG.md)**
```

Omit pkg.go.dev — applications are not importable.

---

## Phase 7: CI/CD Setup (after manual launch is verified)

Only proceed after the custom domain is live and verified.

### Step 1: Create Firebase service account key

```bash
# Find the firebase-admin SDK service account
nix shell nixpkgs#google-cloud-sdk -c \
  gcloud iam service-accounts list --project={firebaseProject} | grep firebase-adminsdk

# Create a key (temp file — clean up after)
nix shell nixpkgs#google-cloud-sdk -c \
  gcloud iam service-accounts keys create /tmp/firebase-ci-key.json \
  --iam-account=firebase-adminsdk-{hash}@{firebaseProject}.iam.gserviceaccount.com \
  --project={firebaseProject}

# Set GitHub secret
gh secret set FIREBASE_SERVICE_ACCOUNT --repo LarsArtmann/{repo} \
  --body "$(cat /tmp/firebase-ci-key.json)"

# Verify
gh secret list --repo LarsArtmann/{repo}

# Clean up
rm /tmp/firebase-ci-key.json
```

### Step 2: Add CI workflow

Load the [CI workflow reference](./references/ci-workflow.md) for the
full template. It uses a two-job pattern:

1. **build-website** — `npm ci`, `astro check`, `astro build`, HTML validation,
   upload artifact
2. **deploy-website** — download artifact, deploy to Firebase via
   `GOOGLE_APPLICATION_CREDENTIALS` secret

The reference also includes rollback commands (`firebase hosting:rollback`)
for reverting a broken deploy.

---

## Commit Discipline

Commit at these checkpoints — never leave a session with uncommitted work:

1. **After domain confirmed by user** — Phase 0.4 gate passed
2. **After README rewrite** — verified correct against source code
3. **After website builds successfully** — `astro check` = 0 errors,
   `astro build` = success
4. **After Firebase deploy confirmed live** — HTTP 200 on web.app URL
5. **After DNS records staged** — Terraform `fmt` + `validate` pass

### Definition of Done

Before declaring complete, verify EVERY item:

**Build and Deploy**

- [ ] `npm run build` succeeds with 0 errors (run from `website/`)
- [ ] `npx astro check` passes with 0 errors
- [ ] `https://{siteId}.web.app` returns HTTP 200
- [ ] All docs pages return HTTP 200 on web.app
- [ ] All internal doc links resolve (no 404s in Starlight sidebar)
- [ ] GitHub homepage URL matches `https://{subdomain}.lars.software`

**README**

- [ ] Centered header with badges (library: Go Reference, CI, Go Report Card; application: CI, Docker)
- [ ] Documentation link to `https://{subdomain}.lars.software`
- [ ] pkg.go.dev link ONLY for libraries, NOT for applications
- [ ] License badge matches actual LICENSE file (NOT hardcoded MIT)
- [ ] No emojis in headers or bullets
- [ ] All code examples verified against Go source
- [ ] Comparison table present

**GitHub**

- [ ] Description updated
- [ ] Homepage URL set to `https://{subdomain}.lars.software`
- [ ] Topics include `go`, `golang`, + domain-specific

**DNS (if credentials available)**

- [ ] CNAME record in `domains/lars.software.tf`
- [ ] ACME TXT record in `domains/lars.software.tf`
- [ ] `terraform validate` passes
- [ ] `terraform fmt -check` passes

**Files**

- [ ] `package-lock.json` committed
- [ ] `flake.lock` committed
- [ ] No `firebase-tools` in `package.json` dependencies
- [ ] No temp files left behind (`/tmp/*.js`)
- [ ] `git status` clean in BOTH repos (project + domains)

### Two repos awareness

When working on a project website with DNS, there are always TWO repos to
commit:

- The project repo (website files, README, CI workflow)
- The domains repo (DNS records)

Run `git status` in BOTH before declaring done.

### Pre-commit check for domains repo

Before editing the domains repo, run `git status`. If there are pre-existing
uncommitted changes from other sessions, flag them to the user before layering
your changes on top.

### Status report guidance

When writing status reports, **never hardcode unconfirmed URLs or domain
names**. Use `{subdomain}.lars.software (pending DNS propagation)` until the
domain is verified live. A status report that references a domain that was
subsequently renamed is worse than no status report — it creates a false
historical record.

---

## Common Pitfalls

Load the [common pitfalls reference](./references/common-pitfalls.md) for the
full list. The most critical:

1. **`curl` is BANNED in Crush** — use the `fetch` tool or Node.js
   `https.request` for HTTP requests. Every command sample in this skill uses
   Nix invocations and Node.js, not curl.
2. **Terraform is unfree** — use `NIXPKGS_ALLOW_UNFREE=1 nix shell --impure
nixpkgs#terraform` or `opentofu`.
3. **`npm`, `node`, `firebase` are not in PATH** — always invoke via
   `nix shell nixpkgs#{package} -c {command}`.
4. **Vite override conflicts** — **Remove `vite` from overrides entirely.**
   Astro 7 manages its own Vite version (Vite 8). Pinning `vite: 7.3.2`
   (copied from gogenfilter's older lockfile) causes a build failure with
   `rollupOptions.input should not be an html file when building for SSR`.
   Keep only `brace-expansion`, `devalue`, and `yaml` in overrides. See
   [dependency-versions.md](./references/dependency-versions.md).
5. **`--legacy-peer-deps` trap** — If you must use it, create `.npmrc`
   with `legacy-peer-deps=true`. Otherwise the lockfile is non-reproducible.
6. **MDX character escaping** — `<`, `>`, `<=`, `>=` break `.mdx` files.
7. **`package-lock.json` + `flake.lock`** — Must be generated and committed.
8. **`GOEXPERIMENT=jsonv2`** — If the library uses `encoding/json/v2`,
   document the build constraint in README.
9. **Stray dependencies** — Never `npm install` a package as a debugging step
   without removing it. Use `npx` for one-off commands.
10. **Firebase upload endpoint** — `upload-firebasehosting.googleapis.com` is a
    different host. If unreachable, deploys fail. Verify before attempting.
11. **bun vs Node.js for deploy** — `firebase deploy` uses the `re2` native
    module which fails under bun. Use real Node.js from Nix.
12. **Edit tool collateral damage** — When editing Terraform files, include
    enough unique context and run `git diff` after every edit.
13. **Committing before domain confirmation** — The subdomain name touches 8+
    files. Never commit until the user confirms the domain (Phase 0.4).
14. **Firebase custom domain API** — Use `customDomains` endpoint (not
    `domains`), body is `{}` with domain in query param, `x-goog-user-project`
    header is required. See [firebase-rest-api.md](./references/firebase-rest-api.md).
15. **Fabricated hero code** — Hero terminal output or code snippets that
    don't match actual tool output. Always run the tool and capture real
    output for the hero section, or label it as illustrative.
16. **Auth secret mismatch** — Upgrading from `FIREBASE_TOKEN` to
    `FIREBASE_SERVICE_ACCOUNT` without adding the new secret first. Deploy
    fails on first push. Check which secret exists before changing the
    workflow.
17. **Stale root-level docs** — Old documentation files (HOW_TO_USE.md,
    USAGE.md, etc.) that overlap with the new website create confusion.
    Consolidate, archive, or link from README.
18. **Branch name in deploy workflow** — The CI workflow template uses
    `master`. If the project uses a different default branch (e.g. `fork`,
    `main`), update ALL branch references in the workflow YAML.
19. **License mismatch** — Verify the LICENSE file, `.goreleaser.yaml`,
    `flake.nix`, and `package.json` all declare the SAME license. Prior
    session found `.goreleaser.yaml` claiming MIT while the LICENSE file
    was proprietary — actively misleading Homebrew/Scoop/Nix repositories.
20. **Lockfile package-manager mismatch** — If the dev environment uses
    `bun install` but CI uses `npm ci`, there's no `package-lock.json`.
    Either: (a) run `npm install` once to generate `package-lock.json`
    for CI, or (b) update CI to use bun and commit `bun.lock` (remove
    it from `.gitignore` first).
21. **Application README claims wrong framework** — A README that claims
    Gin/Echo/Fiber when the code uses `net/http` destroys credibility.
    Always verify `go.mod` for the actual HTTP framework before writing
    the tech stack table.
