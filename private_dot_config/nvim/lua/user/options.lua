local opt = vim.opt


-- Browse
opt.number = true
opt.relativenumber = true
opt.cursorline = true


-- Indent
opt.expandtab = true -- convert tabs to space
opt.shiftwidth = 2
opt.tabstop = 2


-- Search
opt.ignorecase = true
opt.smartcase = true


-- clipboard
opt.clipboard = "unnamedplus" -- use system clipboard
