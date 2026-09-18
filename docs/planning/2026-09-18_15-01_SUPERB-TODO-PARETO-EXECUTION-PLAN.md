# SUPERB TODO Pareto Execution Plan — T30–T56 Backlog

**Date:** 2026-09-18 15:01 (CEST, via `date` CLI)
**Input:** `TODO_LIST.md` post docs-health full audit (2026-09-18 15:05 report): T30, T33, T34, T36–T56 = 23 verified-open items. T35 closed by the audit.
**Format note:** `.md` per explicit user instruction — overrides the pareto-planning skill's HTML canonical output (flagged, not propagated; same override protocol as every prior session).
**Guardrail:** Do not verschlimmbessern. Every change leaves the repo verifiably no worse: no gate is loosened without a fixture proving the loosening is correct; no wording is "improved" without the verified fact it must carry; restraint is success.

---

## Pareto Breakdown

### The 1% → 51% — stop the two things that can actively LIE (~25 min)

| Task | Why it is the 1% |
| ---- | ---------------- |
| **T36** github-voice "every comment across all repos" overclaim | A shipped skill misstating its own corpus — the exact class this repo exists to prevent. XS fix, honesty payoff. |
| **T42** fence-aware check 15 + `It.s` regex + remediation print | The hard gate can fail a legitimate skill (teaching against throat-clearing inside a fence) and matches `Its`. A gate that lies is worse than no gate. |

### The 4% → 64% — trust infrastructure complete (~3.5 h)

Add: **T47** check-skills selftest (the 2026-09-09 silent-exit class can never recur), **T43** `--signal` fixture, **T39** check-14 row-level + reverse, **T37** buildflow verification table, **T38** naming-review description rewrite + mutual disambiguation, **T54** gloss grammar slip.
Result: every automated gate self-verified, every inventory row exact, every skill honest about provenance.

### The 20% → 80% — validation + fleet tooling (~6 h more)

Add: **P4** link-layer self-verification (T41, T56), **P5** site DoD checker (T45), **P6** eval harness + linter-building activation tests (T46, T48), **P8** signal long-tail first tranche + doctrine artifact + quick-test fold (T52a, T53, T44), **P9** shellcheck debt with proof runs (T55).
Result: the repo can prove — mechanically — that sites are healthy, evals are one command, links self-test, and the newest skills activate correctly.

### The other 80% → 100%

**P7** linter-building reference provenance (T49, ~60 min). **P10** shepherding the blocked/gated queue (T30 real-PR scheduling, T33 site-repo work order, T34/T51 user-decision prompts, T52 remaining long tail). These are gated on external events or user decisions — the plan sequences them, execution waits.

---

## Comprehensive Plan (30–100 min packages — ALL 23 TODOs included)

| #  | Package (maps TODOs)                                                                                       | Impact  | Effort | Value | Tier    |
| -- | ---------------------------------------------------------------------------------------------------------- | ------- | ------ | ----- | ------- |
| P1 | Trust-the-gates hardening: fence/quote-aware check 15 + negative fixture + explicit regex + remediation print; check-skills selftest; --signal fixture (T42, T47, T43) | Critical | 90 min | Trust | 4%      |
| P2 | Honesty + skill hygiene: github-voice corpus-claim fix from summary.json; buildflow verification table; naming-review desc rewrite + data-model mutual disambiguation; gloss grammar (T36, T37, T38, T54) | Critical | 60 min | Trust | 1%/4%   |
| P3 | Inventory gates: check-14 row-level + reverse direction + fixtures; README marker audit + parity gate; marker-vocab structural guard (T39, T40, T50) | High    | 75 min | Drift-proofing | 4% |
| P4 | Link-layer self-verification: `--selftest` sandbox matrix; wire `--check` into check-skills; annotate-prose self-test + `marker_for` dedupe (T41, T56) | High    | 60 min | Trust | 20%     |
| P5 | Site fleet DoD checker `scripts/site-dod-check.sh` (cache headers, id=demo, og:image dims, firebase order lint) + four-site run (T45) | High    | 90 min | Customer (sites) | 20% |
| P6 | Eval harness `run-eval.sh` + linter-building fresh-session positive & negative trigger tests (T46, T48) | High    | 90 min | Empirical | 20%  |
| P7 | Linter-building reference provenance: verify-or-mark the ~10 research-sourced specifics + per-reference tables (T49) | Medium  | 60 min | Accuracy | 80%→100% |
| P8 | Signal long tail tranche 1: github-voice preamble=28 audit; "what you get" quick-test row; doctrine artifact in originals/ (T52a, T53, T44) | Medium  | 60 min | Signal | 20% |
| P9 | Shellcheck debt: SC2319 ×6 (jj validate script) + SC2089/90 (naming-smells) + one real proof run each (T55) | Medium  | 45 min | Correctness | 20% |
| P10 | Blocked/gated queue: T33 execution order note; T30 PR scheduling; T34+T51 decision prompt list; T52 rest routing (T30, T33, T34, T51, T52b) | Medium  | 30 min | Unblocking | 80%→100% |

