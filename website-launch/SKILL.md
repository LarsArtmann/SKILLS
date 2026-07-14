---
name: website-launch
description: >-
  Launches a public documentation website for a Go library using the
  LarsArtmann Astro + Starlight + Tailwind v4 + Firebase Hosting pattern.
  Use this skill when the user asks to create a project website, build a
  documentation site, deploy to Firebase, configure DNS, set up GitHub
  metadata for a library, rewrite a README for public presence, "make a
  website", "publish docs", "set up Firebase hosting", configure custom
  domains, or any task involving the sibling-project website pattern
  (go-atomic-write, gogenfilter, go-filewatcher, etc.). Also triggers on
  "website launch", "public presence overhaul", "deploy website", or
  "lars.software domain".
---

# Website Launch

Launches a public documentation website for a Go library using the
deterministic Astro + Starlight + Tailwind v4 + Firebase Hosting pattern
shared across all LarsArtmann projects.

This skill encodes lessons from 6+ prior sessions that each wasted 45-90
minutes rediscovering the same pattern, making the same mistakes, and
writing the same feedback. Following this skill turns a 90-minute
multi-agent exploration into a 25-minute scaffold-and-customize task.

---

## Phase 0: Pre-flight Checks (BEFORE writing any files)

Run these checks first. If any fails, surface it to the user immediately
before investing time in website creation.

### 0.1 Credential and Infrastructure Check

```bash
# Namecheap DNS — can Terraform actually be applied?
cd ~/projects/domains 2>/dev/null || echo "WARN: domains repo not found"
grep -q "REPLACE_WITH\|your_api_key\|xxx" terraform.tfvars 2>/dev/null \
  && echo "BLOCKED: Namecheap API key is a placeholder — DNS cannot be applied from this session" \
  || echo "OK: API key looks real"

# Firebase project exists?
firebase projects:list 2>/dev/null | grep -q lars-software \
  && echo "OK: lars-software project exists" \
  || echo "WARN: lars-software project not found"

# Check for existing hosting site collisions
firebase hosting:sites:list --project lars-software 2>/dev/null
```

### 0.2 Domain Naming

Decide the subdomain and site ID **before** creating anything. These are
immutable after creation.

- **Subdomain convention:** Use the full repo slug when there is any risk
  of collision with sibling projects (e.g. `go-workflow-auditlog`, not
  `auditlog` — because `samber-do-auditlog` also exists).
- **Short subdomains** (e.g. `atomicwrite`, `gogenfilter`) are acceptable
  only when no collision risk exists.
- **Check for collisions:** Search the user's repos for similar names.

### 0.3 Name Collision Check

```bash
# Check existing DNS records for the subdomain
grep -r "{subdomain}" ~/projects/domains/lars.software.tf 2>/dev/null \
  && echo "WARN: DNS record already exists for this subdomain"
```

If pre-flight checks reveal blockers (placeholder credentials, IP not
whitelisted), tell the user immediately:

> "DNS records can be staged in Terraform but cannot be applied from this
> session — the Namecheap API key is a placeholder / the current IP is not
> whitelisted. I will prepare everything else and flag this as a manual
> step."

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
source. The #1 mistake across sessions is writing code examples from
memory that don't compile.

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

Load the [file manifest](./references/file-manifest.md) to see exactly
which files to copy verbatim, which to customize, and which to write
fresh. The classification eliminates the need to read 60+ reference files
via sub-agents.

### Decision: Which Reference Baseline?

Two reference repos exist. Choose the more complete one:

| Feature              | go-atomic-write | gogenfilter                                |
| -------------------- | --------------- | ------------------------------------------ |
| CSP headers          | No              | **Yes** (`fix-csp.mjs`)                    |
| OG images            | No              | **Yes** (`astro-og-canvas`)                |
| Two-job CI           | No              | **Yes** (build → deploy)                   |
| Service account auth | No              | **Yes** (`GOOGLE_APPLICATION_CREDENTIALS`) |

