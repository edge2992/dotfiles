# shellcheck shell=bash
# Shared notification helpers, sourced by permission-notify.sh / stop-notify.sh.
#
# Optional config (~/.config/claude-notify/config, managed by chezmoi):
#   NTFY_TOPIC               ntfy.sh topic; empty/unset disables mobile push
#   NTFY_SERVER              ntfy server base URL (default https://ntfy.sh)
#   STOP_NOTIFY_MIN_SECONDS  min turn duration before a Stop notification

CLAUDE_NOTIFY_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/claude-notify/config"
# shellcheck source=/dev/null
[ -r "$CLAUDE_NOTIFY_CONF" ] && . "$CLAUDE_NOTIFY_CONF"

: "${NTFY_SERVER:=https://ntfy.sh}"
: "${NTFY_TOPIC:=}"
: "${STOP_NOTIFY_MIN_SECONDS:=20}"

project_name() {
  if [ -n "${1:-}" ]; then basename "$1"; else echo "claude"; fi
}

# Resolve "session:window.pane" for the pane Claude Code runs in. Must be
# called at hook time — $TMUX_PANE is inherited from the Claude process and
# cannot be recovered later, when the notification is clicked.
tmux_target() {
  [ -n "${TMUX_PANE:-}" ] || return 0
  command -v tmux >/dev/null 2>&1 || return 0
  local target
  target="$(tmux display-message -p -t "$TMUX_PANE" \
    '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)" || return 0
  # Allowlist guard: the value is embedded in terminal-notifier -execute,
  # so anything shell-hostile (spaces, quotes) falls back to empty.
  [[ "$target" =~ ^[A-Za-z0-9_:.-]+$ ]] && printf '%s' "$target"
  return 0
}

notify_local() {
  local title="$1" message="$2" target="${3:-}"
  case "$(uname -s)" in
    Darwin)
      if command -v terminal-notifier >/dev/null 2>&1; then
        # -group per title: alerts from different projects stack instead of
        # replacing each other.
        terminal-notifier -title "$title" -message "$message" \
          -sound Glass -group "claude-code-$title" \
          -execute "$HOME/.claude/hooks/focus-restore.sh '$target'" \
          >/dev/null 2>&1 || true
      else
        # Fallback: passive toast, no click action.
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\"" 2>/dev/null || true
      fi
      ;;
    Linux)
      notify-send -u critical "$title" "$message" 2>/dev/null || true
      paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || printf '\a'
      ;;
    *)
      printf '\a' >/dev/tty 2>/dev/null || true
      ;;
  esac
}

notify_ntfy() {
  [ -n "$NTFY_TOPIC" ] || return 0
  command -v curl >/dev/null 2>&1 || return 0
  local title="$1" message="$2" priority="${3:-default}" tags="${4:-}"
  # Header values must be single-line (header injection guard).
  title="$(printf '%s' "$title" | tr -d '\r\n')"
  priority="$(printf '%s' "$priority" | tr -d '\r\n')"
  tags="$(printf '%s' "$tags" | tr -d '\r\n')"
  # Background + disown: a slow network must never delay the local alert.
  (
    curl -fsS --max-time 10 \
      -H "Title: $title" -H "Priority: $priority" -H "Tags: $tags" \
      -d "$message" "$NTFY_SERVER/$NTFY_TOPIC" >/dev/null 2>&1 &
    disown
  ) 2>/dev/null || true
}
