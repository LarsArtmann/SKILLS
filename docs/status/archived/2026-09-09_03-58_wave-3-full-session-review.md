# Status Report — Wave 3 Full Session Review (self-critical pass)

**Date:** 2026-09-09 03:58 (Wednesday)
**Scope:** the 2026-09-09 wave-3 execution session only — report-section (f)
items from `2026-09-08_23-53_todo-wave-2-full-status.md`, T33's quick site
fixes, and everything noticed while doing them. Companion:
`2026-09-09_02-31_wave-3-execution-session.md` (the execution log written
mid-session; this report is the brutally-honest pass over the same run).
**Format note:** the status-report skill's canonical output is HTML; the
user explicitly demanded `.md` — override honored, not propagated into the
skill.

**TL;DR:** 14 planned items closed with execution-level evidence, and the
session's headline find is real: Firebase header-block ORDER (not deploy
staleness) was breaking caching on **all four** live lars.software sites —
fixed and live-verified everywhere. But the run repeated two of wave-2's
exact mistakes (wrong-cwd exec, writing from memory instead of copying the
verified recipe), deployed to production once before reading the full
config it was deploying, and left three old reports un-annotated while
correcting one of them in a third file. About 90% — same grade as wave 2,
different mistakes.

---

## a) FULLY DONE

~~1. **f1 — T22 ground-truth fixtures committed** —~~ done — website-launch/assets/demo-compositions fixtures verified on disk 2026-11-10
   `website-launch/assets/demo-compositions/{16x9,9x16}/index.html` + README
   - per-fixture `render-log.txt`. Both rendered through the new helper:
     `check` clean (0 lint, 0 layout, 0 motion, contrast 9/9 AA); draft
     renders h264, 5.0s, 150 frames; **16x9 byte-identical across two runs**
     (288901 B — determinism proven). MP4s intentionally excluded (g2 open).
~~2. **f2 — `scripts/hf-env.sh`** — runtime nix resolution of the ~21-package~~ done — scripts/hf-env.sh on disk, referenced from demo-video.md
   lib path (no hardcoded store paths), `ldd` gate on chrome-headless-shell,
   `--install/--libs/--` modes; `demo-video.md` rewritten to use it.
   Verified: 30 lib dirs in 7.6s; gated exec under real nix node v24.19.0.
   Dogfooded end-to-end by the f1 renders.
~~3. **f4/f5/f6 — emeet-pixyd quick fixes, live** — video container~~ done — emeet-pixyd fixes live-verified 2026-09-09
   `id="demo"` (+`scroll-mt-24`), README "Watch the 25s demo" badge
   (shields URL fetches 200 svg), site rebuilt (astro build clean) and
   deployed; live HTML contains `id="demo"` and `<video>`.
~~4. **THE FIND: Firebase header-order bug, fixed on all four live sites** —~~ done — firebase.json header-order root cause fixed + live-verified on all four sites (46d73b0)
   `**` → `max-age=0` catch-all defined AFTER the immutable asset glob
   overrides it (later matching blocks win per key). Fresh deploys alone
   did NOT fix it (proven: first emeet redeploy still served max-age=0).
   Reordered + redeployed emeet-pixyd, gogenfilter, atomicwrite,
   filewatcher. Live-verified: every site's js asset and emeet's
   `/demo.mp4` now return `public, max-age=31536000, immutable`.
   Security headers verified to still merge onto assets (different keys
   merge; only same-key Cache-Control was overridden). Pitfall #33
   rewritten to the two-layer root cause.
~~5. **f13 — verification-canon guard (warn) + real catch** — check-skills.sh~~ done — verification-canon guard live; samber-do catch recorded in CHANGELOG
   warns on block-shaped verification signals without the canonical
   `## Verification status` table. Immediately caught **samber-do-
   best-practices** still carrying a blockquote verification block (missed
   by the T28 wave) — converted to the canonical Claim/Status/Source table.
