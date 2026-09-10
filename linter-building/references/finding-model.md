# The Finding Data Model

The finding model is where linter architecture lives and dies — same rule as
any data model: a wrong detection function costs minutes, a wrong finding
type costs a migration. Design it BEFORE detection logic.

## The zero-converter rule (the single highest-leverage decision)

**Rules emit the shared finding type directly. Never invent a private issue
type plus a converter.**

Measured history (from `go-linter-sdk/README.md`): consumers that defined
native issue types accumulated 1,200–1,900 LOC of pure conversion glue each;
adopting the shared type deleted it wholesale. The minimal adoption is a
type alias:

```go
type Issue = finding.Finding // your []Issue IS []finding.Finding
```

Full adoption: rules build findings via the shared builder, so severity
filtering, SARIF export, LSP conversion, merging, and CI integration come
free.

## Anatomy of a finding (field-by-field rationale)

Verified against `go-finding/finding.go` (v1.9.x, 2026-09-09):

```go
type Finding struct {
    // Identity — who found it, where
    ID       ID       // derived: "tool:rule:file:42:5" (hash form when no line)
    Rule     RuleName // stable rule identifier
    ToolName ToolName
    Message  string   // what is wrong, actionable, names the fix
    Severity Severity // info | warning | error | critical (ordered)
    Position Position // File, Line (1-based), Column, Offset
    // Classification — routing and filtering
    Category Category // security, correctness, complexity, duplication, ...
    Tags     []Tag    // error-handling, type-safety, testing, ...
    // Fix — what remediation is possible
    FixStrategy FixStrategy // none | suggest | direct | ai
    Suggestion  string      // human-readable fix instruction
    BeforeCode  string      // optional before/after for review UIs
    AfterCode   string
    // Context — triage and correlation
    Range      *Range       // start/end positions for span-based rules
    Snippet    string       // the offending source text
    Confidence Confidence   // 0.0–1.0, named levels Low(0.25)/Medium(0.5)/High(0.75)/Full(1.0)
    GroupID    GroupID      // links clone-group findings to each other
    Related    []RelatedRef // cross-references (finding ID + relation + position)
    Suppression *Suppression
    Metadata   map[string]string // namespaced "toolName.key" extra data
}
```

Design principles behind the shape:

1. **Findings are immutable data, not state machines.** Enables
   clone/filter/merge/serialize without aliasing bugs. Suppression state
   lives ON the finding as data; nothing mutates a finding after build.
2. **Identity is derived, not random.** `tool:rule:file:line:col` is
   human-readable AND machine-parseable. When there is no line (project-level
   findings), use a hash ID — and hash length-prefixed fields, or
   `toolName="a:b"` forges IDs. "Two findings are identical iff their IDs
   are equal" is the documented identity contract.
3. **Three named identity levels** — ID (canonical), Key (fallback,
   includes message), DedupKey (merge-time relaxation: by-position or
   by-rule+position). Name all three explicitly; implicit levels drift.
4. **`Metadata` is string-map only, never `map[string]any`.** String-to-
   string is lossless across SARIF property bags, JSON, CLI flags, env
   vars. Complex values JSON-encode into strings; keys are namespaced
   `"toolName.key"`; a reserved prefix (`go-finding/`) is off-limits.
5. **Zero values are normalized.** `NormalizeFixStrategy("") → "none"` at
   every entry point (Validate, builder, SARIF import, LSP import). A
   split-brain where `""` and `"none"` both mean "no fix" but compare
   unequal is a real shipped-bug class — go-finding has a dedicated
   `splitbrain_test.go` for it.
6. **Validate at construction.** The builder validates; invalid findings
   never enter the pipeline. A low-level constructor exists only for
   trusted/validated sources — keep it internal.

## Builder pattern (verified signatures)

```go
f, err := finding.NewBuilder(rule, toolName, message, severity, pos).
    WithCategory(cat).WithTags(...).
    WithConfidence(finding.ConfidenceHigh).
    WithFixStrategy(finding.FixStrategySuggest).WithSuggestion("...").
    Build() // validates + normalizes; errors, never half-builds
```

- Builder defaults confidence to `Full` — correct for deterministic static
  analysis; lower it explicitly for heuristic rules.
