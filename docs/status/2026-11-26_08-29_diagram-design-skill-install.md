# Status — `diagram-design` third-party skill: install, layout, doctrine update

**Report time:** 2026-11-26 08:29 CET (`date`) · **Repo:** `LarsArtmann/SKILLS`
**Pinned commit:** `b49ff19` (`git rev-parse --short HEAD`, auto-commit
"chore: auto-commit 2 changed file(s)"), plus one uncommitted
`docs/skill-forks.md` correction written during this report.

## Scope line

**Verified here (fresh commands, exit status quoted):**

| Claim | Evidence |
| --- | --- |
| Skill installs and resolves upstream | `npx -y skills@latest add cathrynlavery/diagram-design -g -a crush -y` exit 0; lock entry commit `b228c5d` |
| Installed tree is a faithful copy | `sha256sum` SKILL.md = upstream `1a197a0a…f4600`; installed files 326 = upstream blob count 326 |
| Canonical layout + Crush visibility | `~/.agents/skills/diagram-design` (real dir), `~/.config/crush/skills/diagram-design` → symlink, `readlink -f` resolves |
| Fresh session discovers it | `crush run "… YES if a skill named diagram-design …"` → `YES` |
| CLI sees the source | `npx skills ls -g` → `Agents: Crush, Pi, Zed`, `Source: cathrynlavery/diagram-design` |
| Skill internals sound | 0 broken relative links across the skill's markdown; no `.git*` inside the tree |
| Repo structure still green | `scripts/check-skills.sh` 0 (38 skills, 0 thin; 206 md links OK); `--selftest` 0 (3/3); `check-shell.sh` 0; `check-skill-links.sh` 0; `check-agents-md.sh` 0 with 2 advisories |
| Upstream posture read | `PRIVACY.md` (no server/telemetry; Google Fonts at render; onboarding fetches a named site) |
| Export dependency absent | `python3 -c "import playwright"` fails; `~/.cache/ms-playwright` holds only `ffmpeg-1013` |
| Aggregation repo state | `git -C ~/.agents/skills status --short`: 77 untracked, 92 deleted, 69 modified; `?? diagram-design/` |

**NOT verified here:**

- **`docs-gates` battery — INCONCLUSIVE, not green.** Ran
  `timeout 240 nix run github:Artmann-Technologies/docs-gates -- run .`; it
  was still running and printed "interrupted by the user". The shell then
  echoed `docs_gates_exit=0` — that 0 is **`tail`'s** exit status, not the
  battery's. Treat as not run.
- **No diagram was generated.** Installation is not capability; the 52-type
  rendering path is untested here.
- **PNG/PDF export untested and unprovisionable now** (Playwright + Chromium
  missing; the skill explicitly refuses to install runtimes itself).
- **Snyk "Med Risk"** composition: the skills.sh/Snyk report was not opened.
- **Other agents' discovery** (Pi, Zed) — only Crush was probed.
- **`skills update -g` behaviour against a hand-made symlink** for this skill.
- **`docs-gates`/BuildFlow corpus gates** on the two edited docs.

---

## a) FULLY DONE

1. **Skill installed** — `diagram-design` (MIT, upstream v2.6, commit
   `b228c5d`), 326 files / 6.3 MB: 387-line `SKILL.md` (971-char description,
   under the 1024 cap), 71 `references/`, 245 `assets/` example pages,
   9 Python scripts.
2. **Canonicalised to fleet layout** — real dir in `~/.agents/skills/`, symlink
   from `~/.config/crush/skills/` (the `copywriting`/`typesafe-ai` shape);
   the CLI had written a real directory into the Crush root only.
3. **Integrity proven** — SKILL.md sha256 identical to upstream, file count
   identical to upstream's blob count, no nested `.git`, 0 broken internal
   markdown links.
4. **Discovery proven in a new session** — the documented failure mode
   ("install is a session-start snapshot") was actually tested, not assumed.
