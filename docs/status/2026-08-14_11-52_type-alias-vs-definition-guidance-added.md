# Status Report — 2026-08-14 11:52 — Type Alias vs Definition Guidance Added to how-to-golang

> Session focus: User hit a Go `type Alias = X` vs `type Alias X` confusion in `/home/lars/projects/httputil`. Asked which skill to improve. We added a guidance section to `how-to-golang`.

---

## a) FULLY DONE

1. **Identified the correct skill** — `how-to-golang` is the Go decision guide ("go code style", "go rules"). The alias-vs-definition distinction is a Go language/type-system concept, so this is the right home.
2. **Read the SKILL.md and references directory** — Confirmed `domain-types.md` already uses a type alias (`type UserID = id.ID[UserBrand, nanoid.NanoID]`) in the branded ID pattern without explaining the distinction.
3. **Read `domain-types.md` and `rules.md`** — Confirmed neither file covers the alias-vs-definition distinction.
4. **Added a "Type alias (`=`) vs type definition (no `=`)" section** to the canonical `how-to-golang/references/domain-types.md` (project repo path) containing:
   - A comparison table (kind, identity, method inheritance, assignability)
   - "When to use a type alias" section with 3 use cases
   - "When to use a type definition" section with 3 use cases
   - Two "common mistake" examples, including a real-world middleware example derived from the actual `/home/lars/projects/httputil` issue
   - A one-line decision rule and a diagnostic heuristic
5. **Investigated the actual httputil mistake** — The issue was `type Middleware func(http.Handler) http.Handler` (definition) in both `httputil/recorder.go` and `server_timing/middleware.go`, creating two distinct types that required explicit `Middleware(...)` conversions. The fix changes both to aliases (`type Middleware = func(http.Handler) http.Handler`). `DOMAIN_LANGUAGE.md` also incorrectly called the definition an "alias".
6. **Resolved the source-of-truth confusion** — Discovered that `~/.config/crush/skills/how-to-golang` is a symlink to `/home/lars/.agents/skills/how-to-golang`, and that the canonical source is `/home/lars/projects/SKILLS/`. Copied the updated `domain-types.md` from `.agents` back to the project repo so the change is tracked in git.
7. **Verified sync** — `diff -rq` shows `how-to-golang/` is now identical between project repo and `.agents`. `git status` shows the expected single modified file.
8. **Ran `scripts/check-skills.sh`** — All 25 skills pass structural checks. No regressions.

---

## b) PARTIALLY DONE

1. **Guidance is written but NOT verified against a Go compiler.** Every claim in the table (method inheritance, assignability, conversion requirements) is based on my knowledge of the Go spec, not on actual compilation. A small test program would confirm or refute each claim.
2. **Guidance exists in one reference file but is NOT discoverable from the SKILL.md entrypoint.** The SKILL.md has decision trees for ID types, caches, validation, JSON, testing, and security — but no decision tree or pointer for "alias vs definition". An agent that loads only the SKILL.md body (not the domain-types reference) would still miss this.
3. **The SKILL.md description does NOT include trigger phrases for this topic.** Words like "type alias", "type definition", "`type X = Y`" are absent. An agent encountering the exact question might not trigger the skill at all — it relies on the generic "go code style" / "go rules" triggers being broad enough.

---

## c) NOT STARTED

1. **No Go compilation verification** — Did not write or run a test program to verify the claims.
2. **No decision tree entry in SKILL.md** — The "Decision Trees" section has no entry for alias-vs-definition.
3. **No trigger phrase update in SKILL.md description** — The `description` frontmatter doesn't mention type aliases or type definitions.
4. **No cross-reference to `go-error-modernization`** — The alias-vs-definition distinction is critical for error types: `errors.As`/`errors.Is`/`errors.AsType` behavior depends on whether an error type is an alias or a definition. The section mentions `errors.As`/`errors.Is` in the intro but doesn't link to the `go-error-modernization` skill.
5. **No cross-reference to `data-model-review`** — That skill covers type design and "make impossible states unrepresentable". The alias-vs-definition choice is a type design decision. No link was added.
6. **No check of `architecture.md`** for overlap or conflict — `rules.md` says `architecture.md` covers "Strong types only" and "No `any`, no primitives for domains". The new section might overlap or conflict with content there. Not checked.
7. **No check of other skills/references** for the same alias/definition confusion — Other Go skills (`go-modularize`, `samber-do-best-practices`, `go-error-modernization`) might use type aliases or definitions in examples without explanation.
8. ~~**No feedback file created** — Per the AGENTS.md feedback loop, this kind of "I had an issue, what skill should we improve" interaction is feedback-worthy. Though since we immediately improved the skill, the feedback was already converted to action, so a feedback file may be unnecessary.~~ **Won't implement — feedback was immediately converted into the skill improvement — the loop already served its purpose.**

