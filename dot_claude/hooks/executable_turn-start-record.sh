#!/usr/bin/env bash
# UserPromptSubmit hook: record the turn start time per session so
# stop-notify.sh can skip completion alerts for short turns.
set -uo pipefail

payload="$(cat)"

session_id=""
if command -v jq >/dev/null 2>&1; then
  session_id="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)" || session_id=""
elif command -v python3 >/dev/null 2>&1; then
  session_id="$(printf '%s' "$payload" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("session_id",""))' 2>/dev/null)" || session_id=""
fi

# The regex doubles as a path-injection guard since session_id lands in a path.
[[ "$session_id" =~ ^[A-Za-z0-9-]+$ ]] || exit 0

start_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude/turn-start"
mkdir -p "$start_dir" 2>/dev/null || exit 0
date +%s >"$start_dir/$session_id" 2>/dev/null || true
# GC stamps from sessions that never reached a Stop notification.
find "$start_dir" -type f -mtime +7 -delete 2>/dev/null || true
exit 0
