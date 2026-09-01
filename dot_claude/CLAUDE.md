# Global Guidelines

## Rules

- **Library docs**: Use Context7 MCP before implementing anything library-specific.
- **Worktree isolation**: Always use git worktree for feature work and bug fixes. Never work directly on main. Use `isolation: "worktree"` with the Agent tool.
- **Agentic coding**: Prefer autonomous, agent-driven approaches — subagents, parallel execution, proactive problem-solving.
- **PRs**: Commit and push to feature branches without asking. Create PRs without asking, too.
- **AWS resources**: When viewing or querying AWS resources, always use the `mcp__aws-mcp__aws___call_aws` MCP tool.
- **Python scripts**: Always use `uv` to run Python scripts (`uv run script.py`). Use `uv` for package management instead of `pip`/`python`.
- **Codex review model**: `/codex:review` and `/codex:adversarial-review` call the Codex app-server's `review/start` RPC, which does NOT inherit the top-level `model` from `~/.codex/config.toml` the way interactive/chat threads do — without an explicit `--model` it silently falls back to a different default model. Before running either command, if the user hasn't already passed `--model`/`-m`, read the default with `grep -m1 '^model' ~/.codex/config.toml` and append `--model <that value>` to the arguments. Do not fix this by editing the plugin's own files under `~/.claude/plugins/cache/` — that's plugin-managed and gets overwritten/reinstalled; this note is the actual persistent workaround until it's fixed upstream in `openai/codex-plugin-cc`.

## Subagent Strategy

- **Model cost control**: NEVER let a subagent inherit the main session's model
  (e.g. Opus). Always set `model` explicitly on every Agent/Workflow call:
  research & web search → `"sonnet"` (or `"haiku"` for simple lookups),
  mechanical tasks → `"haiku"`, implementation → per-repo policy.
  The expensive main model is for orchestration, review, and synthesis only.
- **Built-in `Explore` / `Plan` don't read this file.** They are the only
  subagents that skip CLAUDE.md, so the rule above cannot reach them — and since
  v2.1.198 they inherit the main conversation's model, with no Opus cap on
  Bedrock. They are pinned instead by same-named definitions in
  `~/.claude/agents/Explore.md` (haiku) and `Plan.md` (sonnet), which override
  the built-ins. Don't delete those files expecting the CLAUDE.md rule to cover
  them, and pin them with a version-form ID (`claude-haiku-4-5`) — a bare
  `haiku`/`sonnet` alias is silently ignored there on Bedrock.
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

<!-- CODEGRAPH_START -->

## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
