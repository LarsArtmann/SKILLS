# Status Report — TODO-sweep segment 4: batch 5 complete (9 rows), batch 6 externally blocked, batch 7 + wrap-up remain

**Date:** 2026-11-23 06:59 · **Session:** continuation of the standing
directive sweep ("GET SHIT DONE — the WHOLE TODO LIST"); resumed on the
owner's repeated blanket directive, which per the segment-3 interpretation
resolved the three pending §g questions as: batch 6 posts publicly, T59
accepted as-is, global gitignore untouched (owner's config; repo-local
negations only).

**Scope line — VERIFIED here (fresh commands, exit codes quoted):**
check-skills.sh exit 0 (only the allowlisted website-launch 861-line WARN
stands) · --selftest 3/3 · check-shell.sh 0 · check-agents-md.sh 0 ·
sync-html-kit.sh --check 0 · 11 agent commits this segment
(`2b7b78b`…`e2bb955`) + 4 daemon heuristic commits raced in (all verified
to carry correct state, §d). Cross-repo: templ-components `38063b57`
(gitignore negation) + `cf725c9d` (deepening brief) — LOCAL, unpushed.

## a) FULLY DONE this segment (11 rows closed)

1. **T59 tail — website-launch slim closed.** (a) The slim's rewritten
   description was 1204 chars — over Crush's 1024 load limit, caught by
   check-skills (`FAIL: Crush will refuse to load this skill`); re-condensed
   to 1010 with all trigger phrases retained; gates then exit 0.
   (b) Eval battery re-run as `evals/iteration-2/`: 3 fresh subagents, one
   per iteration-1 prompt, 20/20 assertions PASS — and all three responses
   routed through the NEW Go-SSG flow unprompted (websitelaunch
   init/doctor/check, go.mod branching in maintenance mode). (c)
   common-pitfalls duplicate numbering fixed: the "Dependency Pin
   Fragility" sub-series (31/32/33) renumbered 35/36/37; series now unique
   1–37 (verified programmatically; zero inbound numeric refs existed).
   (d) Detailed commit `2b7b78b` (SKILL.md itself landed in daemon
   `dbfe2ed` — verified byte-identical to intent).
2. **Queued item 34 — templ-components gitignore hazard.** Verified all 8
   `website/internal/build/` files are git-TRACKED (gitignore can't touch
   tracked files — no data loss had occurred); the hazard is future files.
   Added repo-local `!website/internal/build/` negation (verified
   `git check-ignore` exit 1 = negation beats the machine-global `build/`),
   committed `38063b57` with the hazard provenance.
