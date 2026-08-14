# Feedback: "Public Website Launch" Skill Gap — go-output Session

**Date:** 2026-07-13
**Project:** go-output
**Session goal:** Make README, public wiki website, and GitHub metadata superb. Then configure DNS (Terraform) and Firebase hosting.

---

## What I Did

Over this session, I:

1. Studied two sibling projects (`go-atomic-write`, `gogenfilter`) for their website patterns, design systems, and component architecture
2. Built a complete Astro 6.x + Starlight + Tailwind v4 website from scratch (57 source files: components, data, docs, layouts, styles, public assets, config)
3. Wrote 14 documentation pages (installation, quick-start, 7 guides, format matrix, changelog, contributing, related-tools)
4. Updated GitHub description, topics (curated to 20/20), and homepage URL
5. Created Firebase hosting site `go-output` in project `lars-software`
6. Registered custom domain `go-output.lars.software` via Firebase Hosting REST API
7. Staged DNS records (CNAME + ACME TXT) in the Terraform `domains` repo
8. Attempted Firebase deploy 4+ times — all failed (upload endpoint unreachable)

---

## Where a SKILL.md Would Have Helped

### 1. The Sibling-Project Dependency Version Matrix

**What happened:** I copied the `package.json` from `gogenfilter/website/` and bumped versions optimistically: `astro@^7.0.3` and `@astrojs/starlight@^0.41.1`. The build failed with a cryptic Vite error: `rollupOptions.input should not be an html file when building for SSR`. It took 5+ failed build attempts, diffing lockfiles, and a clean build of the gogenfilter website (which succeeded) to discover that Astro 7.x has a breaking change incompatible with the `astro-og-canvas` plugin. The sibling project uses Astro 6.3.1 + Starlight 0.39.2 — versions that work.

**What a skill could have said:**

> "Pin these exact versions (verified working as of 2026-07-13):
>
> ```
> "astro": "^6.3.0"
> "@astrojs/starlight": "^0.39.2"
> "@astrojs/sitemap": "^3.7.3"
> "astro-og-canvas": "^0.11.1"
> "tailwindcss": "^4.3.1"
> "@tailwindcss/vite": "^4.3.1"
> ```
>
> Do NOT upgrade Astro to 7.x — `astro-og-canvas` is incompatible and the build fails with a non-obvious Rollup error."

**Impact:** 30+ minutes of debugging, 4 failed builds, a corrupted `package-lock.json` generated with `--legacy-peer-deps`, and a `.npmrc` that's missing.

### 2. The `--legacy-peer-deps` Trap

**What happened:** When `astro-og-canvas@0.11.1` conflicted with `astro@7.x` (peer dep requires `astro@^5.0.0 || ^6.0.0-alpha`), I used `pnpm install --legacy-peer-deps` as a workaround. This generated a lockfile that silently works locally but will fail in CI or for other contributors who run plain `pnpm install`. No `.npmrc` was created to document the requirement.

**What a skill could have said:**

> "If you must use `--legacy-peer-deps`, create a `.npmrc` file with `legacy-peer-deps=true` in the same commit. Otherwise the lockfile is non-reproducible. Better: pin compatible versions (see version matrix above) so `--legacy-peer-deps` is unnecessary."

**Impact:** Anyone cloning the repo and running `pnpm install` will get ERESOLVE errors. The build works only because the lockfile was generated with the flag.

### 3. The Pointer Dereference Bug Pattern

**What happened:** I wrote Go code examples for the website based on the README and AGENTS.md, not from verifying against the actual Go source. The critical API:

```go
func NewGraphNode(id, label string) *GraphNode   // returns POINTER
func (m *GraphBuilder) AddNode(node GraphNode)    // takes VALUE
```

My hero code example wrote `b.AddNode(output.NewGraphNode("compile", "Compile"))` — missing the `*` dereference. This propagated into 5+ files (hero-code.ts, HeroSection.astro, quick-start.mdx, cqrs.mdx, trees-and-graphs.mdx). Ironically, the README itself already had the correct `*output.NewGraphNode(...)` syntax.

**What a skill could have said:**

