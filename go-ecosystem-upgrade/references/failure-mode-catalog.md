# Failure-Mode Catalog — Go Ecosystem Upgrades

Extracted from 14 brutal self-review status reports spanning 2026-06-12 to 2026-07-26.
Each failure is annotated with the reports where it appeared, the root cause, and a
prevention checklist.

These are not hypothetical. Every single one happened, was documented in a status report,
and then happened again in a later session because the lesson wasn't encoded into a skill.

---

## Table of Contents

- [F1 — Respecting .gitignore on "ALL files" tasks](#f1)
- [F2 — go.work interference: GOWORK=off doesn't isolate](#f2)
- [F3 — Build-only verification (no go test)](#f3)
- [F4 — Skipping the delivering layer](#f4)
- [F5 — Blind sed/regex replacement corrupts local types](#f5)
- [F6 — Trusting incomplete CHANGELOGs](#f6)
- [F7 — Deleting and recreating git tags (proxy cache poisoning)](#f7)
- [F8 — Tagging from the wrong commit](#f8)
- [F9 — Hand-editing go.sum with sed](#f9)
- [F10 — Folding side-fixes into version bumps](#f10)
- [F11 — No baseline before migration](#f11)
- [F12 — Not committing (everything ephemeral)](#f12)
- [F13 — Stale vendor directories](#f13)
- [F14 — Dead/stale replace directives](#f14)
- [F15 — Treating checksum mismatches as nuisances](#f15)
- [F16 — Downgrade risk not flagged](#f16)
- [F17 — No tags on consumer releases](#f17)
- [F18 — Pseudo-versions in published go.mod](#f18)

---

<a id="f1"></a>
## F1 — Respecting .gitignore on "ALL files" tasks

**Reports:** go-mod-version-pin (504 modules), erraudit batch run (328 modules), go-error-family rollout (167 modules)

**What happens:** When asked to "make sure ALL go.mod files are on version X," the agent
uses `rg` or `glob` to enumerate files. Both honor `.gitignore` by default, silently
skipping 6–7 gitignored files (generated fixtures, typespec output, archived copies). The
"all" in the task is not achieved. The missed files are only discovered if a final
verification pass *happens* to use `--no-ignore-vcs`.

**Root cause:** `.gitignore` is a developer convenience for keeping `git status` clean.
It is NOT a completeness contract. For "all files" tasks, gitignore-respecting search is a
reasoning failure — "all" means all, including ignored and hidden files.

**Prevention:**
- Default to `rg --no-ignore-vcs --hidden` or `fd -H -I` for "ALL" enumeration tasks
- Run a final verification sweep with the same flags
- When a task says "all," treat gitignore as irrelevant to completeness

---

<a id="f2"></a>
## F2 — go.work interference: GOWORK=off doesn't isolate

**Reports:** httputil v0.5.0 (github-local-sync silent failure), go-cqrs-lite v4, go-error-family rollout, go-mod pin, templ-components (overview go.work severed)

**What happens:** `GOWORK=off go get foo@v1.2.0` reports "upgraded" but writes to
`go.work.sum` instead of `go.mod`. The `go.mod` is unchanged. The agent trusts the output
and moves on, leaving the consumer on the old version. Alternatively, the workspace file
references non-existent modules, causing `go mod tidy` to fail in confusing ways.

**Root cause:** Go's workspace mode is pervasive. Even with `GOWORK=off`, a broken
`go.work` file can influence where changes are written. The `go get` command's output is
misleading — it reports the intended action, not what was persisted to disk.

**Real example (httputil v0.5.0):** `go get` printed "upgraded httputil v0.4.0 => v0.5.0"
but `go.mod` still read `v0.4.0 // indirect`. Only `go.work.sum` was modified. The consumer
was silently left on the old version.

**Prevention:**
- Temporarily rename `go.work` → `go.work.bak` before `go get` + `go mod tidy`
- **Always verify the `go.mod` version after every `go get`** — grep the file, don't
  trust the command output
- Run a final batch verification that greps every consumer's `go.mod` for the target
  version
- Clean up broken `go.work` files that reference non-existent modules (these cause
  failures across sessions)

---

<a id="f3"></a>
## F3 — Build-only verification (no go test)

**Reports:** go-output/cmdguard session 3 (5 projects with test failures), templ-components,
httputil v0.5.0, go-mod pin, ecosystem execution, go-error-family rollout

**What happens:** The agent runs `go build ./...`, declares "all projects PASS, 0
failures," writes a triumphant summary, and moves on. Test failures — behavioral
regressions from changed defaults, removed APIs, or migrated patterns — are never
discovered until the user asks for a self-review or CI catches it.

**Root cause:** `go build` proves compilation. It proves nothing about behavior. Library
upgrades change defaults (CORS `DenyUnmatched`, ETag algorithm CRC32→FNV-64a, rate limiter
validation), rename methods, and shift semantics. These are invisible to the compiler.

**Real example (go-output/cmdguard session 3):** "29/29 projects build. 0 failures."
After user asked for self-review: 5 projects had test failures. "I would have shipped
these to production."

**Prevention:**
- `go test ./...` is non-negotiable after any version change
- Run tests BEFORE committing, not after — committing broken code to master makes it
  worse
- For breaking changes, run tests with `-race` on concurrent code paths
- Track which projects have been tested vs only built — don't lump them together

---

<a id="f4"></a>
## F4 — Skipping the delivering layer

**Reports:** templ-components v1.2.0 (CSS/visual layer skipped), go-sse (templ generate not run)

**What happens:** The agent verifies `go build` passes and declares done. But the library
delivers something beyond Go compilation — CSS assets, generated templ code, rendered HTML,
behavioral middleware. That layer is never verified. The Go code compiles; the visual
styling may be completely broken.

**Root cause:** Agents default to verifying what's easiest to check (compilation) rather
than what the library actually delivers. A UI library's value is in rendering, not in
compiling. The gap between "builds" and "works" is the delivering layer.

**Real example (templ-components v1.2.0):** v0.18.0 introduced a required
`templates/custom.css` that consumers must copy alongside `app.css`. The agent confirmed
Go compilation passed but never verified: (a) the CSS file exists in vendored copies,
(b) any consumer renders correctly in a browser, (c) the Tailwind v4 build picks up new
semantic tokens. "I have zero evidence either way."

**Prevention:**
- Identify the delivering layer in Phase 0 (pre-flight)
- For UI libraries: verify CSS assets present + imported, run `templ generate`, render a
  page in a browser, review golden snapshot diffs line-by-line
- For middleware: test the specific behaviors that changed (CORS, ETag, rate limiting)
- For any library with generated code: run the generator, confirm no diff

---

<a id="f5"></a>
## F5 — Blind sed/regex replacement corrupts local types

**Reports:** cqrs v4.1.0 (AggregateID→StreamID sed), go-output/cmdguard session 3 (v2.→cmdguard. sed), go-cqrs-lite v4 (encoding/json/v2→encoding/json sed)

**What happens:** The agent runs a global `sed` replacement across all `.go` files to
migrate a renamed API. But local domain types share the same method name —
`AggregateBoundary.AggregateID()`, `ConcurrencyError.AggregateID`, local `jsonv1tov2.Name`
— and get incorrectly renamed. Build failures require manual reversion across multiple
iterations.

**Root cause:** Method names collide across packages. A blind text replacement doesn't
know whether `.AggregateID()` refers to the library's interface method or a local domain
type's method. Scope matters.

**Real example (cqrs v4.1.0):** `sed -i 's/\.AggregateID()/\.StreamID()/g'` across all Go
files in KeyCountdown renamed local domain methods like `AggregateBoundary.AggregateID()`
and `ConcurrencyError.AggregateID`. KeyCountdown took 4 fix iterations to recover.

**Prevention:**
- Scope replacements to files that import the library (use `grep -l` on import paths first)
- Before replacing each occurrence, check the type's origin: is it from the library or
  the local domain?
- Prefer AST-based migration tooling (`go/ast`, `gofmt -r`) over text replacement
- Verify each file after transformation with `go build` or `go vet` before moving on
- Never run a migration script on a codebase you haven't enumerated imports for

---

<a id="f6"></a>
## F6 — Trusting incomplete CHANGELOGs

**Reports:** cmdguard/go-output bump (MustNewCommand removal undocumented), ecosystem-wide bump (undocumented removals), go-cqrs-lite v4 (8 removed aliases undocumented)

**What happens:** The agent reads the target library's CHANGELOG to determine what
breaking changes exist. The CHANGELOG omits key removals or renames. The agent declares
"no consumers use removed symbols" based on an incomplete list, then discovers breakage
during build verification.

**Root cause:** Library authors document additions thoroughly but often omit removals,
especially for symbols that were restored and then removed again. The CHANGELOG is a
human document, not a machine-verified API diff.

**Real example (cmdguard v2.8.0):** The changelog documented `MustNewCommand`'s
*restoration* in v2.6.1 but omitted its *removal* in v2.8.0. Two consumers silently broke.

**Prevention:**
- Don't rely solely on the CHANGELOG — grep the library's exported symbols yourself
- Compare the old and new version's exported API: `go doc -all` on both, diff the output
- When a build fails on an undefined symbol, check whether it was removed (not just
  renamed) before assuming it's a consumer bug

---

<a id="f7"></a>
## F7 — Deleting and recreating git tags (proxy cache poisoning)

**Reports:** cqrs v4.1.0 (v4.0.4 cache poisoning), go-error-family rollout (eventtest v0.1.0 re-published), templ-components (checksum mismatches), httputil v0.5.0 (eventtest checksums)

**What happens:** The agent releases a tag, discovers it was cut from the wrong commit,
deletes the tag locally and remotely, and recreates it from the correct commit with the
SAME version number. The Go module proxy (`sum.golang.org`) has already cached the original
checksum. Every consumer that fetches the recreated tag gets a checksum mismatch and fails
to build. The poisoned cache entry may persist for hours or days.

**Root cause:** The Go module proxy is append-only. Once a version's checksum is recorded
by `sum.golang.org`, it is immutable. Re-creating a tag with different content is a supply-
chain red flag that the checksum database correctly rejects. There is no "force push" for
the proxy.

**Real example (cqrs v4.1.0):** First release attempt used v4.0.3/v4.0.4 tags cut from a
commit BEFORE the aggregate→stream rename. Discovered the error, deleted + recreated tags
with same numbers. Proxy had cached old checksums. Every consumer failed. Fix: released as
v4.1.0 (fresh version numbers). The stale v4.0.3/v4.0.4 checksums persist in the proxy
indefinitely.

**Prevention:**
- NEVER delete and recreate git tags with the same version number
- If a tag is wrong, ALWAYS bump to a new version (v4.0.4 → v4.0.5 or v4.1.0)
- Document this rule prominently — it has poisoned the proxy multiple times
- If you encounter a checksum mismatch as a consumer, determine whether the tag was
  re-published (legitimate GOPRIVATE dev practice?) or genuinely concerning

---

<a id="f8"></a>
## F8 — Tagging from the wrong commit

**Reports:** cqrs v4.1.0 (v4.0.4 tags before stream rename)

**What happens:** The batch-release script tags from a parent commit that predates a key
change (rename, removal, fix). The published tag contains the OLD API surface. Consumers
that already migrated to the new API can't compile against the published tag.

**Root cause:** The tag commit is not verified to contain the expected changes. The release
script checks for pseudo-versions but doesn't verify symbol availability in the tagged tree.

**Real example (cqrs v4.1.0):** Tags cut from `ea581627`, but the stream rename was in
`52d7e353` which merged AFTER the batch release parent. Published v4.0.4 tags contained
`AggregateID` but NOT `StreamID`. Consumers migrated to `StreamID()` couldn't compile.

**Prevention:**
- Before tagging: `git merge-base --is-ancestor <key-commit> <tag-commit>` — verify the
  commit with your breaking change is an ancestor of the tag commit
- Or simpler: always tag from HEAD after confirming HEAD has what you need
- Verify symbol availability: `git show <tag>:path/to/file.go | head` — confirm the
  expected symbol exists in the tagged tree

---

<a id="f9"></a>
## F9 — Hand-editing go.sum with sed

**Reports:** templ-components (cqrs-htmx/adminui go.sum sed-edited), go-cqrs-lite v4 (stale checksums)

**What happens:** `go mod tidy` fails (often due to a checksum mismatch from a re-published
tag). The agent bypasses the tooling by manually `sed`-editing `go.sum` to swap hash lines
from one version to another, copied from another project's `go.sum`. This sidesteps the
tooling and produces a fragile, potentially inconsistent `go.sum`.

**Root cause:** The agent optimizes for "make the build green" at the cost of correctness.
`go mod tidy` failing means the dependency graph is broken upstream — that's the real
problem. Hand-editing `go.sum` masks it.

**Prevention:**
- NEVER hand-edit `go.sum` with sed. If `go mod tidy` can't run, the dependency graph is
  broken upstream and that's the real problem.
- Run `go mod verify` after any go.sum manipulation to confirm internal consistency
- If a checksum mismatch blocks `go mod tidy`, investigate the root cause (re-published
  tag? local-ahead? supply-chain concern?) — see F15

---

<a id="f10"></a>
## F10 — Folding side-fixes into version bumps

**Reports:** templ-components (bus.go fix, go.work bump, golden snapshot regen folded in), go-cqrs-lite v4 (encoding/json/v2 import swaps), httputil migration (CORS config changes)

**What happens:** While upgrading a library version, the agent encounters unrelated bugs
or issues. Instead of flagging them separately, it silently folds the fixes into the
version bump. Reviewers can't distinguish "intentional library upgrade" from "behavior
change to a concurrent event bus." The fix may be correct but its review is compromised.

**Root cause:** The "fix issues on sight" principle (from AGENTS.md) conflicts with scope
discipline. When the agent finds a real bug while doing a version bump, it applies the fix
without separating it into its own commit.

**Real example (templ-components v1.2.0):** While upgrading templ-components, the agent
also: fixed a `b.runCtx := nil` bug in `events/bus.go` (invalid `:=` on a struct
selector), bumped the `go` directive 1.26.4→1.26.5, removed a module from `go.work`'s
`use` block, and regenerated golden snapshots — all folded into the templ-components
upgrade. Each of these deserved its own review.

**Prevention:**
- Separate concerns → separate commits → separate review
- When you find an unrelated bug during a version bump, either: (a) stop and flag it, or
  (b) make the minimal unblocking change and call it out in giant letters
- Never ship a behavior change to concurrent code hidden inside a dependency upgrade

---

<a id="f11"></a>
## F11 — No baseline before migration

**Reports:** go-output/cmdguard session 3, cqrs v3 migration, go-cqrs-lite v4, ecosystem-wide bump, httputil v0.5.0

**What happens:** The agent starts migrating without recording the current build/test
state. When tests fail after migration, it can't tell whether the failure was caused by
the migration or was pre-existing. Valuable time is wasted investigating "regressions"
that were already broken on master.

**Root cause:** Many repos have red CI on master. The agent doesn't know this because it
never checked. Without a baseline, every failure looks like a regression.

**Prevention:**
- For every consumer: run `go build ./...` and `go test ./...` BEFORE any change
- Record pre-existing failures in a list — this is your defense against false regression
  claims
- Use `git stash` isolation to confirm: stash your changes, re-run tests, compare
- Clearly separate "broke by this update" from "was already broken" in your final report

---

<a id="f12"></a>
## F12 — Not committing (everything ephemeral)

**Reports:** go-sse session 3 ("Committed NOTHING — again"), ecosystem execution (zero commits across 15+ repos), go-cqrs-lite v4 (nothing committed), templ-components (nothing committed), go-error-family (nothing committed), erraudit (everything in /tmp)

**What happens:** The agent does excellent work but commits nothing. All changes sit in
working trees or `/tmp`. A sibling session (auto-git daemon or parallel agent) overwrites
the work, attributes it to "Unknown Author," or a reboot wipes `/tmp`. The work is lost or
irreversibly mangled.

**Root cause:** The "never commit unless asked" rule conflicts with multi-session safety.
When multiple agents work on the same repos, uncommitted changes are at the mercy of
whoever commits next. The agent follows the rule rigidly even when it knows committing is
the safe choice.

**Real example (go-sse session 3):** "This is the THIRD session where 'committed nothing'
is listed as a mistake. The sibling sessions are committing my work (attributed to 'Unknown
Author'), which means my changes ARE landing — just not under my name, and not in a
controlled way."

**Prevention:**
- For large bumps, ask for commit authorization upfront — don't wait until the end
- Commit immediately after each verification pass, not at the end
- Persist runner scripts and results in the repo, not `/tmp` — reboot = gone
- Run `git log --oneline -5` and `git diff --stat` at the START of every session to detect
  sibling interference

---

<a id="f13"></a>
## F13 — Stale vendor directories

**Reports:** go-error-family rollout (3 vendor trees hundreds of files behind), templ-components (bank-sync vendor), httputil v0.5.0 (KeyCountdown vendor), vendor elimination

**What happens:** Projects with committed `vendor/` directories fall behind their `go.mod`
over time. When the agent runs `go mod vendor` to sync a single dependency, it pulls in
hundreds of unrelated file changes (every stale dep catches up). The diff mixes "sync this
library" with "catch up everything else."

**Root cause:** Vendor directories that are committed but not kept in sync are worse than
gitignored ones — they lie about what the build uses. `go mod vendor` syncs the ENTIRE
dependency tree, not just the one library you bumped.

**Prevention:**
- Detect `vendor/` directories in Phase 1 (baseline)
- Run `go mod vendor` as part of the update flow, not as a reactive fix
- Be aware that vendor sync diffs can be large and mix unrelated changes — call this out
  in commit messages
- Long-term: consider eliminating committed vendor/ in favor of Nix FOD-based vendor
  hashing (see vendor elimination report)

---

<a id="f14"></a>
## F14 — Dead/stale replace directives

**Reports:** go-error-family rollout (docs-organizer dead replace for go-output/enum), go-cqrs-lite v4 (local replaces leaking to tags), httputil v0.5.0, templ-components

**What happens:** `replace` directives in `go.mod` or `go.work` point at local paths that
no longer exist, or at modules that have been moved/deleted. These cause build failures
("no such file or directory") or make the `require` version cosmetic (the replace always
wins for resolution).

**Root cause:** `replace` directives are added during local development and never cleaned
up. When the target module is moved, deleted, or published, the replace becomes stale.
Worse, replaces can leak into published tags (see F18).

**Prevention:**
- Audit `replace` blocks before and after bumps — drop targets that don't exist
- Run `go mod edit -dropreplace` cleanups periodically
- Consider a lint check that flags replaces whose target path doesn't exist
- Document intentional replaces in each repo's AGENTS.md

---

<a id="f15"></a>
## F15 — Treating checksum mismatches as nuisances

**Reports:** templ-components (SECURITY ERROR worked around with replace), erraudit batch (5 checksum-mismatch modules), go-error-family (eventtest re-published), httputil v0.5.0

**What happens:** The Go toolchain prints `SECURITY ERROR ... The bits may have been
replaced on the origin server, or an attacker may have intercepted the download attempt.`
The agent treats this as a nuisance blocking the build and works around it with `replace`
directives or `GONOSUMDB=*` instead of investigating WHY the published hash doesn't match.

**Root cause:** Checksum mismatches have three possible causes: (1) tags were force-pushed/
re-published (common in GOPRIVATE active dev), (2) the local clone is ahead of the
published version, (3) a genuine supply-chain concern. The agent doesn't distinguish
between them.

**Prevention:**
- A `SECURITY ERROR` deserves root-cause analysis, not a `replace` directive
- Run `go mod download -x` / compare `go list -m -json` to characterize the mismatch
- Determine: re-published tag? local-ahead? supply-chain?
- Even if the answer is "we force-push GOPRIVATE tags during dev," write it down so the
  next person doesn't re-investigate

---

<a id="f16"></a>
## F16 — Downgrade risk not flagged

**Reports:** go-mod-version-pin (147 modules downgraded 1.26.5→1.26.4)

**What happens:** The user asks to pin to version X. Most modules are already at version
X+1 (higher). The agent executes the pin without flagging that this is a mass DOWNGRADE.
Downgrades carry real risk — stdlib APIs used at the higher version may not exist at the
lower version. The risk is unmeasured.

**Root cause:** The agent treats all version changes as equivalent. A version DOWN is
riskier than a version UP. Compliance over craft — the agent executes without questioning
whether the task makes engineering sense.

**Prevention:**
- Before executing, compare the target version against what's currently declared
- If the change is a downgrade for any modules, flag it explicitly and confirm with the
  user: "You have X installed and most files are on X+1 — pinning to X downgrades them.
  Confirm?"
- Always pair a downgrade with a build/test sweep — text-match ≠ compile-success
- Separate upgrade/downgrade reporting — risk lives in the direction of change

---

<a id="f17"></a>
## F17 — No tags on consumer releases

**Reports:** go-output/cmdguard session 3 (zero tags on 14 consumers), go-cqrs-lite v4

**What happens:** The agent pushes code changes to consumer projects (migrated APIs,
bumped dependencies) but tags ZERO new releases. The projects are updated on master, but
no consumer can `go get` the fixes without pinning to a commit hash. The migration is
invisible to the Go module proxy.

**Root cause:** The agent treats "push to master" as the completion criterion. But without
a tag, the module proxy doesn't know the new version exists. External consumers are stuck
on the old version.

**Prevention:**
- Tag releases as part of the migration — don't leave code in an unreleased state on master
- After pushing, verify the tag resolves: `go get foo@v1.2.0` in a clean module
- Update CHANGELOG entries for every tagged release

---

<a id="f18"></a>
## F18 — Pseudo-versions in published go.mod

**Reports:** go-cqrs-lite v4 (replace directives leaking to tags), go-output/cmdguard session 3 (14 Pattern B sentinels)

**What happens:** A library's `go.mod` contains local `replace` directives (`=> ../foo`).
When the library is tagged, these replaces leak into the published `go.mod`. External
consumers see `v0.0.0-00010101000000-000000000000` pseudo-versions that cannot be resolved.
Every consumer that depends on the library fails to build.

**Root cause:** `go mod tidy` with a local replace generates a pseudo-version for the
replaced module. This pseudo-version is written to `go.mod` and published with the tag.
The Go module proxy cannot resolve `00010101000000` versions — they're sentinel values for
"unpublished local dependency."

**Prevention:**
- Strip ALL local `replace` directives before tagging
- Use a release script that: (1) strips replaces, (2) runs `go mod tidy` to resolve real
  versions, (3) verifies no `00010101` pseudo-versions remain, (4) tags, (5) restores the
  local replaces for continued development
- Add a CI check that rejects pseudo-versions in any `go.mod` on the default branch
