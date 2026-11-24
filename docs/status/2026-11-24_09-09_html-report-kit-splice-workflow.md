# Status: html-report-kit body-splice workflow (session 2026-11-24 05:0x–09:1x)

**Scope line.** This report covers ONE session in THIS repo: the "templ vs
centralized CSS" design question, the decision + implementation of the
html-report-kit **splice workflow** (agents write body fragments only, CSS
shell untouched), and its fan-out to consumer skills. VERIFIED with:
`shfmt -d` + `shellcheck` (exit 0) and `--self-test` on
`html-report-kit/assets/splice-report.sh` (green: fixture
splice/extract/failure paths + round-trip identity for 2 templates), the same
self-test through vendored copies (`status-report/`, `naming-review/` — green),
an end-to-end demo splice validated with python3 `html.parser` (balanced tags,
internal anchors resolving, CSS shell byte-identical to the template),
`./scripts/check-skills.sh` exit 0, `./scripts/check-shell.sh` exit 0,
`./scripts/check-agents-md.sh` exit 0 (advisories only; 51734 B < 52000
budget), `./scripts/sync-html-kit.sh --check` OK (12 consumers),
`find . -name splice_report.py | wc -l` → 0. Report describes `aa580d6`.
NOT verified here: consumer `references/*.md` layers (e.g.
`library-deep-dive/references/output-guide.md`) for restated copy-workflow
text — grep covered `SKILL.md` files only; `README.md` and
`how-to-write-skills/` workflow phrasing — not checked; the docs-gates
battery — not run this session; render-screenshot of the demo — not taken
(parse-level validation only). Sibling reports today (series continuity):
`2026-11-24_08-57_go-modularize-visibility-tiers-and-facade.md` (parallel
session, disjoint scope) and two `humanlayer-*` reports earlier — no
overlapping items.

## a) FULLY DONE

1. **Design decision.** `.templ` conversion rejected (compiled Go format;
   charter bans go.mod/build systems; per-skill installs carry no toolchain).
   CSS centralization answered with the splice seam instead. Evidence: this
   session's reasoning, recorded in `html-report-kit/references/html-output-guide.md`
   → Splice Workflow.
2. **`html-report-kit/assets/splice-report.sh`** — `--extract` (dump current
   scaffold), splice (template + body → report), `--self-test`. shfmt clean,
   shellcheck clean (full severity), self-test green canonical AND through
   vendored copies. Daemon-committed (`d2f5312` lineage).
3. **End-to-end splice verified.** Demo fragment → editorial template →
   parsed balanced, anchors resolve, pre-`<body>` bytes identical to the
   template, scrollspy preserved.
4. **Python prototype removed.** `git rm splice_report.py`; zero copies
   anywhere (canonical + 12 vendored). Restores the §5.11 no-Python state
   (ruff's "no files matching **/*.py" green claim is true again).
5. **Kit docs rewritten splice-first.** SKILL.md "How Other Skills Use This
   Kit"; guide: TOC entry, new Splice Workflow section (span contract,
   commands, fragment rules, shell-less fallback), Series Discipline rule 2
   ("Splice the template, never transcribe"), Quick Start. dprint clean.
6. **Consumer sweep, SKILL.md layer: 10 skills updated**
   (architecture-review, brutal-self-review, code-quality-scan,
   data-model-review, full-code-review, library-deep-dive, naming-review,
   pareto-planning, status-report, architecture-deepening) — all now link the
   vendored script + `#splice-workflow` anchor instead of restating the copy
   workflow. Repo grep "copy the template" → only intentional fallback text.
   `library-deep-dive`'s line-count-splicing ban now points at the
   anchor-based fix.
7. **Re-vendored all 12 consumers** (`sync-html-kit.sh`; `--check` OK; exec
   bit preserved on vendored scripts).
