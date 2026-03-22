# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites

| OS | 必要なもの |
|----|-----------|
| Linux (Ubuntu/Debian/Fedora/Arch) | Git, curl, sudo 権限 |
| macOS | Git, curl (Xcode CLT で自動インストールされる) |

## Install

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/edge2992/dotfiles.git
```

初期化時に以下の入力を求められます:

- **Email** — Git の `user.email` に使用
- **GitHub username** — Git の `user.name` に使用

### インストール後

インストール直後はPATHが反映されていません。新しいシェルを開くか、以下を実行してください:

```bash
source ~/.zshenv
```

### インストールフロー

`chezmoi init --apply` を実行すると、以下のスクリプトが順番に実行されます:

| 順序 | スクリプト | 内容 | Linux | macOS |
|:---:|-----------|------|:-----:|:-----:|
| 1 | `install-build-deps` | C コンパイラ、OpenSSL ヘッダ等のビルド依存 | ✓ | Xcode CLT |
| 2 | `install-cargo` | Rust ツールチェイン + sheldon, eza, starship, atuin | ✓ | skip |
| 3 | `install-fonts` | Nerd Fonts (UbuntuMono) | ✓ | ✓ |
| 4 | `install-homebrew` | Homebrew + sheldon, eza, starship, atuin 等 | skip | ✓ |
| 5 | `install-linux-packages` | Go, ripgrep, htop, ghq, memo 等 | ✓ | skip |
| 6 | `install-nvim` | Neovim (AppImage) | ✓ | skip |
| 7 | `install-python-tools` | pynvim, uv | ✓ | ✓ |
| 8 | `install-volta` | Volta + Node.js, yarn | ✓ | ✓ |
| - | `install-fzf` | fzf (内容変更時に再実行) | ✓ | ✓ |

> **macOS の注意**: ステップ 1 で Xcode Command Line Tools のインストールダイアログが表示されます。完了後に `chezmoi apply` を再実行してください。

## Update

```bash
chezmoi update
```

設定テンプレートに新しい変数が追加された場合:

```bash
chezmoi update --init
```

## What's Included

| カテゴリ | ツール | 概要 |
|---------|--------|------|
| Shell | Zsh + [sheldon](https://github.com/rossmacarthur/sheldon) + [starship](https://starship.rs/) + [fzf](https://github.com/junegunn/fzf) + [atuin](https://atuin.sh/) | プラグイン管理、プロンプト、ファジー検索、履歴管理 |
| Editor | [Neovim](https://neovim.io/) + [lazy.nvim](https://github.com/folke/lazy.nvim) | LSP、補完、フォーマッタ、Git 連携 |
| Terminal | [Tmux](https://github.com/tmux/tmux) + TPM | セッション管理、ペイン分割 |
| Git | gitconfig + [gitsigns](https://github.com/lewis6991/gitsigns.nvim) + [diffview](https://github.com/sindrets/diffview.nvim) | 署名、差分表示、hunk 操作 |
| AI | [GitHub Copilot](https://github.com/features/copilot) + [Claude CLI](https://docs.anthropic.com/en/docs/claude-cli) | コード補完、AI 開発ワークフロー |

## Documentation

- **[Getting Started](docs/getting-started.md)** — chezmoi の仕組み、ファイル構造、拡張方法
- **[Neovim Guide](docs/neovim.md)** — プラグイン一覧、各プラグインの役割と使い方
- **[Keybindings](docs/keybindings.md)** — Neovim / Tmux / Zsh のキーバインド一覧
- **[Troubleshooting](docs/troubleshooting.md)** — よくある問題と解決方法
