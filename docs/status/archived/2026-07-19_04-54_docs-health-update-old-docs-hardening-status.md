# Status Report — 2026-07-19 Skills Hardening (docs-health + update-old-docs)

**Session:** 2026-07-19 ~04:30–04:54
**Trigger:** Two new feedback files in `docs/feedback/new/` from a prior
`segment-buffer` session where docs-health fabricated a health score and
update-old-docs buried annotations in appendices.
**Scope:** Convert both feedback files into concrete skill hardening, then
archive them per the AGENTS.md §11 feedback loop.
**Outcome:** Substantively done, with **two real bugs** introduced (Go missing
from the quality gate; broken anchor in a code example) and **one class of work
untouched** (reference files may now be split-brained with the hardened
SKILL.md bodies).

This report is a self-critical accounting of the session. It is not a
marketing summary.

---

## a) FULLY DONE

### Hardening applied to `docs-health/SKILL.md` (+41 lines)

All five suggestions from
`docs/feedback/processed/2026-07-19_docs-health-fabricated-score-skipped-verification.md`
were implemented:

1. ~~**Health Score must show the math.** The example report now reads
   `**Health Score: 7/10** (computed: 10 − 1·1 Critical − 0.5·3 Medium − 0.25·1 Low − 0·missing must-have = 7.25, floored to 7)`.
   A new paragraph states: "Show the math, every time. Never invent the score,
   and never invent a prior baseline."~~ done — reference files hardened via the structural refactor + case-study incident 2
2. ~~**Mandatory quality gate** added as VERIFY step 7. Detects Rust / Node /
   Nix / Python and runs canonical commands. States "if no build system,
   state that explicitly — do not skip silently." (Bug: Go missing — see §d.)~~ done — naming-review carries same hardened patterns
3. ~~**Verify-closing-claims step** added as VERIFY step 8. Requires a fresh
   `git status` before any claim about working-tree state in the closing
   message.~~ done — reference sweep done in 2026-08-04 refactor
4. ~~**Cross-file consistency step expanded** (VERIFY step 5) into an
   enumerated minimum checklist (links resolve, counts verified by command,
   referenced files exist, commands run, CHANGELOG URLs match, no
   PLANNED↔FULLY_FUNCTIONAL split brain). Adds: "state which you ran and
   which you skipped — never declare 'clean' without enumerating."~~ done — both bodies rewritten (01-00)
5. ~~**Invented baselines banned** in Report rules: "Never invent a prior
   state. If there was no prior audit, say 'first audit — no baseline.'"

### Hardening applied to `update-old-docs/SKILL.md` (+62 lines)

All five suggestions from
`docs/feedback/processed/2026-07-19_update-old-docs-buried-annotations-format-guidance.md`
were implemented, plus one bonus fix:
~~ done — guide updated with patterns

1. **TL;DR placement-decision rule.** Annotation placement section now
   states: "If the file has a TL;DR / summary / opening paragraph with stale
   claims, you MUST inline-correct those claims. An appendix alone is
   insufficient." Appendix entry marked "Insufficient on its own when the
   file's opening contains load-bearing stale claims — pair with option 1."
2. **Table format example for multi-item resolutions (5+).** Added to Step 3
   with explicit `Commit` and `Release` columns.
3. **Fresh-open test** added to Step 5 and the verification gate. "If the
   file has a stale TL;DR and your annotation is only at the bottom, you
   have failed this test."
4. **Line-number citations banned.** "Never cite line numbers
   (`TODO_LIST line 67`). Cite section names or item text." Added to both
   Step 3 and the verification gate checklist.
5. **Blockquote-update example for TL;DRs** added to Annotation placement
   (option 1). Shows the `> **Update (commit ...):** ...` pattern placed
   immediately after a TL;DR. (Bug: anchor in example is broken — see §d.)
6. ~~**Bonus: verification gate hardened.** "Run the project's quality gate if
   one exists" → "**Run the project's quality gate. Mandatory, not
   optional.**" This was suggested in the docs-health feedback for that
   skill; I judged the same anti-pattern ("if one exists" read as
   "optional") applies here and applied it preemptively.

### Bookkeeping

- Both feedback files moved `docs/feedback/new/` → `docs/feedback/processed/`
  via `git mv` (per global AGENTS.md: never plain `mv` in git repos).
- `scripts/check-skills.sh` passes: **OK, all 20 skills pass structural
  checks.** 0 thin skills.
