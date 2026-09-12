---
name: github-voice
description: >
  Use when drafting or rewriting ANY GitHub communication as Lars — issue
  bodies, PR descriptions, issue comments, replies to maintainers, review
  comments — or when the user says "write this issue", "draft a PR
  description", "comment on this issue", "reply to this maintainer",
  "how would I phrase", "in my voice", "reword my issue", or asks how his
  GitHub writing sounds. Loads Lars's empirically-derived voice profile
  (terse, evidence-first, imperfect grammar preserved) plus per-genre
  skeletons and revision-informed drafting rules. Use it even when the
  user just hands you a bug report and says "file this". Distinct from
  verify-before-filing (that gates WHAT to claim — verify the diagnosis
  before drafting; this skill shapes HOW the text reads once content is
  settled) and jj-fork-pr-workflow (VCS mechanics of upstream PRs, not
  prose).
allowed-tools: gh
metadata:
  tags: github, writing, voice, issues, pull-requests, comments, communication
---

# GitHub Voice

Draft GitHub issues, PRs, comments, and reviews the way Lars actually
writes them — derived from a corpus of 10,682 of his real items
(every issue/PR since 2016, every comment across all repos, plus his
edit histories), not from generic "good issue" advice.

**The #1 failure mode is applying one register everywhere.** Since
2025 Lars writes GitHub in two registers, split by stakes (see profile
§1 "The two registers"): **bodies** (issues/PR descriptions) are long,
structured, evidence-heavy, often AI-drafted-then-cut (~1,050-char
median, `## Problem`/tables, Crush footer when Crush drafted) — while
**comments** are handwritten-terse (~85-char median, one point, no
headers, imperfect grammar, no footer). Polish a comment into assistant
prose, or write a body as a casual one-liner, and it is wrong even when
its content is right.

## Procedure

1. **Classify the artifact**: genre (bug report / feature request / PR
   description / comment / review / maintainer-closing) and audience
   (external repo vs own repo). This selects the profile section.
2. **For external filings, verify content first**: if the issue/PR goes
   to a repo Lars does not own, the diagnosis must pass
   [../verify-before-filing/SKILL.md](../verify-before-filing/SKILL.md)
   before any prose is written. Voice cannot rescue a wrong premise.
3. **Load the profile**:
   [./references/voice-profile.md](./references/voice-profile.md) — pick
   the matching genre section; its skeleton + real examples are the
   template.
4. **Draft** using the genre skeleton and the quick rules below, in the
   right register: bodies long+structured (AI-drafting fine — then cut),
   comments terse+human (draft as if typing fast). Prefer one evidence
   artifact (file:line, version pin, command output, link) over
   adjectives in both.
5. **Revise once, his way**:
   [./references/revision-lessons.md](./references/revision-lessons.md)
   — add status word, add `file:line` precision, swap promises for
   existing proof, bold the recommendation. Do NOT grammar-polish.
6. **Self-check** against the Do/Never table in the profile (§10).
   If any "Never" cell appears (greeting opener, sign-off, hedging
   twice, emoji headers), cut it.

## Quick rules (full detail in the profile)

- Two registers, split by stakes: bodies long+structured (median ~1,050
  chars since 2025-09, 69% headers); comments terse and plain (median
  ~85 chars, 5% headers, never a report).
- Open with the problem, never with a greeting. 5 greetings in 372
  external bodies.
- `## Problem` / `## Why` / `## What changed` headers in bodies;
  backticked `file:line` evidence; versions pinned ("do v2.1.0,
  Go 1.26").
- Comments are one point, often one line. No headers, no sign-offs,
  no AI footer on a one-liner.
- Keep grammar imperfect on purpose in comments ("Did you tested it?"
  shipped); bodies may be fully polished (they are AI-drafted and cut).
  "I am" over "I'm" in careful comments.
- Emoji: max one, at the end. `:)` `👀` `❤️` only.
- Closing formula: `Closing as <obsolete|not planned|duplicate of #N>:
  <specific technical reason>`.
- Attribute AI drafting where it happened: "💘 Generated with Crush"
  footer on bodies; in-line disclosure for AI-assisted reviews
  ("> [!NOTE] PR review done with Crush and GLM-4.6 ..."). Never on
  quick comments.
- Quote-reply with `>` when answering a specific point; `@mention` the
  addressee at the start.

## Fresh examples from the live corpus

The distilled profile carries exemplars, but the full corpus (10k+
markdown files, refreshable) is at `~/.cache/github-voice-corpus/markdown/`.
Sample it when you need more instances of a genre:

```bash
ls ~/.cache/github-voice-corpus/markdown/comments | shuf -n 5
```

Each file's frontmatter carries `kind`, `repo`, `own_repo`, `created`,
`reactions`, `edits` — filter with grep, read with `view`. Weight
`own_repo: false` items highest; check `created:` (≥2024 only — the
2016–2019 era is German Minecraft comments, not the target voice).

## Refreshing the corpus

The corpus is a snapshot. After months of activity (or on a new machine):

```bash
./scripts/collect-corpus.py                 # ~45 min, gh CLI, rate-limit aware
./scripts/analyze-corpus.py                 # regenerates analysis.json + ANALYSIS.md
```

`collect-corpus.py` re-fetches everything (REST search windowed by date —
search caps at 1000/query; GraphQL `userContentEdits` for revisions —
the REST `versions` endpoints 404). If the profile's claims drift from a
fresh `ANALYSIS.md`, update the profile's numbers and examples from the
new corpus — the profile is data-derived and must stay that way.

## Verification status

| Claim                                                  | Status      | Source                                                                                |
| ------------------------------------------------------ | ----------- | ------------------------------------------------------------------------------------- |
| Corpus size 10,682 items / 4,158 comments / 271 edited | ✅ verified | `~/.cache/github-voice-corpus/summary.json`, generated 2026-09-12                     |
| REST `.../versions` endpoints unusable                 | ✅ verified | 404 on `issues/comments/{id}/versions` and `issues/{n}/versions`, 2026-09-12          |
| GraphQL `userContentEdits` returns revision snapshots  | ✅ verified | live query against comment `IC_kwDOOt6mSM8AAAABTopgeQ` + 271 edited items, 2026-09-12 |
| Search 1000-result cap requires date windowing         | ✅ verified | author query returns 9,397 total; windowed retrieval succeeded                        |