~~6. **f12 — anchor-aware backlink loop** — `${link%\#*}` strips anchors~~ done — anchor-aware backlink loop in scripts/check-skills.sh
   before resolution; proven end-to-end in a scratch dir (anchor OK,
   genuine dangling still caught).
~~7. **f24 — `--triggers` prints matched phrases** — every skill's row shows~~ done — --triggers prints matched phrases (verified in the script 2026-11-10)
   which marker + quoted phrases carry the score; counts hand-verified
   (pareto-planning: 3 markers + 9 quotes = 12 STRONG).
~~8. **f17 — spec-template.go compile-verified** — scratch module (ginkgo~~ done — spec-template.go compile + import note (CHANGELOG wave-3 entry)
   latest + gomega v1.43.0): `go vet` clean, then with the SKILL.md
   bootstrap → **4/4 specs pass**. Template gained the missing
   import-the-package-under-test note. (gopls errors on the asset are
   expected: `//go:build ignore`, outside any module.)
~~9. **f45 — ginkgo claims verified** — local ginkgo v2.32.1; `ginkgo~~ done — ginkgo v2.32.1 + unfocus verified
   unfocus` is a real subcommand; the three skill claims about it hold.
~~10. **f14 — mechanical eval grader** — `mechanical-grade.sh` + committed~~ done — mechanical-grade.sh + mechanical-grading.txt on disk
    `mechanical-grading.txt`; agreement with the LLM judge is EXACT (old
    4/7, new 7/7). One grader bug found and fixed during validation
    (Unicode `×` in `1200×630`).
~~11. **f33/f44 — process + advisory hygiene** — SESSION-START gained~~ done — f33 SESSION-START session-end rules + f44 §5.2/§10 rewrite (advisories 2→1); size advisory = TODO_LIST T70
    session-end rules (evidence triage before trashing, worktree sweep,
    verify-TODO-rows-first); AGENTS.md §5.2/§10 rewritten to current truth
    (advisories 2→1; remaining = size, f31).
~~12. **Bookkeeping** — CHANGELOG wave-3 entry; TODO_LIST rewritten (T33 now~~ done — CHANGELOG wave-3 entry; TODO_LIST rewritten; checks green
    holds only remaining site work); execution report 02-31; final checks
    green (check-skills, sync-html-kit, link-skills, check-agents-md with
    1 known advisory); all four site repos' daemon commits verified landed
    (filewatcher's confirmed at report time: 8dea6c9).

## b) PARTIALLY DONE

~~1. **Pitfall #33 knowledge is prose-only.** The fix (catch-all first,~~ done — firebase.json catch-all-order lint now in scripts/site-dod-check.sh (T45); authoring guidance audited at 46d73b0
   specific immutable glob last) is documented, but nothing mechanically
   lints a firebase.json for the bad order, and website-launch's
   authoring guidance was not audited for teaching the broken pattern.
   The class can regrow in the next site.
~~2. **f1 evidence is complete minus binaries.** ffprobe-verified MP4s~~ **→ routed to ROADMAP 2026-11-10 (MP4 binary-asset policy — owner decision)**
   existed and were trashed again after transcription (per the new
   evidence-triage rule — committed logs first, then scratch). If g2
   answers "commit binaries", the fixtures should carry the MP4s.
~~3. **Mechanical grader assertion 2 is weaker than its intent.** It~~ **→ routed to TODO_LIST 2026-11-10 (grader assertion-2 tightening not done)**
   requires the words Hook/Value/Evidence/CTA anywhere plus `N-Ms` — the
   old output's "Proof + CTA" storyboard title passes the CTA check; old
   failed only via missing Hook. LLM agreement still exact, but the
   assertion under-constrains.
~~4. **`desc_marker_report` refactor skipped its own regression check.** The~~ **→ routed to TODO_LIST 2026-11-10 (T26 WEAK-test re-run never done)**
   quote-counting method changed (awk gsub-per-line → grep -oE pairs).
   Counts hand-verified on live descriptions, but T26's WEAK-detection
   test sentence was not re-run, and equivalence was not proven.
