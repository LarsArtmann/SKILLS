---
name: go-ecosystem-upgrade
description: >
  Use when bumping, upgrading, releasing, or migrating Go library versions across multiple
  consumer projects — single-library version bumps (go get @latest), Go toolchain version
  pins (go.mod go directive), major-version module-path migrations (v2 to v3), ecosystem-wide
  dependency sweeps, vendor directory sync, go.sum repair, or git tag/module-proxy releases.
  Trigger phrases: "bump X to vY", "upgrade all consumers", "migrate v2 to v3", "pin go to",
  "go mod vendor", "re-tag the release", "dependency sweep", "version pin", "align go.mod",
  "release the library", "who uses this dependency", "checksum mismatch", "stale vendor".
  Also fires for diagnosing why a version bump broke a build or a tag is poisoned in the
  proxy. Covers the full lifecycle: enumerate consumers, baseline, classify direction,
  execute, verify (build AND test AND the delivering layer), commit per-repo, tag without
  poisoning the module proxy.
metadata:
  tags: go, dependencies, upgrade, release, migration, ecosystem, version, module-proxy
---

# Go Ecosystem Upgrade

A protocol for bumping, migrating, and releasing Go library versions across many consumer
projects without repeating the same expensive mistakes. Every rule below exists because a
real session burned hours (or shipped broken code) by violating it. **The #1 most repeated
failure across every report: build-only verification — running `go build` instead of
`go test ./...` and skipping behavioral checks. Compilation proves nothing about behavior.**

## When this skill activates

You're about to change a version number in one or more Go projects. That covers:

- **Single-library bump**: `go get github.com/foo/bar@v1.2.0` across N consumers
- **Toolchain pin**: every `go.mod` declares `go 1.26` (or a specific patch)
- **Major-version migration**: module path changes (`v2` → `v3`), breaking API migrations
- **Ecosystem-wide sweep**: bump ALL dependencies in ALL repos
- **Library release**: cut tags, push to the module proxy, verify consumers resolve them
- **Vendor sync**: `go mod vendor` after a bump, or eliminating vendor/ via Nix
- **Diagnostic**: a bump broke things, a tag is poisoned, go.sum won't verify

## The protocol

Work through these phases **in order**. Do not skip ahead. Each phase has a verification
gate — if the gate fails, stop and fix before continuing.

### Phase 0 — Pre-flight: classify the change before touching anything

Before writing a single `go get`, answer these questions. Getting them wrong is the most
expensive mistake in the catalog.

1. **What direction is the change?** Upgrades (1.2 → 1.3) carry little risk. Downgrades
   (1.26.5 → 1.26.4) carry real risk — stdlib APIs may have been used that don't exist in
   the lower version. **Flag downgrades explicitly and confirm with the user before
   executing.** A senior engineer's first sentence on a downgrade task should be: "Most
   modules are already at the higher version — pinning downgrades them. Confirm?"

2. **Is it breaking or additive?** Read the target library's CHANGELOG and migration guide.
   Additive bumps (new APIs, no removals) are safe to roll out wide. Breaking bumps
   (removed symbols, renamed methods, changed signatures) require per-consumer code
   migration. If the CHANGELOG is incomplete (common — see failure mode F6), grep the
   library's exported symbols yourself.

3. **What layer does the library deliver?** A pure-logic library is verified by `go build` +
   `go test`. A UI library (templ-components, HTMX helpers) is verified by `go build` +
   `go test` + `templ generate` + **rendering a page in a browser**. An infrastructure
   library (httputil middleware) needs behavioral tests (CORS, ETag, rate limiting changed
   their defaults). **Identify the delivering layer now** — skipping it is failure mode F4.

4. **Is the target version published?** Check `go list -m -versions
github.com/foo/bar` or the module proxy. If the tag doesn't exist yet, you're doing a
   release, not just a bump — see Phase 6.

### Phase 1 — Baseline: establish ground truth before migration

For every consumer you'll touch:

