# Eval 2 — with-skill: "event-sourced web app for consulting invoices, server-rendered UI + login"

**Date:** 2026-10-27 | **Condition:** with stack-selection skill (subagent instructed to view SKILL.md and follow it; `meta` CLI unavailable to subagent → adapted to `.config/metadata.yaml` + capability-map + go.mod greps, adaptations self-reported) | **Config:** agent sub-agent (read-only tools)

## RAW SUBAGENT OUTPUT (verbatim)

All phases executed. Report:

---

# Stack-Selection Report — event-sourced consulting-invoice web app

## 1. REFERENCES LOADED

| File | Phase |
|---|---|
| `/home/lars/projects/SKILLS/stack-selection/SKILL.md` | procedure |
| `/home/lars/projects/SKILLS/stack-selection/references/capability-map.md` | Phase 2 |
| `/home/lars/projects/SKILLS/stack-selection/assets/STACK-template.md` | Phase 5 |
| `/home/lars/projects/SKILLS/how-to-golang/SKILL.md` | Phase 3 (third-party policy) |
| `/home/lars/projects/go-cqrs-lite/SKILL.md` | owning-skill evidence (ADR-0123: `system` + `metaengine` mandatory for new apps) |
| READMEs: `cqrs-htmx`, `go-cqrs-lite`, `templ-components`, `go-composable-business-types`, `go-branded-id` | Phase 1 existence checks |

**Tool adaptations (honesty):** `meta` CLI unavailable → read each project's `.config/metadata.yaml` directly (its data source). `glob` skips hidden dirs → metadata files were viewed by known path, not discovered. `git describe --tags` not runnable → tag evidence adapted to semver-pinned requires in consumers' `go.mod` + release badges in READMEs. `grep` caps at 100 matches → counts reported as "≥N (cap hit)". `meta set` registration (Phase 6) cannot be executed — listed as a manual step.

## 2. INVENTORY EVIDENCE

Importance from `.config/metadata.yaml`; "verified" = non-empty README + `go.mod` seen via ls/view.

| Project | Importance | Tags (condensed) | Verified on disk | Adoption (grep `larsartmann/<name>` across `~/projects/*/go.mod`) |
|---|---|---|---|---|
| cqrs-htmx | 63 | lib | **y** (README v4 release badge, `go.mod`, `usermgmt/`, `loginpage/`, `adminui/`, `setup/`) | strong: crm, webphone, crush-daily, journal, dnsblockd, plugmarket, GmbH, crm-stage-cliwave… (100-match cap hit incl. intra-repo) |
| go-cqrs-lite | 70 | go, cqrs, event-sourcing, ddd, lib | **y** (README, `go.mod`, `SKILL.md`) | strongest in ecosystem: CV, crush-daily, journal, pbx-lens, cqrs-htmx… (100-match cap hit) |
| templ-components | 70 | lib | **y** (README v1.24.0, `go.mod`, `skill/`) | strong: CV, crush-daily, journal, pbx-lens, crm, webphone, dnsblockd, GmbH, media-atlas… (100-match cap hit) |
| go-composable-business-types | 96 | go, types, business, money, lib | **y** (README, `go.mod`, `money/`) | ~20 consumers incl. journal, bank-sync (both use `/money`), project-meta, project-discovery-sdk |
| go-branded-id | 63 | lib | **y** (README, `go.mod`) | very wide: CV, journal, webphone, Cyberdom, StopTube, Standup-Killer, InboxClean… (100-match cap hit) |
| go-business-rules | 80 | go, validation, lib | y (README, `go.mod`) | **0 consumers — no `go.mod` anywhere imports it** |
| go-appkit | 63 | lib | (not deeply checked — rejected on fit) | via health modules only |
| cmdguard | 92 | cli, cobra, lib | (rejected on fit) | 27 per SKILL.md (timesheets tags it — only tag-based signal that exists) |
| go-output | 90 | cli, output, lib | (rejected on fit) | 43 per SKILL.md |
| BuildFlow | 95 | tooling, quality-gate | **y** (`.buildflow.yml` present in cqrs-htmx, templ-components, go-branded-id, go-business-rules) | pipeline adopted across lib repos |
| invoices | 90 | invoices, gobl, ksef, vat, consulting | y (dir exists; app, not lib) | n/a — app |
| timesheets | 91 | pdf, timesheet, cmdguard | y (app, not lib) | n/a — app |
| universal-workflow | 92 | workflow-orchestration, lib | y | not checked — rejected on fit |
| wise-go / go-aichat / go-daemon(74) / go-taskqueue / go-sse / go-datastar / go-codec / go-etag / go-idempotency / go-commit(95) / erraudit(90) / gogenfilter(90) / go-filewatcher(90) / samber-do-auditlog / ActaFlow(63) | 55–95 | lib | metadata viewed; dirs present | rejected on fit/YAGNI (see §5) |

