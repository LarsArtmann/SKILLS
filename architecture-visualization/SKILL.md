---
name: architecture-visualization
description: Generates D2 architecture diagrams for the current system and/or the ideal target architecture. Use when the user wants architecture diagrams, visualizes Events & Commands flow, asks for D2 diagrams, or wants to see how the system IS vs how it SHOULD BE architected. Also trigger when the user asks about system architecture, component relationships, service dependencies, or any visual representation of codebase structure.
metadata:
  tags: architecture, d2, visualization, diagram, events, commands
allowed-tools: d2
---

# Architecture Visualization

Generate D2 diagrams that capture the current and ideal architecture. D2 produces cleaner layouts than Mermaid for complex graphs — use ELK engine for large architectures.

## Process

1. Research the codebase thoroughly before drawing
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

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
