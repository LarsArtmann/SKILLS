#!/usr/bin/env python3
"""Check a draft GitHub issue/PR/comment/review against Lars's voice rules.

This is the mechanical second pass of the github-voice skill: it catches
what agents get wrong even after reading the profile — AI-tell phrases,
wrong register (headers in comments, thin bodies), greeting/sign-off
boilerplate, double-hedging, emoji overuse, and AI-attribution
inconsistency. The third pass (human re-read against the profile's
Do/Never table) stays with the agent; this script is grep, not judgment.

Ban lists are empirical: every FAIL phrase has 0 hits across 555
external texts (>= 2024) in Lars's corpus, verified 2026-09-12. Do not
add phrases on vibes — re-verify against the corpus first (the profile
section "AI-tells" documents the method).

Usage:
    check-draft.py --kind comment draft.md
    check-draft.py --kind body-issue --ai-drafted draft.md
    check-draft.py --list          # show all checks and phrase lists

Exit codes: 0 = no FAIL (WARN allowed), 1 = at least one FAIL,
2 = usage error.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Verified 0 hits in 555 external corpus texts >= 2024 (2026-09-12).
FAIL_PHRASES = [
    "i hope this helps",
    "hope this helps",
    "please let me know",
    "let me know if",
    "thank you for bringing this to our attention",
    "great question",
    "i'd be happy to",
    "i would be happy to",
    "happy to help",
    "as an ai",
    "don't hesitate",
    "do not hesitate",
    "thanks for your patience",
    "thank you for your patience",
    "apologies for the delay",
    "sorry for the delay",
    "amazing project",
    "great project",
    "awesome project",
    "first of all",
    "dear maintainers",
    "dear team",
    "hi team",
    "hello team",
    "thanks in advance",
    "thank you in advance",
    "unfortunately,",
    "furthermore,",
    "moreover,",
    "of course!",
    "absolutely!",
    "sure thing",
    "delve into",
    "please note that",
    "it's worth noting",
    "kindly",
    "that being said",
    "with that said",
    "going forward,",
]

# Present in the corpus only rarely or in natural technical use (counts
# in parentheses) — warn, never fail.
WARN_PHRASES = {
    "feel free to": 1,
    "in summary": "technical noun 'summary' in crush context",
    "to summarize": "technical verb in crush context",
    "additionally,": 1,
    "best regards": "1 formal 2024 email signature",
    "certainly!": 0,
    "leverage": 2,
    "utilize": 2,
    "seamless": 2,
}

SIGNOFF_RE = re.compile(
    r"(?i)^(thanks!?|thank you!?$|best regards.*|kind regards.*|"
    r"cheers!?$|sincerely.*|regards,?.*)\s*$"
)
GREETING_RE = re.compile(r"(?i)^\s*(hi|hello|hey|dear|greetings)\b")
DOUBLE_HEDGE_RE = re.compile(
    r"(?i)\b(i think|i believe|maybe|might|perhaps)\b[^.!?]{0,60}"
    r"\b(i think|i believe|maybe|might|perhaps)\b"
)
EMOJI_RE = re.compile(
    "[\U0001F000-\U0001FAFF\u2600-\u27BF\u2B00-\u2BFF\u2139\uFE0F]"
)
EMOJI_HEADER_RE = re.compile(r"^#+.*[\U0001F000-\U0001FAFF\u2600-\u27BF]", re.MULTILINE)
HEADER_RE = re.compile(r"^#{1,6} ", re.MULTILINE)
FOOTER_RE = re.compile(r"(generated with|co-authored-by|assisted-by)", re.IGNORECASE)
EVIDENCE_RE = re.compile(
    r"(```|\]\(|https?://|^\s*\|)", re.MULTILINE | re.IGNORECASE
)


def content_lines(text: str) -> list[str]:
    out = []
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith(">"):
            continue
        out.append(s)
    return out


def check(kind: str, text: str, ai_drafted: bool) -> list[tuple[str, str, str]]:
    findings: list[tuple[str, str, str]] = []
    low = text.lower()
    lines = content_lines(text)

    for phrase in FAIL_PHRASES:
        if phrase in low:
            findings.append(
                ("FAIL", "ai-tell phrase",
                    (f'"{phrase}" — 0 hits in corpus'))
            )
    for phrase, note in WARN_PHRASES.items():
        if phrase in low:
            findings.append(
                ("WARN", "rare phrase", f'"{phrase}" ({note}) — usually AI')
            )

    if DOUBLE_HEDGE_RE.search(text):
        findings.append(
            ("FAIL", "double hedge",
             "two hedges in one sentence — corpus has zero")
        )

    if lines:
        first = lines[0]
        if kind != "announcement" and "@" not in first:
            if re.match(r"(?i)^\s*(dear|greetings)\b", first):
                findings.append(
                    ("FAIL", "greeting opener",
                     ('"Dear/Greetings" openers: 0 hits in corpus — '
                      "open with the problem instead"))
                )
            elif GREETING_RE.match(first):
                findings.append(
                    ("WARN", "greeting opener",
                     ("hi/hey openers are rare (10/555 corpus texts) "
                      "and real when addressed: 'Hey guys,' / "
                      "'Hi @name' — otherwise open with the problem"))
                )
        last = lines[-1]
        if SIGNOFF_RE.match(last):
            findings.append(
                ("FAIL", "sign-off",
                 f'"{last}" — never signs off')
            )

    emoji_count = len(EMOJI_RE.findall(text))
    if kind != "announcement" and EMOJI_HEADER_RE.search(text):
        findings.append(
            ("FAIL", "emoji header",
             ("emoji in headers is agent-era style "
              "(allowed only in announcement kind)"))
        )

    if kind in ("comment", "review"):
        if HEADER_RE.search(text):
            findings.append(
                ("FAIL", "headers in comment",
                 ("comments are plain text — if this is a release "
                  "announcement or an AI-assisted review report, use "
                  "--kind announcement"))
            )
        if emoji_count >= 3:
            findings.append(
                ("FAIL", "emoji overuse",
                 (f"{emoji_count} emoji — quick comments carry 0-1 "
                  "(2+ only in the announcement genre)"))
            )
        elif emoji_count == 2:
            findings.append(
                ("WARN", "emoji count",
                 "2 emoji — quick comments carry 0-1")
            )
        if len(text) > 600 and not EVIDENCE_RE.search(text):
            findings.append(
                ("WARN", "long comment without evidence",
                 ("long comments in the corpus are evidence dumps "
                  "(code fence, link, or table) — this is just prose"))
            )
        if FOOTER_RE.search(text):
            findings.append(
                ("FAIL", "footer on comment",
                 "AI-attribution footers never appear on quick comments")
            )
    else:
        emoji_cap = 24 if kind == "announcement" else 4
        if emoji_count > emoji_cap:
            findings.append(
                ("WARN", "emoji overuse",
                 (f"{emoji_count} emoji — beyond anything in the "
                  "corpus for this kind"))
            )
        if len(text) < 200:
            findings.append(
                ("WARN", "thin body",
                 (f"{len(text)} chars — 2026 body register is long+"
                  "structured (median ~1,050)"))
            )
        if ai_drafted and not FOOTER_RE.search(text):
            findings.append(
                ("FAIL", "missing attribution",
                 ("AI-drafted bodies carry a footer "
                  '(e.g. "💘 Generated with Crush")'))
            )
        if not ai_drafted and FOOTER_RE.search(text):
            findings.append(
                ("WARN", "footer without --ai-drafted",
                 ("footer present but flag not set — pass --ai-drafted "
                  "or remove the footer if you wrote it unaided"))
            )
    return findings


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("file", nargs="?", help="draft file ('-' for stdin)")
    ap.add_argument(
        "--kind",
        required=True,
        choices=["body-issue", "body-pr", "comment", "review",
                 "announcement"],
        help="announcement = release posts / AI-assisted review "
        "reports: headers, emoji headers, 'Hi,' openers, and AI "
        "footers are allowed there",
    )
    ap.add_argument(
        "--ai-drafted",
        action="store_true",
        help="mark as AI-drafted (bodies then REQUIRE an attribution "
        "footer)",
    )
    ap.add_argument("--list", action="store_true",
                    help="list all checks and phrase lists, then exit")
    args = ap.parse_args()

    if args.list:
        print("FAIL phrases (0 hits in corpus, verified 2026-09-12):")
        for p in FAIL_PHRASES:
            print(f"  {p}")
        print("\nWARN phrases (rare or technical in corpus):")
        for p, note in WARN_PHRASES.items():
            print(f"  {p}  ({note})")
        print("\nStructural checks: ai-tell grep, double-hedge, greeting "
              "opener (unless @mention), sign-off, emoji headers, "
              "comment: no headers / max 1 emoji / no footer, body: "
              "attribution footer iff --ai-drafted, thin-body warn.")
        return 0

    if not args.file:
        ap.error("file required (or use --list)")
    text = (
        sys.stdin.read() if args.file == "-"
        else Path(args.file).read_text()
    )
    findings = check(args.kind, text, args.ai_drafted)
    fails = [f for f in findings if f[0] == "FAIL"]
    warns = [f for f in findings if f[0] == "WARN"]
    for level, name, msg in findings:
        print(f"{level}: [{name}] {msg}")
    print(
        f"== {len(fails)} FAIL, {len(warns)} WARN "
        f"({'VOICE CHECK PASSED' if not fails else 'FIX THE FAILS'})"
    )
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
