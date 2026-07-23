# Migration Checklist: `vendor/` → `mkPreparedSource`

Use this checklist when moving a Go project from committed `vendor/` to a hermetic Nix build with private dependencies.

## Preparation

- [ ] Identify all unique private repos in `go.mod`:

  ```bash
  grep -E 'github\.com/[Ll]ars[Aa]rtmann' go.mod | awk '{print $1}' | sed 's|/v[0-9]*||' | sort -u
  ```

- [ ] Decide whether any public LarsArtmann repos are present. If yes, plan to set `validatePrivateDeps = false;`.
- [ ] Check for transitive private deps by inspecting the `go.mod` files of each private dependency.
- [ ] Check for secondary modules such as `tools/go.mod` that also need `replace` directives.
- [ ] Check whether the project uses `go.work`. If yes, plan to set `GOWORK = "off";` in devShells.

## Flake changes

- [ ] Add `go-nix-helpers` as a flake input with `flake = false;` and `git+ssh://` URL.
- [ ] Add one flake input per private repo (not per sub-module) with `flake = false;` and `git+ssh://` URL.
- [ ] Import `mkPreparedSource` in the `let` block.
- [ ] Build `preparedSrc` with `mkPreparedSource` and the `deps` map keyed by exact module-path case.
- [ ] Set `vendorHash = pkgs.lib.fakeHash;` temporarily.
- [ ] Point `buildGoModule.src` to `preparedSrc`.
- [ ] Add `GOPRIVATE = "github.com/larsartmann/*,github.com/LarsArtmann/*";` to every devShell and CI shell.
- [ ] Set `GOWORK = "off";` if the project uses workspaces.
- [ ] Remove `vendor/` from the source fileset (e.g., `lib.fileset` or `src = ./.;` if it includes it implicitly).

## Remove vendor tracking

- [ ] Delete `vendor/` from git tracking:

  ```bash
  trash vendor/
  # Or if vendor/ is untracked and gitignored:
  rm -rf vendor/
  ```

- [ ] Remove `!vendor/` overrides from `.gitignore`.
- [ ] Commit the flake changes separately from the vendor deletion so each step is reviewable.

## Resolve build

- [ ] Run `nix build .#default` and copy the real `vendorHash` from the error output.
- [ ] Replace `pkgs.lib.fakeHash` with the real hash.
- [ ] Run `nix build .#default && nix flake check` again.

## Verify local development

- [ ] Ensure one-time git SSH rewrite is configured:

  ```bash
  git config --global url."git@github.com:".insteadOf "https://github.com/"
  ```

- [ ] Enter the devShell and confirm Go commands work:

  ```bash
  nix develop -c bash -c 'go mod tidy && go build ./...'
  ```

- [ ] Run the project test suite in the devShell.

## CI verification

- [ ] Choose CI authentication strategy:
  - [ ] Deploy keys (read-only) across all private repos, or
  - [ ] `GITHUB_TOKEN` with `git config insteadOf` rewriting SSH to HTTPS.
- [ ] Verify `nix flake update` and `nix build .#default` pass in a CI runner.
- [ ] Verify `nix flake check` passes in CI.

## Done when

- [ ] `nix build .#default` passes locally and in CI.
- [ ] `nix flake check` passes locally and in CI.
- [ ] `nix develop -c bash -c 'go mod tidy && go build ./...'` passes.
- [ ] No `vendor/` directory is tracked in git.
- [ ] No `!vendor/` override remains in `.gitignore`.
- [ ] Every devShell sets `GOPRIVATE` with both lowercase and uppercase casings.
