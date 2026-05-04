#!/usr/bin/env bash
# INSTALL.sh — installer Mac/Linux para claude-config
#
# Comentario en español: instala el setup en ~/.claude/, hace backup automático,
# verifica que todo cargó bien, e imprime versión instalada.

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_DIR="$REPO_DIR/claude-config"
readonly TARGET_DIR="$HOME/.claude"
readonly BACKUP_DIR="$HOME/.claude.backup.$(date +%Y-%m-%d-%H%M%S)"
readonly VERSION="$(cat "$REPO_DIR/VERSION" 2>/dev/null || echo "unknown")"

log()  { printf "  %s\n" "$*"; }
ok()   { printf "  \033[32m✅\033[0m %s\n" "$*"; }
warn() { printf "  \033[33m⚠️\033[0m  %s\n" "$*"; }
err()  { printf "  \033[31m❌\033[0m %s\n" "$*"; }

echo ""
echo "🔧 Installing claude-config v${VERSION}"
echo ""

if [[ ! -d "$SOURCE_DIR" ]]; then
  err "Source dir not found: $SOURCE_DIR"
  exit 1
fi

# 1. Backup existing ~/.claude/
if [[ -d "$TARGET_DIR" ]]; then
  log "Backing up existing $TARGET_DIR → $BACKUP_DIR"
  cp -R "$TARGET_DIR" "$BACKUP_DIR"
  ok "Backup created at $BACKUP_DIR"
else
  log "No existing ~/.claude/ found, fresh install"
  mkdir -p "$TARGET_DIR"
fi

# 2. Preserve user-personal files we never overwrite
PRESERVE_FILES=("CLAUDE.local.md" "credentials.json" "history.jsonl")
TMP_PRESERVE="$(mktemp -d)"
for f in "${PRESERVE_FILES[@]}"; do
  if [[ -f "$TARGET_DIR/$f" ]]; then
    cp "$TARGET_DIR/$f" "$TMP_PRESERVE/$f"
    log "Preserving $f"
  fi
done

# 3. Copy config files (NOT a symlink — avoids cross-drive issues on Windows-ish setups)
log "Installing config files..."
cp -R "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
cp -R "$SOURCE_DIR/settings.json" "$TARGET_DIR/settings.json" 2>/dev/null || warn "settings.json skipped (existing user settings preserved)"

# Merge directories instead of overwriting (preserves user files in agents/, skills/, etc.)
for subdir in rules scripts templates; do
  if [[ -d "$SOURCE_DIR/$subdir" ]]; then
    mkdir -p "$TARGET_DIR/$subdir"
    cp -R "$SOURCE_DIR/$subdir/." "$TARGET_DIR/$subdir/"
    ok "Installed $subdir/"
  fi
done

# 4. Restore preserved personal files
for f in "${PRESERVE_FILES[@]}"; do
  if [[ -f "$TMP_PRESERVE/$f" ]]; then
    cp "$TMP_PRESERVE/$f" "$TARGET_DIR/$f"
  fi
done
rm -rf "$TMP_PRESERVE"

# 5. Make scripts executable
chmod +x "$TARGET_DIR/scripts/"*.js 2>/dev/null || true

# 6. Verify
echo ""
log "Running verification..."
if [[ -f "$REPO_DIR/tests/verify-install.sh" ]]; then
  bash "$REPO_DIR/tests/verify-install.sh"
else
  warn "verify-install.sh not found — skipping verification"
fi

echo ""
ok "claude-config v${VERSION} installed successfully"
echo ""
echo "📂 Backup: $BACKUP_DIR"
echo "📂 Active config: $TARGET_DIR"
echo ""
echo "Next: open Claude Code in any project. The cascade audit will run automatically."
