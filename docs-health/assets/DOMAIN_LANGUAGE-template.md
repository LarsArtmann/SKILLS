<!-- docs/DOMAIN_LANGUAGE.md template, copy into docs/ and fill in.
     This is the UBIQUITOUS LANGUAGE glossary for the project.
     Domain terms, not implementation details.
     See docs-health/SKILL.md. -->

# Domain Language

> The ubiquitous language of this project. Every term used in code,
> conversations, and docs should be defined here unambiguously.

## Core terms

| Term           | Definition                                          | Where used in code                        |
| -------------- | --------------------------------------------------- | ----------------------------------------- |
| Session        | An authenticated user's active connection           | `auth/session.go`, `Session` type         |
| Tenant         | An isolated workspace owning users and resources    | `tenant/`, `Tenant` struct                |
| Projection     | A read-optimized view derived from events           | `projections/`, `Projection` interface    |

## Bounded contexts

Terms that have different meanings in different parts of the system:

| Term           | Context A (meaning)     | Context B (meaning)       |
| -------------- | ----------------------- | ------------------------- |
| Order          | Checkout (purchase)     | Fulfillment (shipment)    |

## Deprecated terms

| Old term       | Current term            | Why changed                               |
| -------------- | ----------------------- | ----------------------------------------- |
| Account        | Tenant                  | Renamed to avoid banking connotation      |

---

<!-- Guidance for the builder:
  - Every term must still be used in the codebase. Verify by grepping.
  - Look for terms used inconsistently (same concept, different names).
  - Look for code terms with no documented definition.
  - This is DOMAIN language, not API docs. No return types or signatures.
-->
