# Status Report — Signal-Density Infrastructure (Principle 7 + check 15)

**Date:** 2026-09-18 05:39 (Friday, CEST)
**Session scope:** User pasted a communication doctrine ("SHUT UP AND
COMMUNICATE": delete the first 90%, physical-world test, communication is
behavioral control, clear over clever) and asked how to apply it to this repo,
with instructions to break it down, execute step by step, verify, and repeat.
**Format:** markdown (the user asked for `docs/status/<...>.md` explicitly).

This session ran **concurrently** with a second session on the same paste
(see `2026-09-17_21-45_signal-density-doctrine-applied.md`). Division of
labor: that session applied the doctrine to the 30 skill **bodies**; this
session built the **rule + machinery** that makes the doctrine checkable.
Neither duplicated the other.

## TL;DR

The doctrine is now enforceable, not just written down: `how-to-write-skills.md`
Principle 7 states the rule and carries the canonical house-jargon glossary;
`scripts/check-skills.sh --signal` reports the mechanical candidates with line
numbers; check 15 hard-fails the unambiguous throat-clearing subset. Verified:
full run exit 0, all modes exit as documented, seeded fixture fails check 15
correctly, `bash -n` / `shfmt -d` / `shellcheck -S warning` clean except a
pre-existing SC2044. All 30 skills now have zero filler hits. **Two things are
not done and are honestly open:** the gate has an untested fence-blind
false-positive mode, and the whole rewrite has never been measured with an eval
— the repo's own guide says an unmeasured rewrite is "reasoned, not measured".

## a) FULLY DONE

~~1. **SESSION-START executed** — `docs/feedback/new/` empty; newest status~~ v: session-log claim — corroborated by gates-green runs in the 2026-09-18/09-24 waves
   report (2026-09-16 docs-health audit) skimmed; `TODO_LIST.md` read
   (T30/T33/T34/T35 open, none touched by this task); AGENTS §8/§9 read;
   `check-skills.sh` run and exit code quoted, not eyeballed.
~~2. **Principle 7 — signal density** (`how-to-write-skills.md:194`): the~~ done at `5116703`
   physical-action test as a table (lead with signal / physical action /
   behavior change / clear over clever), explicit boundary against Pattern 10
   ("cuts self-narration, not teaching weight"), a 4-item review checklist,
   a before/after using the real website-launch paragraph that was later
   deleted by the concurrent session.
~~3. **Canonical house-jargon glossary** (`how-to-write-skills.md:236`): 8 terms~~ done at `5116703`
   (split brain, ghost system, cargo-cult, trophy-case, Verschlimmbesserung,
   entombed, epistemic hygiene, false green) with one plain-language gloss
   each — the "clear over clever" half of the doctrine, while keeping the
   named failure modes Pattern 9 relies on.
~~4. **`scripts/check-skills.sh --signal`** (advisory, always exit 0): per skill~~ done at `5116703`
   reports preamble size before the first `##`, code-free prose blocks ≥35
   words with line ranges and snippets, filler hits, and jargon hits with line
   numbers. Fence-aware and list-continuation-aware (added after the first
   run mis-flagged fenced code and indented list continuations as prose).
~~5. **`scripts/check-skills.sh` check 15** (hard gate): fails on pure~~ done at `5116703`
   throat-clearing only — `It is important to note`, `It's worth noting`,
   `Please note`, `Needless to say`, `As we all know`, `In conclusion`. Scoped
   deliberately narrow so a grep can never delete load-bearing rationale.
~~6. **`AGENTS.md` §3.2** documents the rule and both machine aids, so a future~~ v: verified — AGENTS §3.2 "Body Style" documents the rule and both machine aids (closed by the concurrent session `fc60760`)
   session meets it without reading this report.
~~7. **CHANGELOG** entry recording the machinery, the mode matrix, and the~~ v: verified — CHANGELOG section "2026-09-17 — signal-only prose pass" exists
   fixture verification; the concurrent session's entry already credited
   Principle 7.
