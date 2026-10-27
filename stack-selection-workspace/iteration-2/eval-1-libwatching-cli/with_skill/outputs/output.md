# Eval 1 — with-skill: "Go CLI watching markdown folder, syncing frontmatter to Notion-style REST API"

**Date:** 2026-10-27 | **Condition:** with stack-selection skill (subagent instructed to view SKILL.md and follow it; `meta` CLI unavailable to subagent → adapted to `.config/metadata.yaml` + capability-map + go.mod greps, adaptations self-reported) | **Config:** agent sub-agent (read-only tools)

## REFERENCES LOADED

| File                                                                        | Purpose                                               |
| --------------------------------------------------------------------------- | ----------------------------------------------------- |
| `/home/lars/projects/SKILLS/stack-selection/SKILL.md`                       | Main procedure (Phases 0–6)                           |
| `/home/lars/projects/SKILLS/stack-selection/references/capability-map.md`   | Phase 2 capability map (importances dated 2026-10-27) |
| `/home/lars/projects/SKILLS/stack-selection/assets/STACK-template.md`       | Phase 5 template                                      |
| `/home/lars/projects/SKILLS/how-to-golang/SKILL.md`                         | Phase 3 policy (banned/required)                      |
| `/home/lars/projects/SKILLS/how-to-golang/references/banned-libraries.md`   | Ban verification (fsnotify, yaml.v2/v3, …)            |
| `/home/lars/projects/SKILLS/how-to-golang/references/required-libraries.md` | Required-stack cross-check                            |

**Adaptations (skill step → what the subagent did):** `meta` CLI unavailable (no shell) → Phase 1 inventory replaced with grep over `~/projects/*/.config/metadata.yaml` + go.mod grep for adoption evidence. `git describe --tags` impossible → tag evidence replaced by version pins in consumer `go.mod` files + major-version module suffixes. Skill file writes (`<project>/STACK.md`, `meta set`) impossible → STACK.md rendered in report; registration deferred.

## INVENTORY EVIDENCE

**Honest finding reported by the subagent:** only **5** of ~280 projects on disk surfaced via `.config/metadata.yaml` glob (hidden-dir limitation of its glob tool) — the subagent marked importance as `map:` (from the capability-map snapshot) wherever yaml was absent, and did NOT fabricate.

Metadata found: `AI-Speed-Test` (58, cli), `standard-bug-tracking-schema` (63, app), `smart-configs` (63, lib), `rules` (55, docs), `anime-comic-pipeline` (55, ai-agent).

| Project         | Importance | Verified on disk                                                 | Adoption evidence (grep across `~/projects/*/go.mod`)                                     |
| --------------- | ---------- | ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| cmdguard        | map: 92    | ✅ README+go.mod (`cmdguard/v4`)                                 | **35+ repos** pin `cmdguard/v4 v4.1.0`                                                    |
| go-output       | map: 90    | ✅                                                               | **~45 repos** at `v0.38.x`                                                                |
| go-filewatcher  | map: 90    | ✅ (`/v2`)                                                       | **16 external repos** at `v2.4.2`/`v2.3.x`                                                |
| go-retry        | not in map | ✅                                                               | `v0.8.0` widespread; direct in CV, crush-daily, dnsblockd, go-commit, bank-sync, wise-go… |
| go-atomic-write | map: 63    | ✅                                                               | `v0.6.0` widespread; direct in 15+ repos                                                  |
| go-localsync    | map: 60    | ✅                                                               | **1 external consumer**; **proprietary license**                                          |
| md-go-validator | map: 82    | ✅                                                               | **0 external consumers**                                                                  |
| segment-buffer  | map: 55    | ⚠️ README only, **no go.mod found** → failed Phase 1 verification |                                                                                           |
| go-nix-helpers  | map: 63    | ⚠️ README only (flake-parts module — correct, not a Go module)    | n/a                                                                                       |

## CAPABILITY MATCH (condensed; full table in raw output)

