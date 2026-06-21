# Global Guidelines

Project-specific instructions are in each project's `CLAUDE.md`.

## Rules

- **Language**: Think in English. Respond in Japanese.
- **Library docs**: Use Context7 MCP before implementing anything library-specific.
- **Worktree isolation**: Always use git worktree for feature work and bug fixes. Never work directly on main. Use `isolation: "worktree"` with the Agent tool.
- **Agentic coding**: Prefer autonomous, agent-driven approaches — subagents, parallel execution, proactive problem-solving.
- **PRs**: Commit and push to feature branches without asking. Always ask before creating a PR.

## Commit Conventions

[Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <subject>`

**Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`

- Subject: ≤50 chars, imperative mood, no trailing period
- Body: _what_ and _why_, not _how_; wrap at 72 chars