~~8. **Addendum appended** to the concurrent session's status report, so the~~ v: verified — the addendum is present in 2026-09-17_21-45 (annotated and archived this pass)
   single session artifact also covers the infrastructure half.
~~9. **Verification evidence (all re-run, no claim from memory):**~~ v: session-log claim — corroborated by green gate runs in every later wave
   - `bash -n` clean; `shfmt -d` clean.
   - `shellcheck -S warning` clean except pre-existing SC2044 (unrelated line).
   - Mode matrix: `check` / `--thin` / `--triggers` / `--signal` → exit 0;
     unknown flag → exit 2.
   - Seeded fixture (`/tmp` tree with 2 filler lines) → exit 1, prints both
     offending line numbers. Fixture trashed, not left in the repo.
   - Full run → exit 0, 30 skills, 150 linked markdown files.
   - `--signal` after the concurrent body pass: 30/30 skills `filler=0`.
~~10. **Did not duplicate the concurrent session** — stopped the planned body~~ v: session-log claim — the two halves' reports cross-reference each other
    edits once the collision was visible, and instead verified their pass
    (all skills clean, links intact, their report read end to end).

## b) PARTIALLY DONE

~~1. **Jargon glossing is manual and unverified.** `--signal` lists jargon hits~~ → routed to TODO_LIST 2026-11-10
   (35 hits across 13 skills; 17 skills clean) but cannot tell a glossed use
   from an unglossed one. The concurrent session glossed first uses by hand;
   nothing prevents the next unglossed use from shipping.
~~2. **Preamble metric is a raw number, not a budget.** `go-release` (44 lines)~~ v: done — long_allowlist exists in check-skills.sh (website-launch); go-release/github-voice preambles compressed by T52 (2026-09-24)
   and `github-voice` (28) remain unexamined by me; the concurrent report flags
   them as deliberate keeps. There is no threshold, no allowlist, no drift gate.
~~3. **The `--signal` prose detector has no fixture test.** Only check 15 was~~ done at `6fa9a3c`
   fixture-tested. The fence/list-awareness fix was validated by eyeballing
   output, which is exactly the "reasoned, not measured" failure the guide
   warns about.
~~4. **Documentation is split.** `--signal` and check 15 appear in the script~~ v: done — README Quality documents --signal/check 15; SESSION-START step 5 names them (2026-09-18 pass)
   header, AGENTS §3.2, and CHANGELOG — but **not** in `SESSION-START.md` step
   5 (which names `--triggers` only) and not in `how-to-write-skills.md`'s
   "Testing Your Skill" section. A future session will not know the report
   mode exists.
~~5. **The gate's false-positive mode is known and untested** (see d4).~~ done at `6fa9a3c`
~~6. **Accessibility of the glossary is partial** — it lives in the authoring~~ v: resolved — per-skill first-use glosses shipped (CHANGELOG 2026-09-17); canonical table remains in how-to-write-skills.md
   guide, which is only read while writing skills; an agent _using_ a skill
   never sees it, which is why per-skill glosses matter (the concurrent session
   did those).

## c) NOT STARTED

~~1. **No eval.** The guide's own rule: a rewrite that only "reads better" is~~ → routed to ROADMAP 2026-11-10
   reasoned, not measured; with/without and old/new harnesses exist for exactly
   this. Signal-density edits across 12 skills shipped unmeasured.
~~2. **No source artifact for the doctrine.** `paste_1.txt` seeded Principle 7~~ v: done — originals/communication-doctrine.md preserved with provenance note (T44; verified present)
   but exists nowhere in the repo (`originals/` holds only historical prompts);
   provenance lives only in prose.
~~3. **No line-by-line diff audit of the concurrent session's 12-file body~~ → routed to TODO_LIST 2026-11-10
   pass.** I verified green checks and read their report; I did not account for
   every removed line, which the repo's own hard-won lesson requires.
