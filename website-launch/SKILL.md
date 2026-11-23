---
name: website-launch
description: >-
  Use this skill when the user asks to create a project website, build a
  documentation site, deploy to Firebase, configure DNS, set up GitHub metadata,
  rewrite a README for public presence, "make a website", "publish docs", "set
  up Firebase hosting", configure custom domains, or any task involving the
  sibling-project website pattern (go-atomic-write, gogenfilter, go-output,
  etc.). Also triggers on "website launch", "public presence overhaul",
  "deploy website", "lars.software domain". Launches a public docs site for a
  Go project by scaffolding the private Go SSG template
  (github.com/LarsArtmann/website-template: Go + templ + Tailwind v4 + Firebase
  Hosting) via the websitelaunch CLI, then DNS/SSL go-live. Legacy Astro sites
  (18 live) get maintenance audits only — no new Astro sites. Every launch
  sells the project with a rendered demo video (HyperFrames HTML→MP4) as the
  landing page centerpiece by default — trigger on "demo video", "product
  tour", "promo clip", "make the launch sell the project" too.
metadata:
  tags: website, firebase, go-ssg, dns, deployment, documentation
allowed-tools: bash view edit write grep fetch
---

# Website Launch

Launches a public documentation website for a Go project (library or
application/server) by scaffolding the canonical **`website-template`** Go
SSG stack (decided 2026-10-27, `docs/decisions/2026-10-27_open-decisions.md`
§A: pure Go `cmd/site` + templ + Tailwind CSS v4 + Firebase Hosting; golden
tests, CSP hash-pinning, and a link checker are built into the template).
The `websitelaunch` CLI in the template repo mechanizes the launch phases:
`doctor` (Phase 0), `init` (Phase 3 scaffold), `check` (Phase 4 DoD).

> **Legacy Astro sites:** the 18 live Astro/Starlight sites get the manual
> §0.0 audit for maintenance only. Do NOT create new Astro sites — the
> Node/pnpm pitfall class (8 of 22 documented pitfalls) died with this
> decision. Astro-specific references retained here are marked `[legacy]`.

> **Path conventions:** This skill assumes the LarsArtmann project layout:
> `~/projects/{repo}` for project repos and `~/projects/domains` for the DNS
> Terraform repo. If your layout differs, substitute your own paths for
> `{repo-path}` and `{domains-path}` throughout. The `{repo}` placeholder in
> commands means the target repo name, not a shell variable — replace it before
> running.

## Environment: Nix + Crush Constraints

All commands below assume a **Nix-based environment** and **Crush CLI tool
constraints**. These apply throughout:

- **`curl` is BANNED** in Crush. Use the `fetch` tool for HTTP requests, or
  Go/Node.js for scripted API calls. Every `curl` in older references has
  been replaced.
- **`go` is on PATH; `templ`/`tailwindcss` may not be.** `websitelaunch
  doctor` probes both — regenerating `.templ` sources needs templ at the
  pinned version (the CLI rewrites import paths at scaffold time, so `init`
  itself does not). Build via `bash build.sh` (tailwindcss via
  `nix shell nixpkgs#tailwindcss_4` when absent).
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

**Start with the mechanized pre-flight** — from a `website-template` clone:

```bash
go run ./cmd/websitelaunch doctor --repo github.com/LarsArtmann/{repo}
```

It checks the template tree, Go toolchain vs go.mod, the templ version pin
(drift re-stamps every generated file), tool presence (WARNs), `gh` auth,
and the repo name collision. Findings print as What/Why/Fix. The manual
checks below cover what a CLI cannot: existing sites, credentials, and the
human domain gate.

**First decision (§0.6):** hosting target. The default is Firebase Hosting
(custom domains, headers, the DNS pipeline in Phases 5–7). If the project
needs none of that, GitHub Pages is a zero-infra alternative — decide early,
it changes which phases apply.

### 0.0 Existing Website Check

Before starting any work, check if a website already exists:

