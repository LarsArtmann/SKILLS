<!-- AGENTS.md template, copy into the project root and fill in.
     This is CONCISE, ENDURING CONTEXT for AI agents.
     Only things hard to discover from code. No changelogs, no task lists.
     See docs-health/SKILL.md. -->

# AGENTS.md, Project Name

> Context for AI agents working in this repository.

## Project Type and Purpose

One paragraph: what kind of project, what it produces, what it does NOT produce.

## Directory Structure

```
project/
├── src/            # one-line annotation
├── tests/          # one-line annotation
├── docs/           # one-line annotation
└── flake.nix       # build and task automation
```

## Conventions

- **Naming:** patterns used in the codebase
- **Code style:** functional/imperative, error handling approach
- **Testing:** framework, file naming, test structure

## Build and Test Commands

```bash
nix build          # build
nix run .#test     # test
nix run .#lint     # lint
```

## Gotchas

- **Non-obvious behavior X:** explanation and workaround
- **Platform quirk Y:** what happens on which OS

## High-Value References

| File | Why it matters |
| ---- | -------------- |
| `docs/DOMAIN_LANGUAGE.md` | Domain vocabulary |
| `FEATURES.md` | Feature inventory with honest status |
| `docs/adr/` | Architecture decisions |

---

<!-- Guidance for the builder:
  - Every referenced path must exist. Verify after writing.
  - Commands must actually work. Test them.
  - Counts must be computed, not hardcoded. Point at a command.
  - Keep it LEAN: only things hard to discover from code.
  - Do NOT put: change logs (CHANGELOG.md), tasks (TODO_LIST.md),
    feature status (FEATURES.md), domain terms (DOMAIN_LANGUAGE.md).
-->
