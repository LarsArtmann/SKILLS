# Skill Proposal: external-issue-discipline

> Prevents filing incorrect, embarrassing, or useless issues/PRs to upstream projects by enforcing verification before submission.

---

## The Problem This Skill Solves

Agents (and humans) frequently file GitHub issues or PRs to upstream projects based on **surface-level understanding** of a problem. The issue draft looks reasonable, is well-formatted, and proposes a clean solution — but the underlying premise is **wrong**. The result:

- Wasted maintainer time reviewing a invalid request
- Embarrassment for the filer
- Reputation damage (the project now ignores your future issues)
- The actual problem remains unsolved because the issue addresses a symptom, not the root cause

### Real Example From This Session

**Setup:** A NixOS build of `llama-cpp` with ROCm support took 30+ minutes from source on every nixpkgs bump because a local `overrideAttrs` changed the store hash, defeating binary caching.

**Surface diagnosis:** "The `GGML_HIP_MMQ_MFMA` flag isn't exposed as a nixpkgs package option. Let's file an issue asking for `rocmMfmaSupport` to be added so Hydra can cache it."

**The issue was drafted, formatted beautifully, and ready to file.**

**What actually happened when we dug deeper:** The flag is a **complete no-op** on the target hardware (AMD Strix Halo / gfx1150 / RDNA 3.5):

1. The flag defaults to `ON` in upstream CMake already — nixpkgs never disables it
2. It only affects **CDNA** GPUs (MI100/200/300/350 datacenter cards), not RDNA
3. RDNA 3.5 uses **WMMA** (not MFMA), which is always enabled via compiler builtins — no toggle exists or is needed
4. The `overrideAttrs` only changed the derivation hash, breaking caching with zero functional effect
5. Filing the issue would have made the filer look incompetent to nixpkgs maintainers

The flag was added to the local config by someone who assumed "MFMA = faster matrix math = good for my GPU" without verifying whether their GPU architecture even has MFMA units.

---

## When This Skill Triggers

- User asks to "file an issue", "open a PR", "report this upstream", or "suggest this to the project"
- Agent is about to draft a GitHub issue or PR body for an **external** project (not the current repo)
- User asks "is there an existing PR/issue for X?" and the answer is no

---

## The Discipline (Workflow)

### Step 1: Verify the premise BEFORE drafting

Before writing a single word of the issue/PR, answer these questions with **evidence from the actual source code** — not assumptions, not blog posts, not AI-generated reasoning:

- [ ] **Does the feature/flag actually do what I think it does?** Read the upstream source code (CMakeLists.txt, source files, docs). Trace the flag/option from its declaration to its effect.
- [ ] **Is the feature already the default?** Check whether the upstream already enables it by default. If so, the issue is unnecessary.
- [ ] **Is it relevant to my hardware/platform/use case?** Check architecture guards, platform conditionals, runtime checks. A flag that only affects CDNA GPUs is irrelevant on RDNA hardware.
- [ ] **Does my local override actually change behavior?** If you're using `overrideAttrs` or similar, compare the WITH and WITHOUT behavior. A store hash change with no behavioral change means the override is a no-op.
- [ ] **Would the proposed change actually fix my problem?** The root problem here was binary caching, not a missing flag. Upstreaming the flag would NOT have fixed caching — Hydra still wouldn't build an MFMA variant. The real fix was removing the unnecessary override.

### Step 2: Verify it doesn't already exist

- Search both open AND closed issues/PRs (use `is:issue` / `is:pr` without `is:open`)
- Search for the exact technical term AND common misspellings/variants
- Check the current package definition source code on master — the feature may have been added since you last checked
- Check if there's a related discussion that already rejected the idea (search closed PRs with reasons)

### Step 3: Understand the root cause chain

Before proposing a fix, ensure you understand the FULL chain from symptom to root cause:

```
Symptom:          30 min build every nixpkgs bump
                   ↓
Surface cause:    overrideAttrs changes store hash → no cache hit
                   ↓
Assumed fix:      Upstream the flag so Hydra caches it
                   ↓
Root cause:       The overrideAttrs is a NO-OP that shouldn't exist
                   ↓
Actual fix:       Delete the overrideAttrs entirely
```