- **Watching:** ★ go-filewatcher/v2 — recursion, debounce, filters, ENOSPC resilience; raw fsnotify ❌ **banned** by how-to-golang (policy found and applied); go-daemon wrong shape (unix-socket daemon); polling rejected.
- **Frontmatter parsing:** md-go-validator ❌ (README-verified: validates code blocks, not frontmatter; 0 adoption); full markdown AST overkill → **stdlib `---` split + go-faster/yaml v0.4.6** (policy replacement for banned yaml.v2/v3; pervasive in ecosystem incl. go-output/serialization).
- **CLI shape:** ★ cmdguard/v4 (typed struct flags, config files, DI, exit-code contract); raw cobra leaks footguns; urfave/cli ❌ banned; stdlib flag throwaway-only.
- **Output:** ★ go-output v0.38.7 (struct → table/JSON/Markdown/CSV); tablewriter/go-pretty ❌ banned.
- **Sync (REST):** stdlib net/http + encoding/json/v2; ★ go-retry (README-verified "dependency-light… CLIs, batch jobs" exact fit); ★ go-atomic-write (crash-safe sync-state); go-localsync ❌ (README-verified **pull** mirror API→local — wrong direction; SQLite+CQRS overkill; proprietary license; 1 consumer); segment-buffer ❌ (failed verification + YAGNI); go-taskqueue/universal-workflow ❌ YAGNI.
- **Testing:** ginkgo/v2+gomega (required); testify ❌ banned. **Logging:** slog.

## CHOSEN FOUNDATION

cmdguard/v4 v4.1.0 ★, go-filewatcher/v2 v2.4.2 ★, go-output v0.38.7 ★, go-retry v0.8.0 ★, go-atomic-write v0.6.0 ★, go-faster/yaml v0.4.6, encoding/json/v2 + net/http, ginkgo/gomega. Go floor 1.26.7 (go-filewatcher README).

## DELIBERATELY EXCLUDED (16 rows; lib / importance / reason)

go-cqrs-lite (70, "no invariants/event-history — plain sync loop, the skill's own example of over-pull"), cqrs-htmx (63, no UI), universal-workflow (92, linear pipeline), go-taskqueue (63, single sequential loop), go-localsync (60, wrong direction + license), segment-buffer (55, **failed Phase 1 verification**), go-daemon (74, daemon blocks), md-go-validator (82, validates wrong thing), go-composable-business-types (96, no business invariants), go-branded-id (63, remote IDs opaque), project-discovery-sdk (87, fixed folder), go-idempotency/go-etag (server-side), go-github-kit/wise-go (specific APIs), gogenfilter/go-commit (no generated code), koanf (deferred — cmdguard owns config).

## STACK.md

Rendered in full per the Phase 5 template (profile table / chosen-foundation table with why-this-not-that + owning-skill + revisit-when columns / deliberately-excluded table / wiring order 1–8 / decision log). Full text preserved in raw subagent output below.

## WIRING ORDER + OWNING SKILLS

1. cmdguard skill ⚠️ honest caveat: subagent could not find `cmdguard/` in the SKILLS repo — flagged unverified (it lives outside the repo per AGENTS §5.10)
2. how-to-golang (re-check banned list after every go get)
3. nix-private-go-repos + go-nix-helpers (private deps)
4. go-modularize (only if multi-module), library-deep-dive (post-adoption audit), go-ecosystem-upgrade / go-release (lifecycle)
5. meta registration — deferred (no shell)

**Done-bar self-report:** STACK.md ✅; every concern a row ✅; every ★ verified README+go.mod ✅ (tag check adapted to consumer pins — stated); no banned third-party lib ✅; owning skills named ✅ (cmdguard location flagged); meta registration ❌ deferred.

---

## RAW SUBAGENT OUTPUT (verbatim)

## RAW SUBAGENT OUTPUT (verbatim)

# Stack Selection Report — Markdown→Notion-style frontmatter sync CLI

## 1. REFERENCES LOADED

| File                                                                        | Purpose                                               |
| --------------------------------------------------------------------------- | ----------------------------------------------------- |
| `/home/lars/projects/SKILLS/stack-selection/SKILL.md`                       | Main procedure (Phases 0–6)                           |
| `/home/lars/projects/SKILLS/stack-selection/references/capability-map.md`   | Phase 2 capability map (importances dated 2026-10-27) |
| `/home/lars/projects/SKILLS/stack-selection/assets/STACK-template.md`       | Phase 5 template                                      |
| `/home/lars/projects/SKILLS/how-to-golang/SKILL.md`                         | Phase 3 policy (banned/required)                      |
| `/home/lars/projects/SKILLS/how-to-golang/references/banned-libraries.md`   | Ban verification (fsnotify, yaml.v2/v3, …)            |
| `/home/lars/projects/SKILLS/how-to-golang/references/required-libraries.md` | Required-stack cross-check                            |

