---
description: Morning planning — gather Jira assignments, recent worklog and Slack mentions, then propose today's prioritized task list
argument-hint: [optional context, e.g. 今日は障害対応を優先したい]
---

# kickoff — 朝のタスク見定め

Gather what is on the user's plate from every available source and propose
a small, prioritized plan for today. Display only — change nothing.

## Instructions

1. **Source availability check** — usable sources this session:
   - Jira: `mcp__mcp-atlassian__jira_search` with
     `assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC`
     (limit 20)
   - Worklog: yesterday's and today's `$CLAUDE_WORKLOG_DIR/YYYY-MM-DD.md` —
     extract interrupted work, unfinished tasks, and 結果 sections that
     mention a next action
   - Slack mentions/unreads: only if a Slack MCP read tool is found via
     ToolSearch
   - Calendar: only if a calendar MCP is available — today's meetings and
     the free blocks between them
   - Skip unavailable sources; list them at the end of the output.

2. **Fan out** — read each source with a parallel subagent
   (`model: haiku`, conclusions only). Small reads (a single worklog file)
   may be done inline instead.

3. **Prioritize** — order candidates by:
   1. hard deadlines and meeting-preparation for today
   2. unblocking others (review requests, blocked teammates)
   3. continuing in-progress work (from worklog)
   4. new work
   - Respect $ARGUMENTS (e.g. 障害対応優先) above these defaults.

4. **Output** (Japanese):
   - 今日のTop 3〜5 — each with 理由 (one line) and 最初の一手
     (a concrete action doable in ~15 minutes)
   - あふれたもの — noteworthy items deliberately not in today's top list
   - 使えなかったソース — skipped sources, one line

5. **Never mutate** — no ticket transitions, no note writes, no messages.
   This skill only reads and proposes.

## Anti-Patterns

- A 15-item todo list — the point is choosing, not enumerating
- Recommendations with no 最初の一手
- Guessing Jira/Slack content when the source is unavailable
