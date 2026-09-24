"""Shared resolution-marker builder for the docs-health annotate scripts.

Canonical vocabulary (docs-health SKILL.md, ANNOTATE): `done at <hashes>`,
`**Won't implement — <reason>.**`, plus the evidence markers
`done — <evidence>` and `done (docs-health pass <date>)`. Both
annotate-rows.py and annotate-prose.py build their markers here so the
formats cannot drift — they had: rows emitted `done — x`, prose emitted
`done (x)` for the same kind; unified 2026-09-24 to the dash form (the
corpus majority and the style of the other dash variants).
"""

import re
from datetime import UTC, datetime


def marker_for(kind: str, value: str) -> str:
    if kind == "h":
        hashes = ", ".join(f"`{h}`" for h in value.split(","))
        return f"done at {hashes}"
    if kind == "v":
        evidence = re.sub(r"^done\b[\s:—-]*", "", value.strip())
        return f"done — {evidence}" if evidence else "done"
    if kind == "p":
        return f"done (docs-health pass {value if value != '-' else datetime.now(tz=UTC).date().isoformat()})"
    if kind == "w":
        return f"**Won't implement — {value}.**"
    raise SystemExit(f"bad kind {kind!r} (use h/v/p/w)")