**Total:** ~10.6 h across 10 packages; 23/23 TODOs covered.

## Micro Breakdown (≤12 min per task — ALL steps included)

| #   | Step (→ package)                                                                                        | ≤ min | Impact |
| --- | ------------------------------------------------------------------------------------------------------- | ----- | ------ |
| m1  | Replace `It.s` with explicit `It is\|It's` alternation in `filler_re` (→P1/T42)                          | 5     | Critical |
| m2  | Copy github-voice collection parameters verbatim from `summary.json`; replace SKILL.md:26 claim (→P2/T36)| 10    | Critical |
| m3  | Grep github-voice shipped prose for `every\|all\|complete`; verify each hit against summary.json (→P2)   | 10    | Critical |
| m4  | check 15: skip fenced-code and `>`-quoted lines (→P1/T42)                                                | 12    | Critical |
| m5  | Negative fixture: filler phrase inside a fence must NOT fail check 15 (→P1/T42)                          | 12    | Critical |
| m6  | check 15 failure prints the remediation ("delete it, or rewrite as an instruction") (→P1/T42)            | 10    | High |
| m7  | check-skills `--selftest`: seeded clean tree asserts exit 0 + final OK line (→P1/T47)                    | 12    | Critical |
| m8  | `--selftest`: seeded broken tree (filler + bad frontmatter) asserts exit 1 (→P1/T47)                     | 12    | Critical |
| m9  | buildflow SKILL.md: add canonical `## Verification status` Claim/Status/Source table (→P2/T37)           | 12    | High |
| m10 | naming-review description: draft ~800-char trigger-first rewrite (→P2/T38)                                | 12    | High |
| m11 | Add data-model-review ↔ naming-review mutual disambiguation, both sides (→P2/T38)                        | 10    | High |
| m12 | Re-run `check-skills.sh` + `--triggers` after m9–m11; quote exits (→P2)                                   | 10    | High |
| m13 | Fix "file no later session reads" → "file **that**…" ×2 files (→P2/T54)                                   | 5     | Low |
| m14 | check 14: row-level match on first-column skill name (→P3/T39)                                            | 12    | High |
| m15 | check 14 reverse: FEATURES rows naming nonexistent skills FAIL (→P3/T39)                                  | 12    | High |
| m16 | Fixtures: missing-row fails, ghost-row fails, present-row passes (→P3/T39)                                | 12    | High |
| m17 | README marker audit: diff 30 per-skill markers vs FEATURES statuses (→P3/T40)                             | 12    | Medium |
| m18 | README↔FEATURES parity guard (advisory warn) (→P3/T40)                                                    | 12    | Medium |
| m19 | Marker-vocab guard: scope marker greps to the HARVEST section (→P3/T50)                                   | 12    | Medium |
| m20 | `--signal` fixture file: known preamble/prose/jargon counts asserted (→P1/T43)                            | 12    | High |
| m21 | link script `--selftest`: AGENTS_DIR sandbox harness (→P4/T41)                                            | 12    | High |
| m22 | `--selftest` matrix: clean/orphan/lockfile-collision/hint cases (→P4/T41)                                 | 12    | High |
| m23 | Wire `link-skills-to-agents.sh --check` into check-skills.sh (→P4/T41)                                    | 10    | High |
| m24 | `annotate-prose.py` self-test (h/v/p/w markers, UTC default) (→P4/T56)                                    | 12    | Medium |
| m25 | Extract `marker_for` to one shared helper + sync note (→P4/T56)                                           | 12    | Medium |
| m26 | site-dod-check.sh: URL + HEAD fetch helpers (→P5/T45)                                                     | 12    | Medium |
| m27 | …assert immutable cache on mp4 + one JS asset (→P5/T45)                                                   | 12    | Medium |
| m28 | …assert `id="demo"` present in served HTML (→P5/T45)                                                      | 10    | Medium |
| m29 | …assert og:image presence + 1200x630 dimensions (→P5/T45)                                                 | 12    | Medium |
| m30 | …firebase.json block-order lint (catch-all last) (→P5/T45)                                                | 12    | Medium |
| m31 | Run checker over all four live sites; record table (→P5/T45)                                             | 12    | High |
| m32 | Reference the checker next to pitfall #33 (→P5/T45)                                                       | 5     | Low |
| m33 | run-eval.sh skeleton: fresh-session invocation + args (→P6/T46)                                           | 12    | High |
| m34 | run-eval.sh: output capture + config symmetry (with/without) (→P6/T46)                                    | 12    | Medium |
| m35 | Dry-run harness against website-launch eval-1 (→P6/T46)                                                   | 12    | Medium |
| m36 | Fresh-session positive trigger test: "write a linter" (→P6/T48)                                           | 12    | High |
| m37 | Negative-prompt eval: "lint my project" → code-quality-scan (→P6/T48)                                     | 12    | High |
| m38 | Record results; note 🆕→🟢 aging evidence (→P6/T48)                                                        | 10    | Medium |
| m39 | Verify-or-mark linter-building ref specifics 1–3: ledger retention, loop cap, H001 signals (→P7/T49)     | 12    | Medium |
| m40 | …4–6: normLit, ADR-0001 citation, ContinueOnError name (→P7/T49)                                          | 12    | Medium |
| m41 | …7–10: RunWithSuggestedFixes, tag scheme, RuleMeta.Validate, `_test` claim (→P7/T49)                     | 12    | Medium |
| m42 | Assemble per-reference Verification-status tables (→P7/T49)                                               | 12    | Medium |
| m43 | github-voice preamble audit: classify all 28 lines signal vs noise (→P8/T52a)                             | 12    | Medium |
| m44 | Compress what m43 flagged; re-run `--signal`; keep = success (→P8/T52a)                                   | 12    | Medium |
| m45 | Quick-test table: add "what you get / why worth it" row (→P8/T53)                                         | 10    | Medium |
| m46 | Write `originals/communication-doctrine.md` + seeded-by note (→P8/T44)                                    | 10    | Low |
| m47 | website-launch 9 prose blocks: triage keep/compress (→P8/T52a)                                            | 12    | Low |
| m48 | SC2319: assign `$?` to vars in validate-workflow.sh (6 sites) (→P9/T55)                                   | 12    | Medium |
| m49 | SC2089/90: bash-array ripgrep opts in naming-smells.sh (→P9/T55)                                          | 12    | Medium |
| m50 | naming-smells fixture re-run: identical results pre/post (→P9/T55)                                        | 12    | Medium |
| m51 | jj scratch sync-loop proof run for m48 (→P9/T55)                                                          | 12    | Medium |
| m52 | T33 order note: emeet composition → first video (g1) → 2 site flows (→P10)                                | 10    | Medium |
| m53 | T30: draft the upstream-PR pick + scheduling note (→P10)                                                  | 10    | Low |
| m54 | T34/T51: one-screen decision prompt for the user (g1–g3 + glossary) (→P10)                                | 10    | Medium |
| m55 | T52b routing: remaining long tail → ROADMAP note (→P10)                                                   | 5     | Low |
| m56 | End-of-wave: gates (`check-skills`, `--triggers`, link, kit) + CHANGELOG wave entry (→all)                | 12    | High |

