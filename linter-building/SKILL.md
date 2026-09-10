---
name: linter-building
description: >
  Use this skill whenever the user wants to build, write, or design a linter,
  static analyzer, custom lint rule, or linter tooling, or asks which linter
  framework to use. Triggers on "write a linter", "build an analyzer",
  "custom rule", "golangci-lint plugin", "oxlint plugin", "static analysis
  tool", "reduce linter false positives", "nolint handling", "lint autofix",
  "SARIF output", "finding data model", "lint exit codes", "lint baseline",
  "architecture test", "archtest". Covers: the mechanism decision tree
  (configure existing vs delegate vs AST walker vs go/analysis vs filesystem
  rules vs configurator), finding/severity/confidence modeling, suppressions,
  autofix safety, FP control, testing, distribution (CLI, golangci plugin,
  Action, SARIF). Distinct from code-quality-scan (RUNS existing linters;
  this AUTHORS new ones) and how-to-golang (general Go policy).
metadata:
  tags: linter, static-analysis, go, go-analysis, golangci-lint, sarif, autofix, finding, rules
allowed-tools: bash view grep
---

# Linter Building

How to build linters, analyzers, and lint-adjacent tooling that developers
keep turned on. Go-first (that is where the verified experience lives), but
the finding model, trust engineering, and distribution doctrine apply to any
language.

**tl;dr — Trust is the product.** The #1 failure mode is shipping false
positives: one crying-wolf rule and users uninstall the whole tool or drown
it in suppressions. The #2 failure mode is building the wrong layer — linter
#842 when a config change, a delegation to a specialist tool, or a 100-line
architecture test would have done the job. Decide the mechanism BEFORE
writing an analyzer, engineer confidence into every finding, and emit a
shared finding type instead of inventing a converter layer.

## Process

1. **Classify the rule.** Ask: what FACT does this rule need — syntax shape,
   type facts, project layout, import graph, or config state? Walk the
   decision tree in [./references/mechanism-choice.md](references/mechanism-choice.md).
   Most "let's write a linter" requests end correctly at this step: configure
   an existing linter, delegate, or write an architecture test instead.
2. **Adopt the finding model before detection logic.** Never invent a native
   issue type plus a converter (measured cost in real projects: 1,200–1,900
   LOC of glue per linter, deleted wholesale on migration). In Go, use
   `github.com/larsartmann/go-finding` and emit `finding.Finding` directly —
   or alias `type Issue = finding.Finding` as the minimal adoption. Full
   model: [./references/finding-model.md](references/finding-model.md).
3. **Design for confidence.** Multi-signal detection (never single-signal),
   negative filters, per-finding confidence. Read
   [./references/trust-engineering.md](references/trust-engineering.md)
   BEFORE writing detection logic — retrofitting false-positive control onto
   a naive rule is a rewrite.
4. **Engineer suppressions from day one.** Stable rule IDs, namespaced
   directives, reason required, staleness verification.
   [./references/suppressions-and-fixes.md](references/suppressions-and-fixes.md).
5. **If autofixing: safety machinery is not optional.** Dry-run default,
   per-finding fix outcomes, rollback, conflict detection — same reference.
