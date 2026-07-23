---
name: samber-do-best-practices
description: |
  Use when the user works with samber/do v2 dependency injection in Go — registering services, resolving dependencies, writing providers, building composition roots, adding health checks or shutdown logic, or reviewing DI code. Also trigger on phrases like "samber/do", "dependency injection", "DI container", "do.New", "do.Provide", "do.Invoke", "injector", or "service locator". Audits usage against the DO-1 → DO-6 anti-pattern rules, applies canonical patterns, and wires lifecycle interfaces, scopes, and audit hooks where appropriate.
allowed-tools: bash view edit grep lsp_definition lsp_references lsp_call_hierarchy
metadata:
  tags: go, golang, dependency-injection, samber-do, di, container, lifecycle, best-practices, anti-patterns
---

# samber/do v2 Best Practices

`samber/do` v2 is the dominant dependency-injection library in this workspace. It is powerful but has a small set of sharp edges that keep reappearing in real code. This skill applies the canonical patterns and rejects the six anti-patterns already implemented in `branching-flow/pkg/doanalyzerv2`.

The single source of truth is the comprehensive report in [./references/samber-do-best-practices-report.md](./references/samber-do-best-practices-report.md). Read it on demand for deep examples, real-workspace case studies, and migration notes.

## 1. Before Editing

1. Load the comprehensive report when you need background or examples:
   ```
   view ./references/samber-do-best-practices-report.md
   ```
2. Find every file that imports `github.com/samber/do` in the target project:
   ```bash
   grep -rl 'github.com/samber/do' --include='*.go' . | head -50
   ```
3. Before changing any symbol, use `lsp_references` to see every call site and avoid breaking runtime container registration.

## 2. Canonical Patterns — Apply on Sight

- **Composition root:** wrap `do.New()` in a constructor and return a cleanup function.
  ```go
  func New() (*Container, func()) {
      injector := do.New()
      // register providers
      return &Container{injector: injector}, func() { injector.Shutdown() }
  }
  ```
- **Lazy singletons:** prefer `do.Provide` for most services.
- **Eager foundation:** use `do.ProvideValue` for config, logger, DB connection, or anything that must exist even before first invocation.
- **Named services:** use `do.ProvideNamed` when multiple implementations of the same interface exist.
- **Interface consumption:** provide concrete structs, invoke by interface with `do.InvokeAs[T]`.
- **Lifecycle guards:** add compile-time checks such as `var _ do.ShutdownerWithError = (*MyService)(nil)`.
- **Packages:** group related providers with `do.Package`.
- **Audit hooks:** use `samber-do-auditlog` when observability of registrations, invocations, health checks, and shutdowns matters.
- **Test container:** create a dedicated test container that overrides production dependencies cleanly.

For quick reference, load [./references/samber-do-quick-reference.md](./references/samber-do-quick-reference.md).

## 3. Anti-Patterns — Reject on Sight

Use the DO-1 → DO-6 rules as a checklist. Load [./references/anti-pattern-examples.md](./references/anti-pattern-examples.md) for concrete before/after snippets.

| ID   | Smell                                                            | Fix                                                                                |
| ---- | ---------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| DO-1 | `Must*` in request handlers, CLI actions, or other runtime paths | Inject the dependency at construction or use `do.Invoke` and handle the error      |
| DO-2 | `do.New()` without a matching `Shutdown()`                       | Add `defer injector.Shutdown()` or return a cleanup function                       |
| DO-3 | `do.Override*` outside `_test.go` or setup functions             | Use `Provide` + aliasing instead; `Override*` only in tests or options-style setup |
| DO-4 | Package-level `do.Injector` or `*do.RootScope` variable          | Pass the injector as a parameter and build a composition root                      |
| DO-5 | `do.Invoke` inside loops                                         | Hoist resolution before the loop                                                   |
| DO-6 | `Shutdown()` accesses other services or the injector             | Make shutdown self-contained; use a lifecycle manager for coordination             |

Additional structural smells to reject:

- **Service-locator smell:** passing the injector deep into business logic and resolving dependencies ad-hoc.
- **Storing the injector inside a service:** services should hold resolved dependencies, not the container.

## 4. When Editing samber/do Code

1. Read the changed file and all files that import `github.com/samber/do` in the same package.
2. Check the changed code against the anti-pattern table above.
3. If a service holds resources, ensure it implements `do.Shutdowner*` and, if relevant, `do.Healthchecker*`.
4. If a new dependency is resolved with `do.MustInvoke`, confirm it is inside `main`, `init`, or a provider closure. Otherwise change to `do.Invoke` and propagate the error.
5. If `do.Override*` is added outside a test or setup function, reject it and use an alias or `ProvideNamed` instead.
6. Run the project’s Go build and tests after every change.

## 5. When Reviewing or Auditing

1. Find all files importing `github.com/samber/do`:
   ```bash
   ./scripts/audit-do.sh
   ```
2. Run the mental equivalent of the DO-1 → DO-6 analyzer rules against each file.
3. Classify findings by severity:
   - **High:** runtime panic risk (`MustInvoke` in handler), resource leak (`do.New()` without `Shutdown`), cross-service shutdown calls
   - **Medium:** global injector, `Override*` in production code, `Invoke` inside loops
   - **Low:** missing lifecycle interface guards, missing named-service helper accessors
4. Suggest concrete refactors with before/after snippets.

## 6. When Designing Greenfield DI

1. Start with a composition root that returns a cleanup function.
2. Add lifecycle interfaces (`do.Shutdowner*`, `do.Healthchecker*`) before first release for any resource-holding service.
3. Use `do.Package` to group related providers.
4. Use child scopes only when the isolation is real (request, session, tenant).
5. Wire `samber-do-auditlog` hooks when observability matters.

## 7. Verification

- After changes, run `go build ./...` and the project’s test suite.
- Ensure every `do.New()` has a matching `.Shutdown()` call reachable on the cleanup path.
- Confirm no `do.MustInvoke` remains in runtime request paths or CLI action handlers.
