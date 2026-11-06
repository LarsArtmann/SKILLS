# docs-gates upstream notes — verified findings from fleet use

Three tool findings from the go-appkit corpus waves (2026-11-06), each
verified against the shipped binary/asset before this note. Filed here as
the tool's home repo; promote to real issues/fixes when the tooling window
opens.

## 1. Routed ≠ resolved — the freshness gate's green reads stronger than it is

**Finding:** `docs-gates freshness` counts an item CLOSED when the report
carries a routed verdict + `<!-- fresh:skip -->`, and `audit-all` (pin 0)
agrees — so a corpus can be FULLY GREEN while every one of those items is
open work living in TODO_LIST rows. The routing guard validates the MARKER
(resolves, venue-form), the freshness gate validates the CLOSURE — but
nothing reports "N items closed as routed (work still open)" as a number
you can watch. The 2026-11-06 go-appkit battery read `5/5 PASS` while
carrying ~15 routed open rows; the distinction was tribal knowledge.

**Verified:** go-appkit `docs-gates run .` on 2026-11-06 — freshness PASS +
audit-all PASS (0 unharvested) with open routed TODO rows present; the
routed-destinations guard separately reports `0 unrouted` (it checks the
markers, not the work).

**Proposal:** a freshness summary line — `closed: X done · Y superseded ·
Z routed (open work) · W not-do` — so the routed count is visible at the
gate surface, not by grepping TODO_LIST.

## 2. Compound §f blocks renumber positionally (address by PRINTED id, not line)

**Finding:** the prose matcher renumbers items positionally within a
section: a wrapped `22. …` block that is physically the SECOND item of the
section is addressed as id 22, and its match spans the wrap continuation
lines. `--emit-keys <file> <physical-line>` on the continuation line
answers "not a numbered row" while the dry-run for the PRINTED id spans
both physical lines. Sessions that map item id → physical line 1:1 write
specs that hit the wrong item.

**Verified (repro, 2026-11-06):**

```console
$ cat probe.md
## f) NEXT
10. ~~**Item ten.**~~ done (early).
22. **Item twenty-two with a long description that wraps across
    multiple lines in the rendered file.** Still open, needs routing.
$ annotate emit-keys probe.md 6 7     # physical lines
22@**Item twenty-two with a long de… / line 7: not a numbered row
$ annotate prose --dry-run probe.md "## f)" "22:v:probe evidence"
DRY probe.md item 22 (lines 6-7): … would annotate 1 items -> [22]
```

**Proposal:** `emit-keys` printing the PRINTED id per physical line (or a
`--printed` mode), so id↔line mapping is mechanical before every spec.

## 3. DF-boundary observability — the DF=8 genericity cliff needs a --explain-df

**Finding:** living-doc candidate lines are rejected at a distinctiveness
floor (DF=8 in the current build); when a pre-flight fails, the failure
does not say WHICH token genericized the line or what the candidate's DF
was — three go-appkit harvests in one day broke on `backlog`, `sweep`,
`mount` before the pattern was understood. `--pre-flight --duplicates`
reports SAFE/UNSAFE and (verbosely) lists boundary tokens it probed, but
there is no per-candidate score, no token ranking, and no
tokens-at-DF-6/7 view for drafting around the boundary.

**Verified:** `docs-gates freshness --help` (2026-11-06) exposes
`--pre-flight`, `--duplicates`, `--replace` — no `--explain-df`, no
score output; the boundary-token list only appears on the verbose probe
path.

**Proposal:** `--explain-df <candidates-file>`: per line, the DF score,
the distinctive-token ranking, and the tokens that would sit at DF 6-7 if
dropped — turning the boundary from trial-and-error into a drafting tool.
