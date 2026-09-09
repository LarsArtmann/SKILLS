# Session Start — Mandatory Checklist

> Execute this checklist at the start of EVERY session in this repo, before
> any task work. Memory of "I know the rules" is not execution: on
> 2026-09-08 two mandatory steps were skipped and only luck made it moot
> (`docs/status/2026-09-08_20-39_*` d6). Run the steps top to bottom; each
> takes under a minute.

- [ ] **1. Scan `docs/feedback/new/`** (AGENTS.md §11). Non-empty? Read every
      file relevant to today's task — feedback is a lead, not a source, but
      skipping it repeats documented mistakes.
- [ ] **2. Open the newest `docs/status/` report** and read its TL;DR plus
      any standing context (open defects, unresolved questions) that touches
      today's task. Status reports are point-in-time — re-verify claims
      before acting on them.
- [ ] **3. Read `TODO_LIST.md`** — the verified-open work items. Pick from
      P0 down unless the user directs otherwise. Also grep `ROADMAP.md` for
      anything today's task touches (a pre-existing idea should be marked,
      not duplicated).
- [ ] **4. Read AGENTS.md §8** ("When Improving This Repo") and §9 ("What
      NOT to Do") before editing anything.
- [ ] **5. Run `scripts/check-skills.sh`** for the current structural state
      (skill count, thin skills, warnings). `--triggers` for the advisory
      trigger-density report if today's work touches descriptions.
      **Quote the exit status (`echo $?`), never just the output tail** —
      on 2026-09-09 the script exited 1 silently (zero-count grep aborts
      under pipefail) while a session read its output as green. A
      green-looking run with a non-zero exit is a FAIL.
- [ ] **6.** If today's work creates a new skill, follow the new-skill
      wiring checklist in `how-to-write-skills.md` (README row + counts,
      two-way description disambiguation, AGENTS §5.5 graph entry, ROADMAP
      reconciliation, `link-skills-to-agents.sh`, structural + trigger
      checks).

Then start the task. A TODO row (or an old audit) is a claim, not a state:
`find <skill-dir> -type f` + `wc -l` before trusting its framing. At session
end: run `scripts/check-skills.sh` again, leave `git status` clean (the
auto-commit daemon handles commits), list `git worktree`s and remove stale
ones, and — before trashing any scratch — commit as fixtures or explicitly
disclaim every artifact a report cites as evidence (the 2026-09-08 trashed-
ground-truth incident). Write a status report to `docs/status/` for any
multi-step session.
