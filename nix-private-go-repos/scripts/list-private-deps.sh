#!/usr/bin/env bash
# Identify private LarsArtmann dependencies in the current Go project.
# Run from the project root next to go.mod.

set -euo pipefail

if [ ! -f "go.mod" ]; then
  echo "Error: no go.mod found. Run this script from a Go project root." >&2
  exit 1
fi

private_pattern='github\.com/[Ll]ars[Aa]rtmann'

unique_deps=$(grep -E "${private_pattern}" go.mod | awk '{print $1}' | sed -E 's|/v[0-9]+||' | sort -u)

if [ -z "${unique_deps}" ]; then
  echo "No private LarsArtmann dependencies found in go.mod."
  exit 0
fi

echo "Unique private dependency repos (one flake input per line):"
echo ""
for dep in ${unique_deps}; do
  repo=$(echo "${dep}" | sed -E 's|github\.com/[Ll]ars[Aa]rtmann/||')
  echo "  ${repo} = {"
  echo "    url = \"git+ssh://git@github.com/LarsArtmann/${repo}?ref=master;\""
  echo "    flake = false;"
  echo "  };"
done

echo ""
echo "Add these to the deps map in mkPreparedSource (adjust exact case to match go.mod):"
for dep in ${unique_deps}; do
  echo "  \"${dep}\" = inputs.${dep#github.com/[Ll]ars[Aa]rtmann/};"
done
