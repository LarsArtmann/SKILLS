# 2026-10-30 02:15 — modern-web-guidance: routing skill for Chrome's web-platform guide library

Scope: THIS session. User ask: **"Add https://developer.chrome.com/docs/modern-web-guidance"**,
with the standing instruction to break it into steps, execute and verify each.

Interpretation (no ambiguity worth a round-trip): this repo collects Agent
Skills for Crush, and MWG is itself an agent-skill library that Google ships and
updates continuously. "Add" therefore means **add a skill to this repo that
routes web-platform work into that library** — not vendoring Google's guide
prose (which would stale weekly) and not silently installing a third-party
plugin onto the machine.

## What was built

New `modern-web-guidance/` (34th repo skill).

| File | Content |
| --- | --- |
| `modern-web-guidance/SKILL.md` | 111 lines: verification-status table, the 5-step search → retrieve → apply loop, command surface, install-vs-npx decision, Baseline discipline, 12-row legacy-default → modern-API table, 6 failure modes, related skills |
| `modern-web-guidance/references/guide-catalog.md` | 383 lines: 59-row intent → guide-ID routing table, category map with counts, full inventory of all 192 IDs, regeneration procedure, docs-vs-CLI coverage gap |
| `modern-web-guidance/references/cli-reference.md` | 152 lines: two verification tables, command surface, install modes, 11-agent install matrix, upstream troubleshooting, gotchas |

## Research findings now encoded

- **The library is bigger than the documentation.** Live `list` returned **192
  use cases across 16 categories**; the rendered docs index showed 12. Absent
  from the site on 2026-10-30: `built-in-ai`, `privacy`, `pwa`, `webmcp`. The
  docs landing page still says "over 100 web development use cases".
- **Guides carry the compatibility contract, not just code.** Retrieved guides
  contain `Baseline status for <feature>: <status>. It's been Baseline since
  <date>`, `Browser support for <feature>: <status>`, and a "Fallbacks & browser
  support" section with the exact degradation. The `dialog` guide is the sharpest
  example: it forbids `role="dialog"`/`aria-modal`/focus traps on native
  modals, forbids `overflow: hidden` on `html`/`body` as a scroll lock, and
  warns that `@supports` cannot detect ignored `overscroll-behavior`.
- **Guides cross-reference each other by ID** (`retrieve "other-id"` hints), so
  one retrieval often implies a second for a two-concern task.
- **The CLI ships the skill inside the package** (bin resolves to
  `skills/modern-web-guidance/modern-web.mjs`), which is why `install` needs no
  second download.

## Verification log (every claim, with its command)

| Check | Result |
| --- | --- |
| `npm view modern-web-guidance version dist-tags bin` | `0.0.196` latest; bin → `skills/modern-web-guidance/modern-web.mjs` |
| `npx -y modern-web-guidance@latest --help` | exit 0; `search`, `list`, `retrieve`, `install`, `uninstall`, `update`, `--choose`, `--skill-version` |
| `npx -y modern-web-guidance@latest list` | exit 0; JSON array, 192 items, 16 categories (accessibility 4, built-in-ai 4, css 18, forms 19, html 8, js 5, performance 26, privacy 1, pwa 1, security 17, ui-atoms 12, ui-behaviors 37, ui-components 14, visual-design 22, wasm 1, webmcp 3) |
| `npx -y modern-web-guidance@latest search "scroll driven animation"` | JSON with `id, description, category, featuresUsed, tokenCount, similarity`; 5 results |
| `npx -y modern-web-guidance@latest retrieve "not-a-real-guide-id"` | exit 1, `Retrieve failed for ...: Error: No guide found for use case: ...` |
| `retrieve "animate-to-from-top-layer"`, `"dialog,style-parent-with-has"`, `"passkey-authentication"`, `"animate-to-intrinsic-sizes"`, `"branded-select-styling"`, `"same-document-transitions"`, `"calculate-event-differentials"`, `"scrollytelling"` | Markdown guides; Baseline + fallback sections confirmed |
| Mechanism spot-checks (`interpolate-size`/`calc-size()`, `:has(:user-invalid)`, `appearance: base-select`, `document.startViewTransition`, `Temporal.*`, `overscroll-behavior` on `:modal` + `::backdrop`) | all present in the retrieved guides, so the SKILL.md replacement table cites guides rather than recall |
| `scripts/check-skills.sh` | **exit 0** — 34 skills, 0 thin, TOC + links + FEATURES coverage + fan-out green |
| `scripts/check-skills.sh --triggers` | modern-web-guidance: markers=10, STRONG, description 897 chars (<1024 cap) |
| `scripts/check-skills.sh --signal` | preamble 7 words, 1 advisory prose block, filler 0, jargon 0 |
| `scripts/link-skills-to-agents.sh` | `~/.agents/skills/modern-web-guidance` → `../../projects/SKILLS/modern-web-guidance`; read back through the fan-out path |
| `crush_info` skills list | **does not yet show the skill** — the list is captured at session start; a restart is required for this session's UI, the on-disk link is correct |

