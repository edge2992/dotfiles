find .zprezto/runcoms -name 'z*' | while read line;
do
  echo $line
  fname="${line##*/}"
  echo $HOME/.$fname
done

DOT_FILES=(.vimrc .tmux.conf)

for file in ${DOT_FILES[@]}
do
	# ln -s $HOME/dotfiles/$file $HOME/$file
  echo $file
done

find .zprezto/runcoms -name 'z*' | while read line;
do
  echo $line
  fname="${line##*/}"
  echo $fname
	ln -s $HOME/dotfiles/$line $HOME/.$fname
done
