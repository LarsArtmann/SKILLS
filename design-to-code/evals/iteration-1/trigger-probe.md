# Natural-trigger probe (iteration-1 addendum)

**Date:** 2026-11-03 · **Session:** fresh `crush run`, scratch dir `/tmp/dtc-trigger-probe`
**Duration:** 94 s · exit 0

## Prompt (verbatim)

> I need a React badge component for a Tailwind v4 app. File: StatusBadge.tsx
> in the current directory. It takes a status prop of type success, warning,
> error, or info; each status has its own pill color (green, amber, red,
> blue). Render the status text in a rounded pill. Create the file, then
> print one final line starting with SKILLS-USED: followed by the
> comma-separated names of any skills you loaded this session, or NONE.

No skill was named, hinted, or path-referenced. The only steering is the
disclosure request at the end (caveat below).

## Result

```
SKILLS-USED: design-to-code, modern-web-guidance
```

**`design-to-code` triggered naturally on a real frontend task.** The
session's own transcript shows which skill governed which decision:

| Decision | Owned by | Evidence in transcript |
| -------- | -------- | ---------------------- |
| No existing design system → compose utilities in markup, no token invention | design-to-code Step 1/3 | "No existing design system in this directory … compose standard Tailwind utilities in markup" |
| Class names written as complete static strings | design-to-code Step 4.3 gotcha | "every class name written as complete static strings per the Tailwind v4 scanning gotcha" |
| Text contrast on colored pills (fixed bg → hard-coded contrasting text) | modern-web-guidance (`contrast-color` guide) | "-100 bg + -800 text of the same hue … per the modern-web-guidance rule" |

## Routing verdict (report task 8, boundary test)

Both plausibly-competing skills loaded **together and complemented** — no
collision. design-to-code owned framework mechanics (scanner behavior,
token/abstraction decisions); modern-web-guidance owned the web-platform
concern (contrast). This matches the one-way disambiguation in the skill
description ("modern-web-guidance: web-platform APIs, not framework
mechanics").

## Caveats

- n=1. Disclosure-only meta-question; it cannot force a load, but a session
  asked to disclose skills may load more eagerly than one never asked.
- The first probe attempt (7 concurrent sessions) died on a provider rate
  limit; this serial rerun is the valid sample.
- Output file: `/tmp/dtc-trigger-probe/StatusBadge.tsx` (ephemeral; the
  transcript quote above is the persisted evidence).
