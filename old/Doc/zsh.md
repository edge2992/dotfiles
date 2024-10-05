# zshの使い方

## お役立ち

| コマンド | 機能                    |
| -------- | ----------------------- |
| Ctrl + A | 行頭 (tmuxと被っている) |
| Ctrl + E | 行末                    |
| Ctrl + S | Lock                    |
| Ctrl + Q | Unlock                  |

## zsh-completion

- `/usr/local/share/zshへの権限設定を行わないとうまく動かない`
- tabを押すと補完候補と説明が出る

## zwsh-autosuggestions

- Endキー、矢印右で補完候補を使用する

## history-search-multi-tools

- C-rで履歴検索
- 詳しい使い方はfzfの使い方を参照する

## forgit

- fzfとgitの連携

| コマンド | 機能                     |
| -------- | ------------------------ |
| ga       | git add with interactive |
| gd       | git diff                 |

## fzf + cd

- cdコマンド後にEnterでfzfでディレクトリを移動する
- Escまたは, Ctrl+cで決定
