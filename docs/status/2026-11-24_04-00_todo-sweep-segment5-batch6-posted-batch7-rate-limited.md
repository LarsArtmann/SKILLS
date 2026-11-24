# Status Report — TODO sweep segment 5: batch 6 posted, batch 7 rate-limited on dispatch

**Date:** 2026-11-24 04:00 CET · **Session:** continuation of the standing
directive sweep ("GET SHIT DONE — THE WHOLE TODO LIST"). Resumed on the
owner's repeated blanket directive. Segment 5 closed batch 6 (both external
postings landed and were verified), landed four small items, and then lost
all three batch-7 subagents to a provider rate limit. The owner ordered this
report at that point.

**TL;DR**

- **Batch 6 is closed.** T140: outcome comment posted on
  mattpocock/skills#1437. T141: NOT filed — the `verify-before-filing` gates
  found the finding filed upstream four times already; the one missing fact
  went up as a comment on the canonical issue instead.
- **Batch 7 made ~15% progress.** T111's lesson files are written and pass the
  structural gate, but the agent died before its verification, format pass and
  adjudication table. Ten bundle rows have zero items adjudicated.
- **The sweep's wrap-up is now the largest open item:** 54 of 65 🔴 rows are
  done across five segments and still sit in TODO_LIST; docs-gates is red on
  two gates (archive cadence, 9 unharvested items).

## Scope line — VERIFIED here (fresh commands, exit codes quoted)

- `bash scripts/check-skills.sh` → **exit 0** at session start and again at
  report time (38 skills; only the allowlisted website-launch 861-line WARN).
- `bash scripts/check-skills.sh --selftest` → **exit 0** (3/3), both times.
- `./scripts/sync-html-kit.sh --check` → **exit 0** after the kit TOC was
  re-vendored into 12 consumers.
- Both posted comments were read back through the API and compared
  byte-for-byte with their draft files (ids and timestamps in §a).
- `go run github-voice/scripts/check-draft/check-draft.go --kind comment` →
  exit 0 on both drafts ("0 FAIL, 0 WARN"); `--self-test` → exit 0.
- `docs-gates run .` baseline (before this report) → **exit 1**: freshness
  PASS, annotate PASS (364/372), routing PASS, cadence **FAIL** (19
  unarchived reports vs threshold 15, oldest 21 days), audit-all **FAIL** (9
  unharvested items across 6 reports).
- The nine previously-inline lessons of `how-to-write-skills` are all present
  in the new `references/process-lessons.md` (distinctive-phrase grep, 9/9).
- Upstream facts re-verified at a pinned commit (`abeeaf95`, shallow clone):
  the skill calls sibling skills at `SKILL.md` lines 13, 64, 66 and 71.

## Scope line — NOT verified here

- **The 54 rows marked done in the four earlier sweep reports were NOT
  re-verified against code in this session.** They are claims from
  `2026-11-23_02-36_*`, `05-03_*`, `06-09_*` and `06-59_*` until the wrap-up
  checks each one before pruning (new row T156).
- **T111's landing is unverified:** no adjudication table exists (the subagent
  died before writing it), so coverage of the 22 routed items and the 25 sweep
  candidates inside `references/process-lessons.md` is unknown.
  `dprint check how-to-write-skills/SKILL.md` → **exit 20 (not formatted)**;
  `references/process-lessons.md` → exit 0. `--signal` was not run.
- `website-launch/evals/trigger-eval.json` was validated as JSON only (20
  queries, 10 positive) and has never been run.
- `scripts/check-shell.sh` and the `buildflow` battery were not run this
  session: no `.sh` was touched, and buildflow is a wrap-up gate.
- T117 and T89 (claimed done in earlier segments) were assigned to a subagent
  that died before reaching them; still unverified.
- The claim "one concurrent subagent holds" is a hypothesis: no subagent was
  resumed after the three failures (the owner ordered this report).

## a) FULLY DONE this segment

