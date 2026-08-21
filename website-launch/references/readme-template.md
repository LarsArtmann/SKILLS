# README Template — Structure, Patterns, and Quality Bar

> Every LarsArtmann Go library README follows the same structure. This
> reference provides the exact section order, badge templates, and patterns
> to match the quality bar set by go-atomic-write and gogenfilter.
>
> For the full set of content patterns (audience targeting, "when not to use",
> curated next-steps, callouts, feedback links), see
> [`content-patterns.md`](./content-patterns.md).

## Standard Section Order

```
1. Centered header (h1 align="center") with project name
2. Centered tagline (strong) — one sentence describing what it does
3. Centered badge row
4. Centered documentation links
5. --- separator
6. One-paragraph summary
7. ## Why?
8. ## Who is this for? — named audience personas (3–5)
9. ## Comparison (table)
10. ## How it works (numbered pipeline)
11. ## When NOT to use this — specific exclusions + the alternative to reach for
12. ## Install
13. ## Usage (minimal working example)
14. ## Configuration Options / API tables
15. ## Domain-specific sections (filters, middleware, types, etc.)
16. ## Advanced features (resilience, observability, etc.)
17. ## Benchmarks (table)
18. ## Dependencies (table)
19. ## Design Decisions (bullet list)
20. ## Error Handling
21. ## Development (Nix commands)
22. ## Examples (table)
23. ## API Stability
24. ## License
```

## Badge Template

Standard order: Go Reference | CI | Go Report Card | License.

```markdown
<p align="center">
<a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}"><img src="https://pkg.go.dev/badge/github.com/LarsArtmann/{repo}.svg" alt="Go Reference"></a>
<a href="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml"><img src="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<a href="https://goreportcard.com/report/github.com/LarsArtmann/{repo}"><img src="https://goreportcard.com/badge/github.com/LarsArtmann/{repo}" alt="Go Report Card"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-{LICENSE}-blue.svg" alt="License: {LICENSE}"></a>
</p>
```

**License badge:** replace `{LICENSE}` with the license actually declared in
the LICENSE file. Do NOT assume MIT — verify first. Some projects are
proprietary.

For v2+ libraries, include `/v2` in the pkg.go.dev and Go Report Card URLs.

**Applications/servers:** replace the Go Reference badge with a Docker (or
GitHub Release) badge and omit pkg.go.dev — applications are not importable:

```markdown
<p align="center">
<a href="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml"><img src="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<a href="https://github.com/LarsArtmann/{repo}/pkgs/container/{repo}"><img src="https://img.shields.io/badge/docker-ghcr.io-blue.svg" alt="Docker"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-{LICENSE}-blue.svg" alt="License: {LICENSE}"></a>
</p>
```

## Documentation Link Bar

Below the tagline, before the `---` separator:

```markdown
<p align="center">
<a href="https://{subdomain}.lars.software">Documentation</a> · <a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}">API Reference</a>
</p>
```

Once the demo video exists (SKILL.md §3.11), append a third link with the real
runtime so GitHub visitors reach the product in motion in one click:

```markdown
<p align="center">
<a href="https://{subdomain}.lars.software">Documentation</a> · <a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}">API Reference</a> · <a href="https://{subdomain}.lars.software/#demo">Watch the 25s demo</a>
</p>
```

## Header Pattern

Use HTML alignment, not markdown headers, for the title section:

```markdown
<h1 align="center">{project-name}</h1>

<p align="center"><strong>{one-sentence-tagline}</strong></p>
```

## "Why?" Section Pattern

State the problem directly, then explain how this library solves it. Use
concrete failure modes, not abstract benefits:

```markdown
## Why?

Every `os.WriteFile` call has three failure modes that silently corrupt data.
This library eliminates all three with a minimal dependency footprint.
```

## "Who is this for?" Pattern

Name the audience as personas, not tasks. 3–5 personas, each with one
concrete pain point. Place it directly after "Why?".

```markdown
## Who is this for?

- **Backend engineers** who need structured errors without a framework.
- **API authors** who want typed error envelopes for OpenAPI generation.
- **Teams replacing `fmt.Errorf` chains** with something diagnosable in prod.
```

Avoid "developers" or "everyone" — useless personas signal an unfocused
project. See [`content-patterns.md`](./content-patterns.md) §1.

## Comparison Table Pattern

Compare against raw alternatives and naive approaches. Use checkmarks and
blanks (not Yes/No text) for scannability:

```markdown
| Feature            | Raw fsnotify | Other wrappers | go-filewatcher |
| ------------------ | :----------: | :------------: | :------------: |
| Recursive watching |              |    Partial     |       ✓        |
| Built-in filters   |              |      Few       |      17+       |
```

## "When NOT to use this" Pattern

The strongest trust signal in technical docs. Name the specific
environments or requirements that rule the project out, and point the
reader at the alternative they should use instead. Place it before
"Install".

```markdown
## When NOT to use this

Skip this library if:

- You need **unbounded message queues** — this is strictly bounded/backpressured.
- You are on a **runtime without `SharedArrayBuffer`/`Atomics`** (very old browsers, locked-down CSP).
- You have a **single producer/consumer with zero contention** — the stdlib is enough.
```

If you cannot list at least three honest exclusions, the project scope is
not yet understood. See [`content-patterns.md`](./content-patterns.md) §2.

## Dependencies Table Pattern

Always include a dependencies table — it builds trust:

```markdown
| Dependency                                                  | Purpose            |
| ----------------------------------------------------------- | ------------------ |
| [`fsnotify/fsnotify`](https://github.com/fsnotify/fsnotify) | Core file watching |
```

## What to Remove

If the existing README has any of these, remove them:

- Emoji in section headers (`## ✨ Features` → `## Features`)
- Emoji bullet points (`- **🎯 Zero Boilerplate**` → `- **Zero Boilerplate**`)
- Table of contents (GitHub renders at most 500 lines without one fine)
- "Made with heart" footer
- HTML emoji entities

## Quality Checklist

Before declaring the README done:

- [ ] Centered header with all 4 badges
- [ ] Documentation link to the website
- [ ] "Why?" section with concrete problem statement
- [ ] "Who is this for?" with 3–5 named personas (not "developers")
- [ ] "When NOT to use this" with at least 3 specific exclusions + alternatives
- [ ] Comparison table with at least 3 columns
- [ ] All code examples verified against Go source (`grep 'func FunctionName' *.go`)
- [ ] Time units correct (`time.Millisecond` not `time.Second`)
- [ ] Import path matches `go.mod` (include `/v2` if applicable)
- [ ] Dependencies table with links
- [ ] No emojis
- [ ] License section at the bottom