```bash
ls ~/projects/{repo}/website/go.mod 2>/dev/null \
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
- Site chrome: git-derived `lastUpdated` and per-page edit links are
  built into the template (`GitHubDefaultBranch` in data.go).
- Swap bold-text warnings for `:::caution` / `:::tip` callouts.
- **Demo video: if the landing page has none, produce one** (see §3.3 and the
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
| Security headers / CSP | Yes (firebase.json headers + hash-pinned CSP) | Limited (needs GH Actions to inject)      |
| Cost / infra           | GCP project                          | None                                      |
| Skill phases used      | All                                  | Skip Phase 5 (DNS/Terraform) + Phase 7 SA |

**Pick Firebase unless the project explicitly asks for GitHub Pages.** If
GitHub Pages is chosen: the build is still `bash build.sh`; deploy `dist/`
via an `actions/deploy-pages` step; configure the custom domain in the
repo's Pages settings, not Terraform. The README rewrite (Phase 2), website
creation (Phase 3), and build verification (Phase 4) are identical.

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

### Error-Surface Inventory (Go projects)

The error surface (sentinels, wrap hierarchy, codes, families) is
documentation-grade data — extract it with erraudit, never reconstruct it
by hand. Full recipe and rules: [content-patterns.md §8](./references/content-patterns.md) (Generated Error Reference page).

```bash
GOWORK=off GOEXPERIMENT=jsonv2 erraudit tree . --markdown --no-position
GOWORK=off GOEXPERIMENT=jsonv2 erraudit . --disable-extensions
```

- `GOEXPERIMENT=jsonv2` is REQUIRED on Go 1.26+ — without it, erraudit
  silently returns 0 findings for the 81% of modules importing
  `encoding/json/v2`
- Exit codes: 0 clean, 2 findings found (SUCCESS, not an error), 1
  analysis error
- Check the `Coverage:` line — "0 files scanned" means a wrong
  directory/pattern, not a clean codebase
- Sentinels marked `· unreferenced` are dead-error candidates — verify
  they are real API before documenting them

---

## Phase 2: README Rewrite

The README is 50% of the public presence. It must match the quality bar
set by go-atomic-write and gogenfilter. Do this BEFORE the website — the
README defines the value proposition, comparison, and API tables that the
website then visualizes.

Load the [README template reference](./references/readme-template.md) for
the complete structure, badge templates, and section ordering.

### Standard README Structure

The canonical section order (centered header → tagline → badges → docs
links → one-paragraph summary → `## Why?` → audience → comparison → how it
works → when-NOT-to-use → install → usage → API tables → benchmarks →
license) lives in the
[README template](./references/readme-template.md) §"Standard Section
Order" — and only there. Restating the list here has drifted from the
template before; the template is the single source of truth for structure,
badge markup, and the documentation link bar.

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
the landing hero headline, the demo video's hook and value beat (§3.3),
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

### Badge row + Documentation Link Bar

Both live as copy-paste templates in the
[README template](./references/readme-template.md) ("Badge Template" and
"Documentation Link Bar" sections): the library badge set (with the
`{LICENSE}` placeholder — verify the real license, never assume MIT), the
application variant (Docker instead of Go Reference), and the link bar —
which gains a "Watch the {N}s demo" third link once the §3.3 video exists.
Do not re-invent either markup here; every restatement has historically
drifted from the template.

---

## Phase 3: Create the Website

Before designing, load the [design inspiration reference](./references/design-inspiration.md)
to calibrate what "nice" looks like (the Nextra-class docs aesthetic —
reached here via `site.css` `@theme` tuning and content patterns, not a
framework switch).

### 3.1 Scaffold from the template

```bash
# Once per machine: clone the (private) template
 git clone git@github.com:LarsArtmann/website-template ~/projects/website-template

cd ~/projects/website-template
go run ./cmd/websitelaunch doctor --repo github.com/LarsArtmann/{repo}
go run ./cmd/websitelaunch init \
  --name {Project} \
  --repo github.com/LarsArtmann/{repo} \
  --url https://{subdomain}.lars.software \
  --dir ~/projects/{repo}/website
```

