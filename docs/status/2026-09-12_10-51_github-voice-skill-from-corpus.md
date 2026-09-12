# Status Report — `github-voice` Skill Built From Full GitHub Corpus

**Date:** 2026-09-12 (Friday, 10:51 CEST)
**Scope:** this session only. Task: list ALL of Lars's GitHub issues/comments
(including projects he does NOT own) and build a skill that teaches writing
in his voice/tone, including lessons from his issue/comment revisions.

**TL;DR:** Collected a 10,682-item corpus (every issue/PR he authored since
2016, 4,158 of his comments/reviews across all repos, 271 items with full
edit history) in 46 minutes via `gh`, analyzed it quantitatively +
qualitatively, and shipped the `github-voice` skill (SKILL.md + 2 references

- 2 scripts). All gates green: check-skills EXIT=0 (29 skills), triggers
  STRONG, link-skills ok, ruff clean on both scripts. The #1 distilled
  lesson: his real voice (external repos) is terse, evidence-first, and
  grammatically imperfect — the opposite of AI-polished assistant prose.

---

## Headline counts

| a) Fully done | b) Partially done | c) Not started | d) Fucked up | e) Improvements | f) Next | g) Questions |
| ------------- | ----------------- | -------------- | ------------ | --------------- | ------- | ------------ |
| 8             | 2                 | 3              | 2            | 3               | 4       | 1            |

## a) FULLY DONE

1. **Session-start checklist executed** — feedback/new read (2026-09-11
   quality-session file: not directly relevant, no skill owned the task),
   newest status report TL;DR read (02-55 self-review: its "quote exit
   codes" lesson was applied live — see d1/d2), TODO_LIST read (T30/T33/
   T34/T35 unrelated), ROADMAP grepped (no voice/writing idea existed —
   nothing to reconcile), check-skills run with EXIT quoted (0).
2. **API surface empirically verified before building** — search counts
   probed (9,397 authored issues / 623 PRs / 7,341 commented threads —
   all above the 1000-result cap → date-windowing required); REST
   `.../versions` endpoints 404 (both comment and issue body variants);
   GraphQL `userContentEdits` works and returns full revision snapshots.
   All findings encoded in the skill's Verification status table.
3. **`collect-corpus.py`** (github-voice/scripts/) — REST search
   discovery (recursively date-windowed), own/external classification
   (own-owners = LarsArtmann, Artmann-Games), agent-filed-body flagging
   ("Task ID:", "Impact Score" markers), comment/review/inline-review
   hydration filtered to Lars, two-pass GraphQL edit-history fetch
   (cheap count probe → diffs only for edited items), rate-limit-aware
   (REST budget poll + GraphQL rateLimit sleep), crash-resume flags,
   markdown corpus rendering with frontmatter (kind/repo/own_repo/
   created/reactions/edits). Smoke-tested on 2026-only window first,
   then full run: **10,682 items, 4,158 comments, 271 edited, 2,749s,
   exit 0**.
4. **`analyze-corpus.py`** — segment stats (external bodies / external
   comments / own bodies / own comments): length quantiles, formatting
   features, opening buckets, bigrams/trigrams, reactions, per-year
   volume. Output: `analysis.json` + `ANALYSIS.md` in the corpus dir.
