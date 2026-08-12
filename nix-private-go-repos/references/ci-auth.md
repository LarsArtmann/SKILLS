# CI Authentication for Private Go Repos in Nix

CI runners must resolve `git+ssh://` flake inputs without your local SSH keys. Two strategies work.

## Strategy 1: Deploy Keys + ssh-agent (used by LarsArtmann projects)

One SSH key pair, public key added as a read-only deploy key to each private repo, private key stored as a GitHub Actions secret. Uses `webfactory/ssh-agent` for clean SSH key injection.

```yaml
- uses: actions/checkout@v4

- name: Install Nix
  uses: DeterminateSystems/nix-installer-action@v16

- name: Configure SSH for private repos
  uses: webfactory/ssh-agent@v0.9.1
  with:
    ssh-private-key: ${{ secrets.DEPLOY_SSH_KEY }}

- name: Update flake inputs
  run: nix flake update

- name: Build
  run: nix build .#default
```

Create a single SSH key pair, add the public key as a deploy key (with read access) to every private repo, and store the private key as the `DEPLOY_SSH_KEY` secret.

**Optional:** add `DeterminateSystems/magic-nix-cache-action@v9` after the installer for faster CI builds via binary caching.

## Strategy 2: `GITHUB_TOKEN` with `insteadOf`

Rewrite SSH URLs to HTTPS with token auth. No deploy keys needed.

```yaml
- name: Configure git for private repos
  run: |
    git config --global url."https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "git@github.com:"
    git config --global url."https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/".insteadOf "ssh://git@github.com/"

- name: Update flake inputs
  run: nix flake update

- name: Build
  run: nix build .#default
```

`GITHUB_TOKEN` is automatically available in GitHub Actions. Ensure the workflow has `contents: read` permission for private repositories if the token is used across repos.

## Which to Choose

| Situation                                    | Recommendation                                                |
| -------------------------------------------- | ------------------------------------------------------------- |
| Few private repos, long-lived project        | Deploy keys — explicit, minimal blast radius                  |
| Many private repos, no deploy-key management | `GITHUB_TOKEN` with `insteadOf` — no key rotation overhead    |
| Cross-organization private deps              | `GITHUB_TOKEN` usually simpler if token access can be granted |
| Strictest separation of concerns             | Deploy keys with one key per repo                             |

## Verify

After wiring CI, push a branch and confirm:

1. `nix flake update` fetches all private inputs.
2. `nix build .#default` succeeds.
3. `nix flake check` succeeds.
