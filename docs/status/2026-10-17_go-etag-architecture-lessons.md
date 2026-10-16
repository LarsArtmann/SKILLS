# go-etag Architecture Lessons → Skill Updates

> 2026-10-17. Task: "What can our skills learn from `/home/lars/projects/go-etag`
> and its architecture?" — full READ/UNDERSTAND/RESEARCH pass over go-etag, gap
> analysis against the SKILLS repo, six lessons encoded into four skills, quality
> gate green.

## What go-etag is (research base)

Two-sided RFC 7232 ETag library, five Go modules on one version train:
root (deprecated alias tombstone, removed at v1.0.0), `entitytag/` (shared
domain type, zero deps), `server/` and `client/` (real code,
`server → entitytag ← client`), `metrics/` (leaf observability companion,
depends on server; server never imports it). One external dependency in the
whole repo. All architectural claims were verified against live files
(go.work, all five go.mod files, `server/entity_tag.go` alias shim,
`deprecated.go` tombstone) before encoding — verify-external-claims inbound
discipline.

## Lessons identified and where each landed

| # | Lesson (from go-etag) | Skill / file |
| - | -------------------- | ------------ |
| 1 | **Version-train workspace pattern** for proxy-published multi-module libraries: replace-free go.mods, sibling requires at the unreleased train version, version-qualified replaces in a COMMITTED go.work (`use` alone fails once an external dep forces graph resolution; unqualified replaces conflict with `use`), tidy is release-time-only, sync gate | `go-modularize/references/real-world-patterns.md` new §Version Train; `phases.md` §3.3 strategy table un-recommended for published repos; `SKILL.md` FM#4 mitigation split app/published |
| 2 | The old §"Anti-pattern: go.work-only" was **wrong for published repos** (it is the correct end state there, with the train mechanics) — the dual strategy (committed go.mod replaces + v0.0.0 normalization) breaks consumer `go get` in anything proxy-published | Same files: dual strategy scoped to app monorepos, warning added to v0.0.0 normalization, "When go.work-only is right" replaces the anti-pattern section |
| 3 | **Bottom-up tag staircase**: each module tag on the commit where its own go.mod/go.sum finalized, dependency-first, root last — eliminates the same-commit variant's window where the frozen tag is red in `GOWORK=off` mode until the post-push go.sum repair commit | `go-release/references/multi-module.md` new "Alternative: the bottom-up tag staircase" + version-qualified-replace bullet in "The go.work interplay"; cross-linked both ways with go-modularize |
| 4 | **Extraction without breakage**: in-module re-export alias shim ("new domain logic goes to the new home, never the shim") + deprecated root tombstone module pinned by an export-parity test, deleted at the major | `go-modularize/references/real-world-patterns.md` §Interface Extraction Patterns, new subsection |
| 5 | **Libraries: nil-default hooks, not telemetry deps** — synchronous `OnX` callbacks (zero cost nil) + optional leaf metrics companion module; "OTEL from day one" scoped to services | `how-to-golang/SKILL.md` principle bullet; `references/philosophy.md` §Build for Observability |
| 6 | **Spec-implementation testing**: RFC-section citation in every test, conformance doc per requirement, fuzz with soundness properties, documented deliberate gaps ("no fuzz for pure counters") to preempt audits | `how-to-golang/references/testing-strategy.md` new section |
| 7 | **Accepted clones as an enforced gate, not prose**: committed baseline + release gate fails unless art-dupl shows exactly the accepted group count (go-etag pins 4) | `deduplicate-code/SKILL.md` Accept section |

## Considered, not done (candidates, low priority)

- `scripts/doc-snippet-refs` (CI-verifies README/docs code snippets reference
  real exported symbols) — a docs-accuracy tool pattern; no natural home found
  in docs-health (which owns living-doc modes, not code-snippet checking).
  Revisit if a third repo adopts the script.
- go-etag's daemon-drift defenses (anchored go-directive parity checks,
  .gitignore negations outside the managed marker block) — too project-specific
  for a skill; belongs in buildflow's orbit if it generalizes.

## Verification

- `./scripts/check-skills.sh` → **EXIT=0** (31 skills, 0 thin, no broken links).
  One regression caught and fixed during the session: a multiedit on
  multi-module.md consumed the `## GORELEASER_CURRENT_TAG` heading
  (anchor check FAIL, exit 1) — restored, re-run green.
- FEATURES.md row updated for go-modularize (version-train pattern note);
  deduplicate-code / how-to-golang / go-release rows re-checked, still accurate.
- Session-start checklist executed (feedback/new empty; newest status report
  unrelated; TODO_LIST not touched by this task's scope).
