# Drift-alarm port evaluation (2026-09-30, round-6 M22)

**Question:** should the cross-file drift alarm
(`nix-international-telephony`'s `tests/drift_alarm.py`, wired there as
the `docs-drift` flake check) be upstreamed into this skill as a
generic asset?

**What it does today (four arms, two files + tree):**

1. Duplication — a TODO row whose stable identifiers overlap a
   `FULLY_FUNCTIONAL` FEATURES row is presumed shipped work.
2. Archived-snapshot citation — evidence pointing into `archived/`.
3. Live-snapshot citation — evidence pointing at docs/status|planning
   snapshots (rots into arm 2 at archive time).
4. Ghost citation — a cited repo-relative path missing from the tree.

**Verdict: valuable, NOT ported now.**

For: the six-doc model is standardized by this skill's templates, so
arms 2–4 generalize to every LarsArtmann repo almost verbatim; arm 1's
duplication check is the cheapest anti-redo device in the toolchain
(the 2026-08-27 archaeology incident is the paid-for evidence).

Against (why not in this pass):

- The corpus-calibrated heuristics are load-bearing and non-obvious:
  option-style identifier rules (`a.b.c` flags alone; file paths and
  ports need TWO shared identifiers), `LOCAL_ONLY_PATHS` carve-outs,
  backtick-span extraction. A naive generalization would false-positive
  every adopter in week one and get uninstalled.
- A faithful port needs a parameter surface (status vocabulary, file
  names, snapshot dirs, local-only paths) plus migrated negative
  self-tests per arm — a standalone medium task (~45–60 min), not a
  rider on another lane.
- Single-consumer risk: porting before a SECOND repo adopts it bakes
  assumptions from one corpus into "generic" code. The right trigger is
  the next repo adopting the six-doc pattern and wanting the gate.

**Decision:** adopt the trigger rule — port when a second repo asks for
it; until then this note is the record. The reference implementation
lives in the telephony repo (`tests/drift_alarm.py`, `--self-test`
covers every arm's negative case); copy from there when triggered.

Related same-session work: `annotate-rows.py` gained kind `r` (routed
verdict, no strike — the 2026-09-29+ house table grammar) with guard
and self-tests; fixture-tested against the telephony repo's archived
plan tables.
