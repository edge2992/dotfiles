---
description: Ultra-fast commit using Haiku model
argument-hint: [optional context]
---

Use the Task tool to launch the fast-committer agent with model haiku.

Pass the following prompt:
"Create a git commit now. Additional context: $ARGUMENTS"

The fast-committer agent will:
1. Check git status and diff
2. Generate appropriate commit message
3. Execute the commit immediately
4. Verify the result

Be concise and fast.
