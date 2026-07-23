---
name: naming-review
description: Reviews and improves naming quality for data models (types, structs, classes, interfaces, enums, fields, properties) and functions (methods, procedures). Use when the user wants to review, audit, improve, or fix naming in their codebase — including type names, function names, variable names, field names, or any identifier naming. Also trigger when the user asks about naming conventions, naming anti-patterns, naming smells, wants better names for their models or functions, or says "naming review", "review naming", "name review", "audit names", "improve naming", "bad names", "naming conventions", "rename identifiers", "clean up names". Covers clarity, honesty, domain alignment, consistency, language-specific conventions, and common anti-patterns like Manager/Handler/Helper classes, Data/Info suffixes, type encoding, lying names, and vague verbs. Includes automated detection via scripts/naming-smells.sh and linter integration for Go (revive), TypeScript (eslint naming), Rust (clippy), and Python (ruff).
metadata:
  tags: naming, review, quality, clean-code, ddd, anti-patterns, data-models, functions, naming-conventions
---

# Naming Review

A comprehensive review skill for making identifiers — especially data model names and function names — honest, clear, and domain-aligned. Based on Clean Code principles, Domain-Driven Design, and analysis of naming anti-patterns across production codebases.

## Process

READ, UNDERSTAND, RESEARCH, REFLECT before each action.

### Step 0: Run Automated Detection

Before manual review, run automated tools to surface low-hanging fruit. Don't reinvent what linters already do well.

Run the appropriate linters for the project's language:

| Language       | Tool                                              | Key Naming Rules                                                         |
| -------------- | ------------------------------------------------- | ------------------------------------------------------------------------ |
| **Go**         | `revive` or `golangci-lint`                       | `var-naming`, `exported`, `package-naming`, `receiver-naming`            |
| **TypeScript** | `eslint` + `@typescript-eslint/naming-convention` | PascalCase types, camelCase variables, consistent enum casing            |
| **Rust**       | `clippy`                                          | `module_name_repetitions`, `enum_variant_names`, `wrong_self_convention` |
| **Python**     | `ruff`                                            | N801-N818: PEP 8 naming                                                  |
| **Java**       | `checkstyle`                                      | `TypeName`, `MethodName`, `ParameterName`, `ConstantName`                |
| **C#**         | `.NET analyzers`                                  | CA1707, IDE1006 naming styles                                            |

Then run `scripts/naming-smells.sh` for deeper pattern detection that linters miss (vague nouns, Manager/Handler classes, Impl suffixes, split-brain terminology). This surfaces issues that require human judgment.

Quick grep for the most common smells:

```bash
# Vague type names
rg -i 'type\s+\w*(Data|Info|Record|Item|Object|Thing)\b' --type-add 'go:*.go' --type-add 'ts:*.ts' --type-add 'py:*.py' --type-add 'rs:*.rs'

# Manager/Handler/Processor classes
rg -i '(class|type|struct|interface)\s+\w*(Manager|Handler|Processor|Helper|Util|Utility)\b'

# Impl suffix (architecture leakage)
rg -i '(class|type|struct)\s+\w*Impl\b'
```

### Step 1: Discovery

Find all source files in the target scope. Read every file that defines data models or functions. Understanding the full picture is essential for catching cross-cutting issues like inconsistent naming patterns, duplicated concepts under different names, and split-brain terminology.

Identify the primary language(s) — conventions differ by language and this skill adapts accordingly.

**Exclude from review**: Generated code (protobuf, OpenAPI/Swagger, ORM models, graphql-codegen, TypeSpec output). These names are dictated by schemas or external tools — flagging them wastes time. If generated names are bad, fix the source schema or generator config, not the output.

### Step 2: Build Naming Glossary

Before checking individual identifiers, build a glossary of all type names and their relationships. This reveals split-brain terminology at a glance.

Extract all type/function names and group by domain:

```markdown
# Naming Glossary

## Domain: User Management

| Code Name     | Role             | Potential Split-Brain    |
| ------------- | ---------------- | ------------------------ |
| User          | Type (struct)    |                          |
| Customer      | Type (struct)    | ← same as User?          |
| Client        | Type (interface) | ← same as User/Customer? |
| AccountHolder | Type (struct)    | ← same as User?          |
| getUser       | Function         |                          |
| fetchCustomer | Function         | ← same as getUser?       |
| findClient    | Function         | ← same as getUser?       |
```

When multiple names appear to represent the same domain concept, flag them for reconciliation. The glossary becomes the authoritative reference for the rest of the review.

### Step 3: Categorize

Classify each identifier into its role:

| Category             | Examples                                           |
| -------------------- | -------------------------------------------------- |
| **Types**            | structs, classes, interfaces, enums, type aliases  |
| **Functions**        | methods, functions, procedures, constructors       |
| **Fields**           | struct fields, class properties, object attributes |
| **Variables**        | local variables, parameters, constants             |
| **Packages/Modules** | package names, module names, namespace names       |

### Step 4: Review Against Checklist

For each identifier, check ALL categories below. Read `references/common-naming-problems.md` for detailed explanations and fixes of each issue.

