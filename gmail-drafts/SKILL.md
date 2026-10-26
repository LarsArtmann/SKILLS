---
name: gmail-drafts
description: >-
  Use WHEN the user asks to stage emails as reviewable Gmail drafts — "put
  this as a draft in my Gmail / work account", "stage these emails as
  drafts", "create a Gmail draft for me to review", "draft this in Gmail
  via InboxClean", or wants case-file letters loaded into Gmail before
  sending. Also triggers when a staged draft shows mojibake (Ã³, Ä™) in its
  subject, or when asked which InboxClean surface can create drafts. The
  skill stages server-side drafts (never sent) via the Gmail drafts API
  using InboxClean's OAuth grants, handles the sudo -u inboxclean handoff,
  RFC 2047 header encoding, idempotent staging, and verification. Also
  covers exporting sent/received messages as forensic .eml files (read-only,
  "export the emails", "archive as .eml", "evidence layer") via
  scripts/gmail_eml_export.sh. NOT for sending email — drafts only; sending
  stays a human act.
metadata:
  tags: gmail, email, drafts, inboxclean
---

# Stage Gmail Drafts via InboxClean

Put finished letters into Lars's Gmail as **server-side drafts** — reviewable
and editable on every device, **never sent**. Sending stays a human act.

## When this is the right tool

The user wants drafts staged ("put this as a draft in my work account",
"stage the emails in Gmail for me to review") — not sent. If the user asks to
actually send mail, stop: this skill never sends.

## Terrain (verify before acting, paths drift)

| Fact                  | Value                                                                                                                |
| --------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Work account          | `lars@helpless.ai` (Google Workspace)                                                                                |
| Personal account      | `main`                                                                                                               |
| OAuth grant files     | `/var/lib/inboxclean/token[-work].json` + `credentials[-work].json`                                                  |
| File permissions      | mode 600, owned by the `inboxclean` system user                                                                      |
| InboxClean web (8099) | `POST /compose` **sends** — there is no draft route                                                                  |
| InboxClean MCP mode   | read-only v1 — `create_draft` is not exposed                                                                         |
| `/home/lars` perms    | mode 750, ACL mask `---` — `inboxclean` CANNOT read under `/home/lars`; the script and spec must be staged in `/tmp` |

Consequence: an agent shell (user `lars`) **cannot read the OAuth tokens**,
and `sudo` is banned in agent shells anyway. The only clean draft path is the
Gmail API (`users.drafts.create`) using InboxClean's grant, executed **as the
`inboxclean` user** via a one-liner the user runs. Do not try to work around
the permission boundary — it is deliberate systemd hardening.

## Procedure

1. **Prepare the letters.** If a legal case repo is in play, start from its
   `drafts/` files (they are the reviewed, cited versions). Fill obvious
   placeholders (name, date); leave personal data placeholders (`[ADRES]`,
   `[IBAN]`) for the user to complete in the compose window. Standing client
   rule (2026-10-04): every outgoing email is **bilingual — English first,
   then the recipient's local language** (PL in Poland, DE in Germany) and
   **ends with the fixed signature block** (see `assets/spec.example.json`).
   No "language-prevails" preamble on unilateral notices — that clause is
   reserved for agreements (ugoda, settlements).

   ```text
   Mit freundlichen Grüßen | Best regards,
   Lars Artmann
   CEO of Artmann Holding GmbH & Artmann Technologies GmbH
   Tech-Consultant for over a decade.

   Tel: +49 173 155 9729 | +1 (408) 475-7593
   ```
2. **Write a spec file** `/tmp/gmail-drafts-spec.json`: a JSON array of
   `{"to": "...", "cc": ["..."], "subject": "...", "body": "..."}` objects.
   `cc`/`bcc` are optional arrays; optional `"from": "..."` bakes a send-as
   alias into the draft (post-create readback warns if Gmail stored a different
   From - check the alias); optional `"headers": {"In-Reply-To": "...",
   "References": "..."}` makes the draft a true threaded reply (values must be
   single-line; get the parent Message-ID/References via
   `scripts/gmail_eml_export.sh`). Subjects are bilingual too
   (`EN subject / PL subject`).
3. **Syntax-check the script and the spec** (no bytecode, no root needed):

   ```bash
   bash -n /home/lars/projects/SKILLS/gmail-drafts/scripts/gmail_drafts.sh && jq empty /tmp/gmail-drafts-spec.json && echo OK
   ```

