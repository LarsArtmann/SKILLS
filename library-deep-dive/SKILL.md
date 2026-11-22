---
name: library-deep-dive
description: >
  Use this skill when the user asks "are we using X to the max", "are we fully
  leveraging <library>", "deep dive into <library>", "library utilization audit",
  "library adoption review", "library maximization", "are we using <library> correctly",
  "what features of <library> are we missing", "library capabilities audit", "library
  usage review", "do we use <library> to its full potential", or any question about
  whether a specific dependency is underutilized, misused, or behind on features. Also
  triggers when the user names a library (e.g. Prisma, Zod, GORM, sqlc, Effect, RxJS,
  gorilla/mux, cobra, viper, react-query, zod, drizzle, typeorm, ent, elm, dayjs,
  lodash, immer, zustand, effector) and wants to know if they're getting the most out
  of it. Performs a deep-dive research audit on a single library. Fires for ANY language
  and ANY library — JS/TS, Go, Rust, Python, Ruby, etc.
metadata:
  tags: library, dependency, utilization, adoption, audit, deep-dive, research, maximization, coverage, gap-analysis
allowed-tools: bash view edit write ls grep agent agentic_fetch mcp_context7_resolve-library-id mcp_context7_query-docs
---

# Library Deep Dive

Determines whether a project uses a **single specific library** to its full potential. The output is a deep, evidence-backed research report — not a surface scan — delivered as a self-contained, beautifully designed HTML file.

## Why This Matters

Most projects use a fraction of a library's surface — `zod` pulled in for
simple validation while schema composition, discriminated unions, and branded
types go unused; `gorm` for basic CRUD while hooks, custom datatypes, batch
operations, and the session API go unnoticed. Hunt for exactly that gap:
hand-rolled code duplicating built-in functionality, slower paths where the
library's optimized one was never used, and stale versions whose newer
features would unlock simplifications. The audit compares what the project
_does_ against everything the library _offers_.

The deliverable is a point-in-time research report — a snapshot read by humans, never edited again — so it gets the full HTML treatment, not Markdown.

## Inputs

The user names a library (e.g. "deep dive into Zod", "are we using GORM to the max"). From that:

1. **Identify the library** in the project's dependency files (`package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `Gemfile`, `pom.xml`, `build.gradle`, etc.).
2. **Capture the exact version** installed — version currency is part of the assessment.
3. If the library is not found in any dependency file, stop and report that to the user with the files checked.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT before each phase. The depth of research is the entire point — do not shortcut it.

### Phase 0: Prior Reports — Read the Series First

Before auditing, list `docs/research/` (or wherever the project keeps point-in-time reports) and skim every earlier report that overlaps this library — a whole-dependency study counts as overlap. Read the project's `AGENTS.md` for what it already knows about the library, too.

Re-auditing what a prior report already covered produces a duplicate, and the two then contradict each other silently. Cite the prior report and state where the new one supersedes it: **newer and narrower wins**. If `docs/research/README.md` exists it is the index — add a row for the new report when you finish.

### Phase 1: Project Discovery — Understand Current Usage

Catalog exactly how the project uses the library today. This is the baseline for the gap analysis.

1. Find every file that imports or references the library (use `grep`/`rg` across the codebase).
2. Enumerate the **touched API surface**: which functions, classes, methods, hooks, middleware, config options, types, and utilities are actually called.
3. Map the **usage patterns**: How is it configured? Is it wrapped in an adapter? Extended? Used raw? Are there custom layers on top?
4. Record **configuration**: What options are set? What's left at defaults?
5. Note any **workarounds or hand-rolled code** near library usage — these often duplicate functionality the library already provides.

For the complete discovery checklist (per language), load [./references/research-methodology.md](./references/research-methodology.md).

### Phase 2: Capability Research — Understand the Full Potential

This is the core of the deep dive. The goal is to build an exhaustive map of what the library _can_ do, so nothing is missed. Use every research tool available — do not rely on training data alone, which is frequently outdated or incomplete.

