---
name: verify-external-claims
description: |
  Use before encoding any external claim into a skill, documentation, code, or review. Triggers on phrases like "verify external claims", "check the tool exists", "unverified claims", "confirm the binary", "validate the API signature", "is this library real", or when a skill references a CLI, library, URL, version, exit code, error message, or statistic that came from another session or from feedback. Prevents fabricated metrics, hallucinated CLI flags, and trophy-case marking of unverified work. Distinct from verify-before-filing (outbound — verify YOUR claims before filing to EXTERNAL projects; this skill is inbound — verify EXTERNAL claims before encoding into YOUR work).
allowed-tools: bash view edit grep fetch sourcegraph agentic_fetch
metadata:
  tags: verification, external-claims, skills, documentation, cli, libraries, fact-checking, quality-gate
---

# Verify External Claims

Before encoding any external claim into a skill, code, doc, or review, verify it against a primary source. Feedback is a lead, not a source. An LLM can generate plausible CLI flag tables, exact error messages, and version numbers without ever running the tool. Specificity is not evidence.

This skill covers **inbound** verification — claims entering your work from outside. For **outbound** verification — verifying your own diagnosis before proposing changes to an external project (issues, PRs, feature requests) — use `verify-before-filing`.

## 1. What Counts as an External Claim

Treat these as claims that need verification:

- CLI tool names, subcommands, flags, and flag values
- Exit codes and error message strings
- Library versions, API signatures, and import paths
- URLs, package names, and registry locations
- Statistics, percentages, and counts
- Tool behaviors, defaults, and side effects
- Dependency availability and license status

## 2. Verify Before Encoding

Run this checklist on every external claim. A claim is verified only when you can point to a primary source.

### 2.1 Official documentation and source code

- Search the project’s official documentation site.
- Read the relevant source file in the canonical repository.
- Check release notes, changelogs, and README examples.

### 2.2 Public indexes and registries

| Domain          | Primary source                                      |
| --------------- | --------------------------------------------------- |
| Go packages     | `pkg.go.dev`                                        |
| Go source repos | `github.com`, `golang.org/x`, `go.googlesource.com` |
| Code search     | `sourcegraph`, `grep.app`, GitHub search            |
| Nix packages    | `search.nixos.org`, `github.com/NixOS/nixpkgs`      |
| pnpm / JS       | `npmjs.com`, `jsr.io`                               |
| Python          | `pypi.org`, GitHub source                           |
| Rust            | `crates.io`, `docs.rs`                              |

### 2.3 Run the tool or code

If the claim is about a CLI:

1. Install the tool in the project’s environment.
2. Run the claimed command with `--help` or a minimal invocation.
3. Check that flags, exit codes, and outputs match the claim.

If the claim is about an API or library:

1. Write a minimal reproduction that uses the API.
2. Compile or run it against the claimed version.
3. Confirm the signature, behavior, and error paths.

### 2.4 Web search for unfindable tools

If a tool cannot be found in any public index, repository, or registry after reasonable search, treat it as **unverified**. It may be private, fabricated, or a closed internal project. Do not encode it as a real public tool without explicit confirmation.

## 3. What to Do with Unverified Claims

| Situation                                           | Action                                                                                                 |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Claim is verifiable and correct                     | Encode it; record the primary source in the doc or a comment                                           |
| Claim is unverifiable but useful as a reported lead | Label it explicitly: "unverified: reported in <source>, not independently confirmed"                   |
| Claim is unverifiable and not durable               | Remove it                                                                                              |
| Entire tool or library cannot be found publicly     | Reframe the skill around durable concepts (API semantics, anti-patterns) rather than the specific tool |

Never mark work as **🟢 Solid** when it contains unverified external claims. New skills start at **🆕 New** and age into **🟢 Solid** only after a documented successful run.

## 4. Skill-Creation Verification Gate

When creating a new skill from feedback or from research, add this gate before writing the `SKILL.md` body:

1. List every external claim in the source material (tools, flags, versions, stats, URLs, signatures).
2. Verify each claim against a primary source.
3. For each unverified claim, decide: remove, reframe, or label.
4. Add a **verification-status block** at the top of the skill if any claims remain unverified.
5. Mark the skill **🆕 New** in `README.md` until it is triggered and succeeds against real work.

## 5. Verification-Status Block Template

If a skill documents a tool whose CLI behavior cannot be verified, add this block at the top of `SKILL.md`:

```markdown
## Verification status

| Claim                                                           | Status        | Source                                                                                                                                                                                        |
| --------------------------------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `errors.AsType[E] (E, bool)` API                                | ✅ Verified   | pkg.go.dev/errors (Go 1.26.0)                                                                                                                                                                 |
| Tool binary `erraudit` (formerly `hierarchical-errors`)         | ❌ Unverified | Searched GitHub, Sourcegraph, pkg.go.dev (2026-08-02); zero matches. Likely private. The `errorfamily` library it may reference IS verified: `github.com/larsartmann/go-error-family` v0.10.0 |
| Decision tree for `errors.As` vs `errors.Is` vs `errors.AsType` | ✅ Verified   | Go `errors` package semantics                                                                                                                                                                 |
```

Replace the rows with the actual claims in the skill. The durable value of the skill should survive even if the specific tool does not exist.

## 6. When to Stop and Ask

Stop and ask the user only when:

- A tool is described as real but is entirely unfindable, and the skill’s value depends on it.
- A statistic or claim has significant safety or compliance implications if wrong.
- You have exhausted public search, source code, and runnable checks and still cannot confirm the claim.

Otherwise, make the reasonable judgment: reframe, label, or remove the unverified claim and proceed.

## 7. Sources and Tools

For detailed search strategies and fallible-claim examples, load [./references/verification-sources.md](./references/verification-sources.md).

After verification, return to the skill you were writing and encode only verified claims. Leave unverified claims explicitly labeled or remove them.