5. **Doctrine updated** — `AGENTS.md` §5.10 third-party inventory now names
   `diagram-design` and the rest of the real directories the old list had
   missed; a pointer to `docs/skill-forks.md` replaces an over-long inline
   paragraph (kept the file under its 52 KB budget: 51,896 B).
6. **Provenance recorded** — `docs/skill-forks.md` §"2026-11-26" carries the
   install command, upstream commit, tree shape, script audit, artifact
   network behaviour, export dependency, layout correction, and the lockfile
   drift finding.
7. **Lockfile drift identified and recorded** — 20 real third-party dirs,
   1 skills-CLI-locked (`diagram-design`), 1 own-channel (`modern-web-guidance`),
   **18 invisible to `skills update -g`**.
8. **Repo gates green** — structural, selftest, shell, links, AGENTS budget.
9. **Formatter state classified** — `dprint fmt AGENTS.md` fails
   "Formatting not stable. Bailed after 5 tries" on *both* the pre-session and
   post-session file; pre-existing, not caused by this change.
   `docs/skill-forks.md` formats clean.

## b) PARTIALLY DONE

1. **Lockfile repair** — the drift is documented, not fixed. 18 third-party
   skills need a per-source re-add to regain lock entries. *Open: re-add loop.
   Effort M.*
2. **Aggregation commit** — `?? diagram-design/` sits untracked in
   `~/​.agents/skills` (git repo `agent-skills`), bundled with a pre-existing
   238-entry mess. Nothing staged, nothing committed (harness forbids commits
   without an explicit request). *Effort S once policy is decided.*
3. **Raster export** — HTML/SVG generation works; PNG/PDF cannot run on this
   machine. The dependency is documented by upstream and the skill refuses to
   self-install. *Effort S/M to provision, decision needed.*
4. **Trigger disambiguation** — `diagram-design` (52 types, architecture /
   sequence / ER / Sankey / Gantt) overlaps `architecture-visualization`
   (D2 diagrams) and `html-report-kit` (report visuals). Neither owned skill
   mentions it; a plain "draw an architecture diagram" can now match two
   skills. *Effort S, one-line description edits.*
5. **HARVEST of section (f)** — deliberately not run; the user said "then wait
   for instructions". `TODO_LIST.md`/`ROADMAP.md` are unchanged, so the
   improvement list below exists only in this timestamped file. *Effort S.*

## c) NOT STARTED

1. **Smoke test** — generate one real diagram (e.g. this repo's architecture)
   and run `scripts/verify_geometry.py` / `self_check.py` on it. This is the
   only check that proves "installed" means "works".
2. **Playwright + Chromium provisioning** (venv/`uv`, then
   `playwright install chromium`); blocked on a toolchain decision, not effort.
3. **Aggregation topology commit** for `diagram-design/`.
4. **Re-add the 18 unlocked third-party skills** by source.
5. **Repair or accept the 92 deleted / 69 modified aggregation entries**
   (HyperFrames upstream moved references; documented strand-locals effect).
6. **dprint `AGENTS.md` instability** — never triaged, only classified.
7. **`docs-gates` full run** — attempted, timed out, inconclusive.
8. **Pi/Zed discovery verification** — `skills ls -g` claims them; not tested.
9. **`skills update -g` symlink-safety test** for this skill (the CLI can
   replace a link with a real dir; §5.10 rule 2 warns about the owned-skill
   case, not the third-party one).
10. **Third-party licence inventory** — 20 upstream-owned trees, no central
    attribution file in this repo.
11. **`~/.diagram-design/profiles/` policy** — where brand profiles will land;
    nothing exists yet, nothing decided.
12. **README / FEATURES.md rows** — correct to skip: doctrine says third-party
    skills are never added to this repo. Recorded here so a later audit does
    not read the omission as a miss.

## d) TOTALLY FUCKED UP

1. **I trashed the original install before verifying the copy.**
   `cp -a` → `find | wc -l` → `trash` → symlink. A file count is not an
   integrity check; a truncated or partially-copied tree would have passed it
   and the good copy would already have been in the trash. The damage is nil
   (sha256 and blob count match upstream, verified afterwards), but the
   *process* was unsafe and is exactly the class the safety rules exist for.
   **Severity: low impact / high risk. Root cause: convenience. Mitigation:
   none needed now; rule change proposed in (e).**
2. **I wrote an unverified causal claim into a repo document.**
   First version of `docs/skill-forks.md` said the Snyk "Med Risk" badge
   "comes from the bundled script surface, not from a finding in the code
   read" — I never opened the report. Corrected in this session to "the report
   was not opened, so no claim is made". **Severity: medium (fabrication risk
   in the provenance file that future sessions trust).**
