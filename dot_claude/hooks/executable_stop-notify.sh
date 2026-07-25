#!/usr/bin/env bash
# Stop hook: desktop + ntfy "task finished" notification.
#
# Runs alongside stop-review.sh in the same Stop matcher and must never
# block the agent, so every path exits 0. Turns shorter than
# STOP_NOTIFY_MIN_SECONDS (measured from the UserPromptSubmit stamp written
# by turn-start-record.sh) stay silent; a missing stamp fails open.
# stop_hook_active means stop-review.sh already bounced this turn once —
# the first Stop already notified, so skip to avoid duplicates.
set -uo pipefail

lib="$(dirname "${BASH_SOURCE[0]}")/lib/notify-common.sh"
[ -r "$lib" ] || exit 0
# shellcheck source=lib/notify-common.sh
. "$lib"

payload="$(cat)"

session_id=""
cwd=""
stop_hook_active="false"
if command -v jq >/dev/null 2>&1; then
  session_id="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)" || session_id=""
  cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null)" || cwd=""
  stop_hook_active="$(printf '%s' "$payload" | jq -r '.stop_hook_active // false' 2>/dev/null)" || stop_hook_active="false"
elif command -v python3 >/dev/null 2>&1; then
  session_id="$(printf '%s' "$payload" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("session_id",""))' 2>/dev/null)" || session_id=""
  cwd="$(printf '%s' "$payload" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)" || cwd=""
  stop_hook_active="$(printf '%s' "$payload" \
    | python3 -c 'import json,sys; print(str(json.load(sys.stdin).get("stop_hook_active",False)).lower())' 2>/dev/null)" || stop_hook_active="false"
fi

[ "$stop_hook_active" = "true" ] && exit 0

elapsed="$STOP_NOTIFY_MIN_SECONDS"
start_file="${XDG_CACHE_HOME:-$HOME/.cache}/claude/turn-start/$session_id"
if [[ "$session_id" =~ ^[A-Za-z0-9-]+$ ]] && [ -r "$start_file" ]; then
  start_ts="$(cat "$start_file" 2>/dev/null)" || start_ts=""
  if [[ "$start_ts" =~ ^[0-9]+$ ]]; then
    elapsed=$(($(date +%s) - start_ts))
  fi
fi
[ "$elapsed" -ge "$STOP_NOTIFY_MIN_SECONDS" ] || exit 0

project="$(project_name "$cwd")"
target="$(tmux_target)" || target=""
notify_local "Claude Code — $project" "タスク完了 (${elapsed}s)" "$target"
notify_ntfy "Claude Code — $project" "タスク完了 (${elapsed}s)" "default" "white_check_mark"
exit 0