---

## d) TOTALLY FUCKED UP

~~1. **Did NOT look at the actual httputil issue.**~~ — **FIXED.** Read the httputil code. The issue was: `type Middleware func(http.Handler) http.Handler` (definition) in both `recorder.go` and `server_timing/middleware.go` created two distinct types, requiring explicit `Middleware(servertiming.ServerTimingMiddleware())` conversions at every composition boundary. The fix (uncommitted) changes both to aliases (`type Middleware = func(http.Handler) http.Handler`), eliminating all conversion friction. `DOMAIN_LANGUAGE.md` also incorrectly called the definition an "alias" — the docs lied about what it was. The guidance section has been updated with this real-world middleware example.

1. ~~**File paths were wrong in the original report.** I initially claimed the edit was in `/home/lars/.config/crush/skills/how-to-golang/references/domain-types.md`. That path is a symlink (`~/.config/crush/skills/how-to-golang -> ../../../.agents/skills/how-to-golang`) that resolves to `/home/lars/.agents/skills/how-to-golang/references/domain-types.md`. The **canonical source of truth** is `/home/lars/projects/SKILLS/how-to-golang/references/domain-types.md`. I have now copied the change to the canonical project repo; git status shows `M how-to-golang/references/domain-types.md`. The `.agents` copy is a runtime installation used by Crush, not the source repo.~~ done at `6efb022`

2. ~~**~/.config/crush/.agents does not exist.** The user asked to compare `/home/lars/.config/crush/.agents` to `/home/lars/projects/SKILLS`. The actual installed skills live at `/home/lars/.agents/skills/` (not under `.config/crush`). Crush accesses them through symlinks in `~/.config/crush/skills/`.~~ done at `6efb022`

3. ~~**The project repo and `.agents` copy are NOT fully in sync.** After syncing `how-to-golang`, I compared every skill directory. Many other skills differ between the project repo and `.agents` — including `code-quality-scan`, `docs-health`, `nix-private-go-repos`, `nix-review`, `verify-external-claims`, and `website-launch`. This means `.agents` is lagging behind the project repo. This is expected if skills are installed/copied from the repo periodically, but it's a source of truth problem: an agent editing `.agents` directly would lose changes when the repo is re-installed.~~ done at `6efb022`

4. ~~**No sync script exists.** `scripts/check-skills.sh` and `scripts/sync-html-kit.sh` exist, but there is no `scripts/sync-to-agents.sh` or equivalent. The `.agents` copy must be updated manually or via the `skills` CLI. This is a process gap worth documenting.~~ done at `b83a729`, `6efb022`

5. **Missing important nuances in the guidance section.** The comparison table and examples are correct for the common cases but miss several important subtleties:

   - **Underlying type operations ARE preserved for type definitions.** The table says methods are not inherited (correct), but doesn't mention that arithmetic operators (`+`, `-`, `*`), comparison operators (`==`, `<`), and other built-in operations ARE available on `type MyInt int` because they operate on the underlying type. This is a key difference from methods.
   - **Untyped constants can be assigned to type definitions without conversion.** `var x MyInt = 5` works even though `var x MyInt = intVar` does not. This is a common source of confusion.
   - **Interface satisfaction is NOT inherited.** `type MyReader io.Reader` does NOT satisfy `io.Reader` because it has no methods. This is one of the most common alias-vs-definition mistakes and it's completely absent from the guidance.
   - **`reflect` behavior differs.** Type aliases produce identical `reflect.Type` values; type definitions produce distinct ones. This matters for serialization, ORM mapping, and any reflection-based code.
   - **Embedding vs aliasing** — not mentioned at all. `type Foo struct { time.Time }` (embedding) vs `type Foo = time.Time` (alias) vs `type Foo time.Time` (definition) are three very different things.

6. **The "common mistake: definition where alias is needed" example may be slightly misleading.** It claims `type UserID id.ID[UserBrand, nanoid.NanoID]` would lose all methods. This is correct per the Go spec (type definitions have empty method sets), but the example doesn't mention that you CAN re-declare methods on the new type — it's just tedious. The guidance implies it's impossible rather than impractical.

---

## e) WHAT WE SHOULD IMPROVE

1. **Verify all Go claims with actual compilation.** Write a small test program that demonstrates each claim in the table. This is the `verify-external-claims` principle applied to our own work.

2. **Add interface satisfaction guidance.** The "type definition from an interface" case is one of the most common and dangerous mistakes. It should be a prominent "common mistake" example.

