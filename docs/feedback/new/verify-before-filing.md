---
name: verify-before-filing
description: |
  Use before filing any issue, PR, or feature request to an external project you don't own. Triggers on "file an issue", "open a PR upstream", "report this to", "suggest this to the project", "is there an existing PR for", or any time you're about to propose a change to someone else's repository. Enforces source-code-level verification of the diagnosis before drafting. Prevents the most common failure: filing a professional-looking issue whose core premise is wrong because the local workaround that motivated it was never verified to do anything.
allowed-tools: bash view fetch agentic_fetch sourcegraph grep glob agent
metadata:
  tags: verification, github, issues, pull-requests, upstream, open-source, epistemic-hygiene
---

# Verify Before Filing

Your local pain is real. Your diagnosis of its cause and location may be wrong. Before asking an external project to change, prove the gap is on their side, not yours.

## 1. The Failure Pattern

This is the sequence that produces bad upstream issues:

```
1. Encounter a problem (slow build, missing feature, broken behavior)
2. Find or inherit a local workaround (overrideAttrs, patch, monkey-patch)
3. ASSUME the workaround is necessary and correct (never verified)
4. Conclude: "upstream should support this so it's cached/builtin/default"
5. Draft a well-formatted issue proposing the change
6. File it → the workaround was a no-op; the issue is wrong
```

**The epistemic error:** Reasoning outward from "I have a workaround" to "upstream must be deficient," without ever verifying that the workaround addresses a real gap. The workaround's existence becomes its own justification.

**Why agents are especially vulnerable:** Agents excel at producing plausible, well-structured proposals from incomplete information. A perfectly formatted issue with clean code examples and a clear proposed solution can still be completely wrong if the underlying premise was never verified. Formatting quality is not evidence of correctness.

## 2. The Core Principle

> **Your workaround is not evidence of an upstream bug.**

Before proposing any change to an external project, you must independently verify:

1. That the change would actually have an effect
2. That the current upstream default doesn't already cover your case
3. That the problem is caused by upstream's design, not your override

## 3. Verification Gates

Run these IN ORDER before drafting any issue or PR. If any gate fails, stop.

### Gate 1: Does your local override actually change runtime behavior?

The most common failure: an `overrideAttrs`, patch, or config flag that changes a hash but has no functional effect.

| How to verify             | What to check                                                                                                                           |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Diff the build output     | Compare the WITH-override and WITHOUT-override outputs. Different hash alone = meaningless. Different compiled behavior = real.         |
| Trace the flag to source  | Follow the flag/option from declaration to its effect site in the upstream codebase. Does it reach code that executes on your platform? |
| Check architecture guards | Is the feature gated behind `#ifdef`, platform checks, or runtime detection that excludes your hardware/OS?                             |

If the override has no measurable effect, **delete it and stop**. The issue was never upstream — it was your config.

### Gate 2: Is the feature already the default upstream?

Before requesting that something be "enabled" or "exposed," verify it isn't already on by default.

| How to verify                  | Where to look                                                                                          |
| ------------------------------ | ------------------------------------------------------------------------------------------------------ |
| Read the upstream declaration  | `option(FOO "..." ON)` means it's ON by default. `cmakeBool "FOO" true` in nixpkgs means it's enabled. |
| Check what nixpkgs passes      | Does nixpkgs explicitly disable it? If not, the upstream default applies.                              |
| Check master, not your channel | The feature may have been added or defaulted since your lock.                                          |

If the feature is already default, your issue is unnecessary. **Stop.**

### Gate 3: Is the feature relevant to your platform?

A flag that controls CDNA GPUs is irrelevant on RDNA. A flag that controls x86 AVX-512 is irrelevant on ARM. Verify the feature's code path can actually execute on your target.

| How to verify         | What to look for                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Architecture macros   | Does the feature require `defined(CDNA)`, `defined(__AVX512F__)`, `defined(__aarch64__)`, etc.? Does your platform define that macro? |
| Platform conditionals | `optionals cudaSupport`, `optionals stdenv.isDarwin`, `optionals hostPlatform.isx86_64` — is your platform in the conditional?        |
| Runtime detection     | Does the feature have a runtime fallback that silently no-ops on unsupported hardware?                                                |

If the feature can't reach your platform, **stop**. File nothing.