1. **T140 — fork-outcome comment posted on mattpocock/skills#1437.** Draft at
   `docs/drafts/2026-11-24_mattpocock-skills-1437-fork-outcome-comment.md`
   (297 bytes): fork link, in-repo destination
   `docs/architecture-understanding/`, env override, and the note that the
   ask still stands for the published skill. Voice check 0 FAIL / 0 WARN.
   Posted as `issuecomment-7119034552` (2026-11-24T01:22:30Z); live body
   matches the draft byte-for-byte.
2. **T141 — closed as "do not file".** The row mandates
   `verify-before-filing`; gate 5 failed. Already upstream: #475 (open,
   `ready-for-human`: the installer has no dependency concept), #1012 §2
   (open, `bug` + `ready-for-agent`, with an attached diff for this skill's
   "None to run it" docs page), #1393 (open: the harness-specific `Skill`
   tool wording for exactly these three callees), #1123 (open; its thread
   names this skill), and #775 closed as not planned (a dependency map).
   The one fact they lacked — `grilling` (`SKILL.md:64` at `abeeaf95`) is the
   third callee and is missing from #1012's table row and diff — went up as
   `issuecomment-7119048411` on #1012 (draft 195 bytes, 0 FAIL / 0 WARN,
   live body matches). Both verdicts are recorded in `docs/skill-forks.md`.
   Agent commit `97d4a8b` (drafts + verdicts, detailed message).
3. **Network diagnosis for batch 6.** `gh` token is valid again. The local
   resolver (127.0.0.1) returns SERVFAIL for `api.github.com` in waves;
   9.9.9.9 times out; 1.1.1.1 answers; TLS to the resolved IP works. The
   API answered 2/4, then 0/80, then 12/12. A helper that retries only on the
   pre-request `error connecting to api.github.com` made the two writes safe
   (helper lives in scratch, see T159).
4. **html-report-kit output guide got a table of contents** (+37 lines, H2
   level with nested H3 for tokens and the component catalog). The link gate
   caught one wrong anchor slug on the first run; fixed, re-vendored into 12
   consumers, `--check` exit 0. Closes 05-03 §f39. Daemon commit `41cc678`.
5. **AGENTS.md §1 stale cross-ref re-anchored:** "TODO_LIST T62" pointed at
   the wrong row after renumbering; now names commit `a8a6139`. Closes 05-03
   §f38. Daemon commit `b28ea5a`.
6. **`website-launch/evals/trigger-eval.json` authored** (10 positive queries
   in Go-SSG phrasing, 10 negatives with legitimate owners). Not run (T158).
   Daemon commit `54a8240`.
7. **Five cross-project lessons appended to crush-config
   `references/lessons.md`** (+20 lines): clean-checkout proof, global
   gitignore shadowing, read-only `cp` mode inheritance, safe network-write
   retry, the duplicate gate. Landed as daemon commit `3e007da` there (my
   detailed message was lost to the daemon race). Closes follow-up 37.
8. **Adjudicated moot without edits:** 05-03 §f40 (Starlight drift: no
   Starlight version claim survives the T59 slim, nothing left to re-verify);
   05-03 §f37 (the version-matrix reference it targeted was deleted); T33's
   site-repo remainder and T126's watch are already routed in ROADMAP
   "Planned first real runs".

## b) PARTIALLY DONE

1. **T111 — lessons landed on disk, verification missing.** The write
   subagent `saskia-lessons-t111` died on the provider rate limit after
   writing and before reporting. On disk: `how-to-write-skills/SKILL.md`
   470 → 471 lines (the lessons section now holds the five most-re-hit rules
   plus a pointer; TOC bullet updated) and a new
   `how-to-write-skills/references/process-lessons.md` (243 lines, 42
   lessons, six themed sections: evidence and exit codes, editing, scripts
   and gates, repo and host environment, extractions, carried rules). What I
   verified after the failure: check-skills exit 0, selftest 3/3, all nine
   old lessons present. What is missing: the format pass on SKILL.md, the
   per-item adjudication table, the coverage audit, the `--signal` advisory,
   a FEATURES row update and an AGENTS §5.6 cross-reference. Daemon commit
   `54a8240` carries the unformatted state. The subagent's session is kept
   and can be resumed.
