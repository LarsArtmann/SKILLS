# Communication Doctrine ("SHUT UP AND COMMUNICATE")

> **Provenance note (2026-09-24).** The user pasted this doctrine into chat on
> 2026-09-17 and asked how to apply it to this repo. The verbatim paste was
> never persisted — it lived only in the session transcript — so this file
> records the doctrine as faithfully reconstructed from the two status reports
> that processed it (`docs/status/2026-09-17_21-45_signal-density-doctrine-applied.md`
> and `docs/status/2026-09-18_05-39_signal-density-infrastructure-status.md`).
> Like everything in `originals/`, this file is frozen source material: do not
> edit; the canonical encoding lives in the skills it seeded.

## What it seeded

- **Principle 7 ("Signal density")** in `how-to-write-skills.md` — the rule,
  the four-consequence table, and the canonical house-jargon glossary.
- **`scripts/check-skills.sh --signal`** — the advisory signal-density report
  (preamble / prose / filler / jargon counts with line numbers).
- **check 15** in `scripts/check-skills.sh` — the hard gate on pure
  throat-clearing ("It is important to note…" can never change an action).
- The 2026-09-17 body-application pass: 12 skills edited, every fix verified.

## The doctrine (four tenets)

1. **Delete the first 90%.** Whatever you wrote first is throat-clearing;
   the communication starts where the substance starts.
2. **The physical-world test.** Every line must produce something in the
   physical world — a tool call, a command, a decision. If deleting a line
   loses no behavior, delete it.
3. **Communication is behavioral control.** The purpose of writing is to
   change what the reader does, not to explain what the writer did. Prose
   that reads well but flips no decision is noise.
4. **Clear over clever.** Invented vocabulary ("ghost system", "split brain")
   is only allowed with a plain gloss at first use.

## Mapping onto this repo (as recorded 2026-09-17/18)

| Doctrine tenet            | Repo encoding                                            |
| ------------------------- | -------------------------------------------------------- |
| delete the first 90%      | Principle 7 "lead with signal"; check 15 filler gate      |
| physical-world test       | "What tool call does this line produce?" (Principle 7)    |
| behavioral control        | "keep the why, drop the essay" (Pattern 10 boundary)      |
| clear over clever         | jargon glossary in Principle 7 + `--signal` jargon report |
