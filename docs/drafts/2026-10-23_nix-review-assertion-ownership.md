## Why

The nix-review checklist teaches WHEN to assert (its NixOS Modules bullet; common-problems #26 "Missing Assertions") but not WHERE an assertion belongs when a repo ships a NixOS module that a downstream stack wraps. Today's webphone↔telephony-stack review derived the placement rules from first principles; the skill should carry them.

The rules that settled it:

- **Assertions live with the module that owns the options.** The stack's `services.telephony.webphone.dashboard` assertion ("requires the webphone service … the vhost location would proxy to nothing") cannot move upstream: the invalid state is a stack artifact — two nginx locations the wrapper option emits. Upstream, the same config (`services.webphone.settings.dashboard.enable` with the service off) is merely inert: freeform settings under `mkIf enable` carry no invalid state.
- **Upstream modules can never reference consumer options** — they must stay evaluable standalone (flake checks evaluate modules with stand-in options; `config.services.consumer.*` is an undefined-option eval error there).
- **Even typed upstream options cannot host cross-module assertions.** Webphone's `caddy.*` is typed, yet the "stack vhost collides with the upstream Caddy generator" guard lives in the stack — only the consumer sees both sides.
- **Wrapper option = passthrough + invariant → grow a typed option upstream.** Freeform settings cannot carry assertions; typed options can (`services.webphone.backup.*` proves it: option + assertion upstream, wrapper just sets it).
- **Rule of thumb:** upstream iff every input and consequence is upstream-namespaced (unit, user, own vhost generator, settings); wrapper iff it reads consumer data (extensions, domains, SSO) or writes consumer surfaces (proxy locations, backup indexes, env-file renders).
- **Eval-time mirrors of boot-time validation are a legitimate wrapper value-add** when defaults derive from consumer data (passkey rpId defaults to the stack's domain; upstream validatePasskey catches it only at boot).

## Proposal

- [ ] `nix-review/SKILL.md` — add next to the existing assertions bullet in `#### NixOS Modules (if applicable)`:

  > - [ ] **Assertions live with the option owner** — a module asserts only options it defines: wrapper/stack modules assert wrapper options, upstream modules theirs; an upstream module must stay evaluable standalone (it can never reference consumer options). A wrapper option that is pure passthrough + invariant is the signal to grow a typed option upstream — freeform `settings.*` cannot carry assertions (detail: `references/best-practices.md` § NixOS Module Structure).

- [ ] `nix-review/references/best-practices.md` — new `### Assertion ownership: wrapper vs upstream modules` under `## NixOS Module Structure` (TOC lists only `##` level, so no TOC edit), carrying the six rules above with the webphone evidence. Dismissed: numbered entry in common-problems.md next to #26 — renumbers #27-63 for no gain.
- [ ] `scripts/check-skills.sh` green (internal-link guard covers the new best-practices pointer).

## To verify

- The bullet exists verbatim as a checklist item and names all three: ownership, standalone evaluability, typed-option upgrade.
- `scripts/check-skills.sh` exit 0.
- Pose the webphone dashboard assertion question to a fresh session with the updated skill loaded: answer comes from the skill, not first-principles re-derivation.

💘 Generated with Crush