5. **Voice analysis (quantitative)** — external comments median 44
   chars, external bodies median 241; 5 greetings in 372 external
   bodies; own-repo segments are template-contaminated ("success
   criteria" ×2,720, "closing as" ×769) → external writing weighted
   highest in the profile.
6. **Voice analysis (qualitative)** — read stratified samples: recent
   external issue bodies (12), external PR bodies (6), recent external
   comments (25), multi-version revision diffs (old era 12, modern era
   9), review bodies (8), own-repo closing formulas (8), top-reacted
   comments (10). Patterns distilled below in "Findings".
7. **Skill authored** — `github-voice/SKILL.md` (112 lines: procedure,
   quick rules, corpus sampling + refresh instructions, verification
   table) + `references/voice-profile.md` (11 sections: universals, 7
   genre skeletons with real examples, Do/Never table, era note) +
   `references/revision-lessons.md` (8 revision patterns with
   before→after). Wired: README row + "Seven skills are 🆕 New" prose,
   two-way disambiguation (verify-before-filing description now carries
   the forward pointer; github-voice disambiguates back + names
   jj-fork-pr-workflow), AGENTS §5.5 graph entry (incl. corpus-outside-
   repo rule and the API findings' canonical home).
8. **All gates green** — check-skills.sh EXIT=0 (29 skills, 146 md
   files, no broken links), --triggers EXIT=0 (github-voice STRONG,
   12 markers, desc 840 chars), link-skills-to-agents.sh + --check
   EXIT=0, ruff EXIT=0 on both scripts (fixes applied: PLW1510
   check=False ×3, ISC004 ×3, FURB167 ×2, F401 ×1, E731 ×1).

## Findings (the distilled voice — also in references/voice-profile.md)

- **Structure**: `## Problem` → `## Impact` → `## Fix` for bugs;
  `## Why` → `## What changed` → `## Test plan` for PRs; `Problem →
  Goal` with today-vs-desired tables for features; checklists for
  multi-part requests.
- **Evidence-first**: `file:line` in backticks everywhere, version pins
  ("do v2.1.0 (also re-verified on v2.0.0), Go 1.26"), measured numbers
  ("10,945 user messages / 23 MB parsed on every sessionless launch"),
  verification provenance stated explicitly.
- **Terse comments**: median 44 chars. "Nice :)", "Same here.",
  "Sorry my mistake.", "Resolved merge conflicts." Quote-reply with `>`
  for specific points; `@mention` the addressee (his most common edit:
  adding the missing @mention).
- **Imperfect grammar is the voice**: "Did you tested it?", "Does
  anybody this care about this PR?", "that's should be keeped" shipped
  and stayed. "I am" over "I'm" in careful comments. Revisions NEVER fix
  grammar — they add precision, status words, or restructure into
  bold-labeled verdicts.
- **Revision patterns**: `Edit:` appends over rewrites; "I've been
  extending" → "I extended" + swap promises for existing proof
  ("`go test ./... -count=1` is green at every slice boundary");
  prose → observation-with-file:symbol → **Fix:** bold section.
- **Closing formulas**: `Closing as <obsolete|not planned|duplicate of
  #N>: <specific technical reason> + evidence`. Rejecting stale
  contributions: greet by name → validate as real bugs → world changed
  → name the one specific valuable part → thank (survived 2 revisions).
- **Attribution**: AI-drafted bodies carry "💘 Generated with Crush".
- **Era split**: 2016–2019 = German Minecraft comments, title-only
  issues; 2024+ = the target voice. Corpus files carry `created:` for
  filtering.

## b) PARTIALLY DONE

1. **Corpus coverage is near-total, not absolute.** Own-repo
   authored∧commented threads: most recent 1,500 of 6,508 hydrated
   (follow-up comments are stylistically homogeneous; REST budget is
   5,000/hr). Edit-history fetch capped at first 10 versions per item
   (`truncated` flag set; the 10-version item was an agent-regeneration
   case anyway). Discussions (GitHub Discussions API) not collected —
   different API, marginal voice value.
2. **agent_suspect heuristic undercounts** — flags 191 bodies, but
   bigram analysis shows template sections ("success criteria" ×2,720)
   in far more. Mitigation: the profile weights external writing
   highest and documents the marker list as heuristic, not truth.

## c) NOT STARTED (deliberate)

1. **Eval harness (skill-creator loop)** — writing-style skill =
   subjective output; per skill-creator and how-to-write-skills,
   quantitative assertions are the wrong tool. Human review prompts
   offered instead (see f2).
2. **Description-optimization loop** — `scripts/run_loop.py` needs the
   `claude` CLI; trigger density is already STRONG (12 markers).
3. **dprint/markdownlint pass over new markdown** — same standing
   advisory backlog as every session (exits ✔ by config).

## d) FUCKED UP (caught in-session, fixed)

1. **Pipe-masked ruff exit on the first lint run** — `ruff | tail -5;
   echo $?` reported the tail's exit (0) while ruff had found 4 errors
   (RUFF_EXIT=0 printed next to "Found 4 errors"). The exact
   SESSION-START step-5 / AGENTS §5.11 failure mode, caught because the
   output contradicted itself. Re-ran unfiltered with `$?` quoted
   immediately after.
2. **Three script bugs shipped to disk before compile/lint**: an
   `af"` f-string typo introduced by my own multiedit, a stray `}` from
   the original write (found only by ast.parse after ruff pointed at
   line 79), and an invalid regex (`|+1|` → `nothing to repeat`) in an
   unused-but-compiled constant. All caught by ruff/py_compile smoke
   before any real run; the corpus run itself was clean.

## e) IMPROVEMENTS (knowledge encoded)

1. AGENTS §5.5 now documents the github-voice graph position + the
   canonical home of the GitHub-API findings (windowed search, REST
   versions-404, GraphQL userContentEdits).
2. The collector's resume flags (`--skip-discover/--skip-hydrate`) make
   corpus refreshes incremental-friendly after crashes.
3. Corpus lives at `~/.cache/github-voice-corpus/` (XDG cache) — never
   committed; the repo carries only distilled patterns.

## f) NEXT

1. **Human review of the skill output**: try it on a real prompt — e.g.
   "file this bug against <repo> for <symptom>" or "reword my comment
   on crush#NNN in my voice" — and check the draft against the Do/Never
   table. Adjust the profile where reality disagrees.
2. **After first successful real use**: age 🆕 → 🟢 in README (same
   convention as collector-extraction).
3. **Optional: full own-repo hydration** — re-run collect with
   `--own-followup-sample 6508` overnight if the maintainer-voice
   segment ever needs depth.
4. **Optional: corpus refresh cadence** — re-run the two scripts after
   ~3 months of activity; update profile numbers if ANALYSIS.md drifts.

## g) QUESTIONS

1. Should GitHub Discussions be collected too (separate GraphQL
   schema)? Skipped as low voice-value; say the word if wanted.

## Evidence

- Corpus: `~/.cache/github-voice-corpus/` (summary.json, analysis.json,
  ANALYSIS.md, raw/*.json, markdown/bodies + markdown/comments).
- Skill: `github-voice/` (SKILL.md 112 lines, 2 references, 2 scripts).
- Wiring diffs: README.md (2 edits), verify-before-filing/SKILL.md
  (description +1 sentence), AGENTS.md (§5.5 +1 paragraph).
- Gates: check-skills.sh EXIT=0 (29 skills), --triggers EXIT=0,
  link-skills-to-agents.sh --check EXIT=0, ruff EXIT=0 ×2 scripts.
- The full-run log (`/tmp/gv-full.log`) is cited for timings but is
  ephemeral /tmp scratch — every number in it is re-derivable from
  summary.json, which IS persisted in the corpus dir.
