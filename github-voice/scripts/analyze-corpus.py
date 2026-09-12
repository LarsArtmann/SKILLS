#!/usr/bin/env python3
"""Analyze the collected GitHub corpus and emit stats for the voice profile.

Reads raw/items.json, raw/comments.json, raw/edits.json produced by
collect-corpus.py (same --out directory) and writes analysis.json plus a
human-readable ANALYSIS.md. Segments the corpus by own/external repo and
artifact kind so the voice profile can weight external-repo writing (the
natural voice) over own-repo automation noise.

Usage:
	analyze-corpus.py [--out ~/.cache/github-voice-corpus]
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

EMOJI_RE = re.compile(
	"[\U0001F300-\U0001FAFF\u2700-\u27BF\u2600-\u26FF\u2B00-\u2BFF"
	"\U0001F000-\U0001F02F\u2139\uFE0F]"
)
GREETING_RE = re.compile(
	r"^(hey|hi|hello|thanks|thank you|sorry|+1|agree)", re.IGNORECASE
)


def pct(part: int, whole: int) -> float:
	return round(100 * part / whole, 1) if whole else 0.0


def quantiles(values: list[int]) -> dict:
	if not values:
		return {}
	sv = sorted(values)

	def take(q: float) -> int:
		return sv[min(int(q * len(sv)), len(sv) - 1)]
	return {
		"p10": take(0.10), "p50": take(0.50), "p90": take(0.90),
	}


def feats(body: str) -> dict:
	return {
		"chars": len(body),
		"words": len(body.split()),
		"code_fence": "```" in body,
		"inline_code": "`" in body,
		"link": "](" in body or "http" in body,
		"bullets": bool(re.search(r"^(\*|-|\d+\.) ", body,
		                       re.MULTILINE)),
		"header": bool(re.search(r"^#+ ", body, re.MULTILINE)),
		"bold": "**" in body,
		"emoji": bool(EMOJI_RE.search(body)),
		"mention": "@" in body,
		"question": "?" in body,
	}


def opening_bucket(body: str) -> str:
	first = body.strip().split("\n")[0][:60].lower()
	if re.match(r"^(hey|hi|hello)\b", first):
		return "greeting"
	if re.match(r"^(thanks|thank you|ty)\b", first):
		return "thanks-first"
	if re.match(r"^sorry\b", first):
		return "sorry-first"
	if first.endswith("?"):
		return "question-first"
	if first.startswith(("#", "##")):
		return "header-first"
	return "direct"


def ngrams(texts: list[str], n: int, top: int = 25) -> list:
	words = Counter()
	for t in texts:
		tokens = re.findall(r"[a-zA-Z']+", t.lower())
		for i in range(len(tokens) - n + 1):
			words[" ".join(tokens[i: i + n])] += 1
	return words.most_common(top)


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--out", default="~/.cache/github-voice-corpus")
	ap.add_argument("--own-owners", default="LarsArtmann,Artmann-Games")
	args = ap.parse_args()
	out = Path(args.out).expanduser()
	own = {o.strip() for o in args.own_owners.split(",")}

	items = json.loads((out / "raw" / "items.json").read_text())
	comments = json.loads((out / "raw" / "comments.json").read_text())
	edits = json.loads((out / "raw" / "edits.json").read_text())

	AGENT = ["Task ID:", "Impact Score", "**Phase:**", "ISSUE TYPE",
	         "Priority: 🔥", "TECHNICAL DEBT:", "## 🚨", "### 🎯",
	         "- **Effort", "**Effort:**"]

	def is_agent(body: str) -> bool:
		head = body[:800]
		return sum(1 for m in AGENT if m in head) >= 2

	bodies_ext = [i for i in items if i["authored"]
	              and i["repo"].split("/")[0] not in own]
	bodies_own = [i for i in items if i["authored"]
	              and i["repo"].split("/")[0] in own
	              and not is_agent(i["body"])]
	bodies_agent = [i for i in items if i["authored"] and is_agent(i["body"])]

	c_ext = [c for c in comments
	         if c["parent_url"].split("github.com/")[1].split("/")[0]
	         not in own]
	c_own = [c for c in comments
	         if c["parent_url"].split("github.com/")[1].split("/")[0] in own]

	def seg_texts(recs, field) -> list[str]:
		return [r[field] or "" for r in recs if (r[field] or "").strip()]

	def seg_stats(label: str, texts: list[str]) -> dict:
		f = [feats(t) for t in texts]
		lengths = [x["chars"] for x in f] or [0]
		return {
			"label": label,
			"count": len(texts),
			"length": quantiles(lengths),
			"words": quantiles([x["words"] for x in f] or [0]),
			"code_fence_pct": pct(sum(x["code_fence"] for x in f),
			                      len(f)),
			"inline_code_pct": pct(sum(x["inline_code"] for x in f),
			                       len(f)),
			"link_pct": pct(sum(x["link"] for x in f), len(f)),
			"bullets_pct": pct(sum(x["bullets"] for x in f), len(f)),
			"header_pct": pct(sum(x["header"] for x in f), len(f)),
			"bold_pct": pct(sum(x["bold"] for x in f), len(f)),
			"emoji_pct": pct(sum(x["emoji"] for x in f), len(f)),
			"mention_pct": pct(sum(x["mention"] for x in f), len(f)),
			"question_pct": pct(sum(x["question"] for x in f), len(f)),
			"openings": dict(Counter(opening_bucket(t)
			                         for t in texts).most_common()),
			"bigrams": ngrams(texts, 2, 20),
			"trigrams": ngrams(texts, 3, 15),
		}

	analysis = {
		"generated": datetime.now(tz=timezone.utc).isoformat(),
		"segments": {
			"bodies_external_issues_prs": seg_stats(
				"external bodies", seg_texts(bodies_ext, "body")),
			"bodies_own_handwritten": seg_stats(
				"own bodies (non-agent)", seg_texts(bodies_own, "body")),
			"bodies_own_agent_suspect": {
				"count": len(bodies_agent),
				"note": "flagged agent-generated; excluded from voice",
			},
			"comments_external": seg_stats(
				"comments in external repos", seg_texts(c_ext, "body")),
			"comments_own": seg_stats(
				"comments in own repos", seg_texts(c_own, "body")),
		},
		"edits": {
			"items_with_edits": len(edits),
			"edit_count_dist": quantiles(
				[e["edit_count"] for e in edits.values()]),
			"with_two_plus_versions": sum(
				1 for e in edits.values()
				if len(e.get("versions", [])) >= 2),
		},
		"reactions": {
			"comments_mean_reactions": round(statistics.mean(
				[c["reactions"] for c in comments]), 2),
			"top_reacted": sorted(
				comments, key=lambda c: -c["reactions"])[:15],
		},
		"temporal": {
			"first_item": min((i["created"] for i in items), default=""),
			"last_item": max((i["created"] for i in items), default=""),
			"items_per_year": dict(sorted(Counter(
				i["created"][:4] for i in items
				if i["authored"]).items())),
		},
	}
	(out / "analysis.json").write_text(json.dumps(
		analysis, ensure_ascii=False, indent=1, default=str))

	lines = [f"# Corpus analysis — {analysis['generated']}", ""]
	for key, seg in analysis["segments"].items():
		if "count" not in seg:
			lines += [f"## {key}: {seg['count']} ({seg['note']})", ""]
			continue
		lines += [
			f"## {key} — {seg['label']} (n={seg['count']})",
			(
				f"- length p10/p50/p90: "
				f"{seg['length'].get('p10')}/"
				f"{seg['length'].get('p50')}/"
				f"{seg['length'].get('p90')} chars"
			),
			(
				f"- code fence {seg['code_fence_pct']}% | "
				f"inline code {seg['inline_code_pct']}% | "
				f"links {seg['link_pct']}% | "
				f"bullets {seg['bullets_pct']}% | "
				f"headers {seg['header_pct']}% | "
				f"bold {seg['bold_pct']}% | "
				f"emoji {seg['emoji_pct']}% | "
				f"mentions {seg['mention_pct']}% | "
				f"question {seg['question_pct']}%"
			),
			f"- openings: {seg['openings']}",
			f"- top bigrams: {seg['bigrams']}",
			"",
		]
	(out / "ANALYSIS.md").write_text("\n".join(lines))
	print(f"[done] {out / 'analysis.json'} and ANALYSIS.md "
	      f"({len(items)} items, {len(comments)} comments, "
	      f"{len(edits)} edited)")


if __name__ == "__main__":
	main()
