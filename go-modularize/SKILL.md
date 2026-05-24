---
name: go-modularize
description: >
  Splits a Go monorepo into semi-independent sub-modules with their own go.mod files.
  Use when the user wants to modularize a Go project, split a Go monorepo into
  sub-modules, create independently versioned Go packages, restructure a Go project,
  or says "modularize", "split modules", "sub-modules", "go.mod per package",
  "multi-module Go project", "module boundaries", "dependency isolation",
  "Go workspace", "go.work", "CQRS modularization", "break apart Go project",
  "too coupled", "Go package boundaries", "remodularize", "re-modularize",
  "merge modules", "too many modules", "wrong module boundaries",
  "over-modularized", "consolidate modules", "fix module structure".
  Also trigger when the user asks how to structure a Go project into multiple
  modules, wants to break a large Go project into smaller pieces, or wants to
  improve module boundaries in an already-partially-modularized Go project —
  including merging over-split modules, fixing wrong boundaries, and cleaning
  up replace directive tangles.
metadata:
  tags: go, modularization, monorepo, multi-module, go.mod, architecture, refactoring,
        go.work, replace-directives, versioning, re-modularization, merge-modules,
        module-boundaries, internal-packages, error-types, unix-philosophy
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

## Design Principles — Unix Philosophy for Go Modules

These principles guide every decision in this skill. When in doubt, return here.

| Principle | Application to Go Modules |
|---|---|
| **Do one thing well** | Each module has a single, clear purpose. If you cannot describe it in one sentence, the boundary is wrong. |
| **Small is beautiful** | Prefer many small, focused modules over few large ones. A module with 2 packages is fine. A module with 20 is a red flag. |
| **Composition over monoliths** | Modules compose via interfaces. Consumers import what they need, never the whole system. |
| **Thin textual interfaces** | Go interfaces are the "pipes" of module architecture — thin, explicit, easy to inspect. Define what, not how. |
| **Mechanism, not policy** | Core modules define *what* (interfaces, types, domain logic). Infrastructure modules define *how* (implementations). Never mix them. |
| **Fail noisily** | Build failures at module boundaries are *good* — they catch coupling early. Do not suppress them with `replace` hacks or clever workarounds. |
| **Opaque internals** | Every module exposes a thin surface (interfaces + types). Internals are opaque, like file descriptors hide implementation. Use `internal/` to enforce this. |

**Litmus test for every proposed module:** Does it do one thing well? Can I compose it with other modules like Unix pipes? If not, redraw the boundary.

---

## When NOT to Modularize

Modularization adds overhead — more go.mod files, more version management, more CI
complexity. Before starting Phase 1, check if the project actually benefits:

| Signal | Do not modularize |
|---|---|
| Small project | Under 10 packages, single domain — a monolith is simpler |
| Single developer | No ownership boundaries needed — coupling is manageable |
| No external consumers | If nobody imports your packages, module boundaries add friction with no payoff |
| Prototype / spike | Modularize after the design stabilizes, not before |
| All packages change together | If every commit touches 80% of packages, boundaries are artificial |

**If 3+ of these apply, stop and discuss with the user before proceeding.**
Modularization should solve a real problem, not satisfy an aesthetic urge.

---

## Known Failure Modes

These are the top ways Go modularization goes wrong. Keep this catalog handy during
execution — if you hit one, the mitigation is here.

| # | Failure | Cause | Mitigation |
|---|---|---|---|
| 1 | **Import cycles** | Circular deps between new modules | Enforce DAG before execution (Phase 3.2). If a cycle appears, boundaries are wrong — redraw. |
| 2 | **Transitive dep bloat** | Module A depends on B's heavy external deps | Extract thin interface modules. Consumers depend on interfaces, not implementations. |
| 3 | **Test dep leaks** | Test-only libs appear in production go.mod | Audit with `go mod why -m <dep>` per module. Move test helpers to separate modules. |
| 4 | **go.work / replace conflicts** | Both `go.work` and `replace` directives for the same pair | Pick one strategy (see Phase 3.3). Never mix both. |
| 5 | **Broken consumers** | External import paths change without redirect | Use `go.mod` redirect tags or `// Deprecated` annotations. |
| 6 | **internal/ access breakage** | Moving a package behind `internal/` blocks cross-module access | Remember: `internal/` restricts access to the *module* tree, not just the package tree. A sub-module's `internal/` is invisible to all other modules. |
| 7 | **Error type inaccessibility** | `errors.Is`/`errors.As` fail because error types moved to a module the consumer doesn't import | Keep sentinel errors and error types in the interface module (core), not in implementations. |
| 8 | **Over-modularization** | 15 micro-modules that should be 4 | Merge modules that always change together. "Small is beautiful" does not mean "atomized." |
| 9 | **Stale go.work** | `go.work` references deleted or renamed modules | Run `go work sync` after every structural change. Commit `go.work` and `go.work.sum` together. |
| 10 | **Flake build breakage** | `flake.nix` references old module paths | Update flake.nix immediately after each module move (Phase 6.4). |

