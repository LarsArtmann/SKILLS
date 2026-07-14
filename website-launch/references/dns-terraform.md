# DNS Terraform — Namecheap Record Templates

> DNS records for LarsArtmann domains are managed via Terraform with the
> Namecheap provider. This reference documents the exact record templates and
> the apply workflow.
>
> **Last verified:** 2026-07-13

## File Location Convention

| Domain                   | File                         |
| ------------------------ | ---------------------------- |
| `{name}.lars.software`   | `domains/lars.software.tf`   |
| `{name}.larsartmann.com` | `domains/larsartmann.com.tf` |

## Record Templates

### CNAME for Firebase-hosted subdomain

```hcl
# {project} website (Firebase Hosting)
record {
  address  = "{siteId}.web.app."
  hostname = "{subdomain}"
  mx_pref  = 0
  ttl      = local.default_ttl
  type     = "CNAME"
}
```

### ACME TXT for Firebase SSL cert verification

The `{acme-token}` value comes from the Firebase Hosting REST API. **See
[firebase-rest-api.md](./firebase-rest-api.md) "Extract ACME Challenge"
section** for the exact API call and response field path
(`cert.verification.dns.desired[0].records[0].rdata`).

```hcl
# Firebase SSL cert verification for {subdomain}.lars.software
record {
  address  = "{acme-token}"
  hostname = "_acme-challenge.{subdomain}"
  mx_pref  = 0
  ttl      = local.default_ttl
  type     = "TXT"
}
```

## Two DNS Patterns

### Subdomains (CNAME)

For `{subdomain}.lars.software`, use manual CNAME records pointing to the
Firebase hosting site's `web.app` domain. This is the standard pattern for all
project websites.

### Apex domain (firebase-hosting module)

For the apex domain (`lars.software` itself), use the `firebase-hosting`
Terraform module. See existing records in `lars.software.tf` for the module
usage pattern.

## Record Placement in .tf Files

Insert new records BEFORE the closing `}` of the
`resource "namecheap_domain_records"` block. Place them after the last
existing record, grouped with a comment header matching the existing
pattern:

```hcl
  # Previous project records...

  # {project} website (Firebase Hosting)
  record {
    address  = "{siteId}.web.app."
    hostname = "{subdomain}"
    mx_pref  = 0
    ttl      = local.default_ttl
    type     = "CNAME"
  }

  # Firebase SSL cert verification for {subdomain}.lars.software
  record {
    address  = "{acme-token}"
    hostname = "_acme-challenge.{subdomain}"
    mx_pref  = 0
    ttl      = local.default_ttl
    type     = "TXT"
  }

}  # <-- closing brace of resource block
```

Never insert records in the middle of existing groups — always append
before the closing brace.

## Apply Workflow

### Prerequisites (check BEFORE writing any Terraform)

1. **API key:** `terraform.tfvars` must have a real Namecheap API key, not a
   placeholder. Check:

   ```bash
   cd ~/projects/domains
   grep -q "REPLACE_WITH\|your_api_key\|xxx" terraform.tfvars \
     && echo "BLOCKED: placeholder API key"
   ```

   Note: A key can also be **expired** (not just a placeholder). The only way
   to detect this is `terraform plan` — it returns error `1011102: "API Key is
invalid or API access has not been enabled"`. Run a targeted plan early to
   catch this.

2. **IP whitelist:** The current machine's public IP must be whitelisted in
   the Namecheap dashboard. Get your IP:

   ```bash
   # Use the fetch tool on https://ifconfig.me or:
   nix shell nixpkgs#nodejs -c node -e \
     "require('https').get('https://api.ipify.org', r => r.on('data', d => console.log(d.toString())))"
   ```

3. **Terraform initialized:**

   ```bash
   NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform init
   ```

### Apply commands

**Terraform is unfree (BSL license) as of v1.1x.** You MUST use one of:

```bash
# Option A: Allow unfree (recommended)
cd ~/projects/domains
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform fmt
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c terraform validate

# Targeted plan (recommended — isolates changes to one domain)
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c \
  terraform plan -target=namecheap_domain_records.lars_software

# If plan succeeds, apply
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#terraform -c \
  terraform apply -target=namecheap_domain_records.lars_software
```

```bash
# Option B: Use opentofu (the open-source Terraform fork)
cd ~/projects/domains
nix run nixpkgs#opentofu -- fmt
nix run nixpkgs#opentofu -- validate
nix run nixpkgs#opentofu -- plan -target=namecheap_domain_records.lars_software
nix run nixpkgs#opentofu -- apply -target=namecheap_domain_records.lars_software
```

### If credentials are blocked

If the API key is expired (error 1011102) or IP is not whitelisted:

1. Stage the records in Terraform (write the `.tf` code)
2. Run `terraform fmt` + `terraform validate` (these don't need API access)
3. Flag to the user: "DNS records are staged but cannot be applied — the
   Namecheap API key is expired. Please refresh it in `terraform.tfvars` and
   run `terraform apply -target=namecheap_domain_records.lars_software`."
4. Do NOT proceed to Firebase custom domain creation until DNS is confirmed
   applied — the domain will be stuck in `OWNERSHIP_MISSING` indefinitely.

## Namecheap Provider Quirks

- **`client_ip` auto-detection** may fail if `api.ipify.org` is blocked. Set
  `NAMECHEAP_CLIENT_IP` explicitly.
- **`MERGE` vs `OVERWRITE` mode:** Understand the implications before changing
  mode settings. `MERGE` adds records; `OVERWRITE` replaces all records for the
  domain.
- **`use_sandbox` flag:** Ensure this is `false` for production.
- **Lock file drift:** If `terraform init` fails with registry URL mismatches
  (`terraform.io` vs `opentofu.org`), run `terraform init -upgrade` to refresh
  the lock file.

## Pre-existing Changes Warning

The domains repo often has uncommitted changes from prior sessions (DNS records
for other projects). Before editing:

```bash
cd ~/projects/domains
git status
```

If there are uncommitted changes:

1. Flag them to the user before layering your changes on top.
2. Consider committing the pre-existing changes first (after asking the user)
   to isolate your diff.
3. Never mix your DNS changes with pre-existing staged content without
   explicit awareness.

## Edit Safety

When using find-replace edit tools on Terraform files:

1. Include 3-5 lines of unique context around the insertion point to make the
   match unambiguous.
2. Run `git diff` after EVERY edit to verify only intended lines changed.
3. Terraform DNS records are infrastructure — accidental modification of a
   sibling project's records can take down a live website.

Example of safe editing context:

```hcl
# Include 2-3 lines of unique context around the insertion point
  record {
    address  = "existing-project.web.app."
    hostname = "existing-project"
    mx_pref  = 0
    ttl      = local.default_ttl
    type     = "CNAME"
  }

  # NEW RECORD GOES HERE — with enough surrounding context to be unique
  record {
    address  = "new-project.web.app."
    hostname = "new-project"
    mx_pref  = 0
    ttl      = local.default_ttl
    type     = "CNAME"
  }
```
