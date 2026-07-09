#!/bin/sh
# PostToolUse hook — syncs ~/.claude/settings.json back to chezmoi source
# Fires after Write or Edit tool calls. Checks if the target was settings.json,
# then folds the user's edit into claude-settings-base.json via a reverse
# merge patch — overlay-managed values never reach the base (see below).
# Always exits 0 so it never blocks Claude.

set -e

SETTINGS="$HOME/.claude/settings.json"
BASE_TEMPLATE=".chezmoitemplates/claude-settings-base.json"

# Parse stdin: the PostToolUse JSON payload
PAYLOAD=$(cat)

# Extract tool name
TOOL_NAME=$(printf '%s' "$PAYLOAD" | jq -r '.tool_name // empty')

# Determine the file path based on the tool
case "$TOOL_NAME" in
  Write)
    FILE_PATH=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // empty')
    ;;
  Edit)
    FILE_PATH=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.path // empty')
    ;;
  *)
    exit 0
    ;;
esac

# Normalize path: expand ~ if present
FILE_PATH=$(printf '%s' "$FILE_PATH" | sed "s|^~|$HOME|")

# Only act on settings.json
if [ "$FILE_PATH" != "$SETTINGS" ]; then
  exit 0
fi

# Check if chezmoi is available
if ! command -v chezmoi > /dev/null 2>&1; then
  printf 'settings-sync: chezmoi not found, skipping\n'
  exit 0
fi

# Semantic diff: compare chezmoi-rendered source vs live file (sorted keys)
RENDERED=$(chezmoi cat "$SETTINGS" 2>/dev/null) || {
  printf 'settings-sync: chezmoi cat failed, skipping\n'
  exit 0
}

DIFF=$(diff \
  <(printf '%s' "$RENDERED" | jq -S .) \
  <(jq -S . "$SETTINGS") 2>/dev/null) || true

if [ -z "$DIFF" ]; then
  printf 'settings-sync: no semantic change, skipping\n'
  exit 0
fi

# Resolve source path for base template
SRC=$(chezmoi source-path 2>/dev/null) || {
  printf 'settings-sync: could not resolve chezmoi source-path, skipping\n'
  exit 0
}

BASE_PATH="$SRC/$BASE_TEMPLATE"

# Reverse merge-patch: new_base = mergePatch(base, diff(rendered, live)).
# `rendered` is the full base+overlay render, so overlay-managed values are
# identical in rendered and live, never enter the patch, and never leak into
# the base — without this script knowing any overlay key names. Only genuine
# user edits (additions, changes, deletions) propagate. The filter lives in
# settings-merge-patch.jq (unit-tested by scripts/test-merge-patch.sh).
MERGE_FILTER="$(dirname "$0")/settings-merge-patch.jq"
if [ ! -f "$MERGE_FILTER" ]; then
  printf 'settings-sync: %s not found, skipping\n' "$MERGE_FILTER"
  exit 0
fi

NEW_BASE=$(jq -n \
  --slurpfile base_a "$BASE_PATH" \
  --argjson rendered "$RENDERED" \
  --slurpfile live_a "$SETTINGS" \
  -f "$MERGE_FILTER") || {
  printf 'settings-sync: failed to compute base update, skipping\n'
  exit 0
}

# Atomic write so a failure never truncates the base template
if ! printf '%s\n' "$NEW_BASE" > "$BASE_PATH.tmp" || ! mv "$BASE_PATH.tmp" "$BASE_PATH"; then
  printf 'settings-sync: failed to write %s\n' "$BASE_PATH"
  rm -f "$BASE_PATH.tmp"
  exit 0
fi

# Safety valve: if re-rendering (base + overlay) no longer matches the live
# file, an overlay-managed value (e.g. a shared array) was involved in the
# edit and the merge patch could not represent it cleanly.
RECHECK=$(chezmoi cat "$SETTINGS" 2>/dev/null) || RECHECK=""
if [ -n "$RECHECK" ] && [ "$(printf '%s' "$RECHECK" | jq -S .)" != "$(jq -S . "$SETTINGS")" ]; then
  printf 'settings-sync: base updated but overlay interaction detected — run the chezmoi-claude-sync skill to reconcile\n'
  exit 0
fi

printf 'settings-sync: updated claude-settings-base.json (chezmoi diff pending)\n'
exit 0