2. **T110, T118, T120 and T112 — zero items adjudicated.** Subagents
   `madeline-corpus-t110-t118-t120` (18 tool calls) and `benoit-linter-t112`
   (10 tool calls) died during their reading phase. No file was touched
   (`git diff f3c80d5..HEAD -- github-voice gmail-drafts linter-building` is
   empty) and no adjudication file exists (their scratch directories are
   empty).
3. **Wrap-up not started.** TODO_LIST still holds 65 🔴 rows; 54 are done
   per the five sweep reports. No CHANGELOG entry exists for any segment of
   the sweep.
4. **Scratch on disk at report time:** `/tmp/scratch-t141-upstream` (upstream
   clone, registered in the scratch manifest), `/tmp/scratch-batch7/*` (three
   empty agent directories), `/tmp/scratch-bin/*` (the `ghr` helper and gate
   logs), `/tmp/issue-1437.json`. The helper is the only artifact worth
   keeping (T159); everything else is trashable.

## c) NOT STARTED

- **Batch 7 (11 bundle rows):** T110, T112, T113, T114, T115, T116, T118,
  T119, T120, T121 untouched; T111 partial (§b1). Plus the T117 and T89
  verifications.
- **Wrap-up:** strike and purge the done rows, CHANGELOG for segments 1–5,
  full gate battery (check-shell, buildflow expecting exit 69, docs-gates),
  FEATURES/README row refresh, closing report.
- **Archive ritual:** docs-gates cadence is overdue (19 unarchived reports,
  threshold 15, oldest 21 days) and audit-all lists 9 unharvested items. Of
  the nine, six are work this sweep finished (T62, T94, common-pitfalls
  numbering, link-canon doctrine, the kit TOC, the buildflow artifact watch)
  and need a `done at` annotation; one is obsolete (`pyJSONString` fuzz: the
  Python it targeted was removed); two need a check (stray-fence lint, the
  two-tier link-canon guard, which is T115/T116 work).
- **Queued follow-ups:** run the website-launch trigger battery; the
  website-template CI workflow and the init CSP self-heal; the two
  skill-level rules from 06-59 §e1/e2.
- **BLOCKED (owner-gated by design):** T30, T68, T71, T75, T122, T123, T124,
  T129, T134, T150, T151, plus the R16 battery half of T125, the
  architecture-deepening grilling pick and the offer-page aging target.
- **Unpushed commits:** SKILLS master is 5 ahead of origin (all daemon
  heuristic commits from this session); templ-components has 3 local commits;
  crush-config is 4 ahead. Nothing was pushed; pushing needs your word.

## d) TOTALLY FUCKED UP (honest, ranked)

