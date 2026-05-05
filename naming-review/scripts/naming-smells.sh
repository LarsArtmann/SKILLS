#!/usr/bin/env bash
#
# naming-smells.sh — Automated detection of common naming anti-patterns
#
# Usage:
#   ./naming-smells.sh [path]           # Scan path (default: .)
#   ./naming-smells.sh --lang go [path] # Limit to Go files
#   ./naming-smells.sh --lang ts [path] # Limit to TypeScript files
#
# Requires: rg (ripgrep) — install via your package manager
#
# This script detects patterns that linters often miss:
# - Vague type names (Data, Info, Record, Item, Object, Thing)
# - Manager/Handler/Processor/Helper/Util classes
# - Impl/Concrete/Default suffixes
# - I-prefix interfaces outside C#
# - Hungarian notation remnants
# - Boolean non-question names
# - Abstract/Base prefixes
# - Number-suffixed variables

set -euo pipefail

PATH_TO_SCAN="${1:-.}"
LANG_FILTER=""
RIPGREP_OPTS="--no-heading --with-filename --line-number --sort path"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang)
            LANG_FILTER="$2"
            shift 2
            ;;
        *)
            PATH_TO_SCAN="$1"
            shift
            ;;
    esac
done

# Language-specific file patterns
case "$LANG_FILTER" in
    go)  TYPE_GLOB="-g *.go" ;;
    ts)  TYPE_GLOB="-g *.ts -g *.tsx" ;;
    py)  TYPE_GLOB="-g *.py" ;;
    rs)  TYPE_GLOB="-g *.rs" ;;
    java) TYPE_GLOB="-g *.java" ;;
    cs)  TYPE_GLOB="-g *.cs" ;;
    *)   TYPE_GLOB="" ;;
esac

SMELL_COUNT=0

smell_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════════════"
}

run_pattern() {
    local description="$1"
    local pattern="$2"
    local severity="$3"
    local count

    count=$(rg $TYPE_GLOB $RIPGREP_OPTS "$pattern" "$PATH_TO_SCAN" 2>/dev/null | head -30 | wc -l)

    if [[ "$count" -gt 0 ]]; then
        SMELL_COUNT=$((SMELL_COUNT + count))
        echo ""
        echo "  [$severity] $description"
        echo "  Pattern: $pattern"
        echo "  Matches: $count"
        echo "  ─────────────────────────────────────────────────────────"
        rg $TYPE_GLOB $RIPGREP_OPTS "$pattern" "$PATH_TO_SCAN" 2>/dev/null | head -10
    fi
}

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Naming Smell Detector                                       ║"
echo "║  Scanning: $PATH_TO_SCAN"
echo "╚═══════════════════════════════════════════════════════════════╝"

# ── CRITICAL: Lying Names ──────────────────────────────────────────

smell_header "CRITICAL — Lying Names (Manual Review Required)"
echo "  Automated detection is limited for honesty issues."
echo "  These patterns are HEURISTICS — always verify manually."

run_pattern \
    "Getter that may mutate (Go: func get.* that saves)" \
    'func \(.*\) Get\w+.*\{[^}]*\.Save\(' \
    "CRITICAL"

run_pattern \
    "Getter that may mutate (Go: func get.* with db.Save)" \
    'func.*[Gg]et\w+.*db\.\w*[Ss]ave' \
    "CRITICAL"

# ── HIGH: Vague Nouns ──────────────────────────────────────────────

smell_header "HIGH — Vague Type Names (Data, Info, Record, Item)"

run_pattern \
    "Types named *Data (Go)" \
    'type\s+\w*Data\s+struct' \
    "HIGH"

run_pattern \
    "Types named *Info (Go)" \
    'type\s+\w*Info\s+struct' \
    "HIGH"

run_pattern \
    "Types named *Record (Go)" \
    'type\s+\w*Record\s+struct' \
    "HIGH"

run_pattern \
    "Classes named *Data (TypeScript)" \
    '(class|interface|type)\s+\w*Data\b' \
    "HIGH"

run_pattern \
    "Classes named *Info (TypeScript)" \
    '(class|interface|type)\s+\w*Info\b' \
    "HIGH"

run_pattern \
    "Classes named *Record (TypeScript)" \
    '(class|interface|type)\s+\w*Record\b' \
    "HIGH"

run_pattern \
    "Classes named *Data (Python)" \
    'class\s+\w*Data' \
    "HIGH"

run_pattern \
    "Classes named *Info (Python)" \
    'class\s+\w*Info' \
    "HIGH"

# ── HIGH: Manager/Handler/Processor/Helper/Util ────────────────────

smell_header "HIGH — Manager/Handler/Processor/Helper/Util Classes"

run_pattern \
    "Manager classes (Go)" \
    'type\s+\w*Manager\s+struct' \
    "HIGH"

run_pattern \
    "Handler classes (Go)" \
    'type\s+\w*Handler\s+struct' \
    "HIGH"

run_pattern \
    "Processor classes (Go)" \
    'type\s+\w*Processor\s+struct' \
    "HIGH"

