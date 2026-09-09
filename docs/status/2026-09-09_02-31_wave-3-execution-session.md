# Status Report — Wave 3 Execution Session (report section f + T33 quick items)

**Date:** 2026-09-09 ~02:31 (Wednesday)
**Session scope:** user ordered "break it down, execute and verify step by
step, keep going until everything works" — executed every ungated,
this-repo-scope item from the wave-2 full-status report's section (f), plus
T33's quick site-repo items. Section (f) items that need product decisions
(g1–g3 answers) or HARVEST authorization were NOT touched (standing
precedent).
**Input reports:** `2026-09-08_23-53_todo-wave-2-full-status.md` (work
queue), `2026-09-08_23-15_demo-video-retro-audit.md` (T33 evidence).

**TL;DR:** 12 items closed with execution-level evidence, including the two
High-impact documentation repairs (committed demo fixtures, runnable
hf-env.sh) and all four emeet-pixyd quick fixes. The site-repo work
surfaced a NEW, deeper root cause under pitfall #33 — Firebase header-block
ORDER, not deploy staleness — which turned out to affect ALL FOUR live
lars.software sites; fixed and live-verified everywhere. The mechanical
eval grader reproduces the LLM judge's verdicts exactly. One finding
invalidated an audit claim (see "Corrections"). Session end: all repo
checks green.

## Done (with evidence)

1. **f33 — SESSION-START session-end rules** — added: TODO-rows-are-claims
   check (`find + wc -l` before trusting framing), worktree sweep, and
   evidence-artifact triage before trashing (the wave-2 d1 incident).
   `SESSION-START.md`.
2. **f44 — AGENTS.md advisories cleared** — §5.2 rewritten to current truth
   ("guarded", points at the check-skills guard); §10 `formerly` → "old
   name:". check-agents-md.sh: 2 advisories → 1 (remaining = the 36 KB
   size advisory = f31, deferred as its own M-L task).
3. **f12 — backlink loop anchor-aware** — `${link%\#*}` strips `#anchor`
   before file resolution; proven end-to-end in a scratch dir (anchor link
   resolves, genuine dangling still caught).
4. **f13 — verification-canon guard (warn)** — check-skills.sh now warns
   when a skill shows block-shaped verification signals (blockquotes,
   stray headings, ≥2 compound claims) without the canonical
   `## Verification status` table. It immediately caught a REAL drift the
   T28 wave missed: **samber-do-best-practices** still had a blockquote
   verification block — converted to the canonical Claim/Status/Source
   table (checked against the §5 template).
5. **f24 — --triggers prints matched phrases** — every skill's row now
   shows WHICH marker phrases and quoted phrases matched (count-based
   verdicts unchanged; pareto-planning 3 markers + 9 quotes = 12 spot-
   checked by hand).
6. **f17 — spec-template.go compile-verified** — instantiated in a scratch
   module (ginkgo latest + gomega v1.43.0): `go vet` clean, then ran with
   the SKILL.md-documented bootstrap → **4/4 specs pass**. Found and fixed
   a real template gap: no note that the package-under-test import cannot
   be pre-written (placeholders). (gopls errors on the asset file itself
   are expected: `//go:build ignore`, outside any module.)
7. **f45 — ginkgo CLI claims verified** — local ginkgo v2.32.1 present;
   `ginkgo unfocus` is a real subcommand (help text confirmed). The three
   SKILL.md/references claims about `unfocus` are accurate.
8. **f14 — mechanical eval grader** —
   `website-launch/evals/iteration-1/eval-1-rerun/mechanical-grade.sh`
   regex-grades all 7 assertions; results committed in
   `mechanical-grading.txt`. Agreement with the LLM judge: EXACT (old 4/7,
   new 7/7). One grader bug fixed during validation (Unicode `×` in
   `1200×630`).
