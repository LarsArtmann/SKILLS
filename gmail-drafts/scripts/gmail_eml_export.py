#!/usr/bin/env python3
"""Export raw .eml files from Gmail via InboxClean's stored OAuth grants.

Read-only: lists messages matching queries and writes their full RFC822 raw
form (format=raw, complete headers incl. DKIM/ARC chains) as .eml files.
Must run as the `inboxclean` system user (token files are mode 600 under
/var/lib/inboxclean). Agent shells hand the one-liner to the user:

    sudo -u inboxclean /run/current-system/sw/bin/python3 \
        gmail_eml_export.py --account work --outdir /tmp/glovo-eml

Custom queries (repeatable; default: the case-glovo 2026-10-04 day-0 set):

    ... --query 'from:example.com after:2026/10/04' --query 'in:sent ...'

Token files are read-only for this script: the refreshed access token lives
in memory only, never written back, never printed.
"""

import argparse
import base64
import email.utils
import hashlib
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from email import policy
from email.header import decode_header
from email.parser import BytesParser

STATE_DIR = "/var/lib/inboxclean"
ACCOUNT_FILES = {
    "main": ("credentials.json", "token.json"),
    "work": ("credentials-work.json", "token-work.json"),
}
API_BASE = "https://gmail.googleapis.com/gmail/v1"

DEFAULT_QUERIES = [
    "in:sent after:2026/10/04 before:2026/10/05",
    "from:bok@biedronka.pl after:2026/10/04",
    "from:mailer-daemon after:2026/10/04 before:2026/10/06",
    "from:glovoapp.com after:2026/10/04",
]


def post(url, data):
    req = urllib.request.Request(url, data=json.dumps(data).encode(), method="POST")
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read())


def get_access_token(account):
    creds_file, token_file = ACCOUNT_FILES[account]
    with open(f"{STATE_DIR}/{creds_file}") as fh:
        creds = json.load(fh)
    with open(f"{STATE_DIR}/{token_file}") as fh:
        token = json.load(fh)
    if not token.get("refresh_token"):
        sys.exit(f"ERROR: {token_file} has no refresh_token (re-auth runbook)")
    inst = creds.get("installed", creds.get("web", {}))
    resp = post(
        "https://oauth2.googleapis.com/token",
        {
            "client_id": inst["client_id"],
            "client_secret": inst["client_secret"],
            "refresh_token": token["refresh_token"],
            "grant_type": "refresh_token",
        },
    )
    return resp["access_token"]


def api(token, path, method="GET", data=None):
    req = urllib.request.Request(f"{API_BASE}{path}", method=method)
    req.add_header("Authorization", f"Bearer {token}")
    body = None
    if data is not None:
        body = json.dumps(data).encode()
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, body, timeout=60) as resp:
        payload = resp.read()
    if not payload:
        return {}
    return json.loads(payload)


def parse_raw(raw_b64):
    return BytesParser(policy=policy.default).parsebytes(
        base64.urlsafe_b64decode(raw_b64 + "===")
    )


def header_str(msg, name):
    parts = []
    for text, _enc in decode_header(str(msg.get(name) or "")):
        parts.append(text if isinstance(text, str) else text.decode("utf-8", "replace"))
    return "".join(parts)


def safe_name(text, maxlen=70):
    text = re.sub(r"[^A-Za-z0-9._-]+", "_", text).strip("_")
    return text[:maxlen].rstrip("_") or "unnamed"


def main():
    parser = argparse.ArgumentParser(description="Export Gmail messages as raw .eml")
    parser.add_argument("--account", choices=sorted(ACCOUNT_FILES), required=True)
    parser.add_argument("--outdir", default="/tmp/gmail-eml-export")
    parser.add_argument(
        "--query",
        action="append",
        metavar="Q",
        help="Gmail search query (repeatable; default: case-glovo day-0 set)",
    )
    parser.add_argument("--limit", type=int, default=25, help="max messages per query")
    args = parser.parse_args()
    queries = args.query or DEFAULT_QUERIES

    token = get_access_token(args.account)
    mailbox = api(token, "/users/me/profile").get("emailAddress", "?")
    print(f"account mailbox: {mailbox}")

    os.makedirs(args.outdir, exist_ok=True)
    os.chmod(args.outdir, 0o755)
    seen = {}

    for query in queries:
        listing = api(
            token,
            f"/users/me/messages?maxResults={args.limit}&q={urllib.parse.quote(query)}",
        )
        ids = [m["id"] for m in listing.get("messages", [])]
        print(f"\nquery: {query!r} -> {len(ids)} message(s)")
        if listing.get("nextPageToken"):
            print("  NOTE: more results exist than fetched (pagination truncated)")
        for mid in ids:
            if mid in seen:
                print(f"  (dup) {mid}")
                continue
            raw_b64 = api(token, f"/users/me/messages/{mid}?format=raw")["raw"]
            eml_bytes = base64.urlsafe_b64decode(raw_b64 + "===")
            msg = parse_raw(raw_b64)
            date_hdr = msg.get("Date", "")
            try:
                dt = email.utils.parsedate_to_datetime(date_hdr)
            except (TypeError, ValueError):
                dt = datetime.now(timezone.utc)
            stamp = dt.strftime("%Y-%m-%d_%H%M")
            subject = header_str(msg, "Subject") or "(no subject)"
            fname = f"{stamp}_{safe_name(subject)}.eml"
            path = os.path.join(args.outdir, fname)
            with open(path, "wb") as fh:
                fh.write(eml_bytes)
            os.chmod(path, 0o644)
            seen[mid] = fname
            print(f"  {mid}  {date_hdr}")
            print(f"    from: {header_str(msg, 'From')}")
            print(f"    to:   {header_str(msg, 'To')}")
            print(f"    msg-id: {msg.get('Message-ID', '?')}")
            print(f"    -> {fname}  sha256={hashlib.sha256(eml_bytes).hexdigest()}")

    print(f"\nwrote {len(seen)} file(s) to {args.outdir} (mode 644, world-readable)")


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as err:
        detail = err.read().decode("utf-8", "replace")[:300]
        sys.exit(f"ERROR: Gmail API {err.code} {err.reason}: {detail}")
