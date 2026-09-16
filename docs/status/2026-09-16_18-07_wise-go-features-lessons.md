# wise-go FEATURES.md Lessons — Session Status Report

**Date:** 2026-09-16 18:07
**Session scope:** User asked "What can we learn from
`/home/lars/projects/wise-go/FEATURES.md` for our skills?" — read, understand,
research, reflect, execute, verify.

---

## a) FULLY DONE

1. **Studied the exemplar.** wise-go's FEATURES.md is a mature specimen of the
   format the `docs-health` skill prescribes: 8 status labels each answering
   ONE question ("does working code exist — and if not, why not?"), a
   dedicated evidence column with `file:line` refs on every row, an
   external-truth sweep date-stamped in the doc ("audited 2026-09-16 against
   the live Wise Platform API reference"), and count claims gate-checked by
   `nix run .#doc-verify` against the compiled surface.
2. **Five lessons extracted and encoded into docs-health** (SKILL.md +
   FEATURES-template + build-guide + verify-checklist + common-mistakes):
   - `DISABLED` split out of `BROKEN` — code that is correct but externally
     switched off (flag, credential, CI) has a different remedy (flip, not
     fix) than failing code. Our old vocabulary merged them.
   - Absent-why extensions (`DEMAND_GATED`, `ON_HOLD`, `OUT_OF_SCOPE`) so
     `PLANNED` cannot become a dumping ground that hides "next on the build
     path" vs "awaiting demand" vs "awaiting a decision" vs "deliberately
     excluded".
   - Evidence is a column, not an afterthought buried in Notes.
   - "Zero BROKEN rows is itself information" — failure states stay nameable.
   - Counts verifiable + external sweeps date-stamped; prefer a standing gate
     over hand-maintained numbers.
3. **Transplanted the doc-verify pattern** into `scripts/check-skills.sh` as
   check 14 (FEATURES coverage guard): every skill directory must have a row
   in FEATURES.md. **First run caught real drift**: buildflow,
   collector-extraction, github-voice, jj-fork-pr-workflow, linter-building
   shipped 09-08..09-14 with no row. Line counts deliberately NOT gated
   (derivable from the script; two copies of the same number always rot).
4. **Fixed the drift it found:** FEATURES.md gained the 5 missing rows (all
   honestly 🆕 NEW — trigger evidence grepped from docs/status, T30/T34 still
   open), the per-skill `Lines` column was removed (12 of 24 rows had
   drifted), the website-launch gap note updated 848→803, and a new
   "GitHub & Open Source" section holds jj-fork-pr-workflow + github-voice.
5. **Wiring:** AGENTS.md §4 step 4 now includes the FEATURES.md row (gated);
   CHANGELOG entry added.
6. **Verification:** `check-skills.sh` exit 0 (quoted, all 30 skills, zero
   FAILs — the coverage guard fires correctly when a row is missing, proven
   live before the fix); `shfmt -l scripts/` clean; dprint fmt applied;
   `check-agents-md.sh` exit 0 (same 1 pre-existing bloat advisory);
   SESSION-START.md executed up front (feedback empty, newest report read,
   TODO_LIST read).

## b) PARTIALLY DONE

1. The vocabulary change is reasoning-verified, not behaviorally validated —
   no fresh-session run has built a FEATURES.md with the new labels yet.
2. dprint fmt touched two historical status reports (2026-09-14) as
   formatting-only side effects of the full-repo fmt run; content untouched.

## c) NOT STARTED

1. wise-go-side: nothing needed — its FEATURES.md is the source exemplar, not
   a target of these changes.
2. Rolling the new labels into any existing consumer project's FEATURES.md
   (wise-go already uses the full 8; no other project audited this session).

## d) TOTALLY FUCKED UP

Nothing shipped broken. One mid-session miss: the check-skills.sh header-comment
edit failed on a malformed edit payload (bad old_string) and was redone cleanly;
the AGENTS.md edit was correctly rejected once for not reading the file first.

## e) WHAT WE SHOULD IMPROVE

1. The 5 missing FEATURES rows existed because new-skill sessions (buildflow
   2026-09-14 included) wired README + AGENTS §5.5 + ROADMAP but skipped
   FEATURES.md — now structurally impossible (check 14 fails the build).
2. Hand-maintained line counts in living docs are pure rot surface; removed
   here, but the pattern could recur elsewhere (grep for count claims when
   docs feel stale).

## f) Next tasks (prioritized)

| # | Task                                                                                             | Why / size                       |
| - | ------------------------------------------------------------------------------------------------ | -------------------------------- |
| 1 | On the next real docs-health BUILD/VERIFY run in a consumer project, exercise the new vocabulary | Behavioral validation (natural)  |
| 2 | Existing T30/T34 remain the aging path for the 5 🆕 NEW rows                                     | Already tracked                  |
| 3 | Consider whether TODO_LIST/ROADMAP want a "why not" split analogous to absent-why labels         | Same conflation exists there (S) |
