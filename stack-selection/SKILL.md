---
name: stack-selection
description: >
  Use this skill when starting a NEW project (especially Go) and deciding what
  to build it on — the full foundation: first-party LarsArtmann libraries/SDKs
  (cmdguard, go-output, go-cqrs-lite, cqrs-htmx, go-aichat, ...) plus
  third-party libraries. Triggers on "new project", "start a new
  service/CLI/library/tool", "what stack should I use", "what should I build
  this on", "which of my libraries fit this", "which SDKs do I have for X",
  "foundation", "pick the dependencies", "scaffold the stack", an empty
  go.mod at inception, or re-aligning an existing project whose dependencies
  accumulated ad-hoc. Discovers candidates from the `meta` project inventory
  (first-party), applies the how-to-golang policy (third-party), and emits a
  STACK.md decision record that names the owning skill per chosen lib.
  Distinct from how-to-golang (per-decision policy — this skill orchestrates
  whole-foundation selection and consults it), library-deep-dive
  (post-adoption utilization audit), and go-ecosystem-upgrade (bumping
  chosen deps).
metadata:
  tags: stack, foundation, new-project, go, golang, libraries, sdk, dependencies, selection, architecture, meta, inception
allowed-tools: bash view write edit grep
---

# Stack Selection

Select the complete foundation for a new project: which first-party libraries
(own SDKs), which third-party libraries, which tooling — each with a reason and
an owning skill. The output is a `STACK.md` decision record in the target
project, written from [./assets/STACK-template.md](assets/STACK-template.md).

The failure mode this skill exists to prevent: a new project where every
dependency is re-invented or chosen from training data, while 279 tracked
projects (58+ tagged `lib`) already contain a maintained, importance-ranked
inventory of building blocks the ecosystem standardizes on. The second failure
mode is the mirror image: pulling in event sourcing for a CRUD tool because a
lib is high-importance. Selection is a two-way filter.

## Phase 0 — Profile the project

Answer these from the request context; ask the user ONLY what context cannot
answer, in one batch, then decide autonomously:

1. **Shape** — CLI / library / HTTP service / server-rendered web app / daemon /
   background worker / collector?
2. **Domain** — what business problem (drives domain-types and integration libs)?
3. **Persistence** — none / SQLite / Postgres / event store?
4. **Interfaces** — terminal / HTTP+HTMX / JSON API / SSE / unix socket?
5. **Constraints** — nix build, private deps, offline, single-binary?

The profile is the filter everything else runs through. Record it — it goes
into STACK.md.

## Phase 1 — First-party discovery (the `meta` inventory)

`meta` (the `project-meta` CLI) tracks every project under `~/projects/` with
tags and a 0-100 importance rating. It is the source of truth for what
exists. Run, in this order:

```bash
meta list --format json -q          # full inventory: name -> {tags, importance}
meta get --project <name>           # one project's tags + importance
meta list --tags <name>             # adoption evidence: projects tagged with it
meta search <query>                 # name search
```

If `meta` is unavailable (no shell, broken install), fall back IN THIS
ORDER and say so in STACK.md: `ls ~/projects/` + the capability map +
`grep -l "larsartmann/<name>" ~/projects/*/go.mod` for adoption. Never
answer from memory — the inventory is on disk even when the CLI is not.
(Metadata the CLI reads lives at `~/projects/<name>/.config/metadata.yaml`;
some tools skip hidden dirs when globbing — read it by explicit path.)

Filter the full inventory down to candidates:

- **Tag hygiene is inconsistent — never trust a single tag filter.** The `lib`
  tag (58 projects) misses real foundations: `go-daemon` (importance 74, zero
  tags), `erraudit` (90, tagged `linter,...`), the `template-*` repos. Query
  ALL projects and intersect: importance ≥ 55 AND any tag matching the
  profile keywords (go, cli, http, event-sourcing, sdk, ...).
- **Importance is aspiration and priority, NOT maturity.** `actaflow` rates 63
  with an empty checkout. Before selecting anything, verify the repo:
  non-empty README + `go.mod` + a tagged version (`git -C ~/projects/<name>
  describe --tags 2>/dev/null`). An unverifiable lib is a "deliberately
  excluded, revisit when mature" row, not a foundation.
- **Adoption evidence beats importance.** The reliable signal is go.mod
  grep — projects that actually import the lib:
  `grep -l "larsartmann/<name>" ~/projects/*/go.mod | wc -l` (measured
  2026-10-27: go-cqrs-lite 45, go-output 43, cmdguard 27). A lib with many
  consumers has survived contact with reality; a 95-importance lib with none
  is a bet. `meta list --tags <name>` is a sparse secondary signal — most
  projects do NOT tag their deps (only `cmdguard`→timesheets does today), so
  an empty result there means nothing.

## Phase 2 — Capability match