3. **T94 — how-to-write-skills.md → proper skill directory.** `git mv` to
   `how-to-write-skills/SKILL.md`; YAML frontmatter (trigger-context
   description, disambiguates against the third-party skill-creator; named
   to avoid that install collision); the 11 pattern bodies moved verbatim
   to `references/skill-patterns.md` with a summary table left in the entry
   point (698 → 472 lines, the guide's own <500 rule); TOC converted
   table→bullet list (check 9's contract); two root-relative links
   re-anchored; all live references updated (AGENTS §2/§4/§5.6/§6/§8 +
   skill count 37→38, README links + inventory row, CONTRIBUTING, FEATURES
   PARTIALLY→FULLY, SESSION-START, ROADMAP question RESOLVED); fan-out
   symlink created + aggregation-repo commit `ddcaae4` (scoped to the one
   symlink — a large foreign media-use update was in flight there);
   `sync-html-kit.sh` consumer discovery taught the instructional-mention
   case (first `kit_non_consumers` entry — the guide teaches the Artifact
   rule but never produces reports; 8 vendored kit files were wrongly
   auto-created and removed). Commits `306264a` (deltas) over daemon
   `86e10e7`/`b817e62` (bulk).
4. **T125 authoring half — go-modularize corpus shapes 6–7.** Eval 6
   (library-monorepo: real proxy consumers, versioning-train cost,
   policy-currency-needs-artifact) and eval 7 (over-modularized at scale:
   23 modules, workspace-fiction gate-5 verdicts, build-tag anti-signal,
   FM#11 container check, six-helper no-consumer-variance cluster), both
   in assertion form per field_rules. Commit `20d7845`. **The full R16
   battery remains owner-gated** per evals/README.md — not overridden by
   the blanket directive (the gate is written into the row itself).
5. **T139 — architecture-deepening trigger battery.** All 20 queries of
   `trigger-eval.json`, one fresh `crush run` session each (two parallel
   batches of 10): 10/10 positive arms → architecture-deepening; 10/10
   negative arms → their legitimate owners (architecture-review,
   architecture-visualization, full-code-review, data-model-review,
   pareto-planning, naming-review, stack-selection, status-report) or
   NONE. **20/20.** Record at `evals/trigger-eval-2026-11-23.md` incl. the
   re-run rule (description edits on companion skills re-run arms 11–13).
6. **T136 — architecture-deepening first real run.** Target: templ-components
   (100 commits/100d, 49 ADRs). Scope: the examples/demo ↔ visualtest ↔
   cmd/tc triangle (hottest paths, 227/1273 file touches). Fresh-context
   scan subagent returned 8 evidence-backed findings (route registry
   restated in ~10 files with observed drift; 625-line bespoke CSP fixture
   re-implementing demo endpoints; hand-maintained tc dependency maps with
   3 fix-commits-in-100; nonce-consumer fact in 6 places + 2 sync tests;
   4-layer mirror-guard apparatus; +3 minor). 5-card editorial brief
   rendered through the vendored kit (first deepening brief in the target's
   series; no overlap with the 2026-11-01 review), committed `cf725c9d`.
   Step 4 stop-and-ask recorded — **grilling loop awaits the owner's
   candidate pick** (top recommendation: export the demo route manifest).
   FEATURES row aged NEW→FULLY_FUNCTIONAL with the run note; README row
   + New-skills paragraph updated (ten→nine New).
7. **T63 — first real triggered MWG task.** Search→retrieve trail recorded:
   `search "accessible dialog modal"` → 10 candidates judged by
   description → `retrieve "dialog,platform-controls-dismiss-dialog,
   prevent-page-scroll-under-modal-dialog,accessibility,html"` (1,343
   lines). Built a delete-confirmation `<dialog>` demo applying the
   retrieved rules (declarative `command="show-modal"`; NO
   role/aria-modal/focus-trap/Esc-handler; `autofocus` on the SAFE action;
   `form method="dialog"` + returnValue reset in the close listener; the
   `dialog:modal`/`::backdrop` overscroll scroll-lock pair — NOT
   body overflow:hidden). Verified end-to-end in headless Chromium: full
   cycle PASS (open via invoker, :modal, delete arm, returnValue reset,
   reopen, cancel arm). **Disclosure-block verdict: KEEP** — the
   "### Modern Web Guidance" section is the provenance mechanism (≤75-word
   cap per guide, "never guess ids/quotes from memory"); it is cheap and
   prevents hallucinated provenance; waive nothing.
8. **T103 — skills-CLI hardening probes (sandboxed, CLI pinned
   `pnpm dlx skills@1.5.22`).** (P1) `remove --all -g` is **symlink-safe**
   for the repo-skill fan-out (the scan counts only `entry.isDirectory()`;
   untracked symlinks in ~/.agents/skills AND agent config dirs survive)
   but **lockfile-leaky**: the removed skill's lockfile entry SURVIVES
   (v1.5.22 bug); also `remove` without `-g` scans the CWD and silently
   finds 0. (P4) **False green REPRODUCED**: a per-source tree-fetch
   failure prints `✗ Failed to fetch tree` and then concludes `✓ All
   global skills are up to date`; and `skillFolderHash` is NEVER consulted
   by update — the hash is bookkeeping, not a drift check. This confirms
   "transient tree-fetch failure" as the 2026-11-03 trigger (was one of
   three hypotheses). (P3) Well-known providers decoded from CLI source:
   non-forge https URLs probe `/.well-known/agent-skills/index.json` then
   `/.well-known/skills/index.json` (agentskills.io discovery 0.2.0).
   (Lockfile location: `$XDG_STATE_HOME/skills/`, fallback `~/.agents/` —
   probe HOME alone does NOT relocate it.) Recorded in
   `docs/skill-forks.md` + AGENTS §5.10 update. Commit `382f6f7`.
9. **T92 — first-customers blind-compare + comparator.md authored.** The
   never-defined "comparator.md flow" is now a file (procedure + honest
   blinding note). Run: two fresh subagents, identical godup 0→1 prompt;
   graded against 10 assertions from the skill's own method.
   **with_skill 10/10 · baseline 3 full + 4 partial (~5/10).** The delta
   concentrates in METHOD DISCIPLINE (stage trees with anchors, verbatim
   phrase-bank mining, pricing mechanics, countable pre-sell gate,
   sequencing rules, activation/TTV, no-premature-A/B) — general knowledge
   already covers diagnosis instinct/positioning/channel choice, recorded
   honestly. Commit `e2bb955`.
10. **T33-partial — demo-video polish + routing.** Range/206 check added
    (integration step 9, runnable node one-liner; Safari/iOS streaming
    dependency stated); header-order pattern added (step 7 + checklist:
    catch-all FIRST, immutable glob LAST, pitfall-37 pointer); pitfall 37
    gained the MERGE-semantics block (same key → later block wins,
    different keys union, no glob-specificity tiebreaker — verified-live
    phrasing); NEW pitfall 38 (deploy against the wrong Firebase site from
    not reading the `.firebaserc` mapping before `firebase deploy`; ties to
    the Phase 0 probes). Placement-viewport + video-beats were ALREADY
    covered by the T59 slim — verified present, not duplicated. Site-repo
    remainder (emeet composition, product videos, og:image, CI deploy
    under Q5) routed to ROADMAP. Commit `09e6f98`.
11. **T126 — adjudicated.** Needs a real production CV session; cannot be
    forced. Routed to ROADMAP "Planned first real runs" as a watch item
    (eval arm passed 2026-11-15; this is the production confirmation).

## b) PARTIALLY DONE

1. **T140/T141 — batch 6, verification complete, POSTING BLOCKED.**
   api.github.com:443 is TCP-unreachable from this machine right now
   (3/3 fails; github.com:443 works; DNS fine; general net up) AND the gh
   token is invalid (`gh auth status`: token in hosts.yml invalid;
   refresh is an interactive owner action). Everything short of posting is
   done: github-voice loaded; **T141 claim verified and PRECISON-CORRECTED
   from source** — upstream `improve-codebase-architecture` calls the
   siblings at 4 sites (lines 13/64/66/71, verified from the aggregation
   repo's git history AND a fresh shallow clone), and the siblings DO
   exist upstream (`skills/engineering/codebase-design`,
   `skills/engineering/domain-modeling`, `skills/productivity/grilling`)
   — so the correct claim is "a PER-SKILL install ships only the one
   directory; the callees are absent at runtime", not "the skills don't
   exist". The mechanical per-skill-install proof attempt in the sandbox
   failed on CLI syntax (local-path@skill parsing), so the strongest
   available evidence is the CLI's documented single-directory copy
   semantics (AGENTS §5.9) + the 2026-11-15 live observation. Drafts NOT
   yet written to docs/drafts/ — that was next when connectivity was
   ruled out.
2. **Scratch:** /tmp holds t63 (dialog demo + MWG guides), t103-home
   (sandbox), t141-upstream (clone), t139-runs (20 eval outputs), t136
   pngs + logs — cleanup deferred to wrap-up by design (evidence for this
   report).

## c) NOT STARTED (remaining sweep work)

- **Batch 7 bundle adjudication:** T110, T111, T112, T113, T114, T115,
  T116, T118, T119, T120, T121 (read each archived f-table, execute cheap
  items, strike obsolete, keep-list with reasons).
- **Final wrap-up (mandatory):** remove all DONE rows from TODO_LIST.md
  (~50 across four segments now) with docs-gates `--pre-flight` on the
  edited table; CHANGELOG entries for every change in ALL segments; full
  gate battery re-run with quoted exit codes (check-skills/--selftest/
  check-shell/check-agents-md/docs-gates/buildflow-expecting-69);
  `scripts/scratch.sh --clean` + trash the /tmp litter; closing report;
  one detailed agent commit.
- **Queued cross-repo follow-ups (§f items 32–40 from segment 3):**
  website-template CI workflow (two-job build+deploy); websitelaunch init
  `--update-csp` self-heal; lessons codification (clean-checkout proof,
  module-cache 0444 cp, golden-oracle path verification) into
  how-to-write-skills + crush-config lessons.md; website-launch eval query
  refresh for Go SSG phrasing.
- **BLOCKED (owner-gated, by design):** T30, T68, T71, T75, T122, T123,
  T124, T129, T134, T150, T151 + the R16 battery gate (T125's other half).

## d) TOTALLY FUCKED UP (honest, ranked)

1. **The brief HTML lost its entire CSS on first write.** My generator
   computed `head` (doctype + 842 lines of kit CSS) and then concatenated
   `before_main + my_main + after_main` — head never made it in. Caught by
   the render-verification pass (CSS token grep returned zero) plus the
   sample's FIXTURE comment surviving in the output; regenerated correctly
   (1,202 lines, verified render + tokens). The class of bug: composing
   files by string surgery instead of checking the assembled artifact.
2. **Link-depth error in the new skill:** wrote `../../docs/...` from
   `how-to-write-skills/SKILL.md` — two levels up ESCAPES THE REPO
   (resolves to ~/projects/docs). The gate caught it (resolved-path FAIL);
   embarrassing because the FAIL message itself was the first hint. Root
   cause: reasoning "repo root is up" without counting levels.
3. **The known traps I hit AGAIN despite the resumption brief warning
   about them:** `printf -- '---\n...'` mangled the T103 probe file
   (frontmatter became `--===`; fixed with python); `rg -rn` blocked by
   the hook a FOURTH time on this host. These are encoded lessons; I
   still reached for the wrong tool first.
4. **`curl` used once for a connectivity check** — pitfall #17 of the very
   skill I was polishing bans curl in Crush. Zero harm (read-only HEAD),
   but it is the exact "known rule, wrong reflex" pattern.
5. **T92 arm outputs persisted as structured summaries, not verbatim
   transcripts.** The subagent reports are the only source; by the time I
   wrote the eval files the full texts were long and I condensed them with
   a provenance note. Weaker artifact than the "an eval is not done until
   it is on disk" bar — the GRADING quotes are verbatim, the outputs are
   not. A tee'd re-run would fix it; not done (spend vs value).
6. **Probe misdiagnosis before source read:** the first `remove --all`
   run found 0 skills and I hypothesized CLI agent-config discovery for
   two rounds before noticing MY probe omitted `-g` (the CLI was scanning
   the CWD exactly as documented). Cost ~10 minutes; the correct rule is
   read-the-flag-semantics first, speculate second.
7. **Daemon race pattern (expected, §5.12):** three of my four intended
   multi-file commits lost files to daemon sweeps (`dbfe2ed` SKILL.md,
   `86e10e7`/`b817e62` T94 bulk, `cdfc042` eval record). All verified
   byte-correct after the fact; the detailed messages document the work
   regardless. Mitigation exhausted — the daemon timer is ~minutes and
   some verifications take longer than that.
8. **First http.server attempt bound nothing:** port 8765 was already held
   by a foreign service (`project-discove`); my 404 came from THAT
   service. Should have checked the listener before serving.

## e) WHAT WE SHOULD IMPROVE

1. **Assemble-then-verify for generated artifacts:** the CSS-less brief
   would have shipped from a less careful session. Add to the
   architecture-deepening skill (or the kit guide): after generating from
   a template/sample, grep for the template's structural tokens (style
   block, a known class) BEFORE rendering.
2. **Eval artifacts should tee the raw output at dispatch time.** The
   comparator flow now says "persist both outputs" — it should say
   "persist the RAW transcript, unedited" and the dispatcher should write
   to a file as the report arrives. My summaries are a workaround for not
   having done that.
3. **The rg -rn hook block is now 4 strikes.** Consider adding the rule
   to the repo's Hard-Won Process Lessons (it lives in the hook text +
   resumption briefs but apparently not in the guide where sessions look
   first).
4. **Pre-flight connectivity for batch-6-style work:** gh auth status +
   a TCP probe to api.github.com before drafting would have surfaced the
   block at session start instead of mid-batch. The drafts-on-disk rule
   then applies (github-voice already mandates docs/drafts/, not /tmp).
5. **Sandbox lockfile probes must export XDG_STATE_HOME** — now encoded
   in skill-forks.md, but it cost a confusing round to discover.

## f) NEXT — ranked (the remaining sweep + follow-ups)

1. Batch 7 adjudication: T110–T116, T118–T121 (11 bundle rows — read each
   archived f-table, execute the cheap items, strike obsolete, keep-list
   with reasons; do not pretend-execute).
2. Wrap-up: TODO_LIST removal of all DONE rows (~50) + docs-gates
   --pre-flight on the edited table.
3. Wrap-up: CHANGELOG entries for all four segments.
4. Wrap-up: full gate battery re-run, exit codes quoted (incl. buildflow
   expecting 69, docs-gates expecting 360/372-or-better).
5. Wrap-up: scratch.sh --clean + /tmp litter (t103-home, t141-upstream,
   t63, t139-runs, t136 pngs).
6. Wrap-up: closing status report + one detailed commit.
7. T140: post the outcome comment on mattpocock/skills#1437 (BLOCKED:
   api.github.com unreachable + token invalid — drafts to docs/drafts/
   ready to post the moment both clear).
8. T141: file the sibling-dependency issue (precision-corrected claim
   from §b; same block).
9. website-template: CI workflow (two-job build+deploy; the Q5-sanctioned
   home for the CI-deploy class).
10. websitelaunch init: --update-csp self-heal (scaffold currently fails
    build until the manual regen step runs).
11. Lessons codification: clean-checkout proof, module-cache 0444 cp,
    golden-oracle path verification → how-to-write-skills + crush-config
    lessons.md.
12. website-launch eval query refresh for Go SSG phrasing (iteration-2
    reused the sales-era queries on purpose; a Go-SSG-flavored query set
    would test the new trigger surface directly).
13. Push decision: templ-components has 3 local commits (38063b57,
    cf725c9d + the earlier one) — unpushed by policy.
14. architecture-deepening grilling loop (owner picks a candidate).
15. offer-page aging run (owner picks the target page).
16. R16 battery (owner-gated) — evals 6–7 are ready to ride along.
17. The e5 improvements above (assemble-then-verify rule; tee-raw-output
    rule; rg-rn lesson in the guide).
18. T30/T68/T71/T75/T122–T124/T129/T134/T150/T151 — remain owner-gated
    (no action until the owner rules).

## g) QUESTIONS (cannot be answered from inside the session)

1. **gh token + network:** `gh auth status` says the token in
   ~/.config/gh/hosts.yml is INVALID (refresh is interactive: `gh auth
   refresh -h github.com`), and api.github.com:443 is TCP-unreachable
   from here right now (github.com itself works). Should I (a) wait and
   retry batch 6 later this session, (b) write both drafts to
   docs/drafts/ and leave posting to you, or (c) treat this as persistent
   and park batch 6?
2. **Push policy for cross-repo session artifacts:** templ-components
   carries 3 local commits from this sweep (gitignore negation + the
   deepening brief) and website-template was pushed under T57's explicit
   task scope. May I push templ-components' master, or does it stay local
   until you review the brief?
3. **T92 re-run for verbatim artifacts:** the blind-compare outputs are
   structured summaries (grading quotes verbatim). Accept as-is, or spend
   two subagents on a verbatim re-run (the prompt and grading would be
   identical; only the persistence improves)?

— segment 4 of the standing sweep; batch 7 + wrap-up are ready to execute
on the next directive.
