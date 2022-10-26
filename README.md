# Dotfiles for edge2992

## Setup

### run command

```=bash
bash -c "`curl -fsSL raw.github.com/edge2992/dotfiles/ubuntu/bootstrap.sh`"
```

### setup color theme and fonts

GNOME Terminalの設定を開いてダウンロードしたカラーテーマとフォントを設定する。  
Tokyo Night Stormを使用した。

>GNOME Terminal (the default Ubuntu terminal): Open Terminal → Preferences and click on the selected profile under Profiles. Check Custom font under Text Appearance and select MesloLGS NF Regular.

## Content

- neovim
  - packer管理
  - typescriptなど一部のLanguage Serverに対応
- zsh
  - zinit管理
  - p10k
- tmux
- fzf

