#!/usr/bin/env bash
# UNINSTALL.sh — restore latest backup and remove the active install.

set -euo pipefail

LATEST_BACKUP="$(ls -dt ~/.claude.backup.* 2>/dev/null | head -n1 || true)"
TARGET_DIR="$HOME/.claude"

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "❌ No backup found in ~/.claude.backup.*"
  echo "   Cannot safely uninstall without a restore point."
  exit 1
fi

echo "Restoring from: $LATEST_BACKUP"
read -p "This will replace $TARGET_DIR. Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

rm -rf "$TARGET_DIR"
cp -R "$LATEST_BACKUP" "$TARGET_DIR"
echo "✅ Restored $TARGET_DIR from $LATEST_BACKUP"
