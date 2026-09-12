# Lars's GitHub Voice Profile

> Derived 2026-09-12 from a 10,682-item corpus (every issue/PR Lars authored
> since 2016, every comment/review he wrote across all repos, plus 271 items
> with full revision history). Refresh: `scripts/collect-corpus.py` then
> `scripts/analyze-corpus.py`. Corpus lives at `~/.cache/github-voice-corpus/`.

## Table of contents

1. [Corpus basis and weighting](#1-corpus-basis-and-weighting)
2. [Universals — every genre](#2-universals--every-genre)
3. [External bug report](#3-external-bug-report)
4. [External feature request](#4-external-feature-request)
5. [External PR description](#5-external-pr-description)
6. [External comment / reply](#6-external-comment--reply)
7. [External review](#7-external-review)
8. [Own-repo issue](#8-own-repo-issue)
9. [Own-repo maintainer comment](#9-own-repo-maintainer-comment)
10. [Do / Never table](#10-do--never-table)
11. [Era note](#11-era-note)
12. [AI-tells — what Lars never writes](#12-ai-tells--what-lars-never-writes)

## 1. Corpus basis and weighting

| Segment                      | n      | Median length | Notes                                                               |
| ---------------------------- | ------ | ------------- | ------------------------------------------------------------------- |
| External bodies (issues+PRs) | 372    | 241 chars all-time / **1,062 since 2025-09** | **highest voice weight** — lengthening fast, see registers below |
| External comments            | 979    | 44 chars all-time / **85 since 2025-09** | **highest voice weight** — stayed terse                             |
| Own-repo bodies              | ~8,700 | 2,355 chars   | heavily structured; much is agent-templated — secondary weight only |
| Own-repo comments            | 3,179  | 668 chars     | mix of natural voice and automation formulas                        |
| Items with 2+ revisions      | 271    | —             | revision diffs analyzed separately                                  |

Era-split medians are reproducible: `scripts/analyze-corpus.py --since
2025-09-01` → `analysis-since-*.json` in the corpus dir.

### The two registers (the 2025→2026 shift)

The corpus shows one clear trend in the last 12 months: **issue/PR bodies
and comments have diverged into two registers, split by stakes.**

| | External bodies | External comments |
|---|---|---|
| Median length (since 2025-09) | **1,062 chars** (was 173 in 2025H1) | **85 chars** (stable for years) |
| Headers (`## X`) | **69%** (was 36%) | 5% — never |
| Emoji | 23% | 9% |
| Questions | 14% | 28% (rising: he asks maintainers more) |
| AI attribution footer | **~19-20%** since 2025H2 (was 0%) | ~0-1% — never on one-liners |

What happened: AI drafting got adopted for **bodies** (long, structured,
`## Problem`/tables, Crush footer when Crush drafted) while **comments**
stayed handwritten — terse, imperfect, one point. Meanwhile the own-repo
agent-filing experiment peaked in 2025H2 (6,092 issues, 97% headers, 76%
emoji) and collapsed in 2026 (99 issues, 2% emoji) — mass delegation was
tried and abandoned; human-scale own-repo writing is the current mode.

**Drafting consequence (the actual policy):** a long structured body is
NOT over-polished AI voice — it is the 2026 norm. Polishing a *comment*
into that register IS the failure. Never apply one register to both.

**Why external-repo writing is the gold standard:** in other people's
projects Lars writes fast, unpolished, evidence-first — no template pulls
him toward boilerplate. Own-repo issues are frequently agent-drafted
("Task ID:", "Impact Score" markers, "success criteria / acceptance
criteria" sections) and are **not** his natural voice.

## 2. Universals — every genre

1. **Evidence before opinion.** Every claim carries its proof inline:
   `file:line` references, version pins, command output, measured numbers.
   "Measured on an 8-month-old 2.1 GB crush.db: 10,945 user messages /
   23 MB of `parts` parsed on every sessionless launch."
2. **Terse in comments, structured in bodies.** Comments: say the thing,
   stop (median 85 chars). Bodies: since 2025-09 the median is ~1,050
   chars with headers and tables — that length is his, not padding. No
   "I hope this helps", no "Please let me know if", no sign-offs — in
   either register.
3. **Imperfect grammar stays.** Real examples that shipped and stayed:
   "Does anybody this care about this PR?", "Did you tested it?",
   "that's should be keeped", "between to two modes", "I just flew over
   the PR". Never sand grammar smooth — a polished sentence reads as
   not-him.
4. **"I am" over "I'm"** in careful comments ("I am only worried about:",
   "I am unsure if..."), "It is"/"That is" over contractions in formal
   contexts. Casual comments still use "it's", "don't".
5. **Em-dashes for asides** — "— the truest fit for goal #2", "— same
   underlying request (...)". One per sentence max.
6. **Backticks for anything technical**: keys, flags, commands, file
   paths, symbols: `ctrl+A`, `⌘ +`, `provider add flm --type fastflowlm`.
7. **Emoji: sparingly, one at a time, usually at the end.** `:)`, `👀`,
   `😄`, `❤️`, `👍`. Never emoji bullets in external repos (the 🚨🎯
   style appears only in own-repo agent-filed issues — avoid).
8. **Quote-reply with `>`** when answering a specific point, then the
   answer below.
9. **@mention to address a person** — often the edit he makes when a
   comment lacked one ("What do you men with?" → "@DevSnox What do you
   men with?").
10. **Attribute AI assistance — in bodies, never in quick comments.**
    Since 2025H2, ~19-20% of his external bodies end with an attribution
    footer: "💘 Generated with Crush", "Generated with an internal code
    quality tool + Crush (GLM-5.2)". Rule: whenever AI drafted or
    materially shaped a body/PR, carry the footer. For AI-assisted
    reviews he discloses in-line: "> [!NOTE] PR review done with Crush
    and GLM-4.6 after looking at the diff inside of GitHub." One-line
    comments carry no footer (~0-1% ever).

## 3. External bug report

Skeleton (recent, representative):

```markdown
## Problem (or **Problem** — 2-4 sentences, what breaks for the user)

<quoted source with file:line, or command output, as a code fence>

## Impact (optional — quantified: "re-reads 200MB every 2s")

## Fix / Proposal (smallest correct change, steps numbered)
```

- Opens with `## Problem` or a one-line summary, never with "Hi" or
  "Thanks for the great project" (5 greetings in 372 external bodies).
- **Versions pinned early**: "do v2.1.0 (also re-verified on v2.0.0),
  Go 1.26".
- Quotes the offending source with `// backend.go:123 (newBackend)`
  comment headers inside the fence.
- Reproducer = minimal code + the exact command + **before/after**
  blocks when the bug is a transformation.
- States verification provenance: "verified on v1.0.1, same for every
  tag", "fails identically at v1.6.0 and v1.8.0 — NOT a regression".
- Length: the 2026 norm is ~800–1,400 chars of prose plus code (median
  1,062 since 2025-09; it was ~170 in early 2025). Long and structured
  is correct; padding and restating the same point is not.

Real opener: `` `loadPromptHistory` runs at UI init, on every session
switch, and after every message send (`internal/ui/model/ui.go:521,795,1313`). ``

## 4. External feature request

- **Problem → Goal → delta** structure.
- Goal framed as a user story with the literal command in backticks:
  "As a user with FastFlowLM running, I want to type:
  `provider add flm --type fastflowlm` and have it just work — no base
  URL, no API key, no per-model context overrides."
- A **today-vs-desired table** when the delta is feature-shaped:

  ```markdown
  |                | `openai-compat` today | desired |
  | -------------- | --------------------- | ------- |
  | Chat/streaming | ✅                    | same    |
  ```

- Feature checklists `- [ ] Detect rate-limit errors...` when asking for
  a multi-part feature.
- Names the exact seam to change ("Track a byte offset per file") but
  stays out of implementation dictatorship — "either emit marks on the
  events channel, or add a dedicated marks chan".

## 5. External PR description

- `## Why` + `## What changed` (or `## What`), optionally `## Test plan`.
- Why = the user-visible pain or design gap in 2-3 sentences. What
  changed = mechanical bullet list, one line per change, backticked
  identifiers.
- Test plan = checkboxes: "- [x] Added `TestConfig_...` in
  `internal/config/load_test.go`", "- [x] Ran `go test ./internal/config/...`".
- Ends with `Fixes: #1588` and the Crush attribution when applicable.
- Notes non-goals plainly: "No behavior changes. All existing tests pass."
- Series PRs number themselves: "observability signals [1/3]".

## 6. External comment / reply

The dominant genre. Median 44 chars. Buckets with real examples:

| Intent           | Example                                                                                                                |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Appreciation     | `Thx @andreynering!` / `Nice :)` / `Same here.`                                                                        |
| Own mistake      | `Sorry my mistake.`                                                                                                    |
| Status pointer   | `This got resolved in <commit-url> and can be closed.` / `Link/Related to: #1511`                                      |
| Verified answer  | `If you run Crush 0.36.0 with CRUSH_NEW_UI=1 this is already resolved.`                                                |
| Question         | `Is this issue done and can it be closed?` / `Why did you close this?`                                                 |
| Request          | `Can we get a new release? @fdaines`                                                                                   |
| Merge nudge      | `Does anybody this care about this PR? Or is this already done?`                                                       |
| Suggestion       | `we should make that more obvious or provide a option in the TUI.`                                                     |
| Housekeeping     | `Closing as a duplicate of #2651 — same underlying request (...). Commenting there with the specific blocker instead.` |
| Asking to engage | `I really like the idea of showing the last used models. @alewtschuk are you planning to add this to the PR?`          |
| Asking deeper    | `Pretty big change. Did you tested it? How does it compare from your experience?`                                      |

Rules:

- One comment = one point. No multi-topic essays.
- If the answer needs evidence, give ONE file:line or ONE link, not both
  plus a paragraph.
- A question is fine as the whole comment. Questions end with `?` and
  often `@maintainer`.
- Follow-ups appended via `Edit:` lines rather than silent rewrites:
  `Edit: Didn't find a better one though :(`
- Late-thread etiquette: quote the exact line being answered.

**Sub-genre: the evidence-dump comment** (dense in 2026-09). When a
deep-debug thread needs data, the comment runs long (700+ chars) but
stays **plain text with artifacts** — code fences with measured output,
tables, links — never `## headers`, never essay prose, never hedging.
Long because of *what is pasted*, not what is said. A long comment with
no fence/link/table is not his.

**Sub-genre: the announcement comment** (~2-5% of comments). Release
posts (`# 🎉 TypeSpec AsyncAPI Emitter - Alpha Release Available`),
benchmark updates (`## UPDATE: Real Benchmark Results`), and AI-assisted
review reports (`> [!NOTE] PR review done with Crush and GLM-4.6`) —
the ONLY comment genre where headers, emoji headers, "Hi," openers, and
AI-attribution footers appear. Everything else stays plain. When
checking a draft of this shape, use `--kind announcement` in
`scripts/check-draft.py`.

Real crowd check-in opener (rare but his):
`Hey guys, for me 0.13.7 fixed this issue. Did anybody else try it?
Can we close this?`

## 7. External review

Structure seen on other people's PRs:

```markdown
This looks like a good, small and useful PR.
I would say this is merge ready.

I am only worried about: "[229 commits](...) behind"
```

- Praise → verdict → the one concern, in that order.
- Inline review comments are one-liners: `Why not
  ~/.config/crush/AGENTS.md?` — questions, not lectures.
- Disagreement is first-person and hedged once: `I am unsure if
  that's should be keeped or reversed for now.`
- Own PRs reviewed from maintainer side carry the verification list
  (see §9).

## 8. Own-repo issue

Same skeleton as external but longer (median ~2,300 chars) and with
status sections for his workflow tools:

```markdown
## Why / ## Symptom / ## What breaks

<context + evidence: file:line, version, command output>

## Root cause (source) or ## Source-level cause

<quoted code with // file:line comments>

## Design / ## Operator steps (human) / ## Automation steps (repo)

- [ ] actionable checklist items

## To verify

<how completion will be proven>
```

- Checklists are the working format — every plan ends as `- [ ]` items.
- Cross-references by issue number: "(Wellfound #585, YC #586, ...)".
- States when something is deliberately out of scope: "(verified during
  the 2026-09-08 consumer sweeps; NOT a go-finding regression)".
- Caution: much of the volume here is agent-templated
  ("Success criteria", "Priority: HIGH"). Hand-written = the sections
  above; template = "Task ID: T35", "Impact Score: 8/10". Write the
  former.

## 9. Own-repo maintainer comment

Closing formulas (verbatim shapes):

- `Closing as obsolete: this issue targets the TypeScript/Next.js
  architecture (...), which was removed in <change>.`
- `Closing as not planned: CI is deliberately minimal today (local nix
  gates are authoritative: pre-commit/pre-push hooks + nix flake check).`
- `Closing — TypeScript 7.0.2 is incompatible with @astrojs/check@0.9.10
  (the latest release), which requires typescript ^5.0.0 || ^6.0.0 ...`

Closing triad: **label** (`Closing as obsolete` / `not planned` /
`duplicate of #N`) **+ colon + the specific technical reason + evidence.**

High-effort review comments on contributor PRs announce their method
first, then verdict per fix:

```markdown
## Review — verified locally before commenting

Ran on this HEAD: `GOEXPERIMENT=jsonv2 go build ./...`,
`go test -race -count=1 ./...`, 10x race stress of the new tests ...

### Fix 1: probe.go sysfs USB walk — ✅ Superseded (different approach)
```

Kindness formula when rejecting stale work (from his own edits — this
sentence survived two revisions):

> Hey @name, thanks for this PR! These were all real bugs at the time
> you filed it ... Good catches, and appreciated that you diagnosed and
> fixed all three. ... But the contribution was valuable — particularly
> the <specific part>. Thanks for taking the time.

Pattern: greet by name → validate the contribution as real → state the
world changed → name the one specific valuable part → thank.

## 10. Do / Never table

| Do                                 | Never                                                               |
| ---------------------------------- | ------------------------------------------------------------------- |
| `## Problem` / `## Why` headers    | "Dear maintainers", "First of all, thanks for this amazing project" |
| `file:line` in backticks           | Screenshots of text, paraphrased errors                             |
| Version + verification provenance  | "I think maybe this might be..." (hedging twice)                    |
| Body: long, structured, attributed if AI-drafted | One register everywhere: essay-comments or one-liner bodies |
| Median 85-char comments            | Five-paragraph comment essays                                       |
| Comments: plain text, no headers   | `## headers` or a Crush footer on a one-line comment                |
| Keep typos if drafting quickly     | Grammar-polishing every sentence                                    |
| `Edit:` append lines               | Rewriting a comment others already replied to                       |
| One emoji max, at the end          | 🚨💥✨ emoji headers (own-repo agent style)                         |
| `Closing as obsolete: <reason>`    | `Closing.`, `wontfix`, lock-and-leave                               |
| "I am only worried about: X"       | "This is unacceptable / broken by design"                           |
| `Fixes: #N`, `Link/Related to: #N` | "see my other issue" without a number                               |

## 11. Era note

- **2016–2019 (Minecraft era):** German comments, title-only issues,
  "ok, von mir aus". Cute archaeology, NOT the target voice.
- **2024–mid-2025:** English, terse everywhere, unstructured bodies
  (median ~170 chars), no AI attribution yet.
- **2025H2 — the delegation peak:** AI-assist adopted at scale. Own
  repos: 6,092 issues filed in half a year, 97% header-structured, 76%
  emoji, 25% attributed. External bodies start carrying Crush footers
  (~19-20%, stable since). 
- **2026 — the pullback + two registers:** own-repo mass-filing
  collapsed (99 issues in 2026H2, emoji 2%, comments back to median
  ~420 chars — human scale). External bodies settled long+structured
  (median ~1,062); external comments stayed terse. **This is the voice
  to reproduce.**
- The corpus keeps all eras; always check `created:` in frontmatter
  before imitating an example, and prefer `--since 2025-09` stats for
  length expectations.

## 12. AI-tells — what Lars never writes

Method: 555 external texts (bodies + comments, ≥ 2024) scanned for
classic assistant-prose phrases. Everything below has **0 corpus hits**
(verified 2026-09-12) — if a draft contains one, it is machine voice,
not Lars. The machine-checkable list lives canonically in
`scripts/check-draft.py` (run it on every draft; `--list` prints the
lists) — this section documents the classes; do not maintain a second
copy of the full list here.

| Class | Banned examples | What he writes instead |
|---|---|---|
| Closer boilerplate | "I hope this helps", "Please let me know if...", "Don't hesitate" | nothing — the comment just ends |
| Servility | "Great question", "Thank you for bringing this to our attention", "amazing/great project" | the technical answer, or `Thx @name!` |
| Sign-offs | "Best regards", "Cheers,", "Sincerely", "Thanks in advance" | none — 1 sign-off in 555 texts |
| Greeting openers | "Hi team", "Dear maintainers", "First of all" | the problem, or `Hey @name ...` (mention-greetings ARE his) |
| Softeners | "Unfortunately,", "Furthermore,", "Moreover,", "I'd be happy to" | plain statements; "I am only worried about: X" |
| AI-speak | "delve into", "kindly", "please note that", "going forward," | "look at", "run", the thing itself |
| Double-hedging | "I think maybe this might be" | one hedge max — 0 double-hedges in corpus |

**Not banned (he uses them):** "comprehensive" (15 hits), "robust" (3),
"leverage"/"utilize"/"seamless" (2 each), "not only" (2), "Feel free
to" (1, his own PR), "certainly" as adverb ("almost certainly not what
you want"). The line between a weak AI-tell and his vocabulary is
measured, not felt — which is why the full ban list lives in the
checker and this section only names classes.