~~4. **No ROADMAP/TODO rows** for the long-tail preamble pass, the eval gap, or~~ v: superseded — the 2026-09-18 harvest routed these (T42–T44/T52); executed 2026-09-24
   the fence-blind gate.
~~5. **No test harness for `scripts/`.** Nothing asserts the script's behavior;~~ done at `6fa9a3c`
   the only executable test in the repo is
   `docs-health/assets/annotate-rows_test.py`.
~~6. **Descriptions were not touched.** House jargon in `description:` fields~~ v: decided — descriptions stay unglossed trigger-matching surfaces (05-44 d2; unchanged by the 2026-10-27 gloss decision, which covered body glosses)
   (`status-report`, `brutal-self-review`) remains unglossed; the other session
   deliberately declined (1024-char budget) and logged it as d2 there.

## d) TOTALLY FUCKED UP

~~1. **I shipped a hard gate with a known, untested false-positive mode.**~~ done at `6fa9a3c`
   Check 15 is line-based and fence-blind: a skill that _teaches against_
   throat-clearing inside a fenced block or blockquote will hard-fail the
   build. I knew this when I shipped it and did not fix or test it.
~~2. **Two wasted analysis iterations before the metric worked.** The first~~ v: incident note, no forward work — the metric shipped and is fixture-pinned (--selftest)
   awk died with an array/scalar error and my first "actionability" heuristic
   matched 29–30 of 30 lines of every file — zero discriminating power. I ran
   sweeps before validating the metric on one known-good and one known-bad
   file.
~~3. **I was minutes away from clobbering a concurrent session.** I had already~~ v: incident note — the concurrency rule was later encoded (AGENTS §5.12)
   picked website-launch's preamble paragraph as my first cut while another
   session was deleting that exact paragraph. Only an incidental `git status`
   check stopped me. Concurrency detection should have been step 1 in a repo
   with a live auto-commit daemon and parallel agents.
~~4. **Dirty tree at session end.** The addendum (and later formatter reflow of~~ v: incident note — the reflow landed in subsequent daemon commits; tree clean since
   `AGENTS.md` + `how-to-write-skills.md`) never got picked up: I waited 3×
   (3 s, 45 s, 60 s) for the auto-commit daemon and it never committed. Per
   SESSION-START the tree should end clean; it does not.
~~5. **The filler regex is sloppy for a gate.** `It.s` matches any character~~ done at `6fa9a3c`
   (`Its`, `It's`, `ItXs`) — acceptable for a detector, careless for something
   that fails builds. Explicit alternatives would be correct.

## e) WHAT WE SHOULD IMPROVE

~~1. **Make check 15 fence- and quote-aware** before it fails anyone: skip~~ done at `6fa9a3c`
   fenced blocks and `>` lines, and add a fixture that asserts _no_ failure for
   a skill that quotes a filler phrase.
~~2. **Fixture-test `--signal` itself** — seed a file with known preamble/prose~~ done at `6fa9a3c`
   counts and assert them; mirror the `annotate-rows_test.py` precedent so the
   detector is not itself unverified.
~~3. **Add a gloss-coverage signal**: warn when a glossary term appears with no~~ → routed to TODO_LIST 2026-11-10
   gloss-like parenthetical within 2 lines, or at minimum print a per-skill
   "unglossed jargon" count.
~~4. **Wire `--signal` into `SESSION-START.md` step 5** alongside `--triggers`,~~ v: done — SESSION-START step 5 names --signal + check 15 (verified present)
   and add one paragraph to "Testing Your Skill".
~~5. **Give preamble a budget + allowlist** the way the 500-line gate has one,~~ v: done — "Testing Your Skill" measures with/without + old-vs-new; review checklist runs --signal (how-to-write-skills.md:218, :575)
   so the metric stops being a number nobody acts on.
~~6. **Separate "preamble" from "preamble with a table"** in the report —~~ v: done — long_allowlist exists (website-launch) in check-skills.sh
   `go-release`'s 44-line preamble is a decision table (signal), and the report
   currently scores it the same as prose.