---

## Tooling Reference

These commands are essential for dependency analysis. Run them early and often:

| Command | Purpose |
|---|---|
| `go mod graph` | Show full dependency graph (direct + transitive) |
| `go mod why -m <package>` | Explain why a specific dependency exists |
| `go mod tidy` | Clean up unused dependencies |
| `go mod verify` | Verify downloaded modules match expected checksums |
| `go vet ./...` | Detect import cycles and other issues |
| `go list ./...` | List all packages in the module |
| `go work sync` | Sync go.work file with module state |
| `GOWORK=off go build ./...` | Test build without workspace — verify modules resolve without go.work |
| `go work edit -fmt` | Format and clean up go.work file |

For generating a visual dependency graph of internal packages only:

```bash
MODULE=$(head -1 go.mod | cut -d' ' -f2)
go mod graph | grep "^${MODULE}" | column -t -s ' '
```

### Minimum Go Versions

| Feature | Go Version |
|---|---|
| Multi-module workspaces (`go.work`) | 1.18+ |
| `go work sync` | 1.22+ (earlier versions have limited support) |
| `go.work.sum` auto-management | 1.21+ |
| Workspace vendor mode (`go work vendor`) | 1.22+ |

Before starting, check `go version` in the project. If the project's `go.mod` specifies
an older Go version, either upgrade it first or plan to use `replace` directives instead
of `go.work`.

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
| Over-modularized | 10+ micro-modules, high inter-module coupling, modules that always change together | Merge and reorganize |
| Already split | Clean DAG, minimal replace, independent CI per module | Skip to Phase 7 reflection only |

### 1.3 Map the existing module landscape

For each existing go.mod, extract:

- Module path
- Direct dependencies (internal + external)
- Whether deps are production or test-only
- `replace` directive targets (local path vs versioned)
- Packages behind `internal/` (these are inaccessible to other modules)

### 1.4 Report findings

Present a summary table:

| Module | Path | Internal Deps | External Deps | Replace Directives | State |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | Clean / Leaky / Broken |

**Do not propose changes yet.** Report state so the user can course-correct.

### 1.5 Re-modularization assessment

**Only when Phase 1 detects existing modules (partial split, over-modularized, or
workspace mode).** Skip for monoliths.

If modules already exist, the problem is rarely "add more modules." It is usually
"the existing boundaries are wrong." Before proposing anything new:

1. **Score existing boundaries** — For each current module, rate:
   - **Cohesion:** Do all packages in this module belong together? (1–5)
   - **Coupling:** Does this module depend on things it should not? (1–5, lower is better)
   - **Independence:** Can this module be built, tested, and versioned alone? (yes/no)

2. **Identify wrong seams** — Common patterns:
   - **Layer-based split** (all handlers in one module, all storage in another) → should be
     domain-based instead
   - **Accidental split** (modules created because "we should modularize" without clear purpose)
   - **Historical artifacts** (modules that made sense at the time but no longer do)

3. **Classify the remodel** — For each existing module, decide:

   | Action | When |
   |---|---|
   | **Keep** | Cohesion high, coupling low, clear purpose |
   | **Merge** | Always changes together with another module, or too small to justify its own go.mod |
   | **Split** | Contains multiple unrelated concerns (god-module) |
   | **Reorganize** | Right packages, wrong boundaries — move packages between modules |
   | **Retire** | No longer used, empty, or fully absorbed by another module |