`init` rewrites the module path (imports in `.go`/`.templ`/`_templ.go`,
`go.mod`, README), the identity constants in `internal/pages/data.go`, and
the firebase targets — count-verified, so a drifted template fails loudly.
It does NOT copy the CLI itself. The site commits into the project repo at
`{repo}/website/` (same layout as every live site).

After `init`, two regeneration steps are mandatory (both embed identity):

```bash
cd ~/projects/{repo}/website
GOWORK=off GOEXPERIMENT=jsonv2 go test ./internal/pages/ -count=1 -update  # goldens
GOWORK=off GOEXPERIMENT=jsonv2 go run ./cmd/site --out dist --repo-root . --update-csp
```

### 3.2 What `init` does not do (the manual map)

1. **Content** — docs pages as markdown in `content/docs/**/*.md` (`title`
   + `description` frontmatter) PLUS a `DocRef` entry in the `docSidebar`
   registry (`internal/pages/docs.go`). Both, or the page does not render;
   the test suite fails on either orphaning.
2. **Landing sections** — the content tables in `internal/pages/data.go`
   (Features, ComparisonColumns, …) and the copy in `landing.templ` /
   `sales.templ` / `hero.templ`. Hero code must be REAL captured output
   (Phase 1 verification), never fabricated.
3. **Accent color** — the `@theme` token block in `site.css`
   (`--color-accent` + hover/dim/light pair; dark overrides under `.dark`).
   No precomputed tables needed — change the tokens, rebuild.
4. **Favicon and assets** — `public/favicon.svg` (28x28 viewBox, rounded
   rect, literal accent HEX — SVG tabs do not resolve CSS variables; use the
   dark-mode accent), `public/manifest.json`, `public/og/*.png` (1200x630).
5. **Per-site CTA config** — `DemoURL` in data.go (linked as "Live Demo"
   from hero/sales/404; point it at something real) and `PkgGoDevURL`
   (libraries only; clear it for applications).

Full per-site adaptation contract: the template repo's `README.md`.

### 3.3 Demo video — the launch's sales engine (default for every project)

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

The mechanized half is one command, run from the site directory:

```bash
cd {repo}/website
bash build.sh    # Go SSG + Tailwind; needs tailwindcss (nix shell nixpkgs#tailwindcss_4)
go run ~/projects/website-template/cmd/websitelaunch check
```

`check` fails red on: monorepo path leftovers, un-rewritten template
identity, `go vet`/`go test ./...` failures (GOWORK=off GOEXPERIMENT=jsonv2
are set by the check itself), and incomplete `dist/`. The Go suite already
includes build integrity, CSP hash sync, link/anchor checks, the search
index, sitemaps, and goldens — the classes that were manual `astro check`
steps before.

### Error-Reference Readiness Gate (Go projects)

The site must render the project's error surface truthfully before
go-live:

```bash
GOWORK=off GOEXPERIMENT=jsonv2 erraudit . --disable-extensions
```

- rc ≤ 2 required (rc 2 = findings exist — triage and reflect them in
  the docs, never hide them)
- If a generated Error Reference page exists (content-patterns.md §8),
  spot-check three of its entries against a fresh `erraudit tree` run —
  the page must list every public sentinel the code declares
- Never document an error the code does not define; never omit a public
  sentinel from the reference

### Visual QA Gate (mandatory — Phase 4 does not start until this passes)

Across prior sessions, agents built 37+ files rendering to 15+ HTML pages and
NEVER looked at any of them. Broken icons, CSS mismatches, and layout bugs
were all latent. This gate exists because that is the single biggest quality
risk in the entire workflow.

**Step 1: Start preview server and verify HTTP responses**