**56 micro-steps**, all ≤12 min; every package and every TODO represented.

---

## Execution graph (D2)

```d2
direction: right
1p: "1% → 51%\nStop the liars" {
  m1_m2: "m1 regex fix\nm2 overclaim fix"
}
4p: "4% → 64%\nTrust infrastructure" {
  gates: "m4–m8, m20 gate selftests"
  inventory: "m14–m16 check-14"
  hygiene: "m9–m13, m19 skill honesty"
}
20p: "20% → 80%\nValidation + tooling" {
  links: "m21–m25 link self-verify"
  sites: "m26–m32 site DoD checker"
  evals: "m33–m38 eval harness"
  signal: "m43–m47 long-tail tranche 1"
  shell: "m48–m51 shellcheck debt"
}
rest: "80% → 100%" {
  provenance: "m39–m42 linter refs"
  shepherd: "m52–m55 blocked queue"
}
verify: "m56 gates + CHANGELOG"

1p.m1_m2 -> 4p.gates
4p.gates -> 4p.inventory
4p.hygiene -> 20p.links
4p.inventory -> 20p.sites
20p.links -> 20p.evals
20p.sites -> rest.shepherd
20p.evals -> rest.provenance
20p.signal -> verify
20p.shell -> verify
rest.provenance -> verify
rest.shepherd -> verify
```

## Verification (per step and per wave)

- Every gate change ships with a fixture proving both directions (fail-when-broken, pass-when-clean) — the m5/m8/m16/m22/m50 pattern.
- Every wording change cites its verified source (summary.json, `--triggers` output, shellcheck).
- Wave end: `check-skills.sh` exit quoted, `--triggers`, `link-skills-to-agents.sh --check`, `sync-html-kit.sh --check`, `git worktree list`, CHANGELOG entry.

## Risk notes (VERSCHLIMMBESSER guardrails)

1. Never loosen a gate without the fixture that justifies the loosening (m4/m5 are a pair; m14/m16 are a pair).
2. Never "tighten" a description below its trigger phrases — validate with `--triggers` after m10/m11.
3. Compression keeps teaching weight (Pattern 10): if a line changes what the agent does, it stays.
4. Blocked items (T30/T33/T34/T51) are sequenced, not forced — scheduling them is the deliverable, not half-executing them.
