#!/usr/bin/env python3
"""Copy-then-splice: instantiate an editorial template without sed-range edits.

The go-legalparty five-skill session (2026-11-22) used this pattern for four
HTML reports: copy the editorial template, then replace ONE span — from the
first `        <nav>` line through `</footer>` — with the report's own
body. Span anchors beat line numbers because template line numbers drift
when the template evolves.

Usage:
    python3 splice_report.py <template.html> <output.html> <body.html>

`body.html` holds everything between (and including) the nav open tag and
the footer close tag. The script fails loudly if either anchor is missing
or non-unique — never guess spans.
"""

import sys
from pathlib import Path

NAV_ANCHOR = "        <nav>"
FOOTER_ANCHOR = "</footer>"


def splice(template_path: str, output_path: str, body_path: str) -> None:
    template = Path(template_path).read_text(encoding="utf-8")
    body = Path(body_path).read_text(encoding="utf-8")

    if template.count(NAV_ANCHOR) != 1:
        sys.exit(f"nav anchor not unique/missing in {template_path}: {template.count(NAV_ANCHOR)}")
    if template.count(FOOTER_ANCHOR) != 1:
        sys.exit(f"footer anchor not unique/missing in {template_path}: {template.count(FOOTER_ANCHOR)}")

    start = template.index(NAV_ANCHOR)
    end = template.index(FOOTER_ANCHOR) + len(FOOTER_ANCHOR)
    Path(output_path).write_text(template[:start] + body + template[end:], encoding="utf-8")
    print(f"spliced {template_path} -> {output_path} ({len(body)} body bytes)")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    splice(sys.argv[1], sys.argv[2], sys.argv[3])
