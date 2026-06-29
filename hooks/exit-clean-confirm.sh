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
    # 只刪「當前專案目錄」對應的 session：用 cwd 算出 slug 直指該目錄，
    # 避免同 session id 被複製到他處時，find 誤刪到別的副本。
    SLUG=$(printf '%s' "$PWD" | sed 's/[^a-zA-Z0-9]/-/g')
    SESSION_FILE="$HOME/.claude/projects/$SLUG/${SID}.jsonl"
    # debug 稽核：每次確認刪除都留一行，方便日後核對是否刪對檔案
    LOG="$HOME/.claude/exit-clean.log"
    printf '%s arm-delete sid=%s pwd=%s slug=%s file=%s exists=%s cc_pid=%s\n' \
      "$(date '+%F %T')" "$SID" "$PWD" "$SLUG" "$SESSION_FILE" \
      "$([ -f "$SESSION_FILE" ] && echo Y || echo N)" "$CC_PID" >> "$LOG"
    [ -f "$SESSION_FILE" ] || block '"當前專案目錄下找不到此 session 檔，已取消"'
    /usr/bin/perl -e '
      use POSIX qw(setsid);
      my ($cc,$f) = @ARGV;
      my $pid = fork; exit 0 if $pid;
      POSIX::setsid();
      my $n = 0;
      while (kill(0, $cc)) { select(undef,undef,undef,0.2); last if ++$n > 3000; }
      select(undef,undef,undef,0.5);
      unlink $f;
      if (open my $lg, ">>", "$ENV{HOME}/.claude/exit-clean.log") {
        print $lg POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime),
                  " post-delete file=$f gone=", ((-e $f) ? 0 : 1), "\n";
      }
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
