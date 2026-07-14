# Firebase Hosting REST API — Custom Domain Management

> The Firebase CLI has **no command** for adding custom domains to hosting
> sites. This reference documents the exact REST API calls, known gotchas,
> and the token extraction method.
>
> **Last verified:** 2026-07-13 against `lars-software` project with Firebase
> CLI v15.22.4.

## Token Extraction

### Method 1: gcloud (preferred)

```bash
ACCESS_TOKEN=$(nix shell nixpkgs#google-cloud-sdk -c gcloud auth print-access-token)
```

### Method 2: Firebase CLI stored credentials

```bash
ACCESS_TOKEN=$(nix shell nixpkgs#nodejs -c node -e \
  "console.log(require(process.env.HOME + '/.config/configstore/firebase-tools.json').tokens.access_token)")
```

## API Endpoint (v1beta1 customDomains)

The correct endpoint is the **`customDomains`** collection, NOT the legacy
`domains` collection. These are different APIs with different request formats.

### Create Custom Domain

```
POST https://firebasehosting.googleapis.com/v1beta1/projects/{PROJECT}/sites/{SITE_ID}/customDomains?customDomainId={DOMAIN}
```

**Headers (all required):**

| Header                | Value                              | Why                                   |
| --------------------- | ---------------------------------- | ------------------------------------- |
| `Authorization`       | `Bearer {ACCESS_TOKEN}`            | OAuth 2.0 auth                        |
| `x-goog-user-project` | `{PROJECT}` (e.g. `lars-software`) | Quota project — omitting causes `403` |
| `Content-Type`        | `application/json`                 | Standard                              |

**Body:** `{}` (empty object — the domain name goes in the `customDomainId`
query parameter, NOT in the body)

#### Node.js script (copy-paste ready)

```javascript
// Save as /tmp/firebase-create-domain.js and run with:
//   ACCESS_TOKEN=$(nix shell nixpkgs#google-cloud-sdk -c gcloud auth print-access-token) \
//     nix shell nixpkgs#nodejs -c node /tmp/firebase-create-domain.js

const https = require("https");
const token = process.env.ACCESS_TOKEN;
const projectId = "lars-software";
const siteId = process.env.SITE_ID || "{siteId}";
const domain = process.env.DOMAIN || "{subdomain}.lars.software";

const data = JSON.stringify({});
const options = {
  hostname: "firebasehosting.googleapis.com",
  path: `/v1beta1/projects/${projectId}/sites/${siteId}/customDomains?customDomainId=${domain}`,
  method: "POST",
  headers: {
    Authorization: "Bearer " + token,
    "Content-Type": "application/json",
    "Content-Length": data.length,
    "x-goog-user-project": projectId,
  },
};
const req = https.request(options, (res) => {
  let body = "";
  res.on("data", (chunk) => (body += chunk));
  res.on("end", () => console.log(res.statusCode + ": " + body));
});
req.on("error", (e) => console.error("Error: " + e.message));
req.write(data);
req.end();
```

### Critical Gotchas (caused 4+ failed attempts in prior sessions)

1. **Use `customDomains` not `domains`** — The legacy `domains` endpoint
   (`POST .../sites/{id}/domains`) accepts different fields and returns `400
"Cannot find field"`. Always use `customDomains`.

2. **Domain goes in query param, not body** — `?customDomainId={domain}` in
   the URL. The body is `{}`. Putting `"domain"` or `"domainName"` in the body
   causes `400 "Unknown name"`.

3. **`x-goog-user-project` header is REQUIRED** — omitting it causes `403
"quota project not set"`. The value is the Firebase project ID (e.g.
   `lars-software`).

4. **Full path includes `projects/{PROJECT}/sites/{SITE_ID}`** — not just
   `sites/{SITE_ID}`. The `projects/` prefix is required.

## List Custom Domains + Check Status

