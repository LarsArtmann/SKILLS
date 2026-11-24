# Status Report — humanlayer/skills analyzed, six patterns adopted into the canon, two leads parked with gates

**Date:** 2026-11-24 06:24 CET · **Session:** owner question "What can we
learn from https://github.com/humanlayer/skills for our SKILLS and
templates?", then an execute-and-verify directive.

**Scope line — VERIFIED here:** every quote encoded into our canon was
re-read in a local clone of the public repo at commit `4d69d20` (rg with
line numbers, this session); structural gates quoted with exit codes —
`check-skills.sh` plain **exit 0** and `--selftest` **exit 0** at session
start, plain **exit 0** after each edit batch; both docs-gates pre-flights
reported **SAFE / exit 0** over 122 reports. Described at HEAD `1491c7f`.
**NOT verified here:** no behavioral claim about the adopted patterns was
measured (they are craft guidance, not verdict-flipping doctrine — the
doctrine bar in `docs/doctrine-eval-protocol.md` applies to T164 if ever
executed); the parallel-sweep claims in the 04:55 report were not
re-verified; `/tmp/hl-skills` is a scratch clone (public repo, pinned
commit — recloneable, not committed as fixture).

## TL;DR

- Six authoring patterns adopted as Patterns 12–17 (completion criteria,
  final-answer templates, asserting headers, slot budgets,
  one-question interviews, provenance frontmatter) + 3 structure idioms
  in the Proven Patterns table.
- status-report now pins HEAD sha in the scope line — this report
  practices both new patterns.
- One TODO (T164: `<important if>` eval gate) and one ROADMAP idea
  (unattended-agent pairing) parked with pre-flight SAFE.
- Their three visible failure modes all re-confirm our existing canon.

## What the source repo is (verified, not remembered)

7 Claude Code plugins (marketplace.json + per-plugin `plugin.json`), MIT,
~8k lines, HEAD `4d69d20` (2026-11-01). Flagship `rpi`: 81-line router
SKILL.md → 14 per-phase `references/<step>/process.md` (create-X /
iterate-X pairs), artifact state in `.agents/artifacts/<task>/` with
`repos: [{identifier, sha}]` frontmatter, 5 subagent defs synced to a
second layout by `sync-rpi-references.ts`, and a two-tier test suite
(74-line structural test + 819-line real-LLM acceptance suite, 51
scenarios, git-diff behavioral assertions). Community signal: 17 issues —
#2 confirms the build/design-control-loop duplication, #1 a name
collision on install, #16/#9/#12 show invocation-spectrum toggling is
lively maintenance surface.

## The adoption is committed, not just proposed

| Change                                                                             | Where                                                           | Commit                    |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------- |
| Patterns 12–17 bodies + dup-fragment fix                                           | `how-to-write-skills/references/skill-patterns.md`              | `5a5acc8` (daemon bundle) |
| Proven Patterns rows (router, review gate, smallest-view) + Patterns 12–17 pointer | `how-to-write-skills/SKILL.md` (480 lines, under budget)        | `5a5acc8`                 |
| Scope line pins `git rev-parse --short HEAD`                                       | `status-report/SKILL.md` + section-quality guide + FEATURES row | `1e1e2e1`                 |
| T164 eval gate + CI-pairing ROADMAP idea                                           | `TODO_LIST.md`, `ROADMAP.md`                                    | `1491c7f`                 |

The daemon bundled the first two files into a heuristic commit before my
detailed commit could land (§5.12; content verified intact post-hoc). The
later edits were each committed immediately and beat the sweep.

## What was deliberately NOT adopted, and the reason

- **`<important if>` blocks for AGENTS.md** — the source's central
  adherence claim carries no measurement; adoption is gated behind a
  doctrine-protocol eval (T164).
- **Unattended CI pairing (skill + workflow YAML)** — genuinely new
  category for us but a direction decision, not a task; ROADMAP raw idea.
- **A show-me-style explanation skill** — trigger-collides with
  `architecture-visualization` and the html-report-kit territory; the
  transferable part (smallest-view menu) went into the Proven Patterns
  table instead.
- **Plugin/marketplace layout, slash-command UX,
  `disable-model-invocation`** — host-specific (Claude Code); our install
  channel is the skills CLI + symlink fan-out.
- **Per-skill semver in a marketplace manifest** — the skills-CLI lockfile
  already owns install/update tracking for third-party; our own skills
  version through git.

## Their failures re-confirm our canon (anti-learnings)

Three unsynced copies of show-me exist, two silently diverged, none carry
provenance headers — exactly what `sync-html-kit.sh --check` prevents
(§5.9). Their two loop skills share ~150 doctrine lines while preaching
"one source of truth" (their own open issue #2) — §5.5's graph prevents
this. Repo cruft (bun, `.humanlayer/` paths) leaks into "generic" plugins
— our extraction discipline (§5.5, collector-extraction pattern) exists
for this.

## Defects found in OUR repo while working (flagged, one fixed)

- **Fixed on sight:** `skill-patterns.md` carried a duplicated two-line
  fragment from the T94 move (2026-11-23); removed in the same edit.
- **Flagged, not mine to fix:** the `FEATURES.md` website-launch row
  claims "Slimmed … 2026-11-23 (T59)" while `website-launch/SKILL.md` is
  861 lines and TODO T59 is 🔵 BLOCKED on T58 — the owning session should
  reconcile the row with reality.
- **Corroborates T161:** two analysis subagents died on
  `Rate limit reached for requests` this session; both were recovered by
  moving to `zai/glm-5.3-flash` and re-prompted — session content
  survived, but it is the same concurrency-ceiling evidence T161 records.

## Reproduce

```bash
git clone --depth 50 https://github.com/humanlayer/skills /tmp/hl-skills
git -C /tmp/hl-skills checkout 4d69d20
rg -n "Completion criterion" /tmp/hl-skills/plugins/build-iterated-agentic-loop
./scripts/check-skills.sh; echo "exit=$?"
```

Encoded quotes trace to: `build-iterated-agentic-loop/SKILL.md:32,60,85,104`,
`rpi/.../create-research/process.md:46`, `show-me/SKILL.md:7`,
`rpi/.../create-prd/process.md:29,33`, `visual-pr/SKILL.md:29-30`,
`rpi/.../create-prd/references/prd_template.md:4-5` (all paths under
`/tmp/hl-skills/plugins/`, verified this session).
