# Health Report Format (AUDIT output)

The output format for the docs-health AUDIT step. Loaded from
[../SKILL.md](../SKILL.md) → AUDIT → step 6. Print the report inline to the
conversation — do **not** write it to a file (a docs-health audit is a living
diagnosis, not a point-in-time snapshot; snapshot status reports belong in
`docs/status/` via the separate `status-report` skill).

Print an inline summary table to the conversation (do NOT write to a file):

```
## Documentation Health Report

**Accuracy: 7.75/10** (computed: 10 − 1·1 Critical − 0.5·2 Medium − 0.25·1 Low = 7.75)
**Fitness: 6.5/10** (computed: 10 − 1·1 missing must-have − 0.75·2 structural-decay findings − 1.0·structural ratio [TODO_LIST 75% non-job → 2×(0.75−0.25)] = 6.5)

_Accuracy measures whether claims in existing docs are true. Fitness measures whether the docs serve their jobs. They are independent — a doc can be 100% accurate and 100% useless._

| Doc                  | Exists | Critical | Med-High | Medium | Low |
|----------------------|--------|----------|----------|--------|-----|
| README.md            | Yes    | 0        | 0        | 0      | 1   |
| AGENTS.md            | Yes    | 0        | 0        | 0      | 0   |
| FEATURES.md          | Yes    | 0        | 0        | 2      | 0   |
| TODO_LIST.md         | Yes    | 1        | 2        | 0      | 0   |
| DOMAIN_LANGUAGE.md   | No     | —        | —        | —      | —   |
| ROADMAP.md           | No     | —        | —        | —      | —   |
| CHANGELOG.md         | Yes    | 0        | 0        | 0      | 0   |

### Findings by severity

#### Critical (1) — affects Accuracy
- TODO_LIST.md:15 references deleted file `auth/old.go` (ghost)

#### Medium-High (2) — affects Fitness
- TODO_LIST.md:8 already done (session revocation fixed in commit abc123) — completed item belongs in CHANGELOG, not TODO_LIST
- TODO_LIST.md has "Previously Completed" section (20 lines duplicating CHANGELOG `[Unreleased]`)

#### Medium (2) — affects Accuracy
- FEATURES.md:12 says FULLY_FUNCTIONAL but tests fail for password reset
- FEATURES.md:18 missing OAuth feature that shipped in v1.2

#### Low (1) — affects Accuracy
- README.md:25 typo: "instalation" should be "installation"

#### Missing must-have (1) — affects Fitness
- docs/DOMAIN_LANGUAGE.md does not exist
```

## Two independent scores

> **Relationship to the AGENTS.md quality rubric:** When AGENTS.md specifically has
> issues, the [agents-quality-guide.md](./agents-quality-guide.md) provides a
> 5-dimension drill-down (Content ownership, Endurance, Leanness, Completeness,
> Structure). That rubric operates on a SINGLE file; Accuracy+Fitness below scores
> the WHOLE doc set. They are complementary, not competing.

A doc set has two health dimensions that diverge:

- **Accuracy** — are the claims in existing docs true? Verified against code.
- **Fitness** — do the docs serve their jobs? Structural decay, missing
  must-haves, forbidden sections, cross-file duplication.

Report both. They are independent: a doc can be 100% accurate and 100%
useless (the trophy-case failure mode). Combining them into one number hides
which axis failed and what kind of fix is needed (fact-check vs rebuild).

## Accuracy formula

Start at 10. Subtract:

- 1 point per Critical finding
- 0.5 points per Medium finding
- 0.25 points per Low finding

Floor at 0. Missing must-have docs do not affect Accuracy — a doc that does
not exist makes no claims to verify. They affect Fitness instead.

## Fitness formula

Start at 10. Subtract:

- 1 point per missing must-have doc
- 0.75 points per Medium-High (structural decay) finding
- **Structural decay ratio penalty:** for any living doc where the fraction
  of non-job content exceeds 25%, subtract `2 × (fraction − 0.25)`. Example:
  a TODO_LIST that is 80% historical cruft: `2 × (0.80 − 0.25)` = 1.1 points,
  even with zero factual errors.

Floor at 0.

**Why two scores, not one.** A single composite score cannot represent the
failure mode this skill exists to catch — a TODO_LIST that is factually
flawless but structurally rotten. Under any composite formula, perfect
Accuracy pulls the number up and hides the Fitness collapse. The split tells
you _which_ kind of fix is needed.

## Math discipline (the 2026-08-18 garbled-math lesson)

The score lines must be a **pure function of the findings table** — nothing else. Rules:

1. **Count first, score second.** Finish the findings table before writing either score line. Each score is computed by substituting the table's column counts into the formula — nothing more.
2. **No narrative adjustments.** Never write "floor-adjusted to…", "grouped as…", "effectively…". If the computed number feels wrong, the FINDINGS LIST is wrong — go fix the table, then recompute. Arithmetic is never massaged to match intuition.
3. **Grouping happens in the table, not the formula.** If 6 raw observations collapse into 3 findings (same root cause), they enter the table as 3 rows and the formula sees 3. The collapse is visible in the findings list where a reader can challenge it.
4. **Show the substitution** exactly as in the example: `10 − 1·1 Critical − 0.5·2 Medium …`. A bare number with no visible math is unverifiable.
5. **Qualitative beats pseudo-quantitative.** If you cannot honestly classify/count the findings, say so in words ("roughly a half-dozen Medium accuracy gaps") instead of fabricating precise-looking arithmetic. Incoherent precision is worse than admitted vagueness.

## Report rules

- State what was stale and fixed, what was already fresh, and what you could
  not verify (and why).
- Do NOT claim "all docs verified" if you skipped any.
- If you fixed issues during the audit, report both the original finding and
  the fix applied.
- **Never invent a prior state.** If there was no prior audit, say "first
  audit — no baseline." Do not write "was Accuracy X / Fitness Y" without a
  prior report to cite. Do not write "improved from X" without evidence of
  the prior state. Invented baselines are lies.
