---
name: modern-web-guidance
description: Use when building, modernizing, or reviewing any browser-facing UI — HTML/CSS/JS, dialogs, popovers, tooltips, dropdowns, menus, tabs, carousels, scroll effects, view transitions, animations, forms, tables, accessibility, LCP/INP, passkeys, CSP — and especially when about to hand-roll in JavaScript something the web platform now does natively. Retrieves Google Chrome's Modern Web Guidance library (192 Baseline-aware use-case guides) through the `modern-web-guidance` CLI and applies each guide's Baseline status and fallbacks. Also triggers on "modern web guidance", "is there a native way", "legacy modal/tooltip/menu migration", "improve my LCP/INP", "CSS anchor positioning", "view transitions", "customizable select", or any Web Components / Shadow DOM question.
metadata:
  tags: web, frontend, css, html, javascript, performance, accessibility, baseline, progressive-enhancement, dialogs, popovers
---

# Modern Web Guidance

Modern Web Guidance (MWG) is Google Chrome's skill library for web platform work: 192 use-case guides that name the native API for a concrete UI problem, show the code, and state the feature's Baseline status plus the fallback for older browsers. It exists because coding agents default to the web of 2015 — a `div` modal with a hand-written focus trap, a JS-positioned tooltip, a `max-height` animation hack — when `<dialog>`, the Popover API, CSS anchor positioning, and `interpolate-size` exist.

This skill is the routing layer: it tells you when the library has the answer, how to retrieve the right guide, and which part of the guide is load-bearing (Baseline status and fallbacks, not just the sample). The guides themselves stay outside this skill so they never go stale in a copy (see [./references/guide-catalog.md](./references/guide-catalog.md) for the offline catalog).

## Verification status

Canonical table per `verify-external-claims/SKILL.md` §5. The CLI is the fact source; anything below marked docs-only has not been executed here.

| Claim | Status | Source |
| --- | --- | --- |
| npm package `modern-web-guidance`, version `0.0.196` (latest) | ✅ Verified | `npm view modern-web-guidance version dist-tags`, 2026-10-30 |
| Command surface: `search`, `list`, `retrieve`, `install`, `uninstall`, `update` (`--choose`, `--skill-version`, `-h`, `-v`) | ✅ Verified | Live `npx -y modern-web-guidance@latest --help`, 2026-10-30 |
| `list` returns 192 use cases across 16 categories, JSON `{id, category, description}` | ✅ Verified | Live `list` run + per-category counts, 2026-10-30 |
| `search <query>` returns JSON with `id, description, category, featuresUsed, tokenCount, similarity` | ✅ Verified | Live `search "scroll driven animation"` / `"carousel scroll snap"`, 2026-10-30 |
| `retrieve <ids>` prints Markdown, comma-separated IDs accepted, output headed `--- Guide for <id> ---` | ✅ Verified | Live `retrieve "animate-to-from-top-layer"`, `"dialog,style-parent-with-has"`, 2026-10-30 |
| Unknown ID fails with exit 1 and `No guide found for use case: <id>` | ✅ Verified | Live `retrieve "not-a-real-guide-id"`, 2026-10-30 |
| Guides carry `Baseline status ... since <date>`, `Browser support for <feature>: <status>`, and a "Fallbacks & browser support" section | ✅ Verified | Retrieved `dialog`, `anchor-positioning-tab-underline`, `passkey-authentication`, `animate-to-intrinsic-sizes`, 2026-10-30 |
| `npx modern-web-guidance@latest install` is the recommended install and enables auto-updates; `--choose` opens an interactive wizard | ⚠️ Docs-only | developer.chrome.com/docs/modern-web-guidance/get-started, read 2026-10-30 — not executed here |
| Other agent channels (`npx skills add GoogleChrome/modern-web-guidance`, Claude/Codex/Copilot/Gemini plugin commands) | ⚠️ Docs-only | Same page, 2026-10-30 — copy the exact command from there, do not retype from memory |
| Docs site renders 12 of the 16 CLI categories (no `built-in-ai`, `privacy`, `pwa`, `webmcp`) | ✅ Verified | Fetched `/guides` index vs. live `list`, 2026-10-30 |

