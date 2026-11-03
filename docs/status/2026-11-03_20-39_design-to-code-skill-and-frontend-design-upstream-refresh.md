# 2026-11-03 20:39 — design-to-code skill shipped, frontend-design refreshed from upstream

> Session type: single-task execution — "Improve frontend-design SKILL!" — run
> under the READ → UNDERSTAND → RESEARCH → REFLECT → Execute → Verify loop.
> Report follows the (a)–(g) buckets; section (f) is the primary input for
> `docs-health` HARVEST.

## TL;DR

| Bucket                              | Count |
| ----------------------------------- | ----- |
| Fully done (verified)               | 7     |
| Partially done                      | 4     |
| Not started                         | 6     |
| Totally fucked up (radical honesty) | 2     |
| Improvements to make                | 6     |
| Ranked next tasks                   | 30    |

**Net state:** the user's ask is delivered in the only two durable forms the
repo's doctrine permits: the third-party `frontend-design` skill was refreshed
to upstream HEAD (it had silently aged ~7 months and was **missing two of
upstream's five calibration clusters**), and the missing engineering layer now
exists as first-party `design-to-code` (skill #34) with 13 same-day-verified
Tailwind v4 claims. Repo gates are green: `scripts/check-skills.sh` **exit 0**
(34 skills, 181 markdown files link-checked), trigger report **STRONG**
(936/1024 chars, 9 markers), fan-out `--check` OK, work committed as
`2b4925f`. No data was lost; no gate was left red.

## Scope line — what this report verified vs. did not

**Verified here (fresh commands/artifacts from this session):**

- `scripts/check-skills.sh` → **exit 0** (quoted, not read from the output
  tail), 34 skills structural-OK, 181 markdown files link-checked — run three
  times (baseline, post-description-fix, post-gloss-fix).
- Installed `~/.agents/skills/frontend-design/SKILL.md` is **byte-identical**
  to `anthropics/skills` HEAD: `diff <(gh api … -H "Accept:
  application/vnd.github.raw") <installed>` exited clean after the re-add.
- Lockfile entry refreshed: `updatedAt: 2026-11-03T19:08:54Z`,
  `pluginName: example-skills` added.
- 13/13 Tailwind v4 claims verified against the primary source
  (`tailwindlabs/tailwindcss.com` `src/docs/*.mdx`, fetched 2026-11-03, docs
  site reports v4.3) — each grep'd in the downloaded MDX, encoded in
  `design-to-code/references/tailwind-v4-gotchas.md` with the canonical
  verification-status table.
- `bash scripts/link-skills-to-agents.sh --check` → OK;
  `~/.agents/skills/design-to-code -> ../../projects/SKILLS/design-to-code`
  exists (relative symlink, per §5.10).
- Trigger report: `design-to-code  markers=9 STRONG desc=936` (limit 1024);
  signal report exit 0 with only advisory flags (both jargon terms glossed).
- Commits: `90e7fa2` (daemon, 2 skill files, pre-fix SKILL.md) and `2b4925f`
  (detailed, 5 files: AGENTS/CHANGELOG/FEATURES/README/SKILL.md);
  `git status --short` clean after.
- Cleanup verified: `trash` 0.26.9.29 present at
  `/run/current-system/sw/bin/trash`; `/tmp/frontend-design-backup-pre-update`
  no longer exists.
- AGENTS.md size re-measured: **42,857 B** (was 41,403 B at T70 filing — see
  (d)).

**NOT verified here, and why:**

- **Live Crush discovery of `design-to-code`** — skill discovery is a
  session-start snapshot (§5.10); proving it requires a fresh-session probe
  (`crush run` asking for `crush_info`, the mechanism proven for MWG on
  2026-10-30). Not run — the session that authored a skill cannot observe its
  own discovery.
- **Any real-work trigger** of `design-to-code` or the refreshed
  `frontend-design` — none exists yet; both are 🆕 by the repo's definition.
- **No behavioral eval** (with/without subagent harness) was run — shipped
  with structural + trigger gates only. This is the known gap vs. the
  `website-launch`/`go-release` eval precedent; see (f) item 2.
- **Exact Trash directory the backup landed in** — `trash` succeeded (source
  path gone, tool present), but I did not chase which trash root it used.
  Immaterial; the backup's content is obsolete upstream material.
- **Aggregation repo (`~/.agents/skills`, → `agent-skills.git`) commit state**
  — left uncommitted by design (third-party update diff + untracked symlink);
  committing that layer is the owner's update ritual (§5.10, 2026-09-13
  precedent).

## Context: the strategy decision, and why

The ask was "Improve frontend-design SKILL!". `frontend-design` is
third-party (`anthropics/skills`, lockfile-tracked, real directory in
`~/.agents/skills/`), so per AGENTS §5.10 it must never be hand-edited —
`skills update -g` would clobber any local change. Three legitimate moves
existed: refresh from upstream, upstream PR, or first-party companion. This
session executed the first and third; the second is filed in (f). The
companion respects the T62 "install, don't wrap" rule: **nothing from
frontend-design's SKILL.md is restated** — every `design-to-code` section adds
mechanics that file does not contain (token encoding, abstraction ladder, v4
syntax, quality-floor audits).

---

## a) FULLY DONE

1. **Third-party `frontend-design` refreshed to upstream HEAD.**
   `skills update -g` reported a false "up to date"; root-caused (lockfile
   carries only `skillFolderHash`, no ref pin) and fixed via re-add
   (`bun x skills add anthropics/skills@frontend-design -g -y`). Evidence:
   diff-vs-HEAD byte-identical; +2 calibration clusters (SaaS-card kit,
   template-chrome tells), typographic default warnings, line-length
   guidance, richer quality floor. LICENSE.txt intact (10,174 B). Lesson
   recorded in AGENTS §5.10.

2. **New skill `design-to-code` (skill #34) authored and committed.**
   `SKILL.md` (117 lines): inspect-the-design-system-first, `@theme` vs
   `:root` token encoding with promote criteria, the 6-rung utility-first
   abstraction ladder, quality-floor audits (screenshot when available,
   DOM-audit fallback, dynamic-class-concatenation scan, hover/touch rule).
   Evidence: `2b4925f`, check-skills exit 0.

3. **`references/tailwind-v4-gotchas.md` with 13 same-day-verified claims.**
   All fetched from the official docs MDX (not from the Lombiq skill, not
   from memory): `@import` replaces `@tailwind`; important-suffix
   `bg-red-500!`; `bg-(--var)` parens; stacked variants left-to-right;
   `hover:` → `@media (hover: hover)`; `@theme` top-level + utility
   generation; `@utility` variant support; `@source`; `@reference` for
   Vue/Svelte/CSS-modules; plain-text class detection; `@layer components`;
   browser floor Chrome 111 / Safari 16.4 / Firefox 128; `prefix(tw)`.
   Evidence: per-claim table in the reference, each row citing the MDX file.

4. **Full new-skill wiring (SESSION-START step 6 checklist).** README row
   (Architecture & Design) + status paragraph Eight→Nine 🆕; FEATURES.md row
   (check 14 coverage gate); CHANGELOG entry; AGENTS §5.5 inter-skill graph
   entry; fan-out symlink. Evidence: `2b4925f`, check-skills exit 0
   including check 14.

5. **Gate-caught defects fixed before ship.** The quality gate failed my
   first description ("description opening has no trigger context") —
   rewritten trigger-first, 936/1024 chars, STRONG. The `--signal` advisory
   caught my `split brain` gloss deviating from the canonical house glossary
   wording — aligned verbatim. Evidence: check-skills FAIL line in
   `/tmp/check-final.txt`, then exit 0 in `/tmp/check-final2.txt`.

6. **Two durable AGENTS.md lessons recorded at discovery time** (§5.10:
   update false-green + re-add refresh + verify-by-API-diff; §5.5:
   design-to-code layering and its one-way disambiguation rationale).
   Evidence: `2b4925f` diff.

7. **Session-start checklist executed before task work** (feedback/new
   empty, newest status TL;DR read, TODO_LIST read, baseline check-skills
   exit 0 quoted). Roadmap grep for frontend/design: no hits, no
   reconciliation needed. Evidence: baseline run at session start.

## b) PARTIALLY DONE

1. **`design-to-code` is structurally valid but behaviorally unevidenced.**
   What works: structural checks, trigger report STRONG, references resolve.
   What remains: behavioral eval (with/without) + a first real triggered run
   (the two-stage aging rule, T34 g2, 🆕→🟡→🟢). Blocker: none — time only.
   Effort: M.
   → RESOLVED m3 `4558d75`/`a060bce`: eval iteration-1 ran (with-skill 13/13
   vs baseline 12/13; discriminating assertion = static-class-names
   doctrine; baseline safelisted around runtime concatenation, leaving the
   trap) + gotchas gained 2 claims the eval surfaced. Evidence:
   `design-to-code/evals/`. 🟢 still requires a genuine user-triggered run.

2. **Live discovery unproven.** Symlink + fan-out `--check` OK, but no fresh
   session has loaded it. Blocker: session-snapshot limitation (can't
   observe from inside). Effort: S — one `crush run` probe.
   → RESOLVED m3 `4f83906`: probe PASS — fresh `crush run` lists
   `design-to-code` (61 skills).

3. **frontend-design "improvement" is partial by construction.** Its
   *content* is now current, but the engineering bridge lives only in our
   first-party companion — upstream users don't get it, and on a machine
   without `design-to-code` installed, frontend-design still produces plans
   with no token-encoding guidance. Blocker: upstream PR not filed. Effort:
   M–L (verify-before-filing + github-voice + jj loop).

4. **Aggregation layer (`agent-skills.git`) not committed.** Working tree
   there carries the frontend-design update diff + untracked
   `design-to-code` symlink. Cosmetic per §5.10; blocking nothing. Effort: S.

## c) NOT STARTED

1. **Upstream PR to `anthropics/skills`** proposing the engineering-bridge
   paragraphs (token encoding + a short verified-gotcha pointer) for
   frontend-design. Not started: needs verify-before-filing gate + github-voice
   + jj-fork-pr-workflow; priority High (benefits every consumer of the most
   popular frontend skill).
2. **Upstream issue to the skills CLI** (`skills update` false green:
   hash-only comparison, no ref pin). Not started: verify-before-filing
   requires reproducing against the CLI source first. Priority Medium.
3. **Behavioral eval for design-to-code** (2–3 prompts, with/without,
   `evals/iteration-1/` + `grading.json` on disk). Not started: skill shipped
   this session; eval is the documented next stage. Priority High.
   → RESOLVED m3 `4558d75` (see (b)1).
4. **Fresh-session discovery probe.** Not started: same-session limitation.
   Priority High (cheap, closes (b)2).
   → RESOLVED m3 `4f83906` (see (b)2).
5. **Drift-check cadence for the 13 verified claims.** No script exists;
   claims are dated 2026-11-03 in the reference table. Not started: needs an
   owner decision on cadence (see question 3). Priority Medium.
6. **Carried open TODOs** — untouched this session by design (user-scoped
   task): T30, T33, T57, T60, T62, T63, T67, T69, T70 (open) and
   T58/T59/T68 (blocked). See TODO_LIST.md — the authoritative state.

## d) TOTALLY FUCKED UP

Nothing destroyed, nothing broken, no gate left red. Two honest entries that
fall short of fucked-up but belong here under radical honesty:

1. **I made the AGENTS.md size advisory worse and shipped it.** AGENTS.md is
   now **42,857 B vs the 30 KB threshold** (`scripts/check-agents-md.sh`,
   filed as T70 at 41,403 B). This session added ~1.45 KB (§5.5 design-to-code
   paragraph + §5.10 false-green lesson) without offsetting trims, even
   though T70 ("trim, or record a justified threshold") was sitting open in
   TODO_LIST.md at session start — I read it and didn't connect it to my own
   edits. Severity: no blockage; a WARN nobody acts on, now 4.7% worse.
   Root cause: memory-updates protocol says "no threshold, write it
   immediately" while T70 says the file is over budget — the two rules
   collided and I followed the one that felt urgent. Mitigation: T70 trim
   pass must absorb this session's additions; (f) item 9.

2. **The canonical version of the skill's first hour is split across two
   commits, one of them daemon noise.** `90e7fa2` (heuristic "auto-commit 1
   changed file(s)") captured the SKILL.md **before** the description fix and
   gloss alignment; `2b4925f` carries the fixes. Anyone reading `90e7fa2`
   sees a description that fails the repo's own gate. Severity: none at HEAD
   (tree is correct); costs history readability. Root cause: §5.12 — the
   daemon commits everything dirty on a timer; path-scoped discipline only
   holds until it wakes. Mitigation: none needed at HEAD; future sessions
   should author + gate + commit in one window before the daemon wakes
   (window observed this session: ~15 minutes).

Near-misses that were caught and are NOT Fucked up, but prove the gates earn
their keep: my description violated §3.1's trigger-first rule as first
written (check-skills FAILed it), and my gloss wasn't canonical (--signal
flagged it). Both fixed pre-commit.

## e) WHAT WE SHOULD IMPROVE

1. **Run the quality gates immediately after authoring, not after wiring.**
   The description fix forced a re-edit cycle with the wiring already in
   place; the trigger/signal advisories were first run at the very end.
   Fix: after writing SKILL.md, run check-skills + --signal + --triggers
   before touching README/FEATURES/CHANGELOG. Cost of the current order: one
   avoidable re-verification round.
2. **Apply the guide's own quick-test table to my own description before
   writing.** I had read how-to-write-skills.md §1 minutes earlier and still
   wrote a what-it-is opener. Fix: the description test table (does it start
   with the user's task? could it be a README sentence?) should be run
   explicitly, not "kept in mind".
3. **Diff-vs-HEAD before any `skills update` invocation.** The update's
   "up to date" cost one investigation cycle; the diff took one command.
   Now encoded in §5.10; make it the reflex (the diff is the source of
   truth, the CLI summary is a claim).
4. **AGENTS.md additions should come with size accounting.** Any session that
   adds to AGENTS.md while T70 is open should either trim an equivalent mass
   or cite why not. Fix: note it in T70's execution: "trim pass must absorb
   2026-11-03 additions".
5. **Verify cleanup outcomes, not cleanup attempts.** My `trash … ||
   mv … ; echo "backup cleaned"` printed success unconditionally; only a
   later explicit check (tmp gone, trash present) made it a fact. Fix: the
   "quote exit codes, not output tails" rule applies to cleanup commands
   too.
6. **Landing-spot analysis deserves a documented decision record.** The
   fork-vs-companion-vs-upstream reasoning lives in this report and the
   commit message; a session with `docs/decisions/` open questions might
   have warranted a short decision entry. Fix: if a second third-party
   skill ever needs this treatment, promote the pattern to
   `how-to-write-skills.md` (it generalizes: refresh → companion → upstream,
   in that order).

## f) 30 things to get done next (ranked; primary input for HARVEST)

> Per the skill: up to 50 was requested — a larger N is a brainstorm, not a
> commitment list. Items 1–10 are new from this session; 11–20 are carried
> open TODOs (evidence in TODO_LIST.md); 21–30 are ROADMAP fuel. HARVEST:
> apply extra routing rigor to 21–30, and skip any item already carrying a
> resolution marker.

| #   | Task                                                                                                                                          | Impact | Effort | Category      | Source |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------ | ------------- | ------ |
| 1   | Fresh-session discovery probe: `crush run` asking for `crush_info`, confirm `design-to-code` PRESENT (mechanism proven 2026-10-30) — m3 `4f83906` | High   | S      | Quality       | NEW    |
| 2   | Behavioral eval for design-to-code: 2–3 real prompts, with/without, persist `evals/iteration-1/` + `grading.json` (eval not done until on disk) — m3 `4558d75`/`a060bce` | High   | M      | Quality       | NEW    |
| 3   | First real triggered design-to-code run on a live UI task; document it; age 🆕→🟡 (two-stage rule) — partial m3 `4f83906` (natural trigger observed in a probe session; 🟢 needs genuine user work) | High   | M      | Quality       | NEW    |
| 4   | Upstream issue to the skills CLI: `update` false green (hash-only lockfile, no ref pin) — verify-before-filing gate first — Won't implement m3 `71b4afb` (gate FAILED the premise: current `vercel-labs/skills` source compares live tree SHAs + supports ref pinning; a live `skills check -g` correctly flags stale skills. 2026-11-03 mechanism claim corrected in AGENTS §5.10; re-evaluate only if it recurs on the current CLI) | High   | S–M    | Bug (upstream)| NEW    |
| 5   | Upstream PR to anthropics/skills: propose token-encoding + gotcha-pointer paragraphs for frontend-design (jj fork loop + github-voice)         | High   | M–L    | Feature (upstream) | NEW |
| 6   | Commit the aggregation repo wave: frontend-design refresh diff + design-to-code symlink (owner ritual per §5.10) — m3 `3e05e02` (agent-skills repo, `docs-health-verify-legs` branch; 65 files incl. the hyperframes upstream restructure) | Medium | S      | Cleanup       | NEW    |
| 7   | Re-verify the 13 gotcha claims after the next Tailwind minor release; bump the verification table date                                        | Medium | S      | Documentation | NEW    |
| 8   | Boundary test: one real web task where design-to-code AND modern-web-guidance both plausibly trigger; record the routing (pairs with T63) — partial m3 `4f83906` (probe session loaded both; clean complement, no collision — `evals/iteration-1/trigger-probe.md`; a live-work case still open) | High   | M      | Quality       | NEW    |
| 9   | T70 execution: AGENTS.md trim pass — must absorb this session's +1.45 KB (42,857 B vs 30 KB threshold)                                        | Medium | M      | Cleanup       | carried|
| 10  | T62: land the "install, don't wrap" rule in how-to-write-skills.md — design-to-code §5.5 entry is now a worked example to cite                | High   | M      | Documentation | carried|
| 11  | T63: first real triggered MWG web task (modal/`<dialog>` case end-to-end)                                                                     | High   | M      | Quality       | carried|
| 12  | T67: markdown-table pipe safety — encode never-a-raw-pipe-in-inline-code + `git diff -w` after formatter runs                                 | High   | S      | Quality       | carried|
| 13  | DOM-audit fallback in design-to-code deserves a concrete script (grep-based interactive-element/focus/reduced-motion checker, naming-smells.sh pattern) | Medium | S–M | Feature       | NEW    |
| 14  | Worked example reference for design-to-code: one v3→v4 before/after (important-suffix, arbitrary vars, dynamic-class fix)                      | Medium | S      | Documentation | NEW    |
| 15  | T60: MWG uninstall proof (snapshot, uninstall, verify, restore)                                                                               | Low    | S      | Quality       | carried|
| 16  | Fleet-wide third-party freshness audit: diff all 15 lockfile skills vs upstream HEAD (gh api loop); report stale ones (frontend-design was 7 months stale — others may be too) | High | M | Quality | NEW |
| 17  | Decide design-to-code's README section: keep under "Architecture & Design" or open a "Frontend & Web" domain section (see question 3)          | Low    | S      | Documentation | NEW    |
| 18  | Audit repo skills for Tailwind-mechanics restatements (website-launch, html-report-kit) that would violate the install-don't-wrap rule         | Medium | S      | Cleanup       | NEW    |
| 19   | Add design-to-code to docs/external-dependencies.md (references public tailwindcss.com docs; table currently has 0 mention) — m3 `4f83906` | Low    | S      | Documentation | NEW    |
| 20   | After items 2–3: update FEATURES note + README paragraph to 🆕 (eval'd) status — m3 `4f83906`/`a060bce` (README marker stays 🆕 per gate convention; aging nuance lives in prose) | Low    | S      | Documentation | NEW    |
| 21  | T30: flip README status 🆕→🟢 after the first real upstream PR kept green via the jj sync loop                                                | Low    | S      | Documentation | carried|
| 22  | T33: site-repo follow-ups (emeet composition from MP4, og:image, CI deploy workflow)                                                          | Medium | M+     | Feature       | carried|
| 23  | T57: extract templ-components Go SSG into canonical private `website-template` repo                                                           | High   | M      | Feature       | carried|
| 24  | T58 (blocked by T57): `websitelaunch` CLI — doctor/init/check                                                                                 | Medium | M      | Feature       | carried|
| 25  | T59 (blocked by T58): website-launch skill slim + evals re-run                                                                                | Medium | S–M    | Cleanup       | carried|
| 26  | T68 (blocked): agent-skills branch policy decision (194-file MWG commit on `docs-health-verify-legs`)                                          | High   | S      | Decision      | carried|
| 27  | T69: triage standing advisory findings (art-dupl 6, jscpd 3, file-size-check 4) into deliberate non-fixes in AGENTS §5.11                      | Medium | S      | Cleanup       | carried|
| 28  | ROADMAP: design-memory convention — frontend-design hints at jotting "what you've tried"; decide if a tiny shared design-notes file is worth it | Low    | S      | Idea          | NEW    |
| 29  | ROADMAP: generalize the refresh→companion→upstream pattern into how-to-write-skills.md if a second third-party skill needs it                 | Low    | S      | Documentation | NEW    |
| 30  | ROADMAP: consider a `tailwind` docs-snapshot skill (Lombiq-style local sync + staleness gate) only if design-to-code's static claims prove insufficient (see question 2) | Low | M | Idea | NEW |

## g) Top 3 questions I cannot figure out myself

1. **First-party only, or also upstream?** Should the design→code bridge
   (token encoding + verified v4 gotchas) be PR'd into `anthropics/skills`'
   frontend-design — it would benefit every consumer of the most popular
   frontend skill, but costs the full verify-before-filing + github-voice +
   jj-fork-pr-workflow loop and forks our maintenance attention upstream —
   or do you deliberately keep this layer first-party? I tried to infer the
   answer from §5.5/T62 doctrine and this repo's upstream-PR history; both
   support either choice, so it's a preference call.
2. **Freshness policy for the 13 verified claims.** Manual periodic
   re-verification (table dated 2026-11-03) vs. a Lombiq-style local
   docs-snapshot sync script with a staleness gate inside design-to-code.
   I couldn't decide because the right answer depends on how often you
   actually build Tailwind UIs and whether you want this skill to carry a
   sync script at all (the repo so far ships static, dated verification
   tables — but it has never had a frontend framework that moves this fast).
3. **Frontend domain placement.** design-to-code currently sits under README
   "Architecture & Design". As frontend coverage grows (it + third-party
   frontend-design + modern-web-guidance + hyperframes suite), do you want a
   dedicated "Frontend & Web" section in the README/FEATURES, or keep the
   current grouping? I checked the README's section history (it grew by
   domain as counts grew) but the threshold for a new section is your call.

---

**Handoff:** section (f) is the primary input for `docs-health` HARVEST — it
belongs in `TODO_LIST.md`/`ROADMAP.md`, not entombed here (canonical rule:
docs-health → "When to run HARVEST"; do not restate it). This report is a
point-in-time snapshot; bring it current later via docs-health → ANNOTATE
(inline, non-destructive), never rewrite.
