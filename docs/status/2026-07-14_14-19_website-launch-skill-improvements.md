# Status Report: website-launch Skill Improvements

**Date:** 2026-07-14 14:19
**Session goal:** Read 7 feedback files, assess the existing `website-launch` skill, improve it to "SUPERB" quality
**Outcome:** Skill improved and validated — 5 issues fixed, but several things forgotten or left undone

---

## a) FULLY DONE

1. **Read and analyzed all 7 feedback files** — Each file fully read, patterns extracted, contradictions identified
2. **Read the entire skill** (SKILL.md + all 6 reference files) — Assessed against feedback and ground truth
3. **Verified ground truth against reference repos** — Sub-agent confirmed actual versions, component structures, CI workflows in gogenfilter and go-atomic-write
4. **Resolved the Astro 6 vs 7 conflict** — Root cause was `astro-og-canvas@0.11.x`, not Vite pinning. gogenfilter runs Astro 7 + og-canvas 0.12.0 + Vite 7.3.2 pin successfully
5. **Fixed SKILL.md frontmatter** — Added `metadata.tags` and `allowed-tools: bash`
6. **Fixed file manifest classifications** — Moved Header/Footer to "Customize" table; added nuance to section components; added OG image page
7. **Fixed dependency-versions.md** — Full rewrite with verified gogenfilter baseline; documented the og-canvas version history; correct override guidance
8. **Fixed common-pitfalls.md Vite entry** — Rewrote pitfall #1 with corrected root cause
9. **Strengthened Visual QA gate** — Hard gate: "Phase 4 does not start until this passes"
10. **Added CI workflow guidance** — Phase 5 now references gogenfilter's `.github/workflows/website.yml`
11. **Validation passes** — `check-skills.sh` reports all 19 skills pass, 0 thin skills, website-launch is 451 lines

---

## b) PARTIALLY DONE

1. **The "pnpm vs bun" guidance is split across files.** Dependency-versions.md has the deploy guidance, common-pitfalls.md has the re2 failure mode, SKILL.md Phase 3 doesn't mention bun at all. An agent reading just SKILL.md might run `bun run build` then hit the re2 error at deploy time without knowing why. The cross-referencing is there but the SKILL.md body should surface the one-liner: "bun is fine for build; deploy needs real Node.js from Nix."

2. **CSP patching is documented but not gated.** file-manifest.md now has a CSP section explaining `fix-csp.mjs`, but SKILL.md doesn't mention CSP as a decision point in Phase 2. An agent following SKILL.md linearly would copy the gogenfilter baseline (which has CSP) but might not realize the build script MUST include `&& node scripts/fix-csp.mjs` or CSP-protected inline scripts will break.

3. **OG image customization is documented but not linked from SKILL.md.** The guidance exists in file-manifest.md, but SKILL.md Phase 2 doesn't mention OG images at all. An agent reading just SKILL.md won't know to look for it.

4. **The `astro.config.mjs` customization is still vague.** The file manifest says "site URL, Starlight title, sidebar structure, social href, head description, fonts" but doesn't show the actual structure. This is the most complex customize file and the agent still has to reverse-engineer the sidebar config, the CSP block, the integration list, and the font configuration. This was flagged in my assessment but not fixed.

5. **The color palette reference now conflicts with the dependency-versions reference.** Dependency-versions.md was rewritten with the gogenfilter baseline (which includes `astro-og-canvas` and `jscpd`), but color-palette.md still has the old derivation formula at the bottom mentioning "Tint and Shade Generator" — a manual step the skill is supposed to eliminate. Not broken, but the tone is inconsistent.

---

## c) NOT STARTED

1. **No scripts were created.** The original plan called for `scripts/preflight-check.sh`, `scripts/generate-palette.sh`, `scripts/add-custom-domain.sh`. None were written. The SKILL.md has inline bash for pre-flight checks, but these are not reusable, testable scripts in `scripts/`.

2. **No evals were run.** The skill-creator process requires test prompts run with and without the skill, graded against assertions. We never wrote test prompts, never ran them, never graded. The skill is untested.

