# 競技プログラミング設定
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME/Documents/code/cpp
gg(){
  g++ -std=c++17 -O2 $1
}


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
# rnascan
# conda用の設定　aliasでpyenvとの競合問題を回避
# export PATH="/home/edge2992/.pyenv/versions/anaconda3-5.3.1/bin:$PATH"
# alias activate_rna="source $PYENV_ROOT/versions/anaconda3-5.3.1/bin/activate rna"



# SAMtools
# export PATH=/mnt/H/Analysis/samtools-0.1.12a/:$PATH
export PICARD="~/tools/picard.jar"
# bedtools
export PATH=~/tools/:$PATH
#sratoolkit
export PATH=~/tools/sratoolkit.2.11.0-ubuntu64/bin:$PATH


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

# Anyenv
if [ -e "$HOME/.anyenv" ]
then
    export ANYENV_ROOT="$HOME/.anyenv"
    export PATH="$ANYENV_ROOT/bin:$PATH"
    if command -v anyenv 1>/dev/null 2>&1
    then
        eval "$(anyenv init -)"
    fi
fi