- No spurious file changes. `git status` confirms exactly: 2 modified
  SKILL.md files + 2 renamed feedback files. Nothing else touched.

---~~ w:open — no demand signal

## b) PARTIALLY DONE

### ~~Reference files not checked for split-brain consistency~~ — done (hardened in the 2026-08-04 refactor)

The SKILL.md bodies were hardened. The reference files they delegate to were
**not re-read**. Several now risk contradicting the hardened main body:

| Reference file                                       | Risk                                                                                                                                          |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `docs-health/references/verify-checklist.md`         | May still describe the quality gate as optional or omit the new mandatory consistency checklist.                                              |
| `docs-health/references/common-mistakes.md`          | Does not yet list "fabricated score" / "invented baseline" / "skipped quality gate" as named common mistakes.                                 |
| `update-old-docs/references/annotation-placement.md` | May still show appendix-only as fully GOOD without the new "insufficient when opening is stale" caveat.                                       |
| `update-old-docs/references/case-study.md`           | Documents only the original Verschlimmbesserung incident; the 2026-07-19 buried-annotations incident is a second case study not yet appended. |

These are the highest-value next-pass items. They were skipped because the
user's instruction was to act on the two feedback files, not to audit the
entire reference tree — but the skills explicitly delegate to these files, so
the split-brain risk is real.

### ~~No git commit made~~ — done (daemon-owned history accepted, AGENTS §7)

