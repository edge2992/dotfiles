local global = vim.g
local o = vim.o

vim.scriptencoding = "utf-8"

-- Map <leaders>

global.mapleader = " " -- Set leader key to space
global.maplocalleader = " " -- Set local leader key to space

-- Editor options

o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus" -- Use system clipboard
o.syntax = "on" -- Enable syntax highlighting
o.autoindent = true
o.cursorline = true
o.expandtab = true -- Convert tabs to spaces
o.shiftwidth = 2
o.tabstop = 2
o.encoding = "utf-8"
o.mouse = "a" -- Enable mouse support in all modes
o.title = true
o.hidden = true
o.ttimeoutlen = 0
o.wildmenu = true
o.showcmd = true
o.showmatch = true
o.inccommand = "split" -- Show live preview of substitution commands
o.splitright = true -- Open new splits to the right
o.termguicolors = true -- Enable true color support
