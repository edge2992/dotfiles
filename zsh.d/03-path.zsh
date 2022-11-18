export PATH=$PATH:$HOME/.local/bin

# npm settings
export PATH=~/.npm-packages/bin:$PATH

# # pyenv の設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
if [ -f ~/.pyenvrc ] && [ -d ~/.pyenv ]; then
  . ~/.pyenvrc
fi

if [ "$(uname -s)" = "Linux" ]; then
  # rbenv
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"

  # GO
  export PATH="$PATH:$(go env GOPATH)/bin"

  # Rust
  source $HOME/.cargo/env
fi

if [ "(uname -s)" = "Darwin" ]; then
  # tcl-tk
  export PATH="/opt/homebrew/opt/tcl-tk/bin:$PATH"
  # # For compilers to find tcl-tk you may need to set:
  #   export LDFLAGS="-L/opt/homebrew/opt/tcl-tk/lib"
  #   export CPPFLAGS="-I/opt/homebrew/opt/tcl-tk/include"

  # # For pkg-config to find tcl-tk you may need to set:
  #   export PKG_CONFIG_PATH="/opt/homebrew/opt/tcl-tk/lib/pkgconfig"

  # libomp
  export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"
fi

export PATH="$HOME/RNA_toolbox/bin:$PATH"

# Texlive用の設定
export MANPATH="/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH"
export PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"

#javaの設定
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export PATH=${JAVA_HOME}/bin:${PATH}

export PATH="$PATH:$HOME/tools/lua-language-server/bin"
# Mecab
export MECABRC=/etc/mecabrc
