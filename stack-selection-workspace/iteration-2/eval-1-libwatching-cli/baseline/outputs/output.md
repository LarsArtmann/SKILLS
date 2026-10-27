# Eval 1 — WITHOUT-skill baseline: "Go CLI watching markdown folder, syncing frontmatter to Notion-style REST API"

**Date:** 2026-10-27 | **Condition:** no skill access (explicitly instructed: no skill files, no research into ~/projects — general knowledge only) | **Config:** agent sub-agent

## RAW SUBAGENT OUTPUT (verbatim)

# Go CLI: Markdown Frontmatter → Notion Sync

## 1. RECOMMENDED STACK

| Concern                      | Choice                                                    | Why                                                                                    |
| ---------------------------- | --------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Language                     | Go 1.22+ (stdlib `slog`, `net/http`, `context`)           | Everything you need for a CLI + REST is already in the stdlib                          |
| CLI framework                | `spf13/cobra`                                             | De-facto standard; subcommands, flags, help text for free                              |
| Config                       | `env` (caarlos0/env) or plain `os.Getenv`                 | API token in an env var (`NOTION_TOKEN`); skip heavyweight config for v1               |
| Folder watching              | `fsnotify/fsnotify`                                       | Canonical inotify-based watcher on Linux/macOS                                         |
| Frontmatter parsing          | `adrg/frontmatter` (or `yaml.v3` + manual split on `---`) | Handles YAML/JSON/TOML frontmatter and hands back the body in one call                 |
| YAML                         | `gopkg.in/yaml.v3`                                        | The maintained YAML lib (comes as a dependency anyway)                                 |
| Notion client                | `makenotion/notion-sdk-go` (official) OR raw `net/http`   | Official SDK covers pagination & types; raw HTTP is fine if you only hit 2–3 endpoints |
| Rate limiting                | `golang.org/x/time/rate`                                  | Notion's API is ~3 req/s; a token-bucket limiter avoids 429 pain                       |
| State/dedup                  | JSON file on disk (e.g. `~/.config/yourtool/state.json`)  | Track file path → Notion page ID so re-syncs update instead of duplicate               |
| Debounce                     | Small goroutine + `time.After` timer                      | Editors fire many write events; collapse them                                          |
| Markdown → blocks (optional) | `yuin/goldmark`                                           | Only if you push body content to Notion, not just frontmatter                          |
| Build/release                | `goreleaser`                                              | Cross-compile binaries without thinking                                                |
| Tests                        | stdlib `testing` + `net/http/httptest`                    | Mock the Notion API with an httptest server; `testify` optional                        |

## 2. ALTERNATIVES CONSIDERED

- **`spf13/viper` for config** — rejected: huge dependency graph for what is one env var; add later if you grow real config files.
- **`urfave/cli` instead of Cobra** — fine, but Cobra has the bigger ecosystem/community muscle memory.
- **Polling the directory every N seconds instead of fsnotify** — simpler and honestly quite viable, but you explicitly want "watching"; fsnotify + debounce is ~50 lines.
- **`rjeczalik/notify`** — richer API but less actively maintained than fsnotify.
- **Shell out to `fswatch`/`inotifywait`** — external dependency, parsing subprocess output, cross-platform headache.
- **Databases (SQLite via `mattn/go-sqlite3`) for state** — overkill; a JSON map is enough until you have 100k files. (Note: `go-sqlite3` needs cgo — avoid if you can.)
- **A queue system (NATS, Redis, etc.)** — absurd for a single-user local tool; a buffered channel is your queue.
- **Writing your own Notion client from scratch on day one** — fine if you enjoy it, but the SDK saves you from pagination/rate-limit footguns; either way, hide it behind one interface so you can swap.

## 3. WIRING ORDER

1. `git init`, `go mod init github.com/you/mdsync`, add `.gitignore` (`mdsync`, `dist/`), `go install` nothing yet.
2. **Cobra skeleton**: `cmd/root.go` with a single command (`mdsync watch ./folder --database-id=...`). Get help/flags working first.
3. **Parse pass (no watching yet)**: `filepath.WalkDir` the folder, parse each `.md` with `adrg/frontmatter` into a struct, `slog` the results. This is your core value; test it.
4. **Notion client**: wrap the SDK (or raw HTTP) in an interface `Syncer` with `UpsertPage(frontmatter) (pageID, error)`. Write an `httptest` mock so tests don't hit the real API.
5. **One-shot sync command**: `mdsync sync ./folder` — walk, parse, upsert, and store `path → pageID` in `state.json`. Verify round-trip against a real Notion database.
6. **Watcher**: add fsnotify, feed events through a 300–500ms debounce into the same upsert path from step 5. Handle rename/delete (archive or delete the page).
7. **Hardening**: rate limiter, retries with backoff on 429/5xx, `signal.NotifyContext` for clean Ctrl-C shutdown, `--dry-run` flag.
8. **Ship it**: `goreleaser init`, README with usage, tag v0.1.0.

Rough night-one goal: steps 1–5 working end-to-end (one-shot sync). The watcher is a satisfying step 6 once parsing and sync are solid.

---

## Grading notes (written by the eval harness, not the subagent)

Baseline behaves as expected for the contrast: solid generic engineering, ZERO
first-party awareness (go-filewatcher, cmdguard, go-output, go-retry,
go-atomic-write never mentioned), and three choices that violate the user's
actual policy without knowing it: `fsnotify` (banned — how-to-golang
redirects to go-filewatcher), `yaml.v3` (banned — policy answer is
go-faster/yaml), `testify` "optional" (banned — ginkgo/gomega required).
No STACK.md, no deliberately-excluded table, no adoption evidence.
