export PATH=$PATH:$HOME/.local/bin

# npm settings
export PATH=~/.npm-packages/bin:$PATH

export PATH="$PATH:$HOME/tools/lua-language-server/bin"

# # pyenv の設定
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# if [ -f ~/.pyenvrc ] && [ -d ~/.pyenv ]; then
#   . ~/.pyenvrc
# fi

# GO
export PATH="$PATH:$(go env GOPATH)/bin"

case `uname` in
  Darwin)
    # homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # tcl-tk
    export PATH="/opt/homebrew/opt/tcl-tk/bin:$PATH"

    # libomp
    export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"

    # volta node version management tools
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
      ;;
  Linux)
    # rbenv
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

    # Rust
    source $HOME/.cargo/env

    # Texlive用の設定
    export MANPATH="/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH"
    export INFOPATH="/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH"
    export PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"

    #javaの設定
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    export PATH=${JAVA_HOME}/bin:${PATH}

    # Mecab
    export MECABRC=/etc/mecabrc
      ;;
esac