```bash
# Start preview server (any static file server over dist/)
nix shell nixpkgs#python3 -c python3 -m http.server 4321 --directory dist &
sleep 2

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

### Social preview

Generate the card with the bundled
[generate.sh](./scripts/social-preview/generate.sh) (writes the SVG source +
the 1280x640 PNG into `assets/branding/`, computes font sizes to fit the
canvas, and machine-checks GitHub's limits):

```bash
website-launch/scripts/social-preview/generate.sh \
  --title "linter-autoconfigure-sdk" \
  --tagline "Shared foundation for linter auto-configuration tools" \
  --install "github.com/larsartmann/linter-autoconfigure-sdk"
```

Then upload it (manual; no API) so repo cards render a designed card instead
of a README screenshot. Add `--animate typing` for a ~37 KB typing-loop GIF
(README embeds, Discord/Slack/Telegram). Load the
[social preview reference](./references/social-preview.md) for the verified
constraints (1280x640, < 1 MB), the no-deep-URL upload gotcha (Settings ->
General -> Social preview; no API), and the design rules + card-size
legibility workflow.

### Documentation link bar

Do not re-invent a bar variant here — the README already carries the bar
Phase 2 placed. The canonical markup (HTML `<p align="center">` form,
libraries vs applications) lives in the
[README template](./references/readme-template.md) "Documentation Link Bar"
section, including the "Watch the {N}s demo" third link that gets appended
once the §3.3 demo video exists. Verify the shipped README matches that
template — a bold-link bar here and an HTML bar in the template is exactly
the split brain that produced two different bars across launched repos.

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

Two-job pattern (same as the legacy Astro flow, Go build):

1. **build-website** — checkout, `nix shell nixpkgs#go nixpkgs#tailwindcss_4 -c
   bash website/build.sh`, upload `website/dist` artifact
2. **deploy-website** — download artifact, deploy to Firebase via
   `GOOGLE_APPLICATION_CREDENTIALS` (the service-account secret from step 1)

The template repo does not yet ship a ready-made workflow file (tracked as
template follow-up, decision Q5: only the CI-deploy item migrates into the
template). Until then write it per project — keep the branch name in sync
with the repo's default (`master` here), and include rollback:
`firebase hosting:rollback` reverts a broken deploy.

---

## Commit Discipline

Commit at these checkpoints — never leave a session with uncommitted work:

1. **After domain confirmed by user** — Phase 0.4 gate passed
2. **After README rewrite** — verified correct against source code
3. **After website builds successfully** — `websitelaunch check` = PASS
   (vet, tests, goldens, leftovers, dist artifacts)
4. **After Firebase deploy confirmed live** — HTTP 200 on web.app URL
5. **After DNS records staged** — Terraform `fmt` + `validate` pass

### Definition of Done

The build/deploy half is `websitelaunch check` PASS plus HTTP 200 on the
web.app and custom URLs. The human-gate half (verify EVERY item):

- [ ] GitHub homepage URL matches `https://{subdomain}.lars.software`
- [ ] README: centered header with badges (library: Go Reference, CI, Go
      Report Card; application: CI, Docker), docs link, pkg.go.dev link ONLY
      for libraries, license badge matches the LICENSE file, no emojis in
      headers, all code examples verified against Go source, comparison
      table present
- [ ] GitHub: description updated, homepage set, topics include `go`,
      `golang`, + domain-specific
- [ ] DNS (if credentials available): CNAME + ACME TXT records in
      `domains/lars.software.tf`; `terraform validate` + `fmt -check` pass
- [ ] Demo video: `website/public/demo.mp4` (< 3 MB, ~20-30s), beats derived
      from the README value prop, visible without scrolling on 1440x900,
      composition committed under `website/video/` (never `/tmp`), poster is
      a selling frame, README bar links it with accurate runtime, `og:image`
      from the poster (1200x630), `firebase.json` cache glob covers
      `mp4|webm|mov`, `HEAD /demo.mp4` returns the immutable cache header
- [ ] `flake.lock` committed; no temp files left behind (`git status` clean)
- [ ] **Two repos awareness**: project repo (website files, README, CI) AND
      domains repo (DNS) — `git status` in BOTH before declaring done
