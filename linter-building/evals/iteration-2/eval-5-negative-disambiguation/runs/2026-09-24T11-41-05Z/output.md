Tiny Go project (no flake.nix), so I'll run the Go toolchain per the scan process.Build and vet pass. Now golangci-lint and duplication scan:All quality gates pass on `fixture/tiny`:

| Gate | Command | Result |
|---|---|---|
| Build | `go build ./...` | OK (exit 0) |
| Vet | `go vet ./...` | OK (exit 0) |
| Lint | `golangci-lint run ./...` | 0 issues |
| Duplication | `art-dupl --type-aware -t 5` | 0 clone groups |

One manual finding golangci-lint's defaults don't catch:

- **Medium** — main.go:6: `errors.New("")` creates an error with an empty message, so callers/logs get a blank error string. Give it a domain message (e.g. `errors.New("run failed")`). Left as-is since this looks like an intentional minimal fixture.

No HTML report written: zero findings in a two-file fixture would make an empty dashboard; say the word if you want one anyway.
