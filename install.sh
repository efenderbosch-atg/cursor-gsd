#!/usr/bin/env bash
# GSD Workflow Commands — Installer / Updater
#
# Requires: gh CLI (https://cli.github.com) — authenticated with repo access
#
# Usage:
#   gh api repos/ben-smith-atg/cursor-gsd/contents/install.sh --jq '.content' \
#     | base64 -d | bash
#
# Or clone and run locally:
#   bash /path/to/cursor-gsd/install.sh
set -euo pipefail

REPO="ben-smith-atg/cursor-gsd"
FILES=(
  setup-gsd.md
  spec-gsd.md
  plan-gsd.md
  build-gsd.md
  verify-gsd.md
  retro-gsd.md
  README.md
)

# --- Tool selection ---
echo ""
echo "Install GSD commands for which AI tool?"
echo "  1) Cursor"
echo "  2) Claude Code"
printf "Choice [1/2]: "
if read -r TOOL_CHOICE </dev/tty 2>/dev/null; then
  : # got input from tty
else
  TOOL_CHOICE="1" # default to Cursor in non-interactive environments
fi
echo ""

case "$TOOL_CHOICE" in
  2)
    TOOL="claude"
    DEST="${HOME}/.claude/commands/gsd"
    TOOL_NAME="Claude Code"
    ;;
  *)
    TOOL="cursor"
    DEST="${HOME}/.cursor/commands/gsd"
    TOOL_NAME="Cursor"
    ;;
esac

# --- Substitution ---
# Strips tool-specific conditional markers and applies path/token substitutions.
# GSD source files use HTML comments to delimit tool-specific sections:
#   <!-- GSD-CURSOR-ONLY-START --> ... <!-- GSD-CURSOR-ONLY-END -->
#   <!-- GSD-CLAUDE-ONLY-START --> ... <!-- GSD-CLAUDE-ONLY-END -->
apply_subs() {
  if [[ "$TOOL" == "claude" ]]; then
    sed \
      -e '/<!-- GSD-CURSOR-ONLY-START -->/,/<!-- GSD-CURSOR-ONLY-END -->/d' \
      -e '/<!-- GSD-CLAUDE-ONLY-START -->/d' \
      -e '/<!-- GSD-CLAUDE-ONLY-END -->/d' \
      -e 's|\.cursor/rules/|.claude/rules/|g' \
      -e 's|\.cursor/plans/|.claude/plans/|g' \
      -e 's|\.cursor/commands/|.claude/commands/|g' \
      -e 's|\.mdc|.md|g' \
      -e 's/cursor rules/project rules/g' \
      -e 's/Cursor rules/project rules/g' \
      -e 's/`SemanticSearch`/the `Explore` agent (via Agent tool)/g' \
      -e 's/.*alwaysApply.*false.*flag.*/- **Context management**: Claude Code reads project rules only when explicitly referenced in skill prompts (via the Pre-Flight step), keeping them out of unrelated conversations./' \
    | awk '
      /^description: GSD project configuration/ { skip = 1; pending = ""; next }
      skip && /^---$/                            { skip = 0; next }
      skip                                       { next }
      /^---$/                                    { pending = $0; next }
      length(pending) > 0                        { print pending; pending = "" }
                                                 { print }
    '
  else
    sed \
      -e '/<!-- GSD-CURSOR-ONLY-START -->/d' \
      -e '/<!-- GSD-CURSOR-ONLY-END -->/d' \
      -e '/<!-- GSD-CLAUDE-ONLY-START -->/,/<!-- GSD-CLAUDE-ONLY-END -->/d'
  fi
}

# --- Install ---
if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI is required. Install from https://cli.github.com" >&2
  exit 1
fi

mkdir -p "$DEST"

echo "Installing GSD commands for ${TOOL_NAME} to ${DEST} ..."
echo ""

for f in "${FILES[@]}"; do
  gh api "repos/${REPO}/contents/${f}" --jq '.content' \
    | base64 -d \
    | apply_subs \
    > "${DEST}/${f}"
  echo "  ✓ ${f}"
done

echo ""
echo "Done. ${#FILES[@]} files installed to ${DEST}"
if [[ "$TOOL" == "cursor" ]]; then
  echo "Restart Cursor to pick up the updated commands."
else
  echo "Start a new Claude Code session to pick up the updated commands."
fi