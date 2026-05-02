---
name: architecture-visualization
description: Generates mermaid.js architecture diagrams for the current system and/or the ideal target architecture. Use when the user wants architecture diagrams, visualizes Events & Commands flow, asks for mermaid.js graphs, or wants to see how the system IS vs how it SHOULD BE architected.
---

# Architecture Visualization

## Current Architecture

Provide a mermaid.js graph on how the Events & Commands are currently architected. Research first!

Write it to:
```
docs/architecture-understanding/<YYYY-MM-DD_HH_MM-SESSION_NAME>.mmd
```

JUST THE mermaid.js graph. No commentary in the file. Research the actual code first.

## Ideal Architecture

Now provide a mermaid.js graph on how the Events & Commands SHOULD BE architected! Research first!

Write it to:
```
docs/architecture-understanding/<YYYY-MM-DD_HH_MM-SESSION_NAME-improved>.mmd
```

JUST THE mermaid.js graph. This represents the target state.

## Process

1. Research the codebase thoroughly before drawing
2. Generate the CURRENT state graph first
3. Then generate the IMPROVED/IDEAL state graph
4. Use cli `date` to get current date-time for filenames
