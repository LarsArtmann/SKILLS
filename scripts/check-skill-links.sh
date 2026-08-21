#!/usr/bin/env bash
#
# check-skill-links.sh — CI-grade broken-internal-link detection.
#
# WHY THIS EXISTS
#   check-skills.sh only verifies relative links inside SKILL.md files. The
#   bulk of this repo's content is references/*.md, whose links to sibling
#   files and in-file anchors (TOCs, cross-section deep links) silently rot
#   when files are renamed or headings edited. An ad-hoc Python one-liner did
#   this on 2026-08-14 and was never productized (docs/status/2026-08-14_14-22
#   e7/f12); this is the permanent version.
#
# WHAT IT CHECKS (per .md file under a skill directory)
#   1. Relative file links  ](path) and ](./path) and ](../path) — target
#      must exist (images included).
#   2. Fragment links       ](#anchor) — anchor must be a heading slug in the
#      SAME file (GitHub-style slugs: lowercase, punctuation stripped, spaces
#      to hyphens, duplicates suffixed -1, -2, ...).
#   3. File + fragment      ](path#anchor) — target file must exist AND the
#      anchor must exist in it.
#   Only local targets are checked; http(s)/mailto/absolute URLs are skipped.
#   Links inside fenced code blocks are skipped.
#
# USAGE
#   scripts/check-skill-links.sh           # check all skill .md files
#   scripts/check-skill-links.sh <file>... # check specific files
#   exit 0 = clean, exit 1 = broken links found

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ $# -gt 0 ]]; then
	files=("$@")
else
	mapfile -t files < <(
		find . -name '*.md' -type f \
			! -path "*/assets/*" \
			! -path "*/originals/*" \
			! -path "*/.git/*" \
			! -path "./docs/*" \
			! -name "CHANGELOG.md" |
			sort
	)
fi

python3 - "${files[@]}" <<'PYEOF'
import os
import re
import sys

files = sys.argv[1:]
repo = os.getcwd()

FENCE_RE = re.compile(r"^```")
LINK_RE = re.compile(r"(!?)\[[^\]]*\]\(([^)\s]+)\)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)$")
# GitHub slugger: keep word chars, spaces, and hyphens; lowercase; spaces -> '-'
STRIP_RE = re.compile(r"[^\w\s-]", re.UNICODE)


def slugify(text: str) -> str:
    return STRIP_RE.sub("", text.strip().lower()).replace(" ", "-")


def headings_of(lines):
    """Return the set of valid GitHub-style heading anchors (with dup suffixes)."""
    slugs, counts = set(), {}
    in_code = False
    for line in lines:
        if FENCE_RE.match(line):
            in_code = not in_code
            continue
        if in_code:
            continue
        m = HEADING_RE.match(line)
        if not m:
            continue
        slug = slugify(m.group(2))
        n = counts.get(slug, 0)
        counts[slug] = n + 1
        slugs.add(slug if n == 0 else f"{slug}-{n}")
    return slugs


def strip_fences(lines):
    out, in_code = [], False
    for line in lines:
        if FENCE_RE.match(line):
            in_code = not in_code
            continue
        if not in_code:
            out.append(line)
    return out


cache = {}
def load(path):
    if path not in cache:
        try:
            with open(path, encoding="utf-8") as fh:
                lines = fh.read().splitlines()
            cache[path] = (strip_fences(lines), headings_of(lines))
        except OSError:
            cache[path] = None
    return cache[path]


broken = 0
for f in files:
    rel = os.path.relpath(f, repo)
    loaded = load(f)
    if loaded is None:
        print(f"FAIL {rel}: unreadable")
        broken += 1
        continue
    lines, slugs = loaded
    for lineno, line in enumerate(lines, 1):
        for _, target in LINK_RE.findall(line):
            if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("//"):
                continue  # external / scheme URLs
            path_part, _, fragment = target.partition("#")
            if path_part == "":
                if fragment and fragment not in slugs:
                    print(f"FAIL {rel}:{lineno}: broken anchor '#{fragment}' (no matching heading)")
                    broken += 1
                continue
            resolved = os.path.normpath(os.path.join(os.path.dirname(f), path_part))
            resolved_rel = os.path.relpath(resolved, repo)
            if not os.path.exists(resolved):
                print(f"FAIL {rel}:{lineno}: broken link '{target}' -> '{resolved_rel}' does not exist")
                broken += 1
                continue
            if fragment and os.path.isfile(resolved) and resolved.endswith(".md"):
                target_loaded = load(resolved)
                if target_loaded and fragment not in target_loaded[1]:
                    print(f"FAIL {rel}:{lineno}: broken anchor in '{resolved_rel}': '#{fragment}' (no matching heading)")
                    broken += 1

if broken:
    print(f"\nFAIL: {broken} broken link(s) found.")
    sys.exit(1)
print(f"OK: no broken internal links in {len(files)} markdown files.")
PYEOF