1. **Record the current version** in each consumer's `go.mod` (grep, don't trust memory).
2. **Run `go build ./...` and `go test ./...` BEFORE any change.** This is your baseline.
   Without it, you cannot distinguish "broke by this update" from "was already broken" —
   failure mode F11. Many repos have red master branches you don't know about.
3. **Check for `vendor/` directories.** If present, note it — you'll need `go mod vendor`
   after the bump. Detecting this late causes reactive scrambling (failure mode F8).
4. **Check for `go.work` files.** Workspace files override `go.mod` resolution and
   interfere with `go get` in non-obvious ways (failure mode F2). Note every consumer
   that has one.
5. **Check for `replace` directives** pointing at the target library. A local `replace`
   makes the `require` version cosmetic — the local source always wins.

If a consumer already has a red build or red tests **before your change**, record it in a
"pre-existing failures" list. This list is your defense against false regression claims.

### Phase 2 — Enumerate: find ALL consumers, not just the obvious ones

This phase exists because "all" means _all_. Multiple sessions missed consumers by
respecting `.gitignore`, capping search depth, or forgetting transitive consumers.

1. **Use `--no-ignore-vcs` and `--hidden`** when searching for files. Gitignore is a dev
   convenience, not a completeness contract. For "all go.mod files" tasks, `rg` and `glob`
   honor `.gitignore` by default and silently skip 6+ files. This is failure mode F1 — the
   single most common enumeration mistake.
2. **Search broadly enough.** Capping at `maxdepth 3` misses nested modules. Run a
   full-depth search and filter results, rather than guessing the depth.
3. **Find transitive consumers too.** A project that doesn't directly import the library
   may get it transitively (e.g., via `cqrs-htmx/v4` which embeds `templ-components`). These
   consumers still need verification, even if no `go.mod` edit is required.
4. **Check non-`go.mod` version references.** A version lives in many places beyond
   `go.mod` — see [./references/version-surface.md](./references/version-surface.md) for
   the exhaustive inventory. Drift between them is the actual bug class.
5. **Include generated/fixture modules.** Gitignored test fixtures (typespec emitter
   output, etc.) may be regenerated and revert your edits. If they're generated, fix the
   generator, not the artifact.

### Phase 3 — Execute: per-consumer, with scope discipline

For each consumer, apply the version change using the right tool:

1. **Use `go mod edit` / `go get`, never manual edits** to dependency files. This is a
   hard rule from the project AGENTS.md. For the `go` directive specifically: `go mod
edit -go=1.26` (not sed).

2. **Handle `go.work` interference explicitly.** `GOWORK=off go get` does NOT fully isolate
   the workspace — it can write to `go.work.sum` instead of `go.mod`, reporting success
   while changing nothing. The reliable approach: **temporarily rename `go.work` →
   `go.work.bak`** before `go get` + `go mod tidy`, then restore. Always verify the
   `go.mod` version _after_ the command, not just trust the output.

3. **Scope code migrations per-file, not per-codebase.** When migrating breaking API
   changes (e.g. `AggregateID()` → `StreamID()`), use targeted `grep` + edit only on files
   that import the library. Blind `sed` across all `.go` files corrupts local domain types
   that happen to share method names (failure mode F5). Before replacing a symbol, check
   each occurrence's origin: is it from the library or the local domain?

4. **Run code generators after the bump.** Any repo with `.templ` files needs
   `templ generate` after a templ/templ-components bump. Stale generated code compiles
   today and breaks tomorrow.

5. **Keep scope discipline.** When a build is blocked by something unrelated to the
   version task, the right move is: report it, flag it, and either stop and ask, or make
   the _minimal_ unblocking change and call it out explicitly. Do not fold side-fixes
   silently into a version bump — they deserve their own commit and review (failure mode
   F10).

6. **Don't sever dev workflows to make CI green.** A `use ../local-lib` directive in a
   `go.work` is a deliberate developer-ergonomics choice. If a local-dev chain breaks
   because of unreleased upstream, the fix is to complete the chain locally (add the
   missing `use`), not to sever it.

### Phase 4 — Verify: build AND test AND the delivering layer

