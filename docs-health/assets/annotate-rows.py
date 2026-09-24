#!/usr/bin/env python3
"""Annotate numbered (or M1/B1/F1.1-style) table rows in a report with done-at markers.

Usage: annotate-rows.py [--dry-run] [--section <heading-prefix>] <file> <spec>...
  spec = <row-id>:<kind>:<value>          (row-id: digits, M1/B1-style, or dotted F1.1-style IDs)
    kind h -> done at `value` (comma-separated hashes in value, split on ,)
    kind v -> done — <value>          (verified evidence, no commit)
    kind p -> done (docs-health pass <value-or-today>)
    kind w -> **Won't implement — <value>.**

--section scopes matches to the region from the first line starting with
<heading-prefix> (e.g. "## f)") up to the next same-level "## " heading;
without it the whole file is searched. When no --section is given but the
file has an "## f)" section, that section is still preferred (legacy
behaviour of the 2026-08 resolving-items pattern).

--dry-run prints the would-be new row instead of writing (ALWAYS dry-run a
new file class first — the 2026-08-16 marker-placement bug shipped because
the first live run mutated without a scratch check).

The already-annotated guard ignores tildes inside inline code spans: a row
describing strikethrough syntax (a literal `~~...~~` example in a cell)
must not look like an annotated row. The 2026-09-16 F12.1-class false trip
blocked annotating exactly the rows that talk about the marker syntax.

After a real write the file is READ BACK and shape-checked (same line
count, every annotated line still carries its marker). This is the guard
against the 2026-08-27 newline-collapse class of bug, where a custom
variant script's `\\s*$` regex swallowed newlines and collapsed a table to
two lines AFTER a correct in-memory edit — write-time races and regex
surprises must abort loudly, not corrupt the report. On shape mismatch the
original content is restored before exiting.

Pattern (docs-health resolving-items.md): strike every cell of the row,
append the marker inside the FIRST cell (the task column). Fails loudly on
missing/duplicate rows and on already-annotated rows; writes only if every
spec matched (atomic in-memory then single write + read-back check).
"""

import importlib.util
import re
import sys
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "annotate_markers", Path(__file__).with_name("annotate-markers.py")
)
_marker_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_marker_mod)
marker_for = _marker_mod.marker_for


def outside_code_spans(line: str) -> str:
    """Line with inline code spans removed, so tildes inside backticks (a
    literal `~~...~~` example) don't false-trip the already-annotated guard.
    Doubled-backtick spans (which may contain single backticks) are stripped
    first, then single-backtick spans."""
    without_double = re.sub(r"``.+?``", "", line)

    return re.sub(r"`[^`]*`", "", without_double)


def already_annotated(line: str) -> bool:
    """True when the line carries strikethrough outside inline code spans."""
    return "~~" in outside_code_spans(line)


def strike_row(line: str, row: str, marker: str) -> str:
    m = re.match(r"^(\|\s*)([A-Za-z]?[A-Za-z0-9.]*)(\s*\|)(.*)(\|)\s*$", line)
    if not m or m.group(2) != row:
        raise SystemExit(
            f"row {row}: line does not match table-row shape: {line[:80]!r}"
        )
    cells = m.group(4).split("|")
    struck = [f" ~~{c.strip()}~~ " for c in cells]
    struck[0] = struck[0].rstrip() + f" {marker} "
    return m.group(1) + f"~~{m.group(2)}~~" + m.group(3) + "|".join(struck) + m.group(5)


def heading_level(line: str) -> int:
    """ATX heading level of line, 0 when the line is not a heading."""
    m = re.match(r"^(#{1,6})\s", line)
    return len(m.group(1)) if m else 0


