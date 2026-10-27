# Eval 2 — WITHOUT-skill baseline: "event-sourced web app for consulting invoices, server-rendered UI + login"

**Date:** 2026-10-27 | **Condition:** no skill access (explicitly instructed: no skill files, no research into ~/projects — general knowledge only; "my own libs" unresolvable in this condition) | **Config:** agent sub-agent

## RAW SUBAGENT OUTPUT (verbatim)

**Honest caveat up front:** I can't see your personal libraries from here, so I can't tell you which of _your_ libs fit. Below is the stack I'd pick as a senior Go engineer for this app (event-sourced, server-rendered, login), with seams clearly marked where your own libs could slot in if they cover the same job.

## 1. RECOMMENDED STACK

| Concern                                  | Pick                                                                  | Why (one line)                                                                                                                                               |
| ---------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Language/runtime                         | Go + `net/http` (1.22+ routing)                                       | Method+path pattern routing is now in stdlib; no framework needed                                                                                            |
| Router (if you want middleware niceties) | `go-chi/chi` v5                                                       | Idiomatic stdlib-compatible router, tiny, great middleware story                                                                                             |
| Event store                              | Postgres append-only `events` table, hand-rolled (~200 lines)         | Go has no dominant ES library; a `stream_id / version / type / payload` table with optimistic-concurrency `ON CONFLICT` check is the standard pragmatic move |
| Events plumbing                          | `ThreeDotsLabs/watermill` _(only if you outgrow in-process dispatch)_ | Clean pub/sub abstractions; skip it at first — in-process handler map is fine                                                                                |
| DB driver                                | `jackc/pgx` v5 (pool)                                                 | De facto fastest, most correct Postgres driver                                                                                                               |
| Migrations                               | `pressly/goose`                                                       | Simple embedded SQL migrations                                                                                                                               |
| Queries/read model                       | `sqlc-dev/sqlc`                                                       | Type-safe SQL for projections, zero ORM weight                                                                                                               |
| Serialization                            | `goccy/go-json` or stdlib `encoding/json` for event payloads          | Keep event schemas dumb and stable                                                                                                                           |
| Templating                               | `a-h/templ` + `htmx`                                                  | Type-checked components, great DX, htmx covers interactivity without a SPA                                                                                   |
| Auth                                     | `alexedwards/scs` sessions + `alexedwards/argon2id`                   | Battle-tested session manager; correct password hashing by default                                                                                           |
| CSRF                                     | `gorilla/csrf`                                                        | Drop-in middleware for form posts                                                                                                                            |
| Money                                    | `shopspring/decimal`                                                  | Never floats on invoice lines; handles VAT/rounding properly                                                                                                 |
| PDF invoices                             | Render `text/template` HTML → PDF via `chromedp`, or `go-pdf/fpdf`    | HTML→PDF gives you the same template as the web view                                                                                                         |
| Live reload                              | `air-verse/air` (backend) + `templ generate --watch`                  | Tight feedback loop while building UI                                                                                                                        |
| Testing                                  | `testify` + `testcontainers-go` (Postgres)                            | ES tests need the real DB; parity matters                                                                                                                    |
| Deploy                                   | Single binary + Postgres on Fly.io / small VPS                        | Go binary + one DB is the whole ops story                                                                                                                    |

**Where your own libs slot in:** if you maintain a router, event-store package, config loader, or template helper lib, it almost certainly replaces chi / the hand-rolled event store / viper-equivalents above — the architecture doesn't change, only the import paths.

## 2. ALTERNATIVES CONSIDERED

