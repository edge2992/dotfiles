#!/usr/bin/env bash
# SessionEnd hook: append a per-session work-log entry to a daily Obsidian note.
#
# Output goes to $CLAUDE_WORKLOG_DIR/YYYY-MM-DD.md, one section per session:
# the first user request (依頼), the follow-up prompts (問いかけ), the last
# assistant message (結果), git context, and session metrics (prompt count,
# AskUserQuestion count, tool errors, permission prompts, token usage).
#
# The permission-prompt count comes from a per-session counter file written by
# permission-notify.sh under ${XDG_CACHE_HOME:-$HOME/.cache}/claude/perm-prompts/
# (one line per prompt); this hook consumes and deletes it.
#
# The hook is intentionally machine-agnostic: if CLAUDE_WORKLOG_DIR is unset
# (e.g. a host without the vault) it no-ops, and it NEVER fails the session
# (always exits 0) so a logging glitch can't disrupt Claude Code.
set -uo pipefail

# Read the SessionEnd payload (session_id, transcript_path, cwd, reason).
input="$(cat)"

# Keep dot_claude portable: do nothing unless an output dir is configured.
[ -n "${CLAUDE_WORKLOG_DIR:-}" ] || exit 0

# Parse the payload and best-effort summary in a single Python pass.
# Output: line 1 = TAB-joined "cwd reason session_id started n_prompts
#         ask_count err_count tok_out tok_in tok_cache_r tok_cache_w n_calls"
#         (metric fields are empty when the transcript couldn't be parsed),
#         then a "---8<---" delimiter, then the multi-line summary.
parsed="$(CLAUDE_HOOK_PAYLOAD="$input" python3 - <<'PY' 2>/dev/null || true
import os, json

payload = {}
try:
    payload = json.loads(os.environ.get("CLAUDE_HOOK_PAYLOAD", "{}"))
except Exception:
    payload = {}

cwd = payload.get("cwd", "") or ""
reason = payload.get("reason", "") or ""
session_id = payload.get("session_id", "") or ""
transcript = payload.get("transcript_path", "") or ""

def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        out = []
        for b in content:
            if isinstance(b, dict) and b.get("type") == "text":
                out.append(b.get("text", ""))
        return "\n".join(out)
    return ""

started = ""
prompts = []
last_asst = ""
ask_count = 0
err_count = 0
seen_calls = set()  # one API call spans several entries repeating the same usage
usage = {"input_tokens": 0, "output_tokens": 0,
         "cache_read_input_tokens": 0, "cache_creation_input_tokens": 0}
parsed_any = False
try:
    with open(transcript, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                e = json.loads(line)
            except Exception:
                continue
            if e.get("isSidechain"):
                continue
            if not started and e.get("timestamp"):
                started = e["timestamp"]
            etype = e.get("type")
            if etype not in ("user", "assistant"):
                continue
            parsed_any = True
            msg = e.get("message") or {}
            content = msg.get("content")
            if etype == "user":
                if not e.get("isMeta"):
                    t = text_of(content).strip()
                    # skip tool results / system-injected turns / interrupts
                    if t and not t.startswith("<") and not t.startswith("["):
                        prompts.append(t)
                if isinstance(content, list):
                    for b in content:
                        if isinstance(b, dict) and b.get("type") == "tool_result" \
                                and b.get("is_error"):
                            err_count += 1
            else:
                t = text_of(content).strip()
                if t:
                    last_asst = t
                if isinstance(content, list):
                    for b in content:
                        if isinstance(b, dict) and b.get("type") == "tool_use" \
                                and b.get("name") == "AskUserQuestion":
                            ask_count += 1
                u = msg.get("usage")
                if isinstance(u, dict):
                    key = msg.get("id") or e.get("requestId") or e.get("uuid")
                    if key and key not in seen_calls:
                        seen_calls.add(key)
                        for k in usage:
                            v = u.get(k)
                            if isinstance(v, (int, float)):
                                usage[k] += int(v)
except Exception:
    pass

def clip(s, n):
    s = " ".join(s.split())
    return s[:n] + ("…" if len(s) > n else "")

def human(n):
    if n >= 1_000_000:
        return "%.1fM" % (n / 1_000_000)
    if n >= 1_000:
        return "%.1fk" % (n / 1_000)
    return str(n)

summary = ""
if prompts:
    summary += "**依頼**: " + clip(prompts[0], 400)
if len(prompts) >= 2:
    shown = prompts[1:16]
    lines = ["**問いかけ** (%d):" % len(prompts)]
    for i, p in enumerate(shown, start=2):
        lines.append("%d. %s" % (i, clip(p, 200)))
    rest = len(prompts) - 1 - len(shown)
    if rest > 0:
        lines.append("…ほか%d件" % rest)
    summary += "\n\n" + "\n".join(lines)
if last_asst:
    summary += ("\n\n" if summary else "") + "**結果**: " + clip(last_asst, 600)

fields = [cwd, reason, session_id, started]
if parsed_any:
    fields += [str(len(prompts)), str(ask_count), str(err_count),
               human(usage["output_tokens"]), human(usage["input_tokens"]),
               human(usage["cache_read_input_tokens"]),
               human(usage["cache_creation_input_tokens"]),
               str(len(seen_calls))]
else:
    fields += [""] * 8
print("\t".join(fields))
print("---8<---")
print(summary)
PY
)"

