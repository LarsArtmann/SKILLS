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

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| Install commands work              | Trace through dependency file; would they run?            | Critical           |
| Feature claims match reality       | Cross-reference against `FEATURES.md` and actual code     | Medium             |
| Quick start steps are accurate     | Walk through each step mentally against the codebase      | Medium             |
| Links point at existing files      | Open each link target                                     | Low                |
| No internal architecture leaking   | Should be end-user facing only                            | Low                |
| Project name and description       | Matches what the project actually is                      | Medium             |

## AGENTS.md

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| Referenced paths exist             | Open each path mentioned in the file                      | Critical           |
| Architecture claims current        | Walk the code; does it match what AGENTS.md says?         | Medium             |
| Gotchas still valid                | Check if the workaround or quirk is still relevant        | Medium             |
| Build/test/lint commands work      | Would the documented commands actually succeed?           | Critical           |
| Counts computed not hardcoded      | Check any number against actual repo state                | Low                |
| No stale references to old skills  | Check for deleted/renamed modules                         | Medium             |

## FEATURES.md

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| FULLY_FUNCTIONAL items work        | Open the code; does it actually work?                     | Critical           |
| BROKEN items are actually broken   | Verify the break still exists                             | Medium             |
| PLANNED items have no code         | Grep for any implementation                               | Medium             |
| PARTIALLY_FUNCTIONAL gaps cited    | Open the cited file:line; is the gap still there?         | Medium             |
| Missing shipped features           | Are there new features in code not in FEATURES.md?        | Medium             |
| Status vocabulary used correctly   | Only the 4 defined statuses, no synonyms                  | Low                |

## TODO_LIST.md

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| Completed items removed            | Look for DONE items; they should not be here              | Medium             |
| No items already done in code      | Grep for symbols mentioned in each TODO                    | Critical           |
| No ROADMAP items leaking in        | Are there vague, unbounded items?                         | Low                |
| Evidence cited                     | Do file:line references still point at real code?         | Medium             |
| No duplicate tasks                 | Semantic dedup check                                      | Low                |

## ROADMAP.md

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| No bounded actionable tasks        | Should be raw ideas only; tasks go to TODO_LIST           | Low                |
| Still relevant                     | Does the direction match recent investment?               | Low                |
| No completed items                 | Shipped ideas should not linger here                      | Low                |

## CHANGELOG.md

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| Entries match git log             | Compare against `git log` since each version              | Medium             |
| Version numbers correct           | Match against git tags                                     | Medium             |
| No missing releases               | Are there tagged releases with no CHANGELOG entry?        | Medium             |
| Breaking changes prominent        | Would an upgrader notice them?                            | Critical           |

## docs/DOMAIN_LANGUAGE.md

| Check                              | How to verify                                              | Severity if failed |
| ---------------------------------- | --------------------------------------------------------- | ------------------ |
| Terms still used in code          | Grep for each term in the codebase                        | Medium             |
| No code terms missing             | Are there domain concepts in code not defined here?       | Medium             |
| Definitions accurate              | Does the definition match how the code uses the term?     | Medium             |

## Cross-file consistency

These checks compare docs against each other, not against code.

| Check                | What to look for                                                       | Severity |
| -------------------- | ---------------------------------------------------------------------- | -------- |
| Status consistency   | `FEATURES.md` says BROKEN but `README.md` markets it as working        | Critical |
| No duplication       | The same fact stated in multiple files (will drift)                    | Medium   |
| Correct ownership    | TODOs leaking into `FEATURES.md`; features leaking into `TODO_LIST.md` | Medium   |
| Valid cross-refs     | `README.md` links to files that exist; `AGENTS.md` paths are real      | Critical |
| Lifecycle integrity  | Shipped feature still in `TODO_LIST.md` (split brain)                  | Critical |
| Version consistency  | `CHANGELOG.md` version matches `README.md` stated version              | Low      |
