# Status Report — 2026-08-04 04:16 — Full TODO_LIST Execution Self-Review

> **Format override note:** User explicitly requested `.md` format. Per
> status-report skill spec, the user's explicit instruction wins.

**Session scope:** Execute all 19 TODO items (T1-T19) in one pass, then
brutally self-review. This report covers what was done, what was fucked up,
and what remains.

---

## a) FULLY DONE

| #  | Item                                                              | Evidence                                                                                                                                                              |
| -- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
~~| 1  | T11: how-to-golang README↔FEATURES split brain fixed              | `README.md:55`, `FEATURES.md:54` aligned; subsequently upgraded to Comprehensive after T4                                                                             |~~ v:verified 2026-11-10 — README:64 and FEATURES both read 🟢 Comprehensive for how-to-golang
~~| 2  | T19: Stale `git restore` reference in case-study.md fixed         | `docs-health/references/case-study.md:134` — lesson now owned by case study, not body                                                                                 |~~ v:verified 2026-11-10 — case-study.md:143 owns the git-restore lesson
~~| 3  | T9: Appendix-only incident added to case-study.md                 | `docs-health/references/case-study.md` — Incident 2 section with setup, failure, root cause, fix, lesson                                                              |~~ v:verified 2026-11-10 — Incident 2 (appendix-only trap) lives in case-study.md:11
~~| 4  | T2: Disambiguation text added to 7 overlapping skill descriptions | code-quality-scan, full-code-review, deduplicate-code, architecture-review, status-report, verify-external-claims, verify-before-filing — all under 1024 char limit   |~~ v:verified 2026-11-10 — all 7 skill descriptions carry Distinct-from disambiguation clauses
~~| 5  | T5: TOC-integrity guard added to check-skills.sh                  | Negative-tested: deliberately introduced drift, guard caught it. Fixed 8 real TOC drifts in reference files.                                                          |~~ v:verified 2026-11-10 — TOC-integrity guard runs as check-skills.sh check 9 (line 621)
~~| 6  | T6: Marker-vocabulary guard added to check-skills.sh              | Checks `done at`, `Won't implement`, `NOT-DO` exist in docs-health/SKILL.md                                                                                           |~~ v:verified 2026-11-10 — marker-vocabulary guard runs as check 10
~~| 7  | T7: Scoring systems cross-referenced                              | `agents-quality-guide.md` and `health-report-format.md` now have callout boxes stating their relationship (per-file vs per-set)                                       |~~ v:verified 2026-11-10 — health-report-format.md:51-54 carries the rubric-relationship callout
~~| 8  | T17: 2026-05-03 comprehensive audit annotated                     | All 25 Top-Tasks resolved inline with markers. Header has resolution summary.                                                                                         |~~ v:verified 2026-11-10 — the 2026-05-03_07-51 audit sits in docs/status/archived/ with inline markers
~~| 9  | T10: Condensing checklist added as Pattern 10                     | `how-to-write-skills.md:414` — 4-step checklist: move examples → move anti-patterns → trim prose → verify                                                             |~~ v:verified 2026-11-10 — Pattern 10 (Condense Without Eroding Teaching Weight) at how-to-write-skills.md:491
~~| 10 | T18: Competing skills disambiguation added as Pattern 11          | `how-to-write-skills.md:450` — rules for "Distinct from" clauses                                                                                                      |~~ v:verified 2026-11-10 — Pattern 11 (Disambiguate Competing Skills) at how-to-write-skills.md:527
~~| 11 | T8: check-agents-md.sh created                                    | 5-tier anti-pattern catalog packaged as standalone scorer. Tested against repo AGENTS.md — works, finds 2 legitimate "was/now" instances.                             |~~ v:verified 2026-11-10 — scripts/check-agents-md.sh exists and runs
~~| 12 | T1: Trigger collision analysis completed                          | Python script analyzed all 24 descriptions: 0 quoted-phrase collisions, 0 undisambiguated high-overlap pairs                                                          |~~ v:verified 2026-11-10 — zero-collision result recorded; TODO_LIST T30 cites the wave-2 T27 trigger test passing both directions
~~| 13 | T16: website-launch refactored                                    | 1106→799 lines (28% cut). Extracted 3 reference files (go-live-runbook, website-creation-details, definition-of-done).                                                |~~ v:verified 2026-11-10 — website-launch now 835 lines with references extracted (go-live-runbook et al.)
~~| 14 | T12: architecture-review deepened                                 | Added assessment-rubric.md (7 dimensions, 1-5 scoring) + review-methodology.md (5-phase process with dependency analysis, domain alignment, recommendation framework) |~~ v:verified 2026-11-10 — assessment-rubric.md + review-methodology.md present in architecture-review/references/
~~| 15 | T13: code-quality-scan deepened                                   | Added tool-guidance.md (per-language tool matrix). Removed "RESEARCH" instruction. Removed deprecated justfile reference.                                             |~~ v:verified 2026-11-10 — tool-guidance.md present in code-quality-scan/references/ and referenced from SKILL.md
~~| 16 | All 24 skills pass check-skills.sh                                | Including new TOC + marker guards. 0 thin skills.                                                                                                                     |~~ v:verified 2026-11-10 — check-skills.sh green (now 35 skills)
~~| 17 | CHANGELOG updated with all session changes                        | `[Unreleased]` section expanded with Added + Changed entries                                                                                                          |~~ v:verified 2026-11-10 — CHANGELOG carries the milestone-wave entries
~~| 18 | TODO_LIST emptied (all items completed)                           | Per docs-health BUILD rule: completed items removed                                                                                                                   |~~ v:verified historically — TODO_LIST was emptied then rebuilt by later HARVEST waves; current rows are open work, not leftovers

