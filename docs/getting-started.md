# Getting Started

このリポジトリは [chezmoi](https://www.chezmoi.io/) で管理された dotfiles です。
chezmoi を使うと、設定ファイルをテンプレート化して複数マシン間で安全に同期できます。

## chezmoi の基本概念

chezmoi は **ソースディレクトリ** (`~/.local/share/chezmoi/`) にある設定ファイルを **ターゲットディレクトリ** (`~/`) にコピー・展開します。

```
ソース (このリポジトリ)              ターゲット (ホームディレクトリ)
~/.local/share/chezmoi/              ~/
├── dot_zshrc.tmpl          →        .zshrc
├── dot_gitconfig.tmpl      →        .gitconfig
├── private_dot_config/     →        .config/
│   └── nvim/               →        .config/nvim/
└── run_once_install-*.sh   →        (初回のみ実行されるスクリプト)
```

## ファイル命名規則

chezmoi はファイル名のプレフィックスで動作を制御します。

| プレフィックス/サフィックス | 意味 | 例 |
|---|---|---|
| `dot_` | `.` に変換 | `dot_zshrc` → `~/.zshrc` |
| `private_` | パーミッション 600/700 で配置 | `private_dot_config/` → `~/.config/` |
| `run_once_` | 初回 apply 時に一度だけ実行 | `run_once_install-packages.sh` |
| `run_onchange_` | 内容変更時に実行 | `run_onchange_update.sh` |
| `.tmpl` サフィックス | Go テンプレートとして処理 | `dot_zshrc.tmpl` → `~/.zshrc` |
| `exact_` | ターゲットの未管理ファイルを削除 | `exact_dot_config/` |

> 参考: [chezmoi - Source state attributes](https://www.chezmoi.io/reference/source-state-attributes/)

## テンプレート構文

`.tmpl` で終わるファイルは Go テンプレートとして処理されます。

```
# OS ごとの条件分岐
{{ if eq .chezmoi.os "linux" }}
sudo apt install -y fzf
{{ end }}

# ユーザーデータの参照
git config --global user.email "{{ .email }}"
```

テンプレートデータは `~/.config/chezmoi/chezmoi.toml` で定義され、`chezmoi init` 時に対話的に設定されます。

## よく使うコマンド

```bash
# 変更のプレビュー（適用前に差分を確認）
chezmoi diff

# 設定を適用
chezmoi apply

# ファイルを編集（chezmoi がソースファイルを開く）
chezmoi edit ~/.zshrc

# 新しいファイルを chezmoi 管理下に追加
chezmoi add ~/.new-config

# テンプレート付きで追加
chezmoi add --template ~/.zshrc

# リモートから更新を取得して適用
chezmoi update
```

## 新しい設定ファイルを追加する

1. ホームディレクトリにファイルを作成・編集
2. chezmoi に追加:
   ```bash
   chezmoi add ~/.config/some-tool/config.toml
   ```
3. 差分を確認:
   ```bash
   chezmoi diff
   ```
4. 問題なければコミット:
   ```bash
   cd ~/.local/share/chezmoi
   git add -A && git commit -m "feat: add some-tool config"
   git push
   ```

## テンプレートを使いたい場合

マシンごとに値が変わる設定（メールアドレス、OS 固有のパスなど）はテンプレートを使います。

```bash
# 既存ファイルをテンプレートに変換
chezmoi chattr +template ~/.gitconfig

# テンプレートの出力を確認
chezmoi execute-template < dot_gitconfig.tmpl
```

> 詳しくは [chezmoi - Templating](https://www.chezmoi.io/user-guide/templating/) を参照。

## リポジトリ構造

```
.
├── README.md                      # 概要とインストール方法
├── docs/                          # 詳細ドキュメント
├── dot_zshrc.tmpl                 # Zsh 設定
├── dot_zshenv                     # Zsh 環境変数
├── dot_gitconfig.tmpl             # Git 設定
├── dot_tmux.conf                  # Tmux 設定
├── dot_ideavimrc                  # IntelliJ IdeaVim 設定
├── dot_claude/                    # Claude CLI 設定
├── dot_atuin/                     # Atuin (シェル履歴) 設定
├── private_dot_config/            # ~/.config/ 配下の設定
│   ├── nvim/                      # Neovim (→ docs/neovim.md)
│   ├── sheldon/                   # Zsh プラグイン管理
│   └── starship.toml              # プロンプト設定
└── run_once_install-*.sh.tmpl     # 初回セットアップスクリプト
```
