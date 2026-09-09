# Suppressions and Autofix Safety

Two subsystems, not afterthoughts: suppression engineering decides whether
users can live with the linter; autofix safety decides whether they trust
it near their code.

## Suppressions are data, not comment hacks

Model a suppression as a record (go-finding's shape):

```go
type Suppression struct {
    Kind      SuppressionKind // in-source (//nolint) | in-config | in-review
    Rule      RuleName        // required — blanket suppressions forbidden
    Reason    string          // why this is acceptable
    ExpiresAt *time.Time      // optional TTL; expiry forces re-review
}
// IsActive(now) = valid && not expired
```

- **in-source** — directive next to the code (auditable in review).
- **in-config** — centralized list (good for generated files).
- **in-review** — an accepted false positive with a paper trail.

Why `Reason` matters: production suppression comments read like mini-ADRs
(verified example from InboxClean: `//cqrs-lint:ignore(B022)
event.CommandCausalityEnricher IS the canonical enricher; the rule cannot
unwrap the generic WithEnricher[...] argument`). A suppression without a
reason is unreviewable debt; samber-linter's spec makes a reason-less
suppress directive ITSELF a finding.

Expiry turns suppressions from permanent blind spots into a re-review
forcing function — a 90-day TTL on "temporary" suppressions is the
difference between a bypass and a decision.

## Directive engineering (the hard-won rules)

1. **Namespace by stable tool name, not module path.** Users (and AIs)
   write the wrong thing: `//nolint:github.com/x/y-linter` silently does
   nothing when the tool expected `//nolint:ylint`. go-humanize-linter
   documents this explicitly — AIs frequently write the module path,
   producing no-op directives.
2. **Verify suppressions, don't just honor them.** Ship
   `--verify-suppressions`: flag (a) directives whose rule never fires
   there anymore (stale) and (b) unparseable/mistyped rule IDs
   (misspelled). A silent no-op directive is worse than none — the user
   believes the finding is suppressed.
3. **Test EVERY placement form.** Verified incident: package-level and
   column-1 `//cqrs-lint:ignore(RULE)` directives silently didn't work;
   only the `ignore-start` block syntax (handled by a different,
   backward-scanning code path) suppressed. Silent suppression failure
   cost the user hours. Fixture-test: line, block (`ignore-start`/`stop`),
   package-level, function-level, with-rule-list, with-reason.
4. **Host-linter interplay.** Inside golangci-lint, the host's nolint
   filter runs too — a finding anchored on the nolint line itself gets
   swallowed by the host before your "stale directive" report survives.
   Re-anchor meta-findings (e.g. to line 1) so they survive the host
   filter.
5. **Rule-level scoping, always.** `//nolint` without a rule list disables
   everything on that line; require (or at least strongly prefer) the
   explicit rule ID list form, and lint against blanket forms
   (nolintlint-style).

## Baselines and ratchets (adoption without big-bang fixes)

- **Baseline mode**: `--save-baseline` records current findings;
  `--behavior-delta` later reports only NEW findings. Existing debt passes,
  regressions fail. (go-humanize-linter ships this as first-class.)
- **Ratchet rules** (e.g. "health-coverage ratio must not decrease") are a
  distinct finding category: ratio findings compare against a stored
  baseline number, not per-line matching (samber-linter HW-6 pattern).
- **Health score** (0–100 from findings) makes lint debt a trend. InboxClean
  ran a remediation session 23 findings → 0 unsuppressed (14 fixed, 9
  documented suppressions), score ~60 → 99 — the score made the progress
  legible.

## FixStrategy taxonomy

Per finding, not per rule: `none | suggest | direct | ai`.

- `suggest` — the finding carries a human-readable instruction; the fix
  needs judgment.
- `direct` — machine-applicable (mechanical edit); this and only this
  auto-applies.
- `ai` — reserved for future delegated fixes; do not remove the enum value
  (go-finding keeps it deliberately reserved).
- Always set it explicitly — an empty-string fix strategy is a split-brain
  bug (normalize to `none`).

## Autofix safety machinery

Non-negotiables before any tool edits user code:

1. **Dry-run default.** `--dry-run` prints the plan; apply is opt-in
   (`--fix`). Apply-dry-run (plan-before-apply) even inside the apply path.
2. **Byte-level edits with conflict detection.** Model fixes as
   `{Offset, Length, Replacement}` edits; apply in DESCENDING offset order
   so earlier edits don't shift later positions; detect overlapping edits
   and refuse with `conflict` rather than corrupting.
3. **Per-finding fix outcomes.** `applied | no-change | refused | conflict
   | invalid | failed` per finding (go-finding's FixOutcome). An exit code
   alone cannot answer "was MY finding fixed?"
4. **Rollback per file.** On failure, restore the failing file only
   (go-finding ADR-016 default: `RollbackPolicyFailingFile`), don't unwind
   the whole run.
5. **Detect→fix loops are capped.** A fix can create a new finding (split
   long line → new lint error); cap iterations (5) and report the
   CompletionReason (`stable | max-iterations | timeout | cancelled`).
6. **Filesystem fixes need more than edits.** Create/delete/rename repairs
   (go-structure-linter: 24 fixable rules) use mixins (FileDeleterFixable,
   FileCreatorFixable) with atomic writes, backups, post-fix
   `ValidateFix`, and idempotency (running twice = no second change).
   This is why its ADR keeps filesystem repair OUT of the code-patch
   finding model — adapters, not contortion.

## Auto-CONFIGURING tools need anti-gaming machinery

When the tool rewrites linter CONFIG (a configurator/fixer), users fight
back and the tool must not flip-flop (golangci-lint-auto-configure's
proven stack):

- **Justified disables**: a `disabled:` sidecar section with reasons;
  unjustified disables get re-enabled, justified ones respected.
- **Never-enable list**: durable cross-machine signal ("stop recommending
  X here") separate from per-disable reasons.
- **Regression-loop detection**: an append-only audit ledger (JSONL) of
  actions; if the tool added a linter and the user removed it, the next
  run records `ActionSuppressedReEnable` instead of re-adding.
- **Idempotence with explicit force**: fill missing settings only;
  `--force-settings` to overwrite; orphaned settings pruned; mutations
  counted and reported.
- **Atomic writes** for anything user-owned: temp file + fsync + rename —
  a crash mid-write must never truncate a config (go-atomic-write;
  `ErrConcurrentModification` surfaced).

## Gate vs. advisory

Hard CI gate only AFTER the suppression discipline exists: with documented,
verified suppressions, `--strict` gating works (InboxClean runs
`min-severity: info` config + health-score workflow in CI). Without
suppression machinery, a hard gate just blocks merges on noise and gets the
linter disabled at the CI level — the worst outcome.
