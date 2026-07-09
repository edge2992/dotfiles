---
description: Investigate an existing system's specification across Confluence, Jira, code, AWS and Datadog, then save a structured evidence-linked report to Obsidian
argument-hint: [system, feature, or question to investigate]
---

# spec-research — 既存システム仕様調査

Run a fan-out investigation of an existing system across every available
source, cross-check the findings, and produce a structured report whose
"未確認事項と検証方法" section feeds the next investigation cycle.

## Instructions

1. **Scope**
   - Parse $ARGUMENTS. If the target is ambiguous (which system? which
     aspect — 仕様 / データフロー / 運用手順 / 変更経緯?), ask one focused
     clarifying question before starting. Otherwise state the scope in one
     sentence and proceed.

2. **Source availability check**
   - Determine which sources are usable in this session (check the defined
     tool list, or ToolSearch for deferred ones):
     - Confluence: `mcp__mcp-atlassian__confluence_search`, `confluence_get_page`
     - Jira: `mcp__mcp-atlassian__jira_search`, `jira_get_issue`
     - Code: local repositories (via `research-coordinator` / Explore agents)
     - AWS: `mcp__aws-mcp__aws___call_aws` — only when infrastructure is in scope
     - Datadog: `mcp__datadog-mcp__*` — only when runtime behavior or service
       dependencies are in scope
   - Unavailable sources are skipped but MUST be listed in the report's
     未使用ソース section. Never silently drop a source.

3. **Parallel fan-out**
   - Launch one subagent per usable source, all in a single message.
   - Broad sweeps (doc search, code exploration) use cheap models:
     Explore agents or `model: haiku`. Synthesis stays in the main session.
   - Tell every subagent to return **conclusions only** (no raw logs, no
     full page dumps) with links/paths as evidence.
   - Confluence agent: search, read the 3-5 most relevant pages, extract
     spec statements each with its page link and last-updated date.
   - Jira agent: find related tickets; extract decisions, rationale, and
     still-open discussions with ticket keys.
   - Code agent: entry points, data model, main flows, feature flags.
   - Keep the agent tree shallow: depth ≤ 2, wide fan-out.

4. **Cross-check**
   - Where documentation and code disagree, trust the code and flag the
     document as stale (with both references).

5. **Report structure**
   - # <対象> 仕様調査 (YYYY-MM-DD)
   - ## 対象概要 — what the system/feature is, in 3-5 sentences
   - ## 仕様の要点 — the confirmed behavior, each point with its evidence
   - ## データフロー・依存関係 — upstream/downstream, stores, external calls
   - ## 根拠 — table of Confluence links / Jira keys / code paths
   - ## ドキュメントとコードの食い違い — stale docs found (or "なし")
   - ## 未確認事項と検証方法 — each open question WITH a concrete way to
     verify it (which log, which environment, which command or query)
   - ## 次のアクション
   - ## 未使用ソース — sources unavailable in this session

6. **Save**
   - Write to `$OBSIDIAN_VAULT/claude/research/YYYY-MM-DD-<slug>.md`
     (slug: short kebab-case from the target name).
   - If `OBSIDIAN_VAULT` is unset, show the full report inline and ask
     where to save it instead.

## Quality Standards

- No claim without evidence — every spec statement links to a page,
  ticket, or code path
- No open question without a verification method
- Prefer primary sources (code, ticket decisions) over secondhand wiki text
- Report language: Japanese

## Anti-Patterns

- Dumping raw search results into the report
- Investigating every aspect shallowly instead of the scoped aspect deeply
- Letting subagents return full page contents into the main context
- Skipping the 未確認事項 section because "everything seems clear"
