# Status Report: go-release Skill — Fix Round 2

**Date:** 2026-08-12 12:10
**Session goal:** Complete all remaining work from the second self-review status report
**Prior report:** `docs/status/2026-08-12_11-08_go-release-fix-round-1.md`

---

## a) FULLY DONE

1. **Verified GoReleaser OSS hook wrapping claim** — Downloaded GoReleaser v2.17.1
   source from `proxy.golang.org`. Confirmed `internal/shell/shell.go:27` executes
   hooks via `exec.CommandContext(ctx, command[0], command[1:]...)`, i.e., directly,
   not through a shell. Added the fact to `references/goreleaser-and-ci.md` Gotchas
   table and to the new `references/quick-reference.md`.

2. **Thinned go-ecosystem-upgrade Phase 6** — Reduced 5 inline release rules to 2
   ecosystem-upgrade-specific rules (verify tag resolves in clean module; re-verify
   CHANGELOG accuracy after git ops) plus a pointer to `go-release` for the full
   procedure. Removed general release rules (tag immutability, tag from right commit,
   strip replace directives) that now live in `go-release`.

3. **Added `gofmt -r` alternative** — Documented `gofmt -r` as the Go-native,
   syntax-aware way to rewrite the root module import during v2+ migration, with a
   note that sub-packages need per-package rules or the scoped `sed` fallback. Also
   clarified that the package name used in code does not change because it is set by
   the imported package's `package` declaration.

4. **Added Docker / Homebrew cask / Scoop publishing** — Added four new sections to
   `references/goreleaser-and-ci.md`:
   - Docker image publishing with `dockers_v2` (multi-platform, buildx, registry
     login, OCI labels/annotations)
   - Homebrew cask publishing with `homebrew_casks` (not deprecated `brews`)
   - Scoop bucket publishing with `scoops`
   - Release branch strategies (when to use, cherry-pick workflow, do-not-merge-back
     rule)
     Updated the file's Table of Contents and verified syntax against GoReleaser's own
     `.goreleaser.yaml` and `pkg/config/config.go`.

5. **Added Table of Contents to SKILL.md** — Generated anchor links for every major
   section and inserted the ToC after the release-shape decision tree.

6. **Wrote and ran test prompts** — Created `evals/evals.json` with 3 realistic
   prompts, ran 6 subagent evaluations (3 with skill loaded, 3 baseline), and graded
   them in `evals/iteration-1/grading.json`. With-skill pass rate: 74%; baseline: 30%.
   Identified one material skill gap (binary-only v2.0.0 release incorrectly
   suggested `/v2` module migration) and fixed it in SKILL.md.

7. **Added `scripts/pre-release-check.sh`** — Automates Phase 3 + Phase 4 gates:
   detects local `replace` directives, pseudo-version placeholders, dirty git tree,
   runs `go mod tidy`, `go mod verify`, `go build`, `go test` (optional `-race`),
   `go vet`, and optional `golangci-lint`. Referenced the script in SKILL.md Phase 4.
   Tested in clean, replace-containing, and dirty-tree modules.

8. **Demoted `sed` for `vendorHash` in failure-modes R16** — Reordered the fix to
   recommend the Nix-native `nix run .#fix-vendor-hash` first, then `lib.fakeHash`,
   with the `sed` fallback last and clearly marked as fallback.

9. **Moved quick-reference sections to `references/quick-reference.md`** — Removed
   the Checklist and Gotchas sections from SKILL.md (saving ~38 lines, keeping it at
   476 lines) and linked the new reference file. This kept SKILL.md under the 500-line
   limit.

10. **Updated README.md status** — Moved `go-release` from 🆕 New to 🟢 Comprehensive
    and adjusted the quality-status paragraph (20 of 25 skills are now
    solid/comprehensive/functional; five remain 🆕 New).

11. **All validations pass** — `scripts/check-skills.sh`: OK, 25 skills. SKILL.md:
    476 lines (limit 500). Description: 989 chars (limit 1024). No `rm` violations in
    skill source files. All JSON eval files valid.

---

## b) PARTIALLY DONE

None. Every remaining item from the prior report is complete.

---

## c) NOT STARTED

None.

---

## d) EXTERNAL CLAIMS STATUS

| Claim                                                 | Status                 | Evidence                                                     |
| ----------------------------------------------------- | ---------------------- | ------------------------------------------------------------ |
| GoReleaser `version: 2` required                      | ✅ Verified            | goreleaser.com + own source                                  |
| GoReleaser hooks use direct `exec.CommandContext`     | ✅ Verified            | `internal/shell/shell.go:27` in v2.17.1 source               |
| Docker v2 syntax (`images`, `tags`, `platforms`)      | ✅ Verified            | GoReleaser's own `.goreleaser.yaml` + `pkg/config/config.go` |
| Homebrew `brews` deprecated, `homebrew_casks` current | ✅ Verified            | `pkg/config/config.go` + own `.goreleaser.yaml`              |
| Scoop `scoops` config                                 | ✅ Verified            | `pkg/config/config.go` + own `.goreleaser.yaml`              |
| Cosign v3 `--bundle` migration                        | ✅ Verified in round 1 |                                                              |
| SLSA `actions/attest-build-provenance@v2`             | ✅ Verified in round 1 |                                                              |
| `go mod edit -retract=vX.Y.Z`                         | ✅ Verified in round 1 | `go help mod edit`                                           |
| GOPROXY comma-vs-pipe                                 | ✅ Verified in round 1 | Go toolchain source                                          |

---

## e) WHAT REMAINS (future work, not blocking)

1. **Re-run evals after the binary-major-version clarification** — The v2.0.0 CLI
   confusion was fixed in SKILL.md; a fresh eval run would likely push the with-skill
   pass rate above 80%.

2. **Add more eval prompts** — Multi-module GoReleaser, retracting a version, private
   dependency release, v2+ migration.

3. **Use the skill-creator runtime for automated evals** — The current run used
   subagents because `claude -p` is unavailable in this environment. The skill-creator
   `run_eval.py` / `run_loop.py` would give trigger-accuracy metrics and variance
   analysis.

4. **Vendor html-report-kit if producing HTML eval reports** — Not needed for the
   current Markdown eval artifacts.

---

## f) FILES CHANGED

### Modified

- `README.md`
- `go-ecosystem-upgrade/SKILL.md`
- `go-release/SKILL.md`
- `go-release/references/failure-modes.md`
- `go-release/references/goreleaser-and-ci.md`
- `go-release/references/major-versions.md`

### Created

- `go-release/references/quick-reference.md`
- `go-release/scripts/pre-release-check.sh`
- `go-release/evals/evals.json`
- `go-release/evals/iteration-1/eval-{1,2,3}/eval_metadata.json`
- `go-release/evals/iteration-1/eval-{1,2,3}/{with,without}_skill/output.md`
- `go-release/evals/iteration-1/grading.json`
- `docs/status/2026-08-12_12-10_go-release-fix-round-2.md` (this file)
