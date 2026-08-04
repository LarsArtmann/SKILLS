# Definition of Done

> Complete checklist for declaring a website launch finished. Verify EVERY item
> before declaring complete. Missing any item means the launch is incomplete.

## Build and Deploy

- [ ] `npm run build` succeeds with 0 errors (run from `website/`)
- [ ] `npx astro check` passes with 0 errors
- [ ] `https://{siteId}.web.app` returns HTTP 200
- [ ] All docs pages return HTTP 200 on web.app
- [ ] All internal doc links resolve (no 404s in Starlight sidebar)
- [ ] GitHub homepage URL matches `https://{subdomain}.lars.software`

## README

- [ ] Centered header with badges (library: Go Reference, CI, Go Report Card; application: CI, Docker)
- [ ] Documentation link to `https://{subdomain}.lars.software`
- [ ] pkg.go.dev link ONLY for libraries, NOT for applications
- [ ] License badge matches actual LICENSE file (NOT hardcoded MIT)
- [ ] No emojis in headers or bullets
- [ ] All code examples verified against Go source
- [ ] Comparison table present

## GitHub

- [ ] Description updated
- [ ] Homepage URL set to `https://{subdomain}.lars.software`
- [ ] Topics include `go`, `golang`, + domain-specific

## DNS (if credentials available)

- [ ] CNAME record in `domains/lars.software.tf`
- [ ] ACME TXT record in `domains/lars.software.tf`
- [ ] `terraform validate` passes
- [ ] `terraform fmt -check` passes

## Files

- [ ] `package-lock.json` committed
- [ ] `flake.lock` committed
- [ ] No `firebase-tools` in `package.json` dependencies
- [ ] No temp files left behind (`/tmp/*.js`)
- [ ] `git status` clean in BOTH repos (project + domains)

## Two repos awareness

When working on a project website with DNS, there are always TWO repos to
commit:

- The project repo (website files, README, CI workflow)
- The domains repo (DNS records)

Run `git status` in BOTH before declaring done.

## Status report guidance

When writing status reports, **never hardcode unconfirmed URLs or domain
names**. Use `{subdomain}.lars.software (pending DNS propagation)` until the
domain is verified live. A status report that references a domain that was
subsequently renamed is worse than no status report — it creates a false
historical record.