This is the phase that gets skipped most often and causes the most damage.

1. **Run `go test ./...`, not just `go build ./...`.** Build-only verification is the
   #1 most repeated failure across every report. Compilation proves nothing about
   behavior. `go test` catches behavioral regressions that builds hide. This is
   non-negotiable.

2. **Verify the delivering layer** identified in Phase 0. For a UI library: confirm CSS
   assets are present and imported, run `templ generate`, render a page in a browser,
   review golden snapshot diffs line-by-line. For middleware: test the changed behavior
   (CORS, ETag, rate limiting). For pure logic: tests suffice.

3. **Re-verify go.mod versions after all changes.** Don't trust `go get` output — grep
   the actual `go.mod` file for every single consumer after all updates are done. Silent
   failures where `go get` reports "upgraded" but doesn't persist are real (failure mode
   F2).

4. **Run `go mod verify`** on every consumer, especially where `go mod tidy` failed. This
   confirms `go.sum` is internally consistent and has all needed hashes.

5. **Validate extraction on one known case first.** If you're parsing output or building
   a batch runner, verify your script against one consumer's raw output before processing
   all of them. A regex bug silently corrupts all rows.

6. **Confirm the full test suite passes with `-race`** on critical/concurrent code paths.
   Data races don't show up in build or basic tests.

### Phase 5 — Commit: per-repo, durable, immediately

1. **Commit per-repository**, not as one mega-commit. Each repo has its own history, CI,
   and branching conventions. A coordinated sweep touching 15 repos should produce 15
   commits, each with a clear message about what changed and why.

2. **Commit immediately after verification passes.** Leaving everything uncommitted
   invites sibling-session chaos (another agent or process may commit your work, overwrite
   it, or attribute it to "Unknown Author"). The "never commit unless asked" rule conflicts
   with multi-session safety — if you're doing a large bump, ask for commit authorization
   upfront.

3. **Persist runner scripts and results in the repo**, not `/tmp`. Everything in `/tmp` is
   ephemeral — reboot = gone, no reproducibility. A real upgrade run should be durable and
   re-runnable.

4. **Don't let pre-commit hooks rewrite your commit messages.** Some repos have hooks that
   intercept and genericize messages. If this happens, use `--no-verify` for the migration
   commit, or investigate whether the hook can preserve the message.

### Phase 6 — Release: tag without poisoning the proxy

If you're cutting tags (releasing a library, not just consuming one). **Load the
`go-release` skill** — it covers the complete lifecycle (version determination,
CHANGELOG, pre-release verification, GoReleaser, post-push validation, recovery).
The two rules below are the additional checks that apply specifically when a
release is part of a larger ecosystem upgrade:

1. **Verify the tag resolves in a clean module.** After pushing, run `go get
  github.com/foo/bar@v1.2.0` in a fresh module (or `GONOSUMDB=*` if the proxy hasn't
  cached it yet). Don't assume the tag works — prove it.

2. **Re-verify CHANGELOG accuracy after any git operation.** A sibling session's
  revert can make your CHANGELOG entries false. A lying CHANGELOG is worse than no
  CHANGELOG.

## The failure-mode catalog (compact reference)

These are the recurring mistakes extracted from 14 brutal self-review status reports.
Each has a code; the full story and root-cause analysis live in
[./references/failure-mode-catalog.md](./references/failure-mode-catalog.md).