def scoped_lines(lines: list[str], section: str | None) -> tuple[int, int]:
    """(start, end) index range of the section; whole file when unscoped.

    The end boundary is the next heading of the SAME OR HIGHER level than the
    section heading, so a `### a)` sub-section stays scoped inside its `## f)`
    parent instead of bleeding past sibling `###` blocks (level-aware scoping,
    upstreamed 2026-09-14 after two `###`-table reports needed a custom
    variant). `section` may carry a 1-based occurrence suffix (`### a)#2`) to
    pick among repeated headings whose row numbers collide.
    """
    auto = "## f)"
    prefix = section
    if prefix is None and any(l.startswith(auto) for l in lines):
        prefix = auto
    if prefix is None:
        return 0, len(lines)

    occurrence = 1
    suffix = re.search(r"#(\d+)$", prefix)
    if suffix:
        occurrence = int(suffix.group(1))
        prefix = prefix[: suffix.start()]

    matches = [i for i, l in enumerate(lines) if l.startswith(prefix)]
    if len(matches) < occurrence:
        raise SystemExit(
            f"section {prefix!r} occurrence {occurrence} not found "
            f"(found {len(matches)})"
        )

    start = matches[occurrence - 1]
    level = heading_level(lines[start])
    if level == 0:
        raise SystemExit(f"section start {lines[start]!r} is not a heading")

    end = next(
        (
            i
            for i, l in enumerate(lines[start + 1 :], start + 1)
            if 0 < heading_level(l) <= level
        ),
        len(lines),
    )
    return start, end


def main() -> None:
    argv = sys.argv[1:]
    dry_run = "--dry-run" in argv
    argv = [a for a in argv if a != "--dry-run"]
    section = None
    if "--section" in argv:
        i = argv.index("--section")
        if i + 1 >= len(argv):
            raise SystemExit("--section needs a heading-prefix argument")
        section = argv[i + 1]
        del argv[i : i + 2]
    if len(argv) < 2:
        raise SystemExit(__doc__)
    target = Path(argv[0])
    original = target.read_text()
    lines = original.splitlines(keepends=True)
    start, end = scoped_lines(lines, section)
    edits: dict[int, str] = {}
    for spec in argv[1:]:
        try:
            row, kind, value = spec.split(":", 2)
        except ValueError:
            raise SystemExit(
                f"bad spec {spec!r} — expected <row-id>:<kind>:<value>; "
                "quote values containing spaces"
            )
        if not re.fullmatch(r"[A-Za-z]?[A-Za-z0-9.]*", row):
            raise SystemExit(
                f"bad row id {row!r} (digits, M1/B1-style, or dotted F1.1-style)"
            )
        marker = marker_for(kind, value)
        pat = re.compile(rf"^\|\s*{re.escape(row)}\s*\|")
        hits = [i for i, l in enumerate(lines) if start <= i < end and pat.match(l)]
        if len(hits) != 1:
            where = f" in section {section!r}" if section else ""
            raise SystemExit(f"row {row}: expected 1 match{where}, found {len(hits)}")
        i = hits[0]
        if already_annotated(lines[i]):
            raise SystemExit(f"row {row}: already annotated")
        edits[i] = strike_row(lines[i].rstrip("\n"), row, marker) + (
            "\n" if lines[i].endswith("\n") else ""
        )
        if dry_run:
            print(
                f"DRY {target.name} row {row}:\n  - {lines[i].rstrip()}\n  + {edits[i].rstrip()}"
            )
    if dry_run:
        print(f"{target.name}: would annotate {len(edits)} rows -> {sorted(edits)}")
        return
    for i, new in edits.items():
        lines[i] = new
    target.write_text("".join(lines))

    # Shape assertion (the newline-collapse guard): read back and verify.
    reread = target.read_text()
    reread_lines = reread.splitlines(keepends=True)
    problems = []
    if len(reread_lines) != len(original.splitlines(keepends=True)):
        problems.append(
            f"line count changed: {len(original.splitlines())} -> {len(reread_lines)}"
        )
    for i, new in edits.items():
        if i >= len(reread_lines) or new.strip() not in reread_lines[i]:
            problems.append(
                f"line {i + 1}: annotated row missing or mangled after write"
            )
    if problems:
        target.write_text(original)  # restore; never leave a collapsed table
        raise SystemExit(
            "SHAPE CHECK FAILED (original restored):\n  " + "\n  ".join(problems)
        )
    print(
        f"{target.name}: annotated {len(edits)} rows -> {sorted(edits)} (shape verified)"
    )


if __name__ == "__main__":
    main()
