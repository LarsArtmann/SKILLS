# Status Report — TODO-sweep session: batches 1–3 (65 open rows triaged, 30 closed, gates recovered)

**Date:** 2026-11-23 02:36 · **Session:** single-session directive sweep ("GET SHIT DONE — the WHOLE TODO LIST"), executed top-down in 7 planned batches; batches 1–3 (quick fixes, cross-repo lessons, scripts/tooling) executed, status taken at the user's checkpoint request before batch 4.

**Starting state:** 78 open TODO rows (65 TODO, 13 BLOCKED), check-skills 37/37 exit 0 + selftest 3/3, docs-gates standing debt (2 audit-all findings, cadence 17/15).

## Scope line — VERIFIED here (fresh commands, exit codes quoted)

- `./scripts/check-skills.sh` → **exit 0** (all 37 skills; only the allowlisted website-launch 835-line WARN remains)
- `./scripts/check-skills.sh --selftest` → **exit 0** (3/3)
- `bash scripts/check-shell.sh` → **exit 0** (full-severity shellcheck over the edited scripts)
- `nix run …docs-gates -- run .` → freshness FRESH · routing 0 unrouted · cadence ARCHIVE-HEALTHY (15 unarchived, at threshold) · annotate ratchet **360/372** (no new damage)
- Full `buildflow` battery run twice this session (markdownlint/shellcheck legs ✔; final expected-green state = exit 69 from the 4 documented file-size findings — see d4 for the exit-code caveat)
- MWG uninstall proof executed live (dir + lock entry removed, exactly 1 skill, snapshot restored byte-identical via `diff -r`)
- crush-config lesson commit: `3036120` (T83+T155)

## Scope line — NOT verified here

- T101's `--fix --budget` insertion leg is **broken and unfixed** (found at report time — see d2)
- Batches 4–7 untouched: all medium-content, heavy-chain, external-filing, and bundle rows
- All 13 BLOCKED rows untouched (owner-gated by definition)

---

## a) FULLY DONE (30 rows closed + standing debt drained)

**Batch 1 — offer-page cluster + quick doc fixes:**

1. **T72+T85** — voice-and-gates.md: primary local path is now Hemingway/hand-count (with the grade formula); textstat marked NOT-installed with the 2026-11-10 verification; syllable-script decision recorded inline (hand-count wins).
2. **T74** — trigger probe RE-RUN in 3 fresh `crush run` sessions (offer-page / first-customers / website-launch — 3/3 correct, boundary arm explicitly declined offer-page) and persisted to `offer-page/evals/iteration-1/trigger-probe.md`.
3. **T76** — first-customers trigger-eval.json reconciled with the offer-page split: q4 de-paged (pricing strategy stays first-customers), q7 flipped `should_trigger:false` (page teardown now routes to offer-page); battery 9 positive / 11 negative, JSON valid.
4. **T77** — `offer-page/evals/evals.json` authored: 3 task prompts (build / teardown-audit / waitlist-fix) with expected_output shaped by the skill's own procedure, per the first-customers pattern.
5. **T79** — +213.16% deduplicated to exactly 2 canonical mentions (page-anatomy.md + CHANGELOG); voice-and-gates, AGENTS §5.5, FEATURES now link instead of restating.
6. **T80** — worked-example Step 4 carries "page rules live in offer-page; this is the worked instance".
7. **T81** — B2B/technical worked micro-example added (on-call/SRE, jargon-survival rule stated).
8. **T84** — SKILL.md re-read against the condensing checklist: **verdict PASS** (113 lines, named failure modes + reasons intact; no condensing needed — documented here as the record).
9. **T86** — audit mode now persists the fix list to disk (default `<target-repo>/docs/offer-page-audit.md`), chat-only audits named as the failure.
10. **T67** — markdown-table formatter-safety lesson (no literal pipes in cells; `git diff -w` after every formatter run) added to Hard-Won Process Lessons.
11. **T88** — how-to-write-skills.md gained an 11-row TOC (real headings only, fence-aware).
12. **T89** — gmail_drafts.sh self-test gained the byte-exact `cmp` fixture (the `$( )` comparison cannot see a lost trailing newline); self-test passes.
13. **T90** — link-skills-to-agents.sh `--list` prints the lockfile summary (18 third-party, overlap count). **Bug found+fixed en route:** both `--list` and `--check` used top-level lockfile keys (4) instead of `.skills` keys (18) — the rule-2 hazard guard had been silently dead.
14. **T93** — deliberate non-fix recorded in check-skills.sh header (`.go` asset gate would duplicate AGENTS §1 + buildflow).
15. **T97** — originals 1:1 audit: every seed maps except the 4 documented exceptions + **new orphan found**: `nix-flake-migration.md` (territory owned by nix-review) — recorded in AGENTS §5.1.
16. **T98** — brutal-self-review → architecture-review cross-reference added (structural findings hand off, not adjudicated inline).
17. **T99** — the 2026-11-12 §a.3 gate run did NOT cover buildflow (check-skills only); the full battery was run this session over the current tree instead — markdownlint/shellcheck legs green within it.
18. **T102** — domain-types.md companion-skills cross-refs (go-error-modernization, data-model-review).
19. **T104** — runtime-symlink install model documented in the guide's Where-to-Place-Skills (4 encoded consequences).
20. **T106** — status-report/docs-health boundary re-verified (holds; rule stated once); docs-health description gained the reverse disambiguation clause, then was condensed back under the 1024-char gate (1129 → under limit, check-skills exit 0).
21. **T108** — docs-health reference upgrades: post-annotation re-read gate (3-step: check-rows → reader re-read → diff accounting) in resolving-items.md + TOC entry; `premise re-checked <date>` convention in harvest-guide.md ledger rules.
22. **T117** — gmail_eml_export.sh `--limit` decided: DOCUMENT, don't auto-paginate (bounded evidence export); usage + NOTE now state the cap semantics and remedy; self-test green.

