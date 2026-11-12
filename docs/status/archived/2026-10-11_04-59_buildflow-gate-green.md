# Status + Brutal Self-Review: Buildflow Findings-Gate Rescue Session

**Date:** 2026-10-11 04:59 · **Scope:** this session only (the
"buildflow exit 69 → exit 0" run: 9 gate-blocking findings triaged and
fixed, 5 shellcheck findings on the new gmail scripts fixed, AGENTS.md
slimmed, `.buildflow.yml` committed) · **Mode:** status-report +
brutal-self-review hybrid

> Brutally honest per prompt and `brutal-self-review`. Every claim below was
> executed this session, not recalled. Format override note: status-report
> skill is HTML-canonical; the prompt names an `.md` path — honored per the
> skill's explicit-request rule (standing task-dispatch exception class).
> Prompt questions answered inline: "what did you forget" → d1–d5; "what
> could you have done better" → d3, e2, e3; "what could you still improve"
> → e1–e7.

## a) FULLY DONE ✅

~~1. **The user's exact command now exits 0.** `buildflow --fix~~ done — point-in-time record (verbatim command exited 0 that session)
   --build-mode=full --budget 5m --log-level warn --max-time 5m && cat
   docs/status/2026-10-11_03-58_*.md` ran end-to-end with
   `BuildFlow passed with warnings` (22 warning/info findings, zero at
   error severity; the `--fail-on=error` gate no longer trips).
~~2. **All 9 gate-blocking findings from the 04:08 run resolved:**~~ done — verified: CHANGELOG "Fixed (2026-10-11 — buildflow findings gate brought to green)"
   - `go.mod` missing + `.golangci.yml` missing (repo-level, critical/error)
     → `.buildflow.yml` committed with a single non-default key
     (`skip_steps: [go-structure-linter]`) and the rationale in the file:
     repo-level Go-project rules contradict this docs-only repo by design
     (AGENTS.md §9). `buildflow config lint` → "config clean"; dry-run shows
     "go-structure-linter: skipped via skip_steps config". Recorded
     deliberate non-fix per buildflow-skill step 7.
   - Two malformed fixture `go.mod`s (`module fixture/tiny` — dotless path,
     rejected by gomod-check) → `module example.com/fixture/tiny` in both
     linter-building eval fixtures. Read both `prompt.txt` files first: the
     eval prompts don't reference go.mod content, so the fixtures' purpose
     is untouched. gomod-check re-verified **no-cache**: `"findings": []`.
   - Two tracked `tiny` binaries → found already resolved before touching
     anything: a concurrent session's commit `812d45f` (04:14) gitignored
     `**/fixture/tiny` and the binaries are untracked+deleted. Verified via
     `git ls-files` (empty) instead of double-fixing.
   - `bdd-testing/assets/spec-template.go` package `TEMPLATE_test` →
     `subject_test` (valid lowercase Go naming for a placeholder; the file
     carries `//go:build ignore` and its header already instructs renaming).
   - AGENTS.md 413 → 342 lines (limit 377): §10 moved verbatim →
     `docs/external-dependencies.md`, §11 verbatim →
     `docs/feedback-loop.md`; compact pointer sections keep the §-numbers so
     existing "AGENTS.md §10/§11" references still resolve. Dangling
     cross-references updated (FEATURES.md, ROADMAP.md, status-report
     section-quality-guide.md).
~~3. **gmail-drafts shellcheck findings 5 → 0**, one of them a real bug:~~ done — verified: CHANGELOG gmail shellcheck findings fixed (RFC 2047 padding bug)
   - **Latent bug fixed:** the RFC 2047 B-decode padding
     `printf '%s%.*s' "$s" "$pad"` consumed `$pad` as a precision and was
     missing its `'=='` string argument — padding was never emitted, and
     decoding silently relied on GNU coreutils `base64 -d` accepting
     unpadded input (proved empirically: padded and unpadded both decode
     `Zm8` → `fo`, rc=0; other systems' base64 may not). Fixed to
     `printf '%s%.*s' "$s" "$pad" '=='` in both scripts.
   - **SC2100 false positive root-caused by bisection:** the flagged line
     (`TOK=token-work.json`) is valid bash; the trigger is the trailing
     `for ((…))` loop interacting with shellcheck's parser (byte-identical
     `head -172` → no finding; full file → fires; `head -362` + `done` →
     fires). Dodged with zero behavior change by quoting the four state
     filenames in `account_files` (verified: quoting silences it).
   - SC2001: `safe_name`'s trailing-underscore re-strip switched from `sed`
     to a parameter-expansion loop (behavior verified: post-truncation
     re-strip, all-underscores → `unnamed`).
   - Both `--self-test` suites pass; `shfmt -l` clean; targeted
     decode/slug checks green.