## 3. CAPABILITY MATCH

| Concern | Candidates (map §) | Decision |
|---|---|---|
| Event sourcing/CQRS | **go-cqrs-lite** (70, skill `go-cqrs-lite`), universal-workflow (92), go-taskqueue, ActaFlow, typespec-eventsourcing (30) | **BUILD-ON go-cqrs-lite** — exact profile need, top adoption, verified; its SKILL.md mandates `system.New` + `metaengine` for new apps. Rejected: universal-workflow (linear request handling here), taskqueue (system owns timers/scheduling), ActaFlow (unverified maturity, no need), typespec (no API spec). |
| Web/UI (server-rendered + HTMX) | **cqrs-htmx** (63, skill `cqrs-htmx`), **templ-components** (70, skill `templ-components`), go-appkit (63) | **BUILD-ON both** — cqrs-htmx wires CQRS→HTTP/HTMX declaratively and is the GOTH-stack pair of templ-components (each README cross-links). Rejected: go-appkit (generic service framework; cqrs-htmx already owns routing/middleware/SSE — double foundation). |
| Auth/login | cqrs-htmx `usermgmt` (WebAuthn/passkeys, OAuth2, TOTP) + `loginpage` + Casbin authz | **BUILD-ON cqrs-htmx usermgmt** — satisfies how-to-golang "never roll your own auth"; verified on disk (`usermgmt/`, `loginpage/`) and in consumers (crm, webphone, crm-stage-cliwave, plugmarket-demo). |
| Money types | **go-composable-business-types** (96: `Money`, `Cents`, `BoundedString`, `Email`) | **BUILD-ON** — invoices are money; `/money` submodule already proven in journal + bank-sync. |
| Domain IDs | **go-branded-id** (63), oklog/ulid | **BUILD-ON go-branded-id** (how-to-golang: domain entity IDs → branded `ID[Brand,V]`); ulid only if an external system mandates it. |
| Validation | go-business-rules (80), sivchari/govalid (how-to-golang) | **govalid** (codegen, zero-alloc; policy answer) at the HTTP edge; domain invariants live in the go-cqrs-lite decider. Rejected: go-business-rules — importance 80 but **zero adoption** (skill: adoption beats importance; unverifiable-in-practice lib is an exclusion row). |
| Persistence (event store) | metaengine sqliteengine (first-party), Postgres engines, gorm/sqlc | **metaengine sqlite (SQLite event store)** — single-user app; sqliteengine proven in CV, journal, pbx-lens `go.mod`. gorm banned; sqlc unneeded (no hand-written SQL layer — ADR-0142: all I/O via metaengine). |
| CLI | cmdguard (92) | **SKIP** — server-rendered app; a serve command is `flag`-level. Revisit if an admin/CLI surface emerges. |
| Quality pipeline | BuildFlow (95, skill `buildflow`) | **BUILD-ON** as tooling (not an import dep) — standard gate across the ecosystem's own repos. |

## 4. CHOSEN FOUNDATION

**Core: cqrs-htmx v4 (HTTP+HTMX+auth+admin) over go-cqrs-lite `system`+`metaengine` (event store), rendered with templ-components v1.24 + templ, domain types from go-composable-business-types (Money) + go-branded-id, SQLite via metaengine/sqliteengine; BuildFlow gate.**

Owning skills the skill says to load next (Phase 6): **`go-cqrs-lite`** (`/home/lars/projects/go-cqrs-lite/SKILL.md` — `system.New` + `metaengine.Store`/`Query[Q,R]`, `systemscenario` testing) and **`templ-components`** (`/home/lars/projects/templ-components/skill/SKILL.md`), plus **`buildflow`**; nix packaging → **`go-nix-helpers`** + **`nix-private-go-repos`** (go-cqrs-lite is Proprietary-licensed → private deps confirmed). **Map drift found:** the capability-map names a `cqrs-htmx` skill, but no `SKILL.md` exists in `/home/lars/projects/cqrs-htmx/` or in SKILLS — use its README/`docs/goth-stack.md` + `setup/` module instead.

## 5. DELIBERATELY EXCLUDED

