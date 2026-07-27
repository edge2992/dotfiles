# 1Password Integration

chezmoi は [1Password CLI (`op`)](https://developer.1password.com/docs/cli/) と連携して、テンプレート内でシークレットを安全に参照できます。

## 前提条件

1. **1Password CLI のインストール**

   ```bash
   # Linux (amd64)
   curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
     sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | \
     sudo tee /etc/apt/sources.list.d/1password.list
   sudo apt update && sudo apt install -y 1password-cli

   # macOS
   brew install 1password-cli
   ```

2. **サインイン**

   ```bash
   # アカウントを追加（初回のみ）
   op account add --address my.1password.com

   # サインイン
   eval $(op signin)
   ```

3. **chezmoi の設定**

   `chezmoi init` 時に 1Password アカウント（例: `my.1password.com`）を入力すると、`.chezmoi.yaml` の `data.op_account` に保存されます。空にするとスキップされます。

## chezmoi テンプレートでの使い方

### `onepasswordRead` - フィールド値の取得

1Password のアイテムからフィールドの値を取得します。引数には [Secret Reference URI](https://developer.1password.com/docs/cli/secret-references/) を使います。

```
# ユーザー名
{{ onepasswordRead "op://vault-name/item-name/username" }}

# パスワード
{{ onepasswordRead "op://vault-name/item-name/password" }}

# カスタムフィールド
{{ onepasswordRead "op://Personal/GitHub Token/credential" }}
```

### `onepassword` - アイテム全体の取得

アイテムのJSON全体を取得し、フィールドにアクセスできます。

```
{{ (onepassword "item-name" "vault-name").fields }}
```

### `onepasswordDocument` - ドキュメントの取得

1Password に保存されたファイル（SSH 鍵など）をそのまま取得します。

```
{{ onepasswordDocument "SSH Key" "vault-name" }}
```

## 使用例

### API キーをテンプレートで参照

例えば `dot_env.tmpl` のようなファイルで:

```
ANTHROPIC_API_KEY={{ onepasswordRead "op://Development/Anthropic API Key/credential" }}
GITHUB_TOKEN={{ onepasswordRead "op://Development/GitHub Token/credential" }}
```

### SSH 秘密鍵の管理

`private_dot_ssh/private_id_ed25519.tmpl`:

```
{{ onepasswordDocument "SSH Private Key" "Personal" }}
```

### 条件付きで 1Password を使用

1Password が設定されていない環境でもエラーにならないようにする:

```
{{ if .op_account -}}
SOME_SECRET={{ onepasswordRead "op://Vault/Item/field" }}
{{ else -}}
# SOME_SECRET is not configured (1Password not available)
{{ end -}}
```

## 動作確認

```bash
# テンプレートの出力を確認（実際にファイルは書き換えない）
chezmoi execute-template '{{ onepasswordRead "op://Personal/Test/password" }}'

# diff で変更を確認
chezmoi diff

# 問題なければ適用
chezmoi apply
```

## 注意事項

- `chezmoi apply` 実行時に `op` CLI の認証が必要です。セッションが切れている場合は `eval $(op signin)` を再実行してください。
- シークレットの値はターゲットファイルに展開されるため、ターゲットファイル自体は Git 管理外（`~/.env` など）にしてください。
- テンプレートソースファイル（`.tmpl`）にはシークレットの値ではなく **参照のみ** が含まれるため、安全にコミットできます。

## SSH エージェントの承認とロック（Claude Code などの非対話ツール向け）

### 既定: ローカル鍵（`~/.ssh/id_ed25519`）

Claude Code のような非対話ツールから git 操作をする場合、**既定のローカル鍵構成を推奨**します。
`chezmoi.yaml` の `useOnePasswordSSHAgent` フラグ（デフォルト `false`）が opt-out の間、
`~/.ssh/config` の `Host github.com` ブロックから `IdentityAgent` 行が自動的に取り除かれ、
1Password 連携は一切介在しません。SSH クライアントは `~/.ssh/config` に何も指定がなくても
デフォルトの鍵探索（`~/.ssh/id_ed25519` など）だけで `git@github.com` の認証に通ります。
承認プロンプトも 1Password のロック状態も関係しないため、非対話ツールでもハングしません。

**トレードオフ**: パスフレーズなしの秘密鍵をディスクに平置きすることになります。これは
**FileVault（フルディスク暗号化）が有効であること**を前提にした選択です。ディスク暗号化を
有効にしていない環境ではこの構成を使わないでください。

新しいマシンでローカル鍵をセットアップする手順:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
gh ssh-key add ~/.ssh/id_ed25519.pub

# 疎通確認
ssh -T git@github.com
```

`chezmoi apply` 後に一度だけ実行される案内スクリプト
（`run_once_after_10_notice-github-ssh.sh.tmpl`）が、鍵の有無に応じてこの手順か
疎通確認コマンドのどちらかを表示します。

### opt-in: 1Password SSH Agent（`useOnePasswordSSHAgent = true`）

1Password の SSH Agent 経由でも GitHub 認証は可能ですが、これは **opt-in** の構成であり、
承認プロンプトと自動ロックに起因するハングというコストが伴います。`chezmoi init` 時に
`useOnePasswordSSHAgent` を `true` にすると、`~/.ssh/config` の `Host github.com` に
`IdentityAgent` 行が追加されます。

`~/.ssh/config` の `Host github.com` が 1Password SSH エージェント（`IdentityAgent`）を経由すると、
`git push` などの SSH 接続には 1Password の承認（Touch ID / アプリ承認）が必要になります。
Claude Code のような非対話ツールは承認プロンプトに応答できないため、承認が切れた状態で
push すると**応答待ちでハング**します。opt-in する場合は、以下の runbook で緩和してください。

#### 仕組み

- 鍵の使用要求ごとに 1Password が承認プロンプトを表示する。承認は**アプリケーション単位**で
  記憶されるため、ターミナルから一度承認すれば、同じターミナル配下で動くツール（Claude Code 含む）は
  記憶が切れるまで再承認不要
- 承認の記憶期間（Remember key approval）は 3 択:
  - **Until 1Password locks**（デフォルト）— ロックの度に承認が消える。**ハングの主因**
  - **Until 1Password quits** — アプリを終了するまで承認を記憶
  - **For a set amount of time**（4/12/24 時間）— ロックしても承認自体は維持
- ただし 1Password が**ロック中**は承認が残っていても鍵にアクセスできず、エージェントは
  解錠プロンプトを出して**応答があるまでブロック**する（エラーにならず、SSH クライアント側からは
  ハングに見える）。そのため自動ロックの緩和もセットで必要

#### 推奨設定（1Password アプリの GUI 設定・chezmoi 管理外）

※ 表記はバージョンにより多少異なる

1. **Settings → Developer**（SSH Agent）: Remember key approval を
   **Until 1Password quits**（または For a set amount of time: 24 hours）に変更。
   デフォルトの Until 1Password locks のままにしない
2. **Settings → Security**（Auto-lock）: アイドル時の自動ロック時間を長め（例: 8 時間）にし、
   スリープ・画面ロック時に 1Password をロックする設定をオフにする

> **トレードオフ**: 離席中も 1Password が解錠されたままになる。macOS 側の画面ロック
> （スリープ/スクリーンセーバーでの即時ロック）を必ず併用すること。

#### 残る制約

- 再起動や明示的なロックの後は、初回のみターミナルからの承認・解錠が必要。長時間の作業セッションの
  前に `ssh -T git@github.com` を一度実行しておくと確実
- それも許容できない場合は、GitHub 向け git 操作を HTTPS + `gh auth git-credential` に
  切り替える選択肢がある（秘密鍵をディスクに置かずに非対話 push が可能）

## 参考リンク

- [chezmoi - 1Password](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [1Password CLI - Secret References](https://developer.1password.com/docs/cli/secret-references/)
- [1Password CLI - Getting Started](https://developer.1password.com/docs/cli/get-started/)