**Use gogenfilter as the baseline** — it has CSP, OG images, and the
professional CI pipeline. go-atomic-write is the older, simpler pattern.

### Steps

1. **Copy verbatim** (~12 files) — see file manifest, "Copy verbatim" rows.
   These need zero changes.

2. **Customize specific fields** (~15 files) — change project name, URLs,
   accent color, sidebar structure. See file manifest, "Customize" rows.

3. **Write fresh** (~20 files) — project-specific content: features, hero
   code, sections, all docs pages, logo, favicon.

### Accent Color

Load the [color palette reference](./references/color-palette.md) for
pre-computed CSS token sets for each supported accent color. Do NOT
manually compute `rgba()` values — use the table.

### Dependencies

Load the [dependency version reference](./references/dependency-versions.md)
for the verified package.json version matrix. Do NOT guess or bump
versions — use the exact pins that are known to work together.

### MDX Gotcha

Characters `<`, `>`, `<=`, `>=` break Starlight `.mdx` file parsing. In
`.mdx` files, escape them as `&lt;`, `&gt;`, or rephrase the sentence to
avoid them. This does not affect `.md` files.

---

## Phase 3: Build Verification

```bash
cd website
npm install
npm run build
```

If using npm v11+, native binary packages need approval:

```bash
npm approve-scripts esbuild sharp   # if blocked by allow-scripts
```

Expected output: N pages generated, sitemap, pagefind search index, 0
errors.

Run type checking and HTML validation:

```bash
npx astro check          # 0 errors, 0 warnings
npx html-validate "dist/**/*.html"
```

### Visual QA Gate (mandatory)

Do NOT declare the website done without verifying visual output. At
minimum:

```bash
npm run preview &
sleep 3
# Verify key pages return 200
curl -s -o /dev/null -w "%{http_code}" http://localhost:4321/
curl -s -o /dev/null -w "%{http_code}" http://localhost:4321/getting-started/installation/
# Check that CSS variables resolved (no missing tokens)
curl -s http://localhost:4321/ | grep -o 'color-accent' | head -1
```

If browser access is available, visually check:

- Hero section renders with code mockup
- Feature icons are visible (not broken SVG)
- Dark/light toggle works
- Mobile layout: nav hamburger, grid collapse
- Footer links resolve

---

## Phase 4: Go-Live Sequence

Follow this exact sequence. Each step depends on the previous one.

### Step 1: Generate lock files

```bash
cd website
nix flake lock           # reproducible Nix builds
# package-lock.json is generated by npm install — commit it
```

### Step 2: Create Firebase hosting site

```bash
firebase hosting:sites:create {siteId} --project lars-software
```

Site IDs are **immutable**. Use the full repo slug to avoid collisions.

### Step 3: Deploy

```bash
cd website
firebase deploy --only hosting:{siteId} --project lars-software
```

If using a shared project with targets, configure `.firebaserc`:

```json
{
  "projects": { "default": "lars-software" },
  "targets": {
    "lars-software": { "hosting": { "{target}": ["{siteId}"] } }
  }
}
```

Then: `firebase deploy --only hosting:{target} --project lars-software`

### Step 4: Verify web.app URL

```bash
curl -sI https://{siteId}.web.app | head -1   # expect HTTP 200 or redirect
```

### Step 5: Add custom domain

The Firebase CLI has **no command** for adding custom domains. Use the
REST API. Load the [Firebase REST API reference](./references/firebase-rest-api.md)
for the exact request format and known gotchas.

### Step 6: Extract ACME challenge

The domain creation response includes the SSL cert verification token.
This maps to a DNS TXT record. See the REST API reference for the exact
response field path.

### Step 7: Stage DNS records in Terraform

Load the [DNS Terraform reference](./references/dns-terraform.md) for the
exact CNAME + TXT record templates.

DNS records for `{name}.lars.software` go in `domains/lars.software.tf`.
Records for `{name}.larsartmann.com` go in `domains/larsartmann.com.tf`.

```bash
cd ~/projects/domains
terraform fmt
terraform validate
```

