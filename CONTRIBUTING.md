# Contributing

Thanks for your interest in contributing!

## How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Development Setup

This is a **content repository** — there is no build system, no package manager,
no test suite, and no compilable code. The markdown files ARE the product.

Validate your changes with the structural checker:

```bash
scripts/check-skills.sh          # validate all skills (frontmatter, line count, name-dir match)
scripts/check-skills.sh --thin   # list thin skills only
scripts/sync-html-kit.sh --check # verify vendored HTML kit copies are not drifted
```

## Reporting Issues

Please use GitHub Issues to report bugs or request features.