---

## b) PARTIALLY DONE

| #     | Item                                                                                                                     | What's done                                                                                                              | What's missing                                                                                                                                                                                                                                                                                                                           |
| ----- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ~~1~~ | ~~**T4: how-to-golang code snippet fixes**~~ done — caveat closed 2026-08-21 — compile pass fixed imports + generateULID | ~~4 known issues fixed (gopter, json/v2, E2E HTTP, Rule 002). Snippets now reference real APIs.~~                        | ~~**Imports not shown in E2E snippet** — uses `json.Marshal`, `bytes.NewReader`, `http.Post`, `http.Get` but no `import` block. Also `generateULID` is still a fictional function. **Never compiled.** The fixes are structurally correct but unverified against a Go compiler.~~                                                        |
| ~~2~~ | ~~**T3: verify-before-filing audit**~~ done — caveat closed 2026-09-18 — wrong qualifier removed from the skill          | ~~Read full skill body. Body structure is solid — 5 verification gates, anti-patterns, examples. Added disambiguation.~~ | ~~**Did not verify the Go claims IN the examples.** The skill says "Go 1.22+ `http.MaxBytesReader`" — `MaxBytesReader` has existed since Go 1.0, not 1.22. The "1.22+" qualifier is wrong. I said "body is solid" without checking its own code claims. **This is the trophy-case-marking anti-pattern applied to my own audit work.**~~ |
~~| 4     | **T7: Scoring reconciliation**                                                                                           | Added cross-reference callout boxes documenting the relationship                                                         | **Did not actually unify the scoring.** Two systems still produce different numbers for the same file. I documented the problem as "complementary" — that's documenting a split brain, not fixing one. The rubric and the health report could still produce conflicting AGENTS.md scores.                                                |~~ v:resolved by scope rule — health-report-format.md:51-54 scopes the 5-dimension rubric to single-file review vs Accuracy+Fitness whole-set (option B)
~~| 5     | **T16: website-launch refactor**                                                                                         | 1106→799 lines, 3 references extracted                                                                                   | **Still 299 lines over the 500 limit.** The allowlist still warns. The remaining body is core decision logic, but the Phase 0 pre-flight checks (81-258) and Phase 2 README rewrite (362-450) could also be extracted.                                                                                                                   |~~ r:routed to ROADMAP 2026-11-10
~~| 6     | **T6: Marker-vocabulary guard**                                                                                          | Checks 3 markers exist somewhere in docs-health/SKILL.md                                                                 | **Does not verify structural relationship.** Just greps for literal strings. It cannot detect if HARVEST invents a rival format — only if the 3 specific markers vanish entirely.                                                                                                                                                        |~~ r:routed to ROADMAP 2026-11-10

