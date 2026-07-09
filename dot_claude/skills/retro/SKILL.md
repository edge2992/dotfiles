---
description: Analyze Claude Code worklog metrics over a period and propose concrete environment improvements (allowlist entries, CLAUDE.md rules, new skills)
argument-hint: [period, e.g. 7d or 2026-07-01..2026-07-07 (default: last 7 days)]
---

# retro — Claude 使い方の振り返り

Close the feedback loop: read the accumulated worklog metrics, find the
friction, and propose concrete config improvements. Propose only — never
apply changes from within this skill.

## Instructions

1. **Period** — parse $ARGUMENTS (`7d`, `14d`, or an explicit
   `YYYY-MM-DD..YYYY-MM-DD` range). Default: the last 7 days.

2. **Read** — the files `$CLAUDE_WORKLOG_DIR/YYYY-MM-DD.md` inside the
   period. If `CLAUDE_WORKLOG_DIR` is unset, explain that this machine has
   no worklog (the SessionEnd hook no-ops without an Obsidian vault) and stop.
   - Parse loosely and best-effort — the format may drift:
     sections start with `## HH:MM <repo> (<branch>)`; metrics live on
     lines starting with `- Metrics:` (問いかけ / AskUserQuestion /
     ツールエラー / 許可プロンプト) and `- Tokens:` (out / in / cache r/w);
     `- Session:` carries the end reason. Skip anything unparsable.
   - For a large period, fan the per-file parsing out to `model: haiku`
     subagents that return per-day aggregate numbers only.

3. **Aggregate** — sessions per day and per repo; totals and
   top-sessions for 問いかけ, AskUserQuestion, ツールエラー,
   許可プロンプト, tokens (in/out/cache).

4. **Friction analysis** — for each signal, name the evidence
   (date + repo + session) and derive a proposal:
   - Many permission prompts → likely-denied tools inferred from the
     依頼/結果 text → propose exact `permissions.allow` entries for
     `.chezmoitemplates/claude-settings-base.json` in the chezmoi repo
   - The same instruction appearing repeatedly across 問いかけ lists →
     propose a CLAUDE.md rule or a new skill that absorbs it
   - Sessions with many tool errors → identify the failing tool/hook
   - Heavy token sessions → propose subagent delegation or haiku fan-out
     for that kind of work

5. **Report** — write to `$OBSIDIAN_VAULT/claude/retro/YYYY-MM-DD-retro.md`
   (if `OBSIDIAN_VAULT` is unset, show inline only):
   - ## サマリ — one table: sessions / prompts / errors / permission
     prompts / tokens, with 週次比較 if a previous retro report exists in
     the same directory (read it and compare)
   - ## うまくいっているパターン — what to keep doing
   - ## 摩擦点 — evidence-linked friction list
   - ## 改善提案 — each proposal with the exact diff or rule text, its
     expected effect, and its cost
   - ## 前回提案のフォローアップ — adopted? still relevant? (skip when no
     previous report exists)

6. **Hand off, don't act** — present the proposals and stop. Applying them
   (editing settings, opening PRs in the chezmoi repo) happens only when
   the user picks proposals explicitly.

## Quality Standards

- Every friction claim cites evidence (date, repo, metric value)
- Proposals are concrete enough to apply verbatim (exact allow entry,
  exact rule sentence) — no "improve prompting" fluff
- Parsing tolerates format drift; unparsable lines are skipped, not fatal
- Report language: Japanese

## Anti-Patterns

- Editing settings or CLAUDE.md from within this skill
- Metrics tables with no interpretation
- Proposals that just restate the metric ("reduce tool errors")
