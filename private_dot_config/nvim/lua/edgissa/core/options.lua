local opt = vim.opt

-- Disable optional providers to suppress warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- Node provider is unused (no node rplugins) and Volta's global model
-- doesn't satisfy nvim's detection; disable to silence the warning
vim.g.loaded_node_provider = 0

-- Point Neovim to the dedicated Python venv if it exists (macOS); falls back to system python3
local nvim_py = vim.fn.expand("~/.local/share/neovim-python/bin/python")
if vim.fn.executable(nvim_py) == 1 then
  vim.g.python3_host_prog = nvim_py
end

-- Browse
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true

-- Tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- Search
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true

-- Clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard

-- Split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Editing
opt.syntax = "on"
opt.ttimeoutlen = 0
opt.wildmenu = true
opt.showmatch = true
opt.inccommand = "split"

-- Command
opt.showcmd = true
