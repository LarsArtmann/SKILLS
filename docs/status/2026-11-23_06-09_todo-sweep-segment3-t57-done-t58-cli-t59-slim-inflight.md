# Status: TODO sweep segment 3 — T57 closed with proof, T58 built and validated, T59 slim in flight

> 2026-11-23 06:09 CET. Segment 3 of the whole-list TODO sweep. Prior
> segments: batches 1–3 (30 rows, `2026-11-23_02-36_*`), batch 4 (11 rows,
> `2026-11-23_05-03_*`). This segment executed T57's DoD, built T58's
> `websitelaunch` CLI end-to-end, and took T59 (skill slim) to ~85% before
> the owner ordered this report.

## TL;DR

- **T57 (website-template extraction): DONE.** Private repo
  `github.com/LarsArtmann/website-template` exists, pushed (6 commits), and
  passes the clean-checkout proof: fresh clone → `go vet` → full test suite
  → `bash build.sh` → complete `dist/`. The proof loop caught **three real
  defects** that all local testing missed (details in §d) — it earned its
  place as DoD.
- **T58 (websitelaunch CLI): DONE.** `doctor`/`init`/`check`, stdlib-only,
  in the template repo. Live-validated in all directions: doctor caught the
  real local templ drift; init scaffolded a fully working site end-to-end;
  check PASSes a scaffold and correctly FAILs the extraction-source monorepo
  site.
- **T59 (website-launch skill slim): ~85%.** SKILL.md rewritten onto the Go
  SSG scaffold flow, 6 references deleted (−1,040 reference lines), ROADMAP
  848-line question closed, FEATURES/README rows updated. **Missing:** gates
  run, evals re-run, common-pitfalls duplicate numbering cleanup, own
  commit (the daemon heuristic-committed most of it as `3003c88`).
- Batches 5 remainder / 6 / 7 and the final wrap-up: **not started** (see §c).

## a) FULLY DONE this segment

### T57 — website-template (cross-repo, `~/projects/website-template`)

Extraction completed against its Definition of Done:

1. **Monorepo leftovers fixed** (all found by the build-integrity test or
   clean-checkout proof, none by wishful reading):
   - `cmd/site/main.go`: `--repo-root` default `..`→`.`; `writeAssets`
     dropped the `repoRoot+"website"` join; `docsSource` reads
     `content/docs/` from repo root; sitemap lastmod sources de-prefixed;
     header comment de-monorepo'd.
   - `cmd/site/main_test.go`: `repoRoot` `"../../.."`→`"../.."`;
     `firebasePath` de-prefixed.
   - `build.sh`: `--repo-root ..`→`.`; hero copy de-templ-components'd.
   - The monorepo single-source docs mirror (`DocRef.RepoFile →
     docs/comparison.md`) materialized as `content/docs/comparison.md` with
     synthesized frontmatter; registry entry now slug-based.
   - `internal/build/llms.go` identity hardcoded ("# templ-components",
     templcomponents.lars.software, marketing blockquote) parametrized
     behind `build.SiteIdentity{Name,URL,Summary}` — build cannot import
     pages (cycle), so `main()` passes the identity block through;
     `pages.LLMSSummary(stats)` added to data.go (marked PER-SITE CONFIG).
     `build_test.go` uses a `testSiteIdentity()` fixture; `main_test.go`
     identity assertions now derive from `pages` constants (survive site
     adaptation).
   - `data.go` DemoURL comment corrected (Cloud Run proxy prose was stale —
     rewrites were removed in the prior segment).
   - `.firebaserc` target aligned with firebase.json (`website-template`).
   - `internal/build/build_test.go` + `internal/pages/golden_test.go` gofmt.
2. **Goldens regenerated twice.** First regen embedded JUNK stats —
   `goldenStats` walked `../../..` from `internal/pages`, which in the
   standalone layout exits the repo and (locally) silently scanned all of
   `~/projects` (0/0/748/1184 from unrelated repos). Fixed to `../..`,
   regenerated with the template's true derived stats (0 components / 0
   icons / 0 enums / 1 module — the deterministic pre-adaptation state).