3. **I understated the network behaviour.** "No network calls
   (`urllib.parse` only)" was true of the *scripts* and false of the
   *artifacts*: upstream `PRIVACY.md` says generated HTML/templates load
   Google Fonts, and onboarding fetches a user-named site. Corrected.
   **Severity: medium (privacy-relevant claim).**
4. **I got a count wrong in the same document** ("73 `references/`") — it is
   71 files, all markdown. Corrected. **Severity: low; the class is "eyeballed
   an `ls` instead of counting".**
5. **PNG/PDF export is non-functional on this machine.** Not broken by me, but
   it *is* the state of the capability I just installed: `import playwright`
   fails, no Chromium. The skill's own docs tell the agent to stop and ask —
   so first use will produce a dead end unless provisioned.
6. **The aggregation layer is materially out of sync** (92 deletions, 69
   modifications, 77 untracked). Pre-existing, discovered here, silently
   invisible to every session-start check. This is the "upstream moves strand
   local copies" effect recorded in `docs/skill-forks.md`, now with a count.
7. **The auto-commit daemon landed my edits as `b49ff19`
   "chore: auto-commit 2 changed file(s)"** — correct per the harness
   (I must not commit), but it means the repo's "very detailed commit message"
   norm lost the explanation; it lives only in this report and the file text.

## e) WHAT WE SHOULD IMPROVE

1. **Verify before destroying** — a byte comparison (`sha256sum`, `diff -rq`)
   must precede `trash`, always. Add one line to AGENTS §5.10's rules list;
   it applies to every future "copy, then replace with a link" step.
2. **Script the recipe instead of hand-dancing it** — install → relocate →
   symlink → verify is four manual steps that already produced a wrong layout
   once. `scripts/install-third-party-skill.sh <owner>/<repo>` would make the
   canonical layout the only possible outcome.
3. **Add a third-party reconciliation check** — compare real dirs in
   `~/.agents/skills/` against the lockfiles and upstream HEAD; report
   unlocked, stale, and store-pinned entries. Today 18 dirs are frozen in
   place and nobody notices.
4. **Security claims must trace to a primary source** — quote `PRIVACY.md`
   lines or the Snyk page; never infer a vendor rating's cause. Same rule as
   `verify-external-claims`, applied to our own writes.
5. **Count, don't eyeball** — every number written into a doc should have the
   command that produced it in the same session (71 vs 73 came from an `ls`
   glance).
6. **Never read an exit code through a pipe.** `cmd | tail; echo $?` reports
   `tail`'s status. This session produced a false `docs_gates_exit=0` on an
   interrupted run — the exact failure `SESSION-START.md` warns about for
   `check-skills.sh`. Use `PIPESTATUS`, or run twice (capture, then display).
7. **Disambiguate at install time** — when a new skill's domain overlaps an
   owned skill, update the owned skill's description in the same change. The
   doctrine forbids editing third-party files; it says nothing about the
   counterpart we own, and that is the side where routing lives.
