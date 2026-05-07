---
name: go-modularize
description: >
  Splits a Go monorepo into semi-independent sub-modules with their own go.mod files.
  Use when the user wants to modularize a Go project, split a Go monorepo into
  sub-modules, create independently versioned Go packages, restructure a Go project,
  or says "modularize", "split modules", "sub-modules", "go.mod per package",
  "multi-module Go project", "module boundaries", "dependency isolation",
  "Go workspace", "go.work", "CQRS modularization", "break apart Go project",
  "this Go project is too big", "too coupled", "Go package boundaries".
  Also trigger when the user asks how to structure a Go project into multiple
  modules, wants to break a large Go project into smaller pieces, wants a
  modularization proposal with execution plan, or wants to improve module
  boundaries in an already-partially-modularized Go project — including refining
  existing go.mod splits, fixing replace directives, or consolidating god-packages.
  Covers dependency graph analysis, module boundary identification, DAG enforcement,
  type model alignment, replace directive strategy, go.work setup, test dependency
  isolation, versioning strategy, interface extraction, and iterative self-review
  with git hygiene.
metadata:
  tags: go, modularization, monorepo, multi-module, go.mod, architecture, refactoring,
        go.work, replace-directives, versioning
---

# Go Modularize

A seven-phase workflow for splitting a Go project into semi-independent sub-modules,
each with its own go.mod. The process detects the current state, proposes boundaries,
subjects the proposal to brutal self-review, plans execution with Pareto prioritization,
executes the split step by step, and closes with a reflection ensuring the result is
superb and long-lasting.

## Why This Matters

A Go project with a single go.mod accumulates coupling — every package can depend on
every other package. Splitting into sub-modules creates hard boundaries: compile-time
enforced interfaces, independent versioning, faster CI, and clearer ownership. The
challenge is finding the right seams without breaking what works.

The converse problem also exists: a partially modularized project with god-packages,
circular replace directives, or test-only dependencies leaking into production go.mod
files. This skill handles both cases — greenfield splits and refinement of existing
multi-module setups.

---

## Tooling Reference

These commands are essential for dependency analysis. Run them early and often:

| Command | Purpose |
|---|---|
| `go mod graph` | Show full dependency graph (direct + transitive) |
| `go mod why -m <package>` | Explain why a specific dependency exists |
| `go mod tidy` | Clean up unused dependencies |
| `go vet ./...` | Detect import cycles and other issues |
| `go list ./...` | List all packages in the module |
| `go work sync` | Sync go.work file with module state |

For generating a visual dependency graph of internal packages only:

```bash
go mod graph | grep '^<module-name>' | column -t -s ' '
```

---

## Phase 1 — Detect Current State

**Goal:** Understand what you're working with before making any assumptions.

### 1.1 Count and locate go.mod files

```bash
find . -name go.mod -not -path './vendor/*'
```

This tells you immediately:

- **Single go.mod** → greenfield modularization
- **Multiple go.mod files** → partial or full split already in progress
- **go.work present** → workspace mode already active

### 1.2 Classify the starting state

| State | Indicators | Approach |
|---|---|---|
| Monolith | Single go.mod, all packages in one tree | Full modularization from scratch |
| Partial split | Multiple go.mods with `replace` directives, some packages still coupled | Refine boundaries, fix leaks |
| Workspace mode | go.work file coordinating multiple modules | Audit workspace structure |
| Already split | Clean DAG, minimal replace, independent CI per module | Skip to Phase 5 reflection only |

### 1.3 Map the existing module landscape

For each existing go.mod, extract:

- Module path
- Direct dependencies (internal + external)
- Whether deps are production or test-only
- `replace` directive targets (local path vs versioned)

### 1.4 Report findings

Present a summary table:

| Module | Path | Internal Deps | External Deps | Replace Directives | State |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | Clean / Leaky / Broken |

**Do not propose changes yet.** Report state so the user can course-correct.

---

## Phase 2 — Research & Analysis

**Goal:** Understand the project deeply enough to identify natural module boundaries
and coupling hotspots.

### 2.1 Explore the codebase

Read every package. Map:

- Package dependency graph (who imports whom) — use tooling from above
- Domain concepts vs infrastructure concerns
- Public API surface per package (exported types, interfaces, functions)
- Shared types and utilities
- Test patterns and testhelpers

### 2.2 Identify coupling points

Find:

