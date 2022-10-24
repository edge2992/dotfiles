#!/bin/bash -eu

ROOT_HOME=/var/root
DOT_HOME=~/dotfiles
REMOTE_URL="https://github.com/edge2992/dotfiles.git"
CONFIG_HOME=~/.config

if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

# funciton

has() {
  type "$1" > /dev/null 2>&1
}

dotfiles() {
  echo $BLUE
  cat <<\EOF
                   __          __       ___      ___
                  /\ \        /\ \__  /'___\ __ /\_ \
                  \_\ \    ___\ \ ,_\/\ \__//\_\\//\ \      __    ____
 _______          /'_` \  / __`\ \ \/\ \ ,__\/\ \ \ \ \   /'__`\ /',__\      _______
/\______\      __/\ \L\ \/\ \L\ \ \ \_\ \ \_/\ \ \ \_\ \_/\  __//\__, `\    /\______\
\/______/     /\_\ \___,_\ \____/\ \__\\ \_\  \ \_\/\____\ \____\/\____/    \/______/
              \/_/\/__,_ /\/___/  \/__/ \/_/   \/_/\/____/\/____/\/___/
EOF
  echo $NORMAL
}

usage() {
  echo $YELLOW
  cat <<\EOF
Commands:
  font-nerd (install Hack Nerd Font)
  deploy (symlink (force override) dotfiles)
  quit
EOF
  echo $NORMAL
}

nerd_fonts() {
  # nerd fontをインストールする
  # neovimで使用
  git clone --branch=master --depth=1 https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts
  ./install.sh $1
  cd ..
  rm -rf nerd-fonts
}

symlink_files() {
  # symlinkを作成する
  if [ ! -d $DOT_HOME ]; then
    echo 'dotfiles do not exist.'
    exit 1
  fi
  echo 'Symlinking dotfiles...'
  cd $DOT_HOME
  for f in *
  do
    # ignore list
    [[ $f = "README.md" ]] && continue
    [[ $f = "bootstrap.sh" ]] && continue
    if [ $f = "nvim" ]; then
      ln -snfv $DOT_HOME/$f $CONFIG_HOME
    elif [ $f = "tmux.conf" ]; then
      ln -snfv $DOT_HOME/$f $1/.$f
    elif [ $f = "zshrc" ]; then
      ln -snfv $DOT_HOME/$f $1/.$f
    elif [ $f = "zshenv" ]; then
      ln -snfv $DOT_HOME/$f $1/.$f
    elif [ $f = "zsh.d" ]; then
      ln -snfv $DOT_HOME/$f $1/.$f
    elif [ $f = "p10k.zsh" ]; then
      ln -snfv $DOT_HOME/$f $1/.$f
    else
      echo "${YELLOW}[future works] ${f} aren't symlinked yet.$NORMAL"
    fi
  done
}

# main
main() {
  usage
  echo -n "${BOLD}command: $NORMAL"
  read command
  case $command in
    quit)
      echo "bye!"
      exit 0
      ;;
    font-nerd)
      nerd_fonts Hack
      main
      ;;
    deploy)
      symlink_files $HOME
      ;;
    *)
      echo "${RED}bootstrap: command not found.$NORMAL"
      main
      ;;
  esac
}
dotfiles
main
exit 0