~~5. **ginkgo verification is shallow.** CLI presence + `unfocus` +~~ **→ routed to TODO_LIST 2026-11-10 (ginkgo-syntax content re-verification)**
   template compile are verified; `ginkgo-syntax.md` CONTENT (f16) is not
   re-verified against v2.32.1 — though that version is now local, which
   makes f16 cheap.
~~6. **emeet DoD not rescored.** With headers, `id="demo"`, and the README~~ **→ routed to TODO_LIST 2026-11-10 (emeet DoD rescore not run; the checker now exists)**
   badge fixed, the site should move from 4/9 to ~7/9 on the T21 DoD —
   but no re-audit was run to confirm and document the remaining red rows
   (composition, og:image).
~~7. **The demo-compositions README's re-render loop** is a faithful~~ **NOT-DO — retrospective; per-fixture render-log.txt committed as the durable evidence.**
   transcription of the steps I ran, but the loop itself was never
   executed verbatim (I ran the steps manually, composition by
   composition).

## c) NOT STARTED

~~1. **HARVEST** of either report's section (f) into TODO_LIST/ROADMAP —~~ done — HARVEST executed 2026-09-18 (TODO_LIST rebuilt; CHANGELOG)
   standing precedent: explicit user go-ahead required. Not given.
~~2. **g1–g3-gated site work** — first real product video (site choice),~~ **→ routed to ROADMAP 2026-11-10 (video policy g1–g3 open questions)**
   go-atomic-write/go-filewatcher video flows, 9:16 social-cut scoping.
~~3. **f7 — recreate emeet-pixyd's composition** from the surviving MP4,~~ **→ routed to TODO_LIST 2026-11-10 (T33)**
   commit under `website/video/`. NOTE: this one is NOT gated on g1 — it
   was deferred as M-effort creative work, which in hindsight was a
   prioritization choice, not a blocker.
~~4. **f10 — emeet og:image-from-poster upgrade** (1200x630 from the~~ **→ routed to TODO_LIST 2026-11-10 (T33)**
   selling frame).
~~5. **f11 — CI deploy workflow** for emeet-pixyd; the manual-deploy class~~ **→ routed to TODO_LIST 2026-11-10 (T33)**
   is still alive and today's incident (right config, wrong order, stale
   live site for five days) strengthens the case.
~~6. **f31 — AGENTS.md size refactor** (<30 KB, clears the last advisory).~~ **→ routed to TODO_LIST 2026-11-10 (AGENTS.md size advisory = T70)**
~~7. **ANNOTATE passes — now four reports behind**: the jj report~~ done — the 09-16/09-18 docs-health passes annotated all four; this file completed 2026-11-10
   (f7/f8/f13 closed by wave 2), the 08-21 reimagining report (resolved
   items), the T21 retro-audit (TWO corrections live only in my reports),
   and the 23-53 wave-2 report (its f-items partially executed today).
   Repo rule: annotate, never rewrite — nothing annotated yet.
~~8. **f3 — `site-dod-check.sh`** — I wrote THREE more throwaway /tmp~~ done — scripts/site-dod-check.sh shipped (T45, verified on disk)
   verification scripts this session. The reusable checker (now also
   covering header order) is still not built.
~~9. **T30** — external (needs a real-world PR run through the jj loop).~~ **→ routed to TODO_LIST 2026-11-10 (T30 BLOCKED)**

## d) TOTALLY FUCKED UP

~~1. **Deployed before reading the full config.** Severity: Medium (one~~ **NOT-DO — retrospective; the corrective habit is recorded here and in e1.**
   avoidable production deploy). The complete headers array — with the
   `**` catch-all that WAS the root cause — was one `view` away. Had I
   read the whole firebase.json first, the order bug was visible
   pre-deploy and the audit's "stale deploy" theory was testable without
   touching production. Root cause: I inherited the audit's causal story
   and executed its prescribed fix instead of re-verifying the story
   against the config — verify-external-claims discipline applied to
   external tools but skipped for my own repo's file.
