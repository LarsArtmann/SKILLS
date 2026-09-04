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

### 19. pnpm/node/firebase not in PATH

**Symptom:** Commands fail with `executable file not found in $PATH`.

**Cause:** In Nix-based environments, these tools are not globally installed.

**Fix:** Always invoke via `nix shell`:

```bash
nix shell nixpkgs#nodejs -c pnpm install
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c firebase deploy --only hosting:{target}
```

## Build Failures

### 1. Vite override conflicts

**Symptom:** Build fails with `rollupOptions.input should not be an html
file when building for SSR` or similar Rollup error.

**Cause:** The `package.json` has `"vite": "7.3.2"` in overrides (copied
from gogenfilter's older lockfile). Astro 7 resolves Vite 8 internally.
Pinning Vite to 7.x causes a fatal Rollup version mismatch.

**Fix:** **Remove `"vite"` from overrides entirely.** Keep only
`brace-expansion`, `devalue`, and `yaml`:

```json
"overrides": {
  "brace-expansion": "5.0.6",
  "devalue": "5.8.1",
  "yaml": "2.8.3"
}
```

**Prevention:** See [dependency-versions.md](./dependency-versions.md) —
the "Vite Override — Critical Fix" section documents this in detail. If
you copy gogenfilter's `package.json`, delete the `"vite"` line before
running `pnpm install`.

### 2. pnpm v11 install scripts blocked

**Symptom:** Build fails with missing `esbuild` or `sharp` binary.

**Cause:** pnpm v11+ blocks install scripts by default.

**Fix:**

```bash
pnpm approve-scripts esbuild sharp
```

**Prevention:** If using bun, this is handled automatically.

### 3. `--legacy-peer-deps` without `.npmrc`

**Symptom:** `pnpm install` fails with `ERESOLVE` for contributors who
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
  pnpm dlx firebase-tools deploy --only hosting:{siteId}
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

**Cause:** `pnpm add firebase-tools` or `bun add firebase-tools` was
used as a debugging step for deploy issues and never removed.

**Fix:** `firebase-tools` should come from the Nix devShell or `pnpm dlx`/
`bunx`. Remove it from `package.json`:

```bash
pnpm remove firebase-tools  # or: bun remove firebase-tools
```

### 13. Missing `package-lock.json` / `flake.lock`

**Symptom:** CI builds fail because lock files are missing.

**Cause:** Generated locally during build but not committed.

**Fix:** Both files must be committed:

- `package-lock.json` — reproducible pnpm installs in CI
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
See SKILL.md Phase 0.3.

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

### 24. pnpm run from wrong working directory

**Symptom:** `pnpm error code ENOENT ... Could not read package.json: Error:
ENOENT: no such file or directory, open '/home/lars/projects/{repo}/package.json'`

**Cause:** Running `pnpm install` or `pnpm run build` from the project root
instead of the `website/` subdirectory.

**Fix:** Always `cd website` before pnpm commands. When using Nix shell
wrappers, set the working directory explicitly:

```bash
nix shell nixpkgs#nodejs -c pnpm install   # run from website/ directory
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

### 27. Fabricated hero code output

**Symptom:** The hero section shows terminal output or code snippets that
don't match the actual tool's real output format.

**Cause:** Writing illustrative hero content from imagination rather than
running the tool and capturing real output.

**Fix:** For CLI tools, run the actual command and capture the output format
before writing the hero section. If the hero content is illustrative (not
real output), label it as such or make it clearly stylized. Verify that
output field names, counts, and formats are plausible against the real tool.

### 28. Auth secret mismatch on workflow upgrade

**Symptom:** First deploy after upgrading the CI workflow fails with auth
error. The old workflow used `FIREBASE_TOKEN`; the new one uses
`FIREBASE_SERVICE_ACCOUNT`.

**Cause:** The `FIREBASE_SERVICE_ACCOUNT` secret was never added to GitHub.
The old `FIREBASE_TOKEN` still exists but the new workflow doesn't reference
it.

**Fix:** Before pushing the new workflow:

1. Check which secrets exist: `gh secret list --repo LarsArtmann/{repo}`
2. If `FIREBASE_SERVICE_ACCOUNT` is missing, create it (see SKILL.md Phase 7)
3. Push the workflow only after the secret exists
4. Optionally remove `FIREBASE_TOKEN` after confirming the new workflow works

### 29. Stale root-level documentation files

**Symptom:** Repository root has HOW_TO_USE.md, USAGE.md, SDK_DESIGN.md,
and other documentation that duplicates or contradicts the new website docs.

**Cause:** Pre-existing documentation from before the website was created.
The README links to some but not all, creating confusion about which is
authoritative.

**Fix:** After the website is live, consolidate root-level docs:

- **Keep:** README.md, CHANGELOG.md, CONTRIBUTING.md, LICENSE
- **Archive or delete:** USAGE.md, HOW_TO_USE.md, PARTS.md, etc. that now
  duplicate website content
- **Link from README:** Any docs that are kept should be linked from the
  README with clear descriptions

### 30. Deploy workflow uses wrong branch name

**Symptom:** Website CI never triggers on push. Workflow file references
`master` but the repo uses `fork`, `main`, or another branch.

**Cause:** The CI workflow template was copied from gogenfilter (which uses
`master`) without updating the branch references.

**Fix:** Update ALL branch references in the workflow YAML:

- `on.push.branches: [master]` → `[your-branch]`
- `on.pull_request.branches: [master]` → `[your-branch]`
- `if: github.ref == 'refs/heads/master'` → `'refs/heads/your-branch'`

### 31. Old static site files not cleaned up

**Symptom:** Repository has both an old `site/` directory (hand-written
HTML) and a new `website/` directory (Astro). Root-level `firebase.json`
and `.firebaserc` conflict with `website/firebase.json`.

**Cause:** New website was created without removing the old static site.

**Fix:** When migrating from a static site to Astro:

1. `trash` (never `rm`) the old `site/` directory
2. `trash` root-level `firebase.json` and `.firebaserc` (now live in `website/`)
3. Remove stale `.gitignore` entries referencing the old site
4. Update the deploy workflow to build from `website/` not `site/`
5. Verify `firebase.json` `public` directory is `dist` (Astro output), not
   `site` (old static files)

### 32. License mismatch across config files

**Symptom:** `package.json` says `"license": "MIT"`, `.goreleaser.yaml`
says `license: MIT`, but `LICENSE` file says "PROPRIETARY". Homebrew, Scoop,
and Nix repositories receive false license metadata.

**Cause:** Assuming MIT without reading the actual LICENSE file. Or a prior
session set MIT in the README template and it propagated.

**Fix:** Before writing badges or package metadata, read the LICENSE file:

```bash
head -3 LICENSE
```

Ensure ALL of these agree:

- `LICENSE` file (source of truth)
- `.goreleaser.yaml` `license:` fields
- `flake.nix` `license = licenses.X`
- `package.json` `"license": "X"`
- README badge `license-{X}-blue.svg`

If the project is proprietary, use `"license": "UNLICENSED"` in
`package.json`, `license = licenses.unfree` in `flake.nix`, and either
omit the license badge or use `license-Proprietary-lightgrey.svg`.

### 33. Lockfile package-manager mismatch

**Symptom:** CI fails with `pnpm install --frozen-lockfile` because `package-lock.json` doesn't
exist. The dev environment used `bun install` which generated `bun.lock`
(which is gitignored).

**Cause:** Using bun locally for speed but not generating the pnpm lockfile
that CI needs.

**Fix:** If CI uses pnpm, run `pnpm install` once to generate
`package-lock.json` and commit it. The `bun.lock` stays gitignored. See
[dependency-versions.md](./dependency-versions.md) Lockfile Decision table.

### 34. Application README claims wrong HTTP framework

**Symptom:** README tech stack table says "Gin" but `go.mod` has no Gin
dependency. The code uses standard `net/http` with Go 1.22+ method routing.

**Cause:** Copying a README template from a project that DID use Gin, or
assuming Go web projects need a framework.

**Fix:** Always verify the HTTP framework in `go.mod`:

```bash
grep 'gin-gonic\|echo\|fiber\|gorilla\|chi' go.mod
# If no results, the project uses net/http
```

Remove framework-specific GitHub topics (e.g. `gin`) and replace with
`net-http` if appropriate. Update the tech stack table to say "Go standard
library `net/http`" instead of the framework name.

## Dependency Pin Fragility (fleet-wide, 2026-09-04)

### 31. astro-og-canvas pulls a broken canvaskit-wasm — pin it DIRECTLY

**Symptom:** Astro prerender crashes on `/og/*.png` with an emscripten
error mentioning `__dirname` (or similar Node/ESM incompatibility) inside
`canvaskit-wasm`. The error text misleadingly blames pnpm hoisting.

**Cause:** `astro-og-canvas@0.13.x` requires `canvaskit-wasm@^0.42.0`
transitively; 0.42.x's emscripten Node build is ESM-incompatible. When a
lockfile regen lets the transitive range win, every `/og` route dies and
the site cannot build.

**Fix:** add `canvaskit-wasm` as a DIRECT dependency with the exact
known-good version (`0.41.1`) in `package.json` — not just a lockfile
entry, which a regen can overwrite:

```json
"canvaskit-wasm": "0.41.1"
```

Re-widen only after upstream fixes the emscripten ESM issue. Applied to
go-output (2026-09-03) and gogenfilter (2026-09-04).

### 32. pnpm v11 traps that break deterministic builds

Three separate traps, each costing real debugging time:

1. **Placeholder `allowBuilds` values silently block build scripts.**
   `esbuild: set this to true or false` (a literal placeholder) is not
   `true` — esbuild's postinstall is skipped and installs warn with
   `[ERR_PNPM_IGNORED_BUILDS]`. Set real booleans in
   `pnpm-workspace.yaml`.
2. **npm-style top-level `overrides` in `package.json` are IGNORED** by
   pnpm. Pin via direct exact versions or `pnpm-workspace.yaml`.
3. **`CI=true` forces `--frozen-lockfile`**, and interactive shells
   without a TTY abort on pnpm's purge prompt — always run website
   installs as `CI=true nix shell nixpkgs#nodejs -c pnpm install
   --frozen-lockfile` (or `--no-frozen-lockfile` when regenerating).