3. **Add a decision tree entry in SKILL.md.** Something like:
   ```
   ### Choosing alias vs definition
   - Same type, interchangeable → type alias (`type X = Y`)
   - Distinct type, compile-time safety → type definition (`type X Y`)
   - See [./references/domain-types.md](references/domain-types.md#type-alias--vs-type-definition-no-)
   ```

4. **Add trigger phrases to the SKILL.md description.** Include "type alias", "type definition", "type X = Y", "when to use type alias".

5. **Cross-reference `go-error-modernization`.** Error types are a domain where the alias-vs-definition distinction is critical. Add a note in both skills.

6. **Fix `DOMAIN_LANGUAGE.md` in httputil.** It incorrectly calls `type Middleware func(http.Handler) http.Handler` an "alias" when it was a definition. The docs should match the code.

7. ~~**Address the .agents source-of-truth gap.** There is no automated way to sync `/home/lars/projects/SKILLS/` to `/home/lars/.agents/skills/`. Agents editing `.agents` directly create changes that are invisible to git. Options:~~ done at `6efb022`
   - Add a `scripts/sync-skills-to-agents.sh` script that rsyncs/copies the repo to `.agents`
   - Document that agents MUST edit `/home/lars/projects/SKILLS/` and that `.agents` is rebuilt from it
   - Add a CI check or pre-commit hook that warns when `.agents` is out of sync

8. ~~**Reconcile existing divergence.** Many skills (`code-quality-scan`, `docs-health`, `nix-private-go-repos`, `nix-review`, `verify-external-claims`, `website-launch`) differ between project repo and `.agents`. Determine if `.agents` should be refreshed from the repo.~~ done at `6efb022`

---

## f) Next Tasks (Up to 50)

| #  | Task                                                                                                       | Impact | Effort |
| -- | ---------------------------------------------------------------------------------------------------------- | ------ | ------ |
| 1  | Write a Go test program verifying every claim in the alias-vs-definition table                             | High   | Low    |
| 2  | Add "interface satisfaction is NOT inherited" common-mistake example to `domain-types.md`                  | High   | Low    |
| 3  | Add "underlying type operations ARE preserved" note to the table or surrounding text                       | High   | Low    |
| 4  | Add "untyped constant assignability" note                                                                  | Medium | Low    |
| 5  | Add `reflect` behavior differences note                                                                    | Medium | Low    |
| 6  | Add a decision tree entry in `how-to-golang/SKILL.md` for alias-vs-definition                              | High   | Low    |
| 7  | Add trigger phrases ("type alias", "type definition") to `how-to-golang/SKILL.md` description              | High   | Low    |
| 8  | Fix `DOMAIN_LANGUAGE.md` in httputil — it calls a type definition an "alias"                               | High   | Low    |
| ~~9~~  | ~~Decide on .agents sync strategy (script, docs, or hook)~~ done at `6efb022` | ~~High~~ | ~~Low~~ |
| ~~10~~ | ~~Refresh `.agents/skills/` from project repo to eliminate current divergence~~ done at `6efb022` | ~~Medium~~ | ~~Medium~~ |
| 11 | Cross-reference `go-error-modernization` skill — error types depend on alias-vs-definition                 | Medium | Low    |
| 12 | Cross-reference `data-model-review` skill — type design decisions                                          | Low    | Low    |
| 13 | Check `how-to-golang/references/architecture.md` for overlap or conflict with new section                  | Medium | Low    |
| 14 | Check other Go skills (`go-modularize`, `samber-do-best-practices`) for alias/definition usage in examples | Low    | Low    |
| 15 | Add embedding-vs-aliasing-vs-definition comparison to `domain-types.md`                                    | Medium | Medium |
| 16 | Clarify that type definitions CAN have methods re-declared (just not inherited)                            | Low    | Low    |
| 17 | Add anchor link (`#type-alias--vs-type-definition-no-`) to any cross-references                            | Low    | Low    |
| 18 | Consider whether the `go-error-modernization` skill needs its own alias-vs-definition section              | Medium | Medium |
| 19 | Run `go vet` / `golangci-lint` on the Go examples in the guidance to catch syntax errors                   | Medium | Low    |
| 20 | Consider adding the alias-vs-definition distinction to the `how-to-write-skills.md` guide as a Go gotcha   | Low    | Low    |

---

## g) Questions I Cannot Answer Myself

1. **~~What was the specific mistake in httputil?~~** — **ANSWERED.** It was a type **definition** where a type **alias** was needed. `type Middleware func(http.Handler) http.Handler` in both `httputil/recorder.go` and `server_timing/middleware.go` created two distinct types, forcing explicit `Middleware(...)` conversions at every composition boundary. The fix is `type Middleware = func(http.Handler) http.Handler` (alias).

