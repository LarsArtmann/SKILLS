#!/usr/bin/env python3
"""Stage the Xcellent Talents reply as a Gmail DRAFT on lars@artmann.tech.

Drafts only — never sends (gmail scope lacks send; script has no send call).
Run as the service user so the work-account token is readable:

    sudo -u inboxclean python3 /tmp/stage_xcellent_reply.py
"""
import base64
import datetime
import json
import os
import sys
import urllib.parse
import urllib.request
from email import policy
from email.message import EmailMessage

MID = "<BENP281MB6594D264A6BEB480EDD70AD4B4702@BENP281MB6594.DEUP281.PROD.OUTLOOK.COM>"
DATA_DIR = "/var/lib/inboxclean"
TO = "Ngoc Trung Le <ngoctrung.le@xcellent-talents.com>"
SUBJECT = "Re: Vielen Dank für das Gespräch – Ergänzung deines Lebenslaufs"

BODY = """Hallo Trung,

danke für das angenehme Gespräch – hier die Selbsteinschätzung in Schulnoten
mit Projektbezug:

Java / Spring Boot: 1
  Java seit 2013, Oracle Certified Associate Java SE 8. Projekte: HORNBACH
  (Java-Microservices, Echtzeit-Streaming), SKYLINES ONE (Java-Backend, als
  CTO), Wolt (Spring-Boot-Microservices, 100k+ Transaktionen/Tag).

Quarkus: 3
  Praktische Projekterfahrung in Kundenprojekten (nicht öffentlich
  zugänglich). Dazu Java seit 2013 (OCA-Zertifikat), Spring Boot produktiv,
  Kubernetes-native Entwicklung — vollständige Sicherheit in kurzer Zeit.

Red Hat: 3
  Keine RHEL-spezifische Projekterfahrung. Einschätzung als Fähigkeitsgrad:
  10+ Jahre professioneller Linux-Betrieb (Debian/Ubuntu/NixOS), systemd
  (eigenes Hardening-DSL), SELinux-Praxis. RHEL-Einarbeitung in Tagen.

Red Hat OpenShift: 3
  Keine Projekterfahrung. Basis: produktive Kubernetes-Administration
  (primeXchange: Linux/K8s/Longhorn-Betrieb; Private Cloud: RKE2, Cilium,
  Argo CD; Wolt: K8s-Plattform). Einarbeitung in Tagen.

Red Hat OpenShift Serverless (Operatoren, Broker): 3
  Keine Projekterfahrung — aber genau meine Schicht: OpenShift Serverless
  ist Knative auf OpenShift. Knative Serving produktiv über Google Cloud
  Run (Rolls-Royce 2025/26; Vortrag "Cloud Run – Why Serverless Is
  Awesome", CloudWorld 2021); Eventing-/Broker-Konzepte vertraut aus
  Produktiv-Kafka-Systemen. Nur die OCP-spezifische Admin-Hülle ist neu.

Apache Kafka: 1
  Produktion: Event Sourcing/CQRS auf Kafka (Kundenprojekt 2021–2022),
  Wolt (Kafka-Plattform). Eigene Open-Source-Kotlin-Bindings für Kafka-
  Clients (github.com/LarsArtmann/kafka-clients-kotlin) und Autor einer
  Message-Bus-/Event-Sourcing-Bibliothek mit Broker-Integration
  (go-cqrs-lite/watermill).

Knative (Eventing, Kafka): 2
  Serving produktiv über Google Cloud Run (Rolls-Royce 2025/26; Vortrag
  "Cloud Run – Why Serverless Is Awesome", CloudWorld 2021). Eventing:
  konzeptionell tief vertraut (Event Sourcing/CQRS seit 2021, eigene
  AsyncAPI/TypeSpec-Emitter), kein eigener Eventing-Produktiveinsatz.

Grafana: 2
  Private Cloud: vollständiger Observability-Stack (Prometheus, Grafana,
  Loki, Tempo).

Prometheus: 2
  Private Cloud (Prometheus-Stack), eigene Plattform SystemNix
  (node-exporter, eigene Textfile-Collectors), Autor eines eigenen
  Monitoring-Servers (monitor365).

Eventgetriebene Architekturen und Betriebsaufgaben: 1
  HORNBACH (Batch → Real-Time-Streaming, 1M+ Produkte), Kundenprojekt
  2021/22 (Kafka CQRS/Event Sourcing), Wolt (event-getriebene
  Microservices), Autor einer Open-Source-Event-Sourcing-Bibliothek
  (go-cqrs-lite), Betrieb einer eigenen Produktivplattform mit 40+
  Services inkl. Observability und Alarmierung.

Viele Grüße
Lars
"""


