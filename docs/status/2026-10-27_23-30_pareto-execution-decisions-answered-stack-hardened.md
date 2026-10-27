# 2026-10-27 23:30 — Pareto plan execution: decision package answered + stack-selection trilogy complete

Scope: THIS session (~22:00–23:30). Input: the user pasted
`docs/planning/2026-10-27_21-56_SUPERB-PARETO-DECISION-UNBLOCK-AND-STACK-HARDENING-PLAN.md`
and demanded read → understand → break down → execute → verify, repeat.
Executed: P1–P6 complete + all decision-quick-executions (P10, P11, P14,
T66). P7–P9 (website-launch template build, ~4 h) and P12 (site media,
separate repos) remain for a dedicated session; P13 is externally blocked.
Format: `.md` — first report under the NEW default (decision D.g4, flipped
this session).

## P1 / T64 — the 1%→51%: consolidated decision package

`docs/decisions/2026-10-27_open-decisions.md` — all 14 open decisions,
one evidence-verified recommendation each, answered by the user in one
sitting (3 question batches):

| Cluster | Verdicts |
| ------- | -------- |
| website-launch Q0–Q5 | Go SSG baseline → private `website-template` repo; `websitelaunch` CLI in Go stdlib-only; gogenfilter rebuilt on template later; T33 kept separate (user: "do what the smartest is") |
| linter-building B.g1–g3 | Stay Go-first; two-stage aging (synthetic eval → 🟡, real run → 🟢); agent commits session artifacts with detailed messages (daemon = floor) |
| Glossary C/T51 | **VERBATIM lockstep** (user overrode the semantic recommendation) |
| ROADMAP D.g1–g4 | Backup trashed (executed via `trash`); third-party stays upstream-managed; pre-commit link hook; status-report default `.md` |

Routing executed: verdicts table filled; ROADMAP g-questions closed with
decided-notes (2026-08-14 g1–g3, 2026-08-16 g2, 2026-09-18 g2); TODO_LIST
flipped (T34/T51/T57 unblocked); T64 closed; T66 created; CHANGELOG.

## P2 / T60 — behavioral evals: 16/16

4 subagent runs (evals 1–2 × with-skill/baseline, spawned same turn).
With-skill honored every how-to-golang ban the baselines violated
(fsnotify, yaml.v3, testify), applied adoption-beats-importance
(go-business-rules 80/zero consumers → excluded), rejected a lib for
FAILING the existence check (segment-buffer), and produced full STACK.md
records. Eval 2 (the hard multi-lib case) chose cqrs-htmx v4 + go-cqrs-lite
system/metaengine + templ-components + Money + branded IDs and excluded 19
libs incl. six 90+-importance ones. Two skill improvements applied from
findings: meta-unavailable fallback ladder (Phase 1) and out-of-repo
owning-skills note (map legend). Timing honestly recorded N/A (agent tool
reports no wall-clock). Evidence: `stack-selection-workspace/iteration-2/`.

## P3 / T62 — drift check: ghost system killed

`stack-selection/scripts/stack-drift-check.sh` (exit 0 clean / 1 undeclared
or contradicted / 2 no STACK.md); 4 fixtures all correct; validated against
the eval-1 STACK.md (PASS); wired into SKILL.md done bar, STACK-template
header, and full-code-review (declared-architecture step). Measured
baseline: **0 of 163** larsartmann-consuming projects have a STACK.md.

## P4 / T61 — trigger eval: 20/20 at round 1

10 should-trigger (typos, lowercase, re-align phrasing) + 10 near-misses
(vs how-to-golang, library-deep-dive, go-ecosystem-upgrade + boundaries).
Subagent matcher round 1: perfect score → plateau, description unchanged,
rounds 2–3 skipped per stop-when-plateau. STRONG preserved, gate green.

## P5 / T63 — aggregation layer

Symlink committed on master (4100313) via temporary worktree; the main
`~/.agents/skills` checkout stayed on its WIP branch untouched; worktree
removed; `link-skills-to-agents.sh --check` EXIT 0. NOT pushed (no request).

## P6 / T65 — capability-map re-verify

New `scripts/capability-map-diff.sh` (live meta diff, classified deltas).
Reconciled: +13 rows (go-retry — the lib eval-1 chose but the map missed —
plus smart-configs, go-sqlitestore, go-credentials-store, go-graph-rag,
go-hotspot, code-duplicate-analyzer, go-humanize-linter, go-auto-upgrade 90,
go-version-auto-configure, go-workflow-auditlog, go-paperless,
go-website-template), 0 stale. Map 55→68 rows; Known-gaps extended
(template-* ceremony family, collector-utils Rust-only, buildflow-pr44
worktree artifact, combined-row script caveat). Cadence recorded in
AGENTS §5.5.

## Decision executions

- **T51/P10:** all first-use glosses aligned VERBATIM to the Principle 7
  table across 6 skills; residual grep zero; `--signal` EXIT 0.
- **T34/P11:** Go-first note in linter-building SKILL.md; two-stage-aging
  legend in FEATURES; commit-ownership rule in AGENTS §7.
- **P14:** status-report default flipped to `.md` (HTML = dashboard-shaped
  only); FEATURES + README rows updated.
- **T66:** `.git/hooks/pre-commit` link guard installed, verified green.

## Verification (exit codes quoted)

- `check-skills.sh` EXIT 0 (33 skills); `--triggers` EXIT 0;
  `--signal` EXIT 0; `link-skills-to-agents.sh --check` EXIT 0.
- Drift-check fixtures: 0/1/1/2 exactly per contract.
- Session artifact commit: `3b5af2e` (34 files, +1339/−77) — agent-owned
  detailed message per decision B.g3 (survived one index.lock race with the
  auto-daemon; retried clean).
- Worktrees: aggregation worktree removed; none stale.

## Open items / honest limits

- **P7–P9 remain** (website-launch template chain — now fully ungated by
  Q0–Q5; needs its own session; CI-green acceptance will require a push
  request). **P12** (T33 site media, separate repos) and **P13** (T30,
  externally blocked on a real upstream PR) unchanged.
- Trigger eval: single matcher simulation, single run (recorded as a known
  limit in `trigger-eval-results.json`; 3× sampling deferred).
- Eval subagents had no shell: meta registration and timing unmeasurable —
  self-reported in every output, adapted honestly.
- The `question`-tool batches presented 14 decisions in 3 rounds, not
  literally one screen (tool caps 5/batch) — same sitting, minimal friction.

## Self-review

What did I forget? Considered executing P7 now; rejected — a 4-hour
extraction at session tail risks a half-done state (the plan's own
Verschlimmbesserung guard), and its acceptance needs a push. What could be
better? The capability-map diff script misses combined rows (documented
in Known-gaps instead of over-engineering the parser). Did I lie? No —
every number above traces to a quoted exit code or a committed artifact.
