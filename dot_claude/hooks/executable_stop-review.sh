#!/usr/bin/env bash
set -euo pipefail

# Prevent re-entrant loop: if this hook already fired, allow stop
input=$(cat)
stop_hook_active=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stop_hook_active', False))" 2>/dev/null || echo "False")
if [ "$stop_hook_active" = "True" ]; then
  exit 0
fi

# Only check if inside a git repo
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

# Check for uncommitted changes (unstaged + staged)
changed=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
total=$((changed + staged))

if [ "$total" -gt 0 ]; then
  cat >&2 <<MSG
未コミットの変更が ${total} 件あります。完了前に確認してください:
- code-reviewer エージェントでレビューを実施
- 変更内容が意図通りか確認 (git diff)
- コミットメッセージは Conventional Commits 形式か
MSG
  exit 2
fi
