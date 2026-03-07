# zsh plugin
command -v sheldon >/dev/null 2>&1 && eval "$(sheldon source)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# fzf settings
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'

# fzf integration
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
