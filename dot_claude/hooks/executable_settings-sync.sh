#!/bin/sh
# PostToolUse hook — syncs ~/.claude/settings.json back to chezmoi source
# Fires after Write or Edit tool calls. Checks if the target was settings.json,
# then strips modify-script-managed env vars and updates claude-settings-base.json.
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

# Strip modify-script-managed env vars from live settings and write to base
jq 'del(
  .env.ANTHROPIC_BEDROCK_BASE_URL,
  .env.AWS_BEARER_TOKEN_BEDROCK,
  .env.CLAUDE_CODE_USE_BEDROCK,
  .env.CLAUDE_CODE_SKIP_BEDROCK_AUTH,
  .env.CLAUDE_CODE_ENABLE_TELEMETRY,
  .env.OTEL_METRICS_EXPORTER,
  .env.OTEL_LOGS_EXPORTER,
  .env.OTEL_EXPORTER_OTLP_PROTOCOL,
  .env.OTEL_EXPORTER_OTLP_ENDPOINT,
  .env.OTEL_EXPORTER_OTLP_HEADERS,
  .env.CCGATE_OPENAI_API_KEY
)' "$SETTINGS" > "$BASE_PATH" || {
  printf 'settings-sync: failed to write %s\n' "$BASE_PATH"
  exit 0
}

printf 'settings-sync: updated claude-settings-base.json (chezmoi diff pending)\n'
exit 0
