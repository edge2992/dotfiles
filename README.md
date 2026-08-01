# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites

| OS | 必要なもの |
|----|-----------|
| Linux (Ubuntu/Debian/Fedora/Amazon Linux 2023/Arch) | Git, curl, sudo 権限 |
| Amazon Linux 2 (EOL済み・ベストエフォート) | 同上。ミラー消滅や古い glibc により一部ツールが入らない場合あり |
| macOS | Git, curl (Xcode CLT で自動インストールされる) |

## Install

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/edge2992/dotfiles.git
```

初期化時に以下の入力を求められます:

- **Email** — Git の `user.email` に使用
- **GitHub username** — Git の `user.name` に使用
- **Install Nerd Fonts** — UbuntuMono Nerd Font を入れるか (デフォルト: No)

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
| 4 | `install-homebrew` | Homebrew 本体のブートストラップのみ | skip | ✓ |
| 5 | `install-linux-packages` | Go, ripgrep, htop, ghq, memo 等 | ✓ | skip |
| 6 | `install-nvim` | Neovim (AppImage) | ✓ | skip |
| 7 | `install-python-tools` | pynvim, uv | ✓ | ✓ |
| 8 | `install-volta` | Volta + Node.js, yarn | ✓ | ✓ |
| - | `install-fzf` | fzf (内容変更時に再実行) | ✓ | ✓ |
| - | `10_brew-bundle` | Brewfile のパッケージを導入 (Brewfile 変更時に再実行) | skip | ✓ |
| - | `install-go-tools` | memo, ccgate, jsonnet (`go install`) | ✓ | ✓ |

> **macOS の注意**: ステップ 1 で Xcode Command Line Tools のインストールダイアログが表示されます。完了後に `chezmoi apply` を再実行してください。

### Homebrew パッケージ (macOS)

macOS の brew パッケージは Brewfile で宣言的に管理します。

```
.chezmoitemplates/Brewfile          共通宣言（全マシン、このリポジトリで管理）
        +
~/.config/brew-overlay/Brewfile     マシン固有・会社固有（任意、リポジトリ外）
        ↓  private_dot_config/homebrew/modify_Brewfile.tmpl が連結
~/.config/homebrew/Brewfile         結合済み
        ↓  run_after_10_brew-bundle.sh が適用
brew bundle install --no-upgrade
```

- **パッケージを追加する**: `.chezmoitemplates/Brewfile` に 1 行足して PR。マージ後の
  `chezmoi apply` で、既に構築済みのマシンにも自動で入ります（`run_once_` 時代の
  「足しても入らない」問題は解消済み）。
- **会社PC だけに入れたい**: `~/.config/brew-overlay/Brewfile` に書きます。ここは
  chezmoi 管理外なので、社内ツール名が公開リポジトリに載りません。Claude settings の
  `~/.config/claude-overlay` と同じ思想です。場所は chezmoi データキー
  `brew_overlay_dir` で変更でき、`~/.config/claude-overlay` を指せば 1 リポジトリに同居できます。
- **バージョンは固定しません**。Brewfile は名前を宣言するだけで、
  `brew bundle install --no-upgrade` は「無ければ入れる」だけです。バージョン更新は
  従来どおり `run_after_upgrade-homebrew.sh` の 7 日スロットルが担当します。
- **ドリフト確認**: `make brew-check` で「宣言したのに入っていないもの」と
  「入っているのに宣言されていないもの」を表示します。削除は行いません
  （`brew bundle cleanup` に `--force` を付けていません）。

### SSH (1Password SSH Agent)

新規端末では、この公開リポジトリを HTTPS のまま `chezmoi init --apply` できます。SSH 鍵をローカルへ展開する必要はありません。

`chezmoi init` 時に `Use 1Password SSH Agent for GitHub?` を聞かれます。`yes` を選ぶと `~/.ssh/config` の `Host github.com` に 1Password SSH Agent のソケットを指す `IdentityAgent` が設定されます（既存設定があればマージされ、重複は作りません）。`no` を選んだ場合、既存の SSH 設定には一切手を加えません。

opt-in 後は、1Password デスクトップアプリで **Settings > Developer > Use the SSH Agent** を有効化し、接続を確認します:

```bash
ssh -T git@github.com
```

秘密鍵は 1Password の SSH Agent ソケット経由で利用され、ローカルのファイルへは展開されません。

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
- **[Claude Code グローバル設定](docs/claude-global-config.md)** — `dot_claude/` で管理する Claude の設定・スキル・エージェント・フックの概要
