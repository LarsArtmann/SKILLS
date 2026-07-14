# Common Pitfalls — Website Launch

> Every pitfall below was hit in at least one prior session. Each one cost
> 5-30 minutes of debugging. Following the SKILL.md procedure prevents all
> of them.
>
> **Last updated:** 2026-07-13

## Environment Failures

### 17. `curl` is BANNED in Crush

**Symptom:** Commands fail with `command is not allowed for security reasons`.

**Cause:** Crush bans `curl` (and `wget`, `ssh`, etc.) for security. The
entire skill and all references previously used `curl` for HTTP requests.

**Fix:** Use the `fetch` tool for one-off HTTP requests, or Node.js
`https.request` for scripted API calls:

```bash
nix shell nixpkgs#nodejs -c node -e \
  "require('https').get('https://example.com', r => r.on('data', d => console.log(d.toString())))"
```

### 18. Terraform is unfree (BSL license)

**Symptom:** `nix shell nixpkgs#terraform` fails with "Refusing to evaluate
package 'terraform-1.15.8' because it has an unfree license (bsl11)".

**Cause:** As of Terraform 1.6+, the license changed from MPL to BSL.

**Fix:** Use one of:

```bash
# Option A: Allow unfree
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform plan

# Option B: Use opentofu (open-source fork)
nix run nixpkgs#opentofu -- plan
```

### 19. npm/node/firebase not in PATH

**Symptom:** Commands fail with `executable file not found in $PATH`.

**Cause:** In Nix-based environments, these tools are not globally installed.

**Fix:** Always invoke via `nix shell`:

```bash
nix shell nixpkgs#nodejs -c npm install
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c firebase deploy --only hosting:{target}
```

## Build Failures

### 1. Vite override conflicts

**Symptom:** Build fails with `rollupOptions.input should not be an html
file when building for SSR` or similar Rollup error.

**Cause:** A prior session (go-output) hit this when using
`astro-og-canvas@0.11.1` with Astro 7. The root cause was the og-canvas
version, not Vite pinning per se — `astro-og-canvas@0.12.0` added Astro 7
support.

gogenfilter pins `vite: 7.3.2` in overrides and works fine. The failure
mode is using incompatible version combinations, not the act of pinning
itself.

**Fix:** Use `astro-og-canvas@^0.12.0` (not 0.11.x) with Astro 7. Either
copy gogenfilter's overrides verbatim or omit them entirely — do not
partially customize.

**Prevention:** See [dependency-versions.md](./dependency-versions.md) —
the verified matrices have been tested in production.

### 2. npm v11 install scripts blocked

**Symptom:** Build fails with missing `esbuild` or `sharp` binary.

**Cause:** npm v11+ blocks install scripts by default.

**Fix:**

```bash
npm approve-scripts esbuild sharp
```

**Prevention:** If using bun, this is handled automatically.

### 3. `--legacy-peer-deps` without `.npmrc`

**Symptom:** `npm install` fails with `ERESOLVE` for contributors who
clone the repo.

**Cause:** The lockfile was generated with `--legacy-peer-deps` but no
`.npmrc` documents the requirement.

**Fix:** Create `.npmrc` with `legacy-peer-deps=true`. Better: pin
compatible versions so the flag is unnecessary.

### 4. re2 native module under bun

**Symptom:** `firebase deploy` fails with `re2.node: undefined symbol`.

**Cause:** bun's node shim cannot load the `re2` native module used by
`firebase-tools`.

**Fix:** Use real Node.js from Nix:

```bash
PATH=$(nix build nixpkgs#nodejs --no-link --print-out-paths)/bin:$PATH \
  npx firebase-tools deploy --only hosting:{siteId}
```

## Content Errors

### 5. Broken Go code examples

**Symptom:** The hero code example or docs code blocks don't compile.

**Cause:** Code was written from README memory instead of verified
against the actual Go source.

**Common trap:** `NewGraphNode` returns `*GraphNode` but `AddNode` takes
`GraphNode` (value) — requires dereference: `b.AddNode(*node)`.

**Fix:** For every Go code example, run `grep 'func FunctionName' *.go`
to verify the signature before writing it into documentation.