```javascript
// Save as /tmp/firebase-list-domains.js
const https = require("https");
const token = process.env.ACCESS_TOKEN;
const projectId = "lars-software";
const siteId = process.env.SITE_ID || "{siteId}";
const options = {
  hostname: "firebasehosting.googleapis.com",
  path: `/v1beta1/projects/${projectId}/sites/${siteId}/customDomains`,
  method: "GET",
  headers: {
    Authorization: "Bearer " + token,
    "x-goog-user-project": projectId,
  },
};
const req = https.request(options, (res) => {
  let body = "";
  res.on("data", (chunk) => (body += chunk));
  res.on("end", () => {
    try {
      const data = JSON.parse(body);
      if (!data.customDomains) {
        console.log(JSON.stringify(data, null, 2));
        return;
      }
      data.customDomains.forEach((cd) => {
        const cname = cd.requiredDnsUpdates?.desired?.[0]?.records?.[0];
        const acme = cd.cert?.verification?.dns?.desired?.[0]?.records?.[0];
        console.log("Domain:", cd.name.split("/").pop());
        console.log("  hostState:", cd.hostState);
        console.log("  ownershipState:", cd.ownershipState);
        console.log("  certState:", cd.cert?.state || "N/A");
        if (cname) console.log("  CNAME:", cname.domainName, "->", cname.rdata);
        if (acme) console.log("  ACME TXT:", acme.domainName, "->", acme.rdata);
        console.log("---");
      });
    } catch (e) {
      console.log("Status:", res.statusCode, body.substring(0, 300));
    }
  });
});
req.on("error", (e) => console.error("Error: " + e.message));
req.end();
```

Run with:

```bash
ACCESS_TOKEN=$(nix shell nixpkgs#google-cloud-sdk -c gcloud auth print-access-token) \
  SITE_ID={siteId} nix shell nixpkgs#nodejs -c node /tmp/firebase-list-domains.js
```

### Domain Status Lifecycle

| Status                      | Meaning                              | Action needed                         |
| --------------------------- | ------------------------------------ | ------------------------------------- |
| `OWNERSHIP_MISSING`         | Domain created, DNS not propagated   | Add CNAME + TXT records, wait         |
| `CERT_VALIDATING`           | DNS partially propagated, cert check | Wait — Firebase is polling DNS        |
| `CERT_ACTIVE` + `DNS_MATCH` | Fully operational                    | Verify with `fetch` tool on HTTPS URL |

## Extract ACME Challenge

The list response includes two DNS records you need to stage in Terraform.
**See [dns-terraform.md](./dns-terraform.md) for the exact HCL record
templates** — copy the CNAME and TXT record blocks from there and fill
in the values extracted below.

### CNAME record

Found at: `requiredDnsUpdates.desired[0].records[0]`

```json
{
  "domainName": "go-workflow-auditlog.lars.software",
  "type": "CNAME",
  "rdata": "auditlog.web.app",
  "requiredAction": "ADD"
}
```

Map to Terraform:

- hostname = `{subdomain}` (e.g. `go-workflow-auditlog`)
- target = `{siteId}.web.app.` (append trailing dot)

### ACME TXT record

Found at: `cert.verification.dns.desired[0].records[0]`

```json
{
  "domainName": "_acme-challenge.go-workflow-auditlog.lars.software",
  "type": "TXT",
  "rdata": "Kl50WF6Xp532l4EmJ2TigjWE2b4u9Njl_-JtkiXmPig",
  "requiredAction": "ADD"
}
```

Map to Terraform:

- hostname = `_acme-challenge.{subdomain}` (e.g. `_acme-challenge.go-workflow-auditlog`)
- value = the `rdata` string

## Delete Custom Domain

```javascript
const https = require("https");
const token = process.env.ACCESS_TOKEN;
const projectId = "lars-software";
const siteId = "{siteId}";
const domain = "{subdomain}.lars.software";
const options = {
  hostname: "firebasehosting.googleapis.com",
  path: `/v1beta1/projects/${projectId}/sites/${siteId}/customDomains/${domain}`,
  method: "DELETE",
  headers: {
    Authorization: "Bearer " + token,
    "x-goog-user-project": projectId,
  },
};
const req = https.request(options, (res) => {
  let body = "";
  res.on("data", (chunk) => (body += chunk));
  res.on("end", () => console.log(res.statusCode + ": " + body));
});
req.on("error", (e) => console.error("Error: " + e.message));
req.end();
```

Use this when you need to recreate a domain with a different name (e.g. after
a rename from `auditlog.lars.software` to
`go-workflow-auditlog.lars.software`).

## ACME TXT Record Lifecycle

ACME TXT records from Firebase are **point-in-time values** for initial cert
provisioning. They work for the first issuance, but Firebase may issue a
different challenge for renewal.

In practice, keeping the TXT in Terraform works for initial setup. Monitor the
Firebase Console for renewal challenges. If the cert fails to renew, re-query
the list endpoint for the new ACME token and update Terraform.

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
joining `lars-software`. Check the existing config before assuming the shared
pattern.
