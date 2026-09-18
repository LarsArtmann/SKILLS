# Status Report — Signal-Only Communication Doctrine Applied to Skill Bodies

**Date:** 2026-09-17 ~21:45 (Thursday, CEST)
**Session scope:** User pasted a communication doctrine ("SHUT UP AND
COMMUNICATE": delete the first 90%, physical-world test, communication is
behavioral control, clear over clever) and asked: _how would you apply this
to our SKILLS?_ — with explicit instruction to break down, execute, and
verify step by step.
**Format:** markdown (7-session streak of HTML-default overrides made
explicit in reports; this session was not asked for a report format at all —
defaulted to the lightweight markdown form used by recent mid-size sessions).

## TL;DR

The doctrine is now encoded as **Principle 7 ("Signal density")** in
`how-to-write-skills.md` (added by a **concurrent session**, commit
`5116703`, together with a `check-skills.sh --signal` advisory) and applied
to the skill **bodies** by this session: 12 skills edited, every fix verified,
all checks green (exit 0). 18 of 30 skills needed nothing.

## a) FULLY DONE

1. **SESSION-START executed** — feedback/new empty; newest report (09-16
   18-47 docs-health audit) TL;DR read; TODO_LIST read (T30/T33/T34/T35 open,
   none touched by this task); AGENTS §8/§9 in context; `check-skills.sh`
   exit 0 (30 skills, 149 md files, 0 thin).
2. **Doctrine mapped to skill-authoring** — the four doc principles
   translate 1:1 onto existing repo doctrine: delete-90% ≈ Principle 7
   signal density; physical-world test ≈ "what tool call does this line
   produce"; behavioral control ≈ "if deleting loses no behavior, delete";
   clear-over-clever ≈ jargon glossary + plain constraints. Conclusion: the
   repo already had 80% of this (Patterns 9/10, Common Mistakes) — the gaps
   were the per-paragraph action test and the jargon glossary.
3. **Concurrent-session collision handled** — while auditing,
   `how-to-write-skills.md` changed under me (mtime 21:27): another session
   had added Principle 7 + the `--signal` checker flag (commit `5116703`).
   My planned "Pattern 12" would have duplicated it — **skipped, not
   duplicated** (a split brain about split brains). This session took the
   complementary half: applying the doctrine to bodies.
4. **Audit** — read-only sub-agent swept all 30 bodies with the four tests
   (preamble / non-actionable prose / jargon / buried lede; linter-building
   excluded while it carried foreign uncommitted changes). 18 files clean,
   zero buried-ledes. Every finding independently re-verified against source
   before editing (no single tool output drove a semantic change).
5. **Fixes applied** (all re-read post-edit; full diff reviewed, every
   removed line accounted for):
   - `full-code-review` — Mindset pep-talk section deleted (persona already
     lives in the description); both noise items gone; verschlimmbessern
     threat → glossed guardrail; split-brain + entombed glossed at first use.
   - `pareto-planning` — "UNDERSTAND????!"/caps noise dropped; magic numbers
     (30–100min/27 tasks, 15min/150 tasks) **kept, plainly stated, no
     fabricated rationale**; threat → guardrail; two filler lines deleted.
     Full-Execution-Mode block kept deliberately (it is instruction).
   - `website-launch` — 4-line session-history sales pitch deleted;
     editing-history meta compressed to the rule it teaches (803→797 lines).
   - `nix-review` / `naming-review` — credentials prose → one line / dropped.
   - `library-deep-dive`, `data-model-review`, `go-modularize` — "Why This
     Matters" philosophy compressed into detection criteria (all concrete
     smells/examples kept — teaching weight preserved per Pattern 10).
   - `verify-before-filing` — vulnerability paragraph compressed to its one
     enforceable sentence; "epistemic error" glossed.
   - `brutal-self-review` — ghost system / split brain glossed at first use
     (canonical glossary wording).
   - `jj-fork-pr-workflow` — prior-art survey moved to new
     `references/prior-art.md` (with a re-verify caveat); the operationally
     load-bearing gh-stack `.jj`-safety rules kept inline.
   - `docs-health` — Verschlimmbesserung glossed; `status-report` — entombed,
     ghost system, split brain glossed; `architecture-review`, `naming-review`,
     `nix-review`, `go-error-modernization` (cargo-cult) — first-use glosses.
