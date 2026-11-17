# Design It Twice

Use when the interface shape for the chosen candidate is still contested. Your first design is unlikely to be the best one, so produce several in parallel and compare them. Based on the "Design It Twice" technique (Ousterhout), run as a parallel-sub-agent pattern.

Vocabulary comes from [./deepening-vocabulary.md](./deepening-vocabulary.md): module, interface, implementation, depth, seam, adapter, port, leverage, locality. Domain nouns come from the project glossary.

## 1. Frame the problem space (user-facing)

Write, for the user, before spawning anything:

- The constraints any new interface must satisfy.
- The dependencies it relies on, each with its category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- A rough code sketch that makes the constraints concrete. It is a constraint illustration, not a proposal.

Show it, then keep going: the user reads and thinks while the sub-agents work. Do not block on an answer here.

## 2. Spawn 3+ read-only sub-agents in parallel

Each gets a fresh context and a **different** design constraint on the same module:

| Agent | Brief                                                                      |
| ----- | -------------------------------------------------------------------------- |
| 1     | Minimise the interface: 1-3 entry points, maximum leverage per entry point |
| 2     | Maximise flexibility: support many use cases and extension points          |
| 3     | Optimise for the most common caller: make the default case trivial         |
| 4     | Ports & adapters, only when a cross-seam dependency genuinely exists       |

Give every agent the same technical facts (file paths, coupling details, dependency category, what sits behind the seam) and the same vocabulary, then the constraint above. The technical brief is independent of the user-facing framing in step 1: it states constraints, not a preferred answer.

Each agent returns:

1. The interface: types, methods, parameters, plus invariants, ordering, error modes.
2. A usage example showing a real caller.
3. What the implementation hides behind the seam.
4. The dependency strategy and the adapters it implies.
5. Trade-offs: where leverage is high, where it is thin.

## 3. Present, compare, recommend

Present the designs sequentially so the user can absorb each one, then compare them in prose on **depth**, **locality**, and **seam placement**. End with your own recommendation and why. If parts of two designs combine cleanly, propose the hybrid — the user wants a strong read, not a menu.

## Failure modes

| Symptom                                    | Cause                                                          |
| ------------------------------------------ | -------------------------------------------------------------- |
| Designs converge on the same shape         | Briefs shared the constraint instead of differing on it        |
| A design needs a port with one adapter     | The seam is hypothetical: merge instead (deletion test)        |
| Comparison lists features, not leverage    | Depth was never measured on the interface a caller must learn  |
| Recommendation is a menu                   | No judgement offered; the user now has to do the design work   |
| Internal helper names leak into interfaces | Implementation detail promoted to interface without a decision |
