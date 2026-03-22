# Chezmoi Dotfiles

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). Source: `~/.local/share/chezmoi/` → Target: `~/`.
Platform: Linux (primary), macOS (secondary).

## chezmoi Naming Conventions

| Prefix/Suffix | Meaning | Example |
|--------------|---------|---------|
| `dot_` | `.` in target | `dot_zshrc` → `~/.zshrc` |
| `private_dot_` | `.` with 600/700 permissions | `private_dot_config/` → `~/.config/` |
| `run_once_` | Runs once on first apply | `run_once_install-packages.sh` |
| `run_onchange_` | Re-runs when content changes | `run_onchange_update.sh` |
| `.tmpl` | Go template (`{{ .variable }}`) | `dot_zshrc.tmpl` |
| `exact_` | Removes unmanaged files in target dir | `exact_dot_config/` |

Never rename chezmoi source files without understanding the naming convention impact.

## Templates

`.tmpl` files use Go template syntax. Template data comes from:
- `~/.config/chezmoi/chezmoi.toml` (runtime config, not in this repo)
- `.chezmoi.yaml.tmpl` (repo root — initial setup prompts for `email`, `name`, `op_account`)

## Testing & Linting

```bash
make lint          # Run all lints — required before committing
make lint-json     # JSON syntax only
```

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`: check-toml, check-yaml, end-of-file-fixer, trailing-whitespace, shellcheck, stylua, gitleaks, chezmoi-template-check.

Never bypass with `--no-verify` — investigate and fix failures.

## Workflow

1. Edit source files directly in this repo
2. `make lint` → `chezmoi diff` → `chezmoi apply`
3. Commit and create PR

## PR-Driven Development (Required)

All changes go through PRs. Never commit directly to main.

1. Create a branch (`feat/colorscheme`, `refactor/zsh-split`, etc.)
2. Use worktrees for parallel work on independent changes
3. `gh pr create` with issue reference (`Closes #XX`)
4. Self-review with code-reviewer agent before submitting
5. `gh pr checks <PR#>` — all CI must pass. Fix failures, never use `--admin` to bypass
6. Merge after review + CI pass

### Parallel Work Rules
- Use `isolation: "worktree"` for concurrent agents
- Never parallelize issues that touch the same files
- Review and merge each PR independently

## Commit Scopes

`zsh`, `nvim`, `tmux`, `git`, `claude`, `atuin`, `fonts`, `install`

## Important Notes

- `.tmpl` files contain Go template syntax — preserve `{{ }}` blocks
- `run_once_` scripts run only once; to re-run, delete state in `.chezmoistate.boltdb`
- After editing `dot_claude/`, run `chezmoi apply` to sync to `~/.claude/`
