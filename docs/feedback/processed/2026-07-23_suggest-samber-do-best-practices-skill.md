# Skill Proposal: `samber-do-best-practices`

**Date:** 2026-07-23  
**Proposed by:** Crush session auditing samber/do usage across `/home/lars/projects`  
**Related work:**

- `/home/lars/projects/samber-do-auditlog/docs/research/samber-do-best-practices-and-anti-patterns.md` (new comprehensive report)
- `/home/lars/projects/branching-flow/pkg/doanalyzerv2/` (existing static analyzer)
- `/home/lars/projects/samber-do-auditlog/` (lifecycle observability plugin)
- `/home/lars/projects/reports/docs/01-technical-analysis/go-libraries/samber-ro-do-linter-design.md` (deep research on DO-1 → DO-6 rules)

---

## 1. Why This Skill Should Exist

`samber/do` v2 is the dominant dependency-injection library in the LarsArtmann Go ecosystem: **72 modules / ~443 Go files** depend on it. Yet the same mistakes keep appearing:

- Missing `injector.Shutdown()` → resource leaks
- `do.MustInvoke` in HTTP handlers or CLI actions → runtime panics
- Global `do.Injector` variables → untestable, mutable state
- `Shutdown()` methods that invoke other services → crashes due to non-deterministic shutdown order (samber/do issue #219)
- `do.Override*` scattered through production code → silent container mutation

The ecosystem already has the raw materials to solve this:

- `branching-flow/pkg/doanalyzerv2` detects six specific anti-patterns.
- `samber-do-auditlog` records every DI event and exports dependency graphs.
- A new comprehensive report consolidates the canonical patterns.

What is missing is a **Crush skill** that activates automatically when an agent touches samber/do code and applies those lessons without the user having to ask.

---

## 2. Proposed Trigger Description

```yaml
name: samber-do-best-practices
description: |
  Use when the user works with samber/do v2 dependency injection in Go —
  registering services, resolving dependencies, writing providers, building
  composition roots, adding health checks or shutdown logic, or reviewing DI
  code. Also trigger on phrases like "samber/do", "dependency injection",
  "DI container", "do.New", "do.Provide", "do.Invoke", "injector", or
  "service locator". Audits usage against the DO-1 → DO-6 anti-pattern rules,
  applies canonical patterns, and wires lifecycle interfaces, scopes, and
  audit hooks where appropriate.
```

---

## 3. What the Skill Would Do

### 3.1 On code changes

1. Load `/home/lars/projects/samber-do-auditlog/docs/research/samber-do-best-practices-and-anti-patterns.md` as the single source of truth.
2. Before editing any file that imports `github.com/samber/do/v2`:
   - Check for `do.New()` without a matching `Shutdown()`.
   - Check for `do.MustInvoke` outside `main()` / `init()` / provider closures.
   - Check for `do.Override*` outside `_test.go` or setup functions.
   - Check for package-level `do.Injector`, `*do.RootScope`, or `*do.Scope` variables.
   - Check for `do.Invoke` inside loops.
   - Check for `Shutdown()` methods that call `do.Invoke` or access injected-service fields.
   - Check for services that store the injector instead of resolved dependencies.
3. Fix the issues inline or flag them with clear reasoning.
4. Add `do.Shutdowner*` / `do.Healthchecker*` interfaces to resource-holding services when missing.
5. Prefer `do.Provide` lazy singletons, `do.ProvideValue` for eager foundation services, and `do.ProvideNamed` for multiple implementations.
6. Wrap composition roots in a constructor that returns a cleanup function.

### 3.2 On reviews or audits

1. Find all files importing `github.com/samber/do/v2`.
2. Run the mental equivalent of `branching-flow/pkg/doanalyzerv2` rules.
3. Produce a short findings list grouped by severity (High/Medium/Low).
4. Suggest concrete refactors with before/after code snippets.

### 3.3 On greenfield DI design

1. Start with `do.New()` and a `defer cleanup()` pattern.
2. Group related providers with `do.Package`.
3. Use scopes for request/session/tenant isolation.
4. Implement lifecycle interfaces from day one.
5. Wire `samber-do-auditlog` hooks when observability matters.

---

## 4. Proposed `SKILL.md` Outline

```markdown
---
name: samber-do-best-practices
description: |
  Use when the user works with samber/do v2 dependency injection in Go ...
allowed-tools: bash view edit grep lsp_definition lsp_references lsp_call_hierarchy
---

# samber/do v2 Best Practices

## 1. Before editing

- Read the comprehensive report at
  /home/lars/projects/samber-do-auditlog/docs/research/samber-do-best-practices-and-anti-patterns.md
- Check all call sites of changed symbols with `lsp_references`.

## 2. Canonical patterns

- Wrap `do.New()` in a constructor + cleanup function.
- Use `do.Provide` for lazy singletons.
- Use `do.ProvideValue` for config/logger/DB that must exist eagerly.
- Use `do.ProvideNamed` for multiple implementations of the same interface.
- Use `do.InvokeAs[T]` for interface-based consumption.
- Implement `do.ShutdownerWithContextAndError` and `do.HealthcheckerWithContext` on resource-holding services.
- Add compile-time guards: `var _ do.ShutdownerWithError = (*MyService)(nil)`.

## 3. Anti-patterns to reject

| ID | Smell | Fix |
| DO-1 | `Must*` outside main/init/Provide closure | Use `do.Invoke` or inject dependency at construction |
| DO-2 | `do.New()` without `Shutdown()` | Add `defer injector.Shutdown()` or cleanup function |
| DO-3 | `Override*` outside setup/_test.go | Use `Provide` + aliasing instead |
| DO-4 | Package-level injector variable | Pass injector as parameter / composition root |
| DO-5 | `Invoke` inside loops | Hoist resolution before the loop |
| DO-6 | `Shutdown()` accesses other services | Make shutdown self-contained; use lifecycle manager |

## 4. When reviewing

- Find all files importing `github.com/samber/do/v2`.
- Classify findings by severity.
- Suggest refactors with code examples.

## 5. When designing new DI

- Start with composition root.
- Add lifecycle interfaces before first release.
- Use scopes only when isolation is real.
- Wire audit hooks for long-running services.
```

---

## 5. Assets to Include

| Asset                                     | Purpose                                                                |
| ----------------------------------------- | ---------------------------------------------------------------------- |
| `references/samber-do-quick-reference.md` | Copy of the core concepts cheat sheet from the report                  |
| `references/anti-pattern-examples.md`     | Before/after snippets for DO-1 → DO-6                                  |
| `scripts/audit-do.sh`                     | Optional shell helper: list all files importing samber/do in a project |

The comprehensive report should remain the single source of truth; the skill can load it with `view` on activation rather than duplicating it.

---

## 6. Relationship to Existing Skills

| Existing skill       | Overlap             | Why this is distinct                                                                                                    |
| -------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `how-to-golang`      | General Go guidance | `how-to-golang` is broad; this skill is narrowly focused on samber/do v2 DI                                             |
| `library-deep-dive`  | Library audit       | `library-deep-dive` asks "are we using X to the max?"; this skill asks "is this specific DI code correct?" and fixes it |
| `brutal-self-review` | Codebase critique   | This skill is a specialized review lens for one library                                                                 |
| `code-quality-scan`  | Lint/build/test     | This skill adds semantic samber/do rules that generic linting cannot encode                                             |

---

## 7. Suggested Next Steps

1. Review the comprehensive report for accuracy.
2. Create `~/.config/crush/skills/samber-do-best-practices/SKILL.md`.
3. Add the reference files and optional `audit-do.sh` script.
4. Test the skill against one active project (e.g., `BuildFlow/internal/di` or `smart-configs/di`).
5. Mark the skill as 🆕 New in `SKILLS/README.md` until it has a documented successful run.
