# Claude Workflow Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** worklog 蓄積を活用する4スキル(times / spec-research / kickoff / retro)と Jira 読み取り permissions を、5本の独立 PR として実装する。

**Architecture:** `dot_claude/skills/<name>/SKILL.md` にポータブルスキルを追加(既存 `deep` スキルの書式に準拠)。会社専用 MCP は実行時存在チェックで縮退。permissions は `.chezmoitemplates/claude-settings-base.json` に追記。各 PR はファイルが互いに素で、並行 worktree 開発・独立マージが可能。

**Tech Stack:** chezmoi, Claude Code skills (Markdown), jsonnet overlay(変更なし), mcp-atlassian / Slack MCP(実行時参照のみ)

**Spec:** `docs/superpowers/specs/2026-07-10-claude-workflow-suite-design.md`

## Global Constraints

- スキル本文の出力言語指定は日本語(既存スキルと同じく本文は英語で書き、成果物出力を日本語と指示する)
- frontmatter は `description`(英語1行)+ `argument-hint` のみ(既存 `deep` スキル準拠)
- コミットは Conventional Commits、scope は `claude`、subject ≤50文字
- コミット前に `make lint` 必須。pre-commit を `--no-verify` で迂回しない
- 各ファイルは末尾改行あり・行末空白なし(pre-commit の end-of-file-fixer / trailing-whitespace)
- PR 作成後は `gh pr checks <PR#> --watch` で CI グリーンを確認する(マージは統括セッションが行う)
- `chezmoi apply` はマージ後に統括セッションが行う。実装タスク内では実行しない

---

### Task 1: Foundation PR — 設計 docs + Jira 読み取り permissions

**Files:**
- Create: `docs/superpowers/specs/2026-07-10-claude-workflow-suite-design.md`(作成済み)
- Create: `docs/superpowers/plans/2026-07-10-claude-workflow-suite.md`(本ファイル、作成済み)
- Modify: `.chezmoitemplates/claude-settings-base.json`(permissions.allow、mcp-atlassian ブロック)

**Interfaces:**
- Consumes: なし
- Produces: allowlist の Jira ツール名(spec-research / kickoff スキルが実行時に参照する前提の許可)

- [ ] **Step 1: permissions.allow に Jira 読み取りツールを追加**

`.chezmoitemplates/claude-settings-base.json` の `"mcp__mcp-atlassian__confluence_search",` の直後(アルファベット順を維持)に以下を挿入:

```json
      "mcp__mcp-atlassian__jira_get_agile_boards",
      "mcp__mcp-atlassian__jira_get_all_projects",
      "mcp__mcp-atlassian__jira_get_board_issues",
      "mcp__mcp-atlassian__jira_get_issue",
      "mcp__mcp-atlassian__jira_get_link_types",
      "mcp__mcp-atlassian__jira_get_project_issues",
      "mcp__mcp-atlassian__jira_get_sprint_issues",
      "mcp__mcp-atlassian__jira_get_sprints_from_board",
      "mcp__mcp-atlassian__jira_get_transitions",
      "mcp__mcp-atlassian__jira_get_user_profile",
      "mcp__mcp-atlassian__jira_get_worklog",
      "mcp__mcp-atlassian__jira_search",
      "mcp__mcp-atlassian__jira_search_fields",
```

- [ ] **Step 2: lint 実行**

Run: `make lint`(worktree ルートで)
Expected: 全 lint が PASS(特に lint-tmpl が settings テンプレートの JSON 妥当性を検証する)

- [ ] **Step 3: chezmoi のレンダリング確認**

Run: `chezmoi diff --source <worktree> -- ~/.claude/settings.json | head -40`
Expected: allow 配列への jira_* 追加のみが差分として見える(overlay 環境では modify スクリプト経由の差分表示)

- [ ] **Step 4: コミット(2つに分ける)**

```bash
git add docs/superpowers/
git commit -m "docs(claude): add workflow suite design and plan"
git add .chezmoitemplates/claude-settings-base.json
git commit -m "feat(claude): allow Jira read-only MCP tools"
```

- [ ] **Step 5: push & PR 作成**

```bash
git push -u origin feat/claude-workflow-foundation
gh pr create --title "feat(claude): workflow suite foundation (design docs + Jira permissions)" --body "..."
```

PR body には: 目的(worklog 活用スイートの土台)、spec へのパス、Jira ツール名の出典(sooperset/mcp-atlassian)、検証内容(make lint / chezmoi diff)を書く。

---

### Task 2: `/times` スキル

**Files:**
- Create: `dot_claude/skills/times/SKILL.md`

**Interfaces:**
- Consumes: `$CLAUDE_WORKLOG_DIR`(worklog.sh が書く日次ノート)、`$SLACK_TIMES_CHANNEL`(会社マシンのシェル env、未設定可)
- Produces: なし(末端スキル)

- [ ] **Step 1: SKILL.md を以下の内容で作成**