~~4. **The 03-58 report's red-card d2 (f2) repaired:**~~ done — verified: docs-health/SKILL.md sentence whole again (checked this pass)
   `docs-health/SKILL.md:158` dangling fragment reconstituted — the lost
   lead-in was the `check-rows` command mention; the sentence is whole
   again and the duplicate mention trimmed from the tooling paragraph.
   Grep-verified: 1 restored occurrence, 0 lines starting `classifies`.
~~5. **AGENTS.md synced with repo reality:** §1 now documents the committed~~ done — verified: AGENTS.md §1 documents the committed .buildflow.yml
   `.buildflow.yml` (quality-gate config, not a build system; §9 still bans
   go.mod/CI/package manager); §5.11 rewritten (previously claimed "no
   committed build config") plus a new eval-fixture hygiene bullet (dotted
   module paths; never commit the `tiny` build artifact).
~~6. **f30 done:** `go` toolchain (1.26+) added to~~ done — verified: docs/external-dependencies.md lists the go toolchain (1.26+)
   `docs/external-dependencies.md` as the runtime dependency of the
   docs-health + github-voice single-file Go tools.
~~7. **CHANGELOG** gained "Fixed (2026-10-11 — buildflow findings gate~~ done — verified: CHANGELOG carries the 2026-10-11 buildflow-gate entry
   brought to green)".
~~8. **Gates, verified fresh:** `./scripts/check-skills.sh` exit 0 (31~~ done — point-in-time record (gates green in later sessions)
   skills, links OK) run after every doc batch and at the end; buildflow
   full exit 0 twice with `BUILDFLOW_NO_RESULT_CACHE=1`; the verbatim user
   command exits 0. Fan-out delivery spot-check (03-58 f5): `readlink
   ~/.agents/skills/docs-health` → `../../projects/SKILLS/docs-health`
   resolves and reads through.
~~9. **The 03-58 report was finally read in full** (the `cat` the original~~ done — point-in-time record
   chained command never reached) and its b/c/d/f lists directly drove
   this session's fix selection (f2, f3, f4, f5, f6/f8, f30).

## b) PARTIALLY DONE 🟡

1. **Preflight `[docs/agents-md-size]` warn remains** (342 vs its max 220). **→ routed to TODO_LIST 2026-11-10**
   Deliberate — §5's gotchas are load-bearing session context and further
   extraction would gut them — but the non-fix decision is nowhere written
   in the repo; it lives only in this report.
2. **The 22 remaining warning/info findings are triaged in conversation **→ routed to TODO_LIST 2026-11-10**
   only, not encoded:** file-size (4; the single-file Go tools exceed the
   350-line advisory by design), jscpd (3; the two gmail scripts
   intentionally share helpers — standalone-script install model),
   art-dupl (2; a 12-token duplicate across the two corpus tools), lychee
   (5; the fleet authenticate-vs-exclude policy is undecided), shellcheck
   (~5 on jj-fork-pr-workflow/naming-review scripts; pre-existing class
   documented in §5.11). §5.11's "green-but-noisy" bullet was not extended
   to cover these.
3. **The go-structure-linter skip is a trade, and the loss is **→ routed to TODO_LIST 2026-11-10**
   uncompensated:** three of today's nine real findings (tracked binaries,
   package naming, agent-config size) came from that tool's per-file
   checks, which are now skipped repo-wide. check-skills has no Go-asset
   gate to replace the value (03-58 f7).
4. **Shellcheck version drift noticed, not recorded:** nixpkgs#shellcheck **→ routed to TODO_LIST 2026-11-10**
   (current) reports SC2126 on jj-fork/naming-review scripts where
   buildflow's bundled shellcheck reported SC2319/SC2089/SC2090 — §5.11's
   documented finding IDs are version-pinned and drifting.
5. **FEATURES.md not updated:** the `.buildflow.yml` is repo **→ routed to TODO_LIST 2026-11-10**
   infrastructure, borderline for the feature inventory; only CHANGELOG
   carries it.