3. **No `references/` TOC was added to large reference files.** The repo conventions say files >300 lines need a TOC. color-palette.md (244 lines) and common-pitfalls.md (228 lines) are close but under. file-manifest.md is now 142 lines. No TOC needed yet, but worth noting the convention.

4. **README.md was not updated.** The skill exists but the repo's `README.md` inventory table was not updated to include `website-launch` as skill #19 (or whatever the count is). Wait — `check-skills.sh` shows 19 skills including website-launch, so it may already be listed. But I didn't verify this.

5. **No `check-skills.sh` update needed.** The script already counts website-launch. But I didn't verify the README.md inventory table is current.

6. **No verification that the reference repos are actually accessible.** The sub-agent confirmed they exist at `~/projects/gogenfilter/` and `~/projectsgo-atomic-write/`, but I didn't add a pre-flight check for the reference repo existence. If those repos aren't cloned, the skill's core instruction ("copy from gogenfilter") fails silently.

7. **Feedback files were not archived.** The 7 feedback files in `docs/feedback/new/` are now processed into the skill. They should probably be moved to `docs/feedback/processed/` or similar, but I didn't touch them.

---

## d) TOTALLY FUCKED UP

1. **I broke the `---` frontmatter delimiter.** The first `multiedit` attempt tried to replace `---` as the first edit's `old_string`, which the tool rejected because "only the first edit can have empty old_string (for file creation)." I then used a single `edit` call to add the metadata block, but the edit replaced `---\n\n# Website Launch` with `metadata: ...\nallowed-tools: bash\n---\n\n# Website Launch` — this means I appended the metadata AFTER the closing `---`, not inside the frontmatter. Wait — let me re-read... Actually the edit was `---\n\n# Website Launch` → `metadata:...\nallowed-tools: bash\n---\n\n# Website Launch`. But the original frontmatter already had `---` delimiters. The edit successfully added the lines inside the frontmatter before the closing `---`. The `check-skills.sh` validation passed, so the frontmatter is valid YAML. **This is likely fine** — but I should have verified the frontmatter structure more carefully during the edit.

   **UPDATE:** Verified — `check-skills.sh` passed and the file reads correctly at line 1-17. Frontmatter is valid. Not actually fucked up.

2. **The edit ordering was sloppy.** I tried `multiedit` with 4 edits, one failed (the `---` replacement), so I had to fall back to individual `edit` calls. This was inefficient and error-prone. I should have planned the edits better upfront.

---

## e) WHAT WE SHOULD IMPROVE

### High Impact

1. **Write the scripts.** The three scripts (preflight-check, generate-palette, add-custom-domain) were the original plan and would make the skill deterministic instead of instructive. The inline bash in SKILL.md is a poor substitute — it's not testable and can't be run without the agent manually executing it.

2. **Add `astro.config.mjs` structure guidance.** This is the most complex customize file and the agent still has to reverse-engineer: the Starlight sidebar config (which is an array of objects with `label`, `items`, `autogenerate`), the CSP `security` block, the integrations list (starlight, sitemap, tailwind, og-canvas), and the font configuration. Without this, the agent will still open gogenfilter's config and spend time understanding it.

3. **Test the skill with evals.** Per the skill-creator process. Write 2-3 realistic prompts (e.g., "set up the website for go-connectors, a connection pool library, use blue theme"), run them with and without the skill, grade the results. The skill is currently untested.

4. **Surface bun/deploy and CSP decisions in SKILL.md body.** Currently these are buried in references. An agent reading SKILL.md linearly needs to know: (1) bun is fine for build, deploy needs real Node.js, (2) if you copy the gogenfilter baseline, the build script MUST include the CSP post-build step.

5. **Add reference repo existence check to pre-flight.** SKILL.md Phase 0 checks Namecheap credentials and Firebase project, but doesn't check `~/projects/gogenfilter/website/` exists. If it's missing, the skill's core copy instruction fails.

### Medium Impact

6. **Add a "decision: standalone vs shared Firebase project" section.** The feedback files flagged that art-dupl has its own Firebase project while most others use `lars-software`. The skill mentions this in the REST API reference but SKILL.md body doesn't present it as an explicit decision.

