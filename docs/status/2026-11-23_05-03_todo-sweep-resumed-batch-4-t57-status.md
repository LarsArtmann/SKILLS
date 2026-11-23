# TODO-Sweep Resumed Session — Batches 3 (tail) + 4 complete, T57 extraction in flight

> Session type: continuation of the whole-TODO-list directive
> (`docs/status/2026-11-23_02-36_todo-sweep-batches-1-3-status.md` covers
> batches 1–3; the owner then answered the three open questions with a
> blanket "execute the whole list" directive). This report covers the
> resumed run only: the batch-3 tail (T101 fix, T105, T153, T154), all of
> batch 4 (T62, T78, T91, T95, T96, T100, T107, T109, T87), and the start
> of batch 5 (T57 extraction executed, verification in flight).
> Repo state at write time: clean (daemon commits `7bc8319`..`97529b5`
> bundle this session's edits); cross-repo work tree
> `~/projects/website-template` exists un-committed (see b, T57).

## a) FULLY DONE (verified)

1. **T101 — check-agents-md.sh `--fix --budget N` repaired, twice over.**
   The resumed context named one bug (the `--budget` VALUE fell into
   `args[]`, became the scan target → silent "No AGENTS.md found under
   2000"). Fixing it exposed a second latent defect: the sed insert
   (`2i\\\n<!-- …`) emitted a literal `\n` before the marker — the real
   repo's marker at AGENTS.md:5 was hand-placed, so the sed path had never
   produced clean output anywhere. Rewrote the flag parse as a consuming
   while/shift loop (`--budget N` validated numeric, exit 2 on bad input)
   and the insert as an awk line-2 insert. Verified: marker inserts clean
   (`<!-- agents-md-size-budget: 40000 -->`), idempotent on re-run, works
   with flags in either order, missing/non-numeric value → exit 2 with
   usage, >100 KB scorer FAIL path exits 1 (168,923 B fixture), real repo
   run unchanged (marker present → no insert), `check-skills.sh` +
   `--selftest` still exit 0. shfmt + shellcheck clean. Note: the prior
   session's verification expectation ("24 KB fixture + `--budget 2000`
   must insert") contradicted the documented contract — insertion fires
   only when the size WARN fires, i.e. file > 30 KB default; the fixture
   could never trigger it. The arg-parse bug was real; that expectation
   was not.
2. **T105 — `how-to-golang/scripts/check-snippets.sh` created and
   validated both directions.** Parse-sweeps all 32 ```go blocks in the
   guide's markdown under five wrappers (as-is / `package p` / func-_
   body / hoisted imports + decls / hoisted imports + func-_ body — the
   guide's snippets are legitimately fragment-shaped: import lines
   followed by bare usage statements, mid-block imports), treats blocks
   containing `...` as deliberate placeholder SKIPs, parse-checks the 31
   `references/<topic>-NN/main.go` example files the same way (30 of 31
   are themselves fragments — only `domain-types-01` is a complete
   program, which the script compiles in its own temp module). Green on
   the real corpus: `PASS 61 OK, 0 fail, 2 skip`. Negative validation:
   an injected syntax defect in a copied tree fails with exit 1 and a
   `FAIL references/rules.md:175` line. shfmt + shellcheck clean.
3. **T153 — stale fan-out README trashed.** `~/.config/crush/skills/
   README.md` was a real file dated 2026-07-15 still listing removed
   skills (`improve-codebase-architecture`, `execution-mode`); nothing
   references the path except the TODO row itself and historical status
   reports; the canonical fan-out description is crush-config's tracked
   `skills/README.md` (fixed 2026-11-16) and home-manager does not deploy
   a skills README (no `.nix` wiring). Trashed via `trash`.
4. **T154 — stale second aggregation checkout trashed.**
   `~/projects/agent-skills`: working tree clean, `master` ==
   `origin/master` at `b1d2119`, no stashes, remote identical to the live
   layer's (`git@github.com:LarsArtmann/agent-skills.git`), nothing on
   this machine references the path. Trashed via `trash`.
5. **T62 — "install, don't wrap" landed in three legs.**
   (1) New subsection "Install, don't wrap: check for an installer before
   authoring" in `how-to-write-skills.md` (decision rule + why from the
   2026-10-30 MWG wrapper reversal + when layering IS right + the pointer
   rule for layered skills); TOC row description updated.
   (2) One-way pointers added: `html-report-kit/SKILL.md` Design
   Principles first bullet and `website-launch/SKILL.md` Common Pitfalls
   preamble — web-platform behaviour is owned by the installed
   `modern-web-guidance` skill; do not restate.
   (3) Restatement audit over repo skills: heading-overlap scan (5
   third-party SKILL.mds × repo) found only generic coincidences
   ("Core Principles", "Related Skills", "Routing"); distinctive-phrase
   scan (long body lines greped verbatim) found zero body restatements.
6. **T78 — five pinned offer-page numbers independently spot-fetched
   from primary bytes, all five verified; one sub-claim downgraded.**
   Baymard 40% "extra costs too high" verbatim in raw HTML (also 70.22%
   and 23.48 on the same page); NN/g 57% / 74% / 42% verbatim in the raw
   article (n=120 participants, 130k+ fixations); EU DSA Art. 25 in raw
   EUR-Lex text — titled "Online interface design and organisation",
   para 1 bans deceiving/manipulating interfaces (the "dark patterns"
   shorthand is the common name, recorded as such); FTC rule via Federal
   Register API — "Trade Regulation Rule on the Use of Consumer Reviews
   and Testimonials", 89 FR 68034, 16 CFR part 465, effective 2024-10-21;
   J. Retailing DOI via Crossref raw JSON — Janakiraman/Syrdal/Freling,
   "The Effect of Return Policy Leniency on Consumer Purchase and Return
   Decisions: A Meta-analytic Review", J. Retailing 92(2), 226-235
   (2016) — the guide's claim wording matches the source title exactly.
   Re-verification notes persisted into `offer-page/references/cut-list.md`
   (verification table) and `page-anatomy.md` (inline). Two incidents
   inside this item, see d) 1 and d) 2.
7. **T91 — objection→FAQ worksheet authored once, referenced from both
   layers.** `offer-page/assets/objection-faq-worksheet.md`: Part 1
   mining (sources ranked, verbatim-only extraction, clustering,
   frequency × proximity ranking, routing litmus: FAQ vs proof vs
   positioning vs roadmap) labeled as the first-customers strategy half;
   Part 2 assembly (fill-in table, entry rules, placement, voice gates
   per entry, sourcing gate) as the offer-page half. Referenced from
   `offer-page/SKILL.md` §6 and from `first-customers/SKILL.md` (by
   skill name — no cross-skill file path, per the T79 canon).
8. **T95 — CSP-safe worked example added to the kit's output guide**
   (`html-report-kit/references/html-output-guide.md`, new section before
   Component Catalog): the no-inline-handlers/no-style-attributes
   contract, the two patterns where inline style creeps in (proportional
   bars, one-off accent overrides) shown wrong vs CSP-safe (utility
   classes + variant class in the style block), and the scrollspy
   nonce/hash/delete note. Grounded against the installed
   modern-web-guidance security guide (inline scripts and styles need
   "nonces, hashes, or refactoring"; style ATTRIBUTES get no nonce
   rescue). Kit re-vendored; `sync-html-kit.sh --check` exit 0.
9. **T96 — WCAG 2.1/2.2 AA review of both Bauhaus templates, recorded +
   one fix applied.** Mechanically computed contrast ratios from resolved
   token values (rgba blends flattened over their surfaces). Real
   findings: light `--accent` #e63946 = 3.78:1 on paper FAILS SC 1.4.3 at
   the small sizes it is used at (`.eyebrow` 0.72rem bold, `h2 .num`
   0.82rem bold); `--text-faint` = 4.24:1 dark / 3.49:1 light (fine for
   decoration, must not carry meaning); light `--color-yellow` 1.33:1 is
   decorative-only (never used as text — safe). Structure: landmarks,
   `lang`, `:focus-visible` all present in both; dark template has an
   h1→h3 heading skip (sidebar label) and two unlabelled `<nav>`s; both
   have `<th>` without `scope`. Findings + fix options recorded in new
   `html-report-kit/references/wcag-review.md`; the uncontroversial fix
   applied to both templates (`prefers-reduced-motion` guard killing
   `scroll-behavior: smooth` + transitions); palette change left as an
   owner decision with two concrete options. Re-vendored; gates green.
10. **T100 — bdd-testing deepened with spec-design guidance.** New
    `bdd-testing/references/spec-design.md`: granularity tests (user-verb
    / assertion-count / refactor tests), Context semantics (precondition
    > input class > actor; outcome-named Contexts are an anti-pattern),
    two-level nesting max with the specialization test, setup layering
    (BeforeEach at the level where it becomes true, JustBeforeEach for
    construction, DeferCleanup beside the act, builders over shared
    fixtures), error paths as first-class specs (`errors.Is` identity +
    `errors.AsType` type, never strings), migration criteria from
    table-driven tests, and a smells→redesign table. Pointer added in
    SKILL.md step 3.
11. **T107 — living-reference freshness sweep, five skills, date-stamped
    in FEATURES.** go-release: version strings are semver walkthrough
    examples, not tool claims — no drift. nix-review: no version claims,
    structural. website-launch: npm registry spot-check — astro 7.4.13
    (still major 7, matrix `^7.0.3` holds), tailwindcss 4.3.5 (`^4.3.1`
    holds), `@astrojs/starlight` drifted 0.41→0.43 and caret semantics do
    NOT cover 0.x minors — noted in FEATURES as "re-verify at next site
    build". architecture-visualization: d2 v0.9.0 renders the skill's
    example snippet cleanly. deduplicate-code: `art-dupl` flags
    (`--type-aware`, `--sort total-tokens`, `--html`, `-t`) re-verified
    against `--help`. Five FEATURES rows date-stamped 2026-11-23.
12. **T109 — process-rule cluster, all three items.** (1)
    `scripts/scratch.sh --adopt <dir>` added (registers pre-helper /tmp
    dirs into the manifest so `--clean` covers them; refuses non-/tmp
    paths) — tested both directions, adopted this session's own scratch
    dirs. (2) New-linter first-run triage rule added to
    `linter-building/SKILL.md` Core rules (hand-verify a 2-3 finding
    sample before touching code; mostly-FP sample means the checker is
    the bug). (3) benchstat harness invariants stated as rules in
    `how-to-golang/references/performance-tuning.md` (same package, same
    benchmark names — pairing identity; same flags; `-count` ≥ 6;
    measure → fix → re-measure; never stitch pre-existing runs).
13. **T87 — offer-page first-real-run plan recorded** in ROADMAP under a
    new "Planned first real runs" section: target (owner's live offer —
    uptimeguru.io or InboxClean, owner picks), trigger, acceptance
    (9-section arc, 10 voice gates with pass/fail recorded, worksheet
    filled from real mining, QA executed, page deployed), and the aging
    step (README/FEATURES NEW→GREEN with dated run note). docs-gates
    pre-flight on the candidate lines: SAFE.

## b) PARTIALLY DONE

1. **T57 — website-template extraction EXECUTED, verification ~70%.**
   Done: full module copy from `templ-components/website` (excluding
   dist/, node_modules/); module path rewritten to
   `github.com/LarsArtmann/website-template` (11 files, zero leftovers;
   the templ-components LIBRARY dependency untouched — 12 refs in
   go.mod); `_templ.go` regenerated with the pinned templ v0.3.1100
   (system templ is v0.3.1020 — version drift would re-stamp generated
   files); workspace `replace` directives stripped from go.mod (they
   pointed at `../utils`, `../icons`, `../errorpage` — the copy broke
   confusingly until they went); `go mod tidy` + `go vet` + `go build`
   clean standalone. Parametrization per P7.2: `cmd/site/main.go`
   gitHubAPIURL now points at the template repo;
   `internal/pages/data.go` identity block marked PER-SITE CONFIG with a
   new `GitHubDefaultBranch` constant; `EditLink` now derives the branch
   from that constant and the content path corrected for the standalone
   layout (`/edit/<branch>/content/docs/<slug>.md` — the `website/`
   prefix from the monorepo dropped); `firebase.json` demo Cloud Run
   rewrites + `/demo/**` header block removed (templ-components-specific)
   and target renamed to `website-template`. Parity gaps editLink and
   lastUpdated turned out ALREADY CLOSED upstream (docs.templ:35,
   main.go:325) — the T57 row predates their implementation; verified
   present, EditLink improved. Remaining (the actual DoD): `go test
   ./...` currently fails on the golden suite — expected, the goldens
   embed the OLD site identity (lars.software URLs, templ-components
   GitHub links, star counts 138 vs the deterministic 0) — needs a
   golden regeneration; README.md rewrite (per-site adaptation guide:
   identity block, content/, firebase target); git init + detailed
   commit; `gh repo create LarsArtmann/website-template --private` +
   push (Q4 verdict: private, publishable later); clean-checkout clone
   build proof (the row's acceptance criterion).

## c) NOT STARTED (in directive scope)

Batch 5 rest: T58, T59 (see g1), T63 (first real triggered web task),
T92 (blind-compare first-customers), T94 (how-to-write-skills → skill
directory), T103 (skills-CLI hardening cluster), T125 (go-modularize
3-shape eval corpus), T136 (architecture-deepening first real run),
T139 (20-query trigger-eval battery), T33-partial (demo-video.md
reference polish + site-repo routing), T126 (adjudicate the CV watch
item to ROADMAP). Batch 6: T140, T141 (see g2). Batch 7 bundles:
T110–T116, T118–T121. Final wrap-up: TODO_LIST removal of the ~39 rows
now done across both segments, CHANGELOG entries for every change,
full gate battery re-run with quoted exit codes, `scratch.sh --clean`,
closing report.

## d) WHAT I FUCKED UP / ALMOST FUCKED UP

1. **Composed a Federal Register URL from pattern intuition** while
   writing the T78 verification row (`/2024/08/26/2024-18519/...`) —
   the real API `html_url` says 2024-08-**22**. This is the exact
   highest-frequency fabrication class verify-external-claims §0 bans.
   Caught it immediately by fetching the API's authoritative field and
   fixed the row — but I should never have written the URL by hand;
   take URLs from the fetched payload, always.
2. **Pinned a wrong sub-claim correction, then corrected it again.**
   First I wrote "the 4,532-adult n lives on Baymard's reasons research,
   not this page" — a guess about where the number lives. A background
   subagent search found n=4,532 on NO public Baymard page (likely the
   paywalled GC050 study or third-party paraphrase). Final state labels
   the sub-claim honestly ("appears on no public Baymard page — treated
   as unverified detail; keep or drop it but do not re-pin it"). Two
   writes where one verified write belonged.
3. **Two wasted T101 verification runs on undersized fixtures** (3.5 KB,
   then 24 KB — both under the 30 KB threshold the insert condition
   keys on). Size the fixture to the condition BEFORE running the check.
4. **check-snippets.sh shipped two bugs on first run** (slash-bearing
   temp filenames broke awk; the FAIL-branch diagnostic pipe aborted the
   whole script under `set -e` + pipefail mid-loop). Both caught by
   running it immediately; both fixed same-session. Lesson applied
   retroactively: exercise the FAIL path of a new script before trusting
   its PASS path — I validated the negative direction only after the
   rewrite.
5. **Copied go.mod WITH workspace replace directives** — the standalone
   build failed with confusing multi-path errors before the cause was
   found. Extraction checklist item (strip workspace state at copy
   time) now learned the hard way.
6. **`rg -rn` flag misuse** (third strike on this host per the hook's
   own message) — hook blocked it, corrected to `rg -n`.
7. Minor tool-discipline noise: two `edit` calls rejected by the
   read-before-edit guard (files only viewed via bash, not View);
   `shellcheck -q` does not exist on this install (my CLI misuse, noise
   only); one edit invalidated by my own earlier `shfmt -w` (mtime bump).
8. **Session-artifact commits are all daemon-heuristic** so far
   (`7bc8319`..`97529b5`). AGENTS §7 / decision B.g3 say the agent
   commits session artifacts with detailed messages; the reasoning
   survives in this report and will land in CHANGELOG at wrap-up, but
   the history for this segment is heuristic-titled. The closing commit
   (report + CHANGELOG + TODO_LIST) will carry the detailed message.

## e) WHAT WE SHOULD IMPROVE (this segment)

1. **URL-from-payload rule needs teeth**: I violated a written rule
   while the skill was loaded (the documented 2026-08-21 failure mode
   exactly). Candidate: check-skills check or authoring-guide line —
   "any external URL written into a doc must be a copy from fetched
   bytes in the same session" — but honestly the rule exists; the
   improvement is ME running a grep for hand-composed `/documents/`
   style paths before saving.
2. **Fixture-first verification**: before any positive/negative
   verification run, state the threshold the code keys on and size the
   fixture past it (d3). Costs seconds, saves reruns.
3. **New scripts: FAIL path first.** Validate-the-validator negative
   case BEFORE the green run (d4).
4. **Extraction checklist for Go module copies**: strip workspace
   replaces, regen templ with the PINNED generator version, expect
   goldens to embed site identity and plan their regeneration as a
   first-class step (they are the natural "did parametrization
   complete" oracle).
5. **DNS flapping playbook worked**: the fetch tool's Go resolver hit
   9.9.9.9 timeouts repeatedly while the system resolver was fine —
   retry-once recovered every time; agentic_fetch ran as background
   fallback. Keep that order.
6. **The scratch helper pays for itself**: adopting this session's own
   /tmp dirs into the manifest at creation time keeps the final cleanup
   to one `--clean`.

## f) NEXT THINGS (ranked, up to 50)

1. T57 finish: regenerate goldens (`UPDATE_GOLDENS=1`-style or equivalent
   — check the golden harness's regen flag) so `go test ./...` is green
   with the template identity.
2. T57 finish: write `website-template/README.md` (what it is, the
   per-site adaptation checklist: identity block, content/, firebase
   target, clean URLs, build.sh, DoD reference).
3. T57 finish: `git init` + detailed initial commit in website-template.
4. T57 finish: `gh repo create LarsArtmann/website-template --private
   --source . --push` (Q4 verdict).
5. T57 finish: clean-checkout proof — clone to /tmp, `nix shell` tailwind,
   `./build.sh`, expect dist/ (the row's acceptance).
6. T57 finish: strike the row in TODO_LIST at wrap-up; note in CHANGELOG.
7. g1 answer → T58: `websitelaunch` CLI in the template repo (doctor /
   init / check; stdlib-only, hard-capped; validate check against the
   extraction source).
8. g1 answer → T59: website-launch skill slim (Phase 3 → scaffold
   instructions, absorb references per disposition tables, FEATURES row,
   re-run evals/, close the ROADMAP 848-line question).
9. T94: `git mv how-to-write-skills.md how-to-write-skills/SKILL.md` +
   frontmatter + description-as-trigger rewrite + README/FEATURES/AGENTS
   (§2 tree, §5.6, §4.1, §6) reference updates + `link-skills-to-agents.sh`.
10. T63: first real triggered web task — modal/`<dialog>` end-to-end via
    MWG search→retrieve, record the trail, decide the disclosure-block
    question.
11. T92: blind-compare first-customers guided output vs no-skill baseline
    (two fresh sessions, comparator.md flow).
12. T103: skills-CLI hardening — sandboxed `skills remove` probe (fake
    HOME), pin/record CLI 1.5.22, investigate "well-known" providers,
    lockfile hash-drift check.
13. T136: first real architecture-deepening run against a small repo
    (verify brief path, kit rendering, grilling loop; age FEATURES).
14. T139: architecture-deepening 20-query trigger-eval battery (fresh
    session each; default provider per directive).
15. T125: go-modularize library-monorepo + over-modularized eval shapes
    per evals/README.md owner gate.
16. g2 answer → T140: comment on mattpocock/skills#1437 (github-voice
    draft; verify-before-filing pass on the claims).
17. g2 answer → T141: file the sibling-dependency issue upstream
    (verify-before-filing first: confirm the three sibling skills are
    unshipped on per-skill install).
18. T33-partial: demo-video.md reference polish (header-order pattern,
    Range/206 check, merge-semantics doc for pitfall #33,
    read-config-before-deploy, video-beats, placement-viewport check);
    route the site-repo remainder.
19. T126: adjudicate the CV two-currency watch item → ROADMAP standing
    watch with explicit trigger (next CV session).
20. T110: github-voice depth backlog — read the two archived f-tables,
    adjudicate each of the 19 items (execute cheap / strike obsolete /
    keep-list the rest).
21. T111: how-to-write-skills lessons additions — merge the routed
    discipline items into Hard-Won Process Lessons (dedupe against
    existing lines).
22. T112: linter-building depth backlog adjudication (assets/ worked
    example, negative eval, category count, jscpd docs, cross-model
    eval, aging, conflict-injection assert).
23. T113: how-to-golang verification backlog (govalid bench, second
    marker family, compile harness — now cheap via check-snippets.sh;
    bdd ginkgo-syntax re-verification).
24. T114: docs-health/session-infra backlog (live-site VERIFY mode,
    trigger tests, session-end.sh, origin audit, crush-log convention).
25. T115: signal-density tooling backlog (--signal --strict/--json,
    preamble split, unglossed-jargon hook, glossary guard, gloss-drift,
    formatter --check leg, README/FEATURES prose WARNs).
26. T116: docs-health + gate-infra backlog (deferred-architecture
    pattern, doc-gates recipe, persist eval artifacts at probe time,
    line-by-line diff audit, daemon exclusion, stale-lock line,
    fail-fixtures, run-eval --session, redundancy re-read).
27. T118: github-voice banner/habit backlog (wrap-tolerant UNSOLICITED
    regex, --kind body-pr example, persisted fixtures, refresh cadence,
    unsolicited-banner doc rows).
28. T119: repo-hygiene smalls (compile-check domain-types-01 — covered
    by check-snippets.sh, strike; shellcheck PATH; git mini-reference;
    FEATURES .buildflow row; SC2100 note; rebuild cadence; stale-claim
    sweep; verify-conversion.sh; GOCACHE note; gmail cc/bcc doc; retry
    doc; PASS-line convention).
29. T120: gmail/voice corpus-tooling backlog (resume tests, --since
    tests, surrogate fixture, corpus run, profile refresh, fixtures).
30. T121: go-aichat skill-sync backlog (contextwindow suite, claim-or-
    omit, pairing note, consumers doctrine, gap list, tripwire, CI, README
    path).
31. Wrap-up: remove the ~39 DONE rows from TODO_LIST (both segments:
    batches 1–4 + T57), pre-flight the edited table with docs-gates.
32. Wrap-up: CHANGELOG entries for every change (batches 1–3 from the
    prior report's file list + this segment's a/b items).
33. Wrap-up: full gate battery with quoted exit codes — check-skills +
    --selftest, check-shell, docs-gates (annotate ratchet), buildflow
    (expect exit 69 = green with exactly the 4 documented findings).
34. Wrap-up: `scratch.sh --clean` (manifest currently holds agents-fix-3,
    agents-fix-4, scratch-probe1 + any later adopts).
35. Wrap-up: closing status report + one detailed agent commit for
    report/CHANGELOG/TODO_LIST (B.g3).
36. Wrap-up: update FEATURES/README rows touched by this segment
    (bdd-testing spec-design, offer-page worksheet, how-to-golang
    check-snippets.sh, html-report-kit CSP+WCAG sections).
37. website-launch dependency-versions.md: add the starlight 0.41→0.43
    drift note next to the matrix (from T107).
38. AGENTS §1 stale cross-ref: "(added 2026-11-17 … TODO_LIST T62)"
    points at the OLD T62 numbering — re-anchor to the decision it
    actually came from.
39. html-report-kit output guide (710+ lines) has no TOC — repo
    convention wants one at >300 lines; cheap add.
40. ROADMAP Open Questions: fold in the starlight-drift re-verify
    trigger (T107 finding) so it is not lost.

## g) QUESTIONS FOR THE OWNER

1. **T58/T59 framing.** The checkpoint classified T58 and T59 among the
   13 "owner-gated BLOCKED" rows, but their Evidence column blocks them
   on T57 alone ("T57; 04:29 proposal §5.2/§6.4"), and T57's decision
   package is fully answered. Once T57's clean-checkout proof lands, are
   T58 (websitelaunch CLI) and T59 (skill slim) cleared to execute in
   this sweep, or do you want to review the extracted template repo
   first?
2. **External postings (T140/T141).** Your blanket directive says finish
   the whole list; the checkpoint had these gated on an explicit owner
   answer because they post publicly to mattpocock/skills under your
   GitHub identity (a comment on #1437 and a new sibling-dependency
   issue). Confirm posting both once their verify-before-filing +
   github-voice passes are done — or say "draft only" and I stage them
   as files.
3. **website-template golden/content shape.** The extracted template
   currently ships the templ-components landing/docs content as its
   example content, and the golden tests embed that content (star
   counts, marketing copy, lars.software links). Option (a): regenerate
   goldens as-is — template stays byte-identical to the proven site,
   new sites replace content + regen goldens themselves. Option (b):
   slim the landing to a neutral template landing now — cleaner first
   impression for reuse, more divergence from the extraction source to
   maintain. I recommend (a) (parity over polish; Q3 already keeps
   gogenfilter as the playground until the template is CI-green).
