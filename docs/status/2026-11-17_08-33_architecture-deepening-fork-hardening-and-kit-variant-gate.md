# Architecture-deepening fork hardening — kit variant gate and end-to-end wiring

**Date:** 2026-11-17 08:33 CET
**Scope:** execute the unblocked high-impact remainder of the 2026-11-16 fork
self-review (T137-T152), with every claim re-verified against the working tree
**Report style:** status inventory (a-f) plus owner questions (g); no roadmap

## TL;DR

Ten TODO rows closed and removed. The fork is now _proven_ reachable in a fresh
session and _provably_ routed away from its two neighbours. The
wrong-template-variant bug that the previous report could only describe is now
a gate (`check-skills.sh` check 17) — and writing that gate exposed a worse
fact: the structural gate had been unable to pass its own selftest since
2026-11-15 (`docs-gates` would never have said so). Both are fixed. What is
still not done is the only thing that cannot be done alone: a real triggered
run against a repository the owner picks (T136), and the three owner decisions
in §g.

## a) FULLY DONE

1. **Aggregation topology committed (T137).** `agent-skills` commit `fa4aeec`:
   deletes `improve-codebase-architecture/{SKILL.md,HTML-REPORT.md,agents/openai.yaml}`,
   adds the `architecture-deepening` symlink. Verified before committing: zero
   dangling symlinks across `~/.agents/skills`.
2. **Discovery probe passed (T138).** Fresh `crush run` session lists exactly
   `architecture-deepening`, `architecture-review`, `architecture-visualization`
   — the removed skill is gone — and answers "our modules are shallow" with
   `architecture-deepening`.
3. **Routing probe passed, both arms (T139 part 1).** Scored assessment →
   `architecture-review`; pain-to-change/shallow → `architecture-deepening`;
   every-file audit → `full-code-review`. Transcript persisted at
   `architecture-deepening/evals/probe-2026-11-17.md`.
4. **Trigger eval authored (T139 part 2).**
   `architecture-deepening/evals/trigger-eval.json`, 20 queries (10 positive,
   10 negative), each negative naming the skill that must win instead.
5. **Template variants audited and fixed (T142).** Five consumers linked the
   dark dashboard while the kit's own mapping assigns editorial to reviews and
   audit briefs: `architecture-review`, `brutal-self-review`,
   `data-model-review`, `full-code-review`, `naming-review`. All five now link
   `report-template-editorial.html` and state why. The decision itself moved
   into one place: the `variant-assignments` table in
   `html-report-kit/references/html-output-guide.md`, with series continuity as
   the documented override.
6. **Variant guard added (T144).** `check-skills.sh` check 17 fails when a
   skill's named template contradicts its assignment row, when the assigned
   template is not vendored into that skill, or when a named template does not
   exist. Validated in both directions with a throwaway fixture tree (wrong
   variant → 2 FAIL lines; corrected + vendored → clean), and the real repo
   passes.
7. **Structural gate repaired.** `check-skills.sh --selftest` was failing at
   HEAD before this session's edits: the docs-health artifact gate ran
   `cd docs-health/assets` unconditionally, so fixture trees without tooling
   aborted. It now skips with a NOTE; all three selftest legs are green.
8. **Sample candidate brief shipped (T143).**
   `architecture-deepening/assets/sample-candidate-brief.html`: two candidates
   in the real editorial classes (before/after diagram pair, one
   `table.compare`, both badge tiers, problem/solution/wins, ADR callout),
   zero external references, balanced tags, all classes defined, every anchor
   target present.
9. **Design-it-twice extracted (T145).**
   `architecture-deepening/references/design-it-twice.md` (process, briefs,
   output contract, failure modes) replaces the dense step-5 paragraph, which
   is now a pointer. The vocabulary gained **port** plus a worked four-module
   table separating an internal seam from a port.
10. **Output-path precedence pinned (T146).** `ARCH_DEEPENING_OUT` then
    `ARCH_REVIEW_OUT`; a value ending in `.html` is the file, any other value is
    the directory; neither → `docs/architecture-understanding/`. Four cases run
    against a dummy repo, including both-variables-set.
11. **README honesty restored (T147).** Verification date changed to
    2026-11-17 with the method stated, and README's 36 skill rows re-diffed
    against the 36 skill directories (no drift).
