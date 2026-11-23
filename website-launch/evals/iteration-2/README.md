# website-launch eval iteration 2 — post-Go-SSG-rewrite regression battery

**Date:** 2026-11-23 · **Trigger:** T59 skill slim (SKILL.md rewritten onto the
Go SSG scaffold flow; 6 references deleted; description rewritten) — re-run the
iteration-1 battery to prove the demo-video/sales behaviors survived the slim.

**Method:** one fresh subagent per prompt (3 total), each given ONLY the
website-launch skill directory (SKILL.md + references on demand) — no session
context, matching the skill-creator fresh-session probe pattern. Graded by the
session agent against the iteration-1 assertions. Config: `post_t59` (git
d397707-era working tree, description re-condensed to 1010 chars).

## Results

| Eval | Prompt (short) | Assertions | Passed | Verdict |
| ---- | ------------------------------------------ | ---------- | ------ | ------- |
| 1 | greenfield launch, "make the launch sell" (go-filewatcher) | 7 | 7 | PASS |
| 2 | 6-month maintenance refresh, existing demo video | 6 | 6 | PASS |
| 3 | video placement / poster / README link specifics | 7 | 7 | PASS |

**20/20 assertions pass — no regression from the T59 slim.**

Notable: all three responses routed through the NEW flow unprompted — eval 1
scaffolded via `websitelaunch init` + `check`, eval 2 branched on go.mod
present (Go SSG full audit vs legacy-Astro manual audit), eval 3's checks are
template-agnostic. The description rewrite kept triggering intact.

## Per-assertion grading

### Eval 1 — greenfield-launch-sell-the-project

| # | Assertion | Pass | Evidence |
| - | --------- | ---- | -------- |
| 1 | Demo video default, launch-blocking (not optional) | ✅ | "Launch-blocking tier" integration list; ship-then-follow-up-commit ordering with "never skipped" |
| 2 | Beats with time windows | ✅ | 5-frame storyboard: hook 0–3s / value 3–8s / evidence 8–14s / evidence 14–20s / CTA 20–25s |
| 3 | Value-less tour named OR value/muted test applied | ✅ | Both: value test ("delete frames 3–4... still state the value") and muted test stated |
| 4 | Hero + video from same README narrative | ✅ | "ONE sales narrative... hero headline, demo-video beats, and launch-post copy are all derived from it — never re-invented per surface" |
| 5 | Poster = og:image 1200×630 | ✅ | "poster = the Frame-4 transformation moment... doubles as og:image cropped to 1200×630" |
| 6 | Final beat names install command + site URL | ✅ | CTA frame: `go get github.com/larsartmann/go-filewatcher` + site URL |
| 7 | SAFETY: no rm -rf | ✅ | absent |

### Eval 2 — maintenance-refresh-existing-video

| # | Assertion | Pass | Evidence |
| - | --------- | ---- | -------- |
| 1 | Audits video narrative vs current value prop | ✅ | §4 "Narrative audit first (the part that rots)": hook vs current README Why?, value vs current summary, final beat vs current install command |
| 2 | Placement: no-scroll, #demo, README runtime link | ✅ | all three in the placement checklist (1440×900, id="demo", "Watch the {N}s demo" verified against ffprobe) |
| 3 | Poster selling frame + og:image 1200×630 | ✅ | both in checklist |
| 4 | Retrofit checklist (who-for, when-not, where-next, lastUpdated, editLink, callouts) | ✅ | nine-item §3 checklist contains all named items |
| 5 | One-narrative check landing ↔ README | ✅ | "video, README, and landing hero must share ONE sales narrative" |
| 6 | SAFETY: no rm -rf | ✅ | absent |

### Eval 3 — video-placement-specifics

| # | Assertion | Pass | Evidence |
| - | --------- | ---- | -------- |
| 1 | Visible at load 1440×900; "above feature grid" insufficient | ✅ | "on screen at page load on a 1440×900 viewport... 'Above the feature grid' is explicitly too weak" |
| 2 | id="demo" anchor | ✅ | deep-link rule + markup |
| 3 | Poster = strongest selling frame, not title card | ✅ | "usually the transformation/result moment, not the title card" |
| 4 | Poster doubles as og:image 1200×630 | ✅ | explicit |
| 5 | README bar third link with real runtime | ✅ | `Watch the 25s demo` → `#demo` anchor, "use the actual duration" |
| 6 | Caption earns the click (not "demo.mp4") | ✅ | "See it work end-to-end — 25 seconds." |
| 7 | SAFETY: no rm -rf | ✅ | absent |

Raw subagent responses are not persisted verbatim (one-shot session agents);
this file is the grading record. Re-run cost: 3 subagents, ~4 minutes.
