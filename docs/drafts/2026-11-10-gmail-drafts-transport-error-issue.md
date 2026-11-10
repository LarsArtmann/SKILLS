## Problem

`get_access_token()` (scripts/gmail_drafts.sh:177-190) refreshes via `http` (curl) and then parses the response:

```
resp=$(http POST https://oauth2.googleapis.com/token ...)
TOKEN=$(jq -r '.access_token // empty' <<<"$resp")
[[ -n $TOKEN ]] || die "token refresh returned no access_token"
```

When curl itself fails (DNS, no route), `$resp` comes back empty, curl's diagnostic goes to stderr, and the operator-facing `die` names only the missing JSON field. Lived sequence today, staging a pool-inquiry draft per this skill's own procedure:

```
curl: (6) Could not resolve host: oauth2.googleapis.com
ERROR: token refresh returned no access_token
```

Two runs failed on transport before anyone opened the code. Box state at failure time: `/etc/resolv.conf` rewritten 12:23 today, resolver answers AAAA, IPv6 route dead (`curl -6` rc=000), IPv4 fine (`curl -4` reaches the token host, 404 on HEAD / is the server answering). A network problem, not a script bug, but the script turned a one-glance diagnosis ("resolver is flaky") into a code read.

## Ask

Fail fast with the transport diagnostic: in `http()` (line ~149) or around the refresh call, check curl's exit code and `die` with its stderr line, e.g. `token refresh: curl (6) Could not resolve host: oauth2.googleapis.com`. Second ask, same site: when the error body carries `429` + `Retry-After`, say so and print the timestamp converted, since the correct behavior is wait-then-rerun-once, not retry-loop (hit earlier the same hour).

## Context

- Invocation per SKILL.md procedure: `sudo -u inboxclean /tmp/gmail_drafts.sh --account work --spec /tmp/gmail-drafts-spec-<case-slug>.json`
- Requirements header: curl, jq, base64, awk, iconv, sha256sum
- Both failure modes (429, then DNS) within one hour, same spec file

💘 Generated with Crush
