# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- **Shell**: Zsh configuration with Starship prompt, sheldon plugin manager, and Go binary path setup
- **Git**: Git configuration with color settings and nvim as default editor
- **Tmux**: Terminal multiplexer configuration with plugin manager
- **Neovim**: Lua-based configuration
- **Development Tools**: Automated installation of essential development tools
- **Fonts**: Nerd Fonts support for enhanced shell experience

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) - dotfiles manager
- Git

## Installation

1. Install chezmoi:
   ```bash
   # macOS
   brew install chezmoi
   
   # Linux
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. Initialize and apply dotfiles:
   ```bash
   chezmoi init --apply https://github.com/edge2992/dotfiles.git
   ```

## What Gets Installed

### Configuration Files
- `.zshrc` - Zsh shell configuration
- `.zshenv` - Zsh environment variables
- `.gitconfig` - Git configuration
- `.tmux.conf` - Tmux configuration
- `~/.config/nvim/` - Neovim configuration

### Development Tools (Auto-installed)
- **fzf** - Fuzzy finder
- **memo** - Note-taking tool (`github.com/mattn/memo`)
- **ghq** - Git repository manager (`github.com/x-motemen/ghq`)
- **uv** - Python package manager
- **tmux** - Terminal multiplexer
- **tpm** - Tmux plugin manager
- **volta** - JavaScript tool manager
- **Node.js** - Via volta
- **aicommits** - AI-powered commit messages
- **claude-code** - Anthropic's Claude CLI
- **cargo** - Rust package manager
- **sheldon** - Zsh plugin manager
- **starship** - Cross-shell prompt
- **Nerd Fonts** - Patched fonts for better terminal experience

## Usage

### Managing Dotfiles
```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply

# Check what would change
chezmoi diff

# Update from repository
chezmoi update
```

### Platform Support
- **macOS**: Uses Homebrew for package installation
- **Linux**: Uses apt package manager and manual installation

## Font Setup

The Starship prompt requires a Nerd Font to display icons correctly. Nerd Fonts are automatically installed via the `run_once_install-fonts.sh.tmpl` script (Ubuntu Mono Nerd Font). After installation, configure your terminal:

### macOS (iTerm2)

1. **Configure iTerm2:**
   - Open iTerm2 → Preferences (`Cmd + ,`)
   - Go to Profiles → Text
   - Change Font to "UbuntuMono Nerd Font" or "UbuntuMono NF"
   - Set size to 14pt or your preference

### Ubuntu (Terminal)

1. **Configure Terminal:**
   - Open Terminal → Preferences
   - Go to your profile → Text
   - Uncheck "Use system fixed-width font"
   - Change Custom font to "UbuntuMono Nerd Font Regular"
   - Set size to 12pt or your preference

**Note:** 
- Fonts are automatically installed during chezmoi setup
- To skip font installation, set `SKIP_NERD_FONTS_INSTALL=true` before running chezmoi
- Restart your terminal application after setup for fonts to take effect

## Customization

The configuration supports different operating systems through chezmoi templates. Installation scripts automatically detect your OS and install appropriate packages.

## Structure

```
.
├── dot_gitconfig           # Git configuration
├── dot_tmux.conf          # Tmux configuration  
├── dot_zshenv             # Zsh environment variables
├── dot_zshrc              # Zsh configuration
├── private_dot_config/    # Private config directory
│   └── nvim/             # Neovim configuration
└── run_once_*.sh.tmpl    # Installation scripts
```
