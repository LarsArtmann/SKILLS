# Status Report — 2026-08-02 03:27 — verify-before-filing Skill Conversion

> **Scope:** This session only. Feedback files in `docs/feedback/new/` → skill conversion. No unrelated research. Honest self-assessment included.

---

## 0. TL;DR

Converted two feedback files describing the **same failure pattern** (filing premature upstream issues from unverified workarounds) into one skill: `verify-before-filing/`. All structural checks pass. **Two real gaps remain** (AGENTS.md reference graph not updated; process slip on edit ordering). No catastrophic damage.

---

## a) FULLY DONE ✅

| #   | Work item                                               | Evidence                                                                                                                                                                                                  |
| --- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Created `verify-before-filing/SKILL.md`** (193 lines) | Merged the best of both feedback files: gate-based workflow from the polished draft + the "Red Flags" quick-triage table unique to the raw proposal. 9 sections, under the 500-line gate.                 |
| 2   | **Frontmatter valid**                                   | `name: verify-before-filing` matches directory; description is a real trigger (567 chars, well under 1024); `allowed-tools` + `tags` set. `check-skills.sh` confirms.                                     |
| 3   | **README.md inventory updated**                         | Added row to "Skill Authoring & Verification" table; bumped count `24 → 25`; updated Quality & Status breakdown (Four → Five 🆕 New). Count guard passes.                                                 |
| 4   | **Bidirectional inter-skill link**                      | New skill §8 references `verify-external-claims` (outbound); `verify-external-claims/SKILL.md:13` now references `verify-before-filing` (inbound). Both directions confirmed via grep.                    |
| 5   | **Feedback archived**                                   | Both files `git mv`'d from `new/` to `processed/` with date-prefixed descriptive names. `docs/feedback/new/` is empty. Feedback-loop staleness check clean.                                               |
| 6   | **`check-skills.sh` passes**                            | All 25 skills valid, 0 thin skills, backlink integrity OK, count guard satisfied.                                                                                                                         |
| 7   | **Verified the embedded `gh` CLI command**              | `gh search issues --repo OWNER/REPO --state closed "keyword"` — confirmed `--repo` (`-R`) and `--state` flags exist via `--help`. The verification skill does not itself contain an unverified CLI claim. |

---

## b) PARTIALLY DONE ⚠️

| #   | Item                                 | What's missing                                                                                                                                                                                                                                                                                                              |
| --- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Inter-skill graph documentation**  | I added the bidirectional _link_ between the skills, but did NOT record the new pair in **AGENTS.md §5.5** ("Inter-Skill References") — the canonical place agents check before adding cross-references. Future agents won't know this link exists and could duplicate or break it. **This is the biggest gap.**            |
| 2   | **README "Quality & Status" nuance** | I bumped "Four → Five 🆕 New" correctly, and "Three of these carry verification-status blocks" remains accurate (the new skill has no unverified claims). But I did not add a sentence explaining _why_ `verify-before-filing` has no verification-status block while its sibling does — a future reader may wonder. Minor. |

---

## c) NOT STARTED ⏭️

| #   | Item                                              | Why                                                                                  | Should it be done?                               |
| --- | ------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------ |
| 1   | **Git commit**                                    | User did not ask.                                                                    | Awaiting instruction.                            |
| 2   | **Trigger-description testing**                   | Out of session scope; skill-creator eval loop not run.                               | Valuable but optional for a 🆕 New skill.        |
| 3   | **Sync installed `~/.config/crush/skills/` copy** | The repo is the canonical source; the installed copy I edited is a separate concern. | User manages their own install.                  |
| 4   | **Add to a comprehensive audit doc**              | No new audit was requested.                                                          | Next time `docs-health` or `status-report` runs. |

---

## d) TOTALLY FUCKED UP 💥

**Nothing catastrophic.** One process slip worth flagging:

- **Edited the wrong copy first.** I ran `edit` on `~/.config/crush/skills/verify-external-claims/SKILL.md` (the installed global copy) before realizing the canonical source lives in the repo at `/home/lars/projects/SKILLS/verify-external-claims/SKILL.md`. I then fixed the repo copy too. Both are now consistent, but the installed copy may drift from the repo on future reinstalls. **Lesson:** always confirm which path is canonical (repo vs. installed) before the first edit. The repo root is the source of truth for this project.

---

## e) WHAT WE SHOULD IMPROVE 🎯

### Process improvements (this session's lessons)

1. **Edit-ordering discipline.** Before editing any file that exists in two locations (repo + installed), identify the canonical source first. The project repo is canonical; installed copies are build artifacts of `skills add`.

2. **AGENTS.md §5.5 is a checklist item, not an afterthought.** Whenever a new cross-skill link is created, §5.5 must be updated in the same change set. The check-skills.sh guard catches _removed_ handoffs but not _added_ ones — that's a gap in the guard itself (see f).

3. **Verification skills should self-verify by default.** I got lucky that the `gh` command was correct. A verification skill embedding an unverified CLI command would be deeply ironic. The `verify-external-claims` skill's own gate should be run on any new skill before merging — especially one in the "Verification" category.

### Skill-content improvements (for verify-before-filing specifically)

4. **The example is single-domain (Nix/ROCm).** The skill generalizes to any upstream issue, but the only boxed example is the llama-cpp/ROCm case. A second short example from a different domain (e.g., a Go library issue, a TypeScript typings PR) would broaden triggering confidence.

5. **No `references/` directory yet.** The skill is 193 lines — lean and good. But as real-world failures accumulate, a `references/failure-catalog.md` would let the skill grow without bloating. Not needed now; plant the seed.

6. **Gate 5 (`gh search`) could mention `is:closed` web search as a fallback** for users without `gh` installed. Currently assumes the CLI is present.