1. **Resolve the library** via the Context7 MCP (`mcp_context7_resolve-library-id`) and query its documentation (`mcp_context7_query-docs`) for:
   - The full API surface and configuration options
   - Advanced patterns and recommended usage
   - Migration guides and version-specific features
2. **Fetch official docs** via `agentic_fetch` for topics Context7 doesn't cover deeply — especially configuration reference, middleware/hooks/plugins, performance tuning, and lesser-known features.
3. **Search for best practices and anti-patterns** via `agentic_fetch` — community guides, "tips and tricks", "advanced usage", "common mistakes with <library>".
4. **Check the changelog / release notes** for the installed version and newer versions. What features were added that the project may not know about? Are they behind on a major version? READ the dependency's LOCAL `CHANGELOG.md` and `TODO_LIST.md` in full, not just released tags — release intent, tag ETA, and owner-gated blockers live in `[Unreleased]` prose (the 2026-11-19 go-compliance run found "the tag itself waits for the owner's go" there, which reframed the whole adoption timeline).
5. **Enumerate these capability categories** for every library:

| Category                         | What to Look For                                                                   |
| -------------------------------- | ---------------------------------------------------------------------------------- |
| Core API                         | All public functions, classes, methods — not just the ones used                    |
| Configuration                    | Every option, flag, and tunable — many projects leave powerful options at defaults |
| Middleware / Hooks / Plugins     | Extension points the library offers for customization                              |
| Advanced / Lesser-Known Features | Features buried in docs that solve real problems                                   |
| Performance Features             | Caching, batching, streaming, lazy loading, pooling, connection management         |
| Type Safety / DX Features        | Type inference, schema validation, codegen, autocomplete enhancements              |
| Integrations                     | Official adapters, plugins, or compatibility layers for other tools                |
| Testing Utilities                | Built-in test helpers, mocks, fakes, fixtures                                      |
| Error Handling                   | Structured errors, error codes, recovery patterns                                  |
| Observability                    | Logging, metrics, tracing, debug modes the library supports                        |

For the detailed research framework with tool sequencing and search strategy, load [./references/research-methodology.md](./references/research-methodology.md).

### Phase 3: Gap Analysis — Compare Usage vs Potential

For every capability the library offers, determine the project's adoption status. This is where the research pays off — each finding must cite evidence (where in the codebase, or where in the docs).

Grade each capability:

| Status                     | Meaning                                                  | Visual                              |
| -------------------------- | -------------------------------------------------------- | ----------------------------------- |
| **Fully Leveraged**        | Used correctly and optimally — nothing to improve        | 🟢 `.card-solution` / `.score-good` |
| **Partially Used**         | Used, but a more powerful built-in path exists           | 🟡 `.card-warning` / `.score-warn`  |
| **Missed Opportunity**     | Powerful feature not used at all — high potential impact | 🔴 `.card-problem` / `.score-bad`   |
| **Misused / Anti-Pattern** | Used against best practices — actively harmful           | ⚠️ `.card-problem` + warning callout |
| **Not Applicable**         | Feature exists but doesn't apply to this project's needs | ⚪ muted / excluded from scoring    |

Every "Partially Used", "Missed Opportunity", and "Misused" finding must include:

- **What the library offers** (the capability, with a doc reference)
- **What the project does instead** (the current code, with file:line citation)
- **The impact** — what improves by adopting it (performance, correctness, less code, better DX)
- **A concrete code example** showing the recommended usage

**"Not Applicable" is a claim, not an escape hatch.** Every N/A row must carry a one-line reason (why this capability cannot apply to this project). An unexplained N/A reads as "not checked" and silently inflates the adoption score.

### Phase 4: Scoring & Prioritization

Synthesize the gap analysis into an actionable assessment.

