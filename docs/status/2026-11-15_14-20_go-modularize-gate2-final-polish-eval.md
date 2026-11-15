# Status — go-modularize gate-2: final polish + first behavioral eval (2026-11-15 14:20)

**Session:** owner instruction "last change to perfect the skill" — execute
the owner-independent items from the 13:22 self-review
(`2026-11-15_13-22_go-modularize-gate2-fix-self-review.md` f-list).
Owner-gated items (f6, f8, f9) were deliberately NOT touched; questions
g1–g3 remain open.

---

## a) FULLY DONE

1. **f2 — policy-lapse symmetry** landed in `go-modularize/SKILL.md` gate-2
   evidence bar: policy retired or ceiling already met → the boundary's
   justification is dead → re-run gate 2 before keeping the seam.
2. **f3 — anti-gaming clause** landed beside it: a size policy authored in
   the same session that proposes the extraction is self-ratifying, not
   committed; it counts only after an owner question ratifies it (a policy
   predating the session in a committed artifact counts on its face).
3. **f4 — vocabulary pass finished**: SKILL.md FM#8 row, phases.md 1.5
   intro, and evals.json eval-2 expected output now all say "payoff in
   either currency" / "pipe payoff"; zero stale "composability payoff"/
   "Pipe test" strings remain inside the skill.
4. **f7 — generalized lesson** landed in `how-to-write-skills.md` Hard-Won
   Process Lessons: a decision gate recognizing exactly one payoff currency
   is a structural bias against every population that can never pay in it
   (dated, evidence-cited, points at the persisted probe).
