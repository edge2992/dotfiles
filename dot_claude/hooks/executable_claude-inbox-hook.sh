#!/usr/bin/env bash
# Claude session inbox: track which sessions are waiting for the user.
#
# Registered for four events (dispatch on hook_event_name from stdin):
#   Stop              -> write state "waiting"
#   Notification      -> write state "permission" (matcher: permission_prompt;
#                        may linger after approval until the next Stop
#                        overwrites it — acceptable, self-corrects)
#   UserPromptSubmit  -> the user is back at this session: clear its entry
#   SessionEnd        -> clear its entry
#
# State: one JSON per session under $CLAUDE_INBOX_DIR (default
# ~/.cache/claude-inbox), consumed by ~/.local/bin/claude-inbox.
# Sessions outside tmux are skipped: the inbox's whole point is jumping to
# the pane, and unjumpable entries would only pollute the list.
# Like worklog.sh, this hook NEVER fails the session (always exits 0).
set -uo pipefail

input="$(cat)"

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

dir="${CLAUDE_INBOX_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/claude-inbox}"

event="$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null)"
[ -n "$event" ] || event="${1:-}"
sid="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)"
# The regex doubles as a path-injection guard since session_id lands in a
# path (same convention as worklog.sh / permission-notify.sh).
[[ "$sid" =~ ^[A-Za-z0-9-]+$ ]] || exit 0
f="$dir/$sid.json"

case "$event" in
  UserPromptSubmit | SessionEnd)
    rm -f "$f" 2>/dev/null
    exit 0
    ;;
  Stop) state="waiting" ;;
  Notification) state="permission" ;;
  *) exit 0 ;;
esac

# A Stop re-fired by another Stop hook's block (stop-review.sh) is not a
# fresh "waiting for input" moment; skip to avoid double writes.
[ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ] && exit 0

# Pane ID (%N) is the jump target: unique for the tmux server lifetime,
# unlike window indices (renumber-windows on). #S:#I.#P is display-only.
target="$(tmux display-message -p -t "$TMUX_PANE" '#S:#I.#P' 2>/dev/null)" || exit 0

cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[ -n "$cwd" ] || cwd="$PWD"
transcript="$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null)"

# Git context (best effort, same as worklog.sh).
repo=""
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  top="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"
  [ -n "$top" ] && repo="$(basename "$top")"
  branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)"
fi

# One-line summary: last assistant text from the transcript tail, clipped.
# Rich detail is rendered lazily by `claude-inbox preview`.
summary=""
if [ -n "$transcript" ] && [ -r "$transcript" ]; then
  summary="$(tail -n 40 "$transcript" 2>/dev/null | jq -nrR '
    [ inputs | fromjson? // empty
      | select(.message.role? == "assistant")
      | .message.content
      | if type == "array"
        then (map(select(.type? == "text") | .text) | join(" "))
        else tostring end
      | select(length > 0)
    ] | last // ""' 2>/dev/null | tr -s ' \t\n' '   ' | sed 's/[[:space:]]*$//' | cut -c 1-160)" || summary=""
fi

mkdir -p "$dir" 2>/dev/null || exit 0
tmp="$f.tmp.$$"
# tmp+mv keeps writes atomic: the status bar polls this dir every second.
jq -n \
  --arg sid "$sid" --arg state "$state" --arg pane "$TMUX_PANE" \
  --arg target "$target" --arg cwd "$cwd" --arg repo "$repo" \
  --arg branch "$branch" --arg transcript "$transcript" --arg summary "$summary" \
  '{session_id: $sid, state: $state, pane: $pane, target: $target,
    cwd: $cwd, repo: $repo, branch: $branch, transcript_path: $transcript,
    summary: $summary, ts: now | floor}' >"$tmp" 2>/dev/null \
  && mv "$tmp" "$f" 2>/dev/null
rm -f "$tmp" 2>/dev/null

# Piggyback a prune here: without it, a pane killed outside SessionEnd
# would inflate the status badge until the user next opens the picker.
command -v claude-inbox >/dev/null 2>&1 && claude-inbox gc 2>/dev/null

exit 0
