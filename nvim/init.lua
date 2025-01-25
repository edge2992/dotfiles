require("settings")
require("plugins")
require("maps")

local themeStatus, _ = pcall(require, "solarized")

if themeStatus then
	vim.cmd("colorscheme solarized")
else
	return
end
