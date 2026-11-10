# Status Report — design-to-code evals, the upstream-issue gate that fired, and the aggregation wave

**Session:** 2026-11-03, ~20:40–21:35 CET (continuation of the 20:39 session; same working tree)
**Author:** Crush agent session
**Report type:** point-in-time snapshot (this file goes stale; bring current via docs-health → ANNOTATE)

## Scope line — what this report verified vs. did not

**Verified this session, with which artifact:**

- Eval results: all 6 run directories read directly; every grading.json
  assertion carries quoted file-content evidence (`design-to-code/evals/iteration-1/*/with_skill|without_skill/`).
- Probe results: `crush run` sessions executed live; transcripts + timing.json
  on disk; the trigger probe's `SKILLS-USED:` line is quoted verbatim in
  `trigger-probe.md`.
- Upstream CLI mechanism: `src/update.ts` (1181 lines) fetched and the
  check-loop read; live `bun x skills check -g` executed and its output read
  (6 updates flagged, 7 hyperframes deletions warned, anthropics source
  clean).
- Gotchas addendum: both new claims re-verified against the already-downloaded
  primary source (`/tmp/tw-upgrade-guide.mdx`, fetched 2026-11-03) at
  L212–253 (rename table), L327 (bare-vs-xs), L555–566 (button cursor).
- Gates: `scripts/check-skills.sh` exit 0, "all 34 skills pass structural
  checks", 183 markdown files link-checked; `link-skills-to-agents.sh --check`
  OK; all 34 eval JSON artifacts `jq -e` validated.
- Commits cited by hash exist in the two affected repos
  (`git log` read: `4558d75`, `4f83906`, `71b4afb`, `a060bce`, `e6d5b11`
  here; `3e05e02` in the agent-skills repo).

**NOT verified, and why:**

- **Token counts for eval arms** — `crush run` does not report them; the
  benchmark carries `tokens: null`. Not recoverable after the fact.
- **Which CLI version produced the 2026-11-03 morning false green** — the
  lockfile entry was re-written by the re-add before the mechanism question
  was asked; the pre-refresh state is gone. The failure is real as an
  observation; its trigger (old CLI version / pre-v3 lock entry / transient
  fetch failure) is unconfirmed.
- **skill-creator's eval viewer** (`generate_review.py --static`) — not
  attempted; python availability and Claude-Code-specific path assumptions
  untested. The human-review/feedback.json loop therefore did NOT run.
- **Statistical significance of the eval delta** — n=1 per arm by design
  (iteration-1); pass-rate delta is directional only.
- **The foreign working-tree changes** (`.gitignore`, FEATURES.md, README.md
  table re-padding + a Python→JS ignore swap) — read and characterized, not
  investigated further (out of scope per the session instruction). Not mine;
  not reverted; the daemon may bundle them (§5.12).

## TL;DR

| Question                                    | Answer                                                                                      |
| ------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Did the skill survive contact with reality? | Yes — discovery PASS, natural trigger PASS, eval 13/13 vs 12/13, clean MWG routing          |
| Did anything break?                         | Nothing at HEAD; four honest failures caught and either fixed or documented (section d)     |
| Biggest save                                | verify-before-filing gate **rejected the upstream issue** the 20:39 report had scheduled    |
| Biggest miss                                | A wrong mechanism claim sat in AGENTS.md §5.10 as a "lesson" for ~2 hours before correction |
| Repo state at write time                    | Gates green, tree carries 3 foreign hunks (noted above), 2 authored commits this session    |

---

## a) FULLY DONE

1. **Fresh-session discovery probe (20:39 report f1).** `crush run` in a
   neutral dir: `design-to-code` listed among 61 skills. Closes the
   session-snapshot limitation noted in (b)2 of the 20:39 report.