run_pattern \
    "Helper/Util classes (Go)" \
    'type\s+\w*(Helper|Util|Utility)\s+struct' \
    "HIGH"

run_pattern \
    "Manager/Handler classes (TypeScript)" \
    'class\s+\w*(Manager|Handler|Processor|Helper|Util|Utility)\b' \
    "HIGH"

run_pattern \
    "Manager/Handler classes (Python)" \
    'class\\s+\\w*(Manager|Handler|Processor|Helper|Util|Utility)\\b' \
    "HIGH"

run_pattern \
    "Manager/Handler structs (Rust)" \
    'struct\\s+\\w*(Manager|Handler|Processor|Helper|Util|Utility)\\b' \
    "HIGH"

# ── MEDIUM: Implementation Leakage ─────────────────────────────────

smell_header "MEDIUM — Implementation Leakage (Impl, Abstract, Base)"

run_pattern \
    "Impl suffix (Go)" \
    'type\s+\w*Impl\s+struct' \
    "MEDIUM"

run_pattern \
    "Impl suffix (TypeScript)" \
    '(class|interface|type)\s+\w*Impl\b' \
    "MEDIUM"

run_pattern \
    "Impl suffix (Python)" \
    'class\s+\w*Impl\b' \
    "MEDIUM"

run_pattern \
    "Impl suffix (Rust)" \
    'struct\s+\w*Impl\b' \
    "MEDIUM"

run_pattern \
    "Abstract prefix (Go)" \
    'type\s+Abstract\w*\s+struct' \
    "MEDIUM"

run_pattern \
    "Abstract prefix (TypeScript)" \
    '(class|interface)\s+Abstract\w*' \
    "MEDIUM"

run_pattern \
    "Abstract prefix (Python)" \
    'class\s+Abstract\w*' \
    "MEDIUM"

run_pattern \
    "Base prefix (Go)" \
    'type\s+Base\w*\s+struct' \
    "MEDIUM"

run_pattern \
    "Base prefix (TypeScript)" \
    'class\s+Base\w*' \
    "MEDIUM"

run_pattern \
    "I-prefix interface (Go — anti-pattern)" \
    'type\s+I[A-Z]\w*\s+interface' \
    "MEDIUM"

run_pattern \
    "I-prefix interface (TypeScript — anti-pattern)" \
    'interface\s+I[A-Z]\w*' \
    "MEDIUM"

run_pattern \
    "I-prefix interface (Python — anti-pattern)" \
    'class\s+I[A-Z]\w*\(.*ABC' \
    "MEDIUM"

run_pattern \
    "I-prefix trait (Rust — anti-pattern)" \
    'trait\s+I[A-Z]\w*' \
    "MEDIUM"

# ── MEDIUM: Boolean Non-Questions ──────────────────────────────────

smell_header "MEDIUM — Boolean Non-Question Names"

run_pattern \
    "Boolean field named 'status' (Go)" \
    '(bool|boolean)\s+status\b' \
    "MEDIUM"

run_pattern \
    "Boolean field named 'flag' (Go)" \
    '(bool|boolean)\s+flag\b' \
    "MEDIUM"

run_pattern \
    "Boolean field named 'check' (Go)" \
    '(bool|boolean)\s+check\b' \
    "MEDIUM"

run_pattern \
    "Boolean named 'status' (TypeScript)" \
    '(status|flag|check)\s*:\s*(boolean|bool)' \
    "MEDIUM"

run_pattern \
    "Boolean named 'status' (Python)" \
    '(status|flag|check)\s*:\s*bool' \
    "MEDIUM"

run_pattern \
    "Boolean named 'status' (Rust)" \
    '(status|flag|check)\s*:\s*bool' \
    "MEDIUM"

# ── MEDIUM: Hungarian Notation ─────────────────────────────────────

smell_header "MEDIUM — Hungarian Notation Remnants"

run_pattern \
    "Hungarian prefix str/int/bool/arr (Go)" \
    '(str[A-Z]\w+|int[A-Z]\w+|bool[A-Z]\w+|arr[A-Z]\w+)\s+' \
    "MEDIUM"

run_pattern \
    "Hungarian prefix str/int/bool (TypeScript)" \
    '(str[A-Z]\w+|int[A-Z]\w+|bool[A-Z]\w+)\s*[:=]' \
    "MEDIUM"

# ── MEDIUM: Number Suffixes ───────────────────────────────────────

smell_header "MEDIUM — Number-Suffixed Variables"

run_pattern \
    "Number-suffixed variables (Go)" \
    '\b\w+2\b\s*(,|\)|\s*[=:]|\s+\*)' \
    "MEDIUM"

run_pattern \
    "Number-suffixed variables (TypeScript)" \
    '\b\w+[0-9]+\b\s*[:=]' \
    "MEDIUM"

# ── Summary ────────────────────────────────────────────────────────

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Summary                                                     ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  Potential naming smells found: $SMELL_COUNT"
echo "║                                                               ║"
echo "║  Next steps:                                                  ║"
echo "║  1. Review each match manually (these are HEURISTICS)        ║"
echo "║  2. Run linters for authoritative naming checks              ║"
echo "║  3. Use the naming-review skill for deep manual analysis      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