9. **f2 — scripts/hf-env.sh** — the ~25-store-path LD_LIBRARY_PATH prose is
   now an executable: runtime resolution via `nix build --print-out-paths`
   (never hardcoded), `ldd` gate on chrome-headless-shell (zero "not
   found"), `--install` / `--libs` / `-- <cmd>` modes. demo-video.md's
   NixOS block rewritten to use it. Verified: `--libs` (30 dirs, 7.6s) and
   gated exec under real nix node v24.19.0. Dogfooded through the f1
   renders below. (One bug found+fixed during verification: my glob had an
   extra path level; the doc's recipe was right.)
10. **f1 — T22 ground-truth fixtures committed** —
    `website-launch/assets/demo-compositions/{16x9,9x16}/index.html` +
    README + `render-log.txt` per fixture. Both rendered through hf-env.sh
    (`check`: 0 errors, contrast 9/9 AA; render draft: h264 5.0s 150
    frames; 16x9 288901 B **byte-identical across two runs** —
    deterministic; 9x16 ~184 KB). MP4s deliberately NOT committed — binary
    policy is open question g2. Transient teardown `assert(!this.paused)`
    observed once on 9x16, non-reproducible, artifact ffprobe-valid.
11. **f5+f6 — emeet-pixyd DoD placement fixes** — `id="demo"` +
    `scroll-mt-24` on the video container (ShowcaseSection.astro); README
    docs bar gained the "Watch the 25s demo" badge → `/#demo`. Built
    (astro build clean), deployed, **live-verified**: `id="demo"` present
    in served HTML.
12. **f4 — emeet-pixyd redeploy + header fix (closed, with a twist)** —
    first redeploy did NOT fix caching → investigation → **new root cause**
    (below). After the firebase.json order fix + redeploy: live HEAD
    `/demo.mp4` AND `/js/theme-init.js` return `public, max-age=31536000,
    immutable`. Pitfall #33's live case is closed for real.

## NEW finding: pitfall #33's root cause was incomplete

The T21 audit attributed the max-age=0 symptoms to "stale manual deploy".
Half true. Even after a fresh deploy, emeet-pixyd still served max-age=0 —
and so did **filewatcher** (the audit's implicit "healthy" comparison — its
js was also max-age=0, an over-claim). Real cause: **Firebase Hosting
applies header blocks in definition order; a later matching block overrides
the same key.** Every site's firebase.json had the immutable `**/*.@(...)`
glob FIRST and the `**` → `max-age=0` catch-all SECOND, so the catch-all
clobbered caching for every asset. Verified against Firebase's documented
extglob syntax (docs support `@(...)` — the glob was never the problem).

**Fixed + live-verified 2026-09-09 on all four sites** (reorder + add
`mp4|webm|mov` where missing; deploys: emeet-pixyd, gogenfilter, atomicwrite,
filewatcher — all js assets now `immutable` via bun HEAD checks).
common-pitfalls.md #33 rewritten to the two-layer root cause.

## Corrections to prior reports

- `2026-09-08_23-15_demo-video-retro-audit.md` cross-cutting finding 1:
  "stale manual deploy" was necessary but NOT sufficient — block order was
  the deeper cause. Finding 2's implied healthy baseline (filewatcher) was
  itself broken. Annotate, never rewrite.

## Not done (and why)

- **HARVEST of section (f)** — standing precedent: explicit user go-ahead
  required. Not given.
- **g1–g3-gated items** (f7–f11 site videos, og:image upgrade, CI deploy
  workflow) — product decisions pending (which site gets the first video;
  binary-fixture policy for MP4s; 9:16 tier). f10 and f11 are executable
  but M-effort site work; queued behind the answers.
- **f31 AGENTS.md size refactor** — M-L, Low impact, its own task.
- **f16 ginkgo-syntax re-verification** — M; v2.32.1 now confirmed local,
  which makes it cheaper, but the reference sweep didn't fit this pass.
- **T30** — external (real-world PR run), unchanged.

## Session-end state

check-skills.sh green (26 skills, 1 allowlisted WARN); sync-html-kit green;
link-skills green; check-agents-md: 1 advisory (size, f31). Site repos all
auto-committed by the daemon. Scratch dirs trashed after evidence was
committed (new SESSION-START rule followed).

_Next report: annotate this one via docs-health ANNOTATE when its items
close; section (f) of the 23-53 report remains HARVEST input on user
instruction._
