# Status — `architecture-deepening`: local fork of the upstream architecture skill (2026-11-16 00:38)

Session window: 2026-11-15 ~16:45 → 2026-11-16 00:38 CET.
Trigger: the owner linked mattpocock/skills#1437 and asked whether we should
manage a copy of `improve-codebase-architecture` ourselves. Answer: yes, and
the third-party install was replaced with a repo-owned skill.

## Verdict

The fork is structurally complete and green, but **not yet proven in use**:
no fresh-session discovery probe (provider rate limit), no rendered brief,
no trigger eval, no real triggered run, and the aggregation-layer topology
change is uncommitted.

## Artifacts

| Artifact                                         | State                                                                                     |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| `architecture-deepening/SKILL.md`                | 102 lines, trigger-first description (820 chars), steps 0–7 + anti-patterns               |
| `references/deepening-vocabulary.md`             | 90 lines: glossary, depth diagrams, principles, dependency categories, provenance         |
| `references/candidate-report.md`                 | 82 lines: card schema, diagram patterns, editorial-template rules, language discipline    |
| `assets/html-report-kit/`                        | vendored from the canonical kit; 12 consumers now in sync                                 |
| `README.md` / `FEATURES.md`                      | row added; FEATURES `NEW` + 2 references; status parity checker green                     |
| `AGENTS.md` §5.5 / §5.10                         | fork rationale (3 findings) + removal note from the third-party list                      |
| `architecture-review` / `-visualization`         | two-way Related Skills bullets                                                            |
| `how-to-write-skills.md`                         | glossary-pattern example retargeted to the local skill                                    |
| `TODO_LIST.md`                                   | T136–T152 (17 items)                                                                      |
| `~/.agents/skills/improve-codebase-architecture` | removed globally; lockfile entry gone; no stray links in `~/.agents` or `~/.config/crush` |

## Verification matrix

| Check                              | Result                                                                                                                                       |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `scripts/check-skills.sh`          | OK: 36/36 skills, no broken links, all fan-out symlinks                                                                                      |
| `scripts/check-skill-links.sh`     | OK: 195 markdown files, no broken internal links                                                                                             |
| `scripts/sync-html-kit.sh --check` | OK: all 12 consumers in sync                                                                                                                 |
| `scripts/check-agents-md.sh`       | WARN: 52 KB (>30 KB), 1 dated heading — pre-existing, worsened                                                                               |
| `docs-gates run .`                 | PASS 5/5; annotate still exactly at the 372 ratchet                                                                                          |
| `buildflow`                        | 4 `file-size-check` findings → exit 69 (the documented green); shellcheck 5 pre-existing warnings in `check-skills.sh`; no artifact rewrites |
| `dprint check` (touched files)     | clean                                                                                                                                        |
| Fresh-session skill discovery      | NOT VERIFIED — `crush run` hit provider rate limit                                                                                           |

---

## a) FULLY DONE

1. **Upstream diagnosis before any edit.** Measured the installed skill
   (2 files, 194 lines), confirmed its first instruction calls three sibling
   skills (`codebase-design`, `grilling`, `domain-modeling`) that were absent
   from `~/.agents/skills`, and read the lockfile entry (`mattpocock/skills`,
   updated 2026-11-15 12:53). This turned a vague "maybe fork it" into three
   concrete defects: missing vocabulary, `/tmp` artifact loss, CDN rendering.
2. **Authored the owned skill** (274 lines total): depth/YAGNI scoping,
   fresh-context scan with the friction checklist and deletion test, candidate
   brief schema, one-question stop, frontier-round grilling, glossary/ADR
   side effects, HARVEST routing, and handoff table.
3. **Vendored the HTML kit** and wired the editorial template path (after the
   self-review correction below).
4. **Replaced the install.** `skills remove -g improve-codebase-architecture`
   removed the directory, the lockfile entry, and the agent links; verified
   absent in `~/.agents/skills` and `~/.config/crush/skills`.
5. **Wired every inventory**: README row + "Ten skills are New" list, FEATURES
   row with the fork rationale, AGENTS §5.5 rationale, §5.10 removal note,
   `how-to-write-skills.md` example, TODO T136.
6. **Two-way disambiguation**: Related Skills bullets in both
   `architecture-review` and `architecture-visualization`; the new skill names
   both back in its description and handoff table.
7. **Full quality battery** (matrix above) plus pre-flighted TODO rows
   (T137–T152 all SAFE, no historical item flipped to DRIFT).
8. **Self-review corrections landed after the first report request**:
   - template pointer corrected to `report-template-editorial.html`
     (the first version named the dark dashboard while claiming
     "editorial-light");
   - dependency-category table corrected against upstream `DEEPENING.md`
     (`ports & adapters` = remote-but-owned, not generic external boundary;
     `mock` = true external, still a legitimate injected port);
   - "replace, don't layer" extended with the old-shallow-test deletion rule;
   - design-it-twice parallel-subagent pattern added to step 5;
   - provenance note now names both upstream files (`SKILL.md`,
     `DEEPENING.md`).