**Prevention:** See the Code Example Verification section in SKILL.md.

### 6. MDX character escaping

**Symptom:** Build fails on a `.mdx` file with a parser error pointing at
`<`, `>`, `<=`, or `>=`.

**Cause:** These characters are interpreted as JSX tags in `.mdx` files.

**Fix:** Escape as `&lt;`, `&gt;`, or rephrase to avoid the character.
Example: "values less than or equal to 5" instead of "values <= 5".

**Note:** This does NOT affect regular `.md` files — only `.mdx`.

### 7. Missing GOEXPERIMENT in README

**Symptom:** Consumers report build failures when importing the library.

**Cause:** The library uses `encoding/json/v2` which requires
`GOEXPERIMENT=jsonv2` to be set. The README doesn't mention it.

**Fix:** Add a "Prerequisites" section to README:

````markdown
## Prerequisites

This library uses `encoding/json/v2` (Go 1.25+). Set the build flag:

```bash
export GOEXPERIMENT=jsonv2
```
````

````

## Deployment Issues

### 8. Firebase upload endpoint unreachable

**Symptom:** `firebase deploy` fails with
`Failed to make request to https://upload-firebasehosting.googleapis.com/...`
after 6 retries.

**Cause:** The upload host is different from the main Firebase API host.
Firewalls or DNS policies may block it.

**Fix:** Verify reachability before deploying:
```bash
node -e "require('https').get('https://upload-firebasehosting.googleapis.com', r => console.log(r.statusCode))"
````

If unreachable, deploy from a different network.

### 9. Firebase custom domain — missing `site` field

**Symptom:** REST API call to add custom domain returns `400 "Mismatched
sites"`.

**Cause:** The request body omits the `site` field or uses the full
resource path instead of the bare site ID.

**Fix:** See [firebase-rest-api.md](./firebase-rest-api.md) — the `site`
field is required and must be the bare site ID.

### 10. Namecheap credentials discovered at apply time

**Symptom:** `terraform plan` fails with `API Key is invalid (1011102)`.

**Cause:** The API key in `terraform.tfvars` is expired or a placeholder.
This is discovered only after writing all Terraform code.

**Fix:** Run pre-flight checks (see SKILL.md Phase 0) BEFORE writing any
Terraform. If blocked, stage the records and flag as a manual step.

## Process Failures

### 11. No commits at session end

**Symptom:** All work exists only on disk. One unexpected session end and
everything is lost.

**Cause:** Session proceeded through all phases without any commits.

**Fix:** Commit at defined checkpoints (see SKILL.md Commit Discipline).

### 12. Stray dependencies

**Symptom:** `package.json` has `firebase-tools` in devDependencies.

**Cause:** `npm install firebase-tools` or `bun add firebase-tools` was
used as a debugging step for deploy issues and never removed.

**Fix:** `firebase-tools` should come from the Nix devShell or `npx`/
`bunx`. Remove it from `package.json`:

```bash
npm remove firebase-tools  # or: bun remove firebase-tools
```

### 13. Missing `package-lock.json` / `flake.lock`

**Symptom:** CI builds fail because lock files are missing.

**Cause:** Generated locally during build but not committed.

**Fix:** Both files must be committed:

- `package-lock.json` — reproducible npm installs in CI
- `flake.lock` — reproducible Nix builds

### 14. Edit tool collateral damage on Terraform

**Symptom:** `git diff` shows modifications to sibling project DNS records
that were not intended.

**Cause:** The edit tool's `old_string` matched part of an existing
record block, and the replace consumed it.

**Fix:** Include 3-5 lines of unique context around the insertion point.
Run `git diff` after every edit. See [dns-terraform.md](./dns-terraform.md)
for the safe editing pattern.

### 15. Domain naming collision

**Symptom:** User corrects the domain name after the website is already
deployed (e.g. `auditlog.lars.software` should be
`go-workflow-auditlog.lars.software`).

**Cause:** Short name chosen without checking for sibling project
collisions.

**Fix:** Use the full repo slug as the subdomain when any collision risk
exists. Check the user's other repos for similar names before choosing.
See SKILL.md Phase 0.2.