If your proposed issue fixes the "surface cause" but not the "root cause", it's the wrong issue. Filing it wastes everyone's time.

### Step 4: Only THEN draft the issue

If and only if all checks pass, draft the issue. The draft should:

- State the problem with **reproducible evidence** (build logs, timing, hashes)
- Show that you've read the upstream source and understand the mechanism
- Propose the minimal change with example code
- Explain why existing alternatives don't work
- Acknowledge edge cases or platforms where it might not apply

### Step 5: Peer review the draft

Before filing, re-read the draft as if you were the upstream maintainer. Ask:

- "Is this person asking for something that already works?"
- "Did they actually read our code, or are they guessing?"
- "Would I be annoyed receiving this issue?"

If any answer is "yes" or "maybe", go back to Step 1.

---

## Anti-Patterns

### "Cache the symptom" thinking

> "The build is slow. Let me make the flag configurable upstream so it gets cached."

This skips the question: **do you even need the flag?** If the flag is a no-op, the correct action is deleting it, not upstreaming it.

### "More flags = more control" bias

> "Having the option available can't hurt, even if I don't need it right now."

False. Every upstream option:

- Adds maintenance burden (tests, docs, CI matrix)
- Increases the build matrix exponentially (combining flags)
- Gives users a false sense of control over things that don't matter
- Can confuse users into enabling harmful combinations

Only propose options that solve real, verified problems.

### "I'll file it and let maintainers decide"

> "Even if I'm wrong, the maintainers will just close it. No harm done."

Wrong. Filing low-quality issues:

- Consumes maintainer review time (a scarce resource)
- Lowers your signal-to-noise ratio for future issues
- Can trigger defensive responses that poison the relationship
- Floods the issue tracker, burying real bugs

### "The AI said it was a good idea"

Agents can draft perfectly formatted, technically plausible issues that are completely wrong — because they reason from incomplete information. Formatting quality is NOT evidence of correctness. Always verify the technical claims independently.

---

## Red Flags That Should Stop You From Filing

| Signal                                                                  | What It Usually Means                                                       |
| ----------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| You haven't read the upstream source code for the feature               | You're guessing about the mechanism                                         |
| You can't explain WHY the current default doesn't work for you          | The default probably does work; your override is the problem                |
| The flag/feature relates to hardware you don't fully understand         | You may be targeting the wrong architecture                                 |
| Your local override is recent and added by an AI agent                  | Verify it actually does something before assuming the upstream is deficient |
| You're filing the issue to solve a caching/performance problem          | The root cause is likely in YOUR config, not upstream                       |
| The issue would request a feature useful only to your specific hardware | Consider whether it's generalizable enough for upstream                     |

---

## Positive Patterns

### Do: Remove your own unnecessary overrides first

Before asking upstream to change, audit your own configuration. The most common cause of "upstream doesn't support X" is actually "my override breaks caching for no benefit."

### Do: File issues with root-cause evidence

"This flag is a no-op on RDNA but the nixpkgs documentation implies it helps — can we clarify the docs?" is a better issue than "please add this flag as an option."

### Do: Verify against the actual source

Read `CMakeLists.txt`, source files, and compiler architecture macros. Quote the specific lines in your issue. This demonstrates competence and builds trust.

### Do: Check if your problem is already solved on master

The nixpkgs master branch may have already addressed your concern. Always check `master`, not just the release channel you're on.

---

## Summary Checklist

Before filing ANY issue or PR to an external project:

- [ ] I have read the relevant upstream source code and can trace the feature from declaration to effect
- [ ] I have confirmed the feature is NOT already the default
- [ ] I have confirmed the feature is relevant to my platform/hardware/architecture
- [ ] I have confirmed my local override actually changes runtime behavior (not just the store hash)
- [ ] I have verified the proposed change would actually fix my root problem
- [ ] I have searched both open AND closed issues/PRs for existing work
- [ ] I have re-read the draft as a maintainer and would not be annoyed to receive it

If you cannot check ALL of these boxes, do not file. Investigate further or abandon the issue.
