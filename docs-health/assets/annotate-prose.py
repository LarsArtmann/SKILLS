#!/usr/bin/env python3
"""Annotate prose-numbered list items (1. text / **N.** etc.) in a status report.

Usage: annotate-prose.py [--dry-run] <file> <section-prefix> <spec>...
  section-prefix: e.g. "## f)" scopes to lines between this heading and the
    next "## " heading (empty string = whole file)
  spec = <item-number>:<kind>:<value>
    kind h -> done at `h1`, `h2`     (value comma-separated hashes)
    kind v -> done (<value>)         (verified without a commit, short evidence)
    kind p -> done (docs-health pass <value-or-today>)
    kind w -> **Won't implement — <value>.**

--dry-run prints the would-be new line instead of writing. Wraps the ENTIRE
original item text in ~~...~~ and appends the marker. Fails loudly on
missing/duplicate item numbers and already-annotated lines; writes only if
every spec matched (atomic in-memory then single write).
"""
import re
import sys
from datetime import date
from pathlib import Path


def marker_for(kind: str, value: str) -> str:
    if kind == "h":
        return "done at " + ", ".join(f"`{h}`" for h in value.split(","))
    if kind == "v":
        return f"done ({value})"
    if kind == "p":
        return f"done (docs-health pass {value if value != '-' else date.today().isoformat()})"
    if kind == "w":
        return f"**Won't implement — {value}.**"
    raise SystemExit(f"bad kind {kind!r} (use h/v/p/w)")


def main() -> None:
    argv = sys.argv[1:]
    dry_run = "--dry-run" in argv
    argv = [a for a in argv if a != "--dry-run"]
    if len(argv) < 3:
        raise SystemExit(__doc__)
    target = Path(argv[0])
    prefix = argv[1]
    lines = target.read_text().splitlines(keepends=True)
    if prefix:
        start = next((i for i, l in enumerate(lines) if l.startswith(prefix)), None)
        if start is None:
            raise SystemExit(f"section {prefix!r} not found")
        end = next(
            (i for i, l in enumerate(lines[start + 1 :], start + 1) if l.startswith("## ")),
            len(lines),
        )
    else:
        start, end = 0, len(lines)
    done = []
    for spec in argv[2:]:
        try:
            num_s, kind, value = spec.split(":", 2)
        except ValueError:
            raise SystemExit(
                f"bad spec {spec!r} — expected <number>:<kind>:<value>; "
                "quote values containing spaces"
            )
        num = int(num_s)
        marker = marker_for(kind, value)
        pat = re.compile(r"^(\s*)(?:\d+\.|\*\*\d+\.\*\*)\s")
        hits = [
            i
            for i in range(start, end)
            if pat.match(lines[i]) and re.match(rf"^\s*(?:\*\*)?{num}\.(?:\*\*)?\s", lines[i])
        ]
        if len(hits) != 1:
            raise SystemExit(f"item {num}: expected 1 match in section, found {len(hits)}")
        i = hits[0]
        if "~~" in lines[i]:
            raise SystemExit(f"item {num}: already annotated")
        raw = lines[i].rstrip("\n")
        m = re.match(r"^(\s*)((?:\*\*)?\d+\.(?:\*\*)?\s*)(.*)$", raw)
        new = f"{m.group(1)}{m.group(2)}~~{m.group(3)}~~ {marker}"
        if dry_run:
            print(f"DRY {target.name} item {num}:\n  - {raw}\n  + {new}")
        else:
            lines[i] = new + ("\n" if lines[i].endswith("\n") else "")
        done.append(num)
    if not dry_run:
        target.write_text("".join(lines))
    print(f"{target.name}: {'would annotate' if dry_run else 'annotated'} {len(done)} items -> {sorted(done)}")


if __name__ == "__main__":
    main()
