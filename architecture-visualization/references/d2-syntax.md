# D2 Syntax Cheat Sheet

> Loaded on demand by `architecture-visualization/SKILL.md`. Every snippet on
> this page was rendered with the local `d2` binary (v0.8.x, ELK engine) on
> 2026-09-08 — if it is here, it compiles.

## Verify before you draw

```bash
command -v d2 || {
  # NixOS:      nix shell nixpkgs#d2 -c d2 --version
  # Go toolchain (upstream-documented): go install oss.terrastruct.com/d2@latest
  echo "d2 missing — see install line above"
  exit 1
}
```

Render: `d2 --layout=elk input.d2 output.svg` (success prints
`successfully compiled ... to ...svg`). Use the exit code, not the absence of
stderr, to gate the next step.

## Shape vocabulary (architecture-relevant)

| Shape     | Syntax                                  | Use for           |
| --------- | --------------------------------------- | ----------------- |
| rectangle | `api: API {shape: rectangle}` (default) | services, modules |
| cylinder  | `db: Postgres {shape: cylinder}`        | databases, stores |
| cloud     | `cdn: CDN {shape: cloud}`               | external services |
| queue     | `events: Bus {shape: queue}`            | buses, channels   |
| page      | `users: Users {shape: person}`          | actors            |

## Direction and grouping

```d2
direction: down          # top-to-bottom reads best for event/command flows

system: Booking System {  # nesting = a box that contains children
  api: API
  worker: Worker
}
db: Postgres
system.api -> db: writes
```

`direction` is a root-level keyword. Nesting is indentation (spaces); a
nested key with a dot (`system.api`) is equivalent to nesting by braces.

## Connections with verb labels

```d2
api -> service: queries
service -> events: emits BookingCreated
events -> handler: delivers
handler -> service: handles
```

Labels after the colon are the verb — keep them domain verbs (`emits`,
`handles`, `queries`), never `conn1`.

## Styling (sparingly)

```d2
cache: Cache {
  style.stroke: "#3b82f6"    # hex colors, quoted
  style.fill: "#0b0f14"
}
```

Prefer semantic shape names over visual overrides; style only to mark
boundaries (e.g. dashed for the "proposed" box in an improved-state diagram:
`style.border-dashed: true`).

## Layout engines

- Default (dagre) is fine for small graphs and renders fastest.
- `--layout=elk` for large architectures — better automatic positioning of
  dense graphs (verified: both engines compiled the sample above on 0.8.x;
  ELK is bundled, no separate install).
- `--watch` for live iteration while authoring (opens a browser — avoid in
  headless agent sessions; just re-render the file instead).

## Common mistakes

- Unquoted hex in style values, or unquoted labels containing `:` — quote
  them: `label: "a: b"`.
- Forgetting that every key is global unless nested — two `api:` keys at root
  merge into one node; prefix or nest deliberately.
- Multi-word labels need quoting only when they contain specials
  (`:`, `;`, `,`); plain `User Service` is fine as a value, not as a key.
