#!/usr/bin/env bash
# verify-install.sh — checks that ~/.claude/ has all expected pieces.

set -uo pipefail

readonly TARGET="$HOME/.claude"
fail=0

check() {
  local label="$1" path="$2" expected="$3"
  if [[ -e "$path" ]]; then
    if [[ -n "$expected" ]]; then
      printf "  ✅ %s → %s\n" "$label" "$expected"
    else
      printf "  ✅ %s\n" "$label"
    fi
  else
    printf "  ❌ %s missing: %s\n" "$label" "$path"
    fail=1
  fi
}

count_files() {
  find "$1" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' '
}

count_imports() {
  grep -c "^@" "$1" 2>/dev/null || echo "0"
}

echo ""
echo "🔍 Verifying ~/.claude/ install..."
echo ""

check "CLAUDE.md root" "$TARGET/CLAUDE.md" "$(wc -l < "$TARGET/CLAUDE.md" 2>/dev/null) líneas, $(count_imports "$TARGET/CLAUDE.md") imports"
check "settings.json" "$TARGET/settings.json" ""
check "rules/ directory" "$TARGET/rules" "$(count_files "$TARGET/rules") archivos top-level"
check "rules/stack/" "$TARGET/rules/stack" "$(count_files "$TARGET/rules/stack") stack overlays"
check "scripts/" "$TARGET/scripts" "$(find "$TARGET/scripts" -type f -name '*.js' 2>/dev/null | wc -l | tr -d ' ') scripts"
check "templates/large-project/" "$TARGET/templates/large-project" ""
check "templates/medium-project/" "$TARGET/templates/medium-project" ""
check "templates/small-project/" "$TARGET/templates/small-project" ""
check "templates/monorepo/" "$TARGET/templates/monorepo" ""

# Required rule files
for rule in code-quality-standards no-legacy-rule per-module-claude-md project-detector claude-md-freshness verification-first context-discipline plan-mode-trigger ask-user-question engram-protocol sdd-orchestrator refs-and-routes-tracking; do
  check "rule: $rule.md" "$TARGET/rules/$rule.md" ""
done

# Required scripts
for s in block-sensitive-files auto-format detect-structural-change check-claude-md-freshness; do
  check "script: $s.js" "$TARGET/scripts/$s.js" ""
done

echo ""
if [[ $fail -eq 0 ]]; then
  echo "✅ Setup verified: all components present."
  exit 0
else
  echo "❌ Setup incomplete. Re-run INSTALL.sh."
  exit 1
fi