3. **README.md written** — stack, build/test, content convention, per-site
   adaptation map, golden regen, templ pin, clean-checkout DoD (later
   extended with the websitelaunch fast path).
4. **Git + GitHub:** `git init -b master`, six detailed commits, private
   repo created via `gh repo create LarsArtmann/website-template --private
   --source . --push`. Commits: `129e6c4` (initial), `7fa675a` (track
   internal/build), `bcb9145` (golden stats path), `03fbb66` (Tailwind
   staging), `576ed88` (daemon, CLI files), `a41d4dc` (CLI).
5. **Clean-checkout proof PASS** — fresh clone of the pushed repo: `go vet`
   clean, `GOWORK=off GOEXPERIMENT=jsonv2 go test ./... -count=1` green
   (4 packages), `nix shell nixpkgs#tailwindcss_4 -c bash build.sh` →
   `dist/` complete (index.html + assets/app.css, 146 KB, library
   component classes verified present).

### T58 — websitelaunch CLI (in the template repo)

`cmd/websitelaunch/main.go` (stdlib-only; flag/go/format/os/exec/path/
regexp/strconv/strings) + `main_test.go` (4 tests):

- **doctor** — template-tree check, Go toolchain vs go.mod directive, templ
  CLI pin check (const `templVersion = "v0.3.1100"`; drift re-stamps
  generated files), tailwindcss/git/gh/firebase presence as WARNs, `gh
  auth status`, and a `gh repo view` name-collision probe. Findings print
  What/Why/Fix. Live run on this machine: exit 0, caught the REAL drift
  (system templ v0.3.1123 ≠ pin).
- **init** — scaffolds from a template checkout: walks the tree (skips
  `.git/ dist/ tailwind/ .firebase/ node_modules/ cmd/websitelaunch`),
  applies global substitutions (module path everywhere INCLUDING
  `_templ.go` — so no templ regen needed at scaffold time; bare repo slug
  for the GitHub API URL) and identity substitutions (SiteName/SiteTitle/
  SiteDescription/SiteURL/GitHubDefaultBranch/AuthorName/AuthorURL/
  DemoURL-optional in data.go; firebase targets in firebase.json +
  .firebaserc). Identity replacements are **required-and-count-verified** —
  a drifted template fails loudly instead of half-adapting. Every `.go`
  file gofmt'd after substitution (`go/format`). Library references
  (PkgGoDevURL, comparison content) deliberately preserved.
- **check** — DoD as code: monorepo-leftover scan (Tailwind `../templates`
  imports, `@source "../` globs, `filepath.Join(…, "website")` — markdown
  exempt because docs legitimately SHOW monorepo examples), un-rewritten
  template identity (`module != template && templateModule string
  present`), `go vet ./...` + `go test ./... -count=1` (sets
  `GOWORK=off GOEXPERIMENT=jsonv2` itself), dist artifact completeness.

**Live validation (all three subcommands, both directions):**
doctor exit 0 with real warnings; `init` scaffolded
`github.com/larsartmann/demo-site` into `/tmp/t58-site` (97 files) → goldens
regen, full suite green, `build.sh` idempotent, `dist/index.html` carries
the new identity; `check` **PASS** there; `check` on the extraction-source
`~/projects/templ-components/website` **correctly FAILs** with every
expected monorepo detection (repoRoot+"website" joins in main.go/main_test,
`../templates/custom.css`, `@source "../` globs). That fulfills the row's
"validate check against the extraction-source site" requirement.

