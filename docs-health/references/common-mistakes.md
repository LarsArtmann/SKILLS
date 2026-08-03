# Common Mistakes and Decision Trees

> Avoid these patterns when building or maintaining project docs.

## Common mistakes

### When building FEATURES.md

| Mistake                                 | Why it fails                                         | Instead                                                       |
| --------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------- |
| Copying README claims into FEATURES.md  | README is marketing, not verified truth              | Study the code, then write the status                         |
| Listing every endpoint as a feature     | Three endpoints often serve one user-visible feature | Group by user intent: one row per recognizable capability     |
| Rounding up to FULLY_FUNCTIONAL         | Inflates trust; users hit bugs they did not expect   | If you cannot exercise it, it is PARTIALLY_FUNCTIONAL at best |
| Ignoring BROKEN features                | Hiding broken things makes the inventory useless     | A BROKEN status that surprises the maintainer is a success    |
| Putting implementation details in Notes | FEATURES.md is inventory, not a code guide           | Cite the entry point and the gap; nothing more                |

### When building TODO_LIST.md

| Mistake                              | Why it fails                                         | Instead                                                     |
| ------------------------------------ | ---------------------------------------------------- | ----------------------------------------------------------- |
| Keeping DONE items in the list       | Clutters active work; nobody knows what is left      | Remove DONE items; log them in CHANGELOG.md                 |
| Adding vague items ("improve X")     | Nobody knows when it is done or what "improve" means | Refine into concrete steps, or move to ROADMAP.md           |
| Mixing ROADMAP vision into TODO_LIST | Dilutes actionable work with unbounded ideas         | ROADMAP.md is for raw ideas; TODO_LIST is for bounded tasks |
| No evidence column                   | Next person cannot verify without re-deriving        | Cite `file:line` for every item                             |
| Duplicating by text match            | Same task described differently stays duplicated     | Deduplicate by semantic intent                              |

### When building README.md

| Mistake                            | Why it fails                                      | Instead                                              |
| ---------------------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| Internal architecture in README    | End-users do not care about your module structure | Keep it user-facing; put internals in AGENTS.md      |
| Install commands that assume setup | "Just run X" when X needs Y installed first       | Test mentally on a clean machine; list prerequisites |
| Marketing copy for broken features | Users try it, it fails, trust is gone             | Cross-reference FEATURES.md for honest status        |

### When maintaining AGENTS.md

| Mistake                     | Why it fails                            | Instead                                                  |
| --------------------------- | --------------------------------------- | -------------------------------------------------------- |
| Hardcoding counts           | Numbers rot the fastest                 | Point at a command that recomputes (`wc -l`, `ls`, etc.) |
| Putting TODOs here          | Nobody actions them; they rot           | TODO_LIST.md owns actionable work                        |
| Putting feature status here | Splits the inventory                    | FEATURES.md owns feature status                          |
| Writing a changelog         | Conflates enduring context with history | CHANGELOG.md owns release history                        |
| Version numbers in headings | `## API Surface (v0.10.0)` rots on release | Drop the version: `## API Surface`                    |
| Commit hashes inline        | Provide no value after the fix ships    | Delete the hash; keep the lesson (if still relevant)     |
| Sprint/session numbers      | `(Sprint 52)` means nothing later       | State the current truth without the temporal anchor      |
| Coverage percentages        | Change on every commit                  | Delete entirely; not enduring                            |
| Code blocks >5 lines        | Duplicates source, wastes context budget | Link to the source file instead                         |
| Resolved incidents          | Zero future value once fixed            | Delete; the resolution lives in git history              |
| "Was X, now Y" narratives   | Documents history, not current state    | State only "Y" — the "was X" part is changelog           |
| Gotchas tables >20 rows     | Become refactoring graveyards           | Keep only current constraints; delete resolved entries   |
| Dated section headings      | `(added 2026-07-05)` rots immediately   | Remove the date; if it exists now, the date is noise     |
| Full config/API catalogs    | Duplicate structs and routers in prose  | Link to source or example config file                    |

### When verifying docs

| Mistake                            | Why it fails                                                        | Instead                                                          |
| ---------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Trusting docs at face value        | Stale docs lie                                                      | Treat every claim as a hypothesis to test                        |
| Patching when rebuild is needed    | Scar-covered docs become unreadable                                 | If factual drift exceeds 50%, rebuild from scratch               |
| Skipping cross-file checks         | Code-doc drift is only half the problem                             | Always check docs against each other too                         |
| Checking truth but not job-fitness | A 100% accurate doc can be 100% useless (structural decay)          | First state the doc's job; flag content that belongs elsewhere   |
| Ignoring structural decay          | TODO_LIST passes factual checks while 80% of it is historical cruft | If >25% of content is non-job, rebuild (see two-axis tree below) |

