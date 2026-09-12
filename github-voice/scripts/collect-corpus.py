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
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
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
				input=input_text,
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
				capture_output=True, text=True, input=body,
			)
			if proc.returncode == 0:
				data = json.loads(proc.stdout)
				if "errors" in data:
					msgs = "; ".join(e.get("message", "?") for e in data["errors"])
					if "rate limit" in msgs.lower() or "billing" in msgs.lower():
						time.sleep(60)
						continue
					raise RuntimeError(f"GraphQL errors: {msgs}")
				self.gl_calls += 1
				rl = data["data"].get("rateLimit") or {}
				remaining = rl.get("remaining")
				if remaining is not None and remaining < 200:
					reset = rl.get("resetAt", "")
					print(f"  GraphQL budget low ({remaining}); "
					      f"sleeping until {reset}", flush=True)
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
				capture_output=True, text=True,
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
		}

	def discover(self, year_start: int) -> None:
		now_year = datetime.now(tz=timezone.utc).year
		windows = []
		for y in range(year_start, now_year + 1):
			windows.append((f"{y}-01-01", f"{y + 1}-01-01"))
		queries = {
			"authored-issue": f"author:{self.user} is:issue",
			"authored-pr": f"author:{self.user} is:pr",
			"commented-other": f"commenter:{self.user} -author:{self.user}",
			"authored-commented": f"author:{self.user} "
			                      f"commenter:{self.user}",
		}
		for label, qbase in queries.items():
			print(f"[discover] {label}", flush=True)
			for start, end in windows:
				for raw in self.search_window(qbase, start, end):
					item = self.normalize(raw)
					item["bucket"] = label
					prev = self.items.get(item["url"])
					if prev is None:
						self.items[item["url"]] = item
					elif label == "authored-issue" or label == "authored-pr":
						prev["bucket"] = label
			print(f"  total unique items: {len(self.items)}", flush=True)

	# ---------- classification ----------

	def own_repo(self, repo: str) -> bool:
		return repo.split("/")[0] in self.own_owners

	@staticmethod
	def agent_suspect(body: str) -> bool:
		head = body[:800]
		return sum(1 for m in MARKERS_AGENT_BODY if m in head) >= 2

	# ---------- hydration ----------

	def paginate(self, path: str) -> list[dict]:
		out, page = [], 1
		while page <= 20:
			data = self.gh(f"{path}?per_page=100&page={page}")
			if not isinstance(data, list):
				return out if not out else out
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
			self.comments.append({
				"kind": "comment",
				"node_id": c["node_id"],
				"body": c.get("body") or "",
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
					"body": r["body"],
					"created": r.get("submitted_at") or r["created_at"],
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
					"body": c["body"],
					"created": c["created_at"],
					"reactions": (c.get("reactions") or {}).get(
						"total_count", 0),
					"parent": item,
				})

	def hydrate(self) -> None:
		by_url = self.items
		commented_other = [i for i in by_url.values()
		                   if i["bucket"] == "commented-other"]
		auth_comm = [i for i in by_url.values()
		             if i["bucket"] == "authored-commented"]
		auth_comm_external = [i for i in auth_comm if not self.own_repo(
			i["repo"])]
		auth_comm_own = sorted(
			[i for i in auth_comm if self.own_repo(i["repo"])],
			key=lambda i: i["updated"], reverse=True,
		)[: self.own_followup_sample]
		authored_prs = [i for i in by_url.values()
		                if i["bucket"] == "authored-pr"]

		targets = (commented_other + auth_comm_external + auth_comm_own
		           + authored_prs)
		seen: set[str] = set()
		plan = [i for i in targets
		        if not (i["url"] in seen or seen.add(i["url"]))]
		print(f"[hydrate] {len(plan)} items "
		      f"(ext-thread {len(commented_other)}, "
		      f"ext-followup {len(auth_comm_external)}, "
		      f"own-followup {len(auth_comm_own)}, "
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
		authored = [i for i in self.items.values()
		            if i["bucket"].startswith("authored")]
		ext_bodies = [i["node_id"] for i in authored
		              if not self.own_repo(i["repo"])]
		own_bodies = sorted(
			[i for i in authored if self.own_repo(i["repo"])],
			key=lambda i: i["updated"], reverse=True,
		)[: self.own_edit_bodies]
		comment_ids = [c["node_id"] for c in self.comments
		               if c["kind"] in ("comment", "review")]
		check = ext_bodies + [i["node_id"] for i in own_bodies] \
			+ comment_ids
		print(f"[edits] checking {len(check)} ids "
		      f"({len(ext_bodies)} ext bodies, "
		      f"{len(own_bodies)} own bodies, "
		      f"{len(comment_ids)} comments)", flush=True)
		edited: list[str] = []
		for n in range(0, len(check), 50):
			ids = check[n: n + 50]
			data = self.graphql(GL_COST_QUERY, ids, 1)
			for node in data.get("nodes") or []:
				if not node:
					continue
				conn = node.get("userContentEdits")
				if conn and conn.get("totalCount", 0) > 0:
					edited.append(node["url"])
					self.edits[node["url"]] = {
						"edit_count": conn["totalCount"],
						"versions": [],
					}
			if n % 500 == 0:
				print(f"  checked {n + len(ids)}/{len(check)}, "
				      f"{len(edited)} edited", flush=True)
		self.save_json("edited-ids.json", edited)
		print(f"[edits] {len(edited)} items have edits; "
		      f"fetching diffs", flush=True)
		id_by_url = {i["url"]: i["node_id"] for i in authored}
		id_by_url.update({c["node_id"]: c["node_id"]
		                  for c in self.comments})
		url_ids = [id_by_url[u] for u in edited if u in id_by_url]
		# map node id back to url for storage
		url_by_id = {v: k for k, v in id_by_url.items()}
		for n in range(0, len(url_ids), 25):
			ids = url_ids[n: n + 25]
			data = self.graphql(GL_DIFF_QUERY, ids, 10)
			for node in data.get("nodes") or []:
				if not node:
					continue
				conn = node.get("userContentEdits")
				if not conn:
					continue
				url = url_by_id.get(node.get("url"), node.get("url"))
				if url not in self.edits:
					url = node["url"]
				self.edits[url]["versions"] = [
					{"editedAt": v.get("editedAt"),
					 "diff": v.get("diff")}
					for v in conn.get("nodes", [])
				]
				self.edits[url]["truncated"] = (
					conn.get("totalCount", 0) > 10)

	# ---------- rendering ----------

	def save_json(self, name: str, payload: object) -> None:
		path = self.out / "raw" / name
		path.write_text(json.dumps(payload, ensure_ascii=False,
		                           indent=1))

	def render(self) -> None:
		md = self.out / "markdown"
		for sub in ("bodies", "comments"):
			(md / sub).mkdir(parents=True, exist_ok=True)
		for i in self.items.values():
			if not i["bucket"].startswith("authored"):
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
				f"agent_suspect: "
				f"{str(self.agent_suspect(i['body'])).lower()}",
			]
			if edit:
				front.append(f"edits: {edit['edit_count']}")
			text = "---\n" + "\n".join(front) + "\n---\n\n"
			text += f"# {i['title']}\n\n{i['body']}\n"
			if edit and edit.get("versions"):
				text += "\n## Revisions\n\n"
				for v in edit["versions"]:
					text += (f"### edited {v.get('editedAt')}\n"
					         f"```diff\n{v.get('diff') or ''}\n"
					         f"```\n")
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
				f"url: {p['url']}#issuecomment-{c['node_id']}",
				f"created: {c['created']}",
				f"reactions: {c['reactions']}",
			]
			if c["kind"] == "review":
				front.append(f"review_state: {c['review_state']}")
			edit = self.edits.get(c["node_id"])
			if edit:
				front.append(f"edits: {edit['edit_count']}")
			text = "---\n" + "\n".join(front) + "\n---\n\n"
			text += (f"> On **{p['title']}** "
			         f"(by {p['author']}):\n"
			         f"> {(p['body'] or '')[:400].replace(chr(10), ' ')}"
			         f"\n\n---\n\n{c['body']}\n")
			if edit and edit.get("versions"):
				text += "\n## Revisions\n\n"
				for v in edit["versions"]:
					text += (f"### edited {v.get('editedAt')}\n"
					         f"```diff\n{v.get('diff') or ''}\n"
					         f"```\n")
			(md / "comments" / f"{slug}.md").write_text(text)

	def summary(self) -> dict:
		def n(pred) -> int:
			return sum(1 for x in self.items.values() if pred(x))

		stats = {
			"generated": datetime.now(tz=timezone.utc).isoformat(),
			"user": self.user,
			"items_total": len(self.items),
			"bodies_authored_issue": n(lambda i: i["bucket"]
			                           == "authored-issue"),
			"bodies_authored_pr": n(lambda i: i["bucket"]
			                        == "authored-pr"),
			"bodies_external": n(lambda i: i["bucket"].startswith(
				"authored") and not self.own_repo(i["repo"])),
			"agent_suspect_bodies": n(
				lambda i: i["bucket"].startswith("authored")
				and self.agent_suspect(i["body"])),
			"threads_commented_not_authored": n(
				lambda i: i["bucket"] == "commented-other"),
			"comments": len(self.comments),
			"comments_by_kind": {
				k: sum(1 for c in self.comments if c["kind"] == k)
				for k in ("comment", "review", "review-inline")
			},
			"comments_external_repo": sum(
				1 for c in self.comments
				if not self.own_repo(c["parent"]["repo"])),
			"items_with_edits": len(self.edits),
			"rest_calls": self.rest_calls,
			"graphql_calls": self.gl_calls,
			"top_repos_bodies": self.top(lambda i: i["bucket"].startswith(
				"authored")),
			"top_repos_comments": self.top(
				lambda i: any(c["parent"]["url"] == i["url"]
				              for c in []) or True),
		}
		return stats

	def top(self, _pred) -> dict:
		from collections import Counter
		c1 = Counter(i["repo"] for i in self.items.values()
		             if i["bucket"].startswith("authored"))
		return dict(c1.most_common(15))


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--user", default="LarsArtmann")
	ap.add_argument("--out", default="~/.cache/github-voice-corpus")
	ap.add_argument("--own-owners",
	                default="LarsArtmann,Artmann-Games")
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
	if not args.skip_discover:
		col.discover(args.year_start)
		col.save_json("items.json", list(col.items.values()))
		print(f"[done-discover] {len(col.items)} items "
		      f"({time.time() - t0:.0f}s)", flush=True)
	if not args.skip_hydrate:
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
	(out / "summary.json").write_text(json.dumps(
		stats, ensure_ascii=False, indent=1))
	print(json.dumps(stats, ensure_ascii=False, indent=1))
	print(f"[done] corpus at {out} ({time.time() - t0:.0f}s)",
	      flush=True)


if __name__ == "__main__":
	try:
		main()
	except KeyboardInterrupt:
		sys.exit(130)