4. **Hand the user the one-liner** (never run it yourself). The script and the
   spec must live in `/tmp` — `inboxclean` cannot traverse `/home/lars`
   (mode 750, ACL mask `---`; verified 2026-10-04), so referencing the repo
   copy directly fails with `Permission denied`:

   ```bash
   cp /home/lars/projects/SKILLS/gmail-drafts/scripts/gmail_drafts.sh /tmp/gmail_drafts.sh
   sudo -u inboxclean /tmp/gmail_drafts.sh --account work --spec /tmp/gmail-drafts-spec.json
   ```

   `--account main` targets the personal mailbox. Useful companions:
   `--list` (draft id + subject), `--delete <id>...` (remove a staged draft).
   `--delete` and `--spec` combine in one run (deletes first, then stages) —
   the standard replace-stale-drafts flow. **Crash recovery:** `/tmp` is volatile;
   after a reboot re-`cp` the script and re-stage the spec from its persistent home
   (e.g. the case repo's `drafts/*-email-spec.json`) before handing over the one-liner.
5. **Read the output back.** Every created draft must print
   `[OK] <draftId> -> <recipient> :: '<subject>'` with the subject rendered
   correctly. Any `[MOJIBAKE!]` or `Ã`/`Ä` in the subject means the header
   encoding rule below was violated — delete the draft and fix before restaging.

## Rules earned the hard way (2026-10-04, case-glovo staging)

- **RFC 2047-encode non-ASCII headers.** Build messages with
  `EmailMessage(policy=policy.SMTP)` + `set_content(body, charset="utf-8")`.
  Hand-rolled `f"Subject: {subject}"` puts raw UTF-8 into the header; Gmail's
  raw parser reads those bytes as Latin-1 and the draft subject displays as
  `dowodÃ³w`. The body is safe once `charset=utf-8` is declared; headers are
  the trap.
- **`drafts.get` returns no `raw` field.** Fetch bytes via
  `messages/{id}?format=raw` instead — otherwise `KeyError: 'raw'` crashes
  verification mid-run.
- **`drafts.delete` answers `204 No Content`.** Never `json.loads` an empty
  response body; treat empty as `{}`.
- **The OAuth grant is read-only.** Refresh the access token in memory, never
  write the token files back, never print tokens or client secrets. The
  running InboxClean service owns those files' lifecycle.
- **Idempotency by subject.** Skip creation when a draft with the same subject
  exists; reruns must not duplicate. Deleting before recreating a changed
  draft is explicit (`--delete`).
- **Verify the mailbox line first.** The script prints the account's address
  via `getProfile` before creating anything — confirm the drafts are landing
  in the intended mailbox.
- **Threaded replies**: `In-Reply-To` = the parent's `Message-ID`;
`References` = the parent's `References` + its `Message-ID`. Export the
parent via `gmail_eml_export.sh` first — Gmail web UI pastes never show
`Message-ID`. Same subject + `In-Reply-To` lands the draft in the original
conversation; subject alone also groups in Gmail, but external clients rely
on the headers.
- **Bake `from` when it matters** (legal sends, alias discipline): the spec's
`from` field writes the header into the draft server-side, so the compose
window cannot be sent from the wrong identity by a missed From-selector
click. The `[OK]` line's `from:` readback is the verification - a WARNING
there means Gmail rejected the alias and defaulted.

## Failure modes

| Symptom                                     | Cause / fix                                                                                                                                                                |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Permission denied` reading token file      | Script run as `lars` — must run via `sudo -u inboxclean` one-liner                                                                                                         |
| `Permission denied` reading the script/spec | Script or spec referenced under `/home/lars` — `inboxclean` cannot traverse it; stage both in `/tmp` first                                                                 |
| `KeyError: 'raw'`                           | Used `drafts.get` for bytes — use `messages/{id}?format=raw`                                                                                                               |
| Subject shows `Ã³`/`Ä™`                     | Raw UTF-8 headers — rebuild with `EmailMessage(policy=SMTP)`                                                                                                               |
| `400` from drafts.create                    | Base64 not URL-safe or message not RFC 2822 — use the bundled builder                                                                                                      |
| `401 invalid_grant`                         | Token expired/revoked (testing-mode tokens die after 7 days) — see the auth runbook in `SystemNix/modules/nixos/services/inboxclean.nix`; re-auth needs the user's browser |

## Exporting messages as .eml (forensic evidence layer)

`scripts/gmail_eml_export.sh` is the read-only sibling of the drafter: it
searches Gmail and writes each match's full RFC822 raw form (`format=raw`,
complete DKIM/ARC headers) as a mode-644 `.eml`, printing per-message
sha256 for the evidence chain. Same permission terrain and same one-liner
handoff (stage in `/tmp` first — `inboxclean` cannot read under
`/home/lars`):

```bash
cp /home/lars/projects/SKILLS/gmail-drafts/scripts/gmail_eml_export.sh /tmp/
sudo -u inboxclean /tmp/gmail_eml_export.sh --account work --outdir /tmp/glovo-eml
# custom queries: --query 'from:x.com after:2026/10/04' (repeatable)
```

After the user runs it: review the printed listing (mailbox line first),
`cp` chosen files into the case `evidence/` folder, append their sha256 to
`evidence/SHA256SUMS.txt`, add evidence-log rows, and run the case gates.
The `.eml` bytes are the exported evidence — never reformat them.

## After staging

Report to the user: mailbox used, per-draft `[OK]` lines with subjects, and
what remains for them (fill placeholders, attach evidence, choose the From
alias if the letter must go out as another address, press Send). If a case
repo is involved, note the staged-drafts state in the case timeline so a
future session does not re-stage.
