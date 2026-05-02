---
name: brutal-self-review
description: Triggers a brutally honest self-review of recent work and the current codebase state. Use when the user asks for self-reflection, self-critique, wants to know what was forgotten, what's stupid, what could be better, find ghost systems, split brains, or wants a comprehensive improvement plan with Go ecosystem library awareness.
---

# Brutal Self-Review

## Instructions

0. ALWAYS be BRUTALLY HONEST! NEVER LIE TO THE USER!

1. Answer every question below with full honesty:
   a. What did you forget?
   b. What is something that's stupid that we do anyway?
   c. What could you have done better?
   d. What could you still improve?
   e. Did you lie to me?
   f. How can we be less stupid?
   g. Is everything correctly integrated or are we building ghost systems? IF you find a 'ghost system' ALWAYS ask yourself should this be integrated? What value is in it? FIRST!
   h. Are we focusing on the scope creep trap?
   i. Did we remove something that was actually useful?
   j. Did we create ANY split brains? Even small things that could be considered split brain!
   k. How are we doing on tests? What can we do better, regarding automated testing?

2. Create a Comprehensive Multi-Step Execution Plan (keep each step small)!

3. Sort them by work required vs impact.

4. If you want to implement some feature, reflect if we already have some code that would fit your requirements before implementing it from scratch!

5. Also consider how we could improve our Type models to create a better architecture while getting real work done well.

6. Do NOT reinvent the wheel!! ALWAYS consider how we can use & leverage already well established libs to make our live easier!

7. If you find a Ghost system, report back and make sure you integrate it.

8. If there is legacy code around try to reduce it constantly and consistently. Our target for legacy code is ZERO.

## Architectural Review Questions

- Which architectural decisions we made in the past are causing problems now / could be improved? How can we be less stupid?
- Also consider how we could improve our Type models to create a better architecture while getting real work done well.
- Make sure to take FULL advantage of existing libraries we are already using!

## Go Ecosystem Libraries

For MOST Go-projects this should include:
- gin-gonic/gin (HTTP Server)
- knadh/koanf (Configs)
- a-h/templ (All HTML components)
- bigskysoftware/htmx (Client Side Code)
- fe3dback/go-arch-lint (Architecture Enforcement)
- samber/lo (Lodash-style Go library based on Go 1.18+ Generics)
- samber/mo (Monads and popular FP abstractions)
- samber/do (Dependency Injection)
- sqlc-dev/sqlc (ALL SQL code)
- onsi/ginkgo (for tests)
- charmbracelet/fang (batteries-included spf13/cobra apps)
- OpenTelemetry (OTEL)
- casbin/casbin (for auth)
- github.com/resend/resend-go/v3 (for e-mail)
- LarsArtmann/uniflow (custom UserFriendlyErrors lib; fallback to cockroachdb/errors)

If you need more information on how a lib works try: `https://context7.com/[REPO_OWNER]/[REPO_NAME]/llms.txt?tokens=100000`

## Architecture Patterns to Respect

- Don't Repeat Yourself
- Separation of concerns
- Event-Sourcing
- Domain-Driven Design (DDD)
- Command Query Responsibility Segregation (CQRS)
- Composition over inheritance
- General and Advanced Functional Programming Patterns
- Layered Architecture (N-Tier Architecture)
- Event-Driven Architecture (EDA)
- Railway Oriented Programming
- Behavior-driven development (BDD)
- Test Driven Development (TDD)
- "one way to do it" principle

## Execution

```
READ, UNDERSTAND, RESEARCH, REFLECT.
Break this down into multiple actionable steps. Think about them again.
Execute and Verify them one step at the time.
Repeat until done. Keep going until everything works and you think you did a great job!
```

Report back and ask questions if necessary aka. have a hard time to figure something out!
Run "git status & git commit ..." after each smallest self-contained change.
Run "git push" when done.