- A `Template` stamps tool/category/fix-strategy once for a whole rule,
  then `tmpl.Build(rule, msg, sev, pos)` per finding — removes the
  per-finding boilerplate rules reinvent.
- `MustBuild`/`BuildOrDefault` only for test fixtures and provably-valid
  inputs.

## Rule and registry design (go-linter-sdk shape)

```go
type Rule interface {
    ID() string          // STABLE forever: suppression and config key on it
    Name() string        // display name, may change
    Description() string
    Category() Category
    Severity() finding.Severity // rule-level DEFAULT; findings may override
    IsEnabledByDefault() bool
    Check(ctx context.Context, dir string) ([]finding.Finding, error)
}

type RuleFunc struct { // the common case: identity header + closure
    Meta RuleMeta
    Run  func(ctx context.Context, dir string) ([]finding.Finding, error)
}
```

Registry contracts (verified `go-linter-sdk/registry.go`):

- **Duplicate rule ID → panic at Register.** Rationale (their ADR): a
  duplicate is a programming error; failing loud at startup beats silent
  shadowing in production.
- `Registry.Run(ctx, dir)` fails fast by default; `ContinueOnError()`
  joins per-rule errors. Either way, errors carry the rule ID
  (`RuleError{RuleID, Cause}`), wrapped at exactly one chokepoint, never
  double-wrapped.
- Two adapter shapes: one opaque `finding.Detector` for the whole registry
  (simple), or one detector PER RULE (pipeline gets per-rule metrics,
  timeouts, and panic isolation). Prefer per-rule when a pipeline is
  upstream.
- Panic isolation belongs in the executor: `go-structure-linter` converts a
  panicking rule into a synthetic high-severity finding ("this is a bug in
  the linter rule") — one bad rule must never kill the run.

**Capability interfaces over a god-interface:** `FixableRule`
(`DryRunFix/ApplyFix/ValidateFix`), `ProjectAware`
(`CheckWithProject(proj)`) — checked optionally at runtime. Common-case
rules stay tiny; special powers are mixins.

## Rule ID discipline

- IDs are API: users write them in configs (`enable: "H001,H003"`),
  suppressions (`//nolint:tool:H001`), and baselines. Changing one breaks
  every downstream consumer — treat a rename as a major release.
- Prefix + counter scheme (`H001`, `HW-1`, `E017`, `B005`) keeps IDs short,
  sortable, and referenceable in docs. Pseudo-rules (e.g. suppression
  staleness `H0SUP`) exist outside the default rule list on purpose.
- `IsEnabledByDefault() = false` + explicit opt-in beats loud-by-default for
  anything with known false-positive surface.

## Severity mapping when adopting the model in an existing tool

Literal aliasing (old low/medium/high → new warning/error/critical) causes
semantic distortion. The proven method (InboxClean's go-finding migration
docs): write a semantic mapping TABLE with rationale per mapping, adopt via
aliases first to preserve API, then convert at boundaries for genuinely
different domain meanings. Filled-in example (from that migration):

| Legacy value | Context meaning                                    | go-finding mapping | Rationale                                |
| ------------ | -------------------------------------------------- | ------------------ | ---------------------------------------- |
| `low`        | Non-blocking but notable (error-handling findings) | `warning`          | Not gate-worthy alone, must stay visible |
| `medium`     | Real defect, should fix soon                       | `error`            | Gate-worthy in CI                        |
| `high`       | Data loss / correctness violation                  | `critical`         | Merge-blocker, top of triage             |

Same-shape rule for domain concepts: `ThreatLevel` in InboxClean was NOT
aliased — it is a domain meaning, converted explicitly at the boundary.
Alias mechanics, convert semantics.

## Severity ≠ Confidence ≠ CorrelationScore

Three orthogonal axes, routinely conflated:

| Axis             | Question it answers                  | Consumer                                |
| ---------------- | ------------------------------------ | --------------------------------------- |
| Severity         | If real, how bad?                    | Gate policy (error blocks merge)        |
| Confidence       | How sure is the rule it is real?     | Triage (`--min-confidence`), exit codes |
| CorrelationScore | How strongly do TWO findings relate? | Merge/dedup                             |

A critical-severity low-confidence finding is the norm for heuristic rules —
only separated axes can express it.
