if [ "$(uname -s)" = "Linux" ]; then
  # 将来的には, /usr/local/binにシンボリックリンクを通して一括管理したい
  # picard
  export PICARD="~/tools/picard.jar"

  # bedtools
  export PATH=~/tools/:$PATH

  #sratoolkit
  export PATH=~/tools/sratoolkit.2.11.0-ubuntu64/bin:$PATH
fi

if [ "(uname -s)" = "Darwin" ]; then
fi