~~6. **No HARVEST routing:** neither the 03-58 f-list nor this session's~~ done — resolved by this 2026-11-10 annotate pass (both reports' f-lists dispositioned)
   items are routed into TODO_LIST (report-then-WAIT precedent); the
   TODO_LIST staleness warn (288 h) still stands.
7. **README runtime-prerequisites note deferred** (go for the Go tools, **→ routed to TODO_LIST 2026-11-10**
   curl+jq for gmail, inboxclean user) — considered, not written (f31).

## c) NOT STARTED ⬜

1. **SC2100 parser quirk dodged, not filed:** the shellcheck bug (valid **→ routed to TODO_LIST 2026-11-10**
   bash flagged because a later `for ((…))` loop poisons the parse) has a
   near-minimal repro (`head -362` + `done` vs full file) but was never
   filed upstream — verify-before-filing + github-voice workflow not run.
2. **Stale-claim sweep not run:** nothing greps living docs for the **→ routed to TODO_LIST 2026-11-10**
   superseded "no .buildflow.yml / no committed build config" claim beyond
   AGENTS.md itself (the two status reports are point-in-time and exempt).
3. **Buildflow binary rebuild not done (user action, other repo):** the **→ routed to TODO_LIST 2026-11-10**
   binary-freshness advisory fired on every run — binary at 25b07c4 vs
   BuildFlow repo HEAD, which moved twice DURING this session (546156c →
   b8835cf; concurrent BuildFlow dev is active). Every verdict in this
   report is from buildflow 25b07c4. Fix: `nix build . && nix run
   .#reinstall` in `/home/lars/projects/BuildFlow`.
4. **Equivalence harness + fake-`gh`/fake-`curl` fixtures still live only **→ routed to TODO_LIST 2026-11-10**
   in /tmp** (03-58 g1 unanswered; the port's byte-identical claims remain
   un-reproducible from the repo).
5. **Everything else carried from 03-58 §c untouched:** real authenticated **→ routed to TODO_LIST 2026-11-10**
   Go corpus re-collection, voice-profile number refresh, real-server
   gmail smoke test, nix wrapper / prebuilt-binary story for machines
   without a Go toolchain.
6. **Untested paths carried:** collect-corpus resume flags, analyze-corpus **→ routed to TODO_LIST 2026-11-10**
   `--since`, surrogate-pair escaping, gmail error-path fixtures,
   verify-conversion.sh, porting-doctrine encoding, check-skills Go gate —
   see §f.

## d) TOTALLY FUCKED UP 💥

Nothing destroyed, corrupted, or reverted; the working tree is clean (the
auto-daemon committed each batch: `3c32731`, `155e911`, `9d40051`,
`592cc61`). But four process failures deserve naming:

~~1. **The result cache almost fooled me — twice.** My first~~ done — point-in-time record
   `buildflow -s gomod-check` and `-s shellcheck` verification runs
   returned empty findings with `filesScanned: 0` — cache replays, not
   scans. I caught both only because I read the scan counts and re-ran
   with `BUILDFLOW_NO_RESULT_CACHE=1`. The buildflow skill documents this
   exact trap; I still ran the cached form first. A green summary that
   scanned nothing is not verification — the same lesson class as 03-58's
   "green-but-noisy tails", re-learned at cost of two wasted runs.
~~2. **Tool-discipline slip:** I fired the first edit batch against the two~~ done — point-in-time record
   fixture `go.mod` files having only `cat`-ed them via bash — the edit
   tool correctly refused ("you must read the file before editing"). One
   wasted round trip for a rule I know and that is written down.
~~3. **Over-investigation before the cheap experiment:** I spent seven tool~~ done — point-in-time record
   calls bisecting shellcheck's parser internals for SC2100 before trying
   the two-call dodge experiment (quoting), which closed it immediately.
   Root-causing an external tool's recovery mode was curiosity, not the
   task. Dodge-first, file-the-repro-later, was the right order.
~~4. **An unexplained number shipped:** after the AGENTS.md splice I~~ done — point-in-time record
   predicted ~345 lines and got 342; I moved on without the ten-second
   reconciliation (my removed-range line estimate was sloppy, not the
   file — structure greps confirmed the sections). Accepting a number I
   couldn't immediately explain is exactly the habit this repo's gates are
   supposed to prevent.
   Honorable mention: I asserted the 5 remaining shellcheck findings were
   "the documented pre-existing ones" without pinning them — my jq
   drill-down of buildflow's findings JSON failed on a field-name mismatch
   and I let it go (the attribution is consistent with §5.11 but unpinned;
   the finding IDs drift across shellcheck versions anyway, b4).