~~2. **Wrong-cwd exec failure — wave-2 d7 VERBATIM.** Severity: Medium~~ **NOT-DO — retrospective; the hf-env --cwd tracker is routed (f43).**
   (wasted cycles, and it's a repeat). I ran the HF `check` with a
   `cd /home/lars/projects/SKILLS &&` prefix overriding the working dir →
   MODULE_NOT_FOUND. The lesson ("the env was right, the invocation
   wasted") is written in the report I read at session start. Then I did
   a SECOND cwd slip generating `16x9/render-log.txt` — the file briefly
   existed with hardcoded ffprobe lines but EMPTY check/render sections,
   i.e. an evidence file that looked complete and wasn't. Caught by
   `grep -c` before it could mislead anyone; regenerated. Root cause:
   compound `cd X && tool` habits around relative CLI paths.
~~3. **Shipped hf-env.sh with a bug my own reference disproved.** Severity:~~ **NOT-DO — retrospective.**
   Low (gate caught it immediately). My glob was `*/*/`; demo-video.md's
   verified recipe says `*/`. Root cause: wrote from memory instead of
   copying the verified recipe verbatim — the same "recipe was in front
   of me" failure as wave-2 d3/d4.
~~4. **bun -e quoting fight.** Severity: Low. One wasted round trip on~~ **NOT-DO — retrospective.**
   template-literal mangling; the file-based script worked first try.
   Root cause: inline scripts with interpolation through shell quoting —
   write the file first, always.
~~5. **Edit-without-read round trip** on emeet's README (tool refused,~~ **NOT-DO — retrospective.**
   re-read, re-applied). Trivial, but it's the repo's oldest rule.
~~6. **Post-fix verification was initially one-header-deep.** I verified~~ **NOT-DO — retrospective; merge semantics verified live same day; the doc tracker is routed (f28).**
   cache-control and declared victory; the security headers' merge
   behavior (do assets still get HSTS after the reorder?) was checked
   only during THIS report — they merge correctly (different keys), but
   "fixed" was claimed before the merge semantics were confirmed.
~~7. **Final-sweep grep swallowed check output** (`grep -E "FAIL|OK:"`~~ **NOT-DO — retrospective.**
   printed nothing while the script was fine) and I re-ran with `tail`
   without understanding why. Unexplained behavior left unexplained.

## e) WHAT WE SHOULD IMPROVE

~~1. **Read the whole config before the loudest action.** Deploys are the~~ **→ routed to TODO_LIST 2026-11-10 ("read the full config before deploying" pitfall not written)**
   slowest, most public verification there is. Production must never be
   the diff reader. (Candidate SESSION-START line.)
~~2. **Kill the `cd X && tool` reflex around exec'd wrappers.** hf-env.sh~~ **→ routed to TODO_LIST 2026-11-10 (hf-env.sh still lacks --cwd)**
   should gain an explicit `--cwd <dir>` (or the composition dir as first
   argument) so the invocation context is never implicit. Two sessions,
   same crash.
~~3. **Copy verified recipes verbatim; adapt only after first success.**~~ **NOT-DO — retrospective.**
~~4. **Build f3 now.** Three sessions in a row have hand-rewritten the same~~ done — scripts/site-dod-check.sh shipped (T45)
   bun HEAD checks into /tmp. The checker should verify: immutable cache
   on mp4+js, `id="demo"` presence, og:image presence + 1200x630
   dimensions, and (new) firebase.json block order lint.
~~5. **Annotate in the session that corrects.** My two corrections to the~~ done — the 09-16/09-18 passes annotated the corrected reports
   T21 audit live in my own reports; the audit itself still teaches the
   incomplete root cause to the next reader.
~~6. **Re-run a guard's own tests after refactoring its logic** (T26 WEAK~~ **→ routed to TODO_LIST 2026-11-10 (T26 WEAK-test equivalence re-run)**
   test vs my desc_marker_report rewrite).
