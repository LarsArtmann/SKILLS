## Problem

Nothing cross-checks the four places that name a module: `go.work`'s `use` list, `.github/dependabot.yml` directories, flake input/vendorHash wiring, and workflow `PACKAGES`/path filters. When a module moves or dies, the survivors keep referencing it and nothing fails — the drift is found by humans, late.

## Live instance

The 2026-09-23 `httputil/etagmetrics` → go-etag move left a dependabot entry pointing at the dead directory. Caught by manual audit (httputil report 2026-09-23_00-04, f26), not by any gate.

## Ask

**A detect-only step** that enumerates the module inventory from go.work and verifies every other surface references only live modules — and the reverse direction where coverage is expected (a go.work module absent from `PACKAGES`-style patterns is the same drift class). Findings, not repairs: which surface is stale is always a human decision.

💘 Generated with Crush