4. **Map the transition** — Build a migration matrix:

   | Old Module | Old Path | Action | New Module(s) | Migration Path |
   |---|---|---|---|---|
   | ... | ... | Keep / Merge / Split / Reorganize / Retire | ... | ... |

5. **Plan deprecation** — For modules being retired or merged:
   - Add `// Deprecated:` comments to all exported symbols pointing to the new location
   - If the module has external consumers: create a final release with deprecation notices
   - Use `go.mod` redirect tags (`// deprecated` comment) if the module path is changing
   - Set a sunset timeline (e.g., remove after 2 minor versions)

Present the assessment before continuing to Phase 2. The user may disagree with the
scores or the remodel classification.

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
- Error types and where they are defined (critical for cross-module `errors.Is`/`errors.As`)

### 2.2 Identify coupling points

Find:

- Circular or tangled dependencies
- Packages that import "everything" (god-packages)
- Types shared across domain boundaries
- Configuration that crosses module lines
- Test-only dependencies listed as production requires in go.mod
- Sentinel errors or error types used across package boundaries

### 2.3 Detect god-packages

A god-package is a single package with many files spanning multiple concerns.
Signs to look for (these are rules of thumb, not hard limits):

- 15+ files with names suggesting unrelated concepts (e.g. `bus.go`, `store.go`,
  `codec.go`, `snapshot.go`, `upcaster.go` all in one package)
- More than 30 exported symbols
- Multiple distinct "clusters" of types that do not reference each other

For each god-package, list the concern clusters it contains. These are candidates
for package-level splits (within a module) that should happen *before* or *alongside*
module-level splits.

### 2.4 Research Go multi-module patterns

Load the `how-to-golang` skill for canonical project structure, required/banned
libraries, domain type patterns, and architecture patterns.

### 2.5 Audit `internal/` usage

When splitting into modules, `internal/` packages behave differently:

- `internal/` in module A is accessible only to packages within module A's tree
- Other modules — even in the same repo — cannot import it
- Moving a package behind `internal/` in a sub-module will break any cross-module imports

Check which `internal/` packages are imported from outside their module tree. These
need either:
- Extraction to a non-internal location, or
- Duplication in the consuming module, or
- Interface extraction so consumers depend on an interface, not the internal package

### 2.6 Audit error types

For cross-module error handling:

- Sentinel errors (`var ErrNotFound = errors.New(...)`) must live in the module that
  *defines the interface*, not the implementation
- Custom error types must be importable by any consumer that needs to check them
- If `errors.Is(err, core.ErrNotFound)` should work across modules, `ErrNotFound`
  must be in a module that both producer and consumer import

Map all error types to their proposed module and verify accessibility.

### 2.7 Report back

Present findings as:

- Current dependency graph (table or D2 diagram)
- Module boundary candidates with rationale
- God-package decomposition candidates
- `internal/` access violations after proposed split
- Error type placement analysis
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
| Purpose | One sentence (if you cannot, the module is too broad) |
| Dependencies (prod) | Which other sub-modules it imports in production code |
| Dependencies (test) | Which sub-modules it imports only in `_test.go` files |
| Public API | Types and functions exposed to other modules |
| Internal packages | Packages not meant for external consumption |
| Error types | Sentinel errors and custom error types, with justification for placement |
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
- Always commit `go.work` and `go.work.sum` together

### 3.4 Plan test dependency isolation

Cross-module test dependencies are a common source of coupling. For each module,
categorize its imports:

- **Production deps** — used in non-test code → listed in `require` block
- **Test deps** — used only in `_test.go` files → still listed in `require` block
  (Go does not have a separate test-only require block). Audit with
  `go mod why -m <dep>` to confirm which deps are test-only and ensure they are
  not pulling in unnecessary transitive production deps.

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

### 3.7 Plan breaking change prevention

If the project has external consumers (published to GOPROXY or imported by other repos):

- Map all currently exported symbols and their import paths
- After modularization, verify every exported symbol still exists at the same path
  or has a clear redirect
- Use `go api-compare` or manual audit to detect breaking changes
- For module path changes: use GOPROXY redirects or `go.mod` `replace` directives
  with `// deprecated` comments pointing to the new path
- Test the migration: create a consumer that imports the old paths, verify it still
  compiles after modularization

### 3.8 Write the proposal

Write to `docs/modularization/PROPOSAL.md` with:

1. **Executive summary** — Why modularize, what changes, expected benefits
2. **Current state analysis** — Dependency graph, coupling hotspots, god-packages
3. **Re-modularization assessment** (if applicable) — Scores, remodel classification,
   migration matrix, deprecation plan
4. **Proposed module structure** — Table from 3.1 + dependency diagram (D2 or ASCII)
5. **DAG verification** — Proof that the proposed structure is acyclic
6. **Replace / workspace strategy** — Which approach and why
7. **Test dependency isolation** — Production vs test dep classification per module
8. **Interface extraction plan** — Which modules get interface/impl splits
9. **Error type placement** — Where sentinel and custom errors live, with accessibility check
10. **Versioning strategy** — Chosen approach with rationale
11. **Breaking change analysis** — Affected import paths, redirect/deprecation plan
12. **Migration strategy** — Ordered steps, each independently executable
13. **Risk assessment** — What could go wrong, how to mitigate (reference failure modes)
14. **Build system impact** — Changes needed to build system (flake.nix, if applicable) and CI/CD

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

### 4.1 Proposal-specific review checklist

Generate a review checklist *from the specific proposal*, not from generic questions.
For each proposed module, ask:

| # | Question | Check |
|---|---|---|
| 1 | What did you forget? | Any packages not assigned to a module? Any imports not accounted for? |
| 2 | What could be improved? | Are any modules doing more than one thing? Any Unix principle violations? |
| 3 | Split brains? | Duplicate type definitions across modules that should be shared? Shared types that should be duplicated? |
| 4 | Right granularity? | Any module with 15+ packages (too coarse)? Any module with 1 trivial package (too fine)? |
| 5 | Existing code reuse? | Can existing code fill the role without creating new packages? |
| 6 | Type model quality? | Can type improvements create cleaner module interfaces? |
| 7 | Reinventing the wheel? | Are you leveraging well-established Go libraries instead of writing custom code? |
| 8 | Import paths verified? | Does the replace/workspace strategy actually work? Did you trace the full import chain? |
| 9 | Test deps isolated? | Are test-only deps absent from production go.mod files? Audit with `go mod why`. |
| 10 | CI actually faster? | Will modularization speed up CI, or just move the bottleneck? Estimate per-module test times. |
| 11 | Versioning realistic? | Does the versioning strategy match how this project is actually consumed? |
| 12 | Error types accessible? | Can consumers use `errors.Is`/`errors.As` across module boundaries? Trace the imports. |
| 13 | internal/ safe? | Did moving packages behind `internal/` break any cross-module imports? |
| 14 | Over-modularized? | Should any proposed modules be merged? Do they always change together? |
| 15 | Consumers broken? | Will external consumers compile after this change? Run the breaking change analysis. |

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

- Be the smallest unit that leaves the project buildable and testable
- Be independently revertable (single commit)

### 5.2 Sort by concrete Pareto tiers

Sort tasks into tiers by concrete module category:

| Tier | Impact | What goes here | Examples |
|---|---|---|---|
| 1 — Core | Foundational. Without this, nothing else works. | Extract core/domain module, fix all import paths to reference it | Create `core/go.mod`, move domain types, update all imports |
| 2 — Untangle | High leverage. Fixes the most painful coupling. | Split god-packages, isolate test deps, break circular replace directives | Extract `storage/` from god-package, create `testhelpers/go.mod` |
| 3 — Infrastructure | Broad value. Completes the module graph. | Extract infrastructure modules, add go.work, update CI per module | Create `storage/go.mod`, `projection/go.mod`, write `go.work` |
| 4 — Polish | Long-term health. Can ship without, but should not. | Versioning setup, deprecation notices, documentation, examples | Add semver tags, write migration guide, update README |

### 5.3 Verify no duplicate work

For each task, check:

- Does existing code already solve this? (e.g., an adapter that just needs moving)
- Can a library replace custom code? (check how-to-golang references)
- Can type model improvements eliminate the need for this task entirely?

### 5.4 Write the plan

Write to `docs/modularization/EXECUTION_PLAN.md` with:

- Ordered task list with dependencies between tasks
- Tier assignment per task
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
  (`--soft` preserves working tree — safe to use without approval)
- Never force push the modularize branch