- Circular or tangled dependencies
- Packages that import "everything" (god-packages)
- Types shared across domain boundaries
- Configuration that crosses module lines
- Test-only dependencies listed as production requires in go.mod

### 2.3 Detect god-packages

A god-package is a single package with 15+ files spanning multiple concerns.
Signs to look for:

- File names suggest unrelated concepts (e.g. `bus.go`, `store.go`, `codec.go`,
  `snapshot.go`, `upcaster.go` all in one package)
- More than 30 exported symbols
- Multiple distinct "clusters" of types that don't reference each other

For each god-package, list the concern clusters it contains. These are candidates
for package-level splits (within a module) that should happen *before* or *alongside*
module-level splits.

### 2.4 Research Go multi-module patterns

Load the `how-to-golang` skill for canonical project structure, required/banned
libraries, domain type patterns, and architecture patterns.

### 2.5 Report back

Present findings as:

- Current dependency graph (table or D2 diagram)
- Module boundary candidates with rationale
- God-package decomposition candidates
- Coupling risks and mitigation strategies
- Recommended module structure at a glance

**Do not propose a full plan yet.** Report findings first so the user can course-correct.

READ, UNDERSTAND, RESEARCH, REFLECT before proposing anything.

---

## Phase 3 — Draft Proposal

**Goal:** Write a concrete modularization proposal with all key decisions documented.

### 3.1 Define each proposed sub-module

For every module (existing or new):

| Field | Content |
|---|---|
| Name & path | e.g. `/core`, `/storage`, `/projection` |
| Purpose | One sentence |
| Dependencies (prod) | Which other sub-modules it imports in production code |
| Dependencies (test) | Which sub-modules it imports only in `_test.go` files |
| Public API | Types and functions exposed to other modules |
| Internal packages | Packages not meant for external consumption |
| External deps | go.mod requirements (third-party libraries) |

### 3.2 Enforce DAG structure

Dependency direction must be a directed acyclic graph:

- Core/domain modules → zero internal dependencies
- Infrastructure modules → depend on core only
- Integration/example modules → depend on core + infrastructure
- Test helper modules → depend on core only (never on infrastructure)

If you find a cycle, the boundaries are wrong. Redraw before proceeding.

**Special case — bidirectional test dependencies:** Sometimes module A's tests import
module B, and module B's tests import module A. This is acceptable in `_test.go` files
but must never appear in production code. Document these clearly.

### 3.3 Define replace directive strategy

Every multi-module Go repo needs a strategy for how modules reference each other during
development. Choose based on project maturity:

| Strategy | When to use | How |
|---|---|---|
| `replace` directives | All modules in same repo, not yet published | `replace github.com/org/mod => ./mod` in each go.mod |
| `go.work` file | 3+ modules, developer convenience | Single `go.work` at repo root listing all modules |
| Versioned imports | Modules published to proxy | Remove all `replace`, use proper semver tags |

**Recommendation for most projects:** Start with `go.work` at the repo root.
It's cleaner than per-module `replace` directives and Go tooling handles it well.
Each module's go.mod should be clean — no `replace` directives — and `go.work`
handles local development. When publishing, `go.work` is ignored by consumers.

Rules:
- Never mix `replace` directives AND `go.work` for the same module pair
- `go.work` belongs in `.gitignore` only if every consumer uses published versions
- Verify `go mod tidy` works both with and without the workspace

### 3.4 Plan test dependency isolation

Cross-module test dependencies are a common source of coupling. For each module,
categorize its imports:

- **Production deps** — used in non-test code → listed in `require` block
- **Test deps** — used only in `_test.go` files → listed with `// indirect` or
  in a separate test-only pattern

**Testhelpers strategy:** If a `testhelpers` package exists:

- Keep it as a separate module if it provides shared fakes/fixtures
- Its go.mod should depend only on core (domain types), never on infrastructure
- Infrastructure modules should have their own test helpers inline, not in the
  shared testhelpers module
- This prevents the common trap of `core` depending transitively on `storage`
  through testhelpers

### 3.5 Plan interface extraction

When moving a package into its own module, its consumers need a clean import surface.
Follow the Go convention:

- **Interface package** — `core/event/` defines `Event`, `Store`, `Bus` as interfaces
  and core types. Other modules import this to implement or consume.
- **Implementation package** — `storage/` provides concrete implementations of
  `core/event.Store`. Importers who only need the interface never see storage details.
- **Adapter package** — `memory/` provides in-memory implementations useful for
  testing. Keep separate from production implementations.

