# tmux-claude-session-manager Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install the `craftzdog/tmux-claude-session-manager` TPM plugin and fully remove the home-grown `claude-inbox` hook/CLI (PR #130) it supersedes.

**Architecture:** This is a dotfiles (chezmoi) repo with no application test suite — "tests" here are `make lint` (JSON/template validity) and `chezmoi diff` (preview of what would land in `$HOME`). Each task ends with both passing. No `chezmoi apply` until after merge (repo standing rule).

**Tech Stack:** chezmoi, tmux 3.7b + TPM, bash, jq, jsonnet-adjacent JSON template (`.chezmoitemplates/claude-settings-base.json`), GNU Make.

## Global Constraints

- Prerequisites for the new plugin (tmux >= 3.2, fzf, jq, Claude Code >= 2.1.139) are already installed on this machine — no install steps needed for them.
- Never run `chezmoi apply` before the PR is merged (repo CLAUDE.md standing rule).
- Never bypass pre-commit hooks with `--no-verify`.
- `make lint` must pass before every commit in this plan.
- Full removal of claude-inbox, no coexistence (decided with user during brainstorming) — do not leave partial/commented-out remnants.

---

### Task 1: Add tmux-claude-session-manager plugin

**Files:**
- Modify: `dot_tmux.conf:97-103` (plugin list block)

**Interfaces:**
- Produces: `dot_tmux.conf` plugin list includes `craftzdog/tmux-claude-session-manager`, still terminated by `run '~/.tmux/plugins/tpm/tpm'`.

- [ ] **Step 1: Add the plugin line**

In `dot_tmux.conf`, the current plugin block (matched from the repo read) is:

```tmux
# -----------------------
# Plugin Config
# -----------------------
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'thewtex/tmux-mem-cpu-load'
set -g @plugin 'catppuccin/tmux'

run '~/.tmux/plugins/tpm/tpm'
```

Replace with:

```tmux
# -----------------------
# Plugin Config
# -----------------------
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'thewtex/tmux-mem-cpu-load'
set -g @plugin 'catppuccin/tmux'
set -g @plugin 'craftzdog/tmux-claude-session-manager'

run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 2: Lint**

Run: `make lint-json && make lint-tmpl`
Expected: both exit 0 (this file isn't JSON/tmpl, so these should be unaffected no-ops for it — they just must still pass overall).

- [ ] **Step 3: Commit**

```bash
git add dot_tmux.conf
git commit -m "feat(tmux): add tmux-claude-session-manager plugin"
```

---

### Task 2: Remove claude-inbox files and tmux.conf wiring

**Files:**
- Delete: `dot_local/bin/executable_claude-inbox`
- Delete: `dot_claude/hooks/executable_claude-inbox-hook.sh`
- Modify: `dot_tmux.conf` (remove the "Claude Inbox" block added after the plugin section)

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: no remaining reference to `claude-inbox` in `dot_tmux.conf` or the filesystem paths above.

- [ ] **Step 1: Delete the CLI and hook scripts**

```bash
git rm dot_local/bin/executable_claude-inbox
git rm dot_claude/hooks/executable_claude-inbox-hook.sh
```

- [ ] **Step 2: Remove the Claude Inbox block from `dot_tmux.conf`**

Delete this block entirely (currently the last section of the file, right after the Pane Style override that follows TPM):

```tmux
# -----------------------
# Claude Inbox (after TPM so it appends to Catppuccin's status-right)
# -----------------------
# Shows "⏳ N" while Claude sessions wait for input; prefix+a opens a fzf
# picker that jumps to the waiting pane. Absolute path: tmux #() and popups
# don't reliably have ~/.local/bin on PATH.
set -ga status-right "#($HOME/.local/bin/claude-inbox status)"
bind a display-popup -E -w 80% -h 60% "$HOME/.local/bin/claude-inbox pick"
```

The file should now end with the `Pane Style (after TPM ...)` block (the four `set -g window-style` / `pane-border-style` lines) and nothing after it.

- [ ] **Step 3: Verify no remaining references**

Run: `grep -rn "claude-inbox" dot_tmux.conf dot_local dot_claude 2>/dev/null || echo "clean"`
Expected: `clean` (no matches) — `.chezmoitemplates/claude-settings-base.json` is handled separately in Task 3.

- [ ] **Step 4: Lint**

Run: `make lint`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add dot_tmux.conf
git commit -m "chore(tmux): remove claude-inbox in favor of session-manager"
```

---

### Task 3: Remove claude-inbox-hook.sh registrations from settings template

**Files:**
- Modify: `.chezmoitemplates/claude-settings-base.json` (hooks: `Notification`, `Stop`, `SessionEnd`, `UserPromptSubmit`)

**Interfaces:**
- Consumes: nothing from Tasks 1-2.
- Produces: valid JSON with no `claude-inbox-hook.sh` command references; `UserPromptSubmit` key removed entirely (it had no other hook).