8. **AGENTS.md §5.9 note** + commit `aa580d6` whose body documents the whole
   change (the daemon's heuristic commits carry no message value).

## b) PARTIALLY DONE

1. **Consumer workflow sweep.** SKILL.md layer done; **references/ layer not
   swept** — `library-deep-dive/references/output-guide.md` very likely
   restates compose-the-file guidance (unverified). `design-to-code` and
   `go-modularize` vendored but their SKILL.mds never mention the kit
   workflow — correct if they don't author reports in-skill (unverified).
   Remaining effort: M.
2. **AGENTS.md size headroom.** 51734/52000 B — 266 B left. Any further §5.9
   growth must extract to `docs/` per the budget comment.
3. **Commit-message coverage.** Substance rides in daemon heuristic commits
   (`c4e896d` 34 files, `fd16355`, `c5414c8`); only `aa580d6` tells the
   story. History readable via that commit body, but fragmented.

## c) NOT STARTED

1. `--lint-report` mechanical checker (see e.3) — the /tmp validator used for
   the demo was thrown away; still wanted, not built.
2. docs-gates battery run over the repo post-change.
3. HARVEST routing of this report's (f) into TODO_LIST/ROADMAP — deliberately
   deferred: user instructed "wait for instructions".
4. Cold-session eval: does an agent follow the splice instructions without
   this session's context (how-to-write-skills eval doctrine)?
5. README.md / how-to-write-skills stale-workflow verification.
6. Recording the dprint inline-code whitespace lesson (see d.4) in
   how-to-write-skills patterns / AGENTS §5.11.

## d) TOTALLY FUCKED UP

1. **`git stash -- AGENTS.md` mid-diagnosis.** Swallowed my own edit in a
   repo with a live auto-commit daemon AND parallel sessions; recovered via
   `git stash pop` after verifying the stash held only AGENTS.md. Severity:
   could have tangled another session's work — did not. Root cause: reached
   for stash instead of a scratch copy. Never stash here again.
2. **Validator false alarm.** My throwaway python parser reported
   `mismatch </meta>` against the TEMPLATES; actual bug was the default
   `handle_startendtag` behavior with `<meta ... />` self-closing tags (my
   override gap). Caught by grep-before-fix — no `</meta>` existed anywhere;
   templates were never broken. Cost: one debug round, zero repo damage.
3. **Process misses.** (i) Five parallel edit calls without prior `View` —
   all rejected by the tool, no damage. (ii) Session-start checklist (§8.0:
   feedback/new scan, newest status report, TODO_LIST) not executed at session
   open — I worked from project context only. (iii) First AGENTS.md draft
   breached the byte budget (52022 > 52000) — caught by the advisory gate,
   trimmed to 51734.
4. **dprint ate whitespace-exact anchors.** First guide edit put
   leading-space anchor strings inside inline code spans; dprint stripped the
   leading spaces — semantic damage to a whitespace-exact contract, caught on
   re-read, reworded formatter-proof (byte-exact anchors now live only in the
   script header/`--help`). Wasted one formatting round because I authored
   formatter-fragile text in a dprint-managed file.

## e) WHAT WE SHOULD IMPROVE

1. **Commit at verified milestones, not at the end.** The daemon fragmented
   the work into heuristic commits; §7 makes agent commits the ceiling and I
   cashed it exactly once (AGENTS.md). Impact: readable history depends on
   one commit body.
2. **Never `git stash` in daemon/parallel repos.** Scratch copies inside the
   repo for A/B diagnostics instead (lesson from d.1).
3. **Fold the throwaway HTML validator into the kit** as `--lint-report` —
   every report author currently re-rolls it per the guide's integrity
   checklist. Bash-implementable subset: `href="#x"` ↔ `id="x"` cross-check,
   placeholder grep, single-`<style>`/`<main>` assertions; parse via the
   documented python3 one-liner.
4. **Author formatter-robust markdown.** Whitespace-exact strings belong in
   code fences or script headers, never in inline code spans of dprint-managed
   files (lesson from d.4).
5. **Grep for doctrine restatements at planning time.** The 10-consumer
   split-brain was found mid-flight; a 30-second repo grep when scoping the
   change would have sized the work upfront.

## f) Top next tasks

| #   | Task                                                                                              | Impact   | Effort | Category    |
| --- | ------------------------------------------------------------------------------------------------- | -------- | ------ | ----------- |
| 1   | Sweep consumer `references/*.md` (start: `library-deep-dive/references/output-guide.md`) for stale copy/line-splice workflow text; convert to splice links | High     | M      | Cleanup     |
| 2   | Verify `design-to-code` + `go-modularize` kit usage teaches no conflicting workflow (read their kit references) | Medium   | S      | Quality     |
| 3   | Grep `README.md` + `how-to-write-skills/` for copy-template phrasing; update if stale              | Medium   | S      | Documentation |
| 4   | Run docs-gates battery; confirm no ratchet regression from this session's docs                    | Medium   | S      | Quality     |
| 5   | HARVEST this report's (f) into TODO_LIST/ROADMAP (pre-flight rows with `docs-gates freshness . --pre-flight`) | High     | M      | Documentation |
| 6   | Add `--lint-report` to splice-report.sh (anchor cross-check, placeholder grep, structure asserts) | High     | M      | Feature     |
| 7   | Record the dprint inline-code whitespace lesson in how-to-write-skills patterns + AGENTS §5.11    | Medium   | S      | Documentation |
| 8   | Cold-session eval of the splice instructions (agent follows them without session context)         | Medium   | M      | Quality     |
| 9   | Plan AGENTS.md §5.9 extraction to `docs/` before the 52000 B budget is hit again (266 B headroom) | Low      | S      | Cleanup     |
| 10  | Guide: mention splice `--self-test` in the Report-Integrity Checklist's mechanical checks          | Low      | S      | Documentation |
| 11  | Consider a check-skills gate: kit consumers must link splice-report.sh (only if restatement recurs) | Low      | S      | Quality     |
| 12  | Optional convenience: `--extract --variant dark\|editorial` wrapper                                | Low      | S      | Feature     |
| 13  | Skim `example-editorial-report.html` for consistency with the rewritten Quick Start numbering      | Low      | S      | Quality     |
| 14  | Watch the first real spliced report in a consumer series; verify continuity in the wild            | Medium   | S      | Quality     |

## g) Questions I cannot answer myself

1. **Follow-up sweep now or queued?** Should the references-layer sweep +
   README/how-to-write-skills verification (f.1–3) run as the next session,
   or behind higher-priority TODO_LIST items? (Priority call is yours.)
2. **`--lint-report` in the script or guide-only?** Build mechanical checks
   into `splice-report.sh` (f.6), or keep them as documented checklist steps
   for report authors? (Tool-scope preference.)
3. **HARVEST timing.** Route this report's (f) into TODO_LIST/ROADMAP now,
   or wait for your signal? (You said wait for instructions — confirming
   this includes the harvest step.)
