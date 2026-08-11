---
name: deduplicate-code
description: >
  Use when the user wants to find and remove code duplication, says "deduplicate",
  "DRY", "art-dupl", "find duplicates", "copy-paste code", "repeated code", "clones",
  "reduce duplication", or wants to clean up similar code blocks. This skill is about
  JUDGMENT — eliminating harmful duplication while accepting intentional similarity
  (table-driven tests, generated code, idiomatic patterns). Iterates to zero harmful
  clones, not zero report lines. Uses semantic clone detection (art-dupl). Distinct
  from code-quality-scan (broad build/lint/dup scan — use this skill when duplication
  is the sole focus).
metadata:
  tags: deduplication, quality, cleanup, art-dupl
allowed-tools: bash view edit grep
---

# Deduplicate Code

## Run

```bash
art-dupl --type-aware --sort total-tokens -t <threshold:5> --html
```

View the HTML output directly — do not save it as a file. `<threshold:5>`
means "the threshold the user asked for, defaulting to 5 when they gave
none." `-t` counts duplicated **statements** (not AST nodes). If the user
specifies a value — "threshold 3", "-t 10", "show me everything" — use that
exactly. Only fall back to `5` when the user said nothing.
Generated code (sqlc, protobuf, mockgen, stringer, templ) and test-file
noise are auto-excluded by default — add `--exclude-pattern` only when a
path genuinely slips past the detector.

## Iterate to Zero

For every clone group: read it, then **extract**, **accept**, or **exclude**.
Re-run art-dupl after each refactor — keep going until only intentional
duplication remains. Run tests after every change. Do not stop at "good
enough"; stop when the report is clean or every remaining clone has a
defensible reason to exist.

## Judgment: Harmful vs Acceptable

**Eliminate** — the duplication is a real maintenance burden:

- Same logic, different names (a semantic clone)
- Must change in N places to keep behavior consistent
- A clear domain name exists for the shared concept
- Shared setup, fixtures, or boilerplate across multiple packages

**Accept** — the similarity is intentional or idiomatic:

- Different business rules or domain contexts behind a similar shape
- Table-driven tests, standard assertions (`Expect(err).ToNot(HaveOccurred())`)
- Generated code (never hand-edit — exclude it, or `--include-generated` to inspect)
- An abstraction would take more parameters than the duplicated code has lines

When accepting, leave a one-line rationale so the next reader knows it was
deliberate.

## Done

**Zero harmful duplication — not zero report lines.** Every remaining clone
is there on purpose, every change is verified by tests.

## Related Skills

- **docs-health** ANNOTATE — Refactoring across many files (extract, rename) is a
  multi-file edit. When the change set is large, use ANNOTATE mode for restraint
  discipline: read every target first, make per-file judgment calls, and never
  blanket-script a transformation that needs judgment.