1. **Adoption Score** (0–100): weighted by impact, not just count. A missed performance feature weighs more than an unused convenience helper.
2. **Version Currency**: Is the project on the latest? How many minor/major versions behind? What notable features are in the gap?
3. **Top Opportunities**: Rank all findings by (impact × ease) — the Pareto set that delivers the most value for the least effort.
4. **Risk Assessment**: Are any usages actively dangerous (deprecated APIs, known security issues, footguns)?

**Scoring rubric — a bare `88/100` is a judgement dressed as a measurement. Derive it and show the inputs:**

1. Count the capability-inventory rows: that is `N`.
2. Subtract the rows graded **Not Applicable** (out of scope): that leaves the applicable count `A`.
3. Score each applicable row: Fully Leveraged = 1, Partially Used = 0.5, Missed Opportunity = 0, Misused = 0 (Misused also raises a risk finding).
4. `score = round(100 × Σ row scores / A)`.

Publish the score together with its inputs (`M` leveraged of `A` applicable) and a
band: **very high** ≥ 85, **high** 70–84, **moderate** 50–69, **low** < 50.

### Phase 5: Write the HTML Report

Write a self-contained, zero-dependency HTML file.

**Output path:** `docs/research/<YYYY-MM-DD>_<library-name>-deep-dive.html`

Use `date` CLI for the filename date. Use kebab-case for the library name.

1. Load the shared design system: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
2. Start from the **editorial light** template (best for long-form research findings): [./assets/html-report-kit/assets/report-template-editorial.html](./assets/html-report-kit/assets/report-template-editorial.html)
3. For the report-specific section structure, content guidance, and component mapping, load [./references/output-guide.md](./references/output-guide.md)
4. Write the full report with real evidence — every claim cited to code or docs.
5. **Compose the file by copying the template and editing it in place.** Never build it by line-count splicing (`head -n 849 template.html > out && cat body >> out`): a later template edit shifts the boundary and corrupts the report silently. Copy the template to the output path, then replace its demo body.
6. **Run the self-consistency gate before shipping.** Two self-inflicted errors are common enough to be checks:
   - **Denominator drift.** Every `X/N` in the prose must use the same `N` as the capability inventory. Re-count the appendix and reconcile each number.
   - **Unsorted tables.** Every table that claims a sort ("sorted by impact × ease", "descending priority") must actually be sorted by that key. Re-read the column and verify the order.
   - Spot-check every `path:line` citation: a missing file or an out-of-range line means the citation went stale while you were writing.
7. **Close with a "How to verify" appendix** — the exact paths and commands a reader runs to re-derive the score and the top findings (count the appendix rows, `grep -rn <lib> src`, `git -C <dep> describe --tags`). A report nobody can re-check rots into folklore.

### Phase 6: Cross-Skill References

After the report, consider which related skills add value:

- If the library is Go and the project needs better type safety around it → `data-model-review`
- If the project's foundation was never deliberately selected (dependencies accumulated ad-hoc, no STACK.md) → `stack-selection` — the inception counterpart of this audit: it selects the foundation before adoption, this skill audits utilization after
- If hand-rolled code duplicates library functionality → `deduplicate-code`
- If the codebase needs a broader quality pass → `code-quality-scan` or `full-code-review`

### Phase 7: Git Workflow

1. Run `git status` to verify what changed.
2. Stage the report: `git add docs/research/<file>.html`.
3. Commit with a VERY DETAILED message describing the library reviewed, the adoption score, key findings, and missed opportunities.
4. Do not push unless the user explicitly requests it.

### Phase 8: Done bar (added 2026-10-24, from the go-cqrs-lite run)

A deep-dive is DONE only when ALL SIX of these hold — the 2026-10-24 run
shipped the report and missed the rest, and each gap cost a same-day closeout
(items 5–6 added 2026-11-03 from the go-aichat fleet-libs run):

- [ ] **Gate:** the project's quality gate is green at the report's HEAD
      (the audit claims must hold on a healthy tree, and `rg -r`-class
      quoting accidents surface as real findings).
- [ ] **Index:** the report is REACHABLE — if `docs/research/README.md` (or
      the project's equivalent index) exists, it gains a row (subject, date,
      refresh trigger); if no index exists, note that in the report handoff. A
      report no fresh session can find is folklore with styling.