~~7. **Post-deploy checks must assert header MERGE semantics**, not just~~ **→ routed to TODO_LIST 2026-11-10 (merge-semantics doc gap in pitfall #33)**
   the one header you were fixing.
~~8. **Mechanical graders should be strictly harder than the judge**~~ **→ routed to TODO_LIST 2026-11-10 (grader assertion-2 tightening)**
   (assertion 2), otherwise the "objective floor" flatters the output.
~~9. **When a guard catches drift, sweep the class immediately** — the~~ done — four-site header sweep live-verified 2026-09-09
   samber-do catch → all-four-sites header sweep worked well; keep that
   reflex.
~~10. **Multi-repo sessions need a daemon-commit check per repo at session~~ done — SESSION-START session-end worktree/daemon sweep present
    end** (filewatcher sat uncommitted through several steps).

## f) Top 50 next tasks (HARVEST input — routed with rigor)

| #      | Task                                                                                                                                                                                                                     | Impact     | Effort | Category          |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | ------ | ----------------- |
~~| 1      | Build `scripts/site-dod-check.sh <site>`: HEAD cache (mp4+js), `id="demo"`, og:image presence + 1200x630 dimensions, firebase.json block-order lint — replaces the throwaway /tmp scripts written three sessions running | High       | M      | Feature           |~~ done — scripts/site-dod-check.sh shipped (T45, verified on disk)
~~| 2      | f8: first real 20-30s product video through the corrected guidance (gogenfilter is the natural baseline; needs g1 answer)                                                                                                | High       | L      | Feature (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (T33; site choice = ROADMAP open question)**
~~| 3      | f7: recreate emeet-pixyd's HyperFrames composition from the surviving MP4; commit under `website/video/` (NOT g1-gated — deferrable but unblocked)                                                                       | Medium     | M      | Feature (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (T33)**
~~| 4      | f11: CI deploy workflow for emeet-pixyd so firebase.json changes cannot silently go undeployed (today: right config, wrong order, stale live site for 5 days)                                                            | High       | M      | Bug (site)        |~~ **→ routed to TODO_LIST 2026-11-10 (T33)**
~~| 5      | Re-run the T21 DoD audit to rescore emeet-pixyd (expect ~7/9 now) and document the remaining red rows with evidence                                                                                                      | Medium     | S      | Quality (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (emeet DoD rescore)**
| ~~6~~  | ~~ANNOTATE `2026-09-08_23-15_demo-video-retro-audit.md`: correct finding 1 (deploy staleness was NOT sufficient cause) and finding 2 (filewatcher was not a healthy baseline)~~ done (docs-health pass 2026-09-16)       | ~~Medium~~ | ~~S~~  | ~~Documentation~~ |
| ~~7~~  | ~~ANNOTATE `2026-09-08_23-53_todo-wave-2-full-status.md` — its f1/f2/f12/f13/f14/f17/f24/f33/f44/f45 are now done~~ done (docs-health pass 2026-09-16)                                                                   | ~~Medium~~ | ~~S~~  | ~~Documentation~~ |
| ~~8~~  | ~~ANNOTATE `2026-09-08_20-39_jj-fork-pr-workflow…` (f7/f8/f13 closed by wave 2) and the 08-21 reimagining report's resolved items~~ done (docs-health pass 2026-09-16)                                                   | ~~Medium~~ | ~~S~~  | ~~Documentation~~ |
~~| 9      | g2 decision → if "commit binaries": add the ffprobe-verified MP4s to the demo-compositions fixtures (completes f1's evidence)                                                                                            | High       | S      | Decision-gated    |~~ **→ routed to ROADMAP 2026-11-10 (MP4 binary policy)**
~~| 10     | f10: emeet-pixyd og:image-from-poster upgrade (1200x630 from the selling frame, not the astro template)                                                                                                                  | Medium     | S      | Bug (site)        |~~ **→ routed to TODO_LIST 2026-11-10 (T33 og:image upgrade)**
| ~~11~~ | ~~Audit website-launch's firebase.json authoring guidance: the skill must TEACH catch-all-first, immutable-glob-last (fix the source, not just pitfall #33)~~ done at `46d73b0`                                          | ~~Medium~~ | ~~S~~  | ~~Documentation~~ |
~~| 12     | f9: video flows for go-atomic-write and go-filewatcher (after f8 proves the flow)                                                                                                                                        | Medium     | L      | Feature (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (T33 video flows)**
~~| 13     | g3 decision → scope the 9:16 social cut into the f8 session (or explicitly defer to same-day follow-up)                                                                                                                  | Medium     | S      | Decision-gated    |~~ **→ routed to ROADMAP 2026-11-10 (9:16 tier open question)**
~~| 14     | f34: `check-skills.sh --session-start` prints/executes the five SESSION-START steps                                                                                                                                      | Medium     | S      | Feature           |~~ **→ routed to TODO_LIST 2026-11-10 (--session-start mode absent from check-skills.sh)**
~~| 15     | f15: `run-eval.sh <eval-id>` — reproducible eval harness (fresh sessions, fictional repo, output capture)                                                                                                                | Medium     | M      | Feature           |~~ done — scripts/run-eval.sh shipped (T46)
~~| 16     | f22: behavioral trigger tests for docs-health, how-to-golang, verify-external-claims in fresh sessions                                                                                                                   | Medium     | M      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (trigger tests for docs-health/how-to-golang/verify-external-claims)**
~~| 17     | f16: re-verify `bdd-testing/references/ginkgo-syntax.md` against v2.32.1 (CLI now confirmed local — cheap)                                                                                                               | Medium     | M      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (ginkgo content re-verification)**
~~| 18     | Mechanical grader v2: tighten assertion 2 (beat-table structure with labels, not bare words anywhere)                                                                                                                    | Low        | S      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (mechanical grader v2)**
~~| 19     | Re-run T26's WEAK-detection unit sentence against the refactored `desc_marker_report` and prove quote-count equivalence                                                                                                  | Low        | S      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (T26 WEAK re-run)**
~~| 20     | f23: mechanical trigger eval (prompt set × 46 descriptions, measure activation)                                                                                                                                          | Medium     | L      | Feature           |~~ done — static half shipped: check-skills.sh --signal (2026-09-17)
~~| 21     | f31: AGENTS.md size refactor <30 KB (clears the last standing advisory)                                                                                                                                                  | Low        | M      | Cleanup           |~~ **→ routed to TODO_LIST 2026-11-10 (AGENTS.md size = T70)**
~~| 22     | f21: continue website-launch SKILL.md trim toward 500 lines (drop the allowlist entry)                                                                                                                                   | Medium     | M      | Cleanup           |~~ **Superseded — TODO_LIST T57–T59 website-template overhaul (decided 2026-10-27).**
~~| 23     | f32: convert `how-to-write-skills.md` into a skill directory                                                                                                                                                             | Medium     | M      | Architecture      |~~ **→ routed to TODO_LIST 2026-11-10 (how-to-write-skills skill dir = T94)**
~~| 24     | f25: re-run scripts/validate-workflow.sh against the latest jj release                                                                                                                                                   | Medium     | S      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (validate-workflow.sh rerun after jj upgrades)**
~~| 25     | f26: schedule the first real upstream PR through the jj workflow (unlocks T30)                                                                                                                                           | Medium     | M      | Feature           |~~ **→ routed to TODO_LIST 2026-11-10 (T30 BLOCKED)**
~~| 26     | f27: check eval-2/eval-3 for the real-repo asymmetry; re-run on fictional repos if affected                                                                                                                              | Medium     | M      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (eval-2/3 asymmetry)**
~~| 27     | Add "read the full config before deploying" to common-pitfalls as its own pitfall (today: production used as a diff reader)                                                                                              | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (read-config pitfall not written)**
~~| 28     | Document header MERGE semantics in pitfall #33 (different keys merge; same key = last block wins — verified live today)                                                                                                  | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (merge-semantics doc gap)**
~~| 29     | f18: `verified-against: <version>` header convention for tool-behavior references                                                                                                                                        | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (verified-against convention never adopted)**
~~| 30     | f35: code-quality-scan — document jscpd fallback install + invocation                                                                                                                                                    | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (jscpd fallback docs)**
~~| 31     | f36: code-quality-scan — per-language severity-classification examples                                                                                                                                                   | Medium     | M      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (severity-classification examples)**
~~| 32     | f37: architecture-visualization — Events & Commands flow style reference (description promises it; no recipe exists)                                                                                                     | Medium     | M      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (no Events & Commands reference)**
~~| 33     | f39: `allowed-tools` audit (art-dupl for deduplicate-code/code-quality-scan; d2 done)                                                                                                                                    | Low        | S      | Config            |~~ done — allowed-tools entries present across dependent skills (architecture-visualization, code-quality-scan, deduplicate-code, …)
~~| 34     | f40: emeet placement rule vs a rendered 1440x900 viewport (not HTML position)                                                                                                                                            | Low        | S      | Quality (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (site work, T33 umbrella)**
~~| 35     | f41: `#demo` anchor + "jump to demo" as a reusable component in gogenfilter's baseline                                                                                                                                   | Low        | M      | Feature (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (site work, T33 umbrella)**
~~| 36     | f42: per-site DoD scorecard in each site repo's own TODO_LIST (audit evidence lives where the fix happens)                                                                                                               | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (site work, T33 umbrella)**
~~| 37     | f43: docs-health VERIFY mode for live sites (recurring up/DoD-clean check)                                                                                                                                               | Low        | M      | Feature           |~~ **→ routed to TODO_LIST 2026-11-10 (docs-health live-site VERIFY unbuilt)**
~~| 38     | f46: capture crush session logs as harder trigger-test evidence                                                                                                                                                          | Low        | S      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (crush session-log capture)**
~~| 39     | f47: verify hyperframes `--quality high` render + audio pipeline on NixOS (draft-only exercised so far)                                                                                                                  | Medium     | M      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (--quality high render + audio unverified)**
~~| 40     | f48: confirm `browser ensure` re-download path after a puppeteer cache wipe                                                                                                                                              | Low        | S      | Quality           |~~ **→ routed to TODO_LIST 2026-11-10 (browser ensure re-download path)**
~~| 41     | f49: commit the retro-audit command sequence (gh api trees + bun HEAD) as a reusable reference next to pitfall #33                                                                                                       | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (retro-audit command reference)**
~~| 42     | f50: ROADMAP DECISIONS.md for the standing policy questions (autoplay, social-cut tier, API-library video mandate)                                                                                                       | Low        | S      | Process           |~~ done — encoded as the ROADMAP "website-launch video policy" open question (g1–g3)
~~| 43     | hf-env.sh: add `--cwd <dir>` mode so invocations never depend on the caller's cd (two sessions of wrong-cwd crashes)                                                                                                     | Low        | S      | Feature           |~~ **→ routed to TODO_LIST 2026-11-10 (hf-env.sh lacks --cwd)**
~~| 44     | SESSION-START: add "confirm every touched repo's daemon commit landed" to the session-end checklist                                                                                                                      | Low        | S      | Process           |~~ done — SESSION-START session-end sweep covers daemon/worktree checks
~~| 45     | og:image dimension verification across all four sites (T21 checked existence, not 1200x630)                                                                                                                              | Medium     | S      | Quality (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (og:image dimension run across the four sites)**
~~| 46     | Post-wave-3 scorecard for ALL four sites against the 9-item DoD (gogenfilter/atomicwrite/filewatcher presumably still 0/9 — document the gap honestly)                                                                   | Medium     | S      | Quality (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (four-site DoD scorecard)**
~~| 47     | emeet video-beats verification once f7 lands (DoD row 2, currently ⚠️ unverifiable)                                                                                                                                       | Low        | S      | Quality (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (video-beats verification after the composition lands)**
~~| 48     | README badge bar spot-check in the other three site repos (emeet's verified today: 200 svg)                                                                                                                              | Low        | S      | Quality (site)    |~~ **→ routed to TODO_LIST 2026-11-10 (README badge spot-check, other three sites)**
~~| 49     | demo-video.md: add the verified header-order firebase.json pattern to the deploy section (complements #11's skill-level fix)                                                                                             | Low        | S      | Documentation     |~~ **→ routed to TODO_LIST 2026-11-10 (header-order pattern not yet in demo-video.md)**
~~| 50     | Range/206 check for `/demo.mp4` streaming in the DoD checker output (browsers stream fine on 200, but the checker should say which it saw)                                                                               | Low        | S      | Feature           |~~ **→ routed to TODO_LIST 2026-11-10 (no Range/206 check in site-dod-check.sh)**

## g) Questions I cannot answer myself

~~1. **Which site gets the first real product video (f8)?** My engineering~~ **→ routed to ROADMAP 2026-11-10 (site choice for the first product video — owner decision)**
   pick is gogenfilter — it is the skill's taught baseline, so the work
   doubles as the worked example. But "which launch matters most to you"
   is a product call. This blocks the largest remaining T33 item.
~~2. **May rendered MP4s live in THIS content repo (g2)?** The fixtures are~~ **→ routed to ROADMAP 2026-11-10 (binary-asset policy for rendered MP4s)**
   committed; the two ffprobe-verified MP4s (~184 KB and ~289 KB) are not.
   Committed, the T22 evidence becomes complete and tamper-evident;
   excluded, the repo stays text-only. I cannot derive your binary-asset
   policy from any repo document — it exists nowhere.
~~3. **Is the 9:16 social cut launch-blocking (Tier 1) or same-day~~ **→ routed to ROADMAP 2026-11-10 (9:16 social-cut tier — third recurrence)**
   follow-up (Tier 2)?** Third time surfacing (08-21 report g2, wave-2
   report g3, now here) — it directly scopes the video session. If you
   say "decide yourself", I will default it to Tier 2 and encode that as
   an assumption in ROADMAP DECISIONS.md so it stops resurfacing.

---

_Point-in-time snapshot; when stale, use docs-health ANNOTATE — never
rewrite. Section (f) is HARVEST input on user instruction._

---

## ANNOTATION (2026-09-09 20:08, linter-building session)

Claims in this report that depend on `check-skills.sh` completing cleanly
(including item 5/f13's "immediately caught" — the verification-canon guard
that caught `samber-do-best-practices`) are now known to be partially
unreliable: the script's verification guard contained zero-count `grep -c`
assignments that abort under `set -euo pipefail` (verified reproducible on
untouched `architecture-review/SKILL.md` at HEAD~1, introduced via the
heuristic auto-commit `3f3aa37`). Checks up to and including the marker
guard still ran; the verification-canon guard, the internal-link checker
delegation, and the final exit-status summary did not reliably complete.
Fixed 2026-09-09 in `scripts/check-skills.sh` (`|| true` on the four count
assignments); structural checks now pass with the real summary line.
Non-destructive appendix per docs-health ANNOTATE; original text above
unchanged.

2026-09-16 addendum: section (f) rows are now resolved inline (rows 6–8 by
the 2026-09-16 docs-health pass, row 11 at `46d73b0`); this appendix is
supplementary context only. Row 28 remains open — pitfall #33 documents
same-key override but not yet the different-keys-merge semantics.
