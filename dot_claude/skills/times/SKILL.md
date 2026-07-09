---
description: Summarize recent work from the worklog and post it to the personal Slack times channel after explicit confirmation
argument-hint: [optional note or date]
---

# times — 作業ログを times に流す

Summarize today's work into a casual "times" post and send it to the user's
personal Slack times channel. Never send anything without explicit confirmation.

## Instructions

1. **Collect material**
   - Worklog: read `$CLAUDE_WORKLOG_DIR/<date>.md` where `<date>` is today,
     or the `YYYY-MM-DD` date given in $ARGUMENTS. If `CLAUDE_WORKLOG_DIR` is
     unset or the file does not exist, continue with git evidence only and
     note the missing source in the draft preamble.
   - Git: if the current directory is inside a git repository, collect
     today's commits (`git log --since=midnight --oneline`) and pending work
     (`git status --short`, `git diff --shortstat`).
   - Treat the rest of $ARGUMENTS as context to weave in (highlights, mood).

2. **Draft the post**
   - Tone: casual times style. First person, light, no formal report tone.
   - Shape: one-line headline, then 2-5 bullets of what got done, then at
     most one line of 学び or 詰まった点 if there is a genuine one.
   - Emoji: 0-2, only where natural.
   - Redact anything sensitive: no secrets, no customer names, no internal
     URLs. Repo names are fine.
   - Base every bullet on evidence from the worklog or git. Do not embellish.

3. **Confirm before sending (required)**
   - Show the full draft, then use AskUserQuestion with options:
     投稿する / 修正する / やめる.
   - On 修正する, apply the requested edits and confirm again.
   - Never post without this confirmation, even if $ARGUMENTS says to hurry.

4. **Send via Slack MCP**
   - Discover a message-posting Slack MCP tool with ToolSearch
     (query: "+slack post message send"). Do not guess tool names.
   - Post the confirmed draft to the channel in `$SLACK_TIMES_CHANNEL`
     (channel ID or name). Report the resulting permalink if the tool
     returns one.

5. **Fallback (Slack MCP or env missing)**
   - Print the draft, then copy it to the clipboard using the first
     available of: `pbcopy`, `wl-copy`, `xclip -selection clipboard`.
   - Tell the user exactly which piece was missing and the one-line fix,
     e.g. add `export SLACK_TIMES_CHANNEL=C0XXXXXXXX` to the company-local
     zshenv, or configure the Slack MCP server.

## Quality Standards

- **Confirmation is non-negotiable** — no unconfirmed outbound post, ever
- Summarize, don't dump: 2-5 bullets, no raw worklog paste
- Evidence-based: every claim traceable to worklog or git
- Output language: Japanese

## Anti-Patterns

- Turning the post into a formal report (times is a lightweight share)
- Listing every session individually — aggregate by theme
- Posting to any channel other than `$SLACK_TIMES_CHANNEL`
- Retrying a failed post against a different channel or tool without asking
