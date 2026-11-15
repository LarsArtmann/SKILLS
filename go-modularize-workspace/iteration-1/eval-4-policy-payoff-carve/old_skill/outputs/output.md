# eval 4 — policy-payoff-carve — old_skill (pre-fix doctrine, git e1d8a05)

Probe: fresh subagent session, 2026-11-15 ~14:10. Skill loaded from
/tmp/gm-eval-old/go-modularize/ (git archive of e1d8a05 — the pipe-only
gate-2 doctrine). Response verbatim:

---

**Verdict: No. `internal/agent` should not become its own module — it fails the pipe test (gate 2), and no LOC ceiling can override a failed gate. It stays as package(s) in the root module.**

## The five gates, run against your stated evidence

| # | Gate | Verdict | Evidence |
|---|------|---------|----------|
| 1 | Purpose | **PASS** | "Orchestrate agent turns" — one sentence, one verb. Genuinely cohesive. |
| 2 | Pipe test | **FAIL** | No consumer composes `internal/agent` without importing siblings. The binary is the composition root: it imports agent *and* everything else by definition. "No second consumer is ever planned" is below the evidence bar — a planned consumer must be a *named* consumer in a committed artifact (plan row, ADR, issue) with a trigger that fires it. "Someone might someday" is not evidence. |
| 3 | Direction | **PASS** | Imports zero infrastructure — policy/mechanism direction is clean. |
| 4 | Surface | PASS (moot) | As a package it can keep an enumerable surface. Doesn't matter — gate 2 already dissolved the seam. |
| 5 | Solo build | PASS (moot) | Zero internal imports means it would build alone trivially — but a module that builds alone and that nobody *composes* alone is still a boundary with no payoff. Gate 5 passing does not rescue gate 2. |

One failure is decisive: **dissolve the seam**. Record the dissolution and stop — don't carry the proposal forward hoping evidence appears later.

## Why the usual counterarguments don't rescue it

- **"No external consumers is fine — import bans and per-module CI are payoffs too."** True in general, but not here. An import ban pays off when something *could* wrongly import the module and the boundary stops it. Nothing else ever imports `internal/agent` — the binary is its sole, legitimate consumer. There's nothing to ban. Per-module CI over 4,900 dependency-free LOC buys roughly nothing. With a single-binary composition root, extraction creates a go.mod, replace-directive bookkeeping, a CI job, and go.work sync surface — all overhead pricing a boundary nobody composes across.
- **The `internal/` path itself is a liability in extraction.** `internal/` restricts access to the module tree: a sub-module's `internal/` is invisible to *all* other modules — including your root binary. Extraction would force a rename/path migration for the binary's imports, adding mechanical cost to zero payoff.
- **The math doesn't help either.** Extracting 4,900 LOC takes the root from ~85k to ~80k — still 4× your 20k ceiling. Even on the policy's own terms this is a token gesture.

## The root-slim policy is the wrong decision instrument here

The committed 20k ceiling is a *size quota*, and size quotas answer "how many boundaries can we defend," never "is this boundary correct." The doctrine is explicit: a boundary that passes all five gates is worth its overhead at almost any size; one that fails is wrong at any size. A dated planning-doc ceiling is not composability evidence — it cannot promote `internal/agent` from gate-2 failure to extraction. If the ceiling matters to the team, it gets satisfied one of two honest ways:

1. **Run the gates across the remaining ~85k root**, candidate by candidate, looking for the ones that genuinely pass gate 2 — e.g., packages that some of the 12 existing submodules import *without* their siblings (real consumer variance), or infrastructure blobs with real consumer spread. Those are defensible extractions.
2. **Revise or re-date the policy.** If no gate-passing bulk exists in the root, the ceiling is describing a world that no longer exists, and the honest fix is amending the doc, not extracting a package to shave 6% off the number.

## On the prior review ("nothing to extract, keep it all in the root")

Directionally compatible with my verdict on this candidate, but suspect as methodology if it was a blanket call. Blanket keep-everything verdicts are the mirror image of blanket split-everything verdicts — both let a monolith hide problems. At ~85k LOC, the odds that *zero* gate-passing seams exist are low; under-modularization (god-modules bundling unrelated sub-domains, where importing feature X drags in feature Y's types) is as real a failure mode as over-modularization. Re-run the per-candidate gate assessment over the root rather than accepting or rejecting the prior review wholesale.

## What to actually do with `internal/agent`

Keep it as package(s) in the root, and keep it gate-clean at the package level — which it already largely is:

- **Purpose:** already one verb. Don't let it accrete a second.
- **Direction:** it imports zero infrastructure; hold that line (an import-lint check is cheap insurance).
- **Surface:** keep the exported contract enumerable at a glance; grow `internal/` opacity within the root as needed.

Because it already passes gates 1–4 as a package, a future extraction — if a second consumer ever lands as a named, committed plan row with a trigger — will be mechanical. A failed gate 2 is a deferral with a named trigger, not a rejection: re-run the gate when that trigger fires, not before.

**Bottom line:** don't extract `internal/agent`. Spend the review effort instead on a gate-by-gate sweep of the remaining root packages to find whether the 20k policy is satisfiable by any boundary that actually earns its keep — and if not, change the policy, not the module layout.
