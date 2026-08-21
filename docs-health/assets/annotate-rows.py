#!/usr/bin/env python3
"""Annotate numbered table rows in a status report with done-at markers.

Usage: annotate-rows.py [--dry-run] <file> <spec>...
  spec = <row-number>:<kind>:<value>
    kind h -> done at `value` (comma-separated hashes in value, split on ,)
    kind v -> done (<value>)          (verified evidence, no commit)
    kind p -> done (docs-health pass <value-or-today>)
    kind w -> **Won't implement — <value>.**

--dry-run prints the would-be new row instead of writing (ALWAYS dry-run a
new file class first — the 2026-08-16 marker-placement bug shipped because
the first live run mutated without a scratch check).

Pattern (docs-health resolving-items.md): strike every cell of the row,
append the marker inside the FIRST cell (the task column). Fails loudly on
missing/duplicate rows and on already-annotated rows; writes only if every
spec matched (atomic in-memory then single write).
"""

import re
import sys
from datetime import date
from pathlib import Path


def marker_for(kind: str, value: str) -> str:
    if kind == "h":
        hashes = ", ".join(f"`{h}`" for h in value.split(","))
        return f"done at {hashes}"
    if kind == "v":
        return f"done ({value})"
    if kind == "p":
        return f"done (docs-health pass {value if value != '-' else date.today().isoformat()})"
    if kind == "w":
        return f"**Won't implement — {value}.**"
    raise SystemExit(f"bad kind {kind!r} (use h/v/p/w)")


def strike_row(line: str, row: int, marker: str) -> str:
    m = re.match(r"^(\|\s*)(\d+)(\s*\|)(.*)(\|)\s*$", line)
    if not m:
        raise SystemExit(
            f"row {row}: line does not match table-row shape: {line[:80]!r}"
        )
    cells = m.group(4).split("|")
    struck = [f" ~~{c.strip()}~~ " for c in cells]
    struck[0] = struck[0].rstrip() + f" {marker} "
    return m.group(1) + f"~~{m.group(2)}~~" + m.group(3) + "|".join(struck) + m.group(5)


def main() -> None:
    argv = sys.argv[1:]
    dry_run = "--dry-run" in argv
    argv = [a for a in argv if a != "--dry-run"]
    if len(argv) < 2:
        raise SystemExit(__doc__)
    target = Path(argv[0])
    text = target.read_text()
    lines = text.splitlines(keepends=True)
    used = set()
    for spec in argv[1:]:
        try:
            row_s, kind, value = spec.split(":", 2)
        except ValueError:
            raise SystemExit(
                f"bad spec {spec!r} — expected <number>:<kind>:<value>; "
                "quote values containing spaces"
            )
        row = int(row_s)
        marker = marker_for(kind, value)
        pat = re.compile(rf"^\|\s*{row}\s*\|")
        hits = [i for i, l in enumerate(lines) if pat.match(l)]
        # scope to the f) action-items section when one exists
        f_start = next((i for i, l in enumerate(lines) if l.startswith("## f)")), None)
        if f_start is not None:
            f_end = next(
                (
                    i
                    for i, l in enumerate(lines[f_start + 1 :], f_start + 1)
                    if l.startswith("## ")
                ),
                len(lines),
            )
            hits = [i for i in hits if f_start <= i < f_end]
        if len(hits) != 1:
            raise SystemExit(f"row {row}: expected 1 match, found {len(hits)}")
        i = hits[0]
        if "~~" in lines[i]:
            raise SystemExit(f"row {row}: already annotated")
        new = strike_row(lines[i].rstrip("\n"), row, marker)
        if dry_run:
            print(f"DRY {target.name} row {row}:\n  - {lines[i].rstrip()}\n  + {new}")
        else:
            lines[i] = new + ("\n" if lines[i].endswith("\n") else "")
        used.add(row)
    if not dry_run:
        target.write_text("".join(lines))
    print(
        f"{target.name}: {'would annotate' if dry_run else 'annotated'} {len(used)} rows -> {sorted(used)}"
    )


if __name__ == "__main__":
    main()
