#!/usr/bin/env bash
# PostToolUse(Write|Edit) hook: lint/format the file Claude just touched.
#
# Reuses this repo's .pre-commit-config.yaml as the single source of truth so
# the local check matches the pre-commit / CI gate exactly. Runs every hook
# except the slow secret scanner. On failure the output is fed back to Claude
# (exit 2) so issues are fixed immediately, before commit.
set -euo pipefail

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

# Only act on file types our pre-commit config knows about (sh, nvim lua,
# chezmoi templates, toml, yaml, json). Anything else is a fast no-op.
case "$file" in
*.lua | *.sh | *.sh.tmpl | *.tmpl | *.toml | *.yaml | *.yml | *.json) ;;
*) exit 0 ;;
esac

# Resolve the git repo that owns the file; bail if it isn't a repo or has no config.
repo=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$repo/.pre-commit-config.yaml" ] || exit 0
command -v pre-commit >/dev/null 2>&1 || exit 0

rel=${file#"$repo"/}
if ! out=$(cd "$repo" && SKIP=gitleaks pre-commit run --files "$rel" 2>&1); then
	printf 'pre-commit found issues in %s:\n\n%s\n' "$rel" "$out" >&2
	exit 2
fi
exit 0