ファイル内容(全文):

    ---
    description: Summarize recent work from the worklog and post it to the personal Slack times channel after explicit confirmation
    argument-hint: [optional note or date, e.g. "リリース作業がメイン" or 2026-07-09]
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

- [ ] **Step 2: lint 実行**

Run: `make lint`
Expected: PASS

- [ ] **Step 3: コミット・push・PR 作成**

```bash
git add dot_claude/skills/times/SKILL.md
git commit -m "feat(claude): add times skill for worklog sharing"
git push -u origin feat/claude-skill-times
gh pr create --title "feat(claude): add /times skill (worklog → Slack times)" --body "..."
```

PR body: 目的、確認必須の設計、縮退パス(クリップボード)、spec へのパス(foundation PR 参照)、`make lint` PASS を記載。

---

### Task 3: `/spec-research` スキル

**Files:**
- Create: `dot_claude/skills/spec-research/SKILL.md`

**Interfaces:**
- Consumes: mcp-atlassian(confluence_*, jira_search — 許可は Task 1)、`research-coordinator`/`Explore` エージェント、`$OBSIDIAN_VAULT`
- Produces: `$OBSIDIAN_VAULT/claude/research/YYYY-MM-DD-<slug>.md`(レポート蓄積)

- [ ] **Step 1: SKILL.md を以下の内容で作成**

ファイル内容(全文):

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

- [ ] **Step 2: lint 実行**

Run: `make lint`
Expected: PASS

- [ ] **Step 3: コミット・push・PR 作成**

```bash
git add dot_claude/skills/spec-research/SKILL.md
git commit -m "feat(claude): add spec-research skill"
git push -u origin feat/claude-skill-spec-research
gh pr create --title "feat(claude): add /spec-research skill (仕様調査の型化)" --body "..."
```

---

### Task 4: `/kickoff` スキル

**Files:**
- Create: `dot_claude/skills/kickoff/SKILL.md`

**Interfaces:**
- Consumes: `jira_search`(Task 1 の許可)、`$CLAUDE_WORKLOG_DIR`、Slack/カレンダー MCP(あれば)
- Produces: なし(表示のみ)

- [ ] **Step 1: SKILL.md を以下の内容で作成**

ファイル内容(全文):

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

- [ ] **Step 2: lint 実行**

Run: `make lint`
Expected: PASS

- [ ] **Step 3: コミット・push・PR 作成**

```bash
git add dot_claude/skills/kickoff/SKILL.md
git commit -m "feat(claude): add kickoff skill for daily planning"
git push -u origin feat/claude-skill-kickoff
gh pr create --title "feat(claude): add /kickoff skill (朝のタスク見定め)" --body "..."
```

---

### Task 5: `/retro` スキル

**Files:**
- Create: `dot_claude/skills/retro/SKILL.md`

**Interfaces:**
- Consumes: `$CLAUDE_WORKLOG_DIR` の日次ノート(worklog.sh の形式: `## HH:MM repo (branch)` セクション、`- Metrics:` / `- Tokens:` / `- Session:` 行)、`$OBSIDIAN_VAULT`
- Produces: `$OBSIDIAN_VAULT/claude/retro/YYYY-MM-DD-retro.md`

- [ ] **Step 1: SKILL.md を以下の内容で作成**

ファイル内容(全文):

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
         prompts / tokens, with週次比較 if a previous retro report exists in
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

- [ ] **Step 2: lint 実行**

Run: `make lint`
Expected: PASS

- [ ] **Step 3: コミット・push・PR 作成**

```bash
git add dot_claude/skills/retro/SKILL.md
git commit -m "feat(claude): add retro skill for usage feedback loop"
git push -u origin feat/claude-skill-retro
gh pr create --title "feat(claude): add /retro skill (使い方の振り返りループ)" --body "..."
```

---

### Task 6: 統括 — CI 確認・レビュー・マージ・apply(統括セッションが実施)

**Files:** なし(オーケストレーションのみ)

- [ ] **Step 1:** 各 PR に code-reviewer エージェントでセルフレビューを実施し、指摘があれば修正コミット
- [ ] **Step 2:** `gh pr checks <PR#> --watch` で全 PR の CI グリーンを確認
- [ ] **Step 3:** CI グリーンの PR から順にマージ(standing rule: 確認済みのため追加の許可は不要)。Task 1 を最初にマージする(スキルが前提とする permissions が先に main に入るように)
- [ ] **Step 4:** main を `git pull --ff-only` で更新し、`chezmoi diff -- ~/.claude/skills ~/.claude/settings.json` で差分確認 → 該当パスに絞って `chezmoi apply` → `chezmoi diff` が空であることを確認
- [ ] **Step 5:** 動作確認: 新スキルが `~/.claude/skills/` に配置されたこと、`~/.claude/settings.json` の allow に jira_* が入ったこと(overlay 環境での再生成結果)を確認
