# Naming Review Skill — Comprehensive Status Report

**Date:** 2026-05-06 00:34
**Skill:** naming-review
**Location:** `~/projects/SKILLS/naming-review/` (source) → `~/.config/crush/skills/naming-review/` (installed)
**Commits:** 14 commits across 3 sessions (0cb3c34 → fb4ffb2)

---

## a) FULLY DONE

### Core Skill Structure (2,671 lines, 4 files)

| File                                   | Lines | Content                                                                         |
| -------------------------------------- | ----- | ------------------------------------------------------------------------------- |
| `SKILL.md`                             | 286   | 7-step process (Step 0–6), 8 checklist categories, report template, fix guide   |
| `references/common-naming-problems.md` | 973   | 36 anti-patterns with before/after examples + full worked example               |
| `references/naming-best-practices.md`  | 1,019 | 18 sections covering all naming domains, 6 language conventions                 |
| `scripts/naming-smells.sh`             | 393   | Automated detection with ripgrep, 7 severity categories + split-brain detection |

### Process Flow (7 Steps)

1. **Step 0: Run Automated Detection** — linter table (Go/TS/Rust/Python/Java/C#) + naming-smells.sh + quick grep patterns
2. **Step 1: Discovery** — read all source files, identify language, exclude generated code
3. **Step 2: Build Naming Glossary** — extract all identifiers grouped by domain, flag split-brain
4. **Step 3: Categorize** — classify each identifier into role (type/function/field/variable/package)
5. **Step 4: Review Against Checklist** — 8 categories with 33 individual checks
6. **Step 5: Generate Report** — structured markdown template with severity tables
7. **Step 6: Fix (When Requested)** — prioritized fix order + rename safety grep patterns

### Checklist Categories (33 checks)

- Honesty (4 checks) — lying names, hidden side effects, misleading scope, euphemisms
- Clarity (5 checks) — unpronounceable, abbreviations, single-letter, number suffixes, Hungarian
- Precision (5 checks) — vague nouns, vague verbs, Manager/Handler, redundancy with context/type
- Domain Alignment (4 checks) — ubiquitous language, mixed metaphors, split-brain, technical jargon
- Implementation Leakage (4 checks) — Impl suffix, Abstract/Base, I-prefix, framework leakage
- Boolean Naming (4 checks) — yes/no questions, negative booleans, ambiguous, return-type questions
- Function Naming (5 checks) — verb phrases, CQS, and/or, version suffixes, factory names
- Consistency (4 checks) — synonym drift, verb tense, domain consistency, cutesy names
- Language-Specific (5 conventions) — Go, TypeScript, Rust, Python, Java/C#

### Naming Domains Covered

- Data models (types, structs, classes, interfaces, enums)
- Functions (methods, procedures, constructors)
- Fields and variables (timestamps, collections, maps)
- Booleans (prefix guide, yes/no test, negative inversion)
- Events and commands (past tense vs imperative)
- Packages and modules (naming principles, homeless functions)
- DDD naming (ubiquitous language, bounded contexts, aggregates, value objects)
- Error naming (per-language conventions, sentinel errors, error messages)
- Test naming (per-language conventions, test double naming)
- API/Database naming (REST paths, table/column conventions, JSON field styles)
- Config/Environment variables (POSIX convention, feature flags)
- Concurrent/async naming (goroutines, channels, mutexes, WaitGroups, async/await)
- Observability naming (log messages, Prometheus metrics, trace spans)

### Automated Detection (naming-smells.sh)

- Vague type names (Data, Info, Record, Item) — Go, TypeScript, Python, Rust
- Manager/Handler/Processor classes — Go, TypeScript, Python, Rust
- Impl suffix — Go, TypeScript, Python, Rust
- Abstract/Base prefixes — Go, TypeScript, Python
- I-prefix interfaces — Go, TypeScript, Python, Rust
- Boolean non-questions — Go, TypeScript, Python, Rust
- Hungarian notation — Go, TypeScript
- Number-suffixed variables — Go, TypeScript
- **Split-brain detection** — Go structs with >60% field overlap
- Ripgrep availability check
- Self-exclusion (doesn't scan naming-review/ reference files)

### Multi-Language Examples

- Anti-patterns shown in Go, TypeScript, Python, Rust, Java
- Language-specific convention tables for 6 languages
- Official style guide links for all 6 languages

### Cross-References

- full-code-review, code-quality-scan, deduplicate-code, architecture-review

---

## b) PARTIALLY DONE

| Item                  | Status                         | What's Missing                                                    |
| --------------------- | ------------------------------ | ----------------------------------------------------------------- |
| Split-brain detection | Works for Go only              | No TypeScript/Python/Rust struct comparison                       |
| Script testing        | Tested on SKILLS repo only     | Not tested against a real production Go/TS/Python codebase        |
| Linter integration    | Listed in table, not automated | No script to auto-detect and run the right linter for the project |

---

## c) NOT STARTED

| Item                                                                              | Impact | Effort |
| --------------------------------------------------------------------------------- | ------ | ------ |
| Eval test cases (evals/evals.json) — no test prompts to verify skill quality      | HIGH   | MED    |
| Description optimization via skill-creator's run_loop.py                          | MED    | LOW    |
| Linter auto-detection script — detect project language and run appropriate linter | MED    | MED    |
| Split-brain detection for TypeScript/Python/Rust                                  | MED    | MED    |
| Integration with full-code-review skill — naming-review as a sub-step             | LOW    | LOW    |
| Naming glossary auto-generation script — extract identifiers and group by domain  | HIGH   | MED    |
| CI/CD integration — run naming-smells.sh as a pre-commit hook or CI step          | MED    | LOW    |

---

## d) TOTALLY FUCKED UP / REGRETS

| Item                                    | What Happened                                                                  | Fixed?   |
| --------------------------------------- | ------------------------------------------------------------------------------ | -------- |
| Script crashed on first real run        | `set -e` + `rg` exit code 1 = fatal. Script was committed broken, never tested | ✅ Fixed |
| Python regex double-escaped             | Failed multiedit left `\\s` instead of `\s` in Python patterns                 | ✅ Fixed |
| Process flow backwards                  | Automated Detection (Step 0) placed AFTER Steps 1-5                            | ✅ Fixed |
| Number-suffix false positives           | Pattern `\w+2\b` matched v2, Rule007, dates — 21 false positives               | ✅ Fixed |
| `--lang` arg parsing                    | `PATH_TO_SCAN="${1:-.}"` consumed first arg before `--lang` processed          | ✅ Fixed |
| Chinese characters `垃圾桶` in SKILL.md | Non-Chinese readers see garbled text                                           | ✅ Fixed |
| Duplicate Step 3 numbers                | After inserting glossary step, forgot to renumber                              | ✅ Fixed |

---

## e) WHAT WE SHOULD IMPROVE

### High Priority

1. **Test against real codebases** — The script and skill have only been tested on the SKILLS repo itself. Run against a real Go project (e.g., one of Lars's projects) to find real issues
2. **Naming glossary auto-generation** — Step 2 says "build a glossary" but provides no script. A script that extracts all type/function names and clusters them would be extremely valuable
3. **Split-brain for more languages** — Current split-brain detection only works for Go structs. TypeScript interfaces/classes and Python classes need the same treatment

### Medium Priority

4. **Linter auto-detection** — Instead of just listing linters in a table, detect the project language from file extensions and run the appropriate tool automatically
5. **Eval test cases** — Use skill-creator's eval system to create test prompts and verify the skill produces good reviews
6. **How-to-golang NOT synced to installed** — This skill exists in source but not in `~/.config/crush/skills/`

### Low Priority

7. **3 skills in installed but not in source** — `copywriting`, `improve-codebase-architecture`, `remotion-best-practices` exist in `~/.config/crush/skills/` but not in `~/projects/SKILLS/`
8. **More Rust examples in common-naming-problems.md** — Rust examples exist in best practices but anti-patterns are still Go/TS/Python heavy
9. **GraphQL/gRPC naming conventions** — Protobuf field naming, GraphQL schema naming not covered

---

## f) Top #25 Things To Do Next

| #   | Task                                                                                          | Impact | Effort | Category    |
| --- | --------------------------------------------------------------------------------------------- | ------ | ------ | ----------- |
| 1   | Test naming-smells.sh against a real production Go codebase                                   | HIGH   | LOW    | Validation  |
| 2   | Test naming-smells.sh against a real TypeScript codebase                                      | HIGH   | LOW    | Validation  |
| 3   | Create naming glossary auto-generation script                                                 | HIGH   | MED    | Feature     |
| 4   | Sync how-to-golang to installed location                                                      | MED    | LOW    | Sync        |
| 5   | Add eval test cases via skill-creator                                                         | HIGH   | MED    | Quality     |
| 6   | Add linter auto-detection to naming-smells.sh                                                 | MED    | MED    | Feature     |
| 7   | Split-brain detection for TypeScript classes/interfaces                                       | MED    | MED    | Feature     |
| 8   | Split-brain detection for Python classes                                                      | MED    | MED    | Feature     |
| 9   | Run description optimization via run_loop.py                                                  | MED    | LOW    | Quality     |
| 10  | Migrate 3 orphan skills to source repo (copywriting, improve-codebase-architecture, remotion) | MED    | LOW    | Sync        |
| 11  | Add GraphQL schema naming conventions                                                         | LOW    | LOW    | Content     |
| 12  | Add gRPC/Protobuf field naming conventions                                                    | LOW    | LOW    | Content     |
| 13  | Add more Rust anti-pattern examples                                                           | LOW    | LOW    | Content     |
| 14  | Add Java anti-pattern examples                                                                | LOW    | LOW    | Content     |
| 15  | Add C# anti-pattern examples                                                                  | LOW    | LOW    | Content     |
| 16  | CI/CD pre-commit hook for naming-smells.sh                                                    | MED    | LOW    | Integration |
| 17  | Integrate naming-review as sub-step of full-code-review                                       | LOW    | LOW    | Integration |
| 18  | Add naming "quick fix" mode — just list rename suggestions, no full report                    | MED    | LOW    | Feature     |
| 19  | Add naming consistency score (0-100) to reports                                               | MED    | LOW    | Feature     |
| 20  | Add "naming migration" mode — apply a canonical glossary across codebase                      | MED    | MED    | Feature     |
| 21  | Add naming-smells.sh to how-to-golang as recommended tool                                     | LOW    | LOW    | Integration |
| 22  | Add Protocol Buffers naming (snake_case fields, PascalCase messages)                          | LOW    | LOW    | Content     |
| 23  | Add Kubernetes resource naming conventions                                                    | LOW    | LOW    | Content     |
| 24  | Add Terraform/Infrastructure-as-Code naming conventions                                       | LOW    | LOW    | Content     |
| 25  | Create a naming-review README.md with quickstart guide                                        | MED    | LOW    | Docs        |

---

## g) Top #1 Question I Cannot Figure Out Myself

**Should naming-review be a standalone skill or a sub-component of full-code-review?**

Currently both skills exist independently and the naming-review description says "Use naming-review when you want focused, deep naming analysis." But in practice, every full-code-review should include a naming pass. The question is:

- **Option A**: Keep separate — naming-review is deep, full-code-review is broad. User picks which they need.
- **Option B**: Merge — full-code-review loads naming-review's checklist automatically as a sub-step.
- **Option C**: Hybrid — full-code-review has a "quick naming check" step, naming-review is the deep-dive version.

I cannot determine the right answer because it depends on how you (Lars) actually use these skills in practice — do you ever run naming-review standalone, or always as part of a broader review?

---

## File Inventory

```
naming-review/                           2,671 lines
├── SKILL.md                              286 lines  (7-step process, 33 checklist items)
├── scripts/
│   └── naming-smells.sh                  393 lines  (automated smell detector)
└── references/
    ├── common-naming-problems.md         973 lines  (36 anti-patterns + worked example)
    └── naming-best-practices.md        1,019 lines  (18 sections, 6 languages)
```

## Sync Status

| Source (`~/projects/SKILLS/`) | Installed (`~/.config/crush/skills/`) | Status           |
| ----------------------------- | ------------------------------------- | ---------------- |
| naming-review/                | naming-review/                        | ✅ Synced        |
| how-to-golang/                | —                                     | ❌ NOT synced    |
| 14 other skills               | 14 other skills                       | ✅ Synced        |
| —                             | copywriting/                          | ⚠️ Not in source |
| —                             | improve-codebase-architecture/        | ⚠️ Not in source |
| —                             | remotion-best-practices/              | ⚠️ Not in source |

## Commit History (14 commits)

```
fb4ffb2 feat: add split-brain detection, glossary step, rename safety, observability naming
29fa35f fix: fix script crash on no matches, false positives, arg parsing
8d1c766 feat: add worked example showing full mini-review
6cab889 fix: fix broken Python/Rust regex, add rg availability check
275e215 fix: move automated detection to Step 0, add generated code exclusion
ec306d3 fix: improve description for better triggering
cc7c7f9 feat: add concurrent/async naming, Rust detection, TOC updates
2e89d92 feat: add official style guide references
47fb5ba feat: add automated naming smell detection script
62a263a feat: add multi-language examples to common-naming-problems
5978f24 feat: add error, test, API/DB, and config naming conventions
bcf0d36 feat: add automated detection, linter integration, grep patterns, cross-references
0cb3c34 feat: add naming-review skill for reviewing identifier naming quality
```
