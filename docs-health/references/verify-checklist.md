# Verify Checklist: Per-File Freshness Checks

> What to check for each doc type when running VERIFY mode.
> A doc is fresh only when you can confirm its concrete claims against
> the code. "Looks fine" is not a freshness check.

## Table of contents

1. [README.md](#readmemd)
2. [AGENTS.md](#agentsmd)
3. [FEATURES.md](#featuresmd)
4. [TODO_LIST.md](#todo_listmd)
5. [ROADMAP.md](#roadmapmd)
6. [CHANGELOG.md](#changelogmd)
7. [docs/DOMAIN_LANGUAGE.md](#docsdomain_languagemd)
8. [Cross-file consistency](#cross-file-consistency)

---

## README.md

| Check                            | How to verify                                         | Severity if failed |
| -------------------------------- | ----------------------------------------------------- | ------------------ |
| Install commands work            | Trace through dependency file; would they run?        | Critical           |
| Feature claims match reality     | Cross-reference against `FEATURES.md` and actual code | Medium             |
| Quick start steps are accurate   | Walk through each step mentally against the codebase  | Medium             |
| Links point at existing files    | Open each link target                                 | Low                |
| No internal architecture leaking | Should be end-user facing only                        | Low                |
| Project name and description     | Matches what the project actually is                  | Medium             |

## AGENTS.md

| Check                             | How to verify                                      | Severity if failed |
| --------------------------------- | -------------------------------------------------- | ------------------ |
| Referenced paths exist            | Open each path mentioned in the file               | Critical           |
| Architecture claims current       | Walk the code; does it match what AGENTS.md says?  | Medium             |
| Gotchas still valid               | Check if the workaround or quirk is still relevant | Medium             |
| Build/test/lint commands work     | Would the documented commands actually succeed?    | Critical           |
| Counts computed not hardcoded     | Check any number against actual repo state         | Low                |
| No stale references to old skills | Check for deleted/renamed modules                  | Medium             |

## FEATURES.md

| Check                            | How to verify                                      | Severity if failed |
| -------------------------------- | -------------------------------------------------- | ------------------ |
| FULLY_FUNCTIONAL items work      | Open the code; does it actually work?              | Critical           |
| BROKEN items are actually broken | Verify the break still exists                      | Medium             |
| PLANNED items have no code       | Grep for any implementation                        | Medium             |
| PARTIALLY_FUNCTIONAL gaps cited  | Open the cited file:line; is the gap still there?  | Medium             |
| Missing shipped features         | Are there new features in code not in FEATURES.md? | Medium             |
| Status vocabulary used correctly | Only the 4 defined statuses, no synonyms           | Low                |

## TODO_LIST.md

**Structural decay is the dominant failure mode for this file.** Check
job-fitness BEFORE factual accuracy — a TODO_LIST can be 100% factually
correct and 100% useless as a TODO list. If >25% of content is non-actionable
historical material (completed/resolved/rejected/duplicated), rebuild the
file rather than patching (see "Rebuild vs patch" in SKILL.md).

| Check                             | How to verify                                                                        | Severity if failed |
| --------------------------------- | ------------------------------------------------------------------------------------ | ------------------ |
| Job-fitness: open vs historical   | Count lines/items describing open work vs completed/resolved/rejected                | Medium-High        |
| No "Previously Completed" section | Flag any "Done" / "Resolved" / "Previously Completed" heading — belongs in CHANGELOG | Medium-High        |
| No duplication of CHANGELOG       | Cross-check completed items against CHANGELOG `[Unreleased]`                         | Medium-High        |
| No duplication of ROADMAP         | Cross-check deferred/backlog items against ROADMAP entries                           | Medium             |
| No rejected items in open lists   | A REJECTED item with rationale belongs in an ADR or ROADMAP, not TODO_LIST           | Medium             |
| No struck-through resolved items  | "Resolved (date)" with strikethrough belongs in CHANGELOG Fixed                      | Medium-High        |
| Completed items removed           | Look for DONE items; they should not be here (delete, do not annotate)               | Medium             |
| No items already done in code     | Grep for symbols mentioned in each TODO                                              | Critical           |
| No ROADMAP items leaking in       | Are there vague, unbounded items?                                                    | Low                |
| Evidence cited                    | Do file:line references still point at real code?                                    | Medium             |
| No duplicate tasks                | Semantic dedup check                                                                 | Low                |

## ROADMAP.md

| Check                       | How to verify                                   | Severity if failed |
| --------------------------- | ----------------------------------------------- | ------------------ |
| No bounded actionable tasks | Should be raw ideas only; tasks go to TODO_LIST | Low                |
| Still relevant              | Does the direction match recent investment?     | Low                |
| No completed items          | Shipped ideas should not linger here            | Low                |

## CHANGELOG.md

| Check                      | How to verify                                      | Severity if failed |
| -------------------------- | -------------------------------------------------- | ------------------ |
| Entries match git log      | Compare against `git log` since each version       | Medium             |
| Version numbers correct    | Match against git tags                             | Medium             |
| No missing releases        | Are there tagged releases with no CHANGELOG entry? | Medium             |
| Breaking changes prominent | Would an upgrader notice them?                     | Critical           |

## docs/DOMAIN_LANGUAGE.md

| Check                    | How to verify                                         | Severity if failed |
| ------------------------ | ----------------------------------------------------- | ------------------ |
| Terms still used in code | Grep for each term in the codebase                    | Medium             |
| No code terms missing    | Are there domain concepts in code not defined here?   | Medium             |
| Definitions accurate     | Does the definition match how the code uses the term? | Medium             |

## Cross-file consistency

These checks compare docs against each other, not against code.

| Check                     | What to look for                                                                   | Severity    |
| ------------------------- | ---------------------------------------------------------------------------------- | ----------- |
| Status consistency        | `FEATURES.md` says BROKEN but `README.md` markets it as working                    | Critical    |
| No duplication            | The same fact stated in multiple files (will drift)                                | Medium      |
| Correct ownership         | TODOs leaking into `FEATURES.md`; features leaking into `TODO_LIST.md`             | Medium      |
| Valid cross-refs          | `README.md` links to files that exist; `AGENTS.md` paths are real                  | Critical    |
| Lifecycle integrity       | Shipped feature still in `TODO_LIST.md` (split brain)                              | Critical    |
| TODO↔CHANGELOG dup        | Completed item in TODO_LIST also present in CHANGELOG `[Unreleased]`               | Medium-High |
| TODO↔ROADMAP dup          | Deferred/backlog item in TODO_LIST duplicates a ROADMAP entry                      | Medium      |
| TODO covers recent report | TODO_LIST/ROADMAP cover the "next tasks" of the most recent `docs/status/*` report | Medium-High |
| Forbidden sections        | TODO_LIST has a "Previously Completed" / "Done" / "Resolved" section               | Medium-High |
| Version consistency       | `CHANGELOG.md` version matches `README.md` stated version                          | Low         |

---

## Regression scenarios VERIFY must catch

These are concrete doc shapes that factual-only verification passes but a
job-fitness check must flag. Each was a real failure mode from a session. If
your VERIFY pass declares any of these "healthy," the job-fitness step was
skipped — go back.

| Scenario                | Shape                                                                                                                                                         | Factual-only VERIFY                                                | Job-fitness VERIFY (correct)                                                                                                                     |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Trophy section          | TODO_LIST with "Previously Completed" section duplicating CHANGELOG `[Unreleased]`                                                                            | PASSES (all facts true)                                            | FAIL: "structural decay — completed items belong in CHANGELOG"                                                                                   |
| Retained for reference  | TODO_LIST keeps completed items under a header note "retained for reference"                                                                                  | PASSES                                                             | FAIL: "completed items must be deleted, not annotated"                                                                                           |
| Split-brain backlog     | TODO_LIST backlog section and ROADMAP "Deferred Items" list the same 5 items                                                                                  | PASSES (only checks PLANNED-vs-FULLY_FUNCTIONAL)                   | FAIL: "deferred items duplicated across TODO and ROADMAP"                                                                                        |
| Rejected but kept       | TODO item marked REJECTED with rationale, sitting in an "open" list                                                                                           | PASSES                                                             | FAIL: "rejected items don't belong in open-work lists; move to ROADMAP or ADR"                                                                   |
| Struck-through resolved | "Correctness gaps (resolved YYYY-MM-DD)" section with struck-through items                                                                                    | PASSES (items marked resolved)                                     | FAIL: "resolved items belong in CHANGELOG Fixed, not TODO_LIST"                                                                                  |
| Unharvested report      | Most recent `docs/status/*` has a "Next tasks" / "Top N things" section; none of its items appear in TODO_LIST or ROADMAP, and none are verified-done in code | PASSES (TODO_LIST is factually fine — the items are simply absent) | FAIL: "status report next-tasks never harvested into TODO_LIST/ROADMAP — see HARVEST mode in SKILL.md. The report is a snapshot, not a backlog." |