- [ ] **Memory:** the project's AGENTS.md (or memory file) carries the
      durable outcome — the adoption verdict line and the deferral/refresh
      triggers — not just the report path.
- [ ] **Browser:** the committed HTML is screenshot-verified in a headless
      browser (renders, no broken layout, score cards show the derived numbers).
      An unrendered report has shipped with broken markup before; the screenshot
      is the run trace. If the auditing model cannot view images, the visual
      verdict MUST come from a VISION-CAPABLE subagent dispatched to eyeball the
      screenshot — structural checks alone (section greps, DOM presence) do not
      satisfy this bar. Mind viewer limits: most text-model image viewers cap
      around 200 KB, so pre-generate scaled renditions (ffmpeg/ImageMagick) and
      send those to the vision subagent.
- [ ] **Verify blocks executed:** every "how to verify" command block in the
      report is replayed literally as written before shipping — an audit
      whose own verify commands fail on first run (`rg --g`-class typos)
      is self-refuting, and the replay is the cheapest way to guarantee a
      fresh reader can re-derive every claim.
- [ ] **Screenshot preserved in-repo:** the render screenshot is copied into
      the project's docs assets and linked from the report or index, never
      left only in /tmp — run traces in /tmp die with the next reboot. The
      capture must be FULL-PAGE: over-tall window (e.g. 1440x20000) then
      auto-crop to content (ImageMagick `-trim` / `%@` bounding box) — a
      viewport-guessed height truncates long reports and the shipped trace
      misses the appendix (2026-11-19: 3800px capture vs 6126px content).
      Replace the asset UNDER THE SAME NAME so a write-once report needs no
      retro-edit of its links.

## Fleet Runs: the multi-library audit runbook (born nextd, 2026-11-17)

A fleet run audits N libraries of one ecosystem in a single sitting
(nextd's first run: 22 first-party Go libs, 5 sub-agent groups). Phases
0–8 above still govern every individual report; this runbook is the
batch orchestration on top:

0. **Single-report QC pass (mandatory, added 2026-11-19).** Before a
   report ships, dispatch an independent READ-ONLY QC subagent to
   re-verify at least 10 `path:line` citations against the real files,
   recount the appendix/score numbers against the prose claims, and
   re-run the report's own verify block. The first application caught
   two stale citations and superseded provenance hashes in a freshly
   shipped report. Corrections land as errata rows (TODO_LIST), never
   as retro-edits of a write-once report.
1. **Inventory + grouping.** List the fleet's libraries (dependency
   files, project inventory), then group ~4–5 related libs per
   sub-agent. Cap concurrency at 3 — five parallel groups on one
   provider rate-limit-cascaded and cost ~40 minutes on the first run;
   sequential groups lose nothing (each failure predates any output).
   **Dispatch auditor groups SEQUENTIALLY and resume failures in place**
   (2026-11-22, go-cqrs-lite 23-lib run): provider rate-limits and 502s
   killed three of five parallel groups plus one retry — re-dispatching
   from scratch re-derives (and re-bills) the whole context, while
   sending a follow-up message to the failed agent resumes its session
   with the partial work intact. One group at a time also keeps the
   orchestrator's pre-derived facts (pins, tags, HEADs) the only source
   of numbers — sub-agents are for discovery, not arithmetic.
2. **One report contract for every group.** Each lib gets: a verdict
   (ADOPTED / UNDERUSED-<degree> / NOT-ADOPTED / NOT-APPLICABLE), a
   _derived_ score (M leveraged of A applicable, Phase-4 rubric — the
   inputs ship with the score), a capability inventory with evidence in
   BOTH the library repo and the consumer, a gap analysis with code
   snippets, version currency (`git describe --tags` on the local
   checkout — label it "latest local tag" unless remotes were fetched),
   the fleet argument, ranked opportunities, and a verify block the
   AUTHOR executes before shipping.
