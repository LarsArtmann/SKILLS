# First-Party Capability Map

> Navigation aid, not truth. The `meta` inventory is the source of truth for
> what EXISTS; this map tells you what each entry IS FOR and which skill owns
> deep integration. Entries verified against each repo's README on 2026-10-27
> (re-verified the same evening via `scripts/capability-map-diff.sh`: 15 new
> rows from the meta diff, 0 stale rows found).
> Re-verify with `meta get --project <name>` + a README skim before committing
> a STACK.md choice — repos move.

## How to use this map

1. Match the project profile's needs to a category below.
2. For each candidate: run `meta get --project <name>`, skim the repo README,
   and check adoption evidence (`meta list --tags <name>` — projects that
   depend on it often carry it as a tag).
3. Apply the "when not" column — pulling in a high-importance lib you don't
   need is the failure mode this map exists to prevent.

## Legend

- **Skill** = a skill that owns deep integration for this lib. Load it when
  the lib is selected. "—" = no owning skill; README + pkg.go.dev are the docs.
  NOTE: some owning skills live OUTSIDE the SKILLS repo as one-offs
  (cmdguard, go-cqrs-lite, cqrs-htmx, go-aichat, templ-components,
  typesafe-ai — per the SKILLS repo's AGENTS §5.10). If the named skill is
  not found in the skills directory, use the lib's README + docs; the map
  row is not wrong. (Found by eval 2026-10-27: cqrs-htmx.)
- Importance values drift; the ones shown are from 2026-10-27.

## Domain types & invariants

| Lib                               | What it is                                                                         | Skill | When NOT to use                                                      |
| --------------------------------- | ---------------------------------------------------------------------------------- | ----- | -------------------------------------------------------------------- |
| go-composable-business-types (96) | DataPoint[T] with audit trail, bitemporal tracking, Money/Email/Bounded primitives | —     | Trivial scripts with no business semantics                           |
| go-branded-id (63)                | Branded/phantom IDs: `ID[Brand, V]`, compile-time ID-mixing prevention             | —     | Throwaway prototypes (but cost of adoption is near zero)             |
| go-business-rules (80)            | Severity-aware validation rule engine                                              | —     | Pure struct validation → `sivchari/govalid` (codegen, how-to-golang) |
| go-error-family (55)              | Structured error protocol: classification, exit codes, diagnostics                 | —     | Simple wrapped errors; stdlib `fmt.Errorf("%w")` suffices            |
| go-must (63)                      | Panic-on-error helpers for init code and tests                                     | —     | Library code where panics are banned                                 |
| go-policy-dsl (63)                | Compile-time-checked DSL declaring library governance (bans/requirements)          | —     | Governing third-party deps → `library-policy` instead                |

## CLI applications

| Lib                | What it is                                                                                             | Skill      | When NOT to use                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------------ | ---------- | ------------------------------------------------------------------------------------ |
| cmdguard (92)      | Cobra wrapper: typed struct-tag flags, per-command flag structs, DI, config files, exit-code contracts | `cmdguard` | Prototypes where flag structure is still fluid; raw stdlib `flag` for zero-dep tools |
| go-output (90)     | Write data once, render as table/JSON/CSV/Markdown/YAML/HTML/DOT/Mermaid                               | —          | Single fixed output format that `fmt` handles in 3 lines                             |
| go-wizard-sdk (52) | Type-safe multi-step wizards for CLI/TUI                                                               | —          | Single-prompt interactions                                                           |
| gogenfilter (90)   | Detect and filter auto-generated Go code, table-driven, zero-config                                    | —          | Projects with no generated code                                                      |
| go-commit (95)     | AI-generated commit messages from staged diff                                                          | —          | Repos with commit-message compliance rules that AI output breaks                     |
| go-retry (63)      | Dependency-light retry/backoff built for CLIs and batch jobs                                           | —          | Circuit-breaking service meshes (failsafe-go-class needs)                            |
| smart-configs (63) | Intelligent configuration management with actionable error messages                                    | —          | cmdguard-owned config files (it embeds its own)                                      |

## Services, HTTP & realtime

| Lib                      | What it is                                                               | Skill | When NOT to use                                                  |
| ------------------------ | ------------------------------------------------------------------------ | ----- | ---------------------------------------------------------------- |
| go-appkit (63)           | Production-ready HTTP service framework; composes httputil, samber/do    | —     | Single-endpoint utilities; plain `net/http` mux is less ceremony |
| httputil (55)            | Composable middleware, CORS, client-IP, server lifecycle helpers         | —     | Already inside go-appkit (it composes this)                      |
| go-sse (63)              | SSE transport: wire format, connection mgmt, fan-out, reconnection       | —     | Inside go-aichat (ssehub) or cqrs-htmx, which own their SSE      |
| go-datastar (63)         | DataStar protocol: every patch a first-class value producing `sse.Event` | —     | Same as go-sse — check what your framework already embeds        |
| go-etag (63)             | Two-sided RFC 7232 ETags: server middleware + client answering           | —     | Non-cacheable, mutation-only APIs                                |
| go-idempotency (63)      | Turns at-least-once delivery into at-most-once processing                | —     | Pure reads; inherently idempotent handlers                       |
| go-health (63)           | Kubernetes health-probe SDK for samber/do v2 containers                  | —     | Non-service CLIs                                                 |
| go-health-dashboard (63) | Live health status page for go-health via Datastar SSE, one mux call     | —     | No go-health                                                     |
| go-daemon (74)           | Building blocks for long-lived daemons over unix domain sockets          | —     | Request-scoped HTTP services                                     |

## Server-rendered UI

| Lib                   | What it is                                                                                                                                 | Skill              | When NOT to use                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------------------ | ------------------------------------------------------ |
| templ-components (70) | templ + HTMX + Tailwind v4 component library                                                                                               | `templ-components` | SPA requirements — this stack is server-rendered       |
| cqrs-htmx (63)        | CQRS + event-sourcing wired to HTTP/HTMX, one declarative line per endpoint; usermgmt (WebAuthn/OAuth2/TOTP) + admin UI; SSE-only since v5 | `cqrs-htmx`        | Static sites (no commands/events); JSON APIs (no HTMX) |

## Event sourcing, CQRS & workflows

| Lib                       | What it is                                                                                                                                 | Skill          | When NOT to use                                         |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------------- | ------------------------------------------------------- |
| go-cqrs-lite (70)         | CQRS + event sourcing; NEW apps must use the `system` composition root + metaengine cost-based planner                                     | `go-cqrs-lite` | CRUD without invariants/event history — sqlc is simpler |
| universal-workflow (92)   | Workflow orchestration with dependency resolution, parallel execution, event-driven                                                        | —              | Linear request handling                                 |
| go-taskqueue (63)         | Projects-aware task work queue / self-managing worker pool                                                                                 | —              | Single-shot goroutines; errgroup covers simple fan-out  |
| go-dag-app (63)           | Shared DI-container bootstrap for DAG applications                                                                                         | —              | Non-DAG services                                        |
| go-codec (63)             | Encoding/decoding for event-sourced payloads (Codec interface for stores/snapshots)                                                        | —              | Non-event-sourced serialization (→ `encoding/json/v2`)  |
| go-ndjson (63)            | Parse newline-delimited JSON into typed slices, per-line validation                                                                        | —              | One-shot document JSON                                  |
| go-workflow-auditlog (55) | Audit logging for Azure/go-workflow: every step event (attempts, retries, durations, errors) + JSON/NDJSON export; optional viz dashboards | —              | Non-go-workflow pipelines                               |

## AI features

| Lib               | What it is                                                                                                                               | Skill       | When NOT to use                                                  |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------------------------------------------- |
| go-aichat         | AI-chat building blocks: streaming client + breaker + context window + SSE hub + persona + turn orchestration + event-sourced chat store | `go-aichat` | Single non-chat LLM calls — a plain HTTP client is lighter       |
| go-graph-rag (58) | Semantic retrieval primitives: embedding providers, typed knowledge graph, SQLite vector+graph store, hybrid retrieval                   | —           | Plain keyword search; single-shot embeddings without graph needs |

## Files, IO & sync

| Lib                        | What it is                                                                                                         | Skill | When NOT to use                                    |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------ | ----- | -------------------------------------------------- |
| go-atomic-write (63)       | Crash-safe, race-free file writes                                                                                  | —     | Ephemeral temp files                               |
| go-sqlitestore (58)        | Shared SQLite engine core for the fleet: DSN+PRAGMAs, WAL, versioned membership migrations, busy-retry             | —     | Postgres-scale needs (metaengine Postgres engines) |
| go-credentials-store (58)  | Event-sourced, encrypted-at-rest credentials store (API keys, Playwright sessions, passwords) with lifecycle audit | —     | App-level auth (cqrs-htmx usermgmt owns that)      |
| go-filewatcher (90)        | High-performance composable filesystem watcher                                                                     | —     | One-shot reads                                     |
| go-localsync (60)          | Local-first mirror of any paginated REST API (SQLite-backed)                                                       | —     | Real-time requirements (it's pull-based)           |
| segment-buffer (55)        | High-throughput local buffer for cloud sync, durability-configurable                                               | —     | Direct streaming without buffering needs           |
| project-discovery-sdk (87) | Reactive SDK for discovering software projects across directories, language detection                              | —     | Single fixed-path tools                            |

## Static analysis & linting

| Lib                            | What it is                                                                                              | Skill                    | When NOT to use                                |
| ------------------------------ | ------------------------------------------------------------------------------------------------------- | ------------------------ | ---------------------------------------------- |
| go-finding (65)                | Unified finding data model + pipeline for static analysis tools                                         | `linter-building`        | One-off ad-hoc checks                          |
| go-linter-sdk (65)             | Build linters that plug into go-finding                                                                 | `linter-building`        | Non-linter projects                            |
| go-checker-helpers (55)        | Checker-module helpers: finding construction, direct-fix pipeline                                       | —                        | —                                              |
| linter-autoconfigure-sdk (63)  | Shared foundation for linter auto-configuration tools                                                   | `linter-building`        | —                                              |
| erraudit (90)                  | `errors.As`/`Is` → `errors.AsType` modernization linter                                                 | `go-error-modernization` | Non-Go-1.26 codebases                          |
| go-hotspot (58)                | Ranks files by complexity × git churn (CodeScene methodology), offline                                  | —                        | One-off scripts with no history                |
| code-duplicate-analyzer (55)   | AST-based duplicate-code scanner across projects, suggests shared-lib extraction                        | `deduplicate-code`       | —                                              |
| go-humanize-linter (55)        | Lints for human-readable output conventions                                                             | `linter-building`        | —                                              |
| go-auto-upgrade (90)           | Automatic Go migrations: import rewrites, API modernization, redundant-wrapper detection (11 migrators) | —                        | Hand-curated one-off refactors                 |
| go-version-auto-configure (58) | One policy for the Go toolchain version surface, auto-fixed, BuildFlow-wired                            | —                        | —                                              |
| library-policy (55)            | Stop banned/vulnerable/deprecated libs from reaching production                                         | —                        | —                                              |
| md-go-validator (82)           | Markdown static analysis/validation                                                                     | —                        | —                                              |
| go-structure-linter (55)       | Validates Go project structure against best practices                                                   | —                        | Docs-only repos (this repo skips it by design) |
| art-dupl (68)                  | Semantic code duplication detection                                                                     | `deduplicate-code`       | —                                              |

## Tooling, build & templates

| Tool / template              | What it is                                                                           | Skill                  | When NOT to use                                            |
| ---------------------------- | ------------------------------------------------------------------------------------ | ---------------------- | ---------------------------------------------------------- |
| buildflow (95)               | Build-automation + quality pipeline for covered projects                             | `buildflow`            | This repo (docs-only, excluded by design)                  |
| go-nix-helpers (63)          | flake-parts module: Go packaging, devshells, formatting, CI                          | `nix-private-go-repos` | Non-nix environments                                       |
| template-sqlc (65)           | Copy-and-customize sqlc project template                                             | —                      | Non-Postgres                                               |
| template-github-actions (70) | Copy-and-customize GitHub Actions workflows                                          | —                      | —                                                          |
| template-air (68)            | Interactive air (hot-reload) config generator                                        | —                      | —                                                          |
| templates (55)               | Template management/orchestration system                                             | —                      | —                                                          |
| go-website-template (55)     | Go+Templ+HTMX on Cloud Run — the dynamic product-site pattern (i18n, contact, legal) | `website-launch`       | Static docs sites — the website-launch SSG pattern instead |

## External integrations

| Lib                                                                                       | What it is                                                                 | Skill | When NOT to use                                             |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ----- | ----------------------------------------------------------- |
| go-github-kit (75)                                                                        | Operational kernel over google/go-github: auth, rate limits, retries       | —     | One unauthenticated GitHub call                             |
| go-crush-data (71)                                                                        | Typed read-only access to Crush session data                               | —     | —                                                           |
| wise-go (63)                                                                              | Wise API client: transfers, balances, multi-currency accounts              | —     | —                                                           |
| go-paperless (58)                                                                         | Paperless-ngx REST client SDK (documents, tags, correspondents)            | —     | Non-paperless document stores                               |
| typespec-go (63), typespec-asyncapi (60), typespec-sqlc (40), typespec-eventsourcing (30) | TypeSpec emitters: Go types, AsyncAPI 3.1, sqlc config, event-sourced apps | —     | API-first only — skip when there's no spec to generate from |

## Observability

| Lib                          | What it is                                                                                  | Skill                      | When NOT to use  |
| ---------------------------- | ------------------------------------------------------------------------------------------- | -------------------------- | ---------------- |
| go-flightrecorder (63)       | Production-safe wrapper for Go 1.25 `runtime/trace.FlightRecorder` with composable triggers | —                          | Short-lived CLIs |
| tracing-flight-recorder (55) | In-memory ring-buffer flight recorder for tracing events                                    | —                          | —                |
| samber-do-auditlog (55)      | Audit hooks for samber/do registration, invocation, shutdown                                | `samber-do-best-practices` | No samber/do DI  |

## Known map gaps

These exist in `meta` but are NOT mapped above — evaluate by hand if a
profile plausibly touches them (this list itself drifts; re-derive via
`scripts/capability-map-diff.sh`):

- Apps, not libs (never BUILD-ON these): `timesheets`, `invoices`, `bank-sync`,
  `cyberdom`, `stoptube`, `ai-router-implementation`, `wise-transaction-visualization`.
- Infrastructure/config, not importable libs: `systemnix`, `private-cloud`,
  `pbx-artmann`, websites (`lars.software`, `artmann-holding`, `blog`).
- Early/missing repos — `actaflow` (importance 63 but NOT ON DISK as of
  2026-10-27): importance is aspiration, not maturity. ALWAYS verify the repo
  has a README + go.mod before selecting.
- Placeholder/untracked experiments: `berrybig` (8), `darknet-monitor`,
  `media-atlas`, `go-plugin-mvp` (41), `plugmarket` (41), `buildflow-pr44`
  (importance 95 but no README/go.mod — a worktree artifact, not a project).
- `template-*` ceremony family (arch-lint, authors, changelog, cli,
  code-of-conduct, codeowners, commit-hooks, contributing, graphs, readme):
  repo-scaffolding material, not importable foundations. Exception: the
  mapped rows template-sqlc / template-github-actions / template-air.
  (`template-cli` = the zero-consumer SDK rejected 2026-10-11.)
- `collector-utils` (70): shared plumbing for the Rust collector family
  (collector-extraction skill), no go.mod — not a Go foundation.
- Script note: combined rows (e.g. the typespec-* line) are invisible to
  the diff script's row extraction — the script lists them as unmapped;
  they are mapped. Read the table before adding a "duplicate" row.
