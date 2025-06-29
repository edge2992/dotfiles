local opt = vim.opt

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
opt.expandtab = true -- convert tabs to space

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