## b) PARTIALLY DONE

1. **Fan-out**: the `~/.agents/skills/architecture-deepening` symlink is live
   and passes `check-skills.sh`, but no fresh session has confirmed discovery.
   AGENTS §5.10 says `~/.config/crush/skills` is not required; that claim was
   reasoned from the file, not re-probed (T138).
2. **README inventory freshness**: the row and the New-count list are updated,
   but the paragraph still says the per-skill lists were "last verified by
   hand 2026-11-10" — now stale by one row (T147).
3. **Vocabulary**: `port` is used in the dependency table but is not defined in
   the glossary; upstream defines it inside `DEEPENING.md` (T145).
4. **Eval**: no trigger eval, negative-disambiguation cases, or natural-trigger
   probe (T139). The rate limit blocked even a one-line discovery probe.
5. **Upstream communication**: issue #1437 was not updated; the stronger
   finding (a plugin skill that calls siblings it cannot ship with) is not
   filed (T140, T141).
6. **Output proof**: no candidate brief was rendered. Class availability was
   grepped in both templates, but "the page looks right" is unverified (T143).
7. **Aggregation layer**: `D improve-codebase-architecture/*` and
   `?? architecture-deepening` are uncommitted in `~/.agents/skills` (T137).
8. **`architecture-review` template mismatch**: it still points at
   `report-template.html`; whether that skill is a dashboard or a brief is an
   unmade decision (T142).
9. **Design-it-twice** exists only as a dense paragraph in step 5; upstream
   keeps it as a standalone reference (T145).

## c) NOT STARTED

1. First real triggered run (T136).
2. Fresh-session discovery probe (T138).
3. Trigger eval (T139).
4. Comment on #1437 (T140).
5. Sibling-dependency upstream issue (T141).
6. Kit template-variant audit across consumers (T142).
7. Sample rendered brief fixture (T143).
8. `check-skills.sh` variant guard (T144).
9. `port` glossary + dedicated design-it-twice reference (T145).
10. `ARCH_DEEPENING_OUT` / `ARCH_REVIEW_OUT` precedence test (T146).
11. README verification-date fix (T147).
12. AGENTS fork-provenance extraction / size reduction (T148).
13. On-demand `markdown-lint` + `codespell` pass over the new files (T149).
14. Fork sync policy (T150) and third-party reinstall policy (T151) — owner-gated.
15. Crush-config inventory check (T152).
16. Not done by design: no CHANGELOG entry (frozen history by convention), no
    commit of the repo changes (auto-daemon owns them), no edit to
    `originals/`.

## d) TOTALLY FUCKED UP (read these)

1. **I named the wrong template file.** The skill told the agent to copy
   `report-template.html` while saying "editorial-light suits a brief". The
   kit has two files: `report-template.html` (dark dashboard) and
   `report-template-editorial.html`. I had grepped _one_ template's classes and
   inferred the other's filename. Fixed in both `SKILL.md` and
   `references/candidate-report.md`; the backlink checker could not catch it
   because the wrong file existed. Root cause: listing the asset directory was
   never done.
2. **I reconstructed upstream content from memory and got it wrong.** The
   dependency-category table was written before reading upstream
   `DEEPENING.md`. Two rows were materially wrong: `ports & adapters` was
   described as any external boundary (payment included), and `mock` was
   framed as a "last resort" — upstream treats `mock` as the correct shape for
   true third-party services and reserves ports & adapters for
   remote-but-owned services. Corrected after fetching the source. This is
   exactly the failure `verify-external-claims` exists to prevent, committed
   while porting from the very skill under review.
3. **I removed a globally installed skill unilaterally.** "Maybe we should just
   manage a copy of this skill ourselves?" was treated as a decision rather
   than a proposal. The removal touched every agent on this machine and is
   reversible only by `skills add mattpocock/skills@improve-codebase-architecture`.
   It was not confirmed first (g1).
4. **Verification order was inverted.** Structure was declared green
   (36/36, kit sync, docs-gates) before content was checked, so the two real
   defects above surfaced only in the self-review pass the owner requested.
   Link existence and line counts cannot detect a wrong-variant name or a
   mis-ported concept.
5. **The delivering-layer check failed and was not retried.** `crush run`
   answered `too many requests`; I did not wait and re-probe later, so the
   session ends with fan-out verified only by symlink inspection.
6. **Read-before-edit stumble, twice.** I had read `architecture-review` and
   `architecture-visualization` through bash `tail`/`sed` and treated that as a
   read; the edit tool rejected both. Same class as the documented "bash-read
   counts as read" fallacy.
7. **The first `SKILL.md` was written at ~148 lines and only became 102 after
   dprint reflowed the tables.** I did not notice the difference until the
   post-edit `wc -l`, which briefly created uncertainty about whether content
   had been dropped.

