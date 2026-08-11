---
name: bdd-testing
description: Use when the user wants to add BDD tests, behavior tests, spec tests, acceptance tests, or user-focused tests in Go — or says "BDD", "Ginkgo", "Gomega", "Describe/It blocks", "behavior-driven", "spec suite", "write specs", or wants tests that describe observable behavior rather than implementation mechanics. Also triggers when migrating table-driven tests to Ginkgo DescribeTable, adding Gomega assertions, or setting up a Ginkgo test suite (bootstrap file, RegisterFailHandler). Implements tests using onsi/ginkgo.
metadata:
  tags: testing, bdd, ginkgo, go, user-focused
allowed-tools: bash view edit go
---

# BDD Testing

Write Go tests that describe **observable, user-facing behavior** rather than implementation mechanics. Ginkgo structures specs as readable sentences; Gomega asserts outcomes. The goal is a suite that survives refactoring because it states what the system _does_, not how it does it.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT before writing any spec.

1. **Understand the users and their goals.** Identify who calls this code and what outcomes they care about. Specs are written from that vantage point, not from the internals.

2. **Discover behaviors, not functions.** Walk the subject's public surface and list the behaviors a user would notice: "reports the weight in grams", "rejects an empty title", "retries on transient failure". One behavior → one `It`.

3. **Group behaviors into scenarios.** Cluster behaviors under `Context`/`When` blocks that name the precondition ("when the book has no author"). The nesting should read as a sentence top-down.

4. **Implement with Ginkgo + Gomega.** Use the syntax reference for exact APIs:
   [./references/ginkgo-syntax.md](references/ginkgo-syntax.md). Start from the
   template: [./assets/spec-template.go](assets/spec-template.go).

5. **Run via `go test`.** Specs are standard Go test files — `go test ./...` works with no extra tooling. The `ginkgo` CLI adds richer output and parallelism.

## Rules

- **Black-box package** (`package <pkg>_test`) — assert against the public API the way a real caller would. Don't reach into unexported state.
- **One bootstrap file per package** (`<pkg>_suite_test.go`) with `RegisterFailHandler(Fail)` + `RunSpecs`. One spec file per subject, named after it.
- **Fresh subject per spec** — construct in `BeforeEach`, never share a pointer across `It` blocks. Shared mutable state is the #1 cause of order-dependent failures.
- **Assert behavior, not implementation.** `It("returns the author's last name")`, never `It("checks the field")`.
- **No committed focus.** `FIt`/`FDescribe` silently skip the rest of the suite. Run `ginkgo unfocus` (or grep for `^F`) before committing.
- **Async without sleeps.** Use `Eventually(...).Should(...)` instead of `time.Sleep` + `Expect`.

## File naming conventions

| File                  | Purpose                                                               | Example              |
| --------------------- | --------------------------------------------------------------------- | -------------------- |
| `<pkg>_suite_test.go` | Bootstrap file — `RegisterFailHandler` + `RunSpecs`. One per package. | `user_suite_test.go` |
| `<subject>_test.go`   | Spec file — one per subject under test. Named after what it tests.    | `user_repo_test.go`  |
| `helpers_test.go`     | Shared test helpers (builders, fixtures). Not specs.                  | `helpers_test.go`    |

All spec files use `package <pkg>_test` (black-box) and import `onsi/ginkgo` + `onsi/gomega`.

## When to use tables

When many inputs share one behavior shape, prefer `DescribeTable` + `Entry` over copy-pasted `It` blocks — see the syntax reference's "Table-driven specs" section. Each `Entry` is its own spec, so failures point at the exact case.
