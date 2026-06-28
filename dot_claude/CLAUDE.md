# Global Guidelines

Project-specific instructions are in each project's `CLAUDE.md`.

## Rules

- **Language**: Think in English. Respond in Japanese.
- **Library docs**: Use Context7 MCP before implementing anything library-specific.
- **Worktree isolation**: Always use git worktree for feature work and bug fixes. Never work directly on main. Use `isolation: "worktree"` with the Agent tool.
- **Agentic coding**: Prefer autonomous, agent-driven approaches — subagents, parallel execution, proactive problem-solving.
- **PRs**: Commit and push to feature branches without asking. Create PRs without asking, too.

## Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution
- Default to delegating: don't hold exploration, research, or cross-cutting
  analysis in the main context — hand it to a subagent
- Route broad, multi-area investigations to the `research-coordinator` agent
- Tell every child to return conclusions only (no raw logs) to protect main context
- Run independent tasks in parallel; keep nested subagents shallow and wide
  (don't waste the depth-5 nesting limit on tall chains)

## Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

## Commit Conventions

[Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <subject>`

**Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`

- Subject: ≤50 chars, imperative mood, no trailing period
- Body: _what_ and _why_, not _how_; wrap at 72 chars