If a module exposes both interfaces and implementations, split into:
- `module/` — interfaces and types (thin)
- `module/adapters/` or `module/impl/` — concrete implementations

This keeps the dependency graph clean: consumers depend on the thin interface module,
not the heavy implementation.

### 3.6 Define versioning strategy

Choose before executing, not after:

| Strategy | How | Best for |
|---|---|---|
| Shared version | Single git tag `v1.2.3`, all modules bump together | Tight-coupled monorepo, single team |
| Independent semver | Tags per module path `core/v1.2.3`, `storage/v2.0.0` | Published libraries, multiple consumers |
| Root-only versioning | Only root module gets tags, sub-modules use `replace` | Internal projects, no external consumers |

Document the chosen strategy in the proposal. If using independent semver, specify
the git tag format (e.g. `module-name/v1.2.3`) from the start — retrofitting is painful.

### 3.7 Write the proposal

Write to `docs/modularization/PROPOSAL.md` with:

1. **Executive summary** — Why modularize, what changes, expected benefits
2. **Current state analysis** — Dependency graph, coupling hotspots, god-packages
3. **Proposed module structure** — Table from 3.1 + dependency diagram (D2 or ASCII)
4. **DAG verification** — Proof that the proposed structure is acyclic
5. **Replace / workspace strategy** — Which approach and why
6. **Test dependency isolation** — Production vs test dep classification per module
7. **Interface extraction plan** — Which modules get interface/impl splits
8. **Versioning strategy** — Chosen approach with rationale
9. **Migration strategy** — Ordered steps, each independently executable
10. **Risk assessment** — What could go wrong, how to mitigate
11. **Build system impact** — Changes needed to flake.nix, Makefile, CI/CD

Commit the proposal:

```
docs(modularization): add modularization proposal for <project>

- Analyzed current package dependency graph
- Identified N module boundary candidates
- Proposed structure: <list modules>
- Replace/workspace strategy: <chosen approach>
- Versioning: <chosen approach>
- Key decisions: <list 3-5 important decisions>
- Next: self-review and execution plan
```

---

## Phase 4 — Brutal Self-Review

**Goal:** Critically evaluate the proposal before investing execution effort.
This is a separate phase with a different mindset — slow, critical, paranoid.

### 4.1 Answer every question honestly

1. What did you forget?
2. What could you have done better?
3. What could you still improve?
4. Did you create any split brains — duplicate type definitions across modules
   that should be shared, or shared types that should be duplicated?
