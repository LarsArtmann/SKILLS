# Status Report — docs-health Full Audit Session (interrupted mid-ANNOTATE, evidence phase complete)

**Date:** 2026-09-16 18:47 (Wednesday, CEST)
**Session scope:** User instruction: view ALL `**/2026-0*` files, execute the
docs-health skill PROPERLY (AUDIT = BUILD + HARVEST + VERIFY + ANNOTATE), make
TODO_LIST / CHANGELOG / AGENTS / README / ROADMAP / FEATURES superb, archive
fully-done updated files. Third session today (after 18-07/18-17 wise-go
lessons); the 15:04 session (`0d1aca6`) fixed annotate-tooling bugs (code-span
tildes, checker format) that THIS session would have hit.
**Format:** markdown at `docs/status/` per explicit user instruction —
**7th recurrence** of the HTML-default override (still unencoded; see 18-17 g-pending).

---

## a) FULLY DONE

~~1. **docs-health skill loaded before acting** — SKILL.md plus~~ v: session-log claim — corroborated by the executed plan in section f (carried out by the 2026-09-18 pass)
   `references/resolving-items.md` and `references/harvest-guide.md` (the two
   governing references for this run's modes).
~~2. **SESSION-START.md executed** — feedback/new empty; newest report (18-17)~~ v: session-log claim — corroborated by gates-green records in the 2026-09-18 pass (file 15-05)
   read in full; TODO_LIST read (T30/T33/T34/T35 open); AGENTS §8/§9 in
   context; `check-skills.sh` run with **exit status quoted: 0** (30 skills,
   149 md files, 0 thin).
~~3. **ALL 94 `2026-0*` files viewed** (verified counts, not estimates:~~ v: session-log claim — the corpus was fully classified and subsequently annotated/archived by the 2026-09-18 pass (CHANGELOG 2026-09-18)
   `find` → 94 total = docs/status 71 + docs/feedback 22 + docs/planning 1;
   26 already carry `~~` markers, 68 are zero-marker). September reports read
   in full; May–August read via targeted extraction (TL;DR + every numbered
   row + next/questions sections); the two `.html` snapshots inspected
   (tag-stripped heads only — see d5).
~~4. **Living docs read in full** — TODO_LIST (43 lines, 4 open items),~~ v: session-log claim — corroborated by the 2026-09-18 living-docs rebuild (CHANGELOG 2026-09-18)
   FEATURES (132), ROADMAP (211), README (153), CHANGELOG head (current
   Unreleased entries). AGENTS.md was already in context.
~~5. **Annotation-marker map produced** — per-file line counts + strikethrough~~ s: superseded by `2026-09-18_15-05_docs-health-full-audit-corpus-annotated-archived.md` — the pass that consumed this map
   counts for all 94 files (the work plan: which files need ANNOTATE, which
   are SKIP, which are ARCHIVE candidates).
~~6. **Claim verification pass (12 checks, executed)** — caught four real states~~ v: verified — the findings were real: check 14 hardening shipped 2026-09-24 (`6fa9a3c`), naming-review desc rewritten (T38), appendix-only trap closed (CHANGELOG 2026-09-18)
   the reports' next-lists depend on:
   - `github-voice/SKILL.md:26` **still says "every comment across all
     repos"** — the 10-55 report's f1 fix was NEVER applied. Live overclaim,
     must become a TODO item (honesty bug in a shipped skill).
   - `check-skills.sh` check 14 exists (`5479784`) but is the any-mention
     grep — 18-17's f1/f2 hardening still open.
   - **03-58 carries an appendix with ZERO inline strikethroughs** — the
     skill's #1 failure mode (appendix-only), in the very file T35 called
     "already annotated". Must be re-done inline.
   - `link-skills-to-agents.sh` has **no `--selftest`**; `--check` is **not
     wired into check-skills.sh** (14-29 f4/f5 open). `buildflow/SKILL.md`
     has **no Verification-status table** (12-25 f2 open).
     `code-quality-scan` → buildflow back-reference: present (12-25 f1 done).
     SESSION-START hardening steps: present (20-08 f15–f17 done). Pitfall #33
     header-order: documented (03-58 f11/f28 done, `46d73b0`).
~~7. **Evidence hashes collected** for the closed-item citations — dated git~~ v: session-log claim — the annotations shipped by the 2026-09-18 pass cite these hash trails (CHANGELOG 2026-09-18: ~600 verdicts)
   log 09-08 → 09-16 mapped to sessions; `git log -S` located: header-order
   rewrite `46d73b0`, `hf-env.sh` `a067a44`, FEATURES coverage guard
   `5479784`, go-ecosystem.md deletion `0878e62`, sync guards `0f70bdb`
   (09-13), wave-3 execution `01b8ad3`/`36628f5`, check-skills zero-count
   fix `1ec3244` (09-09), annotate-tooling fix `0d1aca6` (today 15:04).
~~8. **Full execution plan built** (22 files to annotate, ~27 archive~~ s: superseded by `2026-09-18_15-05_docs-health-full-audit-corpus-annotated-archived.md` — the pass that executed this plan
   candidates, HARVEST routing list, living-doc updates) — reflected in the
   session todo list and section (f) below.

## b) PARTIALLY DONE

~~1. **Evidence collection incomplete** — 6 of 10 `git log -S` probes returned~~ v: resolved — the corpus annotations shipped with hash evidence in the 2026-09-18 pass (CHANGELOG 2026-09-18)
   NONE on first strings (demo-compositions, matched-phrases output,
   verification-canon guard, SESSION-START end-rules, evals/iteration-1,
   mechanical-grade). The strings exist in the files; my probe
   strings/paths were wrong. Retrying with corrected patterns is 5 minutes
   and required before annotations citing those changes.
~~2. **`naming-review` description length never measured** — regex failed~~ v: done — measured and rewritten 1008→848 chars (T38, 2026-09-24 wave; CHANGELOG 2026-09-24)
   (printed `pattern?`), not retried. It is the evidence for 11-25/11-36's
   open item (desc at ~1008/1024 cap blocking mutual disambiguation).
~~3. **Archive candidates not yet full-read** — the May–July files were~~ v: done — the 2026-09-18 pass full-read and archived 28 reports (CHANGELOG 2026-09-18)
   extraction-read (every numbered row seen), but final per-item verdicts
   (done/won't-implement/routed) for ~27 archive candidates were not yet
   written. Breadth done, depth pending.
~~4. **Todo list discipline** — one todo said "90 matching files" before the~~ v: incident note, no forward work — verified counts recorded in this report's own text
   verified `find` said 94 (and my early prose said 69 zero-marker; verified
   68). The count corrections are in this report; the todos carried the
   stale number mid-session.

## c) NOT STARTED (the actual mutations — zero files touched)

~~1. **ANNOTATE** — no file has been modified. Planned order: 03-58 (fix the~~ v: done — executed corpus-wide by the 2026-09-18 15-05 pass (~600 inline verdicts; CHANGELOG 2026-09-18)
   appendix-only trap inline), 23-53, 22-42, 23-15 (inline-correct findings
   1–2: header ORDER, not deploy staleness, was the root cause; filewatcher
   was not a healthy baseline), 20-08, 23-26, 02-45/02-55, 09-12 ×3, 11-05,
   14-29, 11-25, 11-36, 12-25, 18-17/18-07, 08-21_12-06, 08-04 ×4, the
   July set (14 files), 06-17 ×2 + 06-28, 05-02 ×2 + 05-03_07-52 + 05-06,
   the two execution logs (23-40, 02-31), and
   `docs/planning/archived/2026-08-02_03-11_*` (rows 1–11 all executed
   08-02/08-11 — annotate for the archived-dir completeness gate).
~~2. **The mandated tool dry-run** — annotate-rows.py must be dry-run against~~ v: done — dry-run-first practiced in the 2026-09-18 pass; the Python tooling has since been consolidated into `annotate.go` (CHANGELOG 2026-10-11)
   03-58's f-table shape BEFORE any mutation (skill rule; the 2026-08-18
   marker-placement bug came from skipping it). Not yet run.
~~3. **ARCHIVE** — `docs/status/archived/` does not exist yet; ~27 candidates~~ v: done — 28 reports moved 2026-09-18 (more since; archived/ completeness gate passes)
   identified, zero moved.
~~4. **T35** (pre-existing TODO): the green-claims appendix sweep for~~ v: done — T35 closed by the 2026-09-18 pass (green-claim appendices; CHANGELOG 2026-09-18)
   pre-fix reports (23-15, 23-40, 23-53, 02-31, 22-42) — identified, not
   written.
~~5. **HARVEST** — TODO_LIST rebuild not started. Confirmed inputs: T30/T33/~~ v: done — TODO_LIST rebuilt 2026-09-18 (T36–T56 added with evidence; CHANGELOG 2026-09-18)
   T34 stay; T35 is substantially this session; NEW items verified-open:
   github-voice "every comment" wording fix (10-55 f1, never applied),
   naming-review description rewrite (11-25), buildflow verification table
   (12-25 f2), link selftest + wiring (14-29 f4/f5), check-14 row-level +
   reverse hardening (18-17 f1/f2), README marker audit (18-17 f4), plus
   18-17 f14 (HARVEST of that report = this pass when executed).
~~6. **VERIFY + living-doc updates** — README status markers, FEATURES notes~~ v: done — README/FEATURES/CHANGELOG/ROADMAP/AGENTS refreshed by the 2026-09-18 pass (CHANGELOG 2026-09-18)
   (e.g. collector-extraction aged 🟢 via ssh-key-monitor 2026-09-10 —
   README prose already reflects it), CHANGELOG entry for this wave,
   ROADMAP additions (18-17 g1–g3 → Open Questions: cross-repo aging
   policy, legend canon, formatter scope).
~~7. **Health report, final gates, session-end duties** — pending (all of c).~~ v: session-log claim — gates verified green in the 2026-09-18 pass; report printed inline (not persisted by design)

## d) TOTALLY FUCKED UP

~~1. **Greedy batch-read truncated 341 lines** — cat'd 7 files in one bash~~ v: incident note — process lesson; no forward work
   call; the output cap ate the middle (11-36 body, 12-25 head, 11-05
   entirely). Re-read cost a round trip. Batching must be sized to the
   30k-char tool-output cap (≈3 reports per call for this corpus).
~~2. **6/10 evidence probes mis-fired** (`git log -S` NONE results) and I~~ v: incident note — resolved by the hash-cited annotations of the 2026-09-18 pass
   moved on to report-writing without retrying — annotations citing those
   changes would have shipped without hash evidence or with wrong ones.
   Same class as the repo's "verify before writing" lessons.
~~3. **Declared "View ALL files" done at 90; verified count is 94** — and the~~ v: incident note, no forward work — corrected counts recorded in this report
   two `.html` snapshots got only a 12-line tag-stripped head view, not a
   content read. Both are LEAVE-ALONE candidates (pure point-in-time
   dashboards), so impact is low, but "all" was rounded up in the todo
   before the recount. Counts now verified: 94 / 26 marked / 68 unmarked.
~~4. **Ordering sin (caught, not yet committed):** evidence gathering ran~~ v: incident note — dry-run-first ordering observed in the 2026-09-18 pass
   BEFORE the mandated annotate-tooling dry-run. No file was touched, so no
   harm — but the skill says dry-run the first spec against a new file
   shape BEFORE mutating, and my plan had it one step too late.
~~5. **Repetition risk flagged for next phase:** this session is the THIRD~~ v: incident note — the marker map was in fact used by the 2026-09-18 pass (its report references the 26 already-marked files)
   docs-health-audit run on this corpus (08-21 21:25 did the identical
   instruction for `2026-08-1*`). The failure mode to avoid: re-annotating
   the 26 already-marked files (double markers) or re-harvesting their
   closed items. The marker map (a3/a5) exists precisely to prevent this —
   use it, don't re-derive from memory.

## e) WHAT WE SHOULD IMPROVE

~~1. **Size read-batches to the output cap** (3 files/call for this corpus);~~ s: superseded by `2026-09-18_15-05_docs-health-full-audit-corpus-annotated-archived.md` — the executing pass; its e-section carries the refined lessons
   or per-file `sed -n` ranges when only sections are needed.
~~2. **Verify probe strings against file content BEFORE `git log -S`** —~~ s: superseded by `2026-09-18_15-05_docs-health-full-audit-corpus-annotated-archived.md` — same lesson class, refined there
   pick the string from the live file, then search history (one grep, one
   -S; halves the NONE-rate).
~~3. **Do the tool dry-run FIRST**, then collect evidence — the skill's~~ v: verified — the rule is canon in docs-health SKILL.md (annotate section: "ALWAYS dry-run the first spec against a new file shape")
   ordering rule exists because of the 08-18 marker-placement bug.
~~4. **Never write a count without its command** — 90-vs-94 and 69-vs-68 were~~ v: verified — canon since: README counts are checker-derived; hand counts get commands (docs-health SKILL.md count rule)
   both my estimates beating my verifications. The verified numbers: 94
   files, 26 with markers, 68 zero-marker (commands in a6/evidence).
~~5. **Fresh-file shape check for the two HTML snapshots** if they are ever~~ s: superseded by `2026-09-18_15-05_docs-health-full-audit-corpus-annotated-archived.md` (snapshots declared LEAVE-ALONE there)
   annotated: strikethrough grammar is markdown-only; HTML needs `<del>`
   (annotation-placement.md covers this — load it if they stop being
   LEAVE-ALONE).

## f) Next tasks (prioritized — resume point for the next session/turn)

| #  | Task                                                                                                                                                                                                                                                                                        | Impact | Effort |
| -- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------ |
~~| 1  | Dry-run `docs-health/assets/annotate-rows.py` against 03-58's `## f)` table (first spec, `--dry-run`, mandatory)                                                                                                                                                                            | High   | XS     |~~ v: done — the 2026-09-18 pass dry-ran before mutating; tooling since consolidated into `annotate.go` (CHANGELOG 2026-10-11)
~~| 2  | Inline-annotate 03-58 f-rows (fix appendix-only trap): closed set f6/f7/f8 (this pass), f11+f28 (`46d73b0`), f12/f13/f14/f17/f24/f33/f44/f45 (`01b8ad3`, `36628f5`, `1ec3244`); T33/T30-routed rows stay untouched                                                                          | High   | M      |~~ v: done — corpus annotated by the 2026-09-18 pass; the appendix-only trap it names is closed (CHANGELOG 2026-09-18)
~~| 3  | Inline-annotate 23-53 f1–f50 (same closed set: f1/f2/f4/f5/f6/f12/f13/f14/f17/f19/f20/f24/f33/f44/f45)                                                                                                                                                                                      | High   | M      |~~ v: annotation pass completed in the 2026-11-10 corpus sweep — 23-53 (2026-09-08_23-53) carries 17 markers; 18-17 and 18-07 annotated this pass
~~| 4  | Inline-correct 23-15 findings 1–2 (root cause = header ORDER; wave-3 evidence) + T35 appendix for its green claim                                                                                                                                                                           | Medium | S      |~~ v: done — the 23-15 header-ORDER correction shipped (CHANGELOG 2026-09-18 names it explicitly)
~~| 5  | Annotate 22-42 f1–f14 (f1 `5479784`, f2/f3 done, f8–f12 → T27/T28/T29/T30/T31/T32 routed; f4/f5/g1 stay open)                                                                                                                                                                               | Medium | S      |~~ v: done — 2026-09-08_22-42 carries inline markers (9); T35 appendix per CHANGELOG 2026-09-18
~~| 6  | Annotate 20-08 f1–f30 + 23-26 f1–f25 (f2/evals DONE `1ec3244`-era, f15–f17 SESSION-START done, f11 graph entry done; f1 selftest, f3/f5 fresh-trigger stay open)                                                                                                                            | Medium | M      |~~ v: done — 20-08 carries 25 markers, 23-26 carries 5 (2026-09-18 pass)
~~| 7  | Annotate 02-45 residuals + 02-55 f1–f30 (f9/f10 done, f1–f3 = this pass, 17–19 carried linter items per 23-26, items 24–27 = T35/T33/T30/T34)                                                                                                                                               | Medium | S      |~~ v: done — 02-45 archived with markers; 02-55 carries 14 markers (2026-09-18 pass)
~~| 8  | Annotate 09-12 ×3 (10-51 f1–f4, 10-55 f1–f25, 11-25 f1–f20; f1-of-10-55 is OPEN — harvest; f1-of-11-25 feedback DONE `0f70bdb`)                                                                                                                                                             | Medium | M      |~~ v: done — 10-51 (5), 10-55 (8), 11-25 (9) all carry inline markers
~~| 9  | Annotate 11-05 (open items → ROADMAP questions already there) + 14-29 f1–f22 (f1 done, f7 README done, f4/f5/f12/f13 open) + 11-25 open item (naming-review cap → TODO)                                                                                                                     | Medium | S      |~~ v: done — 11-05 (2 markers) and 14-29 annotated; 2026-09-13_14-29 archived with markers
~~| 10 | Annotate 11-36 f1–f8 (f2 moot — Lines column removed `5dd75e2`; f5 done; f1/f7 open) + 12-25 f1–f25 (f1 done; f2 open → TODO)                                                                                                                                                               | Medium | S      |~~ v: done — 11-36 (5 markers) and 12-25 (6 markers) annotated
~~| 11 | Annotate 18-17 f1–f18 + 18-07 f1–f3 (f14 = the HARVEST in #25; most stay open — 1 day old)                                                                                                                                                                                                  | Low    | S      |~~ v: annotation pass completed in the 2026-11-10 corpus sweep — both files annotated and archived this pass
~~| 12 | Annotate 08-21_12-06 b1–b5 (verify b1 Phase-6 bar + b2 retrofit checklist against current skill; b3 CHANGELOG 08-21 entry; b5 README row done)                                                                                                                                              | Medium | S      |~~ v: done — 2026-08-21_12-06 carries 19 markers (2026-09-18 pass)
~~| 13 | Annotate 08-04 ×4 (00-35 f1–f7: f2 `check-agents-md.sh` DONE, f3 global pointer, f4 worst offenders — external; 01-27 a/b; 01-47 b; 04-16 a/b tables)                                                                                                                                       | Medium | M      |~~ v: done — all four 2026-08-04 files archived with markers (2026-09-18 pass)
~~| 14 | Annotate the July set (07-11 B-items, 07-14 a/b, 07-17 B1/B2, 07-19 b1–b3, 07-20 ×2 f1–f8, 07-21 ×4, 07-23 ×3, 07-25 f1–f2, 07-26 ×2) — most closed by 07-26/08-04 waves                                                                                                                    | Medium | M      |~~ v: done — the entire July set archived with markers (2026-09-18 pass, 28 files)
~~| 15 | Annotate 06-17_20-02 (4 recs done via html-report-kit), 06-17_23-22 (findings table superseded by 06-28 audit), 06-28 items 1–8 (routed)                                                                                                                                                    | Low    | S      |~~ v: done — 06-17 ×2 and 06-28 archived with markers
~~| 16 | Annotate 05-02 ×2, 05-03_07-52, 05-06 (items long-closed or routed; how-to-nix → Won't implement)                                                                                                                                                                                           | Low    | S      |~~ v: done — May files (05-02 ×2, 05-03_07-52, 05-06) archived with markers
~~| 17 | Annotate planning/archived/2026-08-02_03-11 rows 1–11 (rename `08-02`, desc rewrites `08-11`) — archived-dir completeness gate                                                                                                                                                              | Low    | S      |~~ v: done — the planning file carries inline markers (archived-dir completeness gate clean)
~~| 18 | Retry the 6 failed `git log -S` probes with file-derived strings (b1)                                                                                                                                                                                                                       | Medium | XS     |~~ v: done — the 2026-09-18 pass's annotations cite hash evidence (b1's corrected probes)
~~| 19 | Measure naming-review description length (b2)                                                                                                                                                                                                                                               | Low    | XS     |~~ done at `2b81484`
~~| 20 | T35 sweep: append green-claim appendices to 23-15/23-40/23-53/02-31/22-42 (check-skills pre-fix window)                                                                                                                                                                                     | Medium | S      |~~ v: done — T35 closed 2026-09-18 (appendices on the pre-fix reports; CHANGELOG 2026-09-18)
~~| 21 | ARCHIVE: create `docs/status/archived/`, `git mv` the ~27 fully-resolved files (both 05-02s, 05-03_07-52, 05-06, 06-17 ×2 md, 06-28, 07-11, 07-14, 07-17, 07-19, 07-20 ×2, 07-21 ×4, 07-23 ×3, 07-25, 07-26 ×2, 08-04 ×4, 08-21_12-06?, 23-40, 02-31) — each only AFTER every item resolved | High   | M      |~~ v: done — 28 reports moved 2026-09-18; directory has grown since; completeness gate passes
| 22 | Completeness gate: `grep -rLn '~~' docs/status/archived/` prints NOTHING v: verified — the gate passes (zero marker-less files under docs/status/archived/)                                                                                                                                                                                                  | High   | XS     |
~~| 23 | HARVEST: rebuild TODO_LIST.md — keep T30/T33/T34; T35 closes with #20; add github-voice "every comment" fix, naming-review desc rewrite, buildflow verification table, link selftest+wiring, check-14 hardening, README marker audit; every row with evidence                               | High   | M      |~~ v: done — TODO_LIST rebuilt 2026-09-18 with T36–T56 (CHANGELOG 2026-09-18); executed 2026-09-24
~~| 24 | VERIFY: living docs vs repo (README markers ↔ FEATURES ↔ check-skills output; no PLANNED-vs-shipped contradictions; links resolve)                                                                                                                                                          | High   | S      |~~ v: done — README/FEATURES parity verified (parity gate 2026-09-24 `6fa9a3c`)
~~| 25 | Living-doc updates: CHANGELOG wave entry; ROADMAP += 18-17 g1–g3 (cross-repo aging policy, legend canon, formatter scope); FEATURES notes refresh; AGENTS §5 archived-dir convention if created                                                                                             | High   | S      |~~ v: done — CHANGELOG 2026-09-18 wave entry; ROADMAP Open Questions added (verified present)
~~| 26 | Health report inline (Accuracy + Fitness, visible math) + final gates (`check-skills.sh` exit quoted, `link-skills-to-agents.sh --check`, git status, worktree list)                                                                                                                        | High   | S      |~~ v: session-log claim — gates verified green in the 2026-09-18 pass (CHANGELOG "Gates" bullets); report printed inline

Items beyond this are already routed (T33/T34/T30 unchanged; 18-17's own f-list rides along in #11).

## g) QUESTIONS I cannot figure out myself

~~1. **Does "routed" count as resolved for ARCHIVE eligibility?** Several~~ v: answered by practice — routed counts as resolved; the 2026-09-18 pass archived 28 reports on that basis (CHANGELOG 2026-09-18)
   May–July candidates have open QUESTIONS whose content now lives in
   ROADMAP "Open Questions" (how-to-write-skills location, link enforcement
   level, backup retention, status-report format). My plan treats
   "question now homed in ROADMAP" as resolved-at-report-level (the report's
   job was surfacing; routing closed it) — that makes ~10 more files
   archivable. Confirm, or should files with any still-live question stay?
~~2. **Evidence granularity for old files:** May–July items closed by long~~ v: answered by practice — wave-level citations used across the archived corpus (e.g. the 07-26 files' "done — closed by the 22-21 follow-up")
   waves — cite session-date + report (fast, ~27 files this session) or
   per-item git hashes (slower, ~2–3× the annotation time)? My default:
   hashes where single-commit, session-date + report where wave-distributed.
~~3. **The two `.html` snapshots** (06-17_20-41, 06-18_16-57): LEAVE ALONE in~~ v: resolved — snapshots remain LEAVE-ALONE in docs/status/ (2026-09-18 pass decision; CHANGELOG 2026-09-18)
   place (my classification — pure point-in-time dashboards, no forward
   items), or do you want them annotated with `<del>` inline markers / moved
   to archived/ too?

---

**State:** zero files mutated so far (all reads/verification). Resume at f1.
**Standing instruction honored:** report written, now **WAITING FOR INSTRUCTIONS**.
