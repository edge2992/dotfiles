#!/usr/bin/env bash
# SessionEnd hook: append a per-session work-log entry to a daily Obsidian note.
#
# Output goes to $CLAUDE_WORKLOG_DIR/YYYY-MM-DD.md, one section per session.
# The hook is intentionally machine-agnostic: if CLAUDE_WORKLOG_DIR is unset
# (e.g. a host without the vault) it no-ops, and it NEVER fails the session
# (always exits 0) so a logging glitch can't disrupt Claude Code.
set -uo pipefail

# Read the SessionEnd payload (session_id, transcript_path, cwd, reason).
input="$(cat)"

# Keep dot_claude portable: do nothing unless an output dir is configured.
[ -n "${CLAUDE_WORKLOG_DIR:-}" ] || exit 0

# Parse the payload and best-effort summary in a single Python pass.
# Output: line 1 = "cwd<TAB>reason<TAB>session_id<TAB>started",
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
first_user = ""
last_asst = ""
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
            if not started and e.get("timestamp"):
                started = e["timestamp"]
            msg = e.get("message") or {}
            role = msg.get("role") or e.get("type")
            if role == "user" and not first_user:
                t = text_of(msg.get("content")).strip()
                # skip tool results / system-injected meta turns
                if t and not t.startswith("<"):
                    first_user = t
            if role == "assistant":
                t = text_of(msg.get("content")).strip()
                if t:
                    last_asst = t
except Exception:
    pass

def clip(s, n):
    s = " ".join(s.split())
    return s[:n] + ("…" if len(s) > n else "")

summary = ""
if first_user:
    summary += "**依頼**: " + clip(first_user, 400)
if last_asst:
    summary += ("\n\n" if summary else "") + "**結果**: " + clip(last_asst, 600)

print("\t".join([cwd, reason, session_id, started]))
print("---8<---")
print(summary)
PY
)"

# Split Python output into the metadata line and the summary block.
meta="$(printf '%s\n' "$parsed" | head -n1)"
summary="$(printf '%s\n' "$parsed" | awk 'f{print} /^---8<---$/{f=1}')"

IFS=$'\t' read -r cwd reason session_id started <<<"$meta"
[ -n "${cwd:-}" ] || cwd="$PWD"

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
  # shellcheck disable=SC2016  # backticks are literal markdown, not a subshell
  printf -- '- Session: %s · `%s`\n' "${reason:-unknown}" "${session_id:0:8}"
} >>"$out" 2>/dev/null || true

exit 0
