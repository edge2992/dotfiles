# Neovim 設定ガイド

この Neovim 設定は Lua で書かれており、[lazy.nvim](https://github.com/folke/lazy.nvim) でプラグインを管理しています。

## 設定の構造

```
~/.config/nvim/
├── init.lua                       # エントリポイント（core と lazy を読み込む）
└── lua/edgissa/
    ├── core/
    │   ├── init.lua               # core モジュールのローダー
    │   ├── options.lua            # エディタの基本設定
    │   └── keymaps.lua            # グローバルキーマップ
    ├── lazy.lua                   # lazy.nvim のセットアップ
    └── plugins/                   # プラグイン設定（自動読み込み）
        ├── init.lua               # 基本プラグイン (plenary.nvim)
        ├── treesitter.lua         # シンタックスハイライト・テキストオブジェクト
        ├── telescope.lua          # ファジーファインダー
        ├── neo-tree.lua           # ファイルエクスプローラー
        ├── cmp.lua                # 自動補完
        ├── copilot.lua            # GitHub Copilot
        ├── gitsigns.lua           # Git 差分表示・操作
        ├── diffview.lua           # Git diff ビューア
        ├── lualine.lua            # ステータスライン
        ├── which-key.lua          # キーバインドヘルプ
        ├── autopairs.lua          # 括弧の自動補完
        ├── vim-commentary.lua     # コメントトグル
        ├── formatting.lua         # フォーマッタ (conform.nvim)
        ├── linting.lua            # リンター (nvim-lint)
        └── lsp/
            ├── mason.lua          # LSP サーバー・ツールの管理
            └── lspconfig.lua      # LSP クライアント設定
```

## プラグイン一覧と役割

### ファイル操作・ナビゲーション

| プラグイン | 何ができるか | 起動方法 |
|-----------|-------------|---------|
| **telescope.nvim** | ファイル検索、テキスト検索、バッファ切替などのファジーファインダー | `<leader>ff` など |
| **neo-tree.nvim** | サイドバー型のファイルエクスプローラー。ファイルの作成・削除・リネームが可能 | `<leader>e` |

### コーディング支援

| プラグイン | 何ができるか | 備考 |
|-----------|-------------|------|
| **nvim-treesitter** | 構文解析ベースのシンタックスハイライト、インデント、テキストオブジェクト | 14言語対応 |
| **nvim-cmp** | 入力中の自動補完（LSP、バッファ、パス） | `<C-n>`/`<C-p>` で選択 |
| **copilot.vim** | GitHub Copilot による AI コード補完 | 自動で提案が表示される |
| **nvim-autopairs** | 括弧・クォートの自動ペアリング | 自動 |
| **vim-commentary** | コメントのトグル | `gcc` (行), `gc` (選択範囲) |

### LSP (Language Server Protocol)

LSP はエディタに「コードの理解力」を与える仕組みです。定義ジャンプ、補完、エラー表示などが可能になります。

| プラグイン | 何ができるか |
|-----------|-------------|
| **nvim-lspconfig** | LSP クライアントの設定テンプレート |
| **mason.nvim** | LSP サーバー・リンター・フォーマッタのインストール管理 |
| **mason-lspconfig.nvim** | mason と lspconfig の連携 |

#### 対応 LSP サーバー

mason.lua の `ensure_installed` で自動インストールされます:

| サーバー | 言語 |
|---------|------|
| `lua_ls` | Lua |
| `ts_ls` | TypeScript / JavaScript |
| `rust_analyzer` | Rust (clippy 連携あり) |
| `pyright` | Python |
| `gopls` | Go |
| `bashls` | Bash |
| `jsonls` | JSON |
| `cssls` | CSS |
| `html` | HTML |
| `dockerls` | Dockerfile |
| `sqlls` | SQL |
| `zls` | Zig |

### フォーマッタ・リンター

| プラグイン | 何ができるか |
|-----------|-------------|
| **conform.nvim** | ファイル保存時に自動フォーマット。`<leader>cf` で手動実行も可能 |
| **nvim-lint** | ファイル保存時にリンターを実行 |

対応ツール（mason.lua で自動インストール）:

| ツール | 対象 | 種別 |
|-------|------|------|
| prettier | JS/TS/CSS/HTML/JSON/YAML/Markdown | フォーマッタ |
| stylua | Lua | フォーマッタ |
| shfmt | Shell | フォーマッタ |
| black | Python | フォーマッタ |
| isort | Python (import 整理) | フォーマッタ |
| goimports | Go | フォーマッタ |
| shellcheck | Shell | リンター |
| eslint_d | JS/TS | リンター |

### Git 連携

| プラグイン | 何ができるか | 起動方法 |
|-----------|-------------|---------|
| **gitsigns.nvim** | 変更行のサイン表示、hunk 操作 (stage/reset/preview) | `]h`/`[h` で移動 |
| **diffview.nvim** | side-by-side の diff ビュー、ファイル履歴 | `<leader>gd` |

### UI

| プラグイン | 何ができるか |
|-----------|-------------|
| **lualine.nvim** | 画面下部のステータスライン。モード・ファイル名・Git ブランチ等を表示 |
| **which-key.nvim** | `<leader>` を押した後にキーバインドの候補を表示 |
| **nvim-web-devicons** | ファイルタイプに応じたアイコン表示 |

## プラグインの追加方法

1. `private_dot_config/nvim/lua/edgissa/plugins/` に Lua ファイルを作成
2. lazy.nvim のプラグインスペックを `return { ... }` で返す
3. lazy.nvim が `plugins/` ディレクトリを自動スキャンして読み込む

例: 新しいプラグイン `example.lua` を追加する場合:

```lua
-- private_dot_config/nvim/lua/edgissa/plugins/example.lua
return {
  "author/plugin-name",
  event = "VeryLazy",        -- 遅延読み込み（起動高速化）
  config = function()
    require("plugin-name").setup({
      -- 設定
    })
  end,
}
```

キーバインドの詳細は [docs/keybindings.md](keybindings.md) を参照してください。
