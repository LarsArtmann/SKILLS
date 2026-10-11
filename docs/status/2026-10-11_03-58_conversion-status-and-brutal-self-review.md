# Status + Brutal Self-Review: Python→Go/bash Conversion Session

**Date:** 2026-10-11 03:58 · **Scope:** this session only (the "convert all
into Go or .sh" run: 12 Python files, 2,802 lines, three skills) ·
**Mode:** status-report + brutal-self-review hybrid

> Brutally honest per prompt and `brutal-self-review`. Every claim below was
> executed this session, not recalled. Format override note: status-report
> skill is HTML-canonical; your prompt names an `.md` path — honored per the
> skill's explicit-request rule (standing task-dispatch exception class).

## a) FULLY DONE ✅

1. **All 12 Python files converted and deleted** (2,802 lines): zero `.py`
   remains in any skill directory (`find` sweep = 0).
2. **docs-health → `assets/annotate.go`** — one Go program replacing
   `annotate-rows.py`, `annotate-prose.py`, `annotate-status-items.py`,
   `check-rows.py`, `annotate-markers.py`; the two `_test.py` files became a
   `self-test` subcommand. Atomic write, code-span-aware already-annotated
   guards, shape-check-and-restore, level-aware scoping, occurrence
   suffixes, banned-verdict refusal, dup-key refusal, `--emit-keys` — all
   ported and fixture-tested (26 assertions, green via relative AND
   absolute harness invocation).
3. **github-voice → three single-file Go programs** in per-package dirs
   (`check-draft/`, `analyze-corpus/`, `collect-corpus/`) — one `main` per
   directory keeps the repo module-less (§9 no-go.mod) while staying
   gofmt/go-vet/gopls-legit.
4. **gmail-drafts → two bash scripts** — RFC 2047 encode (chunked
   B-words ≤ 75 chars, never splitting a character) + decode (B and Q
   forms, adjacent-word whitespace drop), MIME build/unfold/parse in awk,
   `--self-test` modes, `GMAIL_STATE_DIR` test override, hardened HTTP
   status parsing.
5. **Equivalence verification actually ran** (the session's core value):
   - docs-health: Python-vs-Go side-by-side on fixtures — identical exit
     codes, byte-identical written files, identical stdout/stderr modulo
     deliberate improvements.
   - `check-draft.go`: 4 drafted cases — stdout and exit codes identical.
   - `analyze-corpus.go`: **real corpus** (10,682 items / 4,158 comments /
     271 edited) — ANALYSIS.md byte-identical minus timestamp;
     analysis.json structurally equal.
   - `collect-corpus.go`: offline fake-`gh` fixture — markdown corpus
     byte-identical, items/comments/edits JSON identical, summary equal
     except run timestamp.
   - gmail: fake-`curl` e2e green for drafts (spec-create/SKIP/list/
     delete) and eml export (dup suppression, pagination note, sha256).
6. **Seven real port bugs caught and fixed by the verification** (Go `$`
   anchor vs Python `$`; byte-vs-rune `[:800]` slicing shifting 5 voice
   items; dict-repr single quotes; JSON object-vs-array for top_repos;
   `ensure_ascii` `\uXXXX` escaping incl. surrogate pairs; `omitempty`
   dropping `"truncated": false`; several bash traps — `tr '-_'`,
   `${out:+= }`, awk CRLF, `${text%_*}`, `[:ascii:]`).
7. **All references updated in the same pass:** 3 SKILL.mds,
   `voice-profile.md`, the status-items harness (ported to the Go
   entrypoint + latent relative-`$0` path bug fixed), FEATURES.md,
   CHANGELOG entry, AGENTS.md §1 (Go tooling note) + §5.11 (ruff guidance
   replaced with the observed post-conversion gate output).
8. **Gates green:** `check-skills.sh` exit 0 (31 skills, links OK,
   symlinks OK), `buildflow -s ruff-check-fix` exit 0 (now the expected
   not-applicable rejection), shfmt clean repo-wide, gofmt clean ×4,
   go vet clean ×4, all self-tests green, `check-rows`/annotators verified
   against a PARTIAL-row fixture.
9. **12 `.py` removed via `git rm`; `__pycache__` trashed;** working tree
   left clean (auto-daemon committed; only this report untracked).

## b) PARTIALLY DONE 🟡

1. **Evidence artifacts live only in /tmp** — the equivalence harness
   (`/tmp/conv-cmp/cmp.sh`), the fake-`gh` collector fixture
   (`/tmp/cc-test/`), and the fake-`curl` gmail fixture (`/tmp/gmail-test/`)
   are cited as evidence by the prior session report and this one, but were
   **neither committed nor disclaimed** before the session wrapped. This is
   the exact documented 2026-09-08 trashed-ground-truth incident class.
   Disclaimed HERE; permanence is f1.
2. **shellcheck never ran on the two new `.sh` scripts** — not on PATH;
   `check-skills.sh` fell back to `bash -n` only. The scripts pass syntax +
   self-tests + fake-curl e2e, but zero advisory lint has seen them.
3. **buildflow full pipeline not run post-conversion** — only the single
   ruff step. How the fleet tool treats the new `.go`/`.sh` files
   (language detection, module fan-out, new shellcheck warnings) is
   unknown.
4. **gmail scripts never ran as the real `inboxclean` user on the real
   NixOS server** — the sudo flow is verified only against the fake-curl
   fixture; jq/curl presence on that specific host is assumed, not
   verified.
5. **collect-corpus resume path untested** — `--skip-discover` /
   `--skip-hydrate` (`loadItems`/`loadComments`) have no fixture coverage;
   only the full discover→hydrate→edits path ran.
6. **analyze-corpus `--since` untested** — the era-split suffix files
   (`analysis-since-*.json`) never generated by the Go version.
7. **Surrogate-pair title escaping untested at runtime** — `pyJSONString`
   handles astral chars ( inspected + code-reviewed), but no fixture had a
   title above U+FFFF.
8. **gopls stale diagnostics never cleared in-session** — the editor layer
   still lists 7 errors for deleted flat files and for annotate.go lines
   the compiler proves clean. Documented, restarted twice, still stale; a
   fresh session should confirm quiet. Cosmetic but misleading.
9. **The "22→26 assertions" doc bump is verified only Go-side** — I never
   captured the Python harness's printed count before deletion. The
   assertion list is byte-identical (I only swapped the invocation), and
   the old "22" was itself stale (the 2026-10-04 bold-cell block added 5),
   so 26 is correct now — but the parity claim for the _number_ rests on
   reasoning, not a captured baseline.
10. **Fan-out delivery not read through the symlink layer** — check-skills
    verifies symlink existence, but I never did the global-AGENTS.md
    "read the skill through the fan-out path" check (`readlink` + head via
    `~/.agents/skills/...`) after editing SKILL.mds.

## c) NOT STARTED ⬜

1. **Real GitHub corpus re-collection with the Go collector** (~45 min
   authenticated run) — `collect-corpus.go` has never spoken to the real
   API.
2. **Voice-profile number refresh** — the profile's counts (979 comments,
   6,508 threads, 271 edits) cite Python-era collection; after a real Go
   run they will legitimately shift and need re-harvesting.
3. **Real-server gmail smoke test** — nothing staged via the actual
   `sudo -u inboxclean` flow since the port.
4. **Nix wrapper / prebuilt-binary story** — `go run` requires a Go
   toolchain at skill-runtime; no flake or fallback exists for machines
   without one (incl. the inboxclean host and SSH-Mac sessions).
5. **check-skills structural awareness of `.go` assets** — no gate asserts
   self-test presence, gofmt, or per-dir-per-main layout; nothing prevents
   a future second `main` in a dir from re-breaking tooling.
6. **`.gitignore` for `__pycache__/`** — trashed this session; nothing
   prevents regeneration noise if Python ever returns.
7. **TODO_LIST / HARVEST routing** — intentionally deferred per
   report-then-WAIT (precedent 2026-10-08 b3); f-list below is unharvested.
8. **how-to-write-skills.md "porting doctrine"** — the
   equivalence-first method (old vs new side-by-side, shim-based offline
   e2e) is this repo's best new practice and is not yet encoded anywhere
   reusable.

## d) TOTALLY FUCKED UP 💥

Nothing destroyed, nothing corrupted, no data loss, no reverts — but two
process failures deserve the red card:

1. **Uncommitted evidence (b1)** — the session's central claims (byte-level
   equivalence) rest on harnesses that exist only in `/tmp`. One reboot and
   every "trust me, it matched" claim loses its reproduction path. The
   repo has a named incident for exactly this and I walked into it anyway.
   Mitigated by this disclaimer, not fixed.
