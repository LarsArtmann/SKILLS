# 2026-10-27 21:40 — stack-selection: foundation-selection skill for new projects

Scope: THIS session (21:27–21:40). User ask: "better skills for figuring out
all the SDKs and Libs and Go my projects should be built on top of — smartly
interconnected systems, especially for new projects. Start with `meta list
--sort-by importance --tags lib` and review all."

## What was built

New `stack-selection/` skill (33rd repo skill) — the missing HEAD of the
dependency lifecycle. Nothing previously covered project-inception selection:
`how-to-golang` is per-decision policy, `library-deep-dive` audits after
adoption, the per-SDK skills (cmdguard, go-cqrs-lite, cqrs-htmx, go-aichat,
templ-components) assume the lib is already chosen.

| File                                           | Content                                                                                                       |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `stack-selection/SKILL.md`                     | 168 lines, 7 phases: profile → meta discovery → capability match → policy → decide → emit STACK.md → wire     |
| `stack-selection/references/capability-map.md` | 67 first-party libs in 11 categories, README-verified 2026-10-27, with owning-skill + when-NOT-to-use columns |
| `stack-selection/assets/STACK-template.md`     | Living decision record: profile, chosen foundation (why-this-not-that), deliberately-excluded, wiring order   |
| `stack-selection/evals/evals.json`             | 3 evals (lib-watching CLI, event-sourced web app, one-shot YAGGI script)                                      |

## Research findings encoded in the skill (the "review all" part)

- `meta` tracks 279 projects; the `lib` tag covers only 58 and MISSES real
  foundations (`go-daemon` importance 74 with ZERO tags, `erraudit` 90,
  `template-*`). The skill hard-codes the lesson: query everything,
  intersect importance ≥ 55 + profile keywords, never trust one tag filter.
- Importance is aspiration, not maturity: `actaflow` rates 63 and is NOT ON
  DISK at all. The skill requires README + go.mod + `git describe --tags`
  verification before any selection.
- Adoption evidence: the go.mod grep is the real signal (measured 2026-10-27:
  go-cqrs-lite 45 consumers, go-output 43, cmdguard 27). The meta-tag route
  (`meta list --tags cmdguard` → timesheets) has n=1 coverage — most projects
  do not tag their deps; corrected in the skill the same evening during the
  brutal self-review after measuring.
- Every `meta` command the skill prescribes was executed and verified this
  session (`list --format json`, `get`, `list --tags`, `search`, describe).

## Interconnections (two-way where paired, one-way where lifecycle)

- `how-to-golang` Process now routes whole-foundation/new-project questions
  to `stack-selection`; `stack-selection` Phase 3 consults how-to-golang and
  never restates the policy.
- `library-deep-dive` Phase 6 names `stack-selection` as its inception
  counterpart (select-before vs audit-after).
- Lifecycle chain documented in both the skill and AGENTS.md §5.5:
  SELECT → POLICY → WIRE → SHAPE (`go-modularize`) → AUDIT → UPGRADE → RELEASE.
- `meta` CLI added to `docs/external-dependencies.md` (verified on PATH).
- AGENTS.md §5.5 graph entry, README row (Go Ecosystem) + stale-prose fix
  (the 🆕 count said eight, was already missing first-customers — now ten),
  FEATURES.md row (🆕 NEW), CHANGELOG entry.

## Verification

- `scripts/check-skills.sh` EXIT 0 (33 skills, 171 md files, no broken
  links); `--triggers` EXIT 0 (STRONG, 11 markers); `--signal` EXIT 0
  (preamble=15, prose=1, filler=0, jargon=0).
- One real failure caught and fixed: description was 1057 chars (limit 1024 —
  "Crush will refuse to load this skill"); trimmed to fit, gate re-run green.
- `scripts/link-skills-to-agents.sh` + `--check` EXIT 0; skill readable
  through the fan-out path (`readlink -f` resolves, frontmatter intact).
- Degraded self-run (skill-creator no-subagent fallback) of eval 3 executed
  the full procedure: produced the YAGGI-correct minimal stack (stdlib csv +
  json/v2 + marginal go-must) with explicit exclusion rows for cmdguard (92),
  go-output (90), universal-workflow (92), go-taskqueue. Fixture committed at
  `stack-selection-workspace/iteration-1/eval-one-shot-csv-to-json/with_skill/outputs/STACK.md`.
  Evals 1 and 2 NOT run (need subagents) — the behavioral gap remains.

## Open items / honest limits

- Evals 1–2 unexecuted; trigger-eval set (should-trigger/should-not pairs for
  description optimization) not built. The capability map will drift as libs
  are added — it says so itself and defers truth to `meta`.
- ROADMAP had NO pre-existing stack/foundation/scaffold idea to reconcile
  (grepped) — nothing marked.
- Aggregation repo (`~/.agents/skills`) is on stale branch
  `docs-health-verify-legs` with third-party WIP modifications; per the
  2026-10-24 lesson I did NOT commit there. The `stack-selection` symlink is
  live (verified); committing the aggregation layer is cosmetic, do it next
  time master is checked out there.
- The `meta set` registration step (Phase 6 last bullet) is prescribed but
  was not exercised — no real new project existed to register this session.

## Self-review

What did I forget? Considered hardcoding a top-N lib list in SKILL.md and
rejected it (AGENTS §5.5 anti-drift doctrine — meta is truth, map is
navigation). What could be better? Eval 2 (event-sourced web app) exercises
the cqrs-htmx path and is the highest-value next test run. Did I lie? No —
every number above is from a command output quoted in this session; the one
degraded run is labeled degraded, not full.