> "Before writing any Go code example in documentation, run `grep -A2 'func New' <file>.go` to verify the return type and parameter types. Pointer-receiver vs value-receiver mismatches are the #1 source of broken code examples. Specifically for go-output: `NewGraphNode` and `NewGraphEdge` return pointers but `AddNode`/`AddEdge` take values — always dereference with `*`."

**Impact:** The most prominent code example on the website (the hero section) doesn't compile. Anyone copy-pasting it gets a type error on their first interaction with the library.

### 4. The Edit Tool Collateral Damage Pattern

**What happened:** When adding go-output DNS records to `lars.software.tf`, I used the `edit` tool with `old_string` matching the `auditlog` CNAME block as the insertion anchor. The find-replace consumed the auditlog block and replaced it with go-output + auditlog combined — but with subtle changes to the auditlog records (different hostname, different ACME token). The `git diff` revealed the collateral damage only in the status report review.

**What a skill could have said:**

> "When editing Terraform files with find-replace tools, ALWAYS include enough unique context to make the match unambiguous, and ALWAYS run `git diff` after every edit to verify only the intended lines changed. Terraform DNS records are infrastructure — accidental modification of a sibling project's records can take down a live website."

**Impact:** The terraform diff shows deleted `auditlog` CNAME and modified ACME challenge. If applied, `auditlog.lars.software` could stop resolving. Required a follow-up fix and introduced uncertainty about whether other records were silently modified.

### 5. Firebase CLI Custom Domain Gap