#### Honesty — Does the name tell the truth?

- [ ] **No lying names** — the name must describe what the thing actually does or represents
- [ ] **No hidden side effects** — a function named `getX` must not mutate state
- [ ] **No misleading scope** — a name like `ProcessEverything` on a function that only handles one case
- [ ] **No euphemisms** — `sanitize` for `delete`, `adjust` for `truncate`

#### Clarity — Can a newcomer understand the name without asking?

- [ ] **No unpronounceable names** — if you can't say it in a code review, rename it
- [ ] **No abbreviations that aren't universal** — `usr`, `cnt`, `calc`, `mgr` are not universal
- [ ] **No single-letter names** — except accepted loop variables (`i`, `j`, `k`) or math context (`x`, `y`, `z`)
- [ ] **No number suffixes** — `user1`, `user2`, `result2` indicate missing abstractions
- [ ] **No cryptic prefixes/suffixes** — Hungarian notation (`strName`, `iCount`, `m_user`) encodes type information that the type system already knows

#### Precision — Does the name distinguish from alternatives?

- [ ] **No vague nouns** — `Data`, `Info`, `Record`, `Item`, `Object`, `Thing` carry no domain meaning
- [ ] **No vague verbs** — `do`, `handle`, `process`, `manage`, `perform` say nothing about what actually happens
- [ ] **No "Manager/Handler/Processor/Helper/Util/Utility" classes** — these are trash-can names that collect unrelated behavior; split by responsibility
- [ ] **No redundancy with context** — `User.userName`, `Customer.customerEmail`, `Exception.exceptionMessage`
- [ ] **No redundancy with type** — `nameString`, `amountDecimal`, `idGuid` — the type already says this

#### Domain Alignment — Does the name speak the domain language?

- [ ] **Uses ubiquitous language** — names reflect the domain experts' vocabulary, not developer jargon
- [ ] **No mixed metaphors** — same concept called `Customer` in one place, `Client` in another, `AccountHolder` in a third
- [ ] **No split-brain terminology** — two names for the same domain concept (e.g., `Order` vs `Purchase` vs `Transaction` for the same thing)
- [ ] **No technical jargon for domain concepts** — `AggregateRoot`, `DTO`, `Entity` in the name when the domain term is `Invoice`, `Payment`, `Shipment`

#### Implementation Leakage — Does the name expose how instead of what?

- [ ] **No "Impl/Concrete/Default" suffixes** — these leak architecture; use domain names (`InMemoryPaymentGateway` is OK, `PaymentGatewayImpl` is not)
- [ ] **No "Abstract/Base" prefixes** — `AbstractUser`, `BaseRepository` encode inheritance hierarchy; compose instead
- [ ] **No "I" prefix for interfaces** — except C# convention; in Go/TypeScript/Rust/Python, `IUserService` is an anti-pattern
- [ ] **No framework leakage** — `RestController`, `JpaEntity`, `SqlRepository` when the domain term is `CustomerService`, `Order`, `ProductCatalog`

#### Boolean Naming — Are yes/no questions phrased as questions?

- [ ] **Boolean fields read as yes/no** — `isActive`, `hasPermission`, `canWrite`, `shouldRetry`
- [ ] **No negative booleans** — `isNotEnabled` → `isDisabled`, `hasNoItems` → `isEmpty`
- [ ] **No ambiguous booleans** — `status` (what kind?), `flag` (which flag?), `check` (checks what?)
- [ ] **Functions returning bool are questions** — `isValid()`, `hasAccess()`, `canProceed()`

#### Function Naming — Do function names reveal intent?

- [ ] **Functions are verbs or verb phrases** — `calculateTotal`, `sendEmail`, `validateOrder`
- [ ] **Command-Query Separation** — commands change state (verbs: `add`, `remove`, `send`), queries return data (nouns/questions: `total`, `isValid`)
- [ ] **No and/or in function names** — `addAndValidate` does two things; split into `add` + `validate`
- [ ] **No arbitrary comments in names** — `processOrderV2`, `handleRequest_new`, `calculateTax_fixed`
- [ ] **Factory functions describe what they create** — `NewOrder()` not `Create()`; `withDiscount()` not `apply()`

#### Consistency — Is the same thing called the same thing everywhere?

- [ ] **No synonym inconsistency** — `delete`/`remove`/`destroy`/`erase` for the same operation across the codebase
- [ ] **No inconsistent verb tense** — `getUser`/`fetchUser`/`retrieveUser`/`queryUser` for the same operation
- [ ] **Consistent naming within a domain** — if you name one `createX`, name them all `createY`, not `makeY` or `newY`
- [ ] **No cutesy/clever names** — `reaper`, `ninja`, `wizard`, `magic` obscure meaning

#### Language-Specific Conventions

- [ ] **Go**: `CamelCase` (exported), `camelCase` (unexported); interfaces without `I` prefix; `Err` prefix for errors; `New` for constructors
- [ ] **TypeScript**: `PascalCase` for types/interfaces/classes; `camelCase` for functions/variables; no `I` prefix for interfaces
- [ ] **Rust**: `SnakeCase` for functions/variables; `CamelCase` for types/traits; no `I` prefix for traits
- [ ] **Python**: `snake_case` for functions/variables; `PascalCase` for classes; no `I` prefix for ABCs
- [ ] **Java/C#**: `PascalCase` for classes/methods; `camelCase` for fields/variables; `I` prefix only in C# for interfaces