**Adaptations (skill step → what I did):** `meta` CLI unavailable (no shell) → Phase 1 inventory replaced with grep over `~/projects/*/.config/metadata.yaml` + go.mod grep for adoption evidence. `git describe --tags` impossible → tag evidence replaced by version pins in consumer `go.mod` files + major-version module suffixes (`/v2`, `/v4`). Skill file writes (`<project>/STACK.md`, `meta set`) impossible → STACK.md rendered in this report; registration step deferred.

## 2. INVENTORY EVIDENCE

**Honest finding:** only **5** of ~280 projects on disk have `.config/metadata.yaml` — the `meta` data source is nearly empty locally. None are foundation candidates. Importance ratings below therefore come from the capability-map (its own 2026-10-27 snapshot), marked `map:`.

Metadata found on disk: `AI-Speed-Test` (58, cli), `standard-bug-tracking-schema` (63, app), `smart-configs` (63, lib), `rules` (55, docs), `anime-comic-pipeline` (55, ai-agent).

Projects actually inspected (ls/glob/grep/view — `verified` = non-empty README + go.mod seen):

| Project                                                                                                                                                           | Importance                         | Verified on disk                                                 | Adoption evidence (grep across `~/projects/*/go.mod`)                                                                                                                 |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| cmdguard                                                                                                                                                          | map: 92 (yaml: none)               | ✅ README+go.mod (`cmdguard/v4`)                                 | **35+ repos** pin `cmdguard/v4 v4.1.0` (CV, crm, erraudit, mr-sync, BuildFlow, timesheets, securitymd, samber-linter, go-wizard-sdk, …)                               |
| go-output                                                                                                                                                         | map: 90                            | ✅ README+go.mod                                                 | **~45 repos** at `v0.38.7`/`v0.38.x` (direct: erraudit, mr-sync, journal, library-policy, go-hotspot, branching-flow, …)                                              |
| go-filewatcher                                                                                                                                                    | map: 90                            | ✅ README+go.mod (`go-filewatcher/v2`)                           | **16 external repos** at `v2.4.2`/`v2.3.x` (erraudit, Cyberdom, prompt-crusher, project-discovery-sdk, dynamic-markdown-site, index, auto-deduplicate, pma-daemon, …) |
| go-retry                                                                                                                                                          | not in map                         | ✅ README+go.mod                                                 | `v0.8.0` widespread; **direct** in CV, crush-daily, dnsblockd, go-commit, bank-sync, wise-go, go-paperless, file-and-image-renamer                                    |
| go-atomic-write                                                                                                                                                   | map: 63                            | ✅ README+go.mod                                                 | `v0.6.0` widespread; **direct** in 15+ repos (mr-sync, BuildFlow modules, securitymd, project-meta, clean-wizard, …)                                                  |
| go-localsync                                                                                                                                                      | map: 60                            | ✅ README+go.mod                                                 | **1 external consumer** (`github-local-sync`); **proprietary license**                                                                                                |
| md-go-validator                                                                                                                                                   | map: 82                            | ✅ README+go.mod                                                 | **0 external consumers**                                                                                                                                              |
| segment-buffer                                                                                                                                                    | map: 55                            | ⚠️ README only, **no go.mod found** → failed Phase 1 verification | not searched (failed check)                                                                                                                                           |
| go-nix-helpers                                                                                                                                                    | map: 63                            | ⚠️ README only (flake-parts module — correct, not a Go module)    | n/a (tooling)                                                                                                                                                         |
| go-composable-business-types, go-branded-id, go-daemon, go-taskqueue, universal-workflow, gogenfilter, go-commit, project-discovery-sdk, go-github-kit, BuildFlow | map: 96/63/74/63/92/90/95/87/75/95 | ✅ README+go.mod each                                            | not counted — excluded on capability fit                                                                                                                              |

## 3. CAPABILITY MATCH