1. **I dispatched three write-subagents at once minutes after reading this
   fleet's own lesson on subagent rate budgets.** All three died on `Rate
   limit reached for requests` in the same window (four sessions on glm-5.3
   including mine). The lesson's "three has held" is false for this model
   today, and my "stagger" was about one minute, which is not a rate stagger.
2. **All three adjudication tables were lost.** I told each agent to write its
   table at the END of its run, so the most valuable artifact lived only in
   context. This is the exact failure in crush-config lessons.md ("a derived
   result that lives only in context dies with the session"), read in the
   same hour.
3. **The interrupted lessons work sits in the tree unformatted and
   unreported** (commit `54a8240`). A less careful next session would read
   the green structural gate as "T111 done".
4. **Eleven minutes lost to a blind retry loop** (80 attempts) during a dead
   DNS window. I characterized the flake only afterwards; a one-minute probe
   would have shown the waves first.
5. **I designed a local CONNECT proxy in my head** to bypass the flaky
   resolver before checking whether the good window had returned. It had
   (12/12). Wasted planning, no harm done.
6. **Draft files named `2026-11-23` were written at 00:07 on 2026-11-24.**
   The date-before-filenames lesson was literally on my list of lessons to
   land. Caught, renamed with `git mv` in `97d4a8b`.
7. **The crush-config commit lost its message.** I composed the message after
   the edit; the daemon committed first (`3e007da`). My own new lesson
   ("commit before the daemon's next sweep") was in that very file.
8. **`dprint check … | tail` printed exit 0 while the output said "1 not
   formatted file".** The pipefallacy, caught only because I read the text.
9. **A throwaway verification script misread one JSON object as "4 comments"**
   (`len` of a dict). No wrong conclusion drawn, but the first read of
   "did it land?" was wrong and had to be redone.
10. **Five segments without a TODO prune.** The list has carried 54 done rows
    for a day; every new report re-lists them, and the docs-gates annotate
    and audit-all gates drift further each time.

## e) WHAT WE SHOULD IMPROVE

1. **Subagent protocol for this provider:** one subagent at a time, pre-flighted
   with a single agent; never a symmetric wave on glm-5.3.
2. **Artifacts are written incrementally.** Every adjudication row is written
   the moment it is decided, never at the end.
3. **Prune at the end of every segment**, not at the end of the sweep: strike
   plus purge is two commands and keeps every later report honest.
4. **Small verifications stay in the main session.** T117 and T89 were
   one-grep checks and should never have been bundled into a subagent.
5. **The network-write helper belongs in `scripts/`** with a
   probe-until-healthy gate; two sessions in a row lost time to the same
   resolver.
6. **The resolver itself is an environment defect** (127.0.0.1 forwards to
   an upstream that SERVFAILs `api.github.com`; 9.9.9.9 is unreachable from
   here; 1.1.1.1 answers). Owner-side; I did not touch any system config.
7. **verify-before-filing should say that a queued issue row expires**: T141
   sat eight days and the tracker had moved four times.
8. **Do the cheap skill-level rules with the report that found them**: 06-59
   §e1/e2 are two sentences and are still unlanded a day later.

## f) NEXT — ranked (up to 50; each item names its living-doc home)

**Finish the sweep**

1. **Sweep wrap-up** (→ T156): verify each of the 54 done rows against code,
   `docs-gates strike` + `docs-gates purge --apply`, CHANGELOG for segments
   1–5, full gate battery, FEATURES/README row refresh.
2. **Finish T111** (→ T111, re-scoped at wrap-up): resume its subagent
   session; dprint-format SKILL.md; coverage audit of the 22 routed items and
   25 sweep candidates; `--signal`; FEATURES row; AGENTS §5.6 cross-ref.
3. **T117 and T89 verification** (→ T117 row, one grep each in the main
   session).
4. **Batch 7, one bundle at a time:** T110 (→ T110), T118 (→ T118), T120
   (→ T120), T112 (→ T112), T113 (→ T113), T114 (→ T114), T115 (→ T115),
   T116 (→ T116), T119 (→ T119), T121 (→ T121).
5. **Closing report + one detailed commit** (→ T156).

**Documentation health**

6. **ANNOTATE ritual** (→ T157): the 9 audit-all items, then archive the
   oldest fully resolved reports until cadence is green.
7. **CHANGELOG entry for this sweep** (→ T156): five segments have no entry.

**Tooling and skill-level lines**

8. **Run the website-launch trigger battery** (→ T158).
9. **Promote the gh retry helper** (→ T159).
10. **verify-before-filing expiry line** (→ T160).
11. **Crush-config: fix the concurrency-cap lesson and add the
    incremental-artifact rule** (→ T161).
12. **Assemble-then-verify + tee-raw rules** (→ T162).
13. **website-template CI workflow + init CSP self-heal** (→ T163, local
   commits only until push consent).
14. **FEATURES.md row for how-to-write-skills** (→ T111): mention the
    process-lessons reference.
15. **README inventory paragraph** (→ T156): count of 🆕 skills after the
    architecture-deepening aging.

**Owner-gated (no action until you rule)**

16. T30 — README status flip after a real upstream PR run.
17. T68 — `agent-skills` branch policy.
18. T71 — restore the live-chat conversion guidance.
19. T75 — offer-page eval battery spend.
20. T122 — CV root module under two-currency gate 2.
21. T123 — CV breadcrumb row (consent).
22. T124 — which LOC metric the <20k policy uses.
23. T129 — BuildFlow staged-copy root fix.
24. T134 — accept exit-69-as-green.
25. T150 — fork sync policy (upstream diff or freeze).
26. T151 — third-party original stays removed.
27. T125 — the R16 battery half.
28. architecture-deepening grilling pick (ROADMAP "Planned first real runs").
29. offer-page aging target (ROADMAP "Planned first real runs").
30. Push consent for the three repos with local commits (see §g1).

**ROADMAP fuel (not rows)**

31. DNS resolver upstream fix (owner machine; §e6).
32. A check-skills guard for the two-tier link canon (part of T115/T116).
33. website-launch Phase 7 stops pointing at a template CI workflow that does
    not exist (rides T163).

## g) QUESTIONS (cannot be answered from inside the session)

1. **Push consent.** SKILLS master is 5 commits ahead (this session's daemon
   commits), templ-components has 3 local commits, crush-config 4. May I push
   them, or do you push?
2. **Subagent budget.** Three concurrent subagents on glm-5.3 all died on the
   request rate limit. For batch 7 (10 bundles, about 80 items) do you want me
   to resume one subagent at a time on glm-5.3 (slow but on the model that
   judges well), or name a different model/provider that has budget?
3. **Owner-gated rows.** Eleven rows wait on a one-line ruling each (§f16–27).
   Which of these can you decide now: T134 (exit 69 counts as green —
   already documented in AGENTS §5.11), T150/T151 (fork policy), T71 (restore
   the live-chat guidance)?

## Harvest ledger (this report → living docs)

Rows minted after `docs-gates freshness . --pre-flight` on the candidate
lines (see scope line in the commit); each premise was re-checked
2026-11-24 against the current tree.

| Source (report §item)                         | Disposition                          | Destination / reason                                                                                          |
| --------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| §f1, §f5, §f7, §f15 sweep wrap-up             | new row                             | T156 — no row owned the closing ritual                                                                       |
| §f6 archive ritual + 9 audit-all items       | new row                             | T157 — cadence red, no owner row                                                                              |
| §f8 website-launch trigger battery            | new row                             | T158 — battery authored today, never run                                                                     |
| §f9 gh retry helper                           | new row                             | T159 — helper exists only in /tmp/scratch-bin                                                                 |
| §f10 verify-before-filing expiry line        | new row                             | T160 — lesson from T141, no skill row yet                                                                   |
| §f11 concurrency-cap lesson                  | new row (repo: crush-config)         | T161 — the fleet lesson states a cap that failed today                                                       |
| §f12 assemble-then-verify + tee-raw           | new row                             | T162 — 06-59 §e1/e2 were never routed                                                                         |
| §f13 website-template CI + CSP self-heal      | new row (repo: website-template)     | T163 — 06-09 §f32/f33 were never routed; local commits only until push consent                               |
| §f2 finish T111                                | existing row                        | T111 — stays open, re-scoped to the verification remainder at wrap-up; premise re-checked 2026-11-24          |
| §f3 T117/T89 verification                     | existing row                        | T117 — still unverified; premise re-checked 2026-11-24                                                      |
| §f4 the ten bundle rows                       | existing row                        | T110, T112–T116, T118–T121 — unchanged; premise re-checked 2026-11-24                                        |
| §f16–30 owner-gated rows and picks            | existing row / ROADMAP              | T30, T68, T71, T75, T122–T125, T129, T134, T150, T151; ROADMAP "Planned first real runs"; no change           |
| §f31 DNS resolver defect                      | declined                            | owner machine configuration, not a repo task; §g/§e6 carry it                                                 |
| §f32 two-tier link-canon guard                | existing row                        | T115/T116 gate-infra items absorb it; premise re-checked 2026-11-24                                         |

---

*This report is a point-in-time artifact. Bring it current via docs-health →
ANNOTATE.*
