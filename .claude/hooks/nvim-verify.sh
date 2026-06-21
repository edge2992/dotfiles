#!/usr/bin/env bash
# PostToolUse(Write|Edit) hook: verify the Neovim Lua config still loads after
# Claude edits a file under private_dot_config/nvim/.
#
# Complements precommit-lint.sh (which runs stylua) by adding the runtime check
# stylua can't do: byte-compile every nvim .lua and load edgissa.core — the same
# check `make nvim-check` and CI's nvim-health run. Runs against the chezmoi
# source without touching ~/.config/nvim. On failure the output is fed back to
# Claude (exit 2) so load/syntax errors are fixed immediately, before commit.
set -euo pipefail

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

# Only act on edits to the Neovim Lua config; everything else is a fast no-op.
case "$file" in
*/private_dot_config/nvim/*.lua) ;;
*) exit 0 ;;
esac

command -v nvim >/dev/null 2>&1 || exit 0

# Resolve the repo that owns the file and locate the source + check script.
repo=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
src="$repo/private_dot_config/nvim"
check="$repo/scripts/nvim-check.lua"
[ -f "$check" ] || exit 0

if ! out=$(NVIM_SRC="$src" nvim --headless --clean \
	--cmd "set rtp^=$src" \
	+"luafile $check" +qa 2>&1); then
	printf 'Neovim config failed to load after editing %s:\n\n%s\n' "${file#"$repo"/}" "$out" >&2
	exit 2
fi
exit 0
