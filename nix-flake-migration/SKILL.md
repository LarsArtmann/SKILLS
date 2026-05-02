---
name: nix-flake-migration
description: Creates a migration proposal from justfile and shell scripts to nix flakes. Use when the user wants to plan or start migrating a project from justfile/makefile/shell scripts to nix flake-based build automation, or says "nix flake migration".
metadata:
  tags: nix, flakes, migration, build, justfile
---

# Nix Flake Migration

## Process

1. If we already have a `MIGRATION_TO_NIX_FLAKES_PROPOSAL.md`: STOP! Do not overwrite.
2. Otherwise: Review `Justfile` and all `.sh` scripts and whatever else might be of interest
3. Write a detailed `MIGRATION_TO_NIX_FLAKES_PROPOSAL.md` report

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
