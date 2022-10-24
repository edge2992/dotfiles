#!/usr/bin/zsh
DOT_FILES=(.vimrc .tmux.conf)

for file in ${DOT_FILES[@]}
do
  echo $file
	ln -s $HOME/dotfiles/$file $HOME/$file
done

# zshの設定ファイルをhomeへリンクする
# find .zprezto/runcoms -name 'z*' | while read line;
# do
#   echo $line
#   fname="${line##*/}"
#   echo $fname
# 	ln -s $HOME/dotfiles/$line $HOME/.$fname
# done