## The loop

1. **Name the platform capability, not the framework.** "Animate an accordion open" → intrinsic size animation. "Menu that flips when near the viewport edge" → anchor positioning. The search index is semantic, so intent words beat API names you half-remember.
2. **Search first, always.** `npx -y modern-web-guidance@latest search "accordion expand animation"` returns 5 candidates with `description`, `featuresUsed`, `tokenCount`, and a `similarity` score. Read descriptions to pick, and check `featuresUsed` — that line tells you which platform features the guide assumes your Baseline target must support.
3. **Retrieve 2–3, not 10.** `npx -y modern-web-guidance@latest retrieve "animate-to-intrinsic-sizes,size-aware-styling"`. Guides are 1–5k tokens each (`tokenCount` in the search output); pulling every hit buys context bloat, not accuracy. Guides cross-reference siblings as `retrieve "other-id"` hints — follow one when the task spans two concerns (e.g. a dialog that is also animated).
4. **Apply the guide's constraints verbatim, then its Baseline layer.** The `MANDATORY` / `DON'T` lines are the test assertions: a `<dialog>` must not also carry `role="dialog"` or a focus trap, `view-transition-name` must be unique per element per snapshot, `appearance: base-select` drops native mobile pickers. Then read the "Browser support" and "Fallbacks & browser support" sections and carry the fallback into the code.
5. **Verify in a browser**, at the project's target widths, with reduced motion on. A guide proves the platform can do it; only the browser proves your app does.

## Commands

Run through `npx` so no install is required and the guides are current:

| Goal | Command |
| --- | --- |
| Search by intent | `npx -y modern-web-guidance@latest search "<intent>"` |
| List every use case (JSON) | `npx -y modern-web-guidance@latest list` |
| Read one or more guides | `npx -y modern-web-guidance@latest retrieve "<id>[,<id>...]"` |
| Install for auto-updates | `npx modern-web-guidance@latest install` (add `--choose` to pick individual skills) |
| Update installed skills | `npx modern-web-guidance@latest update` |
| Remove installed skills | `npx modern-web-guidance@latest uninstall` |

Full flag surface, per-agent install commands, and troubleshooting: [./references/cli-reference.md](./references/cli-reference.md).

## Install, or not

- **Per-call `npx` (this skill's default):** zero install, always latest, needs network. npx caches the package, so repeat calls are fast.
- **`install`:** the documented recommendation, because it enables automatic updates. Installing MWG's own skill means the agent may activate it directly; this skill then still earns its place by carrying the offline catalog, the routing table, and the Baseline discipline.
- **Offline or air-gapped:** skip both and work from [./references/guide-catalog.md](./references/guide-catalog.md). Every ID is listed there; the prose lives in Google's repo.

## Baseline discipline (the part that gets skipped)

A guide that compiles on your machine is not a guide that ships to your users. Baseline is the compatibility contract, and MWG states it per feature.

- **Read the status line literally.** `Baseline status ... since 2025-12-12` means safe for a 2025 target. `Browser support for X: Limited availability` means X needs a fallback, and the guide usually names one.
- **Feature-detect behavior, not property support.** The `dialog` guide is explicit: `@supports` reports `overscroll-behavior` as supported even where non-scrollable containers ignore it, so the author must treat scroll containment as progressive enhancement rather than guard it.
- **One fallback per feature, from the guide.** Do not invent a polyfill strategy the guide warns against — the `dialog` guide specifically forbids `overflow: hidden` / `position: fixed` on `html`/`body` as a scroll lock, and forbids `@supports` detection for `closedby` light dismiss.
- **When the target is unknown, ask once and state the assumption.** Default to Widely available and mark features above it as enhancements with visible degradation. A "Newly available" API used silently against a Widely-available target is a production bug, not a modernization.

## Legacy default → modern replacement

The patterns agents still reach for, and what the guides say instead. Every row is backed by a retrieved guide, not recall.

| About to write | Write instead | Guide |
| --- | --- | --- |
| `div` modal with focus trap, `Esc` handler, `aria-modal` | `<dialog>` + `showModal()` (or `command="show-modal"`); the browser supplies inert page, top layer, `::backdrop`, focus return | `dialog` |
| `button.onclick = () => dialog.showModal()` | Invoker commands: `command` / `commandfor` attributes, no JS | `declarative-dialog-popover-control` |
| JS math to position tooltips, dropdowns, menus | Popover API + CSS anchor positioning | `interest-triggered-tooltips`, `menu`, `viewport-aware-dropdowns` |
| `requestAnimationFrame` scroll-linked animation | Scroll-driven animations (`animation-timeline`) | `scrollytelling`, `scroll-progress-indicator`, `scroll-entry-exit-effects` |
| A JS transition library for route/page changes | View Transitions (`document.startViewTransition`, `view-transition-name`) | `same-document-transitions`, `cross-document-transitions` |
| Viewport breakpoints inside a reusable card | Container queries / size-aware styling | `size-aware-styling`, `responsive-design` |
| Toggling a parent class when an input is invalid | `.parent:has(:user-invalid)` in CSS | `style-parent-with-has` |
| JS height measurement to animate `height: auto` | `interpolate-size: allow-keywords` + `calc-size()` | `animate-to-intrinsic-sizes` |
| `position: fixed` / `overflow: hidden` on `body` to lock scroll behind a modal | `overscroll-behavior: contain` on `dialog:modal` and `::backdrop` | `prevent-page-scroll-under-modal-dialog` |
| A date library for timezone-safe differences | `Temporal.ZonedDateTime` / `Temporal.Duration` + `Intl.DurationFormat` | `calculate-event-differentials` |
| Rebuilding `<select>` from divs for brand styling | `appearance: base-select` + `::picker(select)` | `branded-select-styling`, `rich-media-picker` |
| A custom checkbox/switch/range control | Native control + `appearance`/`accent-color`, styled non-destructively | `checkbox`, `switch`, `slider`, `brand-consistent-forms` |

Route a specific request to guide IDs with [./references/guide-catalog.md](./references/guide-catalog.md) §Route by intent.

## Failure modes

| Symptom | Cause and move |
| --- | --- |
| `retrieve` exits 1: `No guide found for use case: <id>` | The ID was invented or remembered from another session. Run `search` and copy the exact `id` from its output. |
| Code from the guide fails to compile or looks unstable | The guide targets the latest platform. Check its Baseline lines and the "Fallbacks" section before adapting; do not "fix" a guide by removing the constraints it calls `MANDATORY`. |
| Search returns plausible neighbours, not the feature needed | Add concrete UI words from the task ("drawer", "wizard", "hover preview", "sticky table header"), not framework names. |
| Guide retrieved twice with different content | The CLI updated. Re-retrieve rather than trusting a pasted copy; treat the CLI as authoritative. |
| Agent applies `base-select` or `interpolate-size` and the UI regresses on older browsers | No fallback was carried over. The guide names the degradation (OS picker, instant size jump); take it. |
| Task is framework-specific (React state, Svelte stores, templ + HTMX wiring) | MWG stops at the platform boundary. Use it for the platform layer, then the framework's own patterns. |

## References

- [./references/guide-catalog.md](./references/guide-catalog.md) — all 192 guide IDs by category plus an intent → ID routing table. Read when offline or when search is not surfacing the right guide.
- [./references/cli-reference.md](./references/cli-reference.md) — verified command surface, per-agent install matrix, troubleshooting, and the docs-vs-CLI coverage gap.

## Related skills

- **frontend-design** (third-party, installed separately): visual direction and taste. This skill decides which platform feature to use, not how it should look.
- **website-launch**: building and deploying the docs site itself; MWG still owns the CSS/HTML/platform layer of what it renders.
- **html-report-kit**: the shared report CSS. Use MWG when changing report behaviour (dialog, toast, scrollspy, container queries), not just its tokens.
- **verify-external-claims**: apply it to any guide claim you copy into a doc; the CLI is the primary source, this skill's catalog is a dated snapshot.