**README (template repo) updated** with the doctor/init/check fast path and
the two post-init regeneration steps (goldens `-update`, `--update-csp` —
the scaffold's CSP header is stale until identity settles).

### T59 — website-launch skill slim (~85%, see §b)

## b) PARTIALLY DONE

### T59 — skill slim (in flight, uncommitted tail)

Done:
- **SKILL.md (840→862 lines):** frontmatter description/tags → Go SSG
  template pattern (legacy-Astro maintenance trigger kept); intro notes the
  2026-10-27 decision and the no-new-Astro-sites rule; Environment section
  (pnpm lines → go/templ/tailwind guidance); Phase 0 opens with
  `websitelaunch doctor` (manual checks kept for what a CLI cannot:
  credentials, domain gate); **Phase 3 replaced** — 3.1 scaffold-from-
  template (clone → doctor → init → goldens+CSP regen), 3.2 "what init does
  not do" manual map (content+registry pair, landing sections, @theme
  accent, favicon 28×28 literal-hex guidance folded in from the retired
  website-creation-details.md, DemoURL/PkgGoDevURL), 3.3 demo video
  (unchanged content, renumbered); **Phase 4 replaced** — `bash build.sh` +
  `websitelaunch check`, preview server switched to `python3 -m http.server
  --directory dist`; Phase 7 CI step adapted (two-job Go build; template
  workflow file noted as tracked follow-up per decision Q5); Commit
  discipline checkpoint 3 → `check` PASS; **DoD folded inline** from the
  retired definition-of-done.md (human gates: README/GitHub/DNS/demo-video/
  two-repos/status-report discipline — the mechanical half is `check`);
  **Common Pitfalls slimmed 22→18** (dead Astro/pnpm entries dropped:
  Vite overrides, legacy-peer-deps, MDX, package-lock, stray pnpm deps,
  lockfile-manager mismatch; added templ-drift, GOEXPERIMENT, and
  "identity drift is checkable" entries); 0.0 maintenance checks adapted
  (go.mod probe, template built-ins instead of astro.config knobs); GH
  Pages decision table fixed (fix-csp.mjs → hash-pinned CSP; astro build →
  bash build.sh); all §3.10/§3.11 cross-refs renumbered.
- **6 references deleted** (git rm): file-manifest (196), dependency-
  versions (186), color-palette (314), definition-of-done (74),
  ci-workflow (151), website-creation-details (119) = **−1,040 lines**;
  their SKILL.md links removed; dangling links in surviving references
  fixed (common-pitfalls ×2, design-inspiration ×1).
- **common-pitfalls.md**: ownership-split header note (what doctor/check
  now mechanize; [legacy] semantics + date); **11 entries marked
  `[legacy Astro]`** (pnpm/node PATH, Vite, pnpm v11 scripts,
  legacy-peer-deps, MDX, stray deps, package-lock, pnpm cwd,
  astro-og-canvas, pnpm v11 traps, lockfile-manager mismatch).
- **ROADMAP.md**: the 848-line question **CLOSED** with the honest outcome
  (SKILL.md 862 — DoD fold; corpus −1,040; split brains eliminated;
  allowlist retained with rationale).
- **FEATURES.md + README.md** rows rewritten (Go SSG template + CLI, T59
  note, absorbed-references list).

Missing (T59 tail):
1. `scripts/check-skills.sh` + `--selftest` NOT yet run after the slim
   (link-lint, signal, structure over the edited skill).
2. `evals/` re-run (T59 row requires it: trigger eval battery — the
   description changed materially).
3. common-pitfalls.md **duplicate numbering** (pre-existing: 31/32/33 each
   appear twice with different content) — noticed, not fixed.
4. Own detailed commit — the daemon heuristic-committed most of the slim
   (`3003c88`, 9 files); FEATURES/README/ROADMAP still dirty. The report +
   dirty files get one agent commit per doctrine B.g3.

## c) NOT STARTED (remaining sweep work)

- **Batch 5 remainder:** T94 (how-to-write-skills → skill dir), T63 (MWG
  modal/dialog end-to-end + disclosure-block verdict), T92 (first-customers
  blind-compare), T103 (skills-CLI hardening probes), T125 (go-modularize
  eval corpus shapes; owner gate in evals/README to check), T136 (first
  real architecture-deepening run), T139 (architecture-deepening 20-query
  eval), T33-partial (demo-video.md polish + route site-repo remainder),
  T126 (adjudicate two-currency-gate-2 watch → ROADMAP).
- **Batch 6:** T140 (comment on mattpocock/skills#1437), T141 (sibling-
  dependency issue) — both gated on g2 (see §g).
