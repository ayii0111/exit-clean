#!/bin/bash
set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/hooks"

cp "$REPO/commands/exit-clean.md"       "$CLAUDE_DIR/commands/exit-clean.md"
cp "$REPO/hooks/exit-clean.sh"          "$CLAUDE_DIR/hooks/exit-clean.sh"
cp "$REPO/hooks/exit-clean-confirm.sh"  "$CLAUDE_DIR/hooks/exit-clean-confirm.sh"
chmod +x "$CLAUDE_DIR/hooks/exit-clean.sh" "$CLAUDE_DIR/hooks/exit-clean-confirm.sh"

python3 << 'EOF'
import json, os

path = os.path.expanduser("~/.claude/settings.json")
s = json.load(open(path)) if os.path.exists(path) else {}
hooks = s.setdefault("hooks", {})

exp = hooks.setdefault("UserPromptExpansion", [])
exp[:] = [e for e in exp if e.get("matcher") != "exit-clean"]
exp.insert(0, {
    "matcher": "exit-clean",
    "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/exit-clean.sh", "timeout": 300}]
})

sub = hooks.setdefault("UserPromptSubmit", [])
if not any("exit-clean-confirm" in h.get("command", "") for e in sub for h in e.get("hooks", [])):
    sub.insert(0, {
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/exit-clean-confirm.sh"}]
    })

with open(path, "w") as f:
    json.dump(s, f, indent=2, ensure_ascii=False)
    f.write("\n")
EOF

echo "✓ 安裝完成，重新開啟 Claude Code 後 /exit-clean 即可使用。"