### Step 8: Apply Terraform (requires credentials)

```bash
# Only if pre-flight checks passed (real API key + whitelisted IP)
export NAMECHEAP_CLIENT_IP=$(curl -s ifconfig.me)
terraform plan
terraform apply
```

If credentials are blocked, stage the records and flag as a manual step.

### Step 9: Wait for SSL provisioning

Poll the domain status until `certStatus` transitions to `CERT_ACTIVE`:

```bash
# See Firebase REST API reference for the polling command
```

Lifecycle: `CERT_PENDING` + `DNS_MISSING` → `CERT_PENDING` + `DNS_MATCH`
→ `CERT_ACTIVE` + `DNS_MATCH`

### Step 10: Set CI secret for auto-deploy

```bash
# Find the firebase-admin SDK service account
gcloud iam service-accounts list --project=lars-software | grep firebase-adminsdk

# Create a key (temp file — clean up after)
gcloud iam service-accounts keys create /tmp/firebase-ci-key.json \
  --iam-account=firebase-adminsdk-{HASH}@lars-software.iam.gserviceaccount.com \
  --project=lars-software

# Set GitHub secret
gh secret set FIREBASE_SERVICE_ACCOUNT --repo LarsArtmann/{repo} \
  --body "$(cat /tmp/firebase-ci-key.json)"

# Verify
gh secret list --repo LarsArtmann/{repo}

# Clean up
rm /tmp/firebase-ci-key.json
```

### Step 11: Verify custom domain

```bash
curl -sI https://{subdomain}.lars.software | head -1   # expect HTTP 200
```

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

## Commit Discipline

Commit at these checkpoints — never leave a session with uncommitted work:

1. **After README rewrite** — verified correct against source code
2. **After website builds successfully** — `astro check` = 0 errors,
   `astro build` = success
3. **After Firebase deploy confirmed live** — HTTP 200 on web.app URL
4. **After DNS records staged** — Terraform `fmt` + `validate` pass

### Two repos awareness

When working on a project website with DNS, there are always TWO repos to
commit:

- The project repo (website files, README, CI workflow)
- The domains repo (DNS records)

Run `git status` in BOTH before declaring done.

### Pre-commit check for domains repo

Before editing the domains repo, run `git status`. If there are
pre-existing uncommitted changes from other sessions, flag them to the
user before layering your changes on top.

---

## Common Pitfalls

Load the [common pitfalls reference](./references/common-pitfalls.md) for
the full list. The most critical:

1. **Vite override** — Do NOT pin `vite` in package.json overrides. Astro
   manages its own Vite version. Pinning causes build failures.
2. **`--legacy-peer-deps` trap** — If you must use it, create `.npmrc`
   with `legacy-peer-deps=true`. Otherwise the lockfile is
   non-reproducible for other contributors.
3. **MDX character escaping** — `<`, `>`, `<=`, `>=` break `.mdx` files.
4. **`package-lock.json`** — Must be committed for reproducible CI builds.
5. **`GOEXPERIMENT=jsonv2`** — If the library uses `encoding/json/v2`,
   document the build constraint in README.
6. **`flake.lock`** — Must be generated (`nix flake lock`) and committed.
7. **Stray dependencies** — Never `npm install` / `bun add` a package as
   a debugging step without removing it if it doesn't solve the problem.
   Use `npx` / `bunx` for one-off commands.
8. **Firebase upload endpoint** — `upload-firebasehosting.googleapis.com`
   is a different host than the main API. If unreachable (firewall, DNS),
   deploys fail. Verify reachability before attempting deploy.
9. **bun vs Node.js for deploy** — `firebase deploy` uses the `re2`
   native module which fails under bun's node shim. Use a real Node.js
   from Nix: `PATH=$(nix build nixpkgs#nodejs --no-link --print-out-paths)/bin:$PATH`
10. **Edit tool collateral damage** — When editing Terraform files with
    find-replace tools, include enough unique context and run `git diff`
    after every edit to verify only intended lines changed.
