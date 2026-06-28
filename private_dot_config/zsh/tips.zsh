# zsh 起動Tip表示
# tips.txt からランダムに1件選んで色付きで表示する。
# 外部コマンド(shuf/awk 等)に依存せず zsh 組み込みのみで動作する。
# データ形式は tips.txt 冒頭のコメント参照（category|trigger|description）。

# カテゴリ別の色（zsh プロンプトカラー名）。未知カテゴリは既定色。
typeset -gA _TIP_COLORS=(
  zsh  magenta
  git  cyan
  tool blue
)

# tip: ランダムなTipを1件表示する。手動でも `tip` で引き直せる。
tip() {
  local file="${1:-$HOME/.config/zsh/tips.txt}"
  [[ -r "$file" ]] || return 0

  # コメント(#始まり)と空行を除いて配列に読み込む
  local -a lines
  lines=("${(@f)$(grep -vE '^[[:space:]]*(#|$)' -- "$file")}")
  (( ${#lines} )) || return 0

  # zsh 配列は1始まり。$RANDOM で1件選ぶ
  local entry="${lines[$(( RANDOM % ${#lines} + 1 ))]}"

  # category|trigger|description に分解
  local category="${entry%%|*}"
  local rest="${entry#*|}"
  local trigger="${rest%%|*}"
  local desc="${rest#*|}"

  local color="${_TIP_COLORS[$category]:-white}"
  # 色装飾(制御下の文字列)だけプロンプト展開し、description は生で出す。
  # starship が PROMPT_SUBST を有効化するため、print -P だと desc 内の
  # `...` や $() がコマンドとして実行されてしまう（それを防ぐ）。
  local fmt="%F{yellow}💡 tip%f %F{${color}}(${category})%f %F{green}${trigger}%f"
  print -r -- "${(%)fmt} — ${desc}"
}

# インタラクティブシェルの起動時に1件表示する
[[ -o interactive ]] && tip