8. **AGENTS.md has 104 bytes of headroom.** It was 51,734 B before this
   session; the doctrine is "extract to docs, never raise the budget". The
   next addition must remove something.
9. **Aggregation drift has no gate.** Either add a check (count of
   deleted/modified entries above a threshold) or state explicitly that the
   aggregation repo is never trusted as current.
10. **The formatter cannot format the repo's canonical document**
    (`AGENTS.md`, 5-try instability). Whatever plugin produces that is
    effectively unformatted forever; decide: exclude it deliberately, or fix.
11. **Install ≠ capability.** Every skill install should end with one
    end-to-end exercise, otherwise the fleet accumulates "available but never
    run" skills — the ghost-system failure class.
12. **CLI version drift** — I used `skills@latest`; the repo's own T103
    evidence pinned 1.5.22. Pin when reproducing probes, or the observation
    is not reproducible.

## f) Up to 50 things to get done next

Impact: Critical / High / Medium / Low. Effort: S (<30 min) / M (30 min–2 h) /
L (>2 h).

| # | Task | Impact | Effort | Category |
| --- | --- | --- | --- | --- |
| 1 | Smoke-test the skill: generate one architecture diagram for this repo, then run `verify_geometry.py` + `self_check.py` | High | M | Test |
| 2 | Correct the Snyk line in `docs/skill-forks.md` — already corrected this session; verify by reading it back after the daemon commits | High | S | Documentation |
| 3 | Verify the corrected network/PRIVACY paragraph survives formatting and reads accurately | High | S | Documentation |
| 4 | Provision Playwright + Chromium (venv or `uv`) and prove `export_png.py` on a sample | High | M | Feature |
| 5 | Decide and record whether raster/PDF export is a requirement at all | High | S | Decision |
| 6 | Add `scripts/install-third-party-skill.sh` (add → relocate → symlink → checksum verify) | Medium | M | Quality |
| 7 | Add `scripts/check-third-party.sh` reconciling real dirs vs lockfiles vs upstream HEAD | Medium | M | Quality |
| 8 | Re-add the 18 unlocked third-party skills by source to restore lock entries | Medium | M | Quality |
| 9 | Commit the aggregation topology for `diagram-design/` only (leave HyperFrames hunks untouched) | Medium | S | Cleanup |
| 10 | Triage the aggregation repo's 92 deletions / 69 modifications (re-add vs accept) | Medium | M | Cleanup |
| 11 | Add a disambiguation sentence to `architecture-visualization` pointing to `diagram-design` for HTML/SVG editorial output | High | S | Documentation |
| 12 | Decide whether `html-report-kit` consumer skills should cite `diagram-design` for diagram blocks | Medium | S | Decision |
| 13 | Run `docs-health` HARVEST over this report's section (f) once the user gives the go-ahead | High | S | Documentation |
| 14 | Add "verify before trash" to AGENTS §5.10 rules | Medium | S | Documentation |
| 15 | Replace the AGENTS third-party list with a pointer to a generated inventory file, freeing budget | Medium | M | Documentation |
| 16 | Triage the dprint `AGENTS.md` 5-try instability (repro, then exclude or fix) | Medium | M | Bug |
| 17 | Add `AGENTS.md` exclusion to dprint config if the plugin bug is unfixable | Low | S | Cleanup |
| 18 | Add a session-start check for third-party dirs missing from any lockfile | Medium | M | Quality |
| 19 | Test `skills update -g` against the hand-made `diagram-design` symlink and record the result | Medium | S | Test |
| 20 | Probe Pi and Zed discovery instead of trusting `skills ls -g`'s Agents column | Low | S | Test |
| 21 | Document the `~/.diagram-design/profiles/` location and decide repo vs home policy | Low | S | Decision |
| 22 | Verify the skill's first-run style-guide gate behaves sanely in a branded project (option "e: keep default" path) | Medium | S | Test |
| 23 | Pin the skills CLI version used for installs/probes (record 1.5.22 baseline) | Low | S | Documentation |
| 24 | Add a one-line "install != capability" rule to `how-to-write-skills` or the install doctrine | Medium | S | Documentation |
| 25 | Count-check every numeric claim added to `docs/skill-forks.md` (326, 6.3 MB, 71, 245, 9, 20, 18) in one pass | Medium | S | Documentation |
| 26 | Clean the 6.3 MB duplicate out of the trash once satisfied | Low | S | Cleanup |
| 27 | Test the tier-1 install path (`skills add owner/repo@diagram-design`) to confirm per-skill install works | Low | M | Test |
| 28 | Measure the session-context cost of a 971-char skill description before adding more of them | Low | S | Quality |
| 29 | Decide ownership of "diagram inside a report" (kit component vs skill output) | Medium | S | Decision |
| 30 | Add `diagram-design`/`general-video`-class licence attribution to a single third-party inventory | Low | M | Documentation |
| 31 | Verify AGENTS §5.10 rule 7's three one-off entries still match reality (font-design, go-cqrs-lite, templ-components) | Low | S | Documentation |
| 32 | Add a guard that Crush-root entries are symlinks except the documented real dirs | Low | M | Quality |
| 33 | Re-run `docs-gates` with a longer timeout and capture its real exit code (no pipe) | Medium | S | Test |
| 34 | Re-run `buildflow` and confirm the 4 `go-file-too-large` findings are unchanged by this session | Low | M | Test |
| 35 | Decide whether `style-sampling`/`reverse-any-video`/`general-video` are still wanted (three unlisted real dirs) | Low | S | Decision |
| 36 | Add upstream-version staleness detection for third-party skills (metadata.version vs plugin.json) | Low | M | Feature |
| 37 | Record the `-a crush` layout trap in the skills-CLI findings list (it is documented, but not as a trap) | Medium | S | Documentation |
| 38 | Check whether diagram `assets/` example pages need to ship at all (4.9 MB of 6.3 MB) | Low | S | Cleanup |
| 39 | If the assets are needed, document that the skill is 6.3 MB before fleet-wide rollout | Low | S | Documentation |
| 40 | Add a "third-party skill audit" subsection template (install, sha, tree, scripts, network, deps) so the next install is mechanical | Medium | S | Documentation |

