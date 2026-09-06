# exit-clean

A Claude Code command that exits the current session and permanently deletes its history file.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/exit-clean/main/install.sh | bash
```

安裝後在 CC 執行 `/reload-plugins` 套用。

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/exit-clean/main/uninstall.sh | bash
```

## Usage

在 CC 輸入 `/exit-clean`，確認後離開並刪除當前 session 歷史檔（不可復原）。

## 安裝原理
- 原則上功能包含 hook 與 command 部分
- hook 採 plugin 安裝
- command 則採用手動插入 command 檔案，以避免指令提示會自動加上 plugin 的名稱，變成「exit-clean: exit-clean」(這樣很醜)