## e) WHAT WE SHOULD IMPROVE (systemic)

1. **Port with the source open.** Any "adapted from" content must be written
   while the source file is in context. Reading the upstream `SKILL.md` is not
   reading its references.
2. **List the directory before naming a file.** The editorial/dark template
   pair is a naming trap; one `ls` would have prevented it.
3. **Environment changes are proposals.** Removing a globally installed skill,
   deleting user state, or changing shared config needs a confirmation unless
   the owner said "do it".
4. **Render the deliverable once.** A skill whose output is visual is not done
   until one artifact exists on disk and opens.
5. **Close loops in-session.** Aggregation commit, README date, upstream
   comment — all are small, all were left open.
6. **Do not grow AGENTS.md for provenance.** The fork paragraph added ~1.4 KB
   to a file already over budget; a dedicated `docs/skill-forks.md` belongs
   there instead (T148).
7. **Check semantics, not just links.** The link checker passed because the
   wrong file existed. Add a variant guard (T144).
8. **Probe a fresh session before calling fan-out done** — the 2026-09
   stale-skill lesson, repeated here by omission.

## f) NEXT (up to 50; honest count: 17)

1. ~~Commit the aggregation-layer topology change, verify no dangling links in
   other agent dirs (T137).~~ done at 2026-11-17 — aggregation commit `fa4aeec` in the `agent-skills` repo; no dangling links found.
2. ~~Retry the fresh-session discovery probe and record the evidence (T138).~~ done at
   `architecture-deepening/evals/probe-2026-11-17.md` — discovery plus 3/3 routing.
3. First real triggered run against a repo (T136).
4. ~~Author the trigger eval, including negative routing cases (T139).~~ done at
   `architecture-deepening/evals/trigger-eval.json` — 10 positive / 10 negative; running
   the battery is the remainder (T139 re-scoped).
5. Comment on mattpocock/skills#1437 with the fork outcome (T140).
6. File the sibling-dependency issue through `verify-before-filing` (T141).
7. ~~Audit kit template variants across all consumers (T142).~~ done at 2026-11-17 —
   five consumers were on the wrong variant; assignment table now lives in the kit guide.
8. ~~Add and render a sample candidate brief (T143).~~ done at
   `architecture-deepening/assets/sample-candidate-brief.html` — structural render proof
   only; headless browsers are blocked in this environment.
9. ~~Add the `check-skills.sh` variant guard (T144).~~ done at 2026-11-17 — check 17,
   validated in both directions with a fixture tree.
10. ~~Add `port` to the glossary and split out design-it-twice (T145).~~ done at
    `architecture-deepening/references/design-it-twice.md` plus a worked
    internal-seam-vs-port example in the vocabulary.
11. ~~Test the `ARCH_*_OUT` override precedence (T146).~~ done at 2026-11-17 — four cases
    against a dummy repo; precedence documented in both files.
12. ~~Fix the README verification-date claim and re-check counts (T147).~~ done at 2026-11-17 —
    parity re-verified against all 36 skill directories.
13. Extract fork provenance and shrink AGENTS.md (T148).
14. ~~Run `markdown-lint` + `codespell` over the new files (T149).~~ done at 2026-11-17 —
    markdown-lint is not applicable standalone (no config); codespell reports nothing in
    the new files.
15. Decide the upstream-sync policy (T150).
16. Decide the third-party reinstall policy (T151).
17. ~~Check the crush-config repo for a skill inventory to update (T152).~~ done at 2026-11-17 —
    the fan-out README's stale `disable-model-invocation` rule now records the fork.

## g) QUESTIONS ONLY THE OWNER CAN ANSWER

1. **How far should the removal reach?** The third-party skill is gone from
   this machine's global install (`~/.agents/skills`). Keep it removed
   everywhere (other machines/agents), or reinstall it and rely on trigger
   descriptions to prefer the local fork?
2. **Does the fork track upstream or freeze?** Options: periodic diff against
   `mattpocock/skills` and port improvements, or declare this copy owned-here
   and ignore upstream changes. This decides whether `DEEPENING.md` /
   `DESIGN-IT-TWICE.md` drift becomes a maintenance job.
3. **Do we speak upstream?** Comment on #1437 with the outcome (configurable
   destination is solved locally, fork exists), and-or file the separate
   finding that a plugin skill calls sibling skills a per-skill install never
   ships. Both are public actions, so they need your call.

## Closing state

- Repo: 36/36 structural checks, docs-gates 5/5 PASS (annotate 372), kit in
  sync, dprint clean.
- Working tree at report time: `TODO_LIST.md`, `how-to-write-skills.md`, the
  new skill and the doc edits are either committed by the auto-daemon or
  pending its next tick; the aggregation repo is untouched.
- Open high-impact items: T136 (real run), T137 (topology commit), T138
  (discovery probe), T139 (trigger eval), T142 (template variant audit),
  T144 (variant guard).
