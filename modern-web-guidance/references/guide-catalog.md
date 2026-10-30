# Guide Catalog — Modern Web Guidance

Snapshot of the Modern Web Guidance use-case library, taken 2026-10-30 from
`npx -y modern-web-guidance@latest list` (CLI v0.0.196): **192 use cases in 16
categories**. Google adds guides continuously, so treat this file as the offline
map and the CLI as the live truth: run `list` or `search` before trusting any
count here.

## Contents

1. [How to read this file](#how-to-read-this-file)
2. [Route by intent](#route-by-intent)
3. [Category map](#category-map)
4. [Full inventory](#full-inventory)
5. [Coverage gaps vs the docs site](#coverage-gaps-vs-the-docs-site)

---

## How to read this file

Search first (`search "<intent>"`), then read the guide (`retrieve "<id>"`).
Use this file when search is not finding the right guide, when the CLI is not
available, or when you need to know whether a topic is covered at all.

The inventory lists IDs only; the prose lives in the guides. An ID is not a
recommendation: the guide's own `Overview` decides whether the pattern fits your
task, and its Baseline section decides whether you can ship it.

## Route by intent

Left column is what the user asked for; right column is what to retrieve. Pass
two or three IDs to one `retrieve` call; more than that is context bloat.

| Intent | Guide IDs |
| --- | --- |
| Modals, dialogs, confirmations | `dialog`, `light-dismiss-a-dialog`, `prevent-page-scroll-under-modal-dialog` |
| Animate a dialog/popover/tooltip in and out of the top layer | `animate-to-from-top-layer`, `animate-element-entry-exit` |
| Open a dialog/popover from a button without JavaScript | `declarative-dialog-popover-control`, `custom-button-actions` |
| Non-blocking panel: find bar, inspector, command palette | `dialog`, `persistent-top-layer-ui` |
| Tooltip on hover or focus | `interest-triggered-tooltips`, `position-aware-tooltips` |
| Dropdown menu, selectable menu, viewport-aware popup | `menu`, `viewport-aware-dropdowns` |
| Toast / snackbar notifications | `persistent-toast-notifications` |
| Hover preview card (hovercard) | `hovercard` |
| Side navigation drawer | `navigation-drawer` |
| Dismiss with Esc or the platform back gesture | `platform-controls-dismiss-dialog` |
| Page or route transition, SPA or cross-document | `same-document-transitions`, `cross-document-transitions`, `directional-navigation-transitions`, `consistent-cross-document-transitions` |
| Faster view transitions in a SPA | `faster-spa-view-transitions` |
| Staggered reveal of sibling elements | `dynamic-sibling-animations` |
| Scroll-driven animation, progress indicator, scrollytelling | `scrollytelling`, `scroll-progress-indicator`, `shrinking-header-on-scroll`, `parallax-scroll-effects` |
| Element enters/leaves the scrollport | `scroll-entry-exit-effects` |
| Natural, physical-feeling easing | `physics-based-easing`, `motion` |
| Drag an element, swipe to reveal or remove, 2D pan | `drag`, `swipe-to-reveal`, `swipe-to-remove`, `2d-panning` |
| Reparent an element without losing its state | `move-dom-element-without-losing-state` |
| Component adapts to its own width (card, dashboard tile) | `size-aware-styling`, `responsive-design`, `css-layout` |
| Animate to/from `auto` or intrinsic sizes (accordion, disclosure) | `animate-to-intrinsic-sizes`, `calculate-with-intrinsic-sizes` |
| Style a parent based on child state or content | `style-parent-with-has`, `child-state-based-styling`, `content-based-styling` |
| Style siblings by count or index | `dynamic-sibling-styling` |
| Design tokens, themes, density modes, component variants | `css`, `design-token-reactivity`, `usage-aware-component-variations` |
| Dark mode and light/dark toggles | `dark-mode`, `dark-mode-toggle`, `component-specific-light-dark-theme` |
| Typography: text-wrap, line height trimming, alignment | `typography`, `improve-text-layout-and-legibility`, `equal-width-text-lines`, `precise-text-alignment` |
| Font fallback that does not shift layout | `visually-stable-font-fallbacks`, `visually-stable-mixed-fonts` |
| Color: modern spaces, contrast-safe text over dynamic backgrounds | `color`, `contrast-color` |
| Scrollbars and browser-generated UI theming | `customize-scrollbar-color-and-thickness`, `adapt-scrollbar-to-contrast-preferences`, `browser-ui-theming` |
| Shapes, texture, decorative effects, canvas/WebGL | `complex-shapes`, `shaped-cutouts`, `visual-effects`, `visually-texture-content`, `soft-edge-content-fade`, `apply-webgl-shaders` |
| Sign-in, sign-up, payment, or address form done right | `autofill-sign-in-form`, `autofill-sign-up-form`, `autofill-payment-form`, `autofill-address-form` |
| Form validation timing and error feedback | `validate-input-after-interaction`, `required-field-feedback`, `accessible-error-announcement` |
| Branded `<select>` picker or rich option content | `branded-select-styling`, `animated-select-picker`, `rich-media-picker`, `custom-select-picker-layouts` |
| Switch, checkbox, or range slider styling | `switch`, `checkbox`, `slider`, `brand-consistent-forms` |
| Enter-to-submit that survives IME composition | `ime-safe-enter-submit` |
| SMS one-time-code verification | `sms-otp-form` |
| General form policy for a new or audited form | `forms` |
| Web Components: define, style, shadow DOM, accessibility | `web-components`, `custom-elements`, `shadow-dom`, `styling-web-components`, `accessible-web-components` |
| Custom control that participates in a `<form>` | `form-associated-custom-elements` |
| Server-render a custom element, then hydrate | `prerendering-custom-elements` |
| HTML semantics, native overlays, resource loading order | `html` |
| LCP: image, preload, and script priority | `optimize-image-priority`, `optimize-preload-priority`, `optimize-script-priority`, `improve-next-page-load-performance` |
| INP: long tasks, interaction cost in complex layouts | `identify-inp-causes`, `break-up-long-tasks`, `interactions-in-complex-layouts`, `schedule-tasks-by-priority` |
| Defer heavy rendering or background work | `defer-rendering-heavy-content`, `defer-work-until-scroll-ends`, `efficient-background-processing`, `detect-initial-visibility-state` |
| Analytics and telemetry that survives unload | `batch-analytics-events`, `full-session-analytics`, `calculate-total-foreground-time` |
| Lazy-load video and audio | `lazy-load-video-and-audio` |
| Stream HTML out of order | `out-of-order-html-streaming` |
| A/B test without a flash of the wrong variant | `flicker-free-client-side-ab-testing` |
| Passkeys: registration, sign-in, re-auth, management | `passkeys`, `passkey-registration`, `passkey-authentication`, `passkey-reauthentication`, `passkey-management`, `passkey-conditional-create`, `quick-sign-ins` |
| CSP, Trusted Types, sanitizing untrusted HTML | `trusted-types`, `security`, `sanitize-untrusted-html` |
| Validate origins and secure external subresources | `validate-origins`, `secure-external-subresources`, `restrict-outbound-connections` |
| Local Network Access prompts | `local-network-access` |
| Client-side encryption and signatures | `client-side-encryption`, `digital-signatures` |
| Verify email ownership | `verify-email-ownership` |
| Time zones, durations, calendars, high-precision timestamps | `calculate-event-differentials`, `coordinate-global-events`, `capture-location-agnostic-data`, `sort-high-precision-timestamps`, `support-global-calendar-systems` |
| On-device AI: prompt, summarize, translate, detect language | `language-model`, `summarizer`, `translator`, `language-detection` |
| Migrate a web app to a new origin | `migrate-web-app-origin` |
| Agent-facing tools and forms (WebMCP) | `webmcp`, `agentic-forms`, `agentic-javascript-tools` |
| Privacy guidance | `privacy` |
| Compile C/C++ to WebAssembly | `cpp-on-the-web` |

## Category map

| Category | Guides | Covers |
| --- | --- | --- |
| `accessibility` | 4 | semantic HTML, focus management, forms, media, ARIA, OS text scale |
| `built-in-ai` | 4 | on-device Prompt / Summarizer / Translator / LanguageDetector APIs |
| `css` | 18 | cascade, selectors, nesting, tokens, layout, intrinsic sizing, theming |
| `forms` | 19 | validation timing, autofill, custom selects, switches/sliders, OTP |
| `html` | 8 | semantics, native overlays, resource priority, custom elements + Shadow DOM |
| `js` | 5 | Temporal-based date, duration, calendar, and timestamp work |
| `performance` | 26 | LCP / INP / CLS, loading priority, long tasks, streaming, analytics |
| `privacy` | 1 | privacy disclosure guidance |
| `pwa` | 1 | installed-app concerns (origin migration) |
| `security` | 17 | passkeys/WebAuthn, CSP + Trusted Types, origin validation, WebCrypto |
| `ui-atoms` | 12 | small pieces: tooltips, carousels, progress, icons, sticky headers, tables |
| `ui-behaviors` | 37 | interaction + motion: dismissal, transitions, scroll effects, drag, snap |
| `ui-components` | 14 | whole components: dialog, menu, drawer, toast, hovercard, scrollspy |
| `visual-design` | 22 | color, typography, dark mode, shapes, effects, canvas/WebGL |
| `wasm` | 1 | compiling C/C++ with Emscripten |
| `webmcp` | 3 | agent-facing tools and forms (WebMCP) |

## Full inventory

Alphabetical within category. Every ID below resolved via live `list` on
2026-10-30; retrieve with `npx -y modern-web-guidance@latest retrieve "<id>"`.

### accessibility (4)

- `accessibility`
- `accessible-error-announcement`
- `accessible-generated-content`
- `respect-os-text-scale`

### built-in-ai (4)

- `language-detection`
- `language-model`
- `summarizer`
- `translator`

### css (18)

- `animate-to-intrinsic-sizes`
- `atrule-support-conditionals`
- `calculate-with-intrinsic-sizes`
- `child-state-based-styling`
- `content-based-styling`
- `css`
- `css-layout`
- `design-token-reactivity`
- `dynamic-sibling-styling`
- `fluid-scaling`
- `individual-transform-properties`
- `overflow-clipping-control`
- `reduce-style-repetition`
- `responsive-design`
- `selector-atrule-combinations`
- `size-aware-styling`
- `style-parent-with-has`
- `usage-aware-component-variations`

### forms (19)

- `animated-select-picker`
- `autofill-address-form`
- `autofill-highlight-inputs`
- `autofill-payment-form`
- `autofill-sign-in-form`
- `autofill-sign-up-form`
- `brand-consistent-forms`
- `branded-select-styling`
- `custom-select-picker-layouts`
- `form-fields-automatically-fit-contents`
- `forms`
- `ime-safe-enter-submit`
- `required-field-feedback`
- `rich-media-picker`
- `select-menu-interaction`
- `slider`
- `sms-otp-form`
- `switch`
- `validate-input-after-interaction`

### html (8)

- `accessible-web-components`
- `custom-elements`
- `form-associated-custom-elements`
- `html`
- `prerendering-custom-elements`
- `shadow-dom`
- `styling-web-components`
- `web-components`

### js (5)

- `calculate-event-differentials`
- `capture-location-agnostic-data`
- `coordinate-global-events`
- `sort-high-precision-timestamps`
- `support-global-calendar-systems`

### performance (26)

- `batch-analytics-events`
- `break-up-long-tasks`
- `calculate-total-foreground-time`
- `conditional-async-dependencies`
- `defer-rendering-heavy-content`
- `defer-work-until-scroll-ends`
- `deliver-optimized-decorative-images`
- `deprioritize-background-fetches`
- `detect-initial-visibility-state`
- `efficient-background-processing`
- `faster-spa-view-transitions`
- `flicker-free-client-side-ab-testing`
- `full-session-analytics`
- `identify-heavy-scripts`
- `identify-inp-causes`
- `improve-next-page-load-performance`
- `interaction-paint-timing`
- `interactions-in-complex-layouts`
- `lazy-load-video-and-audio`
- `optimize-image-priority`
- `optimize-preload-priority`
- `optimize-script-priority`
- `out-of-order-html-streaming`
- `performance`
- `resolution-optimized-pseudo-elements`
- `schedule-tasks-by-priority`

### privacy (1)

- `privacy`

### pwa (1)

- `migrate-web-app-origin`

### security (17)

- `client-side-encryption`
- `digital-signatures`
- `local-network-access`
- `passkey-authentication`
- `passkey-conditional-create`
- `passkey-management`
- `passkey-reauthentication`
- `passkey-registration`
- `passkeys`
- `quick-sign-ins`
- `restrict-outbound-connections`
- `sanitize-untrusted-html`
- `secure-external-subresources`
- `security`
- `trusted-types`
- `validate-origins`
- `verify-email-ownership`

### ui-atoms (12)

- `carousel-slide-effects`
- `component-specific-light-dark-theme`
- `icons`
- `position-aware-tooltips`
- `pull-to-reveal`
- `responsive-table`
- `scroll-position-aware-elements`
- `scroll-progress-indicator`
- `scrollability-affordance-hints`
- `shrinking-header-on-scroll`
- `state-aware-sticky-headers`
- `viewport-aware-dropdowns`

### ui-behaviors (37)

- `2d-panning`
- `anchor-positioning-tab-underline`
- `animate-element-entry-exit`
- `animate-to-from-top-layer`
- `carousel-snap-highlights`
- `consistent-cross-document-transitions`
- `cross-document-transitions`
- `custom-button-actions`
- `declarative-dialog-popover-control`
- `directional-navigation-transitions`
- `drag`
- `dynamic-sibling-animations`
- `group-element-transitions`
- `highlight-text-ranges`
- `interactive-content-reveal`
- `interest-triggered-action-previews`
- `interest-triggered-tooltips`
- `light-dismiss-a-dialog`
- `motion`
- `move-dom-element-without-losing-state`
- `parallax-scroll-effects`
- `persistent-top-layer-ui`
- `physics-based-easing`
- `platform-controls-dismiss-dialog`
- `prevent-page-scroll-under-modal-dialog`
- `same-document-transitions`
- `scoped-component-transitions`
- `scroll-completion-effects`
- `scroll-entry-exit-effects`
- `scroll-snap-realtime-feedback`
- `scroll-snap-state-sync`
- `scroll-target-on-load`
- `scrollytelling`
- `search-hidden-content`
- `spatial-navigation`
- `swipe-to-remove`
- `swipe-to-reveal`

### ui-components (14)

- `card`
- `checkbox`
- `dark-mode-toggle`
- `dialog`
- `hovercard`
- `menu`
- `navigation-drawer`
- `persistent-app-tours`
- `persistent-toast-notifications`
- `progress`
- `progress-ring`
- `scrollspy`
- `spinner`
- `stack-drill-down`

### visual-design (22)

- `adapt-scrollbar-to-contrast-preferences`
- `apply-webgl-shaders`
- `browser-ui-theming`
- `color`
- `complex-shapes`
- `contrast-color`
- `custom-text-decorations`
- `customize-scrollbar-color-and-thickness`
- `dark-mode`
- `equal-width-text-lines`
- `export-html-media-from-canvas`
- `expose-canvas-content-to-browser-features`
- `improve-text-layout-and-legibility`
- `interactive-content-in-3d-scenes`
- `precise-text-alignment`
- `shaped-cutouts`
- `soft-edge-content-fade`
- `typography`
- `visual-effects`
- `visually-stable-font-fallbacks`
- `visually-stable-mixed-fonts`
- `visually-texture-content`

### wasm (1)

- `cpp-on-the-web`

### webmcp (3)

- `agentic-forms`
- `agentic-javascript-tools`
- `webmcp`

## Coverage gaps vs the docs site

The CLI ships more than the website documents. Fetched 2026-10-30, the
[guides index](https://developer.chrome.com/docs/modern-web-guidance/guides)
rendered 12 categories; `list` returned 16. Absent from the rendered index at
that date: `built-in-ai`, `privacy`, `pwa`, `webmcp`. The docs landing page
still says "over 100 web development use cases" while the CLI served 192. When
the two disagree, the CLI is authoritative, and `retrieve` works for the
categories the site does not render.
