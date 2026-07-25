#!/usr/bin/env bash
# Invoked by terminal-notifier -execute when a Claude Code notification is
# clicked. $1 = tmux target "session:window.pane" captured at hook time
# (empty when Claude was not running inside tmux).
set -uo pipefail

target="${1:-}"

if [ -n "$target" ] && command -v tmux >/dev/null 2>&1; then
  # select-* alone doesn't move an attached client that is on another
  # session, so retarget the first attached client explicitly.
  client_tty="$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -n1)" || client_tty=""
  if [ -n "$client_tty" ]; then
    tmux switch-client -c "$client_tty" -t "${target%%:*}" 2>/dev/null || true
  fi
  tmux select-window -t "${target%.*}" 2>/dev/null || true
  tmux select-pane -t "$target" 2>/dev/null || true
fi

if command -v osascript >/dev/null 2>&1; then
  osascript -e 'tell application "WezTerm" to activate' 2>/dev/null || true
fi
