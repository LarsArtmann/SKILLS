# CI Authentication for Private Go Repos in Nix

CI runners must resolve `github:` flake inputs for private repos without your local nix.conf. The Actions `GITHUB_TOKEN` cannot read sibling private repos — use a PAT stored as a secret.

## Strategy 1: PAT + `access-tokens` (current LarsArtmann fleet truth)

Store a fine-grained PAT (read-only **Contents** on every private flake-input repo) as a repo secret, e.g. `FLAKE_PAT`, and pass it to nix via the installer's `extra-conf`:

```yaml
- uses: actions/checkout@v4

- name: Install Nix
  uses: DeterminateSystems/nix-installer-action@v16
  with:
    extra-conf: access-tokens = github.com=${{ secrets.FLAKE_PAT }}

- uses: DeterminateSystems/magic-nix-cache-action@v9

- name: Update flake inputs
  run: nix flake update

- name: Build
  run: nix build .#default
```

If a job enters a devShell and runs `go` (private module fetches go over git transport), also rewrite the git URLs with the same token:

```yaml
- name: Authenticate Go private modules
  run: git config --global url."https://x-access-token:${FLAKE_PAT}@github.com/".insteadOf "https://github.com/"
```

Reference implementation: `Code-Quality-Agent/.github/workflows/ci.yml` (2026-11-11).

## Strategy 2 (legacy): Deploy Keys + ssh-agent

Only needed for flakes still pinned with `git+ssh://` URLs. One SSH key pair, public key added as a read-only deploy key to each private repo, private key stored as a GitHub Actions secret:

```yaml
- uses: actions/checkout@v4

- name: Configure SSH for private repos
  uses: webfactory/ssh-agent@v0.9.1
  with:
    ssh-private-key: ${{ secrets.DEPLOY_SSH_KEY }}

- name: Install Nix
  uses: DeterminateSystems/nix-installer-action@v16

- name: Build
  run: nix build .#default
```

Migrate away by rewriting inputs to `github:owner/repo/ref` and relocking (`nix flake update`), then switching to Strategy 1.

## Which to Choose

| Situation                                    | Recommendation                                |
| -------------------------------------------- | --------------------------------------------- |
| Fleet-standard `github:` inputs (all new work) | PAT + `access-tokens` — one secret, no key rotation per repo |
| Legacy flakes still on `git+ssh://`          | Deploy keys until migrated to `github:`       |
| Cross-organization private deps              | PAT with access to all repos, or per-org PATs |

## Verify

After wiring CI, push a branch and confirm:

1. `nix flake update` fetches all private inputs.
2. `nix build .#default` succeeds.
3. `nix flake check` succeeds.