def api(path, token, data=None):
    url = "https://gmail.googleapis.com/gmail/v1/users/me/" + path
    body = json.dumps(data).encode() if data is not None else None
    for attempt in range(6):
        req = urllib.request.Request(url, data=body, method="POST" if body else "GET")
        req.add_header("Authorization", "Bearer " + token)
        if body:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code != 429 or attempt == 5:
                raise
            retry_after = float(e.headers.get("Retry-After") or 30)
            wait = min(max(retry_after, 5.0), 90.0)
            print(f"429 rate-limited; waiting {wait:.0f}s (attempt {attempt + 1}/5)...", flush=True)
            import time
            time.sleep(wait)
    raise RuntimeError("unreachable")


def refresh():
    tok_path = os.path.join(DATA_DIR, "token-work.json")
    cred_path = os.path.join(DATA_DIR, "credentials-work.json")
    tok = json.load(open(tok_path))
    cred = json.load(open(cred_path))
    inst = cred.get("installed") or cred.get("web") or cred
    data = urllib.parse.urlencode({
        "client_id": inst["client_id"],
        "client_secret": inst["client_secret"],
        "refresh_token": tok["refresh_token"],
        "grant_type": "refresh_token",
    }).encode()
    req = urllib.request.Request("https://oauth2.googleapis.com/token", data=data)
    with urllib.request.urlopen(req, timeout=30) as r:
        resp = json.load(r)
    print("scope:", resp.get("scope"))
    if "compose" in (resp.get("scope") or "") or "mail.google.com" in (resp.get("scope") or ""):
        sys.exit("REFUSING: token grant can send mail; this script stages drafts only")
    tok["access_token"] = resp["access_token"]
    tok["expiry"] = (datetime.datetime.now(datetime.timezone.utc)
                     + datetime.timedelta(seconds=resp["expires_in"])).isoformat()
    with open(tok_path, "w") as f:
        json.dump(tok, f)
    return tok["access_token"]


def main():
    tok = json.load(open(os.path.join(DATA_DIR, "token-work.json")))
    try:
        token = tok["access_token"]
        profile = api("profile", token)
    except Exception:
        token = refresh()
        profile = api("profile", token)
    account = profile.get("emailAddress")
    print("account:", account)
    if account != "lars@artmann.tech":
        sys.exit("REFUSING: expected lars@artmann.tech, got " + str(account))

    res = api("messages?" + urllib.parse.urlencode({"q": 'rfc822msgid:"' + MID + '"', "maxResults": 1}), token)
    msgs = res.get("messages") or []
    if not msgs:
        sys.exit("original message not found (rfc822msgid " + MID + ")")
    thread_id = msgs[0]["threadId"]
    print("thread:", thread_id)

    drafts = api("drafts?maxResults=50", token).get("drafts") or []
    for d in drafts:
        full = api("drafts/" + d["id"], token)
        headers = {h["name"].lower(): h["value"] for h in full["message"]["payload"]["headers"]}
        if headers.get("in-reply-to") == MID:
            sys.exit("draft already staged: " + d["id"] + " — nothing to do")

    m = EmailMessage(policy=policy.SMTP)
    m["From"] = "Lars Artmann <lars@artmann.tech>"
    m["To"] = TO
    m["Subject"] = SUBJECT
    m["In-Reply-To"] = MID
    m["References"] = MID
    m.set_content(BODY)

    raw = base64.urlsafe_b64encode(m.as_string().encode()).decode()
    draft = api("drafts", token, {"message": {"raw": raw, "threadId": thread_id}})
    check = api("drafts/" + draft["id"], token)
    headers = {h["name"].lower(): h["value"] for h in check["message"]["payload"]["headers"]}
    print("DRAFT STAGED:", draft["id"])
    print("subject:", headers.get("subject"))
    print("in-reply-to:", headers.get("in-reply-to"))
    print("thread:", check["message"].get("threadId"))


if __name__ == "__main__":
    main()