- **Batch 7:** T110–T116, T118–T121 bundle adjudication (read each row's
  archived f-table, execute cheap items, strike obsolete, keep-list with
  reasons).
- **Final wrap-up (mandated):** remove ~44 DONE rows from TODO_LIST.md
  (41 prior + T57/T58, +T59 when closed); CHANGELOG entries for ALL changes
  across all three segments; full gates battery with quoted exit codes
  (check-skills + --selftest, check-shell, docs-gates, buildflow expecting
  69); `scripts/scratch.sh --clean` + trash loose /tmp litter (`t57-clean`,
  `t58-site`, `t58-fb-before.json`, plus the prior segment's t101/t105/mwg/
  baymard/ftc files); closing status report; one detailed agent commit.

## d) TOTALLY FUCKED UP (session defects — all caught and fixed)

1. **First golden regeneration embedded junk stats.** `goldenStats`
   (`golden_test.go`) still walked `../../..` — the monorepo path. Locally
   that silently scanned the ENTIRE `~/projects` tree and I committed
   goldens containing 748 enums / 1,184 modules from Lars's unrelated
   repos. Caught only because the /tmp clean clone panicked on a
   permission-denied sibling (`/tmp/.tmp7QWX8s/locked`). Fix: `../..` +
   second regen (`bcb9145`). Lesson: a regen oracle must be path-verified
   in a clean environment BEFORE trusting its output.
2. **Initial commit silently missing `internal/build/` (9 files).** The
   machine-global `~/.config/git/ignore` carries a `build/` pattern that
   matches any depth; `git add -A` skipped the package. Clean-checkout
   proof failed `go vet` ("no required module provides … internal/build").
   Fix: repo-local `!internal/build/` negation (`7fa675a`).
3. **site.css still pointed at monorepo siblings** (`@import
   ../templates/custom.css` + eleven `@source ../<pkg>/**` globs) — the
   import hard-fails standalone, the globs SILENTLY match nothing (CSS
   would ship without library component classes). Fix: build.sh stages
   custom.css/safelist.css/class-inventory from the resolved module into
   `./tailwind/` (ADR-0045 corpus), site.css imports the staged copies
   (`03fbb66`).
4. **build.sh was not idempotent:** plain `cp` inherits the module cache's
   0444 mode, so the second run failed with permission denied. Fix:
   `install -m 644` + `rm -rf tailwind` restage.
5. **`.firebaserc` was copied but never substituted** — `filepath.Ext()`
   returns `.firebaserc` for it, so the text-file filter skipped it. Fix:
   `textFiles` dotfile allowlist (also applied to scanLeftovers). Caught by
   the unit test.
6. **check's `go vet` lacked `./...`** → "no Go files" FAIL on a healthy
   scaffold; and **monorepo patterns false-positived on markdown code
   examples** (theming/installation guides legitimately show `@source
   "../..."`). Both caught by the live both-direction validation; fixed.
7. **First CLI draft defects** (never committed): leftover junk `report()`
   stub, `monoregoPatterns` typo, a literal-`\n` pattern that could never
   match, redundant broken `want` field. Caught by re-read before build.
8. **mvdan/sh `printf -- '---\n…'` glitch** wrote a mangled frontmatter
   head for comparison.md — redone with `printf '%s\n'`.
9. Two multiedit/python assert failures on whitespace-exact table rows —
   fixed by re-reading exact bytes. (Recurring class: trusting rendered
   output over raw bytes.)
10. **Scaffold CSP staleness discovered late:** identity rewrites change
    inline-script/JSON-LD content, so a fresh scaffold FAILS build until
    `--update-csp` runs. Documented in init's next-steps + README; could
    have been an init flag (noted in §e).

No irreversible damage. The daemon heuristic-committed mid-work twice
(`576ed88` in website-template; `3003c88` in SKILLS) — expected per AGENTS
§5.12, both times benign.

## e) WHAT WE SHOULD IMPROVE

