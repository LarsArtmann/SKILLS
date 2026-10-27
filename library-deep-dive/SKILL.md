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
4. **Check the changelog / release notes** for the installed version and newer versions. What features were added that the project may not know about? Are they behind on a major version?
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

A deep-dive is DONE only when ALL FOUR of these hold — the 2026-10-24 run
shipped the report and missed the rest, and each gap cost a same-day closeout:

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
      is the run trace.
