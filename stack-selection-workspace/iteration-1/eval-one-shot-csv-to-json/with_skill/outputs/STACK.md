# STACK — csv2json (one-shot conversion script)

> Degraded self-run fixture (no subagent): the stack-selection skill executed
> inline by its author against evals/evals.json id 3, 2026-10-27. Records the
> procedure's actual decisions, not a polished example.

## Profile

| Axis          | Answer                              |
| ------------- | ----------------------------------- |
| Shape         | one-shot CLI script                 |
| Domain        | convert one CSV file to JSON once   |
| Persistence   | none                                |
| Interfaces    | terminal (argv in, stdout out)      |
| Scale target  | single run, then discard            |
| Constraints   | throwaway — minimize ceremony       |

## Chosen foundation

| Category         | Choice (first-party = ★) | Why this, not that                                          | Owning skill / docs | Revisit when          |
| ---------------- | ------------------------ | ----------------------------------------------------------- | ------------------- | --------------------- |
| CSV reading      | stdlib `encoding/csv`    | stdlib is sufficient; no first-party CSV lib exists in meta  | Go stdlib           | format quirks emerge  |
| JSON writing     | `encoding/json/v2`       | Go 1.25+ policy (how-to-golang); all third-party JSON banned | how-to-golang       | —                     |
| Init error style | ★ go-must (marginal)     | 2-3 `must.Must(...)` calls vs `if err != nil` noise in main  | README + pkg.go.dev | grows beyond one file |

## Deliberately excluded

| Candidate          | Reason                                                                              |
| ------------------ | ------------------------------------------------------------------------------------ |
| ★ cmdguard (92)    | one-shot script — no durable flag structure, no config files; stdlib `flag` suffices |
| ★ go-output (90)   | single fixed output format (JSON to stdout); go-output's multi-format power is dead weight here |
| ★ go-ndjson (63)   | input is CSV, not newline-delimited JSON                                             |
| ★ universal-workflow (92) | zero workflow — single linear conversion                                       |
| ★ go-taskqueue (63) | single file, no queue                                                              |

## Wiring order

1. `go mod init` + no deps beyond (optionally) go-must
2. No owning skill to load — nothing selected has one (that is the correct
   outcome for a one-shot script; a maximal stack here would be the failure)

## Decision log

- 2026-10-27 — Initial selection (degraded self-run of stack-selection,
  evals/evals.json id 3).