---

## c) NOT STARTED

| #     | Item                                                                                                        | Why                                                                                                                                                                                            |
| ----- | ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
~~| 1     | **Empirical trigger testing**                                                                               | T1 was keyword-overlap analysis, not behavioral testing. No skill was tested against Crush's actual selection mechanism. The `skill-creator` eval framework exists and was never used.         |~~ v:done — behavioral trigger tests ran: wave-2 T27 passed both directions (TODO_LIST T30 note)
| ~~2~~ | ~~**Compile-testing the fixed Go snippets**~~ done — 2026-08-21 compile-check of all 31 reference Go blocks | ~~T4 fixed 4 code snippets by reasoning about APIs. None were run through `go build` or `go vet`.~~                                                                                            |
~~| 3     | **Testing check-agents-md.sh against a real bloated AGENTS.md**                                             | Only tested against this repo's lean AGENTS.md (28 KB). Never tested against a 100+ KB file to verify the severity logic.                                                                      |~~ r:routed to TODO_LIST 2026-11-10
| ~~4~~ | ~~**Running sync-html-kit.sh after adding references**~~ done — sync-html-kit green since 2026-08-21        | ~~T12-T15 added new reference files to skills with vendored html-report-kit. The references themselves don't need vendoring, but the sync script was never re-run to verify nothing drifted.~~ |

---

## d) TOTALLY FUCKED UP

| #     | Item                                                                                                                                          | Why It's Fucked                                                                                                                                                                                                                                                                                                                                                                                                              | Severity      |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| ~~1~~ | ~~**verify-before-filing `http.MaxBytesReader` claim not caught**~~ done — fixed 2026-09-18 — qualifier removed from verify-before-filing     | ~~The skill says "Go 1.22+ `http.MaxBytesReader`" — it has existed since **Go 1.0**. The "1.22+" qualifier is factually wrong. I audited this skill (T3), said "body is solid," and **didn't catch the error in the very thing I was supposed to verify.** This is the exact anti-pattern the skill itself warns about: "Formatting quality is not evidence of correctness." I was fooled by a well-structured skill body.~~ | ~~🟡 High~~   |
| ~~2~~ | ~~**T17 audit annotation: `c822b9d` is "relocate" not "delete"**~~ done — fixed 2026-09-18 — 05-03 citation corrected                         | ~~I annotated task #1 as `done at c822b9d` with note "moved to originals/." But the task said "Delete legacy `1.md`-`17.md`." Relocating to `originals/` is not deletion — the files still exist. The annotation should say `Won't implement — relocated to originals/ instead of deleted` or cite the actual deletion if it happened. Lazy citation.~~                                                                      | ~~🟡 High~~   |
~~| 3     | **T14 bdd-testing "deepening" was a 7-line table**                                                                                            | The audit said bdd-testing needs "ginkgo syntax reference, test structure template, file naming conventions." The ginkgo syntax reference already existed (216 lines). I added a 7-line naming conventions table and called it "deepened." That's the thinnest improvement of all T12-T16. The skill is still 50 lines.                                                                                                      | 🟠 Medium     |~~ r:routed to ROADMAP 2026-11-10
~~| 4     | **T12/T13 "deepening" created pointer-only bodies**                                                                                           | architecture-review (54 lines) and code-quality-scan (41 lines) now have Process sections that are 6 "see references/X.md" pointers. The agent must load 2 reference files before it can start. The original bodies at least had inline guidance, even if thin. I replaced inline content with pointers and called it "deeper."                                                                                              | 🟠 Medium     |~~ v:resolved — architecture-review (71 lines) names the 7 rubric dimensions inline (SKILL.md:63); code-quality-scan (46 lines) carries inline build/lint/dup guidance
| ~~5~~ | ~~**E2E snippet uses fictional `generateULID` function**~~ done — fixed 2026-08-21 — generateULID replaced in the compile pass                | ~~T4 fixed the gopter API call, but the test function still calls `generateULID(time.Unix(...))` — a function that doesn't exist. I fixed the API surface but left the domain function fictional. A reader copy-pasting this code gets a compilation error.~~                                                                                                                                                                | ~~🟡 High~~   |
| ~~6~~ | ~~**T10/T18 added patterns to how-to-write-skills.md — not a skill**~~ done — routed to ROADMAP Open Questions — how-to-write-skills location | ~~The condensing checklist and competing-skills section were added to `how-to-write-skills.md`, which is a raw file at the repo root, NOT a skill. No agent loads it via skill triggering. The patterns are valuable but only reachable by an agent that explicitly reads the file.~~                                                                                                                                        | ~~🟠 Medium~~ |

