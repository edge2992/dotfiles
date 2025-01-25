require("settings")
require("plugins")
require("maps")

local has = function(x)
	return vim.fn.has(x) == 1
end

local themeStatus, solarized = pcall(require, "solarized")

if themeStatus then
	vim.cmd("colorscheme solarized")
else
	return
end
