---
name: website-launch
description: >-
  Use this skill when the user asks to create a project website, build a documentation
  site, deploy to Firebase, configure DNS, set up GitHub metadata for a project, rewrite
  a README for public presence, "make a website", "publish docs", "set up Firebase
  hosting", configure custom domains, or any task involving the sibling-project website
  pattern (go-atomic-write, gogenfilter, dynamic-markdown-site, go-output,
  samber-do-auditlog, go-workflow-auditlog, etc.). Also triggers on "website launch",
  "public presence overhaul", "deploy website", or "lars.software domain". Launches a
  public documentation website for a Go project (library OR application/server) using
  the LarsArtmann Astro + Starlight + Tailwind v4 + Firebase Hosting pattern. Every
  launch sells the project with a rendered demo video (HyperFrames HTML→MP4) as the
  landing page's centerpiece by default — trigger on "demo video", "product tour",
  "promo clip", or "make the launch sell the project" for the site too.
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
- **`pnpm` / `node` are not in PATH by default.** Use:
  ```bash
  nix shell nixpkgs#nodejs -c pnpm install
  nix shell nixpkgs#nodejs -c pnpm run build
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
- **Demo video: if the landing page has none, produce one** (see §3.11 and the
  [demo video reference](./references/demo-video.md)) — it retrofits onto any
  existing site as a ShowcaseSection + `public/demo.mp4`. If one exists, audit
  it against the current value prop (headline/message match, hook frame, README
  link, poster) — videos rot as the product evolves.

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

**The value proposition is written once.** The one-paragraph summary and
"## Why?" section are the canonical sales narrative for the entire launch:
the landing hero headline, the demo video's hook and value beat (§3.11),
and any launch post copy are all derived from them — never re-invented
per surface. When these drift apart, the page fights itself and each
element undersells.

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

Once the demo video exists (§3.11), append a "Watch the {N}s demo" link to
either bar — see the Documentation Link Bar section in the
[README template](./references/readme-template.md).

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

### 3.5-3.10 Website creation details

For favicon/logo design, MDX escaping, section component patterns, creation
order, and Starlight config knobs, load
[./references/website-creation-details.md](./references/website-creation-details.md).

### 3.11 Demo video — the launch's sales engine (default for every project)

Produce a 20-30s video that SELLS the project and embed it on the landing
page. This is part of the launch, not a bonus: a working-product video
above the fold converts where prose cannot, and it is cheap (~30-60 min)
with HyperFrames (HTML/CSS/GSAP → deterministic MP4).

The video shares ONE sales narrative with the README and the landing hero
(written once in Phase 2): its hook speaks the README "Why?" pain in
outcome language, its value claim is the one-paragraph summary compressed
to one sentence, and its final beat is the install command. A feature tour
that never states the value is the known failure mode — it demonstrates
but does not sell.

Load the [demo video reference](./references/demo-video.md) for the full
pipeline — script-before-pixels beat structure, routing through the
HyperFrames `/product-launch-video` workflow when the session has
`hyperframes*` skills (hand-rolled pipeline as fallback), NixOS invocation
(`HYPERFRAMES_BROWSER_PATH`, direct CLI path), seek-safe composition
rules, the canonical `website/video/` location (commit the composition,
never stage it in `/tmp`), hero placement + README deep-link +
poster/`og:image`, mp4 cache headers, distribution tiers, and frame-level
verification without eyes.

Order of operations: ship the site first if the session is long, then add
the video as an immediate follow-up commit — but do not skip it.

---

## Phase 4: Build Verification

```bash
cd website
nix shell nixpkgs#nodejs -c pnpm install
nix shell nixpkgs#nodejs -c pnpm run build
```

If using pnpm v11+, native binary packages need approval:

```bash
nix shell nixpkgs#nodejs -c pnpm dlx approve-scripts esbuild sharp   # if blocked
```

Expected output: N pages generated, sitemap, pagefind search index, 0 errors.

Run type checking and HTML validation:

```bash
nix shell nixpkgs#nodejs -c pnpm dlx astro check          # 0 errors, 0 warnings
nix shell nixpkgs#nodejs -c pnpm dlx html-validate "dist/**/*.html"
```

### Visual QA Gate (mandatory — Phase 4 does not start until this passes)

Across prior sessions, agents built 37+ files rendering to 15+ HTML pages and
NEVER looked at any of them. Broken icons, CSS mismatches, and layout bugs
were all latent. This gate exists because that is the single biggest quality
risk in the entire workflow.

**Step 1: Start preview server and verify HTTP responses**

```bash
# Start preview server
nix shell nixpkgs#nodejs -c pnpm run preview &
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

Follow the exact sequence in
[./references/go-live-runbook.md](./references/go-live-runbook.md). Each step
depends on the previous one. The runbook covers: lock files, Firebase site
creation, deploy, web.app verification, custom domain REST API, ACME challenge
extraction, DNS Terraform staging, Terraform apply, SSL provisioning wait,
and custom domain verification.

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

1. **build-website** — `pnpm install --frozen-lockfile`, `astro check`, `astro build`, HTML validation,
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

Before declaring complete, verify EVERY item on the checklist in
[./references/definition-of-done.md](./references/definition-of-done.md).

---

## Common Pitfalls

Load the [common pitfalls reference](./references/common-pitfalls.md) for the
full list. The most critical:

1. **`curl` is BANNED in Crush** — use the `fetch` tool or Node.js
   `https.request` for HTTP requests. Every command sample in this skill uses
   Nix invocations and Node.js, not curl.
2. **Terraform is unfree** — use `NIXPKGS_ALLOW_UNFREE=1 nix shell --impure
nixpkgs#terraform` or `opentofu`.
3. **`pnpm`, `node`, `firebase` are not in PATH** — always invoke via
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
9. **Stray dependencies** — Never `pnpm install` a package as a debugging step
   without removing it. Use `pnpm dlx` for one-off commands.
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
    `bun install` but CI uses `pnpm install --frozen-lockfile`, there's no `package-lock.json`.
    Either: (a) run `pnpm install` once to generate `package-lock.json`
    for CI, or (b) update CI to use bun and commit `bun.lock` (remove
    it from `.gitignore` first).
21. **Application README claims wrong framework** — A README that claims
    Gin/Echo/Fiber when the code uses `net/http` destroys credibility.
    Always verify `go.mod` for the actual HTTP framework before writing
    the tech stack table.
22. **Video composition left in `/tmp`** — HyperFrames work staged in `/tmp`
    is lost on reboot (happened on emeet-pixyd; only the committed MP4
    survived). The composition lives in `{repo}/website/video/` from the
    first command. Also: `firebase.json` cache headers must cover `mp4|webm`,
    or the video serves without long-cache headers.
