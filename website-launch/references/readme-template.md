# README Template — Structure, Patterns, and Quality Bar

> Every LarsArtmann Go library README follows the same structure. This
> reference provides the exact section order, badge templates, and patterns
> to match the quality bar set by go-atomic-write and gogenfilter.

## Standard Section Order

```
1. Centered header (h1 align="center") with project name
2. Centered tagline (strong) — one sentence describing what it does
3. Centered badge row
4. Centered documentation links
5. --- separator
6. One-paragraph summary
7. ## Why?
8. ## Comparison (table)
9. ## How it works (numbered pipeline)
10. ## Install
11. ## Usage (minimal working example)
12. ## Configuration Options / API tables
13. ## Domain-specific sections (filters, middleware, types, etc.)
14. ## Advanced features (resilience, observability, etc.)
15. ## Benchmarks (table)
16. ## Dependencies (table)
17. ## Design Decisions (bullet list)
18. ## Error Handling
19. ## Development (Nix commands)
20. ## Examples (table)
21. ## API Stability
22. ## License
```

## Badge Template

Standard order: Go Reference | CI | Go Report Card | License: MIT.

```markdown
<p align="center">
<a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}"><img src="https://pkg.go.dev/badge/github.com/LarsArtmann/{repo}.svg" alt="Go Reference"></a>
<a href="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml"><img src="https://github.com/LarsArtmann/{repo}/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<a href="https://goreportcard.com/report/github.com/LarsArtmann/{repo}"><img src="https://goreportcard.com/badge/github.com/LarsArtmann/{repo}" alt="Go Report Card"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
</p>
```

For v2+ libraries, include `/v2` in the pkg.go.dev and Go Report Card URLs.

## Documentation Link Bar

Below the tagline, before the `---` separator:

```markdown
<p align="center">
<a href="https://{subdomain}.lars.software">Documentation</a> · <a href="https://pkg.go.dev/github.com/LarsArtmann/{repo}">API Reference</a>
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

## Comparison Table Pattern

Compare against raw alternatives and naive approaches. Use checkmarks and
blanks (not Yes/No text) for scannability:

```markdown
| Feature            | Raw fsnotify | Other wrappers | go-filewatcher |
| ------------------ | :----------: | :------------: | :------------: |
| Recursive watching |              |    Partial     |       ✓        |
| Built-in filters   |              |      Few       |      17+       |
```

## Dependencies Table Pattern

Always include a dependencies table — it builds trust:

```markdown
| Dependency                 | Purpose            |
| -------------------------- | ------------------ |
| [`fsnotify/fsnotify`](url) | Core file watching |
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
- [ ] Comparison table with at least 3 columns
- [ ] All code examples verified against Go source (`grep 'func FunctionName' *.go`)
- [ ] Time units correct (`time.Millisecond` not `time.Second`)
- [ ] Import path matches `go.mod` (include `/v2` if applicable)
- [ ] Dependencies table with links
- [ ] No emojis
- [ ] License section at the bottom
