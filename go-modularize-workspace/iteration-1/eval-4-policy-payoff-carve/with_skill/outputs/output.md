# eval 4 — policy-payoff-carve — with_skill (fixed doctrine, HEAD 2026-11-15)

Probe: fresh subagent session, 2026-11-15 ~14:10. Skill loaded from
/home/lars/projects/SKILLS/go-modularize/ (post-fix + same-day hardening).
Response verbatim:

---

**Verdict: yes — extract `internal/agent` as its own module.** It passes all five gates, with gate 2 paying in the policy currency. The prior review's "nothing to extract" is the predictable artifact of a gate-2 that weighed only the pipe currency in a repo where pipe payoff is structurally unavailable — that's a keep-the-monolith bias wearing a gate's clothes, not a neutral finding.

## The five gates, run against your stated facts

| # | Gate | Verdict | Evidence |
|---|------|---------|----------|
| 1 | Purpose | **PASS** | "Orchestrate agent turns" — one sentence, one verb. Cohesion at module scale. |
| 2 | Payoff | **PASS (policy currency)** | See below. |
| 3 | Direction | **PASS** | Imports zero infrastructure — dependencies run policy → mechanism cleanly. Nothing to untangle first. |
| 4 | Surface | **PASS, with work attached** | Thin exported contract (what the binary wires in: the orchestrator's entry types/functions) + `internal/` for the rest. |
| 5 | Solo build | **Pending — mechanical** | `GOWORK=off go build ./... && GOWORK=off go test ./...` must be green inside the new module. Zero infra imports makes this near-trivial, but run it: a module that only builds inside `go.work` is a directory with a go.mod, not a module. |

## Gate 2 in detail — both currencies evaluated

**Pipe payoff: structurally unavailable, and that counts for nothing against the candidate.** In a single-binary monorepo the only consumer is the binary itself, so every consumer is a sibling import by definition. "No second consumer is ever planned" just confirms the structural fact. If you weigh only the pipe currency in this repo shape, "nothing to extract" is the *only possible output at any repo size* — which is exactly the error the prior review made. You cannot fail a candidate on a currency your repository geometry makes impossible to earn.

**Policy payoff: present, and it meets the evidence bar twice over.**
- **Named committed artifact:** the dated planning doc carrying the root-slim policy (root < 20k LOC). Because it predates this assessment in a committed artifact, it counts on its face — no ratification question needed.
- **The boundary measurably advances it:** root drops by the candidate's size (~4,900 LOC, ~85k → ~80k) against a ceiling the root currently violates by more than 4×.

And note what a module boundary actually buys you here, since there's no external consumer: inside a single module, `internal/` blocks *nothing* between sibling packages — the compile-time import ban is precisely what a go.mod buys. The root-slim policy is a payoff with zero external consumers by design; "no second consumer ever planned" does not hollow it out.

## The prior review fails the dissolve-symmetry check

"Nothing to extract, keep it all in the root" is a **seam verdict, never "nothing to do."** Before recording a pile of dissolves, you must check the container: a root module at ~85k against its own committed 20k ceiling is an under-modularization finding (a god-module at module scale) sitting open on the record. The honest options were never "keep it all" — they were (a) carve gate-passing candidates until the policy is met, or (b) retire the policy and accept the monolith on the record. The review reported a seam verdict as though it closed the finding, while the repo continues to violate its own committed policy by 4×.

## Conditions and expectations

1. **This is the first carve, not the last.** −4,900 LOC leaves the root at ~80k, still 4× its ceiling. `internal/agent` is the right *first* move precisely because it's cohesive, direction-clean, and infra-free — a near-mechanical extraction — but the policy requires a candidate queue: run the same five gates over the next-largest cohesive chunks until the root is under 20k or the policy is renegotiated on the record.
2. **The seam's justification is the policy currency — permanently.** Pipe payoff will never arrive to back it up, and that's fine; but it cuts both ways: if the root-slim policy is ever retired, the boundary's justification dies with it. Re-run gate 2 before keeping the seam alive on a lapsed policy.
3. **Follow the pattern your 12 existing submodules already established** — the marginal overhead of module #13 is low. Dual strategy: `go.work` for development plus relative-path `replace` directives so every module builds `GOWORK=off` (correct here because nothing is ever proxy-published; committed replaces are only poison for `go get`-able modules). Per-module `GOWORK=off` build/test CI legs, and a `go work sync` idempotency check. Root-only versioning; `cmd/` stays in the root module as the wiring/leaf node.
4. **Watch the two failure modes this extraction shape invites:** internal/ access breakage (once it's a module, the root cannot import anything under the new module's `internal/` — the exported surface must carry everything the binary needs, so define it before moving files) and error-type placement (any sentinel errors the binary checks with `errors.Is` must live in the new module's exported surface, not its internals, or the checks break in isolation even though the workspace masks it).

Bottom line: gate 2 prices a boundary in one of two currencies — pipe payoff (someone composes across it) or policy payoff (a committed policy it advances). `internal/agent` can never pay in the first in this repo, and doesn't need to: it pays in full in the second. Extract it, then queue the next candidate.
