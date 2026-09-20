#!/usr/bin/env python3
"""Annotate numbered/bulleted report items inline (docs-health skill asset).

Strikes item ranges (`~~line~~ marker`) for closed items, appends routing
markers (`← OPEN 🔴 → TODO_LIST #n`, `→ ROADMAP`, `→ backend plan`) for open
ones. Origin: sixth docs-health session (2026-09-20), /tmp helper hardened.

CLI (dry-run by default — pass --write to persist):
    python3 annotate_helper.py <file.md> --specs specs.json [--banner-json b.json] [--write]

specs.json: [{"prefix": "1. ", "mode": "done|open|plain", "marker": "done (<evidence>)"}]
banner-json: {"old": "exact old banner line", "new": "replacement line"}
`prefix` must match exactly one line (stripped). Item extent = the matched
line plus continuation lines until the next numbered item / `## ` / struck
line / bullet boundary (for bullets) / blank line.
"""
import json
import re
import sys
from pathlib import Path


def _extent(lines, start):
    end = start
    is_bullet = lines[start].strip().startswith("- ")
    item_re = re.compile(r"^\d+\\?\.\s")
    while end + 1 < len(lines):
        nxt = lines[end + 1]
        if (
            item_re.match(nxt.strip())
            or nxt.startswith("## ")
            or nxt.strip().startswith("~~")
            or nxt.strip() == ""
            or (is_bullet and nxt.strip().startswith("- "))
        ):
            break
        end += 1
    return end


def annotate(path, specs, banner_old=None, banner_new=None):
    p = Path(path)
    t = p.read_text()
    if banner_old:
        assert t.count(banner_old) == 1, "banner not unique"
        t = t.replace(banner_old, banner_new)
    lines = t.split("\n")
    for spec in specs:
        prefix, mode, marker = spec["prefix"], spec["mode"], spec["marker"]
        hits = [i for i, line in enumerate(lines) if line.strip().startswith(prefix)]
        assert len(hits) == 1, f"{prefix!r}: {len(hits)} hits"
        start = hits[0]
        end = _extent(lines, start)
        if mode == "open":
            assert "← OPEN" not in lines[end] and "~~" not in lines[end], prefix
            lines[end] = lines[end] + marker
        elif mode == "done":
            assert "~~" not in lines[end], prefix
            lines[start] = "~~" + lines[start].lstrip()
            lines[end] = lines[end] + "~~ " + marker
        elif mode == "plain":
            assert marker not in lines[end], prefix
            lines[end] = lines[end] + marker
        else:
            raise ValueError(f"unknown mode {mode!r}")
    return "\n".join(lines)


def main(argv):
    args = argv[1:]
    write = "--write" in args
    args = [a for a in args if a != "--write"]
    if len(args) < 2:
        print(__doc__)
        return 1
    target, specs_path = args[0], args[1]
    specs = json.loads(Path(specs_path).read_text())
    banner_old = banner_new = None
    if "--banner-json" in args:
        b = json.loads(Path(args[args.index("--banner-json") + 1]).read_text())
        banner_old, banner_new = b["old"], b["new"]
    result = annotate(target, specs, banner_old, banner_new)
    if write:
        Path(target).write_text(result)
        print(f"wrote {target}")
    else:
        print("DRY RUN — pass --write to persist. Result preview:")
        print(result)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