Not executed, therefore marked **docs-only** in both verification tables:
`npx modern-web-guidance@latest install` / `--choose` / `update` / `uninstall`,
and the per-agent plugin commands. Read from the get-started page on
2026-10-30; the reference tells the next session to copy them from the page
instead of retyping.

## Wiring checklist (`how-to-write-skills.md` new-skill list)

| Item | Status |
| --- | --- |
| `SKILL.md` + `references/` | ✅ |
| README row + section | ✅ new "Web Platform & Frontend" section |
| README status counts | ✅ "Eight skills are 🆕 New" → "Nine", inserted alphabetically |
| FEATURES.md row (gated by check 14) | ✅ new "Skill Collection — Web Platform & Frontend" section, 🆕 `NEW` |
| CHANGELOG entry | ✅ `### Added (2026-10-30 — modern-web-guidance routing skill)` |
| AGENTS.md §5.5 graph entry | ✅ layering vs `frontend-design`, `website-launch`, `html-report-kit`; "do not author a rival platform-best-practices skill" |
| `docs/external-dependencies.md` | ✅ npm package row with the verified CLI facts |
| Two-way description disambiguation | ⚠️ one-way by necessity — `frontend-design` is third-party (lockfile-managed), so only our description carries the pointer |
| ROADMAP reconciliation | ✅ grepped; nothing pre-existing on web-platform guidance, nothing to mark |
| `link-skills-to-agents.sh` | ✅ |
| Structural + trigger checks | ✅ exit 0, no new warnings |

## Decisions and why

- **Routing layer, not a vendored copy.** Copying guide prose into this repo
  would create a second source of truth that rots with every Google release;
  `guide-catalog.md` carries only IDs, which fail loudly (exit 1) instead of
  silently disagreeing with upstream.
- **`npx` as the default invocation.** It needs no install and always serves the
  current guides; `install` is documented as Google's recommendation because it
  auto-updates, but was not executed here (it mutates the machine's skill set).
- **No `evals/`.** A behavioural eval needs subagent runs against real prompts;
  the skill starts 🆕 per the two-stage aging rule (synthetic eval → 🟡, real
  triggered run → 🟢) rather than claiming depth it has not demonstrated.
- **No `--skill-version` guidance.** The help calls it internal; setting it by
  hand can pin stale guidance, so the reference says not to.

## Known gaps / next steps

1. **First real triggered run** — ask for a dialog/animation/LCP change in a
   real project and record whether `search`/`retrieve` actually fires. That run
   is what ages the skill 🟡/🟢.
2. **Optional behavioural eval** — the natural fixtures are (a) "make this
   legacy modal accessible without a JS focus trap", (b) "animate an accordion
   opening", (c) "our INP is bad on the filter panel". Baselines would be
   authored as div-and-`max-height` implementations.
3. **Install decision for Crush** — whether to run
   `npx modern-web-guidance@latest install` so the guides self-activate without
   this skill's routing. Deliberately left to the user (machine-level state).
4. **Catalog refresh** — `list` is JSON; the regeneration procedure is in
   `guide-catalog.md`. Re-run when the CLI crosses a few versions; the routing
   table must be re-validated against new IDs, not trusted.

## Evidence and its durability

- `/tmp/mwg-list.json` (raw `list` output, 192 items) and `/tmp/gen_catalog.py`
  (the generator that asserted every routed ID exists) were used this session
  and are **not committed** — both are regenerable with the commands in
  `guide-catalog.md` §Regenerating this file, so no artifact cited here depends
  on their survival.
- The auto-commit daemon committed the authored files mid-session
  (`ab35eee`, 6 files); per AGENTS §7 the agent may commit its own artifacts,
  but the user did not ask for a commit, so no hand-authored commit was made.
