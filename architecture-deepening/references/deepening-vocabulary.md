# Deepening Vocabulary

Canonical terms and principles for the deepening review. Use these words exactly; the substitutions listed under each entry are the ones that quietly change the design decision.

## Glossary

**Module** — anything with an interface and an implementation, deliberately scale-agnostic: function, class, package, or a tier-spanning slice.
_Avoid_: unit, component, service.

**Interface** — everything a caller must know to use the module correctly: the type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics.
_Avoid_: API, signature (too narrow — they name only the type-level surface).

**Implementation** — what is inside a module. Distinct from **adapter**: a Postgres repository is a small adapter with a large implementation; an in-memory fake is a large adapter with a small implementation. Say "adapter" when the seam is the topic, "implementation" otherwise.

**Depth** — leverage at the interface: how much behaviour a caller or test can exercise per unit of interface they must learn. A module is **deep** when a large amount of behaviour sits behind a small interface, **shallow** when the interface is nearly as complex as the implementation.

**Seam** (Michael Feathers) — a place where behaviour can change without editing the code at that place; the location where a module's interface lives. Where the seam goes is a separate decision from what sits behind it.
_Avoid_: boundary (overloaded with DDD's bounded context).

**Adapter** — a concrete thing that satisfies an interface at a seam. Names the role (which slot it fills), not the substance (what is inside).

**Leverage** — what callers get from depth: more capability per unit of interface learned. One implementation pays back across N call sites and M tests.

**Locality** — what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place instead of spreading across callers. Fix once, fixed everywhere.

## Deep vs shallow

```
Deep: small interface + large implementation

┌─────────────────────┐
│   Small Interface   │  few methods, simple parameters
├─────────────────────┤
│                     │
│ Deep Implementation │  complex logic hidden behind it
│                     │
└─────────────────────┘

Shallow: large interface + thin implementation (avoid)

┌─────────────────────────────────┐
│        Large Interface          │  many methods, complex parameters
├─────────────────────────────────┤
│  Thin Implementation            │  passes through to other modules
└─────────────────────────────────┘
```

When designing an interface, ask in order: can I remove a method, can I simplify a parameter, can I hide more complexity inside?

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module may be composed internally of small, swappable parts; they just are not part of its interface. Internal seams (private, used by its own tests) are legitimate alongside the external seam.
- **The deletion test.** Imagine deleting the module. Complexity vanishes → it was a pass-through. Complexity reappears across N callers → it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. Needing to test past the interface is evidence the module is the wrong shape.
- **One adapter means a hypothetical seam; two adapters mean a real one.** Do not introduce a seam unless something actually varies across it.

## Dependency categories

Classify every candidate; the category decides whether a seam is warranted at all.

| Category              | Meaning                                                                    | Seam verdict                                             |
| --------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------- |
| `in-process`          | Same process, same language, no external resource.                         | No seam. Deepen by collapsing wrappers.                  |
| `local-substitutable` | Real dependency has a faithful local stand-in (in-memory repo, temp dir).  | Seam only if tests already need the substitute.          |
| `ports & adapters`    | External boundary: network, database, payment, clock, filesystem contract. | Real seam — two or more adapters must exist.             |
| `mock`                | No faithful substitute; only a test double can stand in.                   | Last resort. Prefer reshaping until a real seam appears. |

**Replace, don't layer.** Deepening means the new module absorbs the old shallow ones. Adding a deeper module on top of the shallow ones and leaving them in the call path is not a deepening — it is a second interface to learn.

## Testability signals

Good interfaces make testing natural:

1. **Accept dependencies, don't create them** — injected collaborators cross the seam; constructed ones hide it.
2. **Return results, don't produce side effects** — a value is testable through the interface; an in-place mutation is not.
3. **Small surface area** — fewer methods and parameters mean fewer tests and simpler setup.

## Relationships

A **module** has exactly one **interface**. **Depth** is measured on that interface. A **seam** is where the interface lives. An **adapter** sits at a seam and satisfies the interface. Depth produces **leverage** for callers and **locality** for maintainers.

## Rejected framings

- **Depth as implementation-lines ÷ interface-lines** (Ousterhout) — rewards padding the implementation. Depth here means leverage.
- **"Interface" as the TypeScript `interface` keyword or a class's public methods** — too narrow; the interface includes every fact a caller must know.
- **"Boundary"** — overloaded with DDD's bounded context. Say seam or interface.

## Provenance

Adapted 2026-11-15 from the third-party `codebase-design` skill in `mattpocock/skills`, which the upstream `improve-codebase-architecture` calls but never ships alongside itself in a per-skill install. This repo owns the copy from here on.