5. Are the module boundaries at the right granularity — too fine? too coarse?
6. Is there existing code that already fits the requirements for each module
   (i.e., can we avoid creating new packages by reusing what's there)?
7. Can type models be improved to create cleaner module interfaces?
8. Are you leveraging well-established Go libraries instead of reinventing?
9. Does the replace/workspace strategy actually work? Have you verified the
   import paths resolve correctly?
10. Are test-only dependencies isolated from production go.mod files?
11. Will CI/CD actually be faster after modularization, or have you just moved
    the bottleneck?
12. Is the versioning strategy realistic for how this project is consumed?

### 4.2 Cross-reference with how-to-golang

Load the `how-to-golang` skill and verify:

- No banned dependencies in any proposed module's go.mod
- Required libraries are present where needed
- Domain type patterns (branded IDs, value objects) are correctly placed
- Architecture patterns align with Go conventions

### 4.3 Update the proposal

Incorporate all findings into the proposal document. Commit with a detailed message
explaining what changed and why.

---

## Phase 5 — Execution Plan

**Goal:** Create a detailed, ordered, independently executable step list.

### 5.1 Break into smallest self-contained tasks

Each task must:

- Be completable in 15–30 minutes
- Leave the project in a buildable, testable state
- Be independently revertable (single commit)

### 5.2 Sort by Pareto impact

| Tier | Impact | Examples |
|---|---|---|
| 1% → 51% | Foundational | Extract core module, fix import paths |
| 4% → 64% | High leverage | Split god-packages, isolate test deps |
| 20% → 80% | Broad value | Add go.work, update CI, documentation |
| Remaining | Polish | Versioning setup, cleanup, examples |

### 5.3 Verify no duplicate work

For each task, check:

- Does existing code already solve this? (e.g., an adapter that just needs moving)
- Can a library replace custom code? (check how-to-golang references)
- Can type model improvements eliminate the need for this task entirely?

### 5.4 Write the plan

Write to `docs/modularization/EXECUTION_PLAN.md` with:

- Ordered task list with dependencies between tasks
- Estimated effort per task
- Verification steps (how to confirm the task worked)
- Rollback instructions per task

Commit the plan.

---

## Phase 6 — Execute

**Goal:** Execute the modularization step by step with safety nets.

### 6.1 Rollback strategy

Before starting execution, establish a safety net:

- Create a branch: `git checkout -b modularize/<short-description>`
- Each commit is a checkpoint — `git revert <sha>` undoes one step
- If multiple steps fail, `git reset --soft` to the last known-good commit
  (only with user approval)
- Never force push the modularize branch

### 6.2 Execute one step at a time

For each task in the execution plan:

1. Make the change
2. Run build: `go build ./...` (or `nix build` if using flakes)
3. Run tests: `go test ./...` (or `nix run .#test`)
4. Run lint: `go vet ./...` (or project's lint command)
5. Verify imports resolve: `go mod tidy && go mod verify`
6. If using go.work: `go work sync`
7. If everything passes: `git commit` with detailed message
8. If anything fails: fix immediately or revert — never accumulate broken state

### 6.3 Per-module verification checklist

After creating or modifying a module's go.mod:

- [ ] `go build ./...` passes in the module directory
- [ ] `go test ./...` passes in the module directory
- [ ] `go vet ./...` reports no issues
- [ ] `go mod tidy` changes nothing (already clean)
- [ ] No production dependency on test-only modules
- [ ] Import paths are correct (module path matches directory structure)
- [ ] If using go.work: root-level `go build ./...` still works

### 6.4 Build system updates

If the project uses `flake.nix`, update it to:

- Build each module independently
- Run tests per module
- Provide aggregated checks at the root level

Verify `nix build` and `nix flake check` pass after each modularization step.

### 6.5 When stuck

Report back and ask questions if genuinely stuck on something ambiguous.
Do not stop for perceived difficulty — exhaust these alternatives first:

1. Search for similar patterns in Go ecosystem projects
2. Check if the Go standard library solves it
3. Try a different module boundary
4. Simplify — merge two modules that resist clean separation

### 6.6 Final push

When all steps are complete and everything passes:

- Run full test suite one final time
- Verify `go work sync` (if applicable)
- `git push`

---

## Phase 7 — Final Reflection

After execution, reflect together on what makes this modularization superb:

1. **Structure** — Is the module layout clean and intuitive? Would a newcomer
   understand it in under 5 minutes?
2. **Dependencies** — Are all directions correct? No cycles? No upward dependencies?
   Run `go mod graph` to verify.
3. **Independence** — Can each module be versioned, tested, and built independently?
   Prove it: build each module in isolation.
4. **Robustness** — What would make this modularization last 3+ years without regret?
5. **Naming** — Are module names honest, domain-aligned, and consistent with
   Go conventions?
6. **Granularity** — Should any module be further split or merged? Any god-packages
   that survived the split?
7. **Documentation** — What needs updating?
   - README.md — reflects new structure
   - AGENTS.md — build/test commands per module
   - CONTEXT.md — domain glossary still accurate
   - flake.nix — builds and tests per module
   - CI/CD config — parallel per-module jobs
8. **CI/CD** — Can builds be parallelized per module? Are test boundaries clean?
   Does CI actually run faster now?
9. **Types** — Are shared types in the right module? Are impossible states
   unrepresentable? Any split brains introduced?
10. **Replace/workspace hygiene** — Are replace directives clean? Is go.work
    minimal? Will consumers of published modules have a clean experience?

Update all documentation to reflect the new structure. Commit the final state.

---

## Output

All modularization artifacts go to `docs/modularization/`:

| File | Content |
|---|---|
| `PROPOSAL.md` | Full modularization proposal with all decisions |
| `DEPENDENCY_GRAPH.md` | Current and proposed dependency analysis |
| `EXECUTION_PLAN.md` | Step-by-step migration with impact sorting |

---

## Git Workflow

| When | Action |
|---|---|
| Before starting | Ensure clean git state, create feature branch |
| After Phase 3 (proposal) | Commit with detailed message |
| After Phase 4 (self-review) | Commit proposal updates |
| After Phase 5 (execution plan) | Commit the plan |
| After each Phase 6 step | Commit with detailed message |
| After Phase 7 (reflection) | Commit documentation updates |
| Final | `git push` only when everything passes |

---

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at a time.
Repeat until done. Keep going until everything works and you did a great job!
