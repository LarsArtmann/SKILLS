#!/usr/bin/env bash
# gmail_eml_export.sh — export raw .eml files from Gmail via InboxClean's
# stored OAuth grants. Bash port of gmail_eml_export.py. Read-only: lists
# messages matching queries and writes their full RFC822 raw form (format=raw,
# complete headers incl. DKIM/ARC chains) as .eml files. Must run as the
# `inboxclean` system user; agent shells hand the one-liner to the user:
#
#   sudo -u inboxclean gmail_eml_export.sh --account work --outdir /tmp/glovo-eml
#
# Custom queries (repeatable; default: the case-glovo 2026-10-04 day-0 set):
#
#   ... --query 'from:example.com after:2026/10/04' --query 'in:sent ...'
#
# Token files are read-only for this script: the refreshed access token lives
# in a shell variable only, never written back, never printed.
#
# Test override: GMAIL_STATE_DIR (default /var/lib/inboxclean).
# Requires: curl, jq, base64, awk (gawk), iconv, sha256sum, GNU date.
# Self-test (no network): gmail_eml_export.sh --self-test
set -euo pipefail

STATE_DIR=${GMAIL_STATE_DIR:-/var/lib/inboxclean}
API_BASE=https://gmail.googleapis.com/gmail/v1
DEFAULT_QUERIES=(
	"in:sent after:2026/10/04 before:2026/10/05"
	"from:bok@biedronka.pl after:2026/10/04"
	"from:mailer-daemon after:2026/10/04 before:2026/10/06"
	"from:glovoapp.com after:2026/10/04"
)

usage() {
	echo "usage: gmail_eml_export.sh --account main|work [--outdir <dir>] [--query <q>]... [--limit <n>]" >&2
	echo "       gmail_eml_export.sh --self-test" >&2
	exit 2
}

die() {
	echo "ERROR: $*" >&2
	exit 1
}

# ---------- helpers (shared contract with gmail_drafts.sh) ----------

