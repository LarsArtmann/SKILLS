---
name: website-launch
description: >-
  Launches a public documentation website for a Go, Rust, or TypeScript library
  using the LarsArtmann Astro + Starlight + Tailwind v4 + Firebase Hosting
  pattern. Use this skill when the user asks to create a project website, build
  a documentation site, deploy to Firebase, configure DNS, set up GitHub
  metadata for a library, rewrite a README for public presence, "make a
  website", "publish docs", "set up Firebase hosting", configure custom
  domains, or any task involving the sibling-project website pattern
  (go-atomic-write, gogenfilter, go-output, go-workflow-auditlog, etc.). Also
  triggers on "website launch", "public presence overhaul", "deploy website",
  or "lars.software domain".
metadata:
  tags: website, firebase, astro, starlight, dns, deployment, documentation
allowed-tools: bash
---

# Website Launch

Launches a public documentation website for a library using the deterministic
Astro + Starlight + Tailwind v4 + Firebase Hosting pattern shared across all
LarsArtmann projects.

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

### 0.0 Existing Website Check

Before starting any work, check if a website already exists:

```bash
ls ~/projects/{repo}/website/package.json 2>/dev/null \
  && echo "INFO: website/ directory already exists — check if this is an update or a rebuild"
```

If a website exists, **switch to maintenance mode**: read the existing files,
identify what needs updating, and skip Phase 2 (creation). Do NOT overwrite
existing customization without confirming with the user.

### 0.1 Credential and Infrastructure Check

```bash
# Namecheap DNS — can Terraform actually be applied?
cd ~/projects/domains 2>/dev/null || echo "WARN: domains repo not found"

# Check if API key is a placeholder
grep -q "REPLACE_WITH\|your_api_key\|xxx" terraform.tfvars 2>/dev/null \
  && echo "BLOCKED: Namecheap API key is a placeholder — DNS cannot be applied from this session" \
  || echo "OK: API key looks real"

# Firebase project exists? (use fetch tool on the CLI output)
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c firebase projects:list 2>/dev/null | grep -q lars-software \
  && echo "OK: lars-software project exists" \
  || echo "WARN: lars-software project not found"

# Check for existing hosting site collisions
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c firebase hosting:sites:list --project lars-software 2>/dev/null
```

### 0.2 Domain Naming

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

### 0.3 Confirm Domain with User (BEFORE any commit)

**Do not commit anything until the user confirms the subdomain name.** A domain
rename after commit creates stale git history, stale status reports, and
requires touching 8+ files.

Present the proposed subdomain to the user and wait for confirmation:

> "I'll use `{subdomain}.lars.software` as the documentation URL, and `{siteId}`
> as the Firebase hosting site ID. The site ID is immutable. Confirm before I
> proceed?"

### 0.4 Name Collision Check

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

---

## Phase 1: Research the Project

Before writing any website files, understand the actual library:

1. Read the project's `README.md`, `AGENTS.md`, `go.mod`, and `CHANGELOG.md`.
2. Read the Go source to verify API signatures — see the Code Example
   Verification section below.
3. Check for `GOEXPERIMENT=jsonv2` requirements in `go.mod` or `flake.nix`.
   If the library uses `encoding/json/v2`, the README MUST document the
   build constraint. This is the #1 most commonly forgotten requirement.

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

---

## Phase 2: Create the Website

Load the [file manifest](./references/file-manifest.md) to see exactly which
files to copy verbatim, which to customize, and which to write fresh. The
classification eliminates the need to read 60+ reference files via sub-agents.

### 2.1 Choose the Reference Baseline

Two reference repos exist. **Use gogenfilter (`~/projects/gogenfilter/website/`)
as the baseline** — it has CSP hardening, OG images, and a CI/CD pipeline.
go-atomic-write (`~/projects/go-atomic-write/website/`) is the older, simpler
pattern without these features.

| Feature              | go-atomic-write | gogenfilter                                |
| -------------------- | --------------- | ------------------------------------------ |
| CSP headers          | No              | **Yes** (`fix-csp.mjs`)                    |
| OG images            | No              | **Yes** (`astro-og-canvas`)                |
| Two-job CI           | No              | **Yes** (build, then deploy)               |
| Service account auth | No              | **Yes** (`GOOGLE_APPLICATION_CREDENTIALS`) |

**Important:** Components are NOT verbatim copies between repos. They share
the same data-driven architecture (consume data from `src/data/*.ts`) but
differ in markup, styling, and sometimes structure. Copy from gogenfilter as
the starting point, then customize per-project.

### 2.2 Build the Website

1. **Copy verbatim** (~12 files) — see file manifest, "Copy verbatim" rows.
   These need zero changes.

2. **Customize specific fields** (~15 files) — change project name, URLs,
   accent color, sidebar structure. See file manifest, "Customize" rows.

3. **Write fresh** (~20 files) — project-specific content: features, hero code,
   sections, all docs pages, logo, favicon, and section components (CTASection,
   ComparisonSection, etc. — these follow the data-driven pattern from
   gogenfilter but need per-project markup and styling).

### 2.3 Accent Color

Load the [color palette reference](./references/color-palette.md) for
pre-computed CSS token sets for each supported accent color. Do NOT manually
compute `rgba()` values — use the table.

### 2.4 Dependencies

