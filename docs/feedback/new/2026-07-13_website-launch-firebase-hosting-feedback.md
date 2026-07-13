# Feedback: "Public Website Launch" Skill Gap

**Date:** 2026-07-13
**Project:** go-workflow-auditlog
**Session goal:** Create a public documentation website (Astro + Starlight + Firebase Hosting), wire DNS via Terraform, improve README, and set GitHub repo metadata.

---

## What I Did

Over two sessions, I:

1. Studied two sibling projects (`go-atomic-write`, `gogenfilter`) for their website patterns, design systems, and component architecture
2. Built a complete Astro 7 + Starlight + Tailwind v4 website from scratch (45 source files: components, data, docs, layouts, styles, public assets, config)
3. Wrote 10 documentation pages (installation, quick-start, API reference, 4 guides, changelog, contributing, related-tools)
4. Improved the README (added "Why?" section, docs links, updated coverage)
5. Set GitHub description, topics, and homepage URL
6. Created a Firebase hosting site, deployed the website
7. Added a custom domain via Firebase REST API
8. Added DNS CNAME + ACME TXT records to the Terraform `domains` project
9. Discovered the domain should be `go-workflow-auditlog.lars.software` (not `auditlog.lars.software`), renamed everything, redeployed

---

## Where a SKILL.md Would Have Helped

### 1. The Domain Naming Convention

**What happened:** I named the custom domain `auditlog.lars.software`, mirroring the short-name pattern of `atomicwrite.lars.software` and `gogenfilter.lars.software`. The user corrected me: it must be `go-workflow-auditlog.lars.software` because there's a sibling project `samber-do-auditlog` that also needs an `auditlog` subdomain.

**What a skill could have said:**

> "Domain naming: Use the full repo name slug (e.g. `go-workflow-auditlog.lars.software`), not a shortened version, when there's a risk of collision with sibling projects. Check the user's other repos for name collisions before choosing a subdomain."

**Impact:** Cost a full rename cycle — delete the Firebase custom domain, recreate it, re-edit Terraform, rebuild website config, redeploy, update GitHub homepage, update README. ~15 minutes of rework that a single line in a skill would have prevented.

### 2. Firebase Hosting Site ID vs Custom Domain

**What happened:** I named the Firebase hosting site `auditlog` (short, matching `atomicwrite` / `gogenfilter`). The site ID cannot be renamed. The custom domain is `go-workflow-auditlog.lars.software`. This creates a mismatch: the CNAME points to `auditlog.web.app`, the `.firebaserc` target is `auditlog`, but the public-facing domain is `go-workflow-auditlog.lars.software`.

**What a skill could have said:**

> "Firebase hosting site IDs are immutable. Choose the site ID to match the repo slug (e.g. `go-workflow-auditlog`, not `auditlog`), even if sibling projects used shorter names. The site ID becomes the default URL (`go-workflow-auditlog.web.app`) and appears in the CNAME target."

**Impact:** Permanent minor confusion. Not worth recreating the site, but it's a scar that a skill would have avoided.

### 3. The Namecheap API Key Blocker Pattern

**What happened:** I wrote the Terraform DNS records correctly, ran `terraform validate` (passed), then tried `terraform plan` — it failed with "API Key is invalid (1011102)". The key in `terraform.tfvars` was expired. I had no way to know this until I tried to apply.

**What a skill could have said:**

> "Before planning Terraform changes, verify the Namecheap API key is valid: `terraform plan -target=namecheap_domain_records.<domain>` on a no-op change first. If it fails with 1011102, tell the user immediately that the key is expired and the DNS changes cannot be applied until they refresh it. Do NOT spend time on the Firebase custom domain until DNS is confirmed applicable."

**Impact:** I proceeded to set up the Firebase custom domain and SSL cert verification before discovering DNS couldn't be applied. The custom domain is now in `OWNERSHIP_MISSING` state, waiting indefinitely. If I'd known the API key pattern, I would have flagged the blocker earlier and avoided creating Firebase resources that can't complete.

### 4. The Sibling-Project Copy Pattern: What to Copy vs What to Customize

**What happened:** I read ~15 files from `go-atomic-write/website/` and `gogenfilter/website/` to understand the pattern. This took many tool calls and context. I copied the shared infrastructure (JS utilities, layout structure, Section/Card/Icon components) faithfully, but had to make many small decisions about what to customize (accent color, logo, features data, hero code, sections data, icons).

**What a skill could have said:**

