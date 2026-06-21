---
description: Stage-aware auto commit — analyze staged diff file by file, then commit
argument-hint: [optional context]
---

# Auto Commit (staged, file-by-file)

Analyze the **staged** changes incrementally (file by file), generate a
Conventional Commits message, and create the commit immediately. No editor
prompt, no confirmation — this runs fully automatically.

This is the engine behind the `git ai` / `git aic` shell wrappers, which run
this skill headless via `claude -p` with `--permission-mode acceptEdits` and a
git-only `--allowedTools` allowlist — least privilege, not a full bypass.

## Instructions

1. **List staged files**
   ```bash
   git diff --cached --stat
   ```
   - If there are no staged changes, print `No staged changes` and stop. Do not
     stage anything yourself — staging is the wrapper's job.

2. **Read the diff incrementally — one file at a time**
   For each staged file, inspect its diff on its own rather than reading the
   whole diff at once. This keeps large changesets accurate.
   ```bash
   git diff --cached -- <file>
   ```
   - For a very large file, walk it hunk by hunk.
   - For each file, note a one-line summary of *what changed and why*.

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
