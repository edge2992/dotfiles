# Claude ワークフロースイート設計

日付: 2026-07-10
ステータス: 承認済み(方向性はユーザー承認、細部は自律判断で確定)

## 背景・目的

会社では Sonnet/Haiku のみ(Opus 不可)で日々 $50〜100 のコストをかけて、
既存基幹システムの仕様調査・運用・AWS 関連の開発を行っている。ツールは
GHES / Slack / Datadog / Confluence / Jira(AWS・Datadog・Atlassian は MCP 接続済み、
Slack MCP は設定済みだが未活用)。dot_claude は chezmoi で会社マシンにも配布済みで、
会社差分は jsonnet オーバーレイ(PR #128)が稼働中。

3本柱ロードマップの柱1(worklog + メトリクス収集、PR #93/#129)は完成しており、
蓄積したデータを使う側が存在しない。本設計はその「使う側」を整備し、
feedback ループを閉じることを目的とする:

1. **仕様調査の型化** — Confluence/Jira/コードを横断調査して構造化レポートを蓄積
2. **times 共有の低コスト化** — 作業ログ要約を個人 times へ手軽に投稿(Slack MCP 活用)
3. **使い方の振り返りループ** — worklog メトリクスから環境改善案を定期的に出す
4. **日々のタスク見定め** — 朝のプランニング支援

「タスク実行中の回し方改善」は独立成果物にせず、spec-research(調査→検証→
レポートの型)と retro(摩擦点検出)に折り込む。

## 全体方針

- `dot_claude/skills/` にポータブルスキルを4つ追加。**1スキル = 1PR** で段階導入
- 会社専用リソース(Slack/Jira MCP 等)は**実行時に存在チェック**し、無ければ縮退。
  マシン固有値(times チャンネル等)は env 変数で注入し、リポジトリには入れない
- モデル戦略: メインはセッションモデル(会社では Sonnet)。広く浅い掃き出しは
  `model: haiku` のサブエージェントへファンアウトし、統合はメインが行う(コスト最適化)
- 既存資産を再利用する:
  - worklog 形式: `dot_claude/hooks/executable_worklog.sh` が書く
    `$CLAUDE_WORKLOG_DIR/YYYY-MM-DD.md`(セクション `## HH:MM repo (branch)`、
    依頼/問いかけ/結果、Metrics/Tokens 行)
  - エージェント: `research-coordinator`(sonnet)、`search-specialist`(haiku)、Explore
  - env: `$OBSIDIAN_VAULT` / `$CLAUDE_WORKLOG_DIR`(`dot_zshenv.tmpl` L39-42、
    vault が無いホストでは未定義)
- スキル書式は既存の `dot_claude/skills/deep/SKILL.md` に合わせる
  (frontmatter は `description` + `argument-hint`、本文は手順+品質基準+アンチパターン、
  出力は日本語)

## コンポーネント設計

### 1. `/times` — 作業ログの times 投稿(手動)

- **入力**: 任意の補足メッセージ / 期間(省略時: 本日)
- **処理**:
  1. `$CLAUDE_WORKLOG_DIR` の当日(指定があればその期間)の worklog と、
     カレントリポジトリの当日のコミットを読む
  2. times 口調(カジュアル、一人称、箇条書き 2〜5 点、絵文字控えめ)の投稿案を生成
  3. **必ず AskUserQuestion で確認**(投稿 / 編集 / やめる)。無確認送信はしない
  4. 送信: ToolSearch で Slack MCP の投稿ツールを探し、`$SLACK_TIMES_CHANNEL` へ投稿
- **縮退**: Slack MCP が無い、または `$SLACK_TIMES_CHANNEL` 未設定なら、投稿文を
  表示してクリップボードへコピー(pbcopy/wl-copy/xclip の順で検出)。env 未設定の場合は
  シェル設定(会社ローカルの zshenv)への追加方法を案内する
- **非スコープ**: 自動投稿(SessionEnd フック化)は今回やらない — 手動で型が
  固まってから検討

### 2. `/spec-research` — 既存システム仕様調査

- **入力**: 調査対象(システム名・機能・質問)。曖昧なら着手前に絞り込みを質問
- **処理**: 利用可能なソースへ並列ファンアウト(各ソースは存在チェック付き):
  - Confluence(`mcp__mcp-atlassian__confluence_search` → `confluence_get_page`)
  - Jira(`jira_search` で関連チケット・経緯)
  - コード(`research-coordinator` / Explore サブエージェント、breadth は haiku)
  - AWS(`mcp__aws-mcp__aws___call_aws`、インフラが関わる場合)
  - Datadog(実行時挙動・依存関係が論点の場合)
  - サブエージェントには「結論のみ返す」を必ず指示
- **出力**: 構造化レポート
  (対象概要 / 仕様の要点 / データフロー・依存関係 / 根拠リンク一覧 /
  **未確認事項と検証方法** / 次のアクション)
- **保存**: `$OBSIDIAN_VAULT/claude/research/YYYY-MM-DD-<slug>.md`。
  vault が無ければ表示のみ+保存先の選択肢を提示
- **回し方の型**: 「未確認事項と検証方法」セクションが次サイクルの入力になる
  (調査→検証→再調査のループを明示的に支援)

### 3. `/kickoff` — 朝のタスク見定め

- **入力**: なし(任意で「今日は◯◯を優先したい」等の文脈)
- **処理**: 利用可能なソースから並列収集(各ソースは存在チェック付き、haiku ファンアウト):
  - Jira: 自分にアサインされた未完了チケット(`jira_search`、
    `assignee = currentUser() AND statusCategory != Done`)
  - worklog: 昨日・今日のエントリから未完タスク・中断作業を抽出
  - Slack: メンション・未読(MCP があれば)
  - カレンダー(MCP があれば。会社に無ければ自然にスキップ)
- **出力**: 優先度付き Top 3〜5(それぞれ理由と「最初の一手」付き)。
  会議までの空き時間を考慮した並び順。表示のみ(ノート書き込みはしない — YAGNI)

### 4. `/retro` — Claude 使い方の振り返り

- **入力**: 期間(省略時: 直近 7 日)
- **処理**:
  1. `$CLAUDE_WORKLOG_DIR` の期間内ファイルを読み、メトリクスを集計
     (セッション数・リポジトリ別内訳・問いかけ数・AskUserQuestion・
     ツールエラー・許可プロンプト・トークン)
  2. 摩擦点を分析:
     - 許可プロンプトが多い → allowlist 追加候補(`claude-settings-base.json` への diff 案)
     - 繰り返し同じ指示・問いかけをしている → CLAUDE.md ルール化 / スキル化候補
     - ツールエラーが多いセッション → フック・設定の修正候補
     - トークン消費が大きいパターン → サブエージェント委譲・haiku 化候補
  3. レポートを `$OBSIDIAN_VAULT/claude/retro/YYYY-MM-DD-retro.md` に保存
     (vault 無しなら表示のみ)
- **出力**: メトリクスサマリ + 改善提案リスト(chezmoi リポジトリへの具体 diff 案)。
  **提案の実装はユーザー確認後**(このスキルは提案まで。勝手に設定を変えない)
- worklog 形式が将来変わっても壊れないよう、パースは緩く(セクション見出しと
  `- Metrics:` / `- Tokens:` 行のベストエフォート抽出)

### 5. 基盤整備(foundation PR)

- `.chezmoitemplates/claude-settings-base.json` の `permissions.allow` に
  mcp-atlassian の **Jira 読み取り専用ツール**を追加(既存の confluence_* と同列):
  `jira_search`, `jira_get_issue`, `jira_get_all_projects`, `jira_get_project_issues`,
  `jira_get_worklog`, `jira_get_transitions`, `jira_search_fields`,
  `jira_get_agile_boards`, `jira_get_board_issues`, `jira_get_sprints_from_board`,
  `jira_get_sprint_issues`, `jira_get_user_profile`, `jira_get_link_types`
  (sooperset/mcp-atlassian の命名。存在しない名前はマッチしないだけで無害)
- Slack MCP の allow は追加しない — 会社のサーバ名が不明なため。初回は許可プロンプトで
  対応し、`/retro` が allowlist 候補として拾い上げる(ループが自分自身を改善する)
- 本設計ドキュメントと実装プランもこの PR に含める

## エラー処理・縮退の原則

- MCP ツールは呼ぶ前に ToolSearch / 定義済みツール一覧で存在確認。無ければ
  そのソースをスキップし、レポートに「未使用ソース」として明記(無言で欠落させない)
- env 変数(`CLAUDE_WORKLOG_DIR` / `OBSIDIAN_VAULT` / `SLACK_TIMES_CHANNEL`)未設定時は
  機能を縮退し、設定方法を一行案内
- 外部送信(Slack 投稿)は必ず事前確認。それ以外の操作は読み取りのみ

## テスト・検証

- `make lint` が通ること(全 PR 共通、コミット前必須)
- `chezmoi diff --source <worktree>` で配布結果を確認(apply はマージ後)
- スキル書式: frontmatter が `description` / `argument-hint` を持ち、
  `dot_claude/skills/<name>/SKILL.md` に配置されている
- 手動検証(個人マシン): `/times` と `/retro` は worklog 実データで縮退パスまで動作確認。
  `/spec-research` `/kickoff` の会社 MCP 依存部は縮退パスのみ確認(会社マシンで後日実測)

## PR 分割と導入順

| # | ブランチ | 内容 |
|---|---------|------|
| 1 | `feat/claude-workflow-foundation` | 本設計・プラン docs + Jira 読み取り permissions |
| 2 | `feat/claude-skill-times` | `dot_claude/skills/times/SKILL.md` |
| 3 | `feat/claude-skill-spec-research` | `dot_claude/skills/spec-research/SKILL.md` |
| 4 | `feat/claude-skill-kickoff` | `dot_claude/skills/kickoff/SKILL.md` |
| 5 | `feat/claude-skill-retro` | `dot_claude/skills/retro/SKILL.md` |

各 PR はファイルが互いに素なので並行開発・独立マージ可能。
マージ後に `chezmoi apply` を該当パスに絞って実行する(リポジトリの標準フロー)。
