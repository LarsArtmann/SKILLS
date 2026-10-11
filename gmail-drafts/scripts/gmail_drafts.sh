#!/usr/bin/env bash
# gmail_drafts.sh — create server-side Gmail drafts via InboxClean's stored
# OAuth grants. Bash port of gmail_drafts.py. Never sends mail. Must run as
# the `inboxclean` system user (token files are mode 600 under
# /var/lib/inboxclean); agent shells hand the one-liner to the user:
#
#   sudo -u inboxclean gmail_drafts.sh --account work --spec /tmp/spec.json
#
# Spec JSON: array of {"to", "cc"?, "bcc"?, "subject", "body"} objects.
# Creation is idempotent per subject (an existing draft with the same
# subject is skipped), headers are RFC 2047 B-encoded when non-ASCII (raw
# UTF-8 header bytes are read as Latin-1 by Gmail -> mojibake), and the
# token files are read-only: the refreshed access token lives in a shell
# variable only, never written back.
#
# Requires: curl, jq, base64, awk (gawk), iconv, sha256sum.
# Self-test (no network): gmail_drafts.sh --self-test
set -euo pipefail

STATE_DIR=/var/lib/inboxclean
API_BASE=https://gmail.googleapis.com/gmail/v1

usage() {
	echo "usage: gmail_drafts.sh --account main|work (--spec <json-file> | --list | --delete <draft-id>...)" >&2
	echo "       gmail_drafts.sh --self-test" >&2
	exit 2
}

die() { echo "ERROR: $*" >&2; exit 1; }

# ---------- helpers ----------

