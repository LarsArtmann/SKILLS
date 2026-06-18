# Research Methodology

The detailed discovery and research framework for the library deep dive. This file
expands on the phases defined in [../SKILL.md](../SKILL.md) with concrete checklists,
tool sequencing, and search strategies.

## Table of Contents

- [Phase 1: Project Discovery Checklists](#phase-1-project-discovery-checklists)
  - [Per-Language Dependency Files](#per-language-dependency-files)
  - [Usage Surface Mapping](#usage-surface-mapping)
  - [Spotting Duplication](#spotting-duplication)
- [Phase 2: Capability Research Framework](#phase-2-capability-research-framework)
  - [Tool Sequencing](#tool-sequencing)
  - [Search Strategy](#search-strategy)
  - [Capability Categories Expanded](#capability-categories-expanded)
  - [Version & Changelog Investigation](#version--changelog-investigation)
- [Phase 3: Gap Analysis Grading Rubric](#phase-3-gap-analysis-grading-rubric)
- [Phase 4: Scoring Model](#phase-4-scoring-model)

---

## Phase 1: Project Discovery Checklists

### Per-Language Dependency Files

Find the library declaration and exact version.

| Language / Ecosystem    | Dependency File(s)                                          | Version Lock File                                  |
| ----------------------- | ----------------------------------------------------------- | -------------------------------------------------- |
| JavaScript / TypeScript | `package.json`                                              | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` |
| Go                      | `go.mod`                                                    | `go.sum`                                           |
| Python                  | `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile` | `poetry.lock`, `Pipfile.lock`                      |
| Rust                    | `Cargo.toml`                                                | `Cargo.lock`                                       |
| Ruby                    | `Gemfile`                                                   | `Gemfile.lock`                                     |
| Java / Kotlin           | `pom.xml`, `build.gradle`, `build.gradle.kts`               | —                                                  |
| PHP                     | `composer.json`                                             | `composer.lock`                                    |
| Swift                   | `Package.swift`                                             | `Package.resolved`                                 |
| Elixir                  | `mix.exs`                                                   | `mix.lock`                                         |
| .NET                    | `*.csproj`, `*.fsproj`                                      | `packages.lock.json`                               |

**Always read the lock file** for the exact resolved version — the declared version in
the manifest may be a range (`^4.2.0`) while the lock file pins the exact installed
version. The exact version determines what features are available.

### Usage Surface Mapping

After finding where the library lives, map exactly how it is used:

1. **Import search** — `grep`/`rg` for every import/require/use statement referencing
   the library. Record the file path for each.
2. **API call inventory** — for each import, trace which exported symbols are actually
   called. Many projects import a module but only use a fraction of its exports.
3. **Configuration audit** — find where the library is initialized/configured. Read
   every option that is explicitly set. List options that are left at defaults — these
   are often the highest-leverage missed opportunities (e.g., connection pooling,
   caching, retry policies, debug modes).
4. **Wrapper / adapter detection** — does the project wrap the library in its own
   abstraction? Read the wrapper fully. Wrappers often reveal that the team only
   exposed a subset of the library's capabilities.
5. **Decorator / middleware / plugin search** — search for any extension points the
   project registers with the library. Missing these is a common gap.

### Spotting Duplication

The most valuable findings are often hand-rolled code that duplicates built-in
library functionality. Look for:

- **Manual validation** near a library that provides schema validation
- **Custom serialization** when the library has built-in (de)serialization
- **Hand-rolled retries / caching / rate limiting** when the library offers these
- **Custom error types** that mirror the library's error model
- **Reimplemented utilities** (formatting, parsing, date math) the library exports
- **Duplicate type definitions** that mirror types the library already exports

Search broadly around import sites — duplication is often in adjacent files, not the
same file as the import.

---

## Phase 2: Capability Research Framework

The depth of this phase determines the quality of the entire report. Never rely on
training data alone — library APIs evolve fast and training data is a stale snapshot.
Use live research tools systematically.

### Tool Sequencing

Research in this order to maximize coverage and minimize redundant work:

1. **Context7 — resolve the library** (`mcp_context7_resolve-library-id`)
   - Pass the exact library name and a query describing the research goal.
   - Select the result with the best reputation and snippet count.
   - This gives you a canonical library ID for targeted doc queries.

2. **Context7 — query core capabilities** (`mcp_context7_query-docs`)
   - Query: "full API surface, all configuration options, and advanced features"
   - Query: "best practices, recommended patterns, and common pitfalls"
   - Query: "performance optimization, caching, batching, and streaming features"
   - Three targeted queries cover configuration, patterns, and performance.

3. **agentic_fetch — official documentation** for topics Context7 doesn't cover:
   - Configuration reference pages (every option documented)
   - Middleware / hooks / plugins / lifecycle events
   - Migration guides (what changed between versions)
   - API reference for specific advanced features

4. **agentic_fetch — community knowledge**:
   - "advanced <library> tips and tricks <year>"
   - "<library> features you're not using"
   - "common mistakes with <library>"
   - "<library> performance best practices"
   - GitHub issues/discussions tagged "best-practice" or "question"

5. **agentic_fetch — changelog / release notes**:
   - Fetch the library's `CHANGELOG.md` or releases page
   - Compare installed version to latest stable
   - Identify features added since the installed version

### Search Strategy

When researching, think in **layers** — start broad, then go deep on high-value areas:

**Layer 1 — Breadth:** What does this library do? Enumerate every major feature area.
Goal: build a complete table of contents of capabilities.

**Layer 2 — Depth:** For each feature area, what are the specific APIs, options, and
patterns? Goal: enough detail to write a code example for each.

**Layer 3 — Wisdom:** What do experienced users recommend? What are the footguns?
Goal: distinguish "Fully Leveraged" from "Partially Used" and catch anti-patterns.

**Layer 4 — Currency:** What's new since the installed version? Goal: version
currency assessment and "features you're missing by not upgrading."

### Capability Categories Expanded

For every library, systematically check these categories. Not all apply to every
library, but checking each one ensures nothing is missed.

#### Core API Surface

- Every public/exported function, class, method, and constant
- Alternative entry points (many libraries have a "simple" and "advanced" API)
- Fluent/builder APIs that enable richer configuration
- Sub-modules and sub-packages that may be under-imported

#### Configuration & Options

- Every constructor/factory option and its default value
- Global configuration / environment variables
- Runtime reconfiguration options
- Feature flags or opt-in experimental features

#### Middleware / Hooks / Plugins / Lifecycle

- Pre/post hooks on operations
- Middleware chains or interceptors
- Plugin systems and registered extensions
- Event emitters / observers / subscribers
- Custom serializers, formatters, or validators that can be registered

#### Advanced / Lesser-Known Features

- Features documented but not in the "getting started" guide
- Power-user APIs (batch, bulk, streaming, async iterators)
- Code generation / CLI tooling shipped with the library
- Schema/type inference and derivation features
- Composition patterns (merging, extending, transforming existing instances)

#### Performance

- Connection pooling / resource management
- Caching layers (built-in or configurable)
- Batching / bulk operations
- Streaming / lazy evaluation / generators
- Worker pools / concurrency primitives
- Memory management options (limits, eviction, compression)

#### Type Safety & Developer Experience

- Type inference and generic type parameters
- Schema → type derivation
- Template literal types / branded types
- Autocomplete enhancements (e.g., `as const` patterns)
- Strict mode options

#### Testing Utilities

- Built-in test helpers, mocks, fakes, stubs
- In-memory or test-mode adapters
- Fixture builders and factories
- Snapshot / assertion utilities

#### Error Handling

- Structured error types and error codes
- Error recovery and retry options
- Error transformation / mapping utilities
- Validation error aggregation

#### Observability

- Logging integration (structured logs, log levels)
- Metrics / telemetry hooks
- Distributed tracing support
- Debug / verbose modes
- Health check endpoints

### Version & Changelog Investigation

Version currency is a first-class finding. A project may be "fully leveraging" the
library as it existed two years ago, but missing everything added since.

1. **Record installed version** from the lock file.
2. **Find latest stable version** via the package registry, GitHub releases, or docs.
3. **Read the changelog** from installed version → latest.
4. **Categorize what's in the gap:**
   - New features (missed by not upgrading)
   - Bug fixes (possible latent bugs)
   - Breaking changes (upgrade effort estimation)
   - Deprecations (current usage may be on borrowed time)
5. **Assess upgrade risk:** Is it a major version bump? Are there migrations?

---

## Phase 3: Gap Analysis Grading Rubric

Apply this rubric to every capability discovered in Phase 2.

### Fully Leveraged 🟢

Criteria (all must hold):

- The feature is used in the project
- It is used in the recommended / idiomatic way
- No significantly better built-in alternative exists
- Configuration is appropriate (not left at a suboptimal default)

These don't need action items, but documenting them gives the team confidence and
shows the audit was thorough.

### Partially Used 🟡

Criteria (any one):

- The feature is used but via a weaker API when a stronger one exists
  (e.g., basic query when a builder/advanced query API is available)
- Configuration is present but a high-value option is left at default
- The feature is used in some places but not others where it would help
- A utility function is reimplemented using lower-level library primitives

These are the **highest-ROI findings** — the project already invested in the library,
so adopting the better path is low-effort and high-impact.

### Missed Opportunity 🔴

Criteria (all must hold):

- The feature is not used anywhere in the project
- It would clearly benefit the project (solve a real problem that exists)
- It is not "Not Applicable" (see below)

Each missed opportunity must articulate the **specific problem it solves** in this
project, with evidence (where in the codebase the problem manifests). Vague "you
could use this feature" findings without project context are low quality — reject them.

### Misused / Anti-Pattern ⚠️

Criteria (any one):

- The library is used in a way the docs or community explicitly warn against
- A deprecated API is in use
- The usage pattern causes a known performance problem or correctness issue
- The library is configured in a way that defeats its purpose
  (e.g., disabling connection pooling, setting cache to 0)

These are **urgent** — they represent active harm, not just missed value. Flag them
prominently in the report.

### Not Applicable ⚪

Criteria (all must hold):

- The feature exists in the library
- It genuinely does not apply to this project's use case or architecture

Exclude from scoring. Document briefly so the reader knows it was considered, not
missed. Example: a CLI library's interactive prompt features, when the project only
builds non-interactive tools.

---

## Phase 4: Scoring Model

### Adoption Score (0–100)

Weight findings by impact, not count. A library with 50 convenience helpers that go
unused should not score worse than one where a single critical performance feature
is missed.

Suggested weighting:

| Component                                           | Weight | Rationale                                |
| --------------------------------------------------- | ------ | ---------------------------------------- |
| Critical features (core API, performance, security) | 40%    | These matter most                        |
| Advanced features (high-value missed opportunities) | 25%    | Differentiates "using" from "leveraging" |
| Configuration optimization                          | 15%    | Defaults are often suboptimal            |
| Best-practice adherence (no anti-patterns)          | 10%    | Correctness check                        |
| Version currency                                    | 10%    | Stale = missing everything new           |

Score each component as a percentage (leveraged / applicable), then apply weights.

### Interpretation

| Score  | Meaning                                                                |
| ------ | ---------------------------------------------------------------------- |
| 90–100 | **Maximized** — extracting nearly all value; minor tuning only         |
| 75–89  | **Strong** — solid adoption with a few high-value gaps                 |
| 60–74  | **Moderate** — using the basics well but missing significant value     |
| 40–59  | **Surface-level** — barely scratching the surface; major opportunities |
| 0–39   | **Token adoption** — the library is present but almost entirely unused |

### Top Opportunities Ranking

Rank all actionable findings (Partially Used + Missed Opportunity + Misused) by:

**Priority = Impact × Ease**

- **Impact** (1–5): How much value does adopting this deliver? (performance gain, code
  reduction, correctness improvement, DX enhancement)
- **Ease** (1–5): How easy is it to adopt? (drop-in config change = 5, major refactor = 1)

Present the top 10–15 as a prioritized action list in the report.