### When annotating many old files at once

| Mistake                                           | Why it fails                                                                             | Instead                                                                                      |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Stamping the same generic banner on every file    | Says nothing a reader can act on; noise that has to be rolled back (Verschlimmbesserung) | Annotate only files where it adds value; cite a commit hash or TODO id per file              |
| Treating "update all" as "every file must change" | Clutters already-clear files with duplicate info                                         | "All" means no file that NEEDS updating is missed — leaving clear files untouched is correct |
| Injecting a banner between title and body         | Destroys the historical document's structure and pushes real content down                | Prefer inline edits or an end-of-file `## Resolution` appendix                               |

> This is the full subject of the **[`update-old-docs`](../../update-old-docs/SKILL.md)** skill.
> Defer to it whenever the task involves bringing many OLD/historical documents
> current (distinct from rewriting LIVING docs in place).

---

## Decision trees

### Does this information belong in AGENTS.md or DOMAIN_LANGUAGE.md?

```
Is it a domain term (business concept, entity name)?
├── YES → docs/DOMAIN_LANGUAGE.md
└── NO → Is it a non-obvious behavior or gotcha?
    ├── YES → AGENTS.md
    └── NO → Is it a build/test command?
        ├── YES → flake.nix (AGENTS.md as pointer only)
        └── NO → Does not belong in either file
```

### Does this content pass the endurance test for AGENTS.md?

```
Will this statement be true 6 months from now?
├── NO → Does it describe what changed?
│   ├── YES → CHANGELOG.md (if not already logged)
│   └── NO → Is it a future task?
│       ├── YES → TODO_LIST.md or ROADMAP.md
│       └── NO → Delete it (it's stale)
└── YES → Does it duplicate what's in the source code?
    ├── YES → Replace with a link to the source file
    └── NO → Does it reference a specific version/date/sprint/commit?
        ├── YES → Strip the temporal anchor; state current truth
        └── NO → AGENTS.md ✓ (it passes)
```

### Is this a TODO_LIST item or a ROADMAP item?

```
Is it actionable with a clear scope?
├── NO (vague, unbounded) → ROADMAP.md
└── YES → Can you estimate the effort?
    ├── NO (too uncertain) → ROADMAP.md until refined
    └── YES → Is it short-term (next few weeks)?
        ├── YES → TODO_LIST.md
        └── NO (months away, depends on other work) → ROADMAP.md
```

### Is this feature FULLY_FUNCTIONAL or PARTIALLY_FUNCTIONAL?

```
Can you point to the code that implements it?
├── NO → PLANNED (if documented) or missing from FEATURES.md entirely
└── YES → Can you confirm it actually works?
    ├── NO (tests fail, endpoint 500s, disabled) → BROKEN
    └── YES → Are there known gaps or edge cases?
        ├── YES → PARTIALLY_FUNCTIONAL (cite the gap)
        └── NO → FULLY_FUNCTIONAL
```

### Rebuild or patch? (two independent axes)

Drift has two flavors. A doc can need a rebuild on one axis and not the
other. Check both before deciding. The "living doc disguised as a trophy
case" failure passes the factual axis cleanly and fails the structural axis
catastrophically — which is why factual-only verification misses it.

**Factual drift** (wrong hashes, ghost files, broken commands, stale status):

```
How much of the doc is factually stale?
├── < 25% of claims → Patch in place
├── 25-50% of claims → Patch, but review the whole file afterward
└── > 50% of claims → Rebuild from scratch using BUILD mode
```

**Structural decay** (content that belongs in another file — completed items
in TODO_LIST, "Previously Completed" sections, deferred items duplicating
ROADMAP):

```
How much of the doc is non-job content?
├── < 10% → Patch in place (delete the stray items)
├── 10-25% → Patch, but review the whole file afterward
└── > 25% → Rebuild from scratch using BUILD mode
```

---

## Examples: good vs bad

### Good FEATURES.md row

```
| Email/password login | FULLY_FUNCTIONAL | JWT in auth/login.go; covered by auth_test |
```

Why: concise, cites evidence, honest status, user-visible feature.

### Bad FEATURES.md row

```
| Auth | Works | Implemented |
```

Why: "Auth" is not a feature, "Works" is not a status, "Implemented" is not
evidence. What kind of auth? How well does it work? Where is the code?

### Good TODO_LIST.md row

```
| Fix session revocation 500 | TODO | High | 30min | auth/revoke.go:42 panics on nil token |
```

Why: specific task, clear status, ranked impact, effort estimate, cited evidence.

### Bad TODO_LIST.md row

```
| Improve authentication | DONE | ? | ? | maybe in auth/ |
```

Why: vague task, should not be DONE (remove it), no impact, no effort, no evidence.
