# Session Status: Python-to-Go/bash Conversion (12 files, 2,802 lines)

**Date:** 2026-10-11 03:55 · **Scope:** all 12 Python script assets in
docs-health/assets, github-voice/scripts, gmail-drafts/scripts · **Mode:**
engineering (directive: "convert all into Go or .sh")

## a) FULLY DONE ✅

1. **All 12 Python files (2,802 lines) converted and deleted** — zero `.py`
   remains in any skill directory.
2. **docs-health → `assets/annotate.go`**: one Go program (subcommands
   `rows`/`prose`/`status-items`/`emit-keys`/`check-rows`/`self-test`)
   replacing the five annotator scripts + absorbing both `_test.py` files.
   Kills the importlib-by-hyphen hack and the marker-vocabulary drift risk
   the old docstrings documented. Atomic write, already-annotated guards
   (code-span aware), shape-check-and-restore, level-aware scoping,
   occurrence suffixes — all ported and fixture-tested.
3. **github-voice → three single-file Go programs** in per-package
   subdirectories (`check-draft/`, `analyze-corpus/`, `collect-corpus/`) —
   one `main` per dir keeps the repo module-less (no go.mod, §9) while
   staying gopls/golangci-clean.
4. **gmail-drafts → two bash scripts** (`gmail_drafts.sh`,
   `gmail_eml_export.sh`) with in-process RFC 2047 encode/decode (B + Q
   forms, chunked encoded-words ≤ 75 chars, whitespace-between-words drop),
   MIME build/unfold/parse in awk, `--self-test` modes, and a
   `GMAIL_STATE_DIR` test override.
5. **Equivalence verification (the core of the session):**
   - docs-health: side-by-side Python-vs-Go on fixtures — identical exit
     codes, byte-identical written files; 26-assertion bash harness green
     via both invocation styles.
   - check-draft: 4 drafted-case comparison — identical stdout + exit codes.
   - analyze-corpus: real corpus (10,682 items / 4,158 comments / 271
     edited) — ANALYSIS.md byte-identical (minus timestamp),
     analysis.json structurally identical.
   - collect-corpus: offline fake-`gh` fixture — markdown corpus
     byte-identical; items/comments/edits JSON identical; summary.json
     identical except the run timestamp.
   - gmail scripts: `--self-test` suites + fake-`curl` e2e (drafts
     create/SKIP/list/delete; eml export with dup suppression + pagination
     note + sha256 lines).
6. **All references updated in the same pass:** three SKILL.mds,
   `references/voice-profile.md`, `assets/annotate-status-items_test.sh`
   (ported to the Go entrypoint), FEATURES.md row, CHANGELOG entry,
   AGENTS.md §1 (Go tooling note) + §5.11 (ruff guidance replaced by the
   post-conversion gate reality).
7. **Gates:** `check-skills.sh` exit 0 (31 skills), `buildflow -s
   ruff-check-fix --format finding` exit 0 (now the expected
   not-applicable rejection), shfmt clean repo-wide, gofmt clean, go vet
   clean ×4, all self-tests green.

## b) Real bugs caught by verification (fixed in-session)

1. **Go `$` vs Python `$`**: Python's regex `$` matches before a trailing
   newline; Go's does not — the checkbox pattern silently failed on raw
   lines. Fixed by matching on newline-stripped lines (resolve + emit-keys).
2. **Byte vs rune slicing**: `body[:800]` in Go cut emoji-heavy agent bodies
   mid-rune and shifted 5 items between voice segments — fixed with rune
   slicing (both `isAgent` and `openingBucket`).
3. **Python dict-repr fidelity**: ANALYSIS.md openings needed single-quote
   Python repr; summary `top_repos*`/`comments_by_kind` needed JSON objects
   (not arrays) with Python dict ordering.
4. **`ensure_ascii=True`**: frontmatter titles must escape non-ASCII as
   `\uXXXX` (surrogate pairs above BMP) to match `json.dumps` defaults.
5. **`omitempty` dropped Python's explicit `"truncated": false`** — removed
   the tag.
