# トラブルシューティング

## chezmoi

### `chezmoi apply` でエラーが出る

テンプレートの変数が未定義の場合に発生します。

```bash
# テンプレートの出力を確認
chezmoi execute-template < dot_zshrc.tmpl

# データの確認
chezmoi data
```

データが足りない場合は `~/.config/chezmoi/chezmoi.toml` を編集するか、再初期化します:

```bash
chezmoi init --prompt
```

### `run_once` スクリプトを再実行したい

`run_once_` スクリプトは一度だけ実行されます。再実行するにはスクリプトの内容を変更する（コメントを追加するなど）か、chezmoi の状態をリセットします:

```bash
# 状態データベースの場所を確認
chezmoi state dump
```

## Neovim

### プラグインが読み込まれない

lazy.nvim がプラグインをインストールしているか確認します:

```vim
:Lazy
```

`Lazy` ウィンドウで `I` を押すと未インストールのプラグインをインストールできます。
`U` でプラグインを更新します。

### LSP サーバーが動作しない

1. mason でインストール状態を確認:
   ```vim
   :Mason
   ```

2. LSP の動作状態を確認:
   ```vim
   :LspInfo
   ```

3. 対象言語のファイルを開いた状態で LSP が起動しない場合、mason で対応サーバーをインストール:
   ```vim
   :MasonInstall <server_name>
   ```

### treesitter のパーサーエラー

パーサーの再インストールで解消することがあります:

```vim
:TSUpdate
```

特定言語のパーサーを再インストール:

```vim
:TSInstall! lua
```

### フォーマッタが動作しない

1. conform.nvim の設定を確認:
   ```vim
   :ConformInfo
   ```

2. フォーマッタがインストールされているか確認:
   ```vim
   :Mason
   ```
   対応するフォーマッタ (prettier, stylua など) が `installed` になっているか確認してください。

### `:checkhealth` で問題を特定する

Neovim には組み込みのヘルスチェック機能があります:

```vim
:checkhealth             " 全体チェック
:checkhealth lazy        " lazy.nvim のチェック
:checkhealth mason       " mason のチェック
:checkhealth lspconfig   " LSP のチェック
```

## Tmux

### プラグインが読み込まれない

TPM (Tmux Plugin Manager) がインストールされているか確認:

```bash
ls ~/.tmux/plugins/tpm
```

なければインストール:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

その後、tmux 内で `Prefix + I` でプラグインをインストールします。

### 256色が表示されない

`$TERM` の設定を確認してください。`dot_tmux.conf` で `screen-256color` に設定していますが、ターミナルエミュレータ側でも True Color 対応が必要です。

```bash
echo $TERM
# screen-256color であることを確認
```

## Zsh

### sheldon のプラグインが読み込まれない

sheldon がインストールされているか確認:

```bash
command -v sheldon
```

インストールされていれば、プラグインのロック状態を更新:

```bash
sheldon lock
```

### fzf と Atuin の Ctrl+R が競合する

`dot_zshrc.tmpl` 内の init 順序が重要です。Atuin は fzf の後に初期化される必要があります:

```
fzf     → Ctrl+R を登録
atuin   → Ctrl+R を上書き（Atuin が優先される）
```

現在の設定ではこの順序が守られています。もし Atuin が動作しない場合は `dot_zshrc.tmpl` の init 順序を確認してください。

### Nerd Font のアイコンが表示されない

ターミナルのフォント設定で Nerd Font を指定する必要があります:

1. インストール済みフォントを確認:
   ```bash
   fc-list | grep -i nerd
   ```

2. ターミナルエミュレータの設定で「UbuntuMono Nerd Font」を選択