**Batch 2 — cross-repo lessons:**

23. **T83 + T155** — crush-config `references/lessons.md` + commit `3036120`: subagent cold-start/quarterly-credit protocol (incl. "2 failures → solo pivot", richer than the TODO row per the 11-18 report) and the Crush-bash `$PWD` vs jq relative-path trap.

**Batch 3 — gates, AGENTS shrink, tooling:**

24. **T60** — MWG uninstall proof end-to-end (see scope line).
25. **T69** — art-dupl (6) + jscpd (3) advisory findings triaged and recorded as deliberate non-fixes in AGENTS §5.11 (single-file-program clones; deliberately-standalone gmail scripts whose sourced-common-file would dangle at the /tmp sudo call site).
26. **T148** — fork provenance extracted to **`docs/skill-forks.md`** (architecture-deepening fork, MWG channel, skills-CLI findings, 2026-09-14 merge assessment full record, Growth-stack sourcing detail); AGENTS keeps compact pointers.
27. **T70** — AGENTS.md 56.8 KB → ~50.3 KB + justified budget marker (`agents-md-size-budget: 52000`, T101-adjacent mechanism); size WARN cleared; the two remaining advisories (dated headings, commit hashes) are this repo's evidence-citing style and stay.
28. **Standing debt drained (docs-gates 2 red findings):** unharvested §f items annotated (11-15 §f4 `done at e7f3882`; 11-18 doctrine decision resolved); **two-tier cross-skill link canon codified at §5.5 head** (tier 1 name-only for independently installed pairs / tier 2 guard-pinned relative links — the gates already enforced it); 2026-11-10_00-46 and 2026-11-12_22-18 fully annotated + `git mv`'d to archived/ → cadence 17→15, ARCHIVE-HEALTHY.
29. **On-sight fixes:** gmail-drafts canonical `## Verification status` table (clears the standing check-13 WARN); check-skills extract_desc now strips YAML quotes (naming-review WARN was a false positive from quoted-scalar handling); missing 2026-11-12 CHANGELOG entry late-landed; `docs/skill-forks.md` linked from AGENTS.
30. **Committed:** `7f1e783` (gmail table + YAML-quote fix) + `3036120` (crush-config); remaining work was bundled by the daemon into heuristic commits (§5.12 known behavior — see e4).

## b) PARTIALLY DONE

