# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites

- Git
- curl
- Linux (Ubuntu/Debian)

## Install

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/edge2992/dotfiles.git
```

初期化時に以下の入力を求められます:

- **Email** — Git の `user.email` に使用
- **GitHub username** — Git の `user.name` に使用

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
