---
name: zsh-tips
description: Add or curate the zsh startup tip rotation (private_dot_config/zsh/tips.txt) in this dotfiles repo. Use this whenever the user wants more shell tips or to grow the startup tip pool — phrases like 「tip増やして」「zshのtip追加して」「便利コマンド集に足して」「起動メッセージのバリエーション増やして」, or just "add some zsh tips". It reads tips.txt plus the repo's real aliases/functions/tools and appends new, non-duplicate, correctly-formatted tips. Always prefer this over hand-writing tips, so the format and dedup stay consistent.
argument-hint: [number of tips and/or a theme, e.g. "5 git tips"]
---

# zsh 起動Tip メンテナンス

この dotfiles リポジトリには zsh 起動時にランダムな便利Tipを1件表示する仕組みが
ある（`private_dot_config/zsh/tips.zsh` が `tips.txt` を読んで表示）。この skill は
その **Tipプール (`tips.txt`) を育てる**ためのもの。表示ロジックには触れない。

肝は「実在するものだけを、重複なく、正しい形式で足す」こと。汎用的なシェル豆知識を
並べるのではなく、**このユーザーが実際に使える** alias / 関数 / 導入済みツールに
根ざした Tip を作るのが価値になる（だから起動時に出して役立つ）。

## データ形式

`tips.txt` は1行1Tip、パイプ区切りの3フィールド:

```
category|trigger|description
```

- `category`: `zsh` / `git` / `tool` のいずれか（表示色がカテゴリで変わる）
- `trigger`: コマンド名や alias。実在するものだけ（例 `gb`, `gwta <path>`, `mdp`）
- `description`: 日本語1行の簡潔な説明
- 区切りは**最初の2つの `|` だけ**。`description` 内に `|` を含めてよい
  （例: `zsh|ask|claude -p をワンショット。\`cmd | ask 質問\` で文脈も渡せる`）
- `#` 始まりの行と空行は無視される

## ワークフロー

### 1. 既存を読んで把握する

`private_dot_config/zsh/tips.txt` を読み、フォーマットと**既存の trigger 一覧**を
頭に入れる。新しい Tip は既存 trigger と重複させない。

### 2. 真実の源から素材を集める

Tip は次の実ファイルに**実在する**ものだけから作る（推測で書かない）:

- `private_dot_config/zsh/functions.zsh` — 自作関数（`gb` `glog` `gpr` `gst`
  `mdp` `sshf` `ask` など）
- `private_dot_config/zsh/aliases.zsh.tmpl` — alias（`g` `vim` `cw` `vlast`
  `gwt`/`gwta`/`gwtr` `ma` など）
- `private_dot_config/zsh/plugins.zsh` — 導入ツール（fzf, atuin, starship,
  direnv など）

git/gh ワークフローやツール一般の Tip を足す場合も、このリポジトリ/環境で実際に
使える範囲に留める。ユーザーがテーマ（例「git のTipだけN個」）を指定したら従う。

### 3. 生成して追記する

`category|trigger|description` 形式で指定件数（デフォルト5件程度）を生成し、
`tips.txt` の**末尾に追記**する。

- 日本語・1行・簡潔
- 既存 trigger と重複させない
- 末尾に空白を付けない（pre-commit の trailing-whitespace で弾かれる）
- 関連カテゴリの既存ブロックの近くに置くと読みやすいが、末尾追記でも可

### 4. 検証する

追記後、最低限これを確認する:

```bash
# フィールド不足の行（description 内の | は許容なので NF<3 だけが異常）
grep -vE '^[[:space:]]*(#|$)' tips.txt | awk -F'|' 'NF<3{print "BAD:",$0}'
# trigger 重複
grep -vE '^[[:space:]]*(#|$)' tips.txt | awk -F'|' '{print $2}' | sort | uniq -d
```

両方とも出力が空なら健全。可能なら実表示も確認:

```bash
zsh -c 'source private_dot_config/zsh/tips.zsh; tip private_dot_config/zsh/tips.txt'
```

### 5. chezmoi フローを守る

ここで触るのは chezmoi **ソース**だけ。`chezmoi apply` はしない
（このリポジトリの標準: 編集 → PR → **マージ後**に apply）。変更は PR で出す。

## 例

**Input:** 「git worktree 系のTipを2つ増やして」

**Output（tips.txt 末尾に追記）:**
```
git|git worktree prune|削除済み worktree の登録を掃除（git worktree prune）
git|gwta + cd|`gwta ../wt-foo branch` で作業場所を分けてから移動すると安全
```

**Input:** 「tip 5個足して」（テーマ指定なし）

→ functions.zsh / aliases.zsh.tmpl / plugins.zsh を読み、まだ Tip 化されて
いない実在の関数・alias・ツールを優先して5件作り、重複チェックして追記する。
