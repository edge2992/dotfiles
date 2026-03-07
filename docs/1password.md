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

## 参考リンク

- [chezmoi - 1Password](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [1Password CLI - Secret References](https://developer.1password.com/docs/cli/secret-references/)
- [1Password CLI - Getting Started](https://developer.1password.com/docs/cli/get-started/)
