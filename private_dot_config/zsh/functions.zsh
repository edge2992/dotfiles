# Environment tint for sshf: colour the pane background while connected, so a
# prod shell never looks like a dev shell. wezterm's text_background_opacity
# keeps these translucent, so they read as a tint over the desktop/photo
# rather than an opaque block — keep them dark and low-saturation.
typeset -gA SSHF_ENV_COLORS=(
  prod '#3d1b1b'
  stg  '#16301f'
  dev  '#2d1b3d'
)

# Classify a host name into prod / stg / dev. Most dangerous wins, so a host
# like "stg-to-prod-sync" is treated as prod. "stg" also covers stgqa/stg-qa.
function _sshf_env_for_host() {
  case "${1:l}" in
    *prod*) print -r -- prod ;;
    *stg*) print -r -- stg ;;
    *dev*) print -r -- dev ;;
  esac
}

# Tint only the pane running ssh. Inside tmux that means pane-scoped options
# (tmux swallows raw OSC unless allow-passthrough is on, and window-style would
# repaint every pane in the window); bare wezterm falls back to OSC 11.
function _sshf_tint_on() {
  if [[ -n "$TMUX" && -n "$TMUX_PANE" ]]; then
    tmux set-option -p -t "$TMUX_PANE" window-style "bg=$1"
    tmux set-option -p -t "$TMUX_PANE" window-active-style "bg=$1"
  else
    printf '\e]11;%s\a' "$1"
  fi
}

function _sshf_tint_off() {
  if [[ -n "$TMUX" && -n "$TMUX_PANE" ]]; then
    tmux set-option -p -u -t "$TMUX_PANE" window-style
    tmux set-option -p -u -t "$TMUX_PANE" window-active-style
  else
    printf '\e]111\a'
  fi
}

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
    local sshf_env
    sshf_env=$(_sshf_env_for_host "$selection")
    [[ -n "$sshf_env" ]] && _sshf_tint_on "$SSHF_ENV_COLORS[$sshf_env]"
    # `always` also runs on interrupt, so Ctrl-C never leaves the pane tinted.
    {
      ssh "$@""$selection"
    } always {
      [[ -n "$sshf_env" ]] && _sshf_tint_off
    }
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

# Draft a blog post with memo (bare `memo` captures into the Obsidian inbox)
# MEMODIR is the only setting memo honours from the environment.
function bmemo() {
  [ -z "$OBSIDIAN_VAULT" ] && { echo "bmemo: OBSIDIAN_VAULT is not set" >&2; return 1; }
  MEMODIR="$OBSIDIAN_VAULT/20_tech/blog/_posts" command memo "$@"
}
