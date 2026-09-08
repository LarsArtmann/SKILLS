# charmbracelet Contribution Conventions

Load this file when the contribution target is any `github.com/charmbracelet/*`
repository (`bubbletea`, `lipgloss`, `bubbles`, `wish`, `vhs`, `soft-serve`,
...). The org centralizes defaults in the [`charmbracelet/.github`](https://github.com/charmbracelet/.github)
meta-repo; individual repos can override, so re-check the target repo's
`CONTRIBUTING.md` and `.github/PULL_REQUEST_TEMPLATE.md` before filing.

> Raw-verified 2026-09-08 via the GitHub API against `charmbracelet/.github`
> CONTRIBUTING.md, the org-level `.github/PULL_REQUEST_TEMPLATE.md`, and
> `bubbletea` merge history. Individual repos can override the org defaults —
> re-check the target repo before filing.

## Convention summary

| Concern          | charmbracelet convention                                                                                                                                                                                        |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Merge strategy   | **Squash and merge.** The PR title becomes the sole commit on `main`.                                                                                                                                           |
| Commit/PR title  | **Conventional Commits** required — `feat:`, `fix:`, `chore:`, `docs:`, `ci:` — explicitly requested "to make it easier to generate release notes".                                                             |
| DCO / CLA        | **None.** Instead: by contributing you assert 100% authorship and agree the content may be provided under the project's MIT license. `Signed-off-by` trailers are not required.                                 |
| PR template      | Org-level template is **two checkboxes** (read CONTRIBUTING.md; maintainer-approved Discussion for new features). No enforced body sections; GitHub auto-inserts it in repos without their own template.        |
| Evidence bar     | CONTRIBUTING requires tests or a minimal reproducible example to review changes; bug PRs need before/after repro steps. Run the repo's CI commands (`go test ./...`, `go vet ./...`, lint) and show the output. |
| Review readiness | Only mark "Ready for Review" when complete; failing CI without a request for help is assumed to be WIP.                                                                                                         |
| New features     | **Open a Discussion first.** Feature PRs without prior maintainer buy-in are discouraged.                                                                                                                       |
| CI state         | Failing CI is read as work-in-progress. A PR with red CI stalls silently — keep every PR rebased and green (the sync loop in SKILL.md Phase 4 exists for exactly this).                                         |
| Language         | Go (core libs). Some tooling (`vhs`) mixes Go + TypeScript.                                                                                                                                                     |

## Applying the jj fork workflow here

1. **Fork + clone** exactly as SKILL.md Phase 1
   (`gh repo fork charmbracelet/<repo> --clone=false`, `jj git clone
   --colocate`, add `upstream`, `jj git fetch --all-remotes`).
2. **Title the PR in Conventional Commits** — it will be squashed verbatim
   into history. One logical concern per PR; split with `jj split` if needed.
3. **Write the PR body** — the org template only contributes two
   checkboxes, so structure the body yourself (problem → fix → evidence).
   CONTRIBUTING asks for before/after repro steps on bug fixes. When
   passing `gh pr create --body` explicitly, include the checkboxes
   yourself — GitHub only auto-inserts the template for empty bodies:

   ```markdown
   `bubbletea` re-renders the full view on every mouse move, causing visible
   flicker at high report rates. Before: `go run examples/mouse/main.go`,
   move the mouse, observe flicker. After this change: no flicker.

   Fix: skip the repaint when the rendered frame is byte-identical to the
   previous one (`renderer.flush()` now early-returns on unchanged output).

   - `go test ./...` — pass
   - `go vet ./...` — pass
   - `golangci-lint run` — pass

   - [x] I have read [`CONTRIBUTING.md`](https://github.com/charmbracelet/.github/blob/main/CONTRIBUTING.md).
   - [ ] I have created a discussion that was approved by a maintainer (for new features).
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
  after every sync-loop push, check `gh pr checks` (run it in the clone — it
  selects the PR for the current branch; `owner/repo` is not a valid
  argument to it).
- **Rendering/TTY code needs manual evidence.** For TUI-affecting changes,
  the PR body should include a reproducible manual check (which example
  program, what to observe) — automated tests rarely cover terminal
  rendering.
