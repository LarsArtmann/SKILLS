# AGENTS.md — SKILLS Repository

> _Context for AI agents working in this repository._
>
> <!-- agents-md-size-budget: 52000 — justified (T70, 2026-11-22): this repo's
>      charter makes AGENTS.md the operating manual for 38 skills (§5 graph,
>      gates, daemon rules); provenance detail already extracted to
>      docs/skill-forks.md. Growth beyond the budget means NEW provenance is
>      being inline'd — extract to docs/ instead of raising this. -->

**Project:** A collection of [Agent Skills](https://agentskills.io) for [Crush](https://github.com/charmbracelet/crush) — structured, discoverable skill directories converted from raw prompt snippets.

---

## 1. Project Type & Purpose

This is a **documentation-only content repository**. There is no build system, no package manager, no test suite, no CI config. Every skill is a self-contained directory of markdown files (and optionally scripts/assets).

If you are looking for source code to build, test, or lint: **there is none**. The "product" is the markdown content itself.

**Shell scripts:** format every `.sh` with shfmt (tab indentation) BEFORE writing/committing; the repo owner reformats non-conforming scripts (see `b6163c2`), which trips "modified since read" guards. Quality gate: `scripts/check-skills.sh` (run after every change). Shellcheck gate: `scripts/check-shell.sh` runs shellcheck at full severity over every `.sh` in the repo (falls back to `nix run nixpkgs#shellcheck` when no shellcheck is on PATH); the baseline is clean, so keep it that way. Intentional style exceptions carry an inline `# shellcheck disable=SCxxxx  # reason` comment at the offending line, never a file-wide or repo-wide exclusion (added 2026-11-17 from the `nix-private-go-repos/scripts/list-private-deps.sh` unquoted-variable bug class, commit `a8a6139`). An external tool (buildflow) also lints this repo via a minimal committed `.buildflow.yml` (quality-gate config, not a build system — §9 still bans go.mod/CI/package manager) — see §5.11 for what it covers and which invocation is reliable.

**Go tooling:** the script assets are single-file, stdlib-only Go programs run via `go run <file.go>` (`docs-health/assets/annotate.go`; `github-voice/scripts/{check-draft,analyze-corpus,collect-corpus}/*.go`) — the repo still has no go.mod by design (§9), so each program is deliberately one self-contained file in its own directory. Format with gofmt, check with `go vet <file.go>`, and run the embedded `self-test` subcommands after edits.

---

## 2. Directory Structure

```
SKILLS/
├── README.md                    # Project overview, skills table, installation
├── how-to-write-skills/SKILL.md       # Authoritative guide for writing new skills (currently at root)
├── originals/                   # Legacy raw prompt source material. DO NOT EDIT.
│   └── <skill-name>.md            #   Raw prompts named after the skill they seeded.
│                                 #   Two legacy source prompts produced
│                                 #   multiple files (execution-mode,
│                                 #   pareto-planning). Skills/ directories
│                                 #   are canonical (see docs/status/).
│
├── <skill-name>/                # One directory per skill (run scripts/check-skills.sh for the current count)
│   ├── SKILL.md                 # Required: YAML frontmatter + agent instructions
│   ├── scripts/                 # Optional: executable helpers (run without loading into context)
│   ├── references/              # Optional: detailed docs loaded on demand via `view`
│   ├── rules/                   # Optional: domain-specific constraints loaded on demand
│   └── assets/                  # Optional: templates, images, sample data
│
└── docs/
    └── status/                  # Point-in-time session reports (living set)
        └── archived/            # Fully-resolved reports (every item carries an
                                 #   inline strikethrough verdict; moved via git mv
                                 #   per docs-health ANNOTATE)
```

### Which files to edit

| File/Dir                       | Action                                                        |
| ------------------------------ | ------------------------------------------------------------- |
| `<skill-name>/SKILL.md`        | Edit freely — this is the work product                        |
| `<skill-name>/references/*.md` | Edit freely — supporting docs                                 |
| `<skill-name>/scripts/*`       | Edit freely — but keep executable                             |
| `originals/*.md`               | **NEVER EDIT** — legacy source material, superseded by skills |
| `README.md`                    | Update when adding/removing skills                            |
| `how-to-write-skills/SKILL.md`       | Update when skill-writing guidance changes                    |

---

## 3. Skill Format Conventions

### 3.1 `SKILL.md` Frontmatter (Required)

The `description` field is **trigger context for the AI agent**, not a description of the skill itself. It must tell Crush _when_ to load and use this skill. If it reads like a feature list or a README sentence, rewrite it.

```yaml
---
name: skill-name # lowercase, hyphens, MUST match directory name
description: > # TRIGGER CONTEXT — tells the agent WHEN to use this skill
  WHEN the user asks about X, says Y, or needs Z.
  Include exact trigger phrases + adjacent contexts + what the agent will do.
  Be explicit and slightly pushy; agents under-trigger.
  Max ~1024 chars.
metadata:
  tags: foo, bar # comma-separated, helps with discovery
---
```

**Critical nuance:** The `description` is read by Crush's skill selection system. It must answer "what user task makes this skill the right tool?" If it is vague, the skill will never activate. If it describes what the skill _is_ or _contains_ rather than _when to use it_, the skill will never activate. Study existing good descriptions in `go-modularize`, `nix-review`, `how-to-golang`, `naming-review`.

### 3.2 Body Style

- **Imperative steps**, not essays. The agent follows instructions literally.
- **Signal density**: every line must map to a tool call, file read, command, or decision branch. Delete self-justifying preamble and decoration; keep the _why_ that flips a decision. Jargon (split brain, ghost system, ...) needs a plain gloss at first use. Canonical rule + glossary: `how-to-write-skills/SKILL.md` Principle 7. Machine help: `scripts/check-skills.sh --signal` (advisory) and check 15 (hard-fails throat-clearing).
- **Keep under ~500 lines**. Move detailed material to `references/` or `rules/`.
- **Reference sibling files** with relative links: `[./references/details.md](./references/details.md)` — the agent will `view` them on demand.
- **Explain the why**, not just the what. Agents follow reasoned instructions more reliably than rigid `ALWAYS`/`MUST`/`NEVER` directives.
- **Define output formats with examples** when producing structured output (reports, plans, etc.).

### 3.3 Progressive Disclosure

| Level             | What's loaded                                  | Cost                                |
| ----------------- | ---------------------------------------------- | ----------------------------------- |
| Metadata          | `name` + `description`                         | ~100 words, always in context       |
| SKILL.md body     | Full instructions                              | <500 lines ideal, loaded on trigger |
| Bundled resources | `references/`, `rules/`, `scripts/`, `assets/` | Unlimited, loaded on demand         |

Large reference files (>300 lines) should include a table of contents at the top.

---

## 4. Authoring a New Skill

1. Read `how-to-write-skills/SKILL.md` at repo root — the authoritative guide.
2. Create `my-skill/SKILL.md` with valid YAML frontmatter.
3. Add optional `references/`, `scripts/`, `rules/`, `assets/` subdirectories as needed.
4. Update `README.md` to include the new skill in the inventory table, and add a row to `FEATURES.md` — coverage is gated (`scripts/check-skills.sh` check 14; an undocumented skill fails the check).
5. Follow the pattern of `how-to-golang` for rich skills (lean SKILL.md + dense references) or `architecture-visualization` for focused skills (short, single-purpose).

---

## 5. Known Gotchas & Non-Obvious Patterns

### 5.1 Legacy Files (`originals/<skill-name>.md`)

The `originals/` directory holds the raw prompt snippets that seeded
this repository, one per skill directory plus a few sub-variants
(`execution-mode-reflective` / `execution-mode-aggressive`,
`pareto-planning` / `pareto-planning-execution-plan` /
`pareto-planning-12min-task-decomposition`). Files are named after the
skill they originally produced, so you can read the seed prompt that
generated any given skill. They are **source material, not canonical**: any edits are wasted work. The skills in `<skill-name>/SKILL.md` are
the canonical versions.

Three original files (`todo-list-builder.md`, `features-audit.md`,
`docs-freshness-check.md`) now seed skills that were consolidated into
`docs-health`. They are kept for historical reference; the canonical
skill is `docs-health/SKILL.md`. A fourth orphan of the same class,
`nix-flake-migration.md` (one-shot "write MIGRATION_TO_NIX_FLAKES_PROPOSAL.md"
prompt), has no skill directory either — its territory is owned by
`nix-review` (flake review + go-standard migration recommendations); found
by the 2026-11-22 originals 1:1 audit, which otherwise confirmed every
remaining seed maps to its skill directory.

`communication-doctrine.md` (added 2026-09-24) is the one original that
seeded a _principle_ rather than a skill directory: the 2026-09-17 user
paste ("SHUT UP AND COMMUNICATE") distilled into `how-to-write-skills/SKILL.md`
Principle 7, the `--signal` report, and check 15. The verbatim paste was
never persisted; the file is a faithful reconstruction from the two
processing reports, and says so in its provenance note.

### 5.2 `git commit <--` Syntax Bug (guarded)

The literal phrase `git commit <--` is banned in every `SKILL.md`: `<--` is not a git flag, it is a typo artifact inherited from the original prompts. Write clear prose instead ("commit with a very detailed message"). `scripts/check-skills.sh` fails if the phrase reappears in any `SKILL.md`; `originals/` is exempt — frozen source material.

### 5.3 Parallelism (resolved)

`brutal-self-review` instructs "Use 1 Sub Agent per file. ONLY 1 at a time." This previously contradicted the removed `execution-mode` skill, which said "Use MULTIPLE Tasks to get multiple Todos done at the same time." With `execution-mode` deleted, the contradiction no longer exists. Do not reintroduce conflicting parallelism guidance when editing either skill. The `docs-health` skill (which absorbed `todo-list-builder`) also instructs sequential sub-agent use for TODO_LIST.md builds.

### 5.4 Thin Skills

Skill depth varies. The authoritative status is the line count and a quality read of each `SKILL.md`; run `scripts/check-skills.sh` to surface the current thin ones. The comprehensive audit in `docs/status/2026-06-17_23-22_comprehensive-status.md` grades every skill and lists what each thin skill is missing. **Read the latest audit before attempting to flesh out a skill** — it contains specific, actionable findings (e.g., "`bdd-testing` needs ginkgo syntax reference, test structure template, file naming conventions").

### 5.5 Inter-Skill References

**Cross-skill link canon (two-tier, decided 2026-11-22 from review finding 6 of the 2026-11-18 interlink pass):** which linking style a handoff uses depends on how the pair distributes. Tier 1 — **independently installed pairs** (per-skill `skills add` copies one directory, so `../other-skill/...` paths dangle): hand off BY SKILL NAME, never by cross-skill file path. Tier 2 — **co-distributed repo pairs pinned by a guard** (status-report → docs-health HARVEST): the linked relative path is canon, and `scripts/check-skills.sh` check 8 FAILS if the link disappears; converting those to name-only would fight the repo's own gate. When adding a handoff, pick the tier by install reality: if either skill is commonly installed alone, tier 1; if a check pins the link, tier 2.

The `full-code-review` skill now delegates planning to `pareto-planning` (previously inlined the same Pareto breakdown — a split brain). `status-report` hands its "next tasks" section (f) to `docs-health` HARVEST — the canonical "run HARVEST after a status report" rule lives **only** in `docs-health` → "When to run HARVEST"; `status-report` links rather than restates (do not duplicate the rationale in both). Several skills reference the shared `html-report-kit` design system for consistent HTML output — the authoritative consumer list is produced by `scripts/sync-html-kit.sh --list` (see 5.9). Do not hardcode that list in prose; it drifts. The Go release pair is bidirectional: `go-release` owns the full release procedure (supply side); `go-ecosystem-upgrade` Phase 6 is a thin pointer to it (demand side) with only ecosystem-specific rules inline. The version-train triangle (2026-10-17) is split by concern, linked both ways: `go-modularize` owns the workspace strategy, `go-release` the release mechanics (tag staircase + go.work replace rules), `go-ecosystem-upgrade` the consumer side of split repos — do not restate any of these in a second skill. `website-launch/references/demo-video.md` defers story doctrine to the third-party `hyperframes-creative` skill — the one repo↔third-party pair; re-check it when either side changes. When adding cross-references, check this graph first.

`docs-health` ANNOTATE and HARVEST modes form a two-way loop over the same status reports and MUST share vocabulary. ANNOTATE resolves items **backward** (marks each `done at` / `Won't implement` / `NOT-DO`, then archives fully-resolved files to `<dir>/archived/`). HARVEST pulls items **forward** into TODO_LIST — and it must **skip any item already carrying a resolution marker** (those are closed; route to CHANGELOG, never re-harvest into TODO_LIST). The marker vocabulary (`done at`, `Won't implement`, `NOT-DO/DUPLICATE`) is owned by ANNOTATE; HARVEST references it, never restates a rival format. (Previously two separate skills — `update-old-docs` and `docs-health` — merged 2026-08-04 to eliminate cross-reference maintenance and the 3× boundary restatement.)

`verify-external-claims` and `verify-before-filing` form an **epistemic-hygiene pair** covering opposite directions of the same failure mode (unverified claims). `verify-external-claims` is **inbound** — verify external tool/library claims before encoding them into your own work. `verify-before-filing` is **outbound** — verify your own diagnosis before proposing changes to an external project. Each skill names the other explicitly; do not duplicate the rationale in both (the inbound/outbound split is stated once in `verify-external-claims/SKILL.md` and once in `verify-before-filing` §8). When adding a new verification-flavored skill, check whether it overlaps this pair before introducing a third angle.

`jj-fork-pr-workflow` pairs with `verify-before-filing` on the outbound direction: it owns the VCS mechanics of upstream contribution (fork setup, the multi-PR sync loop, post-merge cleanup) and hands off to `verify-before-filing` for the diagnosis check before a PR is filed — link, do not restate the rationale.

`github-voice` (added 2026-09-12) is the prose layer over `verify-before-filing`: verify-before-filing gates WHAT to claim before filing upstream; github-voice shapes HOW the issue/PR/comment reads (Lars's voice, derived from a 10k-item corpus of his GitHub writing — every authored issue/PR since 2016 plus sampled comments and revision histories). `verify-before-filing`'s description carries the forward pointer; github-voice's description disambiguates back and also names `jj-fork-pr-workflow`. Its raw corpus lives OUTSIDE the repo at `~/.cache/github-voice-corpus/` (refreshable via its `scripts/`, rate-limit aware) — the repo carries only the distilled profile, and the corpus collector is the only place that knows the GitHub-API findings (REST search date-windowing, GraphQL `userContentEdits`).

`linter-building` (added 2026-09-09) is the authoring counterpart to `code-quality-scan`: code-quality-scan RUNS existing linters over a codebase; linter-building AUTHORS new linters, rules, and configurators. Both descriptions disambiguate each other. It defers general Go stack decisions to `how-to-golang` (its description names it back) and its `references/ecosystem.md` is the authoritative map of the local linter repos (go-finding, go-linter-sdk, the auto-configure pair, reference linters) — edit that map, not scattered prose, when repo states change.

`buildflow` (added 2026-09-14) is the operations counterpart to the analysis skills: it documents USING the BuildFlow quality pipeline in covered projects and which responsibilities BuildFlow absorbs from them (formatting, lint config, go.mod hygiene, nix hash repair, dep updates, pre-commit gate). It disambiguates against `code-quality-scan` one-way — in covered projects plain `buildflow` is the canonical quality gate; code-quality-scan remains for uncovered repos and one-off deep scans — and defers linter authoring to `linter-building`. Developing BuildFlow itself is out of scope (that repo's own AGENTS.md owns it). Its `references/commands.md` was generated from `buildflow --help` output; the binary is authoritative when they drift.

The 2026-09-14 merge assessment found NO further skill-directory merges warranted (the remaining separations are intent-distinct and documented above) but closed three gaps: (1) `architecture-review` ↔ `architecture-visualization` companion-pair disambiguation (shared `docs/architecture-understanding/` output dir: review judges, visualization draws); (2) `status-report` ↔ `brutal-self-review` trigger-collision disambiguation (state inventory vs quality critique — kept separate despite empirically blended reports); (3) deletion of `brutal-self-review/references/go-ecosystem.md`, an orphaned stale fork of `how-to-golang`'s library domain. Full assessment detail: [docs/skill-forks.md](docs/skill-forks.md). When auditing for merge candidates, distinguish directory-level merges (rarely right here) from content-level split brains (orphaned duplicate references) — the latter are the real rot.

`first-customers` (added 2026-10-24; depth wave 2 same day: page-teardown mode, worked example, cold-outreach + waitlist-email references, launch-checklist + copy-brief assets) is the strategy layer over the third-party `copywriting` skill (same layering as `github-voice` over `verify-before-filing`): first-customers owns the 0→1 sales LOOP — stage diagnosis, VoC research, positioning, offer/pricing, page architecture, channels, activation, funnel metrics; `copywriting` owns the page PROSE once structure and messaging are set. `copywriting`'s description dangles a forward pointer to an `offers` skill that was never installed — first-customers' `references/offer-and-pricing.md` is the de-facto answer to that pointer (do not author a separate `offers/` skill without first reconciling with it). Also disambiguates one-way against `website-launch` (docs-site deployment) and `product-launch-video` (promo video asset); those two reference it, not vice versa, since it is the broader funnel. Research sourcing doctrine: page-conversion and PLG numbers are pinned to their sources inline inside the skill's references, and the payments reference records the 2026 market state with a verify-before-relying note — payment-landscape claims drift quarterly, re-verify before advising a specific vendor.

`offer-page` (added 2026-11-10) splits the page layer OUT of first-customers, making the Growth & Sales stack three layers: first-customers (strategy: what to sell, to whom, at what price) → offer-page (page assembly: 9-section arc, cut list, voice gates, page QA, page audit) → copywriting (third-party; line-level prose via offer-page's copy-brief). Page knowledge has exactly ONE owner (the anatomy + copy-brief were git-mv'd into `offer-page/`), and first-customers Step 4 + teardown mode hand off BY SKILL NAME, never by cross-skill file path (per-skill installs make `../offer-page/...` dangle — same rule as the html-report-kit vendoring). Both descriptions disambiguate two-way: first-customers routes page-build/teardown requests to offer-page; offer-page routes missing offer/positioning/proof inputs back to first-customers. Sourcing doctrine: every conversion number traces to a named primary or carries an explicit unverified/secondary marker — the unverified-number ledger and the corrected CTA myth (+68% is wrong; canonical correction + provenance live in `offer-page/references/page-anatomy.md`) live in the skill's references.

`stack-selection` (added 2026-10-27) is the head of a dependency-lifecycle chain, split by stage rather than restated: SELECT (`stack-selection`, project inception: discovers first-party candidates from the `meta` inventory — never a hardcoded list) → POLICY (`how-to-golang`, two-way) → WIRE (per-SDK skills + `buildflow` + `nix-private-go-repos`) → SHAPE (`go-modularize`, one-way) → AUDIT (`library-deep-dive`, two-way) → UPGRADE (`go-ecosystem-upgrade`) → RELEASE (`go-release`). Its output artifact is a living `STACK.md` decision record in the TARGET project, not a point-in-time report. Maintenance: `stack-selection/scripts/stack-drift-check.sh` enforces go.mod ⊆ STACK.md (wired into the skill's done bar and full-code-review); `stack-selection/scripts/capability-map-diff.sh` re-verifies the map against `meta list` — re-run after every meta `lib`-tag/importance change batch (cadence decided 2026-10-27, T65). Known traps encoded in the skill: `meta` tag hygiene is inconsistent (query all projects, intersect importance + keywords) and importance is aspiration, not maturity — verify README + go.mod + tags before selecting.

`design-to-code` (added 2026-11-03) is the engineering layer under the third-party `frontend-design` skill: frontend-design owns aesthetic direction and ends where code begins; design-to-code owns the bridge — token encoding (`@theme` vs `:root`, promote criteria), the utility-first abstraction ladder, Tailwind v4 mechanics (verified against the official docs, with a verification-status table), and quality-floor audits. The disambiguation is one-way by necessity: `frontend-design` and `modern-web-guidance` are upstream-owned (§5.10) and cannot name it back; `website-launch` and `html-report-kit` scopes don't collide. Respects the T62 "install, don't wrap" rule: nothing from frontend-design's SKILL.md is restated — every section adds mechanics that file does not contain.

`architecture-deepening` (added 2026-11-15) is a **local fork, not a wrapper** of the third-party `improve-codebase-architecture` skill (removed from the skills-CLI install the same day; aggregation commit `fa4aeec`). The fork was forced by three upstream findings — missing per-install sibling skills, tmpdir-hardcoded artifact (filed as mattpocock/skills#1437), CDN rendering vs the self-contained doctrine — and the sibling vocabulary lives in its `references/`. Full provenance, evidence pointers, and the open sync/removal decisions: [docs/skill-forks.md](docs/skill-forks.md). Ownership boundary with its companions: `architecture-review` grades the whole structure, `architecture-visualization` draws current vs target with D2, and `architecture-deepening` shortlists refactor candidates and grills the chosen one — all three share `docs/architecture-understanding/` and cross-reference each other in both directions.

### 5.6 `how-to-write-skills/` Skill Directory

Converted to a proper skill directory 2026-11-23 (T94): `git mv how-to-write-skills.md how-to-write-skills/SKILL.md` + frontmatter; the 11 pattern bodies moved to `references/skill-patterns.md` (entry point keeps the summary table, 472 lines). Named `how-to-write-skills/` — NOT `skill-creator/`, which is the third-party upstream skill whose name a repo skill must not collide with (AGENTS §5.10).

### 5.7 No `crush.json` Present

There is no `crush.json` in this repo, so Crush does not auto-discover these skills. Users install them via `pnpm dlx skills add`, `skills_paths` in their own `crush.json`, or by copying directories into `~/.config/crush/skills/`.

### 5.8 `allowed-tools` Frontmatter Field

`pareto-planning` uses `allowed-tools: d2` to pre-approve the D2 CLI for graph rendering. Consider adding it to other skills that rely on specific CLI tools (e.g., `art-dupl` for `deduplicate-code`, `d2` for `architecture-visualization`).

### 5.9 Shared HTML Design System (`html-report-kit`)

Skills that produce point-in-time reports write self-contained HTML files instead of Markdown, using a shared design system so every report shares the same visual language. The kit uses the **Bauhaus** design language: primary colors (red, blue, yellow) on a neutral ground. Two variants: **Bauhaus Dark** (status dashboards, scan results, high-density metrics — graphite ground + primary accents) and **Bauhaus Light** (adoption feedback, architecture reviews, audit briefs — warm paper + primary color blocks). Both share the same component vocabulary: stat/score cards, issue cards, severity badges, callouts, strengths lists, dep-trees, tables, before/after comparisons, syntax highlighting, hero with optional geometric shape cluster (circle/square/triangle/bar).

**Variant assignment is a gate, not a preference.** Which consumer gets which variant is decided once, in the `variant-assignments` table of [`html-report-kit/references/html-output-guide.md`](html-report-kit/references/html-output-guide.md), and enforced by `check-skills.sh` check 17: a skill whose links contradict its row, a consumer that never vendors its assigned template, and a skill naming a template that does not exist all fail. The push behind the gate: on 2026-11-16 five consumers (`architecture-review`, `brutal-self-review`, `data-model-review`, `full-code-review`, `naming-review`) linked the dark dashboard while the kit's mapping assigns editorial to reviews and audit briefs — a link checker cannot see that bug, because the wrong file exists. Series continuity stays an explicit override: an existing report series keeps its variant, and the assignment governs the first report.

**Unified token vocabulary (post-Bauhaus migration):** both templates share the same semantic token names — `--surface`, `--surface-raised`, `--surface-sunken`, `--text`, `--text-muted`, `--text-faint`, `--border`, `--border-strong`, `--accent`, `--problem`, `--solution`, `--warning`. Only the primitive values differ between dark and light. The previous split-brain tokens (`--bg-elevated`/`--rose` in dark vs `--bg-card`/`--coral` in light) are preserved as **backward-compatible aliases** so consumer skills that reference old names keep working. See [`html-report-kit/references/bauhaus-tokens.md`](html-report-kit/references/bauhaus-tokens.md) for the full spec.

**`color-mix()` replaces glow tokens:** instead of paired `--rose` + `--rose-glow` tokens (8 redundant, drift-prone values), translucent variants derive on demand via `color-mix(in srgb, var(--problem) 15%, transparent)`. Browser support: Chrome 111+, Safari 16.2+, Firefox 113+.

**Optional scrollspy:** both templates ship a tiny IntersectionObserver script (~20 lines) that highlights the active sidebar item. It's progressive enhancement — plain `<a href="#section">` anchor links work without JS. Auto-discovers any `[data-nav]` container.

**Sharp corners:** `--radius: 0` is the Bauhaus default. Override per-report if needed.

**The Artifact decision rule** (encoded in `how-to-write-skills/SKILL.md`): Snapshot + HumanReport → HTML; Living + ToolParsed/EndUserDoc → Markdown. Never convert living docs (`FEATURES.md`, `TODO_LIST.md`) to HTML.

#### Vendoring model (fixes per-skill install)

The Agent Skills spec has **no dependency system** — each skill is installed as a flat, self-contained unit. `bunx skills add LarsArtmann/SKILLS@<one-skill>` copies only that one directory, so a `../html-report-kit/...` sibling path dangles and the kit appears not to exist. To make every consumer work in every install mode (per-skill add/update, clone, `skills_paths`), the kit is **vendored** into each consumer:

| Role                      | Path                                 | Edit?                               |
| ------------------------- | ------------------------------------ | ----------------------------------- |
| Canonical source of truth | `html-report-kit/`                   | **Yes** — edit here                 |
| Vendored copy             | `<consumer>/assets/html-report-kit/` | **No** — regenerated build artifact |

Consumer skills reference the kit intra-skill via `./assets/html-report-kit/references/html-output-guide.md` and `./assets/html-report-kit/assets/report-template.html`. The canonical `html-report-kit/SKILL.md` is **excluded** from vendored copies so the skills CLI never mistakes a vendored directory for a standalone skill.

#### Sync workflow

After editing the canonical kit, re-vendor into every consumer and verify:

```bash
./scripts/sync-html-kit.sh          # regenerate all vendored copies
./scripts/sync-html-kit.sh --check  # CI: exit 1 if any copy drifted
./scripts/sync-html-kit.sh --list  # show consumers (authoritative list)
```

When a new skill needs HTML reports: (1) reference `./assets/html-report-kit/...` from its `SKILL.md`, (2) run `./scripts/sync-html-kit.sh` to populate the vendored copy — the script auto-discovers any `SKILL.md` that mentions `html-report-kit`.

**Splice workflow (2026-11-24):** report authors write body fragments only and inject them into the untouched template shell via `html-report-kit/assets/splice-report.sh` (`--extract`, `--self-test`); the ~830-line stylesheet is never agent-authored, so token drift is structurally impossible (manual template-copy remains the shell-less fallback). Span contract: the script header and the guide's Splice Workflow section — consumers link it, never restate it. The 2026-11-22 `splice_report.py` prototype was removed, restoring the no-Python state (§5.11).

### 5.10 Runtime Sync Model — Symlinks, Not Copies

`/home/lars/projects/SKILLS/` is the **only** copy of these skills. The runtime dir `~/.agents/skills/` holds a **relative symlink** per repo skill (`../../projects/SKILLS/<skill>`), so an edit in the repo is live in every agent (Crush, Codex, Cursor, ...) instantly — there is no sync step and no drift is possible. `~/.config/crush/skills/<skill>` chains through `~/.agents/skills/` (double indirection resolves fine).

**Third-party skills are different:** `copywriting`, `find-skills`, `frontend-design`, `skill-creator`, plus the 10-skill HeyGen suite (`hyperframes`, `-animation`, `-audio`, `-cli`, `-core`, `-creative`, `-keyframes`, `-registry`, `media-use`, `product-launch-video`) are real directories in `~/.agents/skills/`, installed and tracked by the [skills CLI](https://skills.sh) via `~/.local/state/skills/.skill-lock.json` (15 entries as of 2026-09-13; `product-launch-video` was added after the 2026-08-21 verification). They are updated **manually** with `skills update -g` and must never be edited by hand or added to this repo. The 2026-08-14 status report called these "orphans" — they are not; they have upstream sources in the lockfile. `improve-codebase-architecture` used to be on this list; it was removed 2026-11-15 because its local fork `architecture-deepening` owns the job (§5.5).

**A second install channel exists (2026-10-30):** `modern-web-guidance` (MWG) — Google Chrome's web-platform guide library — is a real directory in `~/.agents/skills/` with its OWN installer and lockfile (`~/skills-lock.json`), so it never appears in the skills-CLI lockfile: "third-party" means upstream-owned, not "tracked by one particular tool". Install/update from `$HOME` (`pnpx modern-web-guidance@latest install|update`); never author a wrapper skill for it here. Full channel detail, project-scoping trap, offline retrieve, and uninstall proof (2026-11-22): [docs/skill-forks.md](docs/skill-forks.md).

**MWG policy, decided 2026-10-30:** one global install at `$HOME` (per-site installs would duplicate the 1.9 MB guide tree), installed tree committed to the aggregation repo, telemetry off via `DISABLE_TELEMETRY=1` in `~/.env.private`.

**`skills update` can report a false green (hit 2026-11-03; trigger reproduced 2026-11-23, T103):** "All global skills are up to date" while upstream HEAD had moved months ahead. Reproduced mechanism: a per-source tree-fetch failure prints `✗` but still concludes "✓ up to date", and `skillFolderHash` is never consulted — the hash is bookkeeping, not a drift check. The reliable refresh is re-add (`skills add <owner>/<repo>@<skill> -g -y`); verify freshness by diffing against `gh api repos/<owner>/<repo>/contents/<path>`, never by trusting update output. `skills remove --all -g` is symlink-safe for the repo-skill fan-out (isDirectory-only scan) but leaves stale lockfile entries (v1.5.22). The corrected mechanism analysis (the first diagnosis was wrong), the unconfirmed-trigger candidates, and the upstream-moves-strand-locals observation live in [docs/skill-forks.md](docs/skill-forks.md) — do not file upstream on the old mechanism claim.

**Skill discovery is a session-start snapshot, so an install is invisible until restart.** Never judge an install by the current session's skill list — probe a new session (`crush run`; `~/.agents/skills/` alone suffices).

**The aggregation dir is itself a git repo**: `~/.agents/skills/.git` points at `git@github.com:LarsArtmann/agent-skills.git` (tracks repo skills as symlink entries, third-party skills as real files). New repo skills show up **untracked** there until someone commits the aggregation layer — cosmetic, not drift; the symlinks are what matters. Do not "clean" the `.git` away. **What needs an aggregation commit** (2026-11-10): only link/dir topology changes — new skill's symlink, removed skill, vendored third-party update. Content edits propagate instantly through the symlink; the aggregation repo versions the pointer, not the content.

**Empirically verified 2026-08-21 + 2026-09-13:** `skills ls -g` lists ALL skills (lockfile-tracked ones show their GitHub source; own skills show `Source: local`), and `skills update -g` leaves every own-skill symlink byte-identical (target + identity diffed; `link-skills-to-agents.sh --check` green both times). The 2026-09-13 run's third-party diffs + 4 new own-skill symlinks were committed to the aggregation repo (`agent-skills`, `1d897b7`).

**Rules:**

1. NEVER edit anything under `~/.agents/skills/` or `~/.config/crush/skills/` — the repo is canonical. Editing a runtime copy either edits the repo through the symlink (confusing) or forks a third-party skill (drift).
2. Own skills are **not** in the lockfile (removed 2026-08-14). If a future `skills add` ever reinstalls one, it will `rm -rf` the symlink and leave a real directory — recover with `scripts/link-skills-to-agents.sh --force`.
3. Link state is managed by `scripts/link-skills-to-agents.sh` (`--check` for CI/verification, `--list` to inspect, default mode is idempotent repair). The old `sync-skills-to-agents.sh` rsync script is deleted — copying is exactly the drift this model eliminates.
4. Adding a new skill: create the directory here, run `scripts/link-skills-to-agents.sh`. Done.
5. Removing a skill: `git rm` the directory, then remove the `~/.agents/skills/<skill>` symlink.
6. Always read AND edit skill files through the repo path. Edit tools track paths, not symlink identity — reading via `~/.agents/...` or `~/.config/crush/...` then editing via the repo path fails with "file modified since last read" (hit 2026-08-14 and again 2026-08-21).
7. `~/.config/crush/skills/` also holds three one-off entries that are neither repo skills nor drift: `font-design` (→ a project-local skill, DiscordSync), `go-cqrs-lite` (→ the go-cqrs-lite repo's own working checkout at `~/projects/go-cqrs-lite/.agents/skills/go-cqrs-lite`; repointed from the nix store by that repo, verified 2026-11-10 — still satisfies the never-pin-to-store rule), `templ-components` (real directory). Do not "repair" them.

### 5.11 buildflow Runs Over This Repo (external tool)

Lars runs buildflow (a build-automation tool, nix-provisioned) against this
repo. The repo carries a minimal `.buildflow.yml` — quality-gate config, not
a build system; §9 still bans go.mod/CI/package managers. Its only
non-default setting skips `go-structure-linter` (recorded deliberate
non-fix): that tool's repo-level Go-project rules (mandatory `go.mod`,
`.golangci.yml`, `internal/` layout) contradict this docs-only repo by
design. Per-file Go quality is verified per convention: `go vet` + `gofmt`

- `--self-test`. What agents must know:

* **No Python left (2026-10-11):** all 12 former `.py` script assets were
  converted — docs-health annotators → `docs-health/assets/annotate.go`
  (one Go program, subcommands `rows`/`prose`/`status-items`/`emit-keys`/
  `check-rows`/`self-test`), github-voice corpus tooling →
  `github-voice/scripts/{check-draft,analyze-corpus,collect-corpus}/*.go`,
  gmail-drafts → `scripts/gmail_{drafts,eml_export}.sh` (bash + curl + jq).
  ruff has nothing to scan anymore; `buildflow -s ruff-check-fix --format
  finding` now returns exit 0 with a `[Rejection:tool.not_applicable]`
  note ("no files matching: **/*.py") — that rejection IS the green state.
  Conversion was verified equivalence-style: old Python vs new Go/shell
  ran side-by-side on fixtures and the real corpus (byte-identical
  markdown corpus, semantically identical JSON).
* linter-building eval fixtures are real Go modules under
  `linter-building/evals/*/fixture/`: keep their `go.mod` module paths
  dotted (`example.com/fixture/tiny` — gomod-check rejects dotless paths)
  and never commit the `tiny` binary that eval runs build there (gitignored
  via `**/fixture/tiny`).
* Green-but-noisy steps: markdownlint lists hundreds of MD013/MD010
  advisories and still exits ✔; shellcheck warns (SC2319, SC2089/SC2090)
  on `jj-fork-pr-workflow` and `naming-review` scripts and still exits ✔.
  Read exit codes, not output tails.
* lychee's two permanent findings, both unfixable by design: `localhost:4321`
  (`website-launch` documents the Astro dev server, which only answers while
  that server runs) and `[REPO_OWNER]` in `originals/` (frozen placeholder,
  never edited). Attempted 2026-10-30: a repo-level `lychee.toml` /
  `.lychee.toml` exclude list has **no effect** — the BuildFlow step does not
  read repo config, so the config was removed rather than left as dead policy.
  It can also hard-fail the whole run (buildflow exit 69) when a real host is
  unreachable: `crush.land` did on 2026-10-30 and was replaced with the live
  upstream URL.
* `dprint-format` is SKIPPED in `.buildflow.yml` (2026-11-15, same class as
  the lychee entry): BuildFlow's full-pipeline executor stages a copy of the
  repo WITHOUT repo config files (`format_roundtrip.go` in the BuildFlow
  repo), so its dprint step formats on a generated exclude-less config and
  REWRITES frozen eval output artifacts (`**/outputs/**`, `*-workspace/`) —
  observed 4× on 2026-11-15, twice laundered into history by the auto-commit
  daemon and restored (`5e585c4`, `7ce09d9`); it also crashes on tables
  nested in list items in archived reports. Formatting discipline is manual:
  `dprint fmt <files>` with the repo `dprint.json`, whose excludes encode the
  frozen/live boundary (archived status/planning reports, eval outputs,
  workspaces). The local pre-commit hook carries a frozen-evidence guard
  that fails any commit staging a file under an eval `outputs/` dir without
  `FROZEN_OK=1` (validated both directions 2026-11-15; hook is local-only —
  recreate it after fresh clones, see the hook file header; it covers only
  agent/human commits — the daemon bypasses hooks entirely, §5.12).
* **Round 5 (2026-11-22) root-caused: the corruptor was `tailwind-build`,
  not dprint.** With dprint-format skipped, a pipeline run still rewrote
  four frozen design-to-code eval css files — `tailwind-build` regenerates
  them with tailwindcss v4.3.3, SEMANTICALLY changing frozen artifacts; the
  daemon laundered it into `3123c19` within 40 seconds (restored
  `a917805`). Round 4 is most plausibly the same step in a non-fix run;
  full evidence in the 2026-11-22 status report. `tailwind-build` AND `prettier-format` are therefore SKIPPED in
  `.buildflow.yml` (prettier by mechanism: `buildflow --fix` would run
  `prettier --write` on the same files with no exclude mechanism in the
  staged copy). The skip entry in `.buildflow.yml` carries the full
  evidence. Correcting the record: the "dprint corruption" incident class
  was tailwind-build corruption for at least rounds 4-5; rounds 1-3
  followed `buildflow --fix` runs where BOTH dprint and tailwind ran.
* The findings gate: a plain `buildflow` run here exits 69 from exactly 4
  `file-size-check:go-file-too-large` findings on the deliberate
  single-file Go assets (`docs-health/assets/annotate.go`,
  `github-voice/scripts/*/**.go`) — T69 owns the triage; splitting them
  would contradict §1. All steps ✔ with exit 69 = this repo's green.
  T69's remaining advisory triage (2026-11-22, recorded deliberate
  non-fixes): **art-dupl (6)** — 10-14-token duplicate pairs inside
  `annotate.go` (4) and `analyze-corpus.go` (2): the threshold-sized
  clones are the marker-grammar tables recurring across subcommands of a
  deliberately single-file program (§1); deduplicating them into shared
  funcs adds indirection the one-file-per-program rule exists to avoid.
  **jscpd (3)** — `gmail_drafts.sh` ↔ `gmail_eml_export.sh` share
  19-35-line helper blocks (b64url/rfc2047/http plumbing): the scripts are
  DELIBERATELY standalone because the export path copies one script alone
  to `/tmp` for the `sudo -u inboxclean` run — a sourced common file would
  dangle at exactly that call site. Both stay advisory noise by design;
  treat count GROWTH as new damage, the counts themselves as pinned.
* `docs-health/assets/annotate.go self-test` runs the ported
  marker/guard/prose assertions; `docs-health/assets/annotate-status-items_test.sh`
  is the 26-assertion fixture harness against the Go program; both gmail
  scripts carry a `--self-test` mode (RFC 2047/MIME/header helpers, no
  network).

### 5.12 Auto-Commit Daemon Bundles Concurrent Hunks

An auto-commit daemon commits working-tree changes in this repo on a timer
with a heuristic message ("chore: auto-commit N changed file(s)"). Two
consequences for agents:

1. Your uncommitted edits may already be local commits by the time you
   write "uncommitted" in a status report — run `git status` + `git log`
   immediately before claiming repo state (hit 2026-10-30: a hand-off
   reported skill edits as uncommitted after the daemon had committed
   them).
2. The daemon commits everything dirty, including another session's hunks:
   the go-modularize rebalance (`7eeeac7`) was committed bundled with a
   foreign one-line `buildflow/SKILL.md` lesson from a parallel session.
   Path-scoped edit discipline therefore only holds until the daemon
   wakes; scope control for bundled commits happens at push review, not
   in the working tree.
3. **The daemon's commits bypass ALL git hooks** (verified 2026-11-22 by
   service-unit source read, T133): the daemon is
   `projects-management-automation` (system service,
   `/etc/systemd/system/projects-management-automation.service`) and runs
   git with `core.hooksPath=/var/empty` via `GIT_CONFIG_KEY_0/VALUE_0` —
   the §5.11 pre-commit frozen-evidence guard can NEVER fire on a daemon
   commit. The hook protects only agent/human commits; against daemon
   sweeps the ONLY defenses are the dprint.json excludes and the
   `.buildflow.yml` skip. If a formatter corrupts frozen evidence again,
   expect the daemon to commit the corruption — check `git log` for
   heuristic commits before assuming a live process (2026-11-15 round-4
   rule stands). Live test deliberately not performed: it would require
   deliberately committing corrupted frozen evidence.

### 5.13 docs-gates Battery Adopted Repo-Side (2026-11-10)

The five docs-health gates run as the standalone binary:
`nix run github:Artmann-Technologies/docs-gates -- run .` — the canonical
quality gate for documentation health, alongside `scripts/check-skills.sh`
(structure). **annotate is pinned** via `.docs-gates.json` `annotate_max: 372`
— a measured-debt ratchet, not a green light. The findings are almost
entirely the pre-canon archived corpus, cell-boundary strikes in
`docs/planning/archived/`, cross-repo path verdicts, and F/spacing lines in
point-in-time artifacts that should not be rewritten: a long-lived archive
legitimately holds pre-canon files — do NOT "repair" them wholesale; drain
the ratchet only via a dedicated corpus campaign, and treat any count ABOVE
the pin as new damage (it fails red on regression; measured 360/372 on
2026-11-22). The 2026-11-10 corpus sweep archived 90 reports
(2026-06→2026-10 + both June HTML snapshots + the reviews HTML) with
every item struck-with-verdict, won't-implement, NOT-DO, or routed;
`docs/status/` now holds only the recent 5, and routed items live in
TODO_LIST T71–T121 + ROADMAP (Open Questions + themes 9/10). Pre-flight
TODO/ROADMAP rows with `docs-gates freshness . --pre-flight` BEFORE
writing them — candidate lines can genericize tokens other reports
depend on (hit 7× on the first draft, 2026-11-10).

---

## 6. High-Value Reference Files

| File                                                         | Why It Matters                                                                                                                           |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `how-to-write-skills/SKILL.md`                                     | Complete guide for skill authoring — frontmatter rules, description-as-trigger, progressive disclosure, common mistakes                  |
| `docs/status/2026-05-03_07-51_comprehensive-skills-audit.md` | Master audit: every skill graded, every issue catalogued, top 25 next tasks ranked by impact. Read this before any bulk improvement work |
| `go-modularize/SKILL.md`                                     | Best example of a rich, well-structured skill with concrete examples, decision tables, and failure mode catalog                          |
| `nix-review/SKILL.md`                                        | Best example of a checklist-driven review skill with severity guide                                                                      |
| `how-to-golang/SKILL.md`                                     | Best example of a reference-heavy skill: 103-line entrypoint + 10 reference files (incl. `performance-tuning.md`)                        |
| `how-to-golang/references/`                                  | Pattern to emulate for domain-specific deep dives                                                                                        |
| `naming-review/SKILL.md`                                     | Best example of a multi-step review with automated detection → manual review pipeline                                                    |

---

## 7. Git Conventions

- **Main branch:** `master`
- **Remote:** `git@github.com:LarsArtmann/SKILLS.git`
- **Commit style:** Very detailed commit messages (this is explicitly requested in several skills)
- **Commit ownership (DECIDED 2026-10-27, T34 g3):** the agent commits session
  artifacts (status reports, skills, eval evidence) itself with detailed
  messages; the auto-daemon's heuristic commits are the floor, not the
  ceiling. `originals/` stays untouched either way.
- **Clean history:** Logical commits, descriptive messages (the project values this)

---

## 8. When Improving This Repo

Before making changes:

0. **Execute `SESSION-START.md`** (repo root) — the mandatory session-start
   checklist: scan `docs/feedback/new/`, open the newest `docs/status/`
   report, read `TODO_LIST.md`. Skipping these steps is a documented
   failure mode (see `docs/status/2026-09-08_20-39_*` d6); the checklist
   exists so they are executed, not recalled.
1. Read `docs/status/2026-05-03_07-51_comprehensive-skills-audit.md` — it contains the authoritative backlog.
2. If fleshing out a thin skill, study `how-to-golang` or `go-modularize` as the pattern.
3. If adding cross-references, check the audit's "Inter-skill cross-references" section for the intended graph.
4. If fixing the `git commit <--` bug, check all four affected skills.
5. If converting `how-to-write-skills/SKILL.md` to a skill, read the guide itself — it describes the expected directory structure.

---

## 9. What NOT to Do

| Don't                                                            | Why                                                |
| ---------------------------------------------------------------- | -------------------------------------------------- |
| Add a build system (Makefile, package.json, go.mod)              | This repo has no compilable code                   |
| Edit `originals/*.md`                                            | Legacy source material; skills are canonical       |
| Add tests or CI                                                  | No runnable code to test                           |
| Rename skill directories without updating `name:` in frontmatter | Crush matches directory name to frontmatter `name` |
| Write vague `description` fields                                 | The skill will never activate                      |
| Put >500 lines in a single `SKILL.md`                            | Wastes context tokens; use `references/`           |
| Use rigid `ALWAYS`/`MUST`/`NEVER` without explaining why         | Agents follow reasoning better than commandments   |

---

## 10. External Dependencies Referenced by Skills

Skills reference external CLIs and private repos that are **not** bundled here; verify availability before relying on them, and treat private tools (`erraudit`, `go-nix-helpers`, `branching-flow` analyzers, `samber-do-auditlog`) as unverifiable until checked against local source. Full tool table + verification notes: [docs/external-dependencies.md](docs/external-dependencies.md).

## 11. Feedback Loop — `docs/feedback/`

Unprocessed feedback lives in `docs/feedback/new/`, resolved feedback in `docs/feedback/processed/`. Scan `new/` before starting multi-step work. When a pattern appears 2+ times across feedback files, create the skill — never a third feedback file proposing one — then move the sources to `processed/`. Full doctrine: [docs/feedback-loop.md](docs/feedback-loop.md).

## Note

- This is a content repository -- no traditional build/test system
- Validation: check YAML frontmatter format and skill structure manually
