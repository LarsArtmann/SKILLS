# Private Monorepo with Diverged Release Branches

Decision guide for upgrading Go modules from a private monorepo whose
release tags are cut from DIVERGED release branches — meaning no single
tag commit contains the latest code of all sibling modules.

## Detection

You are in this situation when ALL of these hold:

- The upstream repo is private (proxy serves only pre-privatization cache).
- It ships multiple Go modules as sibling directories (`command/v4`,
  `decider/v4`, `query/v4`, ...), each with its own tags like `command/v4.7.1`.
- `git merge-base --is-ancestor <tagA> <tagB>` FAILS across sibling tags —
  release branches diverged, so tag sets are mutually incomparable.

## Decision Tree: how to pin

```
Do all consumed sibling modules have tags whose tips are all contained
in one commit? (verify with merge-base --is-ancestor across the set)
├── YES → Pin the tag.
│         go get module@tag for every sibling; flake input ref=<tag>.
│         Simplest, reproducible, boring. STOP.
│
└── NO (diverged branches)
    → Pin the default branch (master/main):
      flake input ref=master + flake.lock relock, and go.mod requires
      pseudo-versions at ONE rev (see MVS rule below).
      Verify: local build and Nix build compile the SAME code — that is
      the invariant that decides, not aesthetics.
```

## The MVS Ordering Trap (pseudo-version vs tag)

`go get module@master` fails or downgrades silently when the pseudo-version
sorts BELOW an existing tag requirement. Pseudo-versions sort by
(timestamp, rev) against the last known tag on that line:

- `v4.5.1-0.20260906...-abcdef` (master tip after v4.5.1 tag) sorts ABOVE v4.5.1. Good.
- `v4.4.1-0.20260906...-abcdef` sorts BELOW an existing v4.5.0 tag — `go get`
  refuses or MVS resolves the older tag instead, skewing go.mod vs flake.lock.

Rules:

1. For each sibling module, compare the module's own latest tag against the
   master tip. Use the TAG when the tag >= master tip content (i.e., master
   has no post-tag commits for that module); use the master-tip pseudo only
   when it is the highest version.
2. NEVER force `@master` blindly across all siblings — check each module's
   sort position. `go get ...@<full-rev>` and then READ the resolved
   versions in go.mod.
3. Keep flake.lock and go.mod at the SAME rev; mixed revs = split brain
   (CI/lint see different code than the Nix build).

## Nix interplay (mkPreparedSource-style private dep injection)

- Relock the flake input FIRST (`nix flake update <input>`), then bump
  go.mod to the same rev, then `go mod tidy`.
- Any go.mod edit invalidates vendorHash. Automate: `scripts/vendorhash.sh`
  in the consumer repo (fakeHash → parse `got:` → rewrite → rebuild).
- Deleted-but-proxy-cached modules: keep a proxy-eviction canary
  (cold-download of each proxy-only version) wired into CI BEFORE any
  migration work — a guaranteed future outage needs an early warning more
  than a fast fix.

## Verification battery (baseline BEFORE, identical AFTER)

```bash
go build ./... && go test -race ./... && golangci-lint run && nix build .#server
```

Plus the consumer's data-contract tests (event-compat fixtures, wire-format
goldens) if the module touches persistence or serialization. A bump that
changes how stored events fold is a DATA MIGRATION decision, not a version bump.

## Cross-reference

- Live example: PapDashboard `AGENTS.md` (Pin-Update Runbook + pseudo-version
  ADR-lite), `docs/planning/2026-09-07_17-32_go-cqrs-hardening-pareto-plan.md`.
