#!/usr/bin/env python3
"""Collect LarsArtmann's GitHub issues, PRs, comments, and edit history.

Builds a markdown corpus of every issue/PR body authored by the user and
every comment/review the user wrote (own repos + external repos), plus the
GitHub edit history (revision diffs) where available. Output feeds the
voice/tone analysis documented in ../SKILL.md.

Usage:
    collect-corpus.py [--user LarsArtmann] [--out ~/.cache/github-voice-corpus]

Requires: gh CLI, authenticated.

API strategy (empirically verified 2026-09-12):
- Discovery: REST search/issues (windowed by created date — search caps at
  1000 results per query; the user has 9000+ items).
- Comment hydration: REST per item (GraphQL connections cost node points
  and blow the 5000/hr budget; REST is 1 point per call).
- Edit history: GraphQL nodes(ids:) with userContentEdits — the REST
  .../versions endpoints 404. Edit check is cheap (first:1 + totalCount);
  diffs are fetched only for items that were actually edited.

Resume: --skip-discover / --skip-hydrate reload raw/items.json and
raw/comments.json from a previous run.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

MARKERS_AGENT_BODY = [
	"Task ID:",
	"Impact Score",
	"**Phase:**",
	"ISSUE TYPE",
	"Priority: 🔥",
	"TECHNICAL DEBT:",
	"## 🚨",
	"### 🎯",
	"- **Effort",
	"**Effort:**",
]

GL_COST_QUERY = """
query($ids: [ID!]!, $ef: Int!) {
	rateLimit { cost remaining resetAt }
	nodes(ids: $ids) {
		__typename
		... on Issue {
			url
			userContentEdits(first: $ef) { totalCount }
		}
		... on PullRequest {
			url
			userContentEdits(first: $ef) { totalCount }
		}
		... on IssueComment {
			url
			userContentEdits(first: $ef) { totalCount }
		}
	}
}
"""

GL_DIFF_QUERY = """
query($ids: [ID!]!, $ef: Int!) {
	rateLimit { cost remaining resetAt }
	nodes(ids: $ids) {
		__typename
		... on Issue {
			url
			userContentEdits(first: $ef) {
				totalCount
				nodes { editedAt diff }
			}
		}
		... on PullRequest {
			url
			userContentEdits(first: $ef) {
				totalCount
				nodes { editedAt diff }
			}
		}
		... on IssueComment {
			url
			userContentEdits(first: $ef) {
				totalCount
				nodes { editedAt diff }
			}
		}
	}
}
"""


class Collector:
	def __init__(self, user: str, out: Path, own_owners: set[str],
	             own_followup_sample: int, own_edit_bodies: int):
		self.user = user
		self.out = out
		self.own_owners = own_owners
		self.own_followup_sample = own_followup_sample
		self.own_edit_bodies = own_edit_bodies
		self.items: dict[str, dict] = {}
		self.comments: list[dict] = []
		self.edits: dict[str, dict] = {}
		self.rest_calls = 0
		self.gl_calls = 0

	# ---------- transport ----------

	def gh(self, *args: str, input_text: str | None = None) -> object:
		for attempt in range(6):
			proc = subprocess.run(
				["gh", "api", *args], capture_output=True, text=True,
				input=input_text, check=False,
			)
			if proc.returncode == 0:
				self.rest_calls += 1
				return json.loads(proc.stdout) if proc.stdout.strip() else None
			err = proc.stderr.lower()
			if "rate limit" in err:
				wait = 60
				m = re.search(r"retry after (\d+)", err)
				if m:
					wait = min(int(m.group(1)) + 2, 300)
				print(f"  rate limited; sleeping {wait}s", flush=True)
				time.sleep(wait)
				continue
			if attempt < 5 and ("502" in err or "504" in err
			                    or "server error" in err
			                    or "timed out" in err):
				time.sleep(5 * (attempt + 1))
				continue
			raise RuntimeError(f"gh api {' '.join(args)} failed:\n{proc.stderr}")
		raise RuntimeError(f"gh api {' '.join(args)}: retries exhausted")

	def graphql(self, query: str, ids: list[str], ef: int) -> dict:
		body = json.dumps({
			"query": query, "variables": {"ids": ids, "ef": ef},
		})
		for attempt in range(10):
			proc = subprocess.run(
				["gh", "api", "graphql", "--input", "-"],
				capture_output=True, text=True, input=body, check=False,
			)
			if proc.returncode == 0:
				data = json.loads(proc.stdout)
				if "errors" in data:
					msgs = "; ".join(e.get("message", "?")
					                 for e in data["errors"])
					if "rate limit" in msgs.lower():
						time.sleep(60)
						continue
					raise RuntimeError(f"GraphQL errors: {msgs}")
				self.gl_calls += 1
				rl = data["data"].get("rateLimit") or {}
				remaining = rl.get("remaining")
				if remaining is not None and remaining < 300:
					print(f"  GraphQL budget low ({remaining}); "
					      f"sleeping 90s (resets {rl.get('resetAt')})",
					      flush=True)
					time.sleep(90)
				return data["data"]
			if "rate limit" in proc.stderr.lower():
				time.sleep(60)
				continue
			if attempt < 9:
				time.sleep(5 * (attempt + 1))
				continue
			raise RuntimeError(f"graphql failed: {proc.stderr}")
		raise RuntimeError("graphql: retries exhausted")

	def rest_check_budget(self) -> None:
		if self.rest_calls % 100 != 0:
			return
		try:
			proc = subprocess.run(
				["gh", "api", "rate_limit/resource/core",
				 "--jq", ".resources.core.remaining"],
				capture_output=True, text=True, check=False,
			)
			if proc.returncode == 0 and proc.stdout.strip():
				remaining = int(proc.stdout.strip())
				if remaining < 300:
					print(f"  REST budget low ({remaining}); "
					      f"sleeping 120s", flush=True)
					time.sleep(120)
		except (ValueError, OSError):
			pass

	# ---------- discovery ----------

	def search_window(self, qbase: str, start: str, end: str) -> list[dict]:
		q = f"{qbase} created:{start}..{end}"
		probe = self.gh("-X", "GET", "search/issues", "-f", f"q={q}",
		                "-f", "per_page=1")
		total = probe["total_count"]
		if total == 0:
			return []
		if total > 1000:
			sdate = datetime.strptime(start, "%Y-%m-%d").replace(
				tzinfo=timezone.utc)
			edate = datetime.strptime(end, "%Y-%m-%d").replace(
				tzinfo=timezone.utc)
			if (edate - sdate).days >= 2:
				mid = sdate + (edate - sdate) / 2
				mids = mid.strftime("%Y-%m-%d")
				print(f"  split {start}..{end} ({total} hits) "
				      f"at {mids}", flush=True)
				return (self.search_window(qbase, start, mids)
				        + self.search_window(qbase, mids, end))
			print(f"  WARNING: {total} hits in tiny window "
			      f"{start}..{end}; taking first 1000", flush=True)
		time.sleep(2.1)
		found, page = [], 1
		while page <= 10:
			data = self.gh("-X", "GET", "search/issues",
			               "-f", f"q={q}", "-f", "per_page=100",
			               "-f", f"page={page}")
			if not isinstance(data, dict):
				break
			batch = data.get("items", [])
			found.extend(batch)
			if len(batch) < 100:
				break
			page += 1
			time.sleep(2.1)
		return found

	@staticmethod
	def normalize(raw: dict) -> dict:
		repo = raw["repository_url"].replace(
			"https://api.github.com/repos/", "")
		return {
			"node_id": raw["node_id"],
			"url": raw["html_url"],
			"repo": repo,
			"number": raw["number"],
			"title": raw["title"],
			"body": raw.get("body") or "",
			"created": raw["created_at"],
			"updated": raw["updated_at"],
			"state": raw["state"],
			"is_pr": "pull_request" in raw,
			"author": (raw.get("user") or {}).get("login", "?"),
			"reactions": (raw.get("reactions") or {}).get("total_count", 0),
			"comments_total": raw.get("comments", 0),
			"authored": False,
			"commented": False,
		}

	def merge(self, raw: dict, authored: bool, commented: bool) -> None:
		item = self.normalize(raw)
		prev = self.items.get(item["url"])
		if prev is None:
			item["authored"] = authored
			item["commented"] = commented
			self.items[item["url"]] = item
		else:
			prev["authored"] = prev["authored"] or authored
			prev["commented"] = prev["commented"] or commented

	def discover(self, year_start: int) -> None:
		now_year = datetime.now(tz=timezone.utc).year
		windows = [(f"{y}-01-01", f"{y + 1}-01-01")
		           for y in range(year_start, now_year + 1)]
		queries = [
			(f"author:{self.user} is:issue", True, False),
			(f"author:{self.user} is:pr", True, False),
			(f"commenter:{self.user} -author:{self.user}", False, True),
			(f"author:{self.user} commenter:{self.user}", True, True),
		]
		for label_i, (qbase, authored, commented) in enumerate(queries):
			print(f"[discover] {qbase}", flush=True)
			for start, end in windows:
				for raw in self.search_window(qbase, start, end):
					self.merge(raw, authored, commented)
			print(f"  total unique items: {len(self.items)}", flush=True)

	# ---------- classification ----------

	def own_repo(self, repo: str) -> bool:
		return repo.split("/")[0] in self.own_owners

	@staticmethod
	def agent_suspect(body: str) -> bool:
		head = body[:800]
		return sum(1 for m in MARKERS_AGENT_BODY if m in head) >= 2

	# ---------- hydration ----------

	def paginate(self, path: str) -> list:
		out, page = [], 1
		while page <= 20:
			data = self.gh(f"{path}?per_page=100&page={page}")
			if not isinstance(data, list):
				break
			out.extend(data)
			if len(data) < 100:
				break
			page += 1
			self.rest_check_budget()
		return out

	def hydrate_item(self, item: dict) -> None:
		repo, num = item["repo"], item["number"]
		for c in self.paginate(f"repos/{repo}/issues/{num}/comments"):
			if (c.get("user") or {}).get("login") != self.user:
				continue
			if not (c.get("body") or "").strip():
				continue
			self.comments.append({
				"kind": "comment",
				"node_id": c["node_id"],
				"html_url": c["html_url"],
				"body": c["body"],
				"created": c["created_at"],
				"reactions": (c.get("reactions") or {}).get(
					"total_count", 0),
				"parent": item,
			})
		if item["is_pr"]:
			for r in self.paginate(f"repos/{repo}/pulls/{num}/reviews"):
				if (r.get("user") or {}).get("login") != self.user:
					continue
				if not (r.get("body") or "").strip():
					continue
				self.comments.append({
					"kind": "review",
					"node_id": r["node_id"],
					"html_url": r["html_url"],
					"body": r["body"],
					"created": r.get("submitted_at")
					or r["created_at"],
					"reactions": 0,
					"review_state": r.get("state", ""),
					"parent": item,
				})
			for c in self.paginate(f"repos/{repo}/pulls/{num}/comments"):
				if (c.get("user") or {}).get("login") != self.user:
					continue
				if not (c.get("body") or "").strip():
					continue
				self.comments.append({
					"kind": "review-inline",
					"node_id": c["node_id"],
					"html_url": c["html_url"],
					"body": c["body"],
					"created": c["created_at"],
					"reactions": (c.get("reactions") or {}).get(
						"total_count", 0),
					"parent": item,
				})

	def hydrate(self) -> None:
		commented_other = [i for i in self.items.values()
		                   if i["commented"] and not i["authored"]]
		auth_comm = [i for i in self.items.values()
		             if i["commented"] and i["authored"]]
		ext_followup = [i for i in auth_comm
		                if not self.own_repo(i["repo"])]
		own_followup = sorted(
			[i for i in auth_comm if self.own_repo(i["repo"])],
			key=lambda i: i["updated"], reverse=True,
		)[: self.own_followup_sample]
		authored_prs = [i for i in self.items.values()
		                if i["authored"] and i["is_pr"]
		                and not (i["commented"]
		                         or i["repo"] in {
		                             x["repo"] for x in own_followup})]

		seen: set[str] = set()
		plan = [i for i in (commented_other + ext_followup + own_followup
		                    + authored_prs)
		        if not (i["url"] in seen or seen.add(i["url"]))]
		print(f"[hydrate] {len(plan)} items "
		      f"(threads-by-others {len(commented_other)}, "
		      f"ext-followup {len(ext_followup)}, "
		      f"own-followup {len(own_followup)}, "
		      f"authored-pr {len(authored_prs)})", flush=True)
		for n, item in enumerate(plan, 1):
			if n % 100 == 0:
				print(f"  {n}/{len(plan)} ({len(self.comments)} "
				      f"comments so far)", flush=True)
			try:
				self.hydrate_item(item)
			except RuntimeError as exc:
				print(f"  SKIP {item['url']}: {str(exc)[:120]}",
				      flush=True)
			self.rest_check_budget()

	# ---------- edits ----------

	def fetch_edits(self) -> None:
		authored = [i for i in self.items.values() if i["authored"]]
		ext_bodies = [i for i in authored
		              if not self.own_repo(i["repo"])]
		own_bodies = sorted(
			[i for i in authored if self.own_repo(i["repo"])],
			key=lambda i: i["updated"], reverse=True,
		)[: self.own_edit_bodies]
		bodies = ext_bodies + own_bodies
		comments = [c for c in self.comments
		            if c["kind"] in ("comment", "review")]
		node2url = {i["node_id"]: i["url"] for i in bodies}
		node2url.update({c["node_id"]: c["html_url"]
		                 for c in comments})
		check_ids = list(node2url)
		print(f"[edits] checking {len(check_ids)} nodes "
		      f"({len(bodies)} bodies, {len(comments)} comments)",
		      flush=True)
		edited_ids: list[str] = []
		for n in range(0, len(check_ids), 50):
			ids = check_ids[n: n + 50]
			data = self.graphql(GL_COST_QUERY, ids, 1)
			for node in data.get("nodes") or []:
				if not node:
					continue
				conn = node.get("userContentEdits")
				if conn and conn.get("totalCount", 0) > 0:
					edited_ids.append(node["url"])
					self.edits[node["url"]] = {
						"edit_count": conn["totalCount"],
						"versions": [],
					}
			if n and n % 500 == 0:
				print(f"  checked {n}/{len(check_ids)}, "
				      f"{len(edited_ids)} edited", flush=True)
		print(f"[edits] {len(edited_ids)} items have edits; "
		      f"fetching diffs", flush=True)
		url2node = {v: k for k, v in node2url.items()}
		for n in range(0, len(edited_ids), 25):
			batch_urls = edited_ids[n: n + 25]
			ids = [url2node[u] for u in batch_urls if u in url2node]
			if not ids:
				continue
			data = self.graphql(GL_DIFF_QUERY, ids, 10)
			for node in data.get("nodes") or []:
				if not node:
					continue
				conn = node.get("userContentEdits")
				if not conn or node["url"] not in self.edits:
					continue
				self.edits[node["url"]]["versions"] = sorted(
					({"editedAt": v.get("editedAt"),
					  "diff": v.get("diff")}
					 for v in conn.get("nodes", [])),
					key=lambda v: v["editedAt"] or "",
				)
				self.edits[node["url"]]["truncated"] = (
					conn.get("totalCount", 0) > 10)

	# ---------- persistence ----------

	def save_json(self, name: str, payload: object) -> None:
		path = self.out / "raw" / name
		path.write_text(json.dumps(payload, ensure_ascii=False, indent=1))

	def load_items(self) -> None:
		data = json.loads((self.out / "raw" / "items.json").read_text())
		self.items = {i["url"]: i for i in data}

	def load_comments(self) -> None:
		self.comments = []
		data = json.loads(
			(self.out / "raw" / "comments.json").read_text())
		for c in data:
			parent = self.items.get(c["parent_url"])
			if parent:
				self.comments.append(
					{k: v for k, v in c.items()
					 if k != "parent_url"} | {"parent": parent})

	def render(self) -> None:
		md = self.out / "markdown"
		for sub in ("bodies", "comments"):
			(md / sub).mkdir(parents=True, exist_ok=True)
		for i in self.items.values():
			if not i["authored"]:
				continue
			slug = i["repo"].replace("/", "--") + f"--{i['number']}"
			edit = self.edits.get(i["url"])
			front = [
				f"kind: {'body-pr' if i['is_pr'] else 'body-issue'}",
				f"repo: {i['repo']}",
				f"own_repo: {str(self.own_repo(i['repo'])).lower()}",
				f"url: {i['url']}",
				f"title: {json.dumps(i['title'])}",
				f"created: {i['created']}",
				f"reactions: {i['reactions']}",
				f"agent_suspect: {str(self.agent_suspect(i['body'])).lower()}",			]
			if edit:
				front.append(f"edits: {edit['edit_count']}")
			text = "---\n" + "\n".join(front) + "\n---\n\n"
			text += f"# {i['title']}\n\n{i['body']}\n"
			if edit and edit.get("versions"):
				text += "\n## Revisions\n\n"
				for v in edit["versions"]:
					text += (f"### edited {v.get('editedAt')}\n"
					         f"```diff\n{v.get('diff') or ''}\n```\n")
			(md / "bodies" / f"{slug}.md").write_text(text)
		for c in self.comments:
			p = c["parent"]
			slug = (p["repo"].replace("/", "--")
			        + f"--{p['number']}--{c['node_id'][-10:]}")
			front = [
				f"kind: {c['kind']}",
				f"repo: {p['repo']}",
				f"own_repo: {str(self.own_repo(p['repo'])).lower()}",
				f"item: {p['number']}",
				f"item_title: {json.dumps(p['title'])}",
				f"item_author: {p['author']}",
				f"url: {c['html_url']}",
				f"created: {c['created']}",
				f"reactions: {c['reactions']}",
			]
			if c["kind"] == "review":
				front.append(f"review_state: {c['review_state']}")
			edit = self.edits.get(c["html_url"])
			if edit:
				front.append(f"edits: {edit['edit_count']}")
			context = (p["body"] or "")[:400].replace("\n", " ")
			text = "---\n" + "\n".join(front) + "\n---\n\n"
			text += (f"> On **{p['title']}** (by {p['author']}):\n"
			         f"> {context}\n\n---\n\n{c['body']}\n")
			if edit and edit.get("versions"):
				text += "\n## Revisions\n\n"
				for v in edit["versions"]:
					text += (f"### edited {v.get('editedAt')}\n"
					         f"```diff\n{v.get('diff') or ''}\n```\n")
			(md / "comments" / f"{slug}.md").write_text(text)

	def summary(self) -> dict:
		authored = [i for i in self.items.values() if i["authored"]]
		stats = {
			"generated": datetime.now(tz=timezone.utc).isoformat(),
			"user": self.user,
			"items_total": len(self.items),
			"bodies_authored": len(authored),
			"bodies_authored_issue": sum(
				1 for i in authored if not i["is_pr"]),
			"bodies_authored_pr": sum(
				1 for i in authored if i["is_pr"]),
			"bodies_external": sum(1 for i in authored
			                       if not self.own_repo(i["repo"])),
			"agent_suspect_bodies": sum(
				1 for i in authored if self.agent_suspect(i["body"])),
			"threads_commented_not_authored": sum(
				1 for i in self.items.values()
				if i["commented"] and not i["authored"]),
			"comments": len(self.comments),
			"comments_by_kind": dict(Counter(
				c["kind"] for c in self.comments)),
			"comments_external_repo": sum(
				1 for c in self.comments
				if not self.own_repo(c["parent"]["repo"])),
			"items_with_edits": len(self.edits),
			"rest_calls": self.rest_calls,
			"graphql_calls": self.gl_calls,
			"top_repos_bodies": dict(Counter(
				i["repo"] for i in authored).most_common(15)),
			"top_repos_comments": dict(Counter(
				c["parent"]["repo"] for c in self.comments
			).most_common(15)),
		}
		return stats


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--user", default="LarsArtmann")
	ap.add_argument("--out", default="~/.cache/github-voice-corpus")
	ap.add_argument("--own-owners", default="LarsArtmann,Artmann-Games")
	ap.add_argument("--year-start", type=int, default=2016)
	ap.add_argument("--own-followup-sample", type=int, default=1500)
	ap.add_argument("--own-edit-bodies", type=int, default=800)
	ap.add_argument("--skip-discover", action="store_true")
	ap.add_argument("--skip-hydrate", action="store_true")
	args = ap.parse_args()

	out = Path(args.out).expanduser()
	(out / "raw").mkdir(parents=True, exist_ok=True)
	col = Collector(args.user, out,
	                {o.strip() for o in args.own_owners.split(",")},
	                args.own_followup_sample, args.own_edit_bodies)

	t0 = time.time()
	if args.skip_discover:
		col.load_items()
		print(f"[resume] loaded {len(col.items)} items", flush=True)
	else:
		col.discover(args.year_start)
		col.save_json("items.json", list(col.items.values()))
		print(f"[done-discover] {len(col.items)} items "
		      f"({time.time() - t0:.0f}s)", flush=True)
	if args.skip_hydrate:
		col.load_comments()
		print(f"[resume] loaded {len(col.comments)} comments",
		      flush=True)
	else:
		col.hydrate()
		col.save_json("comments.json", [
			{k: v for k, v in c.items() if k != "parent"}
			| {"parent_url": c["parent"]["url"]}
			for c in col.comments
		])
		print(f"[done-hydrate] {len(col.comments)} comments "
		      f"({time.time() - t0:.0f}s)", flush=True)
	col.fetch_edits()
	col.save_json("edits.json", col.edits)
	col.render()
	stats = col.summary()
	(out / "summary.json").write_text(
		json.dumps(stats, ensure_ascii=False, indent=1))
	print(json.dumps(stats, ensure_ascii=False, indent=1))
	print(f"[done] corpus at {out} ({time.time() - t0:.0f}s)", flush=True)


if __name__ == "__main__":
	try:
		main()
	except KeyboardInterrupt:
		sys.exit(130)