### Gate 4: Would the proposed change actually fix your problem?

Trace the full cause chain from symptom to root cause:

```
Symptom:        What you observe (e.g., 30-min build)
Surface cause:  What seems to cause it (e.g., missing cache hit)
Assumed fix:    What you'd ask upstream to do (e.g., expose the flag)
Root cause:     What's actually wrong (e.g., your override is unnecessary)
```

If your proposed fix addresses the surface cause but not the root cause, the issue is wrong. The root cause may be entirely in your configuration.

### Gate 5: Does it already exist?

Search both open AND closed items. Many ideas have been proposed and rejected with reasons you need to know.

```
# Search closed too — rejected PRs are the most important
gh search issues --repo OWNER/REPO --state closed "keyword"
gh search prs --repo OWNER/REPO --state closed "keyword"
```

Check the current source on `master` — the feature may have been added since you last checked.

## 4. Only Then Draft

If all five gates pass, draft the issue with:

- **Evidence of the problem** (build logs, timing, hashes — not assertions)
- **Source-level understanding** (quote the specific upstream code lines — proves you read it)
- **The minimal change** with example code
- **Why existing alternatives don't work** (shows you checked)
- **Platform/architecture scope** (who benefits, who's unaffected)

## 5. Pre-Submission Review

Re-read your draft as the upstream maintainer. Answer honestly:

| Question                                                 | If "no" or "maybe" |
| -------------------------------------------------------- | ------------------ |
| Did they actually read our source, or are they guessing? | Don't file         |
| Is the requested feature already our default?            | Don't file         |
| Would I be annoyed to receive this?                      | Don't file         |
| Is the real problem in their config, not our package?    | Don't file         |

## 6. Anti-Patterns

### "Cache the symptom"

> "The build is slow. Let me upstream the flag so it gets cached."

Skips the question: do you need the flag at all? If it's a no-op, the fix is deleting it, not upstreaming it.

### "More options can't hurt"

Every upstream option adds: test matrix burden, maintenance cost, documentation surface, and the risk of harmful combinations. Only propose options that solve verified problems for a non-trivial user base.

### "I'll file it and let maintainers decide"

Low-quality issues consume the scarcest resource: maintainer review time. They also lower your signal-to-noise ratio permanently — maintainers triage by submitter reputation. One bad issue can bury three good ones in the same session.

### "The flag exists, so it must do something"

Flags are often architecture-conditional, platform-gated, or defaulted-on already. Existence in a CMakeLists.txt or Nix derivation is not evidence of effect on your system.

### "Someone added this override, so it must be needed"

Inherited overrides (especially AI-generated ones) are the highest-risk class. They were often added with plausible reasoning but never verified. Treat every inherited override as suspect until proven functional.

## 7. Relationship to Other Skills

This skill is the **outbound** complement to `verify-external-claims` (which is **inbound**):

- `verify-external-claims`: Verify external claims before encoding them into YOUR code/docs
- `verify-before-filing`: Verify YOUR claims before proposing changes to EXTERNAL projects

Both share the same root discipline: specificity is not evidence, and plausibility is not correctness.

## 8. Concrete Example (Boxed)

> **Scenario:** A NixOS user has a 30-minute `llama-cpp` ROCm build on every nixpkgs bump. Their config contains `overrideAttrs` adding `-DGGML_HIP_MMQ_MFMA=ON`. They want to file a nixpkgs issue requesting the flag be exposed as a package option.
>
> **Gate 1 (Does the override do anything?):** The flag defaults to `ON` in upstream CMake. nixpkgs never disables it. The override is redundant — it only changes the store hash. **FAIL.**
>
> **Gate 3 (Is it relevant to the platform?):** The flag controls MFMA instructions, gated behind `#if defined(CDNA)`. The user's GPU (gfx1150 / RDNA 3.5) does not define `CDNA`. The flag's code path never executes on their hardware. RDNA uses WMMA (a different instruction set with no toggle). **FAIL.**
>
> **Gate 4 (Root cause?):** The root cause is the unnecessary overrideAttrs, not a missing upstream option. The fix is deleting the override, not filing an issue. **FAIL.**
>
> **Outcome:** Issue not filed. Override deleted. Binary caching restored. Comment added to prevent re-introduction.
>
> Filing would have wasted maintainer time and signaled incompetence to the nixpkgs community.
