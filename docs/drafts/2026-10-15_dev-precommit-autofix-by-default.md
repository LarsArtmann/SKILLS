## Problem

`parseAutoFixConfig` auto-enables `--fix` for dev AND pre-commit modes unless the flag was explicitly passed — `internal/cli/workflow_config_1.go:19`:

```go
if (config.BuildMode.IsPreCommit() || config.BuildMode.IsDev()) && !cmd.Flags().Changed("fix") {
	config.AutoFix = true
	log.Debugf("Auto-enabling --fix for %s mode (use --fix=false to disable)", config.BuildMode)
}
```

So the documented daily driver — a plain `buildflow --build-mode dev` — runs repair steps (go-mod-update, go-mod-normalize, go-fix) against the working tree by default. The only notice is a Debug-level line, invisible in a normal run.

## Live incident

2026-09-27, httputil: a baseline dev run with no `--fix` bumped go-error-family v0.10.1→v0.10.2, rewrote server_timing's `go` directive 1.26→1.27, and go-fix restructured struct literals — all swept into the auto-commit daemon's heuristic commits before anyone read the dependency's release notes. "Verified green afterwards" is not "reviewed". httputil's AGENTS.md now mandates a `git status --short` snapshot before EVERY buildflow invocation; that protocol exists because the default mutates.

Adjacent: #45 (go-mod-update's compile gate silently reverting go.mod/go.sum) is the same family — repair steps acting without informed consent.

## Ask

**Default dev-mode repair steps to dry (findings only), with mutation behind an explicit `--fix`** — mirroring the deliberate contract in `format_cmd.go`, where `AutoFix = true` is set explicitly because formatters always fix. If fix-by-default for dev stays, surface it at Info/Warn with a per-step file-count summary instead of Debugf. Pre-commit fixing (like lint-staged) may be legitimate — but it deserves the same visibility.

💘 Generated with Crush
