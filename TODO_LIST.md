# TODO List

> Short-term, actionable, bounded work items. Verified against the actual code
> and harvested from recent status reports in `docs/status/` (2026-08-11 →
> 2026-08-21 wave, harvested 2026-08-21). For long-term vision and unrefined
> ideas, see `ROADMAP.md`.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed — external dependency or decision needed.    |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

---

## P0 — Content correctness

| ID  | Task                                                                                                                               | Status | Impact | Effort | Evidence                                                                                                                 |
| --- | ---------------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| T1  | Add a trigger-first regression guard to `scripts/check-skills.sh` — fail when a `description` does not open with trigger context (decide strict `Use ` prefix vs loose `when`-in-first-sentence, per 08-11 g2) | 🔴 TODO | High   | Low    | `scripts/check-skills.sh` (guard absent, verified 2026-08-21); `docs/status/2026-08-11_12-55_*` b2, e1, f1                  |
| T2  | Add alias-vs-definition decision-tree entry + trigger phrases ("type alias", "type definition", "`type X = Y`") to `how-to-golang/SKILL.md` — the guidance exists only in `references/domain-types.md` and is undiscoverable from the entrypoint | 🔴 TODO | High   | Low    | `how-to-golang/SKILL.md` (zero alias mentions, verified 2026-08-21); `docs/status/2026-08-14_11-52_*` b2/b3, f6/f7         |
| T3  | Harden `how-to-golang/references/domain-types.md` alias section: interface satisfaction NOT inherited, underlying-type ops preserved, untyped-constant assignability, `reflect` divergence, embedding-vs-aliasing-vs-definition — then verify every claim by compiling a scratch program | 🔴 TODO | High   | Medium | `domain-types.md` (all five nuances absent, verified 2026-08-21); `docs/status/2026-08-14_11-52_*` d5, f1-f5, f15-f16      |
| T4  | Fix `website-launch` Phase 6 link-bar split brain (still shows old two-link bars; Phase 2 got the demo-link variant) + add demo-video item to `content-patterns.md` retrofit checklist | 🔴 TODO | High   | Low    | `docs/status/2026-08-21_12-06_*` b1/b2, f1/f5                                                                               |
| T5  | Soften or verify the two unverified HyperFrames claims in `website-launch/references/demo-video.md` (`npx skills update` failure mode; one-command 9:16 re-render), and validate routing/tiers claims by reading `hyperframes-cli` + `hyperframes-core` skill bodies | 🔴 TODO | High   | Medium | `docs/status/2026-08-21_12-06_*` b4, f2/f3/f4                                                                               |

## P1 — Verification debt

| ID  | Task                                                                                                                          | Status | Impact | Effort | Evidence                                                                                                          |
| --- | ------------------------------------------------------------------------------------------------------------------------------ | ------ | ------ | ------ | ------------------------------------------------------------------------------------------------------------------ |
| T6  | Compile-check the Go snippets in `how-to-golang/references/` (start with `performance-tuning.md`) in a scratch module; fix whatever does not build | 🔴 TODO | High   | Medium | AGENTS.md §10 note; `docs/status/2026-08-16_03-32_*` b1, f3; `2026-08-14_14-22` f15-f17                             |
| T7  | Re-run the 3 `go-release` evals after the binary-v2.0.0 fix; add a safety assertion (output must not contain `rm -rf`); confirm pass rate > 74% | 🔴 TODO | High   | Medium | `go-release/evals/iteration-1/grading.json`; `docs/status/2026-08-12_12-15_*` b2, e3, f1/f2                          |
| T8  | Verify the skills CLI empirically against the 5-entry lockfile: `skills ls -g` shows only third-party skills; `skills update -g` never touches the 25 symlinks | 🔴 TODO | High   | Low    | `~/.local/state/skills/.skill-lock.json`; `docs/status/2026-08-14_15-04_*` b1, c1/c2, f1/f2                          |
| T9  | Exercise `scripts/link-skills-to-agents.sh --force` on a scratch skill to prove the documented `skills add` recovery path         | 🔴 TODO | High   | Low    | `scripts/link-skills-to-agents.sh`; `docs/status/2026-08-14_15-04_*` c6, f5                                          |
| T10 | Eval the 2026-08-21 `website-launch` rewrite: 2-3 realistic launch prompts, old-skill baseline vs new (reasoned ≠ measured)      | 🔴 TODO | High   | Medium | `docs/status/2026-08-21_12-06_*` c1, f7                                                                              |

