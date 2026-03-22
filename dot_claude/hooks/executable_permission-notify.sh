#!/usr/bin/env bash
set -euo pipefail

title="Claude Code"
message="Permission required"

# Parse JSON from stdin if jq is available
if command -v jq >/dev/null 2>&1; then
  payload="$(cat)"
  title="$(printf '%s' "$payload" | jq -r '.title // "Claude Code"')"
  message="$(printf '%s' "$payload" | jq -r '.message // "Permission required"')"
fi

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
    ;;
  Linux)
    notify-send -u critical "$title" "$message" 2>/dev/null || true
    if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/bell.oga ]; then
      paplay /usr/share/sounds/freedesktop/stereo/bell.oga &
    fi
    ;;
  *)
    printf '\a' >/dev/tty 2>/dev/null || true
    ;;
esac