2. **Behavioral eval iteration-1, complete pipeline (f2).** 3 evals × 2 arms,
   skill-creator schema adapted to Crush (`crush run` sessions, explicit
   skill-path instruction for with-arms, honor-system no-skills instruction
   for baselines, rationale documented in `evals/evals.json` →
   `harness.adaptation_note`):
   - `theme-token-encoding`: 4/4 vs 4/4 (non-discriminating — baseline
     already writes correct v4 `@theme`)
   - `v3-to-v4-migration`: 5/5 vs 4/5 — **the discriminating eval**: baseline
     kept `"bg-" + tone + "-500"` runtime concatenation and compensated with
     `@source inline(...)`; the skill's doctrine replaces it with complete
     static class names. With-arm additionally caught two silent v4 changes
     _not in the reference_ (`shadow`→`shadow-sm`, `rounded`→`rounded-sm`,
     preflight dropping `cursor: pointer`) by verifying against live docs,
     and restored the cursor via `@layer base`.
   - `status-badge-dynamic-classes`: 4/4 vs 4/4 (baseline independently knows
     the scanner gotcha)
   - Aggregate: **13/13 (1.00) vs 12/13 (0.93)**, n=1 per arm, directional.
   - Everything on disk: evals.json (13 assertions), fixtures, 3×
     eval_metadata.json (4/5/4), 6× grading.json with quoted evidence, 6×
     timing.json, 6 transcripts, benchmark.json, README.
3. **Natural-trigger probe (f3 trigger half + f8 routing half).** After the
   parallel-launch rate-limit failure (see d2), a serial rerun with a purely
   natural prompt returned `SKILLS-USED: design-to-code, modern-web-guidance`.
   The transcript shows clean concern-splitting: design-to-code owned
   framework mechanics (no-token-invention after Step 1 inspection, complete
   static class strings per Step 4.3), modern-web-guidance owned the platform
   concern (`contrast-color` guide → `-100`/`-800` pairing). No collision.
4. **Gotchas reference hardening.** +2 claims verified against the primary
   source and added (scale renames with the bare-renders-smaller /
   `-xs`-restores detail; preflight button cursor) — the reference now
   carries 15 verified claims, and the "four moves that bite" section became
   six. The addendum rows cite their provenance ("added 2026-11-03 after eval
   iteration-1 caught the gap").
5. **Aggregation repo wave committed (f6).** `3e05e02` in
   `~/.agents/skills` (remote `LarsArtmann/agent-skills`): 65 files —
   frontend-design refresh, the hyperframes upstream restructure
   (`hyperframes-core/` → `hyperframes/`, git detected clean renames),
   product-launch-video updates, 9 own-skill symlinks
   (incl. `design-to-code`), `general-video/` + `typesafe-ai/` real dirs.
   Pre-commit secret scan clean; all added trees < 40 KB. Lands on the
   `docs-health-verify-legs` branch — branch-policy question (T68) remains open.
6. **Upstream issue gated OUT (f4 — resolved by rejection).** The
   verify-before-filing gates ran against `vercel-labs/skills` source: the
   current check fetches the **live upstream tree SHA** per locked path and
   supports ref pinning (`ref?: string`, groups by source AND ref) — the
   20:39 report's premise ("hash-only comparison, no ref pin") is wrong
   against source, and a live `skills check -g` correctly flagged 6 stale
   skills. **No issue filed.** Gate 5 (existing issues) searched — no match.
7. **AGENTS.md §5.10 memory correction.** The wrong mechanism claim written
   by the 20:39 session was rewritten in place (commit `71b4afb`): correct
   mechanism, explicit "do not file on the old claim" runbook, and the
   evidence-to-capture recipe if the false green ever recurs on the current
   CLI. Also records the hyperframes deleted-upstream warning.
8. **Cheap documentation wins (f19, f20).** `docs/external-dependencies.md`
   gained the tailwindcss-docs row (fetch route + re-verify note); README and
   FEATURES now show design-to-code as eval'd (README "🆕 New (evald)",
   FEATURES "🟡 `NEW` (eval'd)" — the gate-coupled convention, see d4).