1. **T101** — `--fix` mode added to check-agents-md.sh: offender listing works (verified: line-numbered output, repo scan green, scorer survives a synthetic 292 KB file and FAILs >100 KB). **The `--fix --budget N` insertion leg is broken** — `--budget`'s VALUE lands in `args[]`, `target` becomes `--budget`, the script finds no AGENTS.md and silently exits 0 (found while verifying for this report; not fixed).
2. **Offer-page eval battery (T75, BLOCKED)** — its prerequisite artifacts are now complete (probe persisted, evals.json authored, first-customers battery reconciled); only the owner spend decision remains.
3. **check-skills WARN surface** — down to 1 (allowlisted website-launch length); the size advisory work left 2 style advisories standing deliberately.

## c) NOT STARTED (43 rows)

- **Heavy chains:** T33 (site-repo follow-ups), T57→T58→T59 (website-template extraction chain), T63 (MWG triggered run), T92 (first-customers blind-compare), T94 (guide → skill dir), T103 (skills-CLI hardening), T125 (go-modularize eval shapes), T136 + T139 (architecture-deepening real run + battery), T153, T154 (fan-out README / second checkout fates)
- **Medium content:** T62, T78, T91, T95, T96, T100, T105, T107, T109
- **Bundle rows:** T110, T111, T112, T113, T114, T115, T116, T118, T119, T120, T121
- **External filings:** T140, T141
- **BLOCKED (owner-gated):** T30, T58, T59, T68, T71, T75, T122, T123, T124, T126, T129, T134, T150, T151

## d) TOTALLY FUCKED UP (honest, ranked)

1. **Broke check-skills.sh twice in a row** while adding quote-stripping to an awk program inside a single-quoted shell string: first a literal `['"]` char class (terminated shell quoting), then an apostrophe inside the awk COMMENT re-broke it. Both caught immediately by bash's parser + the selftest leg — which is exactly why the selftest exists — but I touched a load-bearing gate without dry-running the awk in isolation first.
2. **T101's `--fix --budget` leg shipped broken and I declared it done** ("verified" with a test whose exit 0 was actually the silent no-op path). The exit-code-discipline lesson (quote `echo $?`, never trust a quiet zero) — encoded in this repo's own SESSION-START.md — was violated by exactly the tool I was extending.
3. **Overclaimed an annotation:** wrote "CHANGELOG entry landed" for the 2026-11-12 gmail session before checking (no such entry existed). Caught on verification, corrected by late-landing the real entry instead of editing history to fit my claim.
4. **Swallowed exit codes with `| tail`/`| head` twice** (first buildflow run reported "exit 0" through a pipe; had to rerun for the true 69). Same lesson class as d2.
5. **Edit-tool discipline:** 3 "must read first" rejections (multiedit on unread files) — recoverable friction, but each was a guess-edited old_string that had not been re-read.
6. **Daemon scope control lost:** milestone edits were bundled into heuristic commits within minutes (§5.12 known); the detailed-message commit discipline held only for `7f1e783` and `3036120`.

## e) WHAT WE SHOULD IMPROVE

1. **Exit-code hygiene needs a mechanical habit, not a memory:** every piped verification should end in `>file; echo $?`. This session violated the repo's own written rule twice (d2, d4).
2. **Gates edits deserve fixture-first development:** when touching check-skills.sh's awk, write the fixture BEFORE the edit (the selftest caught both breakages only because it existed).
3. **"Verify the fix" must include the fix's OWN flags:** T101's broken leg was reachable by one command I never ran to conclusion.
4. **Description edits need a length pre-count:** the docs-health 1024-char overflow cost 3 edit rounds; `wc -c` on the extracted description before editing would cost one.
5. **AGENTS.md has a ratchet now — keep it:** the budget marker only works if growth beyond it triggers extraction to docs/ (the marker text says so; sessions must obey it).
6. **The two-tier link canon (§5.5 head) should get a check-skills guard eventually** — right now it is prose enforced by convention; the existing check 8 pins only 4 pairs.

## f) NEXT TASKS (up to 50, priority order)

