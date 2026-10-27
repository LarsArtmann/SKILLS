# Open Decisions — Consolidated Package (2026-10-27)

> One sitting, every open user decision, one recommendation each. Sources:
> T34 (2026-09-09 g1–g3), T51 (2026-09-18 g2), T57 (2026-10-11 Q0–Q5),
> ROADMAP g1–g4 (2026-08-14/16). Every question below gates at least one
> TODO item; six of eleven open TODOs are blocked on this document. Claims
> re-verified 2026-10-27 (verification notes inline).
>
> **How to answer:** verdict per question — pick a letter, or write your own.
> Answers get routed to TODO_LIST/ROADMAP the same session; this file then
> records the verdicts and closes.

## A. website-launch template chain (T57) — gates T57→T58→T59

### Q0 — Extraction baseline: Go SSG or Astro?

| Option                                 | What it means                                                                                                                                                                                                                                                                                                                                 |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **(a) Go SSG** (templ-components site) | Matches your stated "standard stack" direction; 8 of 22 documented pitfalls die (all Node/pnpm/MDX classes); 186 lines of prose version-pins die → go.mod/lockfile; golden tests + CSP hash-pinning + link checker built in. Cost: parity gaps first (editLink, per-page lastUpdated), and 18 live Astro sites get no new tooling short-term. |
| (b) Astro (gogenfilter)                | 18 live Astro sites → `retrofit` has immediate consumers; Starlight features complete without new code. Cost: keeps the entire Node/pnpm pitfall class the skill documents; contradicts the Go-everywhere direction; eventual Go pivot = double extraction.                                                                                   |

**Recommendation: (a) Go SSG.** Stack direction is the durable fact; tooling
(`doctor`/`check`) is stack-agnostic and benefits everyone immediately.
Astro sites keep the existing manual §0.0 audit — they are live and stable.

_Verified 2026-10-27: fleet is now 19 sites with `website/` — 18 Astro/JS +
1 Go SSG (templ-components). One new Astro site since the 2026-10-11 count;
split unchanged in kind._

### Q1 — Template repo name?

**Recommendation: `website-template`.** Reads as "THE template for websites";
avoids the `go-website-template` collision (different stack, Cloud Run) and
avoids joining the `template-*` family whose hub (`~/projects/templates`) has
failing macOS-path tests and zero-consumer SDK — no reason to imply
integration with it.

### Q2 — CLI language for `websitelaunch`?

**Recommendation: Go, stdlib-only.** Single binary via nix, flag parsing,
Firebase REST calls, matches the repo's Go convention (P8 already scoped
stdlib-only, hard-capped). Bash would be faster to start and worse to live
with (JSON parsing, HTTP, structured checks).

### Q3 — gogenfilter's fate?

**Recommendation: eventually rebuild on the template; keep hand-maintained
until then.** One baseline beats two; gogenfilter stays the design playground
until the template repo is CI-green and proven by one real launch. Do not
block the template on it.

### Q4 — Template repo visibility?

**Recommendation: private now, publishable later.** It embeds lars.software
conventions and repo paths; parametrize names/assets during extraction (P7.2
already scopes this) so publishing later is a config flip, not a scrub.

### Q5 — Fold T33 site-media items into template milestones, or keep separate?

**Recommendation: keep T33 separate.** T33 is HyperFrames media work
(composition rebuild, product videos, og:image) that stands on its own and is
NOT gated on this package — folding it in would chain ungated visible work to
gated work. Only the CI-deploy-workflow item may migrate into the template's
CI once it exists.

## B. linter-building direction (T34)

### g1 — Go-first or multi-language depth?

**Recommendation: stay Go-first.** 8 of 10 evidence projects are Go; your
linter repos (go-finding, go-linter-sdk, auto-configure pair) are all Go. Add
the oxlint reference only when a real non-Go linter request occurs —
portable-principles + one JS example already covers the "it's mostly the same
judgment" case. (Same logic as stack-selection's YAGNI case.)

### g2 — Synthetic eval as aging evidence, or wait for real trigger?

**Recommendation: synthetic eval ages 🆕→🟡, real run ages →🟢.** A synthetic
subagent eval proves behavior, not fit; it's worth more than "New" but less
than a genuine trigger. Amend the FEATURES legend note once (P11.2). Note:
stack-selection faces the same question next — answering it here settles it
there too.

### g3 — Commit ownership: agent-made detailed commits vs auto-daemon?

