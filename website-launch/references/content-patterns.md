# Content Patterns — What "Nice" Documentation Actually Writes

> Stack-independent patterns that separate a polished docs site from a
> scaffolded one. These are about _what content to write_, not which
> framework renders it. Load this reference whenever authoring or
> auditing docs pages or a README.

The patterns below are modeled on best-in-class docs sites (e.g. the
Nextra-based SP8D docs, Turborepo, Bun, SWC, Zig). They cost minutes to
write and are the single biggest lever for making a site feel
professional and trustworthy. Every one is achievable in Starlight
without a framework switch.

## Why these patterns matter

A visitor lands on a docs page with three questions, in order:

1. **Is this for me?** → answered by "Who is this for?"
2. **Should I trust it?** → answered by "When NOT to use this" + comparison tables
3. **What do I do next?** → answered by curated "Where to go next"

Most scaffolded sites answer only the implicit "what does this do?" and
lose the reader. These three patterns close that gap.

---

## 1. "Who is this for?" — audience targeting

State the audience explicitly, as named personas. This is the fastest
way to tell a visitor whether to keep reading. Place it high — in the
README right after "Why?", and as a callout near the top of the
intro/"what is this" docs page.

```markdown
## Who is this for?

- **Backend engineers** who need structured errors without a framework.
- **API authors** who want typed error envelopes for OpenAPI generation.
- **Teams replacing `fmt.Errorf` chains** with something diagnosable in prod.
```

Rules:

- Name the **role**, not the task ("API authors", not "people who write APIs").
- 3–5 personas. More than 5 means the project lacks focus.
- One concrete pain point per persona. Vague personas ("developers")
  are useless — everyone says "developers".

---

## 2. "When NOT to use this" — the trust pattern

The single highest-leverage trust signal in technical docs. A project
that states its own limits is a project that tells the truth everywhere
else. Place it in the README before "Install", and as its own short
docs page or callout.

```markdown
## When NOT to use this

Skip this library if:

- You need **unbounded message queues** — this is strictly bounded/backpressured.
- You are on a **runtime without `SharedArrayBuffer`/`Atomics`** (very old browsers, locked-down CSP).
- You have a **single producer/consumer with zero contention** — the stdlib is enough.
```

Rules:

- Be **specific** about the environment or requirement that rules it out,
  not abstract ("it's not for everyone").
- Name the **alternative** the reader should reach for instead ("use the
  stdlib", "use X instead"). Sending a user away kindly is the strongest
  trust builder.
- 3–5 bullets. If you can't list _any_, you don't understand your scope.

---

## 3. Comparison tables inside docs pages (not just the landing page)

The landing-page comparison matrix sells the project; the docs-page
comparison matrix _teaches_ it. Repeat the X-vs-Y table inside the
relevant docs page (e.g. on the "concurrency model" or "alternatives"
page), expanded with a prose explanation of each row.

Use glyphs, not words, for scannability:

```markdown
| Feature              | postMessage | MessageChannel | BroadcastChannel | This lib |
| -------------------- | :---------: | :------------: | :--------------: | :------: |
| Lock-free            |             |                |                  |    ✓     |
| Bounded/backpressure |             |                |                  |    ✓     |
| Observable           |             |                |                  |    ✓     |
| Multi-producer/conns |   complex   |    complex     |        ✓         |    ✓     |
```

Legend: `✓` supported · blank not supported · word = partial/conditional.

Rules:

- Order columns from "most familiar alternative" → "this project" (rightmost).
- Use the **same row set** on landing and docs page so the reader builds one mental model.
- Add a sentence under the table explaining the _one_ row that is the real differentiator.

---

## 4. Curated "Where to go next" per page

Starlight renders prev/next pagination automatically, but a **hand-picked
next-steps list** tailored to the page beats linear pagination. Put it at
the bottom of every docs page, ordered by the most likely reader path.

```markdown
## Where to go next

- [Minimal example](/quickstart/minimal-example/) — see it in 10 lines
- [Channel API reference](/api-reference/channel-api/) — every method, every flag
- [Fairness & backpressure](/principles/fairness-backpressure/) — why it never drops
- [FAQ & troubleshooting](/guides-and-howtos/faqs/) — common gotchas
```

Rules:

- 4–6 links, not the whole sidebar.
- Annotate each link with **why** the reader would click it ("see it in
  10 lines", "why it never drops") — never just bare titles.
- Order by the natural learning path, not by sidebar position.

---

## 5. Per-page feedback + "Edit this page" links

Every docs page should offer a frictionless path from "I have a
question" to "I opened an issue / PR". This is the #1 contributor-acquisition
lever and it is nearly free.

In Starlight, enable it in `astro.config.mjs` (see SKILL.md §3.10):

```js
editLink: {
  baseUrl: 'https://github.com/LarsArtmann/{repo}/edit/main/website',
}
```

This renders an "Edit this page" link on every doc. Pair it with a
feedback link pointing to the issue tracker with a pre-filled title. A
reader who spots a typo should be one click from fixing it.

---

## 6. Callouts for scanability

Use Starlight callouts (`:::note`, `:::tip`, `:::caution`, `:::danger`)
to make warnings and tips visually distinct from prose. Readers scan;
callouts are the things they actually read.

```mdx
:::caution
Characters `<`, `>`, `<=`, `>=` break `.mdx` parsing. Escape them or rephrase.
:::

:::tip
Run `nix flake check` before every commit — it catches the 80% case.
:::
```

Rules:

- Reserve `:::danger` for data-loss or security risks only. Inflation
  destroys the signal.
- One idea per callout. A callout with three paragraphs is just prose
  with a border.
- Never put the only copy of a requirement inside a callout — callouts
  are emphasis, not structure.

---

## 7. Last-updated timestamps and reading time

Two small signals that compound: a "last updated" date tells the reader
the page is alive; a reading-time estimate tells them whether to start
now or bookmark. Starlight supports both natively (see SKILL.md §3.10).

Enable `lastUpdated: true` in Starlight config — it reads git history,
so it costs zero authoring effort and is always accurate.

---

## Retrofitting existing sites

When the skill runs against an _existing_ website (maintenance mode,
SKILL.md Phase 0.0), check each docs page and the README for these eight
patterns and add the missing ones. This is how every existing
implementation inherits the improvements without a rebuild:

- [ ] README has a "Who is this for?" section (3–5 named personas)
- [ ] README has a "When NOT to use this" section (3–5 specific exclusions + alternatives)
- [ ] At least one docs page repeats the comparison table with prose
- [ ] Every docs page ends with a curated 4–6 link "Where to go next"
- [ ] `editLink` is enabled in Starlight config
- [ ] Warnings/tips use callouts, not bold text
- [ ] `lastUpdated: true` is set in Starlight config
- [ ] Demo video: present, selling (poster + `#demo` anchor + README
      "Watch the demo" link in the documentation bar), and still matches the
      README "Why?" — videos rot; audit the narrative, not just the
      file's existence (see `demo-video.md`)