~~7. **Write the concurrency rule down**: before editing, check `git status` and~~ → routed to ROADMAP 2026-11-10
   recent mtimes; in this repo a second writer is normal, not exceptional.
~~8. **Eval the doctrine** (2–3 prompts, old vs new skill bodies) before treating~~ → routed to ROADMAP 2026-11-10
   signal-density rewrites as justified rather than plausible.
~~9. **Preserve the doctrine source** as an artifact so the "why" behind~~ v: done — originals/communication-doctrine.md (T44; verified present)
   Principle 7 survives the session that invented it.
~~10. **Have check 15 print the fix**, not just the failure ("delete it, or~~ done at `6fa9a3c`
    rewrite as an instruction") — actionable error messages are repo doctrine.
~~11. **Consider one session report, not two.** Two artifacts for one session is~~ → routed to ROADMAP 2026-11-10
    a split-brain in embryo; the fix is a single report per session, or a rule
    for who writes it when sessions collide.
~~12. **Add the long tail to `TODO_LIST.md`** only if it recurs (both sessions~~ v: resolved — it never recurred as a TODO; T52 audited the remaining prose load-bearing (2026-09-24)
    judged it too small — agreeing is fine, but then it should not reappear in
    three future reports either).

## f) Up to 50 things to get done next

Ordered roughly by value.

~~1. Make check 15 fence-aware and quote-aware; add a negative fixture.~~ done at `6fa9a3c`
~~2. Add a positive+negative fixture test for `--signal` counts.~~ done at `6fa9a3c`
~~3. Replace the `It.s` alternation with explicit `It is|It's` alternatives.~~ done at `6fa9a3c`
~~4. Make check 15 print the remediation line.~~ done at `6fa9a3c`
~~5. Add `--signal` to `SESSION-START.md` step 5.~~ v: done — SESSION-START step 5 names --signal + check 15 (verified present)
~~6. Add a "measuring signal density" paragraph to how-to-write-skills' Testing section.~~ v: done — "Testing Your Skill" measures with/without + old-vs-new; review checklist runs --signal (how-to-write-skills.md:218, :575)
~~7. Add an `--signal` preamble budget with an allowlist for known-good long preambles.~~ v: done — long_allowlist exists (website-launch) in check-skills.sh
~~8. Split the preamble metric into prose-preamble vs structured-preamble (tables).~~ → routed to TODO_LIST 2026-11-10
~~9. Add a glossary hook to `--signal` that flags _unglossed_ jargon, not all jargon.~~ → routed to TODO_LIST 2026-11-10
~~10. Gloss or justify the 35 remaining jargon hits in the 13 flagged skills.~~ done at `2b81484`
~~11. Decide the fate of `go-release` (44-line preamble) — compress or allowlist with a reason.~~ done at `2b81484`
~~12. Decide the fate of `github-voice` (28-line preamble) — same.~~ done at `2b81484`
~~13. Run the long-tail preamble pass over buildflow, docs-health, go-ecosystem-upgrade, go-release, website-launch, github-voice.~~ done at `2b81484`
~~14. Build the old-vs-new eval harness for the 12 edited skill bodies.~~ → routed to ROADMAP 2026-11-10
~~15. Build a with/without harness for `docs-health`, `go-release`, `website-launch` (highest-traffic skills).~~ → routed to ROADMAP 2026-11-10
~~16. Persist eval artifacts (`evals/iteration-N/...`) per the guide's "an eval is not done until it is on disk".~~ → routed to TODO_LIST 2026-11-10
~~17. Preserve the doctrine paste as `originals/communication-doctrine.md` (or docs/feedback/processed/) with a note on what it seeded.~~ v: done — originals/communication-doctrine.md (T44; verified present)
~~18. Line-by-line diff-audit the concurrent session's 12-file pass; account for every removed line.~~ → routed to TODO_LIST 2026-11-10
~~19. Write a concurrency rule into `AGENTS.md` (check status/mtimes before editing).~~ v: done — AGENTS §5.12 "Auto-Commit Daemon Bundles Concurrent Hunks" + git-status guidance
~~20. Add `scripts/` behavior tests to the repo's quality gate (`check-skills.sh` already runs shellcheck/bash -n; add fixture runs).~~ done at `6fa9a3c`
~~21. Consider a `--signal --strict` mode that exits 1 on a caller-supplied threshold, for CI use.~~ → routed to TODO_LIST 2026-11-10
~~22. Document `--signal`'s judgment limit prominently (it lists, it cannot decide) — currently only in the script comment.~~ v: done — usage header: "informational (always exit 0; prints line numbers so an editor can judge each candidate)"; AGENTS §3 carries the advisory framing
~~23. Re-run `--triggers` and decide whether description-level jargon needs glossing at all (1024-char tension).~~ v: decided — descriptions stay unglossed trigger surfaces (d2 of 05-44); outcome-promise row added T53 (2026-09-24)
~~24. Check whether the glossary should be its own file (`references/glossary.md`) so skills can link it.~~ w: decided against — the glossary stayed in how-to-write-skills.md; skills gloss at first use instead
~~25. If the glossary moves, add vendoring/link-integrity coverage for it.~~ w: moot — the glossary never moved (predecessor item decided against)
~~26. Add a TOC to `how-to-write-skills.md` (632 lines and now pattern-dense).~~ → routed to TODO_LIST 2026-11-10
~~27. Re-read `how-to-write-skills.md` for redundancy after Principle 7 — Patterns 9/10 and Principle 7 now overlap at the edges.~~ → routed to TODO_LIST 2026-11-10
~~28. Decide whether Principle 7 should be a Pattern instead (numbering: "Key Principles" vs "Patterns" is getting confusing).~~ → routed to ROADMAP 2026-11-10
~~29. Add feature rows / update `FEATURES.md` if the machinery counts as a feature (currently not gated because no new skill).~~ w: FEATURES.md rows cover skills only; the machinery is documented in README Quality + AGENTS §3 instead (2026-09-18 pass)
~~30. Add a ROADMAP note for "doctrine-driven skill compression" as a sustained theme.~~ v: done — ROADMAP carries the signal-eval / signal-pass theme notes (2026-09-18 harvest, verified present)
~~31. Reconcile the two-session-report overlap with `docs-health` ANNOTATE conventions.~~ → routed to ROADMAP 2026-11-10
~~32. Verify the auto-commit daemon's exclusion rules (why it ignored the addendum for 90+ s).~~ → routed to TODO_LIST 2026-11-10
~~33. Add a `git status` cleanliness assertion to SESSION-START's session-end list (it is prose today; make it a command).~~ v: done — SESSION-START end step: "run check-skills again, leave `git status` clean"
~~34. Consider `trash`-based scratch for fixtures (already followed) and document the fixture pattern.~~ w: nit — the practice was already followed at write time; nothing to encode
~~35. Investigate whether a formatter is rewriting tables/italics in this repo (observed `*why*` → `_why_`, table reflow) — document the owner so edits stop being surprising.~~ v: identified — dprint (repo-committed config); the truncation class was later documented 2026-10-30 (CHANGELOG, T67 evidence)
~~36. Check whether that formatter should be wired into the gate (`--check` mode) so reflows do not appear as mystery diffs.~~ → routed to TODO_LIST 2026-11-10
~~37. Add the 8 glossary terms to any cross-skill vocabulary guard (mirror the marker-vocabulary guard).~~ → routed to TODO_LIST 2026-11-10
~~38. Re-check `linter-building/references/ecosystem.md` (earlier dirty file, committed as `4d62542`) is still internally consistent after the pass.~~ done at `372da1c`
~~39. Spot-check that glosses the concurrent session added match the canonical wording exactly (one wording per term).~~ v: done — T51 aligned all shipped glosses verbatim (decided 2026-10-27; CHANGELOG)
~~40. Add a `--signal` section to the script's `--help`/usage text describing output columns.~~ v: done — the usage block documents --signal output and semantics (check-skills.sh header)
~~41. Have `--signal` print a machine-readable mode (`--json`) for future CI use.~~ → routed to TODO_LIST 2026-11-10
~~42. Decide whether filler detection should also cover mid-sentence filler ("basically", "essentially") — probably not for a hard gate.~~ → routed to ROADMAP 2026-11-10
~~43. Ensure check 15 skips `originals/` (it does — skill dirs only) and confirm vendored `assets/` trees stay excluded.~~ v: verified — the scan excludes `*/originals/*` (check-skills.sh; "originals/ is exempt — frozen source")
~~44. Consider whether `html-report-kit` vendored copies now drift (run `sync-html-kit.sh --check`).~~ v: done — sync-html-kit --check ran exit 0 (2026-09-18 pass, CHANGELOG)
~~45. Run `check-agents-md.sh` to confirm the AGENTS §3.2 edit did not break its guards.~~ v: done — exit 0 (this session's session-end record; green in later waves)
~~46. Re-run the link checker after any glossary/TOC restructuring.~~ w: moot — no glossary/TOC restructure ever happened; the link gate runs green in every wave
~~47. Promote the long-tail pass to a TODO row if it survives two reports without action.~~ v: resolved — it never recurred as a TODO; T52 audited the remaining prose load-bearing (2026-09-24)
~~48. Add a short "what signal density is not" note (it is not minimalism; teaching weight stays).~~ v: done — Principle 7 boundary text "cuts self-narration and decoration, not teaching weight" (how-to-write-skills.md:216)
~~49. Cross-link Principle 7 from `linter-building` and `code-quality-scan` (they are the "quality machinery" skills).~~ → routed to ROADMAP 2026-11-10
~~50. Re-run everything below after any change: `bash -n`, `shfmt -d`, `shellcheck -S warning`, `check-skills.sh`, `check-skill-links.sh`, `check-agents-md.sh`.~~ v: done — all gates green in every subsequent wave (CHANGELOG 2026-09-18 / 2026-09-24)

## g) Questions only you can answer

~~1. **The concurrent session.** Was running a second session on the same paste~~ v: answered — concurrency treated as normal background; the rule was encoded (AGENTS §5.12)
   intentional? If yes, should a parallel writer be treated as a hard stop
   (wait, then integrate) or as normal background noise in this repo? My
   default was to step aside, but I want the rule written down rather than
   guessed.
~~2. **Doctrine provenance.** Should the pasted communication doctrine be~~ v: answered — preserved: originals/communication-doctrine.md with provenance note (T44)
   preserved in the repo as source material (e.g.
   `originals/communication-doctrine.md`), or is Principle 7's distilled form
   the only artifact you want to keep?
~~3. **Evidence bar for rewrites.** `how-to-write-skills.md` says an unmeasured~~ → routed to ROADMAP 2026-11-10
   rewrite is "reasoned, not measured". Should the 12 signal-density body
   rewrites require an old-vs-new eval before they count as done, or is
   review-only acceptance correct for prose changes?

## Session-end state

- Working tree **not clean**: `AGENTS.md`, `how-to-write-skills.md` (a
  formatter reflowed my tables/italics), and the status-report addendum are
  uncommitted; the auto-commit daemon did not pick them up within 90+ s.
- No new worktree, no scratch left behind (fixture tree trashed).
- `check-skills.sh` exit 0; `--signal` exit 0; all modes behave as documented.
- `check-agents-md.sh` exit 0 with one **pre-existing** advisory: `AGENTS.md`
  is 44 KB / 398 lines, over the 30 KB "bloated" threshold. This session added
  one line to it — the warning is not new, but the file is a real trim
  candidate (see f12/f27/f28 on consolidation pressure).