5. **f1 — behavioral eval RUN (the skill's first probe run).** Two new
   regression evals added to `go-modularize/evals/evals.json` (eval 4:
   CV-shaped policy-payoff carve; eval 5: same-session-policy anti-gaming),
   three fresh subagent probes spawned the same turn, old-skill baseline =
   git `e1d8a05` per the `evals/README.md` old-vs-new protocol. Results:
   - eval 4 old_skill: **2/4** — dissolves the seam, explicitly rules the
     committed policy inadmissible ("no LOC ceiling can override a failed
     gate"), fails exactly the two assertions the repair targets.
   - eval 4 with_skill: **4/4** — extracts via policy currency (named
     artifact + measured advance 85k→80k vs 20k ceiling), flags the prior
     review via dissolve symmetry, applies the lapse rule unprompted.
   - eval 5 with_skill: **4/4** — rejects the same-session policy as
     self-ratifying, owner ratify-or-retire question, keep-as-package,
     applies the ceiling-met decay branch unprompted.
     **The verdict flip the repair was built for is demonstrated and
     measured, and the skill did not become an extraction license.** All
     outputs + grading.json + metadata + run README persisted under
     `go-modularize-workspace/iteration-1/` (the on-disk rule).
6. **f5 — quality battery green**: `check-skills.sh` 35/35 exit 0 (after
   every edit batch); dprint over all touched files; docs-gates full run
   **PASS on all five gates** — annotate ratchet exactly at the pinned 372
   (no new findings; the 5 F/spacing lines printed are the documented
   pre-canon archive/workspace corpus), freshness/routing/cadence healthy
   after the TODO edits. buildflow full battery: see b1.
7. **f11 — CHANGELOG convention confirmed and honored**: skill fixes DO
   belong there (Keep-a-Changelog-adapted waves). The missing 2026-11-15
   fix entry was written retroactively covering bug, fix, hardening, eval
   results, and the generalized lesson.
8. **Harvest**: self-review f-items f6/f8/f9/f10/f12 routed into TODO_LIST
   T122–T126 (pre-flighted SAFE via `docs-gates freshness --pre-flight`,
   fed on stdin per the tool's contract; no historical item flips).
   `.docs-gates-preflight.json` git-ignored as the tool itself requested.
9. **FEATURES.md go-modularize row** re-checked same-turn per SESSION-START
   step 6: now carries the hardening + eval-evidence line.

## b) PARTIALLY DONE

1. **buildflow full battery: every step green, exit 69 from the known
   pinned noise only.** Sequence: first run failed `dprint-format` on a
   78-file pre-existing drift; the repair loop then CRASHED (dprint errors
   on tables nested in list items inside frozen archived reports) after
   reformatting 4 frozen eval OUTPUT artifacts (~1,000 lines of compiled
   CSS evidence) — restored via `git restore`, but a second `--fix`
   launched seconds after the dprint.json edit re-applied the corruption
   (config/result-cache race) and the auto-commit daemon committed it in
   `2a1b72a`; the byte-for-byte restore landed as `5e585c4`. dprint.json
   now excludes frozen-evidence paths (`docs/status/archived/**`,
   `docs/planning/archived/**`, `**/outputs/**`, `*-workspace/**`), the
   live drift was formatted (9 files, all whitespace/table-alignment, each
   hunk inspected), and the full battery then ran 86 success / 0 failed /
   lychee ✔ / docs-gates ✔. Exit 69 is solely the 4 pre-existing
   `file-size-check:go-file-too-large` findings on the single-file Go
   assets (annotate.go, analyze-corpus.go, ...) — T69's standing noise,
   routed 2026-11-10; splitting those files would contradict §1's
   deliberate single-file convention, so the disposition stays with T69.

## c) NOT STARTED (deliberately)

1. **f6 (CV breadcrumb), f8 (CV re-adjudication), f9 (CV metric record)** —
   all gated on owner questions g1/g2 from the 13-22 report; now TODO rows
   T122–T124 (BLOCKED).
2. **f10 full 3-shape corpus** — this session landed shape 1 (single-app
   monorepo, evals 4–5) plus the anti-gaming negative; the
   library-monorepo and over-modularized shapes and the full R16 battery
   remain owner-gated per `evals/README.md` (T125).

## d) TOTALLY FUCKED UP (read these)

1. **Daemon beat me to the core commit AGAIN**: despite committing
   "immediately" after the gate run, the 4-file hardening landed as
   heuristic `08a64ae` (§5.12, second session in a row — d5 of the 13-22
   report now has a sibling). The window that killed it was running
   check-skills BETWEEN edit and commit. Lesson for the next session:
   when the edit batch is small, commit FIRST and gate second (the gate
   can amend nothing, but a green gate over committed content is equal
   evidence), or accept the daemon floor and put the detailed message in
   the session record only. No history rewritten.
2. **Two more read-discipline stumbles (CHANGELOG + FEATURES)**: edited
   after bash-head/rg inspection instead of View — the tool guard caught
   both, same class as 13-22 d1/d2. Fourth and fifth recorded strikes of
   the "bash-read counts as read" fallacy. The guard is the only reason
   these are honest notes instead of silent corruption.
3. **Quoted `tail`'s exit code as buildflow's** (`buildflow | tail; echo $?`)
   and read "exit 0" while the log above it said ERROR — the exact
   SESSION-START failure mode ("quote the exit status, never the output
   tail") reproduced against a pipeline instead of a tail. Fixed in the
   next invocation (`buildflow > log; echo $?` → 69).
4. **`buildflow --fix` reformatted frozen eval OUTPUT artifacts** (compiled
   CSS snapshots in `design-to-code/evals/**/outputs/`) before crashing —
   an automated repair corrupting point-in-time evidence. Caught because
   `git diff -w --stat` refused to collapse (1,003 deletions), restored via
   `git restore` within the minute. The exclude fix (b1) is the systemic
   cure; the near-miss is why frozen artifacts now sit OUTSIDE dprint
   scope instead of trusting the formatter to be gentle. Post-fix
   verification: `buildflow -s dprint-format` check-mode ✔ with the
   artifacts untouched (git status clean over design-to-code/), and the
   definitive full battery 86 success / 0 failed, exit 69 = T69's four
   findings only.

## e) WHAT WE SHOULD IMPROVE (systemic)

1. **Eval-before-ship is now precedent, not proposal**: this session ran
   the probe the last session skipped. Encode in future doctrine edits:
   no gate/threshold change ships without a fresh-session probe, and the
   probe artifacts go on disk the same session (f1's pattern, now
   demonstrated twice: go-release, go-modularize).
2. **The old-skill baseline costs one `git archive`** — cheap enough to
   make old-vs-new the default eval shape for every doctrine change, not
   just rewrites.
3. **Pre-flight via stdin is the docs-gates contract** — candidate lines
   on stdin, verdict on the last line; feeding it the exact future rows
   caught nothing this time but costs seconds.
4. **Bulk formatters must be scoped away from frozen evidence**: a format
   gate that includes archived reports and eval outputs will either crash
   (nested tables) or corrupt evidence ("fixing" compiled artifacts). The
   dprint.json exclude list is now the repo's encoding of that boundary —
   extend it, never delete it, when new frozen-evidence dirs appear.
5. Upstream observation (not filed): a `buildflow -s <tool> --fix` run
   launched seconds after a dprint.json edit re-applied stale scope —
   suspected result-cache/config race; BuildFlow#47 made dprint.json
   cache-key material. Until clarified, always `git status` after a fix
   run that follows a config edit by less than a minute.

## f) NEXT (up to 50; honest count: 4 — the rest are already T-rows)

1. T122–T126 in TODO_LIST (CV re-adjudication, CV breadcrumb, CV metric
   record, eval corpus, production-run watch) — all owner-gated or
   scheduled; nothing new to add.
2. Consider a `run-eval.sh` helper for the old-vs-new probe dance
   (archive old skill → spawn same-turn probes → persist outputs) —
   repeated by hand twice now (go-release, go-modularize).
3. T74-analog: render `go-modularize-workspace/iteration-1` through
   skill-creator's `generate_review.py --static` if a human review pass
   is ever wanted (headless this session; not blocking).
4. **Sixth read-discipline strike prevention**: the authoring-guide's
   "read-your-own-authoring-guide" item could gain one line — "bash
   head/cat/rg is NOT a View; the edit tool tracks View reads only"
   (candidate for T111's cluster).
5. Upstream observation (not filed): a `buildflow -s <tool> --fix` run
   launched seconds after a dprint.json edit re-applied stale scope —
   suspected result-cache/config race; BuildFlow#47 made dprint.json
   cache-key material. Until clarified, always `git status` after a fix
   run that follows a config edit by less than a minute.

## g) QUESTIONS ONLY THE OWNER CAN ANSWER

(unchanged from the 13-22 report — g1 CV policy ratify/retire/park and
M108 ordering; g2 cross-repo write consent for the CV breadcrumb; g3
whether an agent may PROPOSE a policy it then asks you to ratify. This
session's eval 5 shows the skill already handles the propose-then-ratify
flow conservatively either way, so g3 is convenience, not correctness.)

---

**Commits this session:** `08a64ae` (daemon, hardening content — f2/f3/f4/
f7/evals), `995a2ff` (TODO harvest T122–T126 + gitignore), plus this
report, CHANGELOG, FEATURES, and the workspace artifacts (committed with
this report).
