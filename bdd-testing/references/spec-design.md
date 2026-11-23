# Spec design — shaping Describe/Context/It beyond naming

Syntax lives in [ginkgo-syntax.md](ginkgo-syntax.md). This file answers the
design questions the syntax reference cannot: how big a behavior is, what a
`Context` means, how deep to nest, and how to keep a suite refactor-proof.

## Granularity: what is one `It`

One `It` = one observable outcome under one set of conditions. Tests:

- **User verb test** — can you phrase it as "the system <verbs> when
  <condition>"? Then it is one `It`. If you need "and" in the phrasing, you
  have two.
- **Assertion-count test** — multiple `Expect` calls are fine when they
  assert ONE outcome's facets (status + message of the same rejection).
  Two unrelated outcomes (created AND notified) = two `It`s — they fail
  independently and read independently.
- **Refactor test** — would this spec survive a rewrite of the
  implementation? If the spec names internals (a method, a field, a goroutine),
  it is a unit test in a costume. Rewrite from the caller's vantage point.

## What a `Context` means (pick one semantic per suite)

A `Context` names the CONDITION that varies; the `Describe` names the
subject behavior. Common condition types, in order of preference:

1. **Precondition state** — "when the cart is empty" (best: state setup in
   `BeforeEach`, specs read cleanly)
2. **Input class** — "with a malformed email"
3. **Caller/actor** — "as an admin" (use sparingly; if most specs differ by
   actor, the actor may deserve its own `Describe`)

Anti-pattern: `Context("success")` / `Context("failure")` — outcome is what
the `It` asserts, not a condition. Rephrase as the input or state that
CAUSES the outcome.

## Nesting depth: two levels of `Context` max

`Describe > Context > It` is the default shape. A second `Context` level is
justified only when a condition genuinely specializes another ("when the
token is expired" > "and the request has a retry header"). At three levels
the sentence falls apart and readers scroll — flatten by merging conditions
into the `It` or splitting the `Describe`.

## Setup layering

- `BeforeEach` at the level where the setup becomes TRUE for every spec
  below — not hoisted to the top "for reuse".
- `JustBeforeEach` for subject construction when nested `BeforeEach` blocks
  must still configure inputs first (construction is the only thing that
  goes here).
- `DeferCleanup` beside the act that creates the obligation — never a
  central `AfterSuite` doing remote teardown; spec-local cleanup keeps the
  suite parallelizable.
- Builders over shared fixtures: a `newValidOrder(t).WithoutPayment()...`
  builder in `helpers_test.go` beats a giant shared JSON fixture, because
  each spec shows the delta from valid that MATTERS to it.

## Error paths are first-class specs

One `It` per distinguishable failure mode, asserting the error contract a
caller can rely on:

```go
It("returns ErrNotFound when the user does not exist", func() {
    _, err := store.Get(ctx, "missing")
    Expect(errors.Is(err, ErrNotFound)).To(BeTrue())
})

It("wraps the cause when the database fails", func() {
    _, err := store.Get(ctx, "any")
    var dbErr *DBError
    Expect(errors.AsType(&dbErr)).To(BeTrue()) // Go 1.26+ generic form
})
```

Do not assert error STRINGS (they churn); assert identity (`errors.Is`) and
type (AsType). A suite that only covers happy paths is a demo, not a spec.

## Migrating table-driven tests

Move a `for _, tt := range cases` loop into `DescribeTable` when — and only
when — every case asserts the same outcome shape. Mixed-shape cases (one
checks error, one checks output) split into TWO tables or stay as loops;
forcing them into one table produces `interface{}` soup in `Entry` params.
Migration order: highest-churn package first (refactor pain = highest payback).

## Smells and their redesign

| Smell                                    | Redesign                                            |
| ---------------------------------------- | --------------------------------------------------- |
| Spec names need "correctly", "properly"  | Name the observable: "returns grams as an integer"  |
| Same 10-line setup in many `It`s         | Hoist ONE level; or builder with per-spec delta     |
| Order-dependent failures (`-p` breaks it)| Shared mutable subject — construct per spec          |
| `It` body over ~15 lines                 | Extract act into helper, or split the behavior      |
| Nested Contexts contradict each other    | Condition belongs in `It` phrasing or a new Describe |
| Specs fail after a pure refactor         | They asserted internals — rewrite from public API   |
