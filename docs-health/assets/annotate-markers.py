"""Shared resolution-marker builder for the docs-health annotate scripts.

Canonical vocabulary (docs-health SKILL.md, ANNOTATE): `done at <hashes>`,
`**Won't implement — <reason>.**`, the decision marker
`**NOT-DO — <reason>.**` (added 2026-09-27 for decided-against items that
are not "won't implement" verdicts on a request), plus the evidence markers
`done — <evidence>` and `done (docs-health pass <date>)`. Both
annotate-rows.py and annotate-prose.py build their markers here so the
types cannot drift — they had: rows emitted `done — x`, prose emitted
`done (x)` for the same kind; unified 2026-09-24 to the dash form (the
corpus majority and the style of the other dash variants).

The routed verdict `**→ <verdict>**` (kind `r`, added 2026-09-30) carries
the full verdict phrase in the value — `done — landed at <hash>`,
`open — owner lane (TODO_LIST row)`, `routed → TODO_LIST` — matching the
2026-09-29+ house table grammar: NO strike, bold arrow appended in the
task cell, the exact shape repo-side marker gates (e.g. nix-international-
telephony scripts/markers_check.py) accept.
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
    if kind == "n":
        return f"**NOT-DO — {value}.**"
    if kind == "r":
        verdict = re.sub(r"^→\s*", "", value.strip())
        return f"**→ {verdict}**" if verdict else "**→ resolved**"
    raise SystemExit(f"bad kind {kind!r} (use h/v/p/w/n/r)")
