#!/usr/bin/env bash
# Notification hook (matcher: permission_prompt): desktop-notify and count.
#
# Besides the notification, each invocation appends one line to a per-session
# counter file under ${XDG_CACHE_HOME:-$HOME/.cache}/claude/perm-prompts/;
# worklog.sh reads the line count at SessionEnd and deletes the file.
# Counting must never break the notification, so every step is guarded.
set -uo pipefail

payload="$(cat)"

title="Claude Code"
message="Permission required"
session_id=""

if command -v jq >/dev/null 2>&1; then
  title="$(printf '%s' "$payload" | jq -r '.title // "Claude Code"' 2>/dev/null)" || title="Claude Code"
  message="$(printf '%s' "$payload" | jq -r '.message // "Permission required"' 2>/dev/null)" || message="Permission required"
  session_id="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)" || session_id=""
elif command -v python3 >/dev/null 2>&1; then
  session_id="$(printf '%s' "$payload" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("session_id",""))' 2>/dev/null)" || session_id=""
fi

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
    ;;
  Linux)
    notify-send -u critical "$title" "$message" 2>/dev/null || true
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || printf '\a'
    ;;
  *)
    printf '\a' >/dev/tty 2>/dev/null || true
    ;;
esac

# Per-session prompt counter: append = atomic-enough increment, count = lines.
# Kept after the notification so counter/GC I/O never delays the alert.
# The regex doubles as a path-injection guard since session_id lands in a path.
count_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude/perm-prompts"
if [[ "$session_id" =~ ^[A-Za-z0-9-]+$ ]] && mkdir -p "$count_dir" 2>/dev/null; then
  printf '.\n' >>"$count_dir/$session_id.count" 2>/dev/null || true
  # GC counters no SessionEnd consumed (e.g. hosts without CLAUDE_WORKLOG_DIR).
  find "$count_dir" -type f -mtime +7 -delete 2>/dev/null || true
fi
