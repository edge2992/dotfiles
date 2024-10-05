# 競技プログラミング設定
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME/Documents/code/cpp
gg(){
  g++ -std=c++17 -O2 $1
}


export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/lib/:$LD_LIBRARY_PATH:
# rnascan
# conda用の設定　aliasでpyenvとの競合問題を回避
# export PATH="/home/edge2992/.pyenv/versions/anaconda3-5.3.1/bin:$PATH"
# alias activate_rna="source $PYENV_ROOT/versions/anaconda3-5.3.1/bin/activate rna"


#icSHAPEの設定
export ICSHAPE="/home/edge2992/H/Analysis/PARIS/tools/icSHAPE"
export PATH=/home/edge2992/.aspera/connect/bin:${PATH}
# export BOWTIELIB=""

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/edge2992/.pyenv/versions/miniconda3-latest/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/edge2992/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh" ]; then
#         . "/home/edge2992/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/edge2992/.pyenv/versions/miniconda3-latest/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

# alias activate="source $PYENV_ROOT/versions/miniconda3-latest/bin/activate"