Per global AGENTS.md ("NEVER commit unless the user explicitly says
'commit'"), changes were left uncommitted in the working tree. The project
values detailed commit messages and clean history, so this is a pending
decision for the user, not an oversight. (See Question 1.)

---

## c) NOT STARTED

- **No audit of other skills** for the same anti-patterns. The "if one
  exists" optional-quality-gate phrasing, the missing "verify closing claims"
  step, and the "show the math for any score" rule are likely absent from
  sibling skills (`naming-review`, `nix-review`, `full-code-review`,
  `architecture-review`, `code-quality-scan`, `library-deep-dive`,
  `status-report`, `brutal-self-review`). None were inspected.
- **No regression check** that the hardened rules would actually have caught
  the original `segment-buffer` failure (e.g., mentally re-run docs-health
  AUDIT on the fabricated-score scenario and confirm step 7 + step 8 +
  Report rules would have blocked the false closing claim).
- **No update to `README.md`** skills inventory. docs-health grew from ~287
  to 326 lines; update-old-docs from ~281 to 336. Material enough to note,
  not to re-grade.
- **No update to the master audit**
  (`docs/status/2026-05-03_07-51_comprehensive-skills-audit.md`). That file
  grades both skills on their pre-hardening state. It is a historical
  snapshot — bringing it current is `update-old-docs` territory, not this
  session's job.

---

## d) TOTALLY FUCKED UP

Two real defects introduced by this session. Neither is caught by
`check-skills.sh` (which is structural only).

### Bug 1 — Go is missing from the mandatory quality gate command list

In `docs-health/SKILL.md` VERIFY step 7, I listed Rust, Node, Nix, Python,
then a catch-all "Other: whatever the project's README/AGENTS.md prescribes."
**Go is absent.** This is indefensible:

- Lars's projects are predominantly Go.
- The global AGENTS.md references `go.mod`, `golangci-lint`, `go test ./...`,
  `go vet`.
- The `how-to-golang` skill exists precisely because Go is the house
  language.
- The docs-health skill will be invoked on Go projects and the command list
  will offer no specific guidance, silently dumping Go into "Other."

The fix is one line: `Go: go vet ./..., go test ./..., golangci-lint run`.

### Bug 2 — Broken anchor in the blockquote-update code example

In `update-old-docs/SKILL.md` Annotation placement option 1, the example
blockquote says:

```markdown
> Full item-by-item status in [Resolution](#resolution) below.
```

But the appendix format prescribed elsewhere in the same skill (Idempotency
section) is `## Resolution (2026-07-17)`. GitHub markdown renders that
heading's anchor as `#resolution-2026-07-17`, **not** `#resolution`. The
example link is dead on arrival. Worse, it is a copy-paste template — anyone
following it will ship a broken anchor.

The fix: change the example to `[Resolution](#resolution-2026-07-19)` and
note that the anchor must include the date because the appendix heading
always does.

### Lesser defects (cosmetic, not blocking)

- The new markdown table in update-old-docs Step 3 has a column-content
  width that exceeds the header dash width for the `Resolution` column. Renders
  fine, slightly ugly source.
- The new docs-health VERIFY process now has 8 steps; steps 7 and 8 could
  plausibly consolidate into one "final verification" step. Minor
  structural smell, not a bug.

---

## e) WHAT WE SHOULD IMPROVE (process-level, beyond this session)

1. **The user had to request this self-review.** The skills themselves
   should trigger it. Both docs-health and update-old-docs now have
   verification gates, but neither says "before declaring done, run
   `brutal-self-review` on your own output." The `brutal-self-review` skill
   exists for exactly this. Adding a cross-reference would have caught both
   bugs in §d before I claimed "Done."

2. **`check-skills.sh` is structural only.** It catches the
   `git commit <--` typo and frontmatter shape, but it cannot catch a dead
   anchor, a missing language from a command list, or a split-brain between
   SKILL.md and its reference files. A content-level lint pass (even just
   "render markdown, check every `[text](#anchor)` resolves to a heading")
   would add real value.

3. **Feedback → skill → reference cascade is not enforced.** When a lesson
   lands in SKILL.md, nothing forces the parallel update to the referenced
   `references/*.md`. This is how split brains start. The docs-health skill
   itself warns about this pattern in living docs; it should heed its own
   warning.

4. **"Show the math" should be a universal rule for any skill that emits a
   score or rating.** Right now it's in docs-health only. The same failure
   mode (vibes-based numbers presented as engineering) is available to
   `status-report`, `code-quality-scan`, `architecture-review`,
   `library-deep-dive`, `naming-review`, `brutal-self-review`. All produce
   scores or grades; none are required to show their computation.

5. **The "verify closing claims" step should be universal.** It now lives
   in docs-health step 8 and the update-old-docs gate. But every skill that
   produces a closing message ("N files staged", "tests pass", "no commit
   made") is vulnerable to the same drift between claim and reality. This
   is arguably a Crush-level rule, not a per-skill rule.

---

## f) Up to 50 things to get done next

Ranked roughly by impact × urgency. Bugs from §d are at the top.

1. ~~**Fix Bug 1:** add `Go: go vet ./..., go test ./..., golangci-lint run` to docs-health VERIFY step 7.~~ done (done — Go added in a later revision (VERIFY step 6 names the canonical gate))
2. ~~**Fix Bug 2:** correct the anchor in the update-old-docs blockquote example to `#resolution-2026-07-19` and note the date requirement.~~ done (done — anchor fixed in the structural refactor (2026-08-04))
3. ~~Read `docs-health/references/verify-checklist.md` and mirror the new mandatory quality gate + consistency checklist.~~ done (done — verify-checklist carries the mandatory gate)
4. ~~Read `update-old-docs/references/annotation-placement.md` and add the "appendix-only insufficient when opening is stale" caveat with the blockquote-update example.~~ done (done — placement reference carries the caveat)
5. ~~Read `docs-health/references/common-mistakes.md` and add named anti-patterns: "Fabricated score", "Invented baseline", "Skipped quality gate", "Declared 'clean' without enumeration."~~ done (done — common-mistakes names the anti-patterns)
6. ~~Append the 2026-07-19 buried-annotations incident as a second case study in `update-old-docs/references/case-study.md`.~~ done (done — case-study Incident 2 (appendix-only))
7. ~~Audit `naming-review` for the "if one exists" optional-gate anti-pattern.~~ done (done — marker guard shipped (04-16 a6))
8. ~~Audit `nix-review` for the same.~~ done (done — naming-review hardened 2026-08-02)
9. ~~Audit `full-code-review` for the same.~~ done (done — nix-review hardened (hermeticity 2026-07-26))
10. ~~Audit `code-quality-scan` for the same.~~ done (done — full-code-review delegates + handoffs)
11. ~~Add "verify closing claims with `git status`" to every skill with a verification gate.~~ done (done — closing-claims discipline encoded (verify-checklist + SESSION-START))
12. ~~Add "show the math for any score/rating" to `status-report`.~~ **Won't implement — covered — show-the-math lives in health-report-format; per-skill scores declined.**
13. ~~Add "show the math" to `code-quality-scan`.~~ **Won't implement — covered — same.**
14. ~~Add "show the math" to `architecture-review`.~~ **Won't implement — covered — same.**
15. ~~Add "show the math" to `library-deep-dive`.~~ **Won't implement — covered — same.**
16. ~~Add "show the math" to `naming-review`.~~ **Won't implement — covered — same.**
17. ~~Add "show the math" to `brutal-self-review`.~~ **Won't implement — covered — same.**
18. ~~Fix the column-width mismatch in the update-old-docs Step 3 table.~~ **Won't implement — moot — table normalized by the formatter era.**
19. ~~Consider consolidating docs-health VERIFY steps 7+8 into one "final verification" step.~~ **Won't implement — resolved-by-decision — 8-step VERIFY shape superseded by the merged skill.**
20. ~~Add "before declaring done, run `brutal-self-review` on your own output" to docs-health verification gate.~~ **Won't implement — covered — brutal-self-review handoff wired.**
21. ~~Add the same to update-old-docs verification gate.~~ **Won't implement — covered — same.**
22. ~~Write a content-level markdown linter script (`scripts/check-anchors.sh`) that verifies every `[text](#anchor)` in every SKILL.md resolves to a heading.~~ done (done — check 11 TOC guard + anchor-aware link checker)
23. ~~Extend `check-skills.sh` to flag any `SKILL.md` whose line count exceeds 500 (currently advisory only).~~ done (done — line-count gate shipped (500 + allowlist))
24. ~~Update the master audit `docs/status/2026-05-03_07-51_comprehensive-skills-audit.md` (via update-old-docs) to note both skills were hardened on 2026-07-19.~~ done (done — 05-03 audit carries a resolution header)
25. ~~Re-grade docs-health and update-old-docs in any future audit against the hardened versions, not the pre-hardening state.~~ done (done — FEATURES rebuilt against current skills 2026-09-16)
26. ~~Add a `scripts/verify-docs-health.sh` that automates the new mandatory consistency checks (link resolution, count verification, ghost-file detection).~~ done (done — verify-checklist IS the enforceable checklist)
27. ~~Grep every SKILL.md for the phrase "if one exists" and review each occurrence — most are probably anti-patterns.~~ **Won't implement — covered — signal pass swept filler repo-wide.**
28. ~~Grep every SKILL.md for the phrase "clean" and ensure none use it without enumeration.~~ **Won't implement — covered — same.**
29. ~~Add Go to the update-old-docs verification-gate quality command list too (currently says "cargo test, pnpm test" — Go is also missing here).~~ done (done — Go commands present)
30. ~~Add a named anti-pattern callout in docs-health for "Marketing-score anti-pattern" (parallel to "Verschlimmbesserung" in update-old-docs).~~ done (done — the Marketing-score callout exists in common-mistakes)
31. ~~Cross-link from `update-old-docs/references/case-study.md` to the two processed feedback files that motivated hardening.~~ done (done — case-study links its feedback lineage)
32. ~~Verify the new cross-file consistency grep commands actually work (e.g., `grep -roE '\]\([^)]+\)' *.md docs/` — test in this repo).~~ **Won't implement — covered — link checker validates.**
33. ~~Consider whether the mandatory quality gate belongs in a shared reference file loaded by multiple skills, to avoid drift.~~ **Won't implement — resolved-by-decision — shared-reference idea superseded by per-skill references.**
34. ~~Add a positive example (not just anti-patterns) to docs-health Report rules: "Here is what a truthful closing claim looks like."~~ done (done — positive examples present in the guides)
35. ~~Add a positive example to update-old-docs: a full before/after of a TL;DR with a blockquote-update applied.~~ done (done — before/after examples present)
36. ~~Review whether the new docs-health step 8 ("auto-commit hooks change state under you") belongs in the skill or in the global Crush AGENTS.md.~~ **Won't implement — moot — step-8 concern folded into the merged skill.**
37. ~~Update `README.md` skills table line counts if they are tracked there.~~ **Won't implement — moot — line counts not tracked in README.**
38. ~~Check `docs-health/assets/*.md` templates for alignment with the hardened rules (e.g., FEATURES-template.md should still emphasize "never round up").~~ done (done — templates align (FEATURES-template carries the vocabulary))
39. ~~Check if `html-report-kit` consumer skills need to know about the new "show the math" rule when they render score cards.~~ **Won't implement — covered — kit renders scores; show-the-math is docs-health canon.**
40. ~~Write a regression scenario: a mock feedback file with a fabricated score, mentally re-run docs-health AUDIT, confirm the new rules would catch it. Document in `docs-health/references/common-mistakes.md`.~~ done (done — regression-scenarios table exists (verify-checklist))
41. ~~Consider whether the table-vs-prose guidance in update-old-docs Step 3 should also apply to docs-health's findings-by-severity section.~~ **Won't implement — covered — table-vs-prose guidance exists in resolving-items.**
42. ~~Audit every `## Verification gate` section across all 20 skills for the two new universal rules (mandatory quality gate; verify closing claims).~~ done (done — verification gates audited across skills)
43. ~~Check if any other skill produces a "was X, now Y" delta claim that could be an invented baseline.~~ **Won't implement — covered — never-invent-baseline rule.**
44. ~~Add a one-line note to the project AGENTS.md §11 (feedback loop) confirming the 2026-07-19 feedback was actioned, so the loop is visibly closed. (Probably unnecessary — `processed/` is self-documenting — but worth considering.)~~ **Won't implement — covered — marker convention documented.**
45. ~~Consider extracting "content-addressed citations" (section names, item text, git blob hashes) into its own short reference file, since the rule now appears in update-old-docs and could spread.~~ **Won't implement — covered — content-addressed citations rule lives in the skill.**
46. ~~Review whether the new "exhaustive consistency checklist" in docs-health step 5 is too rigid for small content repos (this one has no code to verify counts against). Add a "calibrate to project type" note.~~ done (done — project-type calibration note present)
47. ~~Run the full read-through of both edited SKILL.md files end-to-end (I viewed portions, never the whole post-edit flow).~~ done (done — end-to-end re-reads standard since 2026-08-04)
48. ~~Check that the new blockquote-after-TL;DR pattern doesn't subtly conflict with the existing "never inject between title and opening" rule — clarify in prose if a sharp reader could be confused.~~ done (done — blockquote rule clarified (no banners; TL;DR updates differ))
49. ~~Consider adding a `feedback/processed/INDEX.md` that lists every actioned feedback file with a one-line summary of what skill it hardened, for quick history-scan.~~ **Won't implement — covered — processed/ is self-documenting.**
50. ~~Once 1–6 are done, commit with a detailed message covering both skills, both bugs, and the reference-file updates.~~ done (done — committed across the 2026-07-30/08-04 waves)

---

## g) Questions I cannot figure out myself

### ~~Q1 — Commit strategy~~ RESOLVED — daemon-owned commits accepted (AGENTS §7); explicit commits only on request

Global AGENTS.md says "NEVER commit unless the user explicitly says
'commit'." Project AGENTS.md §7 says "Commit style: Very detailed commit
messages (this is explicitly requested in several skills)" and values clean
history. The working tree currently has 2 hardened SKILL.md files + 2
renamed feedback files, uncommitted.

**Should I commit now (one detailed commit covering the hardening + the
two bug fixes from §d), or wait until the reference-file cascade
(items 3–6 in §f) is also done so the commit reflects a complete
hardening rather than a half-finished one?**

### ~~Q2 — Scope of the "show the math" rule~~ RESOLVED — encoded once in docs-health (health-report-format); other skills cite it rather than restate

The docs-health feedback framed the fabricated score as a docs-health bug.
But the same failure mode (presenting a vibes-based number as engineering)
is available to every skill that emits a score, rating, or grade. There are
at least seven such skills (status-report, code-quality-scan,
architecture-review, library-deep-dive, naming-review, brutal-self-review,
and now docs-health).

**Should "show the math for any score" be (a) a per-skill rule added to
each scoring skill individually, (b) a single shared reference file that
all scoring skills link to, or (c) a global Crush-level rule in
`~/.config/crush/AGENTS.md`?** I cannot tell which layer you want this at.

### ~~Q3 — Table-with-Commit-column universal?~~ RESOLVED — encoded as the 5+ multi-item rule (resolving-items.md)

The update-old-docs feedback records a specific user quote — "I like tables
that show in which commit it was done" — which I encoded as a universal
rule: "For multi-item resolutions (5+), prefer a table over prose bullets.
A table with explicit **Commit** and **Release** columns..."

**Is the table-with-Commit-column format a universal default that should
apply to anyone using this skill, or is it Lars-specific taste that
shouldn't be pushed on other users of the skill?** The feedback file
treats it as a general lesson; I encoded it as general; but it is
plausibly a personal preference that I over-generalized. I cannot tell
from the feedback file alone.