---

## e) WHAT WE SHOULD IMPROVE

### Process improvements

~~1. **Verify code claims in skills you are auditing, not just structure.** T3 was supposed to audit verify-before-filing's claims. I said "body is solid" without checking the Go API claims in the examples. The skill's own Rule 5 applies: "Verify Code Examples Against Source." I violated the skill's own rule while auditing it.~~ v:done — the MaxBytesReader Go-1.22 qualifier was removed from verify-before-filing (2026-09-18, see d1/f1)

~~2. **"Deepening" a skill means improving its OUTPUT, not adding reference files.** A skill that produces richer agent behavior is deepened. A skill whose body is replaced with pointers to references is not deeper — it's more indirect. The test is: "Would an agent following this skill produce better results?" not "Does the skill have more files?"~~ v:adopted — architecture-review and code-quality-scan bodies now carry inline decision minimums

~~3. **Compile-test code snippet fixes.** T4 fixed 4 Go code snippets by reasoning. None were compiled. The fixes are structurally correct (real API names, correct types) but unverified. A single `go build` on a test file would catch import errors and fictional functions.~~ v:done — all 31 reference Go blocks compile-checked in the 2026-08-21 pass (c2/f2)

~~4. **Test guard scripts against adversarial input.** T5's TOC guard was negative-tested (good). T8's check-agents-md.sh was only tested against this repo's clean AGENTS.md — never against a 100 KB bloated file. The guard could have bugs that only surface on real-world input.~~ r:routed to TODO_LIST 2026-11-10

### Skill design improvements

~~5. **The "pointer body" anti-pattern.** architecture-review and code-quality-scan now have bodies that are mostly "see references/X.md" pointers. An agent loading the skill must immediately load 1-2 reference files before it can act. The better pattern is how-to-golang: a 94-line body with enough decision logic to START working, plus references for DEEP dives. architecture-review's body should have at least the rubric dimensions inline (names + 1-line descriptions), with the detailed scoring in the reference.~~ v:resolved — the lean-entrypoint + inline-minimum pattern now holds (architecture-review:63, code-quality-scan process steps)

~~6. **bdd-testing needs more than a naming table.** The skill is 50 lines. The ginkgo-syntax reference exists but the body doesn't guide an agent through WHEN to use DescribeTable vs individual It blocks, or how to structure a spec suite from scratch. A "spec design" section in the body would add real value.~~ r:routed to ROADMAP 2026-11-10

~~7. **website-launch Phase 0 and Phase 2 are still in the body.** Phase 0 (pre-flight checks, 81-258 = ~180 lines) and Phase 2 (README rewrite, 362-450 = ~90 lines) could be extracted to references to get under 500 lines. The refactor stopped at Phase 3 and 5 because they were the biggest, but Phase 0 is nearly as large.~~ r:routed to ROADMAP 2026-11-10

### Repo improvements

