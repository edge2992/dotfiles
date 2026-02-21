---
description: Smart git commit with AI-generated message
argument-hint: [optional commit message]
---

# Smart Git Commit

Generate an intelligent commit message and create a git commit.

## Instructions

1. **Check Git Status**
   - Run `git status` to see staged and unstaged changes
   - Run `git diff --cached` to see staged changes
   - Run `git log -3 --oneline` to understand commit style

2. **Analyze Changes**
   - If there are no staged changes, stage relevant files with `git add`
   - Understand the nature of changes (feature, fix, refactor, docs, etc.)
   - Identify the scope and impact

3. **Generate Commit Message**
   Follow Conventional Commits format:
   ```
   <type>(<scope>): <subject>

   <body>
   ```

   Types:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation changes
   - `style`: Formatting, missing semicolons, etc.
   - `refactor`: Code restructuring
   - `perf`: Performance improvements
   - `test`: Adding tests
   - `chore`: Maintenance tasks

   Guidelines:
   - Subject: Concise (50 chars or less), imperative mood
   - Body: Explain what and why (not how), wrap at 72 chars
   - Focus on the impact and reasoning
   - Use Japanese if changes are in Japanese context

4. **Create Commit**
   - Use heredoc for proper formatting:
   ```bash
   git commit -m "$(cat <<'EOF'
   Your commit message here
   EOF
   )"
   ```
   - If $ARGUMENTS is provided, use it as additional context

5. **Verify**
   - Run `git log -1` to show the created commit
   - Run `git status` to confirm

## Example Usage

```bash
# Basic usage
/commit

# With additional context
/commit Added user authentication feature

# After staging specific files
git add src/auth.ts
/commit
```

## Notes

- Only commit files that don't contain secrets
- Warn if attempting to commit .env, credentials, or sensitive files
- Keep commits atomic and focused
- Don't push automatically - let user decide when to push
