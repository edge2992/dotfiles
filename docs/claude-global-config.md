# Claude Code グローバル設定

このリポジトリは [Claude Code](https://docs.claude.com/claude-code) のグローバル
設定（ユーザーの `~/.claude/`）も chezmoi 管理下に置いている。ソースは
`dot_claude/` 配下にあり、`chezmoi apply` で `~/.claude/` に展開される。

> **編集フロー**: `dot_claude/` を編集してもソースが変わるだけ。実機の
> `~/.claude/` に反映されるのは **PR マージ後の `chezmoi apply`** 時点
> （ルート [`CLAUDE.md`](../CLAUDE.md) の Workflow / Standing rule を参照）。

## ディレクトリ構成

```
dot_claude/
├── CLAUDE.md            # 全プロジェクト共通のグローバルガイドライン
├── settings.json       # Claude Code 本体の設定
├── statusline.py       # ステータスライン表示スクリプト
├── agents/             # カスタムサブエージェント定義
├── hooks/              # ライフサイクルフック（シェルスクリプト）
├── skills/             # カスタムスキル（SKILL.md）
└── private_plugins/    # プラグイン設定（config.json）
```

## グローバルガイドライン（`dot_claude/CLAUDE.md`）

全プロジェクトに効くエージェントの行動規範。プロジェクト固有のルールは各
リポジトリの `CLAUDE.md` 側に置く。要点:

- **言語**: 英語で思考し、日本語で応答する
- **ライブラリ参照**: 実装前に Context7 MCP で最新ドキュメントを確認する
- **Worktree 分離**: 機能開発・バグ修正は常に git worktree で行い、main では作業しない
- **エージェント駆動**: サブエージェント・並列実行を積極活用し、main コンテキストを汚さない
- **PR 駆動**: フィーチャーブランチへの commit / push、PR 作成は確認なしで行う
- **完了前の検証**: 動作を証明せずにタスクを完了扱いにしない
- **Commit 規約**: [Conventional Commits](https://www.conventionalcommits.org/)
  （`<type>(<scope>): <subject>`、subject ≤50 字・命令形）

## 本体設定（`dot_claude/settings.json`）

| 項目 | 値 | 説明 |
| --- | --- | --- |
| `model` | `opus` | 既定モデル |
| `alwaysThinkingEnabled` | `true` | 拡張思考を常時有効化 |
| `effortLevel` | `high` | 推論の労力レベル |
| `defaultMode`（permissions） | `plan` | 既定でプランモード起動 |
| `language` | `japanese` | 応答言語 |
| `editorMode` | `vim` | エディタ操作系 |
| `tui` | `fullscreen` | フルスクリーン TUI |
| `cleanupPeriodDays` | `60` | 履歴の保持日数 |
| `attribution` | 空 | commit / PR への Claude 署名を無効化 |

### Permissions

最小権限ベースで、読み取り・Markdown 書き込み・主要な git/gh コマンド・検索系
（`grep`/`rg`/`fd`）・`make`/`shellcheck`・各種 MCP を **allow**。破壊的操作は
**deny**（`sudo`、`git push --force`、`git reset --hard`、`git rebase`、
`chezmoi destroy`/`purge`、`.env` や秘密鍵の読み取り）。`gh pr create` と
`gh pr merge` のみ実行前に **ask**。

### Hooks（`dot_claude/hooks/`）

`~/.claude/hooks/` に展開され、`settings.json` の `hooks` で結線される。

| イベント | スクリプト | 役割 |
| --- | --- | --- |
| `Notification`（permission_prompt） | `permission-notify.sh` | 権限プロンプト時に通知 |
| `Stop` | `stop-review.sh` | 応答終了時に未コミット変更などをレビュー喚起 |
| `SessionEnd` | `worklog.sh` | セッション終了時に作業ログを記録 |

### Agents（`dot_claude/agents/`）

| エージェント | 用途 |
| --- | --- |
| `code-reviewer` | 品質・セキュリティ・保守性のコードレビュー |
| `research-coordinator` | 横断的な調査を分解し並列サブエージェントへ委譲 |
| `search-specialist` | 高度な検索技法を用いた Web リサーチ |

### Skills（`dot_claude/skills/`）

リポジトリ管理のカスタムスキル: `auto-commit`、`commit`、`consult`、`deep`、
`ultra-think`。各 `SKILL.md` で定義。

### Plugins

`enabledPlugins` で公式マーケットプレイス等のプラグインを有効化:
`claude-code-setup`、`claude-md-management`、`code-review`、`commit-commands`、
`context7`、`document-skills`、`gopls-lsp`、`skill-creator`、`superpowers`。

## 関連

- ルート [`CLAUDE.md`](../CLAUDE.md) — このリポジトリ自体の作業ルール（chezmoi 命名規則・PR ワークフロー）
- [Getting Started](getting-started.md) — chezmoi の仕組みとファイル構造
