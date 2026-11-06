> [!NOTE]
> This filing was drafted by GLM-5.3 via Crush from an AI-run investigation, not at my request. When the failure traces to an external report, that source is linked in the body.
>
> - [ ] MANUALLY REVIEWED by `@Lars Artmann` at `[<date-time>]`

## Symptom

`nix build .#buildflow` at master (42d5ebdc2) fails, so the fleet binary cannot be refreshed past e81c11834-dirty — the freshness check (`buildflow --version` vs `git rev-parse --short HEAD`) is unsatisfiable until this builds again. Found while executing the httputil TODO_LIST "Redeploy the buildflow binary" row (fleet apidiff/cue-vet already run on e81c11834; only the HEAD refresh is blocked).

```text
_local_deps/samber-do-auditlog/live/fragments_templ.go:696:62: undefined: templruntime.NewAttributeExpression
_local_deps/samber-do-auditlog/live/fragments_templ.go:1037:61: undefined: templruntime.NewAttributeExpression
_local_deps/samber-do-auditlog/live/fragments_templ.go:1037:61: too many errors
nix log /nix/store/sr25anba9ki7d68p07cps6bxh85629v4-buildflow-42d5ebd.drv
```

## Root cause (source)

- `templruntime.NewAttributeExpression` exists only in templ v0.3.1100 (`templ@v0.3.1100/runtime/attributeexpression.go`); it is absent from v0.3.1070 (verified in the module cache).
- samber-do-auditlog master regenerated its committed fragments for templ v0.3.1100 on 2026-11-05 (b51d80a, after the 2026-11-04 v0.3.1070 regen 02783c9); `live/fragments_templ.go` calls the symbol 11 times and its go.mod pins templ v0.3.1100.
- BuildFlow's `go.mod:331` still `replace`s `github.com/a-h/templ => v0.3.1070` (switched on 2026-11-04, 783ae8106), pinning the whole build — including the vendored `_local_deps` copy of the sibling — to a runtime without that symbol.

## Fix

**Bump the replace at `go.mod:331` from v0.3.1070 to v0.3.1100** (go.mod already carries v0.3.1100 as the indirect requirement at `go.mod:82`), then re-prune go.sum for the new runtime hashes.

## To verify

- [ ] `nix build .#buildflow` at master succeeds
- [ ] SystemNix lock probe (`nix flake lock --update-input buildflow` + build, flake.nix:623 discipline) passes at the fix rev
- [ ] CI green on the fix commit (the #89 local-path-replace strips stay intact)

💘 Generated with Crush