### 6.2 Execute one step at a time

For each task in the execution plan:

1. Make the change
2. Run build: `go build ./...` (or project's build command)
3. Run tests: `go test ./...` (or project's test command)
4. Run lint: `go vet ./...` (or project's lint command)
5. Verify imports resolve: `go mod tidy && go mod verify`
6. If using go.work: `go work sync`
7. If everything passes: `git commit` with detailed message
8. If anything fails: fix immediately or revert — never accumulate broken state

### 6.3 Mini-reflection after each step

After each commit, pause and ask:

- Did this step reveal that the plan needs adjusting?
- Did an unexpected coupling surface? Should boundaries shift?
- Is the project still on track for the Unix principle test? (Does each module do one thing well?)

If the answer to any of these is "no," update the execution plan before continuing.
Do not blindly follow a plan that reality has invalidated.

### 6.4 Per-module verification checklist

After creating or modifying a module's go.mod:

- [ ] `go build ./...` passes in the module directory
- [ ] `go test ./...` passes in the module directory
- [ ] `go vet ./...` reports no issues
- [ ] `go mod tidy` changes nothing (already clean)
- [ ] No production dependency on test-only modules
- [ ] Import paths are correct (module path matches directory structure)
- [ ] Error types are accessible from consuming modules
- [ ] `internal/` packages are not imported from outside the module tree
- [ ] If using go.work: root-level `go build ./...` still works
- [ ] `go.work` and `go.work.sum` are committed together

### 6.5 Build system updates

If the project uses a build system (flake.nix, Makefile, etc.), update it to:

- Build each module independently
- Run tests per module
- Provide aggregated checks at the root level

Verify the build system passes after each modularization step.

### 6.6 When stuck

Do not stop for perceived difficulty — exhaust these alternatives first:

1. Search for similar patterns in Go ecosystem projects
2. Check if the Go standard library solves it
3. Try a different module boundary
4. Simplify — merge two modules that resist clean separation
5. Consult the Known Failure Modes table above

Only report back to the user after exhausting all five alternatives.

### 6.7 Final verification

When all steps are complete and everything passes:

- Run full test suite one final time
- Verify `go work sync` (if applicable)
- Run the breaking change analysis from Phase 3.7 — confirm no external consumers are broken

---

## Phase 7 — Final Reflection

After execution, reflect on what makes this modularization superb. These questions
should feel familiar — they were asked as mini-reflections during execution. Now
answer them for the final state:

1. **Structure** — Is the module layout clean and intuitive? Would a newcomer
   understand it in under 5 minutes?
2. **Unix principles** — Does each module do one thing well? Can they compose like
   pipes? Is mechanism separated from policy?
3. **Dependencies** — Are all directions correct? No cycles? No upward dependencies?
   Run `go mod graph` to verify.
4. **Independence** — Can each module be versioned, tested, and built independently?
   Prove it: build each module in isolation.
5. **Robustness** — What would make this modularization last 3+ years without regret?
6. **Naming** — Are module names honest, domain-aligned, and consistent with
   Go conventions?
7. **Granularity** — Should any module be further split or merged? Any god-packages
   that survived the split? Any micro-modules that should be combined?
8. **Error types** — Can `errors.Is`/`errors.As` work across all module boundaries
   that need it? Are sentinel errors in the right modules?
9. **internal/ hygiene** — Are `internal/` packages truly internal? Any accidental
   cross-module access?
10. **Documentation** — What needs updating?
    - README.md — reflects new structure
    - AGENTS.md — build/test commands per module
    - CONTEXT.md — domain glossary still accurate
    - Build system (flake.nix, etc.) — builds and tests per module
    - CI/CD config — parallel per-module jobs
11. **CI/CD** — Can builds be parallelized per module? Are test boundaries clean?
    Does CI actually run faster now?
12. **Types** — Are shared types in the right module? Are impossible states
    unrepresentable? Any split brains introduced?
13. **Replace/workspace hygiene** — Are replace directives clean? Is go.work
    minimal? Will consumers of published modules have a clean experience?
14. **Deprecation** — Are retired modules properly deprecated? Do migration paths
    exist for consumers?

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

Do not push unless the user explicitly requests it.

---

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and verify them one step at a time.
Repeat until done. Keep going until everything works and you did a great job!