Load the [dependency version reference](./references/dependency-versions.md)
for the verified package.json version matrix. Do NOT guess or bump versions —
use the exact pins that are known to work together.

### 2.5 Favicon and Logo Design

Both use the same design constraints:

- **Dimensions:** 28x28 viewBox
- **Shape:** Rounded rectangle (`rx="6"`) filled with the accent color
- **Foreground:** Simple monogram or icon in `bg-primary` color (`#0a0908`)
- **favicon.svg:** Use the literal hex value of the accent color (not CSS
  variables, since SVGs viewed as tabs don't resolve them). Use the **dark-mode
  `--color-accent` value** from the color palette.
- **Logo.astro:** Use CSS variables (`fill-[var(--color-accent)]`) so it adapts
  to light/dark theme.

### 2.6 MDX Gotcha

Characters `<`, `>`, `<=`, `>=` break Starlight `.mdx` file parsing. In `.mdx`
files, escape them as `&lt;`, `&gt;`, or rephrase the sentence to avoid them.
This does not affect `.md` files.

---

## Phase 3: Build Verification

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

## Phase 4: Go-Live Sequence

Follow this exact sequence. Each step depends on the previous one.

### Step 1: Generate lock files

```bash
cd website
nix shell nixpkgs#nodejs -c npm install   # generates package-lock.json
# Commit package-lock.json for reproducible CI builds
```

### Step 2: Create Firebase hosting site

```bash
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase hosting:sites:create {siteId} --project lars-software
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

# Configure .firebaserc (if using shared project with targets)
# {
#   "projects": { "default": "lars-software" },
#   "targets": {
#     "lars-software": { "hosting": { "{target}": ["{siteId}"] } }
#   }
# }

nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase deploy --only hosting:{target} --project lars-software
```

### Step 4: Verify web.app URL

Use the `fetch` tool to verify `https://{siteId}.web.app` returns HTTP 200.

### Step 5: Add custom domain via REST API

The Firebase CLI has **no command** for adding custom domains. Use the REST
API. The critical details are inline here; load the
[Firebase REST API reference](./references/firebase-rest-api.md) for the full
script templates.

**Endpoint:** `POST https://firebasehosting.googleapis.com/v1beta1/projects/lars-software/sites/{siteId}/customDomains?customDomainId={subdomain}.lars.software`

**Headers (all required):**

- `Authorization: Bearer {ACCESS_TOKEN}`
- `x-goog-user-project: lars-software` — omitting this causes `403 "quota project not set"`
- `Content-Type: application/json`

**Body:** `{}` (empty object — the domain is in the query param)

**Access token:**

```bash
ACCESS_TOKEN=$(nix shell nixpkgs#google-cloud-sdk -c gcloud auth print-access-token)
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

```bash
cd ~/projects/domains
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform fmt
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform validate
```

### Step 8: Apply Terraform (requires valid credentials)

```bash
cd ~/projects/domains

# Verify API key is valid FIRST (see Phase 0.1)
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

## Phase 5: GitHub Metadata

```bash
gh repo edit LarsArtmann/{repo} \
  --description "{one-liner} — {key features}" \
  --homepage "https://{subdomain}.lars.software" \
  --add-topic go,golang,{domain-specific-topics}
```

### Standard topic vocabulary for Go libraries

`go`, `golang`, plus domain-specific topics (e.g. `error-handling`,
`structured-errors`, `code-duplication`, `static-analysis`).

### Badge set (README)

Standard order: Go Reference | Go Report Card | License: MIT | CI status.

### Documentation link bar

Below the tagline in README:

```markdown
**[Documentation](https://{subdomain}.lars.software)** ·
**[pkg.go.dev](https://pkg.go.dev/github.com/LarsArtmann/{repo})** ·
**[Changelog](CHANGELOG.md)**
```

---

## Phase 6: CI/CD Setup (after manual launch is verified)

Only proceed after the custom domain is live and verified.

### Step 1: Create Firebase service account key

```bash
# Find the firebase-admin SDK service account
nix shell nixpkgs#google-cloud-sdk -c \
  gcloud iam service-accounts list --project=lars-software | grep firebase-adminsdk

# Create a key (temp file — clean up after)
nix shell nixpkgs#google-cloud-sdk -c \
  gcloud iam service-accounts keys create /tmp/firebase-ci-key.json \
  --iam-account=firebase-adminsdk-{hash}@lars-software.iam.gserviceaccount.com \
  --project=lars-software

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

1. **After domain confirmed by user** — Phase 0.3 gate passed
2. **After README rewrite** — verified correct against source code
3. **After website builds successfully** — `astro check` = 0 errors,
   `astro build` = success
4. **After Firebase deploy confirmed live** — HTTP 200 on web.app URL
5. **After DNS records staged** — Terraform `fmt` + `validate` pass

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
4. **Vite override conflicts** — Use `astro-og-canvas@^0.12.0` (not 0.11.x)
   with Astro 7. gogenfilter pins `vite: 7.3.2` and works. Either copy
   gogenfilter's overrides verbatim or omit them — do not partially customize.
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
    files. Never commit until the user confirms the domain (Phase 0.3).
14. **Firebase custom domain API** — Use `customDomains` endpoint (not
    `domains`), body is `{}` with domain in query param, `x-goog-user-project`
    header is required. See [firebase-rest-api.md](./references/firebase-rest-api.md).