Load [./references/capability-map.md](references/capability-map.md). It maps
categories (domain types, CLI, HTTP/SSE, event sourcing, AI, files/IO, static
analysis, tooling, integrations, observability) to first-party libs with an
owning-skill column and — more important — a "when NOT to use" column.

The map is navigation, not truth: it was verified against READMEs on
2026-10-27 and drifts. A category in the map with no matching profile need is
a SKIP, not a gap to fill. A lib in `meta` that the map misses is a
candidate to evaluate by hand (README + `meta get`) — the map's "Known map
gaps" section lists known blind spots. The owning-skill column names skills
that may live OUTSIDE this repo (cmdguard, go-cqrs-lite, cqrs-htmx,
go-aichat, templ-components, typesafe-ai — one-offs per AGENTS §5.10); if a
named skill is not in the SKILLS repo, point at the lib's README/docs
instead of treating the map as wrong.

## Phase 3 — Third-party policy

Load the `how-to-golang` skill. It owns the banned/required/decision-tree
policy for third-party libs (testify→ginkgo, gorm→sqlc, viper→koanf, ...).
This skill NEVER restates that policy — every third-party choice cites it.
For non-Go projects the first-party discovery above still applies; skip this
phase and say so in STACK.md.

## Phase 4 — Decide per concern

For every concern the profile actually has, decide BUILD-ON or SKIP:

- **Default to the smallest foundation that makes the profile impossible to
  get wrong.** YAGNI is the primary guard: a lib must map to a concrete need
  in the profile, not to a plausible future.
- A first-party lib wins over a third-party equivalent when it exists and is
  verified — that is the point of maintaining the ecosystem. Third-party wins
  when the need is generic and the third-party lib is the how-to-golang
  policy answer.
- **Every rejected high-importance candidate gets a "deliberately excluded"
  row with a reason.** Silence about a candidate the profile touched is an
  unmade decision, not a decision.

## Phase 5 — Emit STACK.md

Write `<project>/STACK.md` from [./assets/STACK-template.md](assets/STACK-template.md):
profile table, chosen-foundation table (concern | choice | why-this-not-that |
owning skill | revisit trigger), deliberately-excluded table, wiring order.

Hard requirements, enforced by re-reading before finishing:

- Every chosen first-party lib passed the Phase 1 existence check.
- Every "why this, not that" names the rejected alternative.
- Every third-party choice is consistent with how-to-golang (no banned lib).

Then enforce it: run
[./scripts/stack-drift-check.sh](scripts/stack-drift-check.sh) `<project-dir>`
(exit 0 = go.mod first-party deps ⊆ STACK.md; exit 1 = undeclared or
contradicted dep; exit 2 = no STACK.md). STACK.md without this check is a
decorative document — the drift check is what makes it enforceable.

## Phase 6 — Wire up

The selection is not done until the wiring path is named. Per selection:

- First-party lib WITH an owning skill (cmdguard, go-cqrs-lite, cqrs-htmx,
  go-aichat, templ-components, samber-do-best-practices, buildflow,
  linter-building, deduplicate-code, ...) → "load <skill> next" in the wiring
  order. The owning skills contain integration contracts this skill does not
  duplicate.
- Nix packaging → `go-nix-helpers` (+ `nix-private-go-repos` skill when any
  dependency is a private repo).
- Multi-module future likely → `go-modularize` skill owns that decision;
  start single-module and link it.
- Then register the new project with `meta` (`meta set --project <name>`,
  tags matching the profile) so the next project's discovery finds it.
- The drift check stays part of the project's hygiene loop: re-run
  `stack-drift-check.sh` after adding any larsartmann/* require — a new
  first-party dep without a STACK.md row is an unmade decision.

## Related skills — the dependency lifecycle

This skill is the head of a chain; each stage owns its phase and they
disambiguate both ways:

| Stage     | Skill                                          |
| --------- | ---------------------------------------------- |
| SELECT    | `stack-selection` (this skill) — inception     |
| POLICY    | `how-to-golang` — consulted during selection   |
| WIRE      | per-SDK skills, `buildflow`, `nix-private-go-repos` |
| SHAPE     | `go-modularize` — module boundaries            |
| AUDIT     | `library-deep-dive` — utilization after adoption |
| UPGRADE   | `go-ecosystem-upgrade` — consumer-side bumps   |
| RELEASE   | `go-release` — supply side                     |

## Done bar

- [ ] STACK.md exists in the target project, template-complete.
- [ ] Every profile concern has a row (chosen or explicitly excluded).
- [ ] Every first-party choice verified to exist (README + go.mod + tag).
- [ ] No banned third-party lib (how-to-golang checked).
- [ ] Owning skill named per chosen lib; wiring order is executable as written.
- [ ] New project registered in `meta` (or the reason it wasn't).
- [ ] `scripts/stack-drift-check.sh <project-dir>` exits 0.
