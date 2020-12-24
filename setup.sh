#!/usr/bin/zsh
DOT_FILES=(.vimrc .tmux.conf)
#! for file in .??* ${DOT_FILES[@]}

rm -rf $HOME/.vim

for file in .??*
do
  echo "$file のリンクを作成"
  ln -s $HOME/dotfiles/$file $HOME/$file
done

#! Neobundleの設定
git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
