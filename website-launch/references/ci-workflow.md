# CI Workflow — GitHub Actions for Website Build + Deploy

> Copy `.github/workflows/website.yml` into the project repo. The two-job
> pattern (build → deploy) ensures deploys only happen after successful
> builds, and only on `master` pushes.

## Template

```yaml
name: Website

on:
  push:
    branches: [master]
    paths:
      - website/**
      - .github/workflows/website.yml
  pull_request:
    branches: [master]
    paths:
      - website/**
      - .github/workflows/website.yml
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: website-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build-website:
    name: Build Website
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: website
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-node@v6
        with:
          node-version: "24"
          cache: pnpm
          cache-dependency-path: website/package-lock.json

      - run: pnpm install

      - run: pnpm dlx astro check

      - run: pnpm run build

      - name: HTML Validation
        run: pnpm dlx html-validate --config .htmlvalidate.json "dist/**/*.html"

      - uses: actions/upload-artifact@v7
        with:
          name: website-dist
          path: website/dist/

  deploy-website:
    name: Deploy Website
    needs: build-website
    if: github.event_name == 'push' && github.ref == 'refs/heads/master'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-node@v6
        with:
          node-version: "24"

      - uses: actions/download-artifact@v8
        with:
          name: website-dist
          path: website/dist/

      - name: Deploy to Firebase Hosting
        working-directory: website
        run: |
          pnpm add -g firebase-tools
          echo "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}" > "$RUNNER_TEMP/gcp-key.json"
          firebase deploy --only hosting:{TARGET} --project lars-software
        env:
          GOOGLE_APPLICATION_CREDENTIALS: ${{ runner.temp }}/gcp-key.json
```

## What to Customize

| Placeholder     | Replace with                                      |
| --------------- | ------------------------------------------------- |
| `{TARGET}`      | Firebase hosting target name (from `.firebaserc`) |
| `master`        | Default branch name (e.g. `main`, `fork`)         |
| `lars-software` | Firebase project ID (if standalone project)       |

### Branch name

The template uses `master` as the deploy branch. Many repos use `fork`,
`main`, or another branch. Update ALL branch references in the workflow:

- `branches: [master]` in `on.push` and `on.pull_request`
- `github.ref == 'refs/heads/master'` in the deploy job `if` condition

### Standalone Firebase project

If the project uses its own Firebase project (not `lars-software`):

- Change `--project lars-software` to `--project {projectId}`
- Change `--only hosting:{TARGET}` to `--only hosting` (no target)
- Ensure `FIREBASE_SERVICE_ACCOUNT` contains a key for the correct project

## CI Secret Setup

The deploy job requires `FIREBASE_SERVICE_ACCOUNT` as a GitHub secret.
Set it up with:

```bash
# Find the firebase-admin SDK service account
gcloud iam service-accounts list --project=lars-software \
  | grep firebase-adminsdk

# Create a key (temp file — clean up after)
gcloud iam service-accounts keys create /tmp/firebase-ci-key.json \
  --iam-account=firebase-adminsdk-{HASH}@lars-software.iam.gserviceaccount.com \
  --project=lars-software

# Set GitHub secret
gh secret set FIREBASE_SERVICE_ACCOUNT --repo LarsArtmann/{repo} \
  --body "$(cat /tmp/firebase-ci-key.json)"

# Verify
gh secret list --repo LarsArtmann/{repo}

# Clean up the temp key file (security)
rm /tmp/firebase-ci-key.json
```

## Rollback

If a deploy introduces a broken site, roll back to the previous version:

```bash
# List recent releases
firebase hosting:releases:list --site {siteId} --project lars-software

# Rollback to the previous release
firebase hosting:rollback --site {siteId} --project lars-software
```

This reverts the `live` channel to the prior version immediately.
