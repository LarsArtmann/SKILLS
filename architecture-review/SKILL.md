---
name: architecture-review
description: Reviews the current architecture for scalability, modularity, service orientation, and composability. Use when the user asks about architecture quality, scalability, modularity, how to make the codebase more service-oriented or composable, or says "architecture review".
metadata:
  tags: architecture, scalability, modularity, service-oriented, composable
---

# Architecture Review

## Questions to Answer

1. How scalable/modular is the current Architecture?
2. How can we make this repo more:
   - Service oriented?
   - Composable?

## Output

Write the review to `docs/architecture-understanding/YYYY-MM-DD_HH-mm_<name>.html` where `<name>` is a short descriptive slug for the review focus (e.g. `modularity`, `service-orientation`, `coupling`). Use the current timestamp for the date prefix. Create the directory if it doesn't exist.

## Process

1. Thoroughly research the codebase structure
2. Analyze module boundaries, dependencies, coupling
3. Assess scalability of current patterns
4. Evaluate composability and service orientation
5. Provide concrete, actionable recommendations
6. Write findings to the output file

## Execution

READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