## e) WHAT WE SHOULD IMPROVE 🔧

1. **Verification runs should default to `BUILDFLOW_NO_RESULT_CACHE=1`** — **→ routed to TODO_LIST 2026-11-10**
   or buildflow should banner "REPLAYED FROM CACHE (0 files scanned)" when
   a step returns findings-less zero-scan results. (Upstream idea for the
   BuildFlow repo; today it cost two false-green checks.)
2. **Same-session triage of a failed gate:** the 04:08 findings sat ~50 **→ routed to TODO_LIST 2026-11-10**
   minutes before the user re-ran the command; this session proved the 9
   findings were ~45 minutes of focused work. Triage failed gates
   immediately, don't stack runs.
3. **Close-the-loop needs a "dodged ≠ closed" clause:** the SC2100 quirk **→ routed to TODO_LIST 2026-11-10**
   is dodged locally (fine, gate is green) but not filed and not recorded
   as a deliberate non-fix — it currently lives only in CHANGELOG prose.
   Every workaround should end fixed, filed, or documented, not merely
   routed around.
4. **Restore the per-file value the skip removed:** a check-skills Go-asset **→ routed to TODO_LIST 2026-11-10**
   gate (every `assets/*.go` has a `self-test` subcommand, one `main` per
   directory, gofmt-clean, no tracked binaries) would replace the three
   real catches go-structure-linter contributed today (03-58 f7).
5. **Stale-claim sweep after infra changes:** committing `.buildflow.yml` **→ routed to TODO_LIST 2026-11-10**
   made "no committed build config" false; I fixed AGENTS.md but ran no
   repo-wide grep for other living-doc occurrences. Make the sweep part of
   any infra change checklist.
6. **Document the anchor-splice pattern** for moving dprint-aligned tables **→ routed to TODO_LIST 2026-11-10**
   (exact-match edits are impractical on padded markdown tables; the
   verified anchor splice is the safe mechanical form). Otherwise future
   sessions either fear-fail edit tools or improvise riskier rewrites.
7. **README honesty gap:** the repo's runtime story (a Go toolchain for **→ routed to TODO_LIST 2026-11-10**
   docs-health/github-voice tools; curl+jq for gmail-drafts) appears
   nowhere user-facing (f31) — the sales page oversells ease of running.

## f) UP TO 50 THINGS TO GET DONE NEXT (brainstorm — HARVEST must route; ✅ = closed this session, do not re-harvest)

**Evidence & verification debt (03-58 loose ends)**

