# zsh plugin
(( $+commands[sheldon] )) && eval "$(sheldon source)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# fzf settings
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'

# fzf integration
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

(( $+commands[atuin] )) && eval "$(atuin init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# SDKMAN (Java/JVM manager)
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
