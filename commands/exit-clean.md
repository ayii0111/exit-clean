---
description: 離開當前 session 並刪除該 session 的歷史檔（不可復原）
disable-model-invocation: true
---

此指令的實際動作由 `UserPromptExpansion` hook（`~/.claude/hooks/exit-clean.sh`）在展開前攔截執行，正常情況下不會到達這裡。

若你看到這段文字，代表 hook 未生效——請重新開啟 Claude Code，或重新執行 `install.sh`。