### 16. No visual QA

**Symptom:** Website is deployed but has broken icons, misaligned layout, or
CSS token mismatches that nobody noticed.

**Cause:** Website was built and deployed without ever viewing the output.

**Fix:** Run the Visual QA Gate (see SKILL.md Phase 3) before declaring done.
At minimum, verify key pages return HTTP 200 and CSS variables resolved.

## Process Failures (continued)

### 20. Stale commit message after domain rename

**Symptom:** Git history contains a commit message referencing a domain name
that was subsequently renamed (e.g. "auditlog.lars.software" when it should be
"go-workflow-auditlog.lars.software").

**Cause:** Website was committed before the user confirmed the domain name.
When the domain was corrected, the commit message was not amended.

**Fix:** NEVER commit before Phase 0.3 (domain confirmation). If a rename
happens after commit, amend the commit if not pushed. If pushed, add a
follow-up commit with the correct name. Never force-push a public repo
without explicit user approval.

### 21. Firebase `customDomains` vs `domains` API confusion

**Symptom:** REST API returns `400 "Unknown name 'domainName' at 'domain':
Cannot find field"` or `400 "Unknown name 'domain' at 'domain'"`.

**Cause:** Using the legacy `domains` endpoint instead of the `customDomains`
endpoint. These are different APIs with different request formats.

**Fix:** Always use `POST .../customDomains?customDomainId={domain}` with an
empty body `{}`. Never use `POST .../domains` with a body containing the
domain name. See [firebase-rest-api.md](./firebase-rest-api.md).

### 22. Status report hardcodes unconfirmed domain

**Symptom:** Status report references a domain name that was subsequently
renamed, creating a false historical record.

**Cause:** Writing status reports with hardcoded URLs before the domain is
confirmed live.

**Fix:** In status reports, qualify unconfirmed domains: `{subdomain}.lars.software
(pending DNS propagation)`. Only state the domain as fact after the `fetch`
tool returns HTTP 200 from the custom domain URL.

### 23. Hero code time unit typo

**Symptom:** Hero code snippet shows `WithDebounce(500*time.Second)` instead
of `500*time.Millisecond` — 500 seconds of debounce is obviously wrong but
visually easy to miss.

**Cause:** Writing the hero code example from memory without verifying time
units against the actual API.

**Fix:** Always verify time units in code examples. Add time unit check to
the Phase 1 Code Example Verification checklist:

```
6. Are time units correct? (500*time.Millisecond not 500*time.Second)
```

### 24. npm run from wrong working directory

**Symptom:** `npm error code ENOENT ... Could not read package.json: Error:
ENOENT: no such file or directory, open '/home/lars/projects/{repo}/package.json'`

**Cause:** Running `npm install` or `npm run build` from the project root
instead of the `website/` subdirectory.

**Fix:** Always `cd website` before npm commands. When using Nix shell
wrappers, set the working directory explicitly:

```bash
nix shell nixpkgs#nodejs -c npm install   # run from website/ directory
```

### 25. flake.lock generation fails without git add

**Symptom:** `nix flake lock` fails with "Path 'website/flake.nix' in the
repository is not tracked by Git."

**Cause:** Nix flakes only operate on files tracked by git. A newly created
`flake.nix` must be `git add`ed before `nix flake lock` can work.

**Fix:** Always run `git add website/flake.nix` before `nix flake lock`:

```bash
cd website
git add flake.nix
nix flake lock
```

### 26. ACME TXT record not updated for cert renewal

**Symptom:** Custom domain HTTPS stops working after ~90 days. Firebase
Console shows cert renewal failure.

**Cause:** The ACME TXT challenge token in Terraform was a point-in-time
value for initial provisioning. Firebase issues a different challenge for
renewal, and the static TXT record doesn't match.

**Fix:** Monitor the Firebase Console for cert renewal warnings. If renewal
fails, query the Firebase REST API for the new ACME challenge token and
update the Terraform TXT record. Consider automating this with a monitoring
check. The `web.app` URL continues working during cert renewal failure —
only the custom domain is affected.