**What happened:** The Firebase CLI (v15.22.4) has `hosting:sites:create` and `hosting:sites:list` but NO command for adding custom domains. I discovered this after trying `firebase hosting:domains:add` (doesn't exist). I then had to:

1. Discover the correct REST API endpoint via the discovery document
2. Extract the OAuth token from `~/.config/configstore/firebase-tools.json`
3. Write a Node.js HTTPS script to call the API
4. Figure out the correct request body format (`{domainName: "...", site: "go-output"}` — the `site` field must be the short site ID, not the full path)

**What a skill could have said:**

> "Firebase CLI cannot add custom domains. Use the REST API:
>
> ```
> # Extract token from Firebase CLI's stored credentials:
> TOKEN=$(node -e "console.log(require('~/.config/configstore/firebase-tools.json').tokens.access_token)")
>
> # Add custom domain (site field = short site ID, NOT full path):
> POST https://firebasehosting.googleapis.com/v1beta1/projects/{PROJECT}/sites/{SITE}/domains
> Body: {"domainName": "go-output.lars.software", "site": "go-output"}
> Authorization: Bearer $TOKEN
>
> # Check status (returns ACME challenge + CNAME target):
> GET .../domains
> ```
>
> The `site` field in the request body must be the short site ID (`go-output`), not the full resource path (`projects/lars-software/sites/go-output`). Using the full path causes a 400 'Mismatched sites' error."

**Impact:** 15+ minutes of trial and error with wrong request body formats (tried `{domainName}` only → 400 "Mismatched sites", tried `{site: "projects/..."}` → 400, tried `{name: "..."}` → 400 "unknown field"). The discovery doc was 100KB+ and I had to parse it to find the correct schema.

### 6. The Firebase Upload Endpoint Network Failure

**What happened:** After building the website successfully, `firebase deploy --only hosting` consistently failed on the file upload phase. The error: `Failed to make request to https://upload-firebasehosting.googleapis.com/upload/sites/go-output/versions/{id}/files/{hash}`. Each attempt retried 6 times internally, then failed. I retried the deploy 4+ times, each taking 2-3 minutes before failing.

**What a skill could have said:**

> "Firebase Hosting deploys upload files to `upload-firebasehosting.googleapis.com` — a different host than the main Firebase API. If this host is unreachable (firewall, DNS, network policy), deploys will fail with 'retries exhausted'. Before attempting deploy, verify reachability: `node -e \"require('https').get('https://upload-firebasehosting.googleapis.com', r => console.log(r.statusCode))\"`. If unreachable, deploy from a different network or use `firebase deploy --only hosting --debug` to diagnose."

**Impact:** 20+ minutes of repeated failed deploys before I gave up. No way to know if this is a temporary outage or a permanent network restriction.

### 7. The pnpm Script Approval Pattern

**What happened:** pnpm v11+ with `allow-scripts` requires explicit approval for packages with install scripts (`esbuild`, `sharp`). After `pnpm install`, the build silently failed because esbuild's binary wasn't installed. I had to run `pnpm approve-scripts esbuild` and `pnpm approve-scripts sharp` separately, then reinstall.

**What a skill could have said:**

> "pnpm v11+ blocks install scripts by default. After `pnpm install`, run `pnpm approve-scripts --allow-scripts-pending` to approve esbuild and sharp. Without this, the Astro build fails with missing native binaries."

**Impact:** 2 failed builds + 2 extra install cycles before discovering the approval requirement.

### 8. The Website Content Depth vs Accuracy Tradeoff

**What happened:** I wrote 14 documentation pages with substantial Go code examples. The volume was good, but I prioritized breadth over verification. I wrote code from memory/README rather than checking against actual API signatures. The result: the most visible example (hero code) has a compile error.

**What a skill could have said:**

> "For every Go code example in documentation, create a verification checklist:
>
> 1. Does the function exist? (`grep 'func FunctionName' *.go`)
> 2. Does the return type match the usage? (pointer vs value)
> 3. Does the parameter type match the argument? (struct vs \*struct)
> 4. Does the method receiver match the call? (value vs pointer receiver)
> 5. Run `go vet` or compile a minimal test file if possible
>    Accuracy > breadth. One broken hero example damages trust more than 10 missing doc pages."

**Impact:** The hero code — the first thing every visitor sees — is broken. This is the worst possible place for a bug.

### 9. The `astro-og-canvas` Peer Dependency Conflict Pattern

**What happened:** The OG image generation plugin (`astro-og-canvas`) requires `sharp` for image processing. Sharp has native bindings that need `node install.js` to run. pnpm v11 blocks this by default. Additionally, `astro-og-canvas@0.12.0` requires `astro@^5 || ^6`, but I had `astro@7.x`. The interaction between these three issues (Astro version, peer dep, install scripts) took multiple debugging cycles to untangle.

**What a skill could have said:**

> "The OG image pipeline has three known friction points:
>
> 1. Version pinning (see matrix above)
> 2. pnpm script approval (`sharp` needs `pnpm approve-scripts`)
> 3. Native binary availability (`sharp` needs platform-specific binaries)
>    If OG images fail, check all three. If you don't need OG images, remove `astro-og-canvas` from dependencies and delete `src/pages/og/[...slug].ts`."

**Impact:** Multiple failed builds before all three issues were resolved.

---

## Summary: What Skill(s) Would Cover This?

The existing feedback file (`2026-07-13_website-launch-firebase-hosting-feedback.md`) already proposes a `lars-software-website-launch` skill covering the sibling-project copy pattern, domain naming, Firebase REST API, and Namecheap credentials. My session confirms all of those gaps and adds:

### Additional items the skill must encode:

1. **The verified dependency version matrix** — exact Astro/Starlight/og-canvas versions that work together. No guessing, no bumping.
2. **The `--legacy-peer-deps` + `.npmrc` requirement** — if peer deps conflict, either fix versions or document the flag
3. **The pnpm v11 script approval pattern** — `pnpm approve-scripts` for esbuild/sharp
4. **The Go code example verification checklist** — pointer/value, receiver type, return type, parameter type
5. **The Terraform edit safety pattern** — `git diff` after EVERY edit to verify no collateral damage
6. **The Firebase upload endpoint pre-check** — verify `upload-firebasehosting.googleapis.com` reachability before attempting deploy
7. **The REST API `site` field gotcha** — short site ID, not full resource path
8. **The "accuracy > breadth" principle** — verify the hero example before writing 14 doc pages

### What I'd name the skill:

**`lars-software-website-launch`** — same as the existing feedback suggests. It should be one comprehensive skill with a reference file for the Firebase REST API snippets and a checklist file for the Go code verification pattern.
