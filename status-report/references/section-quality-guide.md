# Section Quality Guide

> What each section of the status report should contain, and common pitfalls.
> Load this when writing a status report to make each section maximally useful.

## Contents

1. [a) FULLY DONE](#a-fully-done)
2. [b) PARTIALLY DONE](#b-partially-done)
3. [c) NOT STARTED](#c-not-started)
4. [d) TOTALLY FUCKED UP](#d-totally-fucked-up)
5. [e) WHAT WE SHOULD IMPROVE](#e-what-we-should-improve)
6. [f) Top N next tasks](#f-top-n-next-tasks)
7. [g) Top question](#g-top-question)
8. [Common pitfalls](#common-pitfalls)

---

## a) FULLY DONE

List work that is **verifiably complete** — committed, tested, working.

**Each item should include:**
- What was done (1 sentence, concrete)
- Evidence: commit hash, test status, or "deployed at URL"
- Scope: what files/modules were affected

**Pitfall:** Listing "done" items that are actually partially done. If tests
fail or the build is broken, it goes in (b) or (d), not here.

---

## b) PARTIALLY DONE

Work that is in progress with known gaps.

**Each item should include:**
- What works now (with evidence)
- What remains open (specific, not vague)
- Blocker: what is preventing completion (if any)
- Estimated effort to finish (S/M/L)

**Pitfall:** Vague descriptions like "mostly done." State exactly what is missing.

---

## c) NOT STARTED

Work that is planned but no code written.

**Each item should include:**
- What is planned
- Why it hasn't started (blocked? deprioritized? waiting on decision?)
- Priority: is this still wanted?

**Pitfall:** This section reveals scope — if it's empty, you forgot something.
If it's >50% of the total, the plan is unrealistic.

---

## d) TOTALLY FUCKED UP

Things that are broken, wrong, or actively harmful.

**This is the most valuable section.** It requires radical honesty.

**Each item should include:**
- What is broken (be specific — which test, which endpoint, which module)
- Severity: does this block development? block users? lose data?
- Root cause (if known) or "unknown — needs investigation"
- Mitigation: is there a workaround?

**Pitfall:** Being too gentle. "Some edge cases need attention" is useless.
Name the exact failing scenario.

---

## e) WHAT WE SHOULD IMPROVE

Process and design improvements — not bugs (those go in (d)).

**Each item should include:**
- What pattern/practice is suboptimal
- Impact: how much time/pain it causes
- Suggested fix (concrete, not "improve the architecture")

**Pitfall:** This section is the harvest ground for skills and tooling. If the
same improvement appears in 2+ reports, it should become a skill (see the
feedback loop in AGENTS.md §11).

---

## f) Top N next tasks

Forward-looking work items, ranked by impact.

**This section feeds `docs-health` HARVEST.** After the report is written,
HARVEST pulls these into TODO_LIST.md and ROADMAP.md.

**Each item should include:**
- Task (1 sentence, actionable)
- Impact: Critical / High / Medium / Low
- Effort: S (<30min) / M (30min-2hr) / L (>2hr)
- Category: Bug / Feature / Quality / Cleanup / Documentation

**Pitfall:** Items that are vague ("improve testing"). These are not actionable
and HARVEST will route them to ROADMAP, not TODO_LIST. Make them specific:
"add integration tests for the payment webhook handler."

---

## g) Top question

The single most important question you cannot answer yourself.

**Criteria for a good question:**
- You tried to answer it and could not (state what you tried)
- The answer unblocks significant work
- The user (or domain expert) is the only one who can answer it

**Pitfall:** Asking a question you could answer by reading the code or docs
more carefully. If grep or `view` can answer it, don't ask the user.

---

## Common pitfalls

1. **"All good" reports** — If sections (c) and (d) are empty, you are not
   looking hard enough. Every project has fucked-up things and unstarted work.

2. **Inflated "done" lists** — Each "done" item must cite evidence (commit
   hash, passing test, working URL). No evidence = it goes in (b).

3. **Generic improvement suggestions** — "We should test more" is not
   actionable. "We should add E2E tests for the registration flow" is.

4. **Missing the handoff** — Section (f) is the harvest ground. If you write
   25 tasks and don't mention HARVEST, they die in the timestamped file.

5. **No question** — If you have zero questions, you either know everything
   (unlikely) or you didn't think hard enough about what's blocking you.