6. **Verification** — `check-skills.sh` exit 0 after all edits; internal
   links OK across 150 md files (incl. new prior-art.md); `--signal` deltas
   as expected (website-launch prose 10→9/preamble 19→14, jj prose 2→0,
   nix-review prose 2→0, etc.). Remaining advisory hits are deliberate
   keeps (execution-mode directives, self-glossing contexts like
   linter-building:105 and buildflow:18) — restraint is success.
7. **CHANGELOG** — dated "signal-only prose pass" entry added under
   Unreleased, crediting the concurrent session for Principle 7.

## b) PARTIALLY DONE

- **--signal advisory long tail.** The advisory still lists prose blocks in
  buildflow, docs-health, go-ecosystem-upgrade, go-release, website-launch,
  github-voice (28 preamble lines). Spot-checks showed most are
  behavior-carrying rules, but a future pass could compress the top few.

## c) NOT STARTED

- None for this task.

## d) DEFECTS / OPEN QUESTIONS

- **d1 (observation):** the auto-commit daemon batched this session's 14-file
  edit wave into one "heuristic" commit (`a45e9b2`) while work was still in
  flight — same class as the 2026-09-13 go-paperless lesson; no damage here
  (all edits were complete), but mid-task commits make "diff before finish"
  verification two-step (diff vs daemon commit + diff working tree).
- **d2 (question):** descriptions use house jargon unglossed (e.g.
  status-report desc "ghost systems, split brains"). Deliberate choice —
  descriptions are trigger-matching surfaces, glosses would eat the 1024-char
  budget — but it means the glossary only helps after activation. Acceptable;
  noting so the next session doesn't "fix" it into bloat.

## e) NEXT

1. Optional: run `--signal` over the b)-list long tail in a quiet session.
2. T35 (annotate pre-09-09 status reports) remains the oldest open TODO row.

## f) Forward work for HARVEST

None — no new tasks surfaced beyond the optional long-tail pass above (too
small for a TODO row; if it recurs, promote it then).

## Addendum — infrastructure half (writer of Principle 7)

This report's author and the session that added Principle 7 +
`check-skills.sh --signal` ran concurrently on the same paste; the two halves
complement each other and neither was duplicated. The infrastructure half is
complete and verified (committed while the body pass was in flight):

- `how-to-write-skills.md` Principle 7 (rule + before/after + the canonical
  house-jargon glossary) and Common-Mistakes rows.
- `scripts/check-skills.sh --signal`: advisory, always exit 0, prints per
  skill the preamble size before the first `##`, code-free prose blocks ≥35
  words (fence- and list-continuation-aware), throat-clearing hits, and
  jargon hits with line numbers.
- `scripts/check-skills.sh` check 15: hard-fails the unambiguous
  throat-clearing set only; everything judgment-dependent stays advisory so a
  grep never deletes load-bearing rationale (Pattern 10).
- `AGENTS.md` §3.2 documents the rule and both aids.

Verification: mode matrix `check`/`--thin`/`--triggers`/`--signal` → exit 0,
unknown flag → 2; a seeded fixture SKILL.md with two filler lines fails check
15 and prints both offending line numbers; `bash -n`, `shfmt -d`, and
`shellcheck -S warning` clean apart from the pre-existing SC2044; full run
exit 0 with 30 skills and 150 linked markdown files.

The advisory's known limit: it surfaces candidates, it cannot judge them —
the remaining `--signal` long tail (section b) needs a reader, which is
exactly why check 15 is scoped to throat-clearing only.
