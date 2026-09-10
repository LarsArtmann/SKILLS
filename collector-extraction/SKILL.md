---
name: collector-extraction
description: Use when extracting a monitor365 collector into a standalone sibling repo (like wireguard-collector, mic-monitor, clipboard-monitor), when promoting shared collector plumbing into collector-utils, when wiring a new family crate into monitor365's Cargo.toml/flake.nix (ADR-041 sibling-path + preparedSrc pattern), when bumping a collector-utils family crate version, or when the user says "extract this collector", "make it standalone", "new sibling repo", "move this into collector-utils". Also triggers when choosing WHICH collector to extract next (decision criteria + canonical inventory pointer).
---

# Collector Extraction — monitor365 → standalone sibling repos

Encodes the proven procedure from four successful extractions
(wireguard-collector, mic-monitor, clipboard-monitor, storage-collector).
Each extraction is a standalone repo with ZERO monitor365 dependencies;
monitor365 keeps a thin adapter. Never a monorepo, never a "collectors-rs"
framework crate.

## Prime directive (learned the hard way)

The owner explicitly rejected: (a) a single "monitoring-collectors" monorepo,
(b) a "collectors-rs" framework crate, (c) anything coupling collectors to
monitor365 domain types. **Confirm the target repo name and scope with the
owner BEFORE writing code.** One collector (or one tight domain group) per
repo. If you feel the urge to create a workspace with `crates/` inside the
new repo — stop, that was already rejected once.

**Family repos are PRIVATE on GitHub.** Create with
`gh repo create <name> --private`, then verify with
`gh repo view <name> --json visibility` — never trust docs about repo
visibility (a stale "family is public" claim in monitor365's AGENTS.md made
the ssh-key-monitor repo public on 2026-09-10; flipped same hour). Private
repos mean Nix flake-input fetches need `access-tokens` (github.com) in the
nix config on every building machine.

## The two moves

1. **Extract a collector** → new sibling repo `~/projects/<name>-monitor/`,
   built on `collector-utils`, consumed by monitor365 via ADR-041.
2. **Promote shared plumbing** → move a generic module from
   `crates/collectors/common/src/` INTO the existing collector-utils repo
   (new minor version, feature-gated if it adds deps). monitor365 has NO
   direct collector-utils dependency today — promoting means adding
   `collector-utils = { version = "0.2" }` to the workspace deps + patch
   path (same family wiring).

## When to extract (decision criteria)

Extract when ALL hold:

- Domain logic is self-contained (reads procfs/sysfs/CLI/files — no GUI, no
  monitor365 config plumbing baked into the hot path)
- Can produce **domain-agnostic typed change events** (its own enum, e.g.
  `WireGuardChange`) — no `monitor365_domain::Event` in the extracted crate
- Fits the collector-utils model: state type `S` + `CollectorBackend<S>` +
  (usually) `BaselineDiff<K,V>` for change detection
- Has standalone value outside monitor365 (would a security tool, another
  monitor, or SystemNix consume it?)
- Bounded size (~250–500 lines is the sweet spot; the four extractions were)

Do NOT extract (yet or ever):

- `system_info` — feeds device registration/fingerprinting, deeply
  monitor365-coupled
- Graphical-session collectors (screenshot, camera, window) — IPC + display
  coupling, and clipboard already covers the pattern
- Location cluster (location, indoor_positioning, dead_reckoning,
  cell_tower) — sensor fusion with monitor365-shaped payloads
- `collectors-api` (the `Collector` trait) — that is monitor365's contract;
  `collector_utils::CollectorBackend` is the standalone-side counterpart.
  Extracting it would invert the dependency.
- Anything whose events can't be expressed without `EventType` — genericize
  the payload first, or leave it.

The canonical candidate inventory (~48 items, difficulty-ordered) lives in
monitor365 `docs/status/archive/2026-08-11_13-46_wireguard-collector-extraction-poc.md`
section C. Items are attempted ONE AT A TIME by owner direction — the
inventory is raw ideas, not a task list.

## Sibling repo template (copy from mic-monitor, the cleanest reference)

Sources of truth: `~/projects/mic-monitor/` and `~/projects/storage-collector/`.

Cargo.toml invariants (all four siblings follow this exactly):

```toml
[package]
version = "0.1.0"            # start here; bump on release
edition = "2021"
rust-version = "1.86"
license-file = "LICENSE"
publish = false
# exclude = [ "docs/", "fuzz/", ".github/", "AGENTS.md", "TODO_LIST.md",
#   "ROADMAP.md", "FEATURES.md", "clippy.toml", "deny.toml",
#   "rust-toolchain.toml", "CONTRIBUTING.md", "dprint.json", ".editorconfig" ]

[features]
serde = ["dep:serde", "collector-utils/serde"]   # forward the feature

[dependencies]
collector-utils = { path = "../collector-utils" }   # THE family embed — never a version/git source here
# tokio (minimal features), tracing — keep deps near zero

[dev-dependencies]
collector-utils = { path = "../collector-utils", features = ["testing"] }
proptest = "1"
serde_json = "1"

[lints.rust]
unsafe_code = "forbid"
missing_docs = "deny"
# + the full strict clippy set: pedantic/nursery deny (priority -1),
# unwrap_used/expect_used/indexing_slicing/arithmetic_side_effects/
# string_slice/as_conversions/panic/exit/todo/unimplemented deny
```