12. **On-demand lint run (T149).** `codespell` reports 42 pre-existing
    findings and nothing in the new files; `markdown-lint` is not applicable
    standalone (no repo config) — a rejection, not a pass, and recorded as such.
13. **crush-config fan-out doc corrected (T152).** The stale
    `disable-model-invocation` rule about the removed skill now records the fork
    and its normal appearance in session lists (committed in that repo).
14. **Bookkeeping.** CHANGELOG entry, AGENTS §5.5/§5.9 updates (variant gate,
    design-it-twice reference, probe evidence), TODO_LIST rows T137/T138/T142/
    T143/T144/T145/T146/T147/T149/T152 removed after the work landed, and the
    2026-11-16 report's §f items annotated `done at` inline.
15. **Kit-artifact HTML sanity gate added (check 18).** Any HTML inside a skill
    directory carrying the kit's token vocabulary fails on a network reference,
    an unbalanced block tag, or a dangling in-page anchor. All three failure
    modes exercised with a fixture tree.
16. **`--selftest` is now part of the session-start checklist**, so the gate
    cannot go back to passing rules it no longer evaluates.

## b) PARTIALLY DONE

1. **T136 first real triggered run — not done.** The skill's step 4 asks the
   user which candidate to deepen, so a real run needs a chosen repository and
   a human answer. Synthetic runs would prove the procedure, not the value.
2. **Render proof is structural, not visual.** Headless `firefox` is blocked by
   the permission layer in this environment, so "renders" means: no external
   references, balanced tags, every class defined, every anchor resolves. The
   edit that produced the fixture is `head -n 849 template` + hand-written body
   - the template's own scrollspy block.
3. **T139 battery unrun.** The eval file exists; running 20 fresh sessions is a
   separate spend decision, and the three-prompt probe already covers the
   highest-risk routing.
4. **AGENTS.md got longer, not shorter.** The §5.5 and §5.9 additions are
   small but real; T148 (extract fork provenance into `docs/skill-forks.md`)
   is now more valuable, not less.

## c) NOT STARTED

1. **T140** — comment on mattpocock/skills#1437 with the fork outcome.
2. **T141** — file the sibling-dependency issue (run `verify-before-filing`).
3. **T148** — extract fork provenance, shrink AGENTS.md (52 KB).
4. **T150** — upstream-sync policy for the fork (track periodically or freeze).
5. **T151** — keep the third-party skill removed everywhere, or reinstall it.
6. **T153** — stale deployed inventory `~/.config/crush/skills/README.md`
   (real file, 2026-07-15) still lists `improve-codebase-architecture` and
   `execution-mode`; it is under the never-edit fan-out path, so it needs an
   owner decision (trash, regenerate, or hand to home-manager).
7. **T154** — stale second aggregation checkout `~/projects/agent-skills`
   (2026-10-09) still holds the removed skill as a real directory; nothing
   references it.
8. **T68** — branch policy for `agent-skills`: this session's topology commit
   also landed on `docs-health-verify-legs`, compounding the existing
   `docs-health-verify-legs` question rather than resolving it.

## d) TOTALLY FUCKED UP

1. **The structural gate could not pass its own selftest, and nobody noticed.**
   Every session-start checklist step 5 runs `check-skills.sh`; none runs
   `--selftest`. A gate that cannot validate itself is a gate with an unverified
   verifier — it exited 0 the whole time while the selftest leg was red.
2. **Five consumers had the wrong template variant for months.** The link
   checker passed them all, because the wrong file existed. This is the general
   failure mode: existence checks cannot see semantic mismatch. Check 17 is the
   first guard in this repo that compares a _decision_ against its _links_.
3. **I nearly shipped a fixture that violated its own skill.** The first sample
   brief contained an introduction paragraph, which `candidate-report.md`
   explicitly forbids ("The cards carry the report"). Caught by reading the
   reference against the artifact, not by any gate.
4. **First guard implementation was wrong twice.** It grepped
   `"$sk/references"` even when absent (grep aborts on a missing operand, so
   the "names no template" branch fired spuriously), and a `printf --` fixture
   in the negative test wrote no file at all, producing a false "guard broken"
   read. Both were harness bugs, but they cost two rounds and only surfaced
   because the negative test was run.