3. **A justified no beats a lazy no.** Every NOT-ADOPTED names its flip
   trigger (the condition that would change the verdict); every N/A
   carries its one-line reason. The verdict list IS the deliverable —
   the reports just hold it up.
4. **QC sampling.** The orchestrator re-verifies the FIRST report of
   every group (citations + score recount) before declaring done —
   trust is sampled, not assumed. Reports whose verdicts drive real
   decisions (the adoption candidates) are re-verified too.
5. **Index + done bars.** One dashboard page (stat cards, per-lib table
   rows, verdict summary, verify appendix). Structural checks (row/link
   counts) are the floor; when a headless browser is available, Phase
   8's screenshot bar applies to the index as well — a dashboard that
   was never rendered is styling on hope.
6. **Route findings at write time.** Every numbered finding in the
   run's status report ends with its routing marker (TODO row / ROADMAP
   line) as it is written — a post-hoc routing pass is what reds
   freshness gates and loses findings.
7. **Provenance.** Record which sub-agent group produced each report
   (header line) — QC sampling needs the group boundaries to sample
   from.
8. **Mechanical citation sweep (born summit-planner, 2026-11-19/20).**
   Ship a `scripts/citation-sweep.py` with the run: it extracts every
   `file:line` citation from the reports and verifies file existence +
   line range against the app repo AND the library checkouts (absolute,
   repo-relative, `<lib>/`-qualified cross-repo, bare-basename fallback).
   Exit 0 is the ship gate; re-run after ANY report edit. It caught a
   silently-deleted rationale, an unqualified cross-repo cite, and — when
   a parallel migration shifted the code — all 11 stale anchors at once.
   Normalize en-dashes in ranges (`:636–642` silently escaped the first
   regex; normalize before matching).
9. **Own-command verification tier for stamped facts.** Versions, tags,
   line numbers, go.mod pins that get written into a report are re-derived
   by the orchestrator's own commands — subagents are for discovery, not
   for numbers that get stamped. The 2026-11-20 run's research subagent
   returned 6 wrong submodule tags of 11; only the `git tag --list`
   re-check caught them. Corollary: NEVER read the latest tag as
   `git tag | tail` — tags sort lexicographically (v1.9.0 > v1.27.2);
   semver-sort with a numeric key, and expect per-train tags
   (`subdir/vX.Y.Z` alongside root `vX.Y.Z`) in multi-module repos.
10. **Replay the verify blocks pre-ship.** The author executes each
    report's own verify block before shipping; on the 2026-11-20 run
    this caught 4 defects in first drafts (wrong counts, a wrong line
    range, a nonexistent filename, a typo). Cheapest quality instrument
    the run has.
11. **Parallel-session collision doctrine.** Before code work in a repo
    that may have another live session: `git status` + read the newest
    `docs/status`/`docs/planning` files; foreign in-flight files are
    their lease (never edit, never revert); commit only explicitly-mine
    paths; re-derive all line citations after any foreign commit lands.
    Summit-planner had three same-day collisions from skipping this
    check; the doctrine costs one minute.

### Audit brief template (per-library, given to each auditor subagent)

```
Library: <name> (checkout: ~/projects/<name>)
Consumer: <repo> @ <HEAD sha>
Task: utilization audit — what the consumer DOES use vs what the library COULD do for it.
Read: consumer's import sites (rg '<module>' consumer/), library README + the
  submodules the profile plausibly touches.
Deliver: fact table (module list + latest LOCAL tag @ HEAD, used y/n, verdict,
  score Σleveraged/Σapplicable with the inputs), usage evidence with file:line
  citations (QUALIFY cross-repo cites as <lib>/path:line), ranked gaps with
  snippets, RECONSIDER-WHEN trigger (the condition that flips the verdict),
  and a verify block of commands YOU ran (the orchestrator replays them).
NOT your job: changing verdicts of sibling reports, editing consumer code,
  trusting your own version/line numbers without re-running them (orchestrator
  re-derives stamped facts).
```