# Split Python output into the metadata line and the summary block.
meta="$(printf '%s\n' "$parsed" | head -n1)"
summary="$(printf '%s\n' "$parsed" | awk 'f{print} /^---8<---$/{f=1}')"

IFS=$'\t' read -r cwd reason session_id started n_prompts ask_count err_count \
  tok_out tok_in tok_cache_r tok_cache_w n_calls <<<"$meta"
[ -n "${cwd:-}" ] || cwd="$PWD"

# Consume the permission-prompt counter written by permission-notify.sh.
perm=""
count_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude/perm-prompts"
if [[ "${session_id:-}" =~ ^[A-Za-z0-9-]+$ ]]; then
  count_file="$count_dir/$session_id.count"
  # mv first so a prompt racing with SessionEnd can't append between read and rm
  if mv "$count_file" "$count_file.$$" 2>/dev/null; then
    perm="$(wc -l <"$count_file.$$" 2>/dev/null | tr -d '[:space:]')" || perm=""
    rm -f "$count_file.$$" 2>/dev/null || true
  fi
fi

# Git context (best effort; skipped cleanly for non-git directories).
repo=""
branch=""
changed=""
commits=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  top="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"
  [ -n "$top" ] && repo="$(basename "$top")"
  branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  changed="$(git -C "$cwd" diff --shortstat 2>/dev/null | sed 's/^ *//')"
  if [ -n "${started:-}" ]; then
    commits="$(git -C "$cwd" log --since="$started" --pretty=format:'%h %s' 2>/dev/null | head -n 20)"
  fi
fi

# Compose and append the entry. Never let a write error fail the session.
mkdir -p "$CLAUDE_WORKLOG_DIR" 2>/dev/null || exit 0
out="$CLAUDE_WORKLOG_DIR/$(date +%Y-%m-%d).md"
{
  printf '\n## %s %s (%s)\n\n' "$(date +%H:%M)" "${repo:-$(basename "$cwd")}" "${branch:-no-git}"
  [ -n "$summary" ] && printf '%s\n\n' "$summary"
  [ -n "$changed" ] && printf -- '- Changed: %s\n' "$changed"
  if [ -n "$commits" ]; then
    printf -- '- Commits:\n'
    printf '%s\n' "$commits" | while IFS= read -r c; do printf '    - %s\n' "$c"; done
  fi
  if [ -n "${n_prompts:-}" ]; then
    printf -- '- Metrics: 問いかけ %s · AskUserQuestion %s · ツールエラー %s · 許可プロンプト %s\n' \
      "$n_prompts" "$ask_count" "$err_count" "${perm:-0}"
  fi
  if [ -n "${n_calls:-}" ] && [ "${n_calls:-0}" != "0" ]; then
    printf -- '- Tokens: out %s · in %s · cache r %s / w %s (累計, %s calls)\n' \
      "$tok_out" "$tok_in" "$tok_cache_r" "$tok_cache_w" "$n_calls"
  fi
  # shellcheck disable=SC2016  # backticks are literal markdown, not a subshell
  printf -- '- Session: %s · `%s`\n' "${reason:-unknown}" "${session_id:0:8}"
} >>"$out" 2>/dev/null || true

exit 0