| Code | Failure                                                         | One-line fix                                                            |
| ---- | --------------------------------------------------------------- | ----------------------------------------------------------------------- |
| F1   | Respecting `.gitignore` on "ALL files" tasks                    | Use `--no-ignore-vcs --hidden` from the start                           |
| F2   | `GOWORK=off` doesn't isolate — `go get` silently no-ops         | Rename `go.work` → `.bak`, verify go.mod after every `go get`           |
| F3   | Build-only verification (no `go test`)                          | Always run `go test ./...`, not just `go build`                         |
| F4   | Skipping the delivering layer (CSS, generators, browser render) | Verify the layer the library actually delivers, not just compilation    |
| F5   | Blind `sed`/regex replacement corrupts local types              | Scope per-file on importing files; check each symbol's origin           |
| F6   | Trusting incomplete CHANGELOGs                                  | Grep exported symbols yourself; changelogs omit removals                |
| F7   | Deleting and recreating git tags (proxy cache poisoning)        | Never reuse version numbers; always bump                                |
| F8   | Tagging from the wrong commit (missing the rename)              | Verify `git merge-base --is-ancestor`; tag from HEAD                    |
| F9   | Hand-editing `go.sum` with sed                                  | Never — repair upstream and run `go mod tidy`                           |
| F10  | Folding side-fixes into version bumps silently                  | Separate concerns → separate commits → separate review                  |
| F11  | No baseline before migration                                    | Record build+test state BEFORE touching anything                        |
| F12  | Not committing (everything in `/tmp` or working tree)           | Commit per-repo immediately after verification                          |
| F13  | Stale vendor directories (hundreds of files behind)             | Detect vendor/ in Phase 1; `go mod vendor` in Phase 3                   |
| F14  | Dead/stale `replace` directives                                 | Audit replace blocks; drop targets that don't exist                     |
| F15  | Treating checksum mismatches as nuisances                       | Investigate root cause; a SECURITY ERROR is not a `replace` opportunity |
| F16  | Downgrade risk not flagged                                      | Flag direction; confirm downgrades before executing                     |
| F17  | No tags on consumer releases                                    | Tag releases; untagged master is invisible to the proxy                 |
| F18  | Pseudo-versions in published go.mod                             | Strip replaces before tagging; verify no `00010101` sentinels           |

When something goes wrong during execution, scan this table first — the failure you're
experiencing is almost certainly one of these.

## Decision: additive bump vs breaking migration

```
Is the target version breaking (removed/renamed symbols)?
│
├─ NO (additive) ────────────────────────────────────────────┐
│   Safe to batch: go get @latest across all consumers,      │
│   go mod vendor where needed, build + test, commit.        │
│   Risk is low. Sample-verify builds (don't need all 167).  │
│                                                             │
└─ YES (breaking) ───────────────────────────────────────────┐
    Must go per-consumer:                                     │
    1. Read migration guide + grep removed symbols            │
    2. For each consumer: baseline → migrate code → build →   │
       test → commit                                          │
    3. Never batch-blind sed; scope to importing files        │
    4. Track which consumers are done vs pending              │
    Risk is high. Verify every consumer individually.         │
```

## Quick reference: the verification gate

Before declaring a consumer "done," confirm ALL of:

- [ ] `go.mod` declares the target version (grep the file, don't trust `go get` output)
- [ ] `go build ./...` passes
- [ ] `go test ./...` passes (not just build!)
- [ ] Delivering layer verified (generators run, CSS present, browser render if UI)
- [ ] `go mod verify` passes (go.sum is consistent)
- [ ] `go mod vendor` run if the project has a vendor/ directory
- [ ] No old version references remain (grep `go.mod`, source imports, `go.work`)
- [ ] Pre-existing failures separated from migration failures (baseline comparison)
- [ ] Changes committed per-repo with a clear message

For a library release (tagging), add:

- [ ] Tag cut from a commit that contains all expected symbols
- [ ] No local `replace` directives in the tagged go.mod
- [ ] No pseudo-versions (`00010101...`) in the tagged go.mod
- [ ] Fresh version number (never reused a deleted tag)
- [ ] Tag resolves in a clean module (`go get @version`)
- [ ] CHANGELOG updated and accurate

## Reference files

- [./references/failure-mode-catalog.md](./references/failure-mode-catalog.md) — The full
  failure-mode catalog with root-cause analysis, real examples from status reports, and
  prevention checklists for each of F1–F18.
- [./references/version-surface.md](./references/version-surface.md) — The exhaustive
  inventory of where a version number lives across a Go ecosystem (go.mod, go.work,
  vendor/, CI, Nix flakes, Dockerfiles, etc.) so you never miss a reference.