> "When creating a new project website from the sibling pattern:
>
> - **Copy verbatim:** `theme-init.js`, `animations.js`, `header.js`, `copy-code.js`, `Section.astro`, `SectionHeader.astro`, `Card.astro`, `Header.astro`, `Footer.astro`, `LandingLayout.astro`, `Sections.astro`, `content.config.ts`, `tsconfig.json`, `.htmlvalidate.json`, `.node-version`, `.gitignore`, `firebase.json`, `flake.nix`
> - **Customize data only:** `config.ts` (site name, URLs, GitHub repo), `types.ts` (icon names), `features.ts`, `hero-code.ts`, `sections.ts`
> - **Customize design tokens:** `global.css` (accent color + related tokens), `starlight.css` (Starlight color overrides), `Logo.astro`, `favicon.svg`
> - **Write fresh content:** `index.astro` (page assembly), all `.mdx` doc pages
> - **Update Astro config:** `astro.config.mjs` (site URL, sidebar structure, social links, Starlight title)
>   This gives you ~30 files to copy verbatim, ~6 files to customize data, ~4 files to customize design, and ~12 files to write fresh."

**Impact:** Would have saved 10+ tool calls reading sibling files and eliminated uncertainty about whether I was following the pattern correctly.

### 5. The Commit-Before-Rename Anti-Pattern

**What happened:** A pre-commit hook or prior action committed the website while the domain was still `auditlog.lars.software`. Then the user corrected the domain name. Now there's a commit with the wrong domain in its message, and 5 uncommitted files with the fix.

**What a skill could have said:**

> "Do not commit the website until: (1) the domain name is confirmed with the user, (2) the Firebase hosting site is created, (3) the custom domain is added, (4) the DNS records are staged in Terraform. The domain name touches 8+ files and rewriting commit history on a public repo is costly."

**Impact:** Stale commit message in git history, stale status report, and the user has to decide whether to amend or leave it.

### 6. Firebase REST API for Custom Domains

**What happened:** The Firebase CLI has no command for adding custom domains (`firebase hosting:domains:create` doesn't exist). I had to discover this, research the REST API via `agentic_fetch`, get a `gcloud` access token, and make raw HTTPS calls with Node.js scripts. The API also required an `x-goog-user-project` header that wasn't documented in the first result.

**What a skill could have said:**

> "Firebase custom domains cannot be added via CLI. Use the REST API:
>
> ```bash
> ACCESS_TOKEN=$(gcloud auth print-access-token)
> # Create:
> # POST https://firebasehosting.googleapis.com/v1beta1/projects/{PROJECT}/sites/{SITE}/customDomains?customDomainId={DOMAIN}
> # Header: x-goog-user-project: {PROJECT} (REQUIRED — quota project)
> # Body: {}
> # Delete:
> # DELETE .../customDomains/{DOMAIN}
> # List + check status:
> # GET .../customDomains
> ```
>
> The response includes `requiredDnsUpdates` (CNAME target) and `cert.verification.dns` (ACME TXT record for SSL)."

**Impact:** Cost ~15 minutes of trial-and-error with wrong API formats (tried `customDomain` field, tried `domain` field, got 400s, had to research the correct endpoint path and the quota project header).

### 7. ACME Challenge TXT Records Are Dynamic

**What happened:** Firebase returned an ACME TXT record value for SSL cert verification. I hardcoded it into Terraform. But ACME challenges can rotate — once the cert is provisioned, Firebase may issue a different challenge for renewal.

**What a skill could have said:**

> "ACME TXT records from Firebase are point-in-time values for initial cert provisioning. They work for the first issuance, but monitor the Firebase Console for renewal challenges. Consider whether the TXT record belongs in Terraform (permanent) or should be managed out-of-band (ephemeral)."

**Impact:** Potential future breakage if the ACME challenge rotates and the Terraform-managed TXT becomes stale.

### 8. Status Report Quality

**What happened:** The user asked for brutally honest status reports twice. Both times I produced good reports, but the first one had the wrong domain name throughout (because it was written before the rename), making it immediately stale.

**What a skill could have said:**

> "When writing status reports, avoid hardcoding URLs/domain names that haven't been confirmed live. Use placeholders like `[DOMAIN]` or qualify with '(pending DNS propagation)'."

---

## Summary: What Skill(s) Would Cover This?

A single skill could cover this entire workflow. Suggested name: **`lars-software-website-launch`** or **`firebase-hosting-website`**.

It should encode:

1. **The sibling-project website pattern** — exact file copy/customize/fresh-write lists
2. **Domain naming convention** — full repo slug, check for collisions
3. **Firebase hosting lifecycle** — create site → deploy → add custom domain via REST API → stage DNS in Terraform
4. **The Namecheap API key pre-check** — verify before planning
5. **Firebase REST API snippets** — custom domain create/delete/list with the `x-goog-user-project` header
6. **ACME TXT record guidance** — ephemeral vs permanent
7. **Commit ordering** — don't commit until domain is confirmed and infrastructure is staged
8. **Git history hygiene** — amend stale messages before pushing, never force-push public repos without asking