1. **Clean-checkout proof is the highest-ROI verification step in this whole
   session** — it caught defects 1–3, every one invisible to local tests
   (wrong-but-passing oracles, gitignore shadows, silent glob no-ops).
   Codify it: any extraction/scaffold task proves from a fresh clone, not
   from the working tree. (Candidate for how-to-write-skills.md process
   lessons + crush-config lessons.md.)
2. **Validate the validator in both directions before trusting it** —
   check's self-bugs (§d.6) were found only because I ran it against BOTH a
   known-good and a known-bad tree. Make that the standard for any new
   gate/check tool.
3. **Machine-global gitignore `build/` is a standing hazard** for every Go
   repo with `internal/build` (templ-components' own
   `website/internal/build` is exposed the same way — unverified). Fix at
   the source (owner call, §g.1) or document repo-local negations as the
   fleet pattern.
4. **init could self-heal CSP**: an `--update-csp` invocation (or post-init
   step) inside init would remove one manual step from every scaffold.
5. **Golden-regen + identity edits ordering:** the DoD order (identity →
   regen goldens → update CSP → build) is now written down in the template
   README; the skill should mirror it verbatim to prevent drift between the
   two documents.
6. **common-pitfalls.md numbering is a mess** (duplicates 31–33, ordering
   17–19 before 1–16) — a 15-minute cleanup next time the file is touched.
7. **Daemon bundling:** T59's changes landed as a 9-file heuristic commit;
   the detailed record lives only in this report. For multi-file skill
   rewrites, commit BEFORE the daemon's next sweep (timer is minutes).

## f) NEXT — up to 40 queued items

**T59 tail (do first):**
1. Run `scripts/check-skills.sh` (quote exit code) + `--selftest` after the slim.
2. Re-run `website-launch/evals/` battery (description changed materially).
3. Fix common-pitfalls.md duplicate numbering (31/32/33 ×2).
4. Agent-commit the T59 tail + this report (detailed message).

**Batch 5 remainder:**
5. T94: convert `how-to-write-skills.md` → `how-to-write-skills/SKILL.md` (frontmatter, README/FEATURES/AGENTS §2/§5.6/§4/§6 updates, link script).
6. T63: modal/`<dialog>` end-to-end via MWG; record search→retrieve trail; decide the mandatory-disclosure-block question.
7. T92: blind-compare first-customers guided output vs no-skill baseline (fresh sessions).
8. T103: skills-CLI hardening probes in a fake HOME (remove --all vs symlinks, version pin, well-known providers, lockfile hash drift).
9. T125: go-modularize eval corpus — library-monorepo + over-modularized shapes (check evals/README owner gate first).
10. T136: first real triggered architecture-deepening run against a repo; age FEATURES/README 🆕.
11. T139: architecture-deepening 20-query trigger eval, fresh sessions, record per-arm results.
12. T33-partial: demo-video.md reference polish + route the site-repo remainder (emeet rebuild, product videos, og upgrades) to ROADMAP.
13. T126: adjudicate the two-currency-gate-2 production-watch row → ROADMAP watch entry (needs a real CV session; cannot force).

**Batch 6 (gated on g.3):**
14. T140: github-voice-drafted comment on mattpocock/skills#1437 (fork outcome, configurable destination, missing-sibling-skills).
15. T141: verify-before-filing pass + file the sibling-dependency issue (codebase-design/grilling/domain-modeling unshipped on per-skill install).