2. **I introduced a doc defect while fixing references** —
   `docs-health/SKILL.md` line 158 is now a dangling sentence fragment
   ("classifies every data row…") because I replaced the sentence it used
   to continue. Found by my own post-hoc fact-check while writing this
   report, not by any gate (markdownlint passes it). Fix is one line (f2).
3. **Honorable mention — wasted cycles from my own harness bugs:** the
   fake-`gh` shim's `per_page=100`/`per_page=1` pattern collision made BOTH
   collectors test the empty path (caught because `items_total: 0` looked
   wrong in _both_ outputs — the both-agree-on-wrong trap); an earlier
   `cd` in a compound command ran the rest of the invocation in the wrong
   directory. Caught, fixed, but both were avoidable with a slower first
   pass.

## e) WHAT WE SHOULD IMPROVE 🔧

1. **Equivalence testing should be a permanent repo pattern, not /tmp
   scratch** — the Python↔Go diff harness + shim fixtures are the reason
   this port is trustworthy; they should live in the repo (e.g.
   `docs-health/assets/testdata/`, `github-voice/scripts/collect-corpus/
   testdata/`) with a committed runner.
2. **Capture the baseline BEFORE deleting the original** — the 22→26
   assertion-count question only exists because I ported and deleted in
   the same session without snapshotting the original harness output.
   Order should be: port → prove parity (capture both outputs) → delete.
