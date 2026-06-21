#!/usr/bin/env bash
set -e
NAME="exit-clean"
claude plugin uninstall "${NAME}@${NAME}"
claude plugin marketplace remove "$NAME"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
rm -f "$CLAUDE_DIR/commands/exit-clean.md"

echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
