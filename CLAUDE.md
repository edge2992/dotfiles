# Chezmoi Dotfiles — Project Guidelines

This repository manages personal dotfiles using [chezmoi](https://www.chezmoi.io/).
Claude should read this file to understand the project context before making any changes.

## Project Overview

- **Purpose**: Manage and synchronize personal dotfiles across machines
- **Tool**: chezmoi (dotfiles manager with templating support)
- **Source directory**: `~/.local/share/chezmoi/` (this repository)
- **Target directory**: `~/` (home directory)
- **Platform support**: Linux (primary), macOS (secondary)

## Repository Structure

```
.
├── CLAUDE.md                   # This file (project-specific Claude instructions)
├── README.md                   # Human-readable documentation
├── dot_claude/                 # → ~/.claude/ (Claude CLI configuration)
│   ├── CLAUDE.md               # Global Claude instructions (all projects)
│   ├── agents/                 # Custom subagent definitions
│   ├── commands/               # Custom slash command definitions
│   ├── settings.json           # Permission and security settings
│   └── settings.local.json     # Local preferences (not synced)
├── dot_gitconfig.tmpl          # → ~/.gitconfig (templated)
├── dot_ideavimrc               # → ~/.ideavimrc
├── dot_tmux.conf               # → ~/.tmux.conf
├── dot_zshenv                  # → ~/.zshenv
├── dot_zshrc.tmpl              # → ~/.zshrc (templated)
├── dot_atuin/                  # → ~/.atuin/
├── dot_local/                  # → ~/.local/
├── private_dot_config/         # → ~/.config/ (private permissions)
│   └── nvim/                   # Neovim configuration (Lua + lazy.nvim)
└── run_once_install-*.sh.tmpl  # One-time installation scripts
```

## chezmoi File Naming Conventions

chezmoi uses filename prefixes and suffixes to control how files are managed:

| Prefix/Suffix | Meaning | Example |
|--------------|---------|---------|
| `dot_` | Maps to `.` in target | `dot_zshrc` → `~/.zshrc` |
| `private_dot_` | Maps to `.` with restricted permissions (600/700) | `private_dot_config/` → `~/.config/` |
| `run_once_` | Script runs once on first apply | `run_once_install-packages.sh` |
| `run_onchange_` | Script runs when content changes | `run_onchange_update.sh` |
| `.tmpl` | chezmoi template (supports `{{ .variable }}` syntax) | `dot_zshrc.tmpl` |
| `exact_` | Remove unmanaged files from target dir | `exact_dot_config/` |

**Important**: Never rename chezmoi source files without understanding the naming convention impact.

## chezmoi Template Syntax

Files ending in `.tmpl` support Go template syntax with chezmoi variables:

```
{{ .email }}          # User email (from chezmoi data)
{{ .github_user }}    # GitHub username
{{ if eq .chezmoi.os "linux" }} ... {{ end }}   # OS-conditional blocks
{{ .chezmoi.homeDir }}  # Home directory path
```

Template data is defined in `~/.config/chezmoi/chezmoi.toml` (not in this repo).

## Key chezmoi Commands

```bash
# Preview changes before applying
chezmoi diff

# Apply source to home directory
chezmoi apply

# Edit a target file (chezmoi manages source)
chezmoi edit ~/.zshrc

# Add a new file to chezmoi management
chezmoi add ~/.new-config

# Update from git remote
chezmoi update

# Verify template rendering
chezmoi execute-template < dot_zshrc.tmpl
```

## Development Workflow

1. **Edit source files directly** in this repository (preferred for Claude)
2. Run `chezmoi diff` to verify the changes look correct
3. Run `chezmoi apply` to apply changes to the home directory
4. Commit with Conventional Commits format

## Commit Message Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>
```

**Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`

**Scopes** (for this repo): `zsh`, `nvim`, `tmux`, `git`, `claude`, `atuin`, `fonts`, `install`

**Examples**:
```
feat(claude): add code-reviewer subagent
chore(zsh): add direnv initialization
fix(nvim): resolve LSP server startup issue
```

## Important Notes

- **Never commit sensitive data**: `.env` files, private keys, tokens, or passwords
- **Template files require care**: `.tmpl` files contain Go template syntax — preserve `{{ }}` blocks
- **Installation scripts are idempotent**: `run_once_` scripts execute only once; to re-run, delete the state in `~/.local/share/chezmoi/.chezmoistate.boltdb`
- **Platform conditionals**: Check existing patterns before adding OS-specific code
- **dot_claude/ changes**: After editing `dot_claude/`, run `chezmoi apply` for changes to take effect in `~/.claude/`
