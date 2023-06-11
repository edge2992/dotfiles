# Dotfiles Installation Script

This bash script is designed to automate the setup of a development environment,
specifically by cloning a set of dotfiles and setting up various tools and configurations.

## IMPORTANT NOTICE:

Before running this script, please make sure to **backup your existing configuration files**.
This script will create symbolic links for the downloaded dotfiles, which might replace your current configurations if they have the same filenames.
Always ensure your important data and configurations are backed up before running scripts like these.

## Commands

- `download`: This command downloads the dotfiles from a remote GitHub repository. If they already exist, it skips the download. It also downloads `fzf` and `packer.nvim`.

- `brew-install`: This command runs the `brew bundle` command using the Brewfile in the dotfiles. It is meant to be executed only on macOS.

- `font-nerd`: This command clones the `nerd-fonts` repository and installs the `Hack` and `Meslo` fonts.

- `color-theme`: This command clones the `Gogh` repository and installs the `tokyo-night-storm`, `tokyo-night`, and `twilight` themes for the gnome terminal.

- `deploy`: This command creates symbolic links for the downloaded dotfiles in the home directory or the `.config` directory for Neovim configuration.

## Usage

1. Ensure you have `git` installed on your system.
2. Run the script in your terminal with `./bootstrap.sh`.
3. When prompted, enter one of the commands as described above. If the command is not recognized, it will prompt again.

Please remember to review any script before running it, especially those that require root privileges.

## Detailed Description

### Neovim

- `:PackerSync`: This command, provided by the `packer.nvim` package manager, is used to keep your plugin setup up-to-date.

- `:checkhealth`: This is a built-in Neovim command that provides a health-checking mechanism. When you run `:checkhealth`, it checks the status of your Neovim setup and outputs a report. It helps you identify common issues and provides suggestions for how to fix them.

| Plugin                            | Description                                    |
| --------------------------------- | ---------------------------------------------- |
| wbthomason/packer.nvim            | Plugin manager for NeoVim                      |
| nvim-lua/plenary.nvim             | Set of reusable Lua utilities                  |
| nvim-tree/nvim-web-devicons       | Adds file type icons                           |
| rebelot/kanagawa.nvim             | Color scheme                                   |
| nvim-lualine/lualine.nvim         | Status line plugin                             |
| akinsho/bufferline.nvim           | Enhanced buffer line                           |
| folke/which-key.nvim              | Shows available key mappings                   |
| phaazon/hop.nvim                  | Quick cursor movement                          |
| nvim-treesitter/nvim-treesitter   | Better syntax highlighting and text objects    |
| nvim-telescope/telescope.nvim     | Powerful fuzzy finder, file sorter, and picker |
| neovim/nvim-lspconfig             | Configurations for built-in LSP                |
| onsails/lspkind-nvim              | Show pictograms on autocompletion              |
| L3MON4D3/LuaSnip                  | Snippets plugin                                |
| hrsh7th/nvim-cmp                  | Autocompletion plugin                          |
| hrsh7th/cmp-nvim-lsp              | LSP source for nvim-cmp                        |
| hrsh7th/cmp-path                  | Filepath completion for nvim-cmp               |
| hrsh7th/cmp-buffer                | In-buffer completion for nvim-cmp              |
| jose-elias-alvarez/null-ls.nvim   | Diagnostics, code actions, and more via Lua    |
| williamboman/mason.nvim           | Portable package manager                       |
| williamboman/mason-lspconfig.nvim | Mason integration with LSP                     |
| nvim-neo-tree/neo-tree.nvim       | File system explorer                           |
| norcalli/nvim-colorizer.lua       | Color highlighting for color codes             |
| akinsho/toggleterm.nvim           | Terminal management                            |
| lewis6991/gitsigns.nvim           | Show git changes in sign column                |
| iamcco/markdown-preview.nvim      | Markdown file preview                          |
| windwp/nvim-autopairs             | Auto closing of pairs                          |
| tpope/vim-commentary              | Code commenting                                |
| xiyaowong/nvim-transparent        | Background transparency                        |

### Tmux

The tmux configuration script included in the dotfiles configures the status bar's appearance, pane navigation, color support, history size, and more.
It also installs a range of useful tmux plugins.

### Zsh

The Zsh configuration file sets up a wide variety of aliases, functions, and plugins designed to optimize your terminal usage.
The configuration uses Zinit for managing Zsh plugins, providing a flexible and fast framework for managing your Zsh environment.

## Contribution

If you have any issues or suggestions, please open an issue or a pull request on the GitHub repository. Your feedback is welcome and appreciated.
