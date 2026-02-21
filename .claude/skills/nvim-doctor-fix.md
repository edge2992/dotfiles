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