~~8. **how-to-write-skills.md is still not a skill.** It has 11 patterns now (up from 9) and is the authoritative guide for skill authoring. But it lives at the repo root, not in a skill directory. Agents won't load it via triggering. This was flagged in the 2026-05-03 audit (item C#3) and is still unresolved.~~ r:routed to ROADMAP 2026-11-10

~~9. **The scoring reconciliation (T7) documented the problem instead of fixing it.** The two scoring systems still produce different numbers. A real fix would either: (a) make the 5-dimension rubric feed into Accuracy+Fitness, or (b) pick one and delete the other. Adding cross-reference callout boxes is better than nothing, but the split brain persists.~~ v:resolved by scope rule — health-report-format.md:51-54 (option B)

---

## f) Top 25 things we should get done next

### P0 — fix things I broke or left incomplete

| #     | Task                                                                                                                                                                                    | Impact   | Effort | Evidence                                                                                              |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------ | ----------------------------------------------------------------------------------------------------- |
| ~~1~~ | ~~**Fix `MaxBytesReader` Go version claim in verify-before-filing**~~ done (docs-health pass 2026-09-18 — wrong Go-1.22 qualifier removed from verify-before-filing — stdlib since 1.0) | ~~High~~ | ~~S~~  | ~~`verify-before-filing/SKILL.md:201` — "Go 1.22+" should be "Go 1.0" or just "stdlib"~~              |
| ~~2~~ | ~~**Add import block to E2E snippet in how-to-golang**~~ done — 2026-08-21 compile pass: 31 Go blocks built in a scratch module — imports fixed                                         | ~~Med~~  | ~~S~~  | ~~`how-to-golang/references/testing-strategy.md:117` — uses `json`, `bytes`, `http` without imports~~ |
| ~~3~~ | ~~**Fix `generateULID` fictional function**~~ done — 2026-08-21 compile pass — generateULID replaced                                                                                    | ~~Med~~  | ~~S~~  | ~~`how-to-golang/references/testing-strategy.md:168` — either define it or use a real alternative~~   |
| ~~4~~ | ~~**Fix T17 audit annotation: `c822b9d` is relocate, not delete**~~ done (docs-health pass 2026-09-18 — the 05-03 row-1 citation corrected to Won-t implement — relocated not deleted)  | ~~Low~~  | ~~S~~  | ~~`docs/status/2026-05-03_*:122` — annotation should say relocated, not done~~                        |
~~| 5     | **Extract Phase 0 and Phase 2 from website-launch body**                                                                                                                                | Med      | M      | Would get body under 500 lines. Phase 0 = ~180 lines, Phase 2 = ~90 lines                             |~~ r:routed to ROADMAP 2026-11-10

### P1 — strengthen the guards

| # | Task                                                                     | Impact | Effort | Evidence                                                                                                                                         |
| - | ------------------------------------------------------------------------ | ------ | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
~~| 6 | **Strengthen marker-vocabulary guard to check structural relationship**  | Med    | M      | Current guard greps for literal strings anywhere. Should verify HARVEST section references the markers, not just that markers exist in the file. |~~ r:routed to ROADMAP 2026-11-10
~~| 7 | **Test check-agents-md.sh against a real 100+ KB AGENTS.md**             | Med    | S      | Only tested against 28 KB repo AGENTS.md. Severity logic untested on real bloat.                                                                 |~~ r:routed to TODO_LIST 2026-11-10
~~| 8 | **Add "code snippet compile-test" convention to how-to-write-skills.md** | Med    | S      | Pattern 5 says "verify against source" but doesn't say "run `go build`". The convention should require compilation for compilable languages.     |~~ v:done — compile discipline encoded in Pattern 5 (how-to-write-skills.md ~379): examples must compile and be verified against source

### P2 — actually deepen the thin skills (not just add pointers)

