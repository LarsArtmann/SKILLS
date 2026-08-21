# Status Report — TODO Wave Completion Pass (T11–T20 + Follow-ups)

**Date:** 2026-08-21 22:51
**Scope:** This session's second pass (continuation of the 21:57 report):
executing the remaining TODO-wave items — T11–T16, T19, T20, the
GONOSUMDB eval follow-up, the scratch-helper improvement (e1), README
re-check, and TODO_LIST/CHANGELOG bookkeeping. First pass (T1–T10, T17,
T18) is covered by `2026-08-21_21-57_todo-execution-wave.md`. All changes
committed by the auto-commit daemon (`2fc1b46` tip).

---

## a) FULLY DONE

1. **T11 — website-launch SKILL.md trimmed 840 → 799 lines.** Phase 2's
   badge markdown and documentation link bar (last big duplication of
   readme-template.md) replaced by a pointer to the template's "Badge
   Template" / "Documentation Link Bar" sections. The pointer explicitly
   warns against restating the markup ("every restatement has historically
   drifted"). The template itself gained what the SKILL.md version had and
   it lacked: the applications badge variant (Docker instead of Go
   Reference) and the `{LICENSE}` placeholder rule (never assume MIT).

2. **T12 — `scripts/check-skill-links.sh` created and integrated.** CI-grade
   internal-link detector for ALL skill markdown (122 files): relative file
   links, in-file `#anchors` with GitHub-style slugs (lowercase, punctuation
   stripped, duplicate `-1`/`-2` suffixes), `file.md#anchor` combinations,
   fenced-code and inline-code exclusion, HTML `<a id=...>` anchors
   recognized, true line numbers in failure output. Wired into
   `check-skills.sh` as check 12. First run surfaced 24 findings → 22 were
   checker false positives (inline code like `` `errors.AsType[E](err)` ``
   and `<a id>` anchors — both fixed in the checker), 2 were real (a dead
   `./references/examples.md` link inside an inline-code example — false
   positive after the fix — and one genuinely broken TOC anchor in
   performance-tuning.md `#containers-gomaxprocs-and-cgroup-quotas`,
   fixed). Negative test with 7 edge cases (missing file, bad anchor, valid
   anchor, dup-slug suffixes `-1`/`-2`, html anchor, inline-code) behaved
   exactly as designed.

3. **T13 — Process lessons encoded.** `how-to-write-skills.md` gained an
   "Eval harnesses: two shapes" subsection (with/without vs old-vs-new,
   citing the 35%→100% website-launch result), the rule "an eval is not
   done until it is on disk" (output.md + grading.json per run), and a
   "Hard-Won Process Lessons" section: Questions-tool 200-char limit,
   verify-or-hedge for external-tool sentences, verification-status tables
   in references, trash-for-scratch-dirs. `verify-external-claims/SKILL.md`
   gained §0 "The chat-time gate" — the skill applies at the moment any
   external-behavior sentence is written, not just at skill-creation time.

4. **T14 — REAL benchmark examples in performance-tuning.md.** All three
   were actually run (scratch module, go1.26.5, AMD Ryzen AI MAX+ 395,
   32 threads) and the true output pasted:
   - `-cpu` sweep: knee at 16 workers (2.00ms → 0.61ms 1→16), **worse at
     32** (0.61ms), with B/op growth noted as allocation-side traffic.
   - False sharing: before/after with a 56-byte pad, measured with the
     authentic workflow (same package, same benchmark name, `-count=6`,
     measure → fix → re-measure): benchstat verdict **-80.21%
     (p=0.002, n=6)**.
   - The benchstat methodology bullet now points at the worked example.

5. **T15 — bdd-testing cross-link.** New "Benchmarks are not specs" section:
   performance assertions don't belong in Ginkgo suites; plain
   `BenchmarkXxx` + CI comparison instead; one-way link to
   performance-tuning.md methodology (no duplication).

6. **T16 — trash safety item in go-release quick-reference.md** Phase 6
   checklist ("cleanup uses trash, never rm -rf").

7. **GONOSUMDB follow-up (from T7's last eval miss).** multi-module.md
   Step 9 now prefixes the clean-room `go get` checks with `GONOSUMDB='*'`
   plus a rationale (sum.golang.org propagation independence). Claim
   verified against `go help environment` before encoding — the chat-time
   gate applied to my own edit.

8. **T19 — og:image guidance + launch-post template.**
   file-manifest.md "OG Image Generation" gained the 1200×630 sizing rule
   and the poster-as-landing-og:image override (linking to demo-video.md).
   content-patterns.md gained the "Launch-post copy (mini-template)" —
   hook/link/proof-point skeleton derived from the one-narrative rule, with
   constraints (no claims the README can't back).

9. **T20 — CONTRIBUTING.md add-skill flow.** Six steps: authoring guide
   (trigger-first description warning), directory layout + pattern skills,
   html-kit vendoring via sync-html-kit.sh, the symlink step
   (`link-skills-to-agents.sh` incl. the `--force` recovery path), README
   inventory row (no hardcoded counts), and final validation. Validation
   section updated to list all current scripts.

10. **e1 — `scripts/scratch.sh` helper.** Create (`scratch.sh <name>` →
    /tmp/scratch-\<name\>, registered in a manifest), `--list`, `--clean`
    (trashes every registered dir). Refuses to run without `trash`.
    Tested end-to-end, then used to clean up all 11 of this session's
    scratch directories.

11. **README re-check.** website-launch row already mentions the
    sales-video engine; the 25-skill count is accurate — no change needed
    (verified, not assumed).

12. **Bookkeeping.** TODO_LIST.md rebuilt: T1–T20 removed, six remaining
    verified-open items re-numbered T21–T26 with evidence (two ground-truth
    items, two verification-debt items, two polish items). CHANGELOG.md
    gained the full "TODO wave T1–T20 fully executed" Added/Changed wave
    entries. The 21:57 status report's (f) list annotated with `done at`
    markers so HARVEST skips them.

---

## b) PARTIALLY DONE

1. **website-launch SKILL.md length** — 799 lines, still above 500 and
   above the original "trim below 800" goal by 1 line of margin. The next
   extraction candidate is identified (Phase 2's 25-item structure list
   duplicates readme-template.md's "Standard Section Order") and tracked
   as T25, but not executed — the wave's goal (below 800) is met, the
   repo's real goal (<500 or a justified allowlist) is not.

2. **T5/T22 HyperFrames ground truth** — unchanged from the first pass:
   doc-level verification only (skill bodies read, claims corrected/softened
   against them), no live render has validated the corrected 9:16 guidance.

---

## c) NOT STARTED

1. **T21** — Retro-audit of existing live sites against the new demo-video
   Definition of Done (open since the 08-21 morning report; not part of
   this wave's scope).
2. **T23** — govalid generator end-to-end verification (struct tags compile
   — proven in the T6 pass — but `go generate` output never run).
3. **T24** — website-launch eval-1 re-run with a fully fictional repo to
   remove the real-repo/maintenance-mode asymmetry between the two configs.
4. **T26** — Trigger-density lint mode for check-skills.sh (report
   near-misses without gating) — follow-up idea from the T1 guard.
5. **ROADMAP.md sync** — the new T21–T26 numbering and the wave outcome are
   in TODO_LIST/CHANGELOG, but ROADMAP was not touched this pass; its open
   questions may now overlap (e.g. g1-g3 of the 08-21 morning report on
   autoplay/social-cut/API-library video policy remain unanswered and are
   not represented in TODO_LIST).

---

## d) TOTALLY FUCKED UP

1. **The scratch.sh dogfood round-trip trashed the wrong directories first.**
   I registered the session's scratch names and ran `--clean`, which
   trashed the freshly-created empty `/tmp/scratch-<name>` dirs — not the
   real `/tmp/<name>` originals. Caught by listing; the originals were then
   trashed directly with `trash`. The helper itself is correct (it cleans
   what it created), but the migration pattern "adopt existing dirs into
   the manifest" doesn't exist — a helper gap that cost a round trip and
   briefly looked like cleanup was done when it wasn't.

2. **Check-skill-links v1 shipped with two false-positive classes.** First
   run flagged 24 "broken" links of which 22 were checker bugs (inline code
   spans, HTML anchors). I initially read the output as "mostly genuine
   findings" and started investigating files before questioning the
   checker. Lesson applied but late: when a new linter's first run lights
   up, suspect the linter before the corpus. The fixed checker then found
   exactly one genuine issue.

3. **The benchstat pairing mistake.** My first two A/B attempts used
   different benchmark names (`CounterShared` vs `CounterPadded`) or
   different packages (v1/v2) — benchstat refused to pair them (geomean
   warnings, separate tables). Third attempt did it right: same package,
   same benchmark name, measure → apply fix → re-measure. Two throwaway
   benchmark runs because I designed the harness around the wrong
   invariant (name identity) and only noticed from benchstat's own output.

4. **Two edit failures on markdown table syntax mid-pass** (one in
   CONTRIBUTING rewrite context, one renumbering the status report's
   section c) — the second dropped T12 out of the numbered list silently
   and I only caught it by re-reading the whole file afterward. Renumbering
   lists via sequential edits is error-prone; write the full block in one
   edit.

---

## e) WHAT WE SHOULD IMPROVE

1. **Adopt-existing-dirs mode for scratch.sh** (`scratch.sh --adopt /tmp/x`)
   so cleanup of pre-helper scratch dirs goes through the manifest instead
   of ad-hoc trash calls — closes the gap that caused d1.
2. **New-linter triage rule:** when a freshly written checker reports N
   findings, verify 2-3 by hand BEFORE fixing anything; if the sample is
   mostly false positives, fix the checker first. Encode near the T12
   entry in how-to-write-skills.md's lessons section if it recurs.
3. **benchstat harness recipe:** the correct invariants (same package, same
   benchmark name, count≥6, measure→fix→re-measure) are now implicit in the
   performance-tuning example; consider one sentence stating them as rules
   so the next session doesn't rediscover them via failed pairings (d3).
4. **ROADMAP/TODO cross-check after wave completion** — this pass updated
   TODO_LIST and CHANGELOG but not ROADMAP; a standing "wave complete"
   checklist item (TODO + CHANGELOG + ROADMAP + status-report annotations)
   would prevent drift. Candidate for how-to-write-skills.md process
   lessons.

---

## f) Up to 50 things we should get done next

| #  | Task                                                                                                          | Impact | Effort |
| -- | ------------------------------------------------------------------------------------------------------------- | ------ | ------ |
| 1  | T21: retro-audit live sites (gogenfilter, go-atomic-write, emeet-pixyd, ...) against the demo-video DoD      | Medium | M/site |
| 2  | T22: HyperFrames ground-truth render incl. one 9:16 resized-composition variant                              | High   | M      |
| 3  | T23: govalid generator end-to-end run (`go generate` on a scratch struct)                                     | Medium | S      |
| 4  | T24: website-launch eval-1 re-run with a fully fictional repo                                                 | Low    | S      |
| 5  | T25: next website-launch trim — extract Phase 2 structure list into readme-template (target <700, then <500)  | Low    | S      |
| 6  | T26: trigger-density lint mode for check-skills.sh                                                            | Low    | S      |
| 7  | scratch.sh --adopt mode for pre-existing scratch dirs (e1 follow-up, d1)                                       | Low    | S      |
| 8  | ROADMAP sync: route the 08-21 morning report's unanswered g1-g3 policy questions (autoplay, social-cut tier, API-library video) | Medium | S |
| 9  | benchstat harness invariants as explicit rules in performance-tuning.md (d3)                                   | Low    | S      |
| 10 | skills CLI: lockfile hash drift check — verify `skills update -g` bumps `skillFolderHash` for all 10 updated entries | Low | S |
| 11 | how-to-write-skills.md: add the "new-linter triage" rule if one more session hits it (e2)                      | Low    | S      |
| 12 | FEATURES.md: add rows for the two eval artifacts (go-release iteration-2, website-launch iteration-1)          | Low    | S      |

---

## g) Questions I CANNOT figure out myself

1. **The 500-line gate vs website-launch reality.** The repo rule says
   SKILL.md <500 lines; website-launch is now 799 and only reachable below
   700 with the next extraction, realistically ~600 after two more. Do you
   want a sustained multi-pass push to get under 500 (structural risk:
   phases collapsing into pure pointer lists), or should the allowlist
   entry be re-justified permanently at whatever the extraction ceiling
   turns out to be?

2. **Adopt T24's fictional-repo eval (and the old-vs-new harness generally)
   as the standard rewrite gate?** This wave proved the harness twice
   (go-release 79%→95%, website-launch 35%→100%). If yes, I would encode
   "run an old-vs-new eval before merging any substantive skill rewrite"
   into how-to-write-skills.md — which would make evals a blocking step
   for future skill work rather than follow-up debt.

3. **Priority call between T21 (retro-audit of live sites) and T22 (one
   real HyperFrames render).** Both convert doc-verified guidance into
   ground truth; T21 improves existing properties, T22 de-risks every
   future launch. Which first — or should T22 fold INTO the next real
   launch instead of a synthetic render?

---

_Point-in-time snapshot. When this report goes stale, use `docs-health`
ANNOTATE — never rewrite. Section (f) feeds HARVEST on instruction._
