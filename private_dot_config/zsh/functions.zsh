# SSH shortcut with fzf
function sshf() {
  # Listing Host and HostName from ~/.ssh/config and selecting with fzf
  local selection=$(grep -E "^\s*(Host|HostName) " ~/.ssh/config | \
    sed -E 's/^\s*Host(Name)?[ ]*//g' | \
    awk '{print $1}' | \
    grep -v '^HostName$' | \
    grep -v '\*' | \
    sort -u | \
    fzf --prompt="Select Host or HostName: ")

  # If a selection was made, initiate SSH connection
  if [ -n "$selection" ]; then
    ssh "$@""$selection"
  fi
}

# Git + fzf workflow functions

# Switch git branch with fzf
function gb() {
  local branch
  branch=$(git branch -a --format='%(refname:short)' | fzf --preview 'git log --oneline --graph --color=always {}' | sed 's/^origin\///')
  [ -n "$branch" ] && git switch "$branch"
}

# Browse git log with fzf and copy commit hash
function glog() {
  local commit
  commit=$(git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}')
  [ -n "$commit" ] && echo "$commit"
}

# Browse and checkout GitHub PRs with fzf
function gpr() {
  local pr
  pr=$(gh pr list | fzf --preview 'gh pr view {1}' | awk '{print $1}')
  [ -n "$pr" ] && gh pr checkout "$pr"
}

# Browse and preview Markdown files with fzf + glow
function mdp() {
  local dir="${1:-.}"
  local file
  file=$(find "$dir" -name '*.md' -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | \
    fzf --preview 'glow -s dark -w $FZF_PREVIEW_COLUMNS {}' --preview-window=right:60%)
  [ -n "$file" ] && glow -p "$file"
}

# Browse git stash entries with fzf
function gst() {
  local stash
  stash=$(git stash list | fzf --preview 'echo {1} | sed "s/:$//" | xargs git stash show -p' | awk -F: '{print $1}')
  [ -n "$stash" ] && git stash show -p "$stash"
}

# Fuzzy-find a file and open it in nvim (fv [query])
function fv() {
  local file preview
  if (( $+commands[bat] )); then
    preview='bat --color=always --style=numbers --line-range :200 {}'
  else
    preview='cat {}'
  fi
  if (( $+commands[fd] )); then
    file=$(fd --type f --hidden --exclude .git | fzf --query="$1" --preview "$preview")
  else
    file=$(find . -type f -not -path '*/.git/*' 2>/dev/null | fzf --query="$1" --preview "$preview")
  fi
  [ -n "$file" ] && nvim "$file"
}

# Fuzzy-find a directory under the tree and cd into it (fcd [dir])
function fcd() {
  local dir
  if (( $+commands[fd] )); then
    dir=$(fd --type d --hidden --exclude .git . "${1:-.}" | fzf --preview 'ls -la {}')
  else
    dir=$(find "${1:-.}" -type d -not -path '*/.git/*' 2>/dev/null | fzf --preview 'ls -la {}')
  fi
  [ -n "$dir" ] && cd "$dir"
}

# One-shot question to Claude (non-interactive, uses subscription auth, no API key)
# Usage: ask <question>   /   <command> | ask <question>
function ask() {
  [ $# -eq 0 ] && { echo "usage: ask <question>  (pipe stdin for context)" >&2; return 1; }
  if [ ! -t 0 ]; then
    local context
    context=$(cat)
    claude -p --model haiku -- "$@"$'\n\n---\n'"$context"
  else
    claude -p --model haiku -- "$@"
  fi
}