3. **Gates should know about the new asset class** — check-skills could
   assert: every `assets/*.go` has a `self-test` subcommand, one `main`
   per dir, gofmt-clean. Right now nothing guards the invariants the
   conversion depends on.
4. **"Errors that help" changes need a compatibility note** — FAIL lines
   moved stdout→stderr, tracebacks became clean errors. An improvement,
   but any muscle-memory `… | grep FAIL` pipeline silently changes
   meaning. Such divergences should be listed in one place (they are
   currently scattered across this session's messages).
5. **Shim fidelity is its own skill** — the fake-`gh`/fake-`curl` shims
   needed three correctness iterations (pattern collision, `-w` status
   lines, CRLF/JSON shapes). A shared, tested shim utility would stop
   each session rebuilding and re-debugging mocks.
6. **Run the whole verification suite in one committed script** — I ran
   ~12 gates ad hoc across the session; a single `verify-conversion.sh`
   (self-tests + harnesses + gofmt/vet + sweeps) would have caught the
   gofmt-missed-files gap immediately instead of at final-sweep time.
7. **Fact-check the diff, not just the compile** — the SKILL.md:158
   fragment survived every gate because all of them check structure, not
   prose. A docs-diff read-through belongs in the checklist when edits
   touch multi-sentence reference text.

## f) UP TO 50 THINGS TO GET DONE NEXT (brainstorm — HARVEST must route; most are ROADMAP fuel)

**Evidence & verification debt (this session's loose ends)**

1. Commit the equivalence harness + fake-`gh`/fake-`curl` fixtures as permanent repo testdata (or explicitly decide they were one-shot).
2. Fix `docs-health/SKILL.md` line 158 dangling fragment (one-line doc fix).
3. Run buildflow full pipeline post-conversion; triage new shellcheck/golangci findings on the new files.
4. Install shellcheck (nix shell) and run the advisory pass on both gmail scripts.
5. Read a skill file through the fan-out path (`~/.agents/skills/...`) to verify delivery per the global-AGENTS rule.
6. Add a repo-wide gate: forbid new `*.py` under skill dirs (encodes the conversion policy).
7. Add check-skills checks for Go assets: `self-test` subcommand present, one `main` per dir, gofmt-clean.
8. Add `.gitignore` entry for `__pycache__/`.
9. Fresh-session confirmation that gopls diagnostics are quiet (stale cache complaint).
10. Run `sync-html-kit.sh --check` + `link-skills-to-agents.sh --check` explicitly once post-conversion (cheap, not yet run explicitly this session).

**Test coverage gaps (found, untested paths)**
11. collect-corpus fake-`gh` e2e for the resume path (`--skip-discover`/`--skip-hydrate`).
12. analyze-corpus fixture test for `--since` era-split outputs.
13. Surrogate-pair (emoji) title fixture through `pyJSONString` vs `json.dumps`.
14. fake-curl fixture for gmail error paths (HTTP 403/500 → `die` message shape).
15. fixture for gmail `--delete` + `--spec` combined run (ordering preserved).
16. Body-with-trailing-newline fixture for gmail MIME round-trip.
17. `--kind` before/after-file order-independence test for check-draft.
18. Fuzz `pyJSONString` against Python `json.dumps` over random Unicode (100-string one-liner).

**Real-world proof**
19. Real authenticated `collect-corpus.go` run (~45 min) + corpus diff vs the Python-era snapshot.
20. Refresh `voice-profile.md` numbers after the real run; re-verify the check-draft calibration claims (0% misses / ~3% false alarms) against the corpus with the Go checker.
21. Hand over the real-server gmail one-liner for a smoke test (drafts --list first, read-only).
22. Verify jq/curl/base64/iconv presence on the inboxclean host before the first real run.
23. Re-run analyze-corpus on the refreshed corpus and re-harvest any shifted profile claims.

**Docs & doctrine**
24. Encode the equivalence-first porting doctrine in `how-to-write-skills.md` (port → prove parity → delete order).
25. Polish `docs-health/SKILL.md` tooling paragraphs into non-fragment prose (beyond line 158).
26. Rename the harness header comment (`check-annotator.sh` → actual filename) — inherited inconsistency.
27. Document the deliberate divergences (FAIL→stderr, clean errors vs tracebacks, usage exit 2) in one place — likely annotate.go header or a references note.
28. Document the annotate asymmetry: `rows` has `--section` occurrence suffixes, `prose` does not (Python parity, but undocumented).
29. Note GNU-date dependency in gmail_eml_export.sh (macOS `date` differs; skill used over SSH from Mac).
30. AGENTS.md §10: add `go` toolchain to the external-dependencies table for the affected skills.
31. README: runtime prerequisites note (go for github-voice/docs-health tools; curl+jq for gmail).

**Tooling ergonomics**
32. Single committed `verify-conversion.sh` running all self-tests + harnesses + format/vet gates in one command.
33. Shared, tested fake-`gh`/fake-`curl` shim utility (stop rebuilding mocks per session).
34. Prebuilt-binary or nix-run fallback for the Go tools (machines without a Go toolchain).
35. GOCACHE fallback note in AGENTS.md (session hit an unwritable /mnt/buildcache mid-run; /tmp override unblocked it).
36. gmail scripts: evaluate extracting shared helpers into one sourced lib with an embed-at-`cp`-time step (drift risk vs the self-contained requirement — needs a decision, not silent duplication).
37. gmail_drafts.sh: friendly error when spec `cc`/`bcc` is a string instead of an array.
38. gmail_eml_export.sh: optional beyond-`--limit` pagination flag (Python also truncated — document or extend).

**Larger sweeps (ROADMAP-class)**
39. Run `check-rows` over all archived `docs/status/` files as a one-off uniformity audit.
40. Re-run the session's equivalence harness after any future annotator edit (make it the documented regression test, not a one-off).
41. Consider `go.work`-based multi-file Go tooling IF the repo ever reopens the no-go.mod rule (would enable real `go test`); explicitly rejected this session — record the ADR.
42. Sweep `docs/planning/` for now-executed `.py` references (historical class — annotate rather than rewrite, per docs-health doctrine).
43. Add the `GMAIL_STATE_DIR`/shim-test pattern to the gmail SKILL.md testing section (currently only in script headers).
44. `check-draft.go`: re-run the 518-text calibration corpus through the Go checker to re-ground the "0% misses / ~3% false alarms" claim.
45. Ensure the aggregation repo (`agent-skills`) picks up the new files on its next sync (cosmetic per §5.10, verify once).
46. Add `--self-test` presence to the skill-authoring checklist (how-to-write-skills.md) so future scripts ship testable.
47. Decide whether `cmp.sh`-style diff harnesses should print a machine-readable PASS line (grep-able gate) — small standardization.
48. Review whether `annotate.go self-test` should also cover `check-rows` + `emit-keys` paths (currently only rows/prose/markers are self-tested; check-rows/emit-keys rely on the bash harness + cmp suite).
49. Consider splitting gmail `http()` retries (none exist; Python had none either — but 45-min collectors retry, gmail doesn't; document as known behavior).
50. Close the loop on this report: HARVEST-worthy items → TODO_LIST (per docs-health; deferred now per report-then-WAIT).

## g) QUESTIONS I CANNOT FIGURE OUT MYSELF

1. **Evidence permanence policy:** should the equivalence harness and the fake-`gh`/fake-`curl` fixtures be committed as permanent repo testdata (they make the port's claims reproducible forever), or were they one-shot session scaffolding you're fine losing with /tmp? This decides f1 and whether the "byte-identical" claims remain auditable.
2. **Go toolchain guarantee:** is `go` guaranteed at runtime on every machine that runs these skills (the SSH-Mac sessions, the inboxclean NixOS server), or should the Go-based skill tools get a nix-run wrapper / prebuilt-binary fallback? This decides f4/f34 and whether the SKILL.md invocations are safe as written.
3. **Real-server gmail verification:** do you want the hand-over one-liner for a real `inboxclean` smoke test now (I'd stage nothing — `--list` only, read-only), or is the fake-curl e2e coverage sufficient until the next real drafting session? This decides f21/f22.

---

_Verification snapshot: `check-skills.sh` exit 0 · zero `.py` in skills · gofmt/vet clean ×4 · self-tests green ×4 · harness 26/26 · buildflow ruff green (not-applicable). Prior report: `2026-10-11_03-55_python-to-go-bash-conversion.md` (conversion detail); this report adds the self-review layer and the honest misses above._
