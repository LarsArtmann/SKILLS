# annotate status-items: bare numbered keys strike the first match in the file, silently hitting the wrong section

## Problem

`resolve()` (annotate.go:596) walks the whole file top-down, first-unstruck-match-wins. A bare spec key `1` matches the FIRST unstruck `1.`-numbered line anywhere in the file — with no section awareness. Status reports routinely restate the same item numbers across sections (an §a spec list mirroring the §b findings); the 2026-10-15 docs-health audit session hit this as the "04-30 spec-list shift" corruption and had to restore the file from the strikethrough spans.

The operator intending §b gets §a struck, and the tool prints `OK: annotated 2 items`. The `prose` subcommand has `--section <prefix>` scoping; `status-items` has none. The `@substring` escape exists, but it is opt-in knowledge and nothing warns when a bare key has multiple unstruck candidates in different sections.

## Repro

docs-health @ `5e15779` (`docs-health/assets/annotate.go`):

```console
$ printf '## a) Spec list\n\n1. First spec item\n2. Second spec item\n\n## b) Findings\n\n1. Finding one\n2. Finding two\n' > repro.md
$ printf '1\tdone — evidence B1\n2\tdone — evidence B2\n' > repro.spec
$ go run annotate.go status-items repro.md repro.spec
OK repro.md: annotated 2 items
$ cat repro.md
## a) Spec list

~~1. First spec item~~ done — evidence B1
~~2. Second spec item~~ done — evidence B2

## b) Findings

1. Finding one
2. Finding two
```

The §b items were the target; §a got struck. Nothing in the output hints at the section mismatch.

## Fix direction

**Fail (or at minimum WARN) when a bare key resolves while the same token exists on another unstruck line elsewhere in the file**, and require `@substring` disambiguation in that case — this mirrors the duplicate-spec-key guard at annotate.go:577-580, which already refuses silently-overwriting repeated keys. A `--section <prefix>` flag matching `prose`'s would work too.

Found during the 2026-10-15 docs-health audit session in LarsArtmann/httputil (status report §d1, the "04-30 spec-list shift" incident).

💘 Generated with Crush
