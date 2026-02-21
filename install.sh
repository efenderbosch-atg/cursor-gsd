#!/usr/bin/env bash
# GSD Workflow Commands — Installer / Updater
# Usage: curl -fsSL https://raw.githubusercontent.com/ben-smith-atg/cursor-gsd/main/install.sh | bash
set -euo pipefail

BASE="https://raw.githubusercontent.com/ben-smith-atg/cursor-gsd/main"
DEST="${HOME}/.cursor/commands/gsd"
FILES=(
  setup-gsd.md
  spec-gsd.md
  plan-gsd.md
  build-gsd.md
  verify-gsd.md
  retro-gsd.md
  README.md
)

mkdir -p "$DEST"

echo "Installing GSD commands to ${DEST} ..."
echo ""

for f in "${FILES[@]}"; do
  if curl -fsSL "${BASE}/${f}" -o "${DEST}/${f}"; then
    echo "  ✓ ${f}"
  else
    echo "  ✗ ${f} (failed)" >&2
    exit 1
  fi
done

echo ""
echo "Done. ${#FILES[@]} files installed to ${DEST}"
echo "Restart Cursor to pick up the updated commands."