| #  | Task                                                             | Impact | Effort | Evidence                                                                                             |
| -- | ---------------------------------------------------------------- | ------ | ------ | ---------------------------------------------------------------------------------------------------- |
~~| 9  | **Inline rubric dimensions into architecture-review body**       | Med    | S      | Body is 6 "see references" pointers. Should have dimension names + 1-line descriptions inline.       |~~ v:done — architecture-review SKILL.md:63 lists the 7 dimension names inline; 1-5 rubric in assessment-rubric.md
~~| 10 | **Inline tool matrix summary into code-quality-scan body**       | Med    | S      | Same issue — body should summarize Go/TS/Rust/Python tools inline, reference for detail.             |~~ v:adopted the lean-body pattern — code-quality-scan carries inline nix/Go build+lint+dup commands; full matrix in tool-guidance.md
~~| 11 | **Add spec design guidance to bdd-testing body**                 | Med    | M      | When to use DescribeTable vs It blocks, how to structure a suite from scratch. 50 lines is too thin. |~~ r:routed to ROADMAP 2026-11-10
~~| 12 | **Add status-report section quality inline, not just reference** | Low    | S      | The body lists sections (a-g) but doesn't say what makes each good. 1 line per section.              |~~ v:done — status-report/references/section-quality-guide.md exists, linked from SKILL.md:33

### P3 — structural improvements

| #      | Task                                                                                                                                  | Impact  | Effort | Evidence                                                                                                                 |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------------------------------------------------------------------------------------------------------------------------ |
~~| 13     | **Unify docs-health scoring: pick one system, delete the other**                                                                      | Med     | M      | Two scoring systems produce different numbers for the same file. Cross-references document the problem but don't fix it. |~~ v:resolved by scope rule — health-report-format.md:51-54 scopes rubric (single-file) vs Accuracy+Fitness (whole-set); option B chosen
~~| 14     | **Convert how-to-write-skills.md into a proper skill directory**                                                                      | Med     | M      | 11 patterns, 533 lines. Not triggerable. Agents must explicitly read it.                                                 |~~ r:routed to ROADMAP 2026-11-10
| ~~15~~ | ~~**Run sync-html-kit.sh after all reference additions**~~ done — sync-html-kit.sh --check green — verified 2026-08-21 and 2026-09-18 | ~~Low~~ | ~~S~~  | ~~T12-T15 added references to skills with vendored kits. Never re-synced.~~                                              |
| ~~16~~ | ~~**Add README quality count auto-computation**~~ done — README counts are script-derived notes — live count via check-skills         | ~~Low~~ | ~~S~~  | ~~"19 of 24" is hardcoded. check-skills.sh already computes the real count. README should reference it, not hardcode.~~  |

### P4 — empirical validation (from ROADMAP)

| #      | Task                                                                                                                      | Impact  | Effort | Evidence                                                                                                    |
| ------ | ------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ----------------------------------------------------------------------------------------------------------- |
~~| 17     | **Run skill-creator eval on 3 thinnest descriptions**                                                                     | High    | L      | ROADMAP theme 1: no skill empirically tested. bdd-testing, architecture-review, status-report are thinnest. |~~ r:routed to ROADMAP 2026-11-10
~~| 18     | **Behavioral trigger test: craft 5 prompts, see which skills fire**                                                       | High    | M      | T1 was keyword analysis. Real test needs actual prompts against Crush's selection mechanism.                |~~ v:done — wave-2 T27 behavioral trigger test passed both directions (TODO_LIST T30 note)
| ~~19~~ | ~~**Verify gopter `gen.Int()` API against actual library source**~~ done — gopter verified in the 2026-08-21 compile pass | ~~Med~~ | ~~S~~  | ~~T4 fix assumed `gen.Int()` is correct. Never verified against `github.com/leanovate/gopter/gen`.~~        |

### P5 — smaller improvements

