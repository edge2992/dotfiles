-- ref: https://github.com/craftzdog/dotfiles-public
require('base')
require('highlights')
require('maps')
require('plugins')

-- clipboard connect (linux, macos)
vim.opt.clipboard:append { 'unnamedplus' }

-- local has = function(x)
--   return vim.fn.has(x) == 1
-- end


