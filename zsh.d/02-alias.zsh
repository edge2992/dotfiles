# Aliases
#
if [ "$(uname -s)" = "Linux" ]; then
  # Linux限定の設定
  alias ls='ls --group-directories-first --human-readable --color=auto'
elif [ "$(uname -s)" = "Darwin" ]; then
  # brew install coreutils
  alias ls='gls --group-directories-first --human-readable --color=auto'
fi


alias luamake=/luamake
alias vim='nvim'

#clipboard copy macと似た機能にする
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

# 競技プログラミング設定
alias oj-bundle='oj-bundle -I /mnt/H/MYWORK/cpplib'

# Slack notification
alias yatta=~/tools/yatta.sh

# ghq
alias g='cd $(ghq list -p | fzf)'

# kubectl
alias k='kubectl'

# eza
command -v eza       &> /dev/null    && alias ls='eza --group --git --group-directories-first'     || alias ls='ls --color=auto --group-directories-first -h'
command -v eza       &> /dev/null    && alias la='ll -a'                                           || alias la='ll -A'
command -v eza       &> /dev/null    && alias lk='ll -s=size'                                      || alias lk='ll -r --sort=size'
command -v eza       &> /dev/null    && alias lm='ll -s=modified'                                  || alias lm='ll -r --sort=time'

alias ll="ls -l"