| Concern                 | Candidates found                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Decision                                                                                                                                                      |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Watching**            | ★ `go-filewatcher/v2` (recursion, debounce, filters, ENOSPC resilience — README verified); raw `fsnotify` (❌ **banned** by how-to-golang, which explicitly redirects to go-filewatcher); `go-daemon` (unix-socket daemon blocks — wrong shape); hand-rolled polling                                                                                                                                                                                                                                                                                                                                                                         | **go-filewatcher/v2** — first-party, verified, 16 consumers, and the _policy-mandated_ fsnotify replacement                                                   |
| **Frontmatter parsing** | `md-go-validator` (❌ README verified: validates _code blocks_, not frontmatter; 0 adoption); `gomarkdown/markdown` full AST (overkill — frontmatter is a delimited YAML header, not AST); ★ `go-composable-business-types` (domain types, not parsing)                                                                                                                                                                                                                                                                                                                                                                                      | **stdlib `---` split + `go-faster/yaml` v0.4.6** — policy replacement for banned `yaml.v2/v3`; already pervasive in ecosystem incl. `go-output/serialization` |
| **CLI shape**           | ★ `cmdguard/v4` (typed struct flags, config files, DI, exit-code contract, zero-panic); raw cobra (cmdguard wraps it — raw leaks footguns); `urfave/cli` (❌ banned); stdlib `flag` (throwaway only); `charm.land/fang/v2` (styling — cmdguard already embeds fang+lipgloss)                                                                                                                                                                                                                                                                                                                                                                 | **cmdguard/v4** — first-party wins per Phase 4; owns flags **and** config-file handling (defers the `koanf` question)                                         |
| **Output**              | ★ `go-output` (one struct → table/JSON/Markdown/CSV; sync-report exactly this); `fmt` fixed format (rejected: need `--json` + human table); `tablewriter`/`go-pretty` (❌ banned)                                                                                                                                                                                                                                                                                                                                                                                                                                                            | **go-output v0.38.7**                                                                                                                                         |
| **Sync (REST client)**  | stdlib `net/http` + `encoding/json/v2` (Go 1.25+, policy); ★ `go-retry` (README: "dependency-light… CLIs, batch jobs… without importing an entire platform" — exact fit); ★ `go-atomic-write` (crash-safe sync-state file); ★ `go-localsync` (❌ README verified: _pull_ mirror API→local, single-writer, SQLite+CQRS event log, proprietary license — wrong direction + overkill); `segment-buffer` (❌ failed verification); ★ `go-taskqueue`/`universal-workflow` (❌ YAGNI); ★ `go-github-kit`/`wise-go` (❌ specific APIs); `failsafe-go` (required-lib answer, but go-retry is the verified first-party equivalent — first-party wins) | **net/http + json/v2 + go-retry + go-atomic-write**                                                                                                           |
| **Testing** (policy)    | ginkgo/v2+gomega (required); testify (❌ banned)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | **ginkgo/gomega** per how-to-golang                                                                                                                           |
| **Logging**             | `log/slog` + `charm.land/log/v2` (required-libraries)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | **slog** (CLI tool; cmdguard provides styled output)                                                                                                          |

## 4. CHOSEN FOUNDATION

| Concern             | Choice                                                                 | Version verified via                                                                                     |
| ------------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| CLI framework       | ★ `github.com/larsartmann/cmdguard/v4`                                 | `v4.1.0` pins in 35+ consumer go.mod; README states "v4.0.0 is the current release on the v4 major line" |
| File watching       | ★ `github.com/larsartmann/go-filewatcher/v2`                           | `v2.4.2` pins in 16 consumer go.mod                                                                      |
| Output rendering    | ★ `github.com/larsartmann/go-output`                                   | `v0.38.7` pins across ecosystem                                                                          |
| HTTP resilience     | ★ `github.com/larsartmann/go-retry`                                    | `v0.8.0` pins; README release badge                                                                      |
| Sync-state writes   | ★ `github.com/larsartmann/go-atomic-write`                             | `v0.6.0` pins                                                                                            |
| YAML frontmatter    | `github.com/go-faster/yaml`                                            | `v0.4.6` pervasive incl. go-output/serialization go.mod                                                  |
| JSON / HTTP / tests | `encoding/json/v2` (GOEXPERIMENT=jsonv2), `net/http`, ginkgo/v2+gomega | how-to-golang required-libraries                                                                         |

Go floor: **1.26.7** (go-filewatcher README: "Requires Go 1.26.7 or later"; go-output/go-retry require 1.26).

## 5. DELIBERATELY EXCLUDED

