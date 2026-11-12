# Status Report — docs-health full-corpus sweep: annotate, archive, harvest, gates adopted

**Session:** 2026-11-10 (runs into 2026-11-12 clock; daemon commits span both)
**Author:** Crush agent session
**Report type:** point-in-time snapshot + bulk-archive manifest (bring current via docs-health → ANNOTATE)

## TL;DR

Executed the docs-health skill end-to-end over the whole documentation
corpus: **77 historical files annotated and archived**, **49 new TODO rows
(T71–T121; T73/T82 folded into done-work, never minted)** and 8 new ROADMAP Open Questions harvested, **9+ drift fixes
landed on sight**, and the **docs-gates battery adopted repo-side** —
freshness, routing, cadence, and audit-all (104 reports replayed) all
PASS; annotate pinned at its measured pre-canon debt (`annotate_max: 372`,
AGENTS §5.13). All six living docs re-verified against the tree.

## a) FULLY DONE

| Item | Evidence |
| --- | --- |
| All 46 `2026-0*.md` + 2 June HTML in docs/status viewed and resolved (user scope), plus the full October corpus + planning + reviews HTML | 8 subagents (glm-5.3-flash, staggered) + main session |
| 77 files archived via `git mv`, every item struck-with-verdict / w / n / s / routed; `check-rows --strict` + `bare-rows` green per file | manifest below; battery annotate corpus 4175 struck items |
| docs-gates battery: freshness PASS, routing PASS (0 unrouted), cadence PASS (5 unarchived, oldest 9d), audit-all FRESH (104 reports, 0 unharvested) | `nix run github:Artmann-Technologies/docs-gates -- run .` |
| `.docs-gates.json` annotate ratchet pinned (372) with drain policy | AGENTS §5.13 |
| TODO_LIST T71–T121 (49 rows) + ROADMAP 8 Open Questions + themes 1/2/6/9/10 additions; every candidate row pre-flighted SAFE | pre-flight caught 7 would-drift tokens on draft 1 |
| Fix-on-sight: toolsdk step-8 parenthetical; FEATURES dated note + 4 drift fixes; README counts claim; AGENTS §5.10 rule-7 repoint + aggregation-commit rule; textstat external-deps row; `.gitignore` pycache; 3 rule-F spacing fixes | commits 2493c64, c386bab, 551e09b + daemon bundles |
| June HTML obligations routed (T95–T98 + ROADMAP theme 9); reviews HTML archived (all four plan items executed) | corpus-a + corpus-g2 inventories |
| Reconciliation decision doc annotated: Q0 answered 2026-10-27 §A (quoted before routing), plan steps → T57–T59, evidence tables ledger-exempt | `2026-10-11_08-30_*` |
| `check-skills.sh` exit 0 (35 skills) before and after; link-check green across 188 files | session-start + end runs |

## b) PARTIALLY DONE

1. **annotate gate** — pinned, not green: 372 findings are pre-canon
   archived damage (320 A/evidence May–July), 23 G/uniform cell-boundary
   strikes in `docs/planning/archived/2026-08-02_*`, 20 C/path verdicts
   citing other repos' paths, 8 F/spacing in point-in-time artifacts, 1
   cross-repo hash (amended to name its repo). Draining needs a dedicated
   campaign (deliberate non-fix recorded, AGENTS §5.13).
2. **docs-gates in buildflow** — the battery runs via nix; not yet wired
   into `.buildflow.yml` as a standing step (candidate follow-up).

## c) NOT STARTED

1. TODO T71–T121 themselves (the harvested backlog — that is next sessions' work).
2. The gmail-repair parallel session's own CHANGELOG entry (its session,
   not mine; its report is `2026-11-12_15-38_*`).

## d) DEFECTS / LESSONS (self-caught)

1. **First TODO draft would have genericized 7 tokens** other reports
   depended on ("medium", "body", "worked/example", "lines", "verify",
   "self-test") — caught by `--pre-flight` BEFORE writing, per the
   pre-flight-before-write contract. Reworded; second run SAFE.
2. **G1, F, G2 hit provider rate limits** (5–6 concurrent flash agents);
   all three recovered via model-move resume with zero lost work. The
   stagger lesson holds: ≤4 concurrent is the safe ceiling.
3. **One orphan file** (`2026-10-11_08-30`, missed in batching) — caught
   by the end-of-sweep `ls` audit and handled by the main session.
4. **2 hybrid struck+routed verdicts** (form violation: routed must be
   unstruck) found by the annotate gate among the agents' output —
   unstriked mechanically; the other 320 A/evidence are pre-canon.