**Batch 7 adjudication bundles (T110–T116, T118–T121):**
16. T110 github-voice profile/tooling depth (19 f-items: evals.json prompts, userContentEdits scope, ban-list helper, monthly mode, …).
17. T111 how-to-write-skills Hard-Won Lessons additions (~24 discipline items across 4 archived reports).
18. T112 linter-building depth (assets/ worked example, negative eval, jscpd docs, conflict-injection assert).
19. T113 how-to-golang verification backlog (govalid benches, ginkgo syntax re-verification).
20. T114 docs-health/session-infra (live-site VERIFY mode, trigger tests, session-end.sh, crush-log convention).
21. T115 signal-density tooling (--strict/--json, preamble metric split, unglossed-jargon hook, drift guards).
22. T116 docs-health/gate-infra (deferred-architecture pattern, daemon exclusion rules, per-check fail-fixtures, run-eval --session).
23. T118 github-voice banner/habit (wrap-tolerant UNSOLICITED regex, persisted fixtures, banner doc rows).
24. T119 repo-hygiene smalls (compile-check domain-types-01, git-integration mini-reference, cmp.sh PASS-line convention, …).
25. T120 gmail/voice corpus-tooling (collect-corpus resume tests, surrogate-pair fixture, profile refresh).
26. T121 go-aichat skill-sync (contextwindow suite, claim-or-omit pass, consumer-side gap list, README install path).

**Final wrap-up (mandated):**
27. Remove all DONE rows from TODO_LIST.md via docs-gates `--pre-flight` on the edited table.
28. CHANGELOG.md entries for every change across all three segments (file lists in `2026-11-23_02-36_*`, `05-03_*`, and this report).
29. Full gates battery with quoted exit codes: check-skills + --selftest, check-shell, docs-gates run, buildflow (expect 69 = 4 documented findings).
30. `scripts/scratch.sh --clean` + trash loose /tmp litter (t57-clean, t58-site, t58-fb-before.json, t101/t105/mwg/baymard/ftc files).
31. Closing status report + single detailed agent commit for report/CHANGELOG/TODO_LIST.

**Cross-repo follow-ups surfaced this segment:**
32. website-template: add the two-job CI workflow (build via nix go+tailwindcss → deploy; Phase 7 says the template owns it once it exists).
33. website-template: `--update-csp` (or auto) as an init post-step; consider `init --ci` scaffolding the workflow.
34. templ-components: verify whether `website/internal/build` is committed despite the global `build/` ignore (same hazard as §d.2) — likely YES since it predates; confirm, then either fix global ignore or add the same negation.
35. gogenfilter rebuild on the template (decision Q3: "eventually, keep hand-maintained until then") — ROADMAP, not now.
36. Codify "clean-checkout proof" + "validate the validator both directions" in how-to-write-skills.md process lessons.
37. crush-config `references/lessons.md`: module-cache 0444 + cp mode inheritance; golden-oracle path verification; gitignore-shadow class.
38. website-launch eval queries: refresh any Astro-era trigger phrasings to cover the Go SSG description.
39. T33 remainder once routed: emeet-pixyd composition rebuild, first 20–30s product video (site choice open), og:image-from-poster upgrade.
40. Watch item after next real CV session: T126's policy-payoff evidence bar (named artifact + measured advance, not split-license).

## g) Questions I cannot answer myself

1. **Machine-global gitignore:** `~/.config/git/ignore` contains `build/`,
   which will keep silently eating `internal/build/` (and any `build/`
   dir) in every future clone/commit on this machine — the template now
   defends itself with a local negation, but new repos will hit it again.
   Remove/narrow the global pattern (I can do it on your OK — it is your
   global config), or keep it and standardize repo-local `!internal/build/`
   negations across the fleet?
2. **T59 acceptance:** the slim eliminates the split brains and deletes
   1,040 reference lines, but SKILL.md itself GREW 840→862 because the DoD
   human-gate checklist (from the retired definition-of-done.md) was folded
   inline. Accept as-is (ROADMAP question closed with that rationale), or
   push the file under ~500–848 by moving the DoD checklist + Visual QA
   gate into a retained reference (which partly reverses the disposition)?
3. **Batch 6 external postings (carried g2):** the repeated blanket
   directive was interpreted as green light, but both T140/T141 post
   publicly under your name on mattpocock/skills — confirm "post publicly"
   vs "stage drafts only" one final time before I execute batch 6.

---

**Repo state at report time:** SKILLS `master` at `3003c88` (daemon, 9
files: the T59 slim); FEATURES.md/README.md/ROADMAP.md dirty (T59 tail),
committed with this report per B.g3. website-template `master` at
`a41d4dc`, clean, all 6 commits pushed to the private remote.
