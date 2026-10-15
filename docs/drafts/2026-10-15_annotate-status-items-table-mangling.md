# annotate status-items strikes whole table rows, destroying markdown tables

## Problem

`annotate.go status-items` resolves `| N | ...` table rows via `reTableRowKey` (annotate.go:177) but strikes the entire line at annotate.go:710-714 (`"~~" + stripped + "~~ " + verdict`). The `~~...~~` wrap crosses the leading and trailing pipes, so the row stops matching markdown table syntax: it detaches from the table and renders as a strikethrough paragraph, orphaning the header and separator rows above it.

This is exactly the report shape the docs-health AUDIT produces — `a)`/`d)` FULLY-DONE tables are common, and every table row annotated through status-items loses table integrity.

## Repro

docs-health @ `5e15779` (`docs-health/assets/annotate.go`):

```console
$ printf '## Fully done\n\n| # | Item |\n| --- | --- |\n| 1 | alpha row |\n| 2 | beta row |\n| 3 | gamma row |\n' > repro.md
$ go run annotate.go emit-keys repro.md 5 6 7      # emits 1@alpha row, 2@beta row, 3@gamma row
$ go run annotate.go status-items repro.md repro.spec
OK repro.md: annotated 3 items
$ cat repro.md
## Fully done

| # | Item |
| --- | --- |
~~| 1 | alpha row |~~ done — evidence A
~~| 2 | beta row |~~ done — evidence A
~~| 3 | gamma row |~~ done — evidence A
```

Three struck rows, zero table body rows left. The tool reports success; the corruption is only visible in a rendered view.

## Fix direction

**Strike the cells, not the row**: keep the leading `| N |` and the trailing `|` outside the strike and put the verdict inside the last cell, e.g. `| 1 | ~~alpha row~~ done — evidence A |`. The table stays parseable and the verdict stays in the row. Alternative: refuse table rows in status-items and route them to a table-aware command — but the current silent destruction is the worst of the options.

Found during the 2026-10-15 docs-health audit session in LarsArtmann/httputil (TODO row: "report the annotate-status-items `| N |`-table mangling defect to the skill repo").

💘 Generated with Crush
