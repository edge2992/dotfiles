# tmux-claude-session-manager Integration Design

## Goal

Replace the home-grown `claude-inbox` hook/CLI (added in PR #130) with
[craftzdog/tmux-claude-session-manager](https://github.com/craftzdog/tmux-claude-session-manager),
a TPM plugin that reads Claude Code's own `claude agents --json` state
(no hooks needed) to list running agents, show live status, preview, jump,
and kill them from a single fzf popup — plus a launcher for new sessions.

## Design Decisions

- **Full migration, not coexistence**: the new plugin's picker (`prefix+u`)
  supersedes claude-inbox's picker (`prefix+a`) for the "jump to a waiting
  session" use case. claude-inbox's only feature the new plugin lacks — the
  always-visible `⏳ N` status-bar badge — is deliberately given up in favor
  of a single, hook-free source of truth. Decided with the user; see prior
  turn.
- **Install method**: TPM, consistent with the other plugins already in
  `dot_tmux.conf` (`tmux-yank`, `tmux-mem-cpu-load`, `catppuccin/tmux`). No
  new install script needed — `run_onchange_after_install-tmux-plugins.sh.tmpl`
  re-triggers `tpm/bin/install_plugins` whenever `dot_tmux.conf`'s content
  hash changes.
- **Prerequisites already satisfied**: tmux 3.7b (>= 3.2 required), fzf, jq,
  Claude Code 2.1.205 (>= 2.1.139 required) are all present on this machine.
- **No keybinding conflicts**: claude-inbox used `prefix+a`; the new plugin
  defaults to `prefix+u` (picker) and `prefix+y` (launcher). All three keys
  are free of collisions in the current `dot_tmux.conf`.
- **Options**: keep plugin defaults (no `@claude_*` overrides) — matches this
  repo's "minimal configuration" pattern for other plugins.

## Implementation

### 1. `dot_tmux.conf`

- Add to the plugin list (after `catppuccin/tmux`, before `run '~/.tmux/plugins/tpm/tpm'`):
  ```tmux
  set -g @plugin 'craftzdog/tmux-claude-session-manager'
  ```
- Remove the entire "Claude Inbox" block (comment + `status-right` append +
  `bind a display-popup ...`).

### 2. Remove claude-inbox files

- Delete `dot_local/bin/executable_claude-inbox`
- Delete `dot_claude/hooks/executable_claude-inbox-hook.sh`

### 3. `.chezmoitemplates/claude-settings-base.json`

Remove every `claude-inbox-hook.sh` hook registration:

- `Notification`: drop the second `permission_prompt` matcher object (the one
  calling `claude-inbox-hook.sh`); keep `permission-notify.sh`.
- `Stop`: drop the second `""` matcher object (`claude-inbox-hook.sh`); keep
  `stop-review.sh`.
- `SessionEnd`: drop the second `""` matcher object (`claude-inbox-hook.sh`);
  keep `worklog.sh`.
- `UserPromptSubmit`: this key has only the `claude-inbox-hook.sh` entry —
  remove the whole key.

### No changes needed

- No new install script: existing TPM `run_onchange` script handles it via
  the `dot_tmux.conf` content hash.
- No settings-sync/hook wiring beyond the JSON removals above (grep confirmed
  no other file references `claude-inbox`).

## Verification

1. `make lint` — JSON validity + template rendering
2. `chezmoi diff --source <this worktree>` — confirm only the intended files
   change (deletions + `dot_tmux.conf` + `claude-settings-base.json`)
3. Do NOT `chezmoi apply` before merge (standing rule)

## Scope

- 2 file deletions, 2 file edits
- No new install scripts
- Update the `claude-setup-3-pillar-roadmap` memory: pillar 2 migrated from
  local claude-inbox (PR #130) to tmux-claude-session-manager
