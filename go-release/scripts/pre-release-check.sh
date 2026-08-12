#!/usr/bin/env bash
# Pre-release gate checker for Go modules.
# Automates Phase 3 (go.mod prep) and Phase 4 (pre-push verification) checks
# from the go-release skill. Run this before creating any release tag.
#
# Usage:
#   ./scripts/pre-release-check.sh          # standard checks
#   ./scripts/pre-release-check.sh --race   # also run tests with -race
#   ./scripts/pre-release-check.sh --lint   # also run golangci-lint if installed

set -euo pipefail

USE_RACE=false
USE_LINT=false

while [[ $# -gt 0 ]]; do
	case "$1" in
	--race)
		USE_RACE=true
		shift
		;;
	--lint)
		USE_LINT=true
		shift
		;;
	-h | --help)
		sed -n '/^#/p' "$0" | head -n -1
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		echo "Usage: $0 [--race] [--lint]" >&2
		exit 1
		;;
	esac
done

fail() {
	echo "❌ FAIL: $1" >&2
	exit 1
}

pass() {
	echo "✅ PASS: $1"
}

# --- Sanity checks ---

[[ -d .git ]] || fail "not a git repository"
[[ -f go.mod ]] || fail "go.mod not found"

pass "inside a git repository with go.mod"

# --- Phase 3: go.mod prep ---

if grep -E '^replace\s+.*=>\s*(\.\./|/|[A-Za-z]:\\)' go.mod >/dev/null 2>&1; then
	fail "go.mod contains local replace directives (=> ../ or absolute path). Remove them before release."
fi
pass "no local replace directives in go.mod"

if grep -E 'v0\.0\.0-00010101000000-000000000000' go.mod >/dev/null 2>&1; then
	fail "go.mod contains pseudo-version placeholders (00010101000000-000000000000)."
fi
pass "no pseudo-version placeholders in go.mod"

if ! git diff --quiet HEAD -- go.mod go.sum; then
	fail "go.mod or go.sum has uncommitted changes"
fi
pass "go.mod and go.sum are clean"

# --- Phase 4: verification ---

if ! git diff --quiet HEAD; then
	fail "working tree has uncommitted changes"
fi
pass "working tree is clean"

if ! git diff --cached --quiet; then
	fail "staging area has uncommitted changes"
fi
pass "staging area is clean"

echo ""
echo "Running go mod tidy..."
if ! go mod tidy; then
	fail "go mod tidy failed"
fi
pass "go mod tidy succeeded"

if ! git diff --quiet HEAD -- go.mod go.sum; then
	fail "go mod tidy changed go.mod or go.sum; commit the changes before tagging"
fi
pass "go.mod and go.sum are unchanged after go mod tidy"

echo ""
echo "Running go mod verify..."
if ! go mod verify; then
	fail "go mod verify failed (go.sum mismatch)"
fi
pass "go.sum is consistent"

echo ""
echo "Running go build ./..."
if ! go build ./...; then
	fail "go build ./... failed"
fi
pass "go build ./... succeeded"

echo ""
if [[ "$USE_RACE" == true ]]; then
	echo "Running go test -race -count=1 ./..."
	if ! go test -race -count=1 ./...; then
		fail "go test -race ./... failed"
	fi
	pass "go test -race ./... succeeded"
else
	echo "Running go test ./..."
	if ! go test ./...; then
		fail "go test ./... failed"
	fi
	pass "go test ./... succeeded"
fi

echo ""
echo "Running go vet ./..."
if ! go vet ./...; then
	fail "go vet ./... failed"
fi
pass "go vet ./... succeeded"

if [[ "$USE_LINT" == true ]]; then
	if command -v golangci-lint >/dev/null 2>&1; then
		echo ""
		echo "Running golangci-lint run..."
		if ! golangci-lint run; then
			fail "golangci-lint found issues"
		fi
		pass "golangci-lint passed"
	else
		fail "--lint requested but golangci-lint is not installed"
	fi
fi

echo ""
echo "🎉 All pre-release checks passed. The repository is ready for tagging."
echo "Next steps: choose the version bump, update CHANGELOG, and run git tag -a vX.Y.Z."