6. **bash traps**: `tr '-_' '+/'` parses `-` as an option (use sed);
   `${out:+= }` yields `"= "` not `" "` (use `${out:+ }`); `[:ascii:]` is
   not a valid bash regex class (byte-length comparison instead); `^$` in
   awk misses `\r` lines (CRLF strip first); `${text%_*}` removes a suffix,
   not trailing underscores.
7. **Harness latent bug** (inherited from the Python original): relative
   `$0` + `cd "$(dirname "$0")"` broke `GO=` resolution — now `GO="$PWD/…"`
   after the cd; verified with both relative and absolute invocation.

## c) Design decisions

- **Go, single file, own directory, no go.mod**: preserves §9 (no build
  system) — each program runs via `go run <file.go>`, stdlib only. Tests
  port as `self-test` subcommands because `go test` needs a module.
- **One Go program for the five docs-health assets**: eliminates the
  shared-marker importlib mechanism entirely (the drift it existed to
  prevent becomes structurally impossible).
- **bash for the two gmail scripts**: linear REST flows (OAuth refresh +
  drafts/eml calls) map 1:1 to curl+jq; they must run as the `inboxclean`
  system user on NixOS, where a Go toolchain is not guaranteed but
  curl/jq/base64/iconv/awk are standard.
- **Deliberate improvements over byte-parity**: FAIL messages go to stderr
  (Python printed to stdout), clean errors replace Python tracebacks,
  `--kind`-less usage exits 2 uniformly, gmail scripts gained `--self-test`
  and `GMAIL_STATE_DIR`.

## d) Not done / follow-ups

1. **gopls diagnostics in this session's editor cache stayed stale** for
   moved/deleted files (compiler is authoritative and green) — worth a
   fresh session to confirm quiet.
2. **`buildflow` full pipeline** was not run (only the ruff gate) — the
   next full run should show shellcheck/markdownlint behavior on the new
   `.sh`/`.go` files; shellcheck is not on PATH locally (check-skills
   bash -n gate passed).
3. **Feature parity caveat (documented in-script):** gmail_drafts.sh
   B-encodes subjects in 11-rune chunks (≤ 75-char encoded-words, never
   splitting a character) vs Python's lib-generated folding — display-
   equivalent, not byte-equal on the wire.
4. **`drift-alarm-port-evaluation.md` line 44** still says "annotate-rows.py
   gained kind r" — intentional: it is a historical record of the
   2026-09-30 session, not a live reference.

## e) Lessons (project-level, encoded in AGENTS.md already)

- Equivalence testing (old vs new side-by-side on fixtures + real data)
  converts a risky 2,802-line port into a mechanical verification — the
  fake-`gh`/fake-`curl` shim pattern made the networked collectors fully
  testable offline, and the shim itself needs to emulate `-w` status lines
  to stay faithful.
- Python→Go silent traps concentrate in: regex `$` anchors, byte-vs-rune
  slicing, map ordering, JSON float/format fidelity, and `omitempty`.
- Python→bash silent traps concentrate in: shell option parsing inside
  arguments (`tr '-_'`), parameter-expansion idioms (`${out:+= }`),
  CRLF vs LF in line-oriented tools, and POSIX class availability.

## f) Harrowable items

None — no new open items. T30/T33/T34/T51 unchanged and untouched.

## g) Verification table

| Claim                             | Status      | Source                                                                    |
| --------------------------------- | ----------- | ------------------------------------------------------------------------- |
| 12 .py files converted, 0 remain  | ✅ Verified | `find docs-health github-voice gmail-drafts -name '*.py'` → 0             |
| docs-health annotators equivalent | ✅ Verified | cmp.sh suite green; 26-assertion harness green (both invocation styles)   |
| check-draft equivalent            | ✅ Verified | 4-case stdout/exit diff identical                                         |
| analyze-corpus equivalent         | ✅ Verified | real corpus: ANALYSIS.md byte-identical, JSON structurally equal          |
| collect-corpus equivalent         | ✅ Verified | fake-gh e2e: markdown identical, JSON identical (minus timestamp)         |
| gmail scripts functional          | ✅ Verified | --self-test green ×2; fake-curl e2e green ×2                              |
| Quality gates                     | ✅ Verified | check-skills exit 0; ruff not-applicable rejection; shfmt/gofmt/vet clean |
