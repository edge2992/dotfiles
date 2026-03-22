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
├── CLAUDE.md                   # Project-specific Claude instructions
├── Makefile                    # Lint targets (make lint)
├── README.md                   # Human-readable documentation
├── .chezmoi.yaml.tmpl          # chezmoi config template (template data)
├── .chezmoiexternal.toml       # External file sources
├── .chezmoiignore              # Files excluded from chezmoi apply
├── .github/                    # GitHub Actions workflows
├── .pre-commit-config.yaml     # Pre-commit hooks config
├── docs/                       # Documentation
├── dot_claude/                 # → ~/.claude/ (Claude CLI configuration)
│   ├── CLAUDE.md               # Global Claude instructions (all projects)
│   ├── agents/                 # Custom subagent definitions
│   ├── hooks/                  # Event-triggered hooks
│   ├── private_plugins/        # Plugin configuration
│   ├── settings.json           # Permission and security settings
│   ├── shell-snapshots/        # Shell environment snapshots
│   ├── skills/                 # Custom skill definitions
│   └── statusline.py           # Status line configuration
├── dot_gitconfig.tmpl          # → ~/.gitconfig (templated)
├── dot_ideavimrc               # → ~/.ideavimrc
├── dot_tmux.conf               # → ~/.tmux.conf
├── dot_zshenv.tmpl             # → ~/.zshenv (templated)
├── dot_zshrc.tmpl              # → ~/.zshrc (templated)
├── dot_atuin/                  # → ~/.atuin/
├── dot_local/                  # → ~/.local/
├── private_dot_config/         # → ~/.config/ (private permissions)
│   ├── nvim/                   # Neovim configuration (Lua + lazy.nvim)
│   ├── gh/                     # GitHub CLI configuration
│   ├── git/                    # Git config (ignore, attributes)
│   ├── private_fcitx5/         # Fcitx5 input method configuration
│   ├── sheldon/                # Zsh plugin manager
│   ├── starship.toml           # Starship prompt configuration
│   ├── wezterm/                # WezTerm terminal configuration
│   └── zsh/                    # Zsh configuration modules
├── run_once_install-*.sh.tmpl  # One-time installation scripts
└── run_onchange_*.sh.tmpl      # Scripts that re-run on content change
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

**Note**: `.chezmoi.yaml.tmpl` (リポジトリルート) が chezmoi 初期設定時のテンプレートデータ (`email`, `name`, `op_account`) を定義している。

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

## Testing

```bash
# Run all lints (JSON validation etc.)
make lint

# JSON syntax validation only
make lint-json
```

**コミット前に必ず `make lint` を実行すること。**

## Pre-commit Hooks

`.pre-commit-config.yaml` により、コミット時に以下が自動実行される:

- **check-toml / check-yaml**: 構文チェック
- **end-of-file-fixer / trailing-whitespace**: フォーマット自動修正
- **shellcheck**: シェルスクリプトの静的解析
- **stylua**: Lua コードのフォーマットチェック
- **gitleaks**: シークレット漏洩検知
- **chezmoi-template-check**: `.tmpl` ファイルのテンプレート構文検証

フックが失敗した場合は原因を調査し、`--no-verify` で迂回しないこと。

## Development Workflow

1. **Edit source files directly** in this repository (preferred for Claude)
2. Run `make lint` to validate file syntax
3. Run `chezmoi diff` to verify the changes look correct
4. Run `chezmoi apply` to apply changes to the home directory
5. Commit with Conventional Commits format

## PR-Driven Development (必須)

すべての変更はPRベースで行う。直接mainにコミットしない。

1. **ブランチ作成**: issue番号に基づくブランチ名 (`feat/colorscheme`, `refactor/zsh-split` 等)
2. **実装**: worktreeを使い、独立した変更は並列で作業する
3. **PR作成**: `gh pr create` でPRを作成。bodyにissue番号を含める (`Closes #XX`)
4. **レビュー**: code-reviewer エージェントでセルフレビューを実施してからPRを出す
5. **CI確認**: `gh pr checks <PR番号>` でCIが全て通過していることを確認する。失敗時は修正してから次へ進む
6. **マージ**: レビュー通過かつCI通過後にマージ。`--admin` でのCI迂回は禁止

### 並列作業時のルール
- **worktree必須**: 並列作業時は `isolation: "worktree"` でエージェントを起動する
- **独立性の確認**: 同じファイルを変更するissueは並列にしない
- **レビュー後にマージ**: 各PRは個別にレビュー・マージする

## Commit Message Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>
```

**Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`

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
