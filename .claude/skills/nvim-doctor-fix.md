# Neovim Doctor Fix Skill

このskillは、Neovim doctorで検出された問題を修正するためのコマンドを提供します。

## 概要

Neovim doctorの結果に基づいて、以下の問題を修正します：
1. システムlocaleの生成（UTF-8サポート）
2. Python pynvimモジュールのインストール
3. ripgrepのシステムインストール

## 修正コマンド

以下のコマンドを順番に実行してください：

### 1. システムlocaleの生成

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

### 2. Python pynvimのインストール

```bash
sudo apt update
sudo apt install -y python3-pynvim
```

### 3. ripgrepのインストール

```bash
sudo apt install -y ripgrep
```

### 4. 修正の確認

すべてのコマンドを実行した後、Neovim doctorを再実行して確認：

```bash
nvim --headless "+checkhealth" "+w! /tmp/nvim-health.log" +qa && cat /tmp/nvim-health.log
```

## 注意事項

- これらのコマンドはsudo権限が必要です
- インストール後、新しいシェルセッションを開始するか、`source ~/.zshenv`を実行してください
- tmuxを使用している場合は、tmuxセッションを再起動してください

## オプション設定（警告を無効化）

Perl、Ruby providerの警告を無効にしたい場合は、以下を`~/.config/nvim/init.lua`の先頭に追加：

```lua
-- Disable optional providers to suppress warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
```

## Node.js provider のyarnエラーについて

Node.js providerで「Failed to run: yarn info neovim --json」というエラーが表示される場合：

### 解決方法1: シェルセッションを再起動

```bash
# tmuxを使用している場合
tmux kill-session
# 新しいtmuxセッションを開始

# またはシンプルに新しいzshセッションを開始
exec zsh
```

### 解決方法2: Node.js providerを無効化（使用しない場合）

`~/.config/nvim/lua/edgissa/core/options.lua`に以下を追加：

```lua
vim.g.loaded_node_provider = 0
```

## pynvim バージョン警告について

pynvimのバージョンが古い（0.5.0）という警告が表示される場合、これは通常の動作には影響しません。最新バージョン（0.6.0）が必要な場合は、以下のコマンドでアップグレードできます：

```bash
# pipxを使用（推奨）
pipx install pynvim
# Neovimに使用するPythonを明示的に設定
# ~/.config/nvim/lua/edgissa/core/options.luaに追加:
# vim.g.python3_host_prog = vim.fn.expand('~/.local/pipx/venvs/pynvim/bin/python')
```

ただし、0.5.0でもほとんどの機能は正常に動作します。