5. **The deployed fan-out README is a live lie** and I did not fix it, because
   the rule forbids editing that path. Leaving a known-wrong doc in place is the
   correct call under the rule, but it needs T153 to close rather than rot.
6. **Two commits of mine are now bundled with foreign work.** The
   crush-config doc fix landed inside a daemon commit (`80cbef4`) that also
   carried an unrelated status report — the documented daemon behaviour, but it
   means neither change has its own message.

## e) WHAT WE SHOULD IMPROVE

1. **The selftest now runs in the session-start checklist** (actions taken, keep
   it there). The selftest is the only thing that proves the gate's rules are
   still being evaluated.
2. **A static HTML sanity check now guards kit artifacts** (`check-skills.sh`
   check 18: no network references, balanced block tags, anchors resolve).
   Teaching-it-the-hard-way note: writing it reintroduced the 2026-09-09
   silent-exit class twice in one hour, because `grep | wc -l` under `pipefail`
   makes an assignment exit non-zero.
3. **Keep decisions in tables, not prose, when a guard can read them.** The
   `variant-assignments` table is the pattern: one source, machine-checked.
   Apply it to other repeated per-skill claims if they start to drift.
4. **AGENTS.md needs the extraction (T148).** Every session adds a paragraph;
   the file is 52 KB against a 30 KB advisory.
5. **TODO_LIST rows should be closed at the moment the work lands**, not at
   session end: the freshness gate went red purely because a completed row
   disappeared before the report that promised it was annotated.
6. **When a shell harness produces a surprising result, suspect the harness
   first.** Two of this session's three "guard is broken" reads were `printf`/
   `grep` semantics, not the guard.

## f) NEXT (up to 50; honest count: 12)

1. **T136** first real triggered run: pick a repository, produce the brief,
   answer step 4, and only then age the 🆕 badge per the two-stage rule.
2. **T139** run the 20-query battery and record per-arm results.
3. **T153** decide the fate of `~/.config/crush/skills/README.md`.
4. **T154** decide the fate of `~/projects/agent-skills`.
5. **T68** resolve the `agent-skills` branch policy now that two commits ride on
   `docs-health-verify-legs`.
6. **T148** extract fork provenance into `docs/skill-forks.md`; shrink AGENTS.
7. **T140** comment on upstream #1437 (draft with `github-voice`).
8. **T141** file the sibling-dependency issue (`verify-before-filing` first).
9. **T150** upstream-sync or freeze decision.
10. **T151** third-party reinstall-or-not decision.
11. Re-run the three routing probes after any future description edit.
12. Watch the next full `buildflow` run: the four known size findings should be
    the only red (T69/T135 territory), and the frozen eval artifacts stay clean.

## g) QUESTIONS ONLY THE OWNER CAN ANSWER

1. **Does the fork track upstream or freeze?** (T150) Periodic diff against
   `mattpocock/skills` and port improvements, or declare this copy owned-here
   and take changes only when someone notices a gap?
2. **Does the third-party skill stay removed everywhere?** (T151) It is gone from
   this machine; other machines and agents may still have it, and its trigger
   text overlaps this fork's.
3. **Do we talk to upstream?** (T140/T141) A comment on #1437 recording the
   local fork and the missing-sibling-skills finding is cheap; the separate
   sibling-dependency issue is a stronger claim and needs
   `verify-before-filing` plus a decision on whether it is one issue or two.

## Verification (this session's evidence)

| Gate                                 | Result                                                     |
| ------------------------------------ | ---------------------------------------------------------- |
| `scripts/check-skills.sh`            | exit 0 — 36 skills, 197 markdown links, new check 17 green |
| `scripts/check-skills.sh --selftest` | exit 0 — 3/3 legs (was failing before this session)        |
| `scripts/check-skill-links.sh`       | OK — no broken links in 197 markdown files                 |
| `scripts/sync-html-kit.sh --check`   | OK — 12 consumers in sync                                  |
| `nix run …docs-gates -- run .`       | PASS 5/5 (annotate held at the 372 ratchet)                |
| `buildflow -s codespell`             | 42 pre-existing findings, none in the new files            |
| `buildflow -s markdown-lint`         | not applicable (no repo markdownlint config)               |
| `dprint check` on all touched files  | clean                                                      |