2. ~~**Should this guidance live in `domain-types.md` (where I put it) or in `rules.md` (which covers the formal Go rules)?** Both are plausible homes. `domain-types.md` is about branded types and domain primitives; `rules.md` is about development rules. The alias-vs-definition distinction spans both — it's relevant to domain types AND is a general Go rule. Should it be in both with a cross-reference, or in one with a pointer from the other?~~ done (routed to ROADMAP Open Questions — guidance home is a user decision)

3. ~~**Should we also create a dedicated `go-type-design` skill** that covers alias-vs-definition, embedding, generics constraints, interface design, and type-level domain modeling — pulling together content currently scattered across `how-to-golang`, `data-model-review`, and `go-error-modernization`? Or is the current distributed approach (guidance in each skill where it's relevant) better?~~ done (routed to ROADMAP Open Questions — go-type-design skill granularity)

---

## h) Full Skill Corpus Comparison & Sync (additional work)

After resolving the alias-vs-definition issue, the user asked to compare **all**
skills between `/home/lars/projects/SKILLS/` and `/home/lars/.agents/skills/`
and make the project-repo skills superb.

### What was compared

- **Project repo:** `/home/lars/projects/SKILLS/` (git repo, canonical source)
- **Runtime copy:** `/home/lars/.agents/skills/` (accessed via symlink
  `~/.config/crush/skills/<skill> -> ../../../.agents/skills/<skill>`)

### Findings

1. ~~**25 skills in project repo, ~30 in `.agents`.**~~ done at `6efb022` — lockfile split resolved the composition: 25 own (symlinked) + 5 third-party
   `.agents` (not in project repo): `copywriting`, `find-skills`,
   `frontend-design`, `improve-codebase-architecture`, `skill-creator`. These
   appear to be installed skills that were never added to the project repo.
2. ~~**6 skills drifted between project repo and `.agents`:**~~ done at `6efb022` — symlinks replaced copies; drift is now impossible
   `code-quality-scan`, `docs-health`, `nix-private-go-repos`, `nix-review`,
   `verify-external-claims`, `website-launch`. In every case, the **project repo
   was ahead** of `.agents` (local commits had not been refreshed to the runtime
   copy).
3. ~~**No sync script existed.**~~ done at `b83a729` — script created, then superseded by the symlink model (`6efb022`)
   `.agents` in sync with the project repo.

### Actions taken

1. ~~**Created `scripts/sync-skills-to-agents.sh`** with three modes:~~ done at `b83a729` — script later deleted and replaced by `link-skills-to-agents.sh` (`6efb022`)
   - `--list` — show skills that would be synced
   - `--check` — detect drift, exit 1 if runtime is out of sync
   - default — sync project-repo skills to `.agents` via `rsync -a --delete`
2. ~~**Ran the sync.**~~ done at `b83a729` — moot since symlinks (`6efb022`)
   `.agents` counterparts (verified with `diff -rq`).
3. ~~**Fixed broken internal links in skill files:**~~ done at `b83a729`
   - `docs-health/references/build-guide.md`: 7 links pointed to
     `../../assets/` but templates live in `docs-health/assets/`; corrected to
     `../assets/`
   - `website-launch/references/readme-template.md`: replaced placeholder
     `(url)` with `https://github.com/fsnotify/fsnotify`
4. ~~**Improved a weak trigger description:**~~ done at `b83a729`
   - `html-report-kit/SKILL.md`: removed feature-list language ("Provides...")
     and added explicit trigger phrases ("HTML report", "dashboard",
     " Bauhaus design", etc.)
5. ~~**Validated all SKILL.md frontmatter**~~ done at `b83a729` — all 25 skills valid
   skills have valid frontmatter, matching `name:` values, and required
   `description` fields.
6. ~~**Checked for broken internal links**~~ done at `b83a729` — zero broken links after fixes
   after fixes, no broken internal links remain.

### Remaining quality gaps

| # | Gap                                                                           | Priority |
| - | ----------------------------------------------------------------------------- | -------- |
| 1 | `website-launch/SKILL.md` is 797 lines (should be <500)                       | Medium   |
| ~~2~~ | ~~`copywriting`, `find-skills`, `frontend-design`, etc. exist only in `.agents`~~ **Won't implement — resolved 15:04: third-party installs with lockfile sources, intentionally outside this repo.** | ~~Low~~      |
| 3 | Several skills still duplicate the "READ, UNDERSTAND..." footer               | Low      |
| 4 | No empirical trigger testing in Crush                                         | Medium   |
