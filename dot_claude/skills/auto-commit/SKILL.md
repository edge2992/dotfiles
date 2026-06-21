---
description: Stage-aware auto commit — read key files in full, the rest by name, then commit
argument-hint: [optional context]
---

# Auto Commit (staged, fast)

Analyze the **staged** changes — reading the key files in full and the rest by
name — generate a Conventional Commits message, and create the commit
immediately. No editor prompt, no confirmation — this runs fully automatically.

This is the engine behind the `git ai` / `git aic` shell wrappers, which run
this skill headless via `claude -p` with `--permission-mode acceptEdits` and a
git-only `--allowedTools` allowlist — least privilege, not a full bypass.

Keep tool calls to a few: one overview, a handful of targeted diffs, the style
check, and the commit. Do **not** crawl the diff file by file — that is slow on
large changesets and rarely changes the message.

## Instructions

1. **Survey staged files in one shot**
   ```bash
   git diff --cached --stat
   ```
   - If there are no staged changes, print `No staged changes` and stop. Do not
     stage anything yourself — staging is the wrapper's job.
   - This single overview lists every file with its insertion/deletion counts —
     enough to judge which files actually need a close read.

2. **Read only the files that matter**
   From the `--stat` overview, pick the files carrying the substance of the
   change and read just those in full:
   ```bash
   git diff --cached -- <file>
   ```
   - Read in full the **largest few files** — rough guide: the top 3–5 by
     changed lines, or any file over ~30 changed lines.
   - For the rest, rely on the filename and its `--stat` insertion/deletion
     counts — do not diff them.
   - Skip the contents of lock/generated files (`*-lock.json`, `*.lock`,
     minified bundles) entirely — the filename is enough.
   - If the whole changeset is small (few files, low line count), just read it
     all; the goal is to avoid a long file-by-file crawl on big changesets, not
     to withhold context when it is cheap.

3. **Check commit style**
   ```bash
   git log -5 --oneline
   ```
   Match the repo's existing tone and language.

4. **Synthesize one commit message**
   Combine the per-file summaries into a single Conventional Commits message:
   ```
   <type>(<scope>): <subject>

   <body>
   ```
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
   - Subject: imperative mood, no trailing period, ≤50 chars
   - Body (only when the change needs explanation): *what* and *why*, not *how*;
     wrap at 72 chars
   - Use Japanese when the codebase/comments are primarily Japanese
   - `$ARGUMENTS`, if provided, is extra context from the user — weave it in
   - Pick `<scope>` from the dominant area of change; in this repo the common
     scopes are `zsh`, `nvim`, `tmux`, `git`, `claude`, `atuin`, `fonts`,
     `install`

5. **Commit immediately** — write the closing `EOF` at column 0 when you run it:
   ```bash
   git commit -F - <<'EOF'
   <type>(<scope>): <subject>

   <body if needed>
   EOF
   ```

6. **Verify**
   ```bash
   git log -1 --stat
   ```

## Safety

- Never commit `.env`, credentials, or key files. If a staged file looks
  sensitive, abort with a clear warning instead of committing.
- Never use `--no-verify` — let pre-commit hooks run.
- Commit only what is already staged; never run `git add`.

## Output

Keep it terse. Show only:
- `✓ Committed: <type>(<scope>): <subject>`
- The list of committed files
