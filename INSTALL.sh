#!/usr/bin/env bash
# INSTALL.sh — non-destructive installer for Mac/Linux.
#
# Comentario en español: este installer NO sobreescribe configs existentes.
# Hace deep-merge de settings.json, usa marcadores en CLAUDE.md, y aplica
# no-clobber en rules/. Si tenés tu propio agents/, skills/, commands/, no
# se tocan. Backup automático antes de cualquier cambio.

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_DIR="$REPO_DIR/claude-config"
readonly TOOLS_DIR="$REPO_DIR/tools"
readonly TARGET_DIR="$HOME/.claude"
readonly BACKUP_DIR="$HOME/.claude.backup.$(date +%Y-%m-%d-%H%M%S)"
readonly VERSION="$(cat "$REPO_DIR/VERSION" 2>/dev/null || echo "unknown")"

log()   { printf "  %s\n" "$*"; }
ok()    { printf "  \033[32m✅\033[0m %s\n" "$*"; }
warn()  { printf "  \033[33m⚠️\033[0m  %s\n" "$*"; }
err()   { printf "  \033[31m❌\033[0m %s\n" "$*"; }
info()  { printf "  \033[36mℹ️\033[0m  %s\n" "$*"; }

echo ""
echo "🔧 Installing claude-config v${VERSION} (non-destructive merge)"
echo ""

if [[ ! -d "$SOURCE_DIR" ]]; then
  err "Source dir not found: $SOURCE_DIR"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  err "Node.js required for safe merge. Install: https://nodejs.org/"
  exit 1
fi

# 1. Backup
if [[ -d "$TARGET_DIR" ]]; then
  log "Backing up existing $TARGET_DIR → $BACKUP_DIR"
  cp -R "$TARGET_DIR" "$BACKUP_DIR"
  ok "Backup created"
else
  log "Fresh install — no existing ~/.claude/"
  mkdir -p "$TARGET_DIR"
fi

# 2. CLAUDE.md (marker-based merge)
log "Merging CLAUDE.md (marker-based)..."
node "$TOOLS_DIR/merge-claude-md.js" "$TARGET_DIR/CLAUDE.md" "$SOURCE_DIR/CLAUDE.md" 2>&1 | sed 's/^/    /'

# 3. settings.json (deep merge)
log "Merging settings.json (deep merge)..."
if [[ -f "$TARGET_DIR/settings.json" ]]; then
  node "$TOOLS_DIR/merge-settings.js" "$TARGET_DIR/settings.json" "$SOURCE_DIR/settings.json" 2>&1 | sed 's/^/    /'
else
  cp "$SOURCE_DIR/settings.json" "$TARGET_DIR/settings.json"
  ok "settings.json: created (no existing user file)"
fi

# 4. rules/ (no-clobber: never overwrite user's same-named files)
log "Installing rules/ (no-clobber)..."
mkdir -p "$TARGET_DIR/rules"
skipped_rules=()
added_rules=0
while IFS= read -r -d '' src; do
  rel="${src#$SOURCE_DIR/rules/}"
  dst="$TARGET_DIR/rules/$rel"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]]; then
    if ! cmp -s "$src" "$dst"; then
      skipped_rules+=("$rel")
    fi
  else
    cp "$src" "$dst"
    added_rules=$((added_rules + 1))
  fi
done < <(find "$SOURCE_DIR/rules" -type f -print0)
ok "rules/: $added_rules new files added"
if [[ ${#skipped_rules[@]} -gt 0 ]]; then
  warn "rules/: ${#skipped_rules[@]} files differ from yours — kept yours:"
  for r in "${skipped_rules[@]}"; do echo "       - $r"; done
  info "  To force overwrite a specific rule, run: cp $SOURCE_DIR/rules/<file> $TARGET_DIR/rules/<file>"
fi

# 5. scripts/ (always overwrite — these are tooling, not user content)
log "Installing scripts/ (overwrite)..."
mkdir -p "$TARGET_DIR/scripts"
cp -R "$SOURCE_DIR/scripts/." "$TARGET_DIR/scripts/"
chmod +x "$TARGET_DIR/scripts/"*.js 2>/dev/null || true
ok "scripts/: installed"

# 6. templates/ (no-clobber)
log "Installing templates/ (no-clobber)..."
mkdir -p "$TARGET_DIR/templates"
template_added=0
template_skipped=0
while IFS= read -r -d '' src; do
  rel="${src#$SOURCE_DIR/templates/}"
  dst="$TARGET_DIR/templates/$rel"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]]; then
    template_skipped=$((template_skipped + 1))
  else
    cp "$src" "$dst"
    template_added=$((template_added + 1))
  fi
done < <(find "$SOURCE_DIR/templates" -type f -print0)
ok "templates/: $template_added new files, $template_skipped existing files preserved"

# 7. CLAUDE.local.md scaffold (only if it doesn't exist)
if [[ ! -f "$TARGET_DIR/CLAUDE.local.md" ]]; then
  cat > "$TARGET_DIR/CLAUDE.local.md" <<'EOF'
# Personal — local-only (NOT pushed to repo)

> This file is gitignored. Add your personal identity, tone, language preferences,
> or project context here. Survives UPDATE.sh.

## Identity
- Name: <your-name>

## Conversation tone
- <your preferences>
EOF
  ok "CLAUDE.local.md: scaffold created (edit it with your personal config)"
else
  ok "CLAUDE.local.md: preserved (your existing file untouched)"
fi

# 8. Verify
echo ""
log "Running verification..."
if [[ -f "$REPO_DIR/tests/verify-install.sh" ]]; then
  bash "$REPO_DIR/tests/verify-install.sh" || warn "Verification reported issues — review above"
fi

# 9. Summary
echo ""
ok "claude-config v${VERSION} installed (non-destructive)"
echo ""
echo "  📂 Backup:        $BACKUP_DIR"
echo "  📂 Active config: $TARGET_DIR"
echo ""
echo "  Preserved untouched:"
echo "    - agents/, skills/, commands/, plugins/, sessions/, cache/"
echo "    - history.jsonl, credentials.json, CLAUDE.local.md"
echo "    - any rules/ files that already existed (with different content)"
echo ""
echo "  Merged safely:"
echo "    - CLAUDE.md (only block between <!-- claude-config:start/end --> markers)"
echo "    - settings.json (hooks ∪ permissions ∪ plugins ∪ user keys)"
echo ""
echo "  Next: open Claude Code in any project. Cascade audit runs automatically."
