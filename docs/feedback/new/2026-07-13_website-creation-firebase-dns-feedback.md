# Feedback: go-filewatcher Public Presence Overhaul

**Date:** 2026-07-13
**Task:** Create README, documentation website, configure GitHub metadata, Firebase hosting, and DNS for a Go library
**Session Duration:** ~2 hours across multiple continuations
**Outcome:** Website live at `filewatcher.web.app`, custom domain DNS configured but not applied (blocked on credentials)

---

## What I Did

### 1. Researched Two Reference Websites (20+ minutes of sub-agent calls)

Dispatched multiple sub-agents to read ~60 files across `go-atomic-write/website/` and `gogenfilter/website/` to understand the exact Astro + Starlight + Tailwind v4 + Firebase pattern. Read every component, data file, config, style sheet, JS helper, and content doc. This was the single most expensive part of the session.

### 2. Created a 59-File Website from Scratch

Replicated the reference pattern: Astro 7, Starlight, Tailwind v4, Firebase multi-site hosting, Nix flake, dark/light theme, scroll animations, 11 docs pages, landing page with hero/features/comparison/use-cases/CTA sections.

### 3. Rewrote README.md

Transformed from emoji-heavy, table-of-contents-first style to professional centered-header format matching reference repos.

### 4. Updated GitHub Metadata

Description, homepage URL, 14 topics.

### 5. Created Firebase Hosting Site & Deployed

`firebase hosting:sites:create`, build, deploy. 65 files, live.

### 6. Added Custom Domain to Firebase via REST API

Three failed attempts (wrong request body shape) before finding the right payload. Retrieved ACME challenge token.

### 7. Configured Terraform DNS Records

Added CNAME + TXT records to `domains/lars.software.tf`. Validated. Discovered at apply time that the API key is a placeholder.

---

## Where a SKILL.md Would Have Made Me Faster and Better

### A. `website-creation` Skill — THE BIG ONE

**The problem:** I spent 20+ minutes and 3 sub-agent calls reading 60+ files to reverse-engineer a pattern that is identical across at least 3 repos. The entire website structure is deterministic: same stack, same component architecture, same CSS token system, same data-driven section pattern, same Firebase config, same Nix flake. The only variables are:

| Variable          | Example values                                            |
| ----------------- | --------------------------------------------------------- |
| Project name      | `go-atomic-write`, `gogenfilter`, `go-filewatcher`        |
| Accent color      | `#10b981` (emerald), `#22d3ee` (cyan), `#8b5cf6` (violet) |
| Import path       | `github.com/larsartmann/{repo}` or `/v2`                  |
| Hero code snippet | Project-specific Go code                                  |
| Feature list      | 6 cards with icon/title/desc                              |
| Comparison matrix | Rows + columns specific to the project                    |
| Use cases         | 3 cards                                                   |
| Docs pages        | Sidebar structure + .mdx content                          |
| Logo SVG          | Project-specific monogram                                 |
| Domain            | `{name}.lars.software`                                    |

**What the SKILL.md should contain:**

1. **The complete template** — Every file as a parameterized template with `{{VARIABLE}}` placeholders. Not a description of the pattern. The ACTUAL file contents with substitution points. I should be able to run a single command and get a working website scaffold.

2. **The variable list** — A clear table of "these are the N things you must decide, everything else is deterministic."

3. **The accent color palette** — Not just the hex value. The FULL token set for both dark and light mode (bg-primary, bg-card, border, border-accent, text-primary/secondary/muted, accent/accent-hover/accent-dim/accent-light, Starlight sl-color-\* mappings). I had to manually compute light-mode variants for each token. A skill could include a color palette generator or at least document the mapping formula.

4. **The build verification steps** — `npm install`, `npm run build`, expected output (N pages, sitemap, pagefind index). The exact commands to run and what "success" looks like.

5. **The MDX gotchas** — `<`, `>`, `<=`, `>=` break MDX. Characters that need escaping in Starlight `.mdx` files vs regular `.md`. I hit this on the first build and had to fix it. A skill would have warned me upfront.

6. **The Firebase deploy flow** — The exact sequence: `firebase hosting:sites:create`, `.firebaserc` target config, `firebase deploy --only hosting:{target}`. And the Nix command: `nix run .#deploy`.

7. **The icon path catalog** — The `Icon.astro` component has a hardcoded map of SVG paths. Knowing which icons exist (and their exact path data) without reading the file would save time. Or better: a standard icon set that all websites share.

8. **The content docs structure** — Which docs pages are standard (installation, quick-start, api-reference, changelog, contributing, related-tools) and which are project-specific (guides). The frontmatter format. The sidebar config in `astro.config.mjs`.

**Impact:** This skill would have turned a 90-minute website creation into a 15-minute scaffold + customize. And it would have eliminated the MDX bug, the hero code typo, and the manual color palette computation.

