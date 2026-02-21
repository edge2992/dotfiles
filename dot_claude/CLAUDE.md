# Guidelines

This document defines Claude's global behavioral rules across all projects.
Project-specific instructions are defined in each project's `CLAUDE.md`.

## Top-Level Rules

- **Parallel execution**: To maximize efficiency, if multiple independent processes need to run, invoke those tools concurrently, not sequentially.
- **Language**: Think exclusively in English. Respond in Japanese.
- **Library documentation**: Always use the Context7 MCP to retrieve the latest library documentation before implementing anything library-specific.
- **Read before edit**: Always read a file before modifying it. Never guess at file contents.
- **Minimal changes**: Only make changes directly requested or clearly necessary. Avoid over-engineering.

## Development Workflow

- Before starting work, read relevant files to understand existing patterns.
- Prefer editing existing files over creating new ones.
- After making changes, verify they work as intended.
- Never commit automatically — always wait for explicit user request.
- Never push to remote repositories unless explicitly asked.

## Tool Usage

- Use dedicated tools (Read, Glob, Grep, Edit, Write) over Bash equivalents whenever possible.
- Launch independent tool calls in parallel within a single response.
- Use the Task tool with specialized subagents for complex multi-step research or exploration.
- Use Context7 MCP for library/framework documentation (not web search).

## Code Style

- Avoid hard-coding values unless absolutely necessary.
- Prefer simple, readable code over clever solutions.
- Do not add comments, docstrings, or type annotations to code that wasn't changed.
- Do not add error handling for scenarios that cannot occur.
- Do not create abstractions or utilities for one-time operations.

## Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

<optional body>
```

**Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`

- Subject: 50 chars or less, imperative mood, no trailing period
- Body: Explain *what* and *why*, not *how*; wrap at 72 chars
- Never commit `.env`, credentials, private keys, or secrets

## Security

- Never expose API keys, tokens, passwords, or private keys.
- Never run destructive commands (`rm -rf`, `git reset --hard`, force push) without explicit user confirmation.
- Never bypass git hooks (`--no-verify`) unless explicitly asked.
- Validate inputs at system boundaries; trust internal code.