b64url_decode() {
	local s pad
	s=$(sed 's#-#+#g; s#_#/#g' <<<"$1")
	pad=$(((4 - ${#s} % 4) % 4))
	printf '%s%.*s' "$s" "$pad" | base64 -d
}

q_decode() {
	local s=$1 out="" c i=0
	while ((i < ${#s})); do
		c=${s:i:1}
		if [[ $c == "_" ]]; then
			out+=" "
		elif [[ $c == "=" ]]; then
			out+=$(printf '%b' "\\x${s:i+1:2}")
			((i += 3))
			continue
		else
			out+=$c
		fi
		((i++))
	done
	printf '%s' "$out"
}

rfc2047_decode() {
	local value=$1 out="" head charset enc data decoded
	while [[ -n $value ]]; do
		if [[ $value != *=\?* ]]; then
			out+="$value"
			break
		fi
		head=${value%%=\?*}
		if [[ $head =~ ^[[:space:]]+$ && $value == ${head}"=?"* ]]; then
			:
		else
			out+="$head"
		fi
		value=${value#*=\?}
		charset=${value%%\?*}
		value=${value#*\?}
		enc=${value%%\?*}
		value=${value#*\?}
		data=${value%%\?=*}
		value=${value#*\?=}
		charset=${charset%%\**}
		if [[ ${enc,,} == b ]]; then
			decoded=$(b64url_decode "$data")
		else
			decoded=$(q_decode "$data")
		fi
		decoded=$(printf '%s' "$decoded" | iconv -f "$charset" -t utf-8 2>/dev/null || printf '%s' "$decoded")
		out+="$decoded"
	done
	printf '%s' "$out"
}

extract_header() {
	awk -v target="$2" '
		BEGIN { IGNORECASE = 1 }
		{ sub(/\r$/, "") }
		headerdone { next }
		$0 == "" { headerdone = 1; next }
		$0 ~ /^[ \t]/ { if (capture) { s = $0; sub(/^[ \t]+/, " ", s); buf = buf s } next }
		{
			if (capture) { print buf; capture = 0; buf = "" }
			idx = index($0, ":")
			if (idx > 0) {
				name = substr($0, 1, idx - 1)
				if (tolower(name) == tolower(target)) {
					capture = 1
					buf = substr($0, idx + 1)
					sub(/^ +/, "", buf)
				}
			}
		}
		END { if (capture) print buf }
	' "$1"
}

# safe_name <text> [maxlen=70]: filename-safe slug (mirrors the Python
# original: non [A-Za-z0-9._-] -> _, strip("_") on the edges, then truncate
# to maxlen and re-strip underscores the cut may have exposed).
safe_name() {
	local text max=${2:-70}
	text=$(sed 's/[^A-Za-z0-9._-]/_/g; s/^_*//; s/_*$//' <<<"$1")
	text=${text:0:max}
	text=$(sed 's/_*$//' <<<"$text")
	printf '%s' "${text:-unnamed}"
}

http() {
	local method=$1 url=$2 resp code
	resp=$(curl -sS --max-time 60 -X "$method" -H "Authorization: Bearer $TOKEN" -w $'\n%{http_code}' "$url")
	code=${resp##*$'\n'}
	resp=${resp%$'\n'*}
	if ((code >= 400)); then
		die "Gmail API $code: ${resp:0:300}"
	fi
	printf '%s' "$resp"
}

account_files() {
	case $1 in
	main)
		CRED=credentials.json
		TOK=token.json
		;;
	work)
		CRED=credentials-work.json
		TOK=token-work.json
		;;
	*) usage ;;
	esac
}

get_access_token() {
	local creds token
	[[ -r $STATE_DIR/$CRED ]] || die "$STATE_DIR/$CRED not readable (run as inboxclean?)"
	[[ -r $STATE_DIR/$TOK ]] || die "$STATE_DIR/$TOK not readable (run as inboxclean?)"
	creds=$(jq -r '.installed // .web // empty' "$STATE_DIR/$CRED") || die "cannot parse $CRED"
	[[ -n $creds ]] || die "$CRED has neither installed nor web section"
	token=$(jq -r '.refresh_token // empty' "$STATE_DIR/$TOK") || die "cannot parse $TOK"
	[[ -n $token ]] || die "$TOK has no refresh_token (re-auth runbook)"
	local resp
	resp=$(curl -sS --max-time 60 -X POST -H "Content-Type: application/json" \
		-d "$(jq -n --arg id "$(jq -r .client_id <<<"$creds")" --arg secret "$(jq -r .client_secret <<<"$creds")" --arg rt "$token" \
			'{client_id: $id, client_secret: $secret, refresh_token: $rt, grant_type: "refresh_token"}')" \
		https://oauth2.googleapis.com/token)
	TOKEN=$(jq -r '.access_token // empty' <<<"$resp")
	[[ -n $TOKEN ]] || die "token refresh returned no access_token"
}

# ---------- self-test (no network) ----------

self_test() {
	local failures=0
	check() {
		if [[ $2 == "$3" ]]; then return; fi
		echo "SELF-TEST FAIL: $1" >&2
		echo "  want: $(printf '%q' "$3")" >&2
		echo "  got:  $(printf '%q' "$2")" >&2
		failures=1
	}
	local enc deg msgfile
	enc="=?utf-8?B?$(printf 'Héllo wörld' | base64 -w0)?="
	deg=$(rfc2047_decode "$enc")
	check "utf-8 round-trip" "$deg" "Héllo wörld"
	check "Q-form decode" "$(rfc2047_decode "=?utf-8?Q?a_b=2Fc?=")" "a b/c"
	check "adjacent encoded words drop space" \
		"$(rfc2047_decode "=?utf-8?B?$(printf 'Grü' | base64 -w0)?= =?utf-8?B?$(printf 'ße' | base64 -w0)?=")" \
		"Grüße"
	msgfile=$(mktemp)
	printf 'From: x@y.z\r\nSubject: folded\r\n subject\r\nDate: Thu, 4 Oct 2026 12:34:56 +0200\r\nMessage-ID: <abc@x>\r\n\r\nbody\r\n' >"$msgfile"
	check "unfolded subject" "$(extract_header "$msgfile" Subject)" "folded subject"
	check "date header" "$(extract_header "$msgfile" Date)" "Thu, 4 Oct 2026 12:34:56 +0200"
	check "message-id header" "$(extract_header "$msgfile" Message-ID)" "<abc@x>"
	check "safe_name specials" "$(safe_name "Re: Terrible/Path: name?")" "Re__Terrible_Path__name"
	check "safe_name strips edges" "$(safe_name "__weird__name__")" "weird__name"
	check "safe_name empty" "$(safe_name "???")" "unnamed"
	check "safe_name truncates" "$(safe_name "$(printf 'a%.0s' {1..100})" 10)" "aaaaaaaaaa"
	check "date stamp parses" "$(date -u -d "Thu, 4 Oct 2026 12:34:56 +0200" +%Y-%m-%d_%H%M)" "2026-10-04_1034"
	rm -f "$msgfile"
	if ((failures)); then exit 1; fi
	echo "gmail_eml_export self-test: all passed"
}

# ---------- main ----------

TOKEN=""
ACCOUNT="" OUTDIR=/tmp/gmail-eml-export LIMIT=25
QUERIES=()
while (($#)); do
	case $1 in
	--account)
		[[ $# -ge 2 ]] || usage
		ACCOUNT=$2
		shift 2
		;;
	--outdir)
		[[ $# -ge 2 ]] || usage
		OUTDIR=$2
		shift 2
		;;
	--query)
		[[ $# -ge 2 ]] || usage
		QUERIES+=("$2")
		shift 2
		;;
	--limit)
		[[ $# -ge 2 ]] || usage
		LIMIT=$2
		shift 2
		;;
	--self-test)
		self_test
		exit 0
		;;
	*) usage ;;
	esac
done
[[ -n $ACCOUNT ]] || usage
((${#QUERIES[@]} > 0)) || QUERIES=("${DEFAULT_QUERIES[@]}")
command -v jq >/dev/null || die "jq is required"
account_files "$ACCOUNT"
get_access_token

mailbox=$(http GET "$API_BASE/users/me/profile" | jq -r '.emailAddress // "?"')
echo "account mailbox: $mailbox"

mkdir -p "$OUTDIR"
chmod 755 "$OUTDIR"
declare -A seen=()
emlfile=$(mktemp)
msgfile=$(mktemp)

for query in "${QUERIES[@]}"; do
	listing=$(curl -sS --max-time 60 -G "$API_BASE/users/me/messages" \
		-H "Authorization: Bearer $TOKEN" --data-urlencode "q=$query" --data "maxResults=$LIMIT" \
		-w $'\n%{http_code}')
	code=${listing##*$'\n'}
	listing=${listing%$'\n'*}
	if ((code >= 400)); then
		die "Gmail API $code: ${listing:0:300}"
	fi
	mapfile -t ids < <(jq -r '.messages // [] | .[].id' <<<"$listing")
	echo
	echo "query: $query -> ${#ids[@]} message(s)"
	if jq -e '.nextPageToken' <<<"$listing" >/dev/null 2>&1; then
		echo "  NOTE: more results exist than fetched (pagination truncated)"
	fi
	for mid in "${ids[@]}"; do
		if [[ -n ${seen[$mid]:-} ]]; then
			echo "  (dup) $mid"
			continue
		fi
		raw=$(http GET "$API_BASE/users/me/messages/$mid?format=raw" | jq -r '.raw')
		b64url_decode "$raw" >"$emlfile"
		cp "$emlfile" "$msgfile"
		date_hdr=$(extract_header "$msgfile" Date)
		stamp=$(date -u -d "$date_hdr" +%Y-%m-%d_%H%M 2>/dev/null || date -u +%Y-%m-%d_%H%M)
		subject=$(rfc2047_decode "$(extract_header "$msgfile" Subject)")
		[[ -n $subject ]] || subject="(no subject)"
		fname="${stamp}_$(safe_name "$subject").eml"
		cp "$emlfile" "$OUTDIR/$fname"
		chmod 644 "$OUTDIR/$fname"
		seen[$mid]=$fname
		echo "  $mid  $date_hdr"
		echo "    from: $(rfc2047_decode "$(extract_header "$msgfile" From)")"
		echo "    to:   $(rfc2047_decode "$(extract_header "$msgfile" To)")"
		echo "    msg-id: $(extract_header "$msgfile" Message-ID)"
		echo "    -> $fname  sha256=$(sha256sum "$OUTDIR/$fname" | cut -d' ' -f1)"
	done
done
rm -f "$emlfile" "$msgfile"
echo
echo "wrote ${#seen[@]} file(s) to $OUTDIR (mode 644, world-readable)"
