# exit-clean

A Claude Code custom command that exits the current session and permanently deletes its history file.

## How it works

Type `/exit-clean` → prompted with `⚠️ 確定要離開並刪除此 session？(y/n)` → type `y` to confirm or `n` to cancel.

- Confirmation happens via a `UserPromptExpansion` hook — no model turn is triggered.
- The session file is deleted after Claude Code exits (via a detached background process to avoid race conditions).
- An unanswered prompt auto-cancels after 60 seconds.

## Requirements

- Claude Code
- macOS or Linux (uses `/usr/bin/perl` for the detached deletion process)
- Python 3 (for `install.sh` to patch `settings.json`)

## Install

One-liner (requires the repo to be on GitHub):

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/exit-clean/main/install.sh | bash
```

Or clone manually:

```bash
git clone https://github.com/ayii0111/exit-clean.git
cd exit-clean
bash install.sh
```

Restart Claude Code. The `/exit-clean` command will be available in every session.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/exit-clean/main/uninstall.sh | bash
```

## Migrating to a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/exit-clean/main/install.sh | bash
```