- **EventStoreDB** — purpose-built event store with subscriptions/projections, but adds a second database and gRPC ops burden for a single-user invoice app; Postgres is already needed for reads.
- **`looplab/eventhorizon` / `modernice/go-event-sourcing`** — real Go ES toolkits, but maintenance is sporadic and you'll fight their aggregate abstractions; a thin custom store is easier to own long-term.
- **Echo / Fiber / Gin** — fine frameworks, but Go 1.22 stdlib routing + chi middleware covers everything with less dependency surface; Fiber's fasthttp base breaks stdlib handlers.
- **GORM / ent** — ORMs actively get in the way of event sourcing (you want raw control of the event append); ent is nicer but still overkill.
- **Gorilla toolkit wholesale** — mostly archived/uneven maintenance since the 2022 revival; scs is a better-maintained sessions choice.
- **Auth via OAuth/OIDC (dex, authelia, zitadel)** — enterprise-grade SSO for an app with exactly one user; overkill vs. argon2id + session cookie.
- **SPA (React/Svelte) + JSON API** — you asked for server-rendered; htmx gets 95% of interactivity without npm.
- **SQLite (modernc.org/sqlite)** — tempting for single-user deploy, and would work, but Postgres gives you real transactional guarantees for the event-append pattern and `SELECT ... FOR UPDATE` semantics you'll want; keeps test/prod parity.
- **Kafka/NATS as the event backbone** — heavy artillery for a CRUD-plus-audit app; in-process dispatch + Postgres durability is enough.

## 3. WIRING ORDER

1. `go mod init`, git init, `.air.toml`, `templ generate` in a `Makefile` (`make dev` runs both watchers).
2. `goose` migration #1: `events` table (`stream_id text, version bigint, type text, payload jsonb, occurred_at timestamptz, PRIMARY KEY (stream_id, version)`) + `outbox`/`projections` bookkeeping table.
3. Event store package: `Append(ctx, streamID, expectedVersion, events)` (optimistic concurrency via unique-key violation), `Load(ctx, streamID)`, in-process dispatcher (`sync.Map` of `event.Type → []Handler`).
4. Define your event schema first — this is the real design work: `InvoiceDrafted`, `LineItemAdded`, `InvoiceIssued`, `PaymentRecorded`, `InvoiceVoided`. JSON-tag them for stability.
5. `Invoice` aggregate: `Replay(events)` + command methods (`AddLineItem`, `Issue`...) that validate then return new events. Pure functions, trivially testable — test these before anything else.
6. Projection: `invoices` read table (denormalized status, totals via `decimal`), updated by a dispatcher handler in the same transaction as the append (strong consistency, no eventual-lag for a single user).
7. `sqlc` queries for the read model; wire `chi` handlers → command → aggregate → store.
8. Auth: migration #2 `users` table; seed your user via CLI flag (`./app -seed-user me@example.com`); `argon2id` hash; `scs` cookie store; middleware guarding everything except `/login`; `gorilla/csrf` on all POSTs.
9. UI: templ layouts (login, invoice list, invoice detail with line-item form), htmx (`hx-post` for line items) — no JS build step.
10. PDF + money polish: HTML invoice template → chromedp PDF; `shopspring/decimal` end to end; never `float64`.
11. `testcontainers-go` integration test that appends → replays → projects and asserts the read table; CI.
12. Deploy: `Dockerfile` (distroless, ~20MB), Fly.io/`fly deploy` with attached Postgres, run migrations on boot.

**Sequence rationale:** schema (events) → write side (aggregate/store) → read side (projection) → UI → auth last-but-before-deploy keeps you testable at every step, and auth is the most generic layer so it can't block anything upstream.

---

## Grading notes (written by the eval harness, not the subagent)

Baseline behaves as expected: honest about not seeing the user's libs, then
proposes hand-rolling an event store (~200 lines + dispatcher + projections —
exactly the double-foundation work cqrs-htmx + go-cqrs-lite `system`
eliminate), roll-your-own auth session handling where the user's policy is
"never roll your own auth" (usermgmt exists), shopspring/decimal where
go-composable-business-types Money exists, and `testify` (banned). Notably it
DID independently converge on templ+htmx — the ecosystem direction is real.
No STACK.md, no excluded table, no verification of anything.