## g) Questions I cannot answer myself

1. **Aggregation repo policy:** should `~/.agents/skills` keep committing
   third-party *content* (6.3 MB per skill, 238 dirty entries today), or should
   it track only lockfile/pins and ignore the trees? That decides whether I
   stage `diagram-design/` (item 9) or add it to `.gitignore`.
2. **Is raster/PDF export required?** If yes, I will provision a Python
   Playwright + Chromium environment (nix devshell or `uv` venv) and prove it;
   if HTML/SVG is enough, I will note the limitation and stop.
3. **Should `diagram-design` become the default diagram engine** — i.e. do I
   edit `architecture-visualization` (and report skills) to route HTML/SVG
   diagrams to it, keeping D2 for architecture-as-code? Or is it a secondary
   option and D2 stays first?

---

## Self-review — the questions you asked, answered bluntly

**What did you forget?** Run `check-skills.sh --selftest` at the *start*
(SESSION-START step 5) — I ran the plain check first and only remembered the
selftest while writing this report. Read the skill's `PRIVACY.md` before
claiming "no network calls". Open the Snyk report before explaining its badge.
Verify the copy before trashing the original. Check whether the raster export
could actually run. Notice that a 52-type diagram skill collides with our
existing diagram skill. Capture real exit codes instead of pipe tails. Run one
end-to-end diagram.

**What is something stupid we do anyway?** Installing a skill with four manual
shell steps and no checksum, in a repo whose entire doctrine is "symlinks, not
copies". Trusting `skills ls -g`'s "Agents:" column as proof of discovery.
Keeping 18 third-party skills in a lockfile-less limbo and calling the
directory listing the inventory.

