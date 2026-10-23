## Why

Reviewed the wrapper-vs-upstream split of webphone's NixOS wiring (stack `modules/telephony/{default,web,options}.nix` vs webphone `package/nixos-module.nix`) and the rules that settled "which assertions belong where" are generalizable module design — exactly what the nix-review skill's `NixOS Modules` checklist should teach. Today it has "Assertions for constraints — port ranges, required services, incompatible options" (presence, common-problems #26) but nothing about PLACEMENT when two modules are stacked.

The rules that decided today's case:

- **Assertions live with the module that owns the options.** The stack's `!services.telephony.webphone.dashboard.enable || services.telephony.webphone.enable` (`modules/telephony/default.nix:299`) cannot move upstream: it asserts wrapper options whose invalid state is a stack artifact — the two nginx locations that "would proxy to nothing" (`web.nix:431`). On webphone's side the same config is merely inert (`settings.*` under `mkIf enable`).
- **Upstream modules can never reference consumer options.** They must stay evaluable standalone (flake checks evaluate with stand-in options; a bare `config.services.consumer.*` reference is an undefined-option eval error).
- **Wrapper option = passthrough + invariant → grow a typed option upstream.** Freeform settings cannot carry assertions; typed options can. Webphone shows the pattern both ways: `backup.*`/`caddy.*` are typed options with assertions, while `dashboard`/`crm` are raw `settings` subtrees whose both-or-neither rules live only in the stack plus boot-time Go validation.
- **Rule of thumb:** upstream iff every input and consequence is upstream-namespaced (unit, user, own vhost generator); wrapper iff it reads consumer data (extensions, domains, SSO) or writes consumer surfaces (proxy locations, backup indexes, env-file renders).
- **Eval-time mirrors of boot-time validation are a legitimate wrapper value-add** when defaults derive from consumer data (passkey rpId defaults to the stack's domain; upstream validatePasskey catches it only at boot — `default.nix:364`).

## Proposal

- [ ] `nix-review/SKILL.md` — one checklist bullet in `#### NixOS Modules (if applicable)`, next to the existing assertions bullet: ownership rule + standalone-evaluability constraint + the typed-option-upgrade signal, pointer to the reference entry.
- [ ] `nix-review/references/best-practices.md` — subsection under `## NixOS Module Structure`: "Assertion ownership: wrapper vs upstream modules" with the five rules above and the webphone evidence. (Dismissed alternative: numbered entry in common-problems.md `## NixOS Module Issues` next to #26 — costs renumbering #27-63 for no gain.)
- [ ] `scripts/check-skills.sh` green (checklist↔reference drift guards; nix-review already has its FEATURES.md row).

## To verify

The next "should this assertion/config move upstream?" question is answered by the checklist without re-deriving the standalone-evaluation argument from first principles.

💘 Generated with Crush
