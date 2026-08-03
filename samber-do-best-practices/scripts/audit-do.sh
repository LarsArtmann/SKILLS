#!/usr/bin/env bash
# List all Go files that import samber/do in the current project.
# Run from the project root.

set -euo pipefail

if [ ! -f "go.mod" ]; then
	echo "Error: no go.mod found. Run this script from a Go project root." >&2
	exit 1
fi

# Find files that import any samber/do path (v1, v2, or future versions).
grep -rl 'github.com/samber/do' --include='*.go' . | sort

# Also show a count per module.
echo "---" >&2
echo "Import counts by module path:" >&2
grep -rh 'github.com/samber/do' --include='*.go' . | sort | uniq -c | sort -rn >&2
