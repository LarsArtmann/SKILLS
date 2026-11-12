# Reconciliation: website-launch — Two Proposals, One Decision

**Date:** 2026-10-11 08:30 · **Scope:** compose
[`04-28_go-templ-migration-assessment`](2026-10-11_04-28_website-launch-go-templ-migration-assessment.md)
(stack migration) and
[`04-29_template-sdk-proposal`](2026-10-11_04-29_website-launch-template-sdk-proposal.md)
(template repo + SDK) into one decision and one plan · **Mode:** engineering
reconciliation — the 04:29 report's claims were re-verified this session
before being relied on; nothing outside this repo was modified.

## Context

Two reports landed 60 seconds apart, answering **two different questions
Lars asked** (likely of different sessions):

- **04:28** answers _"migrate website-launch to my standard stack (Go +
  templ + templ-components)?"_ → yes, phased; the templ-components Go SSG is
  the proven reference implementation.
- **04:29** answers _"improve the template — maybe with an actual SDK?"_ →
  keep Astro, extract gogenfilter into a canonical `website-template` repo +
  purpose-built `websitelaunch` CLI (Option A); reject building on
  `template-CLI` (Option B).

They conflict on **stack direction** but agree on **mechanism** (canonical
template repo, mechanical checks as code, skill sheds ~1,000+ lines,
opportunistic site migration, close the ROADMAP 848-line question). This
document merges them into one plan gated on a single decision.

## 1. Verification of the 04:29 Report (all run this session)

| # | Claim                                        | Verdict                                                                                                                                                                             |
| - | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | 18 repos have `website/`                     | ✅ exact list captured — **nuance: 17 Astro/JS + 1 Go SSG (templ-components)**, not a uniform Astro fleet                                                                           |
| 2 | gogenfilter `website/` = 94 files on disk    | ✅ 94 incl. `pnpm-lock.yaml` (93 without)                                                                                                                                           |
| 3 | `templates` CLI tests fail on macOS paths    | ✅ reproduced: `go test ./internal/integration/` → `Expected default templates dir '/Users/larsartmann/projects', got "/home/lars/projects"` FAIL (hardcoded paths in 3 test files) |
| 4 | `template-CLI` has zero consumers            | ✅ only its own `go.mod` matches across `~/projects/*/go.mod`                                                                                                                       |
| 5 | `go-website-template` is a different stack   | ✅ Go+Templ+HTMX on **Cloud Run** — the dynamic product-site pattern (i18n, contact form, legal pages), not static docs                                                             |
| 6 | May-review grades B-/C+ and quotes           | ✅ `review-templates-vs-template-CLI.md` lines 509/513                                                                                                                              |
| 7 | Pitfall #4 (vite pin drift from gogenfilter) | ✅ `SKILL.md:742-747`, and the copy-from-live-repo framing is correct                                                                                                               |
| 8 | "16 references (3,267 lines)"                | ⚠️ **15** reference files (line total correct) — only factual error found                                                                                                            |

The 04:29 problem analysis stands: the de-facto template is gogenfilter's
working tree read at launch time; the version matrix is prose; verification
is agent discipline. Option B/C/D rejections are endorsed on the verified
facts (B: failing hub + zero-consumer SDK is the wrong first consumer; C:
vendoring a 94-file JS project into a docs-only repo violates repo §9; D is
the cheap subset of A).

## 2. The Composition: Mechanism vs Stack

The two proposals operate on different axes and compose cleanly:

- **04:29 owns the DELIVERY MECHANISM** — canonical template repo,
  CI-green-by-construction, `websitelaunch doctor|init|check|retrofit`,
  skill keeps judgment and sheds mechanics. This architecture is
  **stack-agnostic**: `doctor` and `check` barely change, `init` just
  scaffolds from a different source.
- **04:28 owns the CONTENT DECISION** — which existing site gets extracted
  as the canonical baseline: gogenfilter (Astro) or the templ-components Go
  SSG.

Therefore **one decision gates everything**: the extraction source. Building
04:29's Astro template now and pivoting it to Go later is the worst path —
double extraction, double CI, double `init` machinery.

## 3. The Decision (Q0) — Evidence Both Ways

**Q0: extract the Go SSG or the Astro site as the canonical template baseline?**