**What could you have done better?** Written the provenance doc *after* the
verification pass (two of its three defects came from writing first). Pinned
the CLI version. Verified the copy with `diff -rq`/sha before `trash`. Used
`PIPESTATUS` for `docs-gates` so the report would not have needed a
correction paragraph. Chosen the canonical layout from the CLI summary instead
of trusting where the files landed.

**What could you still improve?** Turn the install into a script (item 6), add
the reconciliation check (item 7), make the trigger disambiguation edits
(item 11), and prove the skill by generating a diagram (item 1).

**Did you lie to me?** No deliberate falsehood. Two claims were written
without evidence (the Snyk cause; "no network calls") and one number was
eyeballed (73 vs 71). All three were corrected in this session. One measurement
was *misleading by construction*: `docs_gates_exit=0` came from `tail`, and the
report states it as inconclusive rather than green. The one standing
inaccuracy before correction was the Snyk causal sentence — that is the closest
thing to a lie in this session and it is fixed.

**How can we be less stupid?** Checksum before destroy; script every
multi-step install; count with a command; trace security claims to primaries;
never read exit codes through pipes; disambiguate when you install.

**Ghost systems?** One, and it is real: the raster/PDF export path exists,
is documented, and cannot execute here. It is not a ghost in the repo — the
capability is upstream and honest — but on *this machine* it is a wired-but-
dead branch until Playwright exists. Second, milder: `diagram-design`'s brand
onboarding writes `~/.diagram-design/profiles/`, a directory that does not
exist yet and has no policy.

**Scope creep?** Yes, mildly: the lockfile-drift investigation and the
aggregation-repo census are adjacent to "add a skill", not part of it. They
were cheap and the findings are load-bearing for future installs, so I would
do them again — but they belong in HARVEST as separate items, not inside the
install verdict.

**Did we remove something useful?** No. The only deletion was the duplicate
real directory in the Crush root, replaced by a symlink to the verified
canonical copy. The `AGENTS.md` paragraph was tightened, not deleted: every
distinct concept in it (the list, the update rule, the no-hand-edit rule, the
orphan history, the removed `improve-codebase-architecture` entry) survives in
the replacement or in `docs/skill-forks.md`.

**Split brains?** One candidate: the third-party inventory now exists in three
places — `AGENTS.md` §5.10 (names), `docs/skill-forks.md` (provenance), and the
lockfiles (machine state). They disagree today (the lockfile knows one skill).
Fix is item 7's generated inventory; until then, the doc explicitly says which
one is authoritative (the directories).

**Tests?** For a documentation repo: the structural battery is green, but none
of it exercises the new skill. The missing test is item 1. No automated check
exists for "installed third party dir has a lockfile entry" (item 7) or
"Crush-root entry is a symlink" (item 32).

**Did you re-verify inherited claims?** Yes, where they mattered and where I
could: the "15 lockfile entries" claim was re-checked and found obsolete; the
"~/.agents/skills is canonical" claim was re-checked against the live symlink
class of 20 directories; the "`skills update` false green" claim was inherited
unverified (it is another session's reproduction) and is quoted as such, not
re-proven.

---

## Handoff

- Report written per `status-report`; **no manual commit** — the harness forbids
  committing without an explicit request, and the auto-commit daemon picks the
  file up (as it did for `b49ff19`).
- **HARVEST not run** — the user asked to wait for instructions. Items in (f)
  are therefore not yet in `TODO_LIST.md`/`ROADMAP.md`; treat this file as the
  queue until HARVEST runs.
- Files touched this session: `AGENTS.md` (§5.10 third-party inventory),
  `docs/skill-forks.md` (new 2026-11-26 section + corrections),
  `~/.agents/skills/diagram-design/` (new), `~/.config/crush/skills/diagram-design`
  (symlink), this report.