- [ ] Status reports never hardcode unconfirmed URLs/domains — write
      `{subdomain}.lars.software (pending DNS propagation)` until verified
      live; a report referencing a renamed domain is a false historical record

---

## Common Pitfalls

Web-platform behaviour questions (dialog/popover semantics, `:has()`,
container queries, view transitions, Baseline support) are owned by the
installed `modern-web-guidance` skill — query it, do not restate its
guidance here.

Load the [common pitfalls reference](./references/common-pitfalls.md) for the
full list (Astro/Node entries there are marked `[legacy]` — they apply only
to maintaining the 18 live Astro sites). The most critical:

1. **`curl` is BANNED in Crush** — use the `fetch` tool or scripted HTTP
   from Go/Node.js. Every command sample in this skill uses Nix invocations,
   not curl.
2. **Terraform is unfree** — use `NIXPKGS_ALLOW_UNFREE=1 nix shell --impure
   nixpkgs#terraform` or `opentofu`.
3. **`firebase` is not in PATH** — always invoke via
   `nix shell nixpkgs#firebase-tools -c firebase …`.
4. **templ version drift** — regenerating `.templ` with a templ CLI newer
   than the template pin re-stamps every `_templ.go`; `doctor` warns, the
   fix is `go run github.com/a-h/templ/cmd/templ@<pin> generate`.
5. **`GOEXPERIMENT=jsonv2`** — the site module needs it; `websitelaunch
   check` sets it, but manual `go` invocations must export it.
6. **Identity drift is checkable** — `websitelaunch check` fails red on
   monorepo path leftovers and un-rewritten template identity; never
   hand-patch a scaffold, re-init.
7. **Firebase upload endpoint** — `upload-firebasehosting.googleapis.com`
   is a different host. If unreachable, deploys fail. Verify before
   attempting.
8. **bun vs Node.js for deploy** — `firebase deploy` uses the `re2` native
   module which fails under bun. Use real Node.js from Nix.
9. **Edit tool collateral damage** — When editing Terraform files, include
   enough unique context and run `git diff` after every edit.
10. **Committing before domain confirmation** — The subdomain name touches
    8+ files. Never commit until the user confirms the domain (Phase 0.4).
11. **Firebase custom domain API** — Use `customDomains` endpoint (not
    `domains`), body is `{}` with domain in query param, `x-goog-user-project`
    header is required. See [firebase-rest-api.md](./references/firebase-rest-api.md).
12. **Fabricated hero code** — Hero terminal output or code snippets that
    don't match actual tool output. Always run the tool and capture real
    output for the hero section, or label it as illustrative.
13. **Auth secret mismatch** — Upgrading from `FIREBASE_TOKEN` to
    `FIREBASE_SERVICE_ACCOUNT` without adding the new secret first. Deploy
    fails on first push. Check which secret exists before changing the
    workflow.
14. **Stale root-level docs** — Old documentation files (HOW_TO_USE.md,
    USAGE.md, etc.) that overlap with the new website create confusion.
    Consolidate, archive, or link from README.
15. **Branch name in deploy workflow** — the workflow assumes `master`; if
    the repo defaults elsewhere, update ALL branch references.
16. **License mismatch** — LICENSE, `.goreleaser.yaml`, and `flake.nix` must
    declare the SAME license. A prior session found `.goreleaser.yaml`
    claiming MIT while LICENSE was proprietary — actively misleading
    Homebrew/Scoop/Nix repositories.
17. **Application README claims wrong framework** — a README that claims
    Gin/Echo/Fiber when the code uses `net/http` destroys credibility.
    Verify `go.mod` before writing the tech stack table.
18. **Video composition left in `/tmp`** — HyperFrames work staged in `/tmp`
    is lost on reboot (happened on emeet-pixyd; only the committed MP4
    survived). The composition lives in `{repo}/website/video/` from the
    first command. Also: `firebase.json` cache headers must cover `mp4|webm`,
    or the video serves without long-cache headers.
