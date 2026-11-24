# Process Lessons (Hard-Won, From Real Sessions)

> Landing ground for T111 (discipline items routed 2026-11-10 from the
> 2026-09-10/13, 2026-09-12/14, and 2026-10-08 reports) plus the lessons of
> the 2026-11-23/24 TODO sweep. The SKILL.md entry point keeps only the five
> most-re-hit rules; this file is the full catalog. Every entry names the rule,
> the concrete failure it prevents, and a dated report. Entries that restate a
> rule owned by `AGENTS.md`, `SESSION-START.md`, or `scripts/check-skills.sh`
> point at the owner instead of restating it.

## Contents

- [Evidence, exit codes, and claims](#evidence-exit-codes-and-claims)
- [Editing discipline](#editing-discipline)
- [Scripts, gates, and validators](#scripts-gates-and-validators)
- [Repo and host environment](#repo-and-host-environment)
- [Extractions and generated artifacts](#extractions-and-generated-artifacts)
- [Carried general rules](#carried-general-rules)

## Evidence, exit codes, and claims

- **Quote exit codes from redirected runs, never from a pipeline tail.**
  `cmd | head -3; echo $?` prints `head`'s exit, not the command's — an
  exec-bit smoke test read `exit=0` while the script exits 1
  (2026-09-10 02-55 report, b3/d1), and `| tail` reported buildflow as
  exit 0 when the true exit was 69 (2026-11-23 02-36 report, d4). End every
  piped verification with `> /tmp/x.log 2>&1; echo "exit=$?"`.
  `SESSION-START.md` step 5 owns this for gates; this entry extends it to
  every verification command.
- **A verification claim names the command and the mode.** "Verified
  end-to-end" is not a claim; `buildflow -s ruff-check-fix --format finding`
  → exit 0, 0 findings (fast mode, ruff skipped) is. A CHANGELOG sentence
  oversold a "full pipeline" run that was fast mode (2026-09-10 02-55
  report, b1/d4/d5/e2).
- **Checklist compliance is reported, not just performed.** If a checklist
  step was skipped, the report's checklist section says so in those words;
  the 02-45 report silently omitted a skipped ROADMAP grep (2026-09-10
  02-55 report, d3/e3).
- **Write chat summaries from the evidence table, not from the conclusion.**
  A user-facing summary rounded cluster-based partial reads up to "All 29
  skills examined pairwise" while the report's own table said less
  (2026-09-14 11-36 report, d5).
- **Verify numbers before shipping them, including your own counts.**
  "7 consumer repos" shipped from `go.mod` greps that never checked
  `// indirect` markers; the real count was 6 direct plus 1 indirect
  (2026-10-08 23-18 report, d5/b1/e2). A guessed sub-claim pin took two
  writes where one verified write belonged (2026-11-23 05-03 report, d2).
- **Copy external URLs from fetched payload bytes, never compose them from
  pattern intuition.** A hand-written Federal Register date was wrong
  (`/2024/08/26/` vs the API `html_url`'s 2024-08-22) — the exact
  fabrication class `verify-external-claims` §0 bans (2026-11-23 05-03
  report, d1/e1).
- **Claim "it landed" only after reading it back.** "CHANGELOG entry landed"
  was written before anyone checked that no such entry existed
  (2026-11-23 02-36 report, d3). For repo-state claims specifically,
  `AGENTS.md` §5.12 rule 1 (git status + git log first) owns the rule.
- **Run both advisory reports when an edit touches description AND body.**
  The step-5 checklist item is two-condition, not either/or; a session that
  edited a description ran only `--signal` and skipped `--triggers`
  (2026-10-08 23-18 report, d6/e7).
- **Self-review before declaring Done, and make the read-back cover the
  whole file, not just the edited region.** Every defect in that session
  was findable by a read-back pass minutes earlier (2026-10-08 23-18
  report, e8).
- **Pinned volatile values (versions, counts) carry an explicit re-verify
  trigger** (e.g. "re-check at toolsdk/v1.16+") — otherwise the same pin
  drifts independently in every file that copies it (2026-10-08 23-18
  report, b4/e6).
- **Any new sentence about an external tool's behavior gets
  "verified: how/date" or gets hedged.** Unverified CLI/limit/flag claims
  were written into a reference while `verify-external-claims` was loaded
  (2026-08-21) and had to be softened later.
- **When a reference documents external tools whose behavior was checked,
  put a verification-status table in the reference** (claim / status /
  source, dated). See `how-to-golang/references/performance-tuning.md` and
  `domain-types.md` for the pattern — it tells the next session what is
  verified fact vs. plausible prose.
- **SKILL.md-level verification blocks follow one canonical format**: the
  `## Verification status` table (Claim / Status / Source, ✅/❌) defined in
  `verify-external-claims/SKILL.md` §5. Three skills had drifted into three
  different shapes (2026-09-08 report).

## Editing discipline

- **When inserting before a header, include the header verbatim in
  `new_string`.** A multiedit replaced the `## SARIF` anchor instead of
  inserting before it and was caught only in read-back (2026-10-08 23-18
  report, d1/e1).
- **Markdown tables: never a literal pipe inside a cell, count pipes per
  row after every table edit, and verify `git diff -w` after every
  formatter run.** A raw `int|string|bool` cell would have silently broken
  a row (2026-10-08 23-18 report, d2/e4); dprint truncated an evidence cell
  mid-row because unescaped pipes re-align tables (2026-10-30 03-48
  report, d2/e1). The `-w` diff catches a formatter that ate content, not
  whitespace.
- **After a scripted edit of a file, diff before/after and account for
  EVERY removed line — then make a test exercise the code the edit could
  have deleted.** Three string-slice insertions silently deleted a
  four-line assignment; only shellcheck's SC2154 caught it, which is the
  second rule: run shellcheck/shfmt BEFORE declaring a shell change done
  (2026-09-11).
- **Under `set -o pipefail`, never put an early-exit consumer downstream of
  a chatty producer.** `fc-list | grep -qi` reported both fonts MISSING on
  96 matches: `grep -q` exits at first match, the producer gets SIGPIPE
  (141), pipefail promotes it. Capture the producer's output to a variable
  and parse that (2026-09-11).
- **Run `date` before naming any timestamped file.** A report was named
  `19-02` when the mtime was 22:23 (2026-10-08 23-18 report, d4/e3), and
  after midnight a session's remembered "today" is stale (2026-11-24
  sweep). Zero-cost rule.
- **Verify sed ranges, dates, counts, and names against the source in the
  same breath as writing them.** A guessed `--help` sed range (`2,23p`)
  truncated the header's last line, a report shipped with a wrong date, and
  a count was hardcoded into AGENTS prose — all preventable in seconds at
  write time, all caught only at review time (2026-09-13 14-29 report,
  d5/d6/d7/e1).
- **Pre-count description length before editing a description: `wc -c` on
  the extracted text.** A 1024-char overflow cost three edit rounds because
  the limit was discovered at save time (2026-11-23 02-36 report, e4);
  linter-building sat at 988/1024 with the next addition already needing a
  prune (2026-10-08 23-18 report, f24).

## Scripts, gates, and validators

- **Smoke-execute every script the moment it is written, against the
  smallest dataset available.** An analyzer was written without
  smoke-executing it and three trivial bugs surfaced only after the 46-min
  corpus run; lint alone does not catch invalid regexes in unused
  constants, `KeyError`s, or stray braces (2026-09-12 10-55 report, e1;
  2026-09-12 11-25 report, d4).
- **Validate the validator in both directions before trusting it: run any
  new check against a known-good AND a known-bad tree, and exercise the
  FAIL path before the PASS path.** A scaffold checker's self-bugs were
  found only by the both-direction run (2026-11-23 06-09 report, e2/d6); a
  checker run against 518 ground-truth texts found 3 real genres and 2
  over-strict rules (2026-09-12 11-25 report, e5); a script's FAIL-branch
  diagnostic pipe aborted the whole script under `set -e` + pipefail
  mid-loop (2026-11-23 05-03 report, d4/e3).
- **"Verify the fix" includes the fix's own flags, run to conclusion.** A
  broken `--fix --budget` leg shipped "done" because the one command that
  reached it was never run to its end — its exit 0 was the silent no-op
  path (2026-11-23 02-36 report, d2/e3).
- **Gate edits are fixture-first: write the fixture BEFORE touching a
  gate's awk/parsing.** Two consecutive check-skills breakages (shell
  quoting inside an awk program) were caught only because the selftest leg
  existed (2026-11-23 02-36 report, d1/e2).
- **Before any positive/negative verification run, state the threshold the
  code keys on and size the fixture past it.** Two verification runs were
  wasted on 3.5 KB and 24 KB fixtures, both under the 30 KB threshold the
  insert condition keys on (2026-11-23 05-03 report, d3/e2).
- **Before encoding any FAIL/WARN threshold, grep the corpus stat that
  justifies it.** A header false-positive and a greeting false-positive
  were both avoidable with numbers the session already possessed
  (2026-09-12 11-25 report, e2).
- **Shebang ⇒ mode 755: any tracked file starting with `#!` is committed
  executable — audit with `git ls-files -s`.** EXE001 fired on two
  annotation scripts committed 644 (2026-09-10 02-45 report, root cause 1;
  02-55 report, e6/f6 — the check-skills automation of this is still
  pending).
- **Read the flag semantics first, speculate second.** A probe's own
  missing `-g` was blamed on the CLI for ~10 minutes while it scanned the
  CWD exactly as documented (2026-11-23 06-59 report, d6).
- **`rg -n` only: in ripgrep `-r` is `--replace`, not recursive — and a
  host hook blocks `rg -r`/`rg -rn` after 4+ strikes.** One `-rn` run
  displayed mangled output that briefly narrated a false repo-wide rename
  (2026-09-14 11-36 report, d2); strikes three and four landed in the
  2026-11-23 sweep (05-03 d6, 06-59 d3/e3).
- **Check the listener (`ss -tlnp`) before serving a port.** A 404 was
  answered by a foreign service already holding port 8765
  (2026-11-23 06-59 report, d8).

## Repo and host environment

- **For multi-file rewrites, commit BEFORE the auto-commit daemon's next
  sweep — its timer is minutes.** Three of four intended detailed commits
  in one sweep segment were absorbed into heuristic bundles, leaving the
  detailed record only in the report (2026-11-23 06-09 report, e7; 06-59
  report, d7). `AGENTS.md` §7 and §5.12 own the daemon rules.
- **Machine-global gitignore patterns shadow at any depth: verify adds
  with `git ls-files` / `git check-ignore -v`.** `~/.config/git/ignore`'s
  `build/` made `git add -A` silently skip `internal/build/` (9 files); the
  clean-checkout proof failed `go vet`; fixed with a repo-local
  `!internal/build/` negation (2026-11-23 06-09 report, d2/e3).
- **`cp` from a Go module cache inherits the 0444 mode — the re-run fails
  permission-denied.** Use `install -m 644` (2026-11-23 06-09 report, d4).
- **Pre-flight connectivity before network-dependent work: `gh auth
  status` plus a DNS/TCP probe to the target host before drafting.** A
  batch blocked mid-flight on an invalid token plus an unreachable
  api.github.com:443 (2026-11-23 06-59 report, e4/g1). This is Pattern 1
  (Pre-flight Checks) applied to the session itself.
- **DNS flake waves: diagnose with `dig` per nameserver plus a TLS-by-IP
  probe; retry a network WRITE only on the pre-request connect failure so
  it can never be sent twice; then verify it landed by reading the object
  back and comparing byte-for-byte with the draft.** The local resolver
  intermittently SERVFAILs one host while others resolve (2026-11-24
  sweep, orchestrator-verified; report pending).
- **An "upstream issue" TODO row is a hypothesis until the
  verify-before-filing duplicate gate runs.** T141's finding turned out to
  be filed upstream four times already; comment the new delta on the
  canonical issue instead of filing again (2026-11-24 sweep,
  orchestrator-verified; report pending). `verify-before-filing` Gate 5
  owns the duplicate search.

## Extractions and generated artifacts

- **Module-copy extraction checklist: strip workspace `replace` directives
  at copy time, regenerate with the PINNED generator version, and expect
  goldens to embed the old identity — plan their regeneration as a
  first-class step.** A standalone build failed with confusing multi-path
  errors before the workspace state was found (2026-11-23 05-03 report,
  d5/e4).
- **Clean-checkout proof: any extraction/scaffold task proves from a fresh
  clone, and a regeneration oracle is path-verified in a clean environment
  BEFORE trusting its output.** A stats walker silently scanned the whole
  `~/projects` tree locally and committed goldens containing counts from
  unrelated repos; caught only because the /tmp clone panicked on a
  permission-denied sibling (2026-11-23 06-09 report, d1/e1 — the
  session's highest-ROI verification step).
- **Assemble-then-verify: after generating from a template, grep for the
  template's structural tokens (style block, a known class) BEFORE
  rendering.** A brief lost its entire 842-line CSS block to string
  surgery — head was computed but never concatenated — and only the render
  check caught it (2026-11-23 06-59 report, d1/e1).

## Carried general rules

- **The Questions tool has a ~200-char limit per choice description.**
  Full skill descriptions run 300-700 chars — they do not fit. When asked
  to review long-form text with the user, write the candidates to a
  markdown review file the user can browse (or execute and present a diff)
  instead of burning rounds fighting the tool. (2026-08-11 report, d1)
- **The trash rule applies to scratch and temp directories too.** `rm -rf
  /tmp/foo` in test commands violates the same safety rule as anywhere
  else — repeated while testing safety tooling (2026-08-12 and 2026-08-21
  reports). Use `trash`, always, no path exceptions.
- **A decision gate that recognizes exactly one payoff currency is a
  structural bias.** Any population that can never pay in that currency
  gets "no action" as the only possible verdict — the gate silently
  becomes a keep-the-monolith rule wearing neutrality's clothes. Give
  decision gates at least two payoff currencies, each with its own evidence
  bar and decay rule, and probe a changed gate with a fresh-session eval
  before shipping the doctrine. (2026-11-15 reports, d4/e1; go-modularize
  evals 4-5 are the persisted probe)
