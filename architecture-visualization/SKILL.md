---
name: architecture-visualization
description: Use when the user wants architecture diagrams, D2 diagrams, Events & Commands flow visualization, or wants to see how the system IS vs how it SHOULD BE architected. Also triggers when the user asks about system architecture, component relationships, service dependencies, or any visual representation of codebase structure. Generates D2 architecture diagrams for the current system and/or the ideal target architecture.
metadata:
  tags: architecture, d2, visualization, diagram, events, commands
allowed-tools: d2
---

# Architecture Visualization

Generate D2 diagrams that capture the current and ideal architecture. D2 produces cleaner layouts than Mermaid for complex graphs — use ELK engine for large architectures.

## Process

0. **Verify `d2` is available** before drawing anything: `command -v d2`. If
   it is missing, do not improvise a different diagram tool mid-task — the
   output format and layout contract below assume D2. Install per
   [./references/d2-syntax.md](./references/d2-syntax.md) → "Verify before
   you draw" (NixOS: `nix shell nixpkgs#d2`; Go toolchain:
   `go install oss.terrastruct.com/d2@latest`) and tell the user which
   install path you used. Gate each render on the CLI's exit code.
1. Research the codebase thoroughly before drawing. Use the shape, connection, and style vocabulary from [./references/d2-syntax.md](./references/d2-syntax.md) — every snippet there renders on d2 v0.8.x.
2. Generate the CURRENT state diagram:

   Write D2 source to: `docs/architecture-understanding/<YYYY-MM-DD_HH_MM-SESSION_NAME>.d2`
   Render to SVG: `docs/architecture-understanding/<YYYY-MM-DD_HH_MM-SESSION_NAME>.svg`

   The `.d2` file should contain ONLY the D2 diagram — no commentary.

3. Then generate the IMPROVED/IDEAL state diagram:

   Write D2 source to: `docs/architecture-understanding/<YYYY-MM-DD_HH_MM-SESSION_NAME-improved>.d2`
   Render to SVG: `docs/architecture-understanding/<YYYY-MM-DD_HH_MM-SESSION_NAME-improved>.svg`

   The `.d2` file should contain ONLY the D2 diagram — no commentary. This represents the target state.

4. Use `date` CLI to get current date-time for filenames
5. Render each `.d2` file to `.svg` using `d2` CLI

## D2 Style Conventions

- **Lay out top-to-bottom** where possible — reads naturally for event/command flows
- **Group related components** with nested shapes
- **Label connections** with descriptive verbs (e.g., `emits`, `handles`, `queries`)
- **Use `style` blocks** sparingly — prefer semantic shape names over visual overrides
- **For large diagrams**, set ELK layout for better automatic positioning
