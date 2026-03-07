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

# Browse git stash entries with fzf
function gst() {
  local stash
  stash=$(git stash list | fzf --preview 'echo {1} | sed "s/:$//" | xargs git stash show -p' | awk -F: '{print $1}')
  [ -n "$stash" ] && git stash show -p "$stash"
}
