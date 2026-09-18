# Session Status — Skill Merge Assessment — 2026-09-14 11:25

**Task:** "Are there any skills we should merge?" — full READ → UNDERSTAND → RESEARCH → REFLECT pass over all 29 skills, then execution of the fixes the analysis surfaced.

**Gates at write time:** `check-skills.sh` exit 0 · `check-skills.sh --triggers` exit 0 (all four edited skills STRONG) · `sync-html-kit.sh --check` exit 0 · single worktree.

---

## Verdict

**No further skill-directory merges are warranted.** Every remaining separation is intent-distinct and already documented in AGENTS.md §5.5. The obvious merges were executed long ago (docs-health absorbed `features-audit` + `todo-list-builder` + `docs-freshness-check` + `update-old-docs`; `html-report-kit` absorbed `nix-flake-migration`; `execution-mode` split into `brutal-self-review` + `pareto-planning`). What the assessment DID find: one content-level split brain (fixed by deletion) and two pairs missing their mandated two-way disambiguation (fixed by linking, per the repo's "link, don't merge" graph philosophy).

## Pairs examined and kept separate (with evidence)

| Pair                                                                              | Why separate                                                                                                                                                | Evidence checked                                                                                                                                              |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `status-report` ↔ `brutal-self-review`                                            | State inventory ("where are we") vs quality critique ("what did we get wrong") — different questions, different outputs (`docs/status/` vs `docs/reviews/`) | 16/66 status reports are session self-reviews; the 2026-09-13 report blends both formats in one doc — the pair works as a pipeline, not a redundancy          |
| `architecture-review` ↔ `architecture-visualization`                              | Judgment (rubric + roadmap, HTML) vs pictures (D2 `.d2`/`.svg`)                                                                                             | Both write to `docs/architecture-understanding/` — companions, zero prior cross-links (gap fixed)                                                             |
| `code-quality-scan` ↔ `deduplicate-code` ↔ `linter-building` ↔ `full-code-review` | Breadth scan vs clone-judgment loop vs authoring vs manual file-by-file                                                                                     | Two-way disambiguation already present in all descriptions                                                                                                    |
| `verify-before-filing` ↔ `verify-external-claims`                                 | Outbound vs inbound verification                                                                                                                            | Documented epistemic-hygiene pair (AGENTS §5.5)                                                                                                               |
| `go-release` ↔ `go-ecosystem-upgrade`                                             | Supply side vs demand side; Phase 6 is a thin pointer                                                                                                       | Bidirectional links; trigger overlap on "checksum mismatch" is handled by role split                                                                          |
| `docs-health` ↔ `status-report`                                                   | Living docs vs point-in-time snapshot                                                                                                                       | HARVEST/ANNOTATE handoff documented                                                                                                                           |
| `nix-review` ↔ `nix-private-go-repos`                                             | File review vs private-repo build/packaging                                                                                                                 | Disjoint trigger vocab                                                                                                                                        |
| `data-model-review` ↔ `naming-review`                                             | Structure vs vocabulary                                                                                                                                     | Distinct triggers; NOTE: naming-review description is at ~1008/1024 chars — adding mutual disambiguation requires a rewrite, not an append (left open, minor) |
| `github-voice` / `jj-fork-pr-workflow` / `verify-before-filing`                   | Prose / VCS mechanics / diagnosis gate                                                                                                                      | Documented trio                                                                                                                                               |
| `how-to-golang` vs Go executor skills                                             | Policy hub vs executors                                                                                                                                     | Documented delegation pattern                                                                                                                                 |

## Changes made

1. **Deleted `brutal-self-review/references/go-ecosystem.md`** (git rm) — orphaned
   stale fork of `how-to-golang`'s library domain. It still recommended
   `LarsArtmann/uniflow` as the errors library AFTER how-to-golang's 2026-08-21
   verification marked it uncompilable at @latest (broken cellbuf pin, no
   pipeline-chain API). Nothing linked the file (SKILL.md line ~63 already
   delegates to how-to-golang; only an archived brainstorm HTML mentions it).
   This was 2026-05-03 audit item #3 ("merge or cross-reference go-ecosystem.md
   with library-guide") — the cross-reference half happened, the stale file
   was never removed.
2. **architecture-review + architecture-visualization**: two-way description
   disambiguation + Related Skills sections (judgment vs diagrams, shared
   output dir).
3. **status-report + brutal-self-review**: two-way description disambiguation +
   Related Skills sections (collision zone: "what's fucked up" fires
   status-report; "what's stupid/could be better" fires brutal-self-review).
4. **AGENTS.md §5.5**: graph entries for both pairs + the deletion, including
   the reusable lesson: distinguish directory-level merges (rarely right here)
   from content-level split brains (orphaned duplicate references) — the latter
   are the real rot.
5. **CHANGELOG.md**: 2026-09-14 section.

## Open items from this session

- ~~data-model-review ↔ naming-review mutual disambiguation blocked by
  naming-review's description being at the ~1024-char cap (needs a tightening
  rewrite first). Minor; no trigger confusion observed in practice.~~ done —
  routed to TODO_LIST (T38, 2026-09-18 pass): measured 1021/1024 chars,
  rewrite + mutual disambiguation pending.

## Process notes (honesty section)

- One self-inflicted scare: ran `rg -rn "go-ecosystem"` — in ripgrep `-r` is
  `--replace`, so output displayed "go-ecosystem-upgrade" as "n-upgrade" and
  briefly looked like a botched repo-wide rename. Re-ran with correct flags
  before drawing conclusions. Same class as the encoded pipeline-masking
  lessons: verify the instrument before trusting (or panicking about) its
  output.
- SESSION-START checklist executed BEFORE task work this time (feedback/new
  empty, newest report TL;DR read, TODO_LIST/ROADMAP grepped, gates run with
  quoted exits).