### Step 5: Generate Report

Write a **self-contained styled HTML report** — not a flat Markdown file. A naming review
is a point-in-time audit with category-colored issue tables that benefit from visual treatment.

1. Load the shared design system: [./assets/html-report-kit/references/html-output-guide.md](./assets/html-report-kit/references/html-output-guide.md)
2. Copy the template: [./assets/html-report-kit/assets/report-template.html](./assets/html-report-kit/assets/report-template.html)
3. Write to `docs/reviews/<YYYY-MM-DD_HH-MM_naming-review.html`
4. Map report sections to visual components:
   - **Stat cards** for counts (identifiers reviewed / honesty / clarity / domain / consistency)
   - **Badge-coded tables** per category — one table per issue class:
     - `.card-problem` + `badge-critical` for **Honesty Issues** (Must Fix)
     - `.card-warning` + `badge-high` for **Clarity Issues** (Should Fix)
     - `.card-warning` + `badge-medium` for **Domain Alignment Issues**
     - `.card-warning` + `badge-low` for **Consistency Issues**
     - `.card-warning` + `badge-medium` for **Implementation Leakage**
   - **`.card-solution`** for **Strengths** (good naming to preserve)

Each issue table uses the same column structure:

| # | File | Line | Identifier | Issue | Better Name |

### Step 6: Fix (When Requested)

When the user asks to fix naming issues:

1. Fix honesty issues first (lying names, hidden side effects)
2. Fix clarity issues (abbreviations, vagueness, unpronounceable names)
3. Fix domain alignment (split-brain terminology, establish canonical names)
4. Fix consistency (standardize verbs and nouns across codebase)
5. Fix implementation leakage (remove Impl/Base/Abstract/I prefixes)

After each rename:

- Run the project's test suite to verify nothing breaks
- Use language-appropriate refactoring tools (LSP rename, `gofmt`, IDE refactoring)
- Check for string references (reflection, config files, API contracts, serialized forms)

**Important**: Renaming is a behavioral change only if external consumers depend on the name. Check for:

- Public API consumers outside this codebase
- Serialized field names (JSON, database columns, protobuf)
- Reflection-based access
- Configuration files referencing the name

When a rename would break external contracts, recommend but do not execute.

### Rename Safety Check

Before renaming any identifier, grep for references that won't be caught by refactoring tools:

```bash
# JSON/serialized references
rg -i '"oldName"' --type-add 'json:*.json' --type-add 'yaml:*.yaml' --type-add 'toml:*.toml'

# Database column references
rg -i 'old_name' --type-add 'sql:*.sql'

# Reflection-based access
rg -i '"OldName"' --type-add 'go:*.go'  # string-based reflection

# Config file references
rg -i 'oldName' --type-add 'env:.env' --type-add 'yaml:*.yaml' --type-add 'toml:*.toml'

# API documentation
rg -i 'oldName' --type-add 'md:*.md' --type-add 'html:*.html'
```

## Key Principles

The reason behind each naming rule matters more than the rule itself. A review that explains "why" is far more valuable than one that just says "rename this." When reporting issues, always include:

1. **What** the issue is
2. **Why** it matters (readability, maintainability, domain alignment, honesty)
3. **What to call it instead** (concrete suggestion with reasoning)

## Severity Guide

| Severity        | Meaning                                                                        |
| --------------- | ------------------------------------------------------------------------------ |
| 🔴 **Critical** | Name lies about behavior (hidden mutation, misleading scope)                   |
| 🟠 **High**     | Name carries no meaning (Data, Info, Handler, Manager, do, process)            |
| 🟡 **Medium**   | Name is unclear or inconsistent (abbreviations, synonym drift, tense mismatch) |
| 🔵 **Low**      | Style or convention issue (casing, minor redundancy, language-specific norms)  |

## References

- `references/common-naming-problems.md` — Detailed catalogue of naming anti-patterns with before/after examples, organized by category
- `references/naming-best-practices.md` — Ideal naming patterns per category, domain-driven design language guidelines, and language-specific conventions
- `scripts/naming-smells.sh` — Automated detection of naming anti-patterns using grep/ripgrep

Read these files when you need specific examples or deeper guidance on a particular issue category.

## Related Skills

- **full-code-review** — Broader code review that includes naming as one aspect. Use naming-review when you want focused, deep naming analysis
- **code-quality-scan** — Runs linters that already catch some naming issues. naming-review goes deeper into semantics linters can't check
- **deduplicate-code** — Finds code duplication which often reveals split-brain naming (same concept, different names)
- **architecture-review** — Architecture issues often manifest as naming problems (Manager classes, Impl suffixes)
- **update-old-docs** — When a rename touches many files or old reports, defer to it for restraint discipline: read every target first, apply per-file judgment, and annotate old docs non-destructively instead of blanket-editing