9. **Status report #1 annotated (20:39 report).** 12 inline `m3` markers
   (commit `e6d5b11`): b1/b2/c3/c4 resolved, table rows 1/2/6/19/20 marked
   done, row 3 partial, row 4 `Won't implement` with the gate verdict, row 8
   partial. HARVEST will now skip the closed items.
10. **Gates green at write time.** check-skills 34/34, links OK, fan-out
    symlinks OK, all eval JSON `jq`-valid, working tree carries only the
    foreign hunks noted in the scope line.

## b) PARTIALLY DONE

1. **First real triggered run (f3 residue).** The probe session triggered
   naturally, but it was agent-initiated, not a genuine user-initiated task
   in a live project. The two-stage rule's 🟢 step therefore remains open by
   the rule's own wording. FEATURES honestly says so.
2. **Boundary test (f8 residue).** Routing recorded for one probe session
   (`trigger-probe.md`); the report's actual ask — a _real work_ web task
   where both skills plausibly trigger (pairs with T63) — still open.
3. **Eval rigor.** n=1 per arm (no variance estimate); tokens uncollected;
   10 of 13 assertions pass both arms (they test v4 competence the model
   already has, not the skill's unique doctrine). Iteration-2 should run 3×
   per arm with trap-targeted assertions.
4. **Human-review loop of the eval.** skill-creator's viewer + feedback.json
   flow not run (see scope line). The quantitative half exists; the
   qualitative user-feedback half does not.
5. **Fleet freshness (observed, not acted on).** Live check: 6 third-party
   skills have updates available (`improve-codebase-architecture`,
   `copywriting`, `hyperframes`, `hyperframes-cli`, `hyperframes-registry`,
   `media-use`); 7 hyperframes-suite skills are warned "deleted upstream"
   after the restructure (fail-closed in non-interactive mode — but an
   _interactive_ future `skills update -g` could remove local copies).
6. **False-green root cause.** Symptom real, mechanism narrowed to three
   candidates, none confirmed (see scope line). A definitive answer would
   need the npm version timeline of 2026-11-03 morning — one `gh api`/npm
   query away, not done (out of session scope).

## c) NOT STARTED

1. **The 20:39 report's three owner questions (g1–g3)** — unanswered:
   upstream PR to anthropics/skills vs first-party-only; freshness policy for
   the 15 verified claims (manual cadence vs docs-snapshot sync script);
   README "Frontend & Web" section.
2. **HARVEST of (f) sections into TODO_LIST/ROADMAP** — for both the 20:39
   report and this one. Deferred deliberately per the session instruction
   ("report, then wait"); the canonical rule lives in docs-health.
3. **anthropics/skills PR (f5)** — unchanged; needs the g1 decision plus the
   verify-before-filing + github-voice + jj loop.
4. **Claim re-verification after the next Tailwind minor release (f7)** —
   future-dated; the table carries the 2026-11-03 freshness stamp.
5. **T70: AGENTS.md trim** — still open; this session's §5.10 correction
   grew the file again (net larger than before the session), so the trim
   pass must now absorb two sessions' additions.
6. **T62: land install-don't-wrap in how-to-write-skills.md** — unchanged;
   design-to-code + this session's §5.10 correction are both citable worked
   examples.
7. **f13 DOM-audit script, f14 worked-example reference, f15/T60, f16 fleet
   audit, f17 README section, f18 Tailwind-restatement audit** — untouched.
8. **Carried open TODOs** — T30, T33, T57, T60, T62, T63, T67, T69, T70
   (open); T58/T59/T68 (blocked). TODO_LIST.md remains authoritative.
9. **False-green evidence capture** — conditional task, only actionable if
   the false green recurs on the current CLI (runbook in §5.10).

## d) TOTALLY FUCKED UP

Nothing destroyed, no gate left red, no data loss. Four entries under the
radical-honesty bar:

1. **The repo's own memory briefly poisoned me — and I had poisoned it.** The
   20:39 session asserted a CLI mechanism ("compares installed-folder hashes,
   no ref pin") from _behavior_, never from source, wrote it into AGENTS.md
   §5.10 as a lesson, and scheduled an upstream issue on top of it. This
   session the verify-before-filing gate caught the premise against
   `src/update.ts` before filing — the exact failure the skill exists to
   prevent — but the wrong claim sat in memory for ~2 hours and would have
   become a public wrong-premise issue had the gate not been mandatory. Root
   cause: the 20:39 session obeyed "encode lessons immediately" while
   skipping "verify the mechanism at source first" — the two rules collided
   and the fast one won. Mitigation now in place: the corrected §5.10 entry
   says explicitly what is verified vs unconfirmed, and the runbook requires
   evidence capture before any future filing.
2. **Seven parallel sessions tripped the provider rate limit and I nearly
   misread the casualty.** Launching all 6 eval arms + the trigger probe in
   one turn followed skill-creator's "spawn all runs in the same turn" —
   which assumes Claude-Code subagents, not 7 full `crush run` sessions. The
   probe died with a rate-limit ERROR; worse, its timing.json recorded
   `exit_code: 1` from my trailing `rg` (no match), not from the session —
   measurement conflation I caught only by reading the transcript. Cost: one
   wasted probe + a rerun cycle; the 6 graded arms were unaffected.
3. **A silenced error silently skipped a whole artifact class.** The
   eval_metadata.json generator loop was gated behind a jq syntax probe whose
   failure I routed to `/dev/null 2>&1`; the loop never ran and the files
   were missing until the final JSON validation caught it. This is the
   _same_ failure mode the 20:39 report's improvement e5 already encoded
   ("quote exit codes, not output tails") — violated again, same day, by the
   same author. Twice in one day is a pattern, not a slip.
4. **I invented a status-marker convention the gate immediately rejected.**
   Marking design-to-code 🟡 in the README broke the README↔FEATURES parity
   check, because the gate couples FEATURES' `NEW` token with the README
   emoji and linter-building/stack-selection established the eval'd pair
   years-of-convention ago. check-skills FAILed it; I reverted to the
   established pair. Minor and caught, but it was an avoidable violation of
   the repo's own rot pattern (inventing parallel vocabularies) — the gate's
   comment even documents the coupling I missed.

## e) WHAT WE SHOULD IMPROVE

1. **Concurrency ceiling for eval fleets.** Cap parallel `crush run` fleets
   at 3–4 with serial fallback; add one retry with backoff for probe-type
   sessions. Encode in `evals/README.md` (harness note) so iteration-2
   doesn't repeat d2.
2. **Mechanism claims need source citations before they enter AGENTS.md.**
   A §5.10 lesson that describes _why_ something fails must either cite the
   source file it read or be explicitly marked "behavioral observation,
   mechanism unconfirmed". The corrected §5.10 entry now models this; make it
   the rule, not the exception.
3. **Never silence a gating command's errors.** `cmd 2>/dev/null && loop`
   is how d3 happened. If a command's success gates a loop, check its exit
   code explicitly. (This is e5 from the 20:39 report, escalated: it
   recurred. If it recurs again, promote from improvement to a hard rule.)
4. **Design eval assertions around the skill's unique doctrine.** 10/13
   assertions were non-discriminating on this model. Iteration-2 assertions
   should target what the skill claims _only it_ teaches (trap elimination,
   verification posture), not general v4 competence — otherwise the eval
   measures the model, not the skill.
5. **Run gates immediately after each artifact batch, not at the end.** The
   parity FAIL was caught ~40 minutes after the edit that caused it (20:39
   improvement e1, also recurred). Batch boundary: after README/FEATURES
   edits, run check-skills before moving on.
6. **Token accounting for evals.** `crush run` reports no tokens; either
   find a verbose/session-log source or stop pretending the column exists in
   future benchmarks (leave it out rather than `null`).
7. **Decide the eval-viewer question once.** Either attempt
   `generate_review.py --static` once (accepting it may need path shims) or
   document in the evals README that Crush-terminal evals skip the
   human-review loop deliberately — don't leave it ambiguous for iteration-2.
8. **CHANGELOG.** The eval iteration + gate outcome are not yet reflected in
   the CHANGELOG's design-to-code entry (f20 of this report).

## f) 30 things to get done next (ranked; primary input for HARVEST)

> User asked for up to 50; 30 is what survived rigor — the rest would be
> brainstorm, and brainstorm belongs in ROADMAP. Items 1–12 are new or
> updated by this session; 13–21 carried from the 20:39 report **excluding
> everything this session closed** (rows 1, 2, 4, 6, 19, 20 there now carry
> m3 markers — HARVEST must skip them); 22–30 are ROADMAP fuel. Skip any
> item already carrying a resolution marker.

| #  | Task                                                                                                                                                                             | Impact | Effort | Category      | Source  |
| -- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------------- | ------- |
| 1  | Eval iteration-2 for design-to-code: 3× per arm, trap-targeted assertions, serialized launches (rate-limit ceiling), then re-grade                                               | High   | M      | Quality       | NEW     |
| 2  | First genuine user-triggered design-to-code run on live UI work; age 🆕→🟢 (residue of 20:39 row 3)                                                                              | High   | M      | Quality       | carried |
| 3  | Run docs-health HARVEST over both 2026-11-03 reports' (f) sections into TODO_LIST/ROADMAP (skip m3-marked rows)                                                                  | High   | S      | Documentation | NEW     |
| 4  | Answer the three owner questions (20:39 g1–g3): upstream PR, claim-freshness policy, README "Frontend & Web" section                                                             | High   | S      | Decision      | carried |
| 5  | Fleet freshness wave: update the 6 stale third-party skills; resolve the 7 hyperframes "deleted upstream" warnings (re-add per skill) before an interactive update does it wrong | High   | M      | Cleanup       | NEW     |
| 6  | T70: AGENTS.md trim pass — must now absorb the 20:39 session's +1.45 KB _and_ this session's §5.10 rewrite (file grew again)                                                     | Medium | M      | Cleanup       | carried |
| 7  | T62: land install-don't-wrap in how-to-write-skills.md, citing design-to-code + the §5.10 correction as worked examples                                                          | High   | M      | Documentation | carried |
| 8  | f8 residue: live-work boundary case where design-to-code AND modern-web-guidance both plausibly trigger (pairs with T63)                                                         | High   | M      | Quality       | carried |
| 9  | T67: markdown-table pipe-safety rule (never raw pipe in inline code + `git diff -w` after formatter runs)                                                                        | High   | S      | Quality       | carried |
| 10 | f13: concrete DOM-audit fallback script for design-to-code (grep-based interactive-element/focus/reduced-motion checker)                                                         | Medium | S–M    | Feature       | carried |
| 11 | f14: worked-example reference — one real v3→v4 before/after (important-suffix, var parens, dynamic-class fix)                                                                    | Medium | S      | Documentation | carried |
| 12 | Append eval iteration-1 results + gate outcome to the CHANGELOG design-to-code entry                                                                                             | Low    | S      | Documentation | NEW     |
| 13 | Encode the eval-fleet concurrency ceiling + retry policy in design-to-code/evals/README.md (harness section)                                                                     | Medium | S      | Documentation | NEW     |
| 14 | Mechanism-claims-need-citations rule: decide where it lives (how-to-write-skills.md vs AGENTS.md lesson discipline) and encode it                                                | High   | S      | Documentation | NEW     |
| 15 | Settle the eval-viewer question: attempt `generate_review.py --static` once, or document the deliberate skip in evals/README.md                                                  | Low    | S      | Quality       | NEW     |
| 16 | Confirm the 2026-11-03 morning false-green trigger: query the npm `skills` version timeline for that morning (one `gh api`/npm query)                                            | Low    | S      | Quality       | NEW     |
| 17 | f16: full fleet freshness audit (diff all lockfile skills vs upstream HEAD via gh api loop) — this session's live check was a partial sample                                     | High   | M      | Quality       | carried |
| 18 | f18: audit repo skills (website-launch, html-report-kit) for Tailwind-mechanics restatements that would violate install-don't-wrap                                               | Medium | S      | Cleanup       | carried |
| 19 | T63: first real triggered MWG web task (modal/`<dialog>` end-to-end)                                                                                                             | High   | M      | Quality       | carried |
| 20 | After item 2: update FEATURES/README to 🟢 (or the convention-appropriate marker) per the two-stage rule                                                                         | Low    | S      | Documentation | carried |
| 21 | Consider upgrading the inventory vocabulary so 🟡-eval'd is machine-readable (the gate couples `NEW`↔🆕; eval'd states live in prose only)                                       | Low    | S      | Documentation | NEW     |
| 22 | T60: MWG uninstall proof (snapshot, uninstall, verify, restore)                                                                                                                  | Low    | S      | Quality       | carried |
| 23 | T69: triage standing advisory findings (art-dupl 6, jscpd 3, file-size-check 4) into deliberate non-fixes                                                                        | Medium | S      | Cleanup       | carried |
| 24 | T30: flip README status after first upstream PR kept green via jj sync loop                                                                                                      | Low    | S      | Documentation | carried |
| 25 | T33: site-repo follow-ups (emeet composition, og:image, CI deploy)                                                                                                               | Medium | M+     | Feature       | carried |
| 26 | T57: extract templ-components Go SSG into canonical private `website-template` repo                                                                                              | High   | M      | Feature       | carried |
| 27 | T58/T59 (blocked by T57): `websitelaunch` CLI, then website-launch slim + evals re-run                                                                                           | Medium | M      | Feature       | carried |
| 28 | T68 (blocked): agent-skills branch policy decision — this session committed the wave onto `docs-health-verify-legs`, making the question concrete                                | High   | S      | Decision      | carried |
| 29 | ROADMAP: design-memory convention (tiny shared design-notes file) — revisit once design-to-code has real runs                                                                    | Low    | S      | Idea          | carried |
| 30 | ROADMAP: Lombiq-style tailwind docs-snapshot skill with staleness gate — only if static claims prove insufficient (g2 decides)                                                   | Low    | M      | Idea          | carried |

## g) Top 3 questions I cannot figure out myself

1. **Does the eval evidence change the upstream-PR calculus?** The 20:39
   question (first-party bridge vs PR to anthropics/skills) now has data: the
   bridge content's discriminating value is measured (the migration trap +
   verification posture), and frontend-design itself was 7 months stale
   upstream before today. Does that push you toward proposing the bridge
   paragraphs upstream after all — or does the measured staleness of the
   upstream repo argue _stronger_ for keeping the layer first-party where it
   can't drift?
2. **How much eval rigor do you want, per skill?** Iteration-1 cost ~7 agent
   sessions and produced a directional delta (13/13 vs 12/13, n=1). Rigorous
   evals (3× arms, viewer, feedback loop) cost roughly 3–4× that. Should
   design-to-code's iteration-2 run at full rigor, or is directional
   evidence + a real triggered run enough for 🟢-adjacent confidence — and
   should this bar become the repo-wide standard for 🆕 skills?
3. **Claim-freshness policy (carried from 20:39 g2, now 15 claims).** Manual
   re-verification after each Tailwind minor release vs a Lombiq-style local
   docs-snapshot sync with a staleness gate. Today's eval sharpened the
   stakes: the reference was _missing_ two claims the eval surfaced, which
   argues the claims list itself needs a maintenance trigger, not just a
   re-verification cadence. Static table, sync script, or something in
   between — your call.

---

**Handoff:** section (f) is the primary input for docs-health HARVEST (both
this report and the 20:39 report; the canonical rule lives in docs-health —
do not restate it here). HARVEST must skip every item carrying an `m3`
marker, including the six rows resolved in the 20:39 report this session.
This file is a point-in-time snapshot; bring it current later via
docs-health → ANNOTATE, never rewrite.