# b64url_decode <string>: URL-safe base64 -> raw bytes on stdout.
b64url_decode() {
	local s="$1" pad
	s=${s//-/+}
	s=${s//_//}
	pad=$(((4 - ${#s} % 4) % 4))
	printf '%s%.*s' "$s" "$pad" | base64 -d
}

# rfc2047_encode <text>: B-encoded-word per RFC 2047 (chunked at 45 bytes so
# each encoded word stays under the 75-char limit); ASCII text passes raw.
rfc2047_encode() {
	local text="$1"
	if ! LC_ALL=C grep -q '[^[:print:]]' <<<"$text" && ! LC_ALL=C grep -q '[^ -~]' <<<"$text"; then
		printf '%s' "$text"
		return
	fi
	local out="" chunk="" chunk_bytes=0 word
	while IFS= read -r -N 1 char; do
		local bytes
		bytes=${#char}
		if ((chunk_bytes + bytes > 45)) && [[ -n $chunk ]]; then
			word=$(printf '%s' "$chunk" | base64 -w0)
			out+="${out:+= }=?utf-8?B?${word}?="
			chunk="" chunk_bytes=0
		fi
		chunk+=$char
		chunk_bytes=$((chunk_bytes + ${#char}))
	done <<<"$text"
	if [[ -n $chunk ]]; then
		word=$(printf '%s' "$chunk" | base64 -w0)
		out+="${out:+= }=?utf-8?B?${word}?="
	fi
	printf '%s' "$out"
}

# rfc2047_decode <header-value>: decode =?charset?B|Q?...?= words (space-
# separated encoded words and plain runs both pass through).
rfc2047_decode() {
	local value="$1" out="" token plain
	while [[ -n $value ]]; do
		if [[ $value == *=\?*?\[BbQq\]?*?*=* ]]; then
			plain=${value%%=\?*}
			[[ -n $plain ]] && out+="$plain"
			value=${value#*=\?}
			local charset=${value%%\?*} rest enc data
			value=${value#*\?}
			enc=${value%%\?*}
			value=${value#*\?}
			data=${value%%\?=*}
			value=${value#*\?=}
			if [[ ${enc,,} == b ]]; then
				token=$(b64url_decode "$data" | iconv -f "${charset//\*/}" -t utf-8//translit 2>/dev/null || b64url_decode "$data")
			else
				token=$(printf '%s' "$data" | sed 's/_/ /g; s/=/\n=/g' | while IFS= read -r -d '' -r seg || [[ -n $seg ]]; do :; done)
				token=$(printf '%s' "$data" | perl -pe 's/_/ /g; s/=([0-9A-Fa-f]{2})/chr(hex($1))/ge' 2>/dev/null \
					|| printf '%s' "$data" | sed 's/_/ /g')
				token=$(printf '%s' "$token" | iconv -f "${charset//\*/}" -t utf-8//translit 2>/dev/null || printf '%s' "$token")
			fi
			out+="$token"
		else
			out+="$value"
			value=""
		fi
	done
	printf '%s' "$out"
}

# extract_header <file> <name>: unfolded header value (continuation lines
# joined), case-insensitive, header section only.
extract_header() {
	awk -v target="$2" '
		BEGIN { IGNORECASE = 1 }
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

# http <method> <url> [json-body]: response body on stdout; exits 1 with the
# API error detail on 4xx/5xx.
http() {
	local method=$1 url=$2 body=${3:-} resp code
	local -a args=(curl -sS --max-time 60 -X "$method" -H "Authorization: Bearer $TOKEN")
	if [[ -n $body ]]; then
		args+=(-H "Content-Type: application/json" -d "$body")
	fi
	resp=$("${args[@]}" -w $'\n%{http_code}' "$url")
	code=${resp##*$'\n'}
	resp=${resp%$'\n'*}
	if ((code >= 400)); then
		die "Gmail API $code: ${resp:0:300}"
	fi
	printf '%s' "$resp"
}

account_files() {
	case $1 in
	main) CRED=credentials.json; TOK=token.json ;;
	work) CRED=credentials-work.json; TOK=token-work.json ;;
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
	resp=$(http POST https://oauth2.googleapis.com/token \
		"$(jq -n --arg id "$(jq -r .client_id <<<"$creds")" --arg secret "$(jq -r .client_secret <<<"$creds")" --arg rt "$token" \
			'{client_id: $id, client_secret: $secret, refresh_token: $rt, grant_type: "refresh_token"}')")
	TOKEN=$(jq -r '.access_token // empty' <<<"$resp")
	[[ -n $TOKEN ]] || die "token refresh returned no access_token"
}

# build_raw <to> <cc> <bcc> <subject> <body-file>: RFC822 message, base64url
# (Gmail drafts.create raw format).
build_raw() {
	local to=$1 cc=$2 bcc=$3 subject=$4 bodyfile=$5
	local msg
	msg=$(mktemp)
	{
		printf 'To: %s\r\n' "$to"
		[[ -n $cc ]] && printf 'Cc: %s\r\n' "$cc"
		[[ -n $bcc ]] && printf 'Bcc: %s\r\n' "$bcc"
		printf 'Subject: %s\r\n' "$(rfc2047_encode "$subject")"
		printf 'MIME-Version: 1.0\r\n'
		printf 'Content-Type: text/plain; charset=utf-8\r\n'
		printf 'Content-Transfer-Encoding: base64\r\n'
		printf '\r\n'
		base64 -w 76 "$bodyfile"
	} >"$msg"
	base64 -w0 <"$msg" | tr '+/' '-_' | tr -d '='
	rm -f "$msg"
}

# draft_subjects: prints "draft_id<TAB>decoded-subject" for every draft.
draft_subjects() {
	local listing drafts draft mid raw msgfile
	msgfile=$(mktemp)
	listing=$(http GET "$API_BASE/users/me/drafts?maxResults=100")
	drafts=$(jq -r '.drafts // [] | .[] | "\(.id)\t\(.message.id)"' <<<"$listing")
	while IFS=$'\t' read -r draft mid; do
		[[ -n $draft ]] || continue
		raw=$(http GET "$API_BASE/users/me/messages/$mid?format=raw" | jq -r '.raw // ""')
		b64url_decode "$raw" >"$msgfile"
		printf '%s\t%s\n' "$draft" "$(rfc2047_decode "$(extract_header "$msgfile" Subject)")"
	done <<<"$drafts"
	rm -f "$msgfile"
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
	check "ascii subject passes raw" "$(rfc2047_encode "plain subject")" "plain subject"
	local enc deg
	enc=$(rfc2047_encode "Héllo wörld")
	deg=$(rfc2047_decode "$enc")
	check "utf-8 round-trip" "$deg" "Héllo wörld"
	enc=$(rfc2047_encode "Grüße aus München, viele liebe Grüße und so weiter bis über die Grenze")
	deg=$(rfc2047_decode "$enc")
	check "chunked round-trip" "$deg" "Grüße aus München, viele liebe Grüße und so weiter bis über die Grenze"
	deg=$(rfc2047_decode "=?utf-8?Q?a_b=2Fc?=")
	check "Q-form decode" "$deg" "a b/c"
	local msgfile
	msgfile=$(mktemp)
	printf 'To: a@b.c\r\nSubject: folded\r\n subject line\r\nFrom: x@y.z\r\n\r\nbody here\r\n' >"$msgfile"
	check "unfolded subject" "$(extract_header "$msgfile" Subject)" "folded subject line"
	check "from header" "$(extract_header "$msgfile" From)" "x@y.z"
	check "b64url decode" "$(b64url_decode "$(printf 'Grü' | base64 -w0 | tr '+/' '-_' | tr -d '=')")" "Grü"
	local raw bodyfile
	bodyfile=$(mktemp)
	printf 'Zeile eins\nZwei mit Ümläuten\n' >"$bodyfile"
	raw=$(build_raw "to@x" "cc@x" "" "Betreff Präzise" "$bodyfile")
	printf '%s' "$raw" | tr '-_' '+/' >>/dev/null
	local decoded
	decoded=$(mktemp)
	{ printf '%s' "$raw" | tr '-_' '+/'; local pad=$(((4 - ${#raw} % 4) % 4)); printf '%.*s' "$pad" ''; } | base64 -d >"$decoded"
	check "raw has To" "$(extract_header "$decoded" To)" "to@x"
	check "raw subject decodes" "$(rfc2047_decode "$(extract_header "$decoded" Subject)")" "Betreff Präzise"
	check "raw body intact" "$(base64 -d < <(tail -n 1 "$decoded"))" "$(cat "$bodyfile")"
	rm -f "$msgfile" "$bodyfile" "$decoded"
	if ((failures)); then exit 1; fi
	echo "gmail_drafts self-test: all passed"
}

# ---------- main ----------

TOKEN=""
ACCOUNT="" SPEC="" LIST=0
DELETE=()
while (($#)); do
	case $1 in
	--account)
		[[ $# -ge 2 ]] || usage
		ACCOUNT=$2
		shift 2
		;;
	--spec)
		[[ $# -ge 2 ]] || usage
		SPEC=$2
		shift 2
		;;
	--list)
		LIST=1
		shift
		;;
	--delete)
		shift
		while (($#)) && [[ $1 != --* ]]; do
			DELETE+=("$1")
			shift
		done
		;;
	--self-test)
		self_test
		exit 0
		;;
	*) usage ;;
	esac
done
[[ -n $ACCOUNT ]] || usage
if ((LIST == 0)) && ((${#DELETE[@]} == 0)) && [[ -z $SPEC ]]; then
	usage
fi
command -v jq >/dev/null || die "jq is required"
account_files "$ACCOUNT"
get_access_token

mailbox=$(http GET "$API_BASE/users/me/profile" | jq -r '.emailAddress // "?"')
echo "account mailbox: $mailbox"

if ((LIST)); then
	draft_subjects | sort | while IFS=$'\t' read -r draft subject; do
		printf '  %s  %s\n' "$draft" "$subject"
	done
fi

for draft_id in "${DELETE[@]:-}"; do
	[[ -n $draft_id ]] || continue
	http DELETE "$API_BASE/users/me/drafts/$draft_id" >/dev/null
	echo "deleted $draft_id"
done

[[ -n $SPEC ]] || exit 0
[[ -r $SPEC ]] || die "spec not readable: $SPEC"

existing=$(draft_subjects | sort)
n=$(jq 'length' "$SPEC")
for ((i = 0; i < n; i++)); do
	to=$(jq -r ".[$i].to // \"\"" "$SPEC")
	subject=$(jq -r ".[$i].subject // \"\"" "$SPEC")
	if [[ -z $to || -z $subject ]]; then
		die "spec entry $i missing to/subject"
	fi
	if grep -q "^${draft_id}\b" <<<"" 2>/dev/null; then :; fi
	if cut -f2- <<<"$existing" | grep -qFx "$subject"; then
		match_id=$(awk -F'\t' -v s="$subject" '$2 == s { print $1; exit }' <<<"$existing")
		echo "SKIP (subject exists as draft $match_id): $subject"
		continue
	fi
	cc=$(jq -r ".[$i].cc // [] | join(\", \")" "$SPEC")
	bcc=$(jq -r ".[$i].bcc // [] | join(\", \")" "$SPEC")
	bodyfile=$(mktemp)
	jq -j ".[$i].body // \"\"" "$SPEC" >"$bodyfile"
	raw=$(build_raw "$to" "$cc" "$bcc" "$subject" "$bodyfile")
	rm -f "$bodyfile"
	resp=$(http POST "$API_BASE/users/me/drafts" "{\"message\": {\"raw\": \"$raw\"}}")
	draft_id=$(jq -r '.id' <<<"$resp")
	mid=$(jq -r '.message.id' <<<"$resp")
	raw=$(http GET "$API_BASE/users/me/messages/$mid?format=raw" | jq -r '.raw')
	msgfile=$(mktemp)
	b64url_decode "$raw" >"$msgfile"
	rendered=$(rfc2047_decode "$(extract_header "$msgfile" Subject)")
	rm -f "$msgfile"
	moji=OK
	[[ $rendered == *"Ã"* || $rendered == *"Ä"* ]] && moji="[MOJIBAKE!]"
	echo "$moji $draft_id -> $to :: $rendered"
done
