---
name: go-modularize
description: >
  Use when the user wants to modularize a Go project, create independently versioned
  Go packages, restructure a Go project, or says "modularize", "split modules",
  "sub-modules", "go.mod per package", "multi-module", "module boundaries",
  "dependency isolation", "Go workspace", "go.work", "CQRS modularization", "break
  apart Go project", "too coupled", "Go package boundaries", "remodularize",
  "re-modularize", "merge modules", "too many modules", "over-modularized",
  "consolidate modules", "unix-style", "decompose deeper", "too few modules",
  "god-module", "composable modules". Splits or merges Go modules, refining go.mod
  boundaries. Direction-neutral.
metadata:
  tags: go, modularization, monorepo, multi-module, go.mod, architecture, refactoring,
    go.work, replace-directives, versioning, re-modularization, merge-modules,
    module-boundaries, internal-packages, error-types, unix-philosophy
allowed-tools: d2
---

# Go Modularize

A seven-phase workflow for finding the right Go module boundaries — splitting a
monolith into semi-independent sub-modules, merging over-split modules, or refining
existing boundaries. Each module gets its own go.mod. The process detects the current
state, proposes boundaries, subjects the proposal to brutal self-review, plans
execution with Pareto prioritization, executes step by step, and closes with a
reflection ensuring the result is superb and long-lasting.

**Load [./references/phases.md](./references/phases.md) for the detailed phase
procedures.** This file contains the decision framework, failure modes, and tooling
reference needed before and during execution. For a worked before/after example, see
[./references/example.md](./references/example.md). For patterns distilled from
production Go multi-module projects (dual go.work+replace strategy, CI verification,
error architecture, test infrastructure), see
[./references/real-world-patterns.md](./references/real-world-patterns.md).

## Why This Matters

A single go.mod lets every package depend on every other package; sub-modules
turn soft coupling into compile-time boundaries (enforced interfaces,
independent versioning, faster CI, clearer ownership). This skill handles
both directions: greenfield splits at the right seams, and refining existing
multi-module setups plagued by god-packages, circular replace directives, or
test-only dependencies leaking into production go.mod files.

---

## Design Principles — Unix Philosophy for Go Modules

These principles guide every decision in this skill. When in doubt, return here.

| Principle                      | Application to Go Modules                                                                                                                                   |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Do one thing well**          | Each module has a single, clear purpose. If you cannot describe it in one sentence, the boundary is wrong.                                                  |
| **Small is beautiful**         | Prefer many small, focused modules over few large ones. A module with 2 packages is fine. A module with 20 is a red flag.                                   |
| **Composition over monoliths** | Modules compose via interfaces. Consumers import what they need, never the whole system.                                                                    |
| **Thin textual interfaces**    | Go interfaces are the "pipes" of module architecture — thin, explicit, easy to inspect. Define what, not how.                                               |
| **Mechanism, not policy**      | Core modules define _what_ (interfaces, types, domain logic). Infrastructure modules define _how_ (implementations). Never mix them.                        |
| **Fail noisily**               | Build failures at module boundaries are _good_ — they catch coupling early. Do not suppress them with `replace` hacks or clever workarounds.                |
| **Opaque internals**           | Every module exposes a thin surface (interfaces + types). Internals are opaque, like file descriptors hide implementation. Use `internal/` to enforce this. |

### The Unix gate — where the decision weight lives