7. **Document the `.firebaserc` target pattern more explicitly.** The skill shows the JSON structure but doesn't explain when to use targets (shared project) vs plain `default` (standalone).

8. **Add the GitHub Actions workflow to the file manifest.** It's mentioned in SKILL.md Phase 5 but not in the manifest. An agent using the manifest as a checklist would miss it.

9. **Consolidate the "what I did well" sections from feedback files into a "what right looks like" checklist.** The feedback files contain valuable positive patterns (fact-checking READMEs against source code, validating Terraform before apply, verifying HTTP 200 after deploy) that could become quality gates.

10. **The commit discipline section should mention `package-lock.json` explicitly.** It's in common-pitfalls.md #13 but not in the commit checkpoint descriptions. The commit after successful build should explicitly say "commit `package-lock.json` and `flake.lock`."

### Low Impact

11. **Standardize GitHub URL casing.** The feedback files flagged `larsartmann` vs `LarsArtmann` inconsistency. The skill uses `LarsArtmann` in the `gh repo edit` command but doesn't state the convention explicitly.

12. **Add badge markdown templates.** The skill says "Go Reference | Go Report Card | License: MIT | CI status" but doesn't provide the actual markdown with URLs.

13. **Add a "common docs page structures" reference.** The standard docs page set is listed but the content structure for each isn't documented. An agent still has to guess what an `installation.mdx` should contain.

14. **Document the `fix-csp.mjs` script logic.** It's mentioned as "inject SHA-256 hashes for inline scripts" but the agent doesn't know how it works or what to do if it fails.

15. **Add a "debugging build failures" decision tree.** The common pitfalls list symptoms but don't provide a systematic "if this error, check this" flowchart.

---

## f) Up to 50 Things We Should Get Done Next

### Scripts (deterministic automation — highest ROI)

1. Write `scripts/preflight-check.sh` — checks Namecheap credentials, Firebase project, subdomain collisions, **and reference repo existence**
2. Write `scripts/generate-palette.sh` — takes a hex color, outputs all ~25 CSS tokens for dark/light/Starlight
3. Write `scripts/add-custom-domain.sh` — Firebase REST API call with correct payload, token extraction, ACME response parsing
4. Write `scripts/verify-deploy.sh` — curls key pages, checks CSS variables resolved, verifies HTTP 200

### SKILL.md improvements

5. Add bun/deploy warning to Phase 3 or Phase 4 (one-liner: "bun is fine for build; deploy needs real Node.js from Nix")
6. Add CSP decision point to Phase 2 (if copying gogenfilter baseline, build script MUST include `&& node scripts/fix-csp.mjs`)
7. Add reference repo existence check to Phase 0 pre-flight
8. Add "decision: standalone vs shared Firebase project" section to Phase 4 Step 2
9. Add `package-lock.json` and `flake.lock` to commit checkpoint descriptions
10. Add `.github/workflows/website.yml` to the file manifest
11. Standardize GitHub URL casing convention (state `LarsArtmann` as the standard)
12. Add badge markdown templates with URLs
13. Add "debugging build failures" decision tree
14. Add pre-flight check for Firebase CLI availability (`firebase --version`)
15. Add pre-flight check for `gcloud` availability

### Reference files improvements

