#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# zsh promptをpowerlineする
# powerline-daemon -q
# . ~/.local/lib/python3.7/site-packages/powerline/bindings/zsh/powerline.zsh
export PATH=$PATH:$HOME/.local/bin

# Powerline configuration
if [ -f $HOME/.local/lib/python3.7/site-packages/powerline/bindings/zsh/powerline.sh ]; then
  $HOME/.local/bin/powerline-daemon -q
  POWERLINE_ZSH_CONTINUATION=1
  POWERLINE_ZSH_SELECT=1
  source $HOME/.local/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.sh
fi

# pythonの設定
alias python="python3"
alias pip="pip3"

#clipboard copy macと似た機能にする
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# 競技プログラミング設定
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME/Documents/code/cpp
gg(){
  g++ -std=c++14 $1
}

