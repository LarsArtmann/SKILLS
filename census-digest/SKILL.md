---
name: census-digest
description: >
  Use when the user wants a domain-language census over the ~/projects
  fleet — reading every repo's docs/DOMAIN_LANGUAGE.md and distilling
  commonalities, duplicate glossaries, stub debt, anti-language sections,
  or adoption maps. Triggers on "census", "domain language census",
  "glossary survey", "how many repos have DOMAIN_LANGUAGE", "re-run the
  census", "fleet vocabulary audit", or when building term-frequency or
  duplicate-glossary evidence across the fleet. Owns the digest prompt for
  reader subagents, the hardening passes (md5 duplicate scan, string-verified
  term counts), and the evidence-artifact conventions so a census is
  repeatable in one session.
metadata:
  tags: census, domain-language, glossary, fleet, survey, digests
allowed-tools: bash view grep glob write
---

# Census Digest — repeatable domain-language census over the fleet

Born from the 2026-11-21 census (213 files read in full → 169 unique
projects, 38 identical stubs, 7 duplicate groups) and its follow-up plan.
This skill is the distilled procedure, including the two lessons that
session paid for: persist evidence at capture time, and verify counts
against ground-truth artifacts (never against memory).

## Procedure

### Phase 1 — Ground truth first (before any reading)

1. Persist the md5 all-pairs scan BEFORE dispatching readers — it is the
   duplicate/stub ground truth and catches what digest-readers miss:

   ```bash
   cd ~/projects && find . -maxdepth 4 -name 'DOMAIN_LANGUAGE.md' \
     -not -path '*/.git/*' -not -path '*/archived/*' -not -path '*/.Trash-1000/*' \
     -not -path '*/.corpus-pins/*' -not -path '*/ci-siblings/*' \
     -exec md5sum {} + | sort | awk '{print $1}' | uniq -d > /tmp/dup-hashes.txt
   ```

   Then list the files per duplicated hash and write both to
   `~/projects/docs/status/evidence/<date>_domain-language-identical-file-groups.txt`.

2. Count the corpus: how many files, how many repos have one, total bytes.

### Phase 2 — Reader subagents with the digest prompt

Dispatch readers in waves of ≤5 per provider, staggered (the 2026-11-21
stampede lesson). Each reader gets N files (25-30 per agent) and this
prompt, filled per file:

> Read <path> in full. Produce a digest with EXACTLY these five lines:
>
> - Domain: one sentence naming the business/domain problem.
> - Terms: the glossary's actual terms, comma-separated (verbatim term
>   names, not paraphrases; note the count).
> - Patterns: which of these appear: typed-ids/branded, status-enum,
>   event-sourcing/CQRS, validation-at-construction, versioning,
>   idempotency/retry, dry-run, provenance, workflow-stages, quarantine,
>   watermark/cursor. ALSO list any pattern the doc names that this
>   checklist misses (free-form pass — the checklist anchors, the free
>   pass catches Baseline/Intent/Verdict/Debounce-class concepts).
> - Conventions: doc shape (tables? context column? verification date
>   stamp? citation column "where it lives"? anti-language section?).
> - Distinctive: the one thing this doc does that no other would.
>   If the file matches the bare scaffold template (placeholder rows like
>   "Example Term"), output exactly: STUB (byte-identical template candidate).

Persist each batch's digests to
`~/projects/docs/status/evidence/<date>_domain-language-census-digests.md`
THE MOMENT the batch reports (never batch the writes to the end).

### Phase 3 — Derive, then string-verify

1. Term frequencies: `rg -li '<term>' --include='DOMAIN_LANGUAGE.md' ~/projects`
   (exclude archived/.Trash-1000/.corpus-pins/ci-siblings). Record counts
   as `rg -c` outputs, not estimates. Concept-tallies that cannot be
   string-verified (e.g. "money-as-minor-units" described in per-project
   wording) must be LABELED as concept tallies, never counts.
2. Cross-check every fleet-wide count against the md5 ground truth from
   Phase 1 — two derived numbers disagreeing means a derivation bug
   (2026-11-21: 58 vs 38 stubs; the loop was wrong, the gate was right).
3. Anti-language sections: `rg -li '^#{2,3}.*anti[- ]?(language|patterns|glossary)'`
   identifies header-explicit repos; "avoid-family" membership is
   content-judged and must be labeled as such, never counted as fact.

### Phase 4 — Report + harvest

- Report (HTML per the fleet's styled-report convention, or .md on owner
  override) lives in `~/projects/docs/research/<date>_domain-language-commonalities.html`.
- Every forward recommendation carries its evidence class: string-verified
  count, concept tally, or digest judgment.
- HARVEST within the session: bounded tasks → docs TODO_LIST, raw ideas →
  ROADMAP, owner questions → TODO_LIST "Decisions needed from owner".
- The three recurrence gates already exist (docs-gates stub/citations/stamps;
  `meta dupdocs`): re-run them over the fleet and record fresh baselines
  instead of hand-counting debt classes the gates already measure.

## Standing numbers to beat (2026-11-21 baseline)

169 unique projects, 38 stubs (now 0 after the writing wave), 7 duplicate
groups/51 paths (all folded), anti-language 5 header-explicit, citations
53 repos/147 dangling, CQRS/ES union 68, sync 32, branded IDs 57,
idempotency 28, error-family 25. A re-census should explain every delta.