| #      | Task                                                                                                                                                                      | Impact  | Effort | Evidence                                                                                                  |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | --------------------------------------------------------------------------------------------------------- |
~~| 20     | **Remove how-to-golang from README "functional" list in quality section**                                                                                                 | Low     | S      | It was added then removed — verify the README quality paragraph matches reality                           |~~ v:verified 2026-11-10 — README how-to-golang row reads 🟢 Comprehensive, matching FEATURES after T11
| ~~21~~ | ~~**Add `encoding/json/v2` experimental caveat to README how-to-golang row**~~ **Won't implement — duplicate — the experimental-status caveat lives in AGENTS §10 Note.** | ~~Low~~ | ~~S~~  | ~~README says "Comprehensive" but doesn't mention the experimental JSON status~~                          |
~~| 22     | **Consider whether bdd-testing needs a `references/spec-design.md`**                                                                                                      | Low     | M      | Naming conventions + ginkgo syntax exist, but spec design (how to decompose behaviors into specs) doesn't |~~ r:routed to ROADMAP 2026-11-10
~~| 23     | **Audit all skills for the "pointer body" anti-pattern**                                                                                                                  | Med     | M      | architecture-review and code-quality-scan have it. Check if data-model-review, library-deep-dive do too.  |~~ v:done — architecture-review/code-quality-scan now carry inline minimums; data-model-review (157 lines) and library-deep-dive (199 lines) are not pointer bodies
~~| 24     | **Add `--fix` mode to check-agents-md.sh**                                                                                                                                | Low     | M      | Currently advisory-only. A `--fix` mode that strips temporal pollution would make it actionable.          |~~ r:routed to TODO_LIST 2026-11-10
~~| 25     | **Verify all internal markdown links in new reference files resolve**                                                                                                     | Low     | S      | 11 new .md files created. Never ran the backlink integrity check against them.                            |~~ v:done — scripts/check-skill-links.sh runs as check 12 (anchor-aware link checker)

---

## g) Questions I can NOT figure out myself

~~### Question 1: Should the scoring systems be unified or kept complementary?~~ v:answered — option B: scopes enforced, health-report-format.md:51-54

The 5-dimension rubric (agents-quality-guide.md) scores a single AGENTS.md file.
The 2-score system (health-report-format.md) scores the whole doc set. They
produce different numbers for AGENTS.md. Two options:

- **(A) Merge:** Make the 5-dimension rubric a sub-component of Accuracy+Fitness.
  The rubric feeds into the AGENTS.md row of the health report.
- **(B) Keep separate but enforce scope:** Add a rule that the 5-dimension rubric
  is ONLY used when AGENTS.md is the sole doc under review, and Accuracy+Fitness
  is used for whole-set audits. Never apply both to the same audit.

I documented the relationship (T7) but can't decide whether the split is a
feature (different scopes) or a bug (confusing overlap). This determines whether
T7 is done or needs a follow-up.

~~### Question 2: Is the "pointer body" pattern acceptable, or should every skill have inline decision logic?~~ v:answered in practice — bodies carry inline minimums; references hold the deep dives (architecture-review:63)

architecture-review (54 lines) and code-quality-scan (41 lines) now have Process
sections that are mostly "see references/X.md" pointers. Two philosophies:

- **(A) Pointers are fine:** Progressive disclosure means the body points and
  references detail. The agent loads what it needs. This is the how-to-golang
  pattern.
- **(B) Bodies need inline minimum:** An agent should be able to START working
  from the body alone, loading references only for deep dives. A body that is
  100% pointers is a table of contents, not a skill.

I lean (B), but I'm not sure if (A) is defensible for simple skills where the
"decision logic" is genuinely just "load the tool matrix and run the tools."

~~### Question 3: Should `how-to-write-skills.md` become a skill, or stay as documentation?~~ r:routed to ROADMAP 2026-11-10

It has 11 patterns and 533 lines. It's the authoritative guide for authoring
skills. But it's not a skill — it's a raw file at the repo root. No agent loads
it via triggering.

- **(A) Make it a skill** (`skill-creator/` or `how-to-write-skills/` directory
  with proper frontmatter). It would trigger on "write a skill", "create a
  skill", "skill authoring", etc. The `skill-creator` builtin already exists for
  Crush — would this duplicate it?
- **(B) Leave it as documentation.** It's reference material for humans editing
  this repo, not for agents working in other projects. Making it a skill would
  cause trigger collision with the builtin `skill-creator`.

I can't resolve this because I don't know the relationship between
`skill-creator` (the builtin) and this file's content.
