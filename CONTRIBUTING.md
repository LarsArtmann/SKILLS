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
scripts/check-skills.sh               # validate all skills (frontmatter, trigger-first
                                      #   descriptions, line count, name-dir match,
                                      #   internal links, TOC drift, regression guards)
scripts/check-skill-links.sh          # broken-link detail view (all skill .md files)
scripts/check-skills.sh --thin        # list thin skills only
scripts/sync-html-kit.sh --check      # verify vendored HTML kit copies are not drifted
```

## Adding a New Skill

1. **Read the authoring guide first:** [`how-to-write-skills.md`](./how-to-write-skills.md).
   The `description` frontmatter is **trigger context** (tells the agent WHEN to
   activate the skill), not a description of the skill — the checker rejects
   description-first openings like "Reviews...".

2. **Create the directory** named exactly like the skill (lowercase, hyphens):
   `my-skill/SKILL.md` (YAML frontmatter with `name:` matching the directory)
   plus optional `references/`, `scripts/`, `rules/`, `assets/` subdirectories.
   Study `how-to-golang` (rich, reference-heavy) or `architecture-visualization`
   (short, single-purpose) as patterns.

3. **If the skill produces HTML reports**, reference the vendored kit:
   `./assets/html-report-kit/...`, then run `scripts/sync-html-kit.sh` to
   populate the vendored copy (it auto-discovers SKILL.md files mentioning
   `html-report-kit`). Never edit a vendored copy — edit `html-report-kit/`
   and re-sync.

4. **Link it live** (symlink, not copy — the repo is the single source of truth):

   ```bash
   scripts/link-skills-to-agents.sh          # creates ~/.agents/skills/<skill> -> repo
   scripts/link-skills-to-agents.sh --check  # CI: verify all links correct
   ```

   If `skills add` ever replaces the symlink with a real directory, recover
   with `scripts/link-skills-to-agents.sh --force` (moves the real dir aside
   to `<name>.replaced-<timestamp>` — nothing is deleted).

5. **Update the inventory:** add a row to the skills table in `README.md`
   (do not hardcode a skill count anywhere — the checker enforces this).

6. **Validate everything:**

   ```bash
   scripts/check-skills.sh
   ```

## Reporting Issues

Please use GitHub Issues to report bugs or request features.
