#!/bin/zsh
DOT_FILES=(.vimrc .tmux.conf)

#for file in .??* ${DOT_FILES[@]}
# ディレクトリ上の.gitが入ってしまう
for file in ${DOT_FILES[@]}
do
	echo $file
	ln -s $HOME/dotfiles/$file $HOME/$file
done