1. **Fix T101's `--fix --budget` arg parsing** (exclude `--budget VALUE` from `args[]`; add a fixture proving insertion) — 10 min, closes the d2 defect
2. **T57** website-launch stage 1: extract the templ-components Go SSG into `website-template` (unblocks T58→T59)
3. **T58** `websitelaunch` CLI (doctor/init/check) in the template repo
4. **T59** website-launch skill slim + evals rerun
5. **T62** land "install, don't wrap" rule + third-party-restatement audit
6. **T63** first real MWG-triggered web task (modal/dialog) + disclosure-block decision
7. **T78** spot-fetch the 5 pinned offer-page numbers
8. **T136** first real architecture-deepening run against a repo
9. **T139** run the 20-query trigger battery (needs g1)
10. **T140** post the #1437 outcome comment (needs g2)
11. **T141** file the sibling-dependency upstream issue (needs g2)
12. **T92** first-customers blind-compare eval (needs g1)
13. **T94** convert how-to-write-skills.md into a skill directory
14. **T95** CSP-safe worked example in html-report-kit guide
15. **T96** WCAG AA review of both Bauhaus templates
16. **T100** deepen bdd-testing spec-design guidance
17. **T105** how-to-golang check-snippets.sh compile sweep
18. **T107** living-reference freshness sweep (go-release/nix-review/website-launch/arch-viz/dedup)
19. **T109** process-rule codification cluster
20. **T91** objection-to-FAQ worksheet asset split
21. **T103** skills-CLI hardening cluster (sandbox the remove --all test)
22. **T125** go-modularize eval shapes (library-monorepo + over-modularized)
23. **T153** trash-or-regenerate the stale deployed fan-out README
24. **T154** trash-or-repoint the stale `~/projects/agent-skills` checkout (verify unpushed work first)
25. **T33** site-repo follow-ups (video work — needs the site repos)
26. **T110** github-voice 19-item depth backlog
27. **T111** Hard-Won Lessons additions (2026-09/10 corpus)
28. **T112** linter-building depth backlog
29. **T113** how-to-golang verification backlog
30. **T114** docs-health/session-infra backlog
31. **T115** signal-density tooling backlog
32. **T116** docs-health + gate-infra backlog
33. **T118** github-voice banner/habit backlog
34. **T119** repo-hygiene smalls
35. **T120** gmail/voice corpus-tooling backlog
36. **T121** go-aichat skill-sync backlog
37. Owner: **T68** agent-skills branch policy (the 194-file commit on the feature branch)
38. Owner: **T71** live-chat guidance restore
39. Owner: **T75** offer-page eval spend
40. Owner: **T122–T124** CV root-module policy rulings
41. Owner: **T129** BuildFlow staged-copy root fix
42. Owner: **T134** accept exit-69-as-green note (T69's triage is now recorded — the row is closable on your OK)
43. Owner: **T150/T151** fork sync/removal policy
44. **T126** watch first production two-currency gate-2 run (rides the next CV session)
45. **T30** README status flip after the first real upstream PR run
46. Add a check-skills guard for the two-tier link canon (e5-6)
47. Trash `/tmp/mwg-uninstall-proof` + `/tmp/agents-md-test` scratch after this report is accepted (kept as evidence until then)
48. Commit the aggregation-repo topology if this session created none (content edits propagate via symlink — no action expected)
49. Re-verify FEATURES counts after batch 4+ edits (drift rule from the 11-10 report)
50. Consider promoting the "exit-code through a pipe" rule from e1 into how-to-write-skills Hard-Won Lessons (it is currently only SESSION-START + this report)

## g) QUESTIONS (cannot be answered from inside the session)

1. **Eval spend:** T139/T92/T75 each need many fresh `crush run` sessions, and the 2026-11-10/18 provider state was gemini+huggingface depleted, hyper dead, synthetic capped — zai glm-5.3-flash the survivor. Green-light running the batteries on zai flash (slower, cheaper) now, or wait for a credit refresh? And is `crush run` per-query acceptable as the "fresh session" unit?
2. **External postings (T140/T141):** both target mattpocock/skills as you. Post the #1437 outcome comment and file the sibling-dependency issue directly via `gh` after verify-before-filing + github-voice drafting, or stage the drafts in this repo for your review first?
3. **T57 green light:** extracting the templ-components SSG into a new private `website-template` repo creates a new GitHub repo and moves code out of templ-components (per the 2026-10-27 decisions §A Q0–Q5). Proceed now under those recorded decisions, or is anything about name/visibility/parity-gaps stale?

---

*Probes are snapshots; the offer-page probe must be re-run if its description ever changes. This report is a point-in-time artifact — bring current via docs-health → ANNOTATE.*
