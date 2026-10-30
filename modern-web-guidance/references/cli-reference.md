# CLI Reference — `modern-web-guidance`

Everything the routing skill needs to drive Google's Modern Web Guidance CLI:
the verified command surface, how to install it per agent, and what to do when
the agent will not use it. Google ships updates weekly, so the CLI remains the
fact source when this page and the tool disagree.

## Contents

1. [Verification status](#verification-status)
2. [Command surface](#command-surface)
3. [Install](#install)
4. [Per-agent install commands](#per-agent-install-commands)
5. [Troubleshooting](#troubleshooting)
6. [Notes and gotchas](#notes-and-gotchas)

---

## Verification status

| Claim | Status | Source |
| --- | --- | --- |
| Package `modern-web-guidance@0.0.196`, bin `modern-web-guidance` → `skills/modern-web-guidance/modern-web.mjs` | ✅ Verified | `npm view modern-web-guidance version dist-tags bin`, 2026-10-30 |
| Commands `search`, `list`, `retrieve`, `install`, `uninstall`, `update`; options `--choose`, `--skill-version`, `-h/--help`, `-v/--version` | ✅ Verified | `npx -y modern-web-guidance@latest --help`, 2026-10-30 |
| `search` emits one JSON array: `id`, `description`, `category`, `featuresUsed`, `tokenCount`, `similarity` | ✅ Verified | Live searches (`"scroll driven animation"`, `"carousel scroll snap"`), 2026-10-30 |
| `retrieve` accepts comma-separated IDs and prints Markdown starting `--- Guide for <id> ---` | ✅ Verified | `retrieve "dialog,style-parent-with-has"`, 2026-10-30 |
| `retrieve` on an unknown ID exits 1 with `Retrieve failed for <id>: Error: No guide found for use case: <id>` | ✅ Verified | `retrieve "not-a-real-guide-id"`, 2026-10-30 |
| `list` emits a JSON array of all use cases (192 at v0.0.196) | ✅ Verified | Live `list`, 2026-10-30 |
| `install` is the recommended path and enables automatic updates; `--choose` runs an interactive wizard (useful for extension work) | ⚠️ Docs-only | [get-started](https://developer.chrome.com/docs/modern-web-guidance/get-started), read 2026-10-30; not executed in this repo |
| Documented troubleshooting steps (prompt suffix, keywords, gap-listing instruction) | ✅ Verified | [troubleshoot](https://developer.chrome.com/docs/modern-web-guidance/troubleshoot), read 2026-10-30 |

## Command surface

All commands are subcommands of one binary. Without an install, prefix with
`npx -y modern-web-guidance@latest`.

| Command | Argument | Output |
| --- | --- | --- |
| `search <query>` | free-text intent | JSON array, 5 results, each with `id`, `description`, `category`, `featuresUsed`, `tokenCount`, `similarity` |
| `list` | none | JSON array of every use case: `id`, `category`, `description` (no `featuresUsed`) |
| `retrieve <ids>` | one ID or comma-separated IDs | Markdown guide per ID, each headed `--- Guide for <id> ---` |
| `install [--choose]` | none | installs the MWG skill into the agent's skills location |
| `update` | none | updates installed skills |
| `uninstall` | none | removes installed skills |

`--skill-version <version>` is documented in the help as internal: the skill
passes it when invoking itself. Do not set it by hand; a wrong value can pin
stale guidance.

## Install

| Mode | When | Command |
| --- | --- | --- |
| On-demand `npx` (default here) | one-off retrievals, CI, repos you do not want to mutate | `npx -y modern-web-guidance@latest retrieve "<id>"` |
| CLI install | you want automatic updates and the agent to self-activate MWG | `npx modern-web-guidance@latest install` |
| CLI install, pick skills | Chrome-extension work, or a trimmed catalogue | `npx modern-web-guidance@latest install --choose` |
| Agent Skills registry | Vercel `skills` CLI users | `npx skills add GoogleChrome/modern-web-guidance` |

Rule for this repo: **never vendor MWG content into `SKILLS/`**. Install or
`npx` it, and keep the local snapshot limited to IDs and routing
([./guide-catalog.md](./guide-catalog.md)), which cannot silently contradict the
upstream guide text.

## Per-agent install commands

Copy from the docs page rather than retyping these: the CLI surface of each
agent changes, and a stale command is a silent no-op. As documented on
2026-10-30:

| Agent | Command |
| --- | --- |
| Antigravity CLI | `agy plugin install https://github.com/GoogleChrome/modern-web-guidance` |
| Gemini CLI | `gemini extensions install https://github.com/GoogleChrome/modern-web-guidance --auto-update` |
| GitHub CLI | `gh skill install GoogleChrome/modern-web-guidance` |
| Claude Code | `claude plugin install modern-web-guidance@claude-plugins-official` |
| Claude Code (CLI, manual) | `/plugin marketplace add GoogleChrome/modern-web-guidance` then `/plugin install modern-web-guidance@googlechrome` then `/reload-plugins` |
| Codex | `codex plugin marketplace add GoogleChrome/modern-web-guidance` then `codex plugin add modern-web-guidance@googlechrome` |
| Copilot CLI | `/plugin marketplace add GoogleChrome/modern-web-guidance` then `/plugin install modern-web-guidance@googlechrome` |
| Goose | `goose plugin install https://github.com/GoogleChrome/modern-web-guidance --auto-update` |
| Grok | `grok plugin install https://github.com/GoogleChrome/modern-web-guidance --trust` |
| Kimi Code | `/plugins install https://github.com/GoogleChrome/modern-web-guidance` |
| JetBrains WebStorm | Settings → AI Assistant → Skills → Skill Manager → Modern Web Guidance → Install |

## Troubleshooting

Google documents the failure shapes, because they are common (2026-10-30):

- **The agent ignores MWG.** Append `use modern-web-guidance` to the prompt. Some
  agents also support direct invocation, such as `/modern-web-guidance` or
  `$modern-web-guidance`.
- **The agent invents code.** Add: "Bring up knowledge gaps and don't attempt to
  guess implementation. List them as open questions."
- **The right guide is never found.** Put the feature name in the prompt
  ("view transitions", "LCP", "anchor positioning") instead of vague intent, then
  inspect the agent's `search` and `retrieve` calls to see what it actually
  asked for. The same commands run fine by hand in a terminal.
- **Search returns neighbours only.** Add UI nouns from the task: drawer,
  wizard, hover preview, sticky table header, tap target. Framework names do not
  help; the index is platform-oriented.

Local checks worth running when output looks wrong:

```bash
# Is the tool reachable and current?
npx -y modern-web-guidance@latest --version

# Does the ID exist at all? (exits 1 + "No guide found for use case" if not)
npx -y modern-web-guidance@latest retrieve "<id>"

# What does the index think matches?
npx -y modern-web-guidance@latest search "<the words you would have used>"
```

## Notes and gotchas

- **The package ships the skill itself.** The installed bin resolves to
  `skills/modern-web-guidance/modern-web.mjs` inside the package, which is why
  `install` can write a skill without a second download.
- **`list` is cheaper than `search` for enumeration, but less useful for
  choice**: no `featuresUsed`, no `tokenCount`, no `similarity`.
- **Guides reference sibling guides** by ID, e.g. the `dialog` guide points at
  `declarative-dialog-popover-control` and `prevent-page-scroll-under-modal-dialog`.
  Following one hop is usually enough; chaining five is a sign the task needs
  splitting.
- **Snapshot drift is expected.** `guide-catalog.md` is dated; counts and IDs
  move. Re-run `list` and regenerate rather than editing the snapshot by hand.
- **The docs site lags the CLI** (12 of 16 categories rendered on 2026-10-30).
  If a topic seems undocumented, check `list` before concluding it is missing.
