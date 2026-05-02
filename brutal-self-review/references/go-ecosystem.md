# Go Ecosystem Libraries

Make sure to take FULL advantage of existing libraries we are already using! For MOST Go-projects this includes:

| Library               | Purpose                                                  |
| --------------------- | -------------------------------------------------------- |
| gin-gonic/gin         | HTTP Server                                              |
| knadh/koanf           | Configuration management                                 |
| a-h/templ             | All HTML components                                      |
| bigskysoftware/htmx   | Client Side Code                                         |
| fe3dback/go-arch-lint | Architecture Enforcement                                 |
| samber/lo             | Lodash-style Go library based on Go 1.18+ Generics       |
| samber/mo             | Monads and popular FP abstractions                       |
| samber/do             | Dependency Injection                                     |
| sqlc-dev/sqlc         | ALL SQL code                                             |
| onsi/ginkgo           | Testing framework                                        |
| charmbracelet/fang    | Batteries-included spf13/cobra apps                      |
| OpenTelemetry (OTEL)  | Observability                                            |
| casbin/casbin         | Authorization                                            |
| resend/resend-go/v3   | E-mail                                                   |
| LarsArtmann/uniflow   | Custom UserFriendlyErrors (fallback: cockroachdb/errors) |

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
