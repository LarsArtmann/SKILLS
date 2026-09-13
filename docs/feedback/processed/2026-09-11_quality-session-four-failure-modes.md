# Feedback: 2026-09-11 Quality Session — Four Failure Modes Worth Encoding

**Date:** 2026-09-11
**Project:** linter-autoconfigure-sdk + SKILLS (cross-repo quality session)
**Outcome:** all work completed and verified; the failures below were each caught and fixed in-session, but every one recurred from a class a skill should own.

---

## Incident 1: AI-agent fetch hallucinated the evidence it was asked to extract

**What happened:** While designing `--verify`/`--audit` for the social-preview
generator, three agentic fetches were used to determine whether og:image URLs
distinguish custom uploads from auto-generated cards. The agent summarizations
reported `opengraph.githubassets.com/1/<owner>/<repo>` for two repos — one of
which (vercel/next.js-style answer for the SDK repo) turned out to be wrong
when the same page was later fetched raw. The SDK repo's real og:image points
at `repository-images.githubusercontent.com` (the custom-upload domain), which
flipped the design conclusion: the discriminator DOES exist.

**Root cause:** trusting an LLM summarizer for exact-string extraction.
Summarization is lossy and plausibility-driven; URL extraction needs raw
bytes + grep.

**Skill implication:** `verify-external-claims` should name "agent-summarized
fetch" as a distinct fabrication class from "constructed URL": the claim came
from a tool, so it felt verified, but the tool paraphrased. Rule: when the
claim is an exact string from a page (URL, version, flag, error message),
fetch raw and extract mechanically.

## Incident 2: `grep -q` + `set -o pipefail` = silent SIGPIPE failure

**What happened:** the new `--check-env` font guard (`fc-list | grep -qi
"$font"`) reported both fonts MISSING on a machine where `fc-list | grep -i`
finds 96 matches. `grep -q` exits at first match; fc-list gets SIGPIPE (141);
pipefail promotes it to the pipeline exit; the `if` takes the else branch.

**Root cause:** early-exit downstream (`grep -q`, `head -1`) + upstream that
writes more data + pipefail. Same latent bug existed in the og:image
extraction (`curl | grep | head -1`).

**Skill implication:** shell tooling skills should carry the pattern rule:
under pipefail, never put an early-exit consumer downstream of a chatty
producer; capture to a variable, then parse (`grep -m1` is fine as the LAST
stage or on a variable).

## Incident 3: Result cache served a stale green verdict after a tool upgrade

**What happened:** the SDK's buildflow gate had been green on 2026-09-11
morning, then failed with 58 error findings from golangci-lint-auto-configure
with only a docs commit in between. The step's result cache (168h TTL) had
been masking the failure; `BUILDFLOW_NO_RESULT_CACHE=1` revealed the truth.

**Root cause:** cached verdicts keyed without the tool version/behavior; a
green result outlived the conditions that produced it.

**Skill implication:** quality-gate skills should say: after ANY tool upgrade,
run the gate once with caching disabled before trusting it; and never
attribute a green gate to the current code without noting cache age.

## Incident 4: Script surgery by string-index broke more than it touched

**What happened:** inserting the maintenance modes into generate.sh went
through three increasingly-hairy python string-slice passes; the final rebuild
silently deleted the `xml_escape` assignment block (four lines). Everything
still "worked" — until a title containing `&` would have produced invalid SVG.
Only shellcheck's SC2154 ("referenced but not assigned") caught it.

**Root cause:** rebuilding a region by `index()` anchors without diffing the
result against the original; and testing only the happy path (plain ASCII
title) so the missing escaping was invisible.

**Skill implication:** when a scripted edit lands, (1) diff before/after and
account for EVERY removed line, (2) make the test inputs exercise the deleted
code (a `&` in the title immediately proves xml_escape matters). shellcheck/
linters are the cheap net — run them BEFORE declaring a shell change done,
not after.

---

## What Went Right (keep doing)

- The regeneration regression test (same flags → compare against committed
  card) caught nothing this time but is the reason the xml_escape bug can
  never ship silently again.
- The byte-compare `--verify` verdict turned a "manual upload pending" TODO
  into a verified closed item in one command.
