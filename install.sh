#!/usr/bin/env bash
set -e
NAME="exit-clean"
# 本機執行：用本地路徑
if [ -f "$(dirname "$0")/.claude-plugin/plugin.json" ]; then
  DIR="$(cd "$(dirname "$0")" && pwd)"
  claude plugin marketplace add "$DIR"
else
  # curl | bash：用 GitHub source
  claude plugin marketplace add "ayii0111/$NAME"
fi
claude plugin install "${NAME}@${NAME}"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$CLAUDE_DIR/commands"
printf -- '---\ndisable-model-invocation: true\n---\n' > "$CLAUDE_DIR/commands/exit-clean.md"

echo "✓ 安裝完成。在 CC 執行 /reload-plugins 或重啟 CC 套用。"