Files every sibling ships: `LICENSE`, `README.md`, `CHANGELOG.md`,
`AGENTS.md`, `FEATURES.md`, `ROADMAP.md`, `TODO_LIST.md`, `CONTRIBUTING.md`,
`deny.toml`, `clippy.toml`, `dprint.json`, `rust-toolchain.toml`,
`flake.nix` + `flake.lock`, `.github/workflows/ci.yml` (fmt + clippy -D
warnings + test), `docs/` (status/, DOMAIN_LANGUAGE.md), `examples/`
(at least one runnable), `tests/`, optionally `fuzz/`.

## Extraction procedure (verify each step before the next)

1. **Read the source collector fully** in monitor365. Map: state read,
   baseline handling, event emission, availability probing, config knobs.
2. **Design the standalone surface**: state type `S` (impl `IsEmpty`),
   `CollectorBackend<S>` impl(s), domain change enum, `BaselineDiff` key/value.
   Tests for parser/diff logic come over too. No monitor365 types.
3. **Create the sibling repo** from the template; port logic; add examples.
   Delete nothing in monitor365 yet.
4. **Verify the sibling standalone**: `cargo test`, `cargo clippy --all-targets
   -- -D warnings`, `cargo fmt --check`, `cargo doc` (missing_docs is deny).
5. **Write the thin adapter** in monitor365 (keep it under ~150 lines; the
   wireguard one is 253 for 4 event types — simpler collectors ≈ 30–100).
   The adapter implements monitor365's `Collector` trait, maps the domain
   change enum → `Event` payloads, and forwards availability. Adapter crate
   is platform-cfg'd (`#[cfg(target_os)]`) when the collector is.
6. **Registration rules (critical-rules)**: `register_fn("name", ...)` in the
   right platform `registry.rs`. If the collector is always-on, it must NOT
   appear in `collector_states()` (config-driven collectors only — the
   WireGuard/Ups/CertificateExpiry/ConfigTamper/DiskSerialChange/
   SshKeyDiscovery precedent). Baseline-diff collectors must override
   `collect_batch`, not just `collect`.
7. **Wire the family** (monitor365 side, exact edit sites — SEVEN, the
   eighth hand `uiPreparedSrc.siblingSrc` was missed by the first skill
   draft and caught on the first live run):
   - Root `Cargo.toml`: workspace dep `name = { version = "0.1" }` with a
     comment; `[patch.crates-io]` entry `name = { path = "../name" }`;
     update the `Tags:` comment block (and the revs list under it).
   - `flake.nix`: (1) `flake = false` input with `?ref=<FULL rev>`;
     (2) `outputs` destructure; (3) `familyFiltered.<name> =
     craneLib.cleanCargoSource <name>;`; (4) `siblingOrder` list;
     (5) `pathRewrites` sed line (`s|path = "../name"|path = "name"|`);
     (6) the `extraDummyScript` `mkdir/cp/rm` block (~line 417);
     (7) the `uiPreparedSrc.siblingSrc` map (`name = name;`).
   - `cargo update -p <name>` (lock entry must have NO `source` line).
8. **Prove it end-to-end** (this order, all green before touching git):
   `cargo check --all --all-targets` (workspace-wide — single-crate check
   hides breakage), `cargo nextest run` excluding bdd/e2e, `cargo clippy
   --all --all-targets -- -D warnings`, `nix build .#monitor365
   .#monitor365-server`. Then sibling: push to GitHub, tag, and set the
   flake `?ref=` to the pushed full rev (a rev that only exists locally
   breaks everyone else's builds).
9. **Document immediately, not as follow-up**: AGENTS.md gotcha entry for
   the new always-on/extracted collector + the family bullet; runbook rev
   table (`docs/development/family-bump-runbook.md`); status report in
   `docs/status/`.

## Run record (battle-test log)

- **2026-09-10 — ssh-key-monitor v0.1.0 (first live run, PASS).** 529-line
  in-tree collector → 41-test sibling + ~90-line adapter. What the skill got
  right: template invariants, gate order, family wiring checklist. What the
  run added: SEVENTH flake edit site (above); private-repo default (above);
  in-tree tests may NOT exist — port the AGENTS test-count claim with salt
  and write the sibling suite fresh from behavior; verify parsing
  assumptions empirically before porting (OpenSSH pubkey blobs are UNPADDED
  base64 and the `base64` STANDARD engine accepts them — proven with a
  scratch test); concurrent sessions may extend the sibling mid-extraction —
  adapt to their committed API, never revert it, and let the flake pin trail
  until their work lands.

## Family bump (consuming a new sibling version)

Runbook: monitor365 `docs/development/family-bump-runbook.md`. Four steps:
sibling push (+tag) → flake `?ref=` full rev → `cargo update -p <crate>` →
`nix build .#monitor365 .#monitor365-server` green + sync both rev tables.

## Hard rules (violations caused real damage)

- The family is **sibling-path-only**. Never switch a family crate to a git
  or registry source: the path-dep embed makes git resolution impossible,
  and a git source reintroduces Nix outputHashes. Never "fix" this.
- `clipboard-monitor` can NEVER be published to crates.io (name taken by
  an unrelated crate).
- Fresh clones need sibling checkouts at `~/projects/` — failures there are
  a documented runbook mode, not a bug to "fix" with git deps.
- Use `trash`, never `rm -rf`, for anything in the repos.
- Never propose grouping unrelated collectors into one workspace repo.
  Domain grouping (e.g. "all SSH/security-key collectors") is fine as ONE
  flat crate with multiple backends — ask the owner first.