Principles without tests are decoration. Every proposed module must pass all
five gates. Gates 1–4 apply verbatim to packages inside a monolith (a
god-package is FM#11 at a smaller scale); gate 5 becomes "no hidden coupling
to siblings". No gate is waived by project size.

| #   | Gate       | Pass condition                                                                                      | On failure                                         |
| --- | ---------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| 1   | Purpose    | The module's responsibility is one sentence with one verb                                           | Split or merge — the boundary is wrong             |
| 2   | Pipe test  | At least one consumer, real or credibly planned, composes it without importing any sibling           | No composability payoff — dissolve the seam        |
| 3   | Direction  | Dependencies run policy → mechanism: app/infra may import domain; domain imports zero infrastructure | You have layering, not modules — redraw            |
| 4   | Surface    | Everything `internal/` by default; the exported contract is enumerable at a glance                   | Shrink the surface or extract a contract module    |
| 5   | Solo build | `GOWORK=off go build ./... && GOWORK=off go test ./...` green inside the module alone               | The module is a workspace fiction — fix or merge it |

A boundary that passes all five is worth its overhead at almost any project
size; one that fails is wrong at any size. Size changes how many boundaries
you can defend, never whether a given boundary is correct.

### Direction Neutrality — split and merge are equally valid

This skill is NOT biased toward splitting, and NOT biased toward merging. Both
"too many modules" and "too few modules" are failures of the same kind: a
boundary sits at the wrong place. The Unix principle "small is beautiful" is a
statement about _focus_, not _count_. `grep`, `sed`, and `awk` ship together,
release together, and co-change constantly — yet merging them into one binary
would destroy their composability. **Co-change is evidence to examine, never a
verdict to merge.**

Two questions replace "should I merge or split?":

1. **Decomposition depth** — Is each module at the right level of abstraction?
   A `domain/` module bundling `battle/`, `voting/`, `media/` "does one thing"
   (domain) at the wrong depth: each sub-domain could compose independently and
   deserves its own module. Conversely, a `userdto/` module with one struct is
   too deep — a boundary with no composability payoff.
2. **Composability payoff** — Does the boundary let consumers import only what
   they need? If every consumer imports modules A and B together, the seam earns
   nothing. If some consume A without B, it earns its keep.

When the evidence points to merging, merge. When it points to splitting, split.
Let the evidence decide — never a default bias in either direction.

---

## When NOT to Modularize

Modularization adds overhead — more go.mod files, more version management, more
CI complexity. But overhead prices a boundary; it does not veto one. The Unix
gate decides whether a boundary is right. These signals only decide how many
boundaries to draw now:

| Signal                       | What it actually tells you                                                                        | Action                                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Small project (<10 packages) | There is surface for at most one defensible boundary                                              | Draw zero or one, not five. Not a stop.                                                          |
| No consumer variance         | Every consumer imports A and B together — the seam earns nothing (the FM#8 test)                  | Redraw or dissolve. "No external consumers" is NOT this signal: import bans and per-module CI are payoffs without a single external user. |
| Prototype / spike            | Seams are not stable yet — boundaries drawn now get drawn wrong                                   | Defer the split; run gates 1–4 on packages now so the later extraction is mechanical.            |
| Everything changes together  | Co-change: evidence to examine, never a verdict (see Direction Neutrality); normal in young code   | Check consumer variance before concluding anything.                                              |

The old stop-rule ("3+ High signals → stop") is retired: it let monoliths hide
god-packages behind "too small to modularize". Staying one module is a fine
outcome — but the Unix gate applies with full force either way. A monolith with
gate-passing packages is discipline; a monolith with a god-package is FM#11
waiting to happen.

**Partial modularization** is a valid outcome. If the project only needs a `domain/` module
to decouple domain types from infrastructure, that's a good result. Not every project
needs 5+ modules.

---

## When NOT to Consolidate (and When to Split Further)

The table above governs the _initial_ split decision. The converse — should an
already-split project _merge_ modules or _split deeper_? — has its own
anti-signals. Do NOT merge when:

| Signal                                             | Weight | Why                                                                                                                               |
| -------------------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------- |
| Some consumers import one module without the other | High   | The boundary has a composability payoff. Merging destroys it.                                                                     |
| Modules share only a cross-cutting concern         | High   | Co-change is driven by a shared dependency (timestamps, `eventtest`), not real coupling. Extract the shared concern; don't merge. |
| Duplicated `replace` directives                    | —      | A go.mod hygiene problem, NOT a boundary problem. Fix in place; merging is the wrong cure (see FM#4).                             |
| Test-only deps leaking into production go.mod      | —      | A hygiene problem (see FM#3). Fix in place; merging to "hide" the leak treats the symptom, not the cause.                         |

**The hygiene trap:** Consolidation is NEVER the right fix for duplicated
`replace` directives or test-dep leaks. Those are go.mod hygiene issues — solve
them where they live. Merging modules to paper over a hygiene defect removes a
real boundary to fix an imaginary one.

**When to split further:** A module "does one thing" but at the wrong depth
when it bundles sub-domains that could each compose independently. A `domain/`
module spanning `battle/`, `voting/`, `media/` is under-modularized if a
consumer of battle logic is forced to import voting types. Test: could each
sub-package stand alone as a module that composes like a Unix pipe? If yes, the
boundary is one level too coarse — split deeper.

---

## Known Failure Modes

These are the top ways Go modularization goes wrong. Keep this catalog handy during
execution — if you hit one, the mitigation is here.

| #  | Failure                        | Cause                                                                                                                                                            | How to Detect                                                                                       | Mitigation                                                                                                                                                                                                                                                                                                                                                                                                      |
| -- | ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1  | **Import cycles**              | Circular deps between new modules                                                                                                                                | `go build ./...` fails with "import cycle not allowed"                                              | Enforce DAG before execution (Phase 3.2). If a cycle appears, boundaries are wrong — redraw.                                                                                                                                                                                                                                                                                                                    |
| 2  | **Transitive dep bloat**       | Module A depends on B's heavy external deps                                                                                                                      | `go mod graph` shows large dependency trees for thin modules                                        | Extract thin interface modules. Consumers depend on interfaces, not implementations.                                                                                                                                                                                                                                                                                                                            |
| 3  | **Test dep leaks**             | Test-only libs appear in production go.mod                                                                                                                       | `go mod why -m <dep>` shows only `_test.go` imports for a dep in `require` block                    | Move test helpers to separate modules. Audit each module's go.mod.                                                                                                                                                                                                                                                                                                                                              |
| 4  | **go.work / replace drift**    | `go.work` and `replace` directives disagree — go.work lists a module but replace points elsewhere, or replace is missing for a module pair that go.work resolves | `GOWORK=off go build ./...` fails in a module that builds fine with workspace                       | **Apps (never published): use both go.work AND replace directives** — go.work for development, replace for `GOWORK=off` CI and consumer builds. Keep them in sync with a CI check. **Proxy-published libraries: replaces live version-qualified in go.work, never in go.mod** (§Version Train). See [./references/real-world-patterns.md](./references/real-world-patterns.md) §Dual Strategy / §Version Train. |
| 5  | **Broken consumers**           | External import paths change without redirect                                                                                                                    | Consumer project fails to `go get` after modularization                                             | Use `go.mod` redirect tags or `// Deprecated` annotations.                                                                                                                                                                                                                                                                                                                                                      |
| 6  | **internal/ access breakage**  | Moving a package behind `internal/` blocks cross-module access                                                                                                   | `go build` fails with "use of internal package" from another module                                 | Remember: `internal/` restricts access to the _module_ tree, not just the package tree. A sub-module's `internal/` is invisible to all other modules.                                                                                                                                                                                                                                                           |
| 7  | **Error type inaccessibility** | `errors.Is`/`errors.As` fail because error types moved to a module the consumer doesn't import                                                                   | Tests pass locally (workspace provides all modules) but fail in isolation or for external consumers | Keep **contract** errors in the interface module (domain), not in implementations. Implementation-specific errors live in the implementation module. See [./references/real-world-patterns.md](./references/real-world-patterns.md) §Error Architecture.                                                                                                                                                        |
| 8  | **Over-modularization**        | Micro-modules with no composability payoff — every consumer imports A and B together                                                                             | `git log --stat` shows same files changed together AND no consumer imports one without the other    | Examine the boundary — do NOT auto-merge. Merge only if no consumer benefits from the seam (see Direction Neutrality). Co-change alone is not a verdict.                                                                                                                                                                                                                                                        |
| 9  | **Stale go.work**              | `go.work` references deleted or renamed modules                                                                                                                  | `go work sync` reports errors or `go build` fails at root                                           | Run `go work sync` after every structural change. Commit `go.work` and `go.work.sum` together.                                                                                                                                                                                                                                                                                                                  |
| 10 | **Build system breakage**      | Build system references old module paths                                                                                                                         | `nix build`, `make`, or CI fails after module moves                                                 | Update build system immediately after each module move.                                                                                                                                                                                                                                                                                                                                                         |
| 11 | **Under-modularization**       | God-modules bundling unrelated sub-domains at the wrong depth                                                                                                    | One go.mod with 14+ packages; importing feature X drags in feature Y's types                        | Split along sub-domain boundaries so each composes independently. The inverse of FM#8 — "too few" is as real a failure as "too many."                                                                                                                                                                                                                                                                           |
| 12 | **Workspace-only testing**     | Tests pass with `go.work` but fail in isolation — version mismatches, missing replace directives, or stale module references                                     | `GOWORK=off go build ./...` fails per-module but `go build ./...` at root passes                    | Test every module with `GOWORK=off` in CI. See [./references/real-world-patterns.md](./references/real-world-patterns.md) §CI Verification.                                                                                                                                                                                                                                                                     |

---

## Tooling Reference

These commands are essential for dependency analysis. Run them early and often:

| Command                     | Purpose                                                                                  |
| --------------------------- | ---------------------------------------------------------------------------------------- |
| `go mod graph`              | Show full dependency graph (direct + transitive)                                         |
| `go mod why -m <package>`   | Explain why a specific dependency exists                                                 |
| `go mod tidy`               | Clean up unused dependencies                                                             |
| `go mod verify`             | Verify downloaded modules match expected checksums                                       |
| `go vet ./...`              | Detect import cycles and other issues                                                    |
| `go list ./...`             | List all packages in the module                                                          |
| `go work sync`              | Sync go.work file with module state                                                      |
| `GOWORK=off go build ./...` | Test build without workspace — verify modules resolve without go.work                    |
| `GOWORK=off go test ./...`  | Per-module isolation testing — catches version mismatches and missing replace directives |
| `go work edit -fmt`         | Format and clean up go.work file                                                         |

For generating a visual dependency graph of internal packages only:

```bash
MODULE=$(head -1 go.mod | cut -d' ' -f2)
go mod graph | grep "^${MODULE}" | column -t -s ' '
```

### Minimum Go Versions

| Feature                                  | Go Version                                    |
| ---------------------------------------- | --------------------------------------------- |
| Multi-module workspaces (`go.work`)      | 1.18+                                         |
| `go work sync`                           | 1.22+ (earlier versions have limited support) |
| `go.work.sum` auto-management            | 1.21+                                         |
| Workspace vendor mode (`go work vendor`) | 1.22+                                         |

Before starting, check `go version` in the project. If the project's `go.mod` specifies
an older Go version, either upgrade it first or plan to use `replace` directives instead
of `go.work`.

---

## Phase Overview

The full phase procedures live in [./references/phases.md](./references/phases.md). Load
it before executing. Summary:

| Phase                        | Goal                                                                              |
| ---------------------------- | --------------------------------------------------------------------------------- |
| **1 — Detect Current State** | Map go.mod files, classify state, assess re-modularization if needed              |
| **2 — Research & Analysis**  | Map dependencies, find coupling, audit `internal/` and error types                |
| **3 — Draft Proposal**       | Define modules, enforce DAG, choose replace/go.work strategy, write HTML proposal |
| **4 — Brutal Self-Review**   | Proposal-specific checklist, cross-reference with `how-to-golang`                 |
| **5 — Execution Plan**       | Pareto-tiered task list, each step independently revertable                       |
| **6 — Execute**              | One step at a time, build/test/lint after each, commit checkpoints                |
| **7 — Final Reflection**     | Verify structure, independence, naming, documentation, deprecation                |

---

## Output

All modularization artifacts go to `docs/modularization/` as **self-contained HTML files**:

| File                         | Content                                         |
| ---------------------------- | ----------------------------------------------- |
| `<date>_PROPOSAL.html`       | Full modularization proposal with all decisions |
| `<date>_EXECUTION_PLAN.html` | Step-by-step migration with impact sorting      |

Use the shared [html-report-kit](./assets/html-report-kit/references/html-output-guide.md) design system for all
output. Dependency graphs render as D2→inline SVG within the HTML.

---

## Git Workflow

| When                           | Action                                        |
| ------------------------------ | --------------------------------------------- |
| Before starting                | Ensure clean git state, create feature branch |
| After Phase 3 (proposal)       | Commit with detailed message                  |
| After Phase 4 (self-review)    | Commit proposal updates                       |
| After Phase 5 (execution plan) | Commit the plan                               |
| After each Phase 6 step        | Commit with detailed message                  |
| After Phase 7 (reflection)     | Commit documentation updates                  |

Do not push unless the user explicitly requests it.

---