| Lib | Importance | Why excluded |
|---|---|---|
| invoices | 90 | App, not a lib (map "known gaps") — never BUILD-ON; keep as domain reference for gobl/KSeF/VAT and possible future integration. |
| timesheets | 91 | App, not a lib; feeds invoices via data, not imports. |
| cmdguard | 92 | No CLI concern in profile (YAGNI); revisit when an admin CLI appears. |
| go-output | 90 | Terminal/table rendering — web app renders HTML via templ; no multi-format stdout need. |
| universal-workflow | 92 | Request handling here is linear command→event→projection; no DAG orchestration. |
| go-commit | 95 | Personal dev tooling, not a foundation dependency. |
| erraudit | 90 | Modernization linter for existing codebases; nothing to migrate at inception. |
| go-filewatcher | 90 | No filesystem-watching need. |
| gogenfilter | 90 | Generated-code filtering not needed as a dependency. |
| go-business-rules | 80 | Zero adoption across all `go.mod`s; invariants belong in the decider + govalid. |
| go-appkit | 63 | cqrs-htmx already owns HTTP wiring/middleware/SSE — would be a second, competing framework. |
| go-daemon | 74 | Request-scoped HTTP service, not a unix-socket daemon. |
| wise-go | 63 | YAGNI — no payout requirement stated; revisit when invoices should trigger transfers. |
| go-aichat | 58 | No AI/chat feature in profile. |
| go-sse, go-datastar, go-codec, httputil, go-etag, go-idempotency, go-error-family | 55–63 | Real but transitive — already required by `cqrs-htmx/go.mod`; importing directly duplicates the framework's owned layers (map "when NOT"). |
| go-taskqueue / go-health(-dashboard) / samber-do-auditlog | 55–63 | Covered by `system` composition root / `cqrs-htmx/health`; no samber/do DI mandated. |
| template-sqlc | 65 | No sqlc layer — persistence is the metaengine event store. |
| typespec-eventsourcing (and siblings) | 30–63 | API-first generators; no TypeSpec spec exists. |
| ActaFlow | 63 | Map flags it as not-on-disk/unmature; no workflow need regardless — revisit never triggered. |

## 6. STACK.md

