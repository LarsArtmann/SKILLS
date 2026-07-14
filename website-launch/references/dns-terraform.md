# DNS Terraform — Namecheap Record Templates

> DNS records for LarsArtmann domains are managed via Terraform with the
> Namecheap provider. This reference documents the exact record templates
> and the apply workflow.

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
Firebase hosting site's `web.app` domain. This is the standard pattern for
all project websites.

### Apex domain (firebase-hosting module)

For the apex domain (`lars.software` itself), use the `firebase-hosting`
Terraform module. See existing records in `lars.software.tf` for the
module usage pattern.

## Apply Workflow

### Prerequisites (check BEFORE writing any Terraform)

1. **API key:** `terraform.tfvars` must have a real Namecheap API key,
   not a placeholder. Check:

   ```bash
   grep -q "REPLACE_WITH\|your_api_key\|xxx" terraform.tfvars \
     && echo "BLOCKED: placeholder API key"
   ```

2. **IP whitelist:** The current machine's public IP must be whitelisted
   in the Namecheap dashboard. Check:

   ```bash
   curl -s ifconfig.me  # Compare against Namecheap whitelist
   ```

3. **Terraform initialized:**
   ```bash
   terraform init
   ```

### Apply commands

```bash
cd ~/projects/domains
terraform fmt
terraform validate
NAMECHEAP_CLIENT_IP=$(curl -s ifconfig.me) terraform plan
NAMECHEAP_CLIENT_IP=$(curl -s ifconfig.me) terraform apply
```

Or using Nix (opentofu):

```bash
nix run nixpkgs#opentofu -- plan
nix run nixpkgs#opentofu -- apply
```

## Namecheap Provider Quirks

- **`client_ip` auto-detection** may fail if `api.ipify.org` is blocked.
  Set `NAMECHEAP_CLIENT_IP` explicitly.
- **`MERGE` vs `OVERWRITE` mode:** Understand the implications before
  changing mode settings. `MERGE` adds records; `OVERWRITE` replaces all
  records for the domain.
- **`use_sandbox` flag:** Ensure this is `false` for production.
- **Lock file drift:** If `terraform init` fails with registry URL
  mismatches (`terraform.io` vs `opentofu.org`), run
  `terraform init -upgrade` to refresh the lock file.

## Pre-existing Changes Warning

The domains repo often has uncommitted changes from prior sessions (DNS
records for other projects). Before editing:

```bash
cd ~/projects/domains
git status
```

If there are uncommitted changes:

1. Flag them to the user before layering your changes on top.
2. Consider committing the pre-existing changes first (after asking the
   user) to isolate your diff.
3. Never mix your DNS changes with pre-existing staged content without
   explicit awareness.

## Edit Safety

When using find-replace edit tools on Terraform files:

1. Include enough unique context to make the match unambiguous.
2. Run `git diff` after EVERY edit to verify only intended lines changed.
3. Terraform DNS records are infrastructure — accidental modification of
   a sibling project's records can take down a live website.

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