- [ ] **Step 1: Remove the claude-inbox-hook entry from `Notification`**

Current (verified via read of the file):

```json
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/permission-notify.sh"
          }
        ]
      },
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/claude-inbox-hook.sh"
          }
        ]
      }
    ],
```

Replace with:

```json
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/permission-notify.sh"
          }
        ]
      }
    ],
```

- [ ] **Step 2: Remove the claude-inbox-hook entry from `Stop`**

Current:

```json
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/stop-review.sh"
          }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/claude-inbox-hook.sh"
          }
        ]
      }
    ],
```

Replace with:

```json
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/stop-review.sh"
          }
        ]
      }
    ],
```

- [ ] **Step 3: Remove the claude-inbox-hook entry from `SessionEnd`**

Current:

```json
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/worklog.sh"
          }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/claude-inbox-hook.sh"
          }
        ]
      }
    ],
```

Replace with:

```json
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/worklog.sh"
          }
        ]
      }
    ],
```

- [ ] **Step 4: Remove the whole `UserPromptSubmit` key**

Current (immediately follows `SessionEnd`'s closing `],`):

```json
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/claude-inbox-hook.sh"
          }
        ]
      }
    ]
  },
```

Replace with (note: `SessionEnd`'s closing bracket must become the last entry before `},`, so its trailing comma is removed too):

```json
  },
```

i.e. the `"hooks": { ... }` object's closing now reads:

```json
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/worklog.sh"
          }
        ]
      }
    ]
  },
```

- [ ] **Step 5: Verify JSON validity and no remaining references**

Run: `python3 -c "import json; json.load(open('.chezmoitemplates/claude-settings-base.json'))" && grep -c "claude-inbox" .chezmoitemplates/claude-settings-base.json`
Expected: no JSON parse error, and grep prints `0` (or exits non-zero for "no matches" depending on grep version — either way, zero matches).

- [ ] **Step 6: Lint**

Run: `make lint`
Expected: exit 0.

- [ ] **Step 7: Commit**

```bash
git add .chezmoitemplates/claude-settings-base.json
git commit -m "chore(claude): drop claude-inbox-hook from settings template"
```

---

### Task 4: Full verification and PR

**Files:** none (verification + memory update only)

**Interfaces:**
- Consumes: final state of Tasks 1-3.
- Produces: pushed branch + opened PR.

- [ ] **Step 1: Full repo lint**

Run: `make lint`
Expected: exit 0.

- [ ] **Step 2: Preview what chezmoi would apply**

Run: `chezmoi diff --source /Users/edgissa/.local/share/chezmoi/.claude/worktrees/feat-tmux-claude-session-manager`
Expected: diff shows only `~/.tmux.conf` changes, `~/.local/bin/claude-inbox` removal, `~/.claude/hooks/claude-inbox-hook.sh` removal, and `~/.claude/settings.json` hook removals — nothing else. Do NOT run `chezmoi apply`.

- [ ] **Step 3: Update the `claude-setup-3-pillar-roadmap` memory**

Edit `/Users/edgissa/.claude/projects/-Users-edgissa--local-share-chezmoi/memory/claude-setup-3-pillar-roadmap.md`: note that pillar 2 migrated from the local `claude-inbox` (PR #130) to `tmux-claude-session-manager` (this PR), and why (feature superset: live preview, kill, launcher, no hook maintenance).

- [ ] **Step 4: Push and open PR**

```bash
git push -u origin feat/tmux-claude-session-manager
gh pr create --title "feat(tmux): migrate to tmux-claude-session-manager" --body "$(cat <<'EOF'
## Summary
- Add craftzdog/tmux-claude-session-manager as a TPM plugin (prefix+u picker, prefix+y launcher)
- Fully remove the claude-inbox hook/CLI (PR #130) it supersedes — no hooks, no status-bar polling needed, agent status now read directly from `claude agents --json`

## Test plan
- [ ] `make lint` passes
- [ ] `chezmoi diff` shows only the expected file changes
- [ ] After merge + `chezmoi apply`: `prefix+I` installs the plugin via TPM, `prefix+u` opens the picker, `prefix+y` launches a session
EOF
)"
```

- [ ] **Step 5: Watch CI and merge**

Run: `gh pr checks <PR#> --watch`
Expected: all checks green. Once green, merge (repo standing rule: no need to ask again once checks pass).

---

## Self-Review Notes

- **Spec coverage:** Task 1 covers spec §1 (plugin install); Task 2 covers spec §2 items 1-2 (tmux.conf + file deletions); Task 3 covers spec §2 item 3 (settings template); Task 4 covers spec's Verification section + the memory-update scope item.
- **No placeholders:** every JSON/tmux block is the literal before/after content, taken from the actual file reads earlier in this session.
- **Consistency:** all three commands (`git rm`, edits, lint) reference exact paths matching the spec.
