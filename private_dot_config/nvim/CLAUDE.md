# Neovim 設定 — 変更と検証フロー

この配下（`~/.config/nvim` に対応、すべて `.lua`）を変更したら、次を順に実行する。
壊れた設定をライブの `~/.config/nvim` に撒かないため、まずソースを検証してから適用する。

## 検証フロー（段階的・安全側）

1. **ソース検証（ライブ環境を変更しない）** — リポジトリルートで `make nvim-check`
   - stylua フォーマットチェック + 全 `.lua` の構文チェック + `edgissa.core` ロード検証
   - 失敗したら修正してから次へ。`~/.config/nvim` には反映しない
2. **差分確認** — `chezmoi diff`
3. **適用** — `chezmoi apply`（`~/.config/nvim` に反映）
4. **（任意・より厚い検証）** 実際に nvim を起動し lazy.nvim のプラグイン同期/エラーを確認。
   ヘルスチェック: `nvim --headless "+checkhealth" "+w! /tmp/nvim-health.log" +qa && cat /tmp/nvim-health.log`
   （プラグイン同期はネットワークが必要）

## メモ

- プラグインマネージャは lazy.nvim。プラグイン追加は `lua/edgissa/plugins/` に
  spec を返す `.lua` を置く（詳細は `docs/neovim.md`）。
- フォーマット規約は repo ルート `.stylua.toml`（120 桁・スペース 2）。
- これらの `.lua` はテンプレートではない（`{{ }}` を書かない）。
- コミット scope は `nvim`。
- doctor 系の不具合修正は `.claude/skills/nvim-doctor-fix.md` を参照。