5. Daemon ate several mid-sweep milestone commits as heuristic bundles
   (§5.12, known); detailed messages exist for the central commits
   (2493c64, c386bab, 551e09b) and this report + CHANGELOG carry the record.

## e) Gate state at close

- `./scripts/check-skills.sh` → exit 0 (35 skills; run again at end)
- `docs-gates run .` → freshness PASS · audit-all PASS · routing PASS ·
  cadence PASS · annotate PINNED-AT-372 (rc=1 by design until drained)
- `link-skills-to-agents.sh --check` → clean

## f) Next tasks

→ All rowed in TODO_LIST (T71–T121). Highest-impact unblocked: T72
(textstat path fix), T87 (age offer-page on real work), T94
(how-to-write-skills skill dir), T57 (website-template extraction).
Blocked on owner: T71/T75 + the 8 ROADMAP Open Questions.

## Archive manifest (77 files, per the bulk-archive rule)

**docs/status/archived/ (74):** 2026-06-17/06-18 HTML → LEAVE→ARCHIVED
after obligation routing (T95–T98, ROADMAP theme 9; HTML cannot carry
markers; dispositions in corpus-a inventory + this report). 2026-08-02 ×4
→ ARCHIVE (eval items routed ROADMAP theme 1; erraudit questions answered
2026-10-27). 2026-08-04 ×2 → ARCHIVE (living-docs audit executed; §a prose
left as narrative by precedent). 2026-08-11 → ARCHIVE (trigger-first
migration verified in current descriptions). 2026-08-12 ×4 → ARCHIVE
(go-release creation rounds; grades superseded; eval/wishes routed theme
6). 2026-08-14 ×3 → ARCHIVE (type-alias guidance live at domain-types.md:95;
symlink-model split encoded §5.10; corpus comparison closed). 2026-08-16 →
ARCHIVE (performance-tuning reference verified). 2026-08-21 ×4 → ARCHIVE
(waves T1–T20 executed `2fc1b46`; video reimagining superseded by policy
Q). 2026-09-08 ×5 + 2026-09-09 ×5 → ARCHIVE (waves T21–T32/wave-3
executed; T30/T33 routed; linter-building shipped + deepened 2026-10-08).
2026-09-10 ×2 → ARCHIVE (annotation scripts + lint fixes verified in
current tooling). 2026-09-12 ×3 → ARCHIVE (github-voice shipped; corpus
tooling Go since 2026-10-11; profile wishes → T110). 2026-09-13 ×2 →
ARCHIVE (sync-layer hardening verified; lockfile-count → T90). 2026-09-14
×3 → ARCHIVE (merge assessment verdict "no further merges warranted"
quoted before routing). 2026-09-16 ×3 → ARCHIVE (wise-Go lessons live in
skills; audit review closed). 2026-09-17 → ARCHIVE (signal doctrine
applied). 2026-09-18 ×3 → ARCHIVE (signal infra report; TOC → T88).
2026-09-24 → ARCHIVE (T36–T56 all executed, CHANGELOG evidence).
2026-10-01 → ARCHIVED (unsolicited-banner wishes → T118). 2026-10-08 ×2 →
ARCHIVE (toolsdk documented; step-8 fixed this session). 2026-10-11 ×7 →
ARCHIVE (conversion verified; proposals superseded by 2026-10-27 §A
decision; buildflow gate green; reconciliation = decision doc, Q0
answered). 2026-10-15 → ARCHIVED (go-aichat sync verified; backlog →
T121). 2026-10-17 ×4 → ARCHIVE (etag lessons landed in 3 skills;
cmdguard review wishes routed). 2026-10-24 ×4 → ARCHIVE (first-customers
shipped + wave 2; copy-brief move noted; product questions → ROADMAP).
2026-10-27 ×3 → ARCHIVED (stack-selection shipped; pareto decisions
answered same day; FEATURES re-verified this session). 2026-10-30 ×2 →
ARCHIVED (MWG policy executed + verified; open items live in T60–T70).
**docs/planning/archived/ (2):** 2026-09-16 audit-completion plan +
2026-09-18 pareto plan → executed by the 2026-09-18/24 waves.
**docs/reviews/archived/ (1):** 2026-10-27 brutal-self-review HTML — all
four plan items executed (evals 16/16 + 20/20, drift-check shipped,
aggregation commit `4100313`); zero open obligations.

## g) Questions for the owner

Already routed to ROADMAP Open Questions (offer-page eval spend/scope,
live-chat restore, synthetic.new quota, version-train boundary, cmdguard
depth, first-customers product choices) — see ROADMAP; no new questions
from this sweep beyond those.