1. Commit the equivalence harness + fake-`gh`/fake-`curl` fixtures as permanent repo testdata, or explicitly decide they were one-shot (needs g1). **→ routed to TODO_LIST 2026-11-10**
~~2. ✅ Run the buildflow full pipeline post-conversion; triage findings on the new files (this session: 9 errors resolved, 22 warnings triaged).~~ done — closed 2026-10-11 (this session's buildflow full run, 9 errors resolved)
~~3. ✅ Install/upgrade shellcheck and run the advisory pass on both gmail scripts (this session: 5→0, one real bug).~~ done — closed 2026-10-11 (shellcheck 5→0 on both gmail scripts)
~~4. ✅ Fix the `docs-health/SKILL.md` dangling fragment (this session).~~ done — closed 2026-10-11 (docs-health/SKILL.md:158 reconstituted)
~~5. ✅ Read a skill through the fan-out path to verify delivery (this session: docs-health).~~ done — closed 2026-10-11 (fan-out spot check: readlink + read through)
~~6. ✅ `.gitignore` for `__pycache__/` (present in the buildflow-managed block; verified this session).~~ done — verified: .gitignore __pycache__/ entry present (TODO_LIST T99: DONE 2026-11-10)
7. Add a repo-wide gate: forbid new `*.py` under skill dirs (encodes the conversion policy). **→ routed to TODO_LIST 2026-11-10**
8. Add check-skills checks for Go assets: `self-test` subcommand present, one `main` per dir, gofmt-clean, no tracked binaries (restores what the go-structure-linter skip removed). **→ routed to TODO_LIST 2026-11-10**
9. Fresh-session confirmation that gopls diagnostics are quiet (stale cache from the deleted flat `.go` files). **→ routed to TODO_LIST 2026-11-10**
10. Run `sync-html-kit.sh --check` + `link-skills-to-agents.sh --check` explicitly once (still never run explicitly). **→ routed to TODO_LIST 2026-11-10**
11. Record the deliberate non-fixes for the remaining warnings in §5.11: file-size advisories on the four Go tools, jscpd gmail-script similarity, art-dupl 12-token pair, lychee policy. **→ routed to TODO_LIST 2026-11-10**
12. Document the SC2100 dodge rationale where the next maintainer will look (gmail SKILL.md testing section or script header), not only CHANGELOG. **→ routed to TODO_LIST 2026-11-10**
13. File the shellcheck SC2100 parser quirk upstream (repro: `head -362` + `done` vs full file) — verify-before-filing first. **→ routed to TODO_LIST 2026-11-10**
14. Sweep living docs for superseded "no .buildflow.yml" claims (status reports are point-in-time, exempt). **→ routed to TODO_LIST 2026-11-10**
15. Record the AGENTS.md >220-lines preflight warn as a deliberate non-fix (§5 is load-bearing). **→ routed to TODO_LIST 2026-11-10**
16. Record the shellcheck version-drift observation (finding IDs differ between buildflow's bundled and nixpkgs shellcheck) in §5.11. **→ routed to TODO_LIST 2026-11-10**
17. Rebuild the buildflow binary in the BuildFlow repo (`nix build . && nix run .#reinstall`) to clear the binary-freshness advisory and pick up HEAD (user action, other repo). **→ routed to TODO_LIST 2026-11-10**

**Test coverage gaps (found, untested paths — carried)**

18. collect-corpus fake-`gh` e2e for the resume path (`--skip-discover`/`--skip-hydrate`). **→ routed to TODO_LIST 2026-11-10**
19. analyze-corpus fixture test for `--since` era-split outputs. **→ routed to TODO_LIST 2026-11-10**
20. Surrogate-pair (emoji) title fixture through `pyJSONString` vs `json.dumps`. **→ routed to TODO_LIST 2026-11-10**
21. fake-curl fixtures for gmail error paths (HTTP 403/500 → `die` message shape). **→ routed to TODO_LIST 2026-11-10**
22. gmail `--delete` + `--spec` combined-run fixture (ordering preserved). **→ routed to TODO_LIST 2026-11-10**
23. Body-with-trailing-newline fixture for the gmail MIME round-trip. **→ routed to TODO_LIST 2026-11-10**
24. `--kind` before/after-file order-independence test for check-draft. **→ routed to TODO_LIST 2026-11-10**
25. Fuzz `pyJSONString` against Python `json.dumps` over random Unicode. **→ routed to TODO_LIST 2026-11-10**

**Real-world proof (carried)**

26. Real authenticated `collect-corpus.go` run (~45 min) + corpus diff vs the Python-era snapshot. **→ routed to TODO_LIST 2026-11-10**
27. Refresh `voice-profile.md` numbers after the real run; re-verify check-draft calibration claims with the Go checker. **→ routed to TODO_LIST 2026-11-10**
28. Real-server gmail smoke test (read-only `--list` first) — needs g3. **→ routed to TODO_LIST 2026-11-10**
29. Verify jq/curl/base64/iconv presence on the inboxclean host before the first real run. **→ routed to TODO_LIST 2026-11-10**
30. Re-run analyze-corpus on the refreshed corpus; re-harvest shifted profile claims. **→ routed to TODO_LIST 2026-11-10**

**Docs & doctrine (carried)**

31. Encode the equivalence-first porting doctrine (port → prove parity → delete) in `how-to-write-skills.md`. **→ routed to TODO_LIST 2026-11-10**
32. README runtime-prerequisites section (go; curl+jq; inboxclean user) — honest sales page. **→ routed to TODO_LIST 2026-11-10**
33. Rename the harness header-comment inconsistency (`check-annotator.sh` → actual filename). **→ routed to TODO_LIST 2026-11-10**
34. Document the deliberate divergences (FAIL→stderr, clean errors vs tracebacks, usage exit 2) in one place. **→ routed to TODO_LIST 2026-11-10**
35. Document the annotate asymmetry: `rows` has `--section` occurrence suffixes, `prose` does not. **→ routed to TODO_LIST 2026-11-10**
~~36. Note the GNU-date dependency in `gmail_eml_export.sh` (macOS `date` differs).~~ done — verified: gmail_eml_export.sh:18 header carries "Requires: … GNU date."
37. Document gmail `http()` retry behavior (none; collectors retry, gmail doesn't). **→ routed to TODO_LIST 2026-11-10**

**Tooling ergonomics**

38. Single committed `verify-conversion.sh` running all self-tests + harnesses + format/vet gates in one command. **→ routed to TODO_LIST 2026-11-10**
39. Shared, tested fake-`gh`/fake-`curl` shim utility (stop rebuilding mocks per session). **→ routed to TODO_LIST 2026-11-10**
40. Prebuilt-binary or nix-run fallback for the Go tools — needs g2. **→ routed to ROADMAP 2026-11-10**
41. GOCACHE fallback note in AGENTS.md (unwritable /mnt/buildcache mid-run; /tmp override unblocks). **→ routed to TODO_LIST 2026-11-10**
42. gmail scripts: decide shared-sourced-lib vs self-contained duplication (drift risk vs install model) — decision, not silence. **→ routed to TODO_LIST 2026-11-10**
43. gmail_drafts.sh: friendly error when spec `cc`/`bcc` is a string instead of an array. **→ routed to TODO_LIST 2026-11-10**
44. gmail_eml_export.sh: decide document-vs-extend the `--limit` pagination truncation. **→ routed to TODO_LIST 2026-11-10**
45. check-skills structural awareness of `.go` assets (superset of item 8 — merge when harvesting). **→ routed to TODO_LIST 2026-11-10**
46. Record the no-go.mod / potential go.work ADR (explicitly rejected 2026-10-11 conversion session; write it down as an ADR). **→ routed to ROADMAP 2026-11-10**
47. `cmp.sh`-style harnesses: print a machine-readable PASS line (grep-able gate). **→ routed to TODO_LIST 2026-11-10**
48. `annotate.go self-test`: consider covering `check-rows` + `emit-keys` paths (today only rows/prose/markers). done — verified: annotate.go self-test now covers check-rows + emit-keys round-trip (docs-health/SKILL.md tooling notes)
49. One-off `check-rows` uniformity sweep over archived `docs/status/` files. **→ routed to TODO_LIST 2026-11-10**
50. Close the loop on both open reports: HARVEST-worthy items → TODO_LIST per docs-health (the 288 h staleness warn is this item's shadow). done — resolved by this 2026-11-10 annotate pass (both open reports closed out)

## g) QUESTIONS I CANNOT FIGURE OUT MYSELF

1. **Evidence permanence (carried, still gates item 1):** should the Python↔Go equivalence harness and the fake-`gh`/fake-`curl` fixtures be committed as permanent repo testdata (making the port's byte-identical claims reproducible forever), or were they one-shot scaffolding you're fine losing with /tmp? **→ routed to ROADMAP 2026-11-10**
2. **Go toolchain guarantee (carried, gates items 40 + SKILL.md safety):** is `go` guaranteed at runtime on every machine that runs these skills (SSH-Mac sessions, the inboxclean NixOS server), or should the Go-based tools get a nix-run wrapper / prebuilt-binary fallback? **→ routed to ROADMAP 2026-11-10** **→ routed to ROADMAP 2026-11-10**
3. **Real-server gmail verification (carried, gates item 28):** do you want the read-only `--list` smoke-test hand-over now, or is the fake-curl e2e coverage sufficient until the next real drafting session? **→ routed to ROADMAP 2026-11-10** **→ routed to ROADMAP 2026-11-10**

---

_Verification snapshot: buildflow full exit 0 (fresh, no-cache, ×2; final
verbatim user command exit 0) · `buildflow config lint` clean · gomod-check
`"findings": []` (no-cache) · gmail shellcheck 5→0 · shfmt clean · gmail
self-tests green ×2 · check-skills.sh exit 0 (31 skills, links OK) ·
AGENTS.md 342 lines · fan-out symlink resolves. Prior reports:
`2026-10-11_03-55_python-to-go-bash-conversion.md` (conversion detail) and
`2026-10-11_03-58_conversion-status-and-brutal-self-review.md` (whose f2,
f3, f4, f5, f6/f8, f30 this session closed). All verdicts from buildflow
binary 25b07c4 (HEAD-advisory outstanding, c3)._
