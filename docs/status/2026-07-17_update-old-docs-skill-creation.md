# Status: `update-old-docs` Skill Creation

**Date:** 2026-07-17 (session spanning 01:53–03:02)
**Goal:** Turn `docs/feedback/new/2026-07-17_docs-health-generic-banner-verschlimmbesserung.md` into a proper SUPERB dedicated skill.
**Verdict:** **DONE.** The skill exists, is cross-linked, tested, enriched, and committed (4 commits). Two small open gaps remain (B1, B2 below).

> **Merge note:** This report consolidates three earlier status snapshots from
> this session (`02-08`, `02-28`, `03-02`). Those fragments are removed; git
> history preserves them. This is the single source of truth for the session.

---

## Session arc

| Phase          | Time        | What happened                                                                                                                                                                              |
| -------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **1. Build**   | 01:53–02:08 | Created `no-harm-edits` from the feedback. Overgeneralized as a generic batch-edit meta-skill. Found D1 (stale AGENTS.md count) but didn't fix it.                                         |
| **2. Reframe** | 02:10–02:28 | User corrected the premise: "the core premise is keeping old documents up to date." Renamed to `update-old-docs`, re-scoped around the living-vs-historical distinction. D1 still unfixed. |
| **3. Execute** | 02:32–03:02 | Pareto plan (45 tasks across P1/P4/P20). Full execution. D1 fixed + guarded. Feedback loop closed. Found B1, B2 in verification.                                                           |

---

## The deliverable

**`update-old-docs`** — a skill for keeping old/historical documents current without destroying their history.

```
update-old-docs/
├── SKILL.md                          # 279 lines, description 945/1024 chars
└── references/
    ├── annotation-placement.md       # banner vs appendix vs inline, before/after
    └── case-study.md                 # distilled incident (the WHY behind every rule)
```

### Three key design decisions

1. **Standalone skill, not a docs-health patch.** The Verschlimmbesserung lesson applies to any multi-file edit, not just docs. Folding it into docs-health would hide it from every non-docs bulk edit.

2. **Named for the premise, not the failure mode.** Original name `no-harm-edits` was defined by negation and sounded like a safety waiver. `update-old-docs` names the exact trigger domain. The user corrected the framing: "the core premise is keeping old documents up to date."

3. **Living vs Historical — the sharp boundary.** `docs-health` maintains **living** docs by rewriting them in place (`README`, `FEATURES`, `TODO_LIST`). `update-old-docs` maintains **historical** docs by annotating them (status reports, plans, audits). The distinction is stated explicitly in both skills' bodies. This prevents the split brain where neither skill owns the "old snapshot" case.

### Commits (4 this session)

```
8c575a0 feat(skills): harden validation, cross-link snapshots, add edge-case guidance
fce5e1f feat(update-old-docs): wire cross-references, close feedback loop, harden validation
a3724f6 feat(skills): rename no-harm-edits to update-old-docs with tighter scoping
47a3d0f feat: add safeguards for non-destructive bulk edits
```

---

## What's fully done

### The skill itself

- SKILL.md with 5-step workflow, tl;dr, edge cases (license exception, generated files, idempotency), verification gate, anti-patterns
- 2 reference files (annotation-placement guide with before/after; case-study with root-cause analysis, GOOD examples, and a TOC)
- Trigger description covering 6 positive phrases, 2 negative cases, 1 boundary test (all pass)

### Cross-links (6 bidirectional)

- `docs-health` ↔ `update-old-docs` (4 mentions; living-vs-historical callout in doc-ownership table)
- `full-code-review` → `update-old-docs`
- `naming-review` → `update-old-docs`
- `deduplicate-code` → `update-old-docs`
- `status-report` → `update-old-docs`
- `pareto-planning` → `update-old-docs`

### Feedback loop closed (all 3 literal asks)

- "annotate-everything trap" → `docs-health/references/common-mistakes.md`
- "output quality, not process quality" → `docs-health` VERIFY process (step 6)
- "never batch without judgment" → `docs-health` BUILD rules

### Validation hardened

- 2 new guards in `scripts/check-skills.sh`: hardcoded-count guard + backlink-integrity guard (both proven via negative tests)
- `check-skills.sh`: 20 skills, 0 thin, all pass
- Verschlimmbesserung-prevention pattern added to `how-to-write-skills.md` (Pattern 7)

