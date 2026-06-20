#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"

rm -f "$CLAUDE_DIR/commands/exit-clean.md" \
      "$CLAUDE_DIR/hooks/exit-clean.sh" \
      "$CLAUDE_DIR/hooks/exit-clean-confirm.sh"

python3 << 'EOF'
import json, os

path = os.path.expanduser("~/.claude/settings.json")
if not os.path.exists(path):
    exit(0)

s = json.load(open(path))
hooks = s.get("hooks", {})

if "UserPromptExpansion" in hooks:
    hooks["UserPromptExpansion"] = [e for e in hooks["UserPromptExpansion"] if e.get("matcher") != "exit-clean"]
    if not hooks["UserPromptExpansion"]:
        del hooks["UserPromptExpansion"]

if "UserPromptSubmit" in hooks:
    hooks["UserPromptSubmit"] = [
        e for e in hooks["UserPromptSubmit"]
        if not any("exit-clean-confirm" in h.get("command", "") for h in e.get("hooks", []))
    ]
    if not hooks["UserPromptSubmit"]:
        del hooks["UserPromptSubmit"]

with open(path, "w") as f:
    json.dump(s, f, indent=2, ensure_ascii=False)
    f.write("\n")
EOF

echo "✓ 已移除，重新開啟 Claude Code 後生效。"