| For Go SSG baseline (04:28)                                               | For Astro baseline (04:29)                                          |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Lars' stated direction: "my standard tech stack"                          | 17 live Astro sites → `retrofit` has immediate consumers            |
| Migration pain already paid once (templ-components site, 2026-09-13)      | Starlight feature set complete without new code (editLink etc.)     |
| 8 of 22 pitfalls die (#3,#4,#5,#6,#7,#9,#11,#20 — all Node/pnpm/MDX)      | Future Astro launches (if any) keep working unchanged               |
| `dependency-versions.md` (186 lines of prose pins) dies → lockfile/go.mod | Smaller blast radius; no dogfood coupling to templ-components       |
| Golden tests, CSP hash-pinning, link checker, llms.txt built in           | Skill's Phase 3/4 instructions already match the Astro shape        |
| Dogfoods templ-components across the whole portfolio                      | Go SSG parity gaps must close first (editLink, lastUpdated display) |

**Recommendation: Go SSG baseline.** It matches the stated stack direction,
kills the largest pitfall classes outright, and the reference implementation
is the most-tested site in the portfolio. The 17 Astro sites stay on the
skill's existing manual §0.0 audit (they are live and stable; their retrofits
are occasional) — `retrofit` under a Go baseline becomes a _migration-diff
helper_ for the day each site moves, not a same-stack drift check. Accept
explicitly: short-term, Astro sites get no new tooling; `check`/`doctor`
benefit everyone immediately.

**Fallback:** if Q0 defers the Go call, the Astro baseline is the safe
interim — but then commit to it (17 consumers, retrofit sweep ordered by
security-header/CSP gaps, per 04:29 step 7) and treat the Go SSG as a
separate future v2, not a parallel track.

## 4. Unified Plan (gated at step 0)

| Step | What                                                                                                                                                                                                                       | Source plan                | Gate    |
| ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- | ------- |
| 0    | Lars decides **Q0 + Q1–Q5** (04:29 §7: repo name, CLI language, gogenfilter's fate, visibility, T33 sequencing)                                                                                                            | both                       | user    |
| 1    | Extract chosen baseline → canonical repo; acceptance test: builds from a clean checkout that has never seen the source repo                                                                                                | 04:29 §6.1 + 04:28 Phase A | Q0      |
| 1a   | _(Go only)_ close parity gaps in the template: editLink, per-page lastUpdated; pin standalone `tailwindcss` in CI (nodeless)                                                                                               | 04:28 §2                   | Q0 = Go |
| 2    | `websitelaunch doctor` — Phase 0 as code (stack-agnostic, useful day one)                                                                                                                                                  | 04:29 §5.2                 | step 1  |
| 3    | `init` — scaffold end-to-end; smoke-test = scaffold scratch repo + build                                                                                                                                                   | 04:29 §5.2                 | step 2  |
| 4    | `check` — DoD + Phase 4 as code (lockfile-or-go.mod consistency, license 4-file check, og:image, mp4 cache headers, hero-snippet compile); run against the source site first — its drift findings validate the checker     | 04:29 §5.2/§6.4            | step 3  |
| 5    | Skill slim: Phase 3 → scaffold instructions, absorb references per the disposition tables (04:29 §5.3 / 04:28 §6 — same destination either way), update FEATURES row, **re-run `evals/`**, close ROADMAP 848-line question | both                       | step 4  |
| 6    | Dogfood on the next real launch; fixes flow to the template repo, not the skill                                                                                                                                            | both                       | step 5  |
| 7    | Fleet: Go baseline → opportunistic per-site migration (04:28 Phase D); Astro baseline → `retrofit` sweep ordered by CSP/security gaps (04:29 §6.7)                                                                         | per Q0                     | step 6  |

## 5. Executed This Session vs Blocked

**Executed (this repo only):** 04:29 claim verification (§1 above), this
reconciliation, TODO_LIST rows T57–T59 (decision package → CLI → skill slim),
ROADMAP pointer on the 848-line question, forward-note on the 04:28 report.

**Blocked on Lars (deliberately not started):** Q0 and Q1–Q5; creation of the
template repo; any extraction; any skill-body edit (stack decision rewrites
Phase 3 either way — editing now would churn).

## 6. Verification Log (2026-10-11, this session)

- 18-site list + per-site `website/package.json` vs `website/go.mod` stack
  split → 17 Astro/JS, 1 Go SSG.
- `find ~/projects/gogenfilter/website -type f` (excl. node_modules/dist/
  .firebase) → 94 incl. lockfile, 93 excl.
- `cd ~/projects/templates && go test ./internal/integration/ -count=1` →
  FAIL with the exact macOS-path assertion (claim #3 reproduced, not trusted
  from the report).
- `grep -l LarsArtmann/template-CLI ~/projects/*/go.mod` → self only.
- `review-templates-vs-template-CLI.md` lines 509/513 read (grades/quotes).
- `go-website-template/README.md` head read (Cloud Run, dynamic pattern).
- `website-launch/SKILL.md:730-797` read in full — 22-item pitfalls list,
  pitfall #4 at 742-747 as quoted.
- Reference count: `ls website-launch/references/*.md | wc -l` → 15.
- The 04:29 report itself was **not modified** (not authored by this session;
  its one factual error is recorded here instead).