## P2 — Tooling & polish

| ID  | Task                                                                                                                            | Status | Impact | Effort | Evidence                                                                                                     |
| --- | -------------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------ | ------------------------------------------------------------------------------------------------------------- |
| T11 | Trim `website-launch/SKILL.md` (848 lines, allowlisted): extract Phase 2 badge/link-bar markdown into `readme-template.md` (~60 lines) | 🔴 TODO | Medium | Medium | `scripts/check-skills.sh` WARN; `docs/status/2026-08-21_12-06_*` e4, f8; recurring since `2026-08-14_14-22` f7 |
| T12 | Create `scripts/check-skill-links.sh` — CI-grade broken-internal-link detection (ad-hoc Python existed 2026-08-14, never productized) | 🔴 TODO | High   | Medium | `docs/status/2026-08-14_14-22_*` e7, f12; `2026-08-14_15-04` f19                                              |
| T13 | Encode process lessons into guidance docs: Questions-tool 200-char choice limit (use a review file instead), "verify before you say" chat-time gate in `verify-external-claims`, verification-status-table-in-references pattern in `how-to-write-skills.md` | 🔴 TODO | Medium | Low    | `docs/status/2026-08-11_12-55_*` e4/g3; `2026-08-16_03-32` e1/e4, f13/f14                                     |
| T14 | Add real (run, not invented) examples to `performance-tuning.md`: `-cpu` sweep with knee annotation, `benchstat` before/after, false-sharing before/after benchmark | 🔴 TODO | Medium | Medium | `docs/status/2026-08-16_03-32_*` f8-f10                                                                       |
| T15 | Cross-link `bdd-testing` benchmark lens → `performance-tuning.md` methodology (one-way, no duplication)                          | 🔴 TODO | Medium | Low    | `docs/status/2026-08-16_03-32_*` f11                                                                          |
| T16 | Add the safety checklist item ("`trash` for temp dirs, never `rm -rf`") to `go-release/references/quick-reference.md`            | 🔴 TODO | Medium | Low    | `quick-reference.md` (item absent, verified 2026-08-21); `docs/status/2026-08-12_12-15_*` e2, f2              |
| T17 | Fix the type-alias mislabel in httputil `DOMAIN_LANGUAGE.md` (calls a type definition an "alias") — external repo, not SKILLS     | 🔴 TODO | Medium | Low    | `docs/status/2026-08-14_11-52_*` e6, f8; `2026-08-14_14-22` f11                                               |
| T18 | `link-skills-to-agents.sh`: document the supported `AGENTS_DIR` env override in the header + smoke-test `--help` (sed line range) | 🔴 TODO | Low    | Low    | `docs/status/2026-08-14_15-04_*` f11/f12                                                                      |
| T19 | `website-launch` references: og:image (1200×630) guidance where OG images are configured + launch-post copy mini-template in `content-patterns.md` | 🔴 TODO | Medium | Low    | `docs/status/2026-08-21_12-06_*` f11/f12                                                                      |

---

<!-- Guidance:
  - Source of truth is the CODE and git log. Verify each item before starting.
  - One task per row. If it takes more than ~2 hours, split it.
  - Cite evidence (file paths, report sources) so the next person can verify.
  - DONE items should be REMOVED, not kept. Use CHANGELOG.md for history.
  - If a task is vague, refine it into concrete steps or move to ROADMAP.md.
  - For 80/20 impact prioritization, use the pareto-planning skill AFTER
    building the list here.
  - Deduplicate by semantic intent, not by text match.
-->