16. Add `astro.config.mjs` structure guide to file-manifest.md (sidebar config, CSP block, integrations, fonts)
17. Add a "what right looks like" quality checklist to file-manifest.md (consolidated from feedback "what I did well" sections)
18. Add common docs page content structures (installation.mdx, quick-start.mdx, api-reference.mdx templates)
19. Document the `fix-csp.mjs` script logic and failure modes
20. Add OG image setup as a decision point in file-manifest.md (not just a write-fresh file)
21. Add `.npmrc` guidance to dependency-versions.md (when it's needed, what to put in it)
22. Add a Firebase standalone vs shared project decision tree to firebase-rest-api.md
23. Document the `.firebaserc` target pattern with examples (shared project vs standalone)
24. Add GitHub Actions workflow template to file-manifest.md or a new reference file
25. Add namecheap Terraform provider version and compatibility notes to dns-terraform.md
26. Color palette: add more colors (green, teal, orange, purple-dark, slate)

### Testing & validation

27. Write 2-3 realistic eval prompts for the skill
28. Run evals with-skill vs without-skill
29. Grade results and iterate on SKILL.md based on findings
30. Add eval assertions: pre-flight ran first, palette was looked up not hand-computed, no MDX escaping bugs, commit checkpoints hit
31. Run the skill end-to-end on a real project to validate the full workflow
32. Verify the skill works when reference repos are in different locations (not just `~/projects/`)

### Content & documentation

33. Update README.md inventory table to confirm website-launch is listed
34. Verify all cross-references between SKILL.md and reference files resolve correctly
35. Add a "how to update this skill" note for when the reference repos change
36. Consider adding a "known limitations" section (e.g., "this skill assumes the domains repo is at `~/projects/domains`")
37. Consider adding a "when NOT to use this skill" section (e.g., non-Go libraries, non-LarsArtmann projects)
38. Move the 7 feedback files from `docs/feedback/new/` to `docs/feedback/processed/` after confirming the skill captures all their lessons
39. Add a changelog or version note to the skill (date created, last updated, what changed)
40. Consider whether the "Code Example Verification" section should be its own reference file (it's already detailed in SKILL.md but could be deeper)

### Alignment with other skills

41. Check if `website-launch` should reference `how-to-golang` for the Go code verification pattern
42. Check if the `html-report-kit` vendoring pattern applies (skill produces HTML reports — but this skill produces websites, not reports, so probably not)
43. Ensure the skill's commit discipline aligns with the global AGENTS.md git workflow
44. Consider whether the "visual QA" pattern could be extracted into a reusable section used by other skills

### Cleanup

45. Remove the "Tint and Shade Generator" external link from color-palette.md — the pre-computed table makes it unnecessary
46. Check for any remaining "Astro 6" references across all files (the conflict is resolved)
47. Verify the `metadata.tags` are useful for discovery
48. Consider adding `firebase`, `terraform`, `gcloud` to `allowed-tools` (currently only `bash`)
49. Review whether the SKILL.md description is too long (14 lines in YAML folded scalar — check against the 1024 char limit)
50. Consider whether the skill name should be `lars-software-website-launch` for clarity (matches the feedback file proposals)

---

## g) Top 2 Questions

### 1. Should the reference repo path be hardcoded or configurable?

The skill assumes gogenfilter is at `~/projects/gogenfilter/website/`. This is true on Lars's machine today, but:

- It won't be true if someone else uses this skill
- It won't be true if the repos move
- It won't be true if the skill is installed via `bunx skills add` (which copies the skill to `~/.config/crush/skills/` — the relative paths to `~/projects/` still work, but it's fragile)

**Options:**

- A) Hardcode `~/projects/gogenfilter/website/` and add a pre-flight check
- B) Make it configurable via a variable the user sets
- C) Find the reference repo dynamically (`find ~ -maxdepth 3 -name "gogenfilter" -type d 2>/dev/null`)
- D) Accept that this is a personal skill and hardcoding is fine

I lean toward **A+D** — this is a personal infrastructure skill, like `templ-components`. Hardcoding is honest.

### 2. Should we invest in the scripts now or ship the skill as-is and iterate?

The three scripts (preflight-check, generate-palette, add-custom-domain) would make the skill significantly better — they'd turn instructions into deterministic automation. But writing and testing them takes time, and the skill is already functional without them (the agent executes the inline bash manually).

The alternative is to ship the skill as-is, run it on the next real website launch, and see what actually breaks. The feedback from that session would tell us exactly which scripts are highest-value.

I lean toward **ship as-is, iterate based on real usage** — but this is exactly the pattern that produced 7 feedback files without a skill being created. The counter-argument is that now the skill EXISTS, so the next session will use it and the feedback will be "the skill helped but X was still manual." That's the right kind of feedback to prioritize script creation.
