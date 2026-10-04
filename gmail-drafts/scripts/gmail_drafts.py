#!/usr/bin/env python3
"""Create server-side Gmail drafts via InboxClean's stored OAuth grants.

Never sends mail. Must run as the `inboxclean` system user (the OAuth token
files are mode 600 under /var/lib/inboxclean); agent shells hand the one-liner
to the user:

    sudo -u inboxclean /run/current-system/sw/bin/python3 gmail_drafts.py \
        --account work --spec /tmp/spec.json

Spec JSON: array of {"to", "cc"?, "bcc"?, "subject", "body"} objects.
Creation is idempotent per subject (an existing draft with the same subject
is skipped), headers are RFC 2047-encoded (raw UTF-8 header bytes are read
as Latin-1 by Gmail -> mojibake), and the token files are read-only: the
refreshed access token lives in memory only, never written back.
"""
import argparse
import base64
import json
import sys
import urllib.error
import urllib.request
from email import policy
from email.header import decode_header
from email.message import EmailMessage
from email.parser import BytesParser

STATE_DIR = "/var/lib/inboxclean"
ACCOUNT_FILES = {
    "main": ("credentials.json", "token.json"),
    "work": ("credentials-work.json", "token-work.json"),
}
API_BASE = "https://gmail.googleapis.com/gmail/v1"


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
    resp = post("https://oauth2.googleapis.com/token", {
        "client_id": inst["client_id"],
        "client_secret": inst["client_secret"],
        "refresh_token": token["refresh_token"],
        "grant_type": "refresh_token",
    })
    return resp["access_token"]


def api(token, path, method="GET", data=None):
    req = urllib.request.Request(f"{API_BASE}{path}", method=method)
    req.add_header("Authorization", f"Bearer {token}")
    body = None
    if data is not None:
        body = json.dumps(data).encode()
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, body, timeout=30) as resp:
        payload = resp.read()
    if not payload:
        return {}  # 204 No Content (drafts.delete) has an empty body
    return json.loads(payload)


def parse_raw(raw_b64):
    msg = BytesParser(policy=policy.default).parsebytes(
        base64.urlsafe_b64decode(raw_b64 + "==="))
    return msg


def subject_of(msg):
    parts = []
    for text, _enc in decode_header(str(msg["Subject"] or "")):
        parts.append(text if isinstance(text, str) else text.decode("utf-8", "replace"))
    return "".join(parts)


def draft_subjects(token):
    drafts = api(token, "/users/me/drafts?maxResults=100").get("drafts", [])
    subjects = {}
    for draft in drafts:
        msg = parse_raw(api(
            token,
            f"/users/me/messages/{draft['message']['id']}?format=raw")["raw"])
        subjects[subject_of(msg)] = draft["id"]
    return subjects


def build_raw(to, cc, bcc, subject, body):
    msg = EmailMessage(policy=policy.SMTP)
    msg["To"] = to
    if cc:
        msg["Cc"] = ", ".join(cc)
    if bcc:
        msg["Bcc"] = ", ".join(bcc)
    msg["Subject"] = subject
    msg.set_content(body, charset="utf-8")
    return base64.urlsafe_b64encode(msg.as_bytes()).decode("ascii")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--account", choices=sorted(ACCOUNT_FILES), required=True)
    parser.add_argument("--spec", help="JSON file: array of {to,cc,bcc,subject,body}")
    parser.add_argument("--list", action="store_true", help="list drafts (id + subject)")
    parser.add_argument("--delete", nargs="+", metavar="DRAFT_ID",
                        help="delete drafts by id")
    args = parser.parse_args()
    if not (args.spec or args.list or args.delete):
        parser.error("one of --spec / --list / --delete is required")

    token = get_access_token(args.account)
    mailbox = api(token, "/users/me/profile").get("emailAddress", "?")
    print(f"account mailbox: {mailbox}")

    if args.list:
        for subject, draft_id in sorted(draft_subjects(token).items(),
                                        key=lambda kv: kv[1]):
            print(f"  {draft_id}  {subject!r}")
        return

    for draft_id in args.delete or []:
        api(token, f"/users/me/drafts/{draft_id}", "DELETE")
        print(f"deleted {draft_id}")

    if not args.spec:
        return

    with open(args.spec) as fh:
        letters = json.load(fh)
    existing = draft_subjects(token)
    print(f"existing drafts: {len(existing)}")

    for letter in letters:
        subject = letter["subject"]
        if not letter.get("to") or not subject:
            sys.exit(f"ERROR: spec entry missing to/subject: {letter!r:.120}")
        if subject in existing:
            print(f"SKIP (subject exists as draft {existing[subject]}): {subject!r}")
            continue
        raw = build_raw(letter["to"], letter.get("cc", []), letter.get("bcc", []),
                        subject, letter["body"])
        draft_id = api(token, "/users/me/drafts", "POST",
                       {"message": {"raw": raw}})["id"]
        draft = api(token, f"/users/me/drafts/{draft_id}")
        raw = api(token, f"/users/me/messages/{draft['message']['id']}?format=raw")
        rendered = subject_of(parse_raw(raw["raw"]))
        mojibake = "Ã" in rendered or "Ä" in rendered
        print(f"{'[MOJIBAKE!]' if mojibake else '[OK]'} {draft_id} "
              f"-> {letter['to']} :: {rendered!r}")


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as err:
        detail = err.read().decode("utf-8", "replace")[:300]
        sys.exit(f"ERROR: Gmail API {err.code} {err.reason}: {detail}")
