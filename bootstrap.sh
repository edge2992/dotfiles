#!/bin/bash -eu
# ref: https://github.com/vwrs/dotfiles/blob/master/bootstrap

ROOT_HOME=/var/root
DOT_HOME=~/dotfiles
REMOTE_URL="https://github.com/edge2992/dotfiles.git"
CONFIG_HOME=~/.config
FZF_HOME=~/.fzf
PACKER_NVIM=~/.local/share/nvim/site/pack/packer/start/packer.nvim

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
  download (download tools fzf, packer.nvim)
  brew-install (only mac)
  font-nerd (install Hack, Meslo Nerd Font)
  color-theme (install color scheme for gnome-terminal)
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
  ./install.sh Hack
  ./install.sh Meslo
  cd ..
  rm -rf nerd-fonts
}

color_themes() {
  git clone --branch=master https://github.com/Gogh-Co/Gogh.git
  pushd Gogh
  export TERMINAL=gnome-terminal # necessory on ubuntu
  ./themes/tokyo-night-storm.sh
  ./themes/tokyo-night.sh
  ./themes/twilight.sh
  popd
  rm -rf Gogh
}

download() {
  cd $HOME

  # dotfiles
  if [ ! -d $DOT_HOME ]; then
    echo "Downloading dotfiles..."
    if has "git"; then
      git clone --recursive $REMOTE_URL $DOT_HOME
    else
      echo "${RED}Please install git.$NORMAL"
      exit 1
    fi
    if [ $? = 0 ]; then
      echo "${GREEN}Successfully downloaded dotfiles. ✔︎ $NORMAL"
    else
      echo "${RED}An unexpected error occurred when trying to install git.$NORMAL"
      exit 1
    fi
  else
    echo "${BOLD}dotfiles already exists.$NORMAL"
  fi

  # fzf
  if [ ! -d $FZF_HOME ]; then
    echo "${BOLD}Downloading fzf ...$NORMAL"
    git clone --depth 1 https://github.com/junegunn/fzf.git $FZF_HOME
    ~/.fzf/install
    if [ $? = 0 ]; then
      echo "${GREEN}Successfully installed fzf in $FZF_HOME. ✔︎ $NORMAL"
    else
      echo "${RED}An unexpected error occurred when trying to install fzf.$NORMAL"
    fi
  else
    echo "${BOLD}fzf already exists.$NORMAL"
  fi
  if [ ! -d $PACKER_NVIM ]; then
    echo "${BOLD}Downloading packer.nvim ...$NORMAL"
    # git clone --depth 1 https://github.com/junegunn/fzf.git $FZF_HOME
    # ~/.fzf/install
    git clone --depth 1 https://github.com/wbthomason/packer.nvim $PACKER_NVIM
    if [ $? = 0 ]; then
      echo "${GREEN}Successfully installed packer.nvim in $PACKER_NVIM. ✔︎ $NORMAL"
    else
      echo "${RED}An unexpected error occurred when trying to install packer.nvim.$NORMAL"
    fi
  else
    echo "${BOLD}packer.nvim already exists.$NORMAL"
  fi
}

brew_install() {
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "${BOLD}Downloading...$NORMAL"
    brew bundle --file ${DOT_HOME}/Brewfile
    if [ $? = 0 ]; then
      echo "${GREEN}Successfully installed. ✔︎ $NORMAL"
    else
      echo "${RED}An unexpected error occurred when trying to brew bundle.$NORMAL"
    fi
  else
    echo "${RED}This command is intended to be executed only on a macbook.$NORMAL"
  fi
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
    [[ $f = "Brewfile" ]] && continue
    [[ $f = "Brewfile.lock.json" ]] && continue
    [[ $f = "Doc" ]] && continue
    if [ $f = "nvim" ]; then
      mkdir -p $CONFIG_HOME
      ln -snfv $DOT_HOME/$f $CONFIG_HOME/$f
    else
      ln -snfv $DOT_HOME/$f $1/.$f
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
    download)
      download
      ;;
    color-theme)
      color_themes
      ;;
    font-nerd)
      nerd_fonts
      main
      ;;
    deploy)
      symlink_files $HOME
      ;;
    brew-install)
      brew_install
      main
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