---

### B. `firebase-hosting-setup` Skill

**The problem:** I made 4 failed REST API calls trying to add a custom domain to Firebase. The request body shape was non-obvious (`site` must be the bare name `"filewatcher"`, not `"sites/filewatcher"` or omitted). I had to trial-and-error my way to the right payload.

**What the SKILL.md should contain:**

1. **The exact site creation command** — `firebase hosting:sites:create {siteId} --project {projectId}`

2. **The custom domain REST API call** — The exact Node.js script with correct request body. Document that `site` must be the bare site ID (not the full path), and that `domainName` is the full domain.

3. **The ACME challenge extraction** — How to read the response from the domain creation call and extract `_acme-challenge` token for DNS.

4. **The domain status polling** — How to check `CERT_PENDING` → `CERT_OK` transition. What each status means and what action is needed.

5. **The `gcloud auth print-access-token` + `x-goog-user-project` header pattern** — The Firebase REST API requires both the bearer token AND the quota project header. This took me a 403 error to discover.

6. **The Firebase project list** — That all sites live in `lars-software` project. The multi-site pattern with `.firebaserc` targets.

**Impact:** Would have saved 15 minutes of failed API calls and eliminated the trial-and-error.

---

### C. `domains-dns` Skill

**The problem:** I added DNS records to the Terraform config correctly (the pattern was easy to follow from existing examples), but I hit a wall at apply time because:

- The API key was a placeholder
- The client IP wasn't set
- I didn't know the state of the Terraform initialization (no `.terraform/` dir)

**What the SKILL.md should contain:**

1. **The prerequisites checklist** — Before you can `terraform apply`, you need: (a) real API key in `terraform.tfvars`, (b) current public IP whitelisted in Namecheap, (c) `terraform init` run. State this UPFRONT before writing any Terraform code.

2. **The record patterns** — The CNAME + TXT ACME challenge pattern for Firebase-hosted sites. The A-record pattern for apex domains. The module usage pattern (`firebase-hosting` module vs manual records).

3. **The apply workflow** — The exact commands: `export NAMECHEAP_CLIENT_IP=$(curl -s ifconfig.me)`, `nix run nixpkgs#opentofu -- plan`, `nix run nixpkgs#opentofu -- apply`.

4. **The "you can't apply this yourself" early warning** — If credentials are missing, say so BEFORE writing the Terraform code, not after. I should have checked `terraform.tfvars` for placeholder values at the START of the DNS task.

5. **The Namecheap provider quirks** — The `client_ip` auto-detection fails if `api.ipify.org` is blocked. The `MERGE` vs `OVERWRITE` mode implications. The `use_sandbox` flag.

**Impact:** Would have surfaced the credential blocker immediately instead of after writing and validating config. Would have saved 10 minutes of trying to apply with a placeholder key.

---

### D. `github-repo-metadata` Skill

**The problem:** Minor, but I had to look up the `gh repo edit` syntax and the topic list had to be curated manually.

**What the SKILL.md should contain:**

1. **The standard topic vocabulary** — For Go libraries: `go`, `golang`, plus domain-specific topics. The full set of topics used across Lars's repos as a reference list.

2. **The `gh repo edit` command** — `--description`, `--homepage`, `--add-topic`, `--remove-topic`. The fact that topics must be comma-separated with no spaces.

3. **The homepage URL convention** — `{name}.lars.software` for all project websites.

4. **The badge set** — Go Reference, CI, Go Report Card, License. In what order. The exact markdown.

**Impact:** Minor — would have saved 5 minutes of lookup.

---

## Summary: What Made This Session Slower Than Necessary

| Time Sink                                              | Minutes | Skill That Would Fix It  |
| ------------------------------------------------------ | ------- | ------------------------ |
| Reading 60 reference files via sub-agents              | 20      | `website-creation`       |
| Manual color palette computation for violet theme      | 10      | `website-creation`       |
| Fixing MDX `<` parsing error                           | 5       | `website-creation`       |
| Failed Firebase REST API calls (4 attempts)            | 10      | `firebase-hosting-setup` |
| Discovering Namecheap credential blocker at apply time | 10      | `domains-dns`            |
| GitHub metadata lookup                                 | 5       | `github-repo-metadata`   |
| **Total wasted**                                       | **~60** |                          |

A complete `website-creation` skill alone would have recovered 35 of those 60 minutes. That's the highest-value skill to create.

---

## What I Did Well (No Skill Needed)

- Followed the reference pattern exactly — no improvisation on architecture
- Caught and fixed the MDX bug and hero code typo before any commit
- Verified the build at each stage (install, build, deploy, HTTP 200 check)
- Validated Terraform (fmt + validate) before attempting apply
- Wrote comprehensive status reports
- Didn't touch credentials or force anything
- Searched and read before writing in all cases
