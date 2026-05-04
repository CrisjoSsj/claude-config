#!/usr/bin/env bash
# UPDATE.sh — pulls latest from origin and re-runs INSTALL respecting personal files.

set -euo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$REPO_DIR"

echo ""
echo "🔄 Updating claude-config from origin..."
echo ""

# Pull latest
git pull --ff-only origin main

# Run install (respects CLAUDE.local.md and other personal files)
bash "$REPO_DIR/INSTALL.sh"
