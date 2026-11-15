# eval 5 — same-session-policy — with_skill (fixed doctrine, HEAD 2026-11-15)

Probe: fresh subagent session, 2026-11-15 ~14:10. Skill loaded from
/home/lars/projects/SKILLS/go-modularize/ (post-fix + same-day hardening
including the anti-self-ratification clause). Response verbatim:

---

**Short answer: not on today's evidence — but you're one owner decision away from a yes, and the honest answer is neither "extract now" nor "do nothing."**

## Running the decision through the gates

**Gate 2 is where this lives, and it has exactly two currencies.**

**Pipe payoff: structurally unavailable, and that doesn't count against you.** In a single-app repo the only consumer is the app itself — a sibling by definition — so no consumer can ever compose mailer "without siblings." And "no second consumer planned" means no named consumer with a trigger in a committed artifact either. Weighing only the pipe currency in a one-app monorepo makes "nothing to extract" the only possible output at any repo size — that's a keep-the-monolith bias, not a verdict. So mailer gets judged on the other currency.

**Policy payoff: no committed policy exists.** You checked plans, ADRs, and TODOs — nothing. A root-slim policy is a legitimate payoff currency (import bans, per-module CI, and committed size ceilings all count with zero external consumers), but the evidence bar is a named, committed artifact, not a vibe. And your "root stays under 25k lines" policy has a specific problem: **a size policy authored in the same session that proposes the extraction is self-ratifying, not committed.** You can't write the policy and cite it as the justification in the same breath. Today, gate 2 fails in both currencies — which means: **dissolve the seam for now; keep `internal/mailer` as a package.**

## But a failed gate 2 blesses nothing — the container gets audited too

Before recording "keep as package," check what the candidate stays inside. A root module with ~30 packages matches god-module shape (14+ packages in one go.mod is the under-modularization red flag — the inverse failure of over-modularization, just as real). So this outcome carries a standing under-modularization finding plus exactly **one owner question**:

> **Ratify the 25k root-slim policy in a committed artifact, or retire it and accept the monolith on the record.**

"Nothing to extract" is a seam verdict, never "nothing to do."

## The path to yes — in order

1. **Ratify first.** Get the owner(s) to commit "root stays under 25k LOC" to an ADR or policy doc, *before* deciding the extraction. Once committed, it's a real policy on its face.
2. **Measure the root.** Policy payoff requires the containing module to *violate* the ceiling. You said the root "feels" bloated — measure it. If root is already ≤ 25k, the ceiling is met and the carve's justification is dead; re-examine the policy number instead. If root is over 25k, a −2,000 LOC drop is a measurable advance (the worked precedent: a ~4,900 LOC carve from a root 4× over its ceiling passed on exactly this currency).
3. **Re-run gate 2 with the ratified policy.** It passes — policy currency, with the pipe currency's unavailability explicitly not counting against the candidate.
4. **The other gates still bite — verify against the code (I can't confirm these from what you've told me):**
   - **Purpose:** mailer = "send email," one sentence, one verb. Likely passes if the package is cohesive.
   - **Direction:** the app may import mailer; mailer must import zero app/domain/feature packages. Fix any upward imports as *packages* first, before extraction.
   - **Surface:** everything in the new module `internal/` except a thin exported contract (a `Mailer` interface + config types). Note: inside a single module, `internal/` blocks nothing between siblings — the compile-time import ban is exactly what the module boundary buys.
   - **Solo build:** `GOWORK=off go build ./... && GOWORK=off go test ./...` green inside the new module alone. A module that only builds inside `go.work` is a directory with a go.mod, not a module.
5. **If it proceeds:** app monorepos that are never proxy-published use the dual strategy — `go.work` for development plus `replace` directives in the consuming go.mod so `GOWORK=off` builds work; CI tests both modes and checks go.work/replace agreement; root-only versioning (no per-module tags needed).

One decay clause to write into the policy now: when a boundary's justification lapses — the policy is retired, or the root finally dips under 25k — re-run gate 2 before drawing further seams on the old rationale. And if the policy is ratified and the root is over the ceiling, mailer is a reasonable first carve *because it's the easiest clean seam*, not because it's the biggest — pick the candidate that passes gates 1, 3, 4, 5 most cleanly, and let the policy, not the itch, sequence the rest.
