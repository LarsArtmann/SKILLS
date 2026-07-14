# Firebase Hosting REST API — Custom Domain Management

> The Firebase CLI has **no command** for adding custom domains to hosting
> sites. This reference documents the exact REST API calls, known gotchas,
> and the token extraction method.

## Token Extraction

### Method 1: gcloud (preferred)

```bash
ACCESS_TOKEN=$(gcloud auth print-access-token --project=lars-software)
```

### Method 2: Firebase CLI stored credentials

```bash
ACCESS_TOKEN=$(node -e "console.log(require(process.env.HOME + '/.config/configstore/firebase-tools.json').tokens.access_token)")
```

## Create Custom Domain

```bash
curl -X POST \
  "https://firebasehosting.googleapis.com/v1beta1/sites/{SITE_ID}/domains" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-goog-user-project: lars-software" \
  -d '{"domainName":"{SUBDOMAIN}.lars.software","site":"{SITE_ID}"}'
```

### Critical Gotchas (caused 4+ failed attempts in prior sessions)

1. **`site` field is REQUIRED** — omitting it causes `400 "Mismatched
sites in request: parent has X, domain has empty string"`.

2. **`site` value must be the bare site ID** — use `"dynamicmarkdown"`,
   NOT `"projects/lars-software/sites/dynamicmarkdown"`. Using the full
   path causes a `400` error.

3. **`x-goog-user-project` header is REQUIRED** — omitting it causes
   `403 "quota project not set"`.

4. **`domainName` must be the full domain** — `"dynamicmarkdown.lars.software"`.

## List Custom Domains + Check Status

```bash
curl -s "https://firebasehosting.googleapis.com/v1beta1/sites/{SITE_ID}/domains" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "x-goog-user-project: lars-software" | jq
```

### Domain Status Lifecycle

| Status                         | Meaning                               | Action needed                           |
| ------------------------------ | ------------------------------------- | --------------------------------------- |
| `CERT_PENDING` + `DNS_MISSING` | Domain created, DNS not propagated    | Add CNAME + TXT records, wait           |
| `CERT_PENDING` + `DNS_MATCH`   | DNS propagated, SSL cert provisioning | Wait (can take 10-60 min)               |
| `CERT_ACTIVE` + `DNS_MATCH`    | Fully operational                     | Verify with `curl -sI https://{domain}` |
| `OWNERSHIP_MISSING`            | Domain not verified                   | Check DNS records are correct           |

## Extract ACME Challenge

The domain creation response (or the list response) includes the SSL cert
verification challenge:

```json
{
  "name": "sites/{SITE_ID}/domains/{DOMAIN}",
  "domainName": "{SUBDOMAIN}.lars.software",
  "provisioning": {
    "certStatus": "CERT_PENDING",
    "certChallengeDns": {
      "domainName": "_acme-challenge.{SUBDOMAIN}.lars.software",
      "token": "{ACME_TOKEN_VALUE}"
    },
    "dnsUpdates": {
      "CNAME": {
        "hostname": "{SUBDOMAIN}",
        "target": "{SITE_ID}.web.app"
      }
    }
  }
}
```

Map to Terraform:

- `certChallengeDns.domainName` → TXT record hostname
  (`_acme-challenge.{subdomain}`)
- `certChallengeDns.token` → TXT record value
- `dnsUpdates.CNAME.target` → CNAME record target (`{siteId}.web.app.`)

## Delete Custom Domain

```bash
curl -X DELETE \
  "https://firebasehosting.googleapis.com/v1beta1/sites/{SITE_ID}/domains/{DOMAIN}" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "x-goog-user-project: lars-software"
```

Use this when you need to recreate a domain with a different name (e.g.
after a rename from `auditlog.lars.software` to
`go-workflow-auditlog.lars.software`).

## ACME TXT Record Lifecycle

ACME TXT records from Firebase are **point-in-time values** for initial
cert provisioning. They work for the first issuance, but Firebase may
issue a different challenge for renewal.

Consider whether the TXT record belongs in Terraform (permanent) or should
be managed out-of-band (ephemeral). In practice, keeping it in Terraform
works for the initial setup; monitor the Firebase Console for renewal
challenges.

## Firebase Project Structure

All LarsArtmann websites live in the `lars-software` Firebase project as
separate hosting sites (multi-site pattern).

| Config          | Location                                                     | Purpose                                         |
| --------------- | ------------------------------------------------------------ | ----------------------------------------------- |
| `.firebaserc`   | `website/`                                                   | Maps target names to site IDs                   |
| `firebase.json` | `website/`                                                   | Hosting config (public dir, headers, redirects) |
| Site creation   | `firebase hosting:sites:create {id} --project lars-software` | One-time per project                            |

### Standalone vs Shared Project

Some projects (e.g. `art-dupl`) have their own Firebase project instead of
joining `lars-software`. Check the existing config before assuming the
shared pattern.
