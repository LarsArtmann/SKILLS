# Common Pitfalls — Website Launch

> Every pitfall below was hit in at least one prior session. Each one
> cost 5-30 minutes of debugging. Following the SKILL.md procedure
> prevents all of them.

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

**Symptom:** Website is deployed but has broken icons, misaligned layout,
or CSS token mismatches that nobody noticed.

**Cause:** Website was built and deployed without ever viewing the output.

**Fix:** Run the Visual QA Gate (see SKILL.md Phase 3) before declaring
done. At minimum, verify key pages return HTTP 200 and CSS variables
resolved.