**Recommendation: agent commits session artifacts (reports, skills) with
detailed messages; daemon remains the floor, not the ceiling.** The repo's
own convention ("very detailed commit messages", AGENTS §7) and the git
workflow in Crush already authorize commits when asked; this removes the
ambiguity for report/skill files specifically. Never for `originals/`.

## C. Glossary lockstep (T51 / ROADMAP 2026-09-18 g2)

Principle 7 says "wording identical" to the house-jargon table; the seven
shipped first-use glosses paraphrase (verified again 2026-10-27: e.g.
nix-review glosses "the same rule maintained in two places" vs the table's
"the same concept defined or configured in two places").

| Option                                                   | Consequence                                                                                                   |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| (a) Verbatim lockstep                                    | Align all 7 glosses to the table (P10, ~30 min); future glosses are copy-paste. Stiffest wording in prose.    |
| **(b) Amend rule: "meaning identical, table canonical"** | Rule edit only; glosses stay; drift risk stays low because the table remains the single canonical definition. |

**Recommendation: (b).** The paraphrases are clear, the table is canonical,
and (a) buys identical words at the cost of stiffer prose plus ongoing
enforcement no tool checks. Principle 7's actual goal (no second definition)
is preserved by "table canonical".

## D. ROADMAP g1–g4 (2026-08-14/16 cluster)

### g1 — Backup retention: trash `~/.agents/.backup-skills-20260814/`?

_Verified 2026-10-27: dir exists, 25 skill copies; the lockfile `.bak`
mentioned in the ROADMAP is already gone — only the dir remains._

**Recommendation: trash it.** Symlinks verified green across four months of
`link-skills-to-agents.sh --check` runs and multiple `skills update -g`
cycles. Deletion is irreversible — your call overrides the recommendation.

### g2 — Third-party policy long-term

**Recommendation: stay upstream-managed; fork only on first hard need.** 15
lockfile-tracked third-party skills update cleanly; `first-customers` already
layers over `copywriting` without forking it (boundary documented in AGENTS
§5.5). Revisit only if an upstream change breaks a layered skill.

### g3 — Link-state enforcement level

**Recommendation: pre-commit hook in THIS repo only.** A 10-line hook running
`scripts/link-skills-to-agents.sh --check` at commit time catches drift where
it originates (repo edits); a GitHub Action adds CI machinery to a repo whose
§9 bans CI. Manual-only leaves the 2026-09 stale-skill class unguarded.

### g4 — Status-report default format (.md vs HTML)

**Recommendation: default .md; HTML on explicit request or dashboard-shaped
content (metrics, scores).** The user has demanded `.md` twice explicitly
(2026-10-17, 2026-10-27 plans) and 8 recurrences are documented; the HTML kit
remains for reviews/audits where the Bauhaus layout earns its keep (the
2026-10-27 self-review HTML). Amend status-report skill default (P14).

## Verdicts (answered 2026-10-27, one sitting)

| Q       | Verdict                                                                                   | Routed                                                                   |
| ------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Q0      | **Go SSG** (recommendation accepted)                                                      | T57 unblocked; ROADMAP 848-line note updated                             |
| Q1      | **`website-template`**                                                                    | T57                                                                      |
| Q2      | **Go (stdlib-only)**                                                                      | T58                                                                      |
| Q3      | **Rebuild on template later**                                                             | ROADMAP note                                                             |
| Q4      | **Private, publishable later**                                                            | T57                                                                      |
| Q5      | **Keep T33 separate** (user delegated: "do what the smartest is" → recommendation stands) | T33 stays independent TODO                                               |
| B.g1    | **Stay Go-first**                                                                         | T34 unblocked; linter-building refs stay as-is                           |
| B.g2    | **Two-stage: eval→🟡, real→🟢**                                                           | T34 unblocked; FEATURES legend note; settles stack-selection's aging too |
| B.g3    | **Agent commits artifacts, detailed messages; daemon is floor**                           | AGENTS §7 note                                                           |
| C (T51) | **Verbatim lockstep** (overrides semantic recommendation)                                 | T51 unblocked → align all 7 glosses to the table                         |
| D.g1    | **Trash the backup** (executed 2026-10-27 via `trash`)                                    | ROADMAP g1 closed                                                        |
| D.g2    | **Stay upstream-managed**                                                                 | ROADMAP g2 closed                                                        |
| D.g3    | **Pre-commit hook in this repo**                                                          | ROADMAP g3 closed; hook task created                                     |
| D.g4    | **Default .md**                                                                           | status-report skill default amended; ROADMAP g2 (2026-08-16) closed      |

Every question has a verdict. Package complete; execution per plan P7–P14.
