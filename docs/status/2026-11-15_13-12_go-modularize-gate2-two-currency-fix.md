# Status — go-modularize gate-2 repair: two-currency payoff + dissolve symmetry (2026-11-15 13:12)

**Session:** owner reported "something broke our go-modularize skill — all agents
claim 'next to nothing to do, nothing to extract, keep it all in a huge repo'",
with CV as the exhibiting patient (root module ~84.7k LOC against its own
committed <20k root-slim policy; `docs/modularization/2026-11-15_SUBFEATURE_EXTRACTION_GATES.html`
shows 7 candidates adjudicated, 0 extractions, every seam dissolved at Gate 2).

---

## a) FULLY DONE

1. **Diagnosis confirmed with git archaeology.** The 2026-10-29/30 "rebalance"
   (`7eeeac7` + `446ed94` + `08b8091`) retired the old stop-rule and made the
   five Unix gates the sole decision weight — with Gate 2 recognizing exactly
   ONE payoff currency: a consumer (real or named-with-trigger) that composes
   the candidate without siblings. In a single-app monorepo the only consumer
   is the app itself — a sibling by definition — so pipe payoff is structurally
   unavailable, Phase 0's "dissolve and stop" fires for every candidate at any
   repo size, and the skill's only possible output is "nothing to extract".
   This contradicted the skill's own text in three places ("Why This Matters"
   lists payoffs that need no second consumer; the "No consumer variance" row
   said import bans and per-module CI ARE payoffs; FM#11's remedy routed
   through the same Gate 2 that had just dissolved the seam, making
   under-modularization unfixable by construction). The CV session even
   flagged the gap itself — "policy payoff, not a Gate-2 composition payoff.
   Under the gate as written these fail the pipe test" — and correctly
   refused to un-park owner-gated stages, but the skill gave it no vocabulary
   to do otherwise.
2. **Gate 2 rebuilt as two-currency** (`go-modularize/SKILL.md`): pipe payoff
   (unchanged bar) OR policy payoff — a committed, named size/ownership/CI
   policy the boundary measurably advances, with a symmetric evidence bar
   (name the artifact AND show the advance; "big repos should be smaller"
   feelings are not policy). Explicitly notes `internal/` blocks nothing
   between sibling packages inside one module — the compile-time import ban
   is what a module boundary buys (corrects CV's "the package boundary
   already provides [the import ban]" confusion). Explicitly warns that
   pipe-only weighing in an app monorepo is a keep-the-monolith bias, not
   direction neutrality.
3. **Dissolve-symmetry rule added**: a failed Gate 2 blesses nothing — every
   dissolve inside a module that violates a committed size policy or matches
   god-package shape carries an FM#11 standing finding + one owner question
   (ratify the policy → re-run gate 2 with it, or retire it and accept the
   monolith on the record). "Nothing to extract" is a seam verdict, never
   "nothing to do".
4. **Contradictions reconciled**: "No consumer variance" row now routes to the
   policy currency; "When to split further" replaced its hypothetical
   "could compose like a Unix pipe" test (which the evidence bar rejected)
   with forced-import grep evidence; FM#11 mitigation now says "pass gate 2
   in either currency"; merge-guard table gained the policy-reliance row
   (mirror-image bug: merging away policy-backed boundaries); decomposition-
   depth bullet now evidence-based.
5. **Procedures aligned** (`references/phases.md`): Phase 0 evaluates BOTH
   currencies before dissolving (grep plans/ADRs/TODOs for size ceilings and
   ownership maps), adds the dissolve-symmetry check as step 3; 1.5 scoring
   and Phase 7 reflection item 7 updated to the two-currency vocabulary.
6. **Worked example added** (`references/example.md`): "When policy payoff
   pays — the carve no consumer will ever justify" — the CV story anonymized
   (84k root, committed 20k ceiling, 4,900-LOC brain candidate): PASS on
   policy currency; with no committed policy the same candidate dissolves but
   must carry the FM#11 finding and owner question.
7. **Quality gates green**: `scripts/check-skills.sh` all 35 skills pass;
   dprint formatted (whitespace-only beyond content edits); no stale
   "Pipe test"/"Unix-pipe test" references; SKILL.md at 310 lines (<500).

## b) PARTIALLY DONE

1. **CV repo itself untouched** — its owner questions (M108 module-name gate,
   ratify-vs-retire the <20k policy, the 11 sibling red legs) are Lars's to
   answer, and re-adjudicating CV under the fixed gate is a fresh CV session's
   job (predicted outcome: carve stages 2–4 and the agent carve now PASS gate 2
   via the policy currency — the <20k policy is committed — leaving M108 as the
   only blocker; replyloop/alertrouter still dissolve honestly: no consumer, no
   policy pressure their size justifies).

## c) NOT STARTED (deliberately)

1. No eval run of the fixed skill against a fresh prompt — the natural next
   probe is a CV-shaped sub-feature-extraction ask in a clean session.
2. No backfill of the 2026-10-30 gate lesson into `docs/feedback/` — the
   rebalance was an agent-authored change, not user feedback; the loop does not
   apply.

## d) TOTALLY FUCKED UP

Nothing this session. (The bug being fixed was itself a past session's
over-rotation — the rebalance fixed the old "stop-rule hides monoliths" failure
by installing a gate that hides them harder. Recorded here because the lesson
matters: when a gate is given a single evidence currency, it becomes a bias
with a bureaucracy.)

## e) WHAT WE SHOULD IMPROVE

1. **Single-currency gates are load-bearing biases.** Any future gate that
   decides via one evidence type should be checked against the population it
   will structurally never pass (here: app monorepos). Worth a line in
   `how-to-write-skills.md` if this recurs.
2. The CV lesson "policy payoff not pipe payoff" sat in a committed artifact
   for 16 days before this fix — sessions executing the skill should surface
   contradictions they are forced to hand-wave, not just note them inside
   patient-repo reports.

## f) NEXT

1. Re-run a CV-shaped extraction ask under the fixed skill and record the
   verdict flip (or its honest absence) as the eval evidence.
2. Answer g1 before any CV re-adjudication touches owner-gated stages.

## g) QUESTIONS ONLY THE OWNER CAN ANSWER

1. The CV <20k root-slim policy is now gate-2 evidence by name — do you want
   the (a) ratify-and-carve, (b) retire-and-rebaseline, or (c) park-with-
   loc-gate decision made first, so the re-adjudication inherits it rather
   than asking again?
