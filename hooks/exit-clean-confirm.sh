#!/bin/bash
# UserPromptSubmit hook — 確認階段
# 未武裝時第一行放行，武裝中才攔截 y/n。
set -u
INPUT=$(cat)

SID="${CLAUDE_CODE_SESSION_ID:-unknown}"
MARKER="${TMPDIR:-/tmp}/.exit-clean-arm-${SID}"

[ -f "$MARKER" ] || exit 0

ARMED=$(cat "$MARKER" 2>/dev/null)
NOW=$(date +%s)
if [ -z "$ARMED" ] || [ $((NOW - ARMED)) -gt 60 ]; then rm -f "$MARKER"; exit 0; fi

block() { printf '{"decision":"block","reason":%s}\n' "$1"; exit 0; }

ANS=$(printf '%s' "$INPUT" | python3 -c "import json,sys;print(json.load(sys.stdin).get('prompt','').strip().lower())" 2>/dev/null)

case "$ANS" in
  y|yes|是)
    rm -f "$MARKER"
    p=$PPID; CC_PID=""
    for _ in 1 2 3 4 5 6 7 8; do
      [ -z "$p" ] || [ "$p" = "1" ] && break
      c=$(ps -o command= -p "$p" 2>/dev/null)
      if printf '%s' "$c" | grep -qE '(^|/)claude( |$)'; then CC_PID="$p"; break; fi
      p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
    done
    [ -z "$CC_PID" ] && block '"找不到 CC 主程序，已取消"'
    SESSION_FILE="$(find "$HOME/.claude/projects" -name "${SID}.jsonl" 2>/dev/null | head -1)"
    [ -z "$SESSION_FILE" ] && block '"找不到 session 檔，已取消"'
    /usr/bin/perl -e '
      use POSIX qw(setsid);
      my ($cc,$f) = @ARGV;
      my $pid = fork; exit 0 if $pid;
      POSIX::setsid();
      my $n = 0;
      while (kill(0, $cc)) { select(undef,undef,undef,0.2); last if ++$n > 3000; }
      select(undef,undef,undef,0.5);
      unlink $f;
    ' "$CC_PID" "$SESSION_FILE" >/dev/null 2>&1
    kill "$CC_PID"
    block '"已離開並刪除 session"'
    ;;
  n|no|否)
    rm -f "$MARKER"; block '"已取消"'
    ;;
  *)
    rm -f "$MARKER"; exit 0
    ;;
esac
