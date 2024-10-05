require("settings")
require("plugins")
require("maps")

local has = function(x)
	return vim.fn.has(x) == 1
end

local themeStatus, kanagawa = pcall(require, "kanagawa")

if themeStatus then
	vim.cmd("colorscheme kanagawa")
else
	return
end
