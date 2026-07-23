# Verification Sources and Strategies

Concrete sources to check before trusting an external claim.

## Go ecosystem

| What | Where to look |
| --- | --- |
| Package docs, signatures, versions | `https://pkg.go.dev/\u003cimport-path\u003e` |
| Standard library source | `https://cs.opensource.google/go/go` |
| `golang.org/x` source | `https://github.com/golang` and `go.googlesource.com` |
| Analysis passes roster | `golang.org/x/tools/go/analysis/passes/` |
| gopls analyzers | `gopls/doc/analyzers.md` in the `tools` repo |
| Code search across repos | Sourcegraph, `grep.app`, GitHub search |

## Nix ecosystem

| What | Where to look |
| --- | --- |
| Package options, source | `https://search.nixos.org` |
| nixpkgs source | `https://github.com/NixOS/nixpkgs` |
| flake-parts docs | `https://flake.parts` |
| treefmt-nix docs | `https://github.com/numtide/treefmt-nix` |

## JavaScript / TypeScript

| What | Where to look |
| --- | --- |
| Package versions, README | `https://npmjs.com/package/\u003cname\u003e` |
| JSR registry | `https://jsr.io` |
| Type docs | `https://github.com/\u003cowner\u003e/\u003crepo\u003e` source |

## Python

| What | Where to look |
| --- | --- |
| Package versions | `https://pypi.org/project/\u003cname\u003e/` |
| Source | `https://github.com/\u003cowner\u003e/\u003crepo\u003e` |

## Rust

| What | Where to look |
| --- | --- |
| Crate versions, docs | `https://crates.io/crates/\u003cname\u003e`, `https://docs.rs/\u003cname\u003e` |

## General source code

| Tool | Use when |
| --- | --- |
| Sourcegraph | Cross-repo search for API usage, import paths, tool names |
| `grep.app` | Fast source search across public repos |
| GitHub search | Specific repo, issue, or release lookup |
| `fetch` on a URL | Raw docs or API responses |
| `agentic_fetch` | Complex extraction, summarization, or ambiguous pages |

## How to run a minimal check

### Go API signature

Create a temporary file:

```go
package main

import "errors"

func main() {
    var _ func(error) (error, bool) = errors.AsType[error] // compile check
}
```

Then run `go build` with the claimed Go version.

### CLI behavior

```bash
some-tool --help
some-tool lint ./...; echo "exit code: $?"
```

If the tool does not exist, the shell will report `command not found` immediately.

### Nix flake input

```bash
nix flake metadata github:owner/repo
```

This verifies the repo exists and is reachable without building.

## What to record

When you verify a claim, record enough context that a future reader can reproduce the check:

- URL and exact section
- Command run and its output
- Version tested
- Date verified

If you cannot verify, record that too: "searched <source> on <date>; no public binary found."