---

## f) NEXT TASKS (up to 50, ranked by impact)

### High impact — do soon

1. **Update AGENTS.md §5.5** with the `verify-before-filing ↔ verify-external-claims` inbound/outbound pair. _(Closes the biggest gap from this session.)_
2. **Commit this session's work** (awaiting user go-ahead): new skill + README + backlink + feedback archive.
3. **Add a `check-skills.sh` guard for _new_ cross-skill links** — currently it only asserts _existing_ handoffs survive; it does not detect when a new bidirectional link is added but undocumented in AGENTS.md §5.5.
4. **Add `verify-before-filing` to the `handoffs` allowlist consideration** in check-skills.sh if we want to enforce the §8 backlink survives future edits.

### Medium impact — skill maturity

5. **Add a second boxed example** to `verify-before-filing` from a non-Nix domain (Go library typings, TS bundler config, Python packaging).
6. **Run the skill-creator eval loop** on `verify-before-filing` to test trigger-description accuracy with realistic prompts.
7. **Age the skill from 🆕 New → 🟢 Solid** by triggering it against a real upstream-issue decision and documenting the successful run (per README status legend).
8. **Add a `references/failure-catalog.md`** seed file to `verify-before-filing/` for accumulating future real-world cases.
9. **Consider a shared "epistemic-hygiene" tag cluster** — both verify skills share the tag; surface them together in README or a future index.

### Low impact — polish

10. **Add `is:closed` web-search fallback** to Gate 5 for users without `gh`.
11. **Reconcile installed vs. repo copies** of `verify-external-claims` (I edited both; confirm they're identical or document the install-sync workflow).
12. **Review the 13 pre-existing unstaged changes** in the working tree (architecture-review, bdd-testing, code-quality-scan, deduplicate-code, full-code-review, go-ecosystem-upgrade, go-error-modernization, how-to-golang, html-report-kit, pareto-planning, status-report, AGENTS.md) — these are not mine; they need triage or committing by whoever authored them.
13. **Investigate the `docs/planning/` untracked directory** — appeared in git status, not mine, unknown origin.
14. **Update the comprehensive audit** (`docs/status/2026-05-03_...`) or write a new one reflecting the 25-skill state.
15. **Run `docs-health` HARVEST** to pull any actionable items from this status report into TODO_LIST.md (per the status-report → docs-health handoff).
16. **Add `verify-before-filing` to the AGENTS.md §10 external dependencies table** if we consider `gh` an external dependency worth listing (borderline — `gh` is ubiquitous).

---

## g) QUESTIONS I CANNOT ANSWER MYSELF ❓

1. **Should I commit this session's work now, or do you want to review the `verify-before-filing/SKILL.md` body first?** I held off because the global AGENTS.md says never commit without explicit instruction — but this repo's conventions value clean, logical commits.

2. **The working tree has ~13 pre-existing modified files and a `docs/planning/` untracked dir that I did NOT author** (likely the auto-git daemon or a prior session). Should I leave them entirely untouched, or do you want me to triage whether they're safe to stage alongside my work?

3. **Do you want `verify-before-filing` treated as a standalone skill, or should it eventually be _merged into_ `verify-external-claims`** as a "direction" (inbound/outbound) within one skill? They're tightly coupled — a single skill with two modes might reduce discovery friction, at the cost of a longer SKILL.md. I chose separation this session; the tradeoff is yours to call.

---

## Appendix: Files Touched This Session

| File                                                                | Change                                  | Mine?                                       |
| ------------------------------------------------------------------- | --------------------------------------- | ------------------------------------------- |
| `verify-before-filing/SKILL.md`                                     | Created (193 lines)                     | ✅                                          |
| `README.md`                                                         | Inventory + counts + quality section    | ✅                                          |
| `verify-external-claims/SKILL.md`                                   | +1 line inbound/outbound scope note     | ✅                                          |
| `docs/feedback/processed/2026-08-02_external-issue-discipline-*.md` | Renamed from `new/`                     | ✅                                          |
| `docs/feedback/processed/2026-08-02_verify-before-filing-*.md`      | Renamed from `new/`                     | ✅                                          |
| `~/.config/crush/skills/verify-external-claims/SKILL.md`            | Same +1 line (installed copy)           | ✅ (process slip — edited before repo copy) |
| 13 other modified files + `docs/planning/`                          | Pre-existing, not authored this session | ❌                                          |

---

_Generated 2026-08-02 03:27. Reflects this session only._

---

## Resolution (2026-08-04 — docs-health HARVEST + living-docs build)

Forward-looking items harvested into `TODO_LIST.md` and `ROADMAP.md`.

### Done (confirmed shipped in later sessions)

- ~~f #1: Update AGENTS.md §5.5~~ — DONE. AGENTS.md §5.5 now documents the
  `verify-external-claims` ↔ `verify-before-filing` epistemic-hygiene pair
  (inbound/outbound split).
- ~~f #2: Commit~~ — DONE (committed `3a7cc56`, `e8b20bb`).
- ~~f #15: Run docs-health HARVEST~~ — DONE (this session, 2026-08-04).

### Still open (harvested into TODO_LIST)

| Report item                          | TODO_LIST ID | Notes                                          |
| ------------------------------------ | ------------ | ---------------------------------------------- |
| Audit verify-before-filing body, tags, cross-refs (e #5, f #5–8) | T3 | Committed blind; never properly reviewed |
| check-skills.sh guard for new cross-skill links (f #3) | T7  | Related to marker-vocabulary / handoff guard   |

### Routed to ROADMAP

- Age skill from 🆕 → 🟢 (f #7) → ROADMAP §1 (graduation criterion)
- Skill-creator eval loop (f #6) → ROADMAP §1
