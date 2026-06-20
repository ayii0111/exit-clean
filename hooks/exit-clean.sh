#!/bin/bash
# UserPromptExpansion hook for /exit-clean — 武裝階段
set -u
cat >/dev/null 2>&1

SID="${CLAUDE_CODE_SESSION_ID:-unknown}"
MARKER="${TMPDIR:-/tmp}/.exit-clean-arm-${SID}"
date +%s > "$MARKER"

printf '{"decision":"block","reason":%s}\n' \
  '"⚠️ 確定要離開並刪除此 session？(y/n)"'