| Lib                          | Importance   | Why excluded                                                                                                                               |
| ---------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| go-cqrs-lite                 | map: 70      | No invariants/event-history — plain sync loop (skill's own example of over-pull)                                                           |
| cqrs-htmx                    | map: 63      | Server-rendered web framework; no UI here                                                                                                  |
| universal-workflow           | map: 92      | Watch→parse→PUT is linear; no DAG/parallel orchestration                                                                                   |
| go-taskqueue                 | map: 63      | Single sequential sync loop; errgroup-level concurrency at most                                                                            |
| go-localsync                 | map: 60      | README-verified **pull** mirror (API→local) — need push (local→API); SQLite+CQRS event store overkill; **proprietary license**; 1 consumer |
| segment-buffer               | map: 55      | **Failed Phase 1 verification** (no go.mod on disk); buffering YAGNI for single-folder scale                                               |
| go-daemon                    | map: 74      | Long-lived unix-socket daemon blocks; this is a foreground CLI watch-mode                                                                  |
| md-go-validator              | map: 82      | README-verified: code-block validation, not frontmatter extraction; 0 adoption                                                             |
| go-composable-business-types | map: 96      | Frontmatter passthrough has no business invariants; IDs owned by the remote API                                                            |
| go-branded-id                | map: 63      | No locally-minted domain IDs — remote page IDs are opaque strings                                                                          |
| project-discovery-sdk        | map: 87      | Multi-directory project discovery; one fixed folder here                                                                                   |
| go-idempotency / go-etag     | map: 63/63   | Server-side concerns; we're the client                                                                                                     |
| go-github-kit / wise-go      | map: 75/63   | Specific external APIs; target is generic Notion-style REST                                                                                |
| gogenfilter / go-commit      | map: 90/95   | No generated code; no commit-message generation                                                                                            |
| koanf                        | required-lib | Deferred — cmdguard owns CLI config files; revisit if config outgrows flags                                                                |

## 6. STACK.md

> Rendered per Phase 5; user's repo is empty and unnamed — placeholder `<mdfront-sync>` and write it to `<repo>/STACK.md` on `go mod init`.

```markdown
# STACK — <mdfront-sync> (placeholder name)

> The deliberate foundation of this project: every significant dependency was
> chosen, not accumulated. Generated 2026-10-27 by the stack-selection skill
> (profile: Go CLI tool, watch-mode markdown→REST sync).
> This is a LIVING document — update the row when the reason changes, delete
> the row when the dependency goes.

## Profile

| Axis         | Answer                                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| Shape        | CLI (long-running watch subcommand; foreground, not a socket daemon)                                          |
| Domain       | Watch a folder of markdown files, parse YAML frontmatter, upsert to a Notion-style REST API                   |
| Persistence  | None — single JSON sync-state file (no DB)                                                                    |
| Interfaces   | Terminal in (flags/config); terminal out (table/JSON); outbound HTTPS REST                                    |
| Scale target | Single user, one folder, hundreds of files                                                                    |
| Constraints  | Empty repo tonight; Go 1.26.7 floor (go-filewatcher); single binary; private first-party deps (larsartmann/*) |

## Chosen foundation

| Category            | Choice (first-party = ★)                         | Why this, not that                                                                                                        | Owning skill / docs | Revisit when                           |
| ------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- | ------------------- | -------------------------------------- |
| CLI framework       | ★ cmdguard/v4 (v4.1.0)                           | typed flags + config files + DI + exit-code contract; raw cobra leaks runtime panics, urfave/cli is banned                | `cmdguard` skill    | command set stabilizes differently     |
| File watching       | ★ go-filewatcher/v2 (v2.4.2)                     | recursion, debounce, .md filters, ENOSPC resilience; raw fsnotify is banned by how-to-golang; polling is a rebuild        | README + pkg.go.dev | need NFS/FUSE polling beyond built-ins |
| Frontmatter parsing | go-faster/yaml (v0.4.6) + stdlib delimiter split | how-to-golang policy (yaml.v2/v3 banned); md-go-validator validates code blocks, not frontmatter                          | how-to-golang       | TOML/JSON frontmatter needed           |
| Output rendering    | ★ go-output (v0.38.7)                            | one struct → table/JSON/Markdown; fmt can't do --json, go-pretty/tablewriter banned                                       | README + pkg.go.dev | output needs exceed its formats        |
| HTTP client         | net/http + encoding/json/v2                      | stdlib is the policy answer; no framework needed for one endpoint family                                                  | how-to-golang       | API grows complex (auth flows)         |
| Retry/backoff       | ★ go-retry (v0.8.0)                              | dependency-light, CLI-scoped by design; failsafe-go is the third-party answer but first-party wins; avast/retry-go banned | README + pkg.go.dev | need circuit breaking                  |
| Sync-state file     | ★ go-atomic-write (v0.6.0)                       | crash-safe state across restarts; os.WriteFile corrupts on crash; SQLite (via go-localsync) is overkill                   | README + pkg.go.dev | state needs querying → SQLite+sqlc     |
| Testing             | ginkgo/v2 + gomega                               | testify banned (how-to-golang)                                                                                            | how-to-golang       | —                                      |
| Logging             | log/slog                                         | logrus/zerolog banned; CLI needs no charm.land/log yet                                                                    | how-to-golang       | structured logs needed in TUI          |

First-party verification (2026-10-27): cmdguard, go-filewatcher, go-output,
go-retry, go-atomic-write all confirmed on disk at ~/projects/<name> with
README + go.mod; versions taken from consumer go.mod pins (git tag check
unavailable in this session).

## Deliberately excluded

| Candidate                                              | Reason                                                                                          |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| go-cqrs-lite (70)                                      | No invariants/event-history — plain sync loop (YAGNI)                                           |
| universal-workflow (92)                                | Linear watch→parse→PUT; no orchestration                                                        |
| go-taskqueue (63)                                      | Single sequential loop; errgroup covers simple fan-out                                          |
| go-localsync (60)                                      | Pull mirror (API→local), wrong direction; SQLite+CQRS overkill; proprietary license; 1 consumer |
| segment-buffer (55)                                    | Failed verification (no go.mod on disk); buffering YAGNI                                        |
| go-daemon (74)                                         | Unix-socket daemon; this is a foreground CLI                                                    |
| md-go-validator (82)                                   | Validates code blocks, not frontmatter; 0 adoption                                              |
| go-composable-business-types (96) / go-branded-id (63) | IDs and invariants owned by remote API                                                          |
| project-discovery-sdk (87)                             | Fixed single folder, no discovery needed                                                        |
| go-idempotency (63) / go-etag (63)                     | Server-side concerns; we are the client                                                         |
| go-github-kit (75) / wise-go (63)                      | Specific APIs; target is generic REST                                                           |
| koanf                                                  | cmdguard owns CLI config; revisit if config outgrows flags                                      |

## Wiring order

1. `go mod init` (Go 1.26.7) + `go get` cmdguard/v4@v4.1.0, go-filewatcher/v2@v2.4.2, go-output@v0.38.7, go-retry@v0.8.0, go-atomic-write@v0.6.0, go-faster/yaml@v0.4.6, onsi/ginkgo/v2+gomega
2. Load the `cmdguard` skill for command/flag/config wiring contracts
3. Frontmatter pkg: delimiter split + go-faster/yaml → typed Frontmatter struct
4. go-filewatcher: `.md` filter + per-path debounce + content-hash (skip no-op saves)
5. Sync loop: net/http PUT-by-path-key (idempotent upsert) wrapped in go-retry; state via go-atomic-write
6. Report: go-output table, `--json` via serialization
7. Optional: flake.nix via go-nix-helpers (+ `nix-private-go-repos` skill — deps are private larsartmann repos)
8. Register in `meta`: `meta set --project <name>` tags: cli,sync,markdown (could not run — no shell this session)

## Decision log

- 2026-10-27 — Initial selection (stack-selection skill, session: eval sub-agent, meta CLI unavailable; inventory via .config/metadata.yaml + go.mod greps).
```

## 7. WIRING ORDER + OWNING SKILLS TO LOAD NEXT

1. **`cmdguard` skill** — named by capability map as owning skill for cmdguard integration. ⚠️ Honest caveat: I could not find a `cmdguard/` skill directory under `/home/lars/projects/SKILLS` (nor `agent-skills`) — locate it before wiring; fallback: `https://cmdguard.lars.software` docs. 35+ consumer repos also show usage patterns.
2. **`how-to-golang`** — already loaded; re-check `go.mod` against banned-libraries after every `go get`.
3. **`nix-private-go-repos`** — when packaging via nix (all ★ deps are private `larsartmann/*` repos); **`go-nix-helpers`** for the flake itself.
4. **`go-modularize`** — only if this grows multi-module; start single-module.
5. **`library-deep-dive`** — post-adoption utilization audit (e.g., confirm go-filewatcher debounce/hash middlewares actually used).
6. **`go-ecosystem-upgrade` / `go-release`** — later lifecycle.
7. **Register with `meta`** (`meta set --project <name>`, tags `cli,sync,markdown`) — deferred: CLI unavailable in this session.

**Done-bar status:** STACK.md ✅ (rendered above, to be written to the new repo); every concern has a row ✅; every ★ choice verified README+go.mod ✅ (tag check adapted to consumer version pins — stated); no banned third-party lib ✅; owning skills named ✅ (cmdguard skill location flagged unverified); meta registration ❌ deferred (tool unavailable).