```markdown
# STACK — consulting-invoices (working name)

> The deliberate foundation of this project: every significant dependency was
> chosen, not accumulated. Generated 2026-10-27 by the stack-selection skill
> (profile: event-sourced server-rendered Go web app). LIVING document — update
> the row when the reason changes, delete the row when the dependency goes.

## Profile

| Axis          | Answer |
| ------------- | ------ |
| Shape         | Server-rendered web app (HTTP service + UI) |
| Domain        | Consulting invoice management (customers, line items, VAT, statuses, payment tracking) |
| Persistence   | Event store (SQLite via go-cqrs-lite metaengine) |
| Interfaces    | HTTP + HTMX (+ SSE), login-protected |
| Scale target  | Single user (the consultant) |
| Constraints   | Private first-party deps (larsartmann/*), nix-flake ecosystem, single binary |

## Chosen foundation

| Category              | Choice (first-party = ★)          | Why this, not that                                     | Owning skill / docs              | Revisit when                       |
| --------------------- | --------------------------------- | ------------------------------------------------------ | -------------------------------- | ---------------------------------- |
| Web/CQRS wiring + auth| ★ cqrs-htmx v4                    | event sourcing + HTMX + usermgmt (passkeys/OAuth2/TOTP) in one lib; rolling this by hand re-invents ~10 proven HandlerOptions | README + docs/goth-stack.md + setup/ (map names a `cqrs-htmx` skill; none found on disk 2026-10-27) | no-login or JSON-API pivot |
| Event sourcing core   | ★ go-cqrs-lite v4 (`system` + `metaengine` only, ADR-0123) | hand-wiring event/command/decider layers is banned by its own skill; not watermill/axon — own lib wins | `go-cqrs-lite` skill (repo SKILL.md) | v5 module removals land |
| Event store           | ★ go-cqrs-lite metaengine/sqliteengine | SQLite, not Postgres engines — single user; not gorm (banned) nor sqlc (no SQL layer, ADR-0142) | go-cqrs-lite skill | multi-user / hosted Postgres |
| UI components        | ★ templ-components v1.24 (+ a-h/templ, Tailwind v4) | GOTH-stack pair of cqrs-htmx; not React/SPA (map: server-rendered is the point) | `templ-components` skill (repo skill/SKILL.md) | SPA requirements emerge |
| Money/domain types   | ★ go-composable-business-types (Money, Cents, Email, BoundedString) | invoices are money; not float64/primitive strings (how-to-golang domain-types rule); proven in journal + bank-sync | README + pkg.go.dev | multi-currency beyond Money's model |
| Domain IDs           | ★ go-branded-id | compile-time InvoiceID/CustomerID separation; not raw strings (never) nor plain ulid (no compile-time brand) | README + branded-id.lars.software | — |
| Input validation     | sivchari/govalid | codegen, zero allocs — how-to-golang policy; not go-playground/validator (banned), not go-business-rules (zero adoption) | how-to-golang | — |
| Router               | stdlib net/http mux | cqrs-htmx is router-agnostic; not gin/chi (extra dep with no need) | how-to-golang | routing needs exceed 1.22 patterns |
| Testing              | ginkgo/v2 + gomega; systemscenario (sys-level Given/When/Then) | BDD policy; not testify (banned); systemscenario reuses the real composition root | how-to-golang + go-cqrs-lite skill | — |
| Quality pipeline     | ★ BuildFlow | ecosystem-standard gate (see .buildflow.yml in every chosen lib repo) | `buildflow` skill | — |

Rules honored: one row per real concern; every ★ verified (README + go.mod +
versioned requires: cqrs-htmx v4.14.1, templ-components v1.24.0,
go-branded-id/go-composable-business-types v0.7.0 pinned in consumers);
every "why not" names the loser.

## Deliberately excluded

| Candidate        | Reason                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| invoices (90)    | App, not a lib — domain reference/future integration only              |
| timesheets (91)  | App, not a lib                                                         |
| cmdguard (92)    | No CLI concern (YAGNI); revisit when an admin CLI emerges              |
| go-output (90)   | Terminal rendering; UI is HTML via templ                               |
| universal-workflow (92) | Linear request handling; no DAG orchestration                  |
| go-commit (95)   | Dev tooling, not foundation                                            |
| erraudit (90)    | Modernization linter; greenfield codebase                              |
| go-filewatcher (90), gogenfilter (90) | No watching/generated-code-filtering need                |
| go-business-rules (80) | Zero go.mod consumers; invariants live in decider + govalid      |
| go-appkit (63)   | cqrs-htmx owns the HTTP layer; second framework = double foundation    |
| go-daemon (74)   | Request-scoped HTTP service, not a unix-socket daemon                  |
| wise-go (63)     | YAGNI — no payout flow; revisit if invoices trigger transfers          |
| go-aichat (58)   | No AI features                                                         |
| go-sse/go-datastar/go-codec/httputil/go-etag/go-idempotency/go-error-family | Transitive via cqrs-htmx — do not import directly |
| go-taskqueue, go-health(-dashboard), samber-do-auditlog | Owned by system/cqrs-htmx-health; no samber/do mandate |
| template-sqlc (65), typespec-* (30–63) | No SQL layer / no API-first spec                         |
| ActaFlow (63)    | Unverified maturity (map: not on disk); no workflow need               |

## Wiring order

1. `go mod init`; `go get github.com/larsartmann/cqrs-htmx/v4@v4.14.1`,
   `go-cqrs-lite/system/v4` + `metaengine/sqliteengine/v4`,
   `github.com/larsartmann/templ-components@v1.24.0` (+/htmx,/icons,/errorpage),
   `go-composable-business-types@v0.7.0` (+/money), `go-branded-id@v0.7.0`,
   `sivchari/govalid`, `ginkgo/v2`+`gomega`.
2. Load the `go-cqrs-lite` skill: `system.New(ctx, DomainConfig, DeploymentConfig)` + `metaengine.Store`/`Query[Q,R]`; domain = Invoice aggregate (draft→sent→paid→overdue) with Money fields.
3. Load the `templ-components` skill for UI; cqrs-htmx `setup` + `usermgmt` + `loginpage` for login/admin (docs/goth-stack.md).
4. flake.nix via `go-nix-helpers`; private larsartmann deps → `nix-private-go-repos` skill.
5. BuildFlow quality gate — load `buildflow` skill.
6. Single module for now; `go-modularize` skill owns any future split.
7. Register in meta: `meta set --project consulting-invoices --tags go,event-sourcing,cqrs,web,htmx,invoices,consulting,app` (manual — meta unavailable in this session).

## Decision log

- 2026-10-27 — Initial selection (stack-selection skill; meta CLI unavailable, inventory read from per-project .config/metadata.yaml).
```

## 7. WIRING ORDER

1. `go mod init` + pinned `go get` (versions above — all evidenced in consumers' go.mod files).
2. **Load `go-cqrs-lite` skill** (`/home/lars/projects/go-cqrs-lite/SKILL.md`): `system.New` composition root + `metaengine` SQLite engine; test via `systemscenario`.
3. cqrs-htmx `setup`/`usermgmt`/`loginpage` for login + admin UI (no cqrs-htmx skill exists on disk — use README + `docs/goth-stack.md`).
4. **Load `templ-components` skill** (`/home/lars/projects/templ-components/skill/SKILL.md`) for the UI layer.
5. Nix: `go-nix-helpers` + `nix-private-go-repos` (Proprietary first-party deps confirmed).
6. **Load `buildflow` skill** → quality gate.
7. Register project with `meta` (manual, CLI unavailable); stay single-module, defer to `go-modularize`.