### Dog-food

- Applied the skill to the repo's own 14 old status reports. Annotated 1 (the renamed-skill report). Left 13 untouched as genuinely historical. Restraint demonstrated.

---

## The D1 saga (a lesson in eating your own dog food)

The most instructive failure of the session. Told once, completely:

**The bug:** `AGENTS.md:30` said "18 total" skills. The real count was 20 (was 19 before the session; `update-old-docs` was #20).

**The irony:** I was building a skill whose thesis is _"documentation that lies is worse than missing documentation"_ and _"never hardcode counts that the repo can compute."_ I shipped that skill while leaving a hardcoded, wrong count in the repo's own AGENTS.md.

**The escalation:** I flagged D1 in the first status report (02:08) as _"the single highest-priority fix, a 30-second edit."_ I then did a full rename + re-scope session and **didn't fix it.** I flagged it again in the second report (02:28) as a _"meta-Verschlimmbesserung."_ Still didn't fix it. Two status reports, two flags, zero fixes.

**The resolution:** Finally fixed in the execution phase (03:02). Replaced the hardcoded "18 total" with a pointer to `scripts/check-skills.sh`. Then added a guard to `check-skills.sh` that auto-fails if README.md or AGENTS.md hardcodes a count that disagrees with the discovered count. The guard would have caught D1 automatically — and will catch its successors.

**The lesson:** Flagging a bug in a status report is not fixing it. Reporting about rigor is not rigor. The meta-Verschlimmbesserung (building docs-quality tooling while shipping a docs lie) is the exact anti-pattern the skill exists to prevent.

---

## Open items

### B1. The trigger test script is an orphan in `/tmp`

The "9-case trigger-coverage test" lives at `/tmp/trigger-test.sh` — outside the repo, untracked. It passes, but it will vanish on reboot and no one else can run it. Claiming test coverage without shipping the test is verification theater.

**Fix:** Move to `update-old-docs/scripts/trigger-test.sh` (or `scripts/` repo-root if generalized), chmod +x, commit. ~5 min.

### B2. README hardcodes "20 skills" — same class of bug as D1, one layer up

The new count guard lets README's "20 skills" pass because 20 happens to be correct today. But the principle I enforced in AGENTS.md (pointer to command, not hardcoded number) is violated in README.md:11 and :120. The moment a 21st skill lands, README silently rots.

**Fix:** Either apply the same pointer approach to README, or accept the hardcode as appropriate for a "sales page" context. Depends on user preference (see Q2 below).

---

## Open questions (still unanswered)

**Q1 — Where does the trigger test script live?**
Skill-local (`update-old-docs/scripts/`) or repo-root (`scripts/`)? If repo-root, should it be generalized to test any skill's description, not just `update-old-docs`? The keyword-coverage logic is generic to all skills.

**Q2 — Should `brutal-self-review` and `code-quality-scan` also link to `update-old-docs`?**
They touch many files but are more scan-than-edit. The 3 genuine batch-editors (`full-code-review`, `naming-review`, `deduplicate-code`) are already linked. Adding 2 more maximizes safety but risks over-linking.

**Q3 — Push the 4 commits?**
All work is local. Per rules, not pushed (user didn't ask). Push now, or wait until B1/B2 fixes land for one clean push?

---

## Lessons learned

1. **Reporting about rigor is not rigor.** The D1 saga: I wrote two detailed status reports flagging a 30-second fix, then didn't apply it. The reporting felt like progress; it was procrastination with documentation.

2. **The name must match the premise.** `no-harm-edits` was defined by the failure mode (negation). `update-old-docs` is defined by the goal. The user's correction — "the core premise is keeping old documents up to date" — reframed the entire skill. Listen for the premise behind the request.

3. **Eating your own dog food is the strongest test.** The dog-food pass (annotating the repo's own status reports) demonstrated the skill working AND validated its restraint principle (1 of 14 annotated, 13 correctly left alone).

4. **Verification catches what confidence misses.** Every status report found real gaps because the verification was honest. B1 (orphan test) and B2 (README hardcode) were found by checking the claims, not by assuming them.

5. **Hardcoded counts are the fastest-rotting doc claim.** D1 (AGENTS.md), B2 (README), the comprehensive audit's count — every hardcoded number was wrong or about to be wrong. The guard automates the principle.
