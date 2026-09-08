# Status Report — TODO Wave 2 Full Session Review

**Date:** 2026-09-08 23:53 (Tuesday)
**Session scope:** Execute every verified-open TODO_LIST item (T21–T32),
verify with primary evidence, update bookkeeping. This report is the
brutally-honest pass over that run — what actually held up, what didn't,
what I forgot.
**Companion reports:** `2026-09-08_23-15_demo-video-retro-audit.md` (T21
output), `2026-09-08_23-40_todo-wave-2.md` (execution log).

**TL;DR:** 11 of 12 TODO items closed with execution-level evidence and the
12th (T30) is legitimately external. The wave caught one real code defect
(govalid's documented markers are silently ignored), achieved the
HyperFrames ground truth, and passed the jj skill's first behavioral trigger
test. But the session cleanup **trashed the ground-truth render artifacts
the wave report cites as evidence** — a self-inflicted documentation break —
and three process steps (ANNOTATE of an older report, mechanical eval
grading, fixture preservation) were skipped or weakened. Not the best run I
can do: about 90%.

---

## a) FULLY DONE

1. **T23 — govalid generator flow execution-verified** — scratch module,
   govalid v1.9.0: `go generate` → `go build` → `Validate()` correct on
   valid input, bad email, and minlength violation. Caught a real defect:
   the documented `//govalid:min_len=2` / `max_len=100` markers are
   **silently ignored** by the generator (no error, no check). Fixed to
   `minlength`/`maxlength` in `how-to-golang/references/key-patterns.md`
   and `key-patterns-08/main.go`; AGENTS.md §10 note updated to current
   truth. Evidence: scratch run output (valid→nil; email+required+minlength
   rejections all correct).
2. **T21 — demo-video retro-audit of all four live sites** — GitHub trees
   API + live HTTP fetch/HEAD (bun) per site. Only emeet-pixyd has a video
   (4/9 DoD items); gogenfilter/go-atomic-write/go-filewatcher have none.
   Live site serves `Cache-Control: max-age=0` for EVERY asset — stale
   manual deploy. Report: `docs/status/2026-09-08_23-15_…`; new pitfall #33
   in `website-launch/references/common-pitfalls.md`.
3. **T22 — HyperFrames ground truth achieved** — two real renders through
   the corrected guidance: 1920x1080 (5.0s, 150 frames, 163.4 KB) and the
   9:16 resized-composition variant (1080x1920, 136.7 KB), both
   ffprobe-verified. `demo-video.md`'s NixOS invocation block rewritten to
   the verified pipeline (real nix node for sharp; LD_LIBRARY_PATH recipe
   for puppeteer's chrome-headless-shell; direct CLI invocation;
   `check`-takes-a-directory gotcha).
4. **T24 — website-launch eval-1 re-run, asymmetry eliminated** — both
   configurations run in fresh `crush run` sessions against the same fully
   fictional repo (`go-pixelwand`, builds, deliberately flawed). Artifacts
   committed under `website-launch/evals/iteration-1/eval-1-rerun/`.
   Result: old 4/7, new 7/7 — mirrors the 08-21 outcome; scores were
   unaffected by the original asymmetry, as the TODO predicted.
5. **T27 — jj-fork-pr-workflow behavioral trigger test passed BOTH
   directions** — fresh headless sessions, realistic prompt without the
   word "jj": routed to the skill, quoted Phase 0 step 1 verbatim, surfaced
   the `verify-before-filing` handoff. Negative control (benchstat
   question) routed to `how-to-golang` and did not invoke the jj skill.
6. **T28 — verification-status canon restored** — `jj-fork-pr-workflow`,
   `go-error-modernization`, `nix-private-go-repos` all converted to the
   canonical `## Verification status` Claim/Status/Source table from
   `verify-external-claims` §5 (evidence levels preserved in the Status
   column); `how-to-write-skills.md` now names that template the only
   sanctioned format (the drift: three skills, three shapes).
7. **T29 — "Prior art" note added** (Carbon-lang jj skill, jj-commit
   snippet, explicit gap statement) to `jj-fork-pr-workflow/SKILL.md`.
   Placement deviation: SKILL.md, not `references/charmbracelet.md` — the
   Carbon skill is not charmbracelet-specific; deviation documented.
8. **T25 — website-launch/SKILL.md 799 → 781 lines** — Phase 2's 25-item
   structure list (a restatement that had already drifted from the
   template) replaced by a pointer to `readme-template.md` §"Standard
   Section Order" as single source.
9. **T26 — `check-skills.sh --triggers`** — informational trigger-density
   mode (15 marker phrases + quoted-phrase count; WEAK/NEAR-MISS/OK/STRONG;
   weakest first; always exit 0). WEAK detection unit-tested against the
   classic anti-pattern sentence ("Reviews the architecture…" → 0 markers);
   description extraction refactored into a shared `extract_desc()` so
   check 6 and the report cannot drift.
10. **T31 — thin-skill audit re-verified, real gap closed** — 3 of the 4
    flagged skills already satisfied the 2026-06-17 audit asks (rubric +
    methodology, tool-guidance, ginkgo syntax + template + naming:
    704 reference lines confirmed substantive by spot-check). The one real
    gap — architecture-visualization had no d2-missing error handling —
    closed with a Process step 0 gate plus
    `references/d2-syntax.md` where every snippet was rendered on local d2
    v0.8.x (default AND ELK engines) before being committed.
11. **T32 — `SESSION-START.md` created** (5-step checklist, feedback scan →
    newest status report → TODO_LIST → AGENTS §8/§9 → check-skills) and
    wired as AGENTS.md §8 step 0.
12. **Bookkeeping consistent** — TODO_LIST rewritten (T30 → 🔵 BLOCKED with
    reason; new T33 for site-repo follow-ups; preamble updated); CHANGELOG
    wave-2 entry; execution report 23-40. Final `check-skills.sh` green
    (26 skills, 130 md files, 0 broken links); `sync-html-kit.sh --check`
    green; both AGENTS.md advisories introduced by MY edits fixed to state
    current truth.

## b) PARTIALLY DONE

1. **T22 scope — pipeline ground truth, not a product video.** The
   corrected guidance is execution-verified end-to-end, but with a minimal
   2-clip composition. A real 20-30s product video for a live site was not
   rendered. Remaining: pick a site, produce the video (that is T33's
   largest item). Blocker: none, a scoping decision. Effort: L (site work).
2. **T22 evidence is now prose-only.** The rendered MP4s and both
   composition HTML files were trashed with /tmp scratch at session end
   (see d2) — the wave report's "evidence: renders + ffprobe outputs"
   points at artifacts that no longer exist. Reproducible via the now-
   documented recipe, but redoing discovery-free reproduction costs ~30 min
   (nix build caches help). Effort to fix properly: S (see f1).
3. **T24 grading is LLM-judge (me), not mechanical.** Evidence quotes are
   committed so anyone can re-grade, but assertion checks like "beat table
   has hook/value/evidence/CTA labels" or "og:image + 1200 co-occur" could
   be regex-graded for objectivity. Remaining: mechanical grader script.
   Effort: S-M.
4. **T31 quality depth.** I verified the three existing references EXIST
   and are substantive (spot-checks), but did not re-verify their CONTENT
   against current versions — e.g. `bdd-testing/references/ginkgo-syntax.md`
   says "current as of Ginkgo v2" while v2.32.1 is out; `spec-template.go`
   was never compiled this session. Remaining: version-pinned re-verification.
   Effort: M.
5. **govalid "zero allocations" claim** — labeled upstream-documented, not
   independently benchmarked (correctly hedged in the reference, but the
   benchmark itself remains undone). Effort: M (needs benchstat harness).
6. **T21 audit depth limits** — og:image checked for existence, not actual
   1200x630 dimensions; "visible without scrolling" judged from HTML
   position, not a rendered 1440x900 viewport; video script beats
   unverifiable for emeet (composition lost — the very incident the DoD
   item guards against). A mechanical site-DoD script would close this
   (see f3). Effort: M.
7. **AGENTS.md advisory state** — the two advisories I introduced are
   fixed, but the file still trips `check-agents-md.sh` on pre-existing
   items (36 KB size; the §5.2 `<--` history note's temporal framing).
   Deliberately not touched this session (not mine, and a size refactor is
   its own task). Effort: M-L for the size split.

## c) NOT STARTED

1. **T30 (🔴→🔵 in TODO_LIST)** — flip README 🆕→🟢 after the first real PR
   kept green by the sync loop. Waiting on a real-world run to happen;
   nothing in this repo can start it except scheduling the PR itself (f37).
2. **T33 site-repo work (all six items)** — emeet-pixyd redeploy + `id="demo"`
   + README demo link + composition recreation; gogenfilter / go-atomic-
   write / go-filewatcher video flows. Tracked in TODO_LIST but zero work
   done in the site repos this session — this session only produced the
   audit and the tracking row.
3. **docs-health ANNOTATE pass over `2026-09-08_20-39_jj-fork-pr-workflow…`**
   — its open items f7/f8/f13 were completed by this wave, but the older
   report was not annotated (repo rule: annotate, never rewrite). Also the
   08-21 reimagining report's now-resolved items. Skipped under session
   time pressure; it is exactly the kind of debt ANNOTATE exists for.
4. **Repo guard for the canonical verification-status table** — I aligned
   three skills by hand but did not add a check-skills rule that flags
   future verification blocks that ignore the §5 format. The split brain
   can regrow.
5. **HARVEST of this report's section (f)** — per the standing instruction
   the wave ended with WAIT FOR INSTRUCTIONS; the 08-21 precedent is that
   HARVEST waits for explicit user go-ahead. Not run.
6. **Behavioral trigger tests for other skills** — only jj got one. The
   repo has 25 more skills whose activation has never been observed
   (README "Contributing" asks for this generically).

## d) TOTALLY FUCKED UP

1. **Trashed the ground-truth evidence the report cites** — Severity: High
   (documentation trust). At cleanup I ran `trash /tmp/hf-demo
   /tmp/hf-demo-9x16 …`, deleting the two compositions and both rendered
   MP4s that `2026-09-08_23-40_todo-wave-2.md` lists as T22 evidence. The
   recipe survives in `demo-video.md`, so reproduction is cheap — but a
   report whose evidence pointer dangles is exactly the "false historical
   record" failure mode the DoD itself warns about. Root cause: cleanup
   momentum; I followed the trash rule mechanically without asking "is any
   of this load-bearing?" Mitigation: recreate as committed fixtures (f1).
2. **Read the audit before checking reality (T31 near-miss)** — Severity:
   Medium (wasted planning, not wasted work). I accepted the TODO row's
   "four thin skills" framing and dug into the 2026-06-17 audit before
   listing the skill directories — which showed 3 of 4 asks were already
   satisfied in later waves. Only the file listing prevented me from
   writing ~700 lines of duplicate references. Root cause: trusting a
   point-in-time TODO row over a 10-second `find`. The repo rule says
   "verify each item before starting"; I verified, but late.
3. **Two blind CLI fights before reading the tool's own references** —
   Severity: Medium (burned ~15 minutes and two 4-minute nix build cycles).
   For HyperFrames I tried `bunx`/`pnpm dlx` (sharp crash), then
   `PUPPETEER_EXECUTABLE_PATH` (ignored), then PATH-chromium (ignored),
   then `browser clear` (clears the wrong cache) — before discovering the
   skill references document the browser semantics, and before noticing
   the error footer itself said "Bun v1.3.13" (the machine's `node` is a
   shim `exec bun "$@"` — visible via `file ~/.local/bin/node` in seconds).
   Root cause: try-retry momentum instead of read-first; the exact
   "verify-then-write, for every binary" lesson applied to debugging.
4. **ldd-last instead of ldd-first (browser libs)** — Severity: Low.
   Building the chrome-headless-shell lib path took three iterations
   (`glib` → bin-only output; `systemd.libs` → attribute no longer exists;
   `dbus` default output → lib in `.lib`) because I guessed nixpkgs
   attribute names before running `ldd | grep "not found"` to get the
   exact missing list. The final list is correct and committed, but the
   discovery order was backwards.
5. **Anchor link broke the backlink guard (T28, first edit)** — Severity:
   Low. I wrote `[verify-external-claims §5](…SKILL.md#5-verification-…)` —
   the simple backlink loop in check-skills.sh does not strip anchors and
   failed the check. One fix cycle; and it reveals a real checker
   inconsistency (check-skill-links.sh IS anchor-aware, the SKILL.md loop
   is not) now logged as f12.
6. **`go install` blocked mid-command, unclear blast radius** — Severity:
   Low. The sandbox rejection of `go install` arrived AFTER the heredocs in
   the same compound command had already created scratch files; my first
   recovery attempt assumed the files might not exist. Cost: one confused
   round trip. Root cause: chaining mutating setup with a command I had
   not permission-tested. (Positive: the block is why the go run/build
   workarounds got documented.)
7. **Wrong-cwd `check` invocation** — Severity: Low. After building the
   full chromium+libstdc++ env (a 4-minute nix cycle), I ran the CLI
   without `cd /tmp/hf-demo` and got "No composition found in
   /home/lars/projects/SKILLS". The env was right, the invocation wasted.
8. **Python exact-match edit failed on `demo-video.md`** — Severity: Low.
   The scripted replacement of the NixOS block asserted an old string that
   differed from the file (wrote it from memory of `sed` output rather
   than a view). Fell back to view + edit tool. One wasted cycle; the
   repo's own "copy the EXACT text" rule exists precisely for this.

## e) WHAT WE SHOULD IMPROVE

1. **Cleanup must triage load-bearing artifacts.** "Trash /tmp scratch" is
   reflex; scratch outputs that a report cites as evidence should be
   committed (fixtures) or explicitly declared non-evidence BEFORE cleanup.
   Fix: add a session-end checklist line to `SESSION-START.md`: "evidence
   artifacts committed or disclaimed."
2. **Check the inventory before reading the history.** A TODO row is a
   claim, not a state. `find <skill> -type f` + `wc -l` takes ten seconds
   and would have re-scoped T31 immediately. This is the "status reports
   are point-in-time" lesson applied to TODO rows; worth one line in
   SESSION-START.md.
3. **Read the CLI's skill references at the FIRST failure, not the third.**
   The hyperframes-cli references documented browser semantics I spent
   four attempts rediscovering. Rule of thumb: one failed attempt → grep
   the installed skill's references before retrying.
4. **`ldd` first for "cannot open shared object file".** Derive the exact
   missing-lib list from the binary, then map to nixpkgs attributes —
   never guess attribute names up front.
5. **Encode environment recipes as runnable scripts, not prose.** The
   HF_LD_LIBRARY_PATH recipe is now accurate prose with ~25 store paths —
   which rot. A `scripts/hf-env.sh` (or flake devShell) that emits the
   path would make the docs point at an executable truth (f2).
6. **Mechanical eval grading.** LLM-judge grading (me, same as the original
   run) is fine for narrative; assertions like "contains a beat table with
   hook/value/evidence/CTA + time windows" are regex-checkable and would
   remove judge bias from future re-runs.
7. **Anchor-awareness inconsistency between the two link checkers** —
   check-skill-links.sh handles `#anchors`; the SKILL.md backlink loop
   does not. One of them should win (fix the loop or drop it as
   belt-and-braces).
8. **Version-pin every verified claim at write time.** The wave's docs now
   pin govalid v1.9.0 and hyperframes 0.8.31 — good — but older references
   (ginkgo syntax) still carry "current as of v2" style hedges that let
   content age invisibly. Consider a convention: `verified-against: <ver>`
   line in every reference header.
9. **Evals need a runner script.** The re-run was manual orchestration
   (mkdir, two crush runs, copy files). A `run-eval.sh <eval-id>` would
   make eval re-runs a one-command operation and keep configurations
   symmetric by construction.
10. **Sandbox permission probing before compound commands.** `go install`
    blocked after mutating setup had already run. Cheap rule: test a
    possibly-blocked command alone before embedding it in a larger chain.

## f) Top 50 next tasks (HARVEST input — routed with rigor)

| #  | Task                                                                                                                     | Impact | Effort | Category      |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------ | ------ | ------------- |
| 1  | Recreate the two T22 ground-truth compositions as committed fixtures (e.g. `website-launch/assets/demo-compositions/16x9/` + `9x16/`) so the wave report's evidence regains a durable home            | High   | S      | Documentation |
| 2  | Extract the HF environment recipe into a runnable `scripts/hf-env.sh` (emits node wrapper + LD_LIBRARY_PATH) and point `demo-video.md` at it instead of prose                              | High   | S      | Feature       |
| 3  | Write a mechanical demo-video DoD checker (`scripts/site-dod-check.sh <site>`: HEAD cache headers, mp4 size, id="demo", og:image presence) covering all four live sites                            | High   | M      | Feature       |
| 4  | T33: redeploy emeet-pixyd hosting; verify `HEAD /demo.mp4` AND one JS asset return `immutable` (closes pitfall #33's live case)                      | High   | S      | Bug (site)    |
| 5  | T33: add `id="demo"` to emeet-pixyd's video container (DoD placement item)                                            | Medium | S      | Bug (site)    |
| 6  | T33: add "Watch the 25s demo" link with accurate runtime to emeet-pixyd README docs bar                                | Medium | S      | Bug (site)    |
| 7  | T33: recreate emeet-pixyd's HyperFrames composition from the surviving MP4; commit under `website/video/`              | Medium | M      | Feature (site)|
| 8  | T33: produce the first REAL 20-30s product video through the corrected guidance (gogenfilter is the natural baseline) — also closes T22's product-render gap                         | High   | L      | Feature (site)|
| 9  | T33: video flows for go-atomic-write and go-filewatcher (after #8 proves the flow)                                     | Medium | L      | Feature (site)|
| 10 | T33: emeet-pixyd og:image-from-poster upgrade (1200x630 from the selling frame, not the astro-og template)             | Medium | S      | Bug (site)    |
| 11 | Add a CI deploy workflow to emeet-pixyd so firebase.json changes cannot silently go undeployed (kills pitfall #33's class)          | High   | M      | Bug (site)    |
| 12 | Make the SKILL.md backlink loop anchor-aware (or delete it in favor of check-skill-links.sh) — one checker, one truth | Low    | S      | Cleanup       |
| 13 | Add a check-skills guard: skills containing verification claims must use the canonical §5 Claim/Status/Source table (warn)          | Medium | S      | Quality       |
| 14 | Mechanical grader for eval-1-rerun: regex-file assertions (beat labels, og:image+1200, go get line, rm -rf absence) committed next to grading.json          | Medium | S      | Quality       |
| 15 | Write `run-eval.sh <eval-id>`: reproducible harness for skill evals (fresh sessions, fictional repo, output capture)   | Medium | M      | Feature       |
| 16 | Re-verify `bdd-testing/references/ginkgo-syntax.md` against ginkgo v2.32 (API drift since "current as of Ginkgo v2")   | Medium | M      | Quality       |
| 17 | Compile-check `bdd-testing/assets/spec-template.go` in a scratch module (never compiled)                                | Medium | S      | Quality       |
| 18 | Adopt a `verified-against: <version>` header convention for tool-behavior references (ginkgo, d2, govalid, hyperframes) | Low    | S      | Documentation |
| 19 | Run ANNOTATE on `2026-09-08_20-39_jj-fork-pr-workflow…` (f7/f8/f13 now done) and on the 08-21 reimagining report's resolved items     | Medium | S      | Documentation |
| 20 | Run docs-health HARVEST on this report's (f) into TODO_LIST/ROADMAP after user instruction                            | Medium | S      | Process       |
| 21 | Continue website-launch SKILL.md trim toward 500 (next: §3.11 length, per 08-21 report e4); goal: drop the allowlist entry | Medium | M      | Cleanup       |
| 22 | Behavioral trigger tests for 2-3 more high-traffic skills (docs-health, how-to-golang, verify-external-claims) in fresh sessions      | Medium | M      | Quality       |
| 23 | Build the mechanical trigger eval: prompt set × 46 descriptions, measure activation (T26's density report is the static half)        | Medium | L      | Feature       |
| 24 | Extend `--triggers` to print WHICH phrases matched per skill (actionable output, not just counts)                      | Low    | S      | Feature       |
| 25 | Re-run scripts/validate-workflow.sh against the latest jj release (skill promises rerunnability after jj upgrades)     | Medium | S      | Quality       |
| 26 | Schedule the first real upstream PR through the jj workflow (unlocks T30's README status flip)                          | Medium | M      | Feature       |
| 27 | Check eval-2/eval-3 for the same real-repo asymmetry; re-run on fictional repos if affected                            | Medium | M      | Quality       |
| 28 | govalid: verify a second marker family end-to-end (enum, cel, or migrate subcommand) to widen the execution-verified surface          | Low    | M      | Quality       |
| 29 | govalid: bench the zero-allocation claim (or relabel it permanently as upstream-only)                                   | Low    | M      | Quality       |
| 30 | Add govalid marker correctness to the how-to-golang compile-check harness so the min_len regression class is caught mechanically      | Medium | S      | Quality       |
| 31 | AGENTS.md size refactor: move historical verification records (§10 note lineage) to a references file; target < 30 KB (clears the standing check-agents-md advisory) | Low    | M      | Cleanup       |
| 32 | Convert `how-to-write-skills.md` into a skill directory (audit item 10; surfaced again while editing it this session)  | Medium | M      | Architecture  |
| 33 | Session-end checklist: add "no stale git worktrees" + "evidence artifacts committed or disclaimed" to SESSION-START.md | Low    | S      | Process       |
| 34 | Make SESSION-START.md machine-executable: `check-skills.sh --session-start` prints/executes the five steps             | Medium | S      | Feature       |
| 35 | code-quality-scan: document jscpd fallback install + invocation in tool-guidance.md (referenced, not detailed)          | Low    | S      | Documentation |
| 36 | code-quality-scan: add per-language severity-classification examples (the "what is Critical vs High" gap)               | Medium | M      | Quality       |
| 37 | architecture-visualization: add an Events & Commands flow style reference (the description promises it; no recipe exists)            | Medium | M      | Documentation |
| 38 | architecture-visualization: verify d2-syntax.md claims on the next d2 upgrade (version-pin note in header)              | Low    | S      | Quality       |
| 39 | Add `allowed-tools` entries per AGENTS §5.8 where skills depend on CLIs (art-dupl, d2 — d2 done; audit remaining)       | Low    | S      | Config        |
| 40 | emeet-pixyd: check remaining placement rule (poster/frame above the fold) against a rendered 1440x900 viewport, not HTML position     | Low    | S      | Quality (site)|
| 41 | Decide `#demo` anchor + "jump to demo" pattern as a shared component in gogenfilter's baseline (DoD placement made reusable)         | Low    | M      | Feature (site)|
| 42 | Add a per-site DoD scorecard to each site repo's own TODO_LIST (audit evidence lives where the fix happens)             | Low    | S      | Documentation |
| 43 | Consider `docs-health` VERIFY mode for live sites (are my sites still up/DoD-clean?) as a recurring audit               | Low    | M      | Feature       |
| 44 | Fix the remaining pre-existing AGENTS.md advisory (§5.2 `<--` history note → point at the guard, drop the narrative)    | Low    | S      | Cleanup       |
| 45 | Verify `ginkgo` CLI presence + `ginkgo unfocus` usage claim on this machine (bdd-testing SKILL.md references it)        | Low    | S      | Quality       |
| 46 | Capture crush session logs as harder evidence for trigger tests (response text today; log-level skill-load events tomorrow)          | Low    | S      | Quality       |
| 47 | HyperFrames: verify `--quality high` render + audio pipeline on NixOS (draft-only was exercised)                        | Medium | M      | Quality       |
| 48 | HyperFrames: confirm `browser ensure` re-download path works after a puppeteer cache wipe (recipe resilience)           | Low    | S      | Quality       |
| 49 | Add the retro-audit command sequence (gh api trees + bun HEAD checks) as a reusable reference next to pitfall #33       | Low    | S      | Documentation |
| 50 | ROADMAP: encode the three standing policy questions (autoplay, social-cut tier, API-library video mandate) as DECISIONS.md entries so they stop resurfacing as unowned | Low | S | Process |

## g) Questions I cannot answer myself

1. **Which site gets the first real product video (f8), and do you want it
   produced in a site-repo session?** I would pick gogenfilter (it is the
   skill's taught baseline, so it becomes the worked example), but "which
   launch matters most to you" is a product call I cannot derive from the
   repo. This unblocks T33's biggest item and T22's remaining scope.
2. **What is the binary-asset policy for THIS content repo?** The T22
   evidence would be durable as committed fixtures (f1): compositions are
   text (easy yes), but the rendered MP4s are binary (~160 KB each). AGENTS
   §9 bans build systems, not binaries; nothing answers "may rendered
   media live in this repo?" I checked AGENTS.md, the audit, and prior
   reports — the only precedent is site repos carrying MP4s, not SKILLS.
3. **Should the 9:16 social cut be launch-blocking (Tier 1) or stay
   same-day (Tier 2)?** This is 08-21 report question g2, still unresolved
   after two waves, and it directly scopes f8-f10 (whether the product
   video session must also ship the vertical cut or can defer it). I
   implemented nothing that depends on the answer yet — but T33 planning
   does.

---

_Point-in-time snapshot; when stale, use docs-health ANNOTATE — never
rewrite. Section (f) is HARVEST input on user instruction._
