# Go-Live Runbook

> The exact deployment sequence for launching a website on Firebase Hosting
> with a custom domain. Each step depends on the previous one. Load this
> reference when executing Phase 5 of the website-launch skill.

## Step 1: Generate lock files

```bash
cd website
git add flake.nix   # nix flake lock requires the file to be tracked by git
nix shell nixpkgs#nodejs -c npm install   # generates package-lock.json
nix flake lock                                # generates flake.lock
# Commit package-lock.json AND flake.lock for reproducible CI builds
```

## Step 2: Create Firebase hosting site

```bash
nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase hosting:sites:create {siteId} --project {firebaseProject}
```

Site IDs are **immutable**. Use the full repo slug to avoid collisions.

## Step 3: Deploy

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

# Shared project (.firebaserc with targets):
# {
#   "projects": { "default": "lars-software" },
#   "targets": {
#     "lars-software": { "hosting": { "{target}": ["{siteId}"] } }
#   }
# }
# Deploy: firebase deploy --only hosting:{target} --project lars-software

# Standalone project (.firebaserc without targets):
# { "projects": { "default": "{projectId}" } }
# Deploy: firebase deploy --only hosting --project {projectId}

nix shell nixpkgs#nodejs nixpkgs#firebase-tools -c \
  firebase deploy --only hosting:{targetOrBlank} --project {firebaseProject}
```

## Step 4: Verify web.app URL

Use the `fetch` tool to verify `https://{siteId}.web.app` returns HTTP 200.

## Step 5: Add custom domain via REST API

The Firebase CLI has **no command** for adding custom domains. Use the REST
API. Load the [Firebase REST API reference](./firebase-rest-api.md) for the
full script templates.

**Endpoint:** `POST https://firebasehosting.googleapis.com/v1beta1/projects/{firebaseProject}/sites/{siteId}/customDomains?customDomainId={subdomain}.lars.software`

**Headers (all required):**

- `Authorization: Bearer {ACCESS_TOKEN}`
- `x-goog-user-project: {firebaseProject}` — omitting this causes `403 "quota project not set"`
- `Content-Type: application/json`

**Body:** `{}` (empty object — the domain is in the query param)

**Access token:**

```bash
ACCESS_TOKEN=$(nix shell nixpkgs#google-cloud-sdk -c \
  gcloud auth print-access-token --project={firebaseProject})
```

## Step 6: Extract ACME challenge

The domain creation response (or the list response) includes the SSL cert
verification challenge under `requiredDnsUpdates.desired[0].records` (CNAME)
and `cert.verification.dns.desired[0].records` (ACME TXT).

Map to DNS:

- CNAME record: hostname = `{subdomain}`, target = `{siteId}.web.app.`
- TXT record: hostname = `_acme-challenge.{subdomain}`, value = ACME token

## Step 7: Stage DNS records in Terraform

Load the [DNS Terraform reference](./dns-terraform.md) for the exact
CNAME + TXT record templates.

DNS records for `{name}.lars.software` go in `domains/lars.software.tf`.
Records for `{name}.larsartmann.com` go in `domains/larsartmann.com.tf`.

**Placement:** Insert new records BEFORE the closing `}` of the
`resource "namecheap_domain_records"` block. Place them after the last
existing record, grouped with a comment header matching the existing
pattern (e.g. `# {project} website (Firebase Hosting)`).

```bash
cd ~/projects/domains
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform fmt
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform validate
```

## Step 8: Apply Terraform (requires valid credentials)

```bash
cd ~/projects/domains

# Verify API key is valid FIRST (see Phase 0.2)
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c \
  terraform plan -target=namecheap_domain_records.lars_software

# If plan succeeds, apply
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c \
  terraform apply -target=namecheap_domain_records.lars_software
```

If credentials are blocked (expired API key, IP not whitelisted), stage the
records and flag as a manual step for the user.

## Step 9: Wait for SSL provisioning

Poll the domain status using the Firebase REST API (see reference for the GET
script). Lifecycle: `OWNERSHIP_MISSING` -> `CERT_VALIDATING` ->
`CERT_ACTIVE`.

This can take 10-60 minutes after DNS propagates. Firebase auto-provisions the
SSL certificate once it can verify the ACME TXT record.

## Step 10: Verify custom domain

Use the `fetch` tool to verify `https://{subdomain}.lars.software` returns HTTP 200.
