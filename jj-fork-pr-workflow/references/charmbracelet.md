# charmbracelet Contribution Conventions

Load this file when the contribution target is any `github.com/charmbracelet/*`
repository (`bubbletea`, `lipgloss`, `bubbles`, `wish`, `vhs`, `soft-serve`,
...). The org centralizes defaults in the [`charmbracelet/.github`](https://github.com/charmbracelet/.github)
meta-repo; individual repos can override, so re-check the target repo's
`CONTRIBUTING.md` and `.github/PULL_REQUEST_TEMPLATE.md` before filing.

> Researched 2026-09-08 from `charmbracelet/.github` CONTRIBUTING.md and
> observed merge history on `bubbletea`. Treat per-repo specifics as
> unverified until checked.

## Convention summary

| Concern            | charmbracelet convention                                                                                                                                                                 |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Merge strategy     | **Squash and merge.** The PR title becomes the sole commit on `main`.                                                                                                                    |
| Commit/PR title    | **Conventional Commits** required — `feat:`, `fix:`, `chore:`, `docs:`, `ci:` — explicitly requested "to make it easier to generate release notes".                                      |
| DCO / CLA          | **None.** Instead: by contributing you assert 100% authorship and agree the content may be provided under the project's MIT license. Do NOT add `Signed-off-by` trailers for their sake. |
| PR template        | Sections: **1. Problem**, **2. Fix**, **3. Validation**, plus an agreement checkbox referencing CONTRIBUTING.md.                                                                         |
| Validation section | List the commands you ran — typically `go test ./...`, `go vet ./...`, `golangci-lint run` (match the repo's CI).                                                                        |
| New features       | **Open a Discussion first.** Feature PRs without prior maintainer buy-in are discouraged.                                                                                                |
| CI state           | Failing CI is read as work-in-progress. A PR with red CI stalls silently — keep every PR rebased and green (the sync loop in SKILL.md Phase 4 exists for exactly this).                  |
| Language           | Go (core libs). Some tooling (`vhs`) mixes Go + TypeScript.                                                                                                                              |

## Applying the jj fork workflow here

1. **Fork + clone** exactly as SKILL.md Phase 1
   (`gh repo fork charmbracelet/<repo> --clone=false`, `jj git clone
   --colocate`, add `upstream`, `jj git fetch --all-remotes`).
2. **Title the PR in Conventional Commits** — it will be squashed verbatim
   into history. One logical concern per PR; split with `jj split` if needed.
3. **Fill the template** with concrete, runnable validation output:

   ```markdown
   ## 1. Problem

   `bubbletea` re-renders the full view on every mouse move, causing visible
   flicker at high report rates.

   ## 2. Fix

   Skip the repaint when the rendered frame is byte-identical to the previous
   one. (`renderer.flush()` now early-returns on unchanged output.)

   ## 3. Validation

   - `go test ./...` — pass
   - `go vet ./...` — pass
   - `golangci-lint run` — pass
   - Manual: `go run examples/mouse/main.go`, moved mouse 500x, no flicker
   ```

4. **Never merge main into the PR branch** to update it — under squash-merge
   that pollutes the squash. Rebase via the sync loop instead
   (SKILL.md Phase 4).
5. **After merge**, run Phase 5 cleanup: the change rebases to `empty()`,
   review, `jj abandon`, delete the bookmark, `jj git push --deleted`.

## charmbracelet-specific gotchas

- **Discussions gate for features.** If the user asks to "add feature X to
  bubbletea", surface the Discussion requirement BEFORE writing code — the
  PR may be closed unread otherwise.
- **Their CI is the arbiter.** Local green is necessary, not sufficient;
  after every sync-loop push, check `gh pr checks charmbracelet/<repo>`.
- **Rendering/TTY code needs manual evidence.** For TUI-affecting changes,
  the Validation section should include a reproducible manual check (which
  example program, what to observe) — automated tests rarely cover terminal
  rendering.