6. **Test like a linter author.** Positive AND negative fixtures per rule,
   golden outputs, a corpus sweep with a measured false-positive rate, and a
   discrimination proof that the tests actually fail on a broken rule.
   Covered in [./references/trust-engineering.md](references/trust-engineering.md#testing-the-linter-itself).
7. **Distribute in layers.** One detector core behind library, CLI,
   golangci-lint plugin, GitHub Action, and SARIF — never four
   implementations. [./references/distribution.md](references/distribution.md).
8. **Reuse the local stack before building anything.**
   [./references/ecosystem.md](references/ecosystem.md) maps Lars's existing
   linter-building blocks (go-finding, go-linter-sdk, the auto-configure
   pair) and which reference linter to copy for each architecture.

## Decision tree (summary)

| The rule needs...                                            | Build/Use                                                                                  | Why                                                                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| Nothing an existing linter can't express                     | Config (+ auto-configure tool)                                                             | Cheapest layer. Ceiling: no path scoping for bans, no multi-signal patterns — then graduate to a plugin |
| A syntax pattern in code                                     | Custom AST walker (`go/parser` + `ast.Inspect`)                                            | Fast, no build required, works on dirty trees; resolve import aliases syntactically                     |
| Type facts (interface satisfaction, method sets, resolution) | `go/analysis` with types                                                                   | Not decidable from the AST alone; attribute findings at the call site where the fix lands               |
| File/project layout, config hygiene, repo meta               | Filesystem rule engine                                                                     | go/analysis is per-package; layout is not a package question                                            |
| Import/architecture constraints                              | go-arch-lint config, delegation, or an architecture test (`go list -deps` forbidden pairs) | An arch-test is ~100 LOC, runs as a normal Go test, fails with a reason string                          |
| Something a specialist tool already does                     | Wrap it (ToolAdapter / ExternalToolRule)                                                   | Never reimplement; normalize exit codes (exit 1 = findings, NOT a failure)                              |
| "Which of 800 rules should be on?"                           | A configurator layer, not a linter                                                         | Profiles as data over an embedded, versioned rule registry                                              |
| One finding model across many tools                          | A merge/correlate layer (go-finding)                                                       | Dedup by ID / position / rule; correlate overlapping ranges                                             |

Full matrix with project evidence and anti-patterns:
[./references/mechanism-choice.md](references/mechanism-choice.md).

## Core rules

- **Rule = value object + pure function.** `RuleFunc{Meta, Run}`: a
  declarative identity header (stable `ID` that never changes once shipped +
  mutable display `Name`) plus a detection closure returning findings.
  Interfaces only for capabilities (fixable, project-aware) — never a
  god-interface.
- **Severity ≠ Confidence.** Severity = how bad if real; confidence = how
  sure the rule is that it is real. The ternary exit code (0 clean /
  1 high-confidence findings / 2 needs triage) only works when they are
  separate axes.
- **Registry contracts.** Duplicate rule ID = panic at startup — a
  programming error, not a runtime condition. Execution fails fast by
  default (opt-in continue-on-error); wrap errors with the rule ID at
  exactly one chokepoint, never double-wrap.
- **Attribute findings where the fix lands** — the registration call site,
  not the type definition; real `file:line:col` positions, never fabricated
  line 0.
- **Normalize zero values everywhere.** A split-brain where `""` and
  `"none"` both mean "no fix strategy" but compare unequal is a shipped-bug
  class (go-finding explicitly normalizes at every entry point for this
  reason).
- **Strict on export, lenient on import.** Your own output validates fully;
  foreign SARIF/JSON may legitimately lack fields — never silently drop
  valid external results for being incomplete.

## Glossary

- **Finding** — one immutable issue record: identity (tool, rule, position),
  classification (severity, category, tags), fix info (strategy, suggestion,
  before/after code), and context (range, snippet, confidence, related,
  suppression). Immutable data, not a state machine.
- **Rule** — one detection: stable ID, name, description, category, default
  severity, enabled-by-default flag, and the check itself.
- **Detector** — anything that yields findings (`Name() + Detect(ctx)`); the
  unit the pipeline schedules, times, and isolates.
- **Confidence** — per-finding certainty (Low/Medium/High/Full, or 0–1).
  Drives `--min-confidence` filtering and triage exit codes.
- **FixStrategy** — `none | suggest | direct | ai`: what remediation is
  possible, decided per finding, not per rule.
- **Suppression** — data, not a comment hack: kind (in-source / in-config /
  in-review), rule, reason, optional expiry. Expiry forces re-review.
- **Baseline / ratchet** — a saved snapshot of current findings so adoption
  is incremental: old findings pass, new ones fail.
- **Discrimination proof** — demonstrating the test corpus fails on a
  deliberately broken (mutant) analyzer; proves the tests test.
- **Configurator** — a tool that generates/validates a linter's config
  (profiles, priorities) instead of linting code itself.
- **Health score** — findings as a 0–100 trend metric, not just pass/fail.

## When NOT to build

- An existing linter covers it → configure it (golangci-lint / oxlint
  settings; consider the auto-configure tools in
  [./references/ecosystem.md](references/ecosystem.md)).
- The constraint is architectural (X must not import Y) → an architecture
  test in the repo beats a distributed linter: versioned with the code,
  runs in `go test`, fails with a reason.
- The itch is "too many rules, which matter?" → build the decision layer
  (profiles, priorities, governance maps), not detection number 842.
- You cannot state the rule's false-positive budget → you do not understand
  the rule well enough to encode it yet. Write the golden corpus first.

## Verification status

| Claim                                                                                                                                                                                                                                                            | Status                              | Source                                                                                                                                                                     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| go-finding public (v1.9.x core): `Finding` struct, `NewBuilder(...).Build()`, `Detector` interface shapes                                                                                                                                                        | ✅ verified 2026-09-09, source read | `/home/lars/projects/go-finding/{finding,finding_builder,detector}.go`                                                                                                     |
| go-linter-sdk: `Rule`/`RuleFunc{Meta,Run}`/`Registry.Run`/`ExitCodeByConfidence` returns 0/1/2                                                                                                                                                                   | ✅ verified 2026-09-09, source read | `/home/lars/projects/go-linter-sdk/{rule,registry}.go`                                                                                                                     |
| Converter-glue history: branching-flow 1,871 LOC / erraudit 1,214 LOC → 0 after `type Issue = finding.Finding`                                                                                                                                                   | ✅ verified 2026-09-09, source read | `go-linter-sdk/README.md:33,329-330`                                                                                                                                       |
| golangci-lint v2 module-plugin wiring (`.custom-gcl.yml` → `golangci-lint custom` → `linters.settings.custom` `type: "module"`)                                                                                                                                  | ✅ verified 2026-09-09              | `go-humanize-linter/plugin/plugin.go` integration docs (released, dogfooded)                                                                                               |
| Architecture-test pattern (`go list -deps` + forbidden-pair table)                                                                                                                                                                                               | ✅ verified 2026-09-09, source read | `InboxClean-lint-baseline/internal/archtest/archtest_test.go`                                                                                                              |
| Reason-bearing suppressions in production (`//cqrs-lint:ignore(B022) <reason>`)                                                                                                                                                                                  | ✅ verified 2026-09-09, source read | `InboxClean-lint-baseline/internal/emailcqrs/setup.go`                                                                                                                     |
| H004 shipped at ~60% FP, reduced to ~0% (44→24 findings via multi-signal); 158-project validation sweep                                                                                                                                                          | ✅ verified 2026-09-09, source read | `go-humanize-linter/docs/status/2026-07-30_17-48_real-world-validation-and-plugin-mode.html`, `docs/validation/2026-08-10_real-world-sweep.md`                             |
| Suppression kinds `in-source/in-config/in-review`; `FixOutcome` statuses applied/no-change/refused/conflict/invalid/failed; `CompletionReason` stable/max-iterations/cancelled/timeout/error; v1.7.0 sub-module tag incident; `GOEXPERIMENT=jsonv2` prerequisite | ✅ verified 2026-09-09, source read | `go-finding/suppression.go:10-21`, `go-finding/AGENTS.md:66,160,193`, `go-finding/pipeline/result.go`, `go-finding/README.md:29`                                           |
| Governance maps (`DisabledLinters`/`NeverAutoEnableLinters`/`PragmaticNoiseLinters`) with data-integrity tests; audit-ledger actions `added-to-enable`/`suppressed-re-enable`; 4-tier `LinterPriority`                                                           | ✅ verified 2026-09-09, source read | `golangci-lint-auto-configure/pkg/constants/{rules,data_integrity_test}.go`, `pkg/audit/ledger.go:43-56`, `pkg/types/json_roundtrip_test.go:225-228`                       |
| go-structure-linter ADR-003 adapter-as-permanent-boundary; fix mixins (`FileDeleterFixable`/`FileCreatorFixable`); panic→finding isolation; 65 rules / 24 fixable                                                                                                | ✅ verified 2026-09-09, source read | `go-structure-linter/docs/adr/003-adapter-as-permanent-integration-boundary.md`, `internal/rules/{sdk_adapter,external_tool_rule,backup_file_rule_fix}.go`, `README.md:16` |
| oxlint: 841 rules / 7 categories / 15 plugins / 113 default-on; exit 1 = findings not error; profiles incl. `maximal-typesafe`                                                                                                                                   | ✅ verified 2026-09-09, source read | `oxlint-auto-configure/README.md:9,149`, `pkg/oxlint/detector.go:86-91`, `pkg/profile/profile.go:19-27`                                                                    |
| samber-linter spec: HW-1/HW-5/HW-6 rules, `//samber-linter:allow <rule> <reason>` (reason required)                                                                                                                                                              | ✅ verified 2026-09-09, source read | `samber-linter/README.md:128-252`                                                                                                                                          |
| SARIF property-bag round-trip keys (`go-finding/severity`, `-confidence`, `-category`, `-tags`, `-suggestion`, `-snippet`, `-id`, `-start/end-offset`, `-suppression-kind/reason/rule/expiry`)                                                                   | ✅ verified 2026-09-09, source read | `go-finding/sarif_types.go`                                                                                                                                                |
| linter-autoconfigure-sdk: single-file library (~239 LOC) with `Op`-typed `ConfigError` (read/unmarshal/marshal/mkdir/write)                                                                                                                                      | ✅ verified 2026-09-09, source read | `linter-autoconfigure-sdk/autoconfigure.go:40-44`                                                                                                                          |

All load-bearing claims in this skill were re-verified against source on
2026-09-09 (round 2 of this session); earlier research-pass-only rows have
been upgraded. Exact numbers above are pinned to files — re-verify after
any upstream release.

## References

- [./references/mechanism-choice.md](references/mechanism-choice.md) — the
  full build/configure/delegate decision matrix with evidence and anti-patterns
- [./references/finding-model.md](references/finding-model.md) — finding,
  rule, registry, and report data-model design
- [./references/trust-engineering.md](references/trust-engineering.md) —
  false-positive control, confidence, corpus validation, testing linters
- [./references/suppressions-and-fixes.md](references/suppressions-and-fixes.md) —
  suppression engineering and autofix safety machinery
- [./references/distribution.md](references/distribution.md) — CLI exit
  codes, baselines, golangci plugin, GitHub Action, SARIF, publishing pitfalls
- [./references/ecosystem.md](references/ecosystem.md) — Lars's local
  linter-building stack: what to reuse when, and which repo to copy
