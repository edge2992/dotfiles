#!/usr/bin/env python3
"""PreToolUse hook: 個人リポジトリでの gh pr create / gh pr merge を自動許可する。

判定はすべてローカルで決定論的に行う（ネットワーク不使用）:
  1. コマンドが gh pr create / gh pr merge で始まる「単純コマンド」であること。
     コマンド連結（; && || |）・置換（$() ``）・リダイレクトを含むものは対象外。
     例外として PR body の定型 "$(cat <<'EOF' ... EOF)" だけは安全なので許容する。
  2. カレントリポジトリの origin が github.com 上の個人アカウントであること。

条件を満たすときだけ permissionDecision: "allow" を出力する。
満たさない場合は何も出力せず、通常の承認プロンプトにフォールバックする（fail-safe）。
会社マシンにも同じ設定が配布されるが、会社リポジトリは owner 判定で弾かれるため
挙動は変わらない。owner は CLAUDE_PR_AUTOAPPROVE_OWNERS（カンマ区切り）で上書き可。

重要: gh pr create / gh pr merge を settings.json の permissions.ask にも allow にも
入れないこと。Claude Code は deny -> ask -> allow の順に評価し、hook の返す "allow" は
ask ルールを上書きできないため、ask に入っているとこの hook は無効化されて毎回
プロンプトが出る（実際 ask に入れていて機能していなかった）。allow に入れると今度は
owner 判定を素通りして会社リポジトリでも自動承認されてしまう。制御はこの hook 一本に
寄せる。https://code.claude.com/docs/en/permissions
"""

import json
import os
import re
import subprocess
import sys

DEFAULT_OWNERS = "edge2992"

TARGET_RE = re.compile(r"^gh pr (create|merge)(\s|$)")
# PR body の定型: --body "$(cat <<'EOF' ... EOF)"。'EOF' がクオートされているため
# heredoc 内では一切の展開が起きず、中身は任意テキストでも安全。この 1 形式のみ carve-out。
# body 部は tempered pattern (?:(?!\nEOF\n).)* で「最初の EOF 終端行の手前まで」に限定する。
# 素朴な .*? だと内側の EOF 行をまたいでバックトラックし、bash が最初の EOF で heredoc を
# 閉じた後に実行する注入コマンドごと 1 つの body として潰してしまう（実挙動との乖離＝バイパス）。
# この tempered 版は bash と同じく「最初の EOF 行が終端」を強制するため乖離しない。
HEREDOC_BODY_RE = re.compile(r'"\$\(cat <<\'EOF\'\n(?:(?!\nEOF\n).)*\nEOF\n\)"', re.S)
# クオート外に現れたら「単純コマンド」でなくなるメタ文字
# （連結・パイプ・置換・リダイレクト・サブシェル・改行）。
META = set(";&|`$<>(){}\n")
OWNER_RE = re.compile(r"(?:git@github\.com:|https://github\.com/|ssh://git@github\.com/)([^/]+)/")


def is_simple_gh_pr_command(cmd: str) -> bool:
    """gh pr create/merge の「単純な単一コマンド」なら True。

    正規表現の逐次除去はクオート跨ぎの取りこぼしがあるため、bash のクオート規則を
    左から右へ 1 パスで追う状態機械で判定する（outside / '...' / "..."）。ダブルクオート
    内でも $ と ` は展開されるので危険として弾く。閉じないクオートも安全側に倒して弾く。
    """
    if not TARGET_RE.match(cmd):
        return False
    # 定型 heredoc body だけは安全なので空文字列に潰してから走査する
    s = HEREDOC_BODY_RE.sub('""', cmd)

    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if c == "\\":  # クオート外のエスケープ: 次の 1 文字はリテラル
            i += 2
        elif c == "'":  # シングルクオート: 次の ' まですべてリテラル（展開なし）
            j = s.find("'", i + 1)
            if j == -1:
                return False  # 閉じないシングルクオート
            i = j + 1
        elif c == '"':  # ダブルクオート: $ と ` は展開されるため危険
            i += 1
            while i < n:
                d = s[i]
                if d == "\\":  # ダブルクオート内のエスケープ
                    i += 2
                elif d == '"':
                    i += 1
                    break
                elif d in "$`":
                    return False  # ダブルクオート内での展開
                else:
                    i += 1
            else:
                return False  # 閉じないダブルクオート
        elif c in META:
            return False
        else:
            i += 1
    return True


def origin_owner(cwd: str) -> str | None:
    try:
        proc = subprocess.run(
            ["git", "-C", cwd, "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if proc.returncode != 0:
        return None
    m = OWNER_RE.match(proc.stdout.strip())
    return m.group(1) if m else None


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return
    if not isinstance(data, dict):
        return
    tool_input = data.get("tool_input")
    cmd = tool_input.get("command") if isinstance(tool_input, dict) else None
    if not isinstance(cmd, str) or not is_simple_gh_pr_command(cmd):
        return
    owners = {
        o.strip().lower()
        for o in os.environ.get("CLAUDE_PR_AUTOAPPROVE_OWNERS", DEFAULT_OWNERS).split(",")
        if o.strip()
    }
    cwd = data.get("cwd") or os.getcwd()
    owner = origin_owner(cwd)
    if owner is None or owner.lower() not in owners:
        return
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "allow",
                    "permissionDecisionReason": f"personal repo ({owner}): gh pr create/merge auto-approved",
                }
            }
        )
    )


if __name__ == "__main__":
    main()
