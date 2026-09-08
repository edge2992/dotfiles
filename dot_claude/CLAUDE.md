## Rules

- **Library docs**: Use Context7 MCP before implementing anything library-specific.
- **Worktree isolation**: Never work on main. Use `isolation: "worktree"` with the Agent tool.
- **PRs**: Commit, push, and open PRs without asking.
- **AWS**: Query AWS via `mcp__aws-mcp__aws___call_aws`.
- **Python**: `uv run` / `uv add`. Never `pip` or bare `python`.
- **Commits**: Conventional Commits. Subject ≤50 chars, imperative, no period.

## Subagents

- Delegate exploration, research, and cross-cutting analysis; keep them out of main context.
- Run independent tasks in parallel. Keep nesting shallow.
- Always set `model` explicitly on Agent/Workflow calls. Omitting it falls back to the main session's model (e.g. Opus), not a cheaper one. If you must fall back, default to `sonnet`.

## Done means proven

- Show the test run, the log, or the behavior diff. Not "should work".
